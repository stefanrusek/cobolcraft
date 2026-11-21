*> Acceptance test of docs/protocol/16-commands-catalog.md §4.1 `gamemode` (permission level 2) with 14a: each target changes mode
*> (a target already in the mode is skipped); the player is sent Game Event 3, Player Abilities and, in survival or adventure, Set
*> Health; the source is told commands.gamemode.success.self or .other (broadcast to the other operators as chat.type.admin) and a
*> target that is not the source gameMode.changed; the result is the number of players changed. The mode names are the English
*> texts of gameMode.<name> (a literal argument; a translated argument is BLOCKED in the text component). Opal and Bob hold
*> operator status, Alice does not; the test world's default mode is creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-GAMEMODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
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
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /gamemode an operator sets own mode (creativ" & "e to survival): success.self" TO TL-CASE
     MOVE "gamemode survival" TO WS-LINE
     MOVE "commands.gamemode.success.self(Survival Mode)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the other operator is sent the com" & "mand as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Set own game mode to Survival Mode)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode a player who is not an operator is" & " sent nothing" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the mode of Opal is survival" TO TL-CASE
     MOVE PL-MODE(CN-PLAYER(WS-ID-OPAL)) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /gamemode Alice is already creative: skipped" & ", no message" TO TL-CASE
     MOVE "gamemode creative Alice" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the skipped target is sent nothing" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the result is 0 when nobody change" & "d (not a failure)" TO TL-CASE
     MOVE "gamemode creative Alice" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-IDS" USING WS-ID-OPAL WS-IDS
     MOVE "acceptance US13 /gamemode a target other than the source: su" & "ccess.other with the target name" TO TL-CASE
     MOVE "gamemode survival Alice" TO WS-LINE
     MOVE "commands.gamemode.success.other(Alice,Survival Mode)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the target is told gameMode.change" & "d" TO TL-CASE
     MOVE "gameMode.changed(Survival Mode)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the other operator is sent the com" & "mand as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Set Alice's game mode to Survival Mode)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode Alice is now in survival" TO TL-CASE
     MOVE PL-MODE(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE 1 TO PL-FLYING(CN-PLAYER(WS-ID-ALICE))
     MOVE "acceptance US13 /gamemode adventure is a mode" TO TL-CASE
     MOVE "gamemode adventure Alice" TO WS-LINE
     MOVE "commands.gamemode.success.other(Alice,Adventure Mode)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode Alice is now in adventure mode (2)" & " and stopped flying" TO TL-CASE
     MOVE PL-MODE(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /gamemode a player who changes to adventure " & "mode stops flying" TO TL-CASE
     MOVE PL-FLYING(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /gamemode spectator is a mode" TO TL-CASE
     MOVE "gamemode spectator Alice" TO WS-LINE
     MOVE "commands.gamemode.success.other(Alice,Spectator Mode)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode Alice is now in spectator mode (3)" TO TL-CASE
     MOVE PL-MODE(CN-PLAYER(WS-ID-ALICE)) TO WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /gamemode the result counts every player tha" & "t changed (two of three)" TO TL-CASE
     MOVE "gamemode creative @a" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /gamemode Alice is sent Game Event 3, Player" & " Abilities, Set Health and the message when she changes to s" & "urvival" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE "gamemode survival Alice" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "39 65 106 124" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode Alice is sent Game Event 3, Player" & " Abilities and the message, and no Set Health, when she chan" & "ges to creative" TO TL-CASE
     MOVE "gamemode creative Alice" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "39 65 124" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode a selector with an option" TO TL-CASE
     MOVE "gamemode survival @a[name=Bob]" TO WS-LINE
     MOVE "commands.gamemode.success.other(Bob,Survival Mode)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /gamemode a name that is not online is No pl" & "ayer was found" TO TL-CASE
     MOVE "gamemode survival Zed" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode an unknown mode is a parse error (" & "Invalid or unknown game mode)" TO TL-CASE
     MOVE "gamemode hardcore" TO WS-LINE
     MOVE "argument.gamemode.invalid(hardcore) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode without a mode the line is incompl" & "ete" TO TL-CASE
     MOVE "gamemode" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode a player below level 2 does not kn" & "ow the command" TO TL-CASE
     MOVE "gamemode creative" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the console without a target: a pl" & "ayer is required (permissions.requires.player)" TO TL-CASE
     MOVE "gamemode survival" TO WS-LINE
     MOVE "A player is required to run this command here" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /gamemode the console's feedback is printed" TO TL-CASE
     MOVE "gamemode survival Opal" TO WS-LINE
     MOVE "Set Opal's game mode to Survival Mode" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-GAMEMODE.

 COPY CORETEST.
 COPY CMDTEST.
