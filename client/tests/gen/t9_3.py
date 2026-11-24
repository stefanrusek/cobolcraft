from g9 import *
import math,re
t = mk9(3, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 3 (minecarts): 3.1 the shared MinecartModel part by part for the seven layers, 3.2 the offsetSeed shifts (Validation 3 and the formula with 64-bit wrapping),",
            "the render pose of the new movement behaviour (offset, Y rotation, Z rotation, the hurt tilt, scale), the display block transform of step 5, the culling box growth, the default display block and offset per type, the passenger attachment, and 13.2's swell",
            "and isLit as the TNT minecart contents use them (Validation 5)."], extra='\n 01 WS-KEY               PIC X(24).\n 01 WS-BLOCK-NAME         PIC X(24).\n 01 WS-OFFSET             BINARY-LONG.', title='minecarts')
t.extra_ws += ''
# 3.1 the model
rows = []
for r in table9('### 3.1'):
    n = r['part'].replace('`', '')
    off = pose_cell(r['pose offset']); rot = rot_cell(r['pose rotation'])
    o = triple(r['cuboid origin']); sz = re.match(r'\s*' + NUMR + r' x ' + NUMR + r' x ' + NUMR, r['size (w, h, d)']).groups()
    tx = re.search(r'\((\d+), (\d+)\)', r['tex']).groups()
    rows.append('P %s root %s %s' % (n, ' '.join(off), ' '.join(rot)))
    rows.append('C %s %s %s %s %s 0 0' % (n, tx[0], tx[1], ' '.join(o), ' '.join(sz)))
for layer in ('MINECART', 'CHEST_MINECART', 'COMMAND_BLOCK_MINECART', 'FURNACE_MINECART', 'HOPPER_MINECART', 'SPAWNER_MINECART', 'TNT_MINECART'):
    layer_check(t, layer, rows, 64, 32, '3.1')
# 3.2 offsets: the doc's validation values, then the formula over more ids
M = 2 ** 64
def wrap(x):
    x %= M
    return x - M if x >= 2 ** 63 else x
def seed_of(i):
    s = wrap(i * 493286711)
    return wrap(wrap(wrap(s * s) * 4392167121) + wrap(s * 98761))
v3 = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('3. Minecart offsets')][0]
ids = [int(x) for x in re.findall(r'[Ii]d (\d+)|entity id (\d+)', v3) and [a or b for a, b in re.findall(r'(?:Id (\d+)|entity id (\d+))', v3)]]
seeds = [int(x) for x in re.findall(r'(?:offsetSeed = |seed )`?(-?\d{5,})`?', v3)]
offs = re.findall(r'offsets `\(([^)]*)\)`', v3)
assert len(ids) == 3 and len(seeds) == 3 and len(offs) == 3, (ids, seeds, offs)
for i, sd, of in zip(ids, seeds, offs):
    assert seed_of(i) == sd
    o = [float(x) for x in of.split(',')]
    t.call('EF9-MINECART-OFFSET', [i], o + [sd & (2 ** 27 - 1)], '3.2 offsets of entity %d (Validation 3: x, y, z, low 27 bits of the seed %d)' % (i, sd))
for i in (0, 3, 7, 1000, 123456, 999999):
    sd = seed_of(i)
    o = [((((sd >> sh) & 7) + 0.5) / 8 - 0.5) * 0.004 for sh in (16, 20, 24)]
    t.call('EF9-MINECART-OFFSET', [i], o + [sd & (2 ** 27 - 1)], '3.2 offsets of entity %d (the formula with 64-bit wrapping)' % i)
# 3.2 the submit
def ops(yaw, xrot, ht, hd, dt, ox, oy, oz):
    o = [(1, ox, oy, oz), (3, yaw, 0, 0), (7, -xrot, 0, 0), (1, 0, 0.375, 0)]
    if ht > 0: o.append((5, math.sin(ht) * ht * dt / 10 * hd, 0, 0))
    o.append((2, -1, -1, 1))
    return [len(o)] + [v for p in o for v in p]
for st in ((0, 0, 0, 1, 0, 0, 0, 0), (90, 12, 0, 1, 0, 0.00175, -0.00125, 0.00025), (-135, -30, 5, 1, 18, 0.001, 0, -0.001), (45, 0, 2.5, -1, 7, 0, 0.0005, 0), (10, 5, 0, -1, 4, 0, 0, 0)):
    t.call('EF9-MINECART-OPS', list(st), ops(*st), '3.2 pose for yaw %s pitch %s hurtTime %s dir %s damage %s shift (%s, %s, %s)' % st)
for d in (1, 6, 8):
    t.call('EF9-MINECART-CONTENTS', [d], [3, 2, 0.75, 0.75, 0.75, 1, -0.5, (d - 8) / 16, 0.5, 3, 90, 0, 0], '3.2 step 5 transform for display offset %d' % d)
for d, nonair in ((6, 1), (8, 1), (1, 1), (6, 0), (12, 0)):
    t.call('EF9-MINECART-CULL', [d, nonair], [d * 0.75 / 16 if nonair else 0], '3.2 culling box growth for display offset %d, not air %d' % (d, nonair))
# 3.2 display block per type
dl = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('**Display block per type**')][0]
for key, blk, off in (('minecart', '', 6), ('chest_minecart', 'chest', 8), ('furnace_minecart', 'furnace', 6), ('hopper_minecart', 'hopper', 1), ('spawner_minecart', 'spawner', 6), ('command_block_minecart', 'command_block', 6), ('tnt_minecart', 'tnt', 6)):
    if blk: assert ('`%s_minecart` ' % key.split('_minecart')[0] in dl) or key in dl
    t.raw('MOVE "%s" TO WS-KEY' % key, 'MOVE "x" TO WS-BLOCK-NAME', 'CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET')
    t.text('3.2 default display block of %s' % key, blk, 'WS-BLOCK-NAME'); t.num('3.2 default display offset of %s' % key, off, 'WS-OFFSET')
t.call('EF9-MINECART-PASSENGER', [0], [0, 0.1875, 0], '1.3 passenger attachment of an ordinary rider')
t.call('EF9-MINECART-PASSENGER', [1], [0, 0, 0], '1.3 passenger attachment of a villager or a wandering trader')
t.sec(13, 'falling blocks and primed TNT')
# 13.2 swell and isLit (Validation 5, worked values)
def swell(f):
    s = max(0.0, min(1.0, 1 - f / 10)); s = s * s; s = s * s; return s * 0.3
for f in (-5, -1, 0, 0.5, 4.9, 5, 9, 9.9, 10, 12):
    t.call('EF9-TNT-SWELL', [f], [swell(f)], '13.2 swell(%s)' % f)
assert abs(1 + swell(5) - 1.01875) < 1e-9 and abs(1 + swell(0) - 1.3) < 1e-9
for f in (-1, -0.5, 0, 4.9, 5, 9.99, 10, 10.5, 14.9, 15, 20):
    t.call('EF9-TNT-LIT', [f], [1 if f >= 0 and int(f / 5) % 2 == 0 else 0], '13.2 isLit(%s)' % f)
for f in (-1, -0.5, 0, 5, 9, 10, 11):
    if -1 < f < 10:
        a = swell(f); exp = [2, 1, -a * 0.5, 0, -a * 0.5, 2, 1 + a, 1 + a, 1 + a]
    else: exp = [0]
    t.call('EF9-TNT-CART-OPS', [f], exp, '3.2 TNT minecart contents for f = %s' % f)
save9(t, 3)
