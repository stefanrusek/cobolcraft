*> Acceptance test (lane resume, T5800; docs/protocol/07 section 10): a player who left a 26.3 standard world from a place
*> underground (players/data/<offline-uuid>.dat, a copy of a real file: Pos -43.37 22.15 27.21, health 20, mode 0) joins
*> again and stands there: after the join, and after 100 ticks, not at the world spawn or on the surface. Skipped as a pass
*> without the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-RESUME-POSITION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-COMMAND             PIC X(200).
 01 WS-WORLD               PIC X(64) VALUE Z"build/resume-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-LENGTH              BINARY-LONG VALUE 6.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 100.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-D1                  PIC -(5)9.9.
 01 WS-D2                  PIC -(5)9.9.
 01 WS-D3                  PIC -(5)9.9.
 01 WS-H                   PIC -(5)9.9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
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
         MOVE "acceptance resume position no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "rm -rf build/resume-world && mkdir -p build/resume-world/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp -R core/tests/fixtures/resume/. build/resume-world/" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-NAME WS-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-ROW
     PERFORM SHOW
     MOVE "acceptance resume position given the saved place when the player joins then it stands there" TO TL-CASE
     MOVE "-43.3 22.1 27.2 20.0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM SHOW
     MOVE "acceptance resume position given the saved place when 100 ticks pass then it is still near there" TO TL-CASE
     MOVE "-43.3 22.1 27.2 20.0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The join held at the end of configuration while the spawn area of an existing world is made (GQ-SP-STATE): when it is released the
*>   player keeps the place of its file; CONFIG-RELEASE-HELD used to put every held player at the world spawn.
     MOVE PH-CONFIG TO CN-PHASE(WS-ID)
     MOVE 4 TO CF-STEP(WS-ID)
     CALL "CONFIG-RELEASE-HELD"
     PERFORM SHOW
     MOVE "acceptance resume position given a join held for the spawn area when it is released then the player keeps its saved place"
         TO TL-CASE
     MOVE "-43.3 22.1 27.2 20.0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SHOW.
     COMPUTE WS-D1 = PL-X(WS-ROW)
     COMPUTE WS-D2 = PL-Y(WS-ROW)
     COMPUTE WS-D3 = PL-Z(WS-ROW)
     COMPUTE WS-H = PL-HEALTH(WS-ROW)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-D1) " " FUNCTION TRIM(WS-D2) " " FUNCTION TRIM(WS-D3) " " FUNCTION TRIM(WS-H)
         DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM ACC-RESUME-POSITION.

 COPY CORETEST.
