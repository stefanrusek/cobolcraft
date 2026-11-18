*> Entity NBT, part 2 (docs/protocol/45-entity-nbt-2-living-entity-mob-animal.md sections 2, 3 and 7; lane 002-lane-p49k, T24510): the LivingEntity,
*> Mob and NeutralMob keys of a saved mob after its Health.
*>   LIVING-NBT-WRITE USING row, PB-BUFFER   HurtTime, DeathTime, AbsorptionAmount, current_impulse_context_reset_grace_time, attributes, active_effects
*>                                           (only with an effect), FallFlying, Brain, last_hurt_by_player and its memory time (only when set), the
*>                                           NeutralMob anger_end_time and angry_at of a bee, wolf, iron golem, polar bear, enderman or zombified piglin
*>   LIVING-NBT-KEY USING PB-BUFFER, tag type, name, LV-DATA, handled   reads active_effects, last_hurt_by_player(_memory_time), anger_end_time, angry_at
*>   LIVING-NBT-APPLY USING row, LV-DATA     puts them into the new mob
*>   MOB-EQUIP-WRITE USING row, species key, PB-BUFFER   the equipment compound: mainhand, head, chest, legs, feet, saddle and body (none when all empty)
*>   MOB-EQUIP-READ USING PB-BUFFER, MQ-DATA   reads it (the tag payload at PB-POS)
*> No state in the core: HurtTime and DeathTime (a mob dies at once), AbsorptionAmount, the attribute list (written empty: no permanent modifiers),
*> Brain memories (written empty), FallFlying, sleeping_pos, current_explosion_impact_pos, ticks_since_last_hurt_by_mob, locator_bar_icon, drop_chances,
*> home_*, DeathLootTable, NoAI: written at their defaults where the table says always, read and ignored.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVING-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-FLOAT               FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(24).
 01 WS-COUNT               BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-ID                  PIC X(32).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG VALUE 0.
 01 WS-END                 BINARY-DOUBLE.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE "HurtTime" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-ZERO
     MOVE "DeathTime" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-ZERO
     MOVE "AbsorptionAmount" TO WN MOVE 16 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
     MOVE "current_impulse_context_reset_grace_time" TO WN MOVE 40 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ZERO
     MOVE "attributes" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-FX FROM 1 BY 1 UNTIL WS-FX > 6
         PERFORM LIVING-DURATION
         IF WS-DURATION NOT = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT > 0
         MOVE "active_effects" TO WN MOVE 14 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         PERFORM VARYING WS-FX FROM 1 BY 1 UNTIL WS-FX > 6
             PERFORM LIVING-DURATION
             IF WS-DURATION NOT = 0
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                 MOVE "id" TO WN MOVE 2 TO WL
                 EVALUATE WS-FX
                     WHEN 1 MOVE "minecraft:speed" TO WS-ID MOVE 15 TO WS-ID-LENGTH
                     WHEN 2 MOVE "minecraft:strength" TO WS-ID MOVE 18 TO WS-ID-LENGTH
                     WHEN 3 MOVE "minecraft:regeneration" TO WS-ID MOVE 22 TO WS-ID-LENGTH
                     WHEN 4 MOVE "minecraft:invisibility" TO WS-ID MOVE 22 TO WS-ID-LENGTH
                     WHEN 5 MOVE "minecraft:fire_resistance" TO WS-ID MOVE 25 TO WS-ID-LENGTH
                     WHEN OTHER MOVE "minecraft:water_breathing" TO WS-ID MOVE 25 TO WS-ID-LENGTH
                 END-EVALUATE
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID WS-ID-LENGTH
                 MOVE "amplifier" TO WN MOVE 9 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
                 MOVE "duration" TO WN MOVE 8 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DURATION
                 MOVE "ambient" TO WN MOVE 7 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
                 MOVE "show_particles" TO WN MOVE 14 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
                 MOVE "show_icon" TO WN MOVE 9 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-IF
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-IF
     MOVE "FallFlying" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ZERO
     MOVE "Brain" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "memories" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     IF EN-KILLER(L-ROW) > 0
         IF PL-USED(EN-KILLER(L-ROW)) = 1
             MOVE "last_hurt_by_player" TO WN MOVE 19 TO WL
             CALL "PERSIST-UUID-INTS" USING WS-DIRECTION PL-UUID(EN-KILLER(L-ROW)) WS-INTS
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
             MOVE "last_hurt_by_player_memory_time" TO WN MOVE 31 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-KILLER-AGE(L-ROW)
         END-IF
     END-IF
*>   NeutralMob: the end of the anger as game time, -1 when calm; the angry-at player while it lasts.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "bee" OR "wolf" OR "iron_golem" OR "polar_bear" OR "enderman" OR "zombified_piglin"
         MOVE "anger_end_time" TO WN MOVE 14 TO WL
         MOVE -1 TO WS-END
         IF EN-ANGER(L-ROW) > 0
             COMPUTE WS-END = CW-GAME-TIME + CW-TICKS + EN-ANGER(L-ROW)
         END-IF
         CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-END
         IF EN-ANGER(L-ROW) > 0 AND EN-TARGET(L-ROW) > 0
             IF PL-USED(EN-TARGET(L-ROW)) = 1
                 MOVE "angry_at" TO WN MOVE 8 TO WL
                 CALL "PERSIST-UUID-INTS" USING WS-DIRECTION PL-UUID(EN-TARGET(L-ROW)) WS-INTS
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
             END-IF
         END-IF
     END-IF
     GOBACK.
 LIVING-DURATION.
     EVALUATE WS-FX
         WHEN 1 MOVE EN-FX-SPEED(L-ROW) TO WS-DURATION
         WHEN 2 MOVE EN-FX-STRENGTH(L-ROW) TO WS-DURATION
         WHEN 3 MOVE EN-FX-REGEN(L-ROW) TO WS-DURATION
         WHEN 4 MOVE EN-FX-INVIS(L-ROW) TO WS-DURATION
         WHEN 5 MOVE EN-FX-FIRE(L-ROW) TO WS-DURATION
         WHEN OTHER MOVE EN-FX-WATER(L-ROW) TO WS-DURATION
     END-EVALUATE.
 END PROGRAM LIVING-NBT-WRITE.
