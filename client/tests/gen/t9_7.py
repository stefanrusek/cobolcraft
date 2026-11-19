from g9 import *
import math, struct
D = 0.017453292
def f32(x): return struct.unpack('f', struct.pack('f', x))[0]
def msin(x): return f32(math.sin((int(x * 10430.378350470453) & 65535) / 10430.378350470453))
def mcos(x): return f32(math.sin((int(x * 10430.378350470453 + 16384.0) & 65535) / 10430.378350470453))
t = mk9(7, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 7 and 8: the arguments of ThrownItemRenderer for each type (the 1.1 table and Validation 2), the block light of a full bright item, the quad of the flat item model with",
            "the scale and the firework's rotations, the fishing hook's quad (8 step 1), the fishing line vertices and normals (8 step 2, Validation 7), the swing factor, the holding arm and the hand position of the third person (the table sine and cosine of 34-9 section 2)."],
        extra='\n 01 WS-KEY               PIC X(24).')
# the thrown types and arguments from the table of 1.1
thrown = {}
for r in table9('### 1.1', 0):
    cls = list(r.values())[1]; args = list(r.values())[2]
    if 'ThrownItemRenderer' in cls:
        m = re.search(r'scale ' + NUMR + r', full bright (true|false)', args)
        for k in re.findall(r'`([a-z_]+)`', list(r.values())[0]): thrown[k] = (float(m.group(1)), 1 if m.group(2) == 'true' else 0)
assert len(thrown) == 9 and thrown['fireball'] == (3.0, 1) and thrown['small_fireball'] == (0.75, 1), thrown
for k, (sc, fb) in thrown.items():
    t.raw('MOVE "%s" TO WS-KEY' % k, 'CALL "EF9-THROWN" USING WS-KEY WS-OUT'); t.num('1.1 %s is a thrown item' % k, 1, 'WS-OV(1)'); t.num('1.1 %s scale' % k, sc, 'WS-OV(2)'); t.num('1.1 %s full bright' % k, fb, 'WS-OV(3)')
t.raw('MOVE "pig" TO WS-KEY', 'CALL "EF9-THROWN" USING WS-KEY WS-OUT'); t.num('1.1 a pig is not a thrown item', 0, 'WS-OV(1)')
for bl, fb in ((0, 0), (7, 0), (7, 1), (15, 0), (0, 1)):
    t.call('EF9-THROWN-LIGHT', [bl, fb], [15 if fb else bl], '7.1 block light %d full bright %d' % (bl, fb))
def rotx(p, a): c, s = math.cos(a), math.sin(a); return (p[0], p[1] * c - p[2] * s, p[1] * s + p[2] * c)
def roty(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c + p[2] * s, p[1], p[2] * c - p[0] * s)
def rotz(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c - p[1] * s, p[0] * s + p[1] * c, p[2])
for sc in (1, 3, 0.75):
    for ang in (0, 1):
        out = []
        for (x, y) in ((-0.25, 0.375), (0.25, 0.375), (0.25, -0.125), (-0.25, -0.125)):
            p = (x * sc, y * sc, 0.0)
            if ang: p = rotz(roty(rotx(p, math.pi / 2), math.pi), math.pi)
            out += [v + 0.0 for v in p]
        t.call('EF9-THROWN-QUAD', [sc, ang], out, '7.1/7.2 quad for scale %s shot at an angle %d (12 corner values)' % (sc, ang))
# hook quad
txt = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('1. push; scale 0.5; rotate by the camera orientation')][0]
uv = re.search(r'= (\(0, 0, 0, 1\), \(1, 0, 1, 1\), \(1, 1, 1, 0\), \(0, 1, 0, 0\))', txt).group(1)
vs = [tuple(int(x) for x in v.split(',')) for v in re.findall(r'\(([^)]*)\)', uv)]
exp = []
for px, py, u, v in vs: exp += [(px - 0.5) * 0.5, (py - 0.5) * 0.5, u, v]
t.call('EF9-HOOK-QUAD', [], exp, '8.1 hook quad (x, y, u, v of the four vertices)')
# line
def P(d, tt): return (d[0] * tt, d[1] * (tt * tt + tt) * 0.5 + 0.25, d[2] * tt)
def seg(d, i):
    out = []
    for ta, tb in ((i / 16, (i + 1) / 16), ((i + 1) / 16, i / 16)):
        p = P(d, ta); q = P(d, tb); ln = math.sqrt(sum((q[k] - p[k]) ** 2 for k in range(3)))
        out += list(p) + [(q[k] - p[k]) / ln for k in range(3)]
    return out
for d in ((4, 0, 0), (4, -2, 0), (-1.5, 0.75, 2.25), (0.3, -3, -0.7)):
    for i in (0, 5, 8, 15):
        t.call('EF9-HOOK-LINE', [d[0], d[1], d[2], i], seg(d, i), '8 line segment %d for offset %s (position, normal; both vertices)' % (i, d))
t.call('EF9-HOOK-LINE', [4, 0, 0, 8], [2, 0.25, 0] + [None] * 3 + [None] * 6, 'Validation 7 P(0.5) for (4, 0, 0)')
t.call('EF9-HOOK-LINE', [4, -2, 0, 15], [None] * 6 + [4, -1.75, 0] + [None] * 3, 'Validation 7 P(1) for (4, -2, 0)')
for sw in (0, 0.01, 0.25, 0.5, 0.9, 1):
    t.call('EF9-HOOK-SWING', [sw], [msin(math.sqrt(sw) * 3.1415927)], '8 swing factor of %s' % sw)
for rod, right in ((1, 1), (1, 0), (0, 1), (0, 0)):
    t.call('EF9-HOOK-SIDE', [rod, right], [1 if (rod and right) or (not rod and not right) else -1], '8 holding arm: rod in main hand %d, main arm right %d (side)' % (rod, right))
for yo, yb, pt, side, sc, crouch, eye in ((0, 0, 0.5, 1, 1, 0, (10, 65.62, 10)), (90, 100, 0.5, -1, 1, 1, (0, 1.62, 0)), (-170, 170, 0.25, 1, 0.5, 0, (3.5, 7, -2)), (30, 45, 1, -1, 1.2, 1, (-8, 70, 8))):
    a = (yo + (yb - yo) * pt) * D
    s = side * 0.35 * sc; fw = 0.8 * sc; dy = -0.1875 if crouch else 0
    out = [eye[0] + (-mcos(a) * s - msin(a) * fw), eye[1] + (dy - 0.45 * sc), eye[2] + (-msin(a) * s + mcos(a) * fw)]
    t.call('EF9-HOOK-HAND', [yo, yb, pt, side, sc, crouch, eye[0], eye[1], eye[2]], out, '8 third-person hand for body yaw %s to %s partial %s side %d scale %s crouch %d' % (yo, yb, pt, side, sc, crouch))
save9(t, 7)
