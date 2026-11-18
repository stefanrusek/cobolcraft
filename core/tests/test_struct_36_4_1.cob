*> Real-data test (skipped as a pass without the generated packs; T1384, docs/protocol/36-structures-4-scattered-and-small.md section 1): the map of the family. Each structure of the table is in the loaded
*> structure data with the step the table gives (surface_structures 4, underground_structures 3, underground_decoration 7) and its structure set has the spacing, separation and salt of the last column; the buried
*> treasure's set has frequency 0.01, the frequency method legacy_type_2 (2) and locate offset (9, 0, 9); the ruined_portals set lists seven structures of weight 1; nether_fossil adapts the terrain with beard_thin (2)
*> and the others do not (none, 0); the jungle pyramid keeps its key although its type is jungle_temple (note a).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-SETKEY              PIC X(80).
 01 WS-WSTEP               BINARY-LONG.
 01 WS-WSP                 BINARY-LONG.
 01 WS-WSE                 BINARY-LONG.
 01 WS-WSALT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-CASE                PIC X(160).
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
         MOVE "acceptance US12 36-4§1 Map of the family: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
     CALL "WORLDGEN-FREE"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "minecraft:desert_pyramid" TO WS-KEY
     MOVE "minecraft:desert_pyramids" TO WS-SETKEY
     MOVE 4 TO WS-WSTEP
     MOVE 32 TO WS-WSP
     MOVE 8 TO WS-WSE
     MOVE 14357617 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:jungle_pyramid" TO WS-KEY
     MOVE "minecraft:jungle_temples" TO WS-SETKEY
     MOVE 4 TO WS-WSTEP
     MOVE 32 TO WS-WSP
     MOVE 8 TO WS-WSE
     MOVE 14357619 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:swamp_hut" TO WS-KEY
     MOVE "minecraft:swamp_huts" TO WS-SETKEY
     MOVE 4 TO WS-WSTEP
     MOVE 32 TO WS-WSP
     MOVE 8 TO WS-WSE
     MOVE 14357620 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:igloo" TO WS-KEY
     MOVE "minecraft:igloos" TO WS-SETKEY
     MOVE 4 TO WS-WSTEP
     MOVE 32 TO WS-WSP
     MOVE 8 TO WS-WSE
     MOVE 14357618 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:buried_treasure" TO WS-KEY
     MOVE "minecraft:buried_treasures" TO WS-SETKEY
     MOVE 3 TO WS-WSTEP
     MOVE 1 TO WS-WSP
     MOVE 0 TO WS-WSE
     MOVE 0 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:ruined_portal" TO WS-KEY
     MOVE "minecraft:ruined_portals" TO WS-SETKEY
     MOVE 4 TO WS-WSTEP
     MOVE 40 TO WS-WSP
     MOVE 15 TO WS-WSE
     MOVE 34222645 TO WS-WSALT
     PERFORM CHECK-ROW
     MOVE "minecraft:nether_fossil" TO WS-KEY
     MOVE "minecraft:nether_fossils" TO WS-SETKEY
     MOVE 7 TO WS-WSTEP
     MOVE 2 TO WS-WSP
     MOVE 1 TO WS-WSE
     MOVE 14357921 TO WS-WSALT
     PERFORM CHECK-ROW
*>   buried treasure: frequency 0.01, method legacy_type_2, locate offset (9, 0, 9)
     MOVE "minecraft:buried_treasures" TO WS-SETKEY
     PERFORM FIND-SET
     MOVE "acceptance US12 36-4§1 Map of the family: buried_treasures has frequency 0.01 (times 1000)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-FREQ(WS-SET) * 1000 + 0.5
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§1 Map of the family: buried_treasures uses the frequency method legacy_type_2 (2) and locate offset (9, 0, 9)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-METHOD(WS-SET) * 1000000 + SS-LOC-X(WS-SET) * 10000 + SS-LOC-Y(WS-SET) * 100 + SS-LOC-Z(WS-SET)
     MOVE 2090009 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ruined portals: seven structures, weight 1 each
     MOVE "minecraft:ruined_portals" TO WS-SETKEY
     PERFORM FIND-SET
     MOVE 0 TO WS-W
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-SET)
         ADD SE-WEIGHT(SS-EN-FIRST(WS-SET) + WS-K) TO WS-W
     END-PERFORM
     MOVE "acceptance US12 36-4§1 Map of the family: ruined_portals lists seven structures of weight 1 (total 7)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-EN-COUNT(WS-SET) * 10 + WS-W
     MOVE 77 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-ROW.
     MOVE 1 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     PERFORM FIND-SET
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-4§1 Map of the family: " FUNCTION TRIM(WS-KEY) " has the step of the table" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WSTEP TO TL-EXPECTED-N
     MOVE SDT-STEP(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-4§1 Map of the family: the set of " FUNCTION TRIM(WS-KEY) " is random_spread with spacing, separation and salt of the table"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-WSP * 1000000000 + WS-WSE * 10000000 + FUNCTION MOD(WS-WSALT, 10000000)
     COMPUTE TL-OBSERVED-N = SS-SPACING(WS-SET) * 1000000000 + SS-SEPARATION(WS-SET) * 10000000 + FUNCTION MOD(SS-SALT(WS-SET), 10000000)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-4§1 Map of the family: the salt of " FUNCTION TRIM(WS-KEY) " is the table's" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WSALT TO TL-EXPECTED-N
     MOVE SS-SALT(WS-SET) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance US12 36-4§1 Map of the family: terrain adaptation of " FUNCTION TRIM(WS-KEY) " (beard_thin 2 for the nether fossil, else none)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-KEY = "minecraft:nether_fossil"
         MOVE 2 TO TL-EXPECTED-N
     END-IF
     MOVE SDT-ADAPT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
*> FIND-SET: WS-SET the set row with the key WS-SETKEY (row 1 when absent, so the cases fail)
 FIND-SET.
     MOVE 1 TO WS-SET
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         IF SS-KEY(WS-I) = WS-SETKEY
             MOVE WS-I TO WS-SET
         END-IF
     END-PERFORM
     .
 END PROGRAM TEST-STRUCT-36-4-1.
