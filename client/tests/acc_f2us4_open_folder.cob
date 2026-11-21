*> Acceptance test US4-1, US4-2, Q-2 (spec 002 FR-008; SC-010): the client state names the opener program; with a
*> test opener that records its argument, Open Pack Folder on the pack screen creates resourcepacks/ when it is
*> missing and the opener receives that folder; a pack copied in is listed after the next press, without a
*> restart; a run line names the opener substituted.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US4-OPEN-FOLDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 99.
 01 WS-HITS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-open-folder && mkdir -p build/client-test-open-folder"
     CALL "SYSTEM" USING 'printf "#!/bin/sh\necho \$1 > build/client-test-open-folder/opener.out\n" > build/client-test-open-folder/opener.sh && chmod +x build/client-test-open-folder/opener.sh'
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-open-folder/game" TO CL-GAME-DIR
     MOVE 34 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE SPACES TO CL-OPENER
     MOVE "build/client-test-open-folder/opener.sh" TO CL-OPENER
     MOVE 39 TO CL-OPENER-LENGTH
     CALL "SYSTEM" USING "rm -rf build/client-test-open-folder/game/resourcepacks"
     MOVE SCR-PACKS TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-OPEN-PACK-FOLDER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "SYSTEM" USING "test -d build/client-test-open-folder/game/resourcepacks"
     MOVE 0 TO WS-E1
     IF RETURN-CODE NOT = 0
         MOVE 1 TO WS-E1
     END-IF
*>   The opener runs in the background: poll for its output (a condition, not a fixed pause) for up to 30 seconds, since a loaded machine can take seconds to start a process.
     MOVE 1 TO RETURN-CODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR RETURN-CODE = 0
         CALL "TEST-SLEEP"
         CALL "SYSTEM" USING "grep -q 'game/resourcepacks' build/client-test-open-folder/opener.out"
     END-PERFORM
     MOVE 0 TO WS-E2
     IF RETURN-CODE NOT = 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE WS-FOUND TO WS-E3
     MOVE "acceptance US4-1 given no resourcepacks folder when Open Pack Folder is pressed then the "
         & "folder is created (0 = it exists) and the opener received it (0 = yes)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING "found " WS-E3 " missing " WS-E1 " opener-missed " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 01 missing 0 opener-missed 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A pack folder copied in is listed after the next press, no restart.
     CALL "SYSTEM" USING 'mkdir -p build/client-test-open-folder/game/resourcepacks/Fresh && printf "{\"pack\":{\"description\":\"fresh\",\"min_format\":97,\"max_format\":97}}" > build/client-test-open-folder/game/resourcepacks/Fresh/pack.mcmeta'
     MOVE 0 TO WS-FOUND
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Fresh"
     MOVE "acceptance US4-2 given a pack copied into resourcepacks/ when Open Pack Folder is pressed "
         & "again then the pack is listed without a restart" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FUNCTION MIN(WS-HITS, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US4-OPEN-FOLDER.
 COPY CLTEST.
