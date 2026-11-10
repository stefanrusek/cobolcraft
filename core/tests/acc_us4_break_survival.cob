*> Acceptance test, US4-3 core half (spec US4 scenario 3; tasks T439; standin-content §1.1, §2;
*> data-model §3): in survival, breaking takes the hand break time of §1.1 (50 ms ticks), a quarter of
*> it with the matching tool of §2, and leaves void; a finish before the break time leaves the block;
*> the baseplate is never broken (US4 edge). Alice is a first-time survival player: slot 0 holds
*> greystone (not a tool), slot 8 the pry_bar (hard class), slot 9 the trowel (soft class; swapped
*> into hotbar slot 7 with Container Click SWAP to be held). A completed break also sends the
*> ground item of the yield (Add Entity 1, Set Entity Data 101; the yield itself is checked in
*> acc_us5_break_drop.cob).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-BREAK-SURVIVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
*>   No mob spawns during the test: night (standin §4.8) with hostile mobs off, where §12.4
*>   names only the abend for cobolcraft:main.
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN

     MOVE "acceptance US4-3 given survival and greystone (hardness 1.5, by hand 0.0222 per tick) when "
         & "a block is broken after 31 ticks (progress 0.711, 13 §2.4 accepts from 0.7) then the "
         & "block becomes void" TO TL-CASE
     MOVE 2 TO WS-STATE
     MOVE 31 TO WS-TICKS
     PERFORM BREAK-BLOCK
     MOVE "5(1,20,100,20=255) 8(20,100,20=0) 49(1,1) 1 101 4(2) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival and the matching tool (pry_bar, hard class) when "
         & "greystone is broken then it takes the tool speed 4.0 (rate 0.0889, accepted from 7 ticks)" TO TL-CASE
     MOVE 8 TO WS-SLOT
     CALL "TEST-HELD" USING WS-CONN WS-SLOT
     MOVE 2 TO WS-STATE
     MOVE 7 TO WS-TICKS
     PERFORM BREAK-BLOCK
     MOVE "5(1,20,100,20=255) 8(20,100,20=0) 49(1,1) 1 101 4(4) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival and the matching tool (trowel, soft class) when loam "
         & "(0.6 s) is broken then the tool speed 4.0 (rate 0.2667, accepted from 3 ticks)" TO TL-CASE
     MOVE 9 TO WS-SLOT
     MOVE 7 TO WS-BUTTON
     MOVE 2 TO WS-TYPE
     CALL "TEST-CLICK" USING WS-CONN WS-SLOT WS-BUTTON WS-TYPE
     MOVE 7 TO WS-SLOT
     CALL "TEST-HELD" USING WS-CONN WS-SLOT
     MOVE 3 TO WS-STATE
     MOVE 3 TO WS-TICKS
     PERFORM BREAK-BLOCK
     MOVE "5(1,20,100,20=255) 8(20,100,20=0) 49(1,1) 1 101 4(6) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival and a tool of the other class (trowel on greystone) "
         & "when the block is finished after a quarter of the time then the block is left"
         TO TL-CASE
     MOVE 2 TO WS-STATE
     MOVE 7 TO WS-TICKS
     PERFORM BREAK-BLOCK
     MOVE "8(20,100,20=2) 4(8) state 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival when a break is finished one tick before the break "
         & "time (29 of 30 ticks by hand) then the block is left and the player is sent its real "
         & "state" TO TL-CASE
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-CONN WS-SLOT
     MOVE 2 TO WS-STATE
     MOVE 29 TO WS-TICKS
     PERFORM BREAK-BLOCK
     MOVE "8(20,100,20=2) 4(10) state 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival when a break of one block is finished on another "
         & "block then neither is broken" TO TL-CASE
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 21 TO WS-X
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     PERFORM ADD-STATE
     MOVE 20 TO WS-X
     PERFORM ADD-STATE
     MOVE "5(1,20,100,20=255) 5(1,20,100,20=0) 4(11) 5(1,20,100,20=1) 5(1,20,100,20=2) "
         & "5(1,20,100,20=3) 5(1,20,100,20=4) 5(1,20,100,20=5) 5(1,20,100,20=6) "
         & "5(1,20,100,20=255) 8(21,100,20=2) 4(12) state 2 state 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given survival when the baseplate (y 0) is broken for any time "
         & "then it stays and the player is sent its real state" TO TL-CASE
     MOVE 0 TO WS-Y
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     PERFORM ADD-STATE
     MOVE "8(20,0,20=1) 4(13) 8(20,0,20=1) 4(14) state 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4-3 given survival when a break is aborted then the block stays and a "
         & "later finish without a new start breaks nothing" TO TL-CASE
     MOVE 100 TO WS-Y
     MOVE 2 TO WS-STATE
     PERFORM SET-BLOCK
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 2 TO WS-ACTION
     PERFORM ACT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     PERFORM ADD-STATE
     MOVE "5(1,20,100,20=0) 4(15) 5(1,20,100,20=255) 4(16) 8(20,100,20=2) 4(17) state 2"
         TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Puts WS-STATE at (WS-X, WS-Y, WS-Z), starts a break, waits WS-TICKS ticks, finishes it, drains
*> the packets into WS-TEXT and appends the block's state.
 BREAK-BLOCK.
     PERFORM SET-BLOCK
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     PERFORM ADD-STATE.

 SET-BLOCK.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 ADD-STATE.
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE SPACES TO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US4-BREAK-SURVIVAL.

 COPY CORETEST.
