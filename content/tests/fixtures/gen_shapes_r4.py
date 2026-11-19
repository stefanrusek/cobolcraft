#!/usr/bin/env python3
"""Independent model of the R4 block shapes of docs/protocol/51-block-shapes.md (sections 2, 3.8, R-E5, R-E26).
Written from the document text only: authored pixel boxes, the turn formulas of section 2, no reading of the program.
Prints rows "block|prop1|prop2|C or O|boxes" (boxes in thousandths of a pixel, sorted) = content/tests/fixtures/shapes_r4.txt: python3 gen_shapes_r4.py > shapes_r4.txt"""
import sys
from fractions import Fraction as F

def yaw(b, key):
    x1, y1, z1, x2, y2, z2 = b
    if key == 'north': return b
    if key == 'east': return (16 - z2, y1, x1, 16 - z1, y2, x2)
    if key == 'south': return (16 - x2, y1, 16 - z2, 16 - x1, y2, 16 - z1)
    if key == 'west': return (z1, y1, 16 - x2, z2, y2, 16 - x1)
    raise ValueError(key)

def all6(b, key):
    x1, y1, z1, x2, y2, z2 = b
    if key == 'up': return (x1, 16 - z2, y1, x2, 16 - z1, y2)
    if key == 'down': return (x1, z1, 16 - y2, x2, z2, 16 - y1)
    return yaw(b, key)

def axisyaw(b, facing):  # key z for north/south, key x (the east turn) for east/west
    return b if facing in ('north', 'south') else yaw(b, 'east')

def attach(b, face):
    x1, y1, z1, x2, y2, z2 = b
    if face == 'floor': return (x1, 16 - z2, y1, x2, 16 - z1, y2)
    if face == 'ceiling': return (16 - x2, z1, y1, 16 - x1, z2, y2)
    return b

def fmt(boxes):
    if not boxes: return '-'
    out = []
    for b in boxes:
        out.append(",".join(str(int(round(F(v) * 1000))) for v in b))
    return ";".join(sorted(out))

rows = []
def row(block, p1, p2, which, boxes):
    rows.append((block, p1, p2, which, fmt(boxes)))

def both(block, p1, p2, coll, outl=None):
    row(block, p1, p2, 'C', coll)
    row(block, p1, p2, 'O', coll if outl is None else outl)

# hopper 3.8.1: body boxes, spout by facing
body = [(0,10,0,16,11,16),(0,11,0,2,16,16),(14,11,0,16,16,16),(2,11,0,14,16,2),(2,11,14,14,16,16),(4,4,4,12,10,12)]
spout = {'north': (6,4,0,10,8,8), 'east': (8,4,6,16,8,10), 'south': (6,4,8,10,8,16), 'west': (0,4,6,8,8,10), 'down': (6,0,6,10,6,10)}
for f, s in spout.items():
    both('hopper', 'facing=' + f, '', body + [s])

# cauldrons 3.8.2
legs = [(0,0,0,4,3,2),(0,0,2,2,3,4),(12,0,0,16,3,2),(14,0,2,16,3,4),(0,0,14,4,3,16),(0,0,12,2,3,14),(12,0,14,16,3,16),(14,0,12,16,3,14)]
caul = legs + [(0,3,0,16,4,16),(0,4,0,16,16,2),(0,4,14,16,16,16),(0,4,2,2,16,14),(14,4,2,16,16,14)]
both('cauldron', '', '', caul)
both('lava_cauldron', '', '', caul)
for lv in (1, 2, 3):
    both('water_cauldron', 'level=%d' % lv, '', caul)
    both('powder_snow_cauldron', 'level=%d' % lv, '', caul)

# composter 3.8.3
for lv in range(9):
    f = min(max(1 + 2 * min(lv, 7), 2), 16)
    walls = lambda f: [(0,f,0,16,16,2),(0,f,14,16,16,16),(0,f,2,2,16,14),(14,f,2,16,16,14)]
    row('composter', 'level=%d' % lv, '', 'C', [(0,0,0,16,2,16)] + walls(2))
    row('composter', 'level=%d' % lv, '', 'O', [(0,0,0,16,f,16)] + walls(f))

# bell 3.8.4
B = [(5,6,5,11,13,11),(4,4,4,12,6,12)]
for facing in ('north', 'east', 'south', 'west'):
    both('bell', 'attachment=floor', 'facing=' + facing, [axisyaw((0,0,4,16,16,12), facing)])
    both('bell', 'attachment=ceiling', 'facing=' + facing, B + [(7,13,7,9,16,9)])
    both('bell', 'attachment=double_wall', 'facing=' + facing, B + [axisyaw((7,13,0,9,15,16), facing)])
    both('bell', 'attachment=single_wall', 'facing=' + facing, B + [yaw((7,13,0,9,15,13), facing)])

# lectern R-E5 / 3.8.6
coll = [(0,0,0,16,2,16),(4,2,4,12,14,12)]
desk = [(0,10,1,16,14,F(16,3)),(0,12,F(16,3),16,16,F(29,3)),(0,14,F(29,3),16,18,14)]
# the document gives the constants as the six decimal numbers themselves
desk = [(0,10,1,16,14,F('5.333333')),(0,12,F('5.333333'),16,16,F('9.666667')),(0,14,F('9.666667'),16,18,14)]
for facing in ('north', 'east', 'south', 'west'):
    row('lectern', 'facing=' + facing, '', 'C', coll)
    row('lectern', 'facing=' + facing, '', 'O', coll + [yaw(d, facing) for d in desk])

# grindstone 3.8.7
gw = [(2,6,7,4,10,16),(2,5,3,4,11,9),(12,6,7,14,10,16),(12,5,3,14,11,9),(4,2,0,12,14,12)]
for face in ('wall', 'floor', 'ceiling'):
    for facing in ('north', 'east', 'south', 'west'):
        bx = [yaw(attach(b, face), facing) for b in gw]
        both('grindstone', 'face=' + face, 'facing=' + facing, bx)

# pistons R-E25, R-E26
for blk in ('piston', 'sticky_piston'):
    for facing in ('north', 'east', 'south', 'west', 'up', 'down'):
        both(blk, 'extended=true', 'facing=' + facing, [all6((0,0,4,16,16,16), facing)])
        both(blk, 'extended=false', 'facing=' + facing, [(0,0,0,16,16,16)])
for facing in ('north', 'east', 'south', 'west', 'up', 'down'):
    for short, arm in (('false', (6,6,4,10,10,20)), ('true', (6,6,4,10,10,16))):
        for typ in ('normal', 'sticky'):
            both('piston_head', 'facing=' + facing, 'short=' + short + ',type=' + typ,
                 [all6((0,0,0,16,16,4), facing), all6(arm, facing)])

# scaffolding outline static (3.8.5): context-free (empty context): Stable or Unstable
stable = [(0,14,0,16,16,16),(0,0,0,2,16,2),(14,0,0,16,16,2),(14,0,14,16,16,16),(0,0,14,2,16,16)]
unstable = stable + [(0,0,0,16,2,16),(0,0,0,16,2,2),(14,0,0,16,2,16),(0,0,14,16,2,16),(0,0,0,2,2,16)]
# interaction shapes (51 section 1.8.1, 3.8.1 to 3.8.3, 3.8.5): "I" rows; the default is the empty shape
def inter(block, p1, p2, boxes):
    row(block, p1, p2, 'I', boxes)
for blk in ('cauldron', 'lava_cauldron'):
    inter(blk, '', '', [(2,4,2,14,16,14)])
for lv in (1, 2, 3):
    inter('water_cauldron', 'level=%d' % lv, '', [(2,4,2,14,16,14)])
    inter('powder_snow_cauldron', 'level=%d' % lv, '', [(2,4,2,14,16,14)])
for lv in range(9):
    inter('composter', 'level=%d' % lv, '', [(0,0,0,16,16,16)])
for bt in ('false', 'true'):
    inter('scaffolding', 'distance=2', 'bottom=' + bt, [(0,0,0,16,16,16)])
cv = (2,11,2,14,16,14)
stub = (6,8,0,10,10,4)
for f in ('north', 'east', 'south', 'west'):
    inter('hopper', 'facing=' + f, '', [cv, yaw(stub, 'north' if f == 'north' else f)] if f != 'north' else [cv, stub])
inter('hopper', 'facing=down', '', [cv])
for blk, p1 in (('stone', ''), ('oak_slab', 'type=bottom'), ('chest', 'type=single'), ('bell', 'attachment=floor')):
    inter(blk, p1, '', [])

# shulker box (3.8.8): the box of the current tick's progress p, q = 8 p pixels, by the direction in the order of 05c (0 down, 1 up, 2 north, 3 south, 4 west, 5 east);
# "S" rows: p1 = the direction number, p2 = the progress in tenths (the lid steps 0.1 a tick; 10 is fully open)
for d, name in enumerate(('down', 'up', 'north', 'south', 'west', 'east')):
    for t in range(0, 11):
        q = F(8 * t, 10)
        b = {'up': (0,0,0,16,16 + q,16), 'down': (0,-q,0,16,16,16), 'north': (0,0,-q,16,16,16),
             'south': (0,0,0,16,16,16 + q), 'east': (0,0,0,16 + q,16,16), 'west': (-q,0,0,16,16,16)}[name]
        row('shulker_box', str(d), str(t), 'S', [b])

# light data (51 section 3.8.11, 1.8.1): "L" rows, expected "flags/dampening/occlusion boxes" with flags = 1 canOcclude + 2 useShapeForLightOcclusion + 4 propagatesSkylightDown.
# The occlusion shape is the outline (the empty shape when the block cannot occlude); the lectern's is its collision shape. propagatesSkylightDown by the table.
outline = {(b, p1, p2): bx for (b, p1, p2, w, bx) in rows if w == 'O'}
coll = {(b, p1, p2): bx for (b, p1, p2, w, bx) in rows if w == 'C'}
def light(block, p1, p2, can, use, prop, damp, occ):
    flags = (1 if can else 0) + (2 if use else 0) + (4 if prop else 0)
    row(block, p1, p2, 'L', [])
    rows[-1] = (block, p1, p2, 'L', "%d/%d/%s" % (flags, damp, occ))
for blk, p1 in (('cauldron', ''), ('lava_cauldron', ''), ('water_cauldron', 'level=2'), ('powder_snow_cauldron', 'level=3')):
    light(blk, p1, '', False, False, True, 0, '-')
for f in ('north', 'east', 'south', 'west', 'down'):
    light('hopper', 'facing=' + f, '', False, False, True, 0, '-')
for a in ('floor', 'ceiling', 'single_wall', 'double_wall'):
    light('bell', 'attachment=' + a, 'facing=east', True, False, True, 0, outline[('bell', 'attachment=' + a, 'facing=east')])
for bt in ('false', 'true'):
    # the empty context: Unstable when bottom else Stable; waterlogged states do not propagate skylight and dampen by 1
    key = ('scaffolding', 'bottom=' + bt, '')
# Scaffolding: 51 section 3.8.5 and the table 3.8.11 say canOcclude true (occlusion shape Unstable or Stable), but its builder chain has noCollision(), which clears canOcclude
# (51 section 1.2, 24-1 section 5.2): the two statements disagree and the general rule is kept here (canOcclude false, occlusion shape empty), see the report on 51.
for wl in ('false', 'true'):
    for bt in ('false', 'true'):
        light('scaffolding', 'bottom=' + bt, 'waterlogged=' + wl, False, False, wl == 'false', 0 if wl == 'false' else 1, '-')
for lv in (0, 3, 8):
    light('composter', 'level=%d' % lv, '', True, False, True, 0, outline[('composter', 'level=%d' % lv, '')])
for face in ('wall', 'floor', 'ceiling'):
    light('grindstone', 'face=' + face, 'facing=north', True, False, True, 0, outline[('grindstone', 'face=' + face, 'facing=north')])
light('lectern', 'facing=north', '', True, True, True, 0, coll[('lectern', 'facing=north', '')])
light('piston', 'extended=false', 'facing=north', True, False, False, 15, '0,0,0,16000,16000,16000')
light('piston', 'extended=true', 'facing=north', True, True, True, 0, outline[('piston', 'extended=true', 'facing=north')])
light('sticky_piston', 'extended=true', 'facing=up', True, True, True, 0, outline[('sticky_piston', 'extended=true', 'facing=up')])
for sh in ('false', 'true'):
    light('piston_head', 'facing=north', 'short=%s,type=normal' % sh, True, True, True, 0, outline[('piston_head', 'facing=north', 'short=%s,type=normal' % sh)])
light('moving_piston', '', '', False, False, True, 0, '-')
light('shulker_box', 'facing=up', '', False, False, False, 1, '-')
light('stone', '', '', True, False, False, 15, '0,0,0,16000,16000,16000')
light('oak_slab', 'type=bottom', 'waterlogged=false', True, True, True, 0, '0,0,0,16000,8000,16000')
light('oak_slab', 'type=double', 'waterlogged=false', True, False, False, 15, '0,0,0,16000,16000,16000')
light('glass', '', '', False, False, True, 0, '-')
light('oak_leaves', 'distance=1', 'persistent=true,waterlogged=false', False, False, False, 1, '-')

# face shapes (51 section 1.8.1): "F" rows of the occlusion shape of the state: p2 = the direction (0 down, 1 up, 2 north, 3 south, 4 west, 5 east); the cross-section of the
# shape 1e-7 inside the cell on that side, projected on the face and drawn flat on the face plane (the coordinate of the axis is the plane, both ends).
def face(boxes, d):
    axis = {0: 1, 1: 1, 2: 2, 3: 2, 4: 0, 5: 0}[d]
    high = d in (1, 3, 5)
    out = []
    for b in boxes:
        lo, hi = F(b[axis]), F(b[axis + 3])
        if high:
            ok = hi >= 16 and lo < 16
            plane = 16
        else:
            ok = lo <= 0 and hi > 0
            plane = 0
        if ok:
            c = list(b)
            c[axis] = plane
            c[axis + 3] = plane
            out.append(tuple(c))
    return out
def facerows(block, p1, boxes):
    for d in range(6):
        row(block, p1, str(d), 'F', face(boxes, d))
facerows('lectern', 'facing=north', coll_boxes if False else [(0,0,0,16,2,16),(4,2,4,12,14,12)])
facerows('piston', 'extended=true,facing=north', [(0,0,4,16,16,16)])
facerows('piston', 'extended=true,facing=up', [(0,0,0,16,12,16)])
facerows('piston_head', 'facing=north,short=false,type=normal', [(0,0,0,16,16,4),(6,6,4,10,10,20)])
facerows('piston_head', 'facing=north,short=true,type=normal', [(0,0,0,16,16,4),(6,6,4,10,10,16)])
facerows('stone', '', [(0,0,0,16,16,16)])
facerows('oak_slab', 'type=bottom,waterlogged=false', [(0,0,0,16,8,16)])

if __name__ == '__main__':
    for r in rows:
        print("|".join(r))
