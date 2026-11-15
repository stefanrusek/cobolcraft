*> Test of the clamped int provider (docs/protocol/23 section 7.1, 35-1 section 5; core/src/feat-data.cob FD-J-IP and feat-run.cob FR-INT-SAMPLE): clamp(source.sample(r), min, max),
*> with the draws of the source only, as the count of the forest flower features is written (clamped 0 to 1 over uniform -3 to 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-CLAMPED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 COPY XORO.
 COPY JSONDOC.
 01 WS-TEXT                PIC X(512).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-P.
    05 WS-V                BINARY-LONG OCCURS 4 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG VALUE 5.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "FD-RESET"
     MOVE '{"type": "minecraft:clamped", "min_inclusive": 0, "max_inclusive": 1, "source": {"type": "minecraft:uniform", "min_inclusive": -3, "max_inclusive": 1}}'
         TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7.1 a clamped provider compiles: kind 7, the bounds and the source in the pool" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OK * 100000 + WS-V(1) * 10000 + WS-V(2) * 1000 + WS-V(3) * 100 + FD-POOL-COUNT
     MOVE 174 TO TL-EXPECTED-N
     COMPUTE TL-EXPECTED-N = 100000 + 70000 + 0 + 100 + 4
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   every draw of nextInt(5) - 3 is clamped to 0 or 1: the values -3 .. -1 give 0, 0 gives 0, 1 gives 1; the draws are those of the source only
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "FR-INT-SAMPLE" USING XR-STATE WS-P WS-VALUE
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
         COMPUTE WS-EXPECT = WS-DRAW - 3
         IF WS-EXPECT < 0
             MOVE 0 TO WS-EXPECT
         END-IF
         IF WS-VALUE NOT = WS-EXPECT
             ADD 1 TO WS-SEEN
         END-IF
     END-PERFORM
     MOVE "acceptance 23§7.1 a clamped sample is the clamped source sample (40 seeds)" TO TL-CASE
     MOVE WS-SEEN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a maximum below the minimum, a missing source and a bad source are refused
     MOVE '{"type": "minecraft:clamped", "min_inclusive": 3, "max_inclusive": 1, "source": 2}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7.1 a clamped provider whose maximum is below its minimum is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"type": "minecraft:clamped", "min_inclusive": 0, "max_inclusive": 1}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7.1 a clamped provider without a source is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the bounds themselves: a clamp that pins the value (min = max = 7 over a constant 2 gives 7, over a constant 9 gives 7)
     MOVE '{"type": "minecraft:clamped", "min_inclusive": 7, "max_inclusive": 7, "source": 9}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     CALL "FR-INT-SAMPLE" USING XR-STATE WS-P WS-VALUE
     MOVE "acceptance 23§7.1 a source above the maximum is clamped down to it" TO TL-CASE
     MOVE WS-VALUE TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-CLAMPED.
