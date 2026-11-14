*> Real-data probe of STRUCT-BASE-HEIGHT (skipped as a pass without the generated packs; core/src/struct-height.cob): on the generated vanilla-data (CC_GENERATED_DIR, read only)
*> the heights of the columns of 12 chunks are compared with the heightmaps WORLD_SURFACE_WG and OCEAN_FLOOR_WG that the terrain fill of the same chunk records (the job is
*> stepped to the end of the fill; the fill has the real aquifer, the query the global fluid picker alone, so a surface differs where the aquifer leaves air or another fluid
*> level above stone below sea level). The mismatch counts and the cost of the query (a cold chunk of 256 columns, then warm) are printed as evidence; the floor must agree on
*> every column (the density alone decides stone), the surface on 99 percent of them or better.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-HEIGHT-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENSTEPS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==W-==.
 01 WS-N                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD-SURFACE         BINARY-LONG VALUE 0.
 01 WS-BAD-FLOOR           BINARY-LONG VALUE 0.
 01 WS-TOTAL               BINARY-LONG VALUE 0.
 01 WS-MAXDIFF             BINARY-LONG VALUE 0.
 01 WS-DIFF                BINARY-LONG.
 01 WS-KIND-0              BINARY-LONG VALUE 0.
 01 WS-KIND-1              BINARY-LONG VALUE 1.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-QUERY-MS            BINARY-LONG VALUE 0.
 01 WS-FILL-MS             BINARY-LONG VALUE 0.
 01 WS-COLD-MS            BINARY-LONG.
 01 WS-WARM-MS            BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
 01 WS-CHUNKS.
    05 WS-CHUNK-X          BINARY-LONG OCCURS 12 TIMES.
    05 WS-CHUNK-Z          BINARY-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct height real no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "GEN-QUEUE-RESET"
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 12
         COMPUTE WS-CHUNK-X(WS-N) = FUNCTION MOD(WS-N * 37, 23) - 11
         COMPUTE WS-CHUNK-Z(WS-N) = FUNCTION MOD(WS-N * 53, 29) - 14
     END-PERFORM
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 12
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         MOVE WS-T0 TO WS-T1
         CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CHUNK-X(WS-N) WS-CHUNK-Z(WS-N)
         PERFORM UNTIL W-STAGE > GJ-STAGE-FILL
             CALL "GEN-JOB-STEP" USING WS-JOB
         END-PERFORM
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         COMPUTE WS-DIFF = WS-T0 - WS-T1
         ADD WS-DIFF TO WS-FILL-MS
         MOVE WS-T0 TO WS-T1
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                 COMPUTE WS-X = WS-CHUNK-X(WS-N) * 16 + WS-LX
                 COMPUTE WS-Z = WS-CHUNK-Z(WS-N) * 16 + WS-LZ
                 COMPUTE WS-COL = WS-LZ * 16 + WS-LX + 1
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-0 WS-H
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-1 WS-H2
                 ADD 1 TO WS-TOTAL
                 COMPUTE WS-WANT = W-HM-SURFACE(WS-COL) + 1
                 IF WS-H NOT = WS-WANT
                     ADD 1 TO WS-BAD-SURFACE
                     COMPUTE WS-DIFF = FUNCTION ABS(WS-H - WS-WANT)
                     IF WS-DIFF > WS-MAXDIFF
                         MOVE WS-DIFF TO WS-MAXDIFF
                     END-IF
                 END-IF
                 COMPUTE WS-WANT = W-HM-OCEAN(WS-COL) + 1
                 IF WS-H2 NOT = WS-WANT
                     ADD 1 TO WS-BAD-FLOOR
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         COMPUTE WS-DIFF = WS-T0 - WS-T1
         ADD WS-DIFF TO WS-QUERY-MS
         CALL "GEN-JOB-FREE" USING WS-JOB
     END-PERFORM
*>   the cost of single cold queries (what a structure start pays): one column of each of 12 chunks no query has touched, both kinds, then the same column again
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 12
         COMPUTE WS-X = (WS-CHUNK-X(WS-N) + 300) * 16 + 7
         COMPUTE WS-Z = (WS-CHUNK-Z(WS-N) + 300) * 16 + 9
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-0 WS-H
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-1 WS-H2
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-COLD-MS = WS-T0 - WS-T1
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 12
         COMPUTE WS-X = (WS-CHUNK-X(WS-N) + 300) * 16 + 7
         COMPUTE WS-Z = (WS-CHUNK-Z(WS-N) + 300) * 16 + 9
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-0 WS-H
         CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND-1 WS-H2
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-WARM-MS = WS-T0 - WS-T1
     MOVE WS-COLD-MS TO WS-EDIT
     MOVE WS-WARM-MS TO WS-EDIT2
     DISPLAY "PROBE 12 cold single columns (2 queries each) " FUNCTION TRIM(WS-EDIT) " ms, the same again (warm corners) " FUNCTION TRIM(WS-EDIT2) " ms"
     MOVE WS-TOTAL TO WS-EDIT
     DISPLAY "PROBE columns compared: " FUNCTION TRIM(WS-EDIT)
     MOVE WS-BAD-SURFACE TO WS-EDIT
     MOVE WS-MAXDIFF TO WS-EDIT2
     DISPLAY "PROBE WORLD_SURFACE_WG mismatches: " FUNCTION TRIM(WS-EDIT) " (largest difference " FUNCTION TRIM(WS-EDIT2) ")"
     MOVE WS-BAD-FLOOR TO WS-EDIT
     DISPLAY "PROBE OCEAN_FLOOR_WG mismatches: " FUNCTION TRIM(WS-EDIT)
     MOVE WS-FILL-MS TO WS-EDIT
     MOVE WS-QUERY-MS TO WS-EDIT2
     DISPLAY "PROBE 12 chunks: terrain to the end of the fill " FUNCTION TRIM(WS-EDIT) " ms; 2 queries for each of their 3072 columns " FUNCTION TRIM(WS-EDIT2) " ms"
     MOVE "test struct height real given 12 chunks when OCEAN_FLOOR_WG is asked then it equals the fill's heightmap + 1 on every column" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FLOOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-LIMIT = WS-TOTAL / 100
     MOVE "test struct height real given 12 chunks when WORLD_SURFACE_WG is asked then at least 99 percent of the columns agree" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BAD-SURFACE <= WS-LIMIT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-HEIGHT-REAL.

 COPY CORETEST.
