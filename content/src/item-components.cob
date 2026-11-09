*> The default item components of the content library (T0284; content-api section 2, CONTENT-ITEM-COMPONENT; 17 sections 1.3,
*> 1.4 and 2.1 to 2.5 for the standard set, cobolcraft-standard-core.md section 5.3 for the cobolcraft items).
*> CONTENT-ITEM-COMPONENT (items.cob) first looks a component up in the row's own summary (the entries of the generated
*> table, or of the built-in layer); when the row has none of that name it calls ITEM-DEFAULT-COMPONENT, which derives the
*> component from the item's kind and material as the builders of 17 section 1.4 fill them. So the summary of a row
*> always wins (the turtle helmet's repairable and equippable entries, the fire_resistant marker of netherite).
*>
*> The values (all text, a decimal with one place for a float: "6.0", "-2.4"):
*>   tools (the 35 swords, pickaxes, axes, shovels and hoes of 17 section 2.2 and 2.3):
*>     tool                    the first rule that carries a speed: "<block set> <speed>" ("minecraft:cobweb 15.0" for a sword,
*>                             "#minecraft:mineable/<kind> <material speed>" for the others)
*>     tool_rule_1 .. 3        the rules in order (1.4): "deny <tag>" (a rule with correct_for_drops false: the material's
*>                             incorrect_for_<material>_tool tag), "mine <block set> <speed>" (speed and correct_for_drops true),
*>                             "speed <block set> <speed>" (a speed only); a pickaxe, axe, shovel and hoe has deny then mine, a
*>                             sword has the cobweb mine rule, the sword_instantly_mines rule and the sword_efficient rule
*>     tool_default_speed      "1.0"; tool_damage_per_block "2" for a sword and "1" else; tool_creative_break "0" for a sword
*>                             (can_destroy_blocks_in_creative false) and "1" else
*>     attack_damage, attack_speed   the amounts of the two mainhand modifiers (1.3): the registered damage plus the material's
*>                             attack bonus (the builder adds it, 2.1), and the registered speed modifier; the item's attack
*>                             damage is 1 + attack_damage and its attack speed 4 + attack_speed
*>     weapon                  item_damage_per_attack: "1" for a sword, "2" for the others (1.4)
*>     weapon_disable_blocking disable_blocking_for_seconds: "5.0" for an axe, "0.0" else (1.3)
*>     enchantable, repairable the material's enchantability (2.1) and repair ingredient (an item key, or "#" and a tag)
*>   armor (leather, copper, chainmail, iron, golden, diamond and netherite helmets, chestplates, leggings and boots, and the
*>   turtle helmet; 17 section 2.5):
*>     armor, armor_toughness, armor_knockback_resistance (netherite only, "0.1"), equippable (head, chest, legs, feet),
*>     equippable_damage_on_hurt ("1": armor true, 1.4), enchantable, repairable
*>   cobolcraft tools (standard-core 5.3; no durability, no enchantable, no repairable): tool_rule_1 "mine <set> <speed>",
*>   tool_default_speed "1.0", tool_damage_per_block "1", tool_creative_break "1" and, when the row has a weapon entry,
*>   weapon_disable_blocking "0.0"; tool, attack_damage, attack_speed and weapon are entries of the row's summary.
*> max_stack_size and max_damage are columns of the row (CONTENT-ITEM-COMPONENT itself).
*>
*> Documented assumptions (no document states the member name or rule):
*>   A1  The component names tool_rule_1 to 3, tool_default_speed, tool_damage_per_block, tool_creative_break,
*>       attack_damage, attack_speed, weapon_disable_blocking, armor, armor_toughness, armor_knockback_resistance,
*>       equippable_damage_on_hurt are names chosen here; 17 names the underlying fields (tool rules, default_mining_speed,
*>       damage_per_block, can_destroy_blocks_in_creative, attribute modifiers, disable_blocking_for_seconds, armor
*>       attributes, damage_on_hurt) but gives no flat name, and the value formats above are chosen here.
*>   A2  attack_damage is the modifier amount (registered damage + material bonus), as the cobolcraft summary's
*>       "attack_damage 3.0" already is (standard-core 5.3: the amount, the item's damage is 1 + amount).
*>   A3  17 section 2.1 lists an incorrect_for_diamond_tool and an incorrect_for_netherite_tool tag although those deny
*>       nothing; the deny rule is still given (1.4 builds it for every material), its tag being empty.
*>   A4  The golden material's deny tag is incorrect_for_gold_tool (17 section 2.1 table), its repair item gold_ingot.
*>   A5  Not covered: spears (2.4), the special tools of 2.6 (mace, trident, shears, bow, ...), horse, wolf and nautilus
*>       armor, block_transformer of the axe, shovel and hoe, and the elytra; they answer "not found" unless the row's summary
*>       has the entry. The wolf/animal body armor values of 2.5 are not read.
*>   A6  The cobolcraft rule block set and speed are read from the first summary entry "tool ..." of the row (standard-core
*>       5.2 puts it first); a cobolcraft item without a tool entry has none of the tool defaults.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-TENTHS.
*> USING value in tenths (BINARY-LONG), text out (PIC X(12)): "-2.4", "0.0", "12.0".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(6)9.9.
 LINKAGE SECTION.
 01 L-TENTHS               BINARY-LONG.
 01 L-TEXT                 PIC X(12).
 PROCEDURE DIVISION USING L-TENTHS L-TEXT.
     COMPUTE WS-EDIT = L-TENTHS / 10
     MOVE FUNCTION TRIM(WS-EDIT) TO L-TEXT
     GOBACK.
 END PROGRAM ITEM-TENTHS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-TOOL-COMPONENT.
*> USING tool line (PIC X(26): "<item key>|<registered damage in tenths>|<registered speed modifier in tenths>"), name (PIC X(32)),
*> value out (PIC X(100)), status out (CT-OK, or the status as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-MATERIALS.
    05 FILLER PIC X(80) VALUE "wooden|0|15|2|#minecraft:wooden_tool_materials|wooden".
    05 FILLER PIC X(80) VALUE "stone|1|5|4|#minecraft:stone_tool_materials|stone".
    05 FILLER PIC X(80) VALUE "copper|1|13|5|minecraft:copper_ingot|copper".
    05 FILLER PIC X(80) VALUE "iron|2|14|6|minecraft:iron_ingot|iron".
    05 FILLER PIC X(80) VALUE "golden|0|22|12|minecraft:gold_ingot|gold".
    05 FILLER PIC X(80) VALUE "diamond|3|10|8|minecraft:diamond|diamond".
    05 FILLER PIC X(80) VALUE "netherite|4|15|9|minecraft:netherite_ingot|netherite".
 01 WS-MATERIAL-TABLE REDEFINES WS-MATERIALS.
    05 WS-MATERIAL-LINE    PIC X(80) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(26).
 01 WS-MATERIAL            PIC X(12).
 01 WS-KIND                PIC X(12).
 01 WS-DAMAGE-TEXT         PIC X(8).
 01 WS-SPEED-TEXT          PIC X(8).
 01 WS-NAME                PIC X(12).
 01 WS-BONUS               BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-MINING              BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 01 WS-TAG                 PIC X(12).
 01 WS-BONUS-TEXT          PIC X(8).
 01 WS-ENCHANT-TEXT        PIC X(8).
 01 WS-MINING-TEXT         PIC X(8).
 01 WS-TENTHS              BINARY-LONG.
 01 WS-TEXT                PIC X(12).
 01 WS-EDIT                PIC Z(5)9.
 LINKAGE SECTION.
 01 L-LINE                 PIC X(26).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-LINE L-NAME L-VALUE L-STATUS.
     MOVE SPACES TO WS-KEY WS-DAMAGE-TEXT WS-SPEED-TEXT
     UNSTRING L-LINE DELIMITED BY "|" INTO WS-KEY WS-DAMAGE-TEXT WS-SPEED-TEXT
     MOVE SPACES TO WS-MATERIAL WS-KIND
     UNSTRING WS-KEY DELIMITED BY "_" INTO WS-MATERIAL WS-KIND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-NAME WS-BONUS-TEXT WS-ENCHANT-TEXT WS-MINING-TEXT WS-REPAIR WS-TAG
         UNSTRING WS-MATERIAL-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-BONUS-TEXT WS-ENCHANT-TEXT
             WS-MINING-TEXT WS-REPAIR WS-TAG
         IF WS-NAME = WS-MATERIAL
             COMPUTE WS-BONUS = FUNCTION NUMVAL(WS-BONUS-TEXT)
             COMPUTE WS-ENCHANT = FUNCTION NUMVAL(WS-ENCHANT-TEXT)
             COMPUTE WS-MINING = FUNCTION NUMVAL(WS-MINING-TEXT)
             MOVE 7 TO WS-I
         END-IF
     END-PERFORM
     COMPUTE WS-TENTHS = WS-MINING * 10
     CALL "ITEM-TENTHS" USING WS-TENTHS WS-TEXT
     MOVE CT-OK TO L-STATUS
     MOVE SPACES TO L-VALUE
     EVALUATE TRUE
         WHEN L-NAME = "tool" AND WS-KIND = "sword"
             MOVE "minecraft:cobweb 15.0" TO L-VALUE
         WHEN L-NAME = "tool"
             STRING "#minecraft:mineable/" FUNCTION TRIM(WS-KIND) " " FUNCTION TRIM(WS-TEXT)
                 DELIMITED BY SIZE INTO L-VALUE
         WHEN L-NAME = "tool_rule_1" AND WS-KIND = "sword"
             MOVE "mine minecraft:cobweb 15.0" TO L-VALUE
         WHEN L-NAME = "tool_rule_1"
             STRING "deny #minecraft:incorrect_for_" FUNCTION TRIM(WS-TAG) "_tool" DELIMITED BY SIZE INTO L-VALUE
         WHEN L-NAME = "tool_rule_2" AND WS-KIND = "sword"
             MOVE "speed #minecraft:sword_instantly_mines 3.4028235E38" TO L-VALUE
         WHEN L-NAME = "tool_rule_2"
             STRING "mine #minecraft:mineable/" FUNCTION TRIM(WS-KIND) " " FUNCTION TRIM(WS-TEXT)
                 DELIMITED BY SIZE INTO L-VALUE
         WHEN L-NAME = "tool_rule_3" AND WS-KIND = "sword"
             MOVE "speed #minecraft:sword_efficient 1.5" TO L-VALUE
         WHEN L-NAME = "tool_default_speed"
             MOVE "1.0" TO L-VALUE
         WHEN L-NAME = "tool_damage_per_block" AND WS-KIND = "sword"
             MOVE "2" TO L-VALUE
         WHEN L-NAME = "tool_damage_per_block"
             MOVE "1" TO L-VALUE
         WHEN L-NAME = "tool_creative_break" AND WS-KIND = "sword"
             MOVE "0" TO L-VALUE
         WHEN L-NAME = "tool_creative_break"
             MOVE "1" TO L-VALUE
         WHEN L-NAME = "attack_damage"
             COMPUTE WS-TENTHS = FUNCTION NUMVAL(WS-DAMAGE-TEXT) + WS-BONUS * 10
             CALL "ITEM-TENTHS" USING WS-TENTHS WS-TEXT
             MOVE WS-TEXT TO L-VALUE
         WHEN L-NAME = "attack_speed"
             COMPUTE WS-TENTHS = FUNCTION NUMVAL(WS-SPEED-TEXT)
             CALL "ITEM-TENTHS" USING WS-TENTHS WS-TEXT
             MOVE WS-TEXT TO L-VALUE
         WHEN L-NAME = "weapon" AND WS-KIND = "sword"
             MOVE "1" TO L-VALUE
         WHEN L-NAME = "weapon"
             MOVE "2" TO L-VALUE
         WHEN L-NAME = "weapon_disable_blocking" AND WS-KIND = "axe"
             MOVE "5.0" TO L-VALUE
         WHEN L-NAME = "weapon_disable_blocking"
             MOVE "0.0" TO L-VALUE
         WHEN L-NAME = "enchantable"
             MOVE WS-ENCHANT TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO L-VALUE
         WHEN L-NAME = "repairable"
             MOVE WS-REPAIR TO L-VALUE
         WHEN OTHER
             MOVE CT-NOT-FOUND TO L-STATUS
     END-EVALUATE
     GOBACK.
 END PROGRAM ITEM-TOOL-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-ARMOR-COMPONENT.
*> USING item key (PIC X(38)), name (PIC X(32)), value out (PIC X(100)), status out (CT-OK, or the status as it was): the
*> armor components of a "<material>_<piece>" key of 17 section 2.5; any other key leaves the status alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-MATERIALS.
    05 FILLER PIC X(80) VALUE "leather|1|2|3|1|15|0|0|minecraft:leather".
    05 FILLER PIC X(80) VALUE "copper|1|3|4|2|8|0|0|minecraft:copper_ingot".
    05 FILLER PIC X(80) VALUE "chainmail|1|4|5|2|12|0|0|#minecraft:repairs_chain_armor".
    05 FILLER PIC X(80) VALUE "iron|2|5|6|2|9|0|0|minecraft:iron_ingot".
    05 FILLER PIC X(80) VALUE "golden|1|3|5|2|25|0|0|minecraft:gold_ingot".
    05 FILLER PIC X(80) VALUE "diamond|3|6|8|3|10|2|0|minecraft:diamond".
    05 FILLER PIC X(80) VALUE "netherite|3|6|8|3|15|3|1|minecraft:netherite_ingot".
    05 FILLER PIC X(80) VALUE "turtle|2|5|6|2|9|0|0|minecraft:turtle_scute".
 01 WS-MATERIAL-TABLE REDEFINES WS-MATERIALS.
    05 WS-MATERIAL-LINE    PIC X(80) OCCURS 8 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MATERIAL            PIC X(12).
 01 WS-PIECE               PIC X(12).
 01 WS-NAME                PIC X(12).
 01 WS-BOOTS               PIC X(4).
 01 WS-LEGS                PIC X(4).
 01 WS-CHEST               PIC X(4).
 01 WS-HELMET              PIC X(4).
 01 WS-ENCHANT             PIC X(4).
 01 WS-TOUGHNESS           PIC X(4).
 01 WS-KNOCKBACK           PIC X(4).
 01 WS-REPAIR              PIC X(40).
 01 WS-TENTHS              BINARY-LONG.
 01 WS-TEXT                PIC X(12).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(38).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NAME L-VALUE L-STATUS.
     MOVE SPACES TO WS-MATERIAL WS-PIECE
     UNSTRING L-KEY DELIMITED BY "_" INTO WS-MATERIAL WS-PIECE
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-NAME WS-BOOTS WS-LEGS WS-CHEST WS-HELMET WS-ENCHANT WS-TOUGHNESS WS-KNOCKBACK
             WS-REPAIR
         UNSTRING WS-MATERIAL-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-BOOTS WS-LEGS WS-CHEST WS-HELMET
             WS-ENCHANT WS-TOUGHNESS WS-KNOCKBACK WS-REPAIR
         IF WS-NAME = WS-MATERIAL
             MOVE 1 TO WS-FOUND
             MOVE 9 TO WS-I
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
     EVALUATE WS-PIECE
         WHEN "boots"
             MOVE "feet" TO WS-NAME
         WHEN "leggings"
             MOVE "legs" TO WS-NAME
         WHEN "chestplate"
             MOVE "chest" TO WS-NAME
         WHEN "helmet"
             MOVE "head" TO WS-NAME
         WHEN OTHER
             GOBACK
     END-EVALUATE
     MOVE CT-OK TO L-STATUS
     MOVE SPACES TO L-VALUE
     EVALUATE TRUE
         WHEN L-NAME = "armor" AND WS-PIECE = "boots"
             MOVE WS-BOOTS TO L-VALUE
         WHEN L-NAME = "armor" AND WS-PIECE = "leggings"
             MOVE WS-LEGS TO L-VALUE
         WHEN L-NAME = "armor" AND WS-PIECE = "chestplate"
             MOVE WS-CHEST TO L-VALUE
         WHEN L-NAME = "armor"
             MOVE WS-HELMET TO L-VALUE
         WHEN L-NAME = "armor_toughness"
             COMPUTE WS-TENTHS = FUNCTION NUMVAL(WS-TOUGHNESS) * 10
             CALL "ITEM-TENTHS" USING WS-TENTHS WS-TEXT
             MOVE WS-TEXT TO L-VALUE
         WHEN L-NAME = "armor_knockback_resistance" AND WS-KNOCKBACK NOT = "0"
             COMPUTE WS-TENTHS = FUNCTION NUMVAL(WS-KNOCKBACK)
             CALL "ITEM-TENTHS" USING WS-TENTHS WS-TEXT
             MOVE WS-TEXT TO L-VALUE
         WHEN L-NAME = "equippable"
             MOVE WS-NAME TO L-VALUE
         WHEN L-NAME = "equippable_damage_on_hurt"
             MOVE "1" TO L-VALUE
         WHEN L-NAME = "enchantable"
             MOVE WS-ENCHANT TO L-VALUE
         WHEN L-NAME = "repairable"
             MOVE WS-REPAIR TO L-VALUE
         WHEN OTHER
             MOVE CT-NOT-FOUND TO L-STATUS
     END-EVALUATE
     GOBACK.
 END PROGRAM ITEM-ARMOR-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-COBOLCRAFT-COMPONENT.
*> USING row (PIC X(270), CT-ITEM-ROW of the built-in layer), name (PIC X(32)), value out (PIC X(100)), status out (CT-OK, or the
*> status as it was): the tool defaults of a cobolcraft item whose summary starts with a "tool <set> <speed>" entry
*> (standard-core 5.3, assumption A6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-WEAPONS             BINARY-LONG.
 01 WS-TOOL                PIC X(100).
 LINKAGE SECTION.
 01 L-ROW                  PIC X(270).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NAME L-VALUE L-STATUS.
     MOVE 0 TO WS-WEAPONS
     INSPECT L-ROW(111:160) TALLYING WS-WEAPONS FOR ALL "weapon "
     MOVE SPACES TO WS-TOOL
     IF L-ROW(111:5) = "tool "
         UNSTRING L-ROW(116:155) DELIMITED BY ", " INTO WS-TOOL
     END-IF
     EVALUATE TRUE
         WHEN L-NAME = "tool_rule_1" AND WS-TOOL NOT = SPACES
             STRING "mine " FUNCTION TRIM(WS-TOOL) DELIMITED BY SIZE INTO L-VALUE
             MOVE CT-OK TO L-STATUS
         WHEN L-NAME = "tool_default_speed" AND WS-TOOL NOT = SPACES
             MOVE "1.0" TO L-VALUE
             MOVE CT-OK TO L-STATUS
         WHEN L-NAME = "tool_damage_per_block" AND WS-TOOL NOT = SPACES
             MOVE "1" TO L-VALUE
             MOVE CT-OK TO L-STATUS
         WHEN L-NAME = "tool_creative_break" AND WS-TOOL NOT = SPACES
             MOVE "1" TO L-VALUE
             MOVE CT-OK TO L-STATUS
         WHEN L-NAME = "weapon_disable_blocking" AND WS-WEAPONS > 0
             MOVE "0.0" TO L-VALUE
             MOVE CT-OK TO L-STATUS
     END-EVALUATE
     GOBACK.
 END PROGRAM ITEM-COBOLCRAFT-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-DEFAULT-COMPONENT.
*> USING row (PIC X(270), CT-ITEM-ROW), name (PIC X(32)), value out (PIC X(100)), status out (CT-OK, or the status as it was): the
*> component the row's summary does not hold, from the kind and material of the item (the header). The cobolcraft set has
*> its own defaults; a standard item that is one of the 35 tools gets the tool components, else the armor components.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-TOOLS.
    05 FILLER PIC X(26) VALUE "wooden_sword|30|-24".
    05 FILLER PIC X(26) VALUE "stone_sword|30|-24".
    05 FILLER PIC X(26) VALUE "copper_sword|30|-24".
    05 FILLER PIC X(26) VALUE "iron_sword|30|-24".
    05 FILLER PIC X(26) VALUE "golden_sword|30|-24".
    05 FILLER PIC X(26) VALUE "diamond_sword|30|-24".
    05 FILLER PIC X(26) VALUE "netherite_sword|30|-24".
    05 FILLER PIC X(26) VALUE "wooden_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "stone_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "copper_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "iron_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "golden_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "diamond_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "netherite_pickaxe|10|-28".
    05 FILLER PIC X(26) VALUE "wooden_axe|60|-32".
    05 FILLER PIC X(26) VALUE "stone_axe|70|-32".
    05 FILLER PIC X(26) VALUE "copper_axe|70|-32".
    05 FILLER PIC X(26) VALUE "iron_axe|60|-31".
    05 FILLER PIC X(26) VALUE "golden_axe|60|-30".
    05 FILLER PIC X(26) VALUE "diamond_axe|50|-30".
    05 FILLER PIC X(26) VALUE "netherite_axe|50|-30".
    05 FILLER PIC X(26) VALUE "wooden_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "stone_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "copper_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "iron_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "golden_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "diamond_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "netherite_shovel|15|-30".
    05 FILLER PIC X(26) VALUE "wooden_hoe|0|-30".
    05 FILLER PIC X(26) VALUE "stone_hoe|-10|-20".
    05 FILLER PIC X(26) VALUE "copper_hoe|-10|-20".
    05 FILLER PIC X(26) VALUE "iron_hoe|-20|-10".
    05 FILLER PIC X(26) VALUE "golden_hoe|0|-30".
    05 FILLER PIC X(26) VALUE "diamond_hoe|-30|0".
    05 FILLER PIC X(26) VALUE "netherite_hoe|-40|0".
 01 WS-TOOL-TABLE REDEFINES WS-TOOLS.
    05 WS-TOOL-LINE        PIC X(26) OCCURS 35 TIMES.
 01 WS-VIEW.
    05 WS-ROW              PIC X(270).
    05 WS-R REDEFINES WS-ROW.
       10 FILLER           PIC X(4).
       10 WS-R-KEY         PIC X(38).
       10 FILLER           PIC X(228).
 01 WS-I                   BINARY-LONG.
 01 WS-LINE-KEY            PIC X(38).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  PIC X(270).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NAME L-VALUE L-STATUS.
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         CALL "ITEM-COBOLCRAFT-COMPONENT" USING L-ROW L-NAME L-VALUE L-STATUS
         GOBACK
     END-IF
     MOVE L-ROW TO WS-ROW
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         MOVE SPACES TO WS-LINE-KEY
         UNSTRING WS-TOOL-LINE(WS-I) DELIMITED BY "|" INTO WS-LINE-KEY
         IF WS-LINE-KEY = WS-R-KEY
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         CALL "ITEM-TOOL-COMPONENT" USING WS-TOOL-LINE(WS-FOUND) L-NAME L-VALUE L-STATUS
     ELSE
         CALL "ITEM-ARMOR-COMPONENT" USING WS-R-KEY L-NAME L-VALUE L-STATUS
     END-IF
     GOBACK.
 END PROGRAM ITEM-DEFAULT-COMPONENT.
