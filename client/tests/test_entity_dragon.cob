*> Ender dragon flight history and flap time (34-7 8.1, 8.4, 8.5, 8.8): ENTITIES-ANIM-TICK records (y, wrapped yaw) of the dragon into the 64 sample ring EN-DR-HIST (a new dragon id restarts it
*> and fills it), advances flapTime (EN-TM) by 0.2 / (horizontal speed x 10 + 1) x 2^(vertical velocity); ENTITY-MODEL-EMIT poses the model with EF7-DRAGON-ANIM and the render
*> sequence of EF7-DRAGON-POSE-OPS (ENTITY-DRAGON-SEQUENCE).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-DRAGON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-ID                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SUM1                FLOAT-LONG.
 01 WS-SUM2                FLOAT-LONG.
 01 WS-OPS.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "ender_dragon" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO WS-ROW
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance dragon history belongs to the dragon" TO TL-CASE
     MOVE EN-DR-ID TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance dragon history first record fills the ring (y)" TO TL-CASE
     COMPUTE WS-DIFF = EN-DR-HY(1) - 64 + EN-DR-HY(64) - 64
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon history yaw" TO TL-CASE
     COMPUTE WS-DIFF = EN-DR-HR(33) - 90
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon history head" TO TL-CASE
     MOVE EN-DR-HEAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance dragon flap time of a dragon at rest" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - 0.2
     PERFORM CHECK-SMALL
*>   The second tick moves the head; a yaw of 270 is stored as -90; moving 1 block sideways and 1 up: f = 0.2 / 11 x 2.
     MOVE 270 TO EN-YAW(1)
     MOVE 11.5 TO EN-X(1)
     MOVE 65 TO EN-Y(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance dragon history head advances" TO TL-CASE
     MOVE EN-DR-HEAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance dragon history y of the sample" TO TL-CASE
     COMPUTE WS-DIFF = EN-DR-HY(2) - 65
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon history yaw is wrapped" TO TL-CASE
     COMPUTE WS-DIFF = EN-DR-HR(2) + 90
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon flap time speeds with the motion" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - 0.2 - 0.2 / 11 * 2
     PERFORM CHECK-SMALL
*>   The sequence of 8.5: rotate Y by -yaw(7), X by (y(5) - y(10)) x 10, translate (0, 0, 1), scale, translate.
     MOVE 90 TO EN-YAW(1)
     CALL "ENTITY-DRAGON-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance dragon sequence count" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(1) - 5
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon sequence yaw from the history" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(2) - 3 + WS-OV(3) + 90
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon sequence pitch code 5 (X)" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(6) - 5
     PERFORM CHECK-SMALL
     MOVE "acceptance dragon sequence closing translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(18) - 1 + WS-OV(20) + 1.501
     PERFORM CHECK-SMALL
*>   Another dragon id restarts the history; another mob has none.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "ender_dragon" TO WS-KEY
     MOVE 8 TO WS-ID
     PERFORM SPAWN-ID
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance dragon history restarts for another id" TO TL-CASE
     MOVE EN-DR-ID TO TL-OBSERVED-N
     MOVE 8 TO TL-EXPECTED-N
     PERFORM CHECK-N
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     PERFORM SPAWN-ONE
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance cow leaves the history alone" TO TL-CASE
     MOVE EN-DR-ID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   Drawn: the flap time moves the wings.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "ender_dragon" TO WS-KEY
     PERFORM SPAWN-ONE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 0.25 TO EN-TM(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance dragon drawn with another flap time" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     STOP RUN.
 SPAWN-ONE.
     MOVE 5 TO WS-ID
     PERFORM SPAWN-ID.
 SPAWN-ID.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW.
 SUM-MESH.
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM2 = WS-SUM2 + (RL-EN-Y(WS-J) + RL-EN-X(WS-J) * 2 + RL-EN-Z(WS-J) * 3) * WS-J
     END-PERFORM.
 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0001 AND WS-DIFF > -0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-OTHER.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF > 0.001 OR WS-DIFF < -0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-DRAGON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.


