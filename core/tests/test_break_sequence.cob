*> Test of Player Action start, abort and finish handling with sequence ids and acknowledgements (core/src/breaking.cob;
*> docs/protocol/13 §2.3, §2.4): every answered action ends with Block Changed Ack of its sequence; a finish after
*> enough progress (>= 0.7) breaks the block; an early finish leaves the block, sends its real state and the break
*> goes on to a delayed destroy at progress 1.0; a changed held item or target aborts. Survival Alice breaks loam
*> by hand (0.06667 per tick).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-SEQUENCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 3.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE "test break sequence a start answers with its stage 0 and Block Changed Ack of sequence 10"
         TO TL-CASE
     MOVE 0 TO WS-ACTION
     MOVE 10 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=0) 4(10)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break sequence an abort answers with the cleared stage and the ack of sequence 11"
         TO TL-CASE
     MOVE 2 TO WS-ACTION
     MOVE 11 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "5(1,20,100,20=255) 4(11)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break sequence a finish after 14 ticks (progress past 0.7) breaks the block and is "
         & "acknowledged with sequence 13" TO TL-CASE
     MOVE 0 TO WS-ACTION
     MOVE 12 TO WS-SEQ
     PERFORM ACT
     MOVE 14 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 3 TO WS-ACTION
     MOVE 13 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "4(13) state 0" TO TL-EXPECTED
     PERFORM CHECK-STATE-ACK

     MOVE "test break sequence a finish at 2 ticks (progress 0.2) leaves the block, sends its real "
         & "state and the ack of sequence 15" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     MOVE 14 TO WS-SEQ
     PERFORM ACT
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 3 TO WS-ACTION
     MOVE 15 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE "8(20,100,20=3) 4(15)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break sequence the early finish keeps the break: later ticks bring the progress to "
         & "1.0 and the block breaks (delayed destroy)" TO TL-CASE
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "state 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) - 6:7)) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break sequence a changed held item aborts: the finish that follows breaks nothing"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     MOVE 16 TO WS-SEQ
     PERFORM ACT
     MOVE 14 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 3 TO WS-ACTION
     MOVE 17 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "state 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) - 6:7)) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test break sequence a finish on another block than the started one aborts and breaks "
         & "neither" TO TL-CASE
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 0 TO WS-ACTION
     MOVE 18 TO WS-SEQ
     PERFORM ACT
     MOVE 14 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     ADD 1 TO WS-X
     MOVE 3 TO WS-ACTION
     MOVE 19 TO WS-SEQ
     PERFORM ACT
     SUBTRACT 1 FROM WS-X
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "state 3" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) - 6:7)) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test break sequence a block whose rate reaches 1.0 (hardness 0.001) breaks at the start "
         & "without any tick, with the ack of sequence 20" TO TL-CASE
     MOVE 1 TO CB-BREAK-MS(CB-S-BLOCK(WS-STATE + 1) + 1)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     MOVE 20 TO WS-SEQ
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM ADD-STATE
     MOVE "4(20) state 0" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) - 12:13)) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ACT.
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 ADD-STATE.
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE 3 TO WS-STATE.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ack of the finish is the last packet of the drained text, the block state follows it.
 CHECK-STATE-ACK.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) - 12:13) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BREAK-SEQUENCE.

 COPY CORETEST.
