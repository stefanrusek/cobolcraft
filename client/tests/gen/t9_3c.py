import sys
sys.argv = ['x']
import io, contextlib
with contextlib.redirect_stdout(io.StringIO()):
    pass
from rt9 import *
import math
exec(open('t9_13r.py').read().split("t = RT(")[0].split("from rt9 import *")[1])
M = 2 ** 64
def wrap(x):
    x %= M
    return x - M if x >= 2 ** 63 else x
def shifts(i):
    s = wrap(i * 493286711)
    sd = wrap(wrap(wrap(s * s) * 4392167121) + wrap(s * 98761))
    return [((((sd >> sh) & 7) + 0.5) / 8 - 0.5) * 0.004 for sh in (16, 20, 24)]
t = RT('TEST-ENTITY-CART-BLOCKS-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 3.2 step 5 through the renderer: a furnace, spawner, command block or TNT minecart carries the cube of its block (default display offset 6)",
   "posed by the cart's operations (shift of the entity id, Y rotation, Z rotation, translate 0.375) and then scale 0.75, translate (-0.5, (offset - 8) / 16, 0.5), Y rotation 90; the chest and hopper carts (no cube model) and the plain cart draw no block.",
   "Only the faces that face the eye are in the mesh; the extents are computed by gen/rt9.py."])
t.start()
t.raw('CALL "PACK-STACK-INIT" USING CLIENT-STATE', 'ADD 1 TO PK-COUNT', 'INITIALIZE PK-PACK(PK-COUNT)', 'MOVE 1 TO PK-KIND(PK-COUNT)', 'MOVE 3 TO PK-LEVEL(PK-COUNT)', 'MOVE "generated/vanilla" TO PK-ID(PK-COUNT)',
      'MOVE 17 TO PK-ID-LENGTH(PK-COUNT)', 'MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)', 'MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)', 'CALL "PACK-STACK-OPEN" USING CLIENT-STATE',
      'CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT', 'CALL "ATLAS-BUILD" USING CLIENT-STATE', 'CALL "CONTENT-SET-COUNTS"', 'MOVE 1 TO WS-FIRST')
EYE = (12.0, 67.0, 13.0)
t.raw('MOVE 12 TO WS-EYE(1)', 'MOVE 67 TO WS-EYE(2)', 'MOVE 13 TO WS-EYE(3)')
pos = (10.5, 64.0, 10.5)
for key, ident, yaw, pitch in (('furnace_minecart', 8, 0, 0), ('spawner_minecart', 100, 90, 0), ('command_block_minecart', 2, 45, 20), ('tnt_minecart', 3, -135, -10)):
    t.spawn(key, yaw, pitch, ident)
    t.raw('CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE', 'MOVE RL-GI-COUNT TO WS-LAST', 'CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE')
    sh = shifts(ident)
    ops = [(1, sh[0], sh[1], sh[2]), (3, yaw, 0, 0), (7, -pitch, 0, 0), (1, 0, 0.375, 0), (2, 0.75, 0.75, 0.75), (1, -0.5, (6 - 8) / 16, 0.5), (3, 90, 0, 0)]
    pts = visible_cube(ops, pos, EYE)
    t.extent('34-9§3.2 %s id %d yaw %s pitch %s block' % (key, ident, yaw, pitch), ext(pts), len(pts) // 4 * 6, 'RL-GI-COUNT', 1)
for key in ('minecart', 'chest_minecart', 'hopper_minecart'):
    t.spawn(key, 0, 0, 60)
    t.raw('CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE')
    t.check('34-9§3.2 %s carries no cube' % key, 0, 'RL-GI-COUNT')
t.save('test_entity_cart_blocks_9')
