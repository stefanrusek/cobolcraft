*> Implementation test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md section 6.1, Wet shake): a wolf that was in water shakes when it is out of it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-6-WET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-WATER              BINARY-LONG.
 01 WS-WALK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:wolf" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE 0 TO WS-WATER WS-WALK
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: a dry wolf does not shake" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-WOLF-SHAKE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-WATER
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: in water the wolf is wet and does not shake yet" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = EN-WOLF-WET(WS-ROW) * 10 + EN-WOLF-SHAKE(WS-ROW)
     MOVE 10 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-WATER
     MOVE 1 TO WS-WALK
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: a wolf that follows a path does not start to shake" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-WOLF-SHAKE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-WALK
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: a wolf in the air does not start to shake" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-WOLF-SHAKE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: a wet wolf on dry ground standing still starts to shake" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-WOLF-SHAKE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     END-PERFORM
     MOVE "acceptance US15 19§6.1 Wolf wet shake: the shake is still running 39 ticks after its start (anim 1.95)" TO WS-CASE
     MOVE 40 TO WS-E
     MOVE EN-WOLF-SHAKE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: at anim 2.0 the shake ends and the wolf is dry" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-WOLF-WET(WS-ROW) * 10 + EN-WOLF-SHAKE(WS-ROW)
     PERFORM CHECK-N
     MOVE 1 TO EN-WOLF-WET(WS-ROW)
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE 1 TO WS-WATER
     CALL "WOLF-WET-STEP" USING WS-ROW WS-WATER WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: entering water cancels a running shake and the wolf stays wet" TO WS-CASE
     MOVE 10 TO WS-E
     COMPUTE WS-O = EN-WOLF-WET(WS-ROW) * 10 + EN-WOLF-SHAKE(WS-ROW)
     PERFORM CHECK-N
     MOVE 0 TO EN-WOLF-WET(WS-ROW)
     CALL "WOLF-WET-TICK" USING WS-ROW WS-WALK
     MOVE "acceptance US15 19§6.1 Wolf wet shake: the tick reads the cell it stands in (dry air: nothing changes)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-WOLF-WET(WS-ROW) * 10 + EN-WOLF-SHAKE(WS-ROW)
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-6-WET.
 COPY CORETEST.
 COPY MOBSPTEST.
