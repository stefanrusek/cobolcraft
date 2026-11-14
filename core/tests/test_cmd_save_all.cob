*> Acceptance test of docs/protocol/16-commands-catalog.md §11.9 `save-all [flush]` (permission level 4, dedicated): commands.save.saving (not broadcast),
*> the world is saved (WORLD-SAVE: the world folder holds level.dat) and commands.save.success (broadcast); the result is 1.
*> Opal holds level 4; Olga is an operator at level 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SAVE-ALL.
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
 01 WS-LIST                BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-NAME-OLGA           PIC X(16) VALUE "Olga".
 01 WS-LEN-OLGA            BINARY-LONG VALUE 4.
 01 WS-STATUS              BINARY-LONG.
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
     MOVE "acceptance US13 /save-all an operator of level 3 does not kn" & "ow the command" TO TL-CASE
     MOVE "save-all" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OLGA WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-all the world is saved: Saving the gam" & "e, then Saved the game" TO TL-CASE
     MOVE "save-all" TO WS-LINE
     MOVE "commands.save.saving() | commands.save.success()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-all the other operator is sent the suc" & "cess as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Saved the game)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-all the flush form" TO TL-CASE
     MOVE "save-all flush" TO WS-LINE
     MOVE "commands.save.saving() | commands.save.success()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /save-all the result is 1" TO TL-CASE
     MOVE "save-all" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-DISCARD
     MOVE "acceptance US13 /save-all the console prints the English tex" & "t" TO TL-CASE
     MOVE "save-all" TO WS-LINE
     MOVE "Saving the game (this may take a moment!) | Saved the game" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-SAVE-ALL.

 COPY CORETEST.
 COPY CMDTEST.
