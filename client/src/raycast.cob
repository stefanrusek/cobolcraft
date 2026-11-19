*> The target block (US4-1; client-surface §3; standin-content §3 eye height 1.6, §11.4 block reach):
*> RAYCAST follows the look ray from the local player's eye (yaw 0 faces +Z, 90 faces -X; positive
*> pitch looks down, as render-list.cob) cell by cell through the replica (a voxel walk: the next
*> cell boundary crossed along any axis comes first) for at most CL-REACH blocks. The first cell
*> whose outline shape the ray meets (a full cube for most blocks; docs/protocol/51) is the target; the face the ray enters it through is the clicked face (05c
*> Direction: crossing a boundary towards +x enters the west face 4, towards -x the east face 5,
*> towards +y the bottom 0, towards -y the top 1, towards +z the north face 2, towards -z the south
*> face 3), and the point where it enters, relative to the block's lowest corner, is the cursor of
*> Use Item On. The eye's own cell is never the target.
*> The entity target (US7-5; standin-content §3 sizes, §10.4 attack reach): the nearest player or mob
*> entity of the replica whose collision box (centred on its position horizontally, from its y up)
*> the same ray enters within CL-ATTACK-REACH blocks and before the target block (slab test: the
*> ray's entry distance is the largest of the three axes' near-plane distances, its exit the
*> smallest far one; an axis the ray does not move along must hold the eye between the planes).
*> An entity target replaces the target block (it is in front of it): TG-HIT becomes 0.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAYCAST.
*> USING CLIENT-STATE: sets TG-HIT and, on a hit, TG-X, TG-Y, TG-Z, TG-FACE and TG-CX, TG-CY, TG-CZ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 COPY CLCONST.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CELL                BINARY-LONG OCCURS 3 TIMES.
 01 WS-STEP                BINARY-LONG OCCURS 3 TIMES.
 01 WS-TMAX                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-TDELTA              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FACE-BASES          PIC X(3) VALUE "402".
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HIT                 FLOAT-LONG.
 01 WS-BLOCK-T             FLOAT-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-LO                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-ATTACK              BINARY-LONG.
 01 WS-BOX-HALF            FLOAT-LONG.
 01 WS-BOX-HEIGHT          FLOAT-LONG.
 01 WS-HT                  FLOAT-LONG.
 01 WS-HAX                 BINARY-LONG.
 01 WS-RT                  FLOAT-LONG.
 01 WS-RAX                 BINARY-LONG.
 01 WS-RORG.
    05 WS-RO               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RDIR.
    05 WS-RD               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-ROFF.
    05 WS-RF               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-OFX                 FLOAT-LONG.
 01 WS-OFY                 FLOAT-LONG.
 01 WS-OFZ                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO TG-HIT TG-ENTITY-HIT
     MOVE 1.0E30 TO WS-BLOCK-T
     COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH * FUNCTION PI / 180
     COMPUTE WS-DIR(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DIR(2) = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-DIR(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     MOVE PL-X TO WS-EYE(1)
     COMPUTE WS-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO WS-EYE(3)
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         MOVE WS-EYE(WS-A) TO WS-RO(WS-A)
         MOVE WS-DIR(WS-A) TO WS-RD(WS-A)
     END-PERFORM
*>   Per axis: the step direction, the ray distance to the first boundary and between boundaries
*>   (an axis the ray does not move along is never crossed).
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-CELL(WS-A) = FUNCTION INTEGER(WS-EYE(WS-A))
         EVALUATE TRUE
             WHEN WS-DIR(WS-A) > 0
                 MOVE 1 TO WS-STEP(WS-A)
                 COMPUTE WS-TMAX(WS-A) = (WS-CELL(WS-A) + 1 - WS-EYE(WS-A)) / WS-DIR(WS-A)
                 COMPUTE WS-TDELTA(WS-A) = 1 / WS-DIR(WS-A)
             WHEN WS-DIR(WS-A) < 0
                 MOVE -1 TO WS-STEP(WS-A)
                 COMPUTE WS-TMAX(WS-A) = (WS-CELL(WS-A) - WS-EYE(WS-A)) / WS-DIR(WS-A)
                 COMPUTE WS-TDELTA(WS-A) = -1 / WS-DIR(WS-A)
             WHEN OTHER
                 MOVE 0 TO WS-STEP(WS-A)
                 MOVE 1.0E30 TO WS-TMAX(WS-A) WS-TDELTA(WS-A)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64 OR TG-HIT = 1
         MOVE 1 TO WS-A
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 3
             IF WS-TMAX(WS-K) < WS-TMAX(WS-A)
                 MOVE WS-K TO WS-A
             END-IF
         END-PERFORM
         MOVE WS-TMAX(WS-A) TO WS-T
         IF WS-T > CL-REACH
             EXIT PERFORM
         END-IF
         ADD WS-STEP(WS-A) TO WS-CELL(WS-A)
         ADD WS-TDELTA(WS-A) TO WS-TMAX(WS-A)
         MOVE WS-CELL(1) TO WS-CX
         MOVE WS-CELL(2) TO WS-CY
         MOVE WS-CELL(3) TO WS-CZ
         CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
*>       A liquid block has no outline shape (29a 1.2): the ray goes through water and lava (a wet plant or a waterlogged block is hit).
*>       Any other block is hit where the ray meets a box of its outline shape (51 block shapes: a slab, a stair, a torch, a fence
*>       and the rest are targeted where they are; the full cube is entered at the cell's face).
         MOVE WS-STATE TO WS-SEEN
         MOVE WS-T TO WS-HT
         MOVE WS-A TO WS-HAX
         IF WS-STATE NOT = 0
             CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
             IF ST-FLUID(WS-STATE + 1) = 1 OR ST-FLUID(WS-STATE + 1) = 2
                 MOVE 0 TO WS-SEEN
             END-IF
         END-IF
         IF WS-SEEN NOT = 0
*>           The outline of the cell for the camera entity's context (51 section 1.8.3 item 5): the light block with a light item and scaffolding with a scaffolding item
*>           in the hand are full cubes.
             CALL "TARGET-OUTLINE" USING CLIENT-STATE WS-STATE WS-SHAPE
             EVALUATE TRUE
                 WHEN WS-SHAPE = 0
                     MOVE 0 TO WS-SEEN
                 WHEN WS-SHAPE > 1
*>                   An offset plant's outline is moved by its model offset (51 section 1.4): the ray moves the other way.
                     CALL "BSH-OFFSET" USING WS-STATE WS-CX WS-CY WS-CZ WS-OFX WS-OFY WS-OFZ
                     COMPUTE WS-RF(1) = WS-RO(1) - WS-OFX
                     COMPUTE WS-RF(2) = WS-RO(2) - WS-OFY
                     COMPUTE WS-RF(3) = WS-RO(3) - WS-OFZ
                     CALL "BSH-RAY" USING WS-SHAPE WS-CX WS-CY WS-CZ WS-ROFF WS-RDIR WS-RT WS-RAX
                     IF WS-RT < 0 OR WS-RT > CL-REACH
                         MOVE 0 TO WS-SEEN
                     ELSE
                         MOVE WS-RT TO WS-HT
                         MOVE WS-RAX TO WS-HAX
                     END-IF
             END-EVALUATE
         END-IF
         IF WS-SEEN NOT = 0
             MOVE 1 TO TG-HIT
             MOVE WS-HT TO WS-BLOCK-T
             MOVE WS-CX TO TG-X
             MOVE WS-CY TO TG-Y
             MOVE WS-CZ TO TG-Z
             COMPUTE TG-FACE = FUNCTION NUMVAL(WS-FACE-BASES(WS-HAX:1))
                 + (1 - WS-STEP(WS-HAX)) / 2
             COMPUTE WS-HIT = WS-EYE(1) + WS-DIR(1) * WS-HT - TG-X
             COMPUTE TG-CX = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
             COMPUTE WS-HIT = WS-EYE(2) + WS-DIR(2) * WS-HT - TG-Y
             COMPUTE TG-CY = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
             COMPUTE WS-HIT = WS-EYE(3) + WS-DIR(3) * WS-HT - TG-Z
             COMPUTE TG-CZ = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
         END-IF
     END-PERFORM
*>   The entity target: nearer than the block and within attack reach.
     COMPUTE WS-BEST = FUNCTION MIN(WS-BLOCK-T, CL-ATTACK-REACH)
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         COMPUTE WS-ET = EN-TYPE(WS-R) + 1
*>       The box of an entity of a standard world comes from its registry row (ENTITY-ATTACK-BOX), that of a stand-in type from CL-ENTITIES.
         MOVE 0 TO WS-ATTACK
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 1
             MOVE EN-BOX-ATTACK(WS-R) TO WS-ATTACK
             MOVE EN-BOX-HALF(WS-R) TO WS-BOX-HALF
             MOVE EN-BOX-HEIGHT(WS-R) TO WS-BOX-HEIGHT
         END-IF
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 0 AND WS-ET >= 1 AND WS-ET <= 30
             MOVE CL-ET-ATTACK(WS-ET) TO WS-ATTACK
             MOVE CL-ET-HALF(WS-ET) TO WS-BOX-HALF
             MOVE CL-ET-HEIGHT(WS-ET) TO WS-BOX-HEIGHT
         END-IF
         IF EN-USED(WS-R) = 1
             IF WS-ATTACK = 1
                 COMPUTE WS-LO(1) = EN-X(WS-R) - WS-BOX-HALF
                 COMPUTE WS-HI(1) = EN-X(WS-R) + WS-BOX-HALF
                 MOVE EN-Y(WS-R) TO WS-LO(2)
                 COMPUTE WS-HI(2) = EN-Y(WS-R) + WS-BOX-HEIGHT
                 COMPUTE WS-LO(3) = EN-Z(WS-R) - WS-BOX-HALF
                 COMPUTE WS-HI(3) = EN-Z(WS-R) + WS-BOX-HALF
                 MOVE 0 TO WS-NEAR
                 MOVE WS-BEST TO WS-FAR
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     IF WS-STEP(WS-A) = 0
                         IF WS-EYE(WS-A) < WS-LO(WS-A) OR WS-EYE(WS-A) > WS-HI(WS-A)
                             MOVE -1 TO WS-FAR
                         END-IF
                     ELSE
                         COMPUTE WS-T1 = (WS-LO(WS-A) - WS-EYE(WS-A)) / WS-DIR(WS-A)
                         COMPUTE WS-T2 = (WS-HI(WS-A) - WS-EYE(WS-A)) / WS-DIR(WS-A)
                         COMPUTE WS-NEAR = FUNCTION MAX(WS-NEAR, FUNCTION MIN(WS-T1, WS-T2))
                         COMPUTE WS-FAR = FUNCTION MIN(WS-FAR, FUNCTION MAX(WS-T1, WS-T2))
                     END-IF
                 END-PERFORM
                 IF WS-NEAR <= WS-FAR AND WS-NEAR < WS-BEST
                     MOVE WS-NEAR TO WS-BEST
                     MOVE 1 TO TG-ENTITY-HIT
                     MOVE EN-ID(WS-R) TO TG-ENTITY
                     MOVE 0 TO TG-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAYCAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TARGET-OUTLINE.
*> USING CLIENT-STATE, state id, shape id out: the outline shape of the state for the local player's collision context (51 section 1.8.3 item 5, rules R-A5 and R-C20): the table's
*> outline, except that the light block (BSH-CTX 1) is a full cube while the main hand holds a light item and scaffolding (BSH-CTX 2 to 4) while it holds a scaffolding item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-HELD-ITEM           BINARY-LONG.
 01 WS-HNS                 PIC X(16).
 01 WS-HPATH               PIC X(40).
 01 WS-HMAX                BINARY-LONG.
 01 WS-HBLK                BINARY-LONG.
 01 WS-HTOOL               PIC X.
 01 WS-HFOOD               BINARY-LONG.
 01 WS-HKNOWN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-SHAPE.
     CALL "BSH-OUT-ID" USING L-STATE L-SHAPE
     IF L-STATE > 0 AND L-STATE < BSH-MAX-STATES
         IF BSH-CTX(L-STATE + 1) > 0 AND PL-SLOT-COUNT(PL-HELD + 1) > 0
             MOVE PL-SLOT-ITEM(PL-HELD + 1) TO WS-HELD-ITEM
             CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-HELD-ITEM WS-HNS WS-HPATH WS-HMAX WS-HBLK WS-HTOOL WS-HFOOD WS-HKNOWN
             IF WS-HKNOWN = 1 AND WS-HPATH = "light" AND BSH-CTX(L-STATE + 1) = 1
                 MOVE 1 TO L-SHAPE
             END-IF
             IF WS-HKNOWN = 1 AND WS-HPATH = "scaffolding" AND BSH-CTX(L-STATE + 1) >= 2
                 MOVE 1 TO L-SHAPE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TARGET-OUTLINE.
