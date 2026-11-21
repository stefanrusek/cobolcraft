*> Further humanoid mobs of a standard-set world in the render path (docs/protocol/34-entity-models-2 section 5.2 renderer table, 4 setupAnim variants):
*> husk, drowned, stray, wither skeleton, piglin, piglin brute and zombified piglin are each drawn alone as whole cuboids (36 vertices) of their
*> own model row of CL-MODELS (rest head and limbs by the variant's animation); the husk is the zombie's body, the piglin has ears the zombie lacks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-MOBS-MORE.
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
 01 WS-ID                  BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-NAME                PIC X(20).
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
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         EVALUATE WS-I
             WHEN 0 MOVE "zombie" TO WS-NAME
             WHEN 1 MOVE "husk" TO WS-NAME
             WHEN 2 MOVE "drowned" TO WS-NAME
             WHEN 3 MOVE "stray" TO WS-NAME
             WHEN 4 MOVE "wither_skeleton" TO WS-NAME
             WHEN 5 MOVE "piglin" TO WS-NAME
             WHEN 6 MOVE "piglin_brute" TO WS-NAME
             WHEN OTHER MOVE "zombified_piglin" TO WS-NAME
         END-EVALUATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         IF WS-I = 0
             MOVE RL-EN-COUNT TO WS-ZOMBIE
         END-IF
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 34-2§5.2 " FUNCTION TRIM(WS-NAME) " is drawn as whole cuboids of its own model, at least the zombie's body"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF RL-EN-COUNT >= WS-ZOMBIE AND FUNCTION MOD(RL-EN-COUNT, 36) = 0 AND WS-ZOMBIE >= 216
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-I >= 5 AND WS-I <= 6
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 34-2§5.2 " FUNCTION TRIM(WS-NAME) " has the ears the zombie lacks"
                 DELIMITED BY SIZE INTO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
             MOVE 0 TO TL-OBSERVED-N
             IF RL-EN-COUNT > WS-ZOMBIE
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ENTITY-MOBS-MORE.

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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-RANGE.
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
 END PROGRAM MM-RANGE.


 COPY CLTEST.
