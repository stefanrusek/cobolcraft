*> Walk and idle poses of the mobs of the codes W and V of the model table (CL-MD-ANIM, client/copy/CLMODELS.cpy), docs/protocol/34-entity-models-3..7:
*> ENTITY-POSE-MORE runs the setupAnim program of the row's type on the state the replica has: head pitch, head yaw relative to the body, walk position
*> and walk speed (the renderer's values, 54 section 1) and ageInTicks (code V only; code W models do not depend on it). Everything else a program reads
*> (eating, sitting, ridden, saddled, animation start ticks) is not in the replica and is at its rest value: the start ticks of the keyframe animations
*> are the stopped value -2147483648. A row whose key ends in ~b is the baby row of its type (the baby model flag of the program).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-POSE-MORE.
*> USING model (EMM-MODEL), row key (X(20)), state (16 FLOAT-LONG: 1 pitch, 2 head yaw relative to the body, 3 walk position, 4 walk speed; 15 1 when an aquatic mob is out
*> of water, 16 a squid's tentacle angle; the rest 0), age in ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STOP                FLOAT-LONG VALUE -2147483648.
 01 WS-KEY                 PIC X(20).
 01 WS-BASE                PIC X(20).
 01 WS-TAIL                PIC X(2).
 01 WS-BABY                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-WPOS                FLOAT-LONG.
 01 WS-WSPEED              FLOAT-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-DRY                 FLOAT-LONG.
 01 WS-TANGLE              FLOAT-LONG.
 01 WS-WET                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-KEY                  PIC X(20).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-AGE                  FLOAT-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-KEY L-IN L-AGE.
     MOVE L-KEY TO WS-KEY
     MOVE 0 TO WS-BABY
     MOVE SPACES TO WS-BASE WS-TAIL
     UNSTRING WS-KEY DELIMITED BY "~" INTO WS-BASE WS-TAIL
     IF WS-TAIL = "b"
         MOVE 1 TO WS-BABY
     END-IF
     MOVE L-I(1) TO WS-PITCH
     MOVE L-I(2) TO WS-YAW
     MOVE L-I(3) TO WS-WPOS
     MOVE L-I(4) TO WS-WSPEED
     MOVE L-I(15) TO WS-DRY
     MOVE L-I(16) TO WS-TANGLE
     COMPUTE WS-WET = 1 - WS-DRY
     PERFORM VARYING WS-J FROM 5 BY 1 UNTIL WS-J > 16
         MOVE 0 TO L-I(WS-J)
     END-PERFORM
     EVALUATE WS-BASE
         WHEN "horse" WHEN "skeleton_horse" WHEN "zombie_horse"
             MOVE L-AGE TO L-I(8)
             MOVE 1 TO L-I(9)
             MOVE WS-BABY TO L-I(12)
             CALL "EF4-EQUINE-ANIM" USING EMM-MODEL L-IN
         WHEN "donkey" WHEN "mule"
             MOVE L-AGE TO L-I(8)
             MOVE 1 TO L-I(9) L-I(15)
             COMPUTE L-I(12) = WS-BABY * 2
             CALL "EF4-EQUINE-ANIM" USING EMM-MODEL L-IN
         WHEN "llama" WHEN "trader_llama"
             CALL "EF4-LLAMA-ANIM" USING EMM-MODEL L-IN
         WHEN "goat"
             MOVE 1 TO L-I(5) L-I(6)
             MOVE WS-BABY TO L-I(8)
             CALL "EF4-GOAT-ANIM" USING EMM-MODEL L-IN
         WHEN "camel" WHEN "camel_husk"
             MOVE L-AGE TO L-I(5)
             MOVE WS-BABY TO L-I(7)
             PERFORM VARYING WS-J FROM 10 BY 1 UNTIL WS-J > 14
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EF4-CAMEL-ANIM" USING EMM-MODEL L-IN
         WHEN "rabbit"
             MOVE L-AGE TO L-I(3)
             MOVE WS-BABY TO L-I(4)
             MOVE WS-STOP TO L-I(5) L-I(6)
             CALL "EF4-RABBIT-ANIM" USING EMM-MODEL L-IN
         WHEN "ocelot" WHEN "cat"
             MOVE 1 TO L-I(5)
             MOVE WS-BABY TO L-I(12)
             CALL "EF5-FELINE-ANIM" USING EMM-MODEL L-IN
         WHEN "wolf"
             MOVE 1 TO L-I(5)
             CALL "EF5-WOLF-ANIM" USING EMM-MODEL L-IN
         WHEN "fox"
             MOVE 1 TO L-I(5)
             MOVE L-AGE TO L-I(6)
             MOVE WS-BABY TO L-I(14)
             CALL "EF5-FOX-ANIM" USING EMM-MODEL L-IN
         WHEN "panda"
             MOVE L-AGE TO L-I(5)
             MOVE WS-BABY TO L-I(14)
             CALL "EF5-PANDA-ANIM" USING EMM-MODEL L-IN
         WHEN "polar_bear"
             MOVE 1 TO L-I(6)
             CALL "EF5-BEAR-ANIM" USING EMM-MODEL L-IN
         WHEN "parrot"
             MOVE L-AGE TO L-I(5)
             MOVE 1 TO L-I(6)
             CALL "EF5-PARROT-ANIM" USING EMM-MODEL L-IN
         WHEN "bat"
             MOVE WS-YAW TO L-I(1)
             MOVE L-AGE TO L-I(3)
             MOVE WS-STOP TO L-I(5)
             CALL "EF5-BAT-ANIM" USING EMM-MODEL L-IN
         WHEN "bee"
             MOVE L-AGE TO L-I(1)
             MOVE 0 TO L-I(2)
             MOVE WS-BABY TO L-I(6)
             CALL "EF5-BEE-ANIM" USING EMM-MODEL L-IN
         WHEN "armadillo"
             MOVE L-AGE TO L-I(5)
             MOVE WS-STOP TO L-I(7) L-I(8) L-I(9)
             MOVE WS-BABY TO L-I(10)
             CALL "EF5-ARMADILLO-ANIM" USING EMM-MODEL L-IN
         WHEN "frog"
             MOVE WS-WPOS TO L-I(1)
             MOVE WS-WSPEED TO L-I(2)
             MOVE L-AGE TO L-I(3)
             MOVE WS-STOP TO L-I(5) L-I(6) L-I(7) L-I(8)
             CALL "EF5-FROG-ANIM" USING EMM-MODEL L-IN
         WHEN "tadpole"
             MOVE 1 TO L-I(1)
             MOVE L-AGE TO L-I(2)
             CALL "EF5-TADPOLE-ANIM" USING EMM-MODEL L-IN
         WHEN "turtle"
             MOVE 1 TO L-I(5)
             MOVE WS-BABY TO L-I(8)
             CALL "EF5-TURTLE-ANIM" USING EMM-MODEL L-IN
         WHEN "sniffer"
             MOVE L-AGE TO L-I(5)
             PERFORM VARYING WS-J FROM 7 BY 1 UNTIL WS-J > 11
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EF5-SNIFFER-ANIM" USING EMM-MODEL L-IN
         WHEN "endermite"
             MOVE L-AGE TO L-I(1)
             CALL "EF6-ENDERMITE-ANIM" USING EMM-MODEL L-IN
         WHEN "silverfish"
             MOVE L-AGE TO L-I(1)
             CALL "EF6-SILVERFISH-ANIM" USING EMM-MODEL L-IN
         WHEN "phantom"
             MOVE L-AGE TO L-I(1)
             CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL L-IN
         WHEN "shulker"
             MOVE 0 TO L-I(3)
             MOVE 0 TO L-I(4)
             CALL "EF6-SHULKER-ANIM" USING EMM-MODEL L-IN
         WHEN "warden"
             MOVE L-AGE TO L-I(5)
             PERFORM VARYING WS-J FROM 7 BY 1 UNTIL WS-J > 12
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EF6-WARDEN-ANIM" USING EMM-MODEL L-IN
         WHEN "breeze"
             MOVE L-AGE TO L-I(1)
             PERFORM VARYING WS-J FROM 2 BY 1 UNTIL WS-J > 7
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EF6-BREEZE-ANIM" USING EMM-MODEL L-IN
         WHEN "ghast"
             MOVE L-AGE TO L-I(1)
             CALL "EF7-GHAST-ANIM" USING EMM-MODEL L-IN
         WHEN "happy_ghast"
             MOVE L-AGE TO L-I(1)
             MOVE 0 TO L-I(2)
             CALL "EF4-GHAST-ANIM" USING EMM-MODEL L-IN
         WHEN "strider"
             MOVE L-AGE TO L-I(5)
             MOVE WS-BABY TO L-I(7)
             CALL "EF7-STRIDER-ANIM" USING EMM-MODEL L-IN
         WHEN "hoglin" WHEN "zoglin"
             MOVE WS-YAW TO L-I(1)
             MOVE WS-WPOS TO L-I(2)
             MOVE WS-WSPEED TO L-I(3)
             MOVE 0 TO L-I(4)
             MOVE WS-BABY TO L-I(5)
             CALL "EF7-HOGLIN-ANIM" USING EMM-MODEL L-IN
         WHEN "villager" WHEN "wandering_trader"
             MOVE L-AGE TO L-I(5)
             CALL "EM3-VILLAGER-ANIM" USING EMM-MODEL L-IN
         WHEN "witch"
             MOVE L-AGE TO L-I(5)
             CALL "EM3-WITCH-ANIM" USING EMM-MODEL L-IN
         WHEN "pillager"
             MOVE L-AGE TO L-I(5)
             MOVE 7 TO L-I(7)
             CALL "EM3-ILLAGER-ANIM" USING EMM-MODEL L-IN
         WHEN "vindicator" WHEN "evoker" WHEN "illusioner"
             MOVE L-AGE TO L-I(5)
             CALL "EM3-ILLAGER-ANIM" USING EMM-MODEL L-IN
         WHEN "ravager"
             CALL "EM3-RAVAGER-ANIM" USING EMM-MODEL L-IN
         WHEN "vex"
             MOVE L-AGE TO L-I(3)
             CALL "EM3-VEX-ANIM" USING EMM-MODEL L-IN
         WHEN "iron_golem"
             CALL "EM3-IRON-GOLEM-ANIM" USING EMM-MODEL L-IN
         WHEN "snow_golem"
             CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL L-IN
         WHEN "allay"
             MOVE L-AGE TO L-I(5)
             CALL "EM3-ALLAY-ANIM" USING EMM-MODEL L-IN
         WHEN "cod"
             MOVE 1 TO L-I(1)
             MOVE L-AGE TO L-I(2)
             MOVE WS-WET TO L-I(3)
             CALL "EF8-FISH-ANIM" USING EMM-MODEL L-IN
         WHEN "tropical_fish"
             MOVE 2 TO L-I(1)
             MOVE L-AGE TO L-I(2)
             MOVE WS-WET TO L-I(3)
             CALL "EF8-FISH-ANIM" USING EMM-MODEL L-IN
         WHEN "salmon"
             MOVE 3 TO L-I(1)
             MOVE L-AGE TO L-I(2)
             MOVE WS-WET TO L-I(3)
             CALL "EF8-FISH-ANIM" USING EMM-MODEL L-IN
         WHEN "pufferfish"
             MOVE 4 TO L-I(1)
             MOVE L-AGE TO L-I(2)
             MOVE WS-WET TO L-I(3)
             CALL "EF8-FISH-ANIM" USING EMM-MODEL L-IN
         WHEN "dolphin"
             MOVE WS-PITCH TO L-I(1)
             MOVE WS-YAW TO L-I(2)
             IF WS-WSPEED > 0.01
                 MOVE 1 TO L-I(3)
             END-IF
             MOVE L-AGE TO L-I(4)
             CALL "EF8-DOLPHIN-ANIM" USING EMM-MODEL L-IN
         WHEN "axolotl"
             MOVE FUNCTION MIN(WS-WSPEED, 1) TO L-I(3)
             MOVE L-AGE TO L-I(4)
             IF WS-BABY = 0
                 CALL "EF8-AXOLOTL-ANIM" USING EMM-MODEL L-IN
             END-IF
*>       The squid's tentacles (34-8 section 2): the replica's tentacle angle (ENTITIES-ANIM-TICK).
         WHEN "squid" WHEN "glow_squid"
             MOVE WS-TANGLE TO L-I(1)
             CALL "EF8-SQUID-ANIM" USING EMM-MODEL L-IN
         WHEN "chicken"
             CALL "EF4-CHICKEN-ANIM" USING EMM-MODEL L-IN
*>       The guardian swims with its spikes out and its tail wagging with its age.
         WHEN "guardian" WHEN "elder_guardian"
             MOVE 1 TO L-I(3)
             MOVE L-AGE TO L-I(4) L-I(5)
             CALL "EF6-GUARDIAN-ANIM" USING EMM-MODEL L-IN
         WHEN "wither"
             MOVE L-AGE TO L-I(3)
             CALL "EF7-WITHER-ANIM" USING EMM-MODEL L-IN
         WHEN "end_crystal"
             MOVE L-AGE TO L-I(1)
             MOVE 1 TO L-I(2)
             CALL "EF7-CRYSTAL-ANIM" USING EMM-MODEL L-IN
         WHEN "creaking"
             MOVE L-AGE TO L-I(5)
             MOVE 1 TO L-I(6)
             PERFORM VARYING WS-J FROM 7 BY 1 UNTIL WS-J > 9
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EM3-CREAKING-ANIM" USING EMM-MODEL L-IN
*>       The copper golem walks (34-3 9.2): the walk keyframes with the walk state; no item in the hands, the state animations stopped.
         WHEN "copper_golem"
             MOVE L-AGE TO L-I(5)
             MOVE 0 TO L-I(6) L-I(7)
             PERFORM VARYING WS-J FROM 8 BY 1 UNTIL WS-J > 12
                 MOVE WS-STOP TO L-I(WS-J)
             END-PERFORM
             CALL "EM3-COPPER-ANIM" USING EMM-MODEL L-IN
         WHEN "zombie_villager"
             MOVE WS-BABY TO L-I(1)
             MOVE 1 TO L-I(2)
             MOVE 0 TO L-I(3) L-I(4)
             CALL "EM3-ZV-ARMS" USING EMM-MODEL L-IN
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-POSE-MORE.
