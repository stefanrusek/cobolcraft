*> The sulfur spike differences, the behaviour rows and the potent sulfur block (docs/protocol/29b part 6, section 9) as programs of plain numbers (GC6- prefix), helpers like those
*> of growth-29b-6.cob. The state of a potent sulfur block is 0 dry, 1 wet, 2 dormant, 3 erupting, 4 continuous.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-SULFUR-DIFF.
*> USING the block kind (1 pointed_dripstone, 2 sulfur_spike) (BINARY-LONG), blockToGrowOn (1 dripstone_block, 2 sulfur), a water source two above is needed, getMaxGrowthLength,
*> blocksStalagmiteScan is not canDripThrough (0 never), nextFloat draws per random tick, drip and cauldron fill and mud to clay, fallOn stalagmite damage, landing level event,
*> damage source (1 falling_stalactite), piece cap out (9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-GROW-ON              BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-SCAN                 BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 01 L-DRIP                 BINARY-LONG.
 01 L-FALL-ON              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-CAP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-GROW-ON L-WATER L-LENGTH L-SCAN L-DRAWS L-DRIP L-FALL-ON L-EVENT L-SOURCE L-CAP.
     MOVE L-KIND TO L-GROW-ON
     MOVE 1 TO L-SOURCE
     MOVE 0 TO L-WATER L-SCAN L-DRIP L-FALL-ON
     MOVE 2 TO L-LENGTH
     MOVE 1 TO L-DRAWS
     MOVE 1052 TO L-EVENT
     IF L-KIND = 1
         MOVE 1 TO L-WATER L-SCAN L-DRIP L-FALL-ON
         MOVE 7 TO L-LENGTH
         MOVE 2 TO L-DRAWS
         MOVE 1045 TO L-EVENT
     END-IF
     COMPUTE L-CAP = L-LENGTH + 1
     GOBACK.
 END PROGRAM GC6-SULFUR-DIFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-ROW.
*> USING the row (1 to 12) of the table of 9.2 in its order: budding_amethyst, amethyst cluster and buds, amethyst_block family, speleothem shape update, speleothem tick,
*> speleothem random tick, pointed dripstone fluid transfer, cauldron tick, sculk_shrieker, sculk_catalyst, sculk sensors, sculk and sculk_vein (BINARY-LONG), trigger (1 RT,
*> 2 SU, 3 EV, 4 ST, 0 none), setBlock flags (0 via the update or none), the level event (the landing event of the pointed dripstone and the water fill for the cauldron) out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TRIGGER              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TRIGGER L-FLAGS L-EVENT.
     MOVE 0 TO L-TRIGGER L-FLAGS L-EVENT
     EVALUATE L-ROW
         WHEN 1
             MOVE 1 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
         WHEN 2
             MOVE 2 TO L-TRIGGER
         WHEN 3
             MOVE 3 TO L-TRIGGER
         WHEN 4
             MOVE 2 TO L-TRIGGER
         WHEN 5
             MOVE 4 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
             MOVE 1045 TO L-EVENT
         WHEN 6
             MOVE 1 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
         WHEN 7
             MOVE 1 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
             MOVE 1504 TO L-EVENT
         WHEN 8
             MOVE 4 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
             MOVE 1047 TO L-EVENT
         WHEN 9 THRU 10
             MOVE 4 TO L-TRIGGER
             MOVE 3 TO L-FLAGS
         WHEN 11
             MOVE 4 TO L-TRIGGER
         WHEN 12
             MOVE 3006 TO L-EVENT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-STATE.
*> USING the fluid above is a water source, the block below is in causes_continuous_geyser_eruptions (lava), it is in causes_periodic_geyser_eruptions (magma_block), the fluid state
*> of the block below is empty or a source, the current state (BINARY-LONG), the new state, resetCountdown is called first out (9.3 validBlockState).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-CONTINUOUS           BINARY-LONG.
 01 L-PERIODIC             BINARY-LONG.
 01 L-FLUID-OK             BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-CONTINUOUS L-PERIODIC L-FLUID-OK L-CURRENT L-NEW L-RESET.
     MOVE 0 TO L-NEW L-RESET
     EVALUATE TRUE
         WHEN L-WATER = 0
             CONTINUE
         WHEN L-CONTINUOUS = 1 AND L-FLUID-OK = 1
             MOVE 4 TO L-NEW
         WHEN L-PERIODIC = 1 AND L-FLUID-OK = 1
             MOVE 2 TO L-NEW
             IF L-CURRENT = 3
                 MOVE 3 TO L-NEW
             END-IF
             IF L-CURRENT NOT = 3 AND L-CURRENT NOT = 2
                 MOVE 1 TO L-RESET
             END-IF
         WHEN OTHER
             MOVE 1 TO L-NEW
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-POTENT-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-PLACE.
*> USING the new state (BINARY-LONG), blockEvent(pos, block, 0, 0) is sent, the sound (0 none, 1 geyser_continuous_start, 2 geyser_eruption_start), the game event block_activate out
*> (9.3 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-GAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-EVENT L-SOUND L-GAME.
     MOVE 0 TO L-EVENT L-SOUND L-GAME
     IF L-STATE = 3 OR L-STATE = 4
         MOVE 1 TO L-EVENT L-GAME
         MOVE 1 TO L-SOUND
         IF L-STATE = 3
             MOVE 2 TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-POTENT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-TICKER.
*> USING the state (BINARY-LONG), the client ticker (0 none, 1 noxious gas, 2 geyser plume then launch entity), the server ticker (0 none, 1 nausea effect, 2 waiting countdown then
*> nausea, 3 launch entity then waiting countdown, 4 launch entity alone), the plume sound (0 none, 1 geyser_eruption_active, 2 geyser_continuous_active) out (9.3 getTicker).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CLIENT               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CLIENT L-SERVER L-SOUND.
     MOVE 0 TO L-CLIENT L-SERVER L-SOUND
     EVALUATE L-STATE
         WHEN 1
             MOVE 1 TO L-CLIENT L-SERVER
         WHEN 2
             MOVE 1 TO L-CLIENT
             MOVE 2 TO L-SERVER
         WHEN 3
             MOVE 2 TO L-CLIENT
             MOVE 3 TO L-SERVER
             MOVE 1 TO L-SOUND
         WHEN 4
             MOVE 2 TO L-CLIENT
             MOVE 4 TO L-SERVER
             MOVE 2 TO L-SOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-POTENT-TICKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-CONST.
*> USING the selector (1 to 11) (BINARY-LONG), the value out (9.3): 1 ALLOWED_WATER_BLOCKS_ABOVE, 2 nausea period in ticks, 3 effect duration in ticks, 4 effect range x 10, 5 candidate
*> box x 10, 6 particle period, 7 sound period, 8 geyser base launch speed x 10, 9 launch force x 10, 10 geyser salt, 11 geyser scan limit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUES.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 80.
    05 FILLER              BINARY-LONG VALUE 30.
    05 FILLER              BINARY-LONG VALUE 25.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 40.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE -904011478.
    05 FILLER              BINARY-LONG VALUE 6.
 01 WS-VALUE-T REDEFINES WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 11 TIMES.
 LINKAGE SECTION.
 01 L-SEL                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEL L-VALUE.
     MOVE WS-VALUE(L-SEL) TO L-VALUE
     GOBACK.
 END PROGRAM GC6-POTENT-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-ANIM.
*> USING the state, a water source above, the draw nextInt(10) (BINARY-LONG), sulfur_bubbles bursts, the ambient sound noxious_gas out (9.3 animateTick, client only).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-BURSTS               BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-WATER L-DRAW L-BURSTS L-SOUND.
     MOVE 0 TO L-BURSTS L-SOUND
     IF L-STATE NOT = 0 AND L-WATER = 1
         MOVE 2 TO L-BURSTS
         IF L-DRAW = 0
             MOVE 1 TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC6-POTENT-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC6-POTENT-NAME.
*> USING the state (0 to 4) (BINARY-LONG), the serialized name PIC X(16) out (9.3): dry, wet, dormant, erupting, continuous.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 PROCEDURE DIVISION USING L-STATE L-NAME.
     EVALUATE L-STATE
         WHEN 0
             MOVE "dry" TO L-NAME
         WHEN 1
             MOVE "wet" TO L-NAME
         WHEN 2
             MOVE "dormant" TO L-NAME
         WHEN 3
             MOVE "erupting" TO L-NAME
         WHEN OTHER
             MOVE "continuous" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM GC6-POTENT-NAME.
