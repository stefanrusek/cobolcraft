*> Acceptance test of 21 section 8.4 (falling block entity; 29b part 1 sections 3.1 and 4): FB-SPAWN (the cell becomes air, one falling_block entity carrying the state, Add Entity Data
*> = the state id), the per-tick motion (gravity 0.04, drag 0.98f: a drop of 5 cells lands on tick 17), the landing placing the block in the cell above the floor, cancelDrop (no block, no
*> item), the expiry (time above 600, or above 100 below the world) dropping the block's item with the rule entity_drops, and the whole chain from a placed sand block (onPlace tick 2, fall).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CASE                PIC X(120).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FB-TYPE             BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-SAND-ITEM           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-D                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-AN                  FLOAT-SHORT.
 01 WS-DATA                BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     CALL "GB-RULES-OPEN"
     MOVE "minecraft:falling_block" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-FB-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SAND-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-LY = WS-FY + 1
     COMPUTE WS-SY = WS-LY + 5
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 12
     MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-BZ
*>   Spawn.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-SY WS-BZ WS-SAND
     CALL "FB-SPAWN" USING WS-DIM WS-BX WS-SY WS-BZ WS-SAND WS-ROW
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-SY WS-BZ WS-STATE
     MOVE "acceptance US15 21§8.4 FallingBlockEntity.fall: the block's cell becomes air" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
     PERFORM FIND-FB
     MOVE "acceptance US15 minecraft:falling_block 21§8.4 one falling block entity exists" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:falling_block 21§8.4 it carries the sand state" TO WS-CASE
     MOVE WS-SAND TO WS-E
     MOVE EN-FB-STATE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:falling_block 21§8.4 it starts at the cell's bottom centre (x, tenths)" TO WS-CASE
     COMPUTE WS-E = WS-BX * 10 + 5
     COMPUTE WS-O = FUNCTION INTEGER(EN-X(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-ADD-BUILD" USING WS-ROW PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A
     CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-A
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-D
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-D
     CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-D
     CALL "PB-GET-LPVEC3" USING PB-BUFFER WS-V WS-V WS-V
     CALL "PB-GET-ANGLE" USING PB-BUFFER WS-AN
     CALL "PB-GET-ANGLE" USING PB-BUFFER WS-AN
     CALL "PB-GET-ANGLE" USING PB-BUFFER WS-AN
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-DATA
     MOVE "acceptance US15 minecraft:falling_block 21§8.4 Add Entity Data is the block state id (05a 0x01)" TO WS-CASE
     MOVE WS-SAND TO WS-E
     MOVE WS-DATA TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     CALL "FB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§8.4 the first tick: time 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-FB-TIME(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.4 the first tick lowers y by 0.04 (ten-thousandths of 4.96 above the floor cell)" TO WS-CASE
     MOVE 49600 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-Y(WS-ROW) - WS-LY) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.4 the downward speed after drag is 0.04 x 0.98 (ten-thousandths)" TO WS-CASE
     MOVE 392 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(0 - EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 16
         CALL "FB-STEP" USING WS-ROW
     END-PERFORM
     PERFORM FIND-FB
     MOVE "acceptance US15 21§8.4 after 16 ticks it is still falling" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     CALL "FB-STEP" USING WS-ROW
     PERFORM FIND-FB
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-LY WS-BZ WS-STATE
     MOVE "acceptance US15 21§8.4 landing on tick 17: the entity is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.4 landing: the sand is placed in the cell above the floor" TO WS-CASE
     MOVE WS-SAND TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
*>   cancelDrop: no block, no item.
     COMPUTE WS-X2 = WS-BX + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-SY WS-BZ WS-SAND
     CALL "FB-SPAWN" USING WS-DIM WS-X2 WS-SY WS-BZ WS-SAND WS-ROW
     MOVE 1 TO EN-FB-CANCEL(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         CALL "FB-STEP" USING WS-ROW
     END-PERFORM
     PERFORM FIND-FB
     COMPUTE WS-X2 = WS-BX + 2
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X2 WS-LY WS-BZ WS-STATE
     MOVE "acceptance US15 21§8.4 cancelDrop: the entity ends at the landing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.4 cancelDrop: no block is placed and no item dropped" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-STATE + WS-ITEMS
     PERFORM CHECK-N
*>   Expiry in the air after 600 ticks: the item drops.
     COMPUTE WS-X2 = WS-BX + 4
     CALL "FB-SPAWN" USING WS-DIM WS-X2 WS-SY WS-BZ WS-SAND WS-ROW
     MOVE 600 TO EN-FB-TIME(WS-ROW)
     CALL "FB-STEP" USING WS-ROW
     PERFORM FIND-FB
     MOVE "acceptance US15 21§8.4 time above 600: the entity is discarded" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.4 time above 600: one sand item dropped" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ITEMS TO WS-O
     PERFORM CHECK-N
*>   Below the world after 100 ticks, with entity_drops false: gone, nothing dropped.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     COMPUTE WS-X2 = WS-BX + 6
     CALL "FB-SPAWN" USING WS-DIM WS-X2 WS-SY WS-BZ WS-SAND WS-ROW
     MOVE 100 TO EN-FB-TIME(WS-ROW)
     MOVE -70 TO EN-Y(WS-ROW)
     CALL "FB-STEP" USING WS-ROW
     PERFORM FIND-FB
     MOVE "acceptance US15 21§8.4 time above 100 below the world: discarded, and entity_drops false drops nothing" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = 1 + WS-COUNT + WS-ITEMS - 1
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   The whole chain: sand placed 4 cells above the floor.
     COMPUTE WS-X2 = WS-BX - 8
     COMPUTE WS-SY = WS-LY + 4
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X2 WS-SY WS-BZ WS-SAND
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM FIND-FB
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X2 WS-SY WS-BZ WS-STATE
     MOVE "acceptance US15 29b-1 3.1 sand placed in the air: after its tick of 2 it is an entity and the cell is air" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-COUNT + WS-STATE
     PERFORM CHECK-N
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM FIND-FB
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X2 WS-LY WS-BZ WS-STATE
     MOVE "acceptance US15 29b-1 3.1 the sand has landed on the floor and the entity is gone" TO WS-CASE
     MOVE WS-SAND TO WS-E
     COMPUTE WS-O = WS-STATE + WS-COUNT
     PERFORM CHECK-N
     STOP RUN.
 FIND-FB.
     MOVE 0 TO WS-COUNT WS-ROW WS-ITEMS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-FB-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-J TO WS-ROW
         END-IF
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = CR-LOOSE-ITEM AND EN-ITEM(WS-J) = WS-SAND-ITEM
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-4.
 COPY CORETEST.
 COPY MOBSPTEST.
