*> The remembered states of STRUCT-TPL-STATE (docs/design/world-types.md structures part 8, performance): for the states of the first 400 blocks of the open content set (the stand-in set has 13), the answer
*> of the memo (asked cold, then asked again) equals the engine's (STRUCT-TPL-STATE-RAW); pairs longer than 160 bytes (never kept), an unknown block and a block table of another epoch
*> answer as the engine does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-TPL-STATE-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-TEXT                PIC X(160).
 01 WS-B                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-CASES               BINARY-LONG.
 01 WS-BAD-COLD            BINARY-LONG.
 01 WS-BAD-HIT             BINARY-LONG.
 01 WS-PROPS               BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-CASES WS-BAD-COLD WS-BAD-HIT WS-PROPS
     MOVE CB-BLOCK-COUNT TO WS-LIMIT
     IF WS-LIMIT > 400
         MOVE 400 TO WS-LIMIT
     END-IF
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > WS-LIMIT
         COMPUTE WS-LAST = CB-FIRST-STATE(WS-B) + CB-STATES(WS-B) - 1
         IF CB-STATES(WS-B) > 6
             COMPUTE WS-LAST = CB-FIRST-STATE(WS-B) + 5
         END-IF
         PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-B) BY 1 UNTIL WS-S > WS-LAST
             MOVE SPACES TO WS-KEY WS-PAIRS
             MOVE CB-KEY(WS-B) TO WS-KEY
             CALL "BLOCKS-STATE-PROPS" USING WS-S WS-TEXT
             MOVE WS-TEXT TO WS-PAIRS
             IF WS-TEXT NOT = SPACES
                 ADD 1 TO WS-PROPS
             END-IF
             PERFORM COMPARE-ONE
         END-PERFORM
     END-PERFORM
     MOVE "test struct tpl state cache when the states of 400 blocks are asked cold then they equal the engine's" TO TL-CASE
     MOVE WS-BAD-COLD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct tpl state cache when the same states are asked again then they equal the engine's" TO TL-CASE
     MOVE WS-BAD-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct tpl state cache when the stand-in blocks have states and properties then the comparison is not trivial" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CASES > 15 AND WS-PROPS > 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   long pairs are not kept, an unknown block is state 0
     MOVE SPACES TO WS-KEY WS-PAIRS
     MOVE "minecraft:oak_stairs" TO WS-KEY
     MOVE ALL "facing=east,half=top," TO WS-PAIRS(1:200)
     PERFORM COMPARE-ONE
     PERFORM COMPARE-ONE
     MOVE SPACES TO WS-KEY WS-PAIRS
     MOVE "minecraft:no_such_block" TO WS-KEY
     PERFORM COMPARE-ONE
     PERFORM COMPARE-ONE
     MOVE "test struct tpl state cache when long pairs and an unknown block are asked then they equal the engine's" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-BAD-COLD + WS-BAD-HIT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   another block table epoch
     ADD 1 TO CB-EPOCH
     MOVE "minecraft:oak_stairs" TO WS-KEY
     MOVE "facing=east,half=top" TO WS-PAIRS
     PERFORM COMPARE-ONE
     PERFORM COMPARE-ONE
     MOVE "test struct tpl state cache given another block table epoch when a state is asked then it equals the engine's" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-BAD-COLD + WS-BAD-HIT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COMPARE-ONE.
     ADD 1 TO WS-CASES
     CALL "STRUCT-TPL-STATE-RAW" USING WS-KEY WS-PAIRS WS-RAW
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-COLD
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-HIT
     IF WS-COLD NOT = WS-RAW
         ADD 1 TO WS-BAD-COLD
     END-IF
     IF WS-HIT NOT = WS-RAW
         ADD 1 TO WS-BAD-HIT
     END-IF.
 END PROGRAM TEST-STRUCT-TPL-STATE-CACHE.

 COPY CORETEST.
