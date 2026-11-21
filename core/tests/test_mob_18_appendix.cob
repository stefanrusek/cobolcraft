*> Natural spawn data per biome (docs/protocol/18 Appendix A; lane 002-lane-p49e, T18510): the appendix itself is read at run time (the tests run from the repository
*> root) and every biome of it is compared with the table of MOBSPAWN.cpy: the biome's creature_worldgen_prob, its entry count, each entry in list order (category,
*> species, weight, pack size minimum and maximum) and its spawn costs (charge and energy budget in thousandths).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-APPENDIX.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT DOC-FILE ASSIGN TO "docs/protocol/18-mob-framework.md" ORGANIZATION LINE SEQUENTIAL FILE STATUS WS-FS.
 DATA DIVISION.
 FILE SECTION.
 FD DOC-FILE.
 01 DOC-LINE               PIC X(2048).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBSPAWN.
 01 WS-FS                  PIC XX.
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-BIOMES              BINARY-LONG VALUE 0.
 01 WS-ENTRIES             BINARY-LONG VALUE 0.
 01 WS-COSTS               BINARY-LONG VALUE 0.
 01 WS-COST-IDX            BINARY-LONG VALUE 0.
 01 WS-COSTN               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG VALUE 0.
 01 WS-NEXT                BINARY-LONG VALUE 0.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(48).
 01 WS-PROBTXT             PIC X(24).
 01 WS-PROB                BINARY-LONG.
 01 WS-CAT-TXT             PIC X(40).
 01 WS-CAT                 BINARY-LONG.
 01 WS-REST                PIC X(2048).
 01 WS-REST-LEN            BINARY-LONG.
 01 WS-ITEM                PIC X(80).
 01 WS-P                   BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-WTXT                PIC X(16).
 01 WS-NTXT                PIC X(16).
 01 WS-NRANGE              PIC X(16).
 01 WS-LO-TXT              PIC X(16).
 01 WS-HI-TXT              PIC X(16).
 01 WS-W                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TOK                 PIC X(60) OCCURS 80 TIMES.
 01 WS-TN                  BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-NUM                 PIC X(60).
 01 WS-CHARGE              BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LIVE                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     OPEN INPUT DOC-FILE
     IF WS-FS NOT = "00"
         DISPLAY "cannot open the document: " WS-FS
         STOP RUN RETURNING 1
     END-IF
     PERFORM UNTIL WS-STATE = 9
         READ DOC-FILE
             AT END
                 MOVE 9 TO WS-STATE
         END-READ
         IF WS-STATE NOT = 9
             COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(DOC-LINE TRAILING))
             EVALUATE TRUE
                 WHEN WS-STATE = 0
                     IF DOC-LINE(1:26) = "## Appendix A. Natural spa"
                         MOVE 1 TO WS-STATE
                     END-IF
                 WHEN WS-STATE = 1
                     IF DOC-LINE(1:3) = "```"
                         MOVE 2 TO WS-STATE
                     END-IF
                 WHEN DOC-LINE(1:3) = "```"
                     MOVE 9 TO WS-STATE
                 WHEN DOC-LINE(1:3) = "## "
                     PERFORM FINISH-BIOME
                     PERFORM START-BIOME
                 WHEN DOC-LINE(1:8) = " costs: "
                     IF WS-LIVE = 1
                         PERFORM COSTS-LINE
                     END-IF
                 WHEN DOC-LINE(1:1) = " "
                     IF WS-LIVE = 1
                         PERFORM ENTRY-LINE
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     PERFORM FINISH-BIOME
     CLOSE DOC-FILE
     MOVE "acceptance US15 18§A Natural spawn data per biome: the appendix lists every biome of the table" TO TL-CASE
     MOVE SP-BIOMES TO TL-EXPECTED-N
     MOVE WS-BIOMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§A Natural spawn data per biome: the appendix lists every entry of the table" TO TL-CASE
     MOVE SP-ENTRIES TO TL-EXPECTED-N
     MOVE WS-ENTRIES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§A Natural spawn data per biome: the appendix lists every cost of the table" TO TL-CASE
     MOVE SP-COSTS TO TL-EXPECTED-N
     MOVE WS-COSTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-BIOME.
     MOVE SPACES TO WS-NAME
     MOVE SPACES TO WS-PROBTXT
     COMPUTE WS-T = WS-LEN - 3
     UNSTRING DOC-LINE(4:WS-T) DELIMITED BY " | creature_worldgen_prob= " INTO WS-NAME WS-PROBTXT
     ADD 1 TO WS-BIOMES
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > SP-BIOMES OR WS-ROW > 0
         IF SPB-NAME(WS-E) = WS-NAME
             MOVE WS-E TO WS-ROW
         END-IF
     END-PERFORM
     STRING "acceptance US15 18§A Natural spawn data per biome: the table has " DELIMITED BY SIZE
         FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-LIVE
     IF WS-ROW > 0
         MOVE 1 TO WS-LIVE
         IF WS-PROBTXT(1:4) = "None"
             MOVE 100 TO WS-PROB
         ELSE
             COMPUTE WS-PROB ROUNDED = FUNCTION NUMVAL(WS-PROBTXT) * 1000
         END-IF
         STRING "acceptance US15 18§A Natural spawn data per biome: probability of " DELIMITED BY SIZE
             FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-PROB TO TL-EXPECTED-N
         MOVE SPB-PROB(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPB-FIRST(WS-ROW) TO WS-NEXT
     END-IF
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-COSTN.

*> The biome just read: the entries walked end where the table's list ends, and no entry differed.
 FINISH-BIOME.
     IF WS-LIVE = 1
         STRING "acceptance US15 18§A Natural spawn data per biome: entry count of " DELIMITED BY SIZE
             FUNCTION TRIM(SPB-NAME(WS-ROW)) DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = SPB-FIRST(WS-ROW) + SPB-COUNT(WS-ROW)
         MOVE WS-NEXT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STRING "acceptance US15 18§A Natural spawn data per biome: entries that differ in " DELIMITED BY SIZE
             FUNCTION TRIM(SPB-NAME(WS-ROW)) DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STRING "acceptance US15 18§A Natural spawn data per biome: cost count of " DELIMITED BY SIZE
             FUNCTION TRIM(SPB-NAME(WS-ROW)) DELIMITED BY SIZE INTO TL-CASE
         MOVE SPB-COST-COUNT(WS-ROW) TO TL-EXPECTED-N
         MOVE WS-COSTN TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF
     MOVE 0 TO WS-LIVE.

 ENTRY-LINE.
     MOVE SPACES TO WS-CAT-TXT
     MOVE SPACES TO WS-REST
     COMPUTE WS-T = WS-LEN - 1
     UNSTRING DOC-LINE(2:WS-T) DELIMITED BY ": " INTO WS-CAT-TXT WS-REST
     EVALUATE FUNCTION TRIM(WS-CAT-TXT)
         WHEN "monster"
             MOVE 1 TO WS-CAT
         WHEN "creature"
             MOVE 2 TO WS-CAT
         WHEN "ambient"
             MOVE 3 TO WS-CAT
         WHEN "axolotls"
             MOVE 4 TO WS-CAT
         WHEN "underground_water_creature"
             MOVE 5 TO WS-CAT
         WHEN "water_creature"
             MOVE 6 TO WS-CAT
         WHEN "water_ambient"
             MOVE 7 TO WS-CAT
         WHEN OTHER
             MOVE 0 TO WS-CAT
     END-EVALUATE
     COMPUTE WS-REST-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-REST TRAILING))
     MOVE 1 TO WS-P
     PERFORM UNTIL WS-P > WS-REST-LEN
         MOVE SPACES TO WS-ITEM
         UNSTRING WS-REST(1:WS-REST-LEN) DELIMITED BY ", " INTO WS-ITEM WITH POINTER WS-P
         MOVE SPACES TO WS-KEY
         MOVE SPACES TO WS-WTXT
         MOVE SPACES TO WS-NTXT
         UNSTRING WS-ITEM DELIMITED BY ":" INTO WS-KEY WS-WTXT WS-NTXT
         MOVE WS-WTXT(2:15) TO WS-NUM
         COMPUTE WS-W = FUNCTION NUMVAL(WS-NUM)
         MOVE WS-NTXT(2:15) TO WS-NRANGE
         MOVE SPACES TO WS-LO-TXT
         MOVE SPACES TO WS-HI-TXT
         UNSTRING WS-NRANGE DELIMITED BY "-" INTO WS-LO-TXT WS-HI-TXT
         COMPUTE WS-LO = FUNCTION NUMVAL(WS-LO-TXT)
         IF WS-HI-TXT = SPACES
             MOVE WS-LO TO WS-HI
         ELSE
             COMPUTE WS-HI = FUNCTION NUMVAL(WS-HI-TXT)
         END-IF
         ADD 1 TO WS-ENTRIES
         ADD 1 TO WS-NEXT
         IF WS-NEXT > SP-ENTRIES
             ADD 1 TO WS-BAD
         ELSE
             IF SPE-CAT(WS-NEXT) NOT = WS-CAT OR SPE-KEY(WS-NEXT) NOT = WS-KEY OR SPE-WEIGHT(WS-NEXT) NOT = WS-W
                 OR SPE-MIN(WS-NEXT) NOT = WS-LO OR SPE-MAX(WS-NEXT) NOT = WS-HI
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM.

 COSTS-LINE.
     MOVE 1 TO WS-P
     MOVE 0 TO WS-TN
     COMPUTE WS-T = WS-LEN
     PERFORM UNTIL WS-P > WS-LEN
         ADD 1 TO WS-TN
         MOVE SPACES TO WS-TOK(WS-TN)
         UNSTRING DOC-LINE(1:WS-LEN) DELIMITED BY '"' INTO WS-TOK(WS-TN) WITH POINTER WS-P
     END-PERFORM
     COMPUTE WS-G = (WS-TN - 1) / 6
     PERFORM VARYING WS-E FROM 0 BY 1 UNTIL WS-E >= WS-G
         ADD 1 TO WS-COSTS
         ADD 1 TO WS-COSTN
         ADD 1 TO WS-COST-IDX
         COMPUTE WS-T = 5 + 6 * WS-E
         MOVE WS-TOK(WS-T) TO WS-NUM
         INSPECT WS-NUM CONVERTING ":,}" TO "   "
         COMPUTE WS-CHARGE ROUNDED = FUNCTION NUMVAL(WS-NUM) * 1000
         COMPUTE WS-T = 7 + 6 * WS-E
         MOVE WS-TOK(WS-T) TO WS-NUM
         INSPECT WS-NUM CONVERTING ":,}" TO "   "
         COMPUTE WS-BUDGET ROUNDED = FUNCTION NUMVAL(WS-NUM) * 1000
         COMPUTE WS-T = 2 + 6 * WS-E
         IF WS-COST-IDX > SP-COSTS
             ADD 1 TO WS-BAD
         ELSE
             IF SPC-KEY(WS-COST-IDX) NOT = WS-TOK(WS-T) OR SPC-CHARGE(WS-COST-IDX) NOT = WS-CHARGE
                 OR SPC-BUDGET(WS-COST-IDX) NOT = WS-BUDGET
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-18-APPENDIX.
 COPY CORETEST.
