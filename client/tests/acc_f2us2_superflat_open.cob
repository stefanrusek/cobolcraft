*> Acceptance test, the create-world screen hands its superflat preset to the core (lane 002-lane-superflat-client with 002-lane-superflat-core;
*> docs/protocol/56-superflat-world.md sections 2.6, 3.1 and 3.2, docs/design/world-types.md superflat): a new superflat world made from the
*> create-world screen (SP-OPEN, which calls FLAT-PRESET-SET before CORE-WORLD-OPEN) joins, and the flat settings of the open core are the
*> chosen preset: Tunnelers' Dream (bedrock 1, stone 230, dirt 5, grass_block 1; mineshafts and strongholds) when it was
*> picked on the preset screen, and the world preset `flat` (bedrock 1, dirt 2, grass_block 1; strongholds and villages) when nothing was.
*> Each world is also saved with its settings (data/minecraft/world_gen_settings.dat). The packs are the generated vanilla data (CC_GENERATED_DIR); without them SP-OPEN refuses the world and the test fails.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-SUPERFLAT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-superflat-open".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 32.
 01 WS-FOLDER              PIC X(80) VALUE "Dream".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "Dream".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER2             PIC X(80) VALUE "Plain".
 01 WS-NAME2               PIC X(64) VALUE "Plain".
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-REASON              PIC X(40) VALUE Z"cobolcraft.disconnect.host_closed".
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-FILE                PIC X(160).
 01 WS-INFO                PIC X(16).
 01 WS-SET                 PIC X(80).
 01 WS-GEN                 PIC X(1024).
 01 WS-OK                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FLAGS               PIC X(4).
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
*>   The generated vanilla data (CC_GENERATED_DIR, default /tmp/cc-test/generated): a superflat world opens the standard content set.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-GEN TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-GEN)) TO CL-GENERATED-DIR-LENGTH
*>   The create-world screen, type superflat, preset Tunnelers' Dream as the preset screen leaves it.
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     MOVE "tunnelers_dream" TO SP-FLAT-PRESET
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "superflat open a new superflat world with a chosen preset joins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-JOINED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM SETTINGS-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "superflat open the core holds the chosen preset: spawn height 173 (4 layers, 237 blocks), the mineshafts and "
         & "strongholds sets pass, villages and igloos do not" TO TL-CASE
     MOVE "173 0110" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-STOP" USING WS-REASON
     MOVE SPACES TO WS-FILE
     STRING "build/client-test-superflat-open/saves/Dream/data/minecraft/world_gen_settings.dat" DELIMITED BY SIZE INTO WS-FILE
     MOVE 0 TO WS-E4
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE RETURN-CODE TO WS-E4
     MOVE "N" TO TL-MODE
     MOVE "superflat open the world is saved with its flat settings file" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-E4 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nothing picked: the create-world screen's own default is the world preset `flat` (bedrock 1, dirt 2, grass_block 1; two overrides).
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER2 WS-FOLDER-LENGTH WS-NAME2 WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "superflat open a new superflat world with the default preset joins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-JOINED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM SETTINGS-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "superflat open the default is the world preset flat: spawn height -60 (bedrock 1, dirt 2, grass 1), the "
         & "villages and strongholds sets pass, mineshafts and igloos do not" TO TL-CASE
     MOVE "-60 1100" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CORE-STOP" USING WS-REASON
     STOP RUN.
 SETTINGS-OBSERVED.
*>   The flat settings of the open core as its own programs report them: TL-OBSERVED = spawn height, then the flags of the sets
*>   villages, strongholds, mineshafts, igloos (FLAT-STRUCT-SET-OK, 56 section 4.7).
     CALL "FLAT-SPAWN-HEIGHT" USING WS-Y
     MOVE WS-Y TO WS-E1
     MOVE "minecraft:villages" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-E2
     MOVE WS-E2(10:1) TO WS-FLAGS(1:1)
     MOVE "minecraft:strongholds" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-E2
     MOVE WS-E2(10:1) TO WS-FLAGS(2:1)
     MOVE "minecraft:mineshafts" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-E2
     MOVE WS-E2(10:1) TO WS-FLAGS(3:1)
     MOVE "minecraft:igloos" TO WS-SET
     CALL "FLAT-STRUCT-SET-OK" USING WS-SET WS-OK
     MOVE WS-OK TO WS-E2
     MOVE WS-E2(10:1) TO WS-FLAGS(4:1)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " WS-FLAGS DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM ACC-F2US2-SUPERFLAT-OPEN.
 COPY CLTEST.
