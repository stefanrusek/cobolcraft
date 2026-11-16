 *> Nautilus swim animation (34-8 6.3, Appendix A.2), the zombie nautilus variants (6.4, 6.5: the warm variant is the coral model, entry 21 of the metadata, the corals
*> are hidden under body armor), the nautilus body armor (nautilus_body) and saddle (nautilus_saddle) layers; adults only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NAUTILUS-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-KEY20               PIC X(20).
 01 WS-IKEY                PIC X(40).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(400).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SUM1                FLOAT-LONG.
 01 WS-SUM2                FLOAT-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-LONG                BINARY-DOUBLE VALUE 0.
 01 WS-PATH                PIC X(64).
 01 WS-COUNT-A             BINARY-LONG.
 01 WS-IN.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
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
*>   The swim animation on the built adult nautilus.
     MOVE "nautilus" TO WS-KEY24
     CALL "ENTITY-MODEL-FIND" USING WS-KEY24 WS-MODEL
     CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-STATUS
     MOVE "body" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-BODY
     MOVE "upper_mouth" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-UP
     MOVE "inner_mouth" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-INNER
     MOVE "lower_mouth" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-LOW
*>   Body angles are clamped to 10 degrees (0.17453292 radians), set from the state.
     PERFORM CLEAR-IN
     MOVE 25 TO WS-IV(2)
     MOVE -30 TO WS-IV(1)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim y rotation clamps to 10 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-BODY) - 0.17453292
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim x rotation clamps to -10 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-BODY) + 0.17453292
     PERFORM CHECK-SMALL
     PERFORM CLEAR-IN
     MOVE -25 TO WS-IV(2)
     MOVE 4 TO WS-IV(1)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim y rotation clamps to -10 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-BODY) + 0.17453292
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim x rotation inside the range is kept" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-BODY) - 0.06981317
     PERFORM CHECK-SMALL
*>   Keyframe time 0.5 at full strength: the stretch of the body and mouths.
     PERFORM CLEAR-IN
     MOVE 5 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim t 0.5 body z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1.2
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 upper mouth x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-UP) - 0.5235988
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 upper mouth z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-UP) - 1.4
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 inner mouth x scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXSCALE(WS-INNER) - 0.8
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 inner mouth y scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYSCALE(WS-INNER) - 0.8
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 lower mouth x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-LOW) + 0.5235988
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.5 lower mouth z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-LOW) - 1.4
     PERFORM CHECK-SMALL
*>   Time 0.625, halfway between the keys 0.5 and 0.75.
     PERFORM CLEAR-IN
     MOVE 6.25 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim t 0.625 body z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1.05
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.625 upper mouth x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-UP) - 0.2617994
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.625 upper mouth z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-UP) - 1.15
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.625 inner mouth x scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXSCALE(WS-INNER) - 0.9
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim t 0.625 inner mouth z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-INNER) - 0.95
     PERFORM CHECK-SMALL
*>   Strength (speed + 0.2) x 3 below 1: speed 0 gives 0.6.
     PERFORM CLEAR-IN
     MOVE 5 TO WS-IV(3)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim strength 0.6 body z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1.12
     PERFORM CHECK-SMALL
     MOVE "acceptance nautilus anim strength 0.6 upper mouth x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-UP) - 0.31415927
     PERFORM CHECK-SMALL
*>   The animation loops (length 1 s): position 15 is time 0.5 again; ageInTicks / 5 adds to the position.
     PERFORM CLEAR-IN
     MOVE 15 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim loops: position 15 is time 0.5" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1.2
     PERFORM CHECK-SMALL
     PERFORM CLEAR-IN
     MOVE 25 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim age 25 adds 5 to the position" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1.2
     PERFORM CHECK-SMALL
*>   Times 0.8 (between 0.75 and 0.875) and 0.9375 (after the last change).
     PERFORM CLEAR-IN
     MOVE 8 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim t 0.8 body z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 0.94
     PERFORM CHECK-SMALL
     PERFORM CLEAR-IN
     MOVE 9.375 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN
     MOVE "acceptance nautilus anim t 0.9375 body z scale" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZSCALE(WS-BODY) - 1
     PERFORM CHECK-SMALL
*>   Drawn: a nautilus whose walk state is at the stretch draws other vertices than one at rest; the walk state is what the replica ticks.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE "nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 5 TO EN-WALK-POS(1)
     MOVE 0.8 TO EN-WALK-SPEED(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance nautilus a swimming nautilus draws other vertices" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM2 - WS-SUM1 > 0.001 OR WS-SUM1 - WS-SUM2 > 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance nautilus still 8 cuboids" TO TL-CASE
     MOVE 288 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The zombie nautilus: variant 0 (temperate) the nautilus model, entry 21 value 1 (warm) the coral model with 8 more cuboids.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE "zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 21 1 0 0 0 WS-LONG
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance zombie nautilus temperate 8 cuboids" TO TL-CASE
     MOVE 288 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 21 1 1 0 0 WS-LONG
     MOVE "acceptance zombie nautilus entry 21 is kept" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-VAR(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE 1 WS-MODEL
     MOVE "acceptance zombie nautilus warm model row" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "zombie_nautilus~w" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance zombie nautilus warm texture" TO TL-CASE
     MOVE "textures/entity/nautilus/zombie_nautilus_coral.png" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CL-MD-PATH(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance zombie nautilus warm 16 cuboids with the corals" TO TL-CASE
     MOVE 576 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Body armor hides the corals: the base model 8 cuboids, the armor layer 8 (the same as a temperate one in armor).
     MOVE "iron_nautilus_armor" TO WS-IKEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO EN-EQ(1, 7)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance zombie nautilus warm in armor hides the corals: 16 cuboids" TO TL-CASE
     MOVE 576 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-VAR(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance zombie nautilus temperate in armor: 16 cuboids" TO TL-CASE
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Saddle too: armor 8 and saddle 6 cuboids.
     MOVE "saddle" TO WS-IKEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO EN-EQ(1, 8)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance zombie nautilus in armor and saddle: 22 cuboids" TO TL-CASE
     MOVE 792 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The overlay layers of the nautilus: armor (layer 5, code 7000 + asset: copper 2, iron 4, golden 5, diamond 6, netherite 8) and saddle (layer 6, code 8001).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1 MOVE "copper_nautilus_armor" TO WS-IKEY
             WHEN 2 MOVE "iron_nautilus_armor" TO WS-IKEY
             WHEN 3 MOVE "golden_nautilus_armor" TO WS-IKEY
             WHEN 4 MOVE "diamond_nautilus_armor" TO WS-IKEY
             WHEN OTHER MOVE "netherite_nautilus_armor" TO WS-IKEY
         END-EVALUATE
         PERFORM FIND-ITEM
         MOVE WS-ITEM TO EN-EQ(1, 7)
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 5 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance nautilus armor code of " FUNCTION TRIM(WS-IKEY) DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 7002 TO TL-EXPECTED-N
             WHEN 2 MOVE 7004 TO TL-EXPECTED-N
             WHEN 3 MOVE 7005 TO TL-EXPECTED-N
             WHEN 4 MOVE 7006 TO TL-EXPECTED-N
             WHEN OTHER MOVE 7008 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "acceptance nautilus armor model row" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "nautilus_armor" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nautilus_armor" TO WS-KEY20
     MOVE 7004 TO WS-CODE
     CALL "ENTITY-TEX-PATH" USING WS-KEY20 WS-CODE WS-PATH
     MOVE "acceptance nautilus armor texture" TO TL-CASE
     MOVE "textures/entity/equipment/nautilus_body/iron.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nautilus_saddle" TO WS-KEY20
     MOVE 8001 TO WS-CODE
     CALL "ENTITY-TEX-PATH" USING WS-KEY20 WS-CODE WS-PATH
     MOVE "acceptance nautilus saddle texture" TO TL-CASE
     MOVE "textures/entity/equipment/nautilus_saddle/saddle.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "saddle" TO WS-IKEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO EN-EQ(1, 8)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 6 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance nautilus saddle code" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8001 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance nautilus saddle model row" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "nautilus_saddle" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby nautilus wears no armor and no saddle.
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 6 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance nautilus baby saddle code" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 5 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance nautilus baby armor code" TO TL-CASE
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The zombie nautilus saddle uses the same row.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "saddle" TO WS-IKEY
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO EN-EQ(1, 8)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 6 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance zombie nautilus saddle model row" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "nautilus_saddle" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CLEAR-IN.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         MOVE 0 TO WS-IV(WS-J)
     END-PERFORM.
 FIND-ITEM.
     MOVE SPACES TO WS-KEY
     MOVE WS-IKEY TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS.
 SUM-MESH.
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM2 = WS-SUM2 + RL-EN-Y(WS-J) + RL-EN-X(WS-J) + RL-EN-Z(WS-J)
     END-PERFORM.
 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001 AND WS-DIFF > -0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NAUTILUS-MORE.

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

