*> Acceptance test, US14-2 homestead (spec US14 scenario 2; FR-016; standin-content §16.2 row 26,
*> §5.2): the set-spawn command moves the world spawn point (always in cobolcraft:main, its yaw
*> unchanged); every player in main is sent Set Default Spawn Position, and the sender
*> cobolcraft.command.homestead.done [x, y, z]. Extra dimensions are on; Bob is in the subroutine.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-SET-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OPAL                BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONSOLE             BINARY-LONG VALUE 0.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-PATH                PIC X(256).
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-DEDIT               PIC -(9)9.99.
 01 WS-AREA                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "relocate Bob at 1 40 1 subroutine" TO WS-LINE
     PERFORM OPAL-RUN
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE "acceptance US14-2 when an operator moves the world spawn point then the "
         & "sender is sent homestead.done with the position" TO TL-CASE
     MOVE "homestead 10 60 -5.5" TO WS-LINE
     MOVE "cobolcraft.command.homestead.done(10.00,60.00,-5.50)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the world spawn point is the new position and its yaw is "
         & "unchanged" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     COMPUTE WS-DEDIT ROUNDED = CW-SPAWN-X
     STRING FUNCTION TRIM(WS-DEDIT) " " DELIMITED BY SIZE INTO WS-TEXT
     MOVE 1 TO WS-N
     COMPUTE WS-DEDIT ROUNDED = CW-SPAWN-Y
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-AREA
     COMPUTE WS-DEDIT ROUNDED = CW-SPAWN-Z
     STRING FUNCTION TRIM(WS-AREA) " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-TEXT
     COMPUTE WS-DEDIT ROUNDED = CW-SPAWN-YAW
     MOVE SPACES TO WS-AREA
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-AREA
     MOVE WS-AREA TO WS-TEXT
     MOVE "10.00 60.00 -5.50 -90.00" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 every player in main is sent Set Default Spawn Position" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "99" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 a player in the subroutine is not sent the spawn position" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the spawn point is always in main: y above main's top is "
         & "an invalid argument" TO TL-CASE
     MOVE "homestead 1 255 1" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(255,homestead <x> <y> <z>)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     STOP RUN.

*> Opal holds operator status through the world's operator list.
 JOIN-OPAL.
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OPAL.

*> Opal runs WS-LINE; WS-TEXT is the System Chat she is sent.
 OPAL-RUN.
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT.

 OPAL-CHECK.
     PERFORM OPAL-RUN
     PERFORM CHECK-TEXT.

*> The console runs WS-LINE; WS-TEXT is the console lines it printed, separated by " | ".
 CONSOLE-RUN.
     PERFORM CONSOLE-LINES
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "CMD-RUN" USING WS-CONSOLE WS-LINE WS-LENGTH
     PERFORM CONSOLE-LINES.

 CONSOLE-LINES.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 CHECK-TEXT.
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US14-CMD-SET-SPAWN.

 COPY CORETEST.
