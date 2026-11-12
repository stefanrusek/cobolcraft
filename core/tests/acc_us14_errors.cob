*> Acceptance test, US14-4 core half and the target-rule edge cases (spec US14 scenario 4 and edge cases; FR-016; docs/protocol/15 §6, §12 and
*> 15a §4): an unknown command, a missing argument, a trailing word and an invalid argument each change nothing and send the standard
*> failure (command.unknown.command and command.unknown.argument, which carry the input context line; the argument errors); a command
*> acting on a player that names a player who is not online sends argument.entity.notfound.player. Intents of the stand-in cases
*> that named a dimension argument have no counterpart without a dimension argument (BLOCKED with execute). Opal holds operator status; Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-ERRORS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /errors a player runs an unknown command: Un" & "known or incomplete command" TO TL-CASE
     MOVE "frobnicate the widget" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors command names are case-sensitive: Sa" & "y is unknown" TO TL-CASE
     MOVE "Say hi" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors an argument left out: Unknown or inc" & "omplete command" TO TL-CASE
     MOVE "msg Alice" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors words after the last argument: Incor" & "rect argument for command" TO TL-CASE
     MOVE "seed everyone" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors an argument out of range: the tick c" & "ount must not be less than 1" TO TL-CASE
     MOVE "weather clear -5" TO WS-LINE
     MOVE "argument.time.tick_count_too_low(1,-5) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors a word that is not a listed value: U" & "nknown game mode" TO TL-CASE
     MOVE "gamemode maybe Alice" TO WS-LINE
     MOVE "argument.gamemode.invalid(maybe) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors a literal that is not one of the lis" & "ted words" TO TL-CASE
     MOVE "whitelist maybe" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors a player who is not online: No playe" & "r was found" TO TL-CASE
     MOVE "msg Zed hello" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors player names match exactly: alice is" & " not Alice" TO TL-CASE
     MOVE "msg alice hello" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors a name that is not a login name is n" & "ot found" TO TL-CASE
     MOVE "msg Al-ice hello" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /errors a name of more than 16 characters is" & " an invalid selector" TO TL-CASE
     MOVE "msg Abcdefghijklmnopq hello" TO WS-LINE
     MOVE "argument.entity.invalid() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM ACC-US14-ERRORS.

 COPY CORETEST.
 COPY CMDTEST.
