*> Implementation test (002-lane-mobs2, T4142): CC_COMMANDS ("a;b;c") with CC_COMMANDS_AT_FRAME runs console commands of the hosted world once, from the
*> frame given, so screenshot runs can /summon and set the time without typing: here "gamemode creative @a" makes the player creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STARTUP-COMMANDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-startup".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-FOLDER              PIC X(80) VALUE "w".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(64) VALUE "w".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE "N" TO TL-MODE
     MOVE "test startup commands: the player starts in survival" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-MODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "gamemode creative @a; gamemode creative @a" TO CL-CMD-TEXT
     MOVE 5000000 TO CL-CMD-AT
     PERFORM 5 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "test startup commands: before the frame the commands wait" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-MODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-CMD-AT
     PERFORM 10 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "test startup commands: from the frame the commands run (creative)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-MODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test startup commands: and only once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-CMD-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE
     STOP RUN.
 END PROGRAM TEST-STARTUP-COMMANDS.
 COPY CLTEST.
