*> Implementation test (002-lane-bugarmadillo; docs/protocol/44-residual-mob-questions-4-land-animals.md section 1.5 and section 12, 44-1 RQ-1.34,
*> 19 section 13): the armadillo scare sensor scans every 5 ticks (armadillo_scare_detected: interval 5, ttl 80), so a player who runs
*> (sprints) around an armadillo rolls it up within 5 ticks, not once in 80. isScaredBy: a spectator never scares, a sprinting player or a passenger does,
*> a walking or sneaking player does not. The state is sent to the viewers (Set Entity Data) at every change. Driven through the real
*> Player Command packet and CORE-TICK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-13-SCARE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:armadillo" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   A walking player 3 blocks away never scares it, however long it takes.
     COMPUTE WS-X = WS-PX + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1000000 TO EN-SCUTE(WS-A)
     PERFORM 90 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§12 Armadillo: a player who walks (no sprint) near it never scares it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A sneaking player (not sprinting) does not scare it either.
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     PERFORM 90 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§12 Armadillo: a sneaking player near it does not scare it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)

*>   A sprinting spectator does not scare it (isScaredBy: false for a spectator).
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO PL-SPRINTING(WS-PLAYER)
     PERFORM 90 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§12 Armadillo: a sprinting spectator does not scare it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   A passenger scares it without sprinting (isScaredBy: true for a passenger).
     MOVE 1 TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     PERFORM 5 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§12 Armadillo: a passenger near it scares it within 5 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     CALL "ENTITY-REMOVE" USING WS-A

*>   The proximity path, as the operator plays it: the client sends Player Command start sprinting, the server ticks; within 5 ticks the armadillo rolls up
*>   and its state goes to the viewer.
     COMPUTE WS-X = WS-PX + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1000000 TO EN-SCUTE(WS-A)
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     MOVE 1 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-ACTION
     MOVE 5 TO WS-COUNT
     CALL "TEST-TICKS" USING WS-COUNT
     MOVE "acceptance US15 44-4§12 Armadillo: a sprinting player 3 blocks away rolls it up within 5 ticks (state 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "101("
     MOVE "acceptance US15 19§13 Armadillo: the new state is sent to the viewer (Set Entity Data)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   While the player keeps running the danger is renewed: the armadillo stays rolled (scared) and does not unroll.
     MOVE 100 TO WS-COUNT
     CALL "TEST-TICKS" USING WS-COUNT
     MOVE "acceptance US15 44-4§12 Armadillo: while the player keeps sprinting nearby it stays scared (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The player stops: the memory (80 ticks) runs out, then the 30-tick unrolling: idle again, and each change was sent.
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     MOVE 2 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-CONN WS-ACTION
     MOVE 0 TO WS-SEEN
     PERFORM 140 TIMES
         CALL "TEST-TICKS" USING WS-ONE
         IF EN-ARMA(WS-A) = 3
             MOVE 1 TO WS-SEEN
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§12 Armadillo: once the player stops it unrolls (state 3 was seen)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§12 Armadillo: and is idle again (0) after the memory and the unrolling" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "101("
     MOVE "acceptance US15 19§13 Armadillo: the unrolling and idle states were sent to the viewer too" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-13-SCARE.
 COPY CORETEST.
 COPY MOBSPTEST.
