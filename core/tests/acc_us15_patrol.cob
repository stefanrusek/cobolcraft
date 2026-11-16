*> Acceptance test, the pillager patrol spawner (docs/protocol/20 section 14.1; lane 002-lane-mobsb5, T8908): members by difficulty, the early-game block (first 120000 ticks), the
*> village block, the spawn of a patrol with one leader near the target point, the counter reset and the daylight gate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PATROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY PATROL.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-F0                  BINARY-LONG.
 01 WS-LEADERS             BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         CALL "PATROL-MEMBERS" USING WS-A WS-B
         MOVE "acceptance US15 20§14.1 members are the difficulty + 1 (easy 2, normal 3, hard 4)" TO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-A + 1
         MOVE WS-B TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-A = WS-X - 10
     COMPUTE WS-B = WS-Z - 60
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-A WS-B 120 WS-Y 1
     MOVE 2 TO BW-DIFFICULTY
     MOVE 30 TO WS-OX
     MOVE -30 TO WS-OZ
*>   Early game: the first 120000 game ticks block patrols.
     MOVE 119999 TO CW-TICKS
     CALL "PATROL-ATTEMPT" USING WS-PLAYER WS-OX WS-OZ WS-RESULT
     MOVE "acceptance US15 20§14.1 before 120000 ticks no patrol" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 120000 TO CW-TICKS
*>   A village within 2 sections of the player blocks the attempt.
     COMPUTE WS-A = WS-X + 3
     CALL "PXI-ADD" USING WS-DIM WS-A WS-Y WS-Z WS-KIND2
     CALL "PATROL-ATTEMPT" USING WS-PLAYER WS-OX WS-OZ WS-RESULT
     MOVE "acceptance US15 20§14.1 a player in a village gets no patrol" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Remove the village point and spawn: 3 pillagers on Normal, one leader, near the target point.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         MOVE 0 TO PX-KIND(WS-I)
     END-PERFORM
     MOVE 0 TO WS-F0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-PTYPE
             ADD 1 TO WS-F0
         END-IF
     END-PERFORM
     CALL "PATROL-ATTEMPT" USING WS-PLAYER WS-OX WS-OZ WS-RESULT
     MOVE "acceptance US15 20§14.1 the attempt succeeds" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     MOVE 0 TO WS-NEAR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-PTYPE
             ADD 1 TO WS-N
             IF FUNCTION ABS(EN-X(WS-I) - (WS-X + 30)) <= 12 AND FUNCTION ABS(EN-Z(WS-I) - (WS-Z - 30)) <= 12
                 ADD 1 TO WS-NEAR
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-N = WS-N - WS-F0
     MOVE "acceptance US15 20§14.1 three members on Normal" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.1 all of them within 12 blocks of the target point" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-NEAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LEADERS
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-MAX
         IF PT-ID(WS-I) > 0
             ADD 1 TO WS-N
             ADD PT-LEADER(WS-I) TO WS-LEADERS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§14.1 the patrol has 3 members and one leader" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N * 10 + WS-LEADERS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The counter: at 0 it grows by 12000 + nextInt(1200); at night nothing spawns.
     MOVE 0 TO PT-NEXT
     MOVE 13000 TO CW-TIME
     CALL "PATROL-TICK"
     MOVE "acceptance US15 20§14.1 the counter restarts at 12000 to 13199" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PT-NEXT >= 12000 AND PT-NEXT <= 13199
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PT-NEXT
     CALL "PATROL-TICK"
     MOVE "acceptance US15 20§14.1 above 0 the counter only counts down" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PT-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-PATROL.

 COPY CORETEST.
 COPY MOBSPTEST.
