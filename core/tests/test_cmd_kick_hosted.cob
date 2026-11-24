*> Acceptance test of docs/protocol/16-commands-catalog.md §11.8 `kick` in worlds hosted by the client: in a single-player world (host kind 1) it
*> fails with commands.kick.singleplayer.failed before anyone is touched; in a world opened to others (host kind 2) the host (the
*> owner) is never kicked: kicking only the host is commands.kick.owner.failed and a guest is kicked. Hosty is the host and holds
*> operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-KICK-HOSTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-HOSTY          BINARY-LONG.
 01 WS-ID-GUEST          BINARY-LONG.
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
     MOVE 1 TO CS-HOST-KIND
     MOVE "Hosty" TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Hosty" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-HOSTY
     MOVE "Guest" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-GUEST
     CALL "TEST-DRAIN-CHAT" USING WS-ID-HOSTY WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-GUEST WS-DISCARD
     MOVE "acceptance US13 /kick in a single-player world kick fails (n" & "ot published)" TO TL-CASE
     MOVE "kick Guest" TO WS-LINE
     MOVE "commands.kick.singleplayer.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-HOSTY WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 2 TO CS-HOST-KIND
     MOVE "Hosty" TO CS-HOST-NAME
     MOVE 1 TO CS-GUEST-OPERATOR
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Hosty" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-HOSTY
     MOVE "Guest" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-GUEST
     CALL "TEST-DRAIN-CHAT" USING WS-ID-HOSTY WS-DISCARD
     MOVE "acceptance US13 /kick the owner is not kicked: Cannot kick t" & "he server owner in a LAN game" TO TL-CASE
     MOVE "kick Hosty" TO WS-LINE
     MOVE "commands.kick.owner.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-HOSTY WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /kick a guest is kicked in a world opened to" & " others" TO TL-CASE
     MOVE "kick Guest" TO WS-LINE
     MOVE "commands.kick.success(Guest,Kicked by an operator)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-HOSTY WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-KICK-HOSTED.

 COPY CORETEST.
 COPY CMDTEST.
