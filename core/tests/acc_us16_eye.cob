*> Acceptance test, the eye of ender (docs/protocol/21 section 8.12; lane 002-lane-mobsb6, T9003): signalTo (a target beyond 12 blocks becomes position + (dx / h x 12, 8, dz / h x 12), a nearer one is
*> kept), the velocity update (speed lerp 0.0025, vertical pull 0.015), life counting to 80, then the eye drops as an item (4 in 5) or shatters (event 2003).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EYE-ITEM            BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-SURVIVE             BINARY-LONG.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-DROPS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EYE-ITEM WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 30
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE WS-X TO WS-X0
     COMPUTE WS-TX = WS-X + 20
     MOVE WS-Y TO WS-TY
     MOVE WS-Z TO WS-TZ
     MOVE 1 TO WS-SURVIVE
     CALL "EYE-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-TX WS-TY WS-TZ WS-SURVIVE WS-OWNER WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 21 8.12 a target 20 blocks away becomes 12 blocks along (x)" TO TL-CASE
     MOVE 12000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PJ-R1(WS-SLOT) - WS-X) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.12 and 8 blocks up (y)" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PJ-R2(WS-SLOT) - WS-Y) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EYE-STEP" USING WS-ROW
     CALL "EYE-STEP" USING WS-ROW
     MOVE "acceptance US16 21 8.12 the first tick moves nothing (v = 0), the second by v = (0.03, 0.015, 0)" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-X(WS-ROW) - WS-X0) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 8.12 the vertical speed is 0.015 after the second update (0.029775)" TO TL-CASE
     MOVE 29775 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 3 BY 1 UNTIL WS-I > 80
         CALL "EYE-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 8.12 the eye lives through life 80" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EYE-STEP" USING WS-ROW
     MOVE "acceptance US16 21 8.12 at life 81 it is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DROPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EYE-ITEM AND EN-ITEM-COUNT(WS-I) = 1
             ADD 1 TO WS-DROPS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 8.12 a surviving eye drops one ender_eye item" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DROPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A near target is kept; a shattering eye drops nothing.
     COMPUTE WS-TX = WS-X + 5
     MOVE 0 TO WS-SURVIVE
     CALL "EYE-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-TX WS-TY WS-TZ WS-SURVIVE WS-OWNER WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 21 8.12 a target within 12 blocks is kept" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PJ-R1(WS-SLOT) - WS-X) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 81
         CALL "EYE-STEP" USING WS-ROW
     END-PERFORM
     MOVE 0 TO WS-DROPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-EYE-ITEM AND EN-ITEM-COUNT(WS-I) = 1
             ADD 1 TO WS-DROPS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 8.12 a shattering eye is gone and adds no item (still one)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DROPS * 10 + EN-USED(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-EYE.
 COPY CORETEST.
 COPY MOBSPTEST.
