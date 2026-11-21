*> Acceptance test (lane p49a; docs/protocol/20-mobs-overworld-hostile.md section 3.8 Conversion tracker, skeleton to stray; 18 section 4.10): a skeleton in powder snow
*> counts afflicted ticks up to 140, then converts: the converting flag turns on and 300 ticks count down; below 0 it is replaced by a stray with its equipment kept; if the
*> condition stops both counters reset; a no-AI skeleton does not count. (Zombie to drowned needs a drowned mob, which the core does not have: recorded in the lane report.)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-SKELETON           BINARY-LONG.
 01 WS-STRAY              BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-AIR                BINARY-LONG VALUE 0.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-DONE               BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-STRAYS             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SKELETON WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stray" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STRAY WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 3
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 24 TO EN-EQUIP(WS-ROW)
     MOVE 4 TO EN-HAND(WS-ROW)
     MOVE "N" TO TL-MODE

     PERFORM CONVERT-TICK 139 TIMES
     MOVE "acceptance US15 20§3.8 Conversion tracker: 139 afflicted ticks are not converting" TO WS-CASE
     MOVE 139 TO WS-E
     MOVE EN-AFFLICT(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-E
     MOVE EN-CONVERTING(WS-ROW) TO WS-O
     PERFORM CHECK-N
     PERFORM CONVERT-TICK
     MOVE "acceptance US15 20§3.8 Conversion tracker: the 140th tick starts converting with 300 ticks to count down" TO WS-CASE
     MOVE 1300 TO WS-E
     COMPUTE WS-O = EN-CONVERTING(WS-ROW) * 1000 + EN-CONVERT-LEFT(WS-ROW)
     PERFORM CHECK-N
*>   The synched converting flag: Set Entity Data (0x65), entity id, index 16, BOOLEAN, true.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 20§3.8 Conversion tracker: converting sends index 16 true (stray-conversion flag)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PB-LENGTH >= 5 AND WS-BYTE(1) = X"65" AND WS-BYTE(3) = X"10" AND WS-BYTE(5) = X"01"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     PERFORM CONVERT-TICK 300 TIMES
     MOVE "acceptance US15 20§3.8 Conversion tracker: after 300 ticks the count is 0 and the skeleton is still a skeleton" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-SKELETON AND EN-CONVERT-LEFT(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM CONVERT-TICK
     MOVE 0 TO WS-STRAYS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-STRAY
             ADD 1 TO WS-STRAYS
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§3.8 Conversion tracker: when the count goes below 0 the skeleton is replaced by one stray" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-STRAYS TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 20§3.8 Conversion tracker: the stray has the skeleton's equipment and bow and its position" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-EQUIP(WS-ROW) = 24 AND EN-HAND(WS-ROW) = 4 AND EN-X(WS-ROW) = WS-X AND EN-Z(WS-ROW) = WS-Z
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Out of the snow both counters reset; a no-AI skeleton does not count.
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM CONVERT-TICK 140 TIMES
     PERFORM CONVERT-TICK 200 TIMES
     MOVE "acceptance US15 20§3.8 Conversion tracker: 300 ticks of snow are converting (count 100 left of 300 after 200)" TO WS-CASE
     MOVE 1100 TO WS-E
     COMPUTE WS-O = EN-CONVERTING(WS-ROW) * 1000 + EN-CONVERT-LEFT(WS-ROW)
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     PERFORM CONVERT-TICK
     MOVE "acceptance US15 20§3.8 Conversion tracker: when the afflicted condition stops the count resets" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-AFFLICT(WS-ROW) + EN-CONVERTING(WS-ROW) + EN-CONVERT-LEFT(WS-ROW)
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 1 TO EN-NO-AI(WS-ROW)
     PERFORM CONVERT-TICK 10 TIMES
     MOVE "acceptance US15 20§3.8 Conversion tracker: a no-AI skeleton does not count" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-AFFLICT(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   Through the mob's own step (night, so it does not burn): after the 140 + 301 ticks the row is a stray.
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 16001 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 100 TO EN-HEALTH(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 445
         ADD 1 TO CW-TICKS
         MOVE 0 TO EN-HURT(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE 0 TO WS-STRAYS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-STRAY
             ADD 1 TO WS-STRAYS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§3.8 Conversion tracker: the mob's own step converts it after 441 ticks in powder snow" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-STRAYS TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CONVERT-TICK.
     CALL "M183-CONVERT" USING WS-ROW WS-DONE.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-20-3-8.
 COPY CORETEST.
 COPY MOBSPTEST.
