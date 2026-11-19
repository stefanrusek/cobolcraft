from g9 import *
from jr9 import JR
t = mk9(15, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 15 (lightning bolt): the path table (seed 0 reproduces the worked example and Validation 10), every layer step of the four passes (the trunk and the two branches with their",
             "draws and widths, 14 steps a pass) and the vertices of the four quads of a layer for the document's flag sets, for several seeds; the generator is the Java LCG of 10 section 2.6 written in gen/jr9.py (its first values are checked against Validation 10)."])
def path(seed):
    r = JR(seed); xs = [0] * 8; zs = [0] * 8; x = z = 0
    for i in range(7, -1, -1):
        xs[i] = x; zs[i] = z; x += r.nextInt(11) - 5; z += r.nextInt(11) - 5
    return xs, zs, x, z
xs, zs, ex, ez = path(0)
assert xs == [-13, -10, -7, -4, -1, -2, -5, 0] and zs == [-9, -9, -6, -1, -2, 1, 1, 0] and (ex, ez) == (-16, -13)   # the worked example of 15
for seed in (0, 1, 42, 123456789, 9876543210, -5, 2 ** 40 + 17):
    xs, zs, ex, ez = path(seed)
    t.call('EF9-LIGHTNING-PATH', [seed], xs + zs + [ex, ez], '15 path table of seed %d (xs, zs, endX, endZ)' % seed)
def steps(seed, j):
    xs, zs, ex, ez = path(seed); r = JR(seed); out = []
    for k in range(3):
        main = k == 0; start = 7 - k; end = 0 if main else start - 3 + 1
        px = xs[start] - ex; pz = zs[start] - ez
        for layer in range(start, end - 1, -1):
            prx, prz = px, pz
            if main: px += r.nextInt(11) - 5; pz += r.nextInt(11) - 5
            else: px += r.nextInt(31) - 15; pz += r.nextInt(31) - 15
            wt = wb = 0.1 + j * 0.2
            if main: wt *= layer * 0.1 + 1; wb *= (layer - 1) * 0.1 + 1
            out.append([k, layer, prx, prz, px, pz, wt, wb])
    return out
assert len(steps(0, 0)) == 14
# the trunk's first point relative to the end is (16, 13) for seed 0 (the worked example)
s0 = steps(0, 0)[0]; assert (s0[2], s0[3]) == (16, 13)
for seed in (0, 7, 31337):
    for j in range(4):
        st = steps(seed, j)
        for n in range(14):
            t.call('EF9-LIGHTNING-STEP', [seed, j, n], st[n], '15 seed %d pass %d step %d (k, layer, prevX, prevZ, px, pz, wTop, wBot)' % (seed, j, n))
FLAGS = ((0, 0, 1, 0), (1, 0, 1, 1), (1, 1, 0, 1), (0, 1, 0, 0))
def sgn(f, w): return w if f else -w
def quad(xn, zn, xp, zp, layer, wt, wb, f):
    f1, f2, f3, f4 = f
    return [xn + sgn(f1, wb), layer * 16, zn + sgn(f2, wb), xp + sgn(f1, wt), (layer + 1) * 16, zp + sgn(f2, wt), xp + sgn(f3, wt), (layer + 1) * 16, zp + sgn(f4, wt), xn + sgn(f3, wb), layer * 16, zn + sgn(f4, wb)]
for (xn, zn, xp, zp, layer, wt, wb) in ((16, 13, 16, 13, 7, 0.17, 0.1), (3, -4, 5, 2, 0, 0.1, 0.1), (-8, 9, -6, 11, 4, 0.7, 0.7), (0, 0, 1, 1, 3, 0.5, 0.45)):
    for f in FLAGS:
        t.call('EF9-LIGHTNING-QUAD', [xn, zn, xp, zp, layer, wt, wb] + list(f), quad(xn, zn, xp, zp, layer, wt, wb, f), '15 quad at layer %d new (%s, %s) previous (%s, %s) flags %s' % (layer, xn, zn, xp, zp, f))
t.call('EF9-LIGHTNING-COLOR', [], [0.45, 0.45, 0.5, 0.3], '15 vertex colour')
save9(t, 15)
