*> Weathering copper (docs/protocol/29b part 5, sections 4 to 6) as programs of plain numbers (GC5- prefix): the oxidation engine (4), the ladder, the 15 families and the
*> block id table (5) and the per-class hooks (6). Helpers like those of growth-29b-5.cob: nothing here is wired into the block-update hooks. Weather states are numbered
*> 0 unaffected, 1 exposed, 2 weathered, 3 oxidized; the 8 blocks of a family 0 to 3 (weathering) and 4 to 7 (waxed).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-CONST.
*> USING SCAN_DISTANCE, the random tick gate x 1e8 (BINARY-LONG out) (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-GATE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-GATE.
     MOVE 4 TO L-DISTANCE
     MOVE 5688889 TO L-GATE
     GOBACK.
 END PROGRAM GC5-OX-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-MODIFIER.
*> USING the weather state (BINARY-LONG), the chance modifier x 1000 out (4.1, WeatheringCopper.getChanceModifier): 0.75 when unaffected, else 1.0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-MODIFIER             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-MODIFIER.
     MOVE 1000 TO L-MODIFIER
     IF L-STATE = 0
         MOVE 750 TO L-MODIFIER
     END-IF
     GOBACK.
 END PROGRAM GC5-OX-MODIFIER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-GATE.
*> USING the draw nextFloat() (FLOAT-LONG), passes, draws made out (4.1 step 1): the draw must be below 0.05688889; exactly one draw is consumed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GATE                FLOAT-LONG VALUE 0.05688889.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PASSES               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PASSES L-DRAWS.
     MOVE 0 TO L-PASSES
     MOVE 1 TO L-DRAWS
     IF L-DRAW < WS-GATE
         MOVE 1 TO L-PASSES
     END-IF
     GOBACK.
 END PROGRAM GC5-OX-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-REGION.
*> USING (BINARY-LONG out): the number of offsets with |dx| + |dy| + |dz| <= 4 including the centre, the number examined (without the centre), then the offsets at depth 0 to 4
*> (4.2 step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DEPTHS.
    05 WS-DEPTH            BINARY-LONG OCCURS 5 TIMES.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-EXAMINED             BINARY-LONG.
 01 L-D0                   BINARY-LONG.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-EXAMINED L-D0 L-D1 L-D2 L-D3 L-D4.
     MOVE 0 TO L-TOTAL
     INITIALIZE WS-DEPTHS
     PERFORM VARYING WS-X FROM -4 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM -4 BY 1 UNTIL WS-Y > 4
             PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
                 COMPUTE WS-D = FUNCTION ABS(WS-X) + FUNCTION ABS(WS-Y) + FUNCTION ABS(WS-Z)
                 IF WS-D <= 4
                     ADD 1 TO L-TOTAL
                     ADD 1 TO WS-DEPTH(WS-D + 1)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE L-EXAMINED = L-TOTAL - 1
     MOVE WS-DEPTH(1) TO L-D0
     MOVE WS-DEPTH(2) TO L-D1
     MOVE WS-DEPTH(3) TO L-D2
     MOVE WS-DEPTH(4) TO L-D3
     MOVE WS-DEPTH(5) TO L-D4
     GOBACK.
 END PROGRAM GC5-OX-REGION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-SCAN.
*> USING the block's weather state, the number of scanned cells, their weather states (BINARY-LONG x 16; -1 for a cell that is not a weathering copper block: waxed, other),
*> aborted, H (older), S (same) out (4.2 steps 2 and 3): a younger neighbour aborts the scan at once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 16 TIMES.
 01 L-ABORTED              BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-N L-CELLS L-ABORTED L-H L-S.
     MOVE 0 TO L-ABORTED L-H L-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-ABORTED = 1
         EVALUATE TRUE
             WHEN L-CELL(WS-I) < 0
                 CONTINUE
             WHEN L-CELL(WS-I) < L-STATE
                 MOVE 1 TO L-ABORTED
             WHEN L-CELL(WS-I) > L-STATE
                 ADD 1 TO L-H
             WHEN OTHER
                 ADD 1 TO L-S
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-OX-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-PROB.
*> USING H, S, the weather state (BINARY-LONG), p x 1e6, p (FLOAT-LONG) out (4.2 step 4): f = (H + 1) / (H + S + 1) in single precision, p = f x f x modifier.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-SHORT.
 01 WS-P                   FLOAT-SHORT.
 01 WS-MOD                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MICRO                BINARY-LONG.
 01 L-P                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-H L-S L-STATE L-MICRO L-P.
     MOVE 1.0 TO WS-MOD
     IF L-STATE = 0
         MOVE 0.75 TO WS-MOD
     END-IF
     COMPUTE WS-F = (L-H + 1) / (L-H + L-S + 1)
     COMPUTE WS-P = WS-F * WS-F
     COMPUTE WS-P = WS-P * WS-MOD
     MOVE WS-P TO L-P
     COMPUTE L-MICRO ROUNDED = L-P * 1000000
     GOBACK.
 END PROGRAM GC5-OX-PROB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-RATE.
*> USING H, S, the weather state (BINARY-LONG), the chance per random tick x 1e6, the expected wait in random ticks x 10 out (4.2): 0.05688889 x p.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MICRO               BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-WAIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-S L-STATE L-CHANCE L-WAIT.
     CALL "GC5-OX-PROB" USING L-H L-S L-STATE WS-MICRO WS-P
     COMPUTE WS-CHANCE = 0.05688889 * WS-P
     COMPUTE L-CHANCE ROUNDED = WS-CHANCE * 1000000
     COMPUTE L-WAIT ROUNDED = 10 / WS-CHANCE
     GOBACK.
 END PROGRAM GC5-OX-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-ENGINE.
*> USING the first draw (FLOAT-LONG), the block's weather state, the number of scanned cells, their states (as GC5-OX-SCAN), the second draw (FLOAT-LONG), changed, draws made
*> out (4.1, 4.2): the gate, the scan (an abort makes no second draw), then the second draw below p advances the block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PASSES              BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-ABORTED             BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-MICRO               BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DRAW1                FLOAT-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 16 TIMES.
 01 L-DRAW2                FLOAT-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW1 L-STATE L-N L-CELLS L-DRAW2 L-CHANGED L-DRAWS.
     MOVE 0 TO L-CHANGED
     CALL "GC5-OX-GATE" USING L-DRAW1 WS-PASSES WS-DRAWS
     MOVE WS-DRAWS TO L-DRAWS
     IF WS-PASSES = 1
         CALL "GC5-OX-SCAN" USING L-STATE L-N L-CELLS WS-ABORTED WS-H WS-S
         IF WS-ABORTED = 0
             CALL "GC5-OX-PROB" USING WS-H WS-S L-STATE WS-MICRO WS-P
             MOVE 2 TO L-DRAWS
             IF L-DRAW2 < WS-P
                 MOVE 1 TO L-CHANGED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-OX-ENGINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-OX-TICKING.
*> USING the block has a next block (BINARY-LONG), randomly ticking out (4.3): oxidized and waxed blocks are not.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-NEXT             BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-NEXT L-TICKING.
     MOVE L-HAS-NEXT TO L-TICKING
     GOBACK.
 END PROGRAM GC5-OX-TICKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LADDER-STEP.
*> USING the weather state (BINARY-LONG), next, previous out (5.1): ordinal plus or minus one, clamped at the ends.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-PREVIOUS             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NEXT L-PREVIOUS.
     COMPUTE L-NEXT = FUNCTION MIN(L-STATE + 1, 3)
     COMPUTE L-PREVIOUS = FUNCTION MAX(L-STATE - 1, 0)
     GOBACK.
 END PROGRAM GC5-LADDER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-LADDER-COUNTS.
*> USING families, wax pairs, oxidation steps, blocks per family (BINARY-LONG out) (5.2): 15, 15 x 4, 15 x 3, 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILIES             BINARY-LONG.
 01 L-WAX                  BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 01 L-BLOCKS               BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILIES L-WAX L-STEPS L-BLOCKS.
     MOVE 15 TO L-FAMILIES
     MOVE 8 TO L-BLOCKS
     COMPUTE L-WAX = L-FAMILIES * 4
     COMPUTE L-STEPS = L-FAMILIES * 3
     GOBACK.
 END PROGRAM GC5-LADDER-COUNTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-FAMILY-FIRST.
*> USING the family (1 to 15, the order of the 5.2 table: copper_block, cut_copper, chiseled_copper, cut_copper_stairs, cut_copper_slab, copper_door, copper_trapdoor, copper_grate,
*> copper_bulb, copper_chest, copper_golem_statue, lightning_rod, copper_bars, copper_chain, copper_lantern), the first block id out (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIRSTS.
    05 FILLER              BINARY-LONG VALUE 1124.
    05 FILLER              BINARY-LONG VALUE 1134.
    05 FILLER              BINARY-LONG VALUE 1142.
    05 FILLER              BINARY-LONG VALUE 1150.
    05 FILLER              BINARY-LONG VALUE 1158.
    05 FILLER              BINARY-LONG VALUE 1166.
    05 FILLER              BINARY-LONG VALUE 1174.
    05 FILLER              BINARY-LONG VALUE 1182.
    05 FILLER              BINARY-LONG VALUE 1190.
    05 FILLER              BINARY-LONG VALUE 1198.
    05 FILLER              BINARY-LONG VALUE 1206.
    05 FILLER              BINARY-LONG VALUE 1214.
    05 FILLER              BINARY-LONG VALUE 392.
    05 FILLER              BINARY-LONG VALUE 401.
    05 FILLER              BINARY-LONG VALUE 941.
 01 WS-FIRST-T REDEFINES WS-FIRSTS.
    05 WS-FIRST            BINARY-LONG OCCURS 15 TIMES.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-FIRST.
     MOVE WS-FIRST(L-FAMILY) TO L-FIRST
     GOBACK.
 END PROGRAM GC5-FAMILY-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-FAMILY-CLASS.
*> USING the family (1 to 15), the kind (1 weathering class, 2 waxed class) (BINARY-LONG), the class name PIC X(48) out (5.2 table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   PIC X(48).
 01 WS-B                   PIC X(48).
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(48).
 PROCEDURE DIVISION USING L-FAMILY L-KIND L-NAME.
     EVALUATE L-FAMILY
         WHEN 1 THRU 3
             MOVE "WeatheringCopperFullBlock" TO WS-A
             MOVE "Block" TO WS-B
         WHEN 4
             MOVE "WeatheringCopperStairBlock" TO WS-A
             MOVE "StairBlock" TO WS-B
         WHEN 5
             MOVE "WeatheringCopperSlabBlock" TO WS-A
             MOVE "SlabBlock" TO WS-B
         WHEN 6
             MOVE "WeatheringCopperDoorBlock" TO WS-A
             MOVE "DoorBlock" TO WS-B
         WHEN 7
             MOVE "WeatheringCopperTrapDoorBlock" TO WS-A
             MOVE "TrapDoorBlock" TO WS-B
         WHEN 8
             MOVE "WeatheringCopperGrateBlock" TO WS-A
             MOVE "WaterloggedTransparentBlock" TO WS-B
         WHEN 9
             MOVE "WeatheringCopperBulbBlock" TO WS-A
             MOVE "CopperBulbBlock" TO WS-B
         WHEN 10
             MOVE "WeatheringCopperChestBlock" TO WS-A
             MOVE "CopperChestBlock" TO WS-B
         WHEN 11
             MOVE "WeatheringCopperGolemStatueBlock" TO WS-A
             MOVE "CopperGolemStatueBlock" TO WS-B
         WHEN 12
             MOVE "WeatheringLightningRodBlock" TO WS-A
             MOVE "LightningRodBlock" TO WS-B
         WHEN 13
             MOVE "WeatheringCopperBarsBlock" TO WS-A
             MOVE "IronBarsBlock" TO WS-B
         WHEN 14
             MOVE "WeatheringCopperChainBlock" TO WS-A
             MOVE "ChainBlock" TO WS-B
         WHEN OTHER
             MOVE "WeatheringLanternBlock" TO WS-A
             MOVE "LanternBlock" TO WS-B
     END-EVALUATE
     MOVE WS-A TO L-NAME
     IF L-KIND = 2
         MOVE WS-B TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM GC5-FAMILY-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BLOCK-ID.
*> USING the family (1 to 15), the offset (0 to 7) (BINARY-LONG), the block id out (5.2): the first id plus the offset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-OFFSET L-ID.
     CALL "GC5-FAMILY-FIRST" USING L-FAMILY WS-FIRST
     COMPUTE L-ID = WS-FIRST + L-OFFSET
     GOBACK.
 END PROGRAM GC5-BLOCK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BLOCK-NAME.
*> USING the family (1 to 15), the offset (0 to 7) (BINARY-LONG), the registry name without namespace PIC X(48) out (5.2): the prefixes "", exposed_, weathered_, oxidized_ and
*> waxed_ in front; the family copper_block is copper_block, exposed_copper, weathered_copper, oxidized_copper (and waxed_ in front).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(32).
 01 WS-PTR                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-NAME                 PIC X(48).
 PROCEDURE DIVISION USING L-FAMILY L-OFFSET L-NAME.
     COMPUTE WS-STATE = FUNCTION MOD(L-OFFSET, 4)
     EVALUATE L-FAMILY
         WHEN 1
             MOVE "copper" TO WS-BASE
             IF WS-STATE = 0
                 MOVE "copper_block" TO WS-BASE
             END-IF
         WHEN 2
             MOVE "cut_copper" TO WS-BASE
         WHEN 3
             MOVE "chiseled_copper" TO WS-BASE
         WHEN 4
             MOVE "cut_copper_stairs" TO WS-BASE
         WHEN 5
             MOVE "cut_copper_slab" TO WS-BASE
         WHEN 6
             MOVE "copper_door" TO WS-BASE
         WHEN 7
             MOVE "copper_trapdoor" TO WS-BASE
         WHEN 8
             MOVE "copper_grate" TO WS-BASE
         WHEN 9
             MOVE "copper_bulb" TO WS-BASE
         WHEN 10
             MOVE "copper_chest" TO WS-BASE
         WHEN 11
             MOVE "copper_golem_statue" TO WS-BASE
         WHEN 12
             MOVE "lightning_rod" TO WS-BASE
         WHEN 13
             MOVE "copper_bars" TO WS-BASE
         WHEN 14
             MOVE "copper_chain" TO WS-BASE
         WHEN OTHER
             MOVE "copper_lantern" TO WS-BASE
     END-EVALUATE
     MOVE SPACES TO L-NAME
     MOVE 1 TO WS-PTR
     IF L-OFFSET >= 4
         STRING "waxed_" DELIMITED BY SIZE INTO L-NAME WITH POINTER WS-PTR
     END-IF
     EVALUATE WS-STATE
         WHEN 1
             STRING "exposed_" DELIMITED BY SIZE INTO L-NAME WITH POINTER WS-PTR
         WHEN 2
             STRING "weathered_" DELIMITED BY SIZE INTO L-NAME WITH POINTER WS-PTR
         WHEN 3
             STRING "oxidized_" DELIMITED BY SIZE INTO L-NAME WITH POINTER WS-PTR
     END-EVALUATE
     STRING FUNCTION TRIM(WS-BASE) DELIMITED BY SIZE INTO L-NAME WITH POINTER WS-PTR
     GOBACK.
 END PROGRAM GC5-BLOCK-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BLOCK-LOOKUP.
*> USING a block id (BINARY-LONG), the family (1 to 15), the offset (0 to 7), found out (5.2): the family whose 8 consecutive ids contain the id; 0 0 0 for any other block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FAMILY L-OFFSET L-FOUND.
     MOVE 0 TO L-FAMILY L-OFFSET L-FOUND
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 15 OR L-FOUND = 1
         CALL "GC5-FAMILY-FIRST" USING WS-F WS-FIRST
         IF L-ID >= WS-FIRST AND L-ID < WS-FIRST + 8
             MOVE WS-F TO L-FAMILY
             COMPUTE L-OFFSET = L-ID - WS-FIRST
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC5-BLOCK-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-BLOCK-NEXT.
*> USING a block id (BINARY-LONG), getNext, getPrevious, getFirst, the waxed block (wax on), the unwaxed block (wax off), randomly ticking out (5.1, 4.3): 0 when there is none;
*> a waxed block has no previous and is its own first; an oxidized block has no next; a block of no family gives all 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-PREVIOUS             BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-WAXED                BINARY-LONG.
 01 L-UNWAXED              BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NEXT L-PREVIOUS L-FIRST L-WAXED L-UNWAXED L-TICKING.
     MOVE 0 TO L-NEXT L-PREVIOUS L-FIRST L-WAXED L-UNWAXED L-TICKING
     CALL "GC5-BLOCK-LOOKUP" USING L-ID WS-FAMILY WS-OFFSET WS-FOUND
     IF WS-FOUND = 1
         COMPUTE WS-STATE = FUNCTION MOD(WS-OFFSET, 4)
         MOVE L-ID TO L-FIRST
         IF WS-OFFSET < 4
             COMPUTE L-FIRST = L-ID - WS-STATE
             COMPUTE L-WAXED = L-ID + 4
             IF WS-STATE < 3
                 COMPUTE L-NEXT = L-ID + 1
                 MOVE 1 TO L-TICKING
             END-IF
             IF WS-STATE > 0
                 COMPUTE L-PREVIOUS = L-ID - 1
             END-IF
         ELSE
             COMPUTE L-UNWAXED = L-ID - 4
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-BLOCK-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-HOOK-RUNS.
*> USING the class (1 plain, 2 door, 3 chest, 4 golem statue), half (0 lower, 1 upper), chest type (0 single, 1 left, 2 right), the block entity at the position is a chest block
*> entity, the number of entities with the container open (BINARY-LONG), runs changeOverTime out (6): a door only for the lower half; a chest when its type is not right, the
*> block entity is a chest and nothing holds it open; every other class always.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-HALF L-TYPE L-ENTITY L-OPEN L-RUNS.
     MOVE 1 TO L-RUNS
     IF L-CLASS = 2 AND L-HALF = 1
         MOVE 0 TO L-RUNS
     END-IF
     IF L-CLASS = 3 AND (L-TYPE = 2 OR L-ENTITY = 0 OR L-OPEN > 0)
         MOVE 0 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM GC5-HOOK-RUNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-DOOR-SU.
*> USING this half (0 lower, 1 upper), the update direction (1 down, 2 up, 3 horizontal), the neighbour is a DoorBlock, its half differs, the state can survive (BINARY-LONG), the
*> result out (0 unchanged, 1 the neighbour's state with this half, 2 air) (6.1): an update from the other half's direction takes the neighbour's state when it is a door of the
*> other half, else air; the lower half with a down update that cannot survive gives air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OTHER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-IS-DOOR              BINARY-LONG.
 01 L-DIFFERS              BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-DIR L-IS-DOOR L-DIFFERS L-SURVIVES L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE 2 TO WS-OTHER
     IF L-HALF = 1
         MOVE 1 TO WS-OTHER
     END-IF
     EVALUATE TRUE
         WHEN L-DIR = WS-OTHER AND L-IS-DOOR = 1 AND L-DIFFERS = 1
             MOVE 1 TO L-RESULT
         WHEN L-DIR = WS-OTHER
             MOVE 2 TO L-RESULT
         WHEN L-HALF = 0 AND L-DIR = 1 AND L-SURVIVES = 0
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC5-DOOR-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-CHEST-SU.
*> USING the changed neighbour is a copper chest, this chest's type is not single, the direction is this chest's connected direction (BINARY-LONG), takes the neighbour's block
*> out (6.2 (a)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COPPER               BINARY-LONG.
 01 L-NOT-SINGLE           BINARY-LONG.
 01 L-CONNECTED            BINARY-LONG.
 01 L-TAKES                BINARY-LONG.
 PROCEDURE DIVISION USING L-COPPER L-NOT-SINGLE L-CONNECTED L-TAKES.
     MOVE 0 TO L-TAKES
     IF L-COPPER = 1 AND L-NOT-SINGLE = 1 AND L-CONNECTED = 1
         MOVE 1 TO L-TAKES
     END-IF
     GOBACK.
 END PROGRAM GC5-CHEST-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-CHEST-LEAST.
*> USING both are copper chests, the new state's type is not single, this chest is waxed, the other is waxed, this weather state, the other's (BINARY-LONG), both unwaxed first,
*> the winner (1 this, 2 the other, 0 no pairing), the result is waxed out (6.2 (b)): exactly one waxed unwaxes both; the smaller or equal state wins.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOTH                 BINARY-LONG.
 01 L-NOT-SINGLE           BINARY-LONG.
 01 L-WAXED-THIS           BINARY-LONG.
 01 L-WAXED-OTHER          BINARY-LONG.
 01 L-STATE-THIS           BINARY-LONG.
 01 L-STATE-OTHER          BINARY-LONG.
 01 L-UNWAXED              BINARY-LONG.
 01 L-WINNER               BINARY-LONG.
 01 L-RESULT-WAXED         BINARY-LONG.
 PROCEDURE DIVISION USING L-BOTH L-NOT-SINGLE L-WAXED-THIS L-WAXED-OTHER L-STATE-THIS L-STATE-OTHER L-UNWAXED L-WINNER L-RESULT-WAXED.
     MOVE 0 TO L-UNWAXED L-WINNER
     MOVE L-WAXED-THIS TO L-RESULT-WAXED
     IF L-BOTH = 1 AND L-NOT-SINGLE = 1
         MOVE 1 TO L-WINNER
         IF L-STATE-THIS > L-STATE-OTHER
             MOVE 2 TO L-WINNER
             MOVE L-WAXED-OTHER TO L-RESULT-WAXED
         END-IF
         IF L-WAXED-THIS NOT = L-WAXED-OTHER
             MOVE 1 TO L-UNWAXED
             MOVE 0 TO L-RESULT-WAXED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC5-CHEST-LEAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC5-STATUE-USE.
*> USING the block entity is the statue entity, the stack is in tag axes, the statue is unaffected, the stack is honeycomb, an entity was produced (BINARY-LONG), result (1 success,
*> 0 pass), action (1 remove the statue, 2 change the pose), the axe damaged by 1, the entity added, the block removed out (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-AXE                  BINARY-LONG.
 01 L-UNAFFECTED           BINARY-LONG.
 01 L-HONEY                BINARY-LONG.
 01 L-PRODUCED             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-ADDED                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-AXE L-UNAFFECTED L-HONEY L-PRODUCED L-RESULT L-ACTION L-DAMAGE L-ADDED L-REMOVED.
     MOVE 0 TO L-RESULT L-ACTION L-DAMAGE L-ADDED L-REMOVED
     IF L-ENTITY = 1
         EVALUATE TRUE
             WHEN L-AXE = 1 AND L-UNAFFECTED = 1
                 MOVE 1 TO L-RESULT L-ACTION L-DAMAGE L-REMOVED
                 MOVE L-PRODUCED TO L-ADDED
             WHEN L-AXE = 0 AND L-HONEY = 0
                 MOVE 1 TO L-RESULT
                 MOVE 2 TO L-ACTION
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GC5-STATUE-USE.
