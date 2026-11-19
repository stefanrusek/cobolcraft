*> T9904 (lane 002-lane-p70d; docs/protocol/34-2 section 1.4 and 1.5, 34-3 section 2.4): the armor of babies. A baby zombie, husk, drowned and zombie villager wears its pieces on
*> the baby armor rows armor_<slot>~b (the baby armor mesh at the deformations (-0.1, 0.5, 0.3), the legs slot at (-0.1, 0.3, 0.3)), a baby piglin and zombified piglin on
*> piglin_armor_<slot>~b (0.7 and the arm offset (0.5, -0.5, 0)); their textures are of the layer type humanoid_baby (leggings too) and a baby has no trim. The adult piglin family
*> wears piglin_armor_<slot> (grows 1.02 outer, 0.5 inner). Expected meshes from the table of 34-2 section 1.4: cuboids per slot (head 1, chest 3, legs 3, feet 2), grows (g - 0.1 on
*> legs and waist), the arm pivots.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-BABY-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CLEMM.
 COPY TESTLIB.
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
 01 WS-J                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-K20                 PIC X(24).
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EGX                 BINARY-LONG.
 01 WS-EGY                 BINARY-LONG.
 01 WS-EGZ                 BINARY-LONG.
 01 WS-ECUBES              BINARY-LONG.
 01 WS-ETEXH               BINARY-LONG.
 01 WS-LABEL               PIC X(60).
 01 WS-D1                  PIC 99.
 01 WS-D2                  PIC 99.
 01 WS-D3                  PIC 99.
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
*>   The meshes of the rows: key, cuboids, texture height, the grows (thousandths) of the part named and the part's pivot x (thousandths).
     MOVE "armor_head~b" TO WS-K20
     MOVE "head" TO WS-PN
     MOVE 1 TO WS-ECUBES
     MOVE 64 TO WS-ETEXH
     MOVE -100 TO WS-EGX
     MOVE 500 TO WS-EGY
     MOVE 300 TO WS-EGZ
     PERFORM CHECK-ROW
     MOVE "armor_chest~b" TO WS-K20
     MOVE "body" TO WS-PN
     MOVE 3 TO WS-ECUBES
     PERFORM CHECK-ROW
     MOVE "right_arm" TO WS-PN
     PERFORM CHECK-ROW
     PERFORM CHECK-PIVOT-R
     MOVE "armor_legs~b" TO WS-K20
     MOVE "right_leg" TO WS-PN
     MOVE -200 TO WS-EGX
     MOVE 200 TO WS-EGY
     MOVE 200 TO WS-EGZ
     PERFORM CHECK-ROW
     MOVE "waist" TO WS-PN
     PERFORM CHECK-ROW
     MOVE "armor_feet~b" TO WS-K20
     MOVE "left_foot" TO WS-PN
     MOVE 2 TO WS-ECUBES
     MOVE -100 TO WS-EGX
     MOVE 500 TO WS-EGY
     MOVE 300 TO WS-EGZ
     PERFORM CHECK-ROW
*>   The baby piglin set: 0.7 everywhere (0.6 on the legs and the waist), the arms moved by (0.5, -0.5, 0).
     MOVE "piglin_armor_head~b" TO WS-K20
     MOVE "head" TO WS-PN
     MOVE 1 TO WS-ECUBES
     MOVE 700 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
     MOVE "piglin_armor_chest~b" TO WS-K20
     MOVE "right_arm" TO WS-PN
     MOVE 3 TO WS-ECUBES
     PERFORM CHECK-ROW
     MOVE "piglin_armor_chest~b" TO WS-K20
     PERFORM CHECK-PIVOT-P
     MOVE "piglin_armor_legs~b" TO WS-K20
     MOVE "left_leg" TO WS-PN
     MOVE 600 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
     MOVE "piglin_armor_feet~b" TO WS-K20
     MOVE "right_foot" TO WS-PN
     MOVE 2 TO WS-ECUBES
     MOVE 700 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
*>   The adult piglin set: outer 1.02, the legs slot 0.5 on the body and 0.4 on the legs, the boots' legs 0.92; 64 x 32.
     MOVE "piglin_armor_head" TO WS-K20
     MOVE "head" TO WS-PN
     MOVE 2 TO WS-ECUBES
     MOVE 32 TO WS-ETEXH
     MOVE 1020 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
     MOVE "piglin_armor_chest" TO WS-K20
     MOVE "body" TO WS-PN
     MOVE 3 TO WS-ECUBES
     PERFORM CHECK-ROW
     MOVE "piglin_armor_legs" TO WS-K20
     MOVE "body" TO WS-PN
     MOVE 500 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
     MOVE "right_leg" TO WS-PN
     MOVE 400 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
     MOVE "piglin_armor_feet" TO WS-K20
     MOVE "left_leg" TO WS-PN
     MOVE 2 TO WS-ECUBES
     MOVE 920 TO WS-EGX WS-EGY WS-EGZ
     PERFORM CHECK-ROW
*>   Every baby row is the baby row of its adult row, and the zombie villager's rows too.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         EVALUATE WS-I
             WHEN 1 MOVE "armor_head" TO WS-K20
             WHEN 2 MOVE "armor_chest" TO WS-K20
             WHEN 3 MOVE "armor_legs" TO WS-K20
             WHEN 4 MOVE "armor_feet" TO WS-K20
             WHEN 5 MOVE "zvil_armor_head" TO WS-K20
             WHEN 6 MOVE "zvil_armor_chest" TO WS-K20
             WHEN 7 MOVE "zvil_armor_legs" TO WS-K20
             WHEN 8 MOVE "zvil_armor_feet" TO WS-K20
             WHEN 9 MOVE "piglin_armor_head" TO WS-K20
             WHEN 10 MOVE "piglin_armor_chest" TO WS-K20
             WHEN 11 MOVE "piglin_armor_legs" TO WS-K20
             WHEN OTHER MOVE "piglin_armor_feet" TO WS-K20
         END-EVALUATE
         CALL "ENTITY-MODEL-FIND" USING WS-K20 WS-MODEL
         MOVE CL-MD-BABY(WS-MODEL) TO WS-J
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "baby armor the baby row of " FUNCTION TRIM(WS-K20) DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE "armor_head~b" TO TL-EXPECTED
             WHEN 2 MOVE "armor_chest~b" TO TL-EXPECTED
             WHEN 3 MOVE "armor_legs~b" TO TL-EXPECTED
             WHEN 4 MOVE "armor_feet~b" TO TL-EXPECTED
             WHEN 5 MOVE "armor_head~b" TO TL-EXPECTED
             WHEN 6 MOVE "armor_chest~b" TO TL-EXPECTED
             WHEN 7 MOVE "armor_legs~b" TO TL-EXPECTED
             WHEN 8 MOVE "armor_feet~b" TO TL-EXPECTED
             WHEN 9 MOVE "piglin_armor_head~b" TO TL-EXPECTED
             WHEN 10 MOVE "piglin_armor_chest~b" TO TL-EXPECTED
             WHEN 11 MOVE "piglin_armor_legs~b" TO TL-EXPECTED
             WHEN OTHER MOVE "piglin_armor_feet~b" TO TL-EXPECTED
         END-EVALUATE
         MOVE SPACES TO TL-OBSERVED
         IF WS-J > 0
             MOVE CL-MD-KEY(WS-J) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The overlay layers of the babies: the keys, the model rows and the texture of the iron pieces (layers 8 head, 5 chest, 6 legs, 7 feet).
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE "zombie" TO WS-KEY
             WHEN 2 MOVE "husk" TO WS-KEY
             WHEN 3 MOVE "drowned" TO WS-KEY
             WHEN 4 MOVE "zombie_villager" TO WS-KEY
             WHEN 5 MOVE "piglin" TO WS-KEY
             WHEN 6 MOVE "zombified_piglin" TO WS-KEY
             WHEN 7 MOVE "piglin" TO WS-KEY
             WHEN OTHER MOVE "zombie_villager" TO WS-KEY
         END-EVALUATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE 1 TO EN-BABY(1)
         IF WS-I >= 7
             MOVE 0 TO EN-BABY(1)
         END-IF
         MOVE "iron_helmet" TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         MOVE WS-ITEM TO EN-EQ(1, 6)
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 8 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-D1
         STRING "baby armor case " WS-D1 " the iron helmet is code 6004" DELIMITED BY SIZE INTO TL-CASE
         MOVE 6004 TO TL-EXPECTED-N
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-D1
         STRING "baby armor case " WS-D1 " the helmet's model row" DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 WHEN 2 WHEN 3 WHEN 4 MOVE "armor_head~b" TO TL-EXPECTED
             WHEN 5 WHEN 6 MOVE "piglin_armor_head~b" TO TL-EXPECTED
             WHEN 7 MOVE "piglin_armor_head" TO TL-EXPECTED
             WHEN OTHER MOVE "zvil_armor_head" TO TL-EXPECTED
         END-EVALUATE
         MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-PATH
         CALL "ENTITY-TEX-PATH" USING CL-MD-KEY(WS-MODEL) WS-CODE WS-PATH
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-D1
         STRING "baby armor case " WS-D1 " the helmet's texture" DELIMITED BY SIZE INTO TL-CASE
         MOVE "textures/entity/equipment/humanoid_baby/iron.png" TO TL-EXPECTED
         IF WS-I >= 7
             MOVE "textures/entity/equipment/humanoid/iron.png" TO TL-EXPECTED
         END-IF
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The adult piglin family's other pieces: chestplate, leggings and boots (layers 5, 6, 7) are on the rows piglin_armor_chest, _legs and _feet.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     MOVE "iron_leggings" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 4)
     MOVE "iron_boots" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 3)
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 7
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-I WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "T" TO TL-MODE
         MOVE WS-I TO WS-D1
         MOVE SPACES TO TL-CASE
         STRING "baby armor an adult piglin's layer " WS-D1 " is a piglin armor row" DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 5 MOVE "piglin_armor_chest" TO TL-EXPECTED
             WHEN 6 MOVE "piglin_armor_legs" TO TL-EXPECTED
             WHEN OTHER MOVE "piglin_armor_feet" TO TL-EXPECTED
         END-EVALUATE
         MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A baby zombie's leggings are of the baby layer type, not humanoid_leggings, on the row armor_legs~b.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 1 TO EN-BABY(1)
     MOVE "iron_leggings" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 4)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 6 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE SPACES TO WS-PATH
     CALL "ENTITY-TEX-PATH" USING CL-MD-KEY(WS-MODEL) WS-CODE WS-PATH
     MOVE "T" TO TL-MODE
     MOVE "baby armor a baby's leggings are of the layer type humanoid_baby" TO TL-CASE
     MOVE "textures/entity/equipment/humanoid_baby/iron.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "baby armor a baby's leggings are on the row armor_legs~b" TO TL-CASE
     MOVE "armor_legs~b" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No trim on a baby (humanoid_baby has none), the same trim on an adult is drawn (layer 12 is the trim of the head piece).
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     MOVE 1 TO EN-EQ-TRIM-MAT(1, 6)
     MOVE 1 TO EN-EQ-TRIM-PAT(1, 6)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 12 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "N" TO TL-MODE
     MOVE "baby armor a baby's helmet has no trim layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 12 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "baby armor an adult's helmet has the trim layer" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CODE > 100000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-EQ-TRIM-MAT(1, 6) EN-EQ-TRIM-PAT(1, 6)
*>   The glint of a baby's piece with the foil is layer 16, on the baby row.
     MOVE 1 TO EN-BABY(1)
     MOVE 1 TO EN-EQ-FOIL(1, 6)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 16 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "baby armor the foil helmet's glint layer is code 6004" TO TL-CASE
     MOVE 6004 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "baby armor the glint layer is the model row armor_head~b" TO TL-CASE
     MOVE "armor_head~b" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-EQ-FOIL(1, 6)
*>   It draws: a baby zombie in a helmet takes the baby row's slot and the helmet's slot, and has more vertices than the bare baby.
     MOVE 0 TO EA-MT-COUNT
     MOVE 0 TO EN-EQ(1, 6) EN-EQ(1, 4)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-N
     MOVE "N" TO TL-MODE
     MOVE "baby armor a bare baby zombie takes one atlas slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "baby armor a baby zombie in a helmet takes two atlas slots" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "baby armor the helmet adds the vertices of its box (36)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-N + 36
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The row WS-K20 builds (the cuboids WS-ECUBES, the texture height WS-ETEXH, 64 wide) and its part WS-PN has the grows WS-EGX, WS-EGY, WS-EGZ (thousandths) on its first cuboid.
 CHECK-ROW.
     CALL "ENTITY-MODEL-FIND" USING WS-K20 WS-MODEL
     CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-OK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     MOVE WS-ECUBES TO WS-D2
     MOVE WS-ETEXH TO WS-D3
     STRING "baby armor " FUNCTION TRIM(WS-K20) " builds with " WS-D2 " cuboids" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-ECUBES TO TL-EXPECTED-N
     MOVE WS-CUBES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "baby armor " FUNCTION TRIM(WS-K20) " texture height " WS-D3 DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-ETEXH TO TL-EXPECTED-N
     MOVE MM-TEXH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "baby armor " FUNCTION TRIM(WS-K20) " part " FUNCTION TRIM(WS-PN) " grow x" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EGX TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GX(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "baby armor " FUNCTION TRIM(WS-K20) " part " FUNCTION TRIM(WS-PN) " grow y" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EGY TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GY(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "baby armor " FUNCTION TRIM(WS-K20) " part " FUNCTION TRIM(WS-PN) " grow z" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EGZ TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MC-GZ(WS-P, 1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The right arm of the baby zombie set sits at (-3.5, 15.5, 0).
 CHECK-PIVOT-R.
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "N" TO TL-MODE
     MOVE "baby armor the baby zombie's right arm pivot is (-3.5, 15.5, 0)" TO TL-CASE
     MOVE -349984500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MM-X(WS-P) * 100000000 + MM-Y(WS-P) * 1000 + MM-Z(WS-P)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The right arm of the baby piglin set sits at (-3.5 - 0.5, 15.5 - 0.5, 0) = (-4, 15, 0).
 CHECK-PIVOT-P.
     CALL "ENTITY-MODEL-FIND" USING WS-K20 WS-MODEL
     CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-OK
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "N" TO TL-MODE
     MOVE "baby armor the baby piglin's right arm pivot is (-4, 15, 0)" TO TL-CASE
     MOVE -399985000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = MM-X(WS-P) * 100000000 + MM-Y(WS-P) * 1000 + MM-Z(WS-P)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-BABY-ARMOR.

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
