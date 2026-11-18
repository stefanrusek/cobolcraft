*> Real-data test (skipped as a pass without the generated packs; lane buglocate2 T32700): the cheap cell test of the /locate structure search (CXC-STRUCT-CELL-HIT: the entries' stubs only,
*> STRUCT-STUB-OK, no jigsaw assembly, no scattered pieces, no mansion layout) answers like the start list of the generation (STRUCT-CHUNK-STARTS, whose start holds a wanted structure of
*> the set) for every cell of the ring walk of 36-1 section 11 step 4, from the spot to the first ring in which the search answers (the rings the real command walks), on several seeds
*> (one beyond 2^53 and negative) and structure ids (a tag, the five village types, the single-entry scatter types, the mansion, the mineshaft, the ruined portals, the outpost, the igloo,
*> the shipwreck). A cell is looked at when STRUCT-IS-CHUNK holds for its potential chunk. The stub of every structure of the sets met is also compared with STRUCT-FIND-POINT followed by
*> STRUCT-VALID-AT (the validity test of the start list) on the chunks of the walk, and the stub-only mode must not leave the jigsaw start memo or the piece builder different
*> for the next full start: a village chunk made by STRUCT-FIND-POINT after the stub test has its pieces. The walk is the cost of the slow path, so the spots are chosen near the answers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOCATE-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-N                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-NUM-A               PIC -(9)9.
 01 WS-NUM-B               PIC -(9)9.
*> the runs: seed text, spot x, spot z, kind (1 a structure, 2 a tag), identifier
 01 WS-RUNS.
    05 FILLER PIC X(24) VALUE "424242".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:village".
    05 FILLER PIC X(24) VALUE "424242".
    05 FILLER PIC S9(6) VALUE 6000.
    05 FILLER PIC S9(6) VALUE -4800.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_desert".
    05 FILLER PIC X(24) VALUE "424242".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:desert_pyramid".
    05 FILLER PIC X(24) VALUE "424242".
    05 FILLER PIC S9(6) VALUE -2000.
    05 FILLER PIC S9(6) VALUE 4000.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:mansion".
    05 FILLER PIC X(24) VALUE "424242".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:igloo".
    05 FILLER PIC X(24) VALUE "12345".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:village".
    05 FILLER PIC X(24) VALUE "12345".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:village_plains".
    05 FILLER PIC X(24) VALUE "12345".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:swamp_hut".
    05 FILLER PIC X(24) VALUE "3".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:jungle_pyramid".
    05 FILLER PIC X(24) VALUE "3".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:mineshaft".
    05 FILLER PIC X(24) VALUE "77".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:ruined_portal".
    05 FILLER PIC X(24) VALUE "77".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:pillager_outpost".
    05 FILLER PIC X(24) VALUE "77".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:shipwreck".
    05 FILLER PIC X(24) VALUE "-4172144997902289642".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(40) VALUE "minecraft:village".
    05 FILLER PIC X(24) VALUE "-4172144997902289642".
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC S9(6) VALUE 0.
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(40) VALUE "minecraft:desert_pyramid".
 01 WS-RUNS-R REDEFINES WS-RUNS.
    05 WS-RUN OCCURS 15 TIMES.
       10 WS-R-SEED        PIC X(24).
       10 WS-R-X           PIC S9(6).
       10 WS-R-Z           PIC S9(6).
       10 WS-R-KIND        PIC X(1).
       10 WS-R-ID          PIC X(40).
 01 WS-RUN-N               BINARY-LONG.
 01 WS-LAST-SEED           PIC X(24).
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-NEGR                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-ANSWERED            BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-DIFFS               BINARY-LONG.
 01 WS-SET-WANTED.
    05 WS-SW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID-A             BINARY-LONG.
 01 WS-VALID-B             BINARY-LONG.
 01 WS-STUBS               BINARY-LONG.
 01 WS-STUB-DIFFS          BINARY-LONG.
 01 WS-FULL-PIECES         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ANS-X               BINARY-LONG.
 01 WS-ANS-Z               BINARY-LONG.
 01 WS-ANS-D2              BINARY-DOUBLE.
 01 WS-LAST-D2             BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-DESERT              BINARY-LONG.
 01 WS-OV-SET              BINARY-LONG.
 01 WS-SAVE-FIRST          BINARY-LONG.
 01 WS-SAVE-COUNT          BINARY-LONG.
 01 WS-PREEMPT             BINARY-LONG.
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
         MOVE "acceptance US13 /locate cell test equals the start list: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-LAST-SEED
     PERFORM VARYING WS-RUN-N FROM 1 BY 1 UNTIL WS-RUN-N > 15
         IF WS-R-SEED(WS-RUN-N) NOT = WS-LAST-SEED
             MOVE WS-R-SEED(WS-RUN-N) TO WS-LAST-SEED
             CALL "TEST-SETTINGS" USING CORE-SETTINGS
             MOVE "standard" TO CS-WORLD-TYPE
             MOVE WS-DIR TO CS-GENERATED-DIR
             MOVE 2 TO CS-VIEW-DISTANCE
             MOVE WS-R-SEED(WS-RUN-N) TO CS-SEED-TEXT
             MOVE 0 TO CS-HOSTILE-MOBS
             CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
         END-IF
         PERFORM CHECK-RUN
     END-PERFORM
     PERFORM CHECK-MEMO
     PERFORM CHECK-OVERLAP
     STOP RUN.

*> The run WS-RUN-N: the ring walk from the spot, every cell of every set that holds a wanted structure, the new test against the start list.
 CHECK-RUN.
     IF WS-R-KIND(WS-RUN-N) = "2"
         MOVE 2 TO WS-KIND
     ELSE
         MOVE 1 TO WS-KIND
     END-IF
     MOVE SPACES TO WS-ID
     MOVE WS-R-ID(WS-RUN-N) TO WS-ID
     MOVE WS-R-X(WS-RUN-N) TO WS-SX
     MOVE WS-R-Z(WS-RUN-N) TO WS-SZ
     COMPUTE WS-OX = FUNCTION INTEGER(WS-SX / 16)
     COMPUTE WS-OZ = FUNCTION INTEGER(WS-SZ / 16)
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO WS-SW(WS-S)
         IF SS-KIND(WS-S) = 2
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
                 MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
                 CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID WS-ST WS-WANT
                 IF WS-WANT = 1
                     MOVE 1 TO WS-SW(WS-S)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-ANSWERED WS-CELLS WS-HITS WS-DIFFS WS-STUBS WS-STUB-DIFFS
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 100 OR WS-ANSWERED = 1
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
             IF WS-SW(WS-S) = 1
                 PERFORM WALK-RING
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-SX TO WS-NUM-A
     MOVE WS-SZ TO WS-NUM-B
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate cells seed " FUNCTION TRIM(WS-R-SEED(WS-RUN-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
         FUNCTION TRIM(WS-ID) " the cell test equals the start list in every cell" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate cells seed " FUNCTION TRIM(WS-R-SEED(WS-RUN-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
         FUNCTION TRIM(WS-ID) " the stubs equal find point and valid at" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STUB-DIFFS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the walk ended in a ring that answered (a hit in at least one cell): the test looked at a real answer
     MOVE SPACES TO WS-CASE
     STRING "acceptance US13 /locate cells seed " FUNCTION TRIM(WS-R-SEED(WS-RUN-N)) " from (" FUNCTION TRIM(WS-NUM-A) "," FUNCTION TRIM(WS-NUM-B) ") "
         FUNCTION TRIM(WS-ID) " the walk reaches an answer" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWERED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ring WS-R of the set WS-S: every border cell whose potential chunk is a structure chunk: the cell test (new) and the start list (old) must agree; the stubs of every structure of the set
*> are compared too. A cell where the old test hits answers the ring (the walk stops after the ring).
 WALK-RING.
     COMPUTE WS-NEGR = 0 - WS-R
     PERFORM VARYING WS-IX FROM WS-NEGR BY 1 UNTIL WS-IX > WS-R
         PERFORM VARYING WS-IZ FROM WS-NEGR BY 1 UNTIL WS-IZ > WS-R
             IF FUNCTION ABS(WS-IX) = WS-R OR FUNCTION ABS(WS-IZ) = WS-R
                 COMPUTE WS-CX = WS-OX + SS-SPACING(WS-S) * WS-IX
                 COMPUTE WS-CZ = WS-OZ + SS-SPACING(WS-S) * WS-IZ
                 CALL "STRUCT-POTENTIAL" USING WS-S CW-SEED WS-CX WS-CZ WS-PX WS-PZ
                 CALL "STRUCT-IS-CHUNK" USING WS-S CW-SEED WS-PX WS-PZ WS-FLAG
                 IF WS-FLAG = 1
                     PERFORM CELL-OLD
                     CALL "CXC-STRUCT-CELL-HIT" USING WS-S WS-KIND WS-ID CW-SEED WS-PX WS-PZ WS-NEW
                     ADD 1 TO WS-CELLS
                     IF WS-OLD NOT = WS-NEW
                         ADD 1 TO WS-DIFFS
                     END-IF
                     IF WS-OLD = 1
                         ADD 1 TO WS-HITS
                         MOVE 1 TO WS-ANSWERED
                     END-IF
                     PERFORM CELL-STUBS
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.

*> WS-OLD: 1 when the start list of the chunk has a start of the set WS-S that is a wanted structure (the slow path the search used before).
 CELL-OLD.
     MOVE 0 TO WS-OLD
     CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-PX WS-PZ WS-COUNT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
         IF SC-SET(WS-J) = WS-S
             CALL "CXC-STRUCT-WANT" USING WS-KIND WS-ID SC-STRUCT(WS-J) WS-WANT
             IF WS-WANT = 1
                 MOVE 1 TO WS-OLD
             END-IF
         END-IF
     END-PERFORM.

*> The stub test of every structure of the set WS-S in the chunk against the generation point and the biome at its stub.
 CELL-STUBS.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
         MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
         CALL "STRUCT-FIND-POINT" USING WS-ST CW-SEED WS-PX WS-PZ WS-X WS-Y WS-Z WS-VALID-A
         IF WS-VALID-A = 1
             CALL "STRUCT-VALID-AT" USING WS-ST WS-X WS-Y WS-Z WS-VALID-A
         END-IF
         CALL "STRUCT-STUB-OK" USING WS-ST CW-SEED WS-PX WS-PZ WS-VALID-B
         ADD 1 TO WS-STUBS
         IF WS-VALID-A NOT = WS-VALID-B
             ADD 1 TO WS-STUB-DIFFS
         END-IF
     END-PERFORM.

*> The stub-only mode leaves nothing behind: SD-STUB-ONLY is 0 after every stub test, and a village made by the full find point after the stub tests has its pieces (the jigsaw start memo is
*> not filled by a stub). The structure is the first village type of the loaded data; its chunk is the one the village tag answers from the spawn of the last world.
 CHECK-MEMO.
     MOVE "SD-STUB-ONLY is 0 after the stub tests" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SD-STUB-ONLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FULL-PIECES
     MOVE CW-SEED TO WS-SEED
     MOVE 0 TO WS-LAST-D2
     MOVE 2 TO WS-KIND
     MOVE SPACES TO WS-ID
     MOVE "minecraft:village" TO WS-ID
     MOVE 8 TO WS-SX
     MOVE 8 TO WS-SZ
     CALL "CXC-STRUCT-NEAREST" USING WS-KIND WS-ID WS-SX WS-SZ CW-SEED WS-FOUND WS-ANS-X WS-ANS-Z WS-ANS-D2
     IF WS-FOUND = 1
         COMPUTE WS-PX = FUNCTION INTEGER(WS-ANS-X / 16)
         COMPUTE WS-PZ = FUNCTION INTEGER(WS-ANS-Z / 16)
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
             IF SS-KIND(WS-S) = 2 AND WS-FULL-PIECES = 0
                 PERFORM MEMO-SET
             END-IF
         END-PERFORM
     END-IF
     MOVE "a village made in full after stub tests has pieces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FULL-PIECES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The structures of the set WS-S that are villages: the stub test, then the full find point in the chunks around the answer; a valid full start has SP-COUNT pieces.
 MEMO-SET.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
         MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
         IF SDT-KEY(WS-ST)(1:18) = "minecraft:village_"
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
                 COMPUTE WS-CX = WS-PX - WS-J
                 CALL "STRUCT-STUB-OK" USING WS-ST CW-SEED WS-CX WS-PZ WS-VALID-B
                 CALL "STRUCT-FIND-POINT" USING WS-ST CW-SEED WS-CX WS-PZ WS-X WS-Y WS-Z WS-VALID-A
                 IF WS-VALID-A = 1 AND SP-COUNT > 0
                     ADD SP-COUNT TO WS-FULL-PIECES
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM.

*> Entries whose biomes overlap, which the data of the game has none of (the village types have a biome each): the desert village is given the biomes of the plains village, so in a plains chunk
*> both are valid and the chooser's order decides which is the set's start. The cell test must agree with the start list in every cell of the first rings (a plains village that comes first
*> preempts the desert village; the other way round the desert village is the start), whatever the order; the biomes are put back afterwards.
 CHECK-OVERLAP.
     MOVE 0 TO WS-PLAINS WS-DESERT WS-OV-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
             MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
             IF SDT-KEY(WS-ST) = "minecraft:village_plains"
                 MOVE WS-ST TO WS-PLAINS
                 MOVE WS-S TO WS-OV-SET
             END-IF
             IF SDT-KEY(WS-ST) = "minecraft:village_desert"
                 MOVE WS-ST TO WS-DESERT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE SDT-BIOME-FIRST(WS-DESERT) TO WS-SAVE-FIRST
     MOVE SDT-BIOME-COUNT(WS-DESERT) TO WS-SAVE-COUNT
     MOVE SDT-BIOME-FIRST(WS-PLAINS) TO SDT-BIOME-FIRST(WS-DESERT)
     MOVE SDT-BIOME-COUNT(WS-PLAINS) TO SDT-BIOME-COUNT(WS-DESERT)
     ADD 1 TO SD-EPOCH
     MOVE 1 TO WS-KIND
     MOVE SPACES TO WS-ID
     MOVE "minecraft:village_desert" TO WS-ID
     MOVE 0 TO WS-OX WS-OZ WS-CELLS WS-HITS WS-DIFFS WS-PREEMPT
     MOVE WS-OV-SET TO WS-S
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 6
         PERFORM OVERLAP-RING
     END-PERFORM
     MOVE SPACES TO WS-CASE
     MOVE "overlapping entry biomes: the cell test equals the start list in every cell" TO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "overlapping entry biomes: a desert village starts in some cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "overlapping entry biomes: a plains village preempts it in some cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PREEMPT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVE-FIRST TO SDT-BIOME-FIRST(WS-DESERT)
     MOVE WS-SAVE-COUNT TO SDT-BIOME-COUNT(WS-DESERT)
     ADD 1 TO SD-EPOCH.

 OVERLAP-RING.
     COMPUTE WS-NEGR = 0 - WS-R
     PERFORM VARYING WS-IX FROM WS-NEGR BY 1 UNTIL WS-IX > WS-R
         PERFORM VARYING WS-IZ FROM WS-NEGR BY 1 UNTIL WS-IZ > WS-R
             IF FUNCTION ABS(WS-IX) = WS-R OR FUNCTION ABS(WS-IZ) = WS-R
                 COMPUTE WS-CX = WS-OX + SS-SPACING(WS-S) * WS-IX
                 COMPUTE WS-CZ = WS-OZ + SS-SPACING(WS-S) * WS-IZ
                 CALL "STRUCT-POTENTIAL" USING WS-S CW-SEED WS-CX WS-CZ WS-PX WS-PZ
                 CALL "STRUCT-IS-CHUNK" USING WS-S CW-SEED WS-PX WS-PZ WS-FLAG
                 IF WS-FLAG = 1
                     PERFORM CELL-OLD
                     CALL "CXC-STRUCT-CELL-HIT" USING WS-S WS-KIND WS-ID CW-SEED WS-PX WS-PZ WS-NEW
                     ADD 1 TO WS-CELLS
                     IF WS-OLD NOT = WS-NEW
                         ADD 1 TO WS-DIFFS
                     END-IF
                     ADD WS-OLD TO WS-HITS
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                         IF SC-SET(WS-J) = WS-S AND SC-STRUCT(WS-J) = WS-PLAINS
                             ADD 1 TO WS-PREEMPT
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-CMD-LOCATE-EQUIV.

 COPY NOSPAWN.
 COPY CORETEST.
