*> Test of the entity models in the real render path (docs/protocol/34-entity-models-1..8; client/src/entities-models.cob,
*> entities-render.cob ENTITIES-MESH, entities-replica.cob). Add Entity of a standard-set world keeps the registry key of the
*> spawned type and its model; ENTITIES-MESH then draws that model's cuboids (36 vertices each: 6 faces x 2 triangles) with the
*> pipeline of 34-1 6 / 34-7 1.6 (translate to the entity, rotate Y by 180 - yaw, scale (-1, -1, 1), translate (0, -1.501, 0))
*> and texture rectangles of the entity atlas. The cow (34-4 section 2: 10 cuboids) and the creeper (34-6 section 2: 6 cuboids)
*> are in one frame. Expected positions are computed by hand from the model rows (client/src/entmodel-34-4-2.cob EF4-M-COW,
*> entmodel-34-6-2.cob EF6-M-CREEPER) with the eye at (10, 64, 10): the cow's head cuboid is x -4..4, y -4..4, z -6..-0 around its
*> pivot (0, 4, -8) pixels, so before the pipeline x -0.25..0.25, y 0..0.5, z -0.875..-0.5 blocks; after it y 1.001..1.501 above the
*> feet, and at yaw 0 (rotation 180 about Y) z +0.5..+0.875 in front.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-MODELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-COW-ID              BINARY-LONG.
 01 WS-ROW-N               BINARY-LONG.
 01 WS-FKEY                PIC X(24).
 01 WS-CREEPER-ID          BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-EDIT                PIC -(6)9 OCCURS 6 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MIN-V               FLOAT-LONG.
 01 WS-MAX-V               FLOAT-LONG.
 01 WS-LAYER               PIC XX VALUE "EN".
 01 WS-VT-OK               BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
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
*>   A standard world: its set is open, the entity ids are the registry's.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE SPACES TO WS-KEY
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-ID WS-ROW-AREA WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CREEPER-ID WS-ROW-AREA WS-STATUS

     MOVE 5 TO WS-ID
     MOVE WS-COW-ID TO WS-TYPE
     MOVE 10.5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10.5 TO WS-Z
     MOVE 0 TO WS-YAW
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 6 TO WS-ID
     MOVE WS-CREEPER-ID TO WS-TYPE
     MOVE 20.5 TO WS-X
     MOVE 20.5 TO WS-Z
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 7 TO WS-ID
     MOVE WS-COW-ID TO WS-TYPE
     MOVE 30.5 TO WS-X
     MOVE 10.5 TO WS-Z
     MOVE 90 TO WS-YAW
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW

     MOVE "T" TO TL-MODE
     MOVE "entity models Add Entity of a standard world keeps the registry key and the model of the cow row"
         TO TL-CASE
     MOVE "cow 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF EN-MODEL(1) > 0
         STRING FUNCTION TRIM(EN-KEY(1)) " " EN-VANILLA(1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "entity models a cow (10 cuboids), a creeper (6) and a second cow in one frame draw 36 vertices per cuboid"
         TO TL-CASE
     MOVE 936 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cow's head cuboid (the first 36 vertices), cow at (10.5, 64, 10.5) yaw 0.
     MOVE 1 TO WS-FIRST
     MOVE 36 TO WS-LAST
     CALL "ETM-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-R(WS-I) TO WS-EDIT(WS-I)
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "entity models the cow's head cuboid x 0.25..0.75, y 1.001..1.501, z 1.0..1.375 from the eye (yaw 0)"
         TO TL-CASE
     MOVE "250 750 1001 1501 1000 1375" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT(1)) " " FUNCTION TRIM(WS-EDIT(2)) " " FUNCTION TRIM(WS-EDIT(3)) " "
         FUNCTION TRIM(WS-EDIT(4)) " " FUNCTION TRIM(WS-EDIT(5)) " " FUNCTION TRIM(WS-EDIT(6))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The creeper's head cuboid (vertices 361 to 396): x 20.25..20.75, y 1.126..1.626 above the feet, z 20.25..20.75.
     MOVE 361 TO WS-FIRST
     MOVE 396 TO WS-LAST
     CALL "ETM-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-R(WS-I) TO WS-EDIT(WS-I)
     END-PERFORM
     MOVE "entity models the creeper's head cuboid is at y 1.126..1.626 and centred on its x and z"
         TO TL-CASE
     MOVE "10250 10750 1126 1626 10250 10750" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT(1)) " " FUNCTION TRIM(WS-EDIT(2)) " " FUNCTION TRIM(WS-EDIT(3)) " "
         FUNCTION TRIM(WS-EDIT(4)) " " FUNCTION TRIM(WS-EDIT(5)) " " FUNCTION TRIM(WS-EDIT(6))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The second cow, yaw 90 (faces -X): rotation 90 about Y puts the head at x -0.875..-0.5 from the cow.
     MOVE 577 TO WS-FIRST
     MOVE 612 TO WS-LAST
     CALL "ETM-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-R(WS-I) TO WS-EDIT(WS-I)
     END-PERFORM
     MOVE "entity models a cow at yaw 90 has its head on the -X side"
         TO TL-CASE
     MOVE "19625 20000 1001 1501 250 750" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT(1)) " " FUNCTION TRIM(WS-EDIT(2)) " " FUNCTION TRIM(WS-EDIT(3)) " "
         FUNCTION TRIM(WS-EDIT(4)) " " FUNCTION TRIM(WS-EDIT(5)) " " FUNCTION TRIM(WS-EDIT(6))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Vertex 1 is slot 0 of the DOWN face, corner F (x1, y0, z1) = (4, 0, -8) px: (0.75, 1.501, 1.0) from the eye; its texel
*>   is (uMax, vMin) = (6 + 8, 0) of the 64 x 64 image at atlas row 63 of the atlas (80 x 159 once the creeper's
*>   64 x 32 image is added).
     MOVE "T" TO TL-MODE
     COMPUTE WS-U = FUNCTION INTEGER(RL-EN-U(1) * 1000 + 0.5)
     COMPUTE WS-V = FUNCTION INTEGER(RL-EN-V(1) * 1000 + 0.5)
     MOVE "entity models vertex 1 of the cow is the DOWN face's slot 0: position (0.75, 1.501, 1.0), texel (14, 0) in its rectangle"
         TO TL-CASE
     MOVE "750 1501 1000 175 396 10" TO TL-EXPECTED
     MOVE WS-U TO WS-EDIT(1)
     MOVE WS-V TO WS-EDIT(2)
     COMPUTE WS-EDIT(3) = FUNCTION INTEGER(RL-EN-X(1) * 1000 + 0.5)
     COMPUTE WS-EDIT(4) = FUNCTION INTEGER(RL-EN-Y(1) * 1000 + 0.5)
     COMPUTE WS-EDIT(5) = FUNCTION INTEGER(RL-EN-Z(1) * 1000 + 0.5)
     COMPUTE WS-EDIT(6) = FUNCTION INTEGER(RL-EN-B(1) * 100 + 0.5)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT(3)) " " FUNCTION TRIM(WS-EDIT(4)) " " FUNCTION TRIM(WS-EDIT(5)) " "
         FUNCTION TRIM(WS-EDIT(1)) " " FUNCTION TRIM(WS-EDIT(2)) " " FUNCTION TRIM(WS-EDIT(6))
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The atlas: the three stand-in images (80 x 63) then the cow's (64 x 64) and the creeper's (64 x 32), as rectangles.
     MOVE "entity models the entity atlas holds the stand-in images, the cow's 64 x 64 and the creeper's 64 x 32 images"
         TO TL-CASE
     MOVE "80 159 63 127" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE EA-W TO WS-EDIT(1)
     MOVE EA-H TO WS-EDIT(2)
     MOVE EA-MT-Y(1) TO WS-EDIT(3)
     MOVE EA-MT-Y(2) TO WS-EDIT(4)
     STRING FUNCTION TRIM(WS-EDIT(1)) " " FUNCTION TRIM(WS-EDIT(2)) " " FUNCTION TRIM(WS-EDIT(3)) " "
         FUNCTION TRIM(WS-EDIT(4)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every texel coordinate of the cow's vertices lies inside the cow's rectangle (u 0..64/80, v 63/159..127/159), the creeper's inside its own
*>   (v 127/159..1).
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 360
         IF RL-EN-U(WS-I) >= 0 AND RL-EN-U(WS-I) <= 0.8000001
                 AND RL-EN-V(WS-I) >= 0.3960 AND RL-EN-V(WS-I) <= 0.7988
             ADD 1 TO WS-OK
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 361 BY 1 UNTIL WS-I > 576
         IF RL-EN-U(WS-I) >= 0 AND RL-EN-U(WS-I) <= 0.8000001
                 AND RL-EN-V(WS-I) >= 0.7987 AND RL-EN-V(WS-I) <= 1.0000001
             ADD 1 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "entity models the cow's 360 and the creeper's 216 vertices sample inside their texture rectangles of the atlas"
         TO TL-CASE
     MOVE 576 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-VERTEX-TINTS" USING CLIENT-STATE WS-LAYER WS-VT-OK
     MOVE "entity models every model vertex is untinted white with no sky term" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VT-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A second frame builds nothing new: same vertices, the atlas stays.
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models a second frame draws the same 936 vertices from the cached models" TO TL-CASE
     MOVE 936 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standard-world type without a model (id 0) and an id outside the registry draw nothing, not the stand-in operator.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 8 TO WS-ID
     MOVE 0 TO WS-TYPE
     MOVE 10.5 TO WS-X
     MOVE 10.5 TO WS-Z
     MOVE 0 TO WS-YAW
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 9 TO WS-ID
     MOVE 999 TO WS-TYPE
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models standard-world types without a model draw no stand-in box" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cobolcraft world type: the stand-in types 0, 2, 3 keep drawing their boxes (operator 1, sodgrazer 6, abend 1).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE 8 TO WS-ID
     MOVE 0 TO WS-TYPE
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 9 TO WS-ID
     MOVE 2 TO WS-TYPE
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 10 TO WS-ID
     MOVE 3 TO WS-TYPE
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models the cobolcraft stand-ins operator, sodgrazer and abend still draw 1 + 6 + 1 boxes" TO TL-CASE
     MOVE 288 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "entity models a stand-in row has no vanilla flag and no model" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VANILLA(1) + EN-MODEL(1) + EN-VANILLA(2) + EN-MODEL(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every type of the table, each alone in the frame, draws whole cuboids (a multiple of 36 vertices, at least 36), through its family's
*>   library (34-2, 34-4, 34-5, 34-6, 34-7, 34-8) and its animation (quadruped, creeper, zombie, skeleton, rest pose).
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MODEL-COUNT
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE SPACES TO WS-KEY
         MOVE CL-MD-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 11 TO WS-ID
         MOVE 10.5 TO WS-X
         MOVE 10.5 TO WS-Z
         MOVE 45 TO WS-YAW
         CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         IF RL-EN-COUNT >= 36 AND FUNCTION MOD(RL-EN-COUNT, 36) = 0
             ADD 1 TO WS-OK
         END-IF
*>       The experience orb row (family 0) is one quad of 6 vertices (test_entity_orb_swell).
         IF CL-MD-FAMILY(WS-I) = 0 AND RL-EN-COUNT = 6
             ADD 1 TO WS-OK
         END-IF
*>       A row that is the extra layer of another (the sheep's wool) is no entity type: it is drawn with its base row (below).
         IF WS-STATUS NOT = CT-OK AND RL-EN-COUNT = 0
             ADD 1 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "entity models each type of the table draws whole cuboids on its own" TO TL-CASE
     MOVE CL-MODEL-COUNT TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The sheep is its body (6 cuboids) and its wool layer (6 cuboids); the chicken and the mooshroom draw whole cuboids.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE SPACES TO WS-KEY
     MOVE "sheep" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 11 TO WS-ID
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models a sheep draws its body and its wool layer: 12 cuboids" TO TL-CASE
     MOVE 432 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "entity models the cow and pig textures are the temperate variants (the replica holds no variant)" TO TL-CASE
     MOVE "textures/entity/cow/cow_temperate.png textures/entity/pig/pig_temperate.png" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CL-MD-PATH(1)) " " FUNCTION TRIM(CL-MD-PATH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   An entity farther than 64 blocks (horizontally) from the eye is not drawn (the entity render range); one at 60 blocks is; and 60 cows
*>   (3600 vertices in all) fit in one frame: the vertex capacity is 49152.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE SPACES TO WS-KEY
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 11 TO WS-ID
     MOVE 80.5 TO WS-X
     MOVE 10.5 TO WS-Z
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models a cow 70 blocks away is not drawn" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 70.5 TO WS-X
     CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models a cow 60 blocks away is drawn (360 vertices)" TO TL-CASE
     MOVE 360 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         COMPUTE WS-ID = 100 + WS-I
         COMPUTE WS-X = 10.5 + WS-I / 2
         CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "entity models 60 cows near the eye are all drawn (21600 vertices)" TO TL-CASE
     MOVE 21600 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A model without an atlas slot (its image was never made: more than 16 models, or no frame meshed it yet) draws nothing.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1) EN-MODEL(1)
     MOVE 0 TO EA-MT-COUNT RL-EN-COUNT
     MOVE 1 TO WS-ID
     CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-ID WS-EYE-TABLE
     MOVE "entity models a model without an atlas slot draws no vertex" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Every row of the model table agrees with the model library: its texture size is the layer's.
     CALL "ETM-TABLE-CHECK" USING WS-OK
     MOVE "entity models every table row builds its layer, whose texture size is the row's" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The sheep's extra layer is its own wool row (sheep_wool, 34-4 5.3), not the sheep row itself (which drew the skin twice and never the wool).
     MOVE "sheep" TO WS-FKEY
     CALL "ENTITY-MODEL-FIND" USING WS-FKEY WS-ROW-N
     MOVE "the sheep's extra layer is the row of key sheep_wool" TO TL-CASE
     MOVE "sheep_wool" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW-N > 0 AND CL-MD-EXTRA(WS-ROW-N) > 0
         MOVE CL-MD-KEY(CL-MD-EXTRA(WS-ROW-N)) TO TL-OBSERVED
     END-IF
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-MODELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ETM-SPAWN.
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
 END PROGRAM ETM-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ETM-RANGE.
*> USING CLIENT-STATE, first and last entity vertex, range out (BINARY-LONG x 6): min and max x, y, z in thousandths.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-RANGE.
    05 L-R                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-FIRST L-LAST L-RANGE.
     MOVE 999999999 TO L-R(1) L-R(3) L-R(5)
     MOVE -999999999 TO L-R(2) L-R(4) L-R(6)
     PERFORM VARYING WS-I FROM L-FIRST BY 1 UNTIL WS-I > L-LAST
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-X(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(1), WS-V) TO L-R(1)
         MOVE FUNCTION MAX(L-R(2), WS-V) TO L-R(2)
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-Y(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(3), WS-V) TO L-R(3)
         MOVE FUNCTION MAX(L-R(4), WS-V) TO L-R(4)
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-Z(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(5), WS-V) TO L-R(5)
         MOVE FUNCTION MAX(L-R(6), WS-V) TO L-R(6)
     END-PERFORM
     GOBACK.
 END PROGRAM ETM-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ETM-TABLE-CHECK.
*> USING ok out: 1 when every row of CL-MODELS builds its layer (ENTITY-MODEL-BUILD) and the model's texture size is the row's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMODELS.
 COPY CLEMM.
 01 WS-I                   BINARY-LONG.
 01 WS-BUILT               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-OK.
     MOVE 1 TO L-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MODEL-COUNT
         IF CL-MD-FAMILY(WS-I) > 0
             CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-I WS-BUILT
             MOVE MM-TEXW TO WS-W
             MOVE MM-TEXH TO WS-H
             IF WS-BUILT = 0 OR WS-W NOT = CL-MD-TEXW(WS-I) OR WS-H NOT = CL-MD-TEXH(WS-I)
                 MOVE 0 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ETM-TABLE-CHECK.

 COPY CLTEST.
