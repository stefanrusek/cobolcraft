#!/usr/bin/env python3
"""Independent evaluation of the ore vein rule of docs/protocol/11 section 3.2 for core/tests/test_ore_veins.cob.
Xoroshiro128++ and the positional factories of docs/protocol/10 sections 2.1 to 2.5; the named factory minecraft:ore is
P.fromHashOf("minecraft:ore").forkPositional(). Prints the draws and outcomes the test pastes in."""
import hashlib, sys
M = (1 << 64) - 1
def rotl(x, k): return ((x << k) | (x >> (64 - k))) & M
class X:
    def __init__(self, lo, hi):
        self.lo, self.hi = lo, hi
        if lo == 0 and hi == 0: self.lo, self.hi = 0x9E3779B97F4A7C15, 0x6A09E667F3BCC909
    def next_long(self):
        r = (rotl((self.lo + self.hi) & M, 17) + self.lo) & M
        hi = self.hi ^ self.lo
        lo = rotl(self.lo, 49) ^ hi ^ ((hi << 21) & M)
        self.lo, self.hi = lo, rotl(hi, 28)
        return r
    def next_float(self): return (self.next_long() >> 40) * (2.0 ** -24)
def mix(z):
    z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & M
    z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & M
    return z ^ (z >> 31)
def seeded(seed):
    lo0 = (seed & M) ^ 0x6A09E667F3BCC909
    return X(mix(lo0), mix((lo0 + 0x9E3779B97F4A7C15) & M))
def from_hash(flo, fhi, name):
    d = hashlib.md5(name.encode()).digest()
    return X(int.from_bytes(d[:8], 'big') ^ flo, int.from_bytes(d[8:], 'big') ^ fhi)
def s32(v): return v - (1 << 32) if v >= (1 << 31) else v
def s64(v): return v - (1 << 64) if v >= (1 << 63) else v
def get_seed(x, y, z):
    l = (s32((x * 3129871) & 0xFFFFFFFF) & M) ^ ((z * 116129781) & M) ^ (y & M)
    l = (l * l * 42317861 + l * 11) & M
    return (s64(l) >> 16) & M
def ore_factory(seed):
    master = seeded(seed)
    flo, fhi = master.next_long(), master.next_long()
    g = from_hash(flo, fhi, "minecraft:ore")
    return g.next_long(), g.next_long()
def draws(fac, x, y, z):
    g = X(get_seed(x, y, z) ^ fac[0], fac[1])
    return g.next_float(), g.next_float(), g.next_float()
def f32(v):
    import struct
    return struct.unpack('f', struct.pack('f', v))[0]
def rule(fac, x, y, z, d, r, gap, chance, ore, raw, filler):
    """the state a vein rule gives, or -1"""
    f1, f2, f3 = draws(fac, x, y, z)
    if d <= 0: return -1
    if f1 > d: return -1
    if f2 < r and gap < 0:
        return raw if f3 < f32(chance) else ore
    return filler
if __name__ == "__main__":
    # self check: P for world seed 0 (docs/protocol/10 section 2.7)
    m = seeded(0); assert (m.next_long(), m.next_long()) == (0x2A2CA488F66F517E, 0xCCBC22D72E97C372)
    seed = 7
    fac = ore_factory(seed)
    pts = [(3, -20, 5), (-14, -5, 40), (-1, -1, 32), (-16, -32, 47), (-9, -17, 35), (-5, -30, 33)]
    D = f32(0.7)
    for p in pts:
        print(p, draws(fac, *p))
    ORE, RAW, FILL = 50, 51, 52
    for p in pts:
        print(p, "A", rule(fac, *p, D, 0.5, -1.0, 0.25, ORE, RAW, FILL),
              "raw", rule(fac, *p, D, 1.0, -1.0, 1.0, ORE, RAW, FILL),
              "gap", rule(fac, *p, D, 1.0, 1.0, 0.25, ORE, RAW, FILL),
              "all", rule(fac, *p, 1.0, 0.0, -1.0, 0.25, ORE, RAW, FILL))
    # the chunk (-1, 2) of the grid fixture: y -32 to -1 are vein cells (stone elsewhere, y -64 to -33)
    counts = {1: 0, 50: 0, 51: 0, 52: 0}
    check = 0
    for y in range(-64, 0):
        for z in range(32, 48):
            for x in range(-16, 0):
                s = 1
                if y >= -32:
                    v = rule(fac, x, y, z, D, 0.5, -1.0, 0.25, ORE, RAW, FILL)
                    if v >= 0: s = v
                counts[s] += 1
                check = (check * 31 + s) % 1000003
    print("counts", counts, "checksum", check)
