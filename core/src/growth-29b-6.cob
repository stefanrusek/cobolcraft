*> Sculk, amethyst and speleothems (docs/protocol/29b part 6, sections 1 to 3) as programs of plain numbers (GC6- prefix): the decisions take the facts the caller read from the
*> level (flags, counts, the random draws) and return the decision, as the part 1 and part 5 helpers do. Helpers only: nothing here is wired into the block-update hooks.
*> Directions are numbered as Direction.values(): 1 down, 2 up, 3 north, 4 south, 5 west, 6 east.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-TAG.
*> USING tag (1 speleothems, 2 vibration_resonators, 3 sulfur_spike_replaceable_blocks, 4 impact_projectiles), key (PIC X(48), a block or entity type), member (BINARY-LONG out,
*> 1 or 0): the tag members read from the jar (1, validation 1), listed to make the examples concrete; a reimplementation takes the tags from the data pack.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-KEY L-MEMBER.
     MOVE 0 TO L-MEMBER
     EVALUATE L-TAG
         WHEN 1
             IF L-KEY = "minecraft:pointed_dripstone" OR L-KEY = "minecraft:sulfur_spike"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 2
             IF L-KEY = "minecraft:amethyst_block"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 3
             IF L-KEY = "minecraft:sulfur" OR L-KEY = "minecraft:cinnabar"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN OTHER
             IF L-KEY = "minecraft:arrow" OR L-KEY = "minecraft:spectral_arrow" OR L-KEY = "minecraft:firework_rocket" OR L-KEY = "minecraft:snowball"
                  OR L-KEY = "minecraft:fireball" OR L-KEY = "minecraft:small_fireball" OR L-KEY = "minecraft:egg" OR L-KEY = "minecraft:trident"
                  OR L-KEY = "minecraft:dragon_fireball" OR L-KEY = "minecraft:wither_skull" OR L-KEY = "minecraft:wind_charge"
                  OR L-KEY = "minecraft:breeze_wind_charge"
                 MOVE 1 TO L-MEMBER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCOPE.
*> USING the row (1 to 16) of the table of 1 in its order (BINARY-LONG), the document and section that specify it PIC X(48) out (blank for a row outside the table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DOC                  PIC X(48).
 PROCEDURE DIVISION USING L-ROW L-DOC.
     MOVE SPACES TO L-DOC
     EVALUATE L-ROW
         WHEN 1
             MOVE "31-8 s3" TO L-DOC
         WHEN 2
             MOVE "31-8 s4.1-4.4" TO L-DOC
         WHEN 3
             MOVE "31-8 s5" TO L-DOC
         WHEN 4
             MOVE "44-x2 s2; 31-8 s6" TO L-DOC
         WHEN 5
             MOVE "31-8 s7.1-7.4" TO L-DOC
         WHEN 6
             MOVE "31-8 s7.3" TO L-DOC
         WHEN 7
             MOVE "35-6 s8.3-8.6" TO L-DOC
         WHEN 8
             MOVE "35-6 s4-7" TO L-DOC
         WHEN 9
             MOVE "29b-1 s4" TO L-DOC
         WHEN 10
             MOVE "9.3" TO L-DOC
         WHEN 11
             MOVE "24-8" TO L-DOC
         WHEN 12
             MOVE "29b-1..5, 7" TO L-DOC
         WHEN 13
             MOVE "42-3" TO L-DOC
         WHEN 14
             MOVE "17" TO L-DOC
         WHEN 15
             MOVE "29 s3, s4" TO L-DOC
         WHEN 16
             MOVE "29b-2 s9.5" TO L-DOC
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-SCOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-CONST.
*> USING the selector (1 to 16) (BINARY-LONG), the value out (2.2): 1 cursor limit, 2 max charge, 3 max cursor distance, 4 shrieker placement rate, 5 max growth-rate radius, 6 max decay
*> factor x 100, 7 growth cost, 8 no-growth radius, 9 charge decay rate, 10 additional decay rate (the live parameters 10, 4, 10, 5), 11 sensor ACTIVE_TICKS, 12 COOLDOWN_TICKS,
*> 13 calibrated active ticks, 14 shrieker SHRIEKING_TICKS, 15 WARNING_SOUND_RADIUS, 16 experience of sensor, shrieker and catalyst.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 32.
    05 FILLER              BINARY-LONG VALUE 1000.
    05 FILLER              BINARY-LONG VALUE 1024.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 24.
    05 FILLER              BINARY-LONG VALUE 50.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 30.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 90.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 5.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC6-SCULK-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-EVENT.
*> USING S the summed charge of the cursors on one position, the packed facings (BINARY-LONG), the facing set is non-null, sent, data out (2.2 event 3006): sent when S > 0 and the
*> facings are non-null; data = ((int)(ln(1 + S) / d) + 1) << 6 plus the facings, d the float 2.3 widened to double.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-FACINGS              BINARY-LONG.
 01 L-NONNULL              BINARY-LONG.
 01 L-SENT                 BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-FACINGS L-NONNULL L-SENT L-DATA.
     MOVE 0 TO L-SENT L-DATA
     IF L-S > 0 AND L-NONNULL = 1
         MOVE 1 TO L-SENT
         COMPUTE WS-V = FUNCTION LOG(1 + L-S) / 2.2999999523162842
         COMPUTE WS-N = FUNCTION INTEGER-PART(WS-V)
         COMPUTE L-DATA = (WS-N + 1) * 64 + L-FACINGS
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-DISCHARGE.
*> USING the charge of a cursor (BINARY-LONG), sent, data out (2.2): a charge of 0 or less sends event 3006 with data 0 at its own position.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHARGE               BINARY-LONG.
 01 L-SENT                 BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CHARGE L-SENT L-DATA.
     MOVE 0 TO L-SENT L-DATA
     IF L-CHARGE <= 0
         MOVE 1 TO L-SENT
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-DISCHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-DECAY.
*> USING the charge, distSqr (the squared distance to the catalyst), r (BINARY-LONG), the decay penalty out (2.2): max(1, (int)(charge x min(1, square(sqrt(distSqr) - r) / square(24 - r))
*> x 0.5)) in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-SHORT.
 01 WS-T                   FLOAT-SHORT.
 01 WS-Q                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-CHARGE               BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-PENALTY              BINARY-LONG.
 PROCEDURE DIVISION USING L-CHARGE L-DIST L-R L-PENALTY.
     COMPUTE WS-D = FUNCTION SQRT(L-DIST)
     COMPUTE WS-T = WS-D - L-R
     COMPUTE WS-Q = WS-T * WS-T
     COMPUTE WS-Q = WS-Q / ((24 - L-R) * (24 - L-R))
     IF WS-Q > 1
         MOVE 1 TO WS-Q
     END-IF
     COMPUTE WS-V = L-CHARGE * WS-Q
     COMPUTE WS-V = WS-V * 0.5
     COMPUTE L-PENALTY = FUNCTION INTEGER-PART(WS-V)
     IF L-PENALTY < 1
         MOVE 1 TO L-PENALTY
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-DECAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-GROWCELL.
*> USING the cell above is air, it is a water source, the number of sculk_growth_inhibitors blocks in the box (-4, 0, -4) to (+4, +2, +4) (BINARY-LONG), the cell is usable out (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-INHIBITORS           BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-WATER L-INHIBITORS L-OK.
     MOVE 0 TO L-OK
     IF (L-AIR = 1 OR L-WATER = 1) AND L-INHIBITORS <= 2
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-GROWCELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-CHARGE.
*> USING the charge, the draw nextInt(chargeDecayRate 10), near (closer than the no-growth radius), the cell above is usable, the draw nextInt(additionalDecayRate 5), the draw
*> nextInt(growthSpawnCost 10), the decay penalty (BINARY-LONG), the new charge, a sensor or shrieker placed, draws made out (2.2 SculkBlock.attemptUseCharge): the growth branch
*> places when the third draw is below the charge, draws the growth state nextInt(11) then, and always leaves max(0, charge - 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHARGE               BINARY-LONG.
 01 L-DRAW-A               BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 01 L-USABLE               BINARY-LONG.
 01 L-DRAW-B               BINARY-LONG.
 01 L-DRAW-C               BINARY-LONG.
 01 L-PENALTY              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHARGE L-DRAW-A L-NEAR L-USABLE L-DRAW-B L-DRAW-C L-PENALTY L-NEW L-PLACED L-DRAWS.
     MOVE L-CHARGE TO L-NEW
     MOVE 0 TO L-PLACED L-DRAWS
     IF L-CHARGE NOT = 0
         MOVE 1 TO L-DRAWS
         IF L-DRAW-A = 0
             MOVE 2 TO L-DRAWS
             EVALUATE TRUE
                 WHEN L-NEAR = 1 AND L-DRAW-B = 0
                     COMPUTE L-NEW = L-CHARGE - 1
                 WHEN L-NEAR = 0 AND L-USABLE = 0 AND L-DRAW-B = 0
                     COMPUTE L-NEW = L-CHARGE - L-PENALTY
                 WHEN L-NEAR = 1 OR L-USABLE = 0
                     CONTINUE
                 WHEN OTHER
                     MOVE 3 TO L-DRAWS
                     COMPUTE L-NEW = L-CHARGE - 10
                     IF L-NEW < 0
                         MOVE 0 TO L-NEW
                     END-IF
                     IF L-DRAW-C < L-CHARGE
                         MOVE 1 TO L-PLACED
                         MOVE 4 TO L-DRAWS
                     END-IF
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-CHARGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-CURSOR.
*> USING server level, the position is in an entity-ticking area, the charge (BINARY-LONG), updates out (2.1 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 01 L-UPDATES              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-TICKING L-CHARGE L-UPDATES.
     MOVE 0 TO L-UPDATES
     IF L-SERVER = 1 AND L-TICKING = 1 AND L-CHARGE > 0
         MOVE 1 TO L-UPDATES
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-CURSOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CATALYST-TICK.
*> USING bloom (BINARY-LONG), the new bloom, acts out (2.1): the block tick resets bloom to false when it is true and does nothing otherwise.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOOM                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-ACTS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOOM L-NEW L-ACTS.
     MOVE 0 TO L-NEW
     MOVE L-BLOOM TO L-ACTS
     GOBACK.
 END PROGRAM GC6-CATALYST-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SHRIEKER-TICK.
*> USING shrieking (BINARY-LONG), the new shrieking, tryRespond runs out (2.2): when shrieking is set false with setBlockAndUpdate, then tryRespond.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-RESPONDS             BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-NEW L-RESPONDS.
     MOVE 0 TO L-NEW
     MOVE L-SHRIEKING TO L-RESPONDS
     GOBACK.
 END PROGRAM GC6-SHRIEKER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SHRIEKER-STEP.
*> USING server level, a player was resolved by tryGetPlayer (BINARY-LONG), tryShriek out (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-SHRIEKS              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-PLAYER L-SHRIEKS.
     MOVE 0 TO L-SHRIEKS
     IF L-SERVER = 1 AND L-PLAYER = 1
         MOVE 1 TO L-SHRIEKS
     END-IF
     GOBACK.
 END PROGRAM GC6-SHRIEKER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SHRIEKER-STATE.
*> USING the fluid at the clicked position is water, the placement is world generation (BINARY-LONG), waterlogged, a water tick is scheduled, its delay, can_summon, the height of
*> column(16, 0, height), light occlusion by shape out (2.3 residual facts 1 and 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-WORLDGEN             BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-SUMMON               BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-OCCLUSION            BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-WORLDGEN L-WATERLOGGED L-TICK L-DELAY L-SUMMON L-HEIGHT L-OCCLUSION.
     MOVE L-WATER TO L-WATERLOGGED L-TICK
     MOVE 0 TO L-DELAY
     IF L-WATERLOGGED = 1
         MOVE 5 TO L-DELAY
     END-IF
     MOVE L-WORLDGEN TO L-SUMMON
     MOVE 8 TO L-HEIGHT
     MOVE 1 TO L-OCCLUSION
     GOBACK.
 END PROGRAM GC6-SHRIEKER-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-XP.
*> USING the block (1 sculk, 2 sensor, 3 shrieker, 4 catalyst), experience drops are allowed (BINARY-LONG), the experience out (2.2): 1, 5, 5, 5; none when not allowed.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-ALLOWED L-XP.
     MOVE 0 TO L-XP
     IF L-ALLOWED = 1
         MOVE 5 TO L-XP
         IF L-BLOCK = 1
             MOVE 1 TO L-XP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-SCULK-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SCULK-RANDOM.
*> USING the block (1 sculk, 2 sculk_vein, 3 sculk_catalyst, 4 sculk_sensor, 5 calibrated_sculk_sensor, 6 sculk_shrieker) (BINARY-LONG), randomly ticking out (2.3 residual 4): none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-TICKING.
     MOVE 0 TO L-TICKING
     GOBACK.
 END PROGRAM GC6-SCULK-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-AMETHYST-HIT.
*> USING server level (BINARY-LONG), the draw nextFloat() (FLOAT-LONG), the chime plays, pitch x 1e6 out (3.1): pitch = 0.5 + nextFloat x 1.2; nothing on a client.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PLAYS                BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-DRAW L-PLAYS L-PITCH.
     MOVE 0 TO L-PLAYS L-PITCH
     IF L-SERVER = 1
         MOVE 1 TO L-PLAYS
         COMPUTE L-PITCH ROUNDED = (0.5 + L-DRAW * 1.2) * 1000000
     END-IF
     GOBACK.
 END PROGRAM GC6-AMETHYST-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CLUSTER-SURVIVE.
*> USING the block opposite to facing is sturdy towards facing (BINARY-LONG), canSurvive out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-SURVIVE.
     MOVE L-STURDY TO L-SURVIVE
     GOBACK.
 END PROGRAM GC6-CLUSTER-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CLUSTER-SU.
*> USING waterlogged, the notifying direction is the opposite of facing, the state can survive (BINARY-LONG), a water tick is scheduled, its delay, the result is air out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-OPPOSITE             BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-OPPOSITE L-SURVIVES L-TICK L-DELAY L-AIR.
     MOVE L-WATERLOGGED TO L-TICK
     MOVE 0 TO L-DELAY L-AIR
     IF L-WATERLOGGED = 1
         MOVE 5 TO L-DELAY
     END-IF
     IF L-OPPOSITE = 1 AND L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GC6-CLUSTER-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CLUSTER-PLACE.
*> USING the fluid at the clicked position is water, the clicked face (1 to 6) (BINARY-LONG), waterlogged, facing, the fluid state is the water source out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-FACE L-WATERLOGGED L-FACING L-SOURCE.
     MOVE L-WATER TO L-WATERLOGGED L-SOURCE
     MOVE L-FACE TO L-FACING
     GOBACK.
 END PROGRAM GC6-CLUSTER-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CLUSTER-ROTATE.
*> USING facing (1 to 6), the rotation (0 none, 1 clockwise 90, 2 180, 3 counterclockwise 90) (BINARY-LONG), the new facing out (3.2): the horizontal cycle is north, east, south, west.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CYCLE.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 5.
 01 WS-CYCLE-T REDEFINES WS-CYCLE.
    05 WS-C                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-ROT L-NEW.
     MOVE L-FACING TO L-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-C(WS-I) = L-FACING
             MOVE WS-C(FUNCTION MOD(WS-I - 1 + L-ROT, 4) + 1) TO L-NEW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC6-CLUSTER-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-CLUSTER-MIRROR.
*> USING facing (1 to 6), the mirror (0 none, 1 left-right, 2 front-back) (BINARY-LONG), the new facing out (3.2): Mirror.getRotation turns a facing on the mirrored axis (left-right:
*> north and south, front-back: west and east) by 180 degrees.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TURNS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-MIRROR L-NEW.
     MOVE 0 TO WS-TURNS
     IF L-MIRROR = 1 AND (L-FACING = 3 OR L-FACING = 4)
         MOVE 2 TO WS-TURNS
     END-IF
     IF L-MIRROR = 2 AND (L-FACING = 5 OR L-FACING = 6)
         MOVE 2 TO WS-TURNS
     END-IF
     CALL "GC6-CLUSTER-ROTATE" USING L-FACING WS-TURNS L-NEW
     GOBACK.
 END PROGRAM GC6-CLUSTER-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-BUD-TICK.
*> USING the draw nextInt(5), the draw nextInt(6) (index into down, up, north, south, west, east), the target state (0 other, 1 air, 2 a full water block, 3 a small bud facing the
*> direction, 4 a medium bud facing it, 5 a large bud facing it), the fluid at the target is water (BINARY-LONG), draws made, direction (1 to 6), the new block (0 none, 1 small,
*> 2 medium, 3 large, 4 cluster), waterlogged out (3.3 randomTick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW5                BINARY-LONG.
 01 L-DRAW6                BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW5 L-DRAW6 L-TARGET L-WATER L-DRAWS L-DIR L-NEW L-WATERLOGGED.
     MOVE 1 TO L-DRAWS
     MOVE 0 TO L-DIR L-NEW L-WATERLOGGED
     IF L-DRAW5 = 0
         MOVE 2 TO L-DRAWS
         COMPUTE L-DIR = L-DRAW6 + 1
         EVALUATE L-TARGET
             WHEN 1 THRU 2
                 MOVE 1 TO L-NEW
             WHEN 3
                 MOVE 2 TO L-NEW
             WHEN 4
                 MOVE 3 TO L-NEW
             WHEN 5
                 MOVE 4 TO L-NEW
         END-EVALUATE
         IF L-NEW > 0
             MOVE L-WATER TO L-WATERLOGGED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-BUD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-BUD-RATE.
*> USING (BINARY-LONG out) the chance per random tick of one face x 1e6 (1/5 x 1/6), the random ticks for the four stages (4 x 30), the game ticks at random_tick_speed 3 (3/4096 per
*> game tick), GROWTH_CHANCE (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHANCE               BINARY-LONG.
 01 L-STAGES               BINARY-LONG.
 01 L-GAME                 BINARY-LONG.
 01 L-GROWTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANCE L-STAGES L-GAME L-GROWTH.
     MOVE 5 TO L-GROWTH
     COMPUTE L-CHANCE ROUNDED = 1000000 / (L-GROWTH * 6)
     COMPUTE L-STAGES = 4 * L-GROWTH * 6
     COMPUTE L-GAME = L-STAGES * 4096 / 3
     GOBACK.
 END PROGRAM GC6-BUD-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-AMETHYST-PUSH.
*> USING the block (1 amethyst_block, 2 budding_amethyst) (BINARY-LONG), the push reaction out (1 PUSH_PULL, 2 POPPED) (3.1, 3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-REACTION             BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-REACTION.
     MOVE L-BLOCK TO L-REACTION
     GOBACK.
 END PROGRAM GC6-AMETHYST-PUSH.
