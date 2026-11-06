*> Acceptance test, US14-3 core half (spec US14 scenario 3; FR-016; standin-content §16.1 order of
*> checks, §16.4 not_permitted): a player without operator status who runs an operator command is
*> sent only cobolcraft.command.not_permitted [command name], and nothing changes. Alice has no
*> operator status (dedicated server, empty operator list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-NOT-PERMITTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-EDIT                PIC Z(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 1000 TO CW-TIME

     MOVE "acceptance US14-3 given an operator command and a player without operator status when "
         & "they run /clock 5000 then they are sent only the not-permitted message" TO TL-CASE
     MOVE "clock 5000" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-IDS) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "124 cobolcraft.command.not_permitted(clock)" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-3 given an operator command and a player without operator status when "
         & "they run it then nothing happens: the time of day is unchanged" TO TL-CASE
     MOVE CW-TIME TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1000" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "acceptance US14-3 the not-permitted check comes before the arguments: /promote with no "
         & "argument is not permitted, not a missing argument" TO TL-CASE
     MOVE "promote" TO WS-LINE
     PERFORM RUN-CHECK
     MOVE "cobolcraft.command.not_permitted(promote)" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-3 given a player without operator status when they run /promote Alice "
         & "then they do not gain operator status" TO TL-CASE
     MOVE "promote Alice" TO WS-LINE
     PERFORM RUN-CHECK
     MOVE PL-OPERATOR(CN-PLAYER(WS-ALICE)) TO WS-EDIT
     STRING " operator " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED(42:)
     MOVE "cobolcraft.command.not_permitted(promote) operator 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-3 an everyone command is permitted to a player without operator status"
         TO TL-CASE
     MOVE "roster" TO WS-LINE
     PERFORM RUN-CHECK
     MOVE "cobolcraft.command.roster(1,Alice)" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     STOP RUN.

 RUN-CHECK.
     CALL "TEST-COMMAND" USING WS-ALICE WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US14-NOT-PERMITTED.

 COPY CORETEST.
