*> Live pistons, part 4: the pushing of entities (docs/protocol/30-redstone-3-pistons.md section 8; PistonMovingBlockEntity.moveCollidedEntities, moveEntityByPiston, fixEntityWithinPistonBase).
*> The server pushes the entities of the tracker (mobs, ground items, carts, boats...); a player is not pushed here: its position belongs to its client, which runs the same arithmetic for the local player (10.1).
*> Approximations (open): the world collision of a pushed entity is the overlap test of its box (ENTITY-BOX-HITS) with the largest free distance found by 24 halvings and no step up; the collision shape
*> of a moving block of another piston is not looked at (a pushed entity may overlap one); the on-ground flag keeps its value; the honey block's sticking (8.2) and the stuck-speed multiplier of 8.3 are not done;
*> an armor stand that is a marker is not told from an armor stand.
*>   PST-PUSH-ENTITIES USING block entity index         moveCollidedEntities for the tick of PST-MBE-TICK that raises the progress (called before the progress changes)
*>   PST-PUSH-ONE USING PP-ARG, tracker row             one entity: the slime launch, the push distance, the push and, for a retracting source, the fix of an entity in the base cell
*>   PST-PUSH-MOVE USING tracker row, amount, direction moveEntityByPiston: the per tick accumulators (at most 0.51 a block per axis and tick), the world collision, ENTITY-MOVE
*>   PST-PUSH-BOX USING tracker row, box out            the collision box of an entity: min x y z, max x y z

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUSH-BOX.
*> USING tracker row, box out (6 FLOAT-LONG: min x, y, z, max x, y, z): the box of the entity's type (ET-WIDTH-MILLI, ET-HEIGHT-MILLI) at its position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 LOCAL-STORAGE SECTION.
 01 LS-TYPE                BINARY-LONG.
 01 LS-HALF                FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-ROW L-BOX.
     MOVE EN-TYPE(L-ROW) TO LS-TYPE
     COMPUTE LS-HALF = ET-WIDTH-MILLI(LS-TYPE + 1) / 2000
     COMPUTE LS-HEIGHT = ET-HEIGHT-MILLI(LS-TYPE + 1) / 1000
     COMPUTE L-B(1) = EN-X(L-ROW) - LS-HALF
     MOVE EN-Y(L-ROW) TO L-B(2)
     COMPUTE L-B(3) = EN-Z(L-ROW) - LS-HALF
     COMPUTE L-B(4) = EN-X(L-ROW) + LS-HALF
     COMPUTE L-B(5) = EN-Y(L-ROW) + LS-HEIGHT
     COMPUTE L-B(6) = EN-Z(L-ROW) + LS-HALF
     GOBACK.
 END PROGRAM PST-PUSH-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUSH-MOVE.
*> USING tracker row, amount (FLOAT-LONG, positive), direction (0 down, 1 up, 2 north, 3 south, 4 west, 5 east): moveEntityByPiston (8.3) without the noclip direction (the moving blocks are not collided with). limitPistonMovement:
*> the accumulator of the axis (reset when the game time differs from the one stored) takes the movement and stays within -0.51 to 0.51; the change of the accumulator is the allowed movement, and one of at most
*> 9.999999747378752e-6 is dropped. The entity then moves as far as the blocks allow and ENTITY-MOVE tells its viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-AX-STR              PIC X(6) VALUE "223311".
 01 WS-AX-TAB REDEFINES WS-AX-STR.
    05 WS-AX               PIC 9 OCCURS 6 TIMES.
 01 WS-DELTAS.
    05 WS-DE OCCURS 1024 TIMES.
       10 WS-DE-TIME       BINARY-DOUBLE.
       10 WS-DE-ACC        FLOAT-LONG OCCURS 3 TIMES.
 LOCAL-STORAGE SECTION.
 01 LS-AXIS                BINARY-LONG.
 01 LS-SIGN                BINARY-LONG.
 01 LS-ACC                 FLOAT-LONG.
 01 LS-RAW                 FLOAT-LONG.
 01 LS-NEW                 FLOAT-LONG.
 01 LS-ALLOWED             FLOAT-LONG.
 01 LS-POS                 FLOAT-LONG OCCURS 3 TIMES.
 01 LS-TRY                 FLOAT-LONG OCCURS 3 TIMES.
 01 LS-QX                  FLOAT-LONG.
 01 LS-QY                  FLOAT-LONG.
 01 LS-QZ                  FLOAT-LONG.
 01 LS-LO                  FLOAT-LONG.
 01 LS-HI                  FLOAT-LONG.
 01 LS-MID                 FLOAT-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-HIT                 BINARY-LONG.
 01 LS-TOP                 BINARY-LONG.
 01 LS-YAW                 FLOAT-SHORT.
 01 LS-PITCH               FLOAT-SHORT.
 01 LS-GROUND              BINARY-LONG.
 01 LS-DIM                 BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               FLOAT-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-DIR.
     IF WS-DE-TIME(L-ROW) NOT = CW-TICKS
         MOVE CW-TICKS TO WS-DE-TIME(L-ROW)
         MOVE 0 TO WS-DE-ACC(L-ROW, 1) WS-DE-ACC(L-ROW, 2) WS-DE-ACC(L-ROW, 3)
     END-IF
     MOVE WS-AX(L-DIR + 1) TO LS-AXIS
     COMPUTE LS-SIGN = 2 * FUNCTION MOD(L-DIR, 2) - 1
     MOVE WS-DE-ACC(L-ROW, LS-AXIS) TO LS-ACC
     COMPUTE LS-RAW = LS-ACC + LS-SIGN * L-AMOUNT
     COMPUTE LS-NEW = FUNCTION MAX(-0.51, FUNCTION MIN(0.51, LS-RAW))
     COMPUTE LS-ALLOWED = LS-NEW - LS-ACC
     MOVE LS-NEW TO WS-DE-ACC(L-ROW, LS-AXIS)
     IF FUNCTION ABS(LS-ALLOWED) > 0.000009999999747378752
         MOVE EN-DIM(L-ROW) TO LS-DIM
         MOVE EN-TYPE(L-ROW) TO LS-TYPE
         MOVE EN-X(L-ROW) TO LS-POS(1) LS-TRY(1)
         MOVE EN-Y(L-ROW) TO LS-POS(2) LS-TRY(2)
         MOVE EN-Z(L-ROW) TO LS-POS(3) LS-TRY(3)
         COMPUTE LS-TRY(LS-AXIS) = LS-POS(LS-AXIS) + LS-ALLOWED
         MOVE LS-TRY(1) TO LS-QX
         MOVE LS-TRY(2) TO LS-QY
         MOVE LS-TRY(3) TO LS-QZ
         CALL "ENTITY-BOX-HITS" USING LS-DIM LS-TYPE LS-QX LS-QY LS-QZ LS-HIT LS-TOP
         IF LS-HIT = 1
             MOVE 0 TO LS-LO
             MOVE LS-ALLOWED TO LS-HI
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 24
                 COMPUTE LS-MID = (LS-LO + LS-HI) / 2
                 COMPUTE LS-TRY(LS-AXIS) = LS-POS(LS-AXIS) + LS-MID
                 MOVE LS-TRY(1) TO LS-QX
                 MOVE LS-TRY(2) TO LS-QY
                 MOVE LS-TRY(3) TO LS-QZ
                 CALL "ENTITY-BOX-HITS" USING LS-DIM LS-TYPE LS-QX LS-QY LS-QZ LS-HIT LS-TOP
                 IF LS-HIT = 1
                     MOVE LS-MID TO LS-HI
                 ELSE
                     MOVE LS-MID TO LS-LO
                 END-IF
             END-PERFORM
             COMPUTE LS-TRY(LS-AXIS) = LS-POS(LS-AXIS) + LS-LO
         END-IF
         MOVE EN-YAW(L-ROW) TO LS-YAW
         MOVE EN-PITCH(L-ROW) TO LS-PITCH
         MOVE EN-ON-GROUND(L-ROW) TO LS-GROUND
         MOVE LS-TRY(1) TO LS-QX
         MOVE LS-TRY(2) TO LS-QY
         MOVE LS-TRY(3) TO LS-QZ
         CALL "ENTITY-MOVE" USING L-ROW LS-QX LS-QY LS-QZ LS-YAW LS-PITCH LS-GROUND
     END-IF
     GOBACK.
 END PROGRAM PST-PUSH-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUSH-ONE.
*> USING PP-ARG (PUSHARG.cpy), tracker row: 8.1 steps 5.1 to 5.6 for one entity of the search box. An entity that the piston skips (the keys of Entity.getPistonPushReaction IGNORE_ENTITY, 5.2) and one whose
*> box does not meet the search box are left alone. A slime block sets the component of the motion along the movement axis to 1 or -1 (a ground item has all three components; of another entity only the vertical
*> EN-VY is a motion). The push is the largest overlap depth over the shape's boxes (getMovement of the movement area of each box shifted by the offset), at most the progress step, plus 0.01. A retracting source
*> piston then pushes an entity still in its cell back out of the cell (fixEntityWithinPistonBase, 8.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CTBSHAPE.
 01 WS-AX-STR              PIC X(6) VALUE "223311".
 01 WS-AX-TAB REDEFINES WS-AX-STR.
    05 WS-AX               PIC 9 OCCURS 6 TIMES.
 LOCAL-STORAGE SECTION.
 01 LS-KEY                 PIC X(48).
 01 LS-BARE                PIC X(48).
 01 LS-EBOX.
    05 LS-E                FLOAT-LONG OCCURS 6 TIMES.
 01 LS-TYPE                BINARY-LONG.
 01 LS-AB                  FLOAT-LONG OCCURS 6 TIMES.
 01 LS-C                   FLOAT-LONG OCCURS 6 TIMES.
 01 LS-INT                 FLOAT-LONG OCCURS 6 TIMES.
 01 LS-A                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-HIT                 BINARY-LONG.
 01 LS-MA                  BINARY-LONG.
 01 LS-MS                  BINARY-LONG.
 01 LS-BACK                BINARY-LONG.
 01 LS-BA                  BINARY-LONG.
 01 LS-V                   FLOAT-LONG.
 01 LS-MV                  FLOAT-LONG.
 01 LS-MAXPUSH             FLOAT-LONG.
 01 LS-PUSH                FLOAT-LONG.
 01 LS-D1                  FLOAT-LONG.
 01 LS-D2                  FLOAT-LONG.
 01 LS-DIFF                FLOAT-LONG.
 01 LS-AREA-LO             FLOAT-LONG.
 01 LS-AREA-HI             FLOAT-LONG.
 01 LS-W1                  BINARY-LONG.
 01 LS-W0                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PUSHARG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING PP-ARG L-ROW.
     MOVE EN-TYPE(L-ROW) TO LS-TYPE
     MOVE ET-KEY(LS-TYPE + 1) TO LS-KEY
     CALL "KEY-BARE" USING LS-KEY LS-BARE
     IF LS-BARE = "area_effect_cloud" OR LS-BARE = "interaction" OR LS-BARE = "ominous_item_spawner" OR LS-BARE = "marker"
             OR LS-BARE = "block_display" OR LS-BARE = "item_display" OR LS-BARE = "text_display"
         GOBACK
     END-IF
     CALL "PST-PUSH-BOX" USING L-ROW LS-EBOX
     MOVE 1 TO LS-HIT
     PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
         IF LS-E(LS-A) >= PP-S(LS-A + 3) OR LS-E(LS-A + 3) <= PP-S(LS-A)
             MOVE 0 TO LS-HIT
         END-IF
     END-PERFORM
     IF LS-HIT = 0
         GOBACK
     END-IF
     MOVE WS-AX(PP-MDIR + 1) TO LS-MA
     COMPUTE LS-MS = 2 * FUNCTION MOD(PP-MDIR, 2) - 1
*>   the weights of the two senses of the movement axis: W1 is 1 when it goes towards the greater coordinate, W0 when towards the smaller
     COMPUTE LS-W1 = FUNCTION MOD(PP-MDIR, 2)
     COMPUTE LS-W0 = 1 - LS-W1
     IF PP-SLIME = 1
         MOVE LS-MS TO LS-V
         EVALUATE TRUE
             WHEN LS-MA = 2
                 MOVE LS-V TO EN-VY(L-ROW)
             WHEN LS-MA = 1 AND EN-TYPE(L-ROW) = CR-LOOSE-ITEM
                 MOVE LS-V TO EN-VX(L-ROW)
             WHEN LS-MA = 3 AND EN-TYPE(L-ROW) = CR-LOOSE-ITEM
                 MOVE LS-V TO EN-VZ(L-ROW)
         END-EVALUATE
     END-IF
     MOVE 0 TO LS-MAXPUSH
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > BSH-N(PP-SHAPE + 1) OR LS-MAXPUSH >= PP-DELTA
         PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
             COMPUTE LS-AB(LS-A) = PP-CELL(LS-A) + PP-OFF(LS-A) + BSH-V(PP-SHAPE + 1, LS-I, LS-A) / 16000
             COMPUTE LS-AB(LS-A + 3) = PP-CELL(LS-A) + PP-OFF(LS-A) + BSH-V(PP-SHAPE + 1, LS-I, LS-A + 3) / 16000
         END-PERFORM
*>       the movement area of the box (PistonMath.getMovementArea): the slab beyond the face the movement leaves, one progress step deep
         COMPUTE LS-AREA-LO = LS-W1 * LS-AB(LS-MA + 3) + LS-W0 * (LS-AB(LS-MA) - PP-DELTA)
         COMPUTE LS-AREA-HI = LS-W1 * (LS-AB(LS-MA + 3) + PP-DELTA) + LS-W0 * LS-AB(LS-MA)
         MOVE LS-AREA-LO TO LS-AB(LS-MA)
         MOVE LS-AREA-HI TO LS-AB(LS-MA + 3)
         MOVE 1 TO LS-HIT
         PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
             IF LS-AB(LS-A) >= LS-E(LS-A + 3) OR LS-AB(LS-A + 3) <= LS-E(LS-A)
                 MOVE 0 TO LS-HIT
             END-IF
         END-PERFORM
         IF LS-HIT = 1
             COMPUTE LS-MV = LS-W1 * (LS-AB(LS-MA + 3) - LS-E(LS-MA)) + LS-W0 * (LS-E(LS-MA + 3) - LS-AB(LS-MA))
             IF LS-MV > LS-MAXPUSH
                 MOVE LS-MV TO LS-MAXPUSH
             END-IF
         END-IF
     END-PERFORM
     IF LS-MAXPUSH > 0
         COMPUTE LS-PUSH = FUNCTION MIN(LS-MAXPUSH, PP-DELTA) + 0.01
         CALL "PST-PUSH-MOVE" USING L-ROW LS-PUSH PP-MDIR
         IF PP-EXT = 0 AND PP-SRC = 1
*>           fixEntityWithinPistonBase (8.4): the unit cell of the piston, the entity box after the push, and the box cut to the cell
             CALL "PST-PUSH-BOX" USING L-ROW LS-EBOX
             PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
                 MOVE PP-CELL(LS-A) TO LS-C(LS-A)
                 COMPUTE LS-C(LS-A + 3) = PP-CELL(LS-A) + 1
                 COMPUTE LS-INT(LS-A) = FUNCTION MAX(LS-E(LS-A), LS-C(LS-A))
                 COMPUTE LS-INT(LS-A + 3) = FUNCTION MIN(LS-E(LS-A + 3), LS-C(LS-A + 3))
             END-PERFORM
             MOVE 1 TO LS-HIT
             PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
                 IF LS-C(LS-A) >= LS-E(LS-A + 3) OR LS-C(LS-A + 3) <= LS-E(LS-A)
                     MOVE 0 TO LS-HIT
                 END-IF
             END-PERFORM
             IF LS-HIT = 1
                 COMPUTE LS-BACK = PP-MDIR + 1 - 2 * FUNCTION MOD(PP-MDIR, 2)
                 MOVE WS-AX(LS-BACK + 1) TO LS-BA
                 COMPUTE LS-W1 = FUNCTION MOD(LS-BACK, 2)
                 COMPUTE LS-W0 = 1 - LS-W1
                 COMPUTE LS-D1 = LS-W1 * (LS-C(LS-BA + 3) - LS-E(LS-BA)) + LS-W0 * (LS-E(LS-BA + 3) - LS-C(LS-BA)) + 0.01
                 COMPUTE LS-D2 = LS-W1 * (LS-C(LS-BA + 3) - LS-INT(LS-BA)) + LS-W0 * (LS-INT(LS-BA + 3) - LS-C(LS-BA)) + 0.01
                 COMPUTE LS-DIFF = FUNCTION ABS(LS-D1 - LS-D2)
                 IF LS-DIFF < 0.01
                     COMPUTE LS-PUSH = FUNCTION MIN(LS-D1, PP-DELTA) + 0.01
                     CALL "PST-PUSH-MOVE" USING L-ROW LS-PUSH LS-BACK
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PST-PUSH-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUSH-ENTITIES RECURSIVE.
*> USING block entity index: moveCollidedEntities (8.1) for the moving block entity, before its progress rises by 0.5. The collision related state is the moved state, or, for a retracting source piston, a piston head (short
*> once the progress is above 0.25, sticky by the base, facing as the base). The shape's bounds, shifted by the offset of the current progress (the step of the piston's facing times extendedProgress) and united with the
*> movement area, are the box the entities must meet; PST-PUSH-ONE does each entity of the level but players (spectators included, which the level does not offer to the piston).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY CTBSHAPE.
 COPY PSTATE.
 01 WS-AX-STR              PIC X(6) VALUE "223311".
 01 WS-AX-TAB REDEFINES WS-AX-STR.
    05 WS-AX               PIC 9 OCCURS 6 TIMES.
 LOCAL-STORAGE SECTION.
 COPY PUSHARG.
 01 LS-MOVED               BINARY-LONG.
 01 LS-FACE                BINARY-LONG.
 01 LS-CSTATE              BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-HEAD                BINARY-LONG VALUE 3.
 01 LS-SHORT               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 01 LS-P                   FLOAT-LONG.
 01 LS-EP                  FLOAT-LONG.
 01 LS-FSIGN               BINARY-LONG.
 01 LS-FAXIS               BINARY-LONG.
 01 LS-MA                  BINARY-LONG.
 01 LS-W1                  BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-LO                  FLOAT-LONG.
 01 LS-HI                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     CALL "PST-IDS-ENSURE"
     MOVE BE-DIM(L-INDEX) TO PP-DIM
     MOVE BE-X(L-INDEX) TO PP-CELL(1)
     MOVE BE-Y(L-INDEX) TO PP-CELL(2)
     MOVE BE-Z(L-INDEX) TO PP-CELL(3)
     MOVE BE-XI(L-INDEX, 1) TO LS-MOVED
     MOVE BE-XI(L-INDEX, 2) TO LS-FACE
     MOVE BE-XI(L-INDEX, 3) TO PP-EXT
     MOVE BE-XI(L-INDEX, 4) TO PP-SRC
     MOVE BE-PROGRESS(L-INDEX) TO LS-P
     MOVE 0.5 TO PP-DELTA
     IF PP-EXT = 1
         MOVE LS-FACE TO PP-MDIR
     ELSE
         COMPUTE PP-MDIR = LS-FACE + 1 - 2 * FUNCTION MOD(LS-FACE, 2)
     END-IF
     MOVE 0 TO PP-SLIME
     IF CB-S-BLOCK(LS-MOVED + 1) = PS-SLIME
         MOVE 1 TO PP-SLIME
     END-IF
     MOVE LS-MOVED TO LS-CSTATE
     CALL "PST-CLASS" USING LS-MOVED LS-CLASS
     IF PP-EXT = 0 AND PP-SRC = 1 AND (LS-CLASS = 31 OR LS-CLASS = 32)
         MOVE 0 TO LS-SHORT
         IF LS-P > 0.25
             MOVE 1 TO LS-SHORT
         END-IF
         MOVE 0 TO LS-TYPE
         IF LS-CLASS = 32
             MOVE 1 TO LS-TYPE
         END-IF
         CALL "PST-STATE-OF" USING LS-HEAD LS-FACE LS-SHORT LS-TYPE LS-CSTATE
     END-IF
     CALL "BSH-COLL-ID" USING LS-CSTATE PP-SHAPE
*>   an empty collision shape is the interned shape with no boxes (an id of its own, not 0): there is nothing to push with
     IF PP-SHAPE = 0 OR BSH-N(PP-SHAPE + 1) = 0
         GOBACK
     END-IF
     IF PP-EXT = 1
         COMPUTE LS-EP = LS-P - 1
     ELSE
         COMPUTE LS-EP = 1 - LS-P
     END-IF
     MOVE 0 TO PP-OFF(1) PP-OFF(2) PP-OFF(3)
     MOVE WS-AX(LS-FACE + 1) TO LS-FAXIS
     COMPUTE LS-FSIGN = 2 * FUNCTION MOD(LS-FACE, 2) - 1
     COMPUTE PP-OFF(LS-FAXIS) = LS-FSIGN * LS-EP
*>   the bounds of the shape, moved by the offset
     PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
         MOVE 1000000 TO PP-S(LS-A)
         MOVE -1000000 TO PP-S(LS-A + 3)
     END-PERFORM
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > BSH-N(PP-SHAPE + 1)
         PERFORM VARYING LS-A FROM 1 BY 1 UNTIL LS-A > 3
             COMPUTE LS-LO = PP-CELL(LS-A) + PP-OFF(LS-A) + BSH-V(PP-SHAPE + 1, LS-I, LS-A) / 16000
             COMPUTE LS-HI = PP-CELL(LS-A) + PP-OFF(LS-A) + BSH-V(PP-SHAPE + 1, LS-I, LS-A + 3) / 16000
             IF LS-LO < PP-S(LS-A)
                 MOVE LS-LO TO PP-S(LS-A)
             END-IF
             IF LS-HI > PP-S(LS-A + 3)
                 MOVE LS-HI TO PP-S(LS-A + 3)
             END-IF
         END-PERFORM
     END-PERFORM
*>   united with the movement area: the bounds grown by one progress step on the side the movement goes to
     MOVE WS-AX(PP-MDIR + 1) TO LS-MA
     COMPUTE LS-W1 = FUNCTION MOD(PP-MDIR, 2)
     COMPUTE PP-S(LS-MA + 3) = PP-S(LS-MA + 3) + LS-W1 * PP-DELTA
     COMPUTE PP-S(LS-MA) = PP-S(LS-MA) - (1 - LS-W1) * PP-DELTA
     PERFORM VARYING LS-ROW FROM 1 BY 1 UNTIL LS-ROW > EN-COUNT
         IF EN-USED(LS-ROW) = 1 AND EN-DIM(LS-ROW) = PP-DIM AND EN-PLAYER(LS-ROW) = 0
             CALL "PST-PUSH-ONE" USING PP-ARG LS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PST-PUSH-ENTITIES.
