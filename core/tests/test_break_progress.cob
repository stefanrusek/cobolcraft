*> Implementation test of break-progress broadcasting (core/src/blocks.cob BLOCKS-TICK; tasks T445;
*> 05a 0x05; 09 §3.2 Block Destruction row): while survival Alice (entity 1) breaks greystone by hand
*> (30 ticks), Bob (same dimension, in view) is sent Block Destruction with Alice's entity id, the
*> position and stage = elapsed ticks x 10 / 30 whenever it changes; Alice herself and Carol (out of
*> view) are sent none; the stage is cleared (255) on abort and when the block breaks. View distance
*> 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-PROGRESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
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
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "test break progress a player in view is sent Block Destruction with the breaker's "
         & "entity id, the position and the stage as it changes (ticks 1 and 3: stages 0, 1)"
         TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=0) 5(1,20,100,20=1)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test break progress the breaker is sent no Block Destruction" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "4(1)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test break progress a player out of view is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress an abort clears the stage (255) for the players in view"
         TO TL-CASE
     MOVE 2 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=255)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress a break that runs to its end sends stages 0 to 9, then the "
         & "clear, then the Block Update and Light Update of the broken block and its ground item "
         & "(Add Entity, Set Entity Data)" TO TL-CASE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=0) 5(1,20,100,20=1) 5(1,20,100,20=2) 5(1,20,100,20=3) "
         & "5(1,20,100,20=4) 5(1,20,100,20=5) 5(1,20,100,20=6) 5(1,20,100,20=7) "
         & "5(1,20,100,20=8) 5(1,20,100,20=9) 5(1,20,100,20=255) 8(20,100,20=0) 49(1,1) 1 101"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break progress a break that ends before any tick sends nothing" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 2 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BREAK-PROGRESS.

 COPY CORETEST.
