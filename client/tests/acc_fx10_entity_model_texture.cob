*> Acceptance test (spec 002, entity models in the render path; docs/protocol/34-entity-models-6 section 2, 08 section 10.11): a creeper
*> of a standard-set world is drawn with the image the active pack supplies at assets/minecraft/textures/entity/creeper/creeper.png (here the
*> "entmodel" fixture pack: 64 x 32, texel (x, y) = (10 + x, 10 + y, 77, 255)), not the missing texture: the entity atlas gets that image
*> below the three stand-ins (80 x 63, so at row 63 of an 80 x 95 atlas), and the vertices' texture coordinates point into it. The head
*> cuboid's first vertex is the DOWN face's slot 0, texel (16, 0): u = 16 / 80, v = 63 / 95. Without a pack the same creeper gets
*> the missing-texture stripes (test_entity_models).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-FX10-ENTITY-MODEL-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-fx10-model".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 28.
 01 WS-NAMES               PIC X(256) VALUE "entmodel".
 01 WS-IDS                 PIC X(256) VALUE "file/entmodel".
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 5.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-POS                 BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E1                  PIC ZZ9.
 01 WS-E2                  PIC ZZ9.
 01 WS-E3                  PIC ZZ9.
 01 WS-E4                  PIC ZZ9.
 01 WS-E5                  PIC ZZ9.
 01 WS-EU                  PIC 9.999.
 01 WS-EV                  PIC 9.999.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE SPACES TO WS-KEY
     MOVE "creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "TEST-SPAWN-CREEPER" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T" TO TL-MODE
     MOVE "acceptance given the pack has the creeper image then the atlas holds it (64 x 32) at row 63 of an 80 x 95 atlas"
         TO TL-CASE
     MOVE "80 95 64 32 63" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE EA-W TO WS-E1
     MOVE EA-H TO WS-E2
     MOVE EA-MT-W(1) TO WS-E3
     MOVE EA-MT-H(1) TO WS-E4
     MOVE EA-MT-Y(1) TO WS-E5
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The texel (5, 7) of the image is (15, 17, 77, 255) at atlas (5, 63 + 7).
     SET ADDRESS OF B-ATLAS TO EA-ADDR
     COMPUTE WS-POS = ((EA-MT-Y(1) + 7) * EA-W + 5) * 4 + 1
     MOVE "acceptance the atlas pixel of the creeper image is the pack's, (15, 17, 77, 255)" TO TL-CASE
     MOVE "15,17,77,255" TO TL-EXPECTED
     SUBTRACT 1 FROM FUNCTION ORD(B-ATLAS(WS-POS:1)) GIVING WS-E1
     SUBTRACT 1 FROM FUNCTION ORD(B-ATLAS(WS-POS + 1:1)) GIVING WS-E2
     SUBTRACT 1 FROM FUNCTION ORD(B-ATLAS(WS-POS + 2:1)) GIVING WS-E3
     SUBTRACT 1 FROM FUNCTION ORD(B-ATLAS(WS-POS + 3:1)) GIVING WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "," FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     COMPUTE WS-EU ROUNDED = RL-EN-U(1)
     COMPUTE WS-EV ROUNDED = RL-EN-V(1)
     MOVE "acceptance the head cuboid's first vertex takes texel (16, 0): u 16 / 80, v 63 / 95" TO TL-CASE
     MOVE "0.200 0.663" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-EU " " WS-EV DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-FX10-ENTITY-MODEL-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPAWN-CREEPER.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
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
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM TEST-SPAWN-CREEPER.

 COPY CLTEST.
 COPY PACKTEST.
