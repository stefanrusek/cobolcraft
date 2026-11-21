*> Implementation test of the armour glint (54 section 19.3): GLINT-UV (the scale and the rotation of the glint texture matrix baked into a texture
*> coordinate: rotate Z by 0.17453292 rad after the scale), ENTITY-OVERLAY layers 13 to 16 (the glint of the armour pieces of layers 5 to 8, only for a piece whose
*> stack has the foil) and ENTITIES-MESH (the glint layers go to RL-GL-VERTEX, not to the opaque entity mesh: the same cuboids with the armour glint scale 0.5 on
*> the model's own texture coordinates, brightness the glint strength 0.75, alpha 1, untinted).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-GLINT.
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
 01 WS-ITEM                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 99.
 01 WS-U                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-UI                  PIC -(5)9.
 01 WS-VI                  PIC -(5)9.
 01 WS-COUNT-A             BINARY-LONG.
 01 WS-COUNT-B             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FK                  PIC X(24).
 01 WS-EXP-U               FLOAT-LONG.
 01 WS-EXP-V               FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "T" TO TL-MODE
*>   GLINT-UV: (1, 0) at scale 0.5 is (0.5 cos a, 0.5 sin a) = (0.492, 0.087); (0, 1) is (-0.087, 0.492); (0, 0) stays.
     MOVE 1 TO WS-U
     MOVE 0 TO WS-V
     MOVE 0.5 TO WS-S
     CALL "GLINT-UV" USING WS-U WS-V WS-S
     MOVE "glint uv (1, 0) at scale 0.5" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "492 87" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-U
     MOVE 1 TO WS-V
     CALL "GLINT-UV" USING WS-U WS-V WS-S
     MOVE "glint uv (0, 1) at scale 0.5" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "-87 492" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-U WS-V
     CALL "GLINT-UV" USING WS-U WS-V WS-S
     MOVE "glint uv (0, 0) stays (0, 0)" TO TL-CASE
     PERFORM SHOW-UV
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Layers: a zombie with an iron helmet (equipment slot 5, EN-EQ index 6) that has the foil: layer 16 is its glint (the code of the piece, 6004, and the model armor_head);
*>   without the foil, or with an empty slot, none; layers 13 to 15 none (no chest, legs or feet).
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "N" TO TL-MODE
     MOVE EN-COUNT TO WS-COUNT-A
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-COUNT-A
     MOVE "iron_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO EN-EQ(1, 6)
     PERFORM VARYING WS-I FROM 13 BY 1 UNTIL WS-I > 16
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-I WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-I-D
         STRING "glint layer " WS-I-D " of a helmet without the foil is none" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-COUNT-B
     MOVE "glint: no foil, nothing goes to the glint mesh" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-EQ-FOIL(1, 6)
     PERFORM VARYING WS-I FROM 13 BY 1 UNTIL WS-I > 16
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 WS-I WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-I-D
         STRING "glint layer " WS-I-D " code of a foil iron helmet" DELIMITED BY SIZE INTO TL-CASE
         IF WS-I = 16
             MOVE 6004 TO TL-EXPECTED-N
         ELSE
             MOVE 0 TO TL-EXPECTED-N
         END-IF
         MOVE WS-CODE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 16 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
     MOVE "T" TO TL-MODE
     MOVE "glint layer 16 uses the model row armor_head" TO TL-CASE
     MOVE "armor_head" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "glint: the opaque mesh is the same with and without the foil" TO TL-CASE
     MOVE WS-COUNT-B TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE TL-EXPECTED-N = WS-COUNT-B - WS-COUNT-A
     MOVE "glint: the glint mesh holds the helmet's vertices (the helmet layer of the opaque mesh)" TO TL-CASE
     MOVE RL-GL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint: the first glint vertex has brightness 0.75" TO TL-CASE
     COMPUTE TL-OBSERVED-N = RL-GL-B(1) * 100
     MOVE 75 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "glint: the first glint vertex has alpha 1, no sky term and no tint" TO TL-CASE
     COMPUTE TL-OBSERVED-N = RL-GL-A(1) * 1000 + RL-GL-SKY(1) * 100 + RL-GL-R(1) * 10 + RL-GL-G(1) * 10 + RL-GL-BLUE(1) * 10
     MOVE 1030 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The coordinate of the first glint vertex is the model-space coordinate of the first helmet vertex of the opaque mesh (the same box, drawn without the foil), scaled and rotated.
     MOVE "armor_head" TO WS-FK
     CALL "ENTITY-MODEL-FIND" USING WS-FK WS-MODEL
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EA-MT-COUNT
         IF EA-MT-MODEL(WS-K) = WS-MODEL AND EA-MT-TEX(WS-K) = 6004
             MOVE WS-K TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE "glint: the helmet's atlas slot exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-U = (RL-EN-U(WS-COUNT-A + 1) * EA-W - EA-MT-X(WS-SLOT)) / EA-MT-W(WS-SLOT)
     COMPUTE WS-V = (RL-EN-V(WS-COUNT-A + 1) * EA-H - EA-MT-Y(WS-SLOT)) / EA-MT-H(WS-SLOT)
     MOVE 0.5 TO WS-S
     CALL "GLINT-UV" USING WS-U WS-V WS-S
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(WS-U * 100 + 0.5) * 1000 + FUNCTION INTEGER(WS-V * 100 + 0.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(RL-GL-U(1) * 100 + 0.5) * 1000 + FUNCTION INTEGER(RL-GL-V(1) * 100 + 0.5)
     MOVE "glint: the first glint vertex's coordinate is the scaled, rotated model coordinate (hundredths)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SHOW-UV.
     COMPUTE WS-A ROUNDED = WS-U * 1000
     COMPUTE WS-B ROUNDED = WS-V * 1000
     MOVE WS-A TO WS-UI
     MOVE WS-B TO WS-VI
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-UI) " " FUNCTION TRIM(WS-VI) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-ENTITY-GLINT.

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

