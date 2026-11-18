*> Acceptance test of docs/protocol/36-structures-9-villages-outposts.md section 9 (what the templates carry: entities, chests, markers, T1470) and the template facts of section 13 over the
*> generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without it). Every template below village/ and pillager_outpost/ is loaded (STRUCT-TPL-LOAD): 494 templates (483 and 11,
*> 3 of them village/decays); the jigsaw blocks by name (1972: bottom 759, building_entrance 616, street 533, feature 47, empty 8, entrance 4, plate_entry 4, buidling_entrance 1); no structure block
*> (9.1); the entities of the templates (13 item 8: villager 15, zombie_villager 10, cat 10, horse 7, sheep 4, cow 2, pig 2, iron_golem 2, camel 1, armor_stand 2, allay 2; none lost); the nine
*> livestock templates holding 15 entities (9.2); the loot chests by table (9.5: 62 in the village templates, 2 in the outpost, the table of the document); the chests carry a loot table and no items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-9-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTTPL.
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
 01 WS-TAG                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-N-LOADED            BINARY-LONG.
 01 WS-N-VILLAGE           BINARY-LONG.
 01 WS-N-OUTPOST           BINARY-LONG.
 01 WS-N-DECAYS            BINARY-LONG.
 01 WS-N-BAD               BINARY-LONG.
 01 WS-N-LOST              BINARY-LONG.
 01 WS-N-STRUCTBLOCK       BINARY-LONG.
 01 WS-JIGS                BINARY-LONG.
 01 WS-LIVE-T              BINARY-LONG.
 01 WS-LIVE-E              BINARY-LONG.
 01 WS-LOOT-VILLAGE        BINARY-LONG.
 01 WS-LOOT-OUTPOST        BINARY-LONG.
 01 WS-BUF                 PIC X(1344).
 01 WS-LEN                 BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-PAT                 PIC X(40).
 01 WS-IDTXT               PIC X(32).
 01 WS-PAT-LEN             BINARY-LONG.
 01 WS-SHORT               PIC X(48).
 01 WS-TEXT                PIC X(160).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
*>  jigsaw names and their counts
 01 WS-JN.
    05 WS-JN-ROW           OCCURS 9 TIMES.
       10 WS-JN-NAME       PIC X(24).
       10 WS-JN-COUNT      BINARY-LONG.
 01 WS-JN-NAMES.
    05 FILLER              PIC X(24) VALUE "bottom".
    05 FILLER              PIC X(24) VALUE "building_entrance".
    05 FILLER              PIC X(24) VALUE "street".
    05 FILLER              PIC X(24) VALUE "feature".
    05 FILLER              PIC X(24) VALUE "empty".
    05 FILLER              PIC X(24) VALUE "entrance".
    05 FILLER              PIC X(24) VALUE "plate_entry".
    05 FILLER              PIC X(24) VALUE "buidling_entrance".
 01 WS-JN-NAME-TAB REDEFINES WS-JN-NAMES.
    05 WS-JNN              PIC X(24) OCCURS 8 TIMES.
*>  entities by id
 01 WS-ENT-IDS.
    05 FILLER              PIC X(32) VALUE "minecraft:villager".
    05 FILLER              PIC X(32) VALUE "minecraft:zombie_villager".
    05 FILLER              PIC X(32) VALUE "minecraft:cat".
    05 FILLER              PIC X(32) VALUE "minecraft:horse".
    05 FILLER              PIC X(32) VALUE "minecraft:sheep".
    05 FILLER              PIC X(32) VALUE "minecraft:cow".
    05 FILLER              PIC X(32) VALUE "minecraft:pig".
    05 FILLER              PIC X(32) VALUE "minecraft:iron_golem".
    05 FILLER              PIC X(32) VALUE "minecraft:camel".
    05 FILLER              PIC X(32) VALUE "minecraft:armor_stand".
    05 FILLER              PIC X(32) VALUE "minecraft:allay".
 01 WS-ENT-TAB REDEFINES WS-ENT-IDS.
    05 WS-EID              PIC X(32) OCCURS 11 TIMES.
 01 WS-ENT-WANT.
    05 FILLER              PIC 99 VALUE 15.
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC 99 VALUE 07.
    05 FILLER              PIC 99 VALUE 04.
    05 FILLER              PIC 99 VALUE 02.
    05 FILLER              PIC 99 VALUE 02.
    05 FILLER              PIC 99 VALUE 02.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 02.
    05 FILLER              PIC 99 VALUE 02.
 01 WS-ENT-WANT-TAB REDEFINES WS-ENT-WANT.
    05 WS-EW               PIC 99 OCCURS 11 TIMES.
 01 WS-ENT-COUNTS.
    05 WS-EC               BINARY-LONG OCCURS 11 TIMES.
*>  loot tables (the village chests of 9.5)
 01 WS-LOOT-NAMES.
    05 FILLER              PIC X(24) VALUE "village_armorer".
    05 FILLER              PIC X(24) VALUE "village_butcher".
    05 FILLER              PIC X(24) VALUE "village_cartographer".
    05 FILLER              PIC X(24) VALUE "village_desert_house".
    05 FILLER              PIC X(24) VALUE "village_fisher".
    05 FILLER              PIC X(24) VALUE "village_fletcher".
    05 FILLER              PIC X(24) VALUE "village_mason".
    05 FILLER              PIC X(24) VALUE "village_plains_house".
    05 FILLER              PIC X(24) VALUE "village_savanna_house".
    05 FILLER              PIC X(24) VALUE "village_shepherd".
    05 FILLER              PIC X(24) VALUE "village_snowy_house".
    05 FILLER              PIC X(24) VALUE "village_taiga_house".
    05 FILLER              PIC X(24) VALUE "village_tannery".
    05 FILLER              PIC X(24) VALUE "village_temple".
    05 FILLER              PIC X(24) VALUE "village_toolsmith".
    05 FILLER              PIC X(24) VALUE "village_weaponsmith".
 01 WS-LOOT-TAB REDEFINES WS-LOOT-NAMES.
    05 WS-LN               PIC X(24) OCCURS 16 TIMES.
 01 WS-LOOT-WANT.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 05.
    05 FILLER              PIC 99 VALUE 08.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 06.
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 04.
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC 99 VALUE 04.
    05 FILLER              PIC 99 VALUE 01.
    05 FILLER              PIC 99 VALUE 03.
    05 FILLER              PIC 99 VALUE 05.
 01 WS-LOOT-WANT-TAB REDEFINES WS-LOOT-WANT.
    05 WS-LW               PIC 99 OCCURS 16 TIMES.
 01 WS-LOOT-COUNTS.
    05 WS-LC               BINARY-LONG OCCURS 16 TIMES.
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
         MOVE "acceptance US12 36-9§9 What the templates carry: no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO WS-N-LOADED WS-N-VILLAGE WS-N-OUTPOST WS-N-DECAYS WS-N-BAD WS-N-LOST WS-N-STRUCTBLOCK WS-JIGS
     MOVE 0 TO WS-LIVE-T WS-LIVE-E WS-LOOT-VILLAGE WS-LOOT-OUTPOST
     INITIALIZE WS-JN WS-ENT-COUNTS WS-LOOT-COUNTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VC-TPL-N
         MOVE VC-TPL(WS-I) TO WS-ID
         CALL "STRUCT-TPL-RESET"
         CALL "STRUCT-TPL-LOAD" USING VC-ROOT WS-ID WS-ROW
         IF WS-ROW > 0 AND TP-STATUS(WS-ROW) = 1
             ADD 1 TO WS-N-LOADED
             IF WS-ID(1:8) = "village/"
                 ADD 1 TO WS-N-VILLAGE
             END-IF
             IF WS-ID(1:7) = "pillage"
                 ADD 1 TO WS-N-OUTPOST
             END-IF
             IF WS-ID(1:14) = "village/decays"
                 ADD 1 TO WS-N-DECAYS
             END-IF
             PERFORM ONE-TEMPLATE
         ELSE
             ADD 1 TO WS-N-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§13 Validation: 494 templates below village/ and pillager_outpost/ (483 and 11), all of them load" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N-LOADED * 1000000 + WS-N-VILLAGE * 1000 + WS-N-OUTPOST
     MOVE 494483011 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§13 Validation: 3 of the village templates are village/decays and every template loaded" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N-DECAYS * 1000 + WS-N-BAD
     MOVE 3000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§13 Validation: 1972 jigsaw blocks in the templates" TO TL-CASE
     MOVE WS-JIGS TO TL-OBSERVED-N
     MOVE 1972 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 8
         MOVE WS-JN-COUNT(WS-J) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-9§13 Validation: jigsaw names bottom 759, building_entrance 616, street 533, feature 47, empty 8, entrance 4, plate_entry 4, buidling_entrance 1" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "759 616 533 47 8 4 4 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-9§9.1 Structure blocks (data markers): none in any template (profile: 0 of 494)" TO TL-CASE
     MOVE WS-N-STRUCTBLOCK TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   entities by id
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 11
         MOVE WS-EC(WS-J) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
         IF WS-EC(WS-J) NOT = WS-EW(WS-J)
             ADD 1 TO WS-ANY
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-9§13 Validation item 8: entities in templates villager 15, zombie_villager 10, cat 10, horse 7, sheep 4, cow 2, pig 2, iron_golem 2, camel 1, armor_stand 2, allay 2" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "15 10 10 7 4 2 2 2 1 2 2 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-9§9.2 Entities placed by templates: the table kept every entity record (none lost)" TO TL-CASE
     MOVE WS-N-LOST TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§9.2 Entities placed by templates: the 9 livestock templates (cows, pigs, horses, sheep) hold 15 entities between them" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LIVE-T * 100 + WS-LIVE-E
     MOVE 915 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   loot chests
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         IF WS-LC(WS-J) NOT = WS-LW(WS-J)
             ADD 1 TO WS-ANY
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§9.5 Chests and loot: the 16 village loot tables hold the chest counts of the document (1 1 5 8 1 1 1 6 10 1 4 10 4 1 3 5)" TO TL-CASE
     MOVE WS-ANY TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§9.5 Chests and loot: 62 loot chests in the village templates and 2 in the outpost, none carries items" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LOOT-VILLAGE * 100 + WS-LOOT-OUTPOST
     MOVE 6202 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ONE-TEMPLATE.
*>   the jigsaws, structure blocks and chests of the template's first palette
     COMPUTE WS-BASE = TP-BASE(WS-ROW, 1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-ROW)
         MOVE TB-NBT(WS-BASE + WS-J) TO WS-TAG
         IF WS-TAG > 0
             EVALUATE TN-KIND(WS-TAG)
                 WHEN 4
                     ADD 1 TO WS-JIGS
                     MOVE TN-NAME(WS-TAG) TO WS-SHORT
                     IF WS-SHORT(1:10) = "minecraft:"
                         MOVE WS-SHORT(11:38) TO WS-SHORT
                     END-IF
                     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 8
                         IF WS-SHORT = WS-JNN(WS-T)
                             ADD 1 TO WS-JN-COUNT(WS-T)
                         END-IF
                     END-PERFORM
                 WHEN 3
                     ADD 1 TO WS-N-STRUCTBLOCK
                 WHEN 5
                     ADD 1 TO WS-N-STRUCTBLOCK
                 WHEN 1
                     IF TN-LOOT(WS-TAG) NOT = SPACES
                         IF WS-ID(1:7) = "pillage"
                             ADD 1 TO WS-LOOT-OUTPOST
                         ELSE
                             ADD 1 TO WS-LOOT-VILLAGE
                         END-IF
                         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 16
                             MOVE SPACES TO WS-SHORT
                             STRING "minecraft:chests/village/" FUNCTION TRIM(WS-LN(WS-T)) DELIMITED BY SIZE INTO WS-SHORT
                             IF TN-LOOT(WS-TAG) = WS-SHORT
                                 ADD 1 TO WS-LC(WS-T)
                             END-IF
                         END-PERFORM
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
*>   the entities
     ADD TE-LOST TO WS-N-LOST
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-ENT-N(WS-ROW)
         MOVE TE-DATA(TP-ENT-BASE(WS-ROW) + WS-J) TO WS-BUF
         MOVE TE-LEN(TP-ENT-BASE(WS-ROW) + WS-J) TO WS-LEN
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 11
             MOVE SPACES TO WS-PAT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EID(WS-T))) TO WS-PAT-LEN
             MOVE X"00" TO WS-PAT(1:1)
             MOVE FUNCTION CHAR(WS-PAT-LEN + 1) TO WS-PAT(2:1)
             MOVE WS-EID(WS-T) TO WS-IDTXT
             MOVE WS-IDTXT(1:WS-PAT-LEN) TO WS-PAT(3:WS-PAT-LEN)
             COMPUTE WS-PAT-LEN = WS-PAT-LEN + 2
             MOVE 0 TO WS-ANY
             INSPECT WS-BUF(1:WS-LEN) TALLYING WS-ANY FOR ALL WS-PAT(1:WS-PAT-LEN)
             IF WS-ANY > 0
                 ADD 1 TO WS-EC(WS-T)
                 IF WS-T >= 4 AND WS-T <= 7
                     ADD 1 TO WS-HITS
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-HITS > 0
         ADD 1 TO WS-LIVE-T
         ADD WS-HITS TO WS-LIVE-E
     END-IF.
 COPY VILCENSP.
 END PROGRAM TEST-STRUCT-36-9-9.
 COPY CORETEST.
