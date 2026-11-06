*> Acceptance test, US14-2 relocate ... at (spec US14 scenario 2; FR-016; standin-content §16.2 row
*> 16, §15.5): the teleport command moves a player's feet to a position in any enabled dimension:
*> Player Position in the same dimension, Respawn and the join sequence of the new one otherwise
*> (as travel, without a goto_pad); the sender is sent cobolcraft.command.relocate.position [name,
*> x, y, z, dimension path]. Extra dimensions are on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-TELEPORT-POS.
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
     MOVE "acceptance US14-2 when an operator relocates Alice to a position in her "
         & "dimension then the sender is sent relocate.position with two decimals and the "
         & "dimension path" TO TL-CASE
     MOVE "relocate Alice at 10.5 60 12.5" TO WS-LINE
     MOVE "cobolcraft.command.relocate.position(Alice,10.50,60.00,12.50,main)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice is sent Player Position with the new feet position" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "position 10.5 60.0 12.5" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 Alice's position is the new one" TO TL-CASE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM POSITION-OF
     MOVE "1 10.50 60.00 12.50" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 when an operator relocates Alice to the subroutine then "
         & "the sender is sent relocate.position naming subroutine" TO TL-CASE
     MOVE "relocate Alice at 3.5 40 -3.5 subroutine" TO WS-LINE
     MOVE "cobolcraft.command.relocate.position(Alice,3.50,40.00,-3.50,subroutine)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 relocated to another dimension, Alice is sent Respawn "
         & "and the join sequence of that dimension (Player Position at the new feet)" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "respawn cobolcraft:subroutine mode 1 keep 3 | position 3.5 40.0 -3.5" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 Alice is now in the subroutine at the new position" TO TL-CASE
     PERFORM POSITION-OF
     MOVE "2 3.50 40.00 -3.50" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 with the dimension left out a player sender's dimension "
         & "is used: Opal, in main, brings Alice back to main" TO TL-CASE
     MOVE "relocate Alice at 1.5 50 1.5" TO WS-LINE
     MOVE "cobolcraft.command.relocate.position(Alice,1.50,50.00,1.50,main)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 with the dimension left out the console uses main" TO TL-CASE
     MOVE "relocate Alice at 2.5 50 2.5" TO WS-LINE
     PERFORM CONSOLE-RUN
     MOVE "Relocated Alice to 2.50, 50.00, 2.50 in main" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the relocations left Alice in main at the console's "
         & "position" TO TL-CASE
     PERFORM POSITION-OF
     MOVE "1 2.50 50.00 2.50" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 naming a player who is not online changes nothing and "
         & "sends the §16 player-not-found message (§16 target rule)" TO TL-CASE
     MOVE "relocate Zed at 1 50 1" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Zed)" TO TL-EXPECTED
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

*> WS-TEXT: the dimension row and feet position of player row WS-ROW, two decimals.
 POSITION-OF.
     MOVE SPACES TO WS-TEXT
     MOVE PL-DIM(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE 2 TO WS-N
     COMPUTE WS-DEDIT ROUNDED = PL-X(WS-ROW)
     STRING " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
     COMPUTE WS-DEDIT ROUNDED = PL-Y(WS-ROW)
     STRING " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
     COMPUTE WS-DEDIT ROUNDED = PL-Z(WS-ROW)
     STRING " " FUNCTION TRIM(WS-DEDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N.

 END PROGRAM ACC-US14-CMD-TELEPORT-POS.

 COPY CORETEST.
