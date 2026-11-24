*> Acceptance test of docs/protocol/16-commands-catalog.md §11.12 `stop` (permission level 4, dedicated): commands.stop.stopping (broadcast) and the
*> run state becomes 1 (stop requested, CORE-STATUS-GET); the result is 1; an operator of level 3 does not see the command.
*> Opal holds level 4; Olga is an operator at level 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-OLGA           BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Olga" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OLGA
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE 1 TO WS-LIST
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME-OLGA WS-LEN-OLGA WS-UUID
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE 3 TO AC-LEVEL(1, WS-ROW)
     MOVE "acceptance US13 /stop an operator of level 3 does not know t" & "he command" TO TL-CASE
     MOVE "stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OLGA WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /stop the run state is still 0" TO TL-CASE
     MOVE CW-RUN-STATE TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /stop an operator of level 4 stops the serve" & "r" TO TL-CASE
     MOVE "stop" TO WS-LINE
     MOVE "commands.stop.stopping()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /stop the run state is 1: stop requested" TO TL-CASE
     MOVE CW-RUN-STATE TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /stop the other operator is sent the command" & " as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Stopping the server)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OLGA WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 0 TO CW-RUN-STATE
     MOVE "acceptance US13 /stop the result is 1" TO TL-CASE
     MOVE "stop" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE 0 TO CW-RUN-STATE
     MOVE "acceptance US13 /stop a player without operator status does " & "not know the command" TO TL-CASE
     MOVE "stop" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-CLEO WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /stop the console prints the English text" TO TL-CASE
     MOVE "stop" TO WS-LINE
     MOVE "Stopping the server" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-STOP.

 COPY CORETEST.
 COPY CMDTEST.
