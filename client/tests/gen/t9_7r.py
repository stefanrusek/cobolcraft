from rt9 import *
import math
from jr9 import JR
def ext_of(pts, origin=(0.5, 0, 0.5)):
    r = []
    for k in range(3):
        v = [p[k] + origin[k] for p in pts]
        r += [math.floor(min(v) * 1000 + 0.5), math.floor(max(v) * 1000 + 0.5)]
    return r
def rotx(p, a): c, s = math.cos(a), math.sin(a); return (p[0], p[1] * c - p[2] * s, p[1] * s + p[2] * c)
def roty(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c + p[2] * s, p[1], p[2] * c - p[0] * s)
def rotz(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c - p[1] * s, p[0] * s + p[1] * c, p[2])
def world(local, yaw):
    c, s = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    return (local[0] * -c + local[2] * s, local[1], local[0] * -s + local[2] * -c)
t = RT('TEST-ENTITY-THROWN-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 7 and 9.3 through the renderer: thrown items and the firework rocket are one quad of the carried item's flat model facing the camera (scale of the type: fireball 3,",
   "small fireball 0.75, the rest 1; a rocket shot at an angle rotated X 90, Y 180, Z 180), the ominous item spawner draws renderedAmount flat copies spun by wrapDegrees(age x 40) and grown over 50 ticks; extents computed by gen/rt9.py."])
t.extra = ''
t.start()
t.raw('MOVE 1 TO WS-FIRST')
SC = {'snowball': 1, 'egg': 1, 'ender_pearl': 1, 'splash_potion': 1, 'lingering_potion': 1, 'experience_bottle': 1, 'eye_of_ender': 1, 'fireball': 3, 'small_fireball': 0.75, 'firework_rocket': 1}
for key, sc in SC.items():
    for yaw in (0, 90, 33):
        for angle in ((0, 1) if key == 'firework_rocket' else (0,)):
            t.spawn(key, 0, 0, 40)
            t.raw('MOVE %d TO PL-YAW' % yaw, 'MOVE %d TO EN-X1(1)' % angle)
            t.gimesh(1)
            pts = []
            for (x, y) in ((-0.25, 0.375), (0.25, 0.375), (0.25, -0.125), (-0.25, -0.125)):
                p = (x * sc, y * sc, 0.0)
                if angle: p = rotz(roty(rotx(p, math.pi / 2), math.pi), math.pi)
                pts.append(world(p, yaw))
            t.extent('34-9§7 %s shot at angle %d camera yaw %d' % (key, angle, yaw), ext_of(pts), 6, 'RL-GI-COUNT')
# a type that carries no stack draws nothing
t.spawn('snowball', 0, 0, 41)
t.raw('MOVE 0 TO EN-STACK-COUNT(1)', 'CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE')
t.check('34-9§7 a thrown item without a stack draws nothing', 0, 'RL-GI-COUNT')
# 9.3 the spawner
def wrapd(x): return x - 360 * math.floor((x + 180) / 360)
def copies(n): return 1 if n <= 1 else 2 if n <= 16 else 3 if n <= 32 else 4 if n <= 48 else 5
for count, item, ms in ((1, 4, 0), (1, 4, 1250), (2, 4, 5000), (20, 9, 2500), (64, 4, 12345)):
    age = ms / 50
    t.spawn('ominous_item_spawner', 0, 0, 42)
    t.raw('MOVE %d TO CL-NOW-MS' % ms)
    t.gimesh(count, item)
    n = copies(count); rnd = JR(item)
    step = 0.03125 * 1.5; z0 = -(step * (n - 1)) / 2
    offs = [(0, 0, z0)]
    for k in range(1, n):
        x = (rnd.nextFloat() * 2 - 1) * 0.075; y = (rnd.nextFloat() * 2 - 1) * 0.075
        offs.append((x, y, z0 + step * k))
    sc = age / 50 if age <= 50 else 1.0
    sp = wrapd(age * 40)
    pts = []
    for (ox, oy, oz) in offs:
        for (x, y) in ((-0.25, 0.375), (0.25, 0.375), (0.25, -0.125), (-0.25, -0.125)):
            p = roty((x + ox, y + oy, oz), math.radians(sp))
            pts.append((p[0] * sc, p[1] * sc, p[2] * sc))
    t.extent('34-9§9.3 spawner stack %d age %s' % (count, age), ext_of(pts), 12 * n, 'RL-GI-COUNT')
t.save('test_entity_thrown_9')
