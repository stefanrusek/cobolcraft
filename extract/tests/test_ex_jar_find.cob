*> Implementation test for EX-JAR-FIND (22 §7.1; T0295): --jar wins (CCX-011 when it is no readable file), else the
*> first regular file of <game>/minecraft-26.3-client.jar, <game>/client.jar and ./minecraft-26.3-client.jar,
*> else CCX-010 listing the three. Over a scratch game directory.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-JAR-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-JAR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "jar-find" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) "/both "
         FUNCTION TRIM(WS-ROOT) "/only-client " FUNCTION TRIM(WS-ROOT) "/none " FUNCTION TRIM(WS-ROOT) "/a-dir.jar"
         " && touch " FUNCTION TRIM(WS-ROOT) "/both/minecraft-26.3-client.jar " FUNCTION TRIM(WS-ROOT)
         "/both/client.jar " FUNCTION TRIM(WS-ROOT) "/only-client/client.jar " FUNCTION TRIM(WS-ROOT) "/given.jar"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE "jar-find: scratch tree made" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SHELL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   --jar given and present.
     PERFORM CLEAR-OPT
     MOVE 1 TO EXO-JAR-GIVEN
     STRING FUNCTION TRIM(WS-ROOT) "/given.jar" DELIMITED BY SIZE INTO EXO-JAR
     MOVE "." TO EXO-GAME
     PERFORM RUN-FIND
     MOVE "jar-find: --jar of a file gives status 0" TO TL-CASE
     PERFORM ASSERT-OK
     MOVE "jar-find: --jar path is returned as given" TO TL-CASE
     MOVE EXO-JAR TO TL-EXPECTED
     MOVE WS-JAR TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   --jar missing.
     MOVE SPACES TO EXO-JAR
     STRING FUNCTION TRIM(WS-ROOT) "/missing.jar" DELIMITED BY SIZE INTO EXO-JAR
     PERFORM RUN-FIND
     MOVE "jar-find: --jar of nothing gives CCX-011" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "jar-find: CCX-011 text and exit 2" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-011 Cannot read " FUNCTION TRIM(EXO-JAR) ": no such file." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 2 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   --jar a directory.
     MOVE SPACES TO EXO-JAR
     STRING FUNCTION TRIM(WS-ROOT) "/a-dir.jar" DELIMITED BY SIZE INTO EXO-JAR
     PERFORM RUN-FIND
     MOVE "jar-find: --jar of a directory gives CCX-011 is a directory" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-011 Cannot read " FUNCTION TRIM(EXO-JAR) ": is a directory." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   Search: both files, the Minecraft name wins.
     PERFORM CLEAR-OPT
     STRING FUNCTION TRIM(WS-ROOT) "/both" DELIMITED BY SIZE INTO EXO-GAME
     PERFORM RUN-FIND
     MOVE "jar-find: game directory with both names finds minecraft-26.3-client.jar" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-ROOT) "/both/minecraft-26.3-client.jar" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-JAR TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     PERFORM CLEAR-OPT
     STRING FUNCTION TRIM(WS-ROOT) "/only-client" DELIMITED BY SIZE INTO EXO-GAME
     PERFORM RUN-FIND
     MOVE "jar-find: game directory with client.jar only finds client.jar" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-ROOT) "/only-client/client.jar" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-JAR TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   Nothing anywhere: CCX-010 with the three places.
     PERFORM CLEAR-OPT
     STRING FUNCTION TRIM(WS-ROOT) "/none" DELIMITED BY SIZE INTO EXO-GAME
     PERFORM RUN-FIND
     MOVE "jar-find: nothing found gives CCX-010, exit 2" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "jar-find: CCX-010 lists the three places" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-010 Cannot find the Minecraft client jar. Looked for: " FUNCTION TRIM(WS-ROOT)
         "/none/minecraft-26.3-client.jar, " FUNCTION TRIM(WS-ROOT) "/none/client.jar, ./minecraft-26.3-client.jar."
         " Pass --jar <file>." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   The working directory is the last place.
     MOVE "touch minecraft-26.3-client.jar" TO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM RUN-FIND
     MOVE "jar-find: ./minecraft-26.3-client.jar is the last place" TO TL-CASE
     MOVE "./minecraft-26.3-client.jar" TO TL-EXPECTED
     MOVE WS-JAR TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "rm -f minecraft-26.3-client.jar" TO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     STOP RUN.

 CLEAR-OPT.
     MOVE SPACES TO EXO-JAR EXO-GAME EXO-GEN
     MOVE 0 TO EXO-JAR-GIVEN EXO-FORCE EXO-VERIFY EXO-DRY EXO-QUIET.

 RUN-FIND.
     MOVE SPACES TO WS-JAR
     MOVE -1 TO WS-STATUS
     CALL "EX-JAR-FIND" USING WS-JAR WS-STATUS.

 ASSERT-OK.
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-JAR-FIND.

 COPY EXTEST.
