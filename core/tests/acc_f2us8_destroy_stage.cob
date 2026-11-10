*> Acceptance test, US8-1 to US8-3 (docs/protocol/13 §2.4; 05a 0x05): while a survival player breaks a block the
*> Block Destruction stage 0 to 9 (floor(10 x progress), progress = rate x (ticks since start + 1)) goes to the
*> breaker and to every other player who sees the block, whenever it changes; abort and finish send stage -1 (the
*> byte 255); a block broken by another player ends the progress. Alice and Bobby are survival players in view
*> of each other, Carol is far away; Alice breaks loam (hardness 0.5, by hand 0.06667 per tick).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US8-DESTROY-STAGE.
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
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM DRAIN-ALL
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE "acceptance US8-1 given a survival break of loam when it starts then the breaker is sent "
         & "stage 0 and the ack" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=0) 4(1)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US8-1 the player in view is sent stage 0 at the start" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=0)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US8-1 the player out of view is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-1 given the break goes on when 12 ticks pass then the viewers are sent each "
         & "new stage once, 1 to 8 (progress 0.0667 x (ticks + 1))" TO TL-CASE
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=1) 5(1,20,100,20=2) 5(1,20,100,20=3) 5(1,20,100,20=4) 5(1,20,100,20=5) "
         & "5(1,20,100,20=6) 5(1,20,100,20=7) 5(1,20,100,20=8)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US8-1 the breaker is sent the same stages" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=1) 5(1,20,100,20=2) 5(1,20,100,20=3) 5(1,20,100,20=4) 5(1,20,100,20=5) "
         & "5(1,20,100,20=6) 5(1,20,100,20=7) 5(1,20,100,20=8)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given the progress is past 0.7 when the player finishes then the stage "
         & "is cleared (255) for the viewers, the block becomes void and the ack follows" TO TL-CASE
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=255) 8(20,100,20=0)" TO TL-EXPECTED
     PERFORM CHECK-PREFIX

     MOVE "acceptance US8-2 given a started break when it is aborted then the viewers and the "
         & "breaker are sent stage 255 and the block stays" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 2 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     *>   The 128 is a packet the core sends every 20 ticks (not shown by name by TEST-DRAIN-BLOCKS).
     MOVE "5(1,20,100,20=0) 5(1,20,100,20=1) 128 5(1,20,100,20=2) 5(1,20,100,20=255)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-3 given Alice is breaking a block when Bobby breaks it first then Alice's "
         & "progress ends with stage 255 at the next tick" TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FLAGS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=255) 128" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 DRAIN-ALL.
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CAROL WS-TEXT.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The expected text is the start of the observed text.
 CHECK-PREFIX.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED))) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US8-DESTROY-STAGE.

 COPY CORETEST.
