#!/usr/bin/env python3
"""Writes shim/tests/f64_vectors.txt: operand and result pairs for every cc_f64_* function of
contract/include/ccshim.h section 10, computed independently of the C code (stdlib struct, math and
fractions only; the rules are those of docs/protocol/10-world-generation-terrain.md section 16).

Line format, whitespace separated:  <function suffix> <operands...> <result>
  doubles are 16 hex digits of the IEEE bits (the word nan is a quiet NaN operand, and as a result any
  NaN matches),
  int32 and int64 operands and results are signed decimal, from_text takes the decimal text itself.
usage: gen_f64_vectors.py [output-path]
"""
import hashlib
import math
import os
import struct
import sys
from fractions import Fraction

I32_MAX, I32_MIN = 2**31 - 1, -(2**31)
I64_MAX, I64_MIN = 2**63 - 1, -(2**63)
INF = float("inf")
NAN = float("nan")


def bits(x):
    return struct.unpack(">Q", struct.pack(">d", x))[0]


def from_bits(b):
    return struct.unpack(">d", struct.pack(">Q", b & (2**64 - 1)))[0]


def d(x):
    """Token of a double operand or result."""
    return "nan" if x != x else "%016X" % bits(x)


def f32(x):
    """Nearest binary32 (ties to even), as a double; overflow to infinity."""
    if x != x or x in (INF, -INF):
        return x
    try:
        return struct.unpack(">f", struct.pack(">f", x))[0]
    except OverflowError:
        return math.copysign(INF, x)


def floor_d(x):
    if x != x or x in (INF, -INF) or x == 0:
        return x
    f = Fraction(x)
    return float(f.numerator // f.denominator)


def ceil_d(x):
    if x != x or x in (INF, -INF) or x == 0:
        return x
    f = Fraction(x)
    n = -((-f.numerator) // f.denominator)
    if n == 0:
        return -0.0 if x < 0 else 0.0
    return float(n)


def sat(n, lo, hi):
    return max(lo, min(hi, n))


def to_int(x, lo, hi):
    if x != x:
        return 0
    if x in (INF, -INF):
        return hi if x > 0 else lo
    return sat(int(x), lo, hi)  # int() truncates toward zero


def round_int(x, lo, hi):
    if x != x:
        return 0
    if x in (INF, -INF):
        return hi if x > 0 else lo
    f = Fraction(x) + Fraction(1, 2)
    return sat(f.numerator // f.denominator, lo, hi)


def min_j(a, b):
    if a != a or b != b:
        return NAN
    if a == 0 and b == 0:
        return a if math.copysign(1, a) < 0 else b
    return a if a < b else b


def max_j(a, b):
    if a != a or b != b:
        return NAN
    if a == 0 and b == 0:
        return a if math.copysign(1, a) > 0 else b
    return a if a > b else b


def clamp(v, lo, hi):
    return lo if v < lo else min_j(v, hi)


def signum(a):
    if a != a or a == 0:
        return a
    return 1.0 if a > 0 else -1.0


def fmod(a, b):
    if a != a or b != b or a in (INF, -INF) or b == 0:
        return NAN
    return math.fmod(a, b)


def div(a, b):
    if b == 0:
        if a == 0 or a != a:
            return NAN
        neg = (math.copysign(1, a) < 0) != (math.copysign(1, b) < 0)
        return -INF if neg else INF
    return a / b


def sqrt(a):
    return NAN if a < 0 or a != a else math.sqrt(a)


def log(a):
    if a != a or a < 0:
        return NAN
    return -INF if a == 0 else math.log(a)


def log1p(a):
    if a != a or a < -1:
        return NAN
    return -INF if a == -1 else math.log1p(a)


def asin_(a):
    return NAN if a != a or abs(a) > 1 else math.asin(a)


def acos_(a):
    return NAN if a != a or abs(a) > 1 else math.acos(a)


K = 10430.378350470453
SIN = [f32(math.sin(i / K)) for i in range(65536)]
# docs/protocol/10 section 16.3: the table check value
assert hashlib.sha256(b"".join(struct.pack(">f", v) for v in SIN)).hexdigest() == \
    "87a67a39fff59636acb04edcda4ef622831037291f11fb61586c57596771dac2"


def sin_tab(x):
    return SIN[to_int(x * K, I64_MIN, I64_MAX) & 65535]


def cos_tab(x):
    return SIN[to_int(x * K + 16384.0, I64_MIN, I64_MAX) & 65535]


ASIN_TAB = [math.asin(i / 256.0) for i in range(257)]
COS_TAB = [math.cos(a) for a in ASIN_TAB]
FRAC_BIAS = from_bits(4805340802404319232)


def fast_inv_sqrt(x):
    h = 0.5 * x
    b = bits(x)
    sb = b - 2**64 if b >= 2**63 else b          # signed, arithmetic shift
    nb = 6910469410427058090 - (sb >> 1)
    y = from_bits(nb)
    return y * (1.5 - ((h * y) * y))


def atan2_mth(y, x):
    dd = x * x + y * y
    if dd != dd:
        return NAN
    ny = y < 0
    if ny:
        y = -y
    nx = x < 0
    if nx:
        x = -x
    sw = y > x
    if sw:
        x, y = y, x
    inv = fast_inv_sqrt(dd)
    x = x * inv
    y = y * inv
    if x != x or y != y:
        return NAN
    t = FRAC_BIAS + y
    idx = bits(t) & 0xFFFFFFFF
    a, c = ASIN_TAB[idx], COS_TAB[idx]
    b = t - FRAC_BIAS
    e = y * c - x * b
    p = ((6.0 + (e * e)) * e) * 0.16666666666666666
    r = a + p
    if sw:
        r = 1.5707963267948966 - r
    if nx:
        r = 3.141592653589793 - r
    if ny:
        r = -r
    return r


def lerp_f32(t, a, b):
    return f32(a + f32(t * f32(b - a)))


def lerp_f64(t, a, b):
    return a + (t * (b - a))


def pow_(a, b):
    return math.pow(a, b)


# Operand pools. Doubles are chosen as exact bit patterns where decimal text would be ambiguous.
H = from_bits
COMMON = [0.0, -0.0, 1.0, -1.0, 0.5, -0.5, 2.5, -2.5, 0.1, 0.2, 0.3, 3.0, -3.0, 1e10, -1e10, 3e10, -3e10,
          1e300, -1e300, 4.9e-324, 2.2250738585072014e-308, 1.7976931348623157e308, INF, -INF, NAN,
          0.49999999999999994, 123456.789, -98765.4321, 1.5, 7.0, 360.0, -190.0, 540.0, 9.5e18, -9.5e18]
RAND = []
_s = 0x9E3779B97F4A7C15
for _ in range(40):
    _s = (_s * 6364136223846793005 + 1442695040888963407) & (2**64 - 1)
    v = from_bits(_s)
    if v == v and v not in (INF, -INF) and 1e-30 < abs(v) < 1e30:
        RAND.append(v)
RAND += [0.49999997, 2.0**24 + 1, 2.0**53 + 2, 16777216.0, 3.4028234663852886e38,
         3.4028235677973366e38, 1e40, -1e40, 1.401298464324817e-45, 7e-46]
POOL = COMMON + RAND
FINITE = [v for v in POOL if v == v and v not in (INF, -INF)]


def pairs(fn_filter=None):
    out = []
    for i, a in enumerate(POOL):
        for b in POOL[(i * 7) % len(POOL)::5][:8]:
            out.append((a, b))
    for a, b in ((0.1, 0.2), (1.0, 3.0), (0.0, 0.0), (-0.0, 0.0), (INF, -INF), (INF, 1.0), (1.0, 0.0),
                 (-1.0, 0.0), (0.0, 0.0), (1e308, 1e308), (1e-320, 3.0), (5.0, 3.0), (-5.0, 3.0), (5.0, -3.0),
                 (360.0, 360.0), (190.0, 360.0), (7.5, INF), (INF, 7.5)):
        out.append((a, b))
    return out


lines = []


def emit(name, *tokens):
    lines.append(" ".join([name] + [str(t) for t in tokens]))


PAIRS = pairs()
for a, b in PAIRS:
    emit("add", d(a), d(b), d(a + b) if not (a in (INF, -INF) and b in (INF, -INF) and a != b) else "nan")
    emit("sub", d(a), d(b), d(a - b) if not (a == b and a in (INF, -INF)) else "nan")
    emit("mul", d(a), d(b), d(a * b) if not ((a == 0 and b in (INF, -INF)) or (b == 0 and a in (INF, -INF))) else "nan")
    emit("div", d(a), d(b), d(div(a, b)))
    emit("fmod", d(a), d(b), d(fmod(a, b)))
    emit("min_j", d(a), d(b), d(min_j(a, b)))
    emit("max_j", d(a), d(b), d(max_j(a, b)))
    emit("copysign", d(a), d(b), d(math.copysign(a, b)))
    emit("atan2_mth", d(a), d(b), d(atan2_mth(a, b)))
# the sample the task names, and the doc's worked examples
emit("add", d(0.1), d(0.2), "3FD3333333333334")   # bytes 343333333333D33F little-endian
emit("atan2_mth", d(1.0), d(1.0), "3FE921FB45E6D12F")
emit("atan2_mth", d(3.0), d(-4.0), "4003FC19CD3C7E4C")
emit("atan2_mth", d(0.0), d(0.0), d(0.0))
emit("atan2_mth", d(0.0), d(-1.0), d(math.pi))

for a in POOL:
    emit("floor", d(a), d(floor_d(a)))
    emit("ceil", d(a), d(ceil_d(a)))
    emit("sqrt", d(a), d(sqrt(a)))
    emit("f32_round", d(a), d(f32(a)))
    emit("to_i32", d(a), to_int(a, I32_MIN, I32_MAX))
    emit("to_i64", d(a), to_int(a, I64_MIN, I64_MAX))
    emit("round_f32", d(a), round_int(a, I32_MIN, I32_MAX))
    emit("round_f64", d(a), round_int(a, I64_MIN, I64_MAX))
    emit("signum", d(a), d(signum(a)))
    emit("abs_f32", d(a), d(from_bits(bits(a) & ~(1 << 63))))
    emit("abs_f64", d(a), d(from_bits(bits(a) & ~(1 << 63))))
    emit("f64_bits", d(a), struct.unpack(">q", struct.pack(">Q", bits(a)))[0])
    emit("nextdown", d(a), d(math.nextafter(a, -INF)))
    emit("next_up", d(a), d(math.nextafter(a, INF)))
    emit("log1p", d(a), d(log1p(a)))
    emit("to_radians", d(a), d(a * 0.017453292519943295))
    emit("log", d(a), d(log(a)))
    emit("sin", d(a), d(NAN if a in (INF, -INF) or a != a else math.sin(a)))
    emit("cos", d(a), d(NAN if a in (INF, -INF) or a != a else math.cos(a)))
    emit("asin", d(a), d(asin_(a)))
    emit("acos", d(a), d(acos_(a)))
    emit("sin_tab", d(a), d(sin_tab(a)))
    emit("cos_tab", d(a), d(cos_tab(a)))
    if a == a and a not in (INF, -INF) and a > 0:
        emit("fast_inv_sqrt", d(a), d(fast_inv_sqrt(a)))
        emit("inv_sqrt", d(a), d(1.0 / math.sqrt(a)))
for a in (0.0, 4.0, 16777216.0, 1.0):
    emit("nextdown", d(a), d(math.nextafter(a, -INF)))
emit("round_f32", d(0.49999997), 0)
for v in (2.5, -2.5, -0.5):
    emit("round_f32", d(v), round_int(v, I32_MIN, I32_MAX))
emit("sin_tab", d(1.0), d(struct.unpack(">f", struct.pack(">I", 0x3F57695C))[0]))   # 10 section 16.8
for i in list(range(0, 65536, 61)) + [65535, 16384, 49152]:
    emit("sin_tab", d((i + 0.5) / K), d(SIN[i]))   # the middle of cell i
for n in (0, 1, 2, 16777217, 2**31 - 1, -(2**31), -5, 123456789):
    emit("i32_to_f32", n, d(f32(float(n))))
for n in (0, 1, -1, 4607182418800017408, -4616189618054758400, 0x7FF0000000000000):
    emit("f64_from_bits", n, d(from_bits(n)))
for v, lo, hi in ((0.5, 0.0, 1.0), (-1.0, 0.0, 1.0), (2.0, 0.0, 1.0), (NAN, 0.0, 1.0), (5.0, 3.0, 1.0),
                  (-5.0, 3.0, 1.0), (0.0, -0.0, 1.0), (1.0, 0.0, -0.0), (0.25, 0.1, 0.9)):
    emit("clamp_f32", d(v), d(lo), d(hi), d(clamp(v, lo, hi)))
    emit("clamp_f64", d(v), d(lo), d(hi), d(clamp(v, lo, hi)))
for t, a, b in ((0.0, 0.1, 0.7), (1.0, 0.1, 0.7), (0.3, 0.1, 0.7), (0.5, -2.0, 2.0), (2.0, 0.0, 1.0), (0.25, 3.0, 3.0)):
    emit("lerp_f64", d(t), d(a), d(b), d(lerp_f64(t, a, b)))
    t32, a32, b32 = f32(t), f32(a), f32(b)
    emit("lerp_f32", d(t32), d(a32), d(b32), d(lerp_f32(t32, a32, b32)))
emit("lerp_f32", d(f32(0.3)), d(f32(0.1)), d(f32(0.7)), d(struct.unpack(">f", struct.pack(">I", 0x3E8F5C29))[0]))
for a, b in ((2.0, 10.0), (2.0, -3.0), (0.5, 4.0), (0.3, 3.0), (10.0, 0.5), (0.997, 20.0), (2.0, 0.5), (0.0, 0.0), (-8.0, 1.0 / 3.0)):
    emit("pow", d(a), d(b), d(NAN if a < 0 and b != int(b) else pow_(a, b)))
for y, x in ((1.0, 1.0), (1.0, -1.0), (-1.0, -1.0), (0.0, -1.0), (-0.0, 0.0), (3.0, 4.0), (0.5, 2.0)):
    emit("atan2_lib", d(y), d(x), d(math.atan2(y, x)))

TEXTS = ["0.1", "0.2", "0.3", "1", "-1", "0", "-0", "123456789.123456789", "1e22", "1e23", "1e-5", "5e-324",
         "4.9e-324", "2.4703282292062327e-324", "1.7976931348623157e308", "1e309", "-1e309", "0.017453292519943295",
         "10430.378350470453", "57.2957763671875", "0.16666666666666666", "9007199254740993", "9007199254740995",
         "3.14159265358979323846", "2.5e-3", "1E3"]
for t in TEXTS:
    emit("from_text", t, d(float(t)))

path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "f64_vectors.txt")
with open(path, "w") as f:
    f.write("\n".join(lines) + "\n")
print("wrote %d vectors to %s" % (len(lines), path))
