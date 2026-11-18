*> Real-data test (skipped as a pass without the generated packs; T1316, docs/protocol/36-structures-1-model-placement-starts.md section 11, step 4): the locate search of a random_spread placement. A standard world of
*> seed 3 is opened and the swamp hut (gated on) is searched for from six origins by CXC-STRUCT-NEAREST (core/src/cmd-locate.cob). The model walks the rings r = 0, 1, 2, ... of the document: for ix from -r to r (outer) and
*> iz from -r to r (inner), only the cells on the border of the square, the candidate chunk is the potential chunk of cell (ox + spacing * ix, oz + spacing * iz) from the origin's chunk, and the FIRST candidate in that
*> order that is a structure chunk holding a hut start is the answer of the ring (later cells of the ring are not compared, even when nearer); the model answer is its locate position. The answer of the search must be
*> that one, so its ring is the first ring with a candidate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID                  PIC X(80) VALUE "minecraft:swamp_hut".
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-HUT                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MFOUND              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-N                   BINARY-LONG.
 01 WS-NEGR                BINARY-LONG.
 01 WS-ORIGINS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1000.
    05 FILLER BINARY-LONG VALUE -500.
    05 FILLER BINARY-LONG VALUE -3000.
    05 FILLER BINARY-LONG VALUE 2500.
    05 FILLER BINARY-LONG VALUE 7001.
    05 FILLER BINARY-LONG VALUE 7003.
    05 FILLER BINARY-LONG VALUE -20000.
    05 FILLER BINARY-LONG VALUE -15000.
    05 FILLER BINARY-LONG VALUE 123.
    05 FILLER BINARY-LONG VALUE -4567.
 01 WS-OR REDEFINES WS-ORIGINS.
    05 WS-ORIGIN OCCURS 6 TIMES.
       10 WS-OX0           BINARY-LONG.
       10 WS-OZ0           BINARY-LONG.
 01 WS-CASE                PIC X(160).
 01 WS-NUM                 PIC -(7)9.
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
         MOVE "acceptance US12 36-1§11 Locate: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "3" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
*>   the hut's structure row and its set (a random_spread set that lists it)
     MOVE 0 TO WS-HUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:swamp_hut"
             MOVE WS-I TO WS-HUT
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-I)
             IF SE-STRUCT(SS-EN-FIRST(WS-I) + WS-K) = WS-HUT
                 MOVE WS-I TO WS-SET
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-1§11 Locate: the swamp hut is in a random_spread set of the data (kind 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SS-KIND(WS-SET) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6
         MOVE WS-OX0(WS-N) TO WS-SX
         MOVE WS-OZ0(WS-N) TO WS-SZ
         PERFORM MODEL-SEARCH
         CALL "CXC-STRUCT-NEAREST" USING WS-KIND WS-ID WS-SX WS-SZ WS-SEED WS-FOUND WS-FX WS-FZ WS-D2
         MOVE WS-SX TO WS-NUM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US12 36-1§11 Locate: from x " WS-NUM " the first candidate in ring order is the answer"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE WS-MFOUND TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-CASE
         MOVE WS-SZ TO WS-NUM
         STRING "acceptance US12 36-1§11 Locate: from z " WS-NUM " the locate position equals the model's"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-MX * 100003 + WS-MZ
         COMPUTE TL-OBSERVED-N = WS-FX * 100003 + WS-FZ
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*> MODEL-SEARCH: the rings of step 4 for the one set, from the chunk of (WS-SX, WS-SZ): WS-MFOUND, WS-MX, WS-MZ the locate position of the first candidate of the first ring that has one
 MODEL-SEARCH.
     MOVE 0 TO WS-MFOUND WS-MX WS-MZ
     COMPUTE WS-OX = FUNCTION INTEGER(WS-SX / 16)
     COMPUTE WS-OZ = FUNCTION INTEGER(WS-SZ / 16)
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 100 OR WS-DONE = 1
         COMPUTE WS-NEGR = 0 - WS-R
         PERFORM VARYING WS-IX FROM WS-NEGR BY 1 UNTIL WS-IX > WS-R OR WS-DONE = 1
             PERFORM VARYING WS-IZ FROM WS-NEGR BY 1 UNTIL WS-IZ > WS-R OR WS-DONE = 1
                 IF FUNCTION ABS(WS-IX) = WS-R OR FUNCTION ABS(WS-IZ) = WS-R
                     COMPUTE WS-CX = WS-OX + SS-SPACING(WS-SET) * WS-IX
                     COMPUTE WS-CZ = WS-OZ + SS-SPACING(WS-SET) * WS-IZ
                     CALL "STRUCT-POTENTIAL" USING WS-SET WS-SEED WS-CX WS-CZ WS-PX WS-PZ
                     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-PX WS-PZ WS-FLAG
                     MOVE 0 TO WS-HIT
                     IF WS-FLAG = 1
                         CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-PX WS-PZ WS-COUNT
                         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-COUNT
                             IF SC-STRUCT(WS-S) = WS-HUT
                                 MOVE 1 TO WS-HIT
                             END-IF
                         END-PERFORM
                     END-IF
                     IF WS-HIT = 1
                         CALL "STRUCT-LOCATE-POS" USING WS-SET WS-PX WS-PZ WS-MX WS-MY WS-MZ
                         MOVE 1 TO WS-MFOUND
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 END PROGRAM TEST-STRUCT-36-1-11.
 COPY CORETEST.
