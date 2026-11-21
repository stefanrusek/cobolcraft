*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 4.7 (eyes, T1540) and 3.7 step 6: a portal room draws 12 nextFloat in order and a frame has an eye when its draw is
*> above 0.9, so a room is complete with probability 0.1 ^ 12 and has 1.2 eyes on average. 400 portal rooms are placed (SH-POST, each from its own decoration random) and the flags SH-EYE counted:
*> the mean is within 1.0 and 1.4 (the standard error is 0.05), no room has all twelve, and the counts of rooms with 0, 1 and 2 eyes follow the binomial(12, 0.1) shape (0 eyes: 28 %, 1 eye: 38 %).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY STRUCTSH.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-IDX                 BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-ARG                 PIC X(58).
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TOTAL                BINARY-LONG.
 01 WS-ROOMS-0              BINARY-LONG.
 01 WS-ROOMS-1              BINARY-LONG.
 01 WS-ROOMS-12             BINARY-LONG.
 01 WS-PERMILLE             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     CALL "MSP-BLOCKS"
     MOVE SBK-S-CAVE-AIR TO WS-AIR
     MOVE 0 TO WS-TOTAL WS-ROOMS-0 WS-ROOMS-1 WS-ROOMS-12
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 400
         PERFORM STONE-WORLD
         COMPUTE SP-XR-LO = WS-J * 7919 + 13
         COMPUTE SP-XR-HI = WS-J * 104729 + 77
         MOVE 0 TO A-X0 MOVE 40 TO A-Y0 MOVE 0 TO A-Z0 MOVE 10 TO A-X1 MOVE 47 TO A-Y1 MOVE 15 TO A-Z1
         MOVE 24 TO WS-PT
         MOVE 2 TO WS-PO
         CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
         CALL "SH-POST" USING WS-ROW
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
             ADD SH-EYE(WS-I) TO WS-N
         END-PERFORM
         ADD WS-N TO WS-TOTAL
         IF WS-N = 0
             ADD 1 TO WS-ROOMS-0
         END-IF
         IF WS-N = 1
             ADD 1 TO WS-ROOMS-1
         END-IF
         IF WS-N = 12
             ADD 1 TO WS-ROOMS-12
         END-IF
     END-PERFORM
*>   the mean eyes per room in hundredths
     COMPUTE WS-PERMILLE = WS-TOTAL * 100 / 400
     MOVE "acceptance US12 36-5§4.7 Eyes: the mean number of eyes of 400 portal rooms is between 1.0 and 1.4 (expected 1.2)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PERMILLE >= 100 AND WS-PERMILLE <= 140
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§4.7 Eyes: no portal room of the 400 is already complete (0.1 ^ 12 = 1e-12)" TO TL-CASE
     MOVE WS-ROOMS-12 TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§4.7 Eyes: rooms with no eye (28 percent expected) are between 20 and 36 percent" TO TL-CASE
     COMPUTE WS-PERMILLE = WS-ROOMS-0 * 100 / 400
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PERMILLE >= 20 AND WS-PERMILLE <= 36
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§4.7 Eyes: rooms with one eye (38 percent expected) are between 30 and 46 percent" TO TL-CASE
     COMPUTE WS-PERMILLE = WS-ROOMS-1 * 100 / 400
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PERMILLE >= 30 AND WS-PERMILLE <= 46
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 STONE-WORLD.
     CALL "SPB-RESET"
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-IDX)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     CALL "SH-RESET".
 END PROGRAM TEST-STRUCT-36-5-4-7.
 COPY CORETEST.
