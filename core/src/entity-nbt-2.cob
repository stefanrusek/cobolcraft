*> Entity NBT, part 2 (docs/protocol/45-entity-nbt-2-living-entity-mob-animal.md sections 2, 3 and 7; lane 002-lane-p49k, T24510): the LivingEntity,
*> Mob and NeutralMob keys of a saved mob after its Health.
*>   LIVING-NBT-WRITE USING row, PB-BUFFER   HurtTime, DeathTime, AbsorptionAmount, current_impulse_context_reset_grace_time, attributes, active_effects
*>                                           (only with an effect), FallFlying, Brain, last_hurt_by_player and its memory time (only when set), the
*>                                           NeutralMob anger_end_time and angry_at of a bee, wolf, iron golem, polar bear, enderman or zombified piglin
*>   LIVING-NBT-KEY USING PB-BUFFER, tag type, name, LV-DATA, handled   reads active_effects, last_hurt_by_player(_memory_time), anger_end_time, angry_at
*>   LIVING-NBT-APPLY USING row, LV-DATA     puts them into the new mob
*>   MOB-EQUIP-WRITE USING row, species key, PB-BUFFER   the equipment compound: mainhand, head, chest, legs, feet, saddle and body (none when all empty)
*>   MOB-EQUIP-READ USING PB-BUFFER, MQ-DATA   reads it (the tag payload at PB-POS)
*> State in ENKEEP.cpy (lane 002-lane-p49m, entity-keep.cob): AbsorptionAmount, the impulse keys, attributes (the list kept as the file has it), the amplifier and
*> flags and hidden effect of an effect, the other effects, FallFlying, sleeping_pos, the Brain memories, last_hurt_by_mob, locator_bar_icon. No state in the core: HurtTime
*> and DeathTime (a mob dies at once) and the behaviour of the kept values (an attribute base, an amplifier, a hidden effect, a Brain memory change nothing the mob does).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVING-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENKEEP.
 COPY STDMOBS.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-KEY                 PIC X(24).
 01 WS-COUNT               BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-DURS.
    05 WS-DUR              BINARY-LONG OCCURS 6 TIMES.
 01 WS-ID                  PIC X(32).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
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
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL EK-ABSORB(L-ROW)
     MOVE "current_impulse_context_reset_grace_time" TO WN MOVE 40 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EK-GRACE(L-ROW)
     IF EK-IMPACT-ON(L-ROW) = 1
         MOVE "current_explosion_impact_pos" TO WN MOVE 28 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
         CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EK-IMPACT-X(L-ROW)
         CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EK-IMPACT-Y(L-ROW)
         CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EK-IMPACT-Z(L-ROW)
     END-IF
     MOVE "attributes" TO WN MOVE 10 TO WL
     IF EK-ATTR-LEN(L-ROW) > 0
         CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-LIST WN WL
         CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-ATTR-RAW(L-ROW) EK-ATTR-LEN(L-ROW)
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
     END-IF
     MOVE EN-FX-SPEED(L-ROW) TO WS-DUR(1)
     MOVE EN-FX-STRENGTH(L-ROW) TO WS-DUR(2)
     MOVE EN-FX-REGEN(L-ROW) TO WS-DUR(3)
     MOVE EN-FX-INVIS(L-ROW) TO WS-DUR(4)
     MOVE EN-FX-FIRE(L-ROW) TO WS-DUR(5)
     MOVE EN-FX-WATER(L-ROW) TO WS-DUR(6)
     MOVE EK-FXO-COUNT(L-ROW) TO WS-COUNT
     PERFORM VARYING WS-FX FROM 1 BY 1 UNTIL WS-FX > 6
         IF WS-DUR(WS-FX) NOT = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT > 0
         MOVE "active_effects" TO WN MOVE 14 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
         PERFORM VARYING WS-FX FROM 1 BY 1 UNTIL WS-FX > 6
             MOVE WS-DUR(WS-FX) TO WS-DURATION
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
                 MOVE EK-FX-AMP(L-ROW, WS-FX) TO WS-VALUE
                 IF WS-VALUE > 127
                     SUBTRACT 256 FROM WS-VALUE
                 END-IF
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
                 MOVE "duration" TO WN MOVE 8 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DURATION
                 MOVE "ambient" TO WN MOVE 7 TO WL
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EK-FX-AMBIENT(L-ROW, WS-FX)
                 MOVE "show_particles" TO WN MOVE 14 TO WL
                 COMPUTE WS-VALUE = 1 - EK-FX-NOPART(L-ROW, WS-FX)
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
                 MOVE "show_icon" TO WN MOVE 9 TO WL
                 COMPUTE WS-VALUE = 1 - EK-FX-NOICON(L-ROW, WS-FX)
                 CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
                 IF EK-FX-HID-LEN(L-ROW, WS-FX) > 0
                     MOVE "hidden_effect" TO WN MOVE 13 TO WL
                     CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-COMPOUND WN WL
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-FX-HID-RAW(L-ROW, WS-FX) EK-FX-HID-LEN(L-ROW, WS-FX)
                 END-IF
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-IF
         END-PERFORM
         IF EK-FXO-LEN(L-ROW) > 0
             CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-FXO-RAW(L-ROW) EK-FXO-LEN(L-ROW)
         END-IF
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-IF
     MOVE "FallFlying" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EK-FALLFLY(L-ROW)
     IF EK-SLEEP-ON(L-ROW) = 1
         MOVE "sleeping_pos" TO WN MOVE 12 TO WL
         MOVE EK-SLEEP-X(L-ROW) TO WS-INT(1)
         MOVE EK-SLEEP-Y(L-ROW) TO WS-INT(2)
         MOVE EK-SLEEP-Z(L-ROW) TO WS-INT(3)
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE WS-INTS
     END-IF
     MOVE "Brain" TO WN MOVE 5 TO WL
     IF EK-BRAIN-LEN(L-ROW) > 0
         CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-COMPOUND WN WL
         CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-BRAIN-RAW(L-ROW) EK-BRAIN-LEN(L-ROW)
     ELSE
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "memories" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF EN-KILLER(L-ROW) > 0
         IF PL-USED(EN-KILLER(L-ROW)) = 1
             MOVE "last_hurt_by_player" TO WN MOVE 19 TO WL
             CALL "PERSIST-UUID-INTS" USING WS-DIRECTION PL-UUID(EN-KILLER(L-ROW)) WS-INTS
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
             MOVE "last_hurt_by_player_memory_time" TO WN MOVE 31 TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-KILLER-AGE(L-ROW)
         END-IF
     END-IF
     IF EK-HURTMOB(L-ROW) NOT = SPACES
         MOVE "last_hurt_by_mob" TO WN MOVE 16 TO WL
         CALL "PERSIST-UUID-INTS" USING WS-DIRECTION EK-HURTMOB(L-ROW) WS-INTS
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
         MOVE "ticks_since_last_hurt_by_mob" TO WN MOVE 28 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EK-HURTMOB-TICKS(L-ROW)
     END-IF
     IF EK-LOCATOR-LEN(L-ROW) > 0
         MOVE "locator_bar_icon" TO WN MOVE 16 TO WL
         CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-COMPOUND WN WL
         CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-LOCATOR-RAW(L-ROW) EK-LOCATOR-LEN(L-ROW)
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
 END PROGRAM LIVING-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVING-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-ID-CAPACITY         BINARY-LONG VALUE 48.
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY LVDATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME LV-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "active_effects" AND L-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 MOVE SPACES TO WS-ID
                 MOVE 0 TO WS-DURATION
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
                     IF WS-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "id" AND WS-TYPE = 8
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-ID-CAPACITY WS-ID-LENGTH
                         WHEN WN = "duration" AND WS-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-DURATION
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                     END-EVALUATE
                 END-PERFORM
                 EVALUATE WS-ID
                     WHEN "minecraft:speed" MOVE WS-DURATION TO LV-FX-SPEED
                     WHEN "minecraft:strength" MOVE WS-DURATION TO LV-FX-STRENGTH
                     WHEN "minecraft:regeneration" MOVE WS-DURATION TO LV-FX-REGEN
                     WHEN "minecraft:invisibility" MOVE WS-DURATION TO LV-FX-INVIS
                     WHEN "minecraft:fire_resistance" MOVE WS-DURATION TO LV-FX-FIRE
                     WHEN "minecraft:water_breathing" MOVE WS-DURATION TO LV-FX-WATER
                 END-EVALUATE
             END-PERFORM
         WHEN L-NAME = "last_hurt_by_player" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 4
                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID LV-KILLER WS-INTS
             END-IF
         WHEN L-NAME = "last_hurt_by_player_memory_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER LV-KILLER-AGE
         WHEN L-NAME = "anger_end_time" AND L-TYPE = 4
             CALL "PB-GET-LONG" USING PB-BUFFER LV-ANGER-END
             MOVE 1 TO LV-ANGER-SET
         WHEN L-NAME = "angry_at" AND L-TYPE = 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY WS-INT-COUNT WS-INTS
             IF WS-INT-COUNT = 4
                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID LV-ANGRY-AT WS-INTS
             END-IF
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM LIVING-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIVING-NBT-APPLY.
*> The effects replace the row's; the killer is the player of that UUID in the mob's dimension; an anger end time still ahead of the game time becomes
*> the ticks left (EN-ANGER), its target the player of the angry_at UUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY LVDATA.
 PROCEDURE DIVISION USING L-ROW LV-DATA.
     MOVE LV-FX-SPEED TO EN-FX-SPEED(L-ROW)
     MOVE LV-FX-STRENGTH TO EN-FX-STRENGTH(L-ROW)
     MOVE LV-FX-REGEN TO EN-FX-REGEN(L-ROW)
     MOVE LV-FX-INVIS TO EN-FX-INVIS(L-ROW)
     MOVE LV-FX-FIRE TO EN-FX-FIRE(L-ROW)
     MOVE LV-FX-WATER TO EN-FX-WATER(L-ROW)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND LV-KILLER NOT = SPACES AND PL-UUID(WS-P) = LV-KILLER
             MOVE WS-P TO EN-KILLER(L-ROW)
             MOVE LV-KILLER-AGE TO EN-KILLER-AGE(L-ROW)
         END-IF
     END-PERFORM
     IF LV-ANGER-SET = 1
         COMPUTE WS-NOW = CW-GAME-TIME + CW-TICKS
         MOVE 0 TO EN-ANGER(L-ROW)
         IF LV-ANGER-END > WS-NOW
             COMPUTE EN-ANGER(L-ROW) = LV-ANGER-END - WS-NOW
         END-IF
     END-IF
     IF EN-ANGER(L-ROW) > 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND LV-ANGRY-AT NOT = SPACES AND PL-UUID(WS-P) = LV-ANGRY-AT
                 MOVE WS-P TO EN-TARGET(L-ROW)
                 MOVE PL-ENTITY-ID(WS-P) TO EN-TARGET-ID(L-ROW)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM LIVING-NBT-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EQUIP-ITEM-WRITE.
*> USING PB-BUFFER, slot name (PIC X(8)), name length, item key (PIC X(40)), damage (BINARY-LONG, 0 none): one slot of the equipment compound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLOT                 PIC X(8).
 01 L-SLOT-LENGTH          BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SLOT L-SLOT-LENGTH L-KEY L-DAMAGE.
     MOVE L-SLOT TO WN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN L-SLOT-LENGTH
     MOVE "id" TO WN MOVE 2 TO WL
     COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL L-KEY WS-KEY-LENGTH
     MOVE "count" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-ONE
     IF L-DAMAGE > 0
         MOVE "components" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "minecraft:damage" TO WN MOVE 16 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL L-DAMAGE
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM EQUIP-ITEM-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQUIP-WRITE.
*> The saddle (EN-SADDLE) of the species that wear one and the body slot of a mount (WC-BODY of WCSTATE.cpy: horse armor, llama carpet, nautilus armor; 45-4 section 6.1: equipment.saddle and
*> equipment.body, no SaddleItem or ArmorItem key) are written after the armour and the wolf's body item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY CITEMS.
 01 WS-MOUNT               BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HAND-KEY            PIC X(40).
 01 WS-ITEM-KEY            PIC X(40).
 01 WS-SLOT                PIC X(8).
 01 WS-SLOT-LENGTH         BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SADDLED             BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 01 WS-BODY-COUNT          BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW L-KEY PB-BUFFER.
     MOVE 0 TO WS-SLOTS WS-TIER WS-SADDLED
     IF EN-EQUIP(L-ROW) > 0
         COMPUTE WS-TIER = EN-EQUIP(L-ROW) / 10 - 1
         COMPUTE WS-SLOTS = FUNCTION MOD(EN-EQUIP(L-ROW), 10)
     END-IF
     CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-HAND-KEY
     IF EN-SADDLE(L-ROW) = 1 AND (L-KEY = "pig" OR "horse" OR "donkey" OR "mule" OR "camel" OR "camel_husk" OR "skeleton_horse" OR "zombie_horse" OR "nautilus" OR "zombie_nautilus")
         MOVE 1 TO WS-SADDLED
     END-IF
     MOVE 0 TO WS-BODY
     CALL "MNT-KIND" USING L-ROW WS-MOUNT
     IF WS-MOUNT > 0
         CALL "WC-ROW-OPEN" USING L-ROW
         MOVE WC-BODY(L-ROW) TO WS-BODY
     END-IF
     MOVE 0 TO WS-ANY
     IF WS-SLOTS > 0 OR WS-HAND-KEY NOT = SPACES OR WS-SADDLED = 1 OR WS-BODY > 0 OR (L-KEY = "wolf" AND EN-WOLF-ARM(L-ROW) > 0)
         MOVE 1 TO WS-ANY
     END-IF
     IF WS-ANY = 0
         GOBACK
     END-IF
     MOVE "equipment" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     IF WS-HAND-KEY NOT = SPACES
         MOVE "mainhand" TO WS-SLOT MOVE 8 TO WS-SLOT-LENGTH
         CALL "EQUIP-ITEM-WRITE" USING PB-BUFFER WS-SLOT WS-SLOT-LENGTH WS-HAND-KEY WS-ZERO
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SLOTS
         CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-I WS-ITEM-KEY
         MOVE 0 TO WS-DAMAGE
         EVALUATE WS-I
             WHEN 1 MOVE "head" TO WS-SLOT MOVE 4 TO WS-SLOT-LENGTH
             WHEN 2 MOVE "chest" TO WS-SLOT MOVE 5 TO WS-SLOT-LENGTH
             WHEN 3 MOVE "legs" TO WS-SLOT MOVE 4 TO WS-SLOT-LENGTH
             WHEN OTHER MOVE "feet" TO WS-SLOT MOVE 4 TO WS-SLOT-LENGTH
         END-EVALUATE
         IF WS-I = 1 AND EN-HEAD-WEAR(L-ROW) > 0
             MOVE EN-HEAD-WEAR(L-ROW) TO WS-DAMAGE
         END-IF
         IF NOT (WS-I = 1 AND EN-HEAD-WEAR(L-ROW) = -1)
             CALL "EQUIP-ITEM-WRITE" USING PB-BUFFER WS-SLOT WS-SLOT-LENGTH WS-ITEM-KEY WS-DAMAGE
         END-IF
     END-PERFORM
     IF L-KEY = "wolf" AND EN-WOLF-ARM(L-ROW) > 0
         MOVE "body" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "id" TO WN MOVE 2 TO WL
         COMPUTE WS-VALUE = EN-WOLF-ARM(L-ROW) + 1
         CALL "PERSIST-NAMESPACED" USING IT-KEY(WS-VALUE) IT-KEY-LENGTH(WS-VALUE) WS-NS-KEY WS-NS-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
         MOVE "count" TO WN MOVE 5 TO WL
         MOVE 1 TO WS-VALUE
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
         MOVE "components" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "minecraft:damage" TO WN MOVE 16 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-WOLF-ARM-DMG(L-ROW)
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
*>   The body item is a whole stack: id, count and the components of its patch (WC-BODY-VAR; the binding curse of 28 section 4 effect 29 lives there).
     IF WS-BODY > 0
         MOVE "body" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "KX-PATCH-KEEP" USING WC-BODY-VAR(L-ROW) WS-KP
         CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-BODY WS-BODY-COUNT WS-KP
         CALL "KX-PATCH-FREE" USING WS-KP
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF WS-SADDLED = 1
         MOVE "saddle" TO WS-SLOT MOVE 6 TO WS-SLOT-LENGTH
         MOVE "minecraft:saddle" TO WS-ITEM-KEY
         CALL "EQUIP-ITEM-WRITE" USING PB-BUFFER WS-SLOT WS-SLOT-LENGTH WS-ITEM-KEY WS-ZERO
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-EQUIP-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQUIP-READ.
*> USING PB-BUFFER (at the payload of an equipment compound), MQ-DATA: the saddle (a slot present), the body slot (item and damage), the main hand (EN-HAND
*> code of the item), and the armour: the tier of the pieces present and the count of slots from the head (a missing head with other pieces is a broken helmet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-START               BINARY-LONG.
 01 WS-CONTAINER           BINARY-LONG VALUE 10.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PATH                PIC X(48).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LOCAL               PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-FULL                PIC X(40).
 01 WS-WANT                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-HEAD-PRESENT        BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-TYPE-TEN            BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 COPY PROTO.
 COPY ENMOBDATA.
 PROCEDURE DIVISION USING PB-BUFFER MQ-DATA.
     MOVE PB-POS TO WS-START
     MOVE "saddle" TO WS-PATH
     MOVE 6 TO WS-PATH-LENGTH
     CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
     IF WS-FOUND = 10
         MOVE 1 TO MQ-SADDLE
     END-IF
     MOVE WS-START TO PB-POS
     MOVE "body.id" TO WS-PATH
     MOVE 7 TO WS-PATH-LENGTH
     CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
     IF WS-FOUND = 8
         MOVE SPACES TO WS-KEY
         CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
         CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
         CALL "KEY-BARE" USING WS-LOCAL WS-BARE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
             IF IT-KEY(WS-I) = WS-LOCAL OR IT-KEY(WS-I) = WS-BARE
                 COMPUTE MQ-BODY = WS-I - 1
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-START TO PB-POS
     MOVE "body.components.minecraft:damage" TO WS-PATH
     MOVE 32 TO WS-PATH-LENGTH
     CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
     IF WS-FOUND = 3
         CALL "PB-GET-INT" USING PB-BUFFER MQ-BODY-DMG
     END-IF
*>   The main hand.
     MOVE WS-START TO PB-POS
     MOVE "mainhand.id" TO WS-PATH
     MOVE 11 TO WS-PATH-LENGTH
     CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
     IF WS-FOUND = 8
         MOVE SPACES TO WS-KEY
         CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
         MOVE SPACES TO WS-FULL
         MOVE WS-KEY TO WS-FULL
         PERFORM VARYING WS-CODE FROM 1 BY 1 UNTIL WS-CODE > 10
             CALL "STDMOB-HAND-KEY" USING WS-CODE WS-WANT
             IF WS-WANT NOT = SPACES AND WS-WANT = WS-FULL
                 MOVE WS-CODE TO MQ-HAND
             END-IF
         END-PERFORM
     END-IF
*>   The armour: one slot name at a time, head first.
     MOVE 0 TO WS-LAST WS-HEAD-PRESENT WS-TIER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-START TO PB-POS
         EVALUATE WS-I
             WHEN 1 MOVE "head.id" TO WS-PATH MOVE 7 TO WS-PATH-LENGTH
             WHEN 2 MOVE "chest.id" TO WS-PATH MOVE 8 TO WS-PATH-LENGTH
             WHEN 3 MOVE "legs.id" TO WS-PATH MOVE 7 TO WS-PATH-LENGTH
             WHEN OTHER MOVE "feet.id" TO WS-PATH MOVE 7 TO WS-PATH-LENGTH
         END-EVALUATE
         CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
         IF WS-FOUND = 8
             MOVE SPACES TO WS-KEY
             CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
             MOVE SPACES TO WS-FULL
             MOVE WS-KEY TO WS-FULL
             PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 5
                 CALL "STDMOB-EQUIP-KEY" USING WS-T WS-I WS-WANT
                 IF WS-WANT = WS-FULL
                     MOVE WS-T TO WS-TIER
                     MOVE WS-I TO WS-LAST
                     IF WS-I = 1
                         MOVE 1 TO WS-HEAD-PRESENT
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF WS-LAST > 0
         COMPUTE MQ-EQUIP = 10 * (WS-TIER + 1) + WS-LAST
     END-IF
     IF WS-LAST > 0 AND WS-HEAD-PRESENT = 0
         MOVE -1 TO MQ-HEAD-WEAR
     END-IF
     IF WS-HEAD-PRESENT = 1
         MOVE WS-START TO PB-POS
         MOVE "head.components.minecraft:damage" TO WS-PATH
         MOVE 32 TO WS-PATH-LENGTH
         CALL "NBT-READ-FIND" USING PB-BUFFER WS-CONTAINER WS-PATH WS-PATH-LENGTH WS-FOUND
         IF WS-FOUND = 3
             CALL "PB-GET-INT" USING PB-BUFFER MQ-HEAD-WEAR
         END-IF
     END-IF
     MOVE WS-START TO PB-POS
     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE-TEN
     GOBACK.
 END PROGRAM MOB-EQUIP-READ.
