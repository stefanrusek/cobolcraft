*> Implementation test (coverage lane A; docs/protocol/20 sections 13 and 14.1; core/src/mob-20-patrol.cob): a patrol attempt at a point without ground gives up (result 3), and the patrol
*> counter's tick over many draws: with the only player in the nether nobody is picked, with a spectator no member is made, with a survivor the picks and the random signs of the offsets are all run.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-PATROL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY DIMENSIONS.
 COPY PATROL.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE 130000 TO CW-TICKS
*>   A point far from every loaded chunk has no ground: no member can stand there.
     MOVE 5000 TO WS-OX
     MOVE 5000 TO WS-OZ
     CALL "PATROL-ATTEMPT" USING WS-PLAYER WS-OX WS-OZ WS-RESULT
     MOVE "test cova patrol an attempt far from the player either spawns (0) or finds no ground (3)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-RESULT = 0 OR WS-RESULT = 3
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The only player is in the nether: the counter restarts and nobody is picked.
     MOVE DIM-STANDARD-NETHER TO PL-DIM(WS-PLAYER)
     PERFORM 400 TIMES
         MOVE 0 TO PT-NEXT
         MOVE 6000 TO CW-TIME
         CALL "PATROL-TICK"
     END-PERFORM
     MOVE WS-DIM TO PL-DIM(WS-PLAYER)
     MOVE "test cova patrol a tick re-arms the counter (12000 or more)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PT-NEXT >= 12000
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A spectator is never picked: no patrol member is made over many draws.
     MOVE 0 TO WS-BASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-MAX
         IF PT-ID(WS-I) > 0
             ADD 1 TO WS-BASE
         END-IF
     END-PERFORM
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM 800 TIMES
         MOVE 0 TO PT-NEXT
         MOVE 6000 TO CW-TIME
         CALL "PATROL-TICK"
     END-PERFORM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-MAX
         IF PT-ID(WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "test cova patrol a spectator draws no new patrol member" TO WS-CASE
     MOVE WS-BASE TO WS-E
     MOVE WS-N TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A survival player: the attempts (each run to the end) happen with their offsets of both signs.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM 800 TIMES
         MOVE 0 TO PT-NEXT
         MOVE 6000 TO CW-TIME
         CALL "PATROL-TICK"
     END-PERFORM
     MOVE "test cova patrol the survival run leaves the counter armed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PT-NEXT >= 12000
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-PATROL.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
