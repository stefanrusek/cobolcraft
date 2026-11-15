#!/usr/bin/env python3
"""Independent model of the ocean ruins (docs/protocol/36-structures-6 section 3) for core/tests/test_struct_ruin.cob (prints the expected values the test embeds).
A Java LCG (10 section 2.6), setLargeFeatureSeed (36-4 2.1), the start of 3.2 to 3.6 (rotation, large draw, template choice, cluster) and the block pipeline of one piece
(the rot and block_ignore processors and the capped archaeology rule of 2.4 and 3.7) over the template read from the generated vanilla-data (gzip NBT).
usage: gen_oceanruin.py GENERATED_DIR [SEED]"""
import gzip, os, struct, sys

M48 = (1 << 48) - 1
def s64(v): v &= (1 << 64) - 1; return v - (1 << 64) if v >= 1 << 63 else v
def s32(v): v &= (1 << 32) - 1; return v - (1 << 32) if v >= 1 << 31 else v
def f32(v): return struct.unpack(">f", struct.pack(">f", v))[0]

class Lcg:
    def __init__(self, seed): self.s = (seed ^ 0x5DEECE66D) & M48
    def next(self, bits):
        self.s = (self.s * 0x5DEECE66D + 0xB) & M48
        v = self.s >> (48 - bits)
        return v - (1 << bits) if bits == 32 and v >= 1 << 31 else v
    def next_int(self, bound):
        if bound & (bound - 1) == 0: return (bound * self.next(31)) >> 31
        while True:
            bits = self.next(31); v = bits % bound
            if bits - v + (bound - 1) < (1 << 31): return v
    def next_long(self): return s64((self.next(32) << 32) + self.next(32))
    def next_float(self): return self.next(24) / 16777216.0
    def between(self, lo, hi): return lo if lo >= hi else self.next_int(hi - lo + 1) + lo

def start_random(seed, cx, cz):
    r = Lcg(seed); a = r.next_long(); b = r.next_long()
    r.s = ((s64(cx * a) ^ s64(cz * b) ^ seed) ^ 0x5DEECE66D) & M48
    return r
def get_seed(x, y, z):
    l = s64(s32(x * 3129871) ^ (z * 116129781) ^ y)
    l = s64(l * l * 42317861 + l * 11)
    return l >> 16

def rotate(x, z, rot):   # pivot (0, 0), 36-6 2.2
    return [(x, z), (-z, x), (-x, -z), (z, -x)][rot]

WARM = ["warm_%d" % i for i in range(1, 9)]
BRICK = ["brick_%d" % i for i in range(1, 9)]
CRACKED = ["cracked_%d" % i for i in range(1, 9)]
MOSSY = ["mossy_%d" % i for i in range(1, 9)]
BIG_WARM = ["big_warm_%d" % i for i in (4, 5, 6, 7)]
BIG_BRICK = ["big_brick_%d" % i for i in (1, 2, 3, 8)]
BIG_CRACKED = ["big_cracked_%d" % i for i in (1, 2, 3, 8)]
BIG_MOSSY = ["big_mossy_%d" % i for i in (1, 2, 3, 8)]
LP, CP = f32(0.3), f32(0.9)

def add_piece(r, pos, rot, large, integrity, warm, out):
    if warm:
        name = (BIG_WARM[r.next_int(4)] if large else WARM[r.next_int(8)])
        out.append((name, pos, rot, integrity, large))
    else:
        i = r.next_int(4 if large else 8)
        names = (BIG_BRICK, BIG_CRACKED, BIG_MOSSY) if large else (BRICK, CRACKED, MOSSY)
        for names_i, integ in zip(names, (integrity, 0.7, 0.5)):
            out.append((names_i[i], pos, rot, integ, large))

def ruin(seed, cx, cz, warm):
    """-> list of (template name, (x, z), rotation, integrity, large) pieces of the start (y is the placeholder 90)"""
    r = start_random(seed, cx, cz)
    pos = (cx * 16, cz * 16)
    rot = r.next_int(4)
    large = r.next_float() <= LP
    integrity = 0.9 if large else 0.8
    out = []
    add_piece(r, pos, rot, large, integrity, warm, out)
    if large and r.next_float() <= CP:
        cluster(r, pos, rot, warm, out)
    return rot, large, out

def cluster(r, pos, rot, warm, out):
    bx, bz = rotate(15, 15, rot)
    a, b = pos, (pos[0] + bx, pos[1] + bz)
    main = (min(a[0], b[0]), min(a[1], b[1]), max(a[0], b[0]), max(a[1], b[1]))
    base = (main[0], main[1])
    cands = []
    # draw order of 3.6 step 4: x offset, then z offset, per candidate
    cands.append((base[0] - 16 + r.between(1, 8), base[1] + 16 + r.between(1, 7)))
    cands.append((base[0] - 16 + r.between(1, 8), base[1] + 0 + r.between(1, 7)))
    cands.append((base[0] - 16 + r.between(1, 8), base[1] - 16 + r.between(4, 8)))
    cands.append((base[0] + r.between(1, 7), base[1] + 16 + r.between(1, 7)))
    cands.append((base[0] + r.between(1, 7), base[1] - 16 + r.between(4, 6)))
    cands.append((base[0] + 16 + r.between(1, 7), base[1] + 16 + r.between(3, 8)))
    cands.append((base[0] + 16 + r.between(1, 7), base[1] + 0 + r.between(1, 7)))
    cands.append((base[0] + 16 + r.between(1, 7), base[1] - 16 + r.between(4, 8)))
    n = r.between(4, 8)
    for _ in range(n):
        if not cands: continue
        k = r.next_int(len(cands)); c = cands.pop(k)
        rot2 = r.next_int(4)
        dx, dz = rotate(5, 6, rot2)
        box = (min(c[0], c[0] + dx), min(c[1], c[1] + dz), max(c[0], c[0] + dx), max(c[1], c[1] + dz))
        if box[0] <= main[2] and box[2] >= main[0] and box[1] <= main[3] and box[3] >= main[1]: continue
        add_piece(r, c, rot2, False, 0.8, warm, out)

# ---- NBT
def read_nbt(path):
    data = gzip.open(path).read(); pos = [0]
    def u(fmt):
        n = struct.calcsize(fmt); v = struct.unpack_from(fmt, data, pos[0])[0]; pos[0] += n; return v
    def string():
        n = u(">H"); s = data[pos[0]:pos[0] + n].decode(); pos[0] += n; return s
    def payload(t):
        if t == 1: return u(">b")
        if t == 2: return u(">h")
        if t == 3: return u(">i")
        if t == 4: return u(">q")
        if t == 5: return u(">f")
        if t == 6: return u(">d")
        if t == 7: n = u(">i"); pos[0] += n; return None
        if t == 8: return string()
        if t == 9:
            et = u(">b"); n = u(">i"); return [payload(et) for _ in range(n)]
        if t == 10:
            d = {}
            while True:
                tt = u(">b")
                if tt == 0: return d
                nm = string(); d[nm] = payload(tt)
        if t == 11: n = u(">i"); return [u(">i") for _ in range(n)]
        if t == 12: n = u(">i"); return [u(">q") for _ in range(n)]
    assert u(">b") == 10; string(); return payload(10)

def template(gen, name):
    t = read_nbt(os.path.join(gen, "vanilla-data/data/minecraft/structure/underwater_ruin", name + ".nbt"))
    pal = [p["id"] for p in (t["palettes"][0] if "palettes" in t else t["palette"])]
    return t["size"], [(tuple(b["pos"]), pal[b["state"]]) for b in t["blocks"]]

def place(gen, seed, piece, y, warm):
    """the processed list of one placement: (kept count, suspicious conversions [(x, y, z, loot seed)])"""
    name, (px, pz), rot, integrity, large = piece
    size, blocks = template(gen, name)
    integ = f32(integrity)
    kept = []   # (world x, y, z, block name)
    for (x, by, z), b in blocks:
        rx, rz = rotate(x, z, rot)
        wx, wy, wz = px + rx, y + by, pz + rz
        if f32(Lcg(get_seed(wx, wy, wz)).next_float()) > integ: continue
        if b in ("minecraft:air", "minecraft:structure_block"): continue
        kept.append((wx, wy, wz, b))
    want = "minecraft:sand" if warm else "minecraft:gravel"
    changed = []
    if kept:
        f = Lcg(seed).next_long()
        r = Lcg(get_seed(px, y, pz) ^ f)
        order = list(range(len(kept)))
        for i in range(len(kept), 1, -1):
            j = r.next_int(i); order[i - 1], order[j] = order[j], order[i - 1]
        for i in order:
            if len(changed) >= 5: break
            wx, wy, wz, b = kept[i]
            if b == want:
                changed.append((i, wx, wy, wz, Lcg(get_seed(wx, wy, wz)).next_long()))
    return len(kept), [c[1:] for c in sorted(changed)]   # in template block order (the order of the processed records)

def cobol_tables(gen, seed):
    """the VALUE tables of core/tests/test_struct_ruin.cob (the start cases and the placement cases)"""
    def sg(v, n): return ("-" if v < 0 else "+") + str(abs(v)).zfill(n)
    rows = []
    for warm, cases in ((1, [(-12, 2), (-11, 3), (-8, 0), (-12, -12), (-10, -10), (-12, -7), (-11, 12), (-12, -11)]), (0, [(-12, 2), (-11, 3), (-12, -12), (-11, -3)])):
        for cx, cz in cases:
            rot, large, pieces = ruin(seed, cx, cz, warm)
            rows.append("H" + " " * 16 + sg(cx, 6) + sg(cz, 6) + str(rot) + str(warm) + str(int(large)) + sg(len(pieces), 6))
            for name, (x, z), r, integ, lg in pieces:
                rows.append("P" + name.ljust(16) + sg(x, 6) + sg(z, 6) + str(r) + str(int(round(integ * 10))) + str(int(lg)) + sg(0, 6))
    print("START ROWS", len(rows))
    for r in rows: print('    05 FILLER PIC X(41) VALUE "%s".' % r)
    cases = [(1, "warm_3", (16, -32), 1, 0.8), (0, "mossy_2", (-48, 80), 2, 0.5), (1, "big_warm_5", (0, 0), 3, 0.9), (0, "big_brick_1", (32, 16), 0, 0.9), (0, "cracked_7", (5, 5), 0, 0.7), (1, "warm_8", (-3, 7), 2, 0.8)]
    out = []
    for warm, name, pos, rot, integ in cases:
        kept, ch = place(gen, seed, (name, pos, rot, integ, name.startswith("big")), 40, warm)
        out.append(("C" + name.ljust(16) + sg(pos[0], 6) + sg(pos[1], 6) + str(rot) + str(int(round(integ * 10))) + str(warm) + sg(kept, 6) + sg(len(ch), 6)).ljust(58))
        for x, y, z, sd in ch: out.append("S" + " " * 16 + sg(x, 6) + sg(z, 6) + sg(y, 6) + sg(sd, 19))
    print("PLACE ROWS", len(out))
    for r in out: print('    05 FILLER PIC X(58) VALUE "%s".' % r)
    print("HEIGHT ROWS", len(HEIGHT_CASES))
    for x, z, rot, sx, sz in HEIGHT_CASES: print('    05 FILLER PIC X(19) VALUE "%s".' % (sg(x, 6) + sg(z, 6) + str(rot) + str(sx).zfill(2) + str(sz).zfill(2)))

# footprints (anchor x, z, rotation, size x, size z) of the adapted height cases of the test: found on the data of world seed 12345
HEIGHT_CASES = [(0, 0, 0, 6, 7), (100, -40, 1, 6, 7), (-200, 120, 2, 6, 7), (300, 300, 3, 6, 7), (40, 40, 0, 16, 16),
                (-500, -482, 2, 6, 7), (-500, -473, 3, 6, 7), (-500, -428, 0, 6, 7), (-500, -419, 1, 16, 16), (-500, -482, 2, 16, 16)]

if __name__ == "__main__":
    gen = sys.argv[1]
    if len(sys.argv) > 2 and sys.argv[2] == "--cobol":
        cobol_tables(gen, int(sys.argv[3]) if len(sys.argv) > 3 else 12345); sys.exit(0)
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 12345
    for warm in (1, 0):
        for cx, cz in [(0, 0), (1, 0), (-3, 5), (7, -2), (11, 13), (-9, -4), (20, 3), (5, 5), (2, 9), (-14, 8), (3, 3), (6, -9), (-5, 12), (10, 1), (-2, -2), (4, 14)]:
            rot, large, pieces = ruin(seed, cx, cz, warm)
            print("ruin", "warm" if warm else "cold", cx, cz, "rot", rot, "large", int(large), "pieces", len(pieces))
            for p in pieces: print("   ", p)
    # the block pipeline of a few pieces at y 40
    for warm, name, pos, rot, integ in [(1, "warm_3", (16, -32), 1, 0.8), (0, "mossy_2", (-48, 80), 2, 0.5), (1, "big_warm_5", (0, 0), 3, 0.9), (0, "big_brick_1", (32, 16), 0, 0.9), (0, "cracked_7", (5, 5), 0, 0.7)]:
        piece = (name, pos, rot, integ, name.startswith("big"))
        kept, ch = place(gen, seed, piece, 40, warm)
        print("place", name, pos, rot, integ, "kept", kept, "changed", ch)
