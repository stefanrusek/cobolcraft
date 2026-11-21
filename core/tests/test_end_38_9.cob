*> Implementation test (core/src/end-38d.cob; docs/protocol/38-end.md section 9, Player arrival, the obsidian platform, the return, void and falling): the arrival position of a player (100.5, 49, 0.5) and of another entity (100.5, 50, 0.5), yaw 90; leaving the End (credits first, then the respawn rules); the void below y -64; the platform rebuilt on every entry in the world of the End (a block placed in its volume is reset and counted for the item drop).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 20.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-P
     CALL "END-ARRIVAL" USING WS-P WS-X WS-Y WS-Z WS-YAW
     MOVE WS-X TO WS-V
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling player x" TO TL-CASE
     MOVE 1005000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling player y" TO TL-CASE
     MOVE 490000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-Z TO WS-V
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling player z" TO TL-CASE
     MOVE 5000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE WS-YAW TO WS-V
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling yaw 90" TO TL-CASE
     MOVE 900000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 0 TO WS-P
     CALL "END-ARRIVAL" USING WS-P WS-X WS-Y WS-Z WS-YAW
     MOVE WS-Y TO WS-V
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling non-player y 50" TO TL-CASE
     MOVE 500000000 TO WS-WANT
     PERFORM CHECK-V
     MOVE 1 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-LEAVE" USING WS-P WS-C WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling leaving: unseen credits show the credits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-P
     MOVE 1 TO WS-C
     CALL "END-LEAVE" USING WS-P WS-C WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling leaving: a player who saw them goes to his respawn" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-LEAVE" USING WS-P WS-C WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling leaving: a non-player goes to the level respawn" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-P
     MOVE 1 TO WS-C
     CALL "END-LEAVE" USING WS-P WS-C WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling leaving: a non-player ignores credits" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-A
     MOVE 1 TO WS-B
     CALL "END-BELOW-WORLD" USING WS-A WS-B WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling void: y -64 is still inside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -65 TO WS-A
     MOVE 1 TO WS-B
     CALL "END-BELOW-WORLD" USING WS-A WS-B WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling void: a living entity below -64 takes damage" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -65 TO WS-A
     MOVE 0 TO WS-B
     CALL "END-BELOW-WORLD" USING WS-A WS-B WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling void: a plain entity below -64 is discarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-A
     MOVE 1 TO WS-B
     CALL "END-BELOW-WORLD" USING WS-A WS-B WS-R
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling void: y 10 is fine" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-END TO WS-DIM
     CALL "END-ARRIVE-BUILD" USING WS-DIM WS-DROPPED
     MOVE 100 TO WS-A
     MOVE 48 TO WS-B
     MOVE 0 TO WS-D
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-A WS-B WS-D WS-STATE
     MOVE "obsidian" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-E
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling the platform centre floor is obsidian" TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-A
     MOVE 50 TO WS-B
     MOVE 1 TO WS-D
     MOVE "stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-E
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-A WS-B WS-D WS-E
     CALL "END-ARRIVE-BUILD" USING WS-DIM WS-DROPPED
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling entering again drops the one block placed in the volume" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DROPPED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-A WS-B WS-D WS-STATE
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling and resets it to air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "END-ARRIVE-BUILD" USING WS-DIM WS-DROPPED
     MOVE "acceptance US12 38§9 Player arrival, the obsidian platform, the return, void and falling a third entry changes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DROPPED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-V.
     COMPUTE WS-GOT ROUNDED = WS-V * 10000000
     COMPUTE WS-DIFF = WS-GOT - WS-WANT
     IF WS-DIFF < 0
         COMPUTE WS-DIFF = 0 - WS-DIFF
     END-IF
     MOVE WS-WANT TO TL-EXPECTED-N
     IF WS-DIFF <= WS-TOL
         MOVE WS-WANT TO TL-OBSERVED-N
     ELSE
         MOVE WS-GOT TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-END-38-9.

 COPY CORETEST.
 COPY PORTALTEST.
