*> Acceptance test of docs/protocol/42-particles-4-block-item-dust-ambient.md section 2 (Conventions used in this part): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EDRAWS.
    05 WS-E                FLOAT-LONG OCCURS 16 TIMES.
 01 W1                     FLOAT-LONG.
 01 W2                     FLOAT-LONG.
 01 W3                     FLOAT-LONG.
 01 W4                     FLOAT-LONG.
 01 W5                     FLOAT-LONG.
 01 W6                     FLOAT-LONG.
 01 W7                     FLOAT-LONG.
 01 W8                     FLOAT-LONG.
 01 I1                     BINARY-LONG.
 01 I2                     BINARY-LONG.
 01 I3                     BINARY-LONG.
 01 I4                     BINARY-LONG.
 01 I5                     BINARY-LONG.
 01 B1                     BINARY-DOUBLE.
 01 T1                     PIC X(80).
 01 Z1                     FLOAT-LONG VALUE 0.
 01 Z2                     FLOAT-LONG VALUE 0.
 01 Z3                     FLOAT-LONG VALUE 0.
 01 Z4                     FLOAT-LONG VALUE 0.
 01 Z5                     FLOAT-LONG VALUE 0.
 01 Z6                     FLOAT-LONG VALUE 0.
 01 T-NAME                 PIC X(32).
 01 T-OPT                  PIC X(16).
 01 T-PROV                 PIC X(56).
 01 T-OVR                  BINARY-LONG.
 01 T-SPR                  BINARY-LONG.
 01 T-PART                 BINARY-LONG.
 01 T-ID                   BINARY-LONG.
 01 T-LAYER                BINARY-LONG.
 01 T-SECTION              PIC X(5).
 01 N-OVR                  BINARY-LONG VALUE 0.
 01 N-PLAIN                BINARY-LONG VALUE 0.
 01 N-L0                   BINARY-LONG VALUE 0.
 01 N-L1                   BINARY-LONG VALUE 0.
 01 N-L9                   BINARY-LONG VALUE 0.
 01 N-LN                   BINARY-LONG VALUE 0.
 01 N-FOUND                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "P4-TYPE-COUNT" USING I1
     MOVE "33 types in this part" TO WS-NAME
     MOVE 33 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     PERFORM VARYING I2 FROM 1 BY 1 UNTIL I2 > 33
         CALL "P4-TYPE-LIST" USING I2 T-ID
         CALL "PART-TYPE" USING T-ID T-NAME T-OPT T-OVR T-PROV T-SPR T-PART
         IF T-NAME NOT = SPACES
             ADD 1 TO N-FOUND
         END-IF
         ADD T-OVR TO N-OVR
         IF T-SPR = 0
             ADD 1 TO N-PLAIN
         END-IF
         CALL "P4-TYPE-INFO" USING T-ID T-LAYER T-SECTION
         EVALUATE T-LAYER
             WHEN 0
                 ADD 1 TO N-L0
             WHEN 1
                 ADD 1 TO N-L1
             WHEN 9
                 ADD 1 TO N-L9
             WHEN OTHER
                 ADD 1 TO N-LN
         END-EVALUATE
     END-PERFORM
     MOVE "every listed id is a registry type (names agree with 42-1 2)" TO WS-NAME
     MOVE 33 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-FOUND
     PERFORM ASSERT-NUMBER
     MOVE "the override flag is yes for exactly 6 rows (block_marker and the glow family)" TO WS-NAME
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-OVR
     PERFORM ASSERT-NUMBER
     MOVE "8 rows take no sprite set (plain providers)" TO WS-NAME
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-PLAIN
     PERFORM ASSERT-NUMBER
     MOVE "22 rows are OPAQUE" TO WS-NAME
     MOVE 22 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-L0
     PERFORM ASSERT-NUMBER
     MOVE "1 row is TRANSLUCENT (firefly)" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-L1
     PERFORM ASSERT-NUMBER
     MOVE "9 rows are chosen by sprite" TO WS-NAME
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-L9
     PERFORM ASSERT-NUMBER
     MOVE "1 row has no layer here (infested, 42-2)" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = N-LN
     PERFORM ASSERT-NUMBER
     MOVE 1 TO I2
     CALL "P4-TYPE-LIST" USING I2 T-ID
     MOVE "first row of the table is block (id 1)" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-ID
     PERFORM ASSERT-NUMBER
     MOVE 17 TO I2
     CALL "P4-TYPE-LIST" USING I2 T-ID
     MOVE "row 17 is sulfur_cube_goo (id 127)" TO WS-NAME
     MOVE 127 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-ID
     PERFORM ASSERT-NUMBER
     MOVE 33 TO I2
     CALL "P4-TYPE-LIST" USING I2 T-ID
     MOVE "last row is block_crumble (id 125)" TO WS-NAME
     MOVE 125 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-ID
     PERFORM ASSERT-NUMBER
     MOVE 126 TO T-ID
     CALL "P4-TYPE-INFO" USING T-ID T-LAYER T-SECTION
     MOVE "firefly layer is TRANSLUCENT" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-LAYER
     PERFORM ASSERT-NUMBER
     MOVE "firefly section" TO WS-NAME
     MOVE "12" TO TL-EXPECTED
     MOVE T-SECTION TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 97 TO T-ID
     CALL "P4-TYPE-INFO" USING T-ID T-LAYER T-SECTION
     MOVE "spore_blossom_air is section 10.2" TO WS-NAME
     MOVE "10.2" TO TL-EXPECTED
     MOVE T-SECTION TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 121 TO T-ID
     CALL "P4-TYPE-INFO" USING T-ID T-LAYER T-SECTION
     MOVE "dust_pillar is section 3.5" TO WS-NAME
     MOVE "3.5" TO TL-EXPECTED
     MOVE T-SECTION TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "dust_pillar layer is chosen by sprite" TO WS-NAME
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-LAYER
     PERFORM ASSERT-NUMBER
     MOVE 127 TO T-ID
     CALL "PART-TYPE" USING T-ID T-NAME T-OPT T-OVR T-PROV T-SPR T-PART
     MOVE "sulfur_cube_goo is the only item-family type with a sprite set" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = T-SPR
     PERFORM ASSERT-NUMBER
     MOVE 0 TO W1
     CALL "P4-SCALE-CLAMP" USING W1 W2
     MOVE "dust scale 0 clamps to 0.01" TO WS-NAME
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W2) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 10 TO W1
     CALL "P4-SCALE-CLAMP" USING W1 W2
     MOVE "dust scale 10 clamps to 4.0" TO WS-NAME
     MOVE 400000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W2) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 2.5 TO W1
     CALL "P4-SCALE-CLAMP" USING W1 W2
     MOVE "dust scale 2.5 is kept" TO WS-NAME
     MOVE 250000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W2) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§2 Conventions used in this part: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§2 Conventions used in this part: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-4-2.
