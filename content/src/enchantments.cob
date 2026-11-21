*> The loader of the enchantment and damage type registries (T0286; docs/protocol/28-enchantment-effects.md sections 2 and 13,
*> 04 section 6 enchantment and damage_type, 17 sections 4.12 and 6.1, 23 section 2.1 rows 34 and 37).
*> ENCHANTMENTS-LOAD USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, CT-BAD-DATA; every error is on
*> standard error as "ERROR registry: ..." and nothing of the load stays). The files of data/<namespace>/enchantment/ and
*> data/<namespace>/damage_type/ are read by the registry loader of the shape engine (shapes.cob, CTSHAPE.cpy) and kept as
*> elements of its store; each is checked against the member list of its document:
*>   enchantment (04, 28 section 13): description (any value: a text component), supported_items (a holder set of items),
*>     primary_items and exclusive_set (optional holder sets), weight 1 to 1024, max_level 1 to 255, min_cost and max_cost
*>     (objects with the integers base and per_level_above_first), anvil_cost >= 0, slots (an array of identifiers, each one of
*>     the equipment slot groups of 28 section 7.4), effects (optional object whose keys are among the 31 effect component
*>     types of 28 section 2.2, with or without "minecraft:").
*>   damage_type (04, 17 section 4.12): message_id (string), scaling (never, when_caused_by_living_non_player or always),
*>     exhaustion (number), effects (optional: hurt, thorns, drowning, burning, poking or freezing), death_message_type
*>     (optional: default, fall_variants or intentional_game_design).
*> The equipment registry: the documents define no equipment data file for the data pack (08 section 8 marks the resource pack's
*> equipment/*.json as not read), so "equipment" here is the equipment slot groups an enchantment names (28 section 7.4), checked
*> member by member of slots.
*> The shape engine's enum form holds 40 bytes of values, so the enum members above and the slot groups and the effect keys are
*> checked by ENCHANT-ENUMS-CHECK after the shapes (same ERROR line form). Not checked (not stated by a document as a rule):
*> the content of an effect value (its shape is 28 sections 3 to 6, evaluated by the enchantment engine, not by this loader),
*> and that a supported_items tag exists (23 section 6 freezing is the registry loader's).
*> Documented assumptions: B1 damage_type exhaustion is required (04 section 6 table says Req) and unrestricted in range
*> (23 section 11 says no range); B2 description is accepted as any JSON value, since the text component forms of 00 section 9 are
*> not checked by any shape here; B3 the registries are loaded with the strict setting off (a nested object of an unregistered
*> type is accepted: effect values carry type members of 28 and are not shaped here).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCHANT-EFFECT-KEYS.
*> USING JSON-DOC, effects node (an object), element key (PIC X(112)): one error (WG-FAIL) for each member key that is not
*> one of the 31 effect component types of 28 section 2.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEYS.
    05 FILLER PIC X(40) VALUE "damage_protection".
    05 FILLER PIC X(40) VALUE "damage_immunity".
    05 FILLER PIC X(40) VALUE "damage".
    05 FILLER PIC X(40) VALUE "smash_damage_per_fallen_block".
    05 FILLER PIC X(40) VALUE "knockback".
    05 FILLER PIC X(40) VALUE "armor_effectiveness".
    05 FILLER PIC X(40) VALUE "post_attack".
    05 FILLER PIC X(40) VALUE "post_piercing_attack".
    05 FILLER PIC X(40) VALUE "hit_block".
    05 FILLER PIC X(40) VALUE "item_damage".
    05 FILLER PIC X(40) VALUE "equipment_drops".
    05 FILLER PIC X(40) VALUE "location_changed".
    05 FILLER PIC X(40) VALUE "tick".
    05 FILLER PIC X(40) VALUE "ammo_use".
    05 FILLER PIC X(40) VALUE "projectile_piercing".
    05 FILLER PIC X(40) VALUE "projectile_spawned".
    05 FILLER PIC X(40) VALUE "projectile_spread".
    05 FILLER PIC X(40) VALUE "projectile_count".
    05 FILLER PIC X(40) VALUE "trident_return_acceleration".
    05 FILLER PIC X(40) VALUE "fishing_time_reduction".
    05 FILLER PIC X(40) VALUE "fishing_luck_bonus".
    05 FILLER PIC X(40) VALUE "block_experience".
    05 FILLER PIC X(40) VALUE "mob_experience".
    05 FILLER PIC X(40) VALUE "repair_with_xp".
    05 FILLER PIC X(40) VALUE "attributes".
    05 FILLER PIC X(40) VALUE "crossbow_charge_time".
    05 FILLER PIC X(40) VALUE "crossbow_charging_sounds".
    05 FILLER PIC X(40) VALUE "trident_sound".
    05 FILLER PIC X(40) VALUE "prevent_equipment_drop".
    05 FILLER PIC X(40) VALUE "prevent_armor_change".
    05 FILLER PIC X(40) VALUE "trident_spin_attack_strength".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-NAME         PIC X(40) OCCURS 31 TIMES.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-CHILD               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME                PIC X(60).
 01 WS-SHORT               PIC X(60).
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY.
     SET ADDRESS OF B-TEXT TO JD-ADDR
     MOVE JN-FIRST(L-NODE) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0
         MOVE JN-KEY-POS(WS-CHILD) TO WS-POS
         MOVE JN-KEY-LENGTH(WS-CHILD) TO WS-LENGTH
         MOVE SPACES TO WS-NAME
         IF WS-LENGTH > 0 AND WS-LENGTH <= 60
             MOVE B-TEXT(WS-POS:WS-LENGTH) TO WS-NAME
         END-IF
         IF WS-NAME(1:10) = "minecraft:"
             MOVE SPACES TO WS-SHORT
             MOVE WS-NAME(11:) TO WS-SHORT
             MOVE WS-SHORT TO WS-NAME
         END-IF
         MOVE 0 TO WS-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
             IF WS-NAME = WS-KEY-NAME(WS-I)
                 MOVE 1 TO WS-OK
             END-IF
         END-PERFORM
         IF WS-OK = 0
             MOVE SPACES TO WS-DETAIL
             STRING "effects: unknown effect component " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-DETAIL
             CALL "WG-FAIL" USING L-KEY WS-DETAIL
         END-IF
         MOVE JN-NEXT(WS-CHILD) TO WS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM ENCHANT-EFFECT-KEYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCHANT-ENUM-VALUE.
*> USING JSON-DOC, string node, allowed (PIC X(200): the values, each between "|"), member name (PIC X(24)), element key
*> (PIC X(112)): one error (WG-FAIL) when the string is not one of the values.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(200).
 01 WS-PROBE               PIC X(204).
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ALLOWED              PIC X(200).
 01 L-MEMBER               PIC X(24).
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ALLOWED L-MEMBER L-KEY.
     MOVE SPACES TO WS-TEXT WS-PROBE
     CALL "JSON-STRING" USING JSON-DOC L-NODE WS-TEXT WS-CAPACITY WS-LENGTH
     STRING "|" FUNCTION TRIM(WS-TEXT) "|" DELIMITED BY SIZE INTO WS-PROBE
     MOVE 0 TO WS-COUNT
     INSPECT L-ALLOWED TALLYING WS-COUNT FOR ALL FUNCTION TRIM(WS-PROBE)
     IF WS-COUNT = 0
         MOVE SPACES TO WS-DETAIL
         STRING "member " FUNCTION TRIM(L-MEMBER) " is not one of " FUNCTION TRIM(L-ALLOWED) DELIMITED BY SIZE
             INTO WS-DETAIL
         CALL "WG-FAIL" USING L-KEY WS-DETAIL
     END-IF
     GOBACK.
 END PROGRAM ENCHANT-ENUM-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCHANT-ENUMS-CHECK.
*> No parameters: checks the enum members, the slot groups and the effect keys of the elements of the registries enchantment and
*> damage_type stored since SHAPE-BEGIN (the shapes have already vouched for their form). Errors are counted for SHAPE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 COPY JSONDOC.
 01 WS-CHECKS.
    05 FILLER PIC X(24) VALUE "damage_type".
    05 FILLER PIC X(24) VALUE "scaling".
    05 FILLER PIC X(200) VALUE "|never|when_caused_by_living_non_player|always|".
    05 FILLER PIC X(24) VALUE "damage_type".
    05 FILLER PIC X(24) VALUE "effects".
    05 FILLER PIC X(200) VALUE "|hurt|thorns|drowning|burning|poking|freezing|".
    05 FILLER PIC X(24) VALUE "damage_type".
    05 FILLER PIC X(24) VALUE "death_message_type".
    05 FILLER PIC X(200) VALUE "|default|fall_variants|intentional_game_design|".
    05 FILLER PIC X(24) VALUE "enchantment".
    05 FILLER PIC X(24) VALUE "slots".
    05 FILLER PIC X(200) VALUE "|any|mainhand|offhand|hand|feet|legs|chest|head|armor|body|saddle|".
 01 WS-CHECK-TABLE REDEFINES WS-CHECKS.
    05 WS-CHECK OCCURS 4 TIMES.
       10 WS-CHECK-REGISTRY PIC X(24).
       10 WS-CHECK-MEMBER   PIC X(24).
       10 WS-CHECK-ALLOWED  PIC X(200).
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-E                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-KEY                 PIC X(112).
 01 WS-REGISTRY            PIC X(24).
 01 WS-ALLOWED             PIC X(200).
 01 WS-LABEL-NAME          PIC X(24).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > SH-ELEMENT-COUNT
         IF WS-E > SH-MARK
             SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-E)
             MOVE SH-E-LENGTH(WS-E) TO WS-LENGTH
             MOVE SH-E-KEY(WS-E) TO WS-KEY
             MOVE SH-E-REGISTRY(WS-E) TO WS-REGISTRY
             MOVE SPACES TO WG-LABEL
             MOVE SH-E-REGISTRY(WS-E) TO WG-LABEL
             CALL "JSON-PARSE" USING JSON-DOC B-TEXT WS-LENGTH
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 IF WS-CHECK-REGISTRY(WS-J) = WS-REGISTRY
                     MOVE WS-CHECK-MEMBER(WS-J) TO WS-NAME
                     MOVE WS-CHECK-ALLOWED(WS-J) TO WS-ALLOWED
                     MOVE WS-CHECK-MEMBER(WS-J) TO WS-LABEL-NAME
                     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ONE WS-NAME WS-MEMBER
                     EVALUATE TRUE
                         WHEN WS-MEMBER = 0
                             CONTINUE
                         WHEN JN-TYPE(WS-MEMBER) = JT-STRING
                             CALL "ENCHANT-ENUM-VALUE" USING JSON-DOC WS-MEMBER WS-ALLOWED WS-LABEL-NAME WS-KEY
                         WHEN JN-TYPE(WS-MEMBER) = JT-ARRAY
                             MOVE JN-FIRST(WS-MEMBER) TO WS-CHILD
                             PERFORM UNTIL WS-CHILD = 0
                                 CALL "ENCHANT-ENUM-VALUE" USING JSON-DOC WS-CHILD WS-ALLOWED WS-LABEL-NAME WS-KEY
                                 MOVE JN-NEXT(WS-CHILD) TO WS-CHILD
                             END-PERFORM
                     END-EVALUATE
                 END-IF
             END-PERFORM
             IF WS-REGISTRY = "enchantment"
                 MOVE "effects" TO WS-NAME
                 CALL "RECIPE-MEMBER" USING JSON-DOC WS-ONE WS-NAME WS-MEMBER
                 IF WS-MEMBER > 0
                     IF JN-TYPE(WS-MEMBER) = JT-OBJECT
                         CALL "ENCHANT-EFFECT-KEYS" USING JSON-DOC WS-MEMBER WS-KEY
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENCHANT-ENUMS-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCHANTMENTS-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "enchantment".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "X description;H supported_items=item;h primary_items=item;I weight=1..1024;I max_level=1..255;T min_cost=enchantment_cost;T max_cost=enchantment_cost;I anvil_cost=0..;K slots;h exclusive_set=enchantment;o effects".
    05 FILLER PIC X(24) VALUE "enchantment_cost".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "I base;I per_level_above_first".
    05 FILLER PIC X(24) VALUE "damage_type".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "S message_id;S scaling;N exhaustion;s effects;s death_message_type".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 3.
 01 WS-ENCHANTMENT         PIC X(48) VALUE "enchantment".
 01 WS-ENCHANTMENT-GROUP   PIC X(24) VALUE "enchantment".
 01 WS-DAMAGE              PIC X(48) VALUE "damage_type".
 01 WS-DAMAGE-GROUP        PIC X(24) VALUE "damage_type".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-ENCHANTMENT WS-ENCHANTMENT-GROUP WS-LENIENT
     CALL "SHAPE-LOAD" USING L-DIR WS-DAMAGE WS-DAMAGE-GROUP WS-LENIENT
     CALL "ENCHANT-ENUMS-CHECK"
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM ENCHANTMENTS-LOAD.
