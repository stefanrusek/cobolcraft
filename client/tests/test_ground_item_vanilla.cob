*> Dropped items of a standard-set world (docs/protocol/34-entity-models-9-non-living-entities.md section 9.1 and 9.2, ItemEntityRenderer):
*> the "item" entity is drawn as its item's flat model (the icon quad 0.5 wide of the ground display transform: model box x -0.25..0.25,
*> y -0.125..0.375, so base = 0.1875) lifted by bob = sin(ageInTicks / 10 + bobOffs) 0.1 + 0.1, turned about Y by ageInTicks / 20 + bobOffs radians,
*> in renderedAmount copies (1, 2 for 2 to 16, 3 for 17 to 32, 4 for 33 to 48, 5): flat copies step along z by zs x 1.5 = 0.046875 from
*> -(step (n - 1)) / 2, the later ones scattered in x and y by (r x 2 - 1) x 0.15 x 0.5 with r drawn from the Java LCG seeded with the item id.
*> Each copy is two triangles per side (12 vertices, both sides). bobOffs is not on the wire (the client draws it at random): the replica
*> takes entity id mod 64 / 64 x 2 pi, so id 64 has phase 0 as the cases below use.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-VANILLA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
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
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-EXP.
    05 WS-E                BINARY-LONG OCCURS 6 TIMES.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-EDIT                PIC -(6)9.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE SPACES TO WS-KEY
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 64 TO WS-ID
     MOVE 10.5 TO WS-X WS-Z
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-YAW
     CALL "GIV-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
*>   Without a stack nothing is drawn.
     MOVE 0 TO CL-NOW-MS
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 34-9§9 dropped item without a stack draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Copies by stack size.
     MOVE 4 TO EN-STACK-ITEM(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE 1 TO EN-STACK-COUNT(1)
             WHEN 2 MOVE 2 TO EN-STACK-COUNT(1)
             WHEN 3 MOVE 16 TO EN-STACK-COUNT(1)
             WHEN 4 MOVE 17 TO EN-STACK-COUNT(1)
             WHEN 5 MOVE 32 TO EN-STACK-COUNT(1)
             WHEN 6 MOVE 33 TO EN-STACK-COUNT(1)
             WHEN 7 MOVE 48 TO EN-STACK-COUNT(1)
             WHEN OTHER MOVE 64 TO EN-STACK-COUNT(1)
         END-EVALUATE
         CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
         MOVE SPACES TO TL-CASE
         MOVE EN-STACK-COUNT(1) TO WS-EDIT
         STRING "acceptance US15 34-9§9.1 a stack of " FUNCTION TRIM(WS-EDIT) " is drawn in renderedAmount copies of 12 vertices"
             DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-I
             WHEN 1 MOVE 12 TO TL-EXPECTED-N
             WHEN 2 MOVE 24 TO TL-EXPECTED-N
             WHEN 3 MOVE 24 TO TL-EXPECTED-N
             WHEN 4 MOVE 36 TO TL-EXPECTED-N
             WHEN 5 MOVE 36 TO TL-EXPECTED-N
             WHEN 6 MOVE 48 TO TL-EXPECTED-N
             WHEN 7 MOVE 48 TO TL-EXPECTED-N
             WHEN OTHER MOVE 60 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE RL-GI-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   One copy at age 0: bob 0.1, y 0.1625..0.6625 above the feet, x 0.25..0.75, z 0.5 from the eye, no spin.
     MOVE 1 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE 12 TO WS-LAST
     CALL "GIV-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE 250 TO WS-E(1)
     MOVE 750 TO WS-E(2)
     MOVE 163 TO WS-E(3)
     MOVE 663 TO WS-E(4)
     MOVE 500 TO WS-E(5)
     MOVE 500 TO WS-E(6)
     CALL "GIV-CLOSE" USING WS-RANGE WS-EXP WS-D
     MOVE "acceptance US15 34-9§9.2 one copy at age 0: x .25..75, y bob .1 + base .1875 - .125 = .1625 to .6625, z 0 (+-1 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Age 20 ticks (1000 ms): spin 1 radian, bob sin 2 x 0.1 + 0.1 = 0.19093.
     MOVE 1000 TO CL-NOW-MS
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GIV-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE 365 TO WS-E(1)
     MOVE 635 TO WS-E(2)
     MOVE 253 TO WS-E(3)
     MOVE 753 TO WS-E(4)
     MOVE 290 TO WS-E(5)
     MOVE 710 TO WS-E(6)
     CALL "GIV-CLOSE" USING WS-RANGE WS-EXP WS-D
     MOVE "acceptance US15 34-9§9.2 at age 20 the item is turned 1 radian about Y and has bobbed to .19093 (+-1 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Two copies at age 0: z -0.0234375 and +0.0234375 (step 0.046875 from -(step x 1) / 2), the second scattered by the LCG seeded with the item id.
     MOVE 0 TO CL-NOW-MS
     MOVE 2 TO EN-STACK-COUNT(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE 12 TO WS-LAST
     CALL "GIV-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE 250 TO WS-E(1)
     MOVE 750 TO WS-E(2)
     MOVE 163 TO WS-E(3)
     MOVE 663 TO WS-E(4)
     MOVE 477 TO WS-E(5)
     MOVE 477 TO WS-E(6)
     CALL "GIV-CLOSE" USING WS-RANGE WS-EXP WS-D
     MOVE "acceptance US15 34-9§9.2 flat copies: the first of two lies at z -0.0234375 (+-1 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO WS-FIRST
     MOVE 24 TO WS-LAST
     CALL "GIV-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE EN-STACK-ITEM(1) TO WS-SEED
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R1
     CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-R2
     COMPUTE WS-DX = (WS-R1 * 2 - 1) * 0.075
     COMPUTE WS-DY = (WS-R2 * 2 - 1) * 0.075
     COMPUTE WS-E(1) = FUNCTION INTEGER((0.25 + WS-DX) * 1000 + 0.5)
     COMPUTE WS-E(2) = FUNCTION INTEGER((0.75 + WS-DX) * 1000 + 0.5)
     COMPUTE WS-E(3) = FUNCTION INTEGER((0.1625 + WS-DY) * 1000 + 0.5)
     COMPUTE WS-E(4) = FUNCTION INTEGER((0.6625 + WS-DY) * 1000 + 0.5)
     MOVE 523 TO WS-E(5) WS-E(6)
     CALL "GIV-CLOSE" USING WS-RANGE WS-EXP WS-D
     MOVE "acceptance US15 34-9§9.2 the second copy lies at z +0.0234375 scattered by the seeded draws (r1, r2) x 0.15 x 0.5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GROUND-ITEM-VANILLA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIV-CLOSE.
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
 END PROGRAM GIV-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIV-SPAWN.
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
 END PROGRAM GIV-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GIV-RANGE.
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
 END PROGRAM GIV-RANGE.


 COPY CLTEST.
