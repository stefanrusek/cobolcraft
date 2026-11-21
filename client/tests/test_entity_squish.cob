*> Cube mob squish (34-6 7.2 and 7.4): the replica runs AbstractCubeMob.tick for slimes and magma cubes in ENTITIES-ANIM-TICK (landing sets the target squish to -0.5,
*> take-off to 1, then the decrease 0.6 or 0.9; the squish moves half way to the target each tick), the scale (r x n, n / r, r x n) takes it (ENTITY-CUBE-SCALE) and the
*> magma cube slices spread with it (EF6-MAGMA-ANIM).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-SQUISH.
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
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-XZ                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-H1                  FLOAT-LONG.
 01 WS-H2                  FLOAT-LONG.
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
*>   A slime on the ground: the first tick is a landing (was on ground false): target -0.5 x 0.6.
     MOVE "slime" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish landing target" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) + 0.3
     PERFORM CHECK-SMALL
     MOVE "acceptance squish first tick keeps squish 0" TO TL-CASE
     MOVE EN-SQ(1) TO WS-DIFF
     PERFORM CHECK-SMALL
     MOVE "acceptance squish was on ground set" TO TL-CASE
     MOVE EN-WOG(1) TO WS-DIFF
     COMPUTE WS-DIFF = WS-DIFF - 1
     PERFORM CHECK-SMALL
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish second tick moves half way to the target" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ(1) + 0.15
     PERFORM CHECK-SMALL
     MOVE "acceptance squish old squish" TO TL-CASE
     MOVE EN-SQ-OLD(1) TO WS-DIFF
     PERFORM CHECK-SMALL
     MOVE "acceptance squish target decreases by 0.6" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) + 0.18
     PERFORM CHECK-SMALL
*>   Take-off: target 1 x 0.6; in the air without a change the target keeps decreasing.
     MOVE 0 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish take-off target" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) - 0.6
     PERFORM CHECK-SMALL
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish in the air the target decreases" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) - 0.36
     PERFORM CHECK-SMALL
*>   A magma cube decreases by 0.9; another mob has no squish.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "magma_cube" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish magma cube landing target" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) + 0.45
     PERFORM CHECK-SMALL
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squish a cow has none" TO TL-CASE
     COMPUTE WS-DIFF = EN-SQ-TGT(1) + EN-SQ(1) + EN-WOG(1)
     PERFORM CHECK-SMALL
*>   The scale of 34-6 15.3.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "slime" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 2 TO EN-VAR(1)
     MOVE 0.5 TO EN-SQ(1)
     MOVE 1 TO WS-ROW
     CALL "ENTITY-CUBE-SCALE" USING CLIENT-STATE WS-ROW WS-XZ WS-SY
     MOVE "acceptance squish scale size 2 xz" TO TL-CASE
     COMPUTE WS-DIFF = WS-XZ - 1.6
     PERFORM CHECK-SMALL
     MOVE "acceptance squish scale size 2 y" TO TL-CASE
     COMPUTE WS-DIFF = WS-SY - 2.5
     PERFORM CHECK-SMALL
     MOVE 4 TO EN-VAR(1)
     MOVE -0.3 TO EN-SQ(1)
     CALL "ENTITY-CUBE-SCALE" USING CLIENT-STATE WS-ROW WS-XZ WS-SY
     MOVE "acceptance squish scale size 4 xz" TO TL-CASE
     COMPUTE WS-DIFF = WS-XZ - 4.4444444
     PERFORM CHECK-SMALL
     MOVE "acceptance squish scale size 4 y" TO TL-CASE
     COMPUTE WS-DIFF = WS-SY - 3.6
     PERFORM CHECK-SMALL
     MOVE -1 TO EN-VAR(1)
     MOVE 0 TO EN-SQ(1)
     CALL "ENTITY-CUBE-SCALE" USING CLIENT-STATE WS-ROW WS-XZ WS-SY
     MOVE "acceptance squish scale unknown size is 1" TO TL-CASE
     COMPUTE WS-DIFF = WS-XZ + WS-SY - 2
     PERFORM CHECK-SMALL
*>   Drawn: a slime of size 2 grows 25 percent taller at squish 0.5.
     MOVE 2 TO EN-VAR(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM EXTENT
     MOVE WS-DIFF TO WS-H1
     MOVE 0.5 TO EN-SQ(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM EXTENT
     MOVE WS-DIFF TO WS-H2
     MOVE "acceptance squish drawn slime is 25 percent taller" TO TL-CASE
     COMPUTE WS-DIFF = WS-H2 / WS-H1 - 1.25
     PERFORM CHECK-NEAR
*>   A magma cube at squish 0.5 (size 1: scale y 1.3333): the slices spread to 13.95 / 8 of the height.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "magma_cube" TO WS-KEY
     PERFORM SPAWN-ONE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM EXTENT
     MOVE WS-DIFF TO WS-H1
     MOVE 0.5 TO EN-SQ(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM EXTENT
     MOVE WS-DIFF TO WS-H2
     MOVE "acceptance squish drawn magma cube slices spread" TO TL-CASE
     COMPUTE WS-DIFF = WS-H2 / WS-H1 - 2.325
     PERFORM CHECK-NEAR
     STOP RUN.
 SPAWN-ONE.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW.
 EXTENT.
     MOVE 1000 TO WS-MIN
     MOVE -1000 TO WS-MAX
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         IF RL-EN-Y(WS-J) < WS-MIN
             MOVE RL-EN-Y(WS-J) TO WS-MIN
         END-IF
         IF RL-EN-Y(WS-J) > WS-MAX
             MOVE RL-EN-Y(WS-J) TO WS-MAX
         END-IF
     END-PERFORM
     COMPUTE WS-DIFF = WS-MAX - WS-MIN.
 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001 AND WS-DIFF > -0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-NEAR.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.02 AND WS-DIFF > -0.02
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-SQUISH.

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

