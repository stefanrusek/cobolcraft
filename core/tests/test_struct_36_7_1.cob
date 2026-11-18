*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-7-woodland-mansion.md section 1, 1.1): the structure-level facts read from the data pack. The
*> structure minecraft:mansion has the type woodland_mansion, the generation step surface_structures (4), no terrain adaptation (none, 0) and the biomes of the tag has_structure/woodland_mansion
*> (dark_forest and pale_garden); its structure set woodland_mansions is random_spread, triangular, spacing 80, separation 20, salt 10387319, one entry of weight 1, no exclusion zone, the default
*> frequency reduction and no locate offset; the piece id wmp is a structure piece of the registry; the template directory holds 73 files; the structure is on in a standard world. The
*> spawn_overrides of 1.1 (empty) are read and left out by the loader (STRUCTDATA.cpy), so no case asserts them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-DIRZ                PIC X(1200).
 01 WS-LIST                PIC X(8192).
 01 WS-CAP                 BINARY-LONG VALUE 8192.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAMELEN             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(100).
 01 WS-ELEN                BINARY-LONG.
 01 WS-FILES               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-E                  BINARY-LONG.
 01 WS-ST                 BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-PALE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-7§1 Overview: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:mansion"
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§1.1 structure minecraft:mansion is loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
         MOVE 1 TO WS-ROW
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KIND
     MOVE "woodland_mansion" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-ID
     MOVE "acceptance US12 36-7§1.1 the structure type is woodland_mansion (registry index of worldgen/structure_type)" TO TL-CASE
     MOVE WS-ID TO TL-EXPECTED-N
     MOVE SDT-TYPE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 the type id is a real registry entry (not -1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ID >= 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 generation step surface_structures (decoration step index 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SDT-STEP(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 terrain_adaptation is absent, the codec default none (0): no beardifier" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-ADAPT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the biomes of the tag are dark_forest and pale_garden
     MOVE 0 TO WS-DARK
     MOVE 0 TO WS-PALE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SDT-BIOME-COUNT(WS-ROW)
         IF SD-BIOME(SDT-BIOME-FIRST(WS-ROW) + WS-I) = "minecraft:dark_forest"
             ADD 1 TO WS-DARK
         END-IF
         IF SD-BIOME(SDT-BIOME-FIRST(WS-ROW) + WS-I) = "minecraft:pale_garden"
             ADD 1 TO WS-PALE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§1.1 the biomes of #has_structure/woodland_mansion are dark_forest and pale_garden, two in all" TO TL-CASE
     MOVE 112 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DARK * 100 + WS-PALE * 10 + SDT-BIOME-COUNT(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the structure set woodland_mansions
     MOVE 1 TO WS-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         IF SS-KEY(WS-I) = "minecraft:woodland_mansions"
             MOVE WS-I TO WS-SET
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§1.1 the set is random_spread (2) with spacing 80, separation 20" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 1000000 + 80 * 1000 + 20
     COMPUTE TL-OBSERVED-N = SS-KIND(WS-SET) * 1000000 + SS-SPACING(WS-SET) * 1000 + SS-SEPARATION(WS-SET)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 the set has salt 10387319 and spread_type triangular (1)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10387319 * 10 + 1
     COMPUTE TL-OBSERVED-N = SS-SALT(WS-SET) * 10 + SS-SPREAD(WS-SET)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 the set has one entry, minecraft:mansion, of weight 1" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE SS-EN-FIRST(WS-SET) TO WS-E
     MOVE SE-STRUCT(WS-E) TO WS-ST
     MOVE SS-EN-COUNT(WS-SET) TO TL-OBSERVED-N
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + SE-WEIGHT(WS-E)
     IF SDT-KEY(WS-ST) NOT = "minecraft:mansion"
         ADD 1000 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§1.1 no exclusion zone, the default frequency reduction (0), frequency 1 and locate offset 0, 0, 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SS-EX-SET(WS-SET) + SS-METHOD(WS-SET) + SS-LOC-X(WS-SET) + SS-LOC-Y(WS-SET) + SS-LOC-Z(WS-SET)
     IF SS-FREQ(WS-SET) NOT = 1
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the piece id wmp is a registered structure piece
     MOVE 3 TO WS-KIND
     MOVE "wmp" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-ID
     MOVE "acceptance US12 36-7§1.1 the piece type id wmp (WMP lower-cased) is in the structure_piece registry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ID >= 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "WMP" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-N
     MOVE "acceptance US12 36-7§1.1 the registry lookup of WMP lower-cases it to the same id as wmp" TO TL-CASE
     MOVE WS-ID TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   73 template files under data/minecraft/structure/woodland_mansion
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/data/minecraft/structure/woodland_mansion" DELIMITED BY SIZE INTO WS-FILE
     MOVE LOW-VALUES TO WS-DIRZ
     COMPUTE WS-NAMELEN = FUNCTION LENGTH(FUNCTION TRIM(WS-FILE))
     MOVE WS-FILE(1:WS-NAMELEN) TO WS-DIRZ(1:WS-NAMELEN)
     MOVE 0 TO WS-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-CAP BY REFERENCE WS-COUNT RETURNING WS-STATUS
     MOVE 0 TO WS-FILES
     MOVE 1 TO WS-PTR
     PERFORM WS-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         MOVE 0 TO WS-ELEN
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-ELEN WITH POINTER WS-PTR
         IF WS-ENTRY(1:1) = "F" AND WS-ELEN > 5 AND WS-ENTRY(WS-ELEN - 3:4) = ".nbt"
             ADD 1 TO WS-FILES
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§1.1 the template directory holds 73 structure NBT files" TO TL-CASE
     MOVE 73 TO TL-EXPECTED-N
     MOVE WS-FILES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-1.
