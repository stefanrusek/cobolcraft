 *> T10402 (bug-sweep: dropped block items drew as flat icons): the item of a block (here the grass block of the mini-vanilla pack) dropped in a
*> standard-set world is the cube of its model (34-9 9.2 thick model; ground display of block/block: scale 0.25, translate (0, 3, 0) / 16): 36 vertices a
*> copy, x and z within 0.125 of the entity, y from 0.0625 + bob to 0.3125 + bob (bob 0.1 at age 0), each face with the sprite of its own direction (the top,
*> the bottom and the sides differ), and the copies by stack size.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-MINU                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-SEEN                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-EXP.
    05 WS-E                BINARY-LONG OCCURS 6 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE SPACES TO WS-KEY
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "grass_block" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 64 TO WS-ID
     MOVE 10.5 TO WS-X WS-Z
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-YAW
     CALL "GIB-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE WS-ITEM TO EN-STACK-ITEM(1)
     MOVE 1 TO EN-STACK-COUNT(1)
     MOVE 0 TO CL-NOW-MS RL-GI-COUNT
     CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "ground block item one grass block is one cube of 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FIRST
     MOVE 36 TO WS-LAST
     CALL "GIB-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE 375 TO WS-E(1)
     MOVE 625 TO WS-E(2)
     MOVE 163 TO WS-E(3)
     MOVE 413 TO WS-E(4)
     MOVE 375 TO WS-E(5)
     MOVE 625 TO WS-E(6)
     CALL "GIB-CLOSE" USING WS-RANGE WS-EXP WS-D
     MOVE "ground block item the cube is 0.25 wide, y 0.1625 to 0.4125 above the feet at age 0 (+-1 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The six faces take their own sprites: the smallest u of each face's six vertices differs between the top, the bottom and the sides.
     MOVE 0 TO WS-DISTINCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 1 TO WS-MINU(WS-I)
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             IF RL-GI-U((WS-I - 1) * 6 + WS-J) < WS-MINU(WS-I)
                 MOVE RL-GI-U((WS-I - 1) * 6 + WS-J) TO WS-MINU(WS-I)
             END-IF
         END-PERFORM
         MOVE 0 TO WS-SEEN
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
             IF WS-MINU(WS-J) = WS-MINU(WS-I)
                 MOVE 1 TO WS-SEEN
             END-IF
         END-PERFORM
         IF WS-SEEN = 0
             ADD 1 TO WS-DISTINCT
         END-IF
     END-PERFORM
     MOVE "ground block item the top, the bottom and the sides of the grass block show three different sprites" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-DISTINCT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Copies by stack size: 2 copies of 36.
     MOVE 2 TO EN-STACK-COUNT(1)
     MOVE 0 TO RL-GI-COUNT
     CALL "VANILLA-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "ground block item a stack of 2 is two cubes (72 vertices)" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GROUND-ITEM-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIB-CLOSE.
*> USING range (6 BINARY-LONG), expected (6), flag out: 1 when every value differs by at most 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RANGE.
    05 L-R                 BINARY-LONG OCCURS 6 TIMES.
 01 L-EXP.
    05 L-E                 BINARY-LONG OCCURS 6 TIMES.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-EXP L-FLAG.
     MOVE 1 TO L-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF FUNCTION ABS(L-R(WS-I) - L-E(WS-I)) > 1
             MOVE 0 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GIB-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIB-SPAWN.
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
 END PROGRAM GIB-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIB-RANGE.
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
         COMPUTE WS-V = FUNCTION INTEGER(RL-GI-X(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(1), WS-V) TO L-R(1)
         MOVE FUNCTION MAX(L-R(2), WS-V) TO L-R(2)
         COMPUTE WS-V = FUNCTION INTEGER(RL-GI-Y(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(3), WS-V) TO L-R(3)
         MOVE FUNCTION MAX(L-R(4), WS-V) TO L-R(4)
         COMPUTE WS-V = FUNCTION INTEGER(RL-GI-Z(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(5), WS-V) TO L-R(5)
         MOVE FUNCTION MAX(L-R(6), WS-V) TO L-R(6)
     END-PERFORM
     GOBACK.
 END PROGRAM GIB-RANGE.



 COPY CLTEST.
