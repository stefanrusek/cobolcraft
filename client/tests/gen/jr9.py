# java.util.Random in Python (10 section 2.6), checked against the document's generator vectors (Validation 10 of 34-9)
class JR:
    def __init__(s, seed): s.s = (seed ^ 0x5DEECE66D) & ((1 << 48) - 1)
    def next(s, bits):
        s.s = (s.s * 0x5DEECE66D + 0xB) & ((1 << 48) - 1)
        v = s.s >> (48 - bits)
        if bits == 32 and v >= 1 << 31: v -= 1 << 32
        return v
    def nextInt(s, bound):
        if bound & (bound - 1) == 0: return (bound * s.next(31)) >> 31
        while True:
            bits = s.next(31); val = bits % bound
            if bits - val + (bound - 1) < (1 << 31): return val
    def nextFloat(s): return s.next(24) / float(1 << 24)
def selftest():
    r = JR(0); assert [r.nextInt(100) for _ in range(5)] == [60, 48, 29, 47, 15]
    r = JR(0); assert [r.nextInt(11) for _ in range(8)] == [0, 6, 8, 5, 6, 2, 2, 6]
selftest()
