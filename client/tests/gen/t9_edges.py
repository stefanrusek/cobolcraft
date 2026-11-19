from rt9 import *
import math
t = RT('TEST-ENTITY-EDGES-9', ["Edge cases of the 34-9 emitters (acceptance US15 34-9§7, §9, §13): an entity row that is no thrown type, a spawner without a stack or without room, a TNT whose item is unknown (content not open), a falling block whose state is the level's, unknown or has no item,",
   "a minecart that carries no cube or whose item is unknown, the rotation about X of ENTITY-OPS-POINT, and the firework's shot-at-angle flag read from Set Entity Data (entry 10)."])
t.extra = ' 01 WS-OPS.\n    05 WS-OP               FLOAT-LONG OCCURS 64 TIMES.\n 01 WS-PT.\n    05 WS-PV               FLOAT-LONG OCCURS 3 TIMES.\n 01 WS-SC                  BINARY-LONG.\n 01 WS-BID                 BINARY-LONG.\n 01 WS-BIX                 BINARY-LONG.\n 01 WS-BROW                PIC X(819).\n 01 WS-BST                 BINARY-LONG.\n 01 WS-FOUND               BINARY-LONG.\n 01 WS-LIM                 BINARY-LONG.\n 01 WS-ONE                 BINARY-LONG VALUE 1.\n 01 WS-TEN                 BINARY-LONG VALUE 10.'
t.start()
t.raw('MOVE 1 TO WS-FIRST')
P = 'acceptance US15 34-9§%s '
t.spawn('pig', 0, 0, 70)
t.raw('MOVE 1 TO EN-STACK-COUNT(1)', 'MOVE 4 TO EN-STACK-ITEM(1)', 'CALL "ENTITY-THROWN-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§7 an entity that is no thrown type draws nothing', 0, 'RL-GI-COUNT')
t.spawn('ominous_item_spawner', 0, 0, 71)
t.raw('MOVE 0 TO EN-STACK-COUNT(1)', 'CALL "ENTITY-SPAWNER-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§9 a spawner without a stack draws nothing', 0, 'RL-GI-COUNT')
t.raw('MOVE 64 TO EN-STACK-COUNT(1)', 'MOVE 4 TO EN-STACK-ITEM(1)', 'COMPUTE WS-LIM = CL-MAX-GI-VERTICES - 5', 'MOVE WS-LIM TO RL-GI-COUNT', 'CALL "ENTITY-SPAWNER-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§9 a spawner with less room than its copies adds nothing', 'WS-LIM', 'RL-GI-COUNT')
t.raw('MOVE 0 TO RL-GI-COUNT')
# TNT: the item is unknown while no content set is open
t.spawn('tnt', 0, 0, 72)
t.raw('MOVE 20 TO EN-VALUE(1)', 'MOVE 0 TO CT-OPEN', 'CALL "ENTITY-TNT-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE', 'MOVE 1 TO CT-OPEN')
t.check('acceptance US15 34-9§13 a TNT whose item is unknown draws nothing', 0, 'RL-GI-COUNT')
# falling block: the level's state (an empty replica holds 0), an unknown state, a block without an item (water)
t.spawn('falling_block', 0, 0, 73)
t.raw('MOVE 0 TO EN-BSTATE(1)', 'CALL "ENTITY-FALLING-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§13 a falling block whose state the level holds is not drawn', 0, 'RL-GI-COUNT')
t.raw('MOVE 99999999 TO EN-BSTATE(1)', 'CALL "ENTITY-FALLING-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§13 a falling block of an unknown state draws nothing', 0, 'RL-GI-COUNT')
t.raw('MOVE 0 TO WS-FOUND', 'PERFORM VARYING WS-SC FROM 1 BY 1 UNTIL WS-SC > 40000 OR WS-FOUND = 1', '    CALL "CONTENT-BLOCK-OF-STATE" USING WS-SC WS-BID WS-BIX WS-BROW WS-BST',
      '    MOVE WS-BROW TO CT-BLOCK-ROW', '    IF CT-BR-KEY = "minecraft:water" OR "water"', '        MOVE 1 TO WS-FOUND', '        MOVE WS-SC TO EN-BSTATE(1)', '    END-IF', 'END-PERFORM')
t.check('acceptance US15 34-9§13 the state of water was found', 1, 'WS-FOUND')
t.raw('CALL "ENTITY-FALLING-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§13 a falling block with no item draws nothing', 0, 'RL-GI-COUNT')
# minecarts that carry no cube, and an unknown item
t.spawn('chest_minecart', 0, 0, 74)
t.raw('CALL "ENTITY-CART-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE')
t.check('acceptance US15 34-9§3 a chest minecart carries no cube', 0, 'RL-GI-COUNT')
t.spawn('furnace_minecart', 0, 0, 75)
t.raw('MOVE 0 TO CT-OPEN', 'CALL "ENTITY-CART-EMIT" USING CLIENT-STATE WS-ROW WS-EYE-TABLE', 'MOVE 1 TO CT-OPEN')
t.check('acceptance US15 34-9§3 a carried block whose item is unknown draws nothing', 0, 'RL-GI-COUNT')
# the rotation about X of the operation list: 90 degrees takes (0, 1, 0) to (0, 0, 1); then a translate (the list is read last first)
t.raw('MOVE 1 TO WS-OP(1)', 'MOVE 5 TO WS-OP(2)', 'MOVE 90 TO WS-OP(3)', 'MOVE 0 TO WS-OP(4) WS-OP(5)', 'MOVE 0 TO WS-PV(1) WS-PV(3)', 'MOVE 1 TO WS-PV(2)', 'CALL "ENTITY-OPS-POINT" USING WS-OPS WS-PT')
for k, v in enumerate((0, 0, 1)):
    t.check('acceptance US15 34-9§13 rotation about X of (0, 1, 0) by 90 degrees, component %d (thousandths)' % (k + 1), v * 1000, 'FUNCTION INTEGER(WS-PV(%d) * 1000 + 0.5)' % (k + 1))
# the firework's flag
t.spawn('firework_rocket', 0, 0, 76)
t.raw('CALL "E9-DATA-BOOL" USING CLIENT-STATE WS-ID WS-TEN WS-ONE')
t.check('acceptance US15 34-9§7 the shot-at-angle flag of Set Entity Data entry 10 is kept', 1, 'EN-X1(1)')
t.save('test_entity_edges_9')
