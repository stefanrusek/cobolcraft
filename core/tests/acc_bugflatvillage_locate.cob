*> Acceptance test of the operator report "superflat has no villages now" (try14 play; bug lane bugflatvillage; docs/protocol/56-superflat-world.md sections 2.6 and 4.7,
*> 36-1 section 11, 16 section 7.7): new superflat worlds (the default preset `flat`) of several seeds, among them 64-bit values of both signs such as the create-world screen's
*> random draw gives and a text seed, are asked /locate structure #minecraft:village on the console, and so is each world saved and opened again from its folder (a second session).
*> Expected: every one answers "The nearest ..." (no "Could not find"). Needs the generated packs (CC_GENERATED_DIR): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFLATVILLAGE-LOCATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY CLIMATE.
 COPY STRUCTDATA.
 COPY FLATSET.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-SEEDS.
    05 WS-SEED-TEXT        PIC X(24) OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-CASE                PIC X(120).
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
         MOVE "acc bugflatvillage no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "12345" TO WS-SEED-TEXT(1)
     MOVE "6278314744523580143" TO WS-SEED-TEXT(2)
     MOVE "-7135090535216748403" TO WS-SEED-TEXT(3)
     MOVE "1" TO WS-SEED-TEXT(4)
     MOVE "hello" TO WS-SEED-TEXT(5)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "TEST-SETTINGS" USING CORE-SETTINGS
         MOVE "superflat" TO CS-WORLD-TYPE
         MOVE WS-DIR TO CS-GENERATED-DIR
         MOVE 2 TO CS-VIEW-DISTANCE
         MOVE 0 TO CS-HOSTILE-MOBS
         MOVE SPACES TO CS-SEED-TEXT
         MOVE WS-SEED-TEXT(WS-I) TO CS-SEED-TEXT
         MOVE 0 TO FS-PENDING
         CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
         MOVE "locate structure #minecraft:village" TO WS-LINE
         CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
         DISPLAY "SEED " FUNCTION TRIM(WS-SEED-TEXT(WS-I)) " locate village: " FUNCTION TRIM(WS-TEXT)(1:150)
         MOVE SPACES TO WS-CASE
         STRING "acc bugflatvillage a superflat world of seed " FUNCTION TRIM(WS-SEED-TEXT(WS-I)) " locates a village" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "The nearest " TO TL-EXPECTED
         MOVE WS-TEXT(1:12) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the last world saved and opened again from its folder (a second session of the same world)
         CALL "CORE-SAVE"
         MOVE 0 TO CL-COUNT
         CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
         DISPLAY "REOPEN created " WS-CREATED " gen " FS-GEN-STRUCT " ovr " FS-OVR-COUNT " gate " SD-GATE-COUNT
         MOVE "locate structure #minecraft:village" TO WS-LINE
         CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
         DISPLAY "REOPEN locate village: " FUNCTION TRIM(WS-TEXT)(1:150)
         MOVE SPACES TO WS-CASE
         STRING "acc bugflatvillage a reopened superflat world of seed " FUNCTION TRIM(WS-SEED-TEXT(WS-I)) " locates a village" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "The nearest " TO TL-EXPECTED
         MOVE WS-TEXT(1:12) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-BUGFLATVILLAGE-LOCATE.

 COPY CORETEST.
 COPY CMDTEST.
