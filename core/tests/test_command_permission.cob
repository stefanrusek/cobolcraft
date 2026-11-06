*> Implementation test of the command permission check (core/src/commands.cob CMD-PERMITTED;
*> core/src/access.cob ACCESS-OPERATOR-STATUS; standin-content §16.1 "Permission", FR-016,
*> data-model §10): the console always has operator permission; a player may use the everyone
*> commands, and the operator commands iff they hold operator status. Operator status: a player on
*> the world's operator list; the host of a single-player world (host kind 1) or of a world opened
*> to others (kind 2); a guest of an opened world only when the host allowed it
*> (CS-GUEST-OPERATOR = 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-PERMISSION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY COMMANDS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ID                  BINARY-LONG.
 01 WS-SENDER              BINARY-LONG.
 01 WS-PERMISSION          BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-EVERYONE            BINARY-LONG.
 01 WS-OPERATOR            BINARY-LONG.
 01 WS-E                   PIC 9.
 01 WS-O                   PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "test command permission the console may use everyone and operator commands" TO TL-CASE
     MOVE 0 TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "test command permission a player without operator status (dedicated server) may use "
         & "only the everyone commands" TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "test command permission a player holding operator status may use operator commands"
         TO TL-CASE
     MOVE 1 TO PL-OPERATOR(WS-SENDER)
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "test command permission a player on the world's operator list holds operator status "
         & "when they join" TO TL-CASE
     MOVE "Opal1" TO WS-NAME
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Single-player world (host kind 1): the host holds operator status.
     MOVE 1 TO CS-HOST-KIND
     MOVE "Hosty" TO CS-HOST-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Hosty" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "test command permission the host of a single-player world (host kind 1) holds "
         & "operator status" TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   World opened to others (host kind 2), guests not allowed operator commands.
     MOVE 2 TO CS-HOST-KIND
     MOVE 0 TO CS-GUEST-OPERATOR
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Hosty" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "test command permission the host of a world opened to others (host kind 2) holds "
         & "operator status" TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "Guest" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "test command permission a guest does not hold operator status when CS-GUEST-OPERATOR "
         & "is 0" TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   Guests allowed operator commands.
     MOVE 1 TO CS-GUEST-OPERATOR
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Guest" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID
     MOVE "test command permission a guest holds operator status when CS-GUEST-OPERATOR is 1"
         TO TL-CASE
     MOVE CN-PLAYER(WS-ID) TO WS-SENDER
     PERFORM CHECK-BOTH
     MOVE "everyone 1 operator 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     STOP RUN.

 CHECK-BOTH.
     MOVE CMD-EVERYONE TO WS-PERMISSION
     CALL "CMD-PERMITTED" USING WS-SENDER WS-PERMISSION WS-EVERYONE
     MOVE CMD-OPERATOR TO WS-PERMISSION
     CALL "CMD-PERMITTED" USING WS-SENDER WS-PERMISSION WS-OPERATOR
     MOVE WS-EVERYONE TO WS-E
     MOVE WS-OPERATOR TO WS-O
     MOVE SPACES TO TL-OBSERVED
     STRING "everyone " WS-E " operator " WS-O DELIMITED BY SIZE
         INTO TL-OBSERVED.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-COMMAND-PERMISSION.

 COPY CORETEST.
