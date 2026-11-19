from g9 import *
import math
# direction ids: 0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST (Direction ordinal order of the entity data: DIRECTION)
STEP = {0: (0, -1, 0), 1: (0, 1, 0), 2: (0, 0, -1), 3: (0, 0, 1), 4: (-1, 0, 0), 5: (1, 0, 0)}
DATA2D = {3: 0, 4: 1, 2: 2, 5: 3}   # SOUTH 0, WEST 1, NORTH 2, EAST 3 (11 and Open question 10)
t = mk9(10, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 10 and 11 (item frame and painting): the render offset, the frame's submit (step x 0.46875, X and Y rotations by direction, translate 0.5 or 0.4375,",
             "the map branch and the item branch), the lights of a glow frame (max(5, block), 15728880, 15728850), the worked example and Validation 8; the painting's Y rotation, the block position of each cell's light and the vertices of the six faces of a cell",
             "(the table of 11 evaluated symbolically, Validation 9)."])
doc = open(REPO + DOCS[9]).read().split('\n')
for d, (sx, sy, sz) in STEP.items():
    t.call('EF9-FRAME-OFFSET', [sx, sz], [sx * 0.3, -0.25, sz * 0.3], '10 render offset of direction %d' % d)
def frame_ops(d, invisible, rot, has_map):
    sx, sy, sz = STEP[d]
    if d in (0, 1): xrot = -90 * (1 if d == 1 else -1) * -1 if False else (-90 if d == 1 else 90); yrot = 180
    else: xrot = 0; yrot = 180 - DATA2D[d] * 90
    ops = [(1, sx * 0.46875, sy * 0.46875, sz * 0.46875), (5, xrot, 0, 0), (3, yrot, 0, 0), (1, 0, 0, 0.5 if invisible else 0.4375)]
    if has_map: ops += [(7, (rot % 4) * 2 * 360 / 8, 0, 0), (7, 180, 0, 0), (2, 1 / 128, 1 / 128, 1 / 128), (1, -64, -64, 0), (1, 0, 0, -1)]
    else: ops += [(7, rot * 360 / 8, 0, 0), (2, 0.5, 0.5, 0.5)]
    return [len(ops)] + [v for p in ops for v in p]
# the document's rules: UP xRot -90, DOWN +90 (Validation 8), north: yRot 180 - 180 = 0 (worked example)
assert frame_ops(1, 0, 0, 0)[6] == -90 and frame_ops(0, 0, 0, 0)[6] == 90 and frame_ops(2, 0, 0, 0)[10] == 0
for d in range(6):
    for invisible, rot, has_map in ((0, 0, 0), (0, 3, 0), (1, 7, 0), (0, 5, 1), (0, 2, 1), (1, 0, 1)):
        t.call('EF9-FRAME-OPS', [d, invisible, rot, has_map], frame_ops(d, invisible, rot, has_map), '10 submit for direction %d invisible %d rotation %d map %d' % (d, invisible, rot, has_map))
for glow, bl in ((0, 3), (0, 12), (1, 3), (1, 5), (1, 14)):
    t.call('EF9-FRAME-LIGHT', [glow, bl], [max(5, bl) if glow else bl, 15728880 if glow else 0, 15728850 if glow else 0], '10 lights of glow %d block light %d' % (glow, bl))
# 11
for d in (3, 4, 2, 5):
    t.call('EF9-PAINTING-ROT', [d], [180 - DATA2D[d] * 90], '11 Y rotation of direction %d' % d)
def pblock(d, w, h, i, j, x, y, z, bx, bz):
    ox = (i + (-w / 2)) + 0.5; oy = (j + (-h / 2)) + 0.5
    px, pz = bx, bz
    if d == 2: px = math.floor(x + ox)
    elif d == 4: pz = math.floor(z - ox)
    elif d == 3: px = math.floor(x - ox)
    else: pz = math.floor(z + ox)
    return [px, math.floor(y + oy), pz]
for d in (2, 3, 4, 5):
    for w, h, i, j in ((1, 1, 0, 0), (2, 1, 1, 0), (4, 3, 2, 1), (3, 3, 0, 2)):
        t.call('EF9-PAINTING-BLOCK', [d, w, h, i, j, 10.5, 64.5, -3.5, 10, -4], pblock(d, w, h, i, j, 10.5, 64.5, -3.5, 10, -4), '11 light block of cell (%d, %d) of a %d x %d painting facing %d' % (i, j, w, h, d))
# the vertices of the table of 11, evaluated symbolically
rows = table9('### 11') if False else None
txt = '\n'.join(doc)
sect = txt[txt.index('**Geometry** (`renderPainting`'):txt.index('## 12. Lead knot')]
trs = [l for l in sect.split('\n') if l.startswith('| front') or l.startswith('| back') or l.startswith('| top edge') or l.startswith('| bottom edge') or l.startswith('| edge at')]
assert len(trs) == 6
def verts(row):
    cells = [c.strip() for c in row.strip().strip('|').split('|')]
    return re.findall(r'\(([^()]*)\)', cells[2].replace('`', ''))
def face_vertices(w, h, i, j, face):
    env = dict(x1=-w / 2 + i + 1, x0=-w / 2 + i, y1=-h / 2 + j + 1, y0=-h / 2 + j, z=0.03125, uA=(w - i) / w, uB=(w - i - 1) / w, vA=(h - j) / h, vB=(h - j - 1) / h,
               u0=0, u1=1, v0=0, v1=1, uS=0.0625, vS=0.0625)
    out = []
    for v in verts(trs[face]):
        vals = [eval(a.strip(), {}, env) for a in v.split(',')]
        out += vals
    return out
def present(w, h, i, j, face):
    return face in (0, 1) or (face == 2 and j == h - 1) or (face == 3 and j == 0) or (face == 4 and i == w - 1) or (face == 5 and i == 0)
for w, h in ((1, 1), (2, 1), (3, 2)):
    for j in range(h):
        for i in range(w):
            for face in range(6):
                pr = present(w, h, i, j, face)
                exp = [1 if pr else 0] + (face_vertices(w, h, i, j, face) if pr else [None] * 20)
                t.call('EF9-PAINTING-FACE', [w, h, i, j, face], exp, '11 %d x %d painting cell (%d, %d) face %d' % (w, h, i, j, face))
# Validation 9: 2 x 1, cell (0, 0): x0 -1, x1 0, y0 -0.5, y1 0.5, uA = getU(1), uB = getU(0.5), vA = getV(1), vB = getV(0)
f = face_vertices(2, 1, 0, 0, 0)
assert f[0] == 0 and f[1] == -0.5 and f[3] == 0.5 and f[4] == 1.0 and f[8] == 1.0 and f[18] == 0.5 and f[19] == 0.0, f
save9(t, 10)
