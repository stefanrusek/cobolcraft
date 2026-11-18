*> T9904 (lane 002-lane-p70b; docs/protocol/34-3 section 2.4): the zombie villager's adult armor rows. Each slot's mesh is the humanoid mesh at the slot's grow with the head box
*> 8 high (origin y -10), the body and the legs at grow + 0.1 (tex 16, 16 and 0, 16; leg pivots x -2 and 2) and the retained parts of the slot: helmet head and hat (grows 1.0
*> and 1.5), chestplate body 1.1 and arms 1.0, leggings body 0.6 and legs 0.6, boots legs 1.1. The overlay layers 5 to 8 of an adult zombie villager wear the pieces on the rows
*> zvil_armor_*, with the equipment textures of the humanoid armor; a baby wears none (no baby armor row is wired).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-ZV-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-INNER               FLOAT-LONG VALUE 0.5.
 01 WS-OUTER               FLOAT-LONG VALUE 1.0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PARTS               BINARY-LONG.
 01 WS-CUBES               BINARY-LONG.
 01 WS-PN                  PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-K20                 PIC X(24).
 01 WS-OK                  BINARY-LONG.
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
     MOVE "N" TO TL-MODE
*>   Helmet.
     MOVE 1 TO WS-SLOT
     CALL "EMD-ZV-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "zv armor helmet keeps the head and the hat (2 cuboids)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CUBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor helmet head box starts at y -10, is 8 high, grow 1.0 (milli)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = -10000 * 1000 + 8000 * 10 + 1000 / 1000
     COMPUTE TL-OBSERVED-N ROUNDED = MC-OY(WS-P, 1) * 1000000 + MC-H(WS-P, 1) * 1000 * 10 + MC-GX(WS-P, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor helmet hat grow 1.5 (thousandths)" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Chestplate.
     MOVE 2 TO WS-SLOT
     CALL "EMD-ZV-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "zv armor chestplate keeps body and both arms (3 cuboids)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-CUBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor chestplate body grow 1.1 (thousandths)" TO TL-CASE
     MOVE 1100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zv armor chestplate body texture origin (16, 16)" TO TL-CASE
     MOVE 1616 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MC-U(WS-P, 1) * 100 + MC-V(WS-P, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor chestplate arm grow 1.0 (thousandths)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Leggings (inner grow 0.5).
     MOVE 3 TO WS-SLOT
     CALL "EMD-ZV-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "zv armor leggings keep both legs and the body (3 cuboids)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-CUBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor leggings body grow 0.6 (thousandths)" TO TL-CASE
     MOVE 600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor leggings right leg pivot (-2, 12, 0) and grow 0.6" TO TL-CASE
     MOVE -1987400 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MM-X(WS-P) * 1000000 + MM-Y(WS-P) * 1000 + MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor leggings left leg is the mirrored box at x 2" TO TL-CASE
     MOVE 2000001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MM-X(WS-P) * 1000000 + MC-MIRROR(WS-P, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Boots.
     MOVE 4 TO WS-SLOT
     CALL "EMD-ZV-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "zv armor boots keep both legs (2 cuboids)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CUBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "zv armor boots leg grow 1.1 (thousandths)" TO TL-CASE
     MOVE 1100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The rows build through the model table.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "zvil_armor_head" TO WS-K20
             WHEN 2 MOVE "zvil_armor_chest" TO WS-K20
             WHEN 3 MOVE "zvil_armor_legs" TO WS-K20
             WHEN OTHER MOVE "zvil_armor_feet" TO WS-K20
         END-EVALUATE
         CALL "ENTITY-MODEL-FIND" USING WS-K20 WS-MODEL
         CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-OK
         MOVE SPACES TO TL-CASE
         STRING "zv armor the table builds the row " FUNCTION TRIM(WS-K20) DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   An adult zombie villager in an iron helmet and a diamond chestplate: layers 8 and 5 name the zvillager rows, with the humanoid equipment textures.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     MOVE "diamond_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 8 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "zv armor layer 8 is the iron helmet code 6004" TO TL-CASE
     MOVE 6004 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "zv armor layer 8 is the model row zvil_armor_head" TO TL-CASE
     MOVE "zvil_armor_head" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-PATH
     CALL "ENTITY-TEX-PATH" USING CL-MD-KEY(WS-MODEL) WS-CODE WS-PATH
     MOVE "zv armor layer 8 texture is the humanoid iron armor" TO TL-CASE
     MOVE "textures/entity/equipment/humanoid/iron.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 5 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "zv armor layer 5 is the model row zvil_armor_chest" TO TL-CASE
     MOVE "zvil_armor_chest" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   It draws: the body, the helmet and the chestplate take three atlas slots.
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "zv armor a zombie villager with two pieces takes more than one atlas slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EA-MT-COUNT >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby wears none.
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 8 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "zv armor a baby zombie villager wears no piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTMODEL-ZV-ARMOR.

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
