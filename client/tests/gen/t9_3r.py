from rt9 import *
import math
rows = []
for r in table9('### 3.1'):
    n = r['part'].replace('`', '')
    off = pose_cell(r['pose offset']); rot = rot_cell(r['pose rotation'])
    o = triple(r['cuboid origin']); sz = re.match(r'\s*' + NUMR + r' x ' + NUMR + r' x ' + NUMR, r['size (w, h, d)']).groups()
    tx = re.search(r'\((\d+), (\d+)\)', r['tex']).groups()
    rows.append('P %s root %s %s' % (n, ' '.join(off), ' '.join(rot)))
    rows.append('C %s %s %s %s %s 0 0' % (n, tx[0], tx[1], ' '.join(o), ' '.join(sz)))
M = 2 ** 64
def wrap(x):
    x %= M
    return x - M if x >= 2 ** 63 else x
def shifts(i):
    s = wrap(i * 493286711)
    sd = wrap(wrap(wrap(s * s) * 4392167121) + wrap(s * 98761))
    return [((((sd >> sh) & 7) + 0.5) / 8 - 0.5) * 0.004 for sh in (16, 20, 24)]
t = RT('TEST-ENTITY-MINECART', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 3.2 through the renderer: the minecart rows of CLMODELS draw the five cuboids of 3.1 (180 vertices) posed as the submit says (shift of the entity id,",
   "Y rotation, Z rotation by the pitch, translate 0.375, scale (-1, -1, 1)); the extent of the vertices is computed by gen/rt9.py from the document's part table; the hurt tilt of entries 8 to 10 and its fall by 1 a tick."])
t.extra = ' 01 WS-TICK              BINARY-LONG.'
t.start()
cases = [('minecart', 7, 0, 0), ('chest_minecart', 8, 90, 0), ('tnt_minecart', 100, 45, 20), ('hopper_minecart', 1, -135, -30), ('furnace_minecart', 2, 180, 10), ('spawner_minecart', 3, 10, 0), ('command_block_minecart', 5, 270, -5)]
for key, ident, yaw, pitch in cases:
    t.spawn(key, yaw, pitch, ident)
    sh = shifts(ident)
    ops = [(1, sh[0], sh[1], sh[2]), (3, yaw, 0, 0), (7, -pitch, 0, 0), (1, 0, 0.375, 0), (2, -1, -1, 1)]
    t.mesh()
    t.extent('34-9§3.2 %s id %d yaw %s pitch %s' % (key, ident, yaw, pitch), extent(vertices(rows, ops), (0.5, 0, 0.5)), 180)
# hurt: entries 8 (time), 9 (direction), 10 (damage) as the boat's; the tilt at the partial tick 1 uses the values less 1; each tick lowers both by 1
def hurt_case(ht, hd, dm, ticks):
    t.spawn('minecart', 30, 0, 7)
    t.raw('MOVE 8 TO WS-INDEX', 'MOVE 1 TO WS-SER', 'MOVE %d TO WS-INT' % ht, 'MOVE 0 TO WS-FLOAT', 'CALL "ENTITY-BOAT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-INT WS-FLOAT',
          'MOVE 9 TO WS-INDEX', 'MOVE %d TO WS-INT' % hd, 'CALL "ENTITY-BOAT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-INT WS-FLOAT',
          'MOVE 10 TO WS-INDEX', 'MOVE 3 TO WS-SER', 'MOVE %s TO WS-FLOAT' % lit(dm), 'CALL "ENTITY-BOAT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-INT WS-FLOAT')
    for k in range(ticks): t.raw('CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE')
    h = ht - ticks; d = max(dm - ticks, 0)
    sh = shifts(7)
    ops = [(1, sh[0], sh[1], sh[2]), (3, 30, 0, 0), (7, 0, 0, 0), (1, 0, 0.375, 0)]
    hh = h - 1
    if hh > 0: ops.append((5, math.sin(hh) * hh * max(d - 1, 0) / 10 * hd, 0, 0))
    ops.append((2, -1, -1, 1))
    t.mesh()
    t.extent('34-9§3.2 hurt time %d direction %d damage %s after %d ticks' % (ht, hd, dm, ticks), extent(vertices(rows, ops), (0.5, 0, 0.5)), 180)
hurt_case(10, 1, 20, 0); hurt_case(10, -1, 8, 3); hurt_case(6, 1, 30, 5); hurt_case(10, 1, 20, 10)
# a cow ignores entries 8 to 10 (no hurt state)
t.save('test_entity_minecart')
