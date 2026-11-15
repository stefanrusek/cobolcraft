*> Sponge, wet sponge and magma block (docs/protocol/29b part 3 section 10) as programs of plain numbers (GC3- prefix), in the style of growth-29b-3.cob: the decisions
*> of each rule take the facts the caller read from the level and return the decision. The traversal itself is GC3-BFS (section 2.4).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-CONST.
*> USING MAX_DEPTH, MAX_COUNT, the maxCount handed to the traversal (BINARY-LONG out): the constants of SpongeBlock (10.1); the start counts as the first accepted node.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEPTH                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-TRAVERSAL            BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-COUNT L-TRAVERSAL.
     MOVE 6 TO L-DEPTH
     MOVE 64 TO L-COUNT
     COMPUTE L-TRAVERSAL = L-COUNT + 1
     GOBACK.
 END PROGRAM GC3-SPONGE-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-TRIGGER.
*> USING trigger (1 PL, 2 NU), the old state is already this block (BINARY-LONG), tryAbsorbWater runs (BINARY-LONG out): the trigger table of 10.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGER              BINARY-LONG.
 01 L-OLD-SAME             BINARY-LONG.
 01 L-ABSORB               BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGER L-OLD-SAME L-ABSORB.
     MOVE 1 TO L-ABSORB
     IF L-TRIGGER = 1 AND L-OLD-SAME = 1
         MOVE 0 TO L-ABSORB
     END-IF
     GOBACK.
 END PROGRAM GC3-SPONGE-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-RESULT.
*> USING the accepted count n of the traversal (BINARY-LONG), becomes wet_sponge, setBlock flags, sponge_absorb played (BINARY-LONG out): tryAbsorbWater (10.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-WET L-FLAGS L-SOUND.
     MOVE 0 TO L-WET L-FLAGS L-SOUND
     IF L-N > 1
         MOVE 1 TO L-WET L-SOUND
         MOVE 2 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM GC3-SPONGE-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-NODE.
*> USING q is the sponge position, the fluid at q is in tag water, a BucketPickup gave a non-empty stack, the block is a LiquidBlock, the state is kelp, kelp_plant, seagrass
*> or tall_seagrass (BINARY-LONG), verdict (1 ACCEPT, 2 SKIP) and action (0 none, 1 picked up, 2 set to air, 3 dropped and set to air) out: the node function of 10.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IS-POS               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-PLANT                BINARY-LONG.
 01 L-VERDICT              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-POS L-WATER L-PICKUP L-LIQUID L-PLANT L-VERDICT L-ACTION.
     MOVE 0 TO L-ACTION
     MOVE 1 TO L-VERDICT
     EVALUATE TRUE
         WHEN L-IS-POS = 1
             CONTINUE
         WHEN L-WATER = 0
             MOVE 2 TO L-VERDICT
         WHEN L-PICKUP = 1
             MOVE 1 TO L-ACTION
         WHEN L-LIQUID = 1
             MOVE 2 TO L-ACTION
         WHEN L-PLANT = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-VERDICT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-SPONGE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-LAYER.
*> USING the traversal distance d (BINARY-LONG), the positions of a water body at that distance out: 1 at 0, else 4 d d + 2 (worked example 8: 1, 6, 18, 38).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-SIZE.
     MOVE 1 TO L-SIZE
     IF L-D > 0
         COMPUTE L-SIZE = 4 * L-D * L-D + 2
     END-IF
     GOBACK.
 END PROGRAM GC3-SPONGE-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPONGE-ABSORB.
*> USING the positions the traversal could accept in water within depth 6, the sponge included (BINARY-LONG), accepted, removed (accepted - 1), wet (BINARY-LONG out):
*> the traversal stops at maxCount 65, so at most 64 positions other than the sponge are absorbed (10.1, example 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REACHABLE            BINARY-LONG.
 01 L-ACCEPTED             BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REACHABLE L-ACCEPTED L-REMOVED L-WET.
     MOVE L-REACHABLE TO L-ACCEPTED
     IF L-ACCEPTED > 65
         MOVE 65 TO L-ACCEPTED
     END-IF
     COMPUTE L-REMOVED = L-ACCEPTED - 1
     MOVE 0 TO L-WET
     IF L-REMOVED > 0
         MOVE 1 TO L-WET
     END-IF
     GOBACK.
 END PROGRAM GC3-SPONGE-ABSORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-WET-SPONGE.
*> USING water_evaporates at pos (BINARY-LONG), the draw nextFloat (FLOAT-LONG), becomes sponge, level event, sound played (BINARY-LONG out), the sound pitch x 1000000:
*> WetSpongeBlock placement (10.2): setBlockAndUpdate, event 2009 (data 0) and wet_sponge_dries with pitch (1.0 + nextFloat * 0.2) * 0.7; one draw, only then.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-BECOMES              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVAPORATES L-DRAW L-BECOMES L-EVENT L-SOUND L-PITCH.
     MOVE 0 TO L-BECOMES L-EVENT L-SOUND L-PITCH
     IF L-EVAPORATES = 1
         MOVE 1 TO L-BECOMES L-SOUND
         MOVE 2009 TO L-EVENT
         COMPUTE L-PITCH ROUNDED = (1.0 + L-DRAW * 0.2) * 0.7 * 1000000
     END-IF
     GOBACK.
 END PROGRAM GC3-WET-SPONGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-WET-DRIP.
*> USING the random direction (1 down, 2 up, 3 north, 4 south, 5 west, 6 east: Direction.values order), the neighbour in that direction canOcclude and has a sturdy face toward
*> this block (BINARY-LONG), two nextDouble draws (FLOAT-LONG), a dripping_water particle spawned, y offset x 1000, first and second free offset x 1000 (BINARY-LONG out): animateTick
*> of the wet sponge (10.2). Down: y - 0.05 with x and z plus a draw each; a side face: y plus draw * 0.8 and the other horizontal coordinate plus a draw (the second free offset is -1).
*> Which side gets the face coordinate offset 1.1 or 0.05 is not stated by the document and is not modelled.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STURDY L-D1 L-D2 L-SPAWN L-Y L-A L-B.
     MOVE 0 TO L-SPAWN L-Y L-A L-B
     IF L-DIR = 2 OR L-STURDY = 1
         GOBACK
     END-IF
     MOVE 1 TO L-SPAWN
     IF L-DIR = 1
         MOVE -50 TO L-Y
         COMPUTE L-A ROUNDED = L-D1 * 1000
         COMPUTE L-B ROUNDED = L-D2 * 1000
     ELSE
         COMPUTE L-Y ROUNDED = L-D1 * 800
         COMPUTE L-A ROUNDED = L-D2 * 1000
         MOVE -1 TO L-B
     END-IF
     GOBACK.
 END PROGRAM GC3-WET-DRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-MAGMA-STEP.
*> USING the entity is stepping carefully, it is a LivingEntity (BINARY-LONG), the damage of the hotFloor source x 10 out (0 for none): MagmaBlock.stepOn (10.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAREFUL              BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAREFUL L-LIVING L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     IF L-CAREFUL = 0 AND L-LIVING = 1
         MOVE 10 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GC3-MAGMA-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-MAGMA-REG.
*> USING light level, strength x 10, valid spawn only for fire-immune types, emissiveRendering always, postProcess always, Frost Walker immunity to burn_from_stepping
*> (BINARY-LONG out): the registry values of the magma block (10.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-EMISSIVE             BINARY-LONG.
 01 L-POST                 BINARY-LONG.
 01 L-FROST                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-STRENGTH L-SPAWN L-EMISSIVE L-POST L-FROST.
     MOVE 3 TO L-LIGHT
     MOVE 5 TO L-STRENGTH
     MOVE 1 TO L-SPAWN L-EMISSIVE L-POST L-FROST
     GOBACK.
 END PROGRAM GC3-MAGMA-REG.
