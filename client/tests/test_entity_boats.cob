 *> Boats, chest boats, rafts and chest rafts (34-8 section 7): 22 table rows (code B) over the four meshes of 7.1, the render sequence of 7.4 (no 1.501 lift: translate
*> (0, 0.375, 0), yaw, scale (-1, -1, 1), a quarter turn: the boat's length lies along z at yaw 0) and the paddle animation of 7.2 driven by the paddle entries 11 and 12 of
*> the metadata (rowing time: pi / 8 more per tick while the paddle is held, 0 when it is not).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-BOATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SUM1                FLOAT-LONG.
 01 WS-SUM2                FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE VALUE 0.
 01 WS-WOODS-DATA.
    05 FILLER PIC X(10) VALUE "oak".
    05 FILLER PIC X(10) VALUE "spruce".
    05 FILLER PIC X(10) VALUE "birch".
    05 FILLER PIC X(10) VALUE "jungle".
    05 FILLER PIC X(10) VALUE "acacia".
    05 FILLER PIC X(10) VALUE "cherry".
    05 FILLER PIC X(10) VALUE "dark_oak".
    05 FILLER PIC X(10) VALUE "pale_oak".
    05 FILLER PIC X(10) VALUE "mangrove".
    05 FILLER PIC X(10) VALUE "poplar".
 01 WS-WOODS REDEFINES WS-WOODS-DATA.
    05 WS-WOOD             PIC X(10) OCCURS 10 TIMES.
 01 WS-IN.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
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
*>   The table rows and their textures: ten woods of boat and chest boat, and the two rafts.
     MOVE "N" TO TL-MODE
     MOVE "acceptance boats the table has 226 rows" TO TL-CASE
     MOVE 226 TO TL-EXPECTED-N
     MOVE CL-MODEL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2
             MOVE SPACES TO WS-KEY24 TL-EXPECTED
             IF WS-I = 11 OR WS-I = 12
                 IF WS-J = 1
                     MOVE "bamboo_raft" TO WS-KEY24
                     MOVE "textures/entity/boat/bamboo.png" TO TL-EXPECTED
                 ELSE
                     MOVE "bamboo_chest_raft" TO WS-KEY24
                     MOVE "textures/entity/chest_boat/bamboo.png" TO TL-EXPECTED
                 END-IF
             ELSE
                 IF WS-J = 1
                     STRING FUNCTION TRIM(WS-WOOD(WS-I)) "_boat" DELIMITED BY SIZE INTO WS-KEY24
                     STRING "textures/entity/boat/" FUNCTION TRIM(WS-WOOD(WS-I)) ".png" DELIMITED BY SIZE INTO TL-EXPECTED
                 ELSE
                     STRING FUNCTION TRIM(WS-WOOD(WS-I)) "_chest_boat" DELIMITED BY SIZE INTO WS-KEY24
                     STRING "textures/entity/chest_boat/" FUNCTION TRIM(WS-WOOD(WS-I)) ".png" DELIMITED BY SIZE INTO TL-EXPECTED
                 END-IF
             END-IF
             CALL "ENTITY-MODEL-FIND" USING WS-KEY24 WS-MODEL
             MOVE "T" TO TL-MODE
             MOVE SPACES TO TL-CASE TL-OBSERVED
             STRING "acceptance boats texture of " FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO TL-CASE
             IF WS-MODEL > 0
                 MOVE CL-MD-PATH(WS-MODEL) TO TL-OBSERVED
             END-IF
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
*>   The four meshes: cuboids drawn (boat 9, chest boat 12, raft 6, chest raft 9) and the part counts.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO EA-MT-COUNT
         EVALUATE WS-I
             WHEN 1 MOVE "oak_boat" TO WS-KEY
             WHEN 2 MOVE "oak_chest_boat" TO WS-KEY
             WHEN 3 MOVE "bamboo_raft" TO WS-KEY
             WHEN OTHER MOVE "bamboo_chest_raft" TO WS-KEY
         END-EVALUATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE "N" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance boats vertices of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 324 TO TL-EXPECTED-N
             WHEN 2 MOVE 432 TO TL-EXPECTED-N
             WHEN 3 MOVE 216 TO TL-EXPECTED-N
             WHEN OTHER MOVE 324 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE RL-EN-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE WS-KEY TO WS-KEY24
         CALL "ENTITY-MODEL-FIND" USING WS-KEY24 WS-MODEL
         CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-STATUS
         MOVE SPACES TO TL-CASE
         STRING "acceptance boats parts of " FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 8 TO TL-EXPECTED-N
             WHEN 2 MOVE 11 TO TL-EXPECTED-N
             WHEN 3 MOVE 4 TO TL-EXPECTED-N
             WHEN OTHER MOVE 7 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE MM-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The pose of 7.4: at yaw 0 the length (28 pixels and the ends) lies along z; at yaw 90 along x. Everything stays between the ground and a block above it.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO EA-MT-COUNT
         MOVE "oak_boat" TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         MOVE 0 TO WS-YAW
         IF WS-I = 2
             MOVE 90 TO WS-YAW
         END-IF
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE 100 TO WS-MINX WS-MINY WS-MINZ
         MOVE -100 TO WS-MAXX WS-MAXY WS-MAXZ
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
             MOVE FUNCTION MIN(WS-MINX, RL-EN-X(WS-J) - 0.5) TO WS-MINX
             MOVE FUNCTION MAX(WS-MAXX, RL-EN-X(WS-J) - 0.5) TO WS-MAXX
             MOVE FUNCTION MIN(WS-MINY, RL-EN-Y(WS-J)) TO WS-MINY
             MOVE FUNCTION MAX(WS-MAXY, RL-EN-Y(WS-J)) TO WS-MAXY
             MOVE FUNCTION MIN(WS-MINZ, RL-EN-Z(WS-J) - 0.5) TO WS-MINZ
             MOVE FUNCTION MAX(WS-MAXZ, RL-EN-Z(WS-J) - 0.5) TO WS-MAXZ
         END-PERFORM
         MOVE "N" TO TL-MODE
         MOVE "acceptance boats the hull is 2 blocks long along z at yaw 0, along x at yaw 90" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-I = 1 AND WS-MAXZ - WS-MINZ > 1.95 AND WS-MAXZ - WS-MINZ < 2.05
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         IF WS-I = 2 AND WS-MAXX - WS-MINX > 1.95 AND WS-MAXX - WS-MINX < 2.05
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance boats the hull stays between the ground and a block above" TO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF WS-MINY > -0.15 AND WS-MAXY < 1.0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The paddle animation of 7.2 on the built boat: rowing time 0 on both sides, then 1.2.
     MOVE "oak_boat" TO WS-KEY24
     CALL "ENTITY-MODEL-FIND" USING WS-KEY24 WS-MODEL
     CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-IV(WS-I)
     END-PERFORM
     CALL "EF8-BOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "left_paddle" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-PART
     MOVE "acceptance boats paddle t 0 left x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-PART) + 0.6544985
     PERFORM CHECK-SMALL
     MOVE "acceptance boats paddle t 0 left y rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-PART) - 0.6608898
     PERFORM CHECK-SMALL
     MOVE "acceptance boats paddle keeps its z rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CZROT(WS-PART) - 0.19634955
     PERFORM CHECK-SMALL
     MOVE "right_paddle" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-PART
     MOVE "acceptance boats paddle t 0 right y rotation is pi minus the left" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-PART) - 2.4807029
     PERFORM CHECK-SMALL
     MOVE 1.2 TO WS-IV(3)
     MOVE 1.2 TO WS-IV(4)
     CALL "EF8-BOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "left_paddle" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-PART
     MOVE "acceptance boats paddle t 1.2 left x rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-PART) + 1.0205094
     PERFORM CHECK-SMALL
     MOVE "acceptance boats paddle t 1.2 left y rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-PART) + 0.1560345
     PERFORM CHECK-SMALL
     MOVE "right_paddle" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-PART
     MOVE "acceptance boats paddle t 1.2 right y rotation" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-PART) - 3.2976272
     PERFORM CHECK-SMALL
*>   The paddle entries 11 and 12 (BOOLEAN) of a boat, the rowing time per tick and the mesh.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE "oak_boat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     MOVE 0 TO WS-YAW
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-SUM1
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM1 = WS-SUM1 + RL-EN-Y(WS-J) + RL-EN-X(WS-J)
     END-PERFORM
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 11 8 1 0 0 WS-LONG
     MOVE "N" TO TL-MODE
     MOVE "acceptance boats paddle left entry is kept" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 12 8 1 0 0 WS-LONG
     MOVE "acceptance boats paddle right entry is kept" TO TL-CASE
     MOVE EN-X2(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 3 TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "acceptance boats left paddle position after 3 ticks (3 pi / 8 in thousandths)" TO TL-CASE
     MOVE 1178 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-WALK-POS(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance boats right paddle position after 3 ticks (thousandths)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-WALK-SPEED(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM2 = WS-SUM2 + RL-EN-Y(WS-J) + RL-EN-X(WS-J)
     END-PERFORM
     MOVE "acceptance boats the rowing paddles move the mesh" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM2 - WS-SUM1 > 0.001 OR WS-SUM1 - WS-SUM2 > 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Released: the position goes back to 0 and the mesh to the first one; a metadata entry of another index changes nothing.
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 11 8 0 0 0 WS-LONG
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 12 8 0 0 0 WS-LONG
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE 1 13 1 60 0 0 WS-LONG
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance boats released paddles are back at 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-WALK-POS(1) * 1000 + EN-WALK-SPEED(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM2 = WS-SUM2 + RL-EN-Y(WS-J) + RL-EN-X(WS-J)
     END-PERFORM
     MOVE "acceptance boats released paddles give the first mesh" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM2 - WS-SUM1 < 0.001 AND WS-SUM1 - WS-SUM2 < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001 AND WS-DIFF > -0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-BOATS.

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

