*> Emissive eyes layers of the entity models (docs/protocol/34-entity-models-1 8.5 EyesLayer, 34-6 3 and 6): the spider, cave spider and
*> enderman each draw their own posed model once more with the eyes texture (textures/entity/spider/spider_eyes.png, enderman/enderman_eyes.png;
*> there is one eyes texture for both spiders), full bright (no light, no face shading: brightness 1 on every vertex). The eyes layer is the
*> same mesh as the body: spider and cave spider 11 cuboids (head, two body parts, eight legs) each, so 22 cuboids = 792 vertices with the
*> layer. The render type `eyes` of 34-1 6.7 has depth test GREATER_THAN_OR_EQUAL with depth writes off (drawn over its own body): the
*> client draws the layer into the opaque entity mesh instead, enlarged by 0.3 percent about the entity origin so it lies just outside the body.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-EYES.
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
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-BODY-BRIGHT         BINARY-LONG.
 01 WS-EYES-BRIGHT         BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE-B.
    05 WS-RB               BINARY-LONG OCCURS 6 TIMES.
 01 WS-RANGE-E.
    05 WS-RE               BINARY-LONG OCCURS 6 TIMES.
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
     MOVE 64 TO WS-Y
     MOVE 10.5 TO WS-X WS-Z
     MOVE 0 TO WS-YAW
     MOVE 1 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1 MOVE "spider" TO WS-NAME
             WHEN 2 MOVE "cave_spider" TO WS-NAME
             WHEN OTHER MOVE "enderman" TO WS-NAME
         END-EVALUATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         CALL "TEST-EYE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 34-1§8.5 eyes layer: " FUNCTION TRIM(WS-NAME) " draws its model twice (body and eyes layer)"
             DELIMITED BY SIZE INTO TL-CASE
         COMPUTE WS-HALF = RL-EN-COUNT / 2
         MOVE FUNCTION MOD(RL-EN-COUNT, 72) TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         IF WS-I < 3
             MOVE 792 TO TL-EXPECTED-N
             MOVE RL-EN-COUNT TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       Body half: lit by the cell (light 0: 0.1 at least, below 1); eyes half: every vertex full bright 1.
         MOVE 0 TO WS-BODY-BRIGHT WS-EYES-BRIGHT
         PERFORM VARYING WS-FIRST FROM 1 BY 1 UNTIL WS-FIRST > WS-HALF
             IF RL-EN-B(WS-FIRST) < 1
                 ADD 1 TO WS-BODY-BRIGHT
             END-IF
         END-PERFORM
         PERFORM VARYING WS-FIRST FROM WS-HALF BY 1 UNTIL WS-FIRST > RL-EN-COUNT
             IF WS-FIRST > WS-HALF AND RL-EN-B(WS-FIRST) = 1 AND RL-EN-SKY(WS-FIRST) = 0
                 ADD 1 TO WS-EYES-BRIGHT
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 34-1§8.5 eyes layer: " FUNCTION TRIM(WS-NAME) " body is lit by the cell, every eyes vertex is full bright"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-HALF TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = FUNCTION MIN(WS-BODY-BRIGHT, WS-EYES-BRIGHT)
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       The eyes layer lies just outside the body: its extent is wider.
         MOVE 1 TO WS-FIRST
         MOVE WS-HALF TO WS-LAST
         CALL "TEST-EYE-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE-B
         COMPUTE WS-FIRST = WS-HALF + 1
         MOVE RL-EN-COUNT TO WS-LAST
         CALL "TEST-EYE-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE-E
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 34-1§8.5 eyes layer: " FUNCTION TRIM(WS-NAME) " eyes layer encloses the body (scale 1.003)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-RE(1) <= WS-RB(1) AND WS-RE(2) >= WS-RB(2) AND WS-RE(4) >= WS-RB(4) AND WS-RE(6) >= WS-RB(6)
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The eyes rows of the table: their key is no entity type, the textures are the eyes images, the base rows name them as extra layers.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 34-6§6 spider eyes texture is shared by both spiders, enderman eyes has its own (CL-MODELS)" TO TL-CASE
     MOVE "textures/entity/spider/spider_eyes.png textures/entity/spider/spider_eyes.png textures/entity/enderman/enderman_eyes.png"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CL-MD-PATH(CL-MD-EXTRA(5))) " " FUNCTION TRIM(CL-MD-PATH(CL-MD-EXTRA(18))) " "
         FUNCTION TRIM(CL-MD-PATH(CL-MD-EXTRA(20))) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-EYES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EYE-SPAWN.
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
 END PROGRAM TEST-EYE-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EYE-RANGE.
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
 END PROGRAM TEST-EYE-RANGE.

 COPY CLTEST.
