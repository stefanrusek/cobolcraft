*> Implementation test (002-lane-mobsa4; 54 sections 6.3 and 6.4): the server side of the rider's dash (Player Command START_RIDING_JUMP with data above 0 needs a saddled camel that is not sitting or
*> in a pose transition and has no dash cooldown; it starts the dash flag and the cooldown 55) and the random sitting of an idle camel (a pose change once the pose time is at least 400).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-CAMELIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:camel" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     MOVE 1 TO EN-ON-GROUND(WS-A)
     MOVE 50 TO WS-STRENGTH
     MOVE 0 TO EN-SADDLE(WS-A) EN-CAMEL-DASH(WS-A) EN-CAMEL-POSE(WS-A)
     MOVE 0 TO EN-CAMEL-POSE-T(WS-A)
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: an unsaddled camel does not dash" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-SADDLE(WS-A)
     MOVE 0 TO WS-STRENGTH
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: a jump strength of 0 starts nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-CAMEL-POSE(WS-A)
     MOVE 50 TO WS-STRENGTH
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: a sitting camel does not dash" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-CAMEL-POSE(WS-A)
     MOVE 5990 TO EN-CAMEL-POSE-T(WS-A)
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: a camel in a pose transition (standing up, 52 ticks) does not dash" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-CAMEL-POSE-T(WS-A)
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: a saddled standing camel dashes: cooldown 55" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 55
     COMPUTE TL-OBSERVED-N = WS-OK * 100 + EN-CAMEL-DASH(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-CAMEL-RIDER-JUMP" USING WS-A WS-STRENGTH WS-OK
     MOVE "acceptance US15 54§6.3 Camel: no second dash during the cooldown" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Random sitting: within 4000 ticks an idle camel changes its pose, stamped with the game time.
     MOVE 0 TO EN-SADDLE(WS-A) EN-CAMEL-POSE(WS-A)
     MOVE 0 TO EN-CAMEL-POSE-T(WS-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000 OR EN-CAMEL-POSE(WS-A) = 1
         ADD 1 TO CW-TIME
         ADD 1 TO CW-TICKS
         MOVE 1 TO EN-ON-GROUND(WS-A)
         CALL "M44-CAMEL-BRAIN" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 54§6.4 Camel: an idle camel sits down by itself, the pose time is the game time" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-CAMEL-POSE(WS-A) = 1 AND EN-CAMEL-POSE-T(WS-A) = CW-TIME
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-CAMELIN.
 COPY CORETEST.
 COPY MOBSPTEST.
