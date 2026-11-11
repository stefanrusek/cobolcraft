*> Acceptance test of docs/protocol/35-worldgen-features-1 section 14 (cross-reference index of the siblings): the part of the document that specifies a feature type, for a type of each row of the index.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-HM                  PIC X(32).
 01 WS-TEXT                PIC X(60).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE "no_op" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: no_op is in 35-1 section 9" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-1 section 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "scattered_ore" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: scattered_ore is in 35-1 section 13" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-1 section 13" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ore" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: ore is in 11 section 7" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "11 section 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "tree" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: tree is in 35-3 sections 2 and 7" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-3 sections 2 and 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fallen_tree" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: fallen_tree is in 35-3 sections 2 and 7" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-3 sections 2 and 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bamboo" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: bamboo is in 35-4 sections 4, 5, 6" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-4 sections 4, 5, 6" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "overlay" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: overlay is in 35-4 section 7" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-4 section 7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "root_system" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: root_system is in 35-4 sections 8, 9, 10, 11" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-4 sections 8, 9, 10, 11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "lake" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: lake is in 35-5 sections 3 to 12" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-5 sections 3 to 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spike" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: spike is in 35-5 sections 13 to 16, 18" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-5 sections 13 to 16, 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "geode" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: geode is in 35-6 sections 4 to 10" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-6 sections 4 to 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "end_gateway" TO WS-NAME
     CALL "F351-WHERE" USING WS-NAME WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: end_gateway is in 35-7 sections 3, 4, 8, 9, 10" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "35-7 sections 3, 4, 8, 9, 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     MOVE 1 TO WS-C
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 57
         CALL "F351-REGISTRY-NAME" USING WS-C WS-I WS-NAME
         CALL "F351-WHERE" USING WS-NAME WS-TEXT
         IF WS-TEXT NOT = SPACES
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§14 Cross-reference index of the siblings: every one of the 58 feature types is placed in a part" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SUM
     MOVE 58 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
