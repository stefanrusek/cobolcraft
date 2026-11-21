*> Acceptance test of docs/protocol/16-commands-catalog.md §11.10 `save-on` (permission level 4, dedicated): it re-enables the automatic saving after
*> save-off (BW-SAVE-OFF 0) with commands.save.enabled (broadcast); saving is on at the start, so it fails with commands.save.alreadyOn
*> until save-off has been run; the result is 1; a level-3 operator does not see the command. Opal holds level 4, Olga level 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SAVE-ON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-OLGA           BINARY-LONG.
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
 COPY BRWORLD.
 01 WS-LIST                BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-NAME-OLGA           PIC X(16) VALUE "Olga".
 01 WS-LEN-OLGA            BINARY-LONG VALUE 4.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Olga" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OLGA
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-DISCARD
     MOVE 1 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-OLGA WS-LEN-OLGA WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE 3 TO AC-LEVEL(1, WS-ROW)
     MOVE "acceptance US13 /save-on an operator of level 3 does not kno" & "w the command" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OLGA WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on saving is on at the start: Saving i" & "s already turned on" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     MOVE "commands.save.alreadyOn()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on off first" TO TL-CASE
     MOVE "save-off" TO WS-LINE
     MOVE "commands.save.disabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on save-on: Automatic saving is now en" & "abled" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     MOVE "commands.save.enabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on the other operator is sent both as " & "chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Automatic saving is now disabled) | cha" & "t.type.admin(Opal,Automatic saving is now enabled)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on the automatic saving is on" TO TL-CASE
     MOVE BW-SAVE-OFF TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /save-on off again" TO TL-CASE
     MOVE "save-off" TO WS-LINE
     MOVE "commands.save.disabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-on the result is 1" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /save-on the console prints the failure text" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     MOVE "Saving is already turned on" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SAVE-ON.

 COPY CORETEST.
 COPY CMDTEST.
