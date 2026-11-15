*> Pathfinding (docs/protocol/18-mob-framework.md section 5), world agnostic: path types and the malus table (5.1), nodes, costs and the
*> weighted A* (5.2), the node evaluators (5.3), the navigation classes (5.4) and following a path (5.5). The world is the PF-WORLD
*> snapshot of MOBPATH.cpy; every program is pure.

*> ---- 5.1 Path types and the malus table ----------------------------------------------------------------------------------

*> PATH-MALUS-DEFAULT USING path type id (BINARY-LONG 0..26), default malus out (BINARY-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-MALUS-DEFAULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 16.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-TABLE REDEFINES WS-VALUES.
    05 WS-DEFAULT          BINARY-LONG OCCURS 27 TIMES.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 LK-TYPE                BINARY-LONG.
 01 LK-MALUS               BINARY-LONG.
 PROCEDURE DIVISION USING LK-TYPE LK-MALUS.
     COMPUTE WS-SLOT = LK-TYPE + 1
     MOVE WS-DEFAULT(WS-SLOT) TO LK-MALUS
     GOBACK.
 END PROGRAM PATH-MALUS-DEFAULT.

*> PATH-MALUS-SET USING PF-MALUS-TABLE, path type, malus: Mob.setPathfindingMalus.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-MALUS-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-TYPE                BINARY-LONG.
 01 LK-MALUS               BINARY-LONG.
 PROCEDURE DIVISION USING PF-MALUS-TABLE LK-TYPE LK-MALUS.
     COMPUTE WS-SLOT = LK-TYPE + 1
     MOVE 1 TO PF-MALUS-SET(WS-SLOT)
     MOVE LK-MALUS TO PF-MALUS-VAL(WS-SLOT)
     GOBACK.
 END PROGRAM PATH-MALUS-SET.

*> MOB-MALUS USING PF-MALUS-TABLE, path type, malus out: the mob's override or the type default (getPathfindingMalus).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MALUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-TYPE                BINARY-LONG.
 01 LK-MALUS               BINARY-LONG.
 PROCEDURE DIVISION USING PF-MALUS-TABLE LK-TYPE LK-MALUS.
     COMPUTE WS-SLOT = LK-TYPE + 1
     IF PF-MALUS-SET(WS-SLOT) = 1
         MOVE PF-MALUS-VAL(WS-SLOT) TO LK-MALUS
     ELSE
         CALL "PATH-MALUS-DEFAULT" USING LK-TYPE LK-MALUS
     END-IF
     GOBACK.
 END PROGRAM MOB-MALUS.

*> BLOCK-PATH-TYPE USING block kind (PIC X(16): air, trapdoor, lily_pad, big_dripleaf, powder_snow, cactus, sweet_berry_bush, honey,
*> cocoa, wither_rose, speleothem, lava, fire, door_open, door_wood_closed, door_iron_closed, rail, leaves, fence, wall,
*> fence_gate, water, solid, other), path type out: WalkNodeEvaluator.getPathTypeFromState.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-PATH-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KINDS.
    05 FILLER PIC X(18) VALUE "air             01".
    05 FILLER PIC X(18) VALUE "trapdoor        04".
    05 FILLER PIC X(18) VALUE "lily_pad        04".
    05 FILLER PIC X(18) VALUE "big_dripleaf    04".
    05 FILLER PIC X(18) VALUE "powder_snow     05".
    05 FILLER PIC X(18) VALUE "cactus          16".
    05 FILLER PIC X(18) VALUE "sweet_berry_bush16".
    05 FILLER PIC X(18) VALUE "honey           22".
    05 FILLER PIC X(18) VALUE "cocoa           23".
    05 FILLER PIC X(18) VALUE "wither_rose     24".
    05 FILLER PIC X(18) VALUE "speleothem      24".
    05 FILLER PIC X(18) VALUE "lava            08".
    05 FILLER PIC X(18) VALUE "fire            14".
    05 FILLER PIC X(18) VALUE "door_open       17".
    05 FILLER PIC X(18) VALUE "door_wood_closed18".
    05 FILLER PIC X(18) VALUE "door_iron_closed19".
    05 FILLER PIC X(18) VALUE "rail            11".
    05 FILLER PIC X(18) VALUE "leaves          21".
    05 FILLER PIC X(18) VALUE "fence           07".
    05 FILLER PIC X(18) VALUE "wall            07".
    05 FILLER PIC X(18) VALUE "fence_gate      07".
    05 FILLER PIC X(18) VALUE "water           09".
    05 FILLER PIC X(18) VALUE "solid           00".
 01 WS-TABLE REDEFINES WS-KINDS.
    05 WS-ENTRY OCCURS 23 TIMES.
       10 WS-ENTRY-KIND    PIC X(16).
       10 WS-ENTRY-TYPE    PIC 99.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 LINKAGE SECTION.
 01 LK-KIND                PIC X(16).
 01 LK-TYPE                BINARY-LONG.
 PROCEDURE DIVISION USING LK-KIND LK-TYPE.
     MOVE 1 TO LK-TYPE
     MOVE LK-KIND TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         IF WS-ENTRY-KIND(WS-I) = WS-KEY
             MOVE WS-ENTRY-TYPE(WS-I) TO LK-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-PATH-TYPE.

*> STATIC-PATH-TYPE USING type at the feet, type of the block below, result out (getPathTypeStatic): below an OPEN position decides.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATIC-PATH-TYPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-AT                  BINARY-LONG.
 01 LK-BELOW               BINARY-LONG.
 01 LK-TYPE                BINARY-LONG.
 PROCEDURE DIVISION USING LK-AT LK-BELOW LK-TYPE.
     MOVE LK-AT TO LK-TYPE
     IF LK-AT = 1
         EVALUATE LK-BELOW
             WHEN 9
                 MOVE 9 TO LK-TYPE
             WHEN 8
                 MOVE 8 TO LK-TYPE
             WHEN 14
                 MOVE 14 TO LK-TYPE
             WHEN 16
                 MOVE 16 TO LK-TYPE
             WHEN 22
                 MOVE 22 TO LK-TYPE
             WHEN 5
                 MOVE 6 TO LK-TYPE
             WHEN 24
                 MOVE 24 TO LK-TYPE
             WHEN 4
                 MOVE 25 TO LK-TYPE
             WHEN 1
                 MOVE 1 TO LK-TYPE
             WHEN OTHER
                 MOVE 2 TO LK-TYPE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM STATIC-PATH-TYPE.

*> NEIGHBOUR-ADJUST USING type, damaging, fire or lava, water, damage cautious neighbour present (1/0), result out: for a WALKABLE
*> position the neighbour check of getPathTypeStatic (precedence in that order).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NEIGHBOUR-ADJUST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TYPE                BINARY-LONG.
 01 LK-DAMAGING            BINARY-LONG.
 01 LK-FIRE                BINARY-LONG.
 01 LK-WATER               BINARY-LONG.
 01 LK-CAUTIOUS            BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TYPE LK-DAMAGING LK-FIRE LK-WATER LK-CAUTIOUS LK-RESULT.
     MOVE LK-TYPE TO LK-RESULT
     IF LK-TYPE = 2
         EVALUATE TRUE
             WHEN LK-DAMAGING = 1
                 MOVE 15 TO LK-RESULT
             WHEN LK-FIRE = 1
                 MOVE 13 TO LK-RESULT
             WHEN LK-WATER = 1
                 MOVE 10 TO LK-RESULT
             WHEN LK-CAUTIOUS = 1
                 MOVE 24 TO LK-RESULT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM NEIGHBOUR-ADJUST.

*> MOB-PATH-TYPE USING PF-MALUS-TABLE, PF-TYPESET (the distinct types of the footprint in ascending id order), origin type,
*> entity width (FLOAT-LONG), result out (getPathTypeOfMob).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PATH-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-ORIGIN-MALUS        BINARY-LONG.
 01 WS-BIG-MALUS           BINARY-LONG.
 01 WS-BIG                 BINARY-LONG VALUE 26.
 01 WS-DONE                BINARY-LONG.
 01 WS-FENCE               BINARY-LONG.
 01 WS-RAIL                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-ORIGIN              BINARY-LONG.
 01 LK-WIDTH               FLOAT-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING PF-MALUS-TABLE PF-TYPESET LK-ORIGIN LK-WIDTH LK-RESULT.
     MOVE 0 TO WS-DONE
     MOVE 0 TO WS-FENCE
     MOVE 0 TO WS-RAIL
     MOVE PT-TYPE(1) TO LK-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-COUNT
         IF PT-TYPE(WS-I) = 7
             MOVE 1 TO WS-FENCE
         END-IF
         IF PT-TYPE(WS-I) = 12
             MOVE 1 TO WS-RAIL
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN PT-COUNT = 1
             MOVE 1 TO WS-DONE
         WHEN WS-FENCE = 1
             MOVE 7 TO LK-RESULT
             MOVE 1 TO WS-DONE
         WHEN WS-RAIL = 1
             MOVE 12 TO LK-RESULT
             MOVE 1 TO WS-DONE
     END-EVALUATE
     MOVE -1 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PT-COUNT OR WS-DONE = 1
         MOVE PT-TYPE(WS-I) TO WS-T
         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-T WS-M
         IF WS-M < 0
             MOVE WS-T TO LK-RESULT
             MOVE 1 TO WS-DONE
         ELSE
             IF WS-M NOT < WS-MAX
                 MOVE WS-M TO WS-MAX
                 MOVE WS-T TO LK-RESULT
             END-IF
         END-IF
     END-PERFORM
     IF WS-DONE = 0
         CALL "MOB-MALUS" USING PF-MALUS-TABLE LK-ORIGIN WS-ORIGIN-MALUS
         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-BIG WS-BIG-MALUS
         IF LK-WIDTH > 1.0
             IF WS-ORIGIN-MALUS < WS-MAX AND WS-BIG-MALUS < WS-MAX
                 MOVE 26 TO LK-RESULT
             END-IF
         ELSE
             IF LK-ORIGIN = 1 AND LK-RESULT NOT = 1 AND WS-MAX = 0
                 MOVE 1 TO LK-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-PATH-TYPE.

*> ---- 5.2 Nodes, costs and A* ---------------------------------------------------------------------------------------------

*> NODE-DISTANCE USING x1 y1 z1 x2 y2 z2 (BINARY-LONG), Euclidean distance out (FLOAT-LONG), Manhattan distance out (BINARY-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NODE-DISTANCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 LK-X1                  BINARY-LONG.
 01 LK-Y1                  BINARY-LONG.
 01 LK-Z1                  BINARY-LONG.
 01 LK-X2                  BINARY-LONG.
 01 LK-Y2                  BINARY-LONG.
 01 LK-Z2                  BINARY-LONG.
 01 LK-EUCLID              FLOAT-LONG.
 01 LK-MANHATTAN           BINARY-LONG.
 PROCEDURE DIVISION USING LK-X1 LK-Y1 LK-Z1 LK-X2 LK-Y2 LK-Z2 LK-EUCLID LK-MANHATTAN.
     COMPUTE WS-DX = LK-X2 - LK-X1
     COMPUTE WS-DY = LK-Y2 - LK-Y1
     COMPUTE WS-DZ = LK-Z2 - LK-Z1
     COMPUTE LK-EUCLID = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE LK-MANHATTAN = FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DY) + FUNCTION ABS(WS-DZ)
     GOBACK.
 END PROGRAM NODE-DISTANCE.

*> PATH-BUDGET USING follow range, maxVisitedNodesMultiplier (FLOAT-LONG), budget out (BINARY-LONG): the node budget
*> floor(floor(follow_range x 16) x multiplier).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-BUDGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODES               BINARY-LONG.
 LINKAGE SECTION.
 01 LK-RANGE               FLOAT-LONG.
 01 LK-MULTIPLIER          FLOAT-LONG.
 01 LK-BUDGET              BINARY-LONG.
 PROCEDURE DIVISION USING LK-RANGE LK-MULTIPLIER LK-BUDGET.
     COMPUTE WS-NODES = FUNCTION INTEGER(LK-RANGE * 16)
     COMPUTE LK-BUDGET = FUNCTION INTEGER(WS-NODES * LK-MULTIPLIER)
     GOBACK.
 END PROGRAM PATH-BUDGET.

*> CELL-GET USING PF-WORLD, x, y, z, cell out: the PathType id stored for a position, BLOCKED (0) outside the snapshot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CELL-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-CELL                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD LK-X LK-Y LK-Z LK-CELL.
     MOVE 0 TO LK-CELL
     IF LK-X NOT < 0 AND LK-X < PW-DX AND LK-Y NOT < 0 AND LK-Y < PW-DY AND LK-Z NOT < 0 AND LK-Z < PW-DZ
         COMPUTE WS-K = (LK-Y * PW-DZ + LK-Z) * PW-DX + LK-X + 1
         MOVE PW-CELL(WS-K) TO LK-CELL
     END-IF
     GOBACK.
 END PROGRAM CELL-GET.

*> NODE-GET USING PF-WORLD, PF-NODES, x, y, z, node index out (0 outside the snapshot or when the table is full): the node of a
*> position, created on first use.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NODE-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-NODES LK-X LK-Y LK-Z LK-IDX.
     MOVE 0 TO LK-IDX
     IF LK-X NOT < 0 AND LK-X < PW-DX AND LK-Y NOT < 0 AND LK-Y < PW-DY AND LK-Z NOT < 0 AND LK-Z < PW-DZ
         COMPUTE WS-K = (LK-Y * PW-DZ + LK-Z) * PW-DX + LK-X + 1
         IF PN-INDEX(WS-K) > 0
             MOVE PN-INDEX(WS-K) TO LK-IDX
         ELSE
             IF PN-COUNT < 600
                 ADD 1 TO PN-COUNT
                 MOVE PN-COUNT TO LK-IDX
                 MOVE PN-COUNT TO PN-INDEX(WS-K)
                 MOVE LK-X TO PN-X(LK-IDX)
                 MOVE LK-Y TO PN-Y(LK-IDX)
                 MOVE LK-Z TO PN-Z(LK-IDX)
                 MOVE 0 TO PN-G(LK-IDX)
                 MOVE 0 TO PN-H(LK-IDX)
                 MOVE 0 TO PN-WALKED(LK-IDX)
                 MOVE 0 TO PN-COST(LK-IDX)
                 MOVE 0 TO PN-STATE(LK-IDX)
                 MOVE 0 TO PN-FROM(LK-IDX)
                 MOVE 0 TO PN-TYPE(LK-IDX)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NODE-GET.

*> ---- 5.3 Node evaluators -------------------------------------------------------------------------------------------------

*> STATIC-CELL-TYPE USING PF-WORLD, x, y, z, type out: getPathTypeStatic of one position including the neighbour check.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATIC-CELL-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AT                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DAMAGING            BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-CAUTIOUS            BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-TYPE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD LK-X LK-Y LK-Z LK-TYPE.
     CALL "CELL-GET" USING PF-WORLD LK-X LK-Y LK-Z WS-AT
     IF LK-Y > 0
         COMPUTE WS-BY = LK-Y - 1
     ELSE
         MOVE 0 TO WS-BY
     END-IF
     CALL "CELL-GET" USING PF-WORLD LK-X WS-BY LK-Z WS-BELOW
     CALL "STATIC-PATH-TYPE" USING WS-AT WS-BELOW WS-TYPE
     MOVE 0 TO WS-DAMAGING
     MOVE 0 TO WS-FIRE
     MOVE 0 TO WS-WATER
     MOVE 0 TO WS-CAUTIOUS
     IF WS-TYPE = 2
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                 PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                     COMPUTE WS-NX = LK-X + WS-DX
                     COMPUTE WS-NY = LK-Y + WS-DY
                     COMPUTE WS-NZ = LK-Z + WS-DZ
                     CALL "CELL-GET" USING PF-WORLD WS-NX WS-NY WS-NZ WS-N
                     EVALUATE WS-N
                         WHEN 16
                             MOVE 1 TO WS-DAMAGING
                         WHEN 14
                             MOVE 1 TO WS-FIRE
                         WHEN 8
                             MOVE 1 TO WS-FIRE
                         WHEN 9
                             MOVE 1 TO WS-WATER
                         WHEN 24
                             MOVE 1 TO WS-CAUTIOUS
                     END-EVALUATE
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     CALL "NEIGHBOUR-ADJUST" USING WS-TYPE WS-DAMAGING WS-FIRE WS-WATER WS-CAUTIOUS LK-TYPE
     GOBACK.
 END PROGRAM STATIC-CELL-TYPE.

*> PF-TYPE-AT USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, x, y, z, type out: the mob aware path type of the footprint at a node
*> (walk and amphibious classification: with the kind 4 water next to a blocked block is WATER_BORDER).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PF-TYPE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRESENT             BINARY-LONG OCCURS 27 TIMES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BORDER              BINARY-LONG.
 01 WS-TYPESET.
    05 WS-PT-COUNT          BINARY-LONG.
    05 WS-PT-TYPE           BINARY-LONG OCCURS 27 TIMES.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-TYPE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH LK-X LK-Y LK-Z LK-TYPE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE 0 TO WS-PRESENT(WS-I)
     END-PERFORM
     CALL "STATIC-CELL-TYPE" USING PF-WORLD LK-X LK-Y LK-Z WS-ORIGIN
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX >= PS-WIDTH
         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY >= PS-HEIGHT
             PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ >= PS-WIDTH
                 COMPUTE WS-CX = LK-X + WS-DX
                 COMPUTE WS-CY = LK-Y + WS-DY
                 COMPUTE WS-CZ = LK-Z + WS-DZ
                 CALL "STATIC-CELL-TYPE" USING PF-WORLD WS-CX WS-CY WS-CZ WS-T
                 IF PS-KIND = 4 AND WS-T = 9
                     MOVE 0 TO WS-BORDER
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                         MOVE WS-CX TO WS-NX
                         MOVE WS-CY TO WS-NY
                         MOVE WS-CZ TO WS-NZ
                         EVALUATE WS-I
                             WHEN 1 SUBTRACT 1 FROM WS-NX
                             WHEN 2 ADD 1 TO WS-NX
                             WHEN 3 SUBTRACT 1 FROM WS-NY
                             WHEN 4 ADD 1 TO WS-NY
                             WHEN 5 SUBTRACT 1 FROM WS-NZ
                             WHEN OTHER ADD 1 TO WS-NZ
                         END-EVALUATE
                         CALL "CELL-GET" USING PF-WORLD WS-NX WS-NY WS-NZ WS-N
                         IF WS-N = 0
                             MOVE 1 TO WS-BORDER
                         END-IF
                     END-PERFORM
                     IF WS-BORDER = 1
                         MOVE 10 TO WS-T
                     END-IF
                 END-IF
                 COMPUTE WS-SLOT = WS-T + 1
                 MOVE 1 TO WS-PRESENT(WS-SLOT)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-PT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF WS-PRESENT(WS-I) = 1
             ADD 1 TO WS-PT-COUNT
             COMPUTE WS-PT-TYPE(WS-PT-COUNT) = WS-I - 1
         END-IF
     END-PERFORM
     MOVE PS-WIDTH TO WS-WIDTH
     CALL "MOB-PATH-TYPE" USING PF-MALUS-TABLE WS-TYPESET WS-ORIGIN WS-WIDTH LK-TYPE
     GOBACK.
 END PROGRAM PF-TYPE-AT.

*> NODE-ACCEPT USING PF-WORLD, PF-NODES, x, y, z, path type, malus, extra cost (BINARY-LONG), node index out: the node of a position
*> with costMalus = max(existing, malus + extra) and its path type; 0 when the node is closed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NODE-ACCEPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COST                FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-TYPE                BINARY-LONG.
 01 LK-MALUS               BINARY-LONG.
 01 LK-EXTRA               BINARY-LONG.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-NODES LK-X LK-Y LK-Z LK-TYPE LK-MALUS LK-EXTRA LK-IDX.
     CALL "NODE-GET" USING PF-WORLD PF-NODES LK-X LK-Y LK-Z LK-IDX
     IF LK-IDX > 0
         IF PN-STATE(LK-IDX) = 2
             MOVE 0 TO LK-IDX
         ELSE
             COMPUTE WS-COST = LK-MALUS + LK-EXTRA
             IF WS-COST > PN-COST(LK-IDX)
                 MOVE WS-COST TO PN-COST(LK-IDX)
             END-IF
             MOVE LK-TYPE TO PN-TYPE(LK-IDX)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NODE-ACCEPT.

*> WALK-ACCEPT USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, origin x y z, column x y z (BINARY-LONG), node index out:
*> WalkNodeEvaluator.findAcceptedNode on the integer block grid: a walkable column is accepted, a gap is dropped through up to
*> the maximum fall distance, a blocked column is climbed when the head room above the origin allows it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WALK-ACCEPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-OX                  BINARY-LONG.
 01 LK-OY                  BINARY-LONG.
 01 LK-OZ                  BINARY-LONG.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-OX LK-OY LK-OZ LK-X LK-Y LK-Z LK-IDX.
     MOVE 0 TO LK-IDX
     CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH LK-X LK-Y LK-Z WS-TYPE
     CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
     EVALUATE TRUE
         WHEN WS-TYPE = 1
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > PS-MAX-FALL OR WS-DONE = 1
                 COMPUTE WS-YY = LK-Y - WS-D
                 IF WS-YY < 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH LK-X WS-YY LK-Z WS-TYPE
                     IF WS-TYPE NOT = 1
                         MOVE 1 TO WS-DONE
                         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
                         IF WS-MALUS NOT < 0
                             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES LK-X WS-YY LK-Z WS-TYPE WS-MALUS WS-ZERO LK-IDX
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         WHEN WS-MALUS NOT < 0
             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES LK-X LK-Y LK-Z WS-TYPE WS-MALUS WS-ZERO LK-IDX
         WHEN WS-TYPE = 0 AND PS-STEP > 0
             COMPUTE WS-UP = LK-Y + 1
             COMPUTE WS-HEAD = LK-OY + PS-HEIGHT
             CALL "CELL-GET" USING PF-WORLD LK-OX WS-HEAD LK-OZ WS-CELL
             IF WS-CELL = 1
                 CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH LK-X WS-UP LK-Z WS-TYPE
                 CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
                 IF WS-TYPE = 2 AND WS-MALUS NOT < 0
                     CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES LK-X WS-UP LK-Z WS-TYPE WS-MALUS WS-ZERO LK-IDX
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM WALK-ACCEPT.

*> WALK-NEIGHBORS USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, node index, PF-NEIGH: the four cardinal and four diagonal
*> neighbours of the walk evaluator, plus for the amphibious kind (4) the water nodes above and below and the shallow swimming
*> cost.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WALK-NEIGHBORS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRS.
    05 FILLER              PIC X(4) VALUE "0 1 ".
    05 FILLER              PIC X(4) VALUE "-10 ".
    05 FILLER              PIC X(4) VALUE "0-1 ".
    05 FILLER              PIC X(4) VALUE "1 0 ".
 01 WS-DX                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZ                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-CARD                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CY1                 BINARY-LONG.
 01 WS-CY2                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-COLY                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH.
     MOVE 0 TO PNB-COUNT
     MOVE 0 TO WS-DX(1)
     MOVE 1 TO WS-DZ(1)
     MOVE -1 TO WS-DX(2)
     MOVE 0 TO WS-DZ(2)
     MOVE 0 TO WS-DX(3)
     MOVE -1 TO WS-DZ(3)
     MOVE 1 TO WS-DX(4)
     MOVE 0 TO WS-DZ(4)
     MOVE PN-X(LK-NODE) TO WS-OX
     MOVE PN-Y(LK-NODE) TO WS-OY
     MOVE PN-Z(LK-NODE) TO WS-OZ
     MOVE WS-OY TO WS-COLY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-X = WS-OX + WS-DX(WS-I)
         COMPUTE WS-Z = WS-OZ + WS-DZ(WS-I)
         CALL "WALK-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-OX WS-OY WS-OZ WS-X WS-COLY WS-Z WS-IDX
         MOVE WS-IDX TO WS-CARD(WS-I)
         IF WS-IDX > 0
             ADD 1 TO PNB-COUNT
             MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-I = 4
             MOVE 1 TO WS-J
         ELSE
             COMPUTE WS-J = WS-I + 1
         END-IF
         IF WS-CARD(WS-I) > 0 AND WS-CARD(WS-J) > 0
             MOVE WS-CARD(WS-I) TO WS-CY1
             MOVE WS-CARD(WS-J) TO WS-CY2
             IF PN-Y(WS-CY1) NOT > WS-OY AND PN-Y(WS-CY2) NOT > WS-OY
                 COMPUTE WS-X = WS-OX + WS-DX(WS-I) + WS-DX(WS-J)
                 COMPUTE WS-Z = WS-OZ + WS-DZ(WS-I) + WS-DZ(WS-J)
                 CALL "WALK-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-OX WS-OY WS-OZ WS-X WS-COLY WS-Z WS-IDX
                 IF WS-IDX > 0
                     IF PN-TYPE(WS-IDX) NOT = 3
                         ADD 1 TO PNB-COUNT
                         MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF PS-KIND = 4
         COMPUTE WS-Y = WS-OY + 1
         CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH WS-OX WS-Y WS-OZ WS-TYPE
         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
         IF WS-TYPE = 9 AND WS-MALUS NOT < 0
             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES WS-OX WS-Y WS-OZ WS-TYPE WS-MALUS WS-ZERO WS-IDX
             IF WS-IDX > 0
                 ADD 1 TO PNB-COUNT
                 MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
             END-IF
         END-IF
         COMPUTE WS-Y = WS-OY - 1
         CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH WS-OX WS-Y WS-OZ WS-TYPE
         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
         IF WS-TYPE = 9 AND WS-MALUS NOT < 0
             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES WS-OX WS-Y WS-OZ WS-TYPE WS-MALUS WS-ZERO WS-IDX
             IF WS-IDX > 0
                 ADD 1 TO PNB-COUNT
                 MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
             END-IF
         END-IF
         IF PS-SHALLOW = 1
             COMPUTE WS-LIMIT = PS-SEA-LEVEL - 10
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PNB-COUNT
                 MOVE PNB-NODE(WS-I) TO WS-IDX
                 IF PN-TYPE(WS-IDX) = 9 AND PN-Y(WS-IDX) < WS-LIMIT
                     ADD 1 TO PN-COST(WS-IDX)
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WALK-NEIGHBORS.

*> SWIM-ACCEPT USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, x, y, z, node index out: SwimNodeEvaluator.findAcceptedNode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SWIM-ACCEPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-X LK-Y LK-Z LK-IDX.
     MOVE 0 TO LK-IDX
     MOVE 0 TO WS-DONE
     MOVE 0 TO WS-LAST
     MOVE 0 TO WS-TYPE
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX >= PS-WIDTH OR WS-DONE = 1
         PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY >= PS-HEIGHT OR WS-DONE = 1
             PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ >= PS-WIDTH OR WS-DONE = 1
                 COMPUTE WS-CX = LK-X + WS-DX
                 COMPUTE WS-CY = LK-Y + WS-DY
                 COMPUTE WS-CZ = LK-Z + WS-DZ
                 COMPUTE WS-BY = WS-CY - 1
                 CALL "CELL-GET" USING PF-WORLD WS-CX WS-CY WS-CZ WS-CELL
                 CALL "CELL-GET" USING PF-WORLD WS-CX WS-BY WS-CZ WS-BELOW
                 EVALUATE TRUE
                     WHEN WS-CELL = 1 AND WS-BELOW = 9
                         MOVE 20 TO WS-TYPE
                         MOVE 1 TO WS-DONE
                     WHEN WS-CELL = 8
                         MOVE 0 TO WS-TYPE
                         MOVE 1 TO WS-DONE
                     WHEN WS-CELL = 9
                         MOVE 1 TO WS-LAST
                     WHEN OTHER
                         MOVE 0 TO WS-LAST
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-DONE = 0 AND WS-LAST = 1
         MOVE 9 TO WS-TYPE
     END-IF
     IF WS-TYPE = 9 OR (WS-TYPE = 20 AND PS-BREACH = 1)
         CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
         IF WS-MALUS NOT < 0
             CALL "CELL-GET" USING PF-WORLD LK-X LK-Y LK-Z WS-FIRST
             MOVE 0 TO WS-EXTRA
             IF WS-FIRST NOT = 9
                 MOVE 8 TO WS-EXTRA
             END-IF
             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES LK-X LK-Y LK-Z WS-TYPE WS-MALUS WS-EXTRA LK-IDX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SWIM-ACCEPT.

*> SWIM-NEIGHBORS USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, node index, PF-NEIGH: the six face neighbours and the
*> horizontal diagonals of the swim evaluator.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SWIM-NEIGHBORS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FX                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-FY                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-FZ                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-HX                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-HZ                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-HV                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH.
     MOVE 0 TO PNB-COUNT
     MOVE 0 TO WS-FX(1)
     MOVE -1 TO WS-FY(1)
     MOVE 0 TO WS-FZ(1)
     MOVE 0 TO WS-FX(2)
     MOVE 1 TO WS-FY(2)
     MOVE 0 TO WS-FZ(2)
     MOVE 0 TO WS-FX(3)
     MOVE 0 TO WS-FY(3)
     MOVE -1 TO WS-FZ(3)
     MOVE 0 TO WS-FX(4)
     MOVE 0 TO WS-FY(4)
     MOVE 1 TO WS-FZ(4)
     MOVE -1 TO WS-FX(5)
     MOVE 0 TO WS-FY(5)
     MOVE 0 TO WS-FZ(5)
     MOVE 1 TO WS-FX(6)
     MOVE 0 TO WS-FY(6)
     MOVE 0 TO WS-FZ(6)
     MOVE 1 TO WS-HX(1)
     MOVE 0 TO WS-HZ(1)
     MOVE 0 TO WS-HX(2)
     MOVE 1 TO WS-HZ(2)
     MOVE -1 TO WS-HX(3)
     MOVE 0 TO WS-HZ(3)
     MOVE 0 TO WS-HX(4)
     MOVE -1 TO WS-HZ(4)
     MOVE PN-X(LK-NODE) TO WS-OX
     MOVE PN-Y(LK-NODE) TO WS-OY
     MOVE PN-Z(LK-NODE) TO WS-OZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-HV(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-X = WS-OX + WS-FX(WS-I)
         COMPUTE WS-Y = WS-OY + WS-FY(WS-I)
         COMPUTE WS-Z = WS-OZ + WS-FZ(WS-I)
         CALL "SWIM-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-X WS-Y WS-Z WS-IDX
         IF WS-IDX > 0
             ADD 1 TO PNB-COUNT
             MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
             EVALUATE WS-I
                 WHEN 3 MOVE 1 TO WS-HV(4)
                 WHEN 4 MOVE 1 TO WS-HV(2)
                 WHEN 5 MOVE 1 TO WS-HV(3)
                 WHEN 6 MOVE 1 TO WS-HV(1)
             END-EVALUATE
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-I = 4
             MOVE 1 TO WS-J
         ELSE
             COMPUTE WS-J = WS-I + 1
         END-IF
         IF WS-HV(WS-I) = 1 AND WS-HV(WS-J) = 1
             COMPUTE WS-X = WS-OX + WS-HX(WS-I) + WS-HX(WS-J)
             COMPUTE WS-Z = WS-OZ + WS-HZ(WS-I) + WS-HZ(WS-J)
             CALL "SWIM-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-X WS-OY WS-Z WS-IDX
             IF WS-IDX > 0
                 ADD 1 TO PNB-COUNT
                 MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SWIM-NEIGHBORS.

*> FLY-ACCEPT USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, x, y, z, node index out: FlyNodeEvaluator.findAcceptedNode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLY-ACCEPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELL                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-X LK-Y LK-Z LK-IDX.
     MOVE 0 TO LK-IDX
     CALL "CELL-GET" USING PF-WORLD LK-X LK-Y LK-Z WS-CELL
     COMPUTE WS-BY = LK-Y - 1
     CALL "CELL-GET" USING PF-WORLD LK-X WS-BY LK-Z WS-BELOW
     EVALUATE TRUE
         WHEN WS-CELL = 0
             MOVE 0 TO WS-TYPE
         WHEN WS-CELL = 9
             MOVE 1 TO WS-TYPE
         WHEN WS-CELL = 14 OR WS-CELL = 8 OR WS-CELL = 16 OR WS-CELL = 23 OR WS-CELL = 7
             MOVE WS-CELL TO WS-TYPE
         WHEN WS-CELL = 1 AND WS-BELOW = 0
             MOVE 2 TO WS-TYPE
         WHEN OTHER
             MOVE 1 TO WS-TYPE
     END-EVALUATE
     CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
     IF WS-MALUS NOT < 0
         MOVE 0 TO WS-EXTRA
         IF WS-TYPE = 2
             MOVE 1 TO WS-EXTRA
         END-IF
         CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES LK-X LK-Y LK-Z WS-TYPE WS-MALUS WS-EXTRA LK-IDX
     END-IF
     GOBACK.
 END PROGRAM FLY-ACCEPT.

*> FLY-NEIGHBORS USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, node index, PF-NEIGH: the 6 faces, then the 12 edge and 8
*> corner neighbours whose composing faces are all valid nodes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLY-NEIGHBORS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FV                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-FX                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-FY                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-FZ                  BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AXES                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH.
     MOVE 0 TO PNB-COUNT
     MOVE 0 TO WS-FX(1)
     MOVE -1 TO WS-FY(1)
     MOVE 0 TO WS-FZ(1)
     MOVE 0 TO WS-FX(2)
     MOVE 1 TO WS-FY(2)
     MOVE 0 TO WS-FZ(2)
     MOVE 0 TO WS-FX(3)
     MOVE 0 TO WS-FY(3)
     MOVE -1 TO WS-FZ(3)
     MOVE 0 TO WS-FX(4)
     MOVE 0 TO WS-FY(4)
     MOVE 1 TO WS-FZ(4)
     MOVE -1 TO WS-FX(5)
     MOVE 0 TO WS-FY(5)
     MOVE 0 TO WS-FZ(5)
     MOVE 1 TO WS-FX(6)
     MOVE 0 TO WS-FY(6)
     MOVE 0 TO WS-FZ(6)
     MOVE PN-X(LK-NODE) TO WS-OX
     MOVE PN-Y(LK-NODE) TO WS-OY
     MOVE PN-Z(LK-NODE) TO WS-OZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 0 TO WS-FV(WS-I)
         COMPUTE WS-X = WS-OX + WS-FX(WS-I)
         COMPUTE WS-Y = WS-OY + WS-FY(WS-I)
         COMPUTE WS-Z = WS-OZ + WS-FZ(WS-I)
         CALL "FLY-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-X WS-Y WS-Z WS-IDX
         IF WS-IDX > 0
             MOVE 1 TO WS-FV(WS-I)
             ADD 1 TO PNB-COUNT
             MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 MOVE 0 TO WS-AXES
                 MOVE 1 TO WS-OK
                 IF WS-DX NOT = 0
                     ADD 1 TO WS-AXES
                     IF WS-DX < 0
                         MOVE WS-FV(5) TO WS-I
                     ELSE
                         MOVE WS-FV(6) TO WS-I
                     END-IF
                     IF WS-I = 0
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-DY NOT = 0
                     ADD 1 TO WS-AXES
                     IF WS-DY < 0
                         MOVE WS-FV(1) TO WS-I
                     ELSE
                         MOVE WS-FV(2) TO WS-I
                     END-IF
                     IF WS-I = 0
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-DZ NOT = 0
                     ADD 1 TO WS-AXES
                     IF WS-DZ < 0
                         MOVE WS-FV(3) TO WS-I
                     ELSE
                         MOVE WS-FV(4) TO WS-I
                     END-IF
                     IF WS-I = 0
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-AXES NOT < 2 AND WS-OK = 1
                     COMPUTE WS-X = WS-OX + WS-DX
                     COMPUTE WS-Y = WS-OY + WS-DY
                     COMPUTE WS-Z = WS-OZ + WS-DZ
                     CALL "FLY-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-X WS-Y WS-Z WS-IDX
                     IF WS-IDX > 0
                         ADD 1 TO PNB-COUNT
                         MOVE WS-IDX TO PNB-NODE(PNB-COUNT)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FLY-NEIGHBORS.

*> NODE-NEIGHBORS USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, node index, PF-NEIGH: the neighbours of a node for the
*> evaluator kind of the search (1 walk, 2 swim, 3 fly, 4 amphibious, 5 wall climber).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NODE-NEIGHBORS.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH.
     EVALUATE PS-KIND
         WHEN 2
             CALL "SWIM-NEIGHBORS" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH
         WHEN 3
             CALL "FLY-NEIGHBORS" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH
         WHEN OTHER
             CALL "WALK-NEIGHBORS" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-NODE PF-NEIGH
     END-EVALUATE
     GOBACK.
 END PROGRAM NODE-NEIGHBORS.

*> EVAL-START USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES, node index out (0 for no start): the start node of the
*> evaluator: walk kinds scan down through water or air to the standing level and need a non-negative malus, the fly kind scans
*> up out of water, the swim kind starts at the block itself.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EVAL-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-IDX                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES LK-IDX.
     MOVE 0 TO LK-IDX
     MOVE PS-SX TO WS-X
     MOVE PS-SY TO WS-Y
     MOVE PS-SZ TO WS-Z
     EVALUATE PS-KIND
         WHEN 2
             MOVE 9 TO WS-TYPE
             CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES WS-X WS-Y WS-Z WS-TYPE WS-ZERO WS-ZERO2 LK-IDX
         WHEN 3
             CALL "CELL-GET" USING PF-WORLD WS-X WS-Y WS-Z WS-CELL
             PERFORM UNTIL WS-CELL NOT = 9
                 ADD 1 TO WS-Y
                 CALL "CELL-GET" USING PF-WORLD WS-X WS-Y WS-Z WS-CELL
             END-PERFORM
             CALL "FLY-ACCEPT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-X WS-Y WS-Z LK-IDX
         WHEN OTHER
             MOVE 0 TO WS-DONE
             CALL "CELL-GET" USING PF-WORLD WS-X WS-Y WS-Z WS-CELL
             PERFORM UNTIL WS-DONE = 1
                 IF WS-Y = 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     COMPUTE WS-BY = WS-Y - 1
                     CALL "CELL-GET" USING PF-WORLD WS-X WS-BY WS-Z WS-BELOW
                     IF (WS-CELL = 9 AND WS-BELOW = 9) OR (WS-CELL = 1 AND WS-BELOW = 1)
                         SUBTRACT 1 FROM WS-Y
                     ELSE
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
             CALL "PF-TYPE-AT" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH WS-X WS-Y WS-Z WS-TYPE
             CALL "MOB-MALUS" USING PF-MALUS-TABLE WS-TYPE WS-MALUS
             IF WS-MALUS NOT < 0
                 CALL "NODE-ACCEPT" USING PF-WORLD PF-NODES WS-X WS-Y WS-Z WS-TYPE WS-MALUS WS-ZERO LK-IDX
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EVAL-START.

*> AMPHIBIOUS-PREPARE USING PF-MALUS-TABLE: saves the mob's malus for WALKABLE, WATER and WATER_BORDER and sets WATER 0,
*> WALKABLE 6, WATER_BORDER 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. AMPHIBIOUS-PREPARE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBPATH.
 PROCEDURE DIVISION USING PF-MALUS-TABLE.
     MOVE PF-MALUS-SET(3) TO PF-SAVED-SET(1)
     MOVE PF-MALUS-VAL(3) TO PF-SAVED-VAL(1)
     MOVE PF-MALUS-SET(10) TO PF-SAVED-SET(2)
     MOVE PF-MALUS-VAL(10) TO PF-SAVED-VAL(2)
     MOVE PF-MALUS-SET(11) TO PF-SAVED-SET(3)
     MOVE PF-MALUS-VAL(11) TO PF-SAVED-VAL(3)
     MOVE 1 TO PF-MALUS-SET(3)
     MOVE 6 TO PF-MALUS-VAL(3)
     MOVE 1 TO PF-MALUS-SET(10)
     MOVE 0 TO PF-MALUS-VAL(10)
     MOVE 1 TO PF-MALUS-SET(11)
     MOVE 4 TO PF-MALUS-VAL(11)
     GOBACK.
 END PROGRAM AMPHIBIOUS-PREPARE.

*> AMPHIBIOUS-DONE USING PF-MALUS-TABLE: restores what AMPHIBIOUS-PREPARE saved.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. AMPHIBIOUS-DONE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBPATH.
 PROCEDURE DIVISION USING PF-MALUS-TABLE.
     MOVE PF-SAVED-SET(1) TO PF-MALUS-SET(3)
     MOVE PF-SAVED-VAL(1) TO PF-MALUS-VAL(3)
     MOVE PF-SAVED-SET(2) TO PF-MALUS-SET(10)
     MOVE PF-SAVED-VAL(2) TO PF-MALUS-VAL(10)
     MOVE PF-SAVED-SET(3) TO PF-MALUS-SET(11)
     MOVE PF-SAVED-VAL(3) TO PF-MALUS-VAL(11)
     GOBACK.
 END PROGRAM AMPHIBIOUS-DONE.

*> MAX-FALL-DISTANCE USING has target (1/0), health, max health (FLOAT-LONG), difficulty id (0 Peaceful .. 3 Hard), distance out
*> (BINARY-LONG): Mob.getMaxFallDistance.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. MAX-FALL-DISTANCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-RAW                 FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-HAS                 BINARY-LONG.
 01 LK-HEALTH              FLOAT-LONG.
 01 LK-MAX                 FLOAT-LONG.
 01 LK-DIFFICULTY          BINARY-LONG.
 01 LK-DISTANCE            BINARY-LONG.
 PROCEDURE DIVISION USING LK-HAS LK-HEALTH LK-MAX LK-DIFFICULTY LK-DISTANCE.
     IF LK-HAS = 0
         MOVE 3 TO LK-DISTANCE
     ELSE
         COMPUTE WS-RAW = LK-HEALTH - LK-MAX * 0.33
         COMPUTE WS-N = FUNCTION INTEGER-PART(WS-RAW)
         COMPUTE WS-N = WS-N - (3 - LK-DIFFICULTY) * 4
         IF WS-N < 0
             MOVE 0 TO WS-N
         END-IF
         COMPUTE LK-DISTANCE = WS-N + 3
     END-IF
     GOBACK.
 END PROGRAM MAX-FALL-DISTANCE.

*> JUMP-HEIGHT USING step height (FLOAT-LONG), jump height out (FLOAT-LONG), step-up count out (BINARY-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. JUMP-HEIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-STEP                FLOAT-LONG.
 01 LK-HEIGHT              FLOAT-LONG.
 01 LK-COUNT               BINARY-LONG.
 PROCEDURE DIVISION USING LK-STEP LK-HEIGHT LK-COUNT.
     IF LK-STEP > 1.125
         MOVE LK-STEP TO LK-HEIGHT
     ELSE
         MOVE 1.125 TO LK-HEIGHT
     END-IF
     IF LK-STEP > 1.0
         COMPUTE LK-COUNT = FUNCTION INTEGER(LK-STEP)
     ELSE
         MOVE 1 TO LK-COUNT
     END-IF
     GOBACK.
 END PROGRAM JUMP-HEIGHT.

*> CAN-CUT-CORNER USING path type, result out (1/0): false for FIRE_IN_NEIGHBOR, DAMAGING_IN_NEIGHBOR and WALKABLE_DOOR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAN-CUT-CORNER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-TYPE                BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-TYPE LK-RESULT.
     MOVE 1 TO LK-RESULT
     IF LK-TYPE = 13 OR LK-TYPE = 15 OR LK-TYPE = 3
         MOVE 0 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM CAN-CUT-CORNER.

*> HEURISTIC-UPDATE USING PF-NODES, PF-SEARCH, node index, target table (best distance, best node, reached per target), best
*> distance out (FLOAT-LONG): getBestH, the smallest distance from the node to a target, recording the closest node of each target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEURISTIC-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 01 WS-HEURISTIC           FLOAT-LONG.
 01 WS-MANHATTAN           BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 01 LK-TARGETS.
    05 LK-BEST             FLOAT-LONG OCCURS 4 TIMES.
    05 LK-BEST-NODE        BINARY-LONG OCCURS 4 TIMES.
    05 LK-REACHED          BINARY-LONG OCCURS 4 TIMES.
 01 LK-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION USING PF-NODES PF-SEARCH LK-NODE LK-TARGETS LK-RESULT.
     MOVE 1.0E+30 TO LK-RESULT
     MOVE PN-X(LK-NODE) TO WS-X
     MOVE PN-Y(LK-NODE) TO WS-Y
     MOVE PN-Z(LK-NODE) TO WS-Z
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > PS-TARGET-COUNT
         CALL "NODE-DISTANCE" USING WS-X WS-Y WS-Z PS-TX(WS-T) PS-TY(WS-T) PS-TZ(WS-T) WS-HEURISTIC WS-MANHATTAN
         IF WS-HEURISTIC < LK-BEST(WS-T)
             MOVE WS-HEURISTIC TO LK-BEST(WS-T)
             IF LK-REACHED(WS-T) = 0
                 MOVE LK-NODE TO LK-BEST-NODE(WS-T)
             END-IF
         END-IF
         IF WS-HEURISTIC < LK-RESULT
             MOVE WS-HEURISTIC TO LK-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HEURISTIC-UPDATE.

*> CHOOSE-END USING PF-NODES, PF-SEARCH, target table, end node out: the node the path ends at (sets PS-REACHED): the first reached
*> target, else the target whose best node came closest, ties going to the path with fewer nodes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHOOSE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   BINARY-LONG.
 01 WS-CHAIN               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BEST-LENGTH         BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-CHOSEN-BEST         FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-TARGETS.
    05 LK-BEST             FLOAT-LONG OCCURS 4 TIMES.
    05 LK-BEST-NODE        BINARY-LONG OCCURS 4 TIMES.
    05 LK-REACHED          BINARY-LONG OCCURS 4 TIMES.
 01 LK-END                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-NODES PF-SEARCH LK-TARGETS LK-END.
     MOVE 0 TO WS-CHOSEN
     MOVE 0 TO WS-BEST-LENGTH
     MOVE 1.0E+30 TO WS-CHOSEN-BEST
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > PS-TARGET-COUNT
         MOVE LK-BEST-NODE(WS-T) TO WS-CHAIN
         MOVE 0 TO WS-LENGTH
         PERFORM UNTIL WS-CHAIN = 0
             ADD 1 TO WS-LENGTH
             MOVE PN-FROM(WS-CHAIN) TO WS-CHAIN
         END-PERFORM
         EVALUATE TRUE
             WHEN LK-REACHED(WS-T) = 1 AND PS-REACHED = 0
                 MOVE 1 TO PS-REACHED
                 MOVE WS-T TO WS-CHOSEN
                 MOVE WS-LENGTH TO WS-BEST-LENGTH
             WHEN PS-REACHED = 0 AND LK-BEST(WS-T) < WS-CHOSEN-BEST
                 MOVE LK-BEST(WS-T) TO WS-CHOSEN-BEST
                 MOVE WS-T TO WS-CHOSEN
                 MOVE WS-LENGTH TO WS-BEST-LENGTH
             WHEN PS-REACHED = 0 AND LK-BEST(WS-T) = WS-CHOSEN-BEST AND WS-LENGTH < WS-BEST-LENGTH
                 MOVE WS-T TO WS-CHOSEN
                 MOVE WS-LENGTH TO WS-BEST-LENGTH
         END-EVALUATE
     END-PERFORM
     MOVE LK-BEST-NODE(WS-CHOSEN) TO LK-END
     GOBACK.
 END PROGRAM CHOOSE-END.

*> PATH-FIND USING PF-WORLD, PF-MALUS-TABLE, PF-SEARCH, PF-NODES (MOBPATH.cpy): PathFinder.findPath, a weighted A* (neighbour heuristic
*> weight 1.5, the start unweighted) over the evaluator of PS-KIND. Fills PS-PATH / PS-PATH-COUNT (start to end), PS-REACHED and
*> PS-VISITED (every target reached in the same step ends at the same node, so the first one is taken). The open set is scanned linearly and ties go to the earlier node.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TARGETS.
    05 WS-TARGET-BEST      FLOAT-LONG OCCURS 4 TIMES.
    05 WS-TARGET-NODE      BINARY-LONG OCCURS 4 TIMES.
    05 WS-TARGET-REACHED   BINARY-LONG OCCURS 4 TIMES.
 01 WS-START               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-NEIGHBOR            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-F              FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-EUCLID              FLOAT-LONG.
 01 WS-MANHATTAN           BINARY-LONG.
 01 WS-HEURISTIC           FLOAT-LONG.
 01 WS-BEST-H              FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-TENTATIVE           FLOAT-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BEST-LENGTH         BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-CHAIN               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-CHOSEN-BEST         FLOAT-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NEIGH.
    05 WS-NB-COUNT          BINARY-LONG.
    05 WS-NB-NODE           BINARY-LONG OCCURS 32 TIMES.
 LINKAGE SECTION.
 COPY MOBPATH.
 PROCEDURE DIVISION USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES.
     MOVE 0 TO PS-REACHED
     MOVE 0 TO PS-VISITED
     MOVE 0 TO PS-PATH-COUNT
     CALL "EVAL-START" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-START
     IF WS-START > 0
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > PS-TARGET-COUNT
             MOVE 1.0E+30 TO WS-TARGET-BEST(WS-T)
             MOVE 0 TO WS-TARGET-NODE(WS-T)
             MOVE 0 TO WS-TARGET-REACHED(WS-T)
         END-PERFORM
         CALL "HEURISTIC-UPDATE" USING PF-NODES PF-SEARCH WS-START WS-TARGETS WS-BEST-H
         MOVE 0 TO PN-G(WS-START)
         MOVE WS-BEST-H TO PN-H(WS-START)
         MOVE 0 TO PN-WALKED(WS-START)
         MOVE 1 TO PN-STATE(WS-START)
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1 OR PS-VISITED NOT < PS-BUDGET
             MOVE 0 TO WS-BEST
             MOVE 1.0E+30 TO WS-BEST-F
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PN-COUNT
                 IF PN-STATE(WS-I) = 1
                     COMPUTE WS-F = PN-G(WS-I) + PN-H(WS-I)
                     IF WS-F < WS-BEST-F
                         MOVE WS-F TO WS-BEST-F
                         MOVE WS-I TO WS-BEST
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-BEST = 0
                 MOVE 1 TO WS-DONE
             ELSE
                 MOVE WS-BEST TO WS-NODE
                 MOVE 2 TO PN-STATE(WS-NODE)
                 ADD 1 TO PS-VISITED
                 MOVE 0 TO WS-ANY
                 PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > PS-TARGET-COUNT
                     CALL "NODE-DISTANCE" USING PN-X(WS-NODE) PN-Y(WS-NODE) PN-Z(WS-NODE)
                         PS-TX(WS-T) PS-TY(WS-T) PS-TZ(WS-T) WS-EUCLID WS-MANHATTAN
                     IF WS-MANHATTAN NOT > PS-REACH
                         IF WS-TARGET-REACHED(WS-T) = 0
                             MOVE 1 TO WS-TARGET-REACHED(WS-T)
                             MOVE WS-NODE TO WS-TARGET-NODE(WS-T)
                         END-IF
                         MOVE 1 TO WS-ANY
                     END-IF
                 END-PERFORM
                 IF WS-ANY = 1
                     MOVE 1 TO WS-DONE
                 ELSE
                     CALL "NODE-DISTANCE" USING PN-X(WS-NODE) PN-Y(WS-NODE) PN-Z(WS-NODE)
                         PS-SX PS-SY PS-SZ WS-EUCLID WS-MANHATTAN
                     IF WS-EUCLID < PS-MAX-DIST
                         CALL "NODE-NEIGHBORS" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES WS-NODE WS-NEIGH
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NB-COUNT
                             MOVE WS-NB-NODE(WS-I) TO WS-NEIGHBOR
                             IF PN-STATE(WS-NEIGHBOR) NOT = 2
                                 MOVE PN-X(WS-NODE) TO WS-X1
                                 MOVE PN-Y(WS-NODE) TO WS-Y1
                                 MOVE PN-Z(WS-NODE) TO WS-Z1
                                 MOVE PN-X(WS-NEIGHBOR) TO WS-X2
                                 MOVE PN-Y(WS-NEIGHBOR) TO WS-Y2
                                 MOVE PN-Z(WS-NEIGHBOR) TO WS-Z2
                                 CALL "NODE-DISTANCE" USING WS-X1 WS-Y1 WS-Z1 WS-X2 WS-Y2 WS-Z2 WS-DIST WS-MANHATTAN
                                 COMPUTE PN-WALKED(WS-NEIGHBOR) = PN-WALKED(WS-NODE) + WS-DIST
                                 COMPUTE WS-TENTATIVE = PN-G(WS-NODE) + WS-DIST + PN-COST(WS-NEIGHBOR)
                                 IF PN-WALKED(WS-NEIGHBOR) < PS-MAX-DIST
                                     IF PN-STATE(WS-NEIGHBOR) = 0 OR WS-TENTATIVE < PN-G(WS-NEIGHBOR)
                                         MOVE WS-NODE TO PN-FROM(WS-NEIGHBOR)
                                         MOVE WS-TENTATIVE TO PN-G(WS-NEIGHBOR)
                                         CALL "HEURISTIC-UPDATE" USING PF-NODES PF-SEARCH WS-NEIGHBOR WS-TARGETS WS-BEST-H
                                         COMPUTE PN-H(WS-NEIGHBOR) = 1.5 * WS-BEST-H
                                         MOVE 1 TO PN-STATE(WS-NEIGHBOR)
                                     END-IF
                                 END-IF
                             END-IF
                         END-PERFORM
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         CALL "CHOOSE-END" USING PF-NODES PF-SEARCH WS-TARGETS WS-END
         MOVE 0 TO WS-LENGTH
         MOVE WS-END TO WS-CHAIN
         PERFORM UNTIL WS-CHAIN = 0
             ADD 1 TO WS-LENGTH
             MOVE PN-FROM(WS-CHAIN) TO WS-CHAIN
         END-PERFORM
         MOVE WS-LENGTH TO PS-PATH-COUNT
         MOVE WS-END TO WS-CHAIN
         MOVE WS-LENGTH TO WS-POS
         PERFORM UNTIL WS-CHAIN = 0
             MOVE PN-X(WS-CHAIN) TO PS-PX(WS-POS)
             MOVE PN-Y(WS-CHAIN) TO PS-PY(WS-POS)
             MOVE PN-Z(WS-CHAIN) TO PS-PZ(WS-POS)
             MOVE PN-TYPE(WS-CHAIN) TO PS-PTYPE(WS-POS)
             MOVE 0 TO PS-SKY(WS-POS)
             SUBTRACT 1 FROM WS-POS
             MOVE PN-FROM(WS-CHAIN) TO WS-CHAIN
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PATH-FIND.

*> ---- 5.4 Navigation classes ----------------------------------------------------------------------------------------------
*> Classes: 1 GroundPathNavigation, 2 WaterBoundPathNavigation, 3 FlyingPathNavigation, 4 AmphibiousPathNavigation,
*> 5 WallClimberNavigation.

*> NAV-CLASS-INFO USING class, evaluator kind out, canNavigateGround out (1/0), max vertical distance to a waypoint out (FLOAT-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-CLASS-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-CLASS               BINARY-LONG.
 01 LK-KIND                BINARY-LONG.
 01 LK-GROUND              BINARY-LONG.
 01 LK-VERTICAL            FLOAT-LONG.
 PROCEDURE DIVISION USING LK-CLASS LK-KIND LK-GROUND LK-VERTICAL.
     MOVE 1.0 TO LK-VERTICAL
     MOVE 0 TO LK-GROUND
     EVALUATE LK-CLASS
         WHEN 2
             MOVE 2 TO LK-KIND
             MOVE 0.5 TO LK-VERTICAL
         WHEN 3
             MOVE 3 TO LK-KIND
         WHEN 4
             MOVE 4 TO LK-KIND
             MOVE 1 TO LK-GROUND
         WHEN OTHER
             MOVE 1 TO LK-KIND
             MOVE 1 TO LK-GROUND
     END-EVALUATE
     GOBACK.
 END PROGRAM NAV-CLASS-INFO.

*> NAV-CAN-UPDATE-PATH USING class, on ground, in liquid, is a passenger (1/0), result out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-CAN-UPDATE-PATH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-CLASS               BINARY-LONG.
 01 LK-GROUND              BINARY-LONG.
 01 LK-LIQUID              BINARY-LONG.
 01 LK-PASSENGER           BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-CLASS LK-GROUND LK-LIQUID LK-PASSENGER LK-RESULT.
     MOVE 0 TO LK-RESULT
     EVALUATE LK-CLASS
         WHEN 2
             MOVE LK-LIQUID TO LK-RESULT
         WHEN 3
             IF LK-LIQUID = 0 AND LK-PASSENGER = 0
                 MOVE 1 TO LK-RESULT
             END-IF
         WHEN 4
             MOVE 1 TO LK-RESULT
         WHEN OTHER
             IF LK-GROUND = 1 OR LK-LIQUID = 1 OR LK-PASSENGER = 1
                 MOVE 1 TO LK-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM NAV-CAN-UPDATE-PATH.

*> NAV-STABLE-DESTINATION USING class, block here is a solid render block, block below is a solid render block, block below is
*> air, entity can stand on the block below (all 1/0), result out (1/0): isStableDestination.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-STABLE-DESTINATION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-CLASS               BINARY-LONG.
 01 LK-HERE                BINARY-LONG.
 01 LK-BELOW               BINARY-LONG.
 01 LK-AIR                 BINARY-LONG.
 01 LK-STAND               BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-CLASS LK-HERE LK-BELOW LK-AIR LK-STAND LK-RESULT.
     MOVE 0 TO LK-RESULT
     EVALUATE LK-CLASS
         WHEN 2
             IF LK-HERE = 0
                 MOVE 1 TO LK-RESULT
             END-IF
         WHEN 3
             MOVE LK-STAND TO LK-RESULT
         WHEN 4
             IF LK-AIR = 0
                 MOVE 1 TO LK-RESULT
             END-IF
         WHEN OTHER
             MOVE LK-BELOW TO LK-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM NAV-STABLE-DESTINATION.

*> NAV-CAN-MOVE-DIRECTLY USING class, in liquid, ray test clear (fluids ignored), ray test clear (fluids count as hits) (all 1/0),
*> result out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-CAN-MOVE-DIRECTLY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-CLASS               BINARY-LONG.
 01 LK-LIQUID              BINARY-LONG.
 01 LK-RAY                 BINARY-LONG.
 01 LK-RAY-FLUIDS          BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-CLASS LK-LIQUID LK-RAY LK-RAY-FLUIDS LK-RESULT.
     MOVE 0 TO LK-RESULT
     EVALUATE LK-CLASS
         WHEN 2
             MOVE LK-RAY TO LK-RESULT
         WHEN 3
             MOVE LK-RAY-FLUIDS TO LK-RESULT
         WHEN 4
             IF LK-LIQUID = 1
                 MOVE LK-RAY TO LK-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM NAV-CAN-MOVE-DIRECTLY.

*> PATH-TRIM-SUN USING PF-SEARCH, avoid sun (1/0): with avoidSun the path is cut before the first node whose PS-SKY is 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-TRIM-SUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-CUT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-AVOID               BINARY-LONG.
 PROCEDURE DIVISION USING PF-SEARCH LK-AVOID.
     IF LK-AVOID = 1
         MOVE 0 TO WS-CUT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PS-PATH-COUNT OR WS-CUT > 0
             IF PS-SKY(WS-I) = 1
                 MOVE WS-I TO WS-CUT
             END-IF
         END-PERFORM
         IF WS-CUT > 0
             COMPUTE PS-PATH-COUNT = WS-CUT - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PATH-TRIM-SUN.

*> FIND-SURFACE USING PF-WORLD, x, y, z, y out: GroundPathNavigation.createPath's target adjustment: a target in air goes down to
*> the surface, a target inside a block goes up to the first free position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIND-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELL                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-X                   BINARY-LONG.
 01 LK-Y                   BINARY-LONG.
 01 LK-Z                   BINARY-LONG.
 01 LK-OUT                 BINARY-LONG.
 PROCEDURE DIVISION USING PF-WORLD LK-X LK-Y LK-Z LK-OUT.
     MOVE LK-Y TO LK-OUT
     MOVE 0 TO WS-DONE
     CALL "CELL-GET" USING PF-WORLD LK-X LK-OUT LK-Z WS-CELL
     IF WS-CELL = 0
         PERFORM UNTIL WS-CELL NOT = 0 OR LK-OUT NOT < PW-DY
             ADD 1 TO LK-OUT
             CALL "CELL-GET" USING PF-WORLD LK-X LK-OUT LK-Z WS-CELL
         END-PERFORM
     ELSE
         PERFORM UNTIL WS-DONE = 1
             IF LK-OUT = 0
                 MOVE 1 TO WS-DONE
             ELSE
                 COMPUTE WS-BY = LK-OUT - 1
                 CALL "CELL-GET" USING PF-WORLD LK-X WS-BY LK-Z WS-BELOW
                 IF WS-BELOW = 1
                     SUBTRACT 1 FROM LK-OUT
                 ELSE
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FIND-SURFACE.

*> PATH-REGION-OFFSET USING entity target (1/0), offset out: the padding of the snapshot region, 8 for blocks, 16 for entities.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-REGION-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-ENTITY              BINARY-LONG.
 01 LK-OFFSET              BINARY-LONG.
 PROCEDURE DIVISION USING LK-ENTITY LK-OFFSET.
     MOVE 8 TO LK-OFFSET
     IF LK-ENTITY = 1
         MOVE 16 TO LK-OFFSET
     END-IF
     GOBACK.
 END PROGRAM PATH-REGION-OFFSET.

*> PATH-MAX-LENGTH USING follow range, required path length (FLOAT-LONG), maximum path length out (FLOAT-LONG).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-MAX-LENGTH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-RANGE               FLOAT-LONG.
 01 LK-REQUIRED            FLOAT-LONG.
 01 LK-LENGTH              FLOAT-LONG.
 PROCEDURE DIVISION USING LK-RANGE LK-REQUIRED LK-LENGTH.
     MOVE LK-RANGE TO LK-LENGTH
     IF LK-REQUIRED > LK-RANGE
         MOVE LK-REQUIRED TO LK-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PATH-MAX-LENGTH.

*> CREATE-PATH-GUARD USING empty target set, y below the world minimum, has a current path, current path done, its target is in
*> the set (all 1/0), action out: 0 null, 1 keep the current path, 2 compute a new one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATE-PATH-GUARD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-EMPTY               BINARY-LONG.
 01 LK-BELOW               BINARY-LONG.
 01 LK-CURRENT             BINARY-LONG.
 01 LK-DONE                BINARY-LONG.
 01 LK-INSET               BINARY-LONG.
 01 LK-ACTION              BINARY-LONG.
 PROCEDURE DIVISION USING LK-EMPTY LK-BELOW LK-CURRENT LK-DONE LK-INSET LK-ACTION.
     EVALUATE TRUE
         WHEN LK-EMPTY = 1 OR LK-BELOW = 1
             MOVE 0 TO LK-ACTION
         WHEN LK-CURRENT = 1 AND LK-DONE = 0 AND LK-INSET = 1
             MOVE 1 TO LK-ACTION
         WHEN OTHER
             MOVE 2 TO LK-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM CREATE-PATH-GUARD.

*> PATH-TARGET-Y USING entity block y, offsetUpward (1/0), target y out: a mob paths to the block above an entity's feet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-TARGET-Y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-Y                   BINARY-LONG.
 01 LK-UP                  BINARY-LONG.
 01 LK-OUT                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-Y LK-UP LK-OUT.
     MOVE LK-Y TO LK-OUT
     IF LK-UP = 1
         ADD 1 TO LK-OUT
     END-IF
     GOBACK.
 END PROGRAM PATH-TARGET-Y.

*> ---- 5.5 Following a path ------------------------------------------------------------------------------------------------

*> PATH-NEXT-ENTITY-POS USING PF-SEARCH, node index (BINARY-LONG), bbWidth (FLOAT-LONG), x, y, z out (FLOAT-LONG):
*> Path.getNextEntityPos, the node x and z plus (int)(width + 1) x 0.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATH-NEXT-ENTITY-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHIFT               FLOAT-LONG.
 01 WS-WHOLE               BINARY-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-INDEX               BINARY-LONG.
 01 LK-WIDTH               FLOAT-LONG.
 01 LK-X                   FLOAT-LONG.
 01 LK-Y                   FLOAT-LONG.
 01 LK-Z                   FLOAT-LONG.
 PROCEDURE DIVISION USING PF-SEARCH LK-INDEX LK-WIDTH LK-X LK-Y LK-Z.
     COMPUTE WS-WHOLE = FUNCTION INTEGER-PART(LK-WIDTH + 1)
     COMPUTE WS-SHIFT = WS-WHOLE * 0.5
     COMPUTE LK-X = PS-PX(LK-INDEX) + WS-SHIFT
     MOVE PS-PY(LK-INDEX) TO LK-Y
     COMPUTE LK-Z = PS-PZ(LK-INDEX) + WS-SHIFT
     GOBACK.
 END PROGRAM PATH-NEXT-ENTITY-POS.

*> FOLLOW-REACHED USING mob x y z, node x y z (FLOAT-LONG), bbWidth (FLOAT-LONG), reached out (1/0): followThePath's reach test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOLLOW-REACHED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-MX                  FLOAT-LONG.
 01 LK-MY                  FLOAT-LONG.
 01 LK-MZ                  FLOAT-LONG.
 01 LK-NX                  FLOAT-LONG.
 01 LK-NY                  FLOAT-LONG.
 01 LK-NZ                  FLOAT-LONG.
 01 LK-WIDTH               FLOAT-LONG.
 01 LK-REACHED             BINARY-LONG.
 PROCEDURE DIVISION USING LK-MX LK-MY LK-MZ LK-NX LK-NY LK-NZ LK-WIDTH LK-REACHED.
     IF LK-WIDTH > 0.75
         COMPUTE WS-LIMIT = LK-WIDTH / 2
     ELSE
         COMPUTE WS-LIMIT = 0.75 - LK-WIDTH / 2
     END-IF
     COMPUTE WS-DX = FUNCTION ABS(LK-MX - (LK-NX + 0.5))
     COMPUTE WS-DY = FUNCTION ABS(LK-MY - LK-NY)
     COMPUTE WS-DZ = FUNCTION ABS(LK-MZ - (LK-NZ + 0.5))
     MOVE 0 TO LK-REACHED
     IF WS-DX < WS-LIMIT AND WS-DZ < WS-LIMIT AND WS-DY < 1.0
         MOVE 1 TO LK-REACHED
     END-IF
     GOBACK.
 END PROGRAM FOLLOW-REACHED.

*> FOLLOW-SHORTCUT USING next node is the last (1/0), distance to the next node's bottom centre (FLOAT-LONG), can move directly
*> (1/0), vector A to the next node, vector B to the node after (3 FLOAT-LONG each), shortcut out (1/0):
*> shouldTargetNextNodeInDirection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOLLOW-SHORTCUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A2                  FLOAT-LONG.
 01 WS-B2                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 LINKAGE SECTION.
 01 LK-LAST                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-DIRECT              BINARY-LONG.
 01 LK-AX                  FLOAT-LONG.
 01 LK-AY                  FLOAT-LONG.
 01 LK-AZ                  FLOAT-LONG.
 01 LK-BX                  FLOAT-LONG.
 01 LK-BY                  FLOAT-LONG.
 01 LK-BZ                  FLOAT-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-LAST LK-DIST LK-DIRECT LK-AX LK-AY LK-AZ LK-BX LK-BY LK-BZ LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-LAST = 0 AND LK-DIST < 2.0
         IF LK-DIRECT = 1
             MOVE 1 TO LK-RESULT
         ELSE
             COMPUTE WS-A2 = LK-AX * LK-AX + LK-AY * LK-AY + LK-AZ * LK-AZ
             COMPUTE WS-B2 = LK-BX * LK-BX + LK-BY * LK-BY + LK-BZ * LK-BZ
             IF WS-B2 < WS-A2 OR WS-A2 < 0.5
                 COMPUTE WS-DOT = LK-AX * LK-BX + LK-AY * LK-BY + LK-AZ * LK-BZ
                 IF WS-DOT < 0
                     MOVE 1 TO LK-RESULT
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FOLLOW-SHORTCUT.

*> FOLLOW-ADVANCE USING reached, can cut the corner, shortcut holds (1/0), advance out (1/0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOLLOW-ADVANCE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-REACHED             BINARY-LONG.
 01 LK-CUT                 BINARY-LONG.
 01 LK-SHORTCUT            BINARY-LONG.
 01 LK-ADVANCE             BINARY-LONG.
 PROCEDURE DIVISION USING LK-REACHED LK-CUT LK-SHORTCUT LK-ADVANCE.
     MOVE 0 TO LK-ADVANCE
     IF LK-REACHED = 1 OR (LK-CUT = 1 AND LK-SHORTCUT = 1)
         MOVE 1 TO LK-ADVANCE
     END-IF
     GOBACK.
 END PROGRAM FOLLOW-ADVANCE.

*> FLY-REACHED USING mob block x y z, node x y z (BINARY-LONG), reached out (1/0): the flying navigation's reach test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FLY-REACHED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-MX                  BINARY-LONG.
 01 LK-MY                  BINARY-LONG.
 01 LK-MZ                  BINARY-LONG.
 01 LK-NX                  BINARY-LONG.
 01 LK-NY                  BINARY-LONG.
 01 LK-NZ                  BINARY-LONG.
 01 LK-REACHED             BINARY-LONG.
 PROCEDURE DIVISION USING LK-MX LK-MY LK-MZ LK-NX LK-NY LK-NZ LK-REACHED.
     MOVE 0 TO LK-REACHED
     IF LK-MX = LK-NX AND LK-MY = LK-NY AND LK-MZ = LK-NZ
         MOVE 1 TO LK-REACHED
     END-IF
     GOBACK.
 END PROGRAM FLY-REACHED.

*> STUCK-CHECK USING PF-NAV, speed (FLOAT-LONG), game time (BINARY-LONG), mob x y z (FLOAT-LONG), stuck out (1/0): the movement check
*> of doStuckDetection, every time more than 100 ticks have passed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STUCK-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-SPEED               FLOAT-LONG.
 01 LK-NOW                 BINARY-LONG.
 01 LK-X                   FLOAT-LONG.
 01 LK-Y                   FLOAT-LONG.
 01 LK-Z                   FLOAT-LONG.
 01 LK-STUCK               BINARY-LONG.
 PROCEDURE DIVISION USING PF-NAV LK-SPEED LK-NOW LK-X LK-Y LK-Z LK-STUCK.
     IF LK-NOW - PV-LAST-CHECK > 100
         IF LK-SPEED NOT < 1.0
             MOVE LK-SPEED TO WS-F
         ELSE
             COMPUTE WS-F = LK-SPEED * LK-SPEED
         END-IF
         COMPUTE WS-T = WS-F * 100 * 0.25
         COMPUTE WS-DIST = (LK-X - PV-LAST-X) * (LK-X - PV-LAST-X) + (LK-Y - PV-LAST-Y) * (LK-Y - PV-LAST-Y)
             + (LK-Z - PV-LAST-Z) * (LK-Z - PV-LAST-Z)
         IF WS-DIST < WS-T * WS-T
             MOVE 1 TO PV-STUCK
             MOVE 0 TO PV-COUNT
         ELSE
             MOVE 0 TO PV-STUCK
         END-IF
         MOVE LK-NOW TO PV-LAST-CHECK
         MOVE LK-X TO PV-LAST-X
         MOVE LK-Y TO PV-LAST-Y
         MOVE LK-Z TO PV-LAST-Z
     END-IF
     MOVE PV-STUCK TO LK-STUCK
     GOBACK.
 END PROGRAM STUCK-CHECK.

*> TIMEOUT-CHECK USING PF-NAV, next node index, game time (BINARY-LONG), speed, distance to the node's bottom centre (FLOAT-LONG),
*> timed out out (1/0): the node timeout of doStuckDetection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TIMEOUT-CHECK.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NODE                BINARY-LONG.
 01 LK-NOW                 BINARY-LONG.
 01 LK-SPEED               FLOAT-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-TIMED-OUT           BINARY-LONG.
 PROCEDURE DIVISION USING PF-NAV LK-NODE LK-NOW LK-SPEED LK-DIST LK-TIMED-OUT.
     MOVE 0 TO LK-TIMED-OUT
     IF LK-NODE = PV-CACHED
         COMPUTE PV-TIMER = PV-TIMER + LK-NOW - PV-LAST-TIMEOUT
     ELSE
         MOVE LK-NODE TO PV-CACHED
         IF LK-SPEED > 0
             COMPUTE PV-LIMIT = LK-DIST / LK-SPEED * 20
         ELSE
             MOVE 0 TO PV-LIMIT
         END-IF
     END-IF
     IF PV-LIMIT > 0 AND PV-TIMER > PV-LIMIT * 3
         MOVE 1 TO LK-TIMED-OUT
         MOVE 0 TO PV-TIMER
         MOVE -1 TO PV-CACHED
         MOVE 0 TO PV-LIMIT
     END-IF
     MOVE LK-NOW TO PV-LAST-TIMEOUT
     GOBACK.
 END PROGRAM TIMEOUT-CHECK.

*> RECOMPUTE-GATE USING PF-NAV, game time (BINARY-LONG), recompute now out (1/0): at most once per 20 ticks, else delayed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECOMPUTE-GATE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY MOBPATH.
 01 LK-NOW                 BINARY-LONG.
 01 LK-DO                  BINARY-LONG.
 PROCEDURE DIVISION USING PF-NAV LK-NOW LK-DO.
     IF LK-NOW - PV-LAST-RECOMPUTE > 20
         MOVE LK-NOW TO PV-LAST-RECOMPUTE
         MOVE 0 TO PV-DELAYED
         MOVE 1 TO LK-DO
     ELSE
         MOVE 1 TO PV-DELAYED
         MOVE 0 TO LK-DO
     END-IF
     GOBACK.
 END PROGRAM RECOMPUTE-GATE.

*> SHOULD-RECOMPUTE USING path done or empty (1/0), distance of the target to the end node centre (FLOAT-LONG), nodes remaining
*> (BINARY-LONG), result out (1/0): shouldRecomputePath.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHOULD-RECOMPUTE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DONE                BINARY-LONG.
 01 LK-DIST                FLOAT-LONG.
 01 LK-REMAINING           BINARY-LONG.
 01 LK-RESULT              BINARY-LONG.
 PROCEDURE DIVISION USING LK-DONE LK-DIST LK-REMAINING LK-RESULT.
     MOVE 0 TO LK-RESULT
     IF LK-DONE = 1 OR LK-DIST NOT < LK-REMAINING / 2.0
         MOVE 1 TO LK-RESULT
     END-IF
     GOBACK.
 END PROGRAM SHOULD-RECOMPUTE.

*> NAV-TICK-PLAN USING path done, canUpdatePath, recomputation pending (1/0), recompute out, follow the path out, aim the move
*> control out (1/0): the order of PathNavigation.tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-TICK-PLAN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-DONE                BINARY-LONG.
 01 LK-CAN                 BINARY-LONG.
 01 LK-PENDING             BINARY-LONG.
 01 LK-RECOMPUTE           BINARY-LONG.
 01 LK-FOLLOW              BINARY-LONG.
 01 LK-AIM                 BINARY-LONG.
 PROCEDURE DIVISION USING LK-DONE LK-CAN LK-PENDING LK-RECOMPUTE LK-FOLLOW LK-AIM.
     MOVE LK-PENDING TO LK-RECOMPUTE
     MOVE 0 TO LK-FOLLOW
     MOVE 0 TO LK-AIM
     IF LK-DONE = 0
         MOVE 1 TO LK-AIM
         IF LK-CAN = 1
             MOVE 1 TO LK-FOLLOW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM NAV-TICK-PLAN.

*> NAV-MOVE-TO USING path is null, same as the current path (1/0), node count, accepted out (1/0): PathNavigation.moveTo(path).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAV-MOVE-TO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-NULL                BINARY-LONG.
 01 LK-SAME                BINARY-LONG.
 01 LK-COUNT               BINARY-LONG.
 01 LK-OK                  BINARY-LONG.
 PROCEDURE DIVISION USING LK-NULL LK-SAME LK-COUNT LK-OK.
     EVALUATE TRUE
         WHEN LK-NULL = 1
             MOVE 0 TO LK-OK
         WHEN LK-SAME = 1
             MOVE 1 TO LK-OK
         WHEN LK-COUNT = 0
             MOVE 0 TO LK-OK
         WHEN OTHER
             MOVE 1 TO LK-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM NAV-MOVE-TO.

*> GROUND-Y USING block below is air (1/0), node y, floor level of the block (FLOAT-LONG), y out (FLOAT-LONG): the ground y the
*> ground navigation hands to the move control.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. GROUND-Y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 LK-AIR                 BINARY-LONG.
 01 LK-NODE-Y              FLOAT-LONG.
 01 LK-FLOOR               FLOAT-LONG.
 01 LK-Y                   FLOAT-LONG.
 PROCEDURE DIVISION USING LK-AIR LK-NODE-Y LK-FLOOR LK-Y.
     IF LK-AIR = 1
         MOVE LK-NODE-Y TO LK-Y
     ELSE
         MOVE LK-FLOOR TO LK-Y
     END-IF
     GOBACK.
 END PROGRAM GROUND-Y.
