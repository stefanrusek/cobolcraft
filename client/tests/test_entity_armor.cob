 *> Armor on the humanoid mobs (34-2 section 1.5 HumanoidArmorLayer; 25-4 section 8 equipment asset keys): ENTITY-ARMOR-ASSET names the slot and the asset of an item by its key,
 *> the overlay layers 5 to 8 of a mob that wears armor are its chest, legs, feet and head pieces (each its own armor model row, texture
 *> textures/entity/equipment/humanoid[_leggings]/<asset>.png), posed like the mob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 9.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ASSET               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-K20                 PIC X(20).
 01 WS-BASE-COUNT          BINARY-LONG.
 01 WS-CASES-DATA.
    05 FILLER PIC X(20) VALUE "iron_helmet".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(20) VALUE "diamond_chestplate".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(20) VALUE "leather_leggings".
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(20) VALUE "golden_boots".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(20) VALUE "netherite_helmet".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 8.
    05 FILLER PIC X(20) VALUE "chainmail_boots".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(20) VALUE "copper_chestplate".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(20) VALUE "turtle_helmet".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 7.
    05 FILLER PIC X(20) VALUE "iron_sword".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(20) VALUE "stone".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(20) VALUE "iron_horse_armor".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC 9 VALUE 0.
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-C OCCURS 11 TIMES.
       10 WS-C-KEY         PIC X(20).
       10 WS-C-SLOT        PIC 9.
       10 WS-C-ASSET       PIC 9.
 01 WS-PATHS-DATA.
    05 FILLER PIC X(20) VALUE "armor_head".
    05 FILLER PIC 9999 VALUE 6004.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/iron.png".
    05 FILLER PIC X(20) VALUE "armor_chest".
    05 FILLER PIC 9999 VALUE 6006.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/diamond.png".
    05 FILLER PIC X(20) VALUE "armor_legs".
    05 FILLER PIC 9999 VALUE 6001.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid_leggings/leather.png".
    05 FILLER PIC X(20) VALUE "armor_feet".
    05 FILLER PIC 9999 VALUE 6005.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/gold.png".
    05 FILLER PIC X(20) VALUE "armor_head".
    05 FILLER PIC 9999 VALUE 6007.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/turtle_scute.png".
    05 FILLER PIC X(20) VALUE "armor_legs".
    05 FILLER PIC 9999 VALUE 6008.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid_leggings/netherite.png".
    05 FILLER PIC X(20) VALUE "armor_chest".
    05 FILLER PIC 9999 VALUE 6002.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/copper.png".
    05 FILLER PIC X(20) VALUE "armor_feet".
    05 FILLER PIC 9999 VALUE 6003.
    05 FILLER PIC X(64) VALUE "textures/entity/equipment/humanoid/chainmail.png".
 01 WS-PATHS REDEFINES WS-PATHS-DATA.
    05 WS-P OCCURS 8 TIMES.
       10 WS-P-KEY         PIC X(20).
       10 WS-P-CODE        PIC 9999.
       10 WS-P-PATH        PIC X(64).
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
*>   Items: the slot (1 head, 2 chest, 3 legs, 4 feet, 0 none) and the asset (1 leather, 2 copper, 3 chainmail, 4 iron, 5 gold, 6 diamond, 7 turtle scute, 8 netherite).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE SPACES TO WS-KEY
         MOVE WS-C-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         CALL "ENTITY-ARMOR-ASSET" USING CLIENT-STATE WS-ITEM WS-SLOT WS-ASSET
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance armor " FUNCTION TRIM(WS-C-KEY(WS-I)) " slot" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-C-SLOT(WS-I) TO TL-EXPECTED-N
         MOVE WS-SLOT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance armor " FUNCTION TRIM(WS-C-KEY(WS-I)) " asset" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-C-ASSET(WS-I) TO TL-EXPECTED-N
         MOVE WS-ASSET TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   Texture paths of the armor rows.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-PATH
         MOVE WS-P-CODE(WS-I) TO WS-CODE
         CALL "ENTITY-TEX-PATH" USING WS-P-KEY(WS-I) WS-CODE WS-PATH
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance armor path " WS-P-KEY(WS-I) WS-P-CODE(WS-I) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-P-PATH(WS-I) TO TL-EXPECTED
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A zombie in an iron helmet (equipment slot 5, EN-EQ 6) and a diamond chestplate (slot 4, EN-EQ 5): layers 5 (chest) and 8 (head), the model rows armor_chest and armor_head.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     MOVE "diamond_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 8
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-I WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-I-D
         STRING "acceptance armor zombie layer " WS-I-D DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 5 MOVE 6006 TO TL-EXPECTED-N
             WHEN 8 MOVE 6004 TO TL-EXPECTED-N
             WHEN OTHER MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance armor zombie layer " WS-I-D " model" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         IF WS-I = 5 OR WS-I = 8
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         MOVE 0 TO TL-OBSERVED-N
         IF WS-MODEL > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 5 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance armor the chest layer is the model row armor_chest" TO TL-CASE
     MOVE "armor_chest" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drawing: the body, the chest piece and the head piece take three atlas slots and the mesh holds more cuboids than the bare zombie.
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance armor a zombie with two pieces takes three slots" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-EN-COUNT TO WS-N
     MOVE 0 TO EN-EQ(1, 5) EN-EQ(1, 6)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance armor the armored zombie has more vertices than the bare one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N > RL-EN-COUNT AND RL-EN-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zombie holding a sword in its helmet slot gets no piece (the slot of the item differs); a baby wears none; a cow wears none.
     MOVE "iron_sword" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 8 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance armor a sword in the head slot is no piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 8 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "acceptance armor a baby zombie wears no piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-BABY(1)
*>   Skeletons, piglins, drowned and zombified piglins wear their pieces too; a cow does not.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1 MOVE "skeleton" TO WS-KEY
             WHEN 2 MOVE "piglin" TO WS-KEY
             WHEN 3 MOVE "drowned" TO WS-KEY
             WHEN 4 MOVE "zombified_piglin" TO WS-KEY
             WHEN 5 MOVE "husk" TO WS-KEY
             WHEN OTHER MOVE "cow" TO WS-KEY
         END-EVALUATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE WS-ITEM TO EN-EQ(1, 6)
         MOVE 0 TO EA-MT-COUNT
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance armor a " FUNCTION TRIM(WS-KEY) " in a helmet draws the helmet" DELIMITED BY SIZE INTO TL-CASE
         MOVE 2 TO TL-EXPECTED-N
         IF WS-I = 6
             MOVE 1 TO TL-EXPECTED-N
         END-IF
         MOVE EA-MT-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ENTITY-ARMOR.

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

