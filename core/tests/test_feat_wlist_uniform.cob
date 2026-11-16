*> Test of the weighted_list int provider with uniform entries (docs/protocol/23 section 7.1, 35-1 section 5; core/src/feat-data.cob FD-J-IP and feat-run.cob FR-INT-SAMPLE): the
*> dripleaf stem height {weighted_list: uniform 0..4 weight 2, constant 0 weight 1}: one nextInt(total weight) picks the entry, then the entry is sampled (a uniform draws nextInt(range),
*> a constant draws nothing). The shadow model is a second random stream seeded alike, over 200 seeds; a nested weighted_list as an entry is refused.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-WLIST-UNIFORM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
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
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-AFTER2              BINARY-LONG.
 01 WS-BIG                 BINARY-LONG VALUE 1000.
 01 WS-HIST.
    05 WS-H                BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "FD-RESET"
     MOVE '{"type": "minecraft:weighted_list", "distribution": [{"data": {"type": "minecraft:uniform", "max_inclusive": 4, "min_inclusive": 0}, "weight": 2}, {"data": 0, "weight": 1}]}'
         TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7.1 a weighted_list of a uniform and a constant compiles" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 23§7.1 the weighted_list keeps its kind 6, two entries and the total weight 3" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-V(1) * 100 + WS-V(3) * 10 + WS-V(4)
     COMPUTE TL-EXPECTED-N = 600 + 20 + 3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEEN
     MOVE 0 TO WS-H(1) WS-H(2) WS-H(3) WS-H(4) WS-H(5) WS-H(6)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         CALL "FR-INT-SAMPLE" USING XR-STATE WS-P WS-VALUE
*>       the model: pick below 3 (0, 1 the uniform, 2 the constant), then the uniform draws nextInt(5)
         MOVE 3 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
         IF WS-DRAW < 2
             MOVE 5 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-EXPECT
         ELSE
             MOVE 0 TO WS-EXPECT
         END-IF
         IF WS-VALUE NOT = WS-EXPECT
             ADD 1 TO WS-SEEN
         END-IF
         ADD 1 TO WS-H(WS-VALUE + 1)
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BIG WS-AFTER
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BIG WS-AFTER2
         IF WS-AFTER NOT = WS-AFTER2
             ADD 1 TO WS-SEEN
         END-IF
     END-PERFORM
     MOVE "acceptance 23§7.1 a weighted_list sample and the next draw equal the model (200 seeds)" TO TL-CASE
     MOVE WS-SEEN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 23§7.1 every height 0 to 4 occurs and no other" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF WS-H(WS-I) > 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     ADD WS-H(6) TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a nested weighted_list as an entry is refused
     MOVE '{"type": "minecraft:weighted_list", "distribution": [{"data": {"type": "minecraft:weighted_list", "distribution": [{"data": 1, "weight": 1}]}, "weight": 2}]}'
         TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "acceptance 23§7.1 a weighted_list whose entry is a weighted_list is refused" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-WLIST-UNIFORM.
