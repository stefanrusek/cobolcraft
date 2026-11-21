*> Acceptance test of docs/protocol/36-structures-9-villages-outposts.md section 11 (the pillager outpost, T1474) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass
*> without it). 11.1: the four pools (base_plates: one legacy rigid element base_plate; feature_plates: one terrain_matching element feature_plate; features: seven legacy rigid elements of weight 1
*> and the empty element of weight 6, total 13; towers: one list element of watchtower and watchtower_overgrown), the template sizes (base_plate 16 x 30 x 16, feature_plate 16 x 4 x 32, watchtower
*> 15 x 21 x 15, watchtower_overgrown 15 x 23 x 15, the cages 7 x 4 x 7, logs 6 x 3 x 7, targets 3 x 3 x 7, the tents 6 x 4 x 7), the jigsaws of the plates (the base plate's three plate_entry and two
*> entrance at the listed cells, the feature plate's 15 feature and its plate_entry at (15,0,7)), the structure's size 7 and its vertical limit 80 (11.4: beard_thin, surface_structures). 11.2: one chest
*> in each watchtower template at local (9,14,10) with the loot table chests/pillager_outpost. 11.1 item 3: feature_cage1 stores one iron golem and feature_cage_with_allays two allays. 11.3 item 1:
*> the outpost's box is a full structure override of kind 3 (STRUCT-OVR-NOTE asks the entity channel once for the overall box). The pillager's own spawn rule is test_mob_pillager_spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-9-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY GENENT.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-ROOT                PIC X(1100).
 01 WS-KEY                 PIC X(80).
 01 WS-ID                  PIC X(96).
 01 WS-POOL                BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-SHORT               PIC X(48).
 01 WS-SHORT2              PIC X(48).
 01 WS-TEXT                PIC X(160).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-ED3                 PIC -(9)9.
 01 WS-ED4                 PIC -(9)9.
 01 WS-EMPTY-W             BINARY-LONG.
 01 WS-SEVEN               BINARY-LONG.
 01 WS-CHESTS              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BUF                 PIC X(1344).
 01 WS-LEN                 BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-PAT                 PIC X(40).
 01 WS-PAT-LEN             BINARY-LONG.
 01 WS-IDTXT               PIC X(24).
 01 WS-KIND                BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-IDV                 BINARY-LONG.
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-FEATURES            BINARY-LONG.
 01 WS-PLATE               BINARY-LONG.
 01 WS-PLATE-AT            PIC X(24).
*>  template, size x y z
 01 WS-SIZES.
    05 FILLER              PIC X(48) VALUE "base_plate                                      ".
    05 FILLER              PIC 9(8) VALUE 16301600.
    05 FILLER              PIC X(48) VALUE "feature_plate                                   ".
    05 FILLER              PIC 9(8) VALUE 16043200.
    05 FILLER              PIC X(48) VALUE "watchtower                                      ".
    05 FILLER              PIC 9(8) VALUE 15211500.
    05 FILLER              PIC X(48) VALUE "watchtower_overgrown                            ".
    05 FILLER              PIC 9(8) VALUE 15231500.
    05 FILLER              PIC X(48) VALUE "feature_cage1                                   ".
    05 FILLER              PIC 9(8) VALUE 07040700.
    05 FILLER              PIC X(48) VALUE "feature_cage2                                   ".
    05 FILLER              PIC 9(8) VALUE 07040700.
    05 FILLER              PIC X(48) VALUE "feature_cage_with_allays                        ".
    05 FILLER              PIC 9(8) VALUE 07040700.
    05 FILLER              PIC X(48) VALUE "feature_logs                                    ".
    05 FILLER              PIC 9(8) VALUE 06030700.
    05 FILLER              PIC X(48) VALUE "feature_targets                                 ".
    05 FILLER              PIC 9(8) VALUE 03030700.
    05 FILLER              PIC X(48) VALUE "feature_tent1                                   ".
    05 FILLER              PIC 9(8) VALUE 06040700.
    05 FILLER              PIC X(48) VALUE "feature_tent2                                   ".
    05 FILLER              PIC 9(8) VALUE 06040700.
 01 WS-SIZE-TAB REDEFINES WS-SIZES.
    05 WS-SZ               OCCURS 11 TIMES.
       10 WS-SZ-NAME       PIC X(48).
       10 WS-SZ-X          PIC 99.
       10 WS-SZ-Y          PIC 99.
       10 WS-SZ-Z          PIC 99.
       10 FILLER           PIC XX.
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
         MOVE "acceptance US12 36-9§11 The pillager outpost: no generated packs here, skipped" TO TL-CASE
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
     CALL "GEN-WORLD-SETUP"
     CALL "JIG-RESET"
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
*>   base_plates: one legacy element, rigid, of base_plate
     MOVE "minecraft:pillager_outpost/base_plates" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "acceptance US12 36-9§11.1 The pool graph: base_plates holds one legacy rigid element of base_plate" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF JP-N(WS-POOL) = 1 AND JE-KIND(WS-EL) = 2 AND JE-PROJ(WS-EL) = 0 AND JE-LOC(WS-EL) = "minecraft:pillager_outpost/base_plate"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:pillager_outpost/feature_plates" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "acceptance US12 36-9§11.1 The pool graph: feature_plates holds one legacy terrain_matching element of feature_plate" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF JP-N(WS-POOL) = 1 AND JE-KIND(WS-EL) = 2 AND JE-PROJ(WS-EL) = 1 AND JE-LOC(WS-EL) = "minecraft:pillager_outpost/feature_plate"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   features: seven rigid legacy elements of weight 1 and the empty element of weight 6, total 13
     MOVE "minecraft:pillager_outpost/features" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE 0 TO WS-BAD WS-EMPTY-W WS-SEVEN
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL)
         COMPUTE WS-J = JP-FIRST(WS-POOL) + WS-I
         MOVE JN-ELEM(WS-J) TO WS-EL
         IF JE-KIND(WS-EL) = 5
             ADD JN-WEIGHT(WS-J) TO WS-EMPTY-W
         ELSE
             IF JE-KIND(WS-EL) = 2 AND JE-PROJ(WS-EL) = 0 AND JN-WEIGHT(WS-J) = 1
                 ADD 1 TO WS-SEVEN
             ELSE
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§11.1 The pool graph: features holds seven rigid legacy elements of weight 1, the empty element of weight 6, total weight 13" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SEVEN * 100000 + WS-EMPTY-W * 1000 + JP-TOTAL(WS-POOL) + WS-BAD * 10000000
     MOVE 706013 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   towers: one list element of two templates
     MOVE "minecraft:pillager_outpost/towers" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "acceptance US12 36-9§11.1 The pool graph: towers holds one rigid list element of watchtower then watchtower_overgrown" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF JP-N(WS-POOL) = 1 AND JE-KIND(WS-EL) = 3 AND JE-SUB-N(WS-EL) = 2 AND JE-PROJ(WS-EL) = 0
         MOVE JS-ELEM(JE-SUB-FIRST(WS-EL)) TO WS-SUB
         IF JE-LOC(WS-SUB) = "minecraft:pillager_outpost/watchtower"
             MOVE JS-ELEM(JE-SUB-FIRST(WS-EL) + 1) TO WS-SUB
             IF JE-LOC(WS-SUB) = "minecraft:pillager_outpost/watchtower_overgrown"
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the template sizes
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 11
         MOVE SPACES TO WS-ID
         STRING "pillager_outpost/" FUNCTION TRIM(WS-SZ-NAME(WS-T)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-ROW
         IF WS-ROW = 0
             ADD 1 TO WS-BAD
         ELSE
             IF TP-STATUS(WS-ROW) NOT = 1 OR TP-SX(WS-ROW) NOT = WS-SZ-X(WS-T) OR TP-SY(WS-ROW) NOT = WS-SZ-Y(WS-T) OR TP-SZ(WS-ROW) NOT = WS-SZ-Z(WS-T)
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§11.1 The pool graph: the 11 templates have the sizes of the document (base plate 16 x 30 x 16 and so on)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the base plate's jigsaws: plate_entry (0,0,7), (7,0,15), (15,0,8); entrance (7,1,14), (8,1,14), in block order
     MOVE "pillager_outpost/base_plate" TO WS-ID
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-ROW
     PERFORM LIST-JIGSAWS
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-9§11.1 The pool graph: the base plate has the jigsaws plate_entry (0,0,7), (7,0,15), (15,0,8) and entrance (7,1,14), (8,1,14)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "plate_entry 0,0,7 plate_entry 7,0,15 plate_entry 15,0,8 entrance 7,1,14 entrance 8,1,14 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "pillager_outpost/feature_plate" TO WS-ID
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-ROW
     PERFORM LIST-JIGSAWS
     MOVE "acceptance US12 36-9§11.1 The pool graph: the feature plate has 15 feature jigsaws and its plate_entry at (15,0,7)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FEATURES = 15 AND WS-PLATE = 1 AND WS-PLATE-AT = "15,0,7"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the chests of the two watchtowers: one each at (9,14,10), loot pillager_outpost, no seed
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 2
         IF WS-T = 1
             MOVE "pillager_outpost/watchtower" TO WS-ID
         ELSE
             MOVE "pillager_outpost/watchtower_overgrown" TO WS-ID
         END-IF
         CALL "STRUCT-TPL-RESET"
         CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-ROW
         MOVE 0 TO WS-CHESTS
         COMPUTE WS-BASE = TP-BASE(WS-ROW, 1)
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-ROW)
             MOVE TB-NBT(WS-BASE + WS-J) TO WS-TAG
             IF WS-TAG > 0
                 IF TN-KIND(WS-TAG) = 1 AND TN-LOOT(WS-TAG) = "minecraft:chests/pillager_outpost"
                     ADD 1 TO WS-CHESTS
                     IF TB-X(WS-BASE + WS-J) NOT = 9 OR TB-Y(WS-BASE + WS-J) NOT = 14 OR TB-Z(WS-BASE + WS-J) NOT = 10
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-CHESTS NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§11.2 Loot: each watchtower template has one chest at local (9,14,10) with the table chests/pillager_outpost" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the cages' entities
     MOVE "pillager_outpost/feature_cage1" TO WS-ID
     MOVE "minecraft:iron_golem" TO WS-IDTXT
     PERFORM COUNT-ENTITY
     MOVE "acceptance US12 36-9§11.1 The pool graph: feature_cage1 stores one iron golem" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-HITS * 10 + TP-ENTITIES(WS-ROW)
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pillager_outpost/feature_cage_with_allays" TO WS-ID
     MOVE "minecraft:allay" TO WS-IDTXT
     PERFORM COUNT-ENTITY
     MOVE "acceptance US12 36-9§11.1 The pool graph: feature_cage_with_allays stores two allays" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-HITS * 10 + TP-ENTITIES(WS-ROW)
     MOVE 22 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the structure: size 7, limits 80, beard_thin, surface_structures
     MOVE 0 TO WS-STRUCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:pillager_outpost"
             MOVE WS-I TO WS-STRUCT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§11.4 Terrain and biome: size 7, horizontal and vertical distance 80, projection WORLD_SURFACE_WG" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-JIG-SIZE(WS-STRUCT) * 1000000 + SDT-JIG-HOR(WS-STRUCT) * 1000 + SDT-JIG-VER(WS-STRUCT)
     MOVE 7080080 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-KIND
     MOVE SDT-STEP(WS-STRUCT) TO WS-IDV
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-IDV WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-9§11.4 Terrain and biome: the step is surface_structures" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "surface_structures" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-KIND
     MOVE SDT-ADAPT(WS-STRUCT) TO WS-IDV
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-IDV WS-NAME
     MOVE "acceptance US12 36-9§11.4 Terrain and biome: the terrain adaptation is beard_thin" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "beard_thin" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   11.3 item 1: the outpost's overall box is a full override of kind 3, asked once of the entity channel
     MOVE "minecraft:pillager_outpost" TO WS-KEY
     MOVE 5 TO WS-CHUNK-X
     MOVE 7 TO WS-CHUNK-Z
     MOVE 70 TO WS-B(1)
     MOVE 60 TO WS-B(2)
     MOVE 100 TO WS-B(3)
     MOVE 130 TO WS-B(4)
     MOVE 100 TO WS-B(5)
     MOVE 140 TO WS-B(6)
     MOVE 0 TO GEL-BOX-COUNT
     CALL "STRUCT-OVR-NOTE" USING WS-KEY WS-CHUNK-X WS-CHUNK-Z WS-BOX
     MOVE "acceptance US12 36-9§11.3 Pillager spawning: the outpost box is a full structure override of kind 3: one box in the channel, the overall box" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GEL-BOX-COUNT * 1000 + GEL-B-KIND(1)
     MOVE 1003 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LIST-JIGSAWS.
*>   the jigsaw blocks of the first palette in block order: the entrance and plate_entry ones as "name x,y,z" in WS-TEXT, the feature ones counted, the last plate_entry's cell in WS-PLATE-AT
     MOVE 0 TO WS-FEATURES WS-PLATE
     MOVE SPACES TO WS-PLATE-AT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     COMPUTE WS-BASE = TP-BASE(WS-ROW, 1)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-BLOCKS(WS-ROW)
         MOVE TB-NBT(WS-BASE + WS-J) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 4
                 MOVE TN-NAME(WS-TAG) TO WS-SHORT
                 IF WS-SHORT(1:10) = "minecraft:"
                     MOVE WS-SHORT(11:38) TO WS-SHORT2
                         MOVE WS-SHORT2 TO WS-SHORT
                 END-IF
                 IF WS-SHORT = "feature"
                     ADD 1 TO WS-FEATURES
                 END-IF
                 MOVE TB-X(WS-BASE + WS-J) TO WS-ED2
                 MOVE TB-Y(WS-BASE + WS-J) TO WS-ED3
                 MOVE TB-Z(WS-BASE + WS-J) TO WS-ED4
                 IF WS-SHORT = "plate_entry"
                     ADD 1 TO WS-PLATE
                     MOVE SPACES TO WS-PLATE-AT
                     STRING FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) "," FUNCTION TRIM(WS-ED4) DELIMITED BY SIZE INTO WS-PLATE-AT
                 END-IF
                 IF WS-SHORT = "plate_entry" OR WS-SHORT = "entrance"
                     STRING FUNCTION TRIM(WS-SHORT) " " FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) "," FUNCTION TRIM(WS-ED4) " "
                         DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
                 END-IF
             END-IF
         END-IF
     END-PERFORM.

 COUNT-ENTITY.
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-ROW
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > TP-ENT-N(WS-ROW)
         MOVE TE-DATA(TP-ENT-BASE(WS-ROW) + WS-J) TO WS-BUF
         MOVE TE-LEN(TP-ENT-BASE(WS-ROW) + WS-J) TO WS-LEN
         MOVE SPACES TO WS-PAT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-IDTXT)) TO WS-PAT-LEN
         MOVE X"00" TO WS-PAT(1:1)
         MOVE FUNCTION CHAR(WS-PAT-LEN + 1) TO WS-PAT(2:1)
         MOVE WS-IDTXT(1:WS-PAT-LEN) TO WS-PAT(3:WS-PAT-LEN)
         COMPUTE WS-PAT-LEN = WS-PAT-LEN + 2
         MOVE 0 TO WS-I
         INSPECT WS-BUF(1:WS-LEN) TALLYING WS-I FOR ALL WS-PAT(1:WS-PAT-LEN)
         IF WS-I > 0
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STRUCT-36-9-11.
 COPY CORETEST.
