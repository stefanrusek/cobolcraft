*> Acceptance test, US14-2 sweep (spec US14 scenario 2; FR-016; standin-content §16.2 row 23): the
*> remove-entities command removes the matching mobs and ground items (mobs, items, a mob type path
*> or an item path) in every enabled dimension, or those whose position lies in the box of the two
*> corners in one dimension (bounds included), and sends the sender cobolcraft.command.sweep.done
*> [number removed]. Extra dimensions are on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-REMOVE-ENTITIES.
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
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
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
     MOVE "conjure sodgrazer 10 60 10" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "conjure sodgrazer 50 60 50" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "conjure abend 12 60 12" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "conjure sodgrazer 1 40 1 subroutine" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE 1 TO WS-DIM
     MOVE 11 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 11 TO WS-Z
     MOVE 2 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-ZERO WS-ROW
     MOVE 1 TO WS-DIM
     MOVE 13 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 13 TO WS-Z
     MOVE 3 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-ZERO WS-ROW
     MOVE 1 TO WS-DIM
     MOVE 20 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 20 TO WS-Z
     MOVE 4 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-ZERO WS-ROW
     MOVE 2 TO WS-DIM
     MOVE 2 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 2 TO WS-ITEM
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-ZERO WS-ROW
     MOVE "acceptance US14-2 sweeping a mob type in an area removes the mobs of that "
         & "type whose position lies in the box" TO TL-CASE
     MOVE "sweep sodgrazer area main 0 0 0 20 100 20" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(1)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 sweeping a mob type everywhere removes the mobs of that "
         & "type in every enabled dimension" TO TL-CASE
     MOVE "sweep sodgrazer everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(2)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 sweeping an item path everywhere removes the ground "
         & "items of that item" TO TL-CASE
     MOVE "sweep greystone everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(2)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 sweeping items in an area takes the box between the two "
         & "corners in any order, bounds included" TO TL-CASE
     MOVE "sweep items area main 20 100 20 13 0 13" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(2)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 after the sweeps only the abend is left and no ground "
         & "item" TO TL-CASE
     PERFORM COUNT-ENTITIES
     MOVE "1 mobs 0 items" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 sweeping mobs everywhere removes every mob" TO TL-CASE
     MOVE "sweep mobs everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(1)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 sweeping when nothing matches removes 0" TO TL-CASE
     MOVE "sweep mobs everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.done(0)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a target that is neither mobs, items, a mob type nor an "
         & "item sends sweep.unknown_target" TO TL-CASE
     MOVE "sweep junk everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.unknown_target(junk)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the item nothing is not a sweep target" TO TL-CASE
     MOVE "sweep nothing everywhere" TO WS-LINE
     MOVE "cobolcraft.command.sweep.unknown_target(nothing)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a dimension that does not exist sends dimension_not_found" TO TL-CASE
     MOVE "sweep items area nowhere 0 0 0 1 1 1" TO WS-LINE
     MOVE "cobolcraft.command.dimension_not_found(nowhere)" TO TL-EXPECTED
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

*> WS-TEXT: "<mobs> mobs <items> items" in the tracker.
 COUNT-ENTITIES.
     MOVE 0 TO WS-N WS-I
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) >= 2
             ADD 1 TO WS-N
         END-IF
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = 1
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     MOVE WS-N TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " mobs " DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-I TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) " items" DELIMITED BY SIZE
         INTO WS-AREA
     MOVE WS-AREA TO WS-TEXT.

 END PROGRAM ACC-US14-CMD-REMOVE-ENTITIES.

 COPY CORETEST.
