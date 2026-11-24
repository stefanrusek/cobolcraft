*> The effect component map of an enchantment (docs/protocol/28 section 2; US14; T2165): the 31 component types in registration order with the
*> shape of the value, the loot context set and the hook, and the registries of effect objects.
*> Shapes: 1 list of conditional effects, 2 list of targeted effects, 3 targeted effects of the drops form, 4 list of attribute effects, 5 single
*> value effect, 6 list of sounds, 7 list of charging sound records, 8 unit. Sets: 0 none, 1 ITEM, 2 ENTITY, 3 LOCATION, 4 DAMAGE, 5 HIT_BLOCK.
*>   TOOL-EFFECT-COMPONENT USING key (PIC X(48), no namespace), id out (0 to 30), shape out, set out, hook out (the H number: id + 1), found out
*>   TOOL-EFFECT-SET-COUNT USING set, components out; TOOL-EFFECT-SHAPE-COUNT USING shape, components out
*>   TOOL-EFFECT-TYPE-ID USING registry (1 value effects, 2 level-based values, 3 entity effects, 4 location effects), name, id out (-1 none)
*>   TOOL-EFFECT-RUNTIME-SET USING key, load-time set out, run-time set out (post_piercing_attack: DAMAGE at load, ENTITY at run time)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-COMPONENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 COMPONENT-ROWS.
    05 FILLER              PIC X(34) VALUE "damage_protection               14".
    05 FILLER              PIC X(34) VALUE "damage_immunity                 14".
    05 FILLER              PIC X(34) VALUE "damage                          14".
    05 FILLER              PIC X(34) VALUE "smash_damage_per_fallen_block   14".
    05 FILLER              PIC X(34) VALUE "knockback                       14".
    05 FILLER              PIC X(34) VALUE "armor_effectiveness             14".
    05 FILLER              PIC X(34) VALUE "post_attack                     24".
    05 FILLER              PIC X(34) VALUE "post_piercing_attack            14".
    05 FILLER              PIC X(34) VALUE "hit_block                       15".
    05 FILLER              PIC X(34) VALUE "item_damage                     11".
    05 FILLER              PIC X(34) VALUE "equipment_drops                 34".
    05 FILLER              PIC X(34) VALUE "location_changed                13".
    05 FILLER              PIC X(34) VALUE "tick                            12".
    05 FILLER              PIC X(34) VALUE "ammo_use                        11".
    05 FILLER              PIC X(34) VALUE "projectile_piercing             11".
    05 FILLER              PIC X(34) VALUE "projectile_spawned              12".
    05 FILLER              PIC X(34) VALUE "projectile_spread               12".
    05 FILLER              PIC X(34) VALUE "projectile_count                12".
    05 FILLER              PIC X(34) VALUE "trident_return_acceleration     12".
    05 FILLER              PIC X(34) VALUE "fishing_time_reduction          12".
    05 FILLER              PIC X(34) VALUE "fishing_luck_bonus              12".
    05 FILLER              PIC X(34) VALUE "block_experience                11".
    05 FILLER              PIC X(34) VALUE "mob_experience                  12".
    05 FILLER              PIC X(34) VALUE "repair_with_xp                  11".
    05 FILLER              PIC X(34) VALUE "attributes                      40".
    05 FILLER              PIC X(34) VALUE "crossbow_charge_time            50".
    05 FILLER              PIC X(34) VALUE "crossbow_charging_sounds        70".
    05 FILLER              PIC X(34) VALUE "trident_sound                   60".
    05 FILLER              PIC X(34) VALUE "prevent_equipment_drop          80".
    05 FILLER              PIC X(34) VALUE "prevent_armor_change            80".
    05 FILLER              PIC X(34) VALUE "trident_spin_attack_strength    50".
 01 COMPONENT-R REDEFINES COMPONENT-ROWS.
    05 COMPONENT-ROW OCCURS 31 TIMES.
       10 COMPONENT-NAME   PIC X(32).
       10 COMPONENT-SHAPE  PIC 9.
       10 COMPONENT-SET    PIC 9.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-HOOK                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID L-SHAPE L-SET L-HOOK L-FOUND.
     MOVE 0 TO L-ID L-SHAPE L-SET L-HOOK L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         IF L-KEY = COMPONENT-NAME(WS-I)
             COMPUTE L-ID = WS-I - 1
             MOVE COMPONENT-SHAPE(WS-I) TO L-SHAPE
             MOVE COMPONENT-SET(WS-I) TO L-SET
             MOVE WS-I TO L-HOOK
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-EFFECT-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-SET-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-HOOK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         CALL "TOOL-EFFECT-NTH" USING WS-I WS-KEY
         CALL "TOOL-EFFECT-COMPONENT" USING WS-KEY WS-ID WS-SHAPE WS-SET WS-HOOK WS-FOUND
         IF WS-SET = L-SET
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-EFFECT-SET-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-SHAPE-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-HOOK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         CALL "TOOL-EFFECT-NTH" USING WS-I WS-KEY
         CALL "TOOL-EFFECT-COMPONENT" USING WS-KEY WS-ID WS-SHAPE WS-SET WS-HOOK WS-FOUND
         IF WS-SHAPE = L-SHAPE
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-EFFECT-SHAPE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-NTH.
*> USING index (1 to 31), key out: the name of the component of that registration order position (the ids are positions).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 COMPONENT-ROWS.
    05 FILLER              PIC X(34) VALUE "damage_protection               14".
    05 FILLER              PIC X(34) VALUE "damage_immunity                 14".
    05 FILLER              PIC X(34) VALUE "damage                          14".
    05 FILLER              PIC X(34) VALUE "smash_damage_per_fallen_block   14".
    05 FILLER              PIC X(34) VALUE "knockback                       14".
    05 FILLER              PIC X(34) VALUE "armor_effectiveness             14".
    05 FILLER              PIC X(34) VALUE "post_attack                     24".
    05 FILLER              PIC X(34) VALUE "post_piercing_attack            14".
    05 FILLER              PIC X(34) VALUE "hit_block                       15".
    05 FILLER              PIC X(34) VALUE "item_damage                     11".
    05 FILLER              PIC X(34) VALUE "equipment_drops                 34".
    05 FILLER              PIC X(34) VALUE "location_changed                13".
    05 FILLER              PIC X(34) VALUE "tick                            12".
    05 FILLER              PIC X(34) VALUE "ammo_use                        11".
    05 FILLER              PIC X(34) VALUE "projectile_piercing             11".
    05 FILLER              PIC X(34) VALUE "projectile_spawned              12".
    05 FILLER              PIC X(34) VALUE "projectile_spread               12".
    05 FILLER              PIC X(34) VALUE "projectile_count                12".
    05 FILLER              PIC X(34) VALUE "trident_return_acceleration     12".
    05 FILLER              PIC X(34) VALUE "fishing_time_reduction          12".
    05 FILLER              PIC X(34) VALUE "fishing_luck_bonus              12".
    05 FILLER              PIC X(34) VALUE "block_experience                11".
    05 FILLER              PIC X(34) VALUE "mob_experience                  12".
    05 FILLER              PIC X(34) VALUE "repair_with_xp                  11".
    05 FILLER              PIC X(34) VALUE "attributes                      40".
    05 FILLER              PIC X(34) VALUE "crossbow_charge_time            50".
    05 FILLER              PIC X(34) VALUE "crossbow_charging_sounds        70".
    05 FILLER              PIC X(34) VALUE "trident_sound                   60".
    05 FILLER              PIC X(34) VALUE "prevent_equipment_drop          80".
    05 FILLER              PIC X(34) VALUE "prevent_armor_change            80".
    05 FILLER              PIC X(34) VALUE "trident_spin_attack_strength    50".
 01 COMPONENT-R REDEFINES COMPONENT-ROWS.
    05 COMPONENT-ROW OCCURS 31 TIMES.
       10 COMPONENT-NAME   PIC X(32).
       10 COMPONENT-SHAPE  PIC 9.
       10 COMPONENT-SET    PIC 9.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 PROCEDURE DIVISION USING L-INDEX L-KEY.
     MOVE COMPONENT-NAME(L-INDEX) TO L-KEY
     GOBACK.
 END PROGRAM TOOL-EFFECT-NTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-TYPE-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 VALUE-ROWS.
    05 FILLER              PIC X(24) VALUE "add".
    05 FILLER              PIC X(24) VALUE "all_of".
    05 FILLER              PIC X(24) VALUE "multiply".
    05 FILLER              PIC X(24) VALUE "remove_binomial".
    05 FILLER              PIC X(24) VALUE "exponential".
    05 FILLER              PIC X(24) VALUE "set".
 01 VALUE-R REDEFINES VALUE-ROWS.
    05 VALUE-NAME          PIC X(24) OCCURS 6 TIMES.
 01 LEVEL-ROWS.
    05 FILLER              PIC X(24) VALUE "clamped".
    05 FILLER              PIC X(24) VALUE "fraction".
    05 FILLER              PIC X(24) VALUE "levels_squared".
    05 FILLER              PIC X(24) VALUE "linear".
    05 FILLER              PIC X(24) VALUE "exponent".
    05 FILLER              PIC X(24) VALUE "lookup".
 01 LEVEL-R REDEFINES LEVEL-ROWS.
    05 LEVEL-NAME          PIC X(24) OCCURS 6 TIMES.
 01 ENTITY-ROWS.
    05 FILLER              PIC X(24) VALUE "all_of".
    05 FILLER              PIC X(24) VALUE "apply_mob_effect".
    05 FILLER              PIC X(24) VALUE "change_item_damage".
    05 FILLER              PIC X(24) VALUE "damage_entity".
    05 FILLER              PIC X(24) VALUE "explode".
    05 FILLER              PIC X(24) VALUE "ignite".
    05 FILLER              PIC X(24) VALUE "apply_impulse".
    05 FILLER              PIC X(24) VALUE "apply_exhaustion".
    05 FILLER              PIC X(24) VALUE "play_sound".
    05 FILLER              PIC X(24) VALUE "replace_block".
    05 FILLER              PIC X(24) VALUE "replace_disk".
    05 FILLER              PIC X(24) VALUE "run_function".
    05 FILLER              PIC X(24) VALUE "set_block_properties".
    05 FILLER              PIC X(24) VALUE "spawn_particles".
    05 FILLER              PIC X(24) VALUE "summon_entity".
 01 ENTITY-R REDEFINES ENTITY-ROWS.
    05 ENTITY-NAME         PIC X(24) OCCURS 15 TIMES.
 01 LOCATION-ROWS.
    05 FILLER              PIC X(24) VALUE "all_of".
    05 FILLER              PIC X(24) VALUE "apply_mob_effect".
    05 FILLER              PIC X(24) VALUE "attribute".
    05 FILLER              PIC X(24) VALUE "change_item_damage".
    05 FILLER              PIC X(24) VALUE "damage_entity".
    05 FILLER              PIC X(24) VALUE "explode".
    05 FILLER              PIC X(24) VALUE "ignite".
    05 FILLER              PIC X(24) VALUE "apply_impulse".
    05 FILLER              PIC X(24) VALUE "apply_exhaustion".
    05 FILLER              PIC X(24) VALUE "play_sound".
    05 FILLER              PIC X(24) VALUE "replace_block".
    05 FILLER              PIC X(24) VALUE "replace_disk".
    05 FILLER              PIC X(24) VALUE "run_function".
    05 FILLER              PIC X(24) VALUE "set_block_properties".
    05 FILLER              PIC X(24) VALUE "spawn_particles".
    05 FILLER              PIC X(24) VALUE "summon_entity".
 01 LOCATION-R REDEFINES LOCATION-ROWS.
    05 LOCATION-NAME       PIC X(24) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-NAME L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         EVALUATE L-REGISTRY
             WHEN 1
                 IF WS-I <= 6 AND L-NAME = VALUE-NAME(WS-I)
                     COMPUTE L-ID = WS-I - 1
                 END-IF
             WHEN 2
                 IF WS-I <= 6 AND L-NAME = LEVEL-NAME(WS-I)
                     COMPUTE L-ID = WS-I - 1
                 END-IF
             WHEN 3
                 IF WS-I <= 15 AND L-NAME = ENTITY-NAME(WS-I)
                     COMPUTE L-ID = WS-I - 1
                 END-IF
             WHEN OTHER
                 IF L-NAME = LOCATION-NAME(WS-I)
                     COMPUTE L-ID = WS-I - 1
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-EFFECT-TYPE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-EFFECT-RUNTIME-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-HOOK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-LOAD                 BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LOAD L-RUN.
     CALL "TOOL-EFFECT-COMPONENT" USING L-KEY WS-ID WS-SHAPE L-LOAD WS-HOOK WS-FOUND
     MOVE L-LOAD TO L-RUN
     IF L-KEY = "post_piercing_attack"
         MOVE 2 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM TOOL-EFFECT-RUNTIME-SET.
