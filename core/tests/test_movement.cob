*> Implementation test of movement validation (core/src/movement.cob MOVE-PLAYER, MOVE-COLLIDES;
*> tasks T413; US3-2; standin-content §3 player box 0.7 x 1.75; 05c "Accept Teleportation"). A
*> joined player (view distance 2, spawn (4.5, 54.0, 8.5)) moves over memory connections.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOVEMENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-REAL                FLOAT-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-IDS                 PIC X(1024).
 01 WS-TP-ID               BINARY-LONG.
 01 WS-TP-X                FLOAT-LONG.
 01 WS-TP-Y                FLOAT-LONG.
 01 WS-TP-Z                FLOAT-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-REAL           PIC -(6)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW

     MOVE "test movement: a Move Player Pos into open space one step east of the spawn is "
         & "accepted: the position is stored and nothing is sent" TO TL-CASE
     MOVE 30 TO WS-PACKET
     MOVE 5.25 TO WS-X
     MOVE 54.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM MOVE-AND-DRAIN
     PERFORM START-ROW
     PERFORM ADD-POSITION
     PERFORM ADD-IDS
     MOVE "5.25 54.00 8.50 [] " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement (US3-2): given a player walking when the move would put the "
         & "player box inside solid ground then the player is sent Player Position at the last "
         & "valid position with teleport id 2" TO TL-CASE
     MOVE 50.0 TO WS-Y
     PERFORM MOVE-AND-DRAIN
     PERFORM START-ROW
     PERFORM ADD-POSITION
     PERFORM ADD-IDS
     MOVE CN-TELEPORT-ID(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-TELEPORT-ACKED(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     PERFORM READ-POSITION-PACKET
     MOVE "5.25 54.00 8.50 [73] 2 0 2 5.25 54.00 8.50 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement: while that Player Position is not accepted, moves are ignored" TO TL-CASE
     MOVE 6.0 TO WS-X
     MOVE 54.0 TO WS-Y
     PERFORM MOVE-AND-DRAIN
     PERFORM START-ROW
     PERFORM ADD-POSITION
     PERFORM ADD-IDS
     MOVE "5.25 54.00 8.50 [] " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement: after Accept Teleportation of id 2 a Move Player Pos Rot is accepted "
         & "with its rotation" TO TL-CASE
     CALL "TEST-ACCEPT-TELEPORT" USING WS-CONN
     MOVE 31 TO WS-PACKET
     MOVE 45 TO WS-YAW
     MOVE 30 TO WS-PITCH
     PERFORM MOVE-AND-DRAIN
     PERFORM START-ROW
     PERFORM ADD-POSITION
     PERFORM ADD-ROTATION
     PERFORM ADD-IDS
     MOVE "6.00 54.00 8.50 45.00 30.00 [] " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement: a Move Player Rot changes only the rotation" TO TL-CASE
     MOVE 32 TO WS-PACKET
     MOVE 9.0 TO WS-X
     MOVE -90 TO WS-YAW
     MOVE -10 TO WS-PITCH
     PERFORM MOVE-AND-DRAIN
     PERFORM START-ROW
     PERFORM ADD-POSITION
     PERFORM ADD-ROTATION
     MOVE "6.00 54.00 8.50 -90.00 -10.00 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   A block of greystone placed in the air at (10, 100, 8): the box touches it without overlap.
     MOVE 10 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 8 TO WS-BZ
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "test movement: a box whose east face touches a solid block's west face does not "
         & "collide; one 0.05 further east does" TO TL-CASE
     PERFORM START-ROW
     MOVE 9.65 TO WS-X
     MOVE 100.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     PERFORM ADD-HIT
     MOVE 9.7 TO WS-X
     PERFORM ADD-HIT
     MOVE "0 1 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement: standing on the block (feet at its top face) does not collide; feet 0.1 "
         & "lower, and a head 1.75 high reaching into it from below, do" TO TL-CASE
     PERFORM START-ROW
     MOVE 10.5 TO WS-X
     MOVE 101.0 TO WS-Y
     PERFORM ADD-HIT
     MOVE 100.9 TO WS-Y
     PERFORM ADD-HIT
     MOVE 98.3 TO WS-Y
     PERFORM ADD-HIT
     MOVE 98.25 TO WS-Y
     PERFORM ADD-HIT
     MOVE "0 1 1 0 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test movement: the box is 0.7 wide on z as well: touching the block's north face "
         & "from z 7.65 does not collide, z 7.7 does" TO TL-CASE
     PERFORM START-ROW
     MOVE 100.0 TO WS-Y
     MOVE 10.5 TO WS-X
     MOVE 7.65 TO WS-Z
     PERFORM ADD-HIT
     MOVE 7.7 TO WS-Z
     PERFORM ADD-HIT
     MOVE "0 1 " TO TL-EXPECTED
     PERFORM ASSERT-ROW
     STOP RUN.

 MOVE-AND-DRAIN.
     CALL "TEST-MOVE" USING WS-CONN WS-PACKET WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     MOVE SPACES TO WS-IDS
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 73
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-TP-ID
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TP-X
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TP-Y
             CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-TP-Z
         END-IF
         IF WS-OUTCOME = 0
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-IDS) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
                 INTO WS-IDS
         END-IF
     END-PERFORM.

*> The teleport id and position of the last Player Position MOVE-AND-DRAIN saw.
 READ-POSITION-PACKET.
     MOVE WS-TP-ID TO WS-NUM
     PERFORM ADD-NUM
     MOVE WS-TP-X TO WS-REAL
     PERFORM ADD-REAL
     MOVE WS-TP-Y TO WS-REAL
     PERFORM ADD-REAL
     MOVE WS-TP-Z TO WS-REAL
     PERFORM ADD-REAL.

 ADD-HIT.
     CALL "MOVE-COLLIDES" USING WS-DIM WS-X WS-Y WS-Z WS-HIT
     MOVE WS-HIT TO WS-NUM
     PERFORM ADD-NUM.

 ADD-POSITION.
     MOVE PL-X(WS-ROW) TO WS-REAL
     PERFORM ADD-REAL
     MOVE PL-Y(WS-ROW) TO WS-REAL
     PERFORM ADD-REAL
     MOVE PL-Z(WS-ROW) TO WS-REAL
     PERFORM ADD-REAL.

 ADD-ROTATION.
     MOVE PL-YAW(WS-ROW) TO WS-REAL
     PERFORM ADD-REAL
     MOVE PL-PITCH(WS-ROW) TO WS-REAL
     PERFORM ADD-REAL.

 ADD-IDS.
     STRING "[" FUNCTION TRIM(WS-IDS) "] " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 START-ROW.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR.

 ADD-NUM.
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 ADD-REAL.
     MOVE WS-REAL TO WS-EDIT-REAL
     STRING FUNCTION TRIM(WS-EDIT-REAL) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOVEMENT.

 COPY CORETEST.
