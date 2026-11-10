*> Test of the tool materials of 17 section 2.1 (core/src/tools-materials.cob TOOL-MATERIAL): durability, mining speed, attack
*> bonus, enchantability, repair ingredient, the block tag whose blocks the material is incorrect for (denies drops) and the
*> needs_* tiers that tag holds, for wooden, stone, copper, iron, golden, diamond and netherite; an unknown material is not found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-MATERIALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-MATERIAL          PIC X(12).
 01 WS-DURABILITY        BINARY-LONG.
 01 WS-SPEED             BINARY-LONG.
 01 WS-BONUS             BINARY-LONG.
 01 WS-ENCHANT           BINARY-LONG.
 01 WS-REPAIR            PIC X(40).
 01 WS-DENY              PIC X(48).
 01 WS-TIERS             PIC X(24).
 01 WS-FOUND             BINARY-LONG.
 01 WS-E1                PIC -(9)9.
 01 WS-E2                PIC -(9)9.
 01 WS-E3                PIC -(9)9.
 01 WS-E4                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "acceptance US14 wooden_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "wooden" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 59 speed 2 bonus 0 enchantability 15 repair #minecraft:wooden_tool_materials deny minecraft:incorrect_for_wooden_tool tiers stone iron diamond" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 stone_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "stone" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 131 speed 4 bonus 1 enchantability 5 repair #minecraft:stone_tool_materials deny minecraft:incorrect_for_stone_tool tiers iron diamond" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 copper_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "copper" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 190 speed 5 bonus 1 enchantability 13 repair minecraft:copper_ingot deny minecraft:incorrect_for_copper_tool tiers iron diamond" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 iron_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "iron" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 250 speed 6 bonus 2 enchantability 14 repair minecraft:iron_ingot deny minecraft:incorrect_for_iron_tool tiers diamond" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 golden_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "golden" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 32 speed 12 bonus 0 enchantability 22 repair minecraft:gold_ingot deny minecraft:incorrect_for_gold_tool tiers stone iron diamond" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 diamond_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "diamond" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 1561 speed 8 bonus 3 enchantability 10 repair minecraft:diamond deny minecraft:incorrect_for_diamond_tool tiers none" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 netherite_tool_material durability, mining speed, attack bonus, enchantability, repair, denied tag" TO TL-CASE
     MOVE "netherite" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 1 durability 2031 speed 9 bonus 4 enchantability 15 repair minecraft:netherite_ingot deny minecraft:incorrect_for_netherite_tool tiers none" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 an unknown tool material is not found" TO TL-CASE
     MOVE "emerald" TO WS-MATERIAL
     PERFORM LOOKUP
     MOVE "found 0 durability 0 speed 0 bonus 0 enchantability 0 repair  deny  tiers " TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 LOOKUP.
     CALL "TOOL-MATERIAL" USING WS-MATERIAL WS-DURABILITY WS-SPEED WS-BONUS WS-ENCHANT WS-REPAIR WS-DENY
         WS-TIERS WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE WS-DURABILITY TO WS-E2
     MOVE WS-SPEED TO WS-E3
     MOVE WS-BONUS TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " durability " FUNCTION TRIM(WS-E2) " speed " FUNCTION TRIM(WS-E3)
         " bonus " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ENCHANT TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " enchantability " FUNCTION TRIM(WS-E1) " repair " FUNCTION TRIM(WS-REPAIR)
         " deny " FUNCTION TRIM(WS-DENY) " tiers " FUNCTION TRIM(WS-TIERS) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-MATERIALS.

 COPY CORETEST.
