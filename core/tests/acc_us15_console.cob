*> Acceptance test, US15 core half (spec US15 scenarios 1 and 3; FR-016; contracts/core-host-api.md
*> §2 CORE-CONSOLE and CORE-CONSOLE-DRAIN; operator-surface.md §3, §4; standin-content §16.1): a
*> command line passed to CORE-CONSOLE (without a leading `/`) runs with operator permission and its
*> reply is drained as console lines through the en_us texts; an unknown command, a missing argument
*> and an invalid argument drain the §16 error with its help hint and change nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-CONSOLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-LINE                PIC X(800).
 01 WS-AREA                PIC X(4096).
 01 WS-TEXT                PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     MOVE 16001 TO CW-TIME
     PERFORM DRAIN

     MOVE "acceptance US15-1 given a running world when the player-list command is passed to "
         & "CORE-CONSOLE then its result is drained as a console line" TO TL-CASE
     MOVE Z"list" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM DRAIN
     MOVE "There are 1 of a max of 64 players online: Alice" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-1 given a running world when an operator command is passed to "
         & "CORE-CONSOLE then it runs with operator permission (the clock is set) and its "
         & "confirmation is drained" TO TL-CASE
     MOVE Z"time set 1000" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM DRAIN
     MOVE CW-TIME TO WS-EDIT
     STRING " | time " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE "Set cobolcraft:daylight to 1000 tick(s) | time 1000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-1 a console command's reply goes to the console only (the player is "
         & "sent no System Chat)" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-3 given a running world when an unknown command is passed to "
         & "CORE-CONSOLE then the standard unknown-command error is drained" TO TL-CASE
     MOVE Z"frobnicate now" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM DRAIN
     MOVE "Unknown or incomplete command. See below for error" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-3 a missing argument drains the standard error "
         & "and changes nothing" TO TL-CASE
     MOVE Z"time set" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM DRAIN
     MOVE CW-TIME TO WS-EDIT
     STRING " | time " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE "Unknown or incomplete command. See below for error | time 1000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-3 an invalid argument drains the §16 error with the usage and help "
         & "hint and changes nothing" TO TL-CASE
     MOVE Z"time set soon" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM DRAIN
     MOVE CW-TIME TO WS-EDIT
     STRING " | time " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE "Time marker minecraft:soon does not exist for clock cobolcraft:daylight | time 1000" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> WS-TEXT: the console lines drained now, separated by " | "; WS-PTR the next free position.
 DRAIN.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US15-CONSOLE.

 COPY CORETEST.
