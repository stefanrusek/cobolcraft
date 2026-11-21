*> Acceptance test of the fortress's chests, blaze spawner, loot and spawns (docs/protocol/36-structures-8-nether-and-end.md section 6; core/src/nether-37-6.cob NETHER-FORTRESS-SPAWN,
*> struct-fortress-post.cob; T13513): the five spawn entries of 6.3 with their weights and counts (the cells and the requests of 6.1 and the spawner of 5.6 are in test_struct_36_8_5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(20).
 01 WS-LEN                 BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-WANT.
    05 FILLER PIC X(32) VALUE "blaze           010002003".
    05 FILLER PIC X(32) VALUE "zombified_piglin005004004".
    05 FILLER PIC X(32) VALUE "wither_skeleton 008005005".
    05 FILLER PIC X(32) VALUE "skeleton        002005005".
    05 FILLER PIC X(32) VALUE "magma_cube      003004004".
 01 WS-W REDEFINES WS-WANT.
    05 WS-ROW OCCURS 5 TIMES.
       10 WS-R-NAME        PIC X(16).
       10 WS-R-WEIGHT      PIC 999.
       10 WS-R-MIN         PIC 999.
       10 WS-R-MAX         PIC 999.
       10 FILLER           PIC X(7).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "NETHER-FORTRESS-SPAWN" USING WS-I WS-NAME WS-LEN WS-WEIGHT WS-MIN WS-MAX
         IF WS-NAME NOT = WS-R-NAME(WS-I) OR WS-WEIGHT NOT = WS-R-WEIGHT(WS-I) OR WS-MIN NOT = WS-R-MIN(WS-I) OR WS-MAX NOT = WS-R-MAX(WS-I)
             ADD 1 TO WS-BAD
         END-IF
         IF WS-LEN NOT = FUNCTION LENGTH(FUNCTION TRIM(WS-R-NAME(WS-I)))
             ADD 1 TO WS-BAD
         END-IF
         ADD WS-WEIGHT TO WS-TOTAL
     END-PERFORM
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the five fortress spawn entries with weights and counts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the weights add up to 28" TO TL-CASE
     MOVE 28 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-6.
