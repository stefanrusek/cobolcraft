*> Squid and fish state of the replica and the render sequences of 34-8 sections 2.2 and 5: ENTITY-IN-WATER (the cell at the middle of the entity's box holds water: ST-FLUID 1),
*> ENTITIES-ANIM-TICK (the squid's tentacle movement, rotate speed and body rotations from EF8-SQUID-TENTACLE and EF8-SQUID-BODY with the position change as delta movement; the
*> dry flag EN-DRY of the aquatic mobs), ENTITY-EVENT (event 19 resets the tentacle movement), ENTITY-SQUID-SEQUENCE and ENTITY-FISH-SEQUENCE (the setupRotations op lists).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-SQUID.
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
 01 WS-WET                 BINARY-LONG.
 01 WS-EV                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SUM1                FLOAT-LONG.
 01 WS-SUM2                FLOAT-LONG.
 01 WS-LIB-IN.
    05 WS-LI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-LIB-OUT.
    05 WS-LO               FLOAT-LONG OCCURS 64 TIMES.
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
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 1 TO ST-FLUID(5)
     MOVE 0 TO ST-LEVEL(5) ST-OPAQUE(5)
     MOVE 4 TO WS-STATE
*>   A block of water at (10, 64, 10) only.
     MOVE 10 TO WS-BX WS-BZ
     MOVE 64 TO WS-BY
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "squid" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO WS-ROW
     CALL "ENTITY-IN-WATER" USING CLIENT-STATE WS-ROW WS-WET
     MOVE "acceptance squid in water at a water cell" TO TL-CASE
     MOVE WS-WET TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 80 TO EN-Y(1)
     CALL "ENTITY-IN-WATER" USING CLIENT-STATE WS-ROW WS-WET
     MOVE "acceptance squid not in water at an air cell" TO TL-CASE
     MOVE WS-WET TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   The tick in water: the library's values with the squid's state (movement 0.5, speed 0.15, rotate speed 0.5).
     MOVE 64 TO EN-Y(1)
     MOVE 64 TO EN-OY(1)
     MOVE 0.5 TO EN-TM(1)
     MOVE 0.15 TO EN-TS(1)
     MOVE 0.5 TO EN-RS(1)
     MOVE 0 TO EN-XR(1) EN-ZR(1)
     MOVE 0.5 TO WS-LI(1)
     MOVE 0.15 TO WS-LI(2)
     MOVE 1 TO WS-LI(3)
     MOVE 0.5 TO WS-LI(4)
     CALL "EF8-SQUID-TENTACLE" USING WS-LIB-IN WS-LIB-OUT
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squid tick movement" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - WS-LO(1)
     PERFORM CHECK-SMALL
     MOVE "acceptance squid tick tentacle angle" TO TL-CASE
     COMPUTE WS-DIFF = EN-TA(1) - WS-LO(2)
     PERFORM CHECK-SMALL
     MOVE "acceptance squid tick rotate speed" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - WS-LO(3)
     PERFORM CHECK-SMALL
     MOVE "acceptance squid tick zBodyRot grows by pi x rotateSpeed x 1.5" TO TL-CASE
     COMPUTE WS-DIFF = EN-ZR(1) - 3.1415927 * WS-LO(3) * 1.5
     PERFORM CHECK-SMALL
     MOVE "acceptance squid at rest in water xBodyRot stays 0" TO TL-CASE
     MOVE EN-XR(1) TO WS-DIFF
     PERFORM CHECK-SMALL
     MOVE "acceptance squid in water is not dry" TO TL-CASE
     MOVE EN-DRY(1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   Moving east by 0.2 a tick in water: xBodyRot follows -atan2(h, vy) x 57.3 at 0.1 a tick.
     MOVE 11 TO EN-OX(1)
     MOVE 10.8 TO EN-X(1)
     MOVE 10.5 TO EN-Z(1) EN-OZ(1)
     MOVE 0 TO EN-XR(1)
     MOVE 1 TO WS-BX
     MOVE 64 TO WS-BY
     MOVE 10 TO WS-BZ
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squid moving xBodyRot is pulled toward the heading" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-XR(1) < -0.1
         MOVE 1 TO TL-OBSERVED-N
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     PERFORM CHECK-N
*>   Out of water: dry, the angle |sin| x pi / 4, xBodyRot toward -90 by 0.02.
     MOVE 80 TO EN-Y(1) EN-OY(1)
     MOVE 10.5 TO EN-X(1) EN-OX(1)
     MOVE 1 TO EN-TM(1)
     MOVE 0.1 TO EN-TS(1)
     MOVE 0 TO EN-XR(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance squid dry flag" TO TL-CASE
     MOVE EN-DRY(1) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance squid dry tentacle angle" TO TL-CASE
     COMPUTE WS-DIFF = EN-TA(1) - FUNCTION ABS(FUNCTION SIN(1.1)) * 3.1415927 * 0.25
     PERFORM CHECK-SMALL
     MOVE "acceptance squid dry xBodyRot toward -90" TO TL-CASE
     COMPUTE WS-DIFF = EN-XR(1) + 1.8
     PERFORM CHECK-SMALL
*>   Event 19 resets the movement; another event and an unknown entity change nothing.
     MOVE 19 TO WS-EV
     MOVE 1 TO WS-ID
     CALL "ENTITY-EVENT" USING CLIENT-STATE WS-ID WS-EV
     MOVE "acceptance squid event 19 resets the tentacle movement" TO TL-CASE
     MOVE EN-TM(1) TO WS-DIFF
     PERFORM CHECK-SMALL
     MOVE 2 TO EN-TM(1)
     MOVE 3 TO WS-EV
     CALL "ENTITY-EVENT" USING CLIENT-STATE WS-ID WS-EV
     MOVE "acceptance squid event 3 keeps the movement" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - 2
     PERFORM CHECK-SMALL
     MOVE 19 TO WS-EV
     MOVE 99 TO WS-ID
     CALL "ENTITY-EVENT" USING CLIENT-STATE WS-ID WS-EV
     MOVE "acceptance squid event of an unknown entity" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - 2
     PERFORM CHECK-SMALL
*>   The speed given at spawn lies in 0.1 to 0.2 (21 section 4.5).
     MOVE "acceptance squid spawn speed in range" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "squid" TO WS-KEY
     PERFORM SPAWN-ONE
     IF EN-TS(1) >= 0.1 AND EN-TS(1) <= 0.2
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   The squid op list (34-8 2.2): translate, yaw, X, Y (zBodyRot), translate, then (-1, -1, 1) and (0, -1.501, 0).
     MOVE 30 TO EN-YAW(1)
     MOVE 10 TO EN-XR(1)
     MOVE 20 TO EN-ZR(1)
     MOVE 0 TO EN-BABY(1)
     CALL "ENTITY-SQUID-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance squid sequence op count" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(1) - 7
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence translate y" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(2) - 1 + WS-OV(4) - 0.5
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence yaw" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(6) - 3 + WS-OV(7) - 150
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence xBodyRot" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(10) - 5 + WS-OV(11) - 10
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence zBodyRot about Y" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(14) - 3 + WS-OV(15) - 20
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence closing translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(18) - 1 + WS-OV(20) + 1.2
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence scale" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(22) - 2 + WS-OV(23) + 1 + WS-OV(24) + 1 + WS-OV(25) - 1
     PERFORM CHECK-SMALL
     MOVE "acceptance squid sequence last translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(26) - 1 + WS-OV(28) + 1.501
     PERFORM CHECK-SMALL
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-SQUID-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance squid sequence baby translates" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(4) - 0.25 + WS-OV(20) + 0.6
     PERFORM CHECK-SMALL
*>   Fish: cod in water: yaw, wiggle 4.3 sin(0.6 age), scale, translate.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cod" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 5 TO EN-AGE(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance cod sequence op count" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(1) - 4
     PERFORM CHECK-SMALL
     MOVE "acceptance cod sequence wiggle" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(6) - 3 + WS-OV(7) - 4.3 * FUNCTION SIN(3)
     PERFORM CHECK-SMALL
*>   Out of water the cod lies on its side: translate (0.1, 0.1, -0.1) and Z 90 after the wiggle.
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance cod dry sequence op count" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(1) - 6
     PERFORM CHECK-SMALL
     MOVE "acceptance cod dry translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(10) - 1 + WS-OV(11) - 0.1 + WS-OV(12) - 0.1 + WS-OV(13) + 0.1
     PERFORM CHECK-SMALL
     MOVE "acceptance cod dry rotate Z 90" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(14) - 7 + WS-OV(15) - 90
     PERFORM CHECK-SMALL
*>   Salmon dry: a = 1.3, b = 1.7, translate (0.2, 0.1, 0); tropical fish dry the same translate, wiggle a = b = 1.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "salmon" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 5 TO EN-AGE(1)
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance salmon dry wiggle" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(7) - 1.3 * 4.3 * FUNCTION SIN(1.7 * 0.6 * 5)
     PERFORM CHECK-SMALL
     MOVE "acceptance salmon dry translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(11) - 0.2 + WS-OV(12) - 0.1 + WS-OV(13)
     PERFORM CHECK-SMALL
     MOVE 0 TO EN-DRY(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance salmon wet wiggle" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(7) - 4.3 * FUNCTION SIN(0.6 * 5)
     PERFORM CHECK-SMALL
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "tropical_fish" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 5 TO EN-AGE(1)
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance tropical fish dry translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(11) - 0.2 + WS-OV(12) - 0.1 + WS-OV(13)
     PERFORM CHECK-SMALL
*>   Pufferfish: the bobbing translate first, no wiggle, no lying.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "pufferfish" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 40 TO EN-AGE(1)
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-ROW WS-OPS
     MOVE "acceptance pufferfish sequence op count" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(1) - 4
     PERFORM CHECK-SMALL
     MOVE "acceptance pufferfish bobbing translate" TO TL-CASE
     COMPUTE WS-DIFF = WS-OV(2) - 1 + WS-OV(4) - FUNCTION COS(2) * 0.08
     PERFORM CHECK-SMALL
*>   Drawn: the squid with another zBodyRot, a cod lying on its side.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "squid" TO WS-KEY
     PERFORM SPAWN-ONE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 45 TO EN-ZR(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance squid drawn with another zBodyRot" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 0.5 TO EN-TA(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance squid drawn with another tentacle angle" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cod" TO WS-KEY
     PERFORM SPAWN-ONE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance cod drawn out of water" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
*>   A turtle: EN-DRY is isOnLand (not in water and on the ground, 34-5 14), drawn with the land gait.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "turtle" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 80 TO EN-Y(1) EN-OY(1)
     MOVE 1 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance turtle in the air on the ground is on land" TO TL-CASE
     MOVE EN-DRY(1) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 0 TO EN-ON-GROUND(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance turtle in the air off the ground is not on land" TO TL-CASE
     MOVE EN-DRY(1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(1)
     MOVE 10.5 TO EN-X(1) EN-OX(1)
     MOVE 10.5 TO EN-Z(1) EN-OZ(1)
     MOVE 64 TO EN-Y(1) EN-OY(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance turtle in water is not on land" TO TL-CASE
     MOVE EN-DRY(1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 1 TO EN-WALK-SPEED(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 1 TO EN-DRY(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance turtle drawn on land" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     STOP RUN.
 SPAWN-ONE.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
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
 END PROGRAM TEST-ENTITY-SQUID.

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


 COPY CLTEST.
