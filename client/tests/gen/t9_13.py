from g9 import *
import math
t = mk9(13, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 13 (falling blocks and primed TNT): the TNT submit (translate, swell scale below f = 10, Y rotations, worked values of 13.2), the white flash overlay,",
             "the falling block's translation, shouldRender (the landed state hides the entity) and the block position of the lookup."], title='falling blocks and primed TNT')
def swell(f):
    s = max(0.0, min(1.0, 1 - f / 10)); s = s * s; s = s * s; return s * 0.3
for f in (-1, -0.5, 0, 0.5, 4.9, 5, 9, 9.99, 10, 12, 80):
    o = [(1, 0, 0.5, 0)]
    if f < 10: o.append((2, 1 + swell(f), 1 + swell(f), 1 + swell(f)))
    o += [(3, -90, 0, 0), (1, -0.5, -0.5, 0.5), (3, 90, 0, 0)]
    t.call('EF9-TNT-OPS', [f], [len(o)] + [v for p in o for v in p], '13.2 TNT pose for f = %s' % f)
for f, lit in ((5, 0), (4.9, 1), (0, 1), (-1, 0), (10, 1), (14.99, 1), (15, 0)):
    t.call('EF9-TNT-FLASH', [f], [15 if lit else 0, 63 if lit else 0], '13.2 overlay for f = %s (u, alpha)' % f)
t.call('EF9-FALLING-OPS', [], [1, 1, -0.5, 0, -0.5], '13.1 submit translate (-0.5, 0, -0.5)')
for e, l in ((5, 5), (5, 0), (0, 5), (123, 124)):
    t.call('EF9-FALLING-SHOWN', [e, l], [0 if e == l else 1], '13.1 shouldRender: entity state %d, level state %d' % (e, l))
for x, y, z, h in ((10.5, 64, 10.5, 0.98), (-0.3, 63.2, 5.99, 0.98), (1.5, 70.02, -7.2, 0.98), (-10.5, -64, 0.5, 0.98)):
    t.call('EF9-FALLING-POS', [x, y, z, h], [math.floor(x), math.floor(y + h), math.floor(z)], '13.1 block position at (%s, %s, %s)' % (x, y, z))
save9(t, 13)
