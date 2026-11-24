*> Convergence acceptance test of the world types (spec 002 US2-1 to US2-4; FR-002 to FR-004, SC-011;
*> docs/design/world-types.md): through the client's single-player host one world of each type is created in its
*> own folder under saves/ (the standard one on the extraction tool's output of the operator's jar, build/generated-test;
*> the test extracts it itself and fails loudly without tmp/minecraft-26.3-client.jar), a standard command runs in each
*> (the shared rules), each world is quit and opened again and reopens as its own type with its own registries, and
*> the standard world with the generated directory missing is refused with the packs reason (nothing hosts).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-WORLD-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us2-world-type".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-COMMAND             PIC X(300).
 01 WS-RETURN              BINARY-LONG.
 01 WS-FOLDER              PIC X(80).
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STD-1               PIC X(4).
 01 WS-COB-1               PIC X(4).
 01 WS-STD-2               PIC X(4).
 01 WS-COB-2               PIC X(4).
 01 WS-MODE-STD            PIC X(4).
 01 WS-MODE-COB            PIC X(4).
 01 WS-TYPE-TEXT           PIC X(4).
 01 WS-MODE-TEXT           PIC X(4).
 01 WS-HITS               BINARY-LONG.
 01 WS-K                  BINARY-LONG.
 01 WS-DLOG                PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
*>   A folder another program left under this name (acc_f2us1_start_check makes f2-* folders in it) is not the tool's to replace (CCX-051): start from nothing.
     CALL "SYSTEM" USING "rm -rf build/generated-test"
     MOVE SPACES TO WS-COMMAND
     STRING "build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar "
         "--generated-dir build/generated-test --force --quiet" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND RETURNING WS-RETURN
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/generated-test" TO CL-GENERATED-DIR
     MOVE 20 TO CL-GENERATED-DIR-LENGTH
     MOVE "T" TO TL-MODE

*>   A standard world, then a cobolcraft one, each created, played in and quit.
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     MOVE "TypeStd" TO WS-FOLDER
     MOVE 7 TO WS-FOLDER-LENGTH
     PERFORM OPEN-AND-PLAY
     MOVE WS-TYPE-TEXT TO WS-STD-1
     MOVE WS-MODE-TEXT TO WS-MODE-STD
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     MOVE "TypeCob" TO WS-FOLDER
     PERFORM OPEN-AND-PLAY
     MOVE WS-TYPE-TEXT TO WS-COB-1
     MOVE WS-MODE-TEXT TO WS-MODE-COB
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE "acceptance US2-1 US2-4 given one world of each type created through the client host when "
         & "a standard command runs in each then each is its own type and the command took effect"
         TO TL-CASE
     MOVE "standard 0 mode 1 | cobolcraft 1 mode 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "standard " FUNCTION TRIM(WS-STD-1) " mode " FUNCTION TRIM(WS-MODE-STD)
         " | cobolcraft " FUNCTION TRIM(WS-COB-1) " mode " FUNCTION TRIM(WS-MODE-COB) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Restart: each reopens (the type read from its level.dat) as its own type.
     MOVE "TypeStd" TO WS-FOLDER
     MOVE 7 TO WS-FOLDER-LENGTH
     PERFORM OPEN-AND-PLAY
     MOVE WS-TYPE-TEXT TO WS-STD-2
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE "TypeCob" TO WS-FOLDER
     PERFORM OPEN-AND-PLAY
     MOVE WS-TYPE-TEXT TO WS-COB-2
     CALL "SP-QUIT" USING CLIENT-STATE
     MOVE "acceptance US2-3 given the two worlds quit when each is opened again then each reopens as "
         & "its own type" TO TL-CASE
     MOVE "standard 0 | cobolcraft 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "standard " FUNCTION TRIM(WS-STD-2) " | cobolcraft " FUNCTION TRIM(WS-COB-2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The generated directory removed: the standard world is refused with the packs reason.
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/generated-missing" TO CL-GENERATED-DIR
     MOVE 23 TO CL-GENERATED-DIR-LENGTH
     MOVE "TypeStd" TO WS-FOLDER
     MOVE 7 TO WS-FOLDER-LENGTH
     MOVE 0 TO SP-CREATE-REFUSED SP-ACTIVE
     MOVE "TypeStd" TO WS-LINE
     MOVE 7 TO WS-LINE-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-LINE WS-LINE-LENGTH
         WS-SURVIVAL
     MOVE "acceptance US2-3 FR-003 given the standard world and no generated directory when it is "
         & "opened then it is refused with the packs reason and nothing is hosted" TO TL-CASE
     MOVE "refused 1 hosted 0" TO TL-EXPECTED
     MOVE SP-CREATE-REFUSED TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "refused " FUNCTION TRIM(WS-E1) " hosted " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   Opens WS-FOLDER as a host, waits for play, runs gamemode creative on the host; WS-TYPE-TEXT the open set's type,
*>   WS-MODE-TEXT the host's game mode afterwards.
 OPEN-AND-PLAY.
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
*>   a standard world takes longer than the harness' 400 frames to load its first chunks: wait again, up to 20 times
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM
     MOVE "/gamemode creative Alice" TO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
*>   a standard world loads its chunks slowly: the frames run until the command's answer is in the chat (at most 600)
     MOVE 0 TO WS-K
     MOVE SPACES TO WS-DLOG
     MOVE 0 TO WS-HITS
     PERFORM UNTIL WS-K >= 600 OR WS-HITS > 0
         CALL "CV-STEP" USING CONVH
         ADD 1 TO WS-K
         CALL "CV-CHAT-LOG" USING CONVH WS-ALICE WS-DLOG
         INSPECT WS-DLOG TALLYING WS-HITS FOR ALL "commands.gamemode.success.self"
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CT-SET-TYPE TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TYPE-TEXT
     MOVE PL-MODE TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-MODE-TEXT.
 END PROGRAM ACC-F2US2-WORLD-TYPE.
