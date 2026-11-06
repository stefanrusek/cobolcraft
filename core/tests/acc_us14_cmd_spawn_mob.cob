*> Acceptance test, US14-2 conjure (spec US14 scenario 2; FR-016; standin-content §16.2 row 22, §12):
*> the spawn-mob command creates one mob of the given type (sodgrazer or abend) at the position with
*> yaw 0 and full health, ignoring §12.4's conditions and caps; viewers are sent it; the sender is
*> sent cobolcraft.command.conjure.done [mob path, x, y, z, dimension path]. Extra dimensions are on;
*> no ticks run, so no mob spawns by itself.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-SPAWN-MOB.
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
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 when an operator conjures a sodgrazer then the sender is "
         & "sent conjure.done with the mob path, the position and the dimension path" TO TL-CASE
     MOVE "conjure sodgrazer 10 60 12.5" TO WS-LINE
     MOVE "cobolcraft.command.conjure.done(sodgrazer,10.00,60.00,12.50,main)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a sodgrazer with full health is at the position in the "
         & "sender's dimension" TO TL-CASE
     PERFORM MOBS-OF
     MOVE "1:2@10.00,60.00,12.50/8" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 viewers are sent the new mob (Add Entity)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 a mob may be conjured in another enabled dimension, "
         & "ignoring the spawning conditions" TO TL-CASE
     MOVE "conjure abend 1 40 1 subroutine" TO WS-LINE
     MOVE "cobolcraft.command.conjure.done(abend,1.00,40.00,1.00,subroutine)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the abend, with full health and yaw 0, is in the "
         & "subroutine" TO TL-CASE
     PERFORM MOBS-OF
     MOVE SPACES TO TL-OBSERVED
     MOVE "1:2@10.00,60.00,12.50/8 2:3@1.00,40.00,1.00/12" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 an unknown mob type sends mob_not_found with the word as "
         & "typed" TO TL-CASE
     MOVE "conjure dragon 1 60 1" TO WS-LINE
     MOVE "cobolcraft.command.mob_not_found(dragon)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a dimension that does not exist sends dimension_not_found" TO TL-CASE
     MOVE "conjure sodgrazer 1 60 1 nowhere" TO WS-LINE
     MOVE "cobolcraft.command.dimension_not_found(nowhere)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM JOIN-OPAL
     MOVE "acceptance US14-2 conjuring an abend while hostile-mobs is off sends "
         & "conjure.hostile_disabled" TO TL-CASE
     MOVE "conjure abend 1 60 1" TO WS-LINE
     MOVE "cobolcraft.command.conjure.hostile_disabled(abend)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 no abend was conjured while hostile mobs are off" TO TL-CASE
     PERFORM MOBS-OF
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-TEXT
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

*> WS-TEXT: every mob of the tracker as "<dimension>:<type>@<x>,<y>,<z>/<health>" (one decimal).
 MOBS-OF.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) >= 2
             IF WS-N > 1
                 STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
             MOVE EN-DIM(WS-I) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) ":" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             MOVE EN-TYPE(WS-I) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) "@" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             COMPUTE WS-DEDIT ROUNDED = EN-X(WS-I)
             STRING FUNCTION TRIM(WS-DEDIT) "," DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             COMPUTE WS-DEDIT ROUNDED = EN-Y(WS-I)
             STRING FUNCTION TRIM(WS-DEDIT) "," DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             COMPUTE WS-DEDIT ROUNDED = EN-Z(WS-I)
             STRING FUNCTION TRIM(WS-DEDIT) "/" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             MOVE EN-HEALTH(WS-I) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 END PROGRAM ACC-US14-CMD-SPAWN-MOB.

 COPY CORETEST.
