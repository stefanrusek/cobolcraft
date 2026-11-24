*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-4-scattered-and-small.md section 11, loot placement summary), the rows whose container lives in a
*> template: the igloo basement chest is the template's chest at local (1, 1, 6) of igloo/bottom with no table of its own, its data marker `chest` is the structure block of mode
*> data at (1, 2, 6), igloo/top has no randomizable container (its furnace is not one); the ruined portals' chests carry LootTable minecraft:chests/ruined_portal in the template (portal_1 and
*> giant_portal_1: kind 1, one container each). STRUCT-PLACE-BE draws one seed per container with or without a table and requests only a container with a table: a container of the table
*> above gets it, one with none draws and requests nothing, a minecraft table key longer than the 48 bytes of the request channel is requested without its namespace (a key of another namespace that long requests nothing; GENBE.cpy). The desert, jungle, buried
*> treasure and suspicious sand rows are test_struct_scatter's cases of 36-4 3.4, 3.5, 4.4 and 7.2; the swamp hut and the nether fossil have no container.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-4-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 COPY STRUCTPIECE.
 COPY STRUCTPLACE.
 COPY GENBE.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND-TAG           BINARY-LONG.
 01 WS-CONTAINERS          BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 6.
 01 WS-Z                   BINARY-LONG VALUE 7.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-LO0                 BINARY-DOUBLE UNSIGNED.
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
         MOVE "acceptance US12 36-4§11 Loot placement summary: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-ENV TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE SPACES TO WS-DIR
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-DIR
*>   igloo/bottom: the chest at (1, 1, 6) and the marker at (1, 2, 6)
     MOVE "minecraft:igloo/bottom" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE 1 TO WS-QX
     MOVE 1 TO WS-QY
     MOVE 6 TO WS-QZ
     PERFORM FIND-TAG
     MOVE "acceptance US12 36-4§11 igloo basement: the template chest at (1, 1, 6) is a randomizable container (kind 1) with no table of its own (the marker sets chests/igloo_chest)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND-TAG > 0
         IF TN-KIND(WS-FOUND-TAG) = 1 AND TN-LOOT(WS-FOUND-TAG) = SPACES
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-QY
     PERFORM FIND-TAG
     MOVE "acceptance US12 36-4§11 igloo basement: the marker at (1, 2, 6) is a structure block in data mode (kind 3) with the metadata chest" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND-TAG > 0
         IF TN-KIND(WS-FOUND-TAG) = 3 AND TN-TEXT(WS-FOUND-TAG) = "chest"
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§11 igloo/bottom holds one randomizable container" TO TL-CASE
     PERFORM COUNT-CONTAINERS
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CONTAINERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:igloo/top" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM COUNT-CONTAINERS
     MOVE "acceptance US12 36-4§11 igloo/top holds no randomizable container (its furnace is not one)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CONTAINERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the ruined portals' chests
     MOVE "minecraft:ruined_portal/portal_1" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM COUNT-PORTAL
     MOVE "acceptance US12 36-4§11 ruined portal portal_1: one container, the table chests/ruined_portal" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CONTAINERS * 10 + WS-I
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:ruined_portal/giant_portal_1" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     PERFORM COUNT-PORTAL
     MOVE "acceptance US12 36-4§11 ruined portal giant_portal_1: one container, the table chests/ruined_portal" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a table key of 51 bytes (a barrel of the trial chambers) is read whole: the template loads (it was unsupported while the key was capped at 48 bytes)
     MOVE "minecraft:trial_chambers/intersection/intersection_2" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-DIR WS-ID WS-ROW
     MOVE 0 TO WS-FOUND-TAG
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(WS-ROW) WS-ZERO WS-ZERO2 WS-ZERO3 WS-INDEX
     COMPUTE WS-BASE = TP-BASE(WS-ROW, WS-INDEX + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         MOVE TB-NBT(WS-BASE + WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-LOOT(WS-TAG) = "minecraft:chests/trial_chambers/intersection_barrel"
                 ADD 1 TO WS-FOUND-TAG
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§11 trial_chambers/intersection_2 loads (status 1) and its barrels keep the 51-byte table key" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TP-STATUS(WS-ROW) = 1 AND WS-FOUND-TAG > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the seed rule of STRUCT-PLACE-BE (2.1): one nextLong for every container, a request only for one with a table that fits the channel
     CALL "SPB-RESET"
     MOVE 5 TO SP-XR-LO
     MOVE 9 TO SP-XR-HI
     MOVE 1 TO WS-TAG
     MOVE 0 TO GBL-COUNT GBL-LOST
     PERFORM MAKE-TAGS
     MOVE GBL-COUNT TO WS-BEFORE
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "acceptance US12 36-4§11 a container with a table of the channel's width is requested with that table (kind 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = WS-BEFORE + 1 AND GBL-KIND(GBL-COUNT) = 1 AND GBL-LOOT(GBL-COUNT) = "minecraft:chests/igloo_chest"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE GBL-COUNT TO WS-BEFORE
     MOVE 2 TO WS-TAG
     MOVE SP-XR-LO TO WS-LO0
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "acceptance US12 36-4§11 a container without a table draws its seed (the piece random moved) and requests nothing" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE GBL-COUNT TO TL-OBSERVED-N
     IF SP-XR-LO = WS-LO0
         ADD 1000 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-TAG
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "acceptance US12 36-4§11 a minecraft table key longer than the channel's 48 bytes (chests/trial_chambers/intersection_barrel) is requested without its namespace" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GBL-COUNT = WS-BEFORE + 1 AND GBL-KIND(GBL-COUNT) = 1 AND GBL-LOOT(GBL-COUNT) = "chests/trial_chambers/intersection_barrel"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> FIND-TAG: WS-FOUND-TAG the block entity tag of the template block at (WS-QX, WS-QY, WS-QZ) of the loaded template WS-ROW (0 when none)
 FIND-TAG.
     MOVE 0 TO WS-FOUND-TAG
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(WS-ROW) WS-ZERO WS-ZERO2 WS-ZERO3 WS-INDEX
     COMPUTE WS-BASE = TP-BASE(WS-ROW, WS-INDEX + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         IF TB-X(WS-BASE + WS-I) = WS-QX AND TB-Y(WS-BASE + WS-I) = WS-QY AND TB-Z(WS-BASE + WS-I) = WS-QZ
             MOVE TB-NBT(WS-BASE + WS-I) TO WS-FOUND-TAG
         END-IF
     END-PERFORM
     .
*> COUNT-CONTAINERS: WS-CONTAINERS the blocks of the loaded template WS-ROW whose tag is a randomizable container
 COUNT-CONTAINERS.
     MOVE 0 TO WS-CONTAINERS
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(WS-ROW) WS-ZERO WS-ZERO2 WS-ZERO3 WS-INDEX
     COMPUTE WS-BASE = TP-BASE(WS-ROW, WS-INDEX + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         MOVE TB-NBT(WS-BASE + WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 1
                 ADD 1 TO WS-CONTAINERS
             END-IF
         END-IF
     END-PERFORM
     .
*> COUNT-PORTAL: WS-CONTAINERS and (in WS-I) 1 when every container of the template WS-ROW has the table chests/ruined_portal
 COUNT-PORTAL.
     MOVE 0 TO WS-CONTAINERS
     MOVE 1 TO WS-FOUND-TAG
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(WS-ROW) WS-ZERO WS-ZERO2 WS-ZERO3 WS-INDEX
     COMPUTE WS-BASE = TP-BASE(WS-ROW, WS-INDEX + 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(WS-ROW)
         MOVE TB-NBT(WS-BASE + WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 1
                 ADD 1 TO WS-CONTAINERS
                 IF TN-LOOT(WS-TAG) NOT = "minecraft:chests/ruined_portal"
                     MOVE 0 TO WS-FOUND-TAG
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-FOUND-TAG TO WS-I
     .
*> MAKE-TAGS: three block entity tags of kind 1 at rows beyond the loaded ones: a table of the channel's width, none, and a key of 51 bytes
 MAKE-TAGS.
     MOVE 1 TO TN-KIND(1)
     MOVE "minecraft:chests/igloo_chest" TO TN-LOOT(1)
     MOVE 1 TO TN-KIND(2)
     MOVE SPACES TO TN-LOOT(2)
     MOVE 1 TO TN-KIND(3)
     MOVE "minecraft:chests/trial_chambers/intersection_barrel" TO TN-LOOT(3)
     .
 END PROGRAM TEST-STRUCT-36-4-11.

 COPY NOSPAWN.
 COPY CORETEST.
