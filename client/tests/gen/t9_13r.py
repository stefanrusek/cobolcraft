from rt9 import *
import math
FACES = ["011111101001", "110010000100", "111110100101", "010011001000", "010110111011", "100000001101"]
SHADE = [0.8, 0.8, 0.6, 0.6, 1.0, 0.5]
def op_point(ops, p):
    for code, a, b, c in reversed(ops):
        if code == 1: p = (p[0] + a, p[1] + b, p[2] + c)
        elif code == 2: p = (p[0] * a, p[1] * b, p[2] * c)
        elif code == 3: p = roty(p, math.radians(a))
        elif code == 5: p = rotx(p, math.radians(a))
        elif code == 7: p = rotz(p, math.radians(a))
    return p
def swell(f):
    s = max(0.0, min(1.0, 1 - f / 10)); s = s * s; s = s * s; return s * 0.3
def visible_cube(ops, pos, eye):
    """vertices (relative to the eye) of the faces that face the eye, in the order the emitter keeps (6 vertices a face)"""
    pts = []
    for f in FACES:
        c = []
        for k in range(4):
            q = op_point(ops, tuple(float(f[k * 3 + j]) for j in range(3)))
            c.append(tuple(q[j] + pos[j] - eye[j] for j in range(3)))
        e1 = [c[1][j] - c[0][j] for j in range(3)]; e2 = [c[0][j] - c[3][j] for j in range(3)]
        n = (e1[1] * e2[2] - e1[2] * e2[1], e1[2] * e2[0] - e1[0] * e2[2], e1[0] * e2[1] - e1[1] * e2[0])
        d = sum(n[j] * (c[0][j] + c[2][j]) for j in range(3))
        if d < 0: pts += c
    return pts
def ext(pts):
    r = []
    for k in range(3):
        v = [p[k] for p in pts]
        r += [math.floor(min(v) * 1000 + 0.5), math.floor(max(v) * 1000 + 0.5)]
    return r
t = RT('TEST-ENTITY-BLOCKS-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 13 through the renderer: a primed TNT is the cube of the tnt block posed by the submit of 13.2 (translate 0.5, swell scale below f = 10,",
   "Y -90, translate (-0.5, -0.5, 0.5), Y 90) and a falling block the cube of its block translated by (-0.5, 0, -0.5) unless the level holds the same state (13.1). Only the faces that face the eye are in the mesh (6 vertices each);",
   "the extents are computed by gen/rt9.py from the document's operations and the cube's face table."])
t.start()
t.raw('CALL "PACK-STACK-INIT" USING CLIENT-STATE', 'ADD 1 TO PK-COUNT', 'INITIALIZE PK-PACK(PK-COUNT)', 'MOVE 1 TO PK-KIND(PK-COUNT)', 'MOVE 3 TO PK-LEVEL(PK-COUNT)', 'MOVE "generated/vanilla" TO PK-ID(PK-COUNT)',
      'MOVE 17 TO PK-ID-LENGTH(PK-COUNT)', 'MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)', 'MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)', 'CALL "PACK-STACK-OPEN" USING CLIENT-STATE',
      'CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT', 'CALL "ATLAS-BUILD" USING CLIENT-STATE', 'CALL "CONTENT-SET-COUNTS"', 'MOVE 1 TO WS-FIRST')
EYE = (12.0, 67.0, 13.0)
t.raw('MOVE 12 TO WS-EYE(1)', 'MOVE 67 TO WS-EYE(2)', 'MOVE 13 TO WS-EYE(3)')
pos = (10.5, 64.0, 10.5)
for f in (80, 30, 9, 5, 4, 1, 0):
    t.spawn('tnt', 0, 0, 50)
    t.raw('MOVE %d TO EN-VALUE(1)' % f if f == int(f) else 'MOVE %s TO EN-VALUE(1)' % lit(f))
    t.raw('CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE', 'MOVE RL-GI-COUNT TO WS-LAST', 'CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE')
    ops = [(1, 0, 0.5, 0)]
    if f < 10: ops.append((2, 1 + swell(f), 1 + swell(f), 1 + swell(f)))
    ops += [(3, -90, 0, 0), (1, -0.5, -0.5, 0.5), (3, 90, 0, 0)]
    pts = visible_cube(ops, pos, EYE)
    t.extent('34-9§13.2 tnt fuse %s' % f, ext(pts), len(pts) // 4 * 6, 'RL-GI-COUNT', 1)
# the fuse falls by 1 a tick
t.spawn('tnt', 0, 0, 51)
t.raw('MOVE 80 TO EN-VALUE(1)', 'CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE', 'CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE')
t.check('34-9§13.2 the fuse falls by 1 a tick', 78, 'EN-VALUE(1)')
# a falling block of stone (state 1) and its landing
t.spawn('falling_block', 0, 0, 52)
t.raw('MOVE 1 TO EN-BSTATE(1)', 'CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE', 'MOVE RL-GI-COUNT TO WS-LAST', 'CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE')
pts = visible_cube([(1, -0.5, 0, -0.5)], pos, EYE)
t.extent('34-9§13.1 falling stone', ext(pts), len(pts) // 4 * 6, 'RL-GI-COUNT', 1)
t.save('test_entity_blocks_9')
