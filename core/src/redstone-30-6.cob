*> Redstone part 6 (docs/protocol/30-redstone-6-rails.md) as programs of plain numbers (RS3- prefix), like the part 1 helpers (RS1-): the caller reads the level
*> and passes the facts; the program returns the decision. Nothing here is wired into the block-update hooks.
*> Shapes are the ordinals of section 1 (0 north_south, 1 east_west, 2 ascending_east, 3 ascending_west, 4 ascending_north, 5 ascending_south,
*> 6 south_east, 7 south_west, 8 north_west, 9 north_east). Directions are the data values 2 north, 3 south, 4 west, 5 east (0 down, 1 up).
*> Rail kinds: 1 rail, 2 powered_rail, 3 activator_rail, 4 detector_rail. Booleans are 0 and 1.
*> Velocities of section 8 are in nanoblocks per tick (1e-9), so 0.0078125 is 7812500; positions inside a block are thousandths.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-ORDINAL.
*> USING serialized name, ordinal out (section 1): -1 for an unknown name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ORD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORD.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "north_south"
             MOVE 0 TO L-ORD
         WHEN "east_west"
             MOVE 1 TO L-ORD
         WHEN "ascending_east"
             MOVE 2 TO L-ORD
         WHEN "ascending_west"
             MOVE 3 TO L-ORD
         WHEN "ascending_north"
             MOVE 4 TO L-ORD
         WHEN "ascending_south"
             MOVE 5 TO L-ORD
         WHEN "south_east"
             MOVE 6 TO L-ORD
         WHEN "south_west"
             MOVE 7 TO L-ORD
         WHEN "north_west"
             MOVE 8 TO L-ORD
         WHEN "north_east"
             MOVE 9 TO L-ORD
         WHEN OTHER
             MOVE -1 TO L-ORD
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SHAPE-ORDINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-IS-SLOPE.
*> USING ordinal, result out (section 1): isSlope() is true exactly for ordinals 2 to 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ORD >= 2 AND L-ORD <= 5
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-SHAPE-IS-SLOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-ALLOWED.
*> USING property (1 RAIL_SHAPE: all ten, 2 RAIL_SHAPE_STRAIGHT: ordinals 0 to 5), ordinal, result out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROP                 BINARY-LONG.
 01 L-ORD                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PROP L-ORD L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ORD >= 0 AND L-ORD <= 9
         IF L-PROP = 1 OR L-ORD <= 5
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-SHAPE-ALLOWED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-BLOCK-ROW.
*> USING block kind (1 rail, 2 powered_rail, 3 activator_rail, 4 detector_rail), shapes, has powered, states, isStraight, strength in tenths,
*> collision out (section 1.1); all zero for another kind.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SHAPES               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-STRAIGHT             BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-COLLISION            BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SHAPES L-POWERED L-STATES L-STRAIGHT L-STRENGTH L-COLLISION.
     MOVE 0 TO L-SHAPES L-POWERED L-STATES L-STRAIGHT L-STRENGTH L-COLLISION
     EVALUATE L-KIND
         WHEN 1
             MOVE 10 TO L-SHAPES
             MOVE 20 TO L-STATES
             MOVE 7 TO L-STRENGTH
         WHEN 2 THRU 4
             MOVE 6 TO L-SHAPES
             MOVE 1 TO L-POWERED L-STRAIGHT
             MOVE 24 TO L-STATES
             MOVE 7 TO L-STRENGTH
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-RAIL-BLOCK-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-CONN.
*> USING shape, entry (1 or 2), direction out (2 north, 3 south, 4 west, 5 east), up out (the high end of a slope) (section 1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIRS                PIC X(20) VALUE "23454545232353434252".
 01 WS-UPS                 PIC X(20) VALUE "00000110100100000000".
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-I L-DIR L-UP.
     COMPUTE WS-P = L-ORD * 2 + L-I
     MOVE WS-DIRS(WS-P:1) TO L-DIR
     MOVE WS-UPS(WS-P:1) TO L-UP
     GOBACK.
 END PROGRAM RS3-SHAPE-CONN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-ROTATE.
*> USING shape, rotation (0 none, 1 CW 90, 2 CW 180, 3 CCW 90), shape out (section 1.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CW90                PIC X(10) VALUE "1054237896".
 01 WS-CW180               PIC X(10) VALUE "0132548967".
 01 WS-CCW90               PIC X(10) VALUE "1045329678".
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-ROT L-OUT.
     COMPUTE WS-P = L-ORD + 1
     EVALUATE L-ROT
         WHEN 1
             MOVE WS-CW90(WS-P:1) TO L-OUT
         WHEN 2
             MOVE WS-CW180(WS-P:1) TO L-OUT
         WHEN 3
             MOVE WS-CCW90(WS-P:1) TO L-OUT
         WHEN OTHER
             MOVE L-ORD TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SHAPE-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHAPE-MIRROR.
*> USING shape, mirror (0 none, 1 left-right: swaps north and south, 2 front-back: swaps east and west), shape out (section 1.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LR                  PIC X(10) VALUE "0123549876".
 01 WS-FB                  PIC X(10) VALUE "0132457698".
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-MIR                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-MIR L-OUT.
     COMPUTE WS-P = L-ORD + 1
     EVALUATE L-MIR
         WHEN 1
             MOVE WS-LR(WS-P:1) TO L-OUT
         WHEN 2
             MOVE WS-FB(WS-P:1) TO L-OUT
         WHEN OTHER
             MOVE L-ORD TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SHAPE-MIRROR.

*> ===== Section 2: shared behaviour

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-TAG.
*> USING block name, result out (section 2.1): the rails tag lists exactly four blocks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "rail"
             MOVE 1 TO L-RESULT
         WHEN "powered_rail"
             MOVE 1 TO L-RESULT
         WHEN "detector_rail"
             MOVE 1 TO L-RESULT
         WHEN "activator_rail"
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-RAIL-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-IS-RAIL.
*> USING in the rails tag, is a BaseRailBlock, result out (section 2.1): both tests.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAGGED               BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAGGED L-CLASS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-TAGGED = 1 AND L-CLASS = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-IS-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-OUTLINE.
*> USING shape, selection height in sixteenths out (section 2.2): 8 for slopes, else 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-HEIGHT.
     MOVE 2 TO L-HEIGHT
     IF L-ORD >= 2 AND L-ORD <= 5
         MOVE 8 TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-OUTLINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-SURVIVE.
*> USING the state below has a sturdy rigid top face, canSurvive out (section 2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RIGID                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RIGID L-RESULT.
     MOVE L-RIGID TO L-RESULT
     GOBACK.
 END PROGRAM RS3-RAIL-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-WATER.
*> USING waterlogged, fluid is water out, water tick scheduled out, its delay out (section 2.2): 5 ticks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-FLUID L-SCHEDULED L-DELAY.
     MOVE 0 TO L-FLUID L-SCHEDULED L-DELAY
     IF L-WATERLOGGED = 1
         MOVE 1 TO L-FLUID L-SCHEDULED
         MOVE 5 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-PLACE.
*> USING the placer's horizontal facing (2 to 5), fluid at the clicked position is water, shape out, waterlogged out (section 2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-WATER L-SHAPE L-WATERLOGGED.
     MOVE 0 TO L-SHAPE
     IF L-FACING = 4 OR L-FACING = 5
         MOVE 1 TO L-SHAPE
     END-IF
     MOVE L-WATER TO L-WATERLOGGED
     GOBACK.
 END PROGRAM RS3-RAIL-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-ON-PLACE.
*> USING the old state is the same block, updateState runs out (section 2.3 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-RUNS.
     MOVE 1 TO L-RUNS
     IF L-SAME = 1
         MOVE 0 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-ON-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-UPDATE-STATE.
*> USING isStraight, neighborChanged on itself out (section 2.3 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STRAIGHT             BINARY-LONG.
 01 L-CALLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRAIGHT L-CALLS.
     MOVE L-STRAIGHT TO L-CALLS
     GOBACK.
 END PROGRAM RS3-RAIL-UPDATE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-NEIGHBOR.
*> USING server, still this block, shouldBeRemoved, class (1 plain, 2 powered or activator, 3 detector), action out (section 2.3 step 3):
*> 0 nothing, 1 drop and remove, 2 plain rail 3.1, 3 powered or activator rail 5.2, 4 detector rail (nothing).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-SAME L-REMOVE L-CLASS L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-SERVER = 1 AND L-SAME = 1
         EVALUATE TRUE
             WHEN L-REMOVE = 1
                 MOVE 1 TO L-ACTION
             WHEN L-CLASS = 1
                 MOVE 2 TO L-ACTION
             WHEN L-CLASS = 2
                 MOVE 3 TO L-ACTION
             WHEN OTHER
                 MOVE 4 TO L-ACTION
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-SHOULD-REMOVE.
*> USING shape, the block below has a rigid top, the high-side neighbour of a slope has one, result out (section 2.3 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-BELOW L-HIGH L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-BELOW = 0
         MOVE 1 TO L-RESULT
     END-IF
     IF L-ORD >= 2 AND L-ORD <= 5 AND L-HIGH = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-SHOULD-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SLOPE-HIGH-SIDE.
*> USING shape, direction of the high side out (section 2.3 step 4): 0 for a flat shape.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-DIR.
     MOVE 0 TO L-DIR
     EVALUATE L-ORD
         WHEN 2
             MOVE 5 TO L-DIR
         WHEN 3
             MOVE 4 TO L-DIR
         WHEN 4
             MOVE 2 TO L-DIR
         WHEN 5
             MOVE 3 TO L-DIR
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SLOPE-HIGH-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-UPDATE-DIR.
*> USING server, place runs out (section 2.3 step 5): the client returns the state unchanged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-RUNS.
     MOVE L-SERVER TO L-RUNS
     GOBACK.
 END PROGRAM RS3-RAIL-UPDATE-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-REMOVAL.
*> USING moved by a piston, shape, isStraight, update above out, update at the position out, update below out (section 2.3 step 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOVED                BINARY-LONG.
 01 L-ORD                  BINARY-LONG.
 01 L-STRAIGHT             BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-AT                   BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 PROCEDURE DIVISION USING L-MOVED L-ORD L-STRAIGHT L-ABOVE L-AT L-BELOW.
     MOVE 0 TO L-ABOVE L-AT L-BELOW
     IF L-MOVED = 0
         IF L-ORD >= 2 AND L-ORD <= 5
             MOVE 1 TO L-ABOVE
         END-IF
         IF L-STRAIGHT = 1
             MOVE 1 TO L-AT L-BELOW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-REMOVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-SOURCE.
*> USING kind, isSignalSource out (sections 2.4, 5.1): only the detector rail.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-KIND = 4
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-WIRE-CONNECT.
*> USING kind, the direction argument is non-null, shouldRedstoneWireConnectTo out (section 2.4): the default rule.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SOURCE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIR L-RESULT.
     CALL "RS3-RAIL-SOURCE" USING L-KIND WS-SOURCE
     CALL "RS1-WIRE-CONNECT-DEFAULT" USING WS-SOURCE L-DIR L-RESULT
     GOBACK.
 END PROGRAM RS3-RAIL-WIRE-CONNECT.

*> ===== Section 3: plain rail

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HAS-RAIL.
*> USING a rail at the position, at the position above, at the position below, result out (section 3.1 hasRail).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AT                   BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-AT L-ABOVE L-BELOW L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-AT = 1 OR L-ABOVE = 1 OR L-BELOW = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-HAS-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-COUNT-POTENTIAL.
*> USING hasRail of north, south, west, east, countPotentialConnections out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-S L-W L-E L-COUNT.
     COMPUTE L-COUNT = L-N + L-S + L-W + L-E
     GOBACK.
 END PROGRAM RS3-COUNT-POTENTIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PLAIN-REACT.
*> USING the default state of the source block is a signal source, potential connections, acts out, forceUpdate out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ACTS                 BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-COUNT L-ACTS L-FORCE.
     MOVE 0 TO L-ACTS L-FORCE
     IF L-SOURCE = 1 AND L-COUNT = 3
         MOVE 1 TO L-ACTS
     END-IF
     GOBACK.
 END PROGRAM RS3-PLAIN-REACT.

*> ===== Section 4: shape resolution

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GET-RAIL.
*> USING rail at p, at p above, at p below, which out (section 4.1 getRail): 1, 2, 3 in that order, 0 none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AT                   BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-AT L-ABOVE L-BELOW L-WHICH.
     MOVE 0 TO L-WHICH
     EVALUATE TRUE
         WHEN L-AT = 1
             MOVE 1 TO L-WHICH
         WHEN L-ABOVE = 1
             MOVE 2 TO L-WHICH
         WHEN L-BELOW = 1
             MOVE 3 TO L-WHICH
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-GET-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CONNECTS-TO.
*> USING entries in the list, entry 1 x and z, entry 2 x and z, the other rail x and z, result out (section 4.1 connectsTo).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-X1 L-Z1 L-X2 L-Z2 L-OX L-OZ L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-COUNT >= 1 AND L-X1 = L-OX AND L-Z1 = L-OZ
         MOVE 1 TO L-RESULT
     END-IF
     IF L-COUNT >= 2 AND L-X2 = L-OX AND L-Z2 = L-OZ
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-CONNECTS-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CAN-CONNECT-TO.
*> USING connectsTo, entries in the list, result out (section 4.1): already linked, or a free slot.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONNECTS             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CONNECTS L-COUNT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CONNECTS = 0 OR L-COUNT NOT = 2
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-CAN-CONNECT-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SOFT-KEEP.
*> USING the entry's rail exists, it connects back, keep out (section 4.1 removeSoftConnections): kept entries take the rail's real position.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXISTS               BINARY-LONG.
 01 L-BACK                 BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EXISTS L-BACK L-KEEP.
     MOVE 0 TO L-KEEP
     IF L-EXISTS = 1 AND L-BACK = 1
         MOVE 1 TO L-KEEP
     END-IF
     GOBACK.
 END PROGRAM RS3-SOFT-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HAS-NEIGHBOR-RAIL.
*> USING getRail found one, canConnectTo of it, result out, list cleaned out (section 4.1 hasNeighborRail).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXISTS               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-CLEANED              BINARY-LONG.
 PROCEDURE DIVISION USING L-EXISTS L-CAN L-RESULT L-CLEANED.
     MOVE 0 TO L-RESULT L-CLEANED
     IF L-EXISTS = 1
         MOVE 1 TO L-CLEANED
         MOVE L-CAN TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-HAS-NEIGHBOR-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SLOPE-STEP.
*> USING shape in and out, rail at north.above, south.above, east.above, west.above (sections 4.2 step 5, 4.3): a north_south shape takes
*> ascending_north then ascending_south (south wins), an east_west shape ascending_east then ascending_west (west wins).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-AN                   BINARY-LONG.
 01 L-AS                   BINARY-LONG.
 01 L-AE                   BINARY-LONG.
 01 L-AW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-AN L-AS L-AE L-AW.
     EVALUATE L-SHAPE
         WHEN 0
             IF L-AN = 1
                 MOVE 4 TO L-SHAPE
             END-IF
             IF L-AS = 1
                 MOVE 5 TO L-SHAPE
             END-IF
         WHEN 1
             IF L-AE = 1
                 MOVE 2 TO L-SHAPE
             END-IF
             IF L-AW = 1
                 MOVE 3 TO L-SHAPE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SLOPE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PLACE-SHAPE.
*> USING isStraight, powered, oldShape, n, s, w, e (hasNeighborRail of the four sides), rail above the north, south, east, west neighbour,
*> shape out (section 4.2 steps 1 to 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SH                  BINARY-LONG.
 01 WS-NS                  BINARY-LONG.
 01 WS-EW                  BINARY-LONG.
 01 WS-SE                  BINARY-LONG.
 01 WS-SW                  BINARY-LONG.
 01 WS-NE                  BINARY-LONG.
 01 WS-NW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRAIGHT             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-AN                   BINARY-LONG.
 01 L-AS                   BINARY-LONG.
 01 L-AE                   BINARY-LONG.
 01 L-AW                   BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRAIGHT L-POWERED L-OLD L-N L-S L-W L-E L-AN L-AS L-AE L-AW L-SHAPE.
     MOVE -1 TO WS-SH
     MOVE 0 TO WS-NS WS-EW WS-SE WS-SW WS-NE WS-NW
     IF L-N = 1 OR L-S = 1
         MOVE 1 TO WS-NS
     END-IF
     IF L-W = 1 OR L-E = 1
         MOVE 1 TO WS-EW
     END-IF
     IF L-S = 1 AND L-E = 1
         MOVE 1 TO WS-SE
     END-IF
     IF L-S = 1 AND L-W = 1
         MOVE 1 TO WS-SW
     END-IF
     IF L-N = 1 AND L-E = 1
         MOVE 1 TO WS-NE
     END-IF
     IF L-N = 1 AND L-W = 1
         MOVE 1 TO WS-NW
     END-IF
     IF WS-NS = 1 AND WS-EW = 0
         MOVE 0 TO WS-SH
     END-IF
     IF WS-EW = 1 AND WS-NS = 0
         MOVE 1 TO WS-SH
     END-IF
     IF L-STRAIGHT = 0
         EVALUATE TRUE
             WHEN WS-SE = 1 AND L-N = 0 AND L-W = 0
                 MOVE 6 TO WS-SH
             WHEN WS-SW = 1 AND L-N = 0 AND L-E = 0
                 MOVE 7 TO WS-SH
             WHEN WS-NW = 1 AND L-S = 0 AND L-E = 0
                 MOVE 8 TO WS-SH
             WHEN WS-NE = 1 AND L-S = 0 AND L-W = 0
                 MOVE 9 TO WS-SH
         END-EVALUATE
     END-IF
*>   A shape still undecided here has both axes joined or neither (a single axis was settled above), and a corner whose other two sides are free was
*>   settled by the corner rule above, so the last corner of each priority order below cannot be the only one left.
     IF WS-SH = -1
         IF WS-NS = 1 AND WS-EW = 1
             MOVE L-OLD TO WS-SH
         END-IF
         IF L-STRAIGHT = 0 AND L-POWERED = 1
             EVALUATE TRUE
                 WHEN WS-NW = 1
                     MOVE 8 TO WS-SH
                 WHEN WS-NE = 1
                     MOVE 9 TO WS-SH
                 WHEN WS-SW = 1
                     MOVE 7 TO WS-SH
             END-EVALUATE
         END-IF
         IF L-STRAIGHT = 0 AND L-POWERED = 0
             EVALUATE TRUE
                 WHEN WS-SE = 1
                     MOVE 6 TO WS-SH
                 WHEN WS-SW = 1
                     MOVE 7 TO WS-SH
                 WHEN WS-NE = 1
                     MOVE 9 TO WS-SH
             END-EVALUATE
         END-IF
     END-IF
     CALL "RS3-SLOPE-STEP" USING WS-SH L-AN L-AS L-AE L-AW
     IF WS-SH = -1
         MOVE L-OLD TO WS-SH
     END-IF
     MOVE WS-SH TO L-SHAPE
     GOBACK.
 END PROGRAM RS3-PLACE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CONNECT-SHAPE.
*> USING isStraight, hasConnection of the north, south, west, east columns, rail above the north, south, east, west neighbour, shape out
*> (section 4.3): the shape after the link was appended.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SH                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRAIGHT             BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-AN                   BINARY-LONG.
 01 L-AS                   BINARY-LONG.
 01 L-AE                   BINARY-LONG.
 01 L-AW                   BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRAIGHT L-N L-S L-W L-E L-AN L-AS L-AE L-AW L-SHAPE.
     MOVE -1 TO WS-SH
     IF L-N = 1 OR L-S = 1
         MOVE 0 TO WS-SH
     END-IF
     IF L-W = 1 OR L-E = 1
         MOVE 1 TO WS-SH
     END-IF
     IF L-STRAIGHT = 0
         IF L-S = 1 AND L-E = 1 AND L-N = 0 AND L-W = 0
             MOVE 6 TO WS-SH
         END-IF
         IF L-S = 1 AND L-W = 1 AND L-N = 0 AND L-E = 0
             MOVE 7 TO WS-SH
         END-IF
         IF L-N = 1 AND L-W = 1 AND L-S = 0 AND L-E = 0
             MOVE 8 TO WS-SH
         END-IF
         IF L-N = 1 AND L-E = 1 AND L-S = 0 AND L-W = 0
             MOVE 9 TO WS-SH
         END-IF
     END-IF
     CALL "RS3-SLOPE-STEP" USING WS-SH L-AN L-AS L-AE L-AW
     IF WS-SH = -1
         MOVE 0 TO WS-SH
     END-IF
     MOVE WS-SH TO L-SHAPE
     GOBACK.
 END PROGRAM RS3-CONNECT-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PLACE-WRITE.
*> USING forceUpdate, the level's current state is the identical new state, writes out (section 4.2 step 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FORCE                BINARY-LONG.
 01 L-IDENTICAL            BINARY-LONG.
 01 L-WRITES               BINARY-LONG.
 PROCEDURE DIVISION USING L-FORCE L-IDENTICAL L-WRITES.
     MOVE 0 TO L-WRITES
     IF L-FORCE = 1 OR L-IDENTICAL = 0
         MOVE 1 TO L-WRITES
     END-IF
     GOBACK.
 END PROGRAM RS3-PLACE-WRITE.

*> ===== Section 5: powered rail and activator rail

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-POWER-DECISION.
*> USING hasNeighborSignal, found forward, found backward, current powered, shape is a slope, shouldBePowered out, changed out,
*> update below out, update above out (section 5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-BWD                  BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-SLOPE                BINARY-LONG.
 01 L-SHOULD               BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-FWD L-BWD L-CURRENT L-SLOPE L-SHOULD L-CHANGED L-BELOW L-ABOVE.
     MOVE 0 TO L-SHOULD L-CHANGED L-BELOW L-ABOVE
     IF L-SIGNAL = 1 OR L-FWD = 1 OR L-BWD = 1
         MOVE 1 TO L-SHOULD
     END-IF
     IF L-SHOULD NOT = L-CURRENT
         MOVE 1 TO L-CHANGED L-BELOW
         IF L-SLOPE = 1
             MOVE 1 TO L-ABOVE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-POWER-DECISION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SEARCH-STEP.
*> USING shape (0 to 5), forward, dx, dy, dz out, checkBelow out, axis shape out (0 north_south, 1 east_west) (section 5.3 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-FWD L-DX L-DY L-DZ L-BELOW L-AXIS.
     MOVE 0 TO L-DX L-DY L-DZ
     MOVE 1 TO L-BELOW
     EVALUATE L-ORD
         WHEN 0
             MOVE 0 TO L-AXIS
             IF L-FWD = 1
                 MOVE 1 TO L-DZ
             ELSE
                 MOVE -1 TO L-DZ
             END-IF
         WHEN 1
             MOVE 1 TO L-AXIS
             IF L-FWD = 1
                 MOVE -1 TO L-DX
             ELSE
                 MOVE 1 TO L-DX
             END-IF
         WHEN 2
             MOVE 1 TO L-AXIS
             IF L-FWD = 1
                 MOVE -1 TO L-DX
             ELSE
                 MOVE 1 TO L-DX L-DY
                 MOVE 0 TO L-BELOW
             END-IF
         WHEN 3
             MOVE 1 TO L-AXIS
             IF L-FWD = 1
                 MOVE -1 TO L-DX
                 MOVE 1 TO L-DY
                 MOVE 0 TO L-BELOW
             ELSE
                 MOVE 1 TO L-DX
             END-IF
         WHEN 4
             MOVE 0 TO L-AXIS
             IF L-FWD = 1
                 MOVE 1 TO L-DZ
             ELSE
                 MOVE -1 TO L-DZ
                 MOVE 1 TO L-DY
                 MOVE 0 TO L-BELOW
             END-IF
         WHEN 5
             MOVE 0 TO L-AXIS
             IF L-FWD = 1
                 MOVE 1 TO L-DZ L-DY
                 MOVE 0 TO L-BELOW
             ELSE
                 MOVE -1 TO L-DZ
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SEARCH-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SAME-RAIL.
*> USING the block at the position is the caller's block, axis shape (0 north_south, 1 east_west), neighbour shape, neighbour powered,
*> hasNeighborSignal there, result out (section 5.3 isSameRailWithPower): 0 false, 1 true, 2 the search goes on with count + 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-AXIS L-SHAPE L-POWERED L-SIGNAL L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-SAME = 0
             MOVE 0 TO L-RESULT
         WHEN L-AXIS = 1 AND (L-SHAPE = 0 OR L-SHAPE = 4 OR L-SHAPE = 5)
             MOVE 0 TO L-RESULT
         WHEN L-AXIS = 0 AND (L-SHAPE = 1 OR L-SHAPE = 2 OR L-SHAPE = 3)
             MOVE 0 TO L-RESULT
         WHEN L-POWERED = 0
             MOVE 0 TO L-RESULT
         WHEN L-SIGNAL = 1
             MOVE 1 TO L-RESULT
         WHEN OTHER
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SAME-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LINE-POWER.
*> USING rails in the line, index of the rail to decide (1 based), block kind, direct neighbour signal and powered of every rail
*> (three tables of 64), shouldBePowered out (sections 5.2, 5.3): a line of flat rails on the east-west axis, one cell apart.
*> A rail with a direct signal is powered; else a rail up to 8 steps away along a chain of same-kind powered rails with a direct signal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-LIVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 01 L-KDG.
    05 L-KD                BINARY-LONG OCCURS 64 TIMES.
 01 L-DRG.
    05 L-DR                BINARY-LONG OCCURS 64 TIMES.
 01 L-PWG.
    05 L-PW                BINARY-LONG OCCURS 64 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-IDX L-KDG L-DRG L-PWG L-RESULT.
     MOVE L-DR(L-IDX) TO L-RESULT
     PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 2
         MOVE 1 TO WS-LIVE
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8 OR WS-LIVE = 0
             IF WS-DIR = 1
                 COMPUTE WS-Q = L-IDX - WS-K
             ELSE
                 COMPUTE WS-Q = L-IDX + WS-K
             END-IF
             EVALUATE TRUE
                 WHEN WS-Q < 1 OR WS-Q > L-COUNT
                     MOVE 0 TO WS-LIVE
                 WHEN L-KD(WS-Q) NOT = L-KD(L-IDX)
                     MOVE 0 TO WS-LIVE
                 WHEN L-PW(WS-Q) = 0
                     MOVE 0 TO WS-LIVE
                 WHEN L-DR(WS-Q) = 1
                     MOVE 1 TO L-RESULT
                     MOVE 0 TO WS-LIVE
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-LINE-POWER.

*> ===== Section 6: detector rail

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETECTOR-SIGNAL.
*> USING powered, direction, query (0 getSignal, 1 getDirectSignal), signal out (section 6.1): 15 when powered; the direct one only UP (1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-QUERY                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-DIR L-QUERY L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-POWERED = 1 AND (L-QUERY = 0 OR L-DIR = 1)
         MOVE 15 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS3-DETECTOR-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETECTOR-BOX.
*> USING min x, y, z, max x, y, z out in thousandths of a block above the rail's block origin (section 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MINX                 BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MINZ                 BINARY-LONG.
 01 L-MAXX                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-MAXZ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MINX L-MINY L-MINZ L-MAXX L-MAXY L-MAXZ.
     MOVE 200 TO L-MINX L-MINZ
     MOVE 0 TO L-MINY
     MOVE 800 TO L-MAXX L-MAXY L-MAXZ
     GOBACK.
 END PROGRAM RS3-DETECTOR-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETECTOR-QUERY.
*> USING use (1 pressed check, 2 command block cart, 3 container cart), class out (1 AbstractMinecart, 2 MinecartCommandBlock),
*> predicate out (0 always true, 1 the container selector) (section 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USE                  BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-PRED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-USE L-CLASS L-PRED.
     MOVE 1 TO L-CLASS
     MOVE 0 TO L-PRED
     IF L-USE = 2
         MOVE 2 TO L-CLASS
     END-IF
     IF L-USE = 3
         MOVE 1 TO L-PRED
     END-IF
     GOBACK.
 END PROGRAM RS3-DETECTOR-QUERY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CONTAINER-SELECTOR.
*> USING implements Container, alive, result out (section 6.2 CONTAINER_ENTITY_SELECTOR).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONTAINER            BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CONTAINER L-ALIVE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CONTAINER = 1 AND L-ALIVE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-CONTAINER-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETECTOR-TRIGGER.
*> USING trigger (1 entityInside, 2 tick, 3 onPlace), server, powered, runs checkPressed out (section 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-SERVER L-POWERED L-RUNS.
     MOVE 0 TO L-RUNS
     EVALUATE L-KIND
         WHEN 1
             IF L-SERVER = 1 AND L-POWERED = 0
                 MOVE 1 TO L-RUNS
             END-IF
         WHEN 2
             MOVE L-POWERED TO L-RUNS
         WHEN 3
             MOVE 1 TO L-RUNS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DETECTOR-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CHECK-PRESSED.
*> USING the rail can survive, the block is still this block, wasPowered, any AbstractMinecart in the box, then ran out, powered out,
*> changed out (set the state, updatePowerToConnected, neighbours, dirty), tick delay out (20 or 0), comparator update out (section 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVES             BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-WAS                  BINARY-LONG.
 01 L-CART                 BINARY-LONG.
 01 L-RAN                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-OUTPUT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVES L-SAME L-WAS L-CART L-RAN L-POWERED L-CHANGED L-DELAY L-OUTPUT.
     MOVE 0 TO L-RAN L-CHANGED L-DELAY L-OUTPUT
     MOVE L-WAS TO L-POWERED
     IF L-SURVIVES = 1 AND L-SAME = 1
         MOVE 1 TO L-RAN L-OUTPUT
         MOVE L-CART TO L-POWERED
         IF L-CART NOT = L-WAS
             MOVE 1 TO L-CHANGED
         END-IF
         IF L-CART = 1
             MOVE 20 TO L-DELAY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-CHECK-PRESSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETECTOR-ANALOG.
*> USING powered, a command block cart in the box, its success count, a container cart in the box, its fullness signal, signal out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-HAS-CMD              BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-HAS-CONT             BINARY-LONG.
 01 L-FULLNESS             BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-HAS-CMD L-SUCCESS L-HAS-CONT L-FULLNESS L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     EVALUATE TRUE
         WHEN L-POWERED = 0
             MOVE 0 TO L-SIGNAL
         WHEN L-HAS-CMD = 1
             MOVE L-SUCCESS TO L-SIGNAL
         WHEN L-HAS-CONT = 1
             MOVE L-FULLNESS TO L-SIGNAL
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DETECTOR-ANALOG.

*> ===== Section 7: summary of reactions

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PLACED-EFFECT.
*> USING kind, force out (place runs with forceUpdate), own neighborChanged out (straight rails), what runs out (0 nothing, 1 powered
*> calculation, 2 checkPressed) (section 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 01 L-SELF                 BINARY-LONG.
 01 L-WHAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FORCE L-SELF L-WHAT.
     MOVE 1 TO L-FORCE
     MOVE 0 TO L-SELF L-WHAT
     EVALUATE L-KIND
         WHEN 2
             MOVE 1 TO L-SELF L-WHAT
         WHEN 3
             MOVE 1 TO L-SELF L-WHAT
         WHEN 4
             MOVE 1 TO L-SELF
             MOVE 2 TO L-WHAT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-PLACED-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HANDLER-ID.
*> USING event (1 block placed, 2 neighbour update, 3 removed, 4 rotation or mirror), handler out: 1 onPlace/updateState,
*> 2 neighborChanged, 3 affectNeighborsAfterRemoval, 4 rotate/mirror; 0 for another event (section 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-HANDLER              BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-HANDLER.
     MOVE 0 TO L-HANDLER
     IF L-EVENT >= 1 AND L-EVENT <= 4
         MOVE L-EVENT TO L-HANDLER
     END-IF
     GOBACK.
 END PROGRAM RS3-HANDLER-ID.

*> ===== Section 8: minecart hooks that depend on rail shape and power

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-FEATURE-DEFAULT.
*> USING feature flag name, in the default flags out (section 8 introduction): DEFAULT_FLAGS is the vanilla set only.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     IF FUNCTION TRIM(L-NAME) = "vanilla"
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-FEATURE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-USE-EXPERIMENTAL.
*> USING the level's enabled features contain minecart_improvements, experimental movement out (section 8 introduction).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-RESULT.
     MOVE L-FLAG TO L-RESULT
     GOBACK.
 END PROGRAM RS3-USE-EXPERIMENTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-POS-OLD.
*> USING floor y of the cart, the block at y - 1 is in the rails tag, rail y out (section 8.1, old movement).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-RAIL-Y               BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-BELOW L-RAIL-Y.
     COMPUTE L-RAIL-Y = L-Y - L-BELOW
     GOBACK.
 END PROGRAM RS3-RAIL-POS-OLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PROBE-Y.
*> USING the cart's y (a double), floor of the probe height y - 0.1 - 1e-5 out (section 8.1, experimental movement; the 1e-5 is the
*> float 9.999999747378752E-6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PY                  PIC S9(6)V9(18).
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-FLOOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-FLOOR.
     COMPUTE WS-PY = L-Y - 0.1 - 0.000009999999747378752
     COMPUTE L-FLOOR = FUNCTION INTEGER(WS-PY)
     GOBACK.
 END PROGRAM RS3-PROBE-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-POS-EXP.
*> USING the cart's floor y, floor of the probe height, the probe cell is in the rails tag, rail y out (section 8.1, experimental).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-PROBE                BINARY-LONG.
 01 L-TAGGED               BINARY-LONG.
 01 L-RAIL-Y               BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-PROBE L-TAGGED L-RAIL-Y.
     MOVE L-Y TO L-RAIL-Y
     IF L-TAGGED = 1
         MOVE L-PROBE TO L-RAIL-Y
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-POS-EXP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ON-TRACK.
*> USING the position is a rail, on the track out (section 8.1): a rail runs the track step, else comeOffTrack.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAIL                 BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RAIL L-ON.
     MOVE L-RAIL TO L-ON
     GOBACK.
 END PROGRAM RS3-ON-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACTIVATOR-CALL.
*> USING kind, experimental movement, activateMinecart called out (the state is exactly the activator rail), before the track step out
*> (section 8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EXPERIMENTAL         BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-BEFORE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-EXPERIMENTAL L-CALLED L-BEFORE.
     MOVE 0 TO L-CALLED
     MOVE L-EXPERIMENTAL TO L-BEFORE
     IF L-KIND = 3
         MOVE 1 TO L-CALLED
     END-IF
     GOBACK.
 END PROGRAM RS3-ACTIVATOR-CALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACT-KIND.
*> USING cart class (1 rideable, 2 TNT, 3 hopper, 4 command block, 5 chest, 6 furnace, 7 spawner), overriding handler out (0 none) (8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-HANDLER              BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-HANDLER.
     MOVE 0 TO L-HANDLER
     IF L-CLASS >= 1 AND L-CLASS <= 4
         MOVE L-CLASS TO L-HANDLER
     END-IF
     GOBACK.
 END PROGRAM RS3-ACT-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACT-RIDEABLE.
*> USING powered, passengers, hurt time, eject out, hurt out, new hurt time out, damage in tenths out (section 8.2 rideable minecart).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-PASSENGERS           BINARY-LONG.
 01 L-HURT-TIME            BINARY-LONG.
 01 L-EJECT                BINARY-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-NEW-TIME             BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-PASSENGERS L-HURT-TIME L-EJECT L-HURT L-NEW-TIME L-DAMAGE.
     MOVE 0 TO L-EJECT L-HURT L-DAMAGE
     MOVE L-HURT-TIME TO L-NEW-TIME
     IF L-POWERED = 1
         IF L-PASSENGERS > 0
             MOVE 1 TO L-EJECT
         END-IF
         IF L-HURT-TIME = 0
             MOVE 1 TO L-HURT
             MOVE 10 TO L-NEW-TIME
             MOVE 500 TO L-DAMAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-ACT-RIDEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PRIME-FUSE.
*> USING server level, tnt_explodes, source non-null, ignition source already set, silent, then ran out, fuse out (80, else 0),
*> ignition source set out, entity event 70 out, TNT_PRIMED sound out (section 8.2 primeFuse, in order).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-EXPLODES             BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-IGNITION             BINARY-LONG.
 01 L-SILENT               BINARY-LONG.
 01 L-RAN                  BINARY-LONG.
 01 L-FUSE                 BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-EXPLODES L-SOURCE L-IGNITION L-SILENT L-RAN L-FUSE L-SET L-EVENT L-SOUND.
     MOVE 0 TO L-RAN L-FUSE L-SET L-EVENT L-SOUND
     IF L-SERVER = 0 OR L-EXPLODES = 1
         MOVE 1 TO L-RAN
         MOVE 80 TO L-FUSE
         MOVE 1 TO L-EVENT
         IF L-SERVER = 1 AND L-SOURCE = 1 AND L-IGNITION = 0
             MOVE 1 TO L-SET
         END-IF
         IF L-SILENT = 0
             MOVE 1 TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-PRIME-FUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACT-TNT.
*> USING powered, fuse, tnt_explodes, primeFuse called out, fuse out (section 8.2 TNT minecart; the level is a server level).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAN                 BINARY-LONG.
 01 WS-FUSE                BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-SOUND               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOSOURCE            BINARY-LONG VALUE 0.
 01 WS-NOIGNITION          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-FUSE-IN              BINARY-LONG.
 01 L-EXPLODES             BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-FUSE-OUT             BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-FUSE-IN L-EXPLODES L-CALLED L-FUSE-OUT.
     MOVE 0 TO L-CALLED
     MOVE L-FUSE-IN TO L-FUSE-OUT
     IF L-POWERED = 1 AND L-FUSE-IN < 0
         MOVE 1 TO L-CALLED
         CALL "RS3-PRIME-FUSE" USING WS-ONE L-EXPLODES WS-NOSOURCE WS-NOIGNITION WS-ZERO WS-RAN WS-FUSE WS-SET WS-EVENT WS-SOUND
         IF WS-RAN = 1
             MOVE WS-FUSE TO L-FUSE-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-ACT-TNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACT-HOPPER.
*> USING powered, enabled, setter called out, enabled out (section 8.2 hopper minecart): enabled = not powered, set only on a change.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-ENABLED L-CALLED L-NEW.
     COMPUTE L-NEW = 1 - L-POWERED
     MOVE 1 TO L-CALLED
     IF L-NEW = L-ENABLED
         MOVE 0 TO L-CALLED
     END-IF
     GOBACK.
 END PROGRAM RS3-ACT-HOPPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ACT-COMMAND.
*> USING powered, tickCount, lastActivated, ran out, lastActivated out (section 8.2 command block minecart): at least 4 ticks apart.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-RAN                  BINARY-LONG.
 01 L-NEW-LAST             BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-TICK L-LAST L-RAN L-NEW-LAST.
     MOVE 0 TO L-RAN
     MOVE L-LAST TO L-NEW-LAST
     IF L-POWERED = 1 AND L-TICK - L-LAST >= 4
         MOVE 1 TO L-RAN
         MOVE L-TICK TO L-NEW-LAST
     END-IF
     GOBACK.
 END PROGRAM RS3-ACT-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EXIT.
*> USING shape, which exit (1 first, 2 second), x, y, z out (section 8.5): vectors from the block centre, y -1 is the low end of a slope.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB                 PIC X(60) VALUE "110112011211001211011201110102100112112211112011110011110211".
 01 WS-P                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-I L-X L-Y L-Z.
     COMPUTE WS-P = L-ORD * 6 + (L-I - 1) * 3 + 1
     MOVE WS-TAB(WS-P:1) TO WS-D
     COMPUTE L-X = WS-D - 1
     ADD 1 TO WS-P
     MOVE WS-TAB(WS-P:1) TO WS-D
     COMPUTE L-Y = WS-D - 1
     ADD 1 TO WS-P
     MOVE WS-TAB(WS-P:1) TO WS-D
     COMPUTE L-Z = WS-D - 1
     GOBACK.
 END PROGRAM RS3-EXIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-BEHAVIOR.
*> USING kind, slope pull out, brake and boost out (powered_rail only), activator call out (sections 8.3, 8.4; the slope pull is the same
*> for every rail, 44 section 4.4.1 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-PULL                 BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-CALL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-PULL L-POWER L-CALL.
     MOVE 1 TO L-PULL
     MOVE 0 TO L-POWER L-CALL
     IF L-KIND = 2
         MOVE 1 TO L-POWER
     END-IF
     IF L-KIND = 3
         MOVE 1 TO L-CALL
     END-IF
     GOBACK.
 END PROGRAM RS3-RAIL-BEHAVIOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SLOPE-PULL.
*> USING shape, in water, added x, added z, base y raised out (section 8.3 step 1; nanoblocks per tick).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-RAISED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-WATER L-DX L-DZ L-RAISED.
     MOVE 7812500 TO WS-D
     IF L-WATER = 1
         COMPUTE WS-D = WS-D * 0.2
     END-IF
     MOVE 0 TO L-DX L-DZ L-RAISED
     EVALUATE L-ORD
         WHEN 2
             COMPUTE L-DX = 0 - WS-D
             MOVE 1 TO L-RAISED
         WHEN 3
             MOVE WS-D TO L-DX
             MOVE 1 TO L-RAISED
         WHEN 4
             MOVE WS-D TO L-DZ
             MOVE 1 TO L-RAISED
         WHEN 5
             COMPUTE L-DZ = 0 - WS-D
             MOVE 1 TO L-RAISED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SLOPE-PULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ALIGN.
*> USING shape, vx, vz, vx out, vz out (section 8.3 step 2): the horizontal velocity along the exit pair, sign kept, magnitude min(2.0, speed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 01 WS-LEN                 PIC S9(4)V9(18).
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-VX L-VZ L-OX L-OZ.
     CALL "RS3-EXIT" USING L-ORD WS-ONE WS-X1 WS-Y1 WS-Z1
     CALL "RS3-EXIT" USING L-ORD WS-TWO WS-X2 WS-Y2 WS-Z2
     COMPUTE WS-DX = WS-X2 - WS-X1
     COMPUTE WS-DZ = WS-Z2 - WS-Z1
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF L-VX * WS-DX + L-VZ * WS-DZ < 0
         COMPUTE WS-DX = 0 - WS-DX
         COMPUTE WS-DZ = 0 - WS-DZ
     END-IF
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     IF WS-H > 2000000000
         MOVE 2000000000 TO WS-H
     END-IF
     COMPUTE L-OX ROUNDED = WS-H * WS-DX / WS-LEN
     COMPUTE L-OZ ROUNDED = WS-H * WS-DZ / WS-LEN
     GOBACK.
 END PROGRAM RS3-ALIGN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-NUDGE.
*> USING the first passenger is a player, it is a server player (only then it has an intent), intent x and z in thousandths, horizontal
*> speed in nanoblocks, brake flag, added x out, added z out, brake flag out (section 8.3 step 3): the RAW intent times 0.001 is added
*> when the intent is not zero and the speed squared is below 0.01 (speed below 0.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-SERVER-PLAYER        BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IZ                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BRAKE                BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-BRAKE-OUT            BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-SERVER-PLAYER L-IX L-IZ L-H L-BRAKE L-AX L-AZ L-BRAKE-OUT.
     MOVE 0 TO L-AX L-AZ
     MOVE L-BRAKE TO L-BRAKE-OUT
     IF L-PLAYER = 1 AND L-SERVER-PLAYER = 1 AND (L-IX NOT = 0 OR L-IZ NOT = 0) AND L-H < 100000000
         COMPUTE L-AX = L-IX * 1000
         COMPUTE L-AZ = L-IZ * 1000
         MOVE 0 TO L-BRAKE-OUT
     END-IF
     GOBACK.
 END PROGRAM RS3-NUDGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BRAKE.
*> USING brake flag, vx, vz, vx out, vz out (section 8.3 step 4): speed below 0.03 gives zero, else x and z halved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-BRAKE                BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BRAKE L-VX L-VZ L-OX L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     IF L-BRAKE = 1 AND WS-H < 30000000
         MOVE 0 TO L-OX L-OZ
     END-IF
     IF L-BRAKE = 1 AND WS-H >= 30000000
         COMPUTE L-OX = L-VX / 2
         COMPUTE L-OZ = L-VZ / 2
     END-IF
     GOBACK.
 END PROGRAM RS3-BRAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-MOVE-CLAMP.
*> USING vx, vz, a passenger, in water, x and z of the move out (section 8.3 step 5): times 0.75 with a passenger, clamped to 0.4 (0.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VX L-VZ L-PASSENGER L-WATER L-OX L-OZ.
     MOVE 400000000 TO WS-M
     IF L-WATER = 1
         MOVE 200000000 TO WS-M
     END-IF
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     IF L-PASSENGER = 1
         COMPUTE L-OX = L-VX * 0.75
         COMPUTE L-OZ = L-VZ * 0.75
     END-IF
     IF L-OX > WS-M
         MOVE WS-M TO L-OX
     END-IF
     IF L-OX < 0 - WS-M
         COMPUTE L-OX = 0 - WS-M
     END-IF
     IF L-OZ > WS-M
         MOVE WS-M TO L-OZ
     END-IF
     IF L-OZ < 0 - WS-M
         COMPUTE L-OZ = 0 - WS-M
     END-IF
     GOBACK.
 END PROGRAM RS3-MOVE-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SLOWDOWN.
*> USING movement (0 old, 1 experimental), passenger, in water, vx, vy, vz, then vx, vy, vz out (section 8.3 step 5a): (f, 0, f) with
*> f 0.997 with a passenger, else 0.96 old and 0.975 experimental, then the float 0.95 (0.949999988079071) in water.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOVEMENT             BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-MOVEMENT L-PASSENGER L-WATER L-VX L-VY L-VZ L-OX L-OY L-OZ.
     MOVE 0 TO L-OY
     EVALUATE TRUE
         WHEN L-PASSENGER = 1
             COMPUTE L-OX = L-VX * 0.997
             COMPUTE L-OZ = L-VZ * 0.997
         WHEN L-MOVEMENT = 0
             COMPUTE L-OX = L-VX * 0.96
             COMPUTE L-OZ = L-VZ * 0.96
         WHEN OTHER
             COMPUTE L-OX = L-VX * 0.975
             COMPUTE L-OZ = L-VZ * 0.975
     END-EVALUATE
     IF L-WATER = 1
         COMPUTE L-OX = L-OX * 0.949999988079071
         COMPUTE L-OZ = L-OZ * 0.949999988079071
     END-IF
     GOBACK.
 END PROGRAM RS3-SLOWDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EXIT-DROP.
*> USING shape, floor x - railX, floor z - railZ, y change out (section 8.3 step 5b): the first exit, else only if that did not apply
*> the second: a non-zero exit y with the cart in the block just beyond that end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-RX L-RZ L-DY.
     CALL "RS3-EXIT" USING L-ORD WS-ONE WS-X1 WS-Y1 WS-Z1
     CALL "RS3-EXIT" USING L-ORD WS-TWO WS-X2 WS-Y2 WS-Z2
     MOVE 0 TO L-DY
     EVALUATE TRUE
         WHEN WS-Y1 NOT = 0 AND L-RX = WS-X1 AND L-RZ = WS-Z1
             MOVE WS-Y1 TO L-DY
         WHEN WS-Y2 NOT = 0 AND L-RX = WS-X2 AND L-RZ = WS-Z2
             MOVE WS-Y2 TO L-DY
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-EXIT-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HEIGHT-CORR.
*> USING both rail points exist, p0.y and p1.y in microblocks, vx, vz in nanoblocks, vx out, vz out (section 8.3 step 5c):
*> dy = (p0.y - p1.y) * 0.05; with h > 0 x and z are multiplied by (h + dy) / h.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 01 WS-DY                  PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-BOTH                 BINARY-LONG.
 01 L-P0                   BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BOTH L-P0 L-P1 L-VX L-VZ L-OX L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     COMPUTE WS-DY = (L-P0 - L-P1) * 50
     IF L-BOTH = 1 AND WS-H > 0
         COMPUTE L-OX = L-VX * (WS-H + WS-DY) / WS-H
         COMPUTE L-OZ = L-VZ * (WS-H + WS-DY) / WS-H
     END-IF
     GOBACK.
 END PROGRAM RS3-HEIGHT-CORR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-REDIRECT.
*> USING floor x - railX, floor z - railZ, vx, vz, vx out, vz out (section 8.3 step 5d): after a step into another block the horizontal
*> speed h is redirected along the step: (h * dx, h * dz).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-RX                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RX L-RZ L-VX L-VZ L-OX L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     IF L-RX NOT = 0 OR L-RZ NOT = 0
         COMPUTE L-OX ROUNDED = WS-H * L-RX
         COMPUTE L-OZ ROUNDED = WS-H * L-RZ
     END-IF
     GOBACK.
 END PROGRAM RS3-REDIRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RAIL-SNAP.
*> USING shape, x and z inside the block in thousandths, new x and z out (section 8.3 step 5e, 44 section 4.4.1 step 8): the cart is
*> projected on the line through the half-exit points p1 and p2; t is z for a line along z, x for a line along x, else the dot product
*> form times 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-P1X                 BINARY-LONG.
 01 WS-P1Z                 BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-T                   PIC S9(12)V9(12).
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-PX L-PZ L-OX L-OZ.
     CALL "RS3-EXIT" USING L-ORD WS-ONE WS-X1 WS-Y1 WS-Z1
     CALL "RS3-EXIT" USING L-ORD WS-TWO WS-X2 WS-Y2 WS-Z2
     COMPUTE WS-P1X = 500 + 500 * WS-X1
     COMPUTE WS-P1Z = 500 + 500 * WS-Z1
     COMPUTE WS-EX = 500 * WS-X2 - 500 * WS-X1
     COMPUTE WS-EZ = 500 * WS-Z2 - 500 * WS-Z1
     EVALUATE TRUE
         WHEN WS-EX = 0
             MOVE L-PZ TO WS-T
         WHEN WS-EZ = 0
             MOVE L-PX TO WS-T
         WHEN OTHER
             COMPUTE WS-T = ((L-PX - WS-P1X) * WS-EX + (L-PZ - WS-P1Z) * WS-EZ) * 2 / 1000
     END-EVALUATE
     COMPUTE L-OX ROUNDED = WS-P1X + WS-EX * WS-T / 1000
     COMPUTE L-OZ ROUNDED = WS-P1Z + WS-EZ * WS-T / 1000
     GOBACK.
 END PROGRAM RS3-RAIL-SNAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BOOST.
*> USING powered (a powered powered_rail), shape, vx, vz in nanoblocks, west, east, north, south neighbour conducting, vx out, vz out
*> (section 8.3 step 6): h > 0.01 adds 0.06 along the travel direction; else the 0.02 push away from a conducting wall.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-ORD                  BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-ORD L-VX L-VZ L-W L-E L-N L-S L-OX L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     IF L-POWERED = 1
         IF WS-H > 10000000
             COMPUTE L-OX ROUNDED = L-VX + 60000000 * L-VX / WS-H
             COMPUTE L-OZ ROUNDED = L-VZ + 60000000 * L-VZ / WS-H
         ELSE
             EVALUATE TRUE
                 WHEN L-ORD = 1 AND L-W = 1
                     MOVE 20000000 TO L-OX
                 WHEN L-ORD = 1 AND L-E = 1
                     MOVE -20000000 TO L-OX
                 WHEN L-ORD = 0 AND L-N = 1
                     MOVE 20000000 TO L-OZ
                 WHEN L-ORD = 0 AND L-S = 1
                     MOVE -20000000 TO L-OZ
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-BOOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-OFF-TRACK.
*> USING vx, vy, vz, max speed (all nanoblocks), on the ground before the move, on the ground after it, vx, vy, vz out
*> (section 8.3 step 7, comeOffTrack): x and z clamped, the ground halves the velocity, no ground after the move times the air drag
*> 0.95 (0.949999988079071).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-AFTER                BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-MAX L-GROUND L-AFTER L-OX L-OY L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VY TO L-OY
     MOVE L-VZ TO L-OZ
     IF L-OX > L-MAX
         MOVE L-MAX TO L-OX
     END-IF
     IF L-OX < 0 - L-MAX
         COMPUTE L-OX = 0 - L-MAX
     END-IF
     IF L-OZ > L-MAX
         MOVE L-MAX TO L-OZ
     END-IF
     IF L-OZ < 0 - L-MAX
         COMPUTE L-OZ = 0 - L-MAX
     END-IF
     IF L-GROUND = 1
         COMPUTE L-OX = L-OX * 0.5
         COMPUTE L-OY = L-OY * 0.5
         COMPUTE L-OZ = L-OZ * 0.5
     END-IF
     IF L-AFTER = 0
         COMPUTE L-OX = L-OX * 0.949999988079071
         COMPUTE L-OY = L-OY * 0.949999988079071
         COMPUTE L-OZ = L-OZ * 0.949999988079071
     END-IF
     GOBACK.
 END PROGRAM RS3-OFF-TRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRACK-LOOP.
*> USING first iteration, movementLeft in nanoblocks, alive, continues out (section 8.6): first, or movementLeft above 1e-5, and alive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-CONTINUES            BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-LEFT L-ALIVE L-CONTINUES.
     MOVE 0 TO L-CONTINUES
     IF L-ALIVE = 1 AND (L-FIRST = 1 OR L-LEFT > 10000)
         MOVE 1 TO L-CONTINUES
     END-IF
     GOBACK.
 END PROGRAM RS3-TRACK-LOOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-MOVEMENT-LEFT.
*> USING first iteration, movementLeft, new horizontal length, old horizontal length, movementLeft out (section 8.6 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-LEFT L-NEW L-OLD L-RESULT.
     IF L-FIRST = 1
         MOVE L-NEW TO L-RESULT
     ELSE
         COMPUTE L-RESULT = L-LEFT + (L-NEW - L-OLD)
     END-IF
     GOBACK.
 END PROGRAM RS3-MOVEMENT-LEFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRANSFORM-RUNS.
*> USING transform order (1 slope pull, 2 player nudge, 3 halt, 4 natural slowdown, 5 boost), first iteration, hasGainedSlopeSpeed,
*> hasHalted, hasBoosted, runs out (section 8.6 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORDER                BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-GAINED               BINARY-LONG.
 01 L-HALTED               BINARY-LONG.
 01 L-BOOSTED              BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ORDER L-FIRST L-GAINED L-HALTED L-BOOSTED L-RUNS.
     MOVE 0 TO L-RUNS
     EVALUATE L-ORDER
         WHEN 1
             COMPUTE L-RUNS = 1 - L-GAINED
         WHEN 2
             MOVE L-FIRST TO L-RUNS
         WHEN 3
             COMPUTE L-RUNS = 1 - L-HALTED
         WHEN 4
             MOVE L-FIRST TO L-RUNS
         WHEN 5
             COMPUTE L-RUNS = 1 - L-BOOSTED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TRANSFORM-RUNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRANSFORM-FLAG.
*> USING transform order, horizontal speed squared changed, flag set out (1 hasGainedSlopeSpeed, 2 hasHalted, 3 hasBoosted, 0 none)
*> (section 8.6 table): the slope pull does not set hasHalted.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORDER                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ORDER L-CHANGED L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-CHANGED = 1
         EVALUATE L-ORDER
             WHEN 1
                 MOVE 1 TO L-FLAG
             WHEN 2
                 MOVE 2 TO L-FLAG
             WHEN 3
                 MOVE 2 TO L-FLAG
             WHEN 5
                 MOVE 3 TO L-FLAG
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS3-TRANSFORM-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EXP-SLOPE-PULL.
*> USING shape, in water, horizontal speed in nanoblocks, added x, added z out (section 8.6): d = max(0.0078125, speed * 0.02), times 0.2
*> in water; direction as in 8.3 step 1, other shapes unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-WATER L-H L-DX L-DZ.
     MOVE 7812500 TO WS-D
     IF L-H * 0.02 > WS-D
         COMPUTE WS-D = L-H * 0.02
     END-IF
     IF L-WATER = 1
         COMPUTE WS-D = WS-D * 0.2
     END-IF
     MOVE 0 TO L-DX L-DZ
     EVALUATE L-ORD
         WHEN 2
             COMPUTE L-DX = 0 - WS-D
         WHEN 3
             COMPUTE L-DX = WS-D
         WHEN 4
             COMPUTE L-DZ = WS-D
         WHEN 5
             COMPUTE L-DZ = 0 - WS-D
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-EXP-SLOPE-PULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EXP-NUDGE.
*> USING the first passenger is a server player, intent x and z, horizontal speed in nanoblocks, added x, added z out (section 8.6):
*> 0.001 times the unit vector of the intent, only below speed squared 0.01 and for an intent of non-zero length.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 PIC S9(8)V9(12).
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-IX                   BINARY-LONG.
 01 L-IZ                   BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-IX L-IZ L-H L-AX L-AZ.
     MOVE 0 TO L-AX L-AZ
     IF L-PLAYER = 1 AND (L-IX NOT = 0 OR L-IZ NOT = 0) AND L-H < 100000000
         COMPUTE WS-LEN = FUNCTION SQRT(L-IX * L-IX + L-IZ * L-IZ)
         COMPUTE L-AX ROUNDED = 1000000 * L-IX / WS-LEN
         COMPUTE L-AZ ROUNDED = 1000000 * L-IZ / WS-LEN
     END-IF
     GOBACK.
 END PROGRAM RS3-EXP-NUDGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HALT.
*> USING the block is an unpowered powered_rail, vx, vy, vz in nanoblocks, vx, vy, vz out (section 8.6): speed below 0.03 gives zero,
*> else all components halved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-SQ                  BINARY-DOUBLE.
 01 WS-H                   PIC S9(12)V9(9).
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-VX L-VY L-VZ L-OX L-OY L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VY TO L-OY
     MOVE L-VZ TO L-OZ
     MOVE L-VX TO WS-X
     MOVE L-VZ TO WS-Z
     COMPUTE WS-SQ = WS-X * WS-X + WS-Z * WS-Z
     COMPUTE WS-H = FUNCTION SQRT(WS-SQ)
     IF L-FLAG = 1 AND WS-H < 30000000
         MOVE 0 TO L-OX L-OY L-OZ
     END-IF
     IF L-FLAG = 1 AND WS-H >= 30000000
         COMPUTE L-OX = L-VX / 2
         COMPUTE L-OY = L-VY / 2
         COMPUTE L-OZ = L-VZ / 2
     END-IF
     GOBACK.
 END PROGRAM RS3-HALT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-MAX-SPEED.
*> USING the game rule max_minecart_speed, in water, speed out in microblocks per tick (section 8.6): rule * (0.5 in water, else 1.0) / 20.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-WATER L-SPEED.
     COMPUTE L-SPEED = L-RULE * 50000
     IF L-WATER = 1
         COMPUTE L-SPEED = L-RULE * 25000
     END-IF
     GOBACK.
 END PROGRAM RS3-MAX-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EXP-BOOST.
*> USING powered (a powered powered_rail), shape, speed, vx, vz in nanoblocks, west, east, north, south neighbour conducting, vx out, vz out
*> (section 8.6): speed above 0.01 gives speed + 0.06 along the same direction; else getRedstoneDirection gives a unit vector (east_west west
*> (+1,0,0) else east (-1,0,0); north_south north (0,0,+1) else south (0,0,-1)) and the velocity becomes it times (speed + 0.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-ORD                  BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-ORD L-SPEED L-VX L-VZ L-W L-E L-N L-S L-OX L-OZ.
     MOVE L-VX TO L-OX
     MOVE L-VZ TO L-OZ
     MOVE 0 TO WS-DX WS-DZ
     IF L-POWERED = 1
         IF L-SPEED > 10000000
             COMPUTE L-OX ROUNDED = L-VX * (L-SPEED + 60000000) / L-SPEED
             COMPUTE L-OZ ROUNDED = L-VZ * (L-SPEED + 60000000) / L-SPEED
         ELSE
             EVALUATE TRUE
                 WHEN L-ORD = 1 AND L-W = 1
                     MOVE 1 TO WS-DX
                 WHEN L-ORD = 1 AND L-E = 1
                     MOVE -1 TO WS-DX
                 WHEN L-ORD = 0 AND L-N = 1
                     MOVE 1 TO WS-DZ
                 WHEN L-ORD = 0 AND L-S = 1
                     MOVE -1 TO WS-DZ
             END-EVALUATE
             IF WS-DX NOT = 0 OR WS-DZ NOT = 0
                 COMPUTE L-OX = WS-DX * (L-SPEED + 200000000)
                 COMPUTE L-OZ = WS-DZ * (L-SPEED + 200000000)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-EXP-BOOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEP-CONST.
*> USING minimum movement, minimum horizontal velocity, the lift (0.1), the nudge, the V rest speed squared limit (0.005, nanoblocks
*> squared) out (section 8.6 stepAlongTrack constants).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOVE                 BINARY-LONG.
 01 L-VEL                  BINARY-LONG.
 01 L-LIFT                 BINARY-LONG.
 01 L-NUDGE                BINARY-LONG.
 01 L-REST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MOVE L-VEL L-LIFT L-NUDGE L-REST.
     MOVE 10000 TO L-MOVE L-VEL L-NUDGE
     MOVE 100000000 TO L-LIFT
     MOVE 5000000 TO L-REST
     GOBACK.
 END PROGRAM RS3-STEP-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEP-ZERO.
*> USING movementLeft, horizontal velocity (nanoblocks), returns 0 and zeroes the velocity out (section 8.6 stepAlongTrack).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-ZERO                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-H L-ZERO.
     MOVE 0 TO L-ZERO
     IF L-LEFT < 10000 OR L-H < 10000
         MOVE 1 TO L-ZERO
     END-IF
     GOBACK.
 END PROGRAM RS3-STEP-ZERO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEP-TARGET.
*> USING shape, vx, vz, target out (1 first exit, 2 second) (section 8.6 stepAlongTrack): the half exit with the larger dot product.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-D1                  BINARY-DOUBLE.
 01 WS-D2                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-VX L-VZ L-TARGET.
     CALL "RS3-EXIT" USING L-ORD WS-ONE WS-X1 WS-Y1 WS-Z1
     CALL "RS3-EXIT" USING L-ORD WS-TWO WS-X2 WS-Y2 WS-Z2
     COMPUTE WS-D1 = WS-X1 * L-VX + WS-Z1 * L-VZ
     COMPUTE WS-D2 = WS-X2 * L-VX + WS-Z2 * L-VZ
     MOVE 1 TO L-TARGET
     IF WS-D2 > WS-D1
         MOVE 2 TO L-TARGET
     END-IF
     GOBACK.
 END PROGRAM RS3-STEP-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEP-RAISE.
*> USING the cart is descending, the target is raised 1 block out (section 8.6 stepAlongTrack): unless descending.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DESCENDING           BINARY-LONG.
 01 L-RAISE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DESCENDING L-RAISE.
     COMPUTE L-RAISE = 1 - L-DESCENDING
     GOBACK.
 END PROGRAM RS3-STEP-RAISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEP-V-REST.
*> USING speed squared (nanoblocks squared), a slope under the cart, descending into the next, not descending from it, stopped out
*> (section 8.6 stepAlongTrack): a cart at rest at the bottom of a V.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SQ                   BINARY-LONG.
 01 L-SLOPE                BINARY-LONG.
 01 L-INTO                 BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-STOPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SQ L-SLOPE L-INTO L-FROM L-STOPPED.
     MOVE 0 TO L-STOPPED
     IF L-SQ < 5000000 AND L-SLOPE = 1 AND L-INTO = 1 AND L-FROM = 1
         MOVE 1 TO L-STOPPED
     END-IF
     GOBACK.
 END PROGRAM RS3-STEP-V-REST.
