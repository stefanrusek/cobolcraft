*> Implementation test (integration batch 15; docs/protocol/20 Breeze, the Shoot behaviour): BREEZE-SHOOT stops and erases the draw when the breeze has no target or
*> the target is 16 blocks or more away, and leaves an idle breeze (draw 0) alone; the draw of a breeze with a target in range starts at 1 with 15 ticks to shoot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-B15-BREEZE-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW

*>   No target and no draw: nothing happens.
     MOVE 0 TO EN-TARGET(WS-ROW) EN-DRAW(WS-ROW) EN-SHOOT-TIME(WS-ROW)
     CALL "BREEZE-SHOOT" USING WS-ROW WS-M
     MOVE "test b15 BREEZE-SHOOT: no target and no draw leaves the draw at 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DRAW(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A draw in progress and the target lost: the draw is erased.
     MOVE 1 TO EN-DRAW(WS-ROW)
     MOVE 7 TO EN-SHOOT-TIME(WS-ROW)
     CALL "BREEZE-SHOOT" USING WS-ROW WS-M
     MOVE "test b15 BREEZE-SHOOT: a lost target erases the draw and its timer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-DRAW(WS-ROW) * 100 + EN-SHOOT-TIME(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A target 20 blocks away is out of range (squared distance 400 >= 256): the draw is erased too.
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 20
     MOVE 1 TO EN-DRAW(WS-ROW)
     MOVE 9 TO EN-SHOOT-TIME(WS-ROW)
     CALL "BREEZE-SHOOT" USING WS-ROW WS-M
     MOVE "test b15 BREEZE-SHOOT: a target out of range erases the draw" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-DRAW(WS-ROW) * 100 + EN-SHOOT-TIME(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   In range an idle breeze starts to draw: draw 1 and 15 ticks.
     COMPUTE EN-X(WS-ROW) = PL-X(WS-PLAYER) + 3
     MOVE 0 TO EN-DRAW(WS-ROW) EN-SHOOT-TIME(WS-ROW)
     CALL "BREEZE-SHOOT" USING WS-ROW WS-M
     MOVE "test b15 BREEZE-SHOOT: a target in range starts the draw (draw 1, 15 ticks)" TO TL-CASE
     MOVE 115 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-DRAW(WS-ROW) * 100 + EN-SHOOT-TIME(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-B15-BREEZE-STOP.
 COPY CORETEST.
 COPY MOBSPTEST.
