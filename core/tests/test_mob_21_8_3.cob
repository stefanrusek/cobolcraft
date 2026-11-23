*> Acceptance test of 21 section 8.3 (primed TNT) leftovers and the matching doc 44 x2 section 4.10 (dispenser): the literal constants of the creation (vertical speed 0.20000000298023224,
*> explosion centre y + 0.0612500011920929), the Add Entity followed by Set Entity Data with the fuse, the chain ignition of a TNT block destroyed by an explosion (wasExploded: a primed TNT
*> at the block centre, fuse nextInt(20) + 10, no drop of the block, only with tnt_explodes), and the dispenser's TNT behaviour (a primed TNT in the front cell, nothing when the rule is off).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 01 WS-CASE                PIC X(120).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-TNT-STATE           BINARY-LONG.
 01 WS-TNT-ITEM            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 4.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NO-FIRE             BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MS-TEST-STATE" USING WS-KEY WS-TNT-STATE
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TNT-ITEM WS-ITEM-ROW WS-STATUS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 12
     MOVE FUNCTION INTEGER(PL-Z(WS-PLAYER)) TO WS-BZ
     COMPUTE WS-PX = WS-BX + 0.5
     MOVE WS-BY TO WS-PY
     COMPUTE WS-PZ = WS-BZ + 0.5
     CALL "TNT-PRIME" USING WS-DIM WS-PX WS-PY WS-PZ WS-ROW
     MOVE "acceptance US15 minecraft:tnt 21§8.3 the creation speed up is the float 0.2f widened (1e-9)" TO WS-CASE
     MOVE 200000003 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 1000000000 + 0.5)
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance US15 minecraft:tnt 21§8.3 the viewer gets Add Entity then Set Entity Data (the fuse, metadata 8)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-IDS = "1 101"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "TNT-CENTRE" USING WS-PY WS-CY
     MOVE "acceptance US15 minecraft:tnt 21§8.3 the explosion centre is y + 0.98f x 0.0625 (1e-11 above)" TO WS-CASE
     MOVE 6125000119 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((WS-CY - WS-PY) * 100000000000 + 0.5)
     PERFORM CHECK-N
*>   Chain ignition: a TNT block beside an explosion.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-TNT-STATE
     COMPUTE WS-CX = WS-BX + 0.5
     COMPUTE WS-CY = WS-BY + 0.5
     COMPUTE WS-CZ = WS-BZ + 2.5
     CALL "EXPLODE-RUN" USING WS-DIM WS-CX WS-CY WS-CZ WS-POWER WS-DESTROY WS-NONE WS-NO-FIRE
     PERFORM FIND-TNT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded: the exploded TNT block is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded: one primed TNT appears" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded: its fuse is 10 to 29" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-SWELL(WS-ROW) >= 10 AND EN-SWELL(WS-ROW) <= 29
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded: it sits at the block centre (x, tenths)" TO WS-CASE
     COMPUTE WS-E = WS-BX * 10 + 5
     COMPUTE WS-O = FUNCTION INTEGER(EN-X(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded: the block drops no TNT item" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ITEMS TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   With the rule off the exploded TNT block just goes.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-TNT-STATE
     CALL "EXPLODE-RUN" USING WS-DIM WS-CX WS-CY WS-CZ WS-POWER WS-DESTROY WS-NONE WS-NO-FIRE
     PERFORM FIND-TNT
     MOVE "acceptance US15 minecraft:tnt 21§8.3 wasExploded with tnt_explodes false: no primed TNT" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-N
*>   The dispenser (44 x2 4.10): off, then on.
     CALL "TNT-DISPENSE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     PERFORM FIND-TNT
     MOVE "acceptance US15 44-x2§4.10 the dispenser with tnt_explodes false does nothing (success 0, no entity)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-OK + WS-COUNT
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "TNT-DISPENSE" USING WS-DIM WS-BX WS-BY WS-BZ WS-OK
     PERFORM FIND-TNT
     MOVE "acceptance US15 44-x2§4.10 the dispenser spawns a primed TNT in the front cell (success)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-x2§4.10 one primed TNT at the centre of the front cell with fuse 80" TO WS-CASE
     COMPUTE WS-E = 1 * 1000 + WS-BX * 10 + 5
     COMPUTE WS-O = WS-COUNT * 1000 + FUNCTION INTEGER(EN-X(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.3 Primed TNT: the dispensed TNT's fuse" TO WS-CASE
     MOVE 80 TO WS-E
     MOVE EN-SWELL(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 FIND-TNT.
     MOVE 0 TO WS-COUNT WS-ROW WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TNT-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-ROW
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-TNT-ITEM
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-3.
 COPY CORETEST.
 COPY MOBSPTEST.
