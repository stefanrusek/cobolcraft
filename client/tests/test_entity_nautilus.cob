 *> Nautilus and zombie nautilus (34-8 section 6): the adult model (shell with three boxes, body with two, three mouth boxes: 8 cuboids, texture 128 x 128), the baby
 *> (64 x 64) and the zombie nautilus drawn at rest from the table rows nautilus, nautilus~b and zombie_nautilus.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NAUTILUS.
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
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 9.
 01 WS-MODEL               BINARY-LONG.
 01 WS-CODE                BINARY-LONG VALUE 0.
 01 WS-PATH                PIC X(64).
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO EA-MT-COUNT
         IF WS-I = 3
             MOVE "zombie_nautilus" TO WS-KEY
         ELSE
             MOVE "nautilus" TO WS-KEY
         END-IF
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         IF WS-I = 2
             MOVE 1 TO EN-BABY(1)
         END-IF
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE "N" TO TL-MODE
         MOVE WS-I TO WS-I-D
         MOVE SPACES TO TL-CASE
         STRING "acceptance nautilus case " WS-I-D " draws 8 cuboids" DELIMITED BY SIZE INTO TL-CASE
         MOVE 288 TO TL-EXPECTED-N
         MOVE RL-EN-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE 1 WS-MODEL
         MOVE SPACES TO TL-CASE
         STRING "acceptance nautilus case " WS-I-D " row" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         EVALUATE WS-I
             WHEN 1 MOVE "nautilus" TO TL-EXPECTED
             WHEN 2 MOVE "nautilus~b" TO TL-EXPECTED
             WHEN OTHER MOVE "zombie_nautilus" TO TL-EXPECTED
         END-EVALUATE
         MOVE SPACES TO TL-OBSERVED
         IF WS-MODEL > 0
             MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-PATH
         MOVE SPACES TO TL-CASE
         STRING "acceptance nautilus case " WS-I-D " texture" DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE "textures/entity/nautilus/nautilus.png" TO TL-EXPECTED
             WHEN 2 MOVE "textures/entity/nautilus/nautilus_baby.png" TO TL-EXPECTED
             WHEN OTHER MOVE "textures/entity/nautilus/zombie_nautilus.png" TO TL-EXPECTED
         END-EVALUATE
         MOVE SPACES TO TL-OBSERVED
         IF WS-MODEL > 0
             MOVE CL-MD-PATH(WS-MODEL) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ENTITY-NAUTILUS.

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

