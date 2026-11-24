*> Acceptance test, lane try6fix (operator report: every ocean of a standard world is frozen): the biome table CORE-BIOMES of a standard world
*> opened from the generated vanilla data pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it) holds the
*> climate of each biome (has_precipitation, temperature, temperature_modifier of data/minecraft/worldgen/biome/<name>.json). The entries of
*> a standard set are strict JSON, not network NBT, and larger than 4096 bytes, so the table stayed at temperature 0 and every water
*> surface froze (freeze_top_layer, 35 part 5 section 8: ice below temperature 0.15).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BIOME-CLIMATE-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-WANT                PIC X(48).
 01 WS-LONG               PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-T                   PIC -9.99.
 01 WS-P                   PIC 9.
 01 WS-F                   PIC 9.
 01 WS-TEXT                PIC X(300).
 PROCEDURE DIVISION.
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
         MOVE "N" TO TL-MODE
         MOVE "acceptance biome climate standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Climate" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance biome climate standard: ocean 0.50 and rain, warm_ocean 0.50, jungle 0.95, frozen_ocean 0.00 frozen, "
         & "plains 0.80, desert dry, snowy_plains cold" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE "ocean" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "warm_ocean" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "jungle" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "frozen_ocean" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "plains" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "desert" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE "snowy_plains" TO WS-WANT
     PERFORM ADD-BIOME
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE "ocean  0.50 1 0, warm_ocean  0.50 1 0, jungle  0.95 1 0, frozen_ocean  0.00 1 1, plains  0.80 1 0, "
         & "desert  2.00 0 0, snowy_plains  0.00 1 0," TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Appends "name temperature precipitation frozen," of the biome WS-WANT (with or without the namespace) to WS-TEXT.
 ADD-BIOME.
     MOVE SPACES TO WS-LONG
     STRING "minecraft:" FUNCTION TRIM(WS-WANT) DELIMITED BY SIZE INTO WS-LONG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         IF CBI-KEY(WS-I) = WS-WANT OR CBI-KEY(WS-I) = WS-LONG
             COMPUTE WS-T ROUNDED = CBI-TEMPERATURE(WS-I)
             MOVE CBI-PRECIPITATION(WS-I) TO WS-P
             MOVE CBI-FROZEN(WS-I) TO WS-F
             STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-WANT) " " WS-T " " WS-P " " WS-F ","
                 DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BIOME-CLIMATE-STANDARD.

 COPY NOSPAWN.
 COPY CORETEST.
