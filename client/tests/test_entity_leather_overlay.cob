 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-LEATHER-OVERLAY.
*> The second (overlay) layer of worn leather armour (57-1 section 4, T9901): ENTITY-OVERLAY layers 17 to 20 are the overlay passes of the pieces of layers 5 to 8
*> (code 6101, white, the same model row as the piece), only for leather; ENTITY-TEX-PATH gives the file leather_overlay.png of the piece's layer type; ENTITIES-MESH
*> draws the pass after the piece itself, enlarged by 0.1 percent per layer number about the entity origin.
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
 01 WS-I-D                 PIC 99.
 01 WS-ITEM                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-N-BARE              BINARY-LONG.
 01 WS-N-IRON              BINARY-LONG.
 01 WS-N-LEATHER           BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LEATHER-KEYS.
    05 FILLER              PIC X(20) VALUE "leather_helmet".
    05 FILLER              PIC X(20) VALUE "leather_chestplate".
    05 FILLER              PIC X(20) VALUE "leather_leggings".
    05 FILLER              PIC X(20) VALUE "leather_boots".
 01 WS-LK REDEFINES WS-LEATHER-KEYS.
    05 WS-LEATHER-KEY      PIC X(20) OCCURS 4 TIMES.
 01 WS-ROWS-DATA.
    05 FILLER              PIC X(24) VALUE "armor_chest".
    05 FILLER              PIC X(24) VALUE "armor_legs".
    05 FILLER              PIC X(24) VALUE "armor_feet".
    05 FILLER              PIC X(24) VALUE "armor_head".
 01 WS-ROWS REDEFINES WS-ROWS-DATA.
    05 WS-ROW-KEY          PIC X(24) OCCURS 4 TIMES.
 01 WS-PATHS-DATA.
    05 FILLER              PIC X(20) VALUE "armor_head".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "armor_chest".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "armor_legs".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid_leggings/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "armor_feet".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "armor_legs~b".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid_baby/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "armor_head~b".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid_baby/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "zvil_armor_chest".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid/leather_overlay.png".
    05 FILLER              PIC X(20) VALUE "piglin_armor_legs".
    05 FILLER              PIC X(64) VALUE "textures/entity/equipment/humanoid_leggings/leather_overlay.png".
 01 WS-PATHS REDEFINES WS-PATHS-DATA.
    05 WS-P OCCURS 8 TIMES.
       10 WS-P-KEY         PIC X(20).
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
*>   Texture paths of the overlay code 6101 for each layer type (57-1 section 4.2): humanoid, humanoid_leggings, humanoid_baby.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-PATH
         MOVE 6101 TO WS-CODE
         CALL "ENTITY-TEX-PATH" USING WS-P-KEY(WS-I) WS-CODE WS-PATH
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "leather overlay path of " FUNCTION TRIM(WS-P-KEY(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-P-PATH(WS-I) TO TL-EXPECTED
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A zombie wearing the four leather pieces: layers 17 to 20 are the overlay passes (code 6101, white, the model row of the piece).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-LEATHER-KEY(WS-I) TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
*>       Equipment index of the piece: head 6, chest 5, legs 4, feet 3.
         COMPUTE WS-K = 7 - WS-I
         MOVE WS-ITEM TO EN-EQ(1, WS-K)
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-K = 16 + WS-I
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-K WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-K TO WS-I-D
         STRING "leather overlay layer " WS-I-D " code" DELIMITED BY SIZE INTO TL-CASE
         MOVE 6101 TO TL-EXPECTED-N
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "leather overlay layer " WS-I-D " is white" DELIMITED BY SIZE INTO TL-CASE
         MOVE 765 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N ROUNDED = (WS-RED + WS-GREEN + WS-BLUE) * 255
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "leather overlay layer " WS-I-D " model row" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-ROW-KEY(WS-I) TO TL-EXPECTED
         MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The overlay is never tinted by the dye: the chest piece (layer 5) takes the dye 3F76E4, layer 17 stays white (57-1 section 4.3).
     MOVE 4158180 TO EN-EQ-DYE(1, 5)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 5 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "N" TO TL-MODE
     MOVE "leather overlay: the dyed chest piece is blue" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-RED * 255
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 17 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "leather overlay: the overlay of the dyed chest piece stays white" TO TL-CASE
     MOVE 765 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (WS-RED + WS-GREEN + WS-BLUE) * 255
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not leather, no piece, or a thing that wears no armor: no overlay.
     MOVE "iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 17 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "leather overlay: an iron chestplate has none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-EQ(1, 4)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 18 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "leather overlay: a bare leg slot has none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 21 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "leather overlay: layer 21 does not exist" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby zombie wears the overlay on the baby armor row; a zombie villager on its own row; a cow wears none.
     MOVE "leather_leggings" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 4)
     MOVE 1 TO EN-BABY(1)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 18 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "N" TO TL-MODE
     MOVE "leather overlay: a baby zombie wears it" TO TL-CASE
     MOVE 6101 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "leather overlay: the baby's leggings overlay is the row armor_legs~b" TO TL-CASE
     MOVE "armor_legs~b" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-BABY(1)
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "leather_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 17 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "N" TO TL-MODE
     MOVE "leather overlay: a zombie villager wears it" TO TL-CASE
     MOVE 6101 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "leather overlay: the zombie villager's overlay is the row zvil_armor_chest" TO TL-CASE
     MOVE "zvil_armor_chest" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE WS-ITEM TO EN-EQ(1, 5)
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 17 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "N" TO TL-MODE
     MOVE "leather overlay: a cow has none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Drawing: a zombie in an iron chestplate draws the piece once; in a leather chestplate it draws the piece and the overlay (twice the piece's vertices) and takes
*>   one more atlas slot (the overlay file), and the overlay vertices are the piece's scaled by 1.001 about the entity origin (layer 17).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-N-BARE
     MOVE "iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-N-IRON
     MOVE "N" TO TL-MODE
     MOVE "leather overlay: an iron chestplate takes two atlas slots" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "leather_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 5)
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-N-LEATHER
     MOVE "leather overlay: a leather chestplate takes a third atlas slot" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-PIECE = WS-N-IRON - WS-N-BARE
     MOVE "leather overlay: the overlay draws the piece's vertices once more" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-N-BARE + 2 * WS-PIECE
     MOVE WS-N-LEATHER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The piece's vertices follow the body's, the overlay's the piece's: the same cuboids 0.1 percent larger about the entity origin (eye-relative (0.5, 0, 0.5)).
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-PIECE
         COMPUTE WS-DX = (RL-EN-X(WS-N-BARE + WS-PIECE + WS-K) - 0.5) - 1.001 * (RL-EN-X(WS-N-BARE + WS-K) - 0.5)
         COMPUTE WS-DY = RL-EN-Y(WS-N-BARE + WS-PIECE + WS-K) - 1.001 * RL-EN-Y(WS-N-BARE + WS-K)
         COMPUTE WS-DZ = (RL-EN-Z(WS-N-BARE + WS-PIECE + WS-K) - 0.5) - 1.001 * (RL-EN-Z(WS-N-BARE + WS-K) - 0.5)
         IF FUNCTION ABS(WS-DX) > 0.0001 OR FUNCTION ABS(WS-DY) > 0.0001 OR FUNCTION ABS(WS-DZ) > 0.0001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "leather overlay: every overlay vertex is the piece's scaled by 1.001 about the entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-LEATHER-OVERLAY.

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
