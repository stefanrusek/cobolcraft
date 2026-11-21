*> Test of the special item mace (17 section 2.6; core/src/tools-special.cob TOOL-SPECIAL-STATS, TOOL-SPECIAL-COMPONENT): its stack size,
*> durability (0 none), rarity (common by default), enchantability (-1: no enchantable component), repair ingredient (an item key or a #tag,
*> without the namespace; none) and the listed components and stats.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-SPECIAL-MACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-RARITY              PIC X(12).
 01 WS-REPAIR              PIC X(40).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

     MOVE "acceptance US14 mace stack size 1, durability 500, rarity epic, enchantability 15, repair breeze_rod" TO TL-CASE
     MOVE "mace" TO WS-KEY
     CALL "TOOL-SPECIAL-STATS" USING WS-KEY WS-FOUND WS-STACK WS-DURABILITY WS-ENCHANT WS-RARITY WS-REPAIR
     MOVE WS-FOUND TO WS-E1
     MOVE WS-STACK TO WS-E2
     MOVE WS-DURABILITY TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " stack " FUNCTION TRIM(WS-E2) " durability " FUNCTION TRIM(WS-E3) " rarity "
         FUNCTION TRIM(WS-RARITY) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ENCHANT TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " enchantability " FUNCTION TRIM(WS-E1) " repair " FUNCTION TRIM(WS-REPAIR)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 1 stack 1 durability 500 rarity epic enchantability 15 repair breeze_rod" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component attack_damage is 5.0" TO TL-CASE
     MOVE "attack_damage" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 5.0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component attack_speed is -3.4" TO TL-CASE
     MOVE "attack_speed" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 -3.4" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component tool_default_speed is 1.0" TO TL-CASE
     MOVE "tool_default_speed" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 1.0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component tool_damage_per_block is 2" TO TL-CASE
     MOVE "tool_damage_per_block" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 2" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component tool_creative_break is 0" TO TL-CASE
     MOVE "tool_creative_break" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 mace component weapon_item_damage is 1" TO TL-CASE
     MOVE "weapon_item_damage" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a component the item does not have is not found" TO TL-CASE
     MOVE "tool_rule_1" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 an unknown item is not special" TO TL-CASE
     MOVE "no_such_item" TO WS-KEY
     CALL "TOOL-SPECIAL-STATS" USING WS-KEY WS-FOUND WS-STACK WS-DURABILITY WS-ENCHANT WS-RARITY WS-REPAIR
     MOVE WS-FOUND TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 minecraft:mace with its namespace has the same component" TO TL-CASE
     MOVE "minecraft:mace" TO WS-KEY
     MOVE "attack_damage" TO WS-NAME
     PERFORM COMPONENT
     MOVE "found 1 5.0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 a repair text is normalized: braces, tag prefix and the minecraft namespace go" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "breeze_rod" TO WS-REPAIR
     CALL "TOOL-REPAIR-NORMALIZE" USING WS-REPAIR
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-REPAIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "{phantom_membrane}" TO WS-REPAIR
     CALL "TOOL-REPAIR-NORMALIZE" USING WS-REPAIR
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-REPAIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "tag wooden_tool_materials" TO WS-REPAIR
     CALL "TOOL-REPAIR-NORMALIZE" USING WS-REPAIR
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-REPAIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "#minecraft:stone_tool_materials" TO WS-REPAIR
     CALL "TOOL-REPAIR-NORMALIZE" USING WS-REPAIR
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-REPAIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:copper_ingot" TO WS-REPAIR
     CALL "TOOL-REPAIR-NORMALIZE" USING WS-REPAIR
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-REPAIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "breeze_rod phantom_membrane #wooden_tool_materials #stone_tool_materials copper_ingot" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     PERFORM CHECK-DONE
     STOP RUN.

 COMPONENT.
     CALL "TOOL-SPECIAL-COMPONENT" USING WS-KEY WS-NAME WS-VALUE WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-VALUE) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-SPECIAL-MACE.

 COPY CORETEST.
