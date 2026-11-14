#!/usr/bin/env python3
"""Independent model of the start draws of the igloo (36-4 6.1) and the shipwreck (36-6 4.2) for core/tests/test_struct_tpl_gen.cob (prints the expected values the test embeds).
A Java LCG (10 section 2.6) and setLargeFeatureSeed (36-4 2.1); the world seed is the signed 64-bit value of the test's seed text."""
import sys

M48 = (1 << 48) - 1
def s64(v): v &= (1 << 64) - 1; return v - (1 << 64) if v >= 1 << 63 else v
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
    def next_double(self): return ((self.next(26) << 27) + self.next(27)) * 2.0 ** -53
def start_random(seed, cx, cz):
    r = Lcg(seed); a = r.next_long(); b = r.next_long()
    r.s = ((s64(cx * a) ^ s64(cz * b) ^ seed) ^ 0x5DEECE66D) & M48
    return r

OCEAN = "with_mast upsidedown_full upsidedown_fronthalf upsidedown_backhalf sideways_full sideways_fronthalf sideways_backhalf rightsideup_full rightsideup_fronthalf rightsideup_backhalf".split()
OCEAN += [n + "_degraded" for n in ["with_mast", "upsidedown_full", "upsidedown_fronthalf", "upsidedown_backhalf", "sideways_full", "sideways_fronthalf", "sideways_backhalf", "rightsideup_full", "rightsideup_fronthalf", "rightsideup_backhalf"]]
BEACHED = "with_mast sideways_full sideways_fronthalf sideways_backhalf rightsideup_full rightsideup_fronthalf rightsideup_backhalf with_mast_degraded rightsideup_full_degraded rightsideup_fronthalf_degraded rightsideup_backhalf_degraded".split()

def igloo(seed, cx, cz):
    r = start_random(seed, cx, cz); rot = r.next_int(4); x0, z0 = cx * 16, cz * 16
    pieces = []
    if r.next_double() < 0.5:
        n = r.next_int(8) + 4
        pieces.append((3, x0, 90 - 3 - n * 3, z0 - 2))
        for i in range(n - 1): pieces.append((2, x0 + 2, 90 - 3 - i * 3, z0 + 4))
    pieces.append((1, x0, 90, z0))
    return rot, pieces
def shipwreck(seed, cx, cz, beached):
    r = start_random(seed, cx, cz); rot = r.next_int(4)
    names = BEACHED if beached else OCEAN
    return rot, names[r.next_int(len(names))], r
if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 12345
    for cx, cz in [(0, 0), (1, 0), (-3, 5), (7, -2), (11, 13), (-9, -4), (20, 3), (5, 5)]:
        print("igloo", cx, cz, igloo(seed, cx, cz))
        for b in (0, 1):
            rot, name, r = shipwreck(seed, cx, cz, b)
            print("shipwreck", "beached" if b else "ocean", cx, cz, rot, name, "next3" if not b else r.next_int(3))
