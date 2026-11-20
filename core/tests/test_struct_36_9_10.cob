*> Acceptance test of docs/protocol/36-structures-9-villages-outposts.md section 10 (points of interest while a village is generated, T1472) over the generated vanilla-data (CC_GENERATED_DIR, read
*> only; skipped as a pass without it). 10.3: the census of the blocks that make points of interest over all village templates (bell 39: plains 14, desert 6, savanna 10, snowy 6, taiga 3; bed heads
*> 134: plains 32, desert 24, savanna 24, snowy 28, taiga 26, both halves of a bed are blocks, so twice that; composter 18, barrel 18, loom 13, water cauldron 11, grindstone 11, smoker 9, brewing
*> stand 9, blast furnace 8, lectern 8, cartography table, fletching table, stonecutter and smithing table 6 each; no beehive, bee nest, lightning rod or lodestone). 10.2 and 10.1 as the core has
*> them (the POI index of core/src/mob-vil-index.cob, found by scanning chunks and noted when a block is set): every block of the census maps to its kind (bed 1, bell 2, job site 3); a point that
*> is added is unclaimed (10.1 item 4: after generation no ticket is taken).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-9-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY STRUCTTPL.
 COPY VILPOIX.
 COPY VILCENSW.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-TEXT                PIC X(160).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-BELLS.
    05 WS-BELL             BINARY-LONG OCCURS 5 TIMES.
 01 WS-BEDS.
    05 WS-BED              BINARY-LONG OCCURS 5 TIMES.
 01 WS-BLOCK-COUNTS.
    05 WS-BC               BINARY-LONG OCCURS 1400 TIMES.
 01 WS-KINDS.
    05 WS-KC               BINARY-LONG OCCURS 4 TIMES.
 01 WS-X                   BINARY-LONG VALUE 1.
 01 WS-Y                   BINARY-LONG VALUE 2.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-TICKETS             BINARY-LONG.
*>  the census blocks: key, wanted count, wanted kind (0 none)
 01 WS-CENSUS.
    05 FILLER              PIC X(32) VALUE "minecraft:composter".
    05 FILLER              PIC 9(5) VALUE 00183.
    05 FILLER              PIC X(32) VALUE "minecraft:barrel".
    05 FILLER              PIC 9(5) VALUE 00183.
    05 FILLER              PIC X(32) VALUE "minecraft:loom".
    05 FILLER              PIC 9(5) VALUE 00133.
    05 FILLER              PIC X(32) VALUE "minecraft:water_cauldron".
    05 FILLER              PIC 9(5) VALUE 00113.
    05 FILLER              PIC X(32) VALUE "minecraft:grindstone".
    05 FILLER              PIC 9(5) VALUE 00113.
    05 FILLER              PIC X(32) VALUE "minecraft:smoker".
    05 FILLER              PIC 9(5) VALUE 00093.
    05 FILLER              PIC X(32) VALUE "minecraft:brewing_stand".
    05 FILLER              PIC 9(5) VALUE 00093.
    05 FILLER              PIC X(32) VALUE "minecraft:blast_furnace".
    05 FILLER              PIC 9(5) VALUE 00083.
    05 FILLER              PIC X(32) VALUE "minecraft:lectern".
    05 FILLER              PIC 9(5) VALUE 00083.
    05 FILLER              PIC X(32) VALUE "minecraft:cartography_table".
    05 FILLER              PIC 9(5) VALUE 00063.
    05 FILLER              PIC X(32) VALUE "minecraft:fletching_table".
    05 FILLER              PIC 9(5) VALUE 00063.
    05 FILLER              PIC X(32) VALUE "minecraft:stonecutter".
    05 FILLER              PIC 9(5) VALUE 00063.
    05 FILLER              PIC X(32) VALUE "minecraft:smithing_table".
    05 FILLER              PIC 9(5) VALUE 00063.
    05 FILLER              PIC X(32) VALUE "minecraft:bell".
    05 FILLER              PIC 9(5) VALUE 00392.
    05 FILLER              PIC X(32) VALUE "minecraft:beehive".
    05 FILLER              PIC 9(5) VALUE 00000.
    05 FILLER              PIC X(32) VALUE "minecraft:bee_nest".
    05 FILLER              PIC 9(5) VALUE 00000.
    05 FILLER              PIC X(32) VALUE "minecraft:lightning_rod".
    05 FILLER              PIC 9(5) VALUE 00000.
    05 FILLER              PIC X(32) VALUE "minecraft:lodestone".
    05 FILLER              PIC 9(5) VALUE 00000.
 01 WS-CENSUS-TAB REDEFINES WS-CENSUS.
    05 WS-CE               OCCURS 18 TIMES.
       10 WS-CE-KEY        PIC X(32).
       10 WS-CE-COUNT      PIC 9(4).
       10 WS-CE-KIND       PIC 9.
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
         MOVE "acceptance US12 36-9§10 Points of interest while a village is generated: no generated packs here, skipped" TO TL-CASE
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
     MOVE SPACES TO VC-ROOT
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO VC-ROOT
     PERFORM VC-COLLECT
     CALL "PXI-INIT"
     INITIALIZE WS-BLOCK-COUNTS WS-BELLS WS-BEDS WS-KINDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VC-TPL-N
         MOVE VC-TPL(WS-I) TO WS-ID
         CALL "STRUCT-TPL-RESET"
         CALL "STRUCT-TPL-LOAD" USING VC-ROOT WS-ID WS-ROW
         IF WS-ROW > 0 AND TP-STATUS(WS-ROW) = 1 AND WS-ID(1:8) = "village/"
             PERFORM ONE-TEMPLATE
         END-IF
     END-PERFORM
*>   the census by key
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 18
         MOVE WS-CE-KEY(WS-T) TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
         COMPUTE WS-BLK = CB-S-BLOCK(WS-STATE + 1) + 1
         IF WS-BC(WS-BLK) NOT = WS-CE-COUNT(WS-T)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§10.3 Census of what the templates place: every census block is as often in the village templates as the table says" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
         MOVE WS-BELL(WS-T) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-9§10.3 Census of what the templates place: bells by variant plains 14, desert 6, savanna 10, snowy 6, taiga 3" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "14 6 10 6 3 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   beds: both halves are blocks: twice the heads, 32 24 24 28 26 heads
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
         COMPUTE WS-J = WS-BED(WS-T) / 2
         MOVE WS-J TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     END-PERFORM
     MOVE "acceptance US12 36-9§10.3 Census of what the templates place: bed heads by variant plains 32, desert 24, savanna 24, snowy 28, taiga 26 (134 in all)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "32 24 24 28 26 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   the kinds of the POI index: bed 1, bell 2, job site 3 and none for the others of the census (no beehive and so on)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 18
         MOVE WS-CE-KEY(WS-T) TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
         COMPUTE WS-BLK = CB-S-BLOCK(WS-STATE + 1) + 1
         EVALUATE TRUE
             WHEN WS-T = 14
                 IF PX-BKIND(WS-BLK) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN WS-T <= 13
                 IF PX-BKIND(WS-BLK) NOT = 3
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-9§10.2 POI types of the family: the 13 job-site blocks of the census are kind 3 and the bell is kind 2 in the POI index" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§10.3 Census of what the templates place: the bed blocks (every colour) are kind 1 and there are 268 of them (two halves of 134 beds)" TO TL-CASE
     MOVE WS-KC(1) TO TL-OBSERVED-N
     MOVE 268 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   10.1 item 4: a point that is added is unclaimed
     CALL "PXI-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-KIND
     CALL "PXI-TICKETS" USING WS-DIM WS-X WS-Y WS-Z WS-KIND WS-TICKETS
     MOVE "acceptance US12 36-9§10.1 The registration path: a newly added record is unclaimed (no ticket taken), so a fresh village is no village yet" TO TL-CASE
     MOVE WS-TICKETS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ONE-TEMPLATE.
     MOVE 0 TO WS-VARIANT
     EVALUATE TRUE
         WHEN WS-ID(1:15) = "village/plains/"
             MOVE 1 TO WS-VARIANT
         WHEN WS-ID(1:15) = "village/desert/"
             MOVE 2 TO WS-VARIANT
         WHEN WS-ID(1:16) = "village/savanna/"
             MOVE 3 TO WS-VARIANT
         WHEN WS-ID(1:14) = "village/snowy/"
             MOVE 4 TO WS-VARIANT
         WHEN WS-ID(1:14) = "village/taiga/"
             MOVE 5 TO WS-VARIANT
     END-EVALUATE
     COMPUTE WS-BASE = TP-BASE(WS-ROW, 1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-ROW)
         MOVE TB-STATE(WS-BASE + WS-J) TO WS-STATE
         COMPUTE WS-BLK = CB-S-BLOCK(WS-STATE + 1) + 1
         ADD 1 TO WS-BC(WS-BLK)
         IF PX-BKIND(WS-BLK) = 1
             ADD 1 TO WS-KC(1)
             IF WS-VARIANT > 0
                 ADD 1 TO WS-BED(WS-VARIANT)
             END-IF
         END-IF
         IF PX-BKIND(WS-BLK) = 2 AND WS-VARIANT > 0
             ADD 1 TO WS-BELL(WS-VARIANT)
         END-IF
     END-PERFORM.
 COPY VILCENSP.
 END PROGRAM TEST-STRUCT-36-9-10.
 COPY CORETEST.
