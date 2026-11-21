*> Acceptance test (US12-3, docs/protocol/38-end.md section 8, 39-portals.md section 7.6, 31-block-entities-5 section 4): a player whose box touches an end_gateway block of the
*> End moves to its exit (an exact exit: its bottom centre, else one above the tallest non-bedrock solid block within 5 of the exit raised by 2, the column of the exit itself
*> skipped; nothing there: three above the exit), the gateway's own cooldown of 40 ticks keeps the next touch from moving her, her own cooldown of 10 ticks stops the move,
*> a spectator is not moved, an entity without an exit moves nobody, and the gateway's age and its attention interval of 2400 ticks start the cooldown. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-END-GATEWAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY ENDTRAVEL.
 COPY ENDGATEWAY.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-GATEWAY             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-ED                  PIC -(7)9.9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 end gateway: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "end_gateway" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-GATEWAY
     MOVE "stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "bedrock" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-BEDROCK
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE DIM-STANDARD-END TO PL-DIM(WS-ROW)
     MOVE 10 TO WS-X MOVE 60 TO WS-Y MOVE 10 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-GATEWAY
     CALL "TEST-TICKS" USING WS-ONE

*>   Standing in the air beside it nothing happens (no entity for a cell that is not a gateway).
     MOVE 20.5 TO PL-X(WS-ROW)
     MOVE 70.0 TO PL-Y(WS-ROW)
     MOVE 20.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: away from the gateway block no entity exists" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   She touches the gateway: a return gateway, exit (100, 50, 0) exact.
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 60.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: she is at (100.5, 50, 0.5) after touching the block" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM POSITION-TEXT
     MOVE "100.5 50.0 0.5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end gateway: the gateway cooldown is 39 after the tick (40 set) and hers is the 10 of the move" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3910 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EG-COOLDOWN(1) * 100 + ET-COOLDOWN(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end gateway: the entity stands at the block and is the first" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE 60 TO WS-Y
     CALL "END-GATEWAY-FIND" USING DIM-STANDARD-END EG-X(1) WS-Y EG-Z(1) WS-GATE
     COMPUTE TL-OBSERVED-N = EG-X(1) * WS-GATE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Touching again while the gateway cools down moves nobody.
     MOVE 0 TO ET-COOLDOWN(WS-ROW)
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 60.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: while the gateway cools down she stays" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM POSITION-TEXT
     MOVE "10.5 60.0 10.5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Her own cooldown stops the move but the gateway starts its cooldown and hers is set to 10.
     MOVE 0 TO EG-COOLDOWN(1)
     MOVE 7 TO ET-COOLDOWN(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: with her own cooldown running she stays, the gateway cools down" TO TL-CASE
     PERFORM POSITION-TEXT
     MOVE "10.5 60.0 10.5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-3 end gateway: her cooldown was reset to 10, the gateway's is 39" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3910 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EG-COOLDOWN(1) * 100 + ET-COOLDOWN(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A spectator does not use it.
     MOVE 0 TO EG-COOLDOWN(1) ET-COOLDOWN(WS-ROW)
     MOVE 3 TO PL-MODE(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: a spectator is not moved and starts no cooldown" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-X(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TL-EXPECTED-N
     MOVE EG-COOLDOWN(1) TO TL-OBSERVED-N
     MOVE "acceptance US12-3 end gateway: the gateway of the spectator did not cool down" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-ROW)

*>   A gateway without an exit: nobody moves, the cooldown starts.
     MOVE 0 TO EG-HAS-EXIT(1)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: an entity without an exit moves nobody" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-X(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A non-exact exit: one above the tallest solid block within 5 of (8, 52, 8) (the stone at (10, 100, 8); the bedrock at (6, 120, 8) is passed over).
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 8 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STONE
     MOVE 6 TO WS-X MOVE 120 TO WS-Y MOVE 8 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-BEDROCK
     MOVE 1 TO EG-HAS-EXIT(1)
     MOVE 0 TO EG-EXACT(1) EG-COOLDOWN(1) ET-COOLDOWN(WS-ROW)
     MOVE 8 TO EG-EXIT-X(1) EG-EXIT-Z(1)
     MOVE 50 TO EG-EXIT-Y(1)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: a searched exit is one above the tallest block, (10.5, 101, 8.5)" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM POSITION-TEXT
     MOVE "10.5 101.0 8.5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nothing solid near the exit: three above it. The creative player of the same gateway moves too.
     MOVE 300 TO EG-EXIT-X(1)
     MOVE 8 TO EG-EXIT-Z(1)
     MOVE 0 TO EG-COOLDOWN(1) ET-COOLDOWN(WS-ROW)
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 60.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: nothing near the exit puts a creative player three above it, (300.5, 53, 8.5)" TO TL-CASE
     PERFORM POSITION-TEXT
     MOVE "300.5 53.0 8.5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The attention interval: an age of 2399 and no cooldown starts the cooldown on the next tick.
     MOVE 2399 TO EG-AGE(1)
     MOVE 0 TO EG-COOLDOWN(1)
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance US12-3 end gateway: at an age divisible by 2400 the cooldown of 40 starts, and the age counts" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 402400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EG-COOLDOWN(1) * 10000 + EG-AGE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 POSITION-TEXT.
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-ED = PL-X(WS-ROW)
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     COMPUTE WS-ED = PL-Y(WS-ROW)
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-ED = PL-Z(WS-ROW)
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED.

 END PROGRAM ACC-F2US12-END-GATEWAY.

 COPY CORETEST.
 COPY PORTALTEST.
