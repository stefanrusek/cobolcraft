*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md sections 10.3 and 10.3.1 "Dispenser"): a dispenser facing a tame adult nautilus or zombie nautilus
*> (the entity's box meets the front cell) puts one nautilus armor into its empty BODY slot or one saddle into its empty SADDLE slot (canEquipWithDispenser: alive, canUseSlot, the slot empty,
*> canDispenserEquipIntoSlot true for BODY and SADDLE of a nautilus); the mob becomes persistent and the item is spent. An untamed or baby nautilus, a filled slot or a nautilus that is not in the front cell
*> leave the item to the default behaviour (it is thrown). The first entity that qualifies takes it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAUTILUS-DISPENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY WCSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-IDKEY               PIC X(112).
 01 WS-IDOUT               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FACING              BINARY-LONG VALUE 5.
 01 WS-BARE                PIC X(48).
 01 WS-SADDLE              BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-NAU                 BINARY-LONG.
 01 WS-NAU2                BINARY-LONG.
 01 WS-ZOM                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-CY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE "saddle" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SADDLE
     MOVE "diamond_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-ARMOR
     MOVE "cobblestone" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-STONE

*>   A tame adult nautilus in the front cell takes a saddle: the slot is filled, the mob persists, the item is spent.
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-IN-FRONT
     MOVE WS-M TO WS-NAU
     MOVE 0 TO EN-PERSISTENT(WS-NAU)
     MOVE WS-SADDLE TO WS-ITEM
     MOVE "saddle" TO WS-BARE
     MOVE 0 TO WS-VAR
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a dispenser puts a saddle on a tame adult nautilus in front" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) * WS-CONSUMED * WS-HANDLED
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the mob becomes persistent" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-PERSISTENT(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   The slot is full now: the same item is left to the default behaviour (handled 0, not consumed here).
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a saddle slot that is taken passes the item on to the default drop" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CONSUMED + WS-HANDLED
     PERFORM CHECK

*>   Nautilus armor goes to BODY with the stack's components (the slot variant).
     MOVE WS-ARMOR TO WS-ITEM
     MOVE "diamond_nautilus_armor" TO WS-BARE
     MOVE 77 TO WS-VAR
     PERFORM DISPENSE
     CALL "WC-ROW-OPEN" USING WS-NAU
     MOVE "implementation 44-7 10.3.1 nautilus armor goes into the empty BODY slot" TO WS-CASE
     MOVE WS-ARMOR TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-BODY(WS-NAU) * WS-CONSUMED * WS-HANDLED
     PERFORM CHECK
     MOVE "implementation 44-7 10.3.1 the worn armor keeps the components of the dispensed stack" TO WS-CASE
     MOVE 77 TO WS-EXPECT
     MOVE WC-BODY-VAR(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a BODY slot that is taken passes the item on" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CONSUMED + WS-HANDLED
     PERFORM CHECK
     MOVE 0 TO EN-TAMED(WS-NAU)
     MOVE 0 TO EN-SADDLE(WS-NAU)
     MOVE WS-SADDLE TO WS-ITEM
     MOVE "saddle" TO WS-BARE
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3 an untamed nautilus (canUseSlot false) takes nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + WS-CONSUMED + WS-HANDLED
     PERFORM CHECK
     MOVE 1 TO EN-TAMED(WS-NAU)
     MOVE -1000 TO EN-MOBAGE(WS-NAU)
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3 a baby nautilus (canUseSlot false) takes nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + WS-CONSUMED + WS-HANDLED
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-NAU)
     MOVE 0 TO EN-HEALTH(WS-NAU)
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a dead one is no candidate" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + WS-CONSUMED + WS-HANDLED
     PERFORM CHECK
     MOVE 15 TO EN-HEALTH(WS-NAU)
     MOVE WS-STONE TO WS-ITEM
     MOVE "cobblestone" TO WS-BARE
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 an item that cannot be worn is not taken" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + WS-CONSUMED + WS-HANDLED
     PERFORM CHECK

*>   A nautilus that is not in the front cell (two cells away) is not asked; of two in the cell the first takes the item; a zombie nautilus is the same.
     MOVE WS-SADDLE TO WS-ITEM
     MOVE "saddle" TO WS-BARE
     COMPUTE EN-X(WS-NAU) = WS-CX + 2.5
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a nautilus two blocks from the cell takes nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) + WS-CONSUMED + WS-HANDLED
     PERFORM CHECK
     COMPUTE EN-X(WS-NAU) = WS-CX + 0.5
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-IN-FRONT
     MOVE WS-M TO WS-NAU2
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 of two in the cell the first of the entity table takes the item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-NAU) * (1 - EN-SADDLE(WS-NAU2)) * WS-CONSUMED * WS-HANDLED
     PERFORM CHECK
     MOVE "zombie_nautilus" TO WS-KEY24
     PERFORM SPAWN-IN-FRONT
     MOVE WS-M TO WS-ZOM
     MOVE 0 TO EN-HEALTH(WS-NAU) EN-HEALTH(WS-NAU2)
     PERFORM DISPENSE
     MOVE "implementation 44-7 10.3.1 a tame zombie nautilus takes the saddle too" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-ZOM) * WS-CONSUMED * WS-HANDLED
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-IN-FRONT: a tame adult mob of the key WS-KEY24 at the centre of the front cell (WS-CX, WS-CY, WS-CZ), its tracker row in WS-M
 SPAWN-IN-FRONT.
     COMPUTE WS-X = WS-CX + 0.5
     MOVE WS-CY TO WS-Y
     COMPUTE WS-Z = WS-CZ + 0.5
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M).
*> DISPENSE: the dispenser's rule for the item WS-ITEM (bare key WS-BARE, slot variant WS-VAR) facing the cell
 DISPENSE.
     CALL "RL-DISP-MORE" USING WS-DIM WS-CX WS-CY WS-CZ WS-FACING WS-BARE WS-HANDLED WS-CONSUMED WS-ITEM WS-VAR.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NAUTILUS-DISPENSE.
 COPY CORETEST.
 COPY MOBSPTEST.
