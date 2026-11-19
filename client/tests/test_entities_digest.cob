*> Equivalence test of the entity mesh (lane perfframe): the vertices ENTITIES-MESH makes for every entity model of the table that has an entity type, in four
*> states (at rest; walking with a head turn and a pitch; aggressive, baby and swinging; the eye elsewhere), are digested (CRC-32 of the 44-byte vertex records
*> of a batch of 16 rows, the digests summed with the batch and the state as weights). The digest was taken from the code before the lane's changes and must stay the
*> same byte for byte: an optimisation of the entity mesh changes its cost, never a vertex. The digest of a batch also has to differ from the one of another state
*> (the cases are not vacuous).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITIES-DIGEST.
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
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BATCH               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TILDE               BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROWS                BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ZERO                BINARY-DOUBLE VALUE 0.
 01 WS-BYTES               BINARY-DOUBLE.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED.
 01 WS-DIGEST              BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-STATE-DIGEST        BINARY-DOUBLE UNSIGNED OCCURS 4 TIMES VALUE 0.
 01 WS-VERTS               BINARY-DOUBLE VALUE 0.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-BAKE-US             BINARY-DOUBLE.
 01 WS-BAKES               BINARY-LONG.
 01 WS-BAKES0              BINARY-LONG.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE OCCURS 4 TIMES VALUE 0.
 01 WS-USE                 PIC 9(9) OCCURS 4 TIMES.
 01 WS-WEIGHT              BINARY-DOUBLE.
 01 WS-D20                 PIC Z(18)9.
 01 WS-D9                  PIC 9(9).
 01 WS-DONE                BINARY-LONG VALUE 0.
 01 WS-SEEN-KEYS.
    05 WS-SEEN             PIC X(20) OCCURS 200 TIMES.
 01 WS-SEEN-COUNT          BINARY-LONG VALUE 0.
 01 WS-BASE                PIC X(20).
 01 WS-DUP                 BINARY-LONG.
 01 WS-EXPECT              BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 1 TO RL-CULL-DISABLE
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
*>   One row for every distinct base key of the model table (the part of a key before "~") that is an entity type of the content.
     PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > CL-MODEL-COUNT
         MOVE SPACES TO WS-BASE
         MOVE CL-MD-KEY(WS-M) TO WS-BASE
         MOVE 0 TO WS-TILDE
         INSPECT WS-BASE TALLYING WS-TILDE FOR CHARACTERS BEFORE INITIAL "~"
         IF WS-TILDE < 20
             MOVE SPACES TO WS-BASE(WS-TILDE + 1:)
         END-IF
         MOVE 0 TO WS-DUP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SEEN-COUNT
             IF WS-SEEN(WS-I) = WS-BASE
                 MOVE 1 TO WS-DUP
             END-IF
         END-PERFORM
         IF WS-DUP = 0 AND WS-BASE NOT = SPACES
             ADD 1 TO WS-SEEN-COUNT
             MOVE WS-BASE TO WS-SEEN(WS-SEEN-COUNT)
             MOVE SPACES TO WS-KEY
             MOVE WS-BASE TO WS-KEY
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
             IF WS-STATUS = 0
                 ADD 1 TO WS-ROWS
                 COMPUTE WS-ID = 100 + WS-ROWS
                 COMPUTE WS-X = 10 + FUNCTION MOD(WS-ROWS, 4) * 5
                 COMPUTE WS-Q = FUNCTION MOD(WS-ROWS, 16) / 4
                 COMPUTE WS-Z = 10 + WS-Q * 5
                 COMPUTE WS-YAW = FUNCTION MOD(WS-ROWS * 37, 360)
                 CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO WS-STATE
     PERFORM VARYING WS-STATE FROM 1 BY 1 UNTIL WS-STATE > 4
*>       The state of every row.
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
             EVALUATE WS-STATE
                 WHEN 1
                     CONTINUE
                 WHEN 2
                     COMPUTE EN-WALK-POS(WS-R) = 0.3 * WS-R
                     COMPUTE EN-WALK-SPEED(WS-R) = 0.1 + FUNCTION MOD(WS-R, 5) * 0.2
                     COMPUTE EN-HEAD-YAW(WS-R) = EN-YAW(WS-R) + FUNCTION MOD(WS-R * 13, 60) - 30
                     COMPUTE EN-PITCH(WS-R) = FUNCTION MOD(WS-R * 7, 50) - 25
                     COMPUTE EN-AGE(WS-R) = 20 + WS-R
                 WHEN 3
                     IF FUNCTION MOD(WS-R, 2) = 1
                         MOVE 4 TO EN-MOB-FLAGS(WS-R)
                     END-IF
                     IF FUNCTION MOD(WS-R, 3) = 0
                         MOVE 1 TO EN-BABY(WS-R)
                     END-IF
                     COMPUTE EN-WALK-POS(WS-R) = 1.1 * WS-R
                     MOVE 1 TO EN-SW-ACTIVE(WS-R)
                     MOVE 1 TO EN-SW-TYPE(WS-R)
                     COMPUTE EN-SW-ANIM(WS-R) = 0.4 + FUNCTION MOD(WS-R, 3) * 0.2
                 WHEN OTHER
                     COMPUTE EN-WALK-POS(WS-R) = 2.5 + 0.2 * WS-R
                     COMPUTE EN-AGE(WS-R) = 5 + WS-R
             END-EVALUATE
         END-PERFORM
         MOVE 10 TO WS-EYE(1) WS-EYE(3)
         MOVE 66 TO WS-EYE(2)
         IF WS-STATE = 4
             MOVE 17.25 TO WS-EYE(1)
             MOVE 61.5 TO WS-EYE(2)
             MOVE 3.125 TO WS-EYE(3)
         END-IF
*>       Batches of 16 rows (only those are in use for the batch), digested one after the other.
         COMPUTE WS-N = (EN-COUNT + 15) / 16
         PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B >= WS-N
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
                 MOVE 0 TO EN-USED(WS-R)
                 COMPUTE WS-BATCH = (WS-R - 1) / 16
                 IF WS-BATCH = WS-B
                     MOVE 1 TO EN-USED(WS-R)
                 END-IF
             END-PERFORM
             CALL STATIC "clock" RETURNING WS-T0
             CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
             CALL STATIC "clock" RETURNING WS-T1
             COMPUTE WS-US(WS-STATE) = WS-US(WS-STATE) + WS-T1 - WS-T0
             COMPUTE WS-BYTES = RL-EN-COUNT * 44
             ADD RL-EN-COUNT TO WS-VERTS
             MOVE 0 TO WS-CRC
             IF WS-BYTES > 0
                 CALL STATIC "crc32" USING BY VALUE WS-ZERO BY REFERENCE RL-EN-VERTEX(1) BY VALUE WS-BYTES RETURNING WS-CRC
             END-IF
             COMPUTE WS-WEIGHT = (WS-STATE * 1000 + WS-B + 1) * 1000003
             COMPUTE WS-DIGEST = FUNCTION MOD(WS-DIGEST + WS-CRC * WS-WEIGHT, 9223372036854775783)
             COMPUTE WS-STATE-DIGEST(WS-STATE) = FUNCTION MOD(WS-STATE-DIGEST(WS-STATE) + WS-CRC * (WS-B + 1), 9223372036854775783)
         END-PERFORM
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
             MOVE 1 TO EN-USED(WS-R)
         END-PERFORM
     END-PERFORM
     MOVE WS-ROWS TO WS-D9
     MOVE WS-VERTS TO WS-D20
     DISPLAY "entity rows " WS-D9 " vertices " WS-D20
     MOVE WS-DIGEST TO WS-D20
     DISPLAY "DIGEST entities " WS-D20
     PERFORM VARYING WS-STATE FROM 1 BY 1 UNTIL WS-STATE > 4
         MOVE WS-US(WS-STATE) TO WS-USE(WS-STATE)
     END-PERFORM
     DISPLAY "PERF entities-mesh us (116 rows, ENTITIES-MESH CPU per state): " WS-USE(1) " " WS-USE(2) " " WS-USE(3) " " WS-USE(4)
     MOVE "test entities digest: the digest of the entity mesh of every model in four states is the one taken before the optimisations" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "6106902634934864984" TO TL-EXPECTED
     MOVE WS-DIGEST TO WS-D20
     MOVE FUNCTION TRIM(WS-D20) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test entities digest: the entity mesh of every model in four states has vertices (rows and vertices)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "rows above 100, vertices above 100000" TO TL-EXPECTED
     IF WS-ROWS > 100 AND WS-VERTS > 100000
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-ROWS TO WS-D9
         MOVE WS-VERTS TO WS-D20
         STRING "rows " WS-D9 " vertices " WS-D20 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test entities digest: the states do not all make the same mesh" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "different" TO TL-EXPECTED
     IF WS-STATE-DIGEST(1) NOT = WS-STATE-DIGEST(2) AND WS-STATE-DIGEST(2) NOT = WS-STATE-DIGEST(3)
             AND WS-STATE-DIGEST(3) NOT = WS-STATE-DIGEST(4) AND WS-STATE-DIGEST(1) NOT = WS-STATE-DIGEST(4)
         MOVE "different" TO TL-OBSERVED
     ELSE
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITIES-DIGEST.

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

 COPY CLTEST.
