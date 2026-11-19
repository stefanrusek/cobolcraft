from g9 import *
import math
from jr9 import JR
D = 0.017453292
t = mk9(9, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 9 (dropped items, clusters, the ominous item spawner): renderedAmount from the table of 9.1 and Validation 4, seedFor (187 for an empty stack),",
            "the bob, base and spin of 9.2 (steps 1 and 2), submitMultipleFromCount for thick and flat models (the draws of the Java LCG, generator vectors of Validation 10 checked in gen/jr9.py), and 9.3 (grow over 50 ticks, spin in degrees, fixed full bright light)."])
rows = table9('### 9.1')
ranges = []
for r in rows:
    c0 = list(r.values())[0]; c1 = int(list(r.values())[1])
    nums_ = [int(x) for x in re.findall(r'\d+', c0)]
    lo = nums_[0] if 'to' in c0 or 'above' in c0 else -10 ** 9
    hi = nums_[1] if 'to' in c0 else (nums_[0] if '<=' in c0 else 10 ** 9)
    ranges.append((lo, hi, c1))
def copies(n):
    for lo, hi, c in ranges:
        if lo <= n <= hi: return c
    raise Exception(n)
assert [copies(n) for n in (1, 40, 64)] == [1, 4, 5]
for n in (-1, 0, 1, 2, 16, 17, 32, 33, 40, 48, 49, 64, 99):
    t.call('EF9-ITEM-COPIES', [n], [copies(n)], '9.1 renderedAmount of a stack of %d' % n)
for iid, dmg, empty in ((0, 0, 1), (5, 3, 1), (0, 0, 0), (42, 0, 0), (1000, 12, 0), (7, 1, 0)):
    t.call('EF9-ITEM-SEED', [iid, dmg, empty], [187 if empty else iid + dmg], '9.1 seedFor id %d damage %d empty %d' % (iid, dmg, empty))
for age, bo, miny in ((0, 0, -0.125), (20, 0, -0.125), (33.5, 2.5, 0), (100, 5.9, 0.3), (1234.5, 0.3, -0.5)):
    t.call('EF9-ITEM-POSE', [age, bo, miny], [math.sin(age / 10 + bo) * 0.1 + 0.1 + (-miny + 0.0625), age / 20 + bo], '9.2 pose age %s bobOffs %s minY %s (translate y, spin radians)' % (age, bo, miny))
def cluster(n, seed, zs):
    rnd = JR(seed); out = [n]
    if n < 1: return [0]
    if zs > 0.0625:
        out += [0, 0, 0]
        for k in range(1, n): out += [(rnd.nextFloat() * 2 - 1) * 0.15, (rnd.nextFloat() * 2 - 1) * 0.15, (rnd.nextFloat() * 2 - 1) * 0.15]
    else:
        step = zs * 1.5; z = -(step * (n - 1)) / 2
        out += [0, 0, z]
        for k in range(1, n):
            x = (rnd.nextFloat() * 2 - 1) * 0.15 * 0.5; y = (rnd.nextFloat() * 2 - 1) * 0.15 * 0.5
            out += [x, y, z + step * k]
    return out
for n, seed, zs in ((1, 187, 0.03125), (2, 5, 0.03125), (3, 1234, 0.03125), (5, 98765, 0.03125), (4, 7, 0.0625), (2, 42, 0.0625001), (5, 98765, 0.25), (3, 187, 1), (0, 5, 0.5)):
    t.call('EF9-CLUSTER', [n, seed, zs], cluster(n, seed, zs), '9.2 cluster of %d seed %d zSize %s (copies, then x y z each)' % (n, seed, zs))
def wrapd(x): return x - 360 * math.floor((x + 180) / 360)
for age in (0, 10, 25, 50, 50.5, 51, 80, 400.25):
    o = []
    if age <= 50: o.append((2, age / 50, age / 50, age / 50))
    o.append((3, wrapd(age * 40), 0, 0))
    t.call('EF9-SPAWNER-OPS', [age], [len(o)] + [v for p in o for v in p], '9.3 ominous item spawner pose at age %s' % age)
t.call('EF9-SPAWNER-LIGHT', [], [15728880], '9.3 fixed light coordinates (block 15, sky 15)')
save9(t, 9)
