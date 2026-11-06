"""Generate a full OTClient minimap (.otmm) from a server .otbm map.

Usage: python -I generate_otmm.py <map.otbm> <appearances.dat> <output.otmm>

Reproduces OTClient's own per-tile minimap logic (Minimap::updateTile and
Tile::getMinimapColorByte) using appearance flags instead of items.otb, which
15.x clients no longer ship.
"""
import math
import re
import struct
import sys
import zlib

BLOCK = 64
TILE_BYTES = 3
FLAG_SEEN, FLAG_NOT_PATHABLE, FLAG_NOT_WALKABLE = 1, 2, 4
OTMM_SIGNATURE = 0x4D4D544F

NODE_START, NODE_END, ESCAPE = 0xFE, 0xFF, 0xFD
OTBM_TILE_AREA, OTBM_TILE, OTBM_ITEM, OTBM_HOUSETILE = 4, 5, 6, 14
ATTR_TILE_FLAGS, ATTR_ITEM = 3, 9


# --- minimal protobuf reader -------------------------------------------------
def varint(buf, i):
    result = shift = 0
    while True:
        b = buf[i]
        i += 1
        result |= (b & 0x7F) << shift
        if b < 0x80:
            return result, i
        shift += 7


def fields(buf):
    i, n = 0, len(buf)
    while i < n:
        key, i = varint(buf, i)
        num, wire = key >> 3, key & 7
        if wire == 0:
            val, i = varint(buf, i)
        elif wire == 2:
            ln, i = varint(buf, i)
            val = buf[i:i + ln]
            i += ln
        elif wire == 5:
            val = buf[i:i + 4]
            i += 4
        elif wire == 1:
            val = buf[i:i + 8]
            i += 8
        else:
            raise ValueError(f"unsupported wire type {wire}")
        yield num, val


class Kind:
    __slots__ = ("color", "ground", "special", "unpass", "avoid", "speed")

    def __init__(self):
        self.color = 0
        self.ground = self.special = self.unpass = self.avoid = False
        self.speed = 0


def load_appearances(path):
    data = open(path, "rb").read()
    kinds = {}
    for num, obj in fields(data):
        if num != 1:  # Appearances.object
            continue
        oid, flags = None, None
        for f, v in fields(obj):
            if f == 1:
                oid = v
            elif f == 3:
                flags = v
        if oid is None or flags is None:
            continue
        k = Kind()
        for f, v in fields(flags):
            if f == 1:  # bank
                k.ground = True
                for bf, bv in fields(v):
                    if bf == 1:
                        k.speed = bv
            elif f in (2, 3, 4) and v:  # clip / bottom / top
                k.special = True
            elif f == 13 and v:
                k.unpass = True
            elif f == 16 and v:
                k.avoid = True
            elif f == 30:  # automap
                for af, av in fields(v):
                    if af == 1:
                        k.color = av
        kinds[oid] = k
    return kinds


# --- OTBM streaming parser ---------------------------------------------------
def walk_otbm(path, on_tile):
    raw = open(path, "rb").read()
    stack = []  # entries: [type, bytearray data, items list, extra]
    pos = 4  # skip file identifier
    specials = re.compile(rb"[\xfd\xfe\xff]")
    n = len(raw)
    area = None
    while pos < n:
        m = specials.search(raw, pos)
        end = m.start() if m else n
        if stack and end > pos:
            stack[-1][1] += raw[pos:end]
        if not m:
            break
        c = raw[end]
        if c == ESCAPE:
            if stack:
                stack[-1][1].append(raw[end + 1])
            pos = end + 2
        elif c == NODE_START:
            if stack and stack[-1][0] == OTBM_TILE_AREA and area is None:
                d = stack[-1][1]
                area = struct.unpack_from("<HHB", d, 0)
            stack.append([raw[end + 1], bytearray(), [], None])
            pos = end + 2
        else:  # NODE_END
            node = stack.pop()
            ntype, data = node[0], node[1]
            if ntype == OTBM_ITEM:
                if stack and len(data) >= 2:
                    stack[-1][2].append(struct.unpack_from("<H", data, 0)[0])
            elif ntype in (OTBM_TILE, OTBM_HOUSETILE):
                handle_tile(ntype, data, node[2], area, on_tile)
            elif ntype == OTBM_TILE_AREA:
                area = None
            pos = end + 1


def handle_tile(ntype, data, children, area, on_tile):
    if area is None or len(data) < 2:
        return
    x = area[0] + data[0]
    y = area[1] + data[1]
    i = 2
    if ntype == OTBM_HOUSETILE:
        i += 4
    items = []
    while i < len(data):
        attr = data[i]
        i += 1
        if attr == ATTR_TILE_FLAGS:
            i += 4
        elif attr == ATTR_ITEM:
            items.append(struct.unpack_from("<H", data, i)[0])
            i += 2
        else:
            break
    on_tile(x, y, area[2], items + children)


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    otbm, appearances, out = sys.argv[1:]
    kinds = load_appearances(appearances)
    print(f"appearances: {len(kinds)} objects")

    default = bytes([0, 255, 10]) * (BLOCK * BLOCK)
    blocks = {}
    count = [0]

    def on_tile(x, y, z, ids):
        things = [kinds.get(i) for i in ids]
        things = [t for t in things if t is not None]
        if not things:
            return
        color = 0
        for t in reversed(things):  # top-most first, like Tile::getMinimapColorByte
            if not (t.ground or t.special):
                continue
            if t.color:
                color = t.color
                break
        if color == 0:
            color = 255
        ground = next((t for t in things if t.ground), None)
        flags = FLAG_SEEN
        if ground is None or any(t.unpass for t in things):
            flags |= FLAG_NOT_WALKABLE
        if any(t.avoid for t in things):
            flags |= FLAG_NOT_PATHABLE
        speed = min(math.ceil((ground.speed if ground else 100) / 10), 255)
        key = (x - x % BLOCK, y - y % BLOCK, z)
        block = blocks.get(key)
        if block is None:
            block = blocks[key] = bytearray(default)
        idx = ((y % BLOCK) * BLOCK + (x % BLOCK)) * TILE_BYTES
        block[idx:idx + 3] = bytes((flags, color, speed))
        count[0] += 1

    walk_otbm(otbm, on_tile)
    print(f"tiles: {count[0]}, blocks: {len(blocks)}")

    desc = b"OTMM 1.0"
    header = struct.pack("<IHHI", OTMM_SIGNATURE, 0, 1, 0) + struct.pack("<H", len(desc)) + desc
    header = header[:4] + struct.pack("<H", len(header)) + header[6:]
    with open(out, "wb") as f:
        f.write(header)
        for (bx, by, z) in sorted(blocks, key=lambda k: (k[2], k[1], k[0])):
            comp = zlib.compress(bytes(blocks[(bx, by, z)]), 6)
            f.write(struct.pack("<HHBH", bx, by, z, len(comp)))
            f.write(comp)
        f.write(struct.pack("<HHB", 0xFFFF, 0xFFFF, 0xFF))
    print(f"written {out}")


if __name__ == "__main__":
    main()
