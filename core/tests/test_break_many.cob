*> Edge-case test (spec edge case; docs/protocol/13 §2.4): several players break different blocks at once and each
*> stage goes only to the players who can see that block, per block. View distance 2: Alice (near x 20) breaks
*> loam at (20,100,20), Dora (near x 100) breaks loam at (100,100,100); Bobby sees Alice's block only, Erin sees
*> Dora's block only. Each breaker also gets the stage of its own block and nothing of the other.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-MANY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DORA                BINARY-LONG.
 01 WS-ERIN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-X2                  BINARY-LONG VALUE 100.
 01 WS-Z2                  BINARY-LONG VALUE 100.
 01 WS-FLOOR-Z             BINARY-LONG VALUE 101.
 01 WS-GREY                BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 3.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 100.5.
 01 WS-FY                  FLOAT-LONG VALUE 100.0.
 01 WS-FZ                  FLOAT-LONG VALUE 100.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "Dora" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-DORA
     MOVE "Erin" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ERIN
     CALL "TEST-MOVE" USING WS-ERIN WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
*>   Dora stands on greystone next to her block (on the ground, so her break runs at the full rate).
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-FLOOR-Z WS-GREY
     MOVE 101 TO WS-FY
     MOVE 101.5 TO WS-FZ
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-DORA WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z2 WS-STATE
     PERFORM DRAIN-ALL

     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-DORA WS-ACTION WS-X2 WS-Y WS-Z2 WS-FACE WS-SEQ
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS

     MOVE "test break many the player near Alice's block is sent Alice's stages only (entity 1)"
         TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=0) 5(1,20,100,20=1) 5(1,20,100,20=2)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test break many the player near Dora's block is sent Dora's stages only (entity 3)"
         TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ERIN WS-TEXT
     MOVE "5(3,100,100,100=0) 5(3,100,100,100=1) 5(3,100,100,100=2)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test break many each breaker is sent the stages of its own block and the ack only"
         TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=0) 4(1) 5(1,20,100,20=1) 5(1,20,100,20=2)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-BLOCKS" USING WS-DORA WS-TEXT
     MOVE "5(3,100,100,100=0) 4(2) 5(3,100,100,100=1) 5(3,100,100,100=2)" TO TL-EXPECTED
     MOVE "test break many Dora's stages (her own)" TO TL-CASE
     PERFORM CHECK

     MOVE "test break many when Alice aborts only the viewers of her block see the clear and "
         & "Dora's progress goes on" TO TL-CASE
     MOVE 2 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=255)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-BLOCKS" USING WS-ERIN WS-TEXT
     MOVE "acceptance test break many the other block's viewer is sent nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 DRAIN-ALL.
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-DORA WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ERIN WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BREAK-MANY.

 COPY CORETEST.
