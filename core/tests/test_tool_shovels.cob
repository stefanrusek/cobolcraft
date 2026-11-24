*> Test of the shovels (17 section 2.3; core/src/tools-shovels.cob TOOL-SHOVEL-STATS): every row of the table, the durability, the attack damage (1 + modifier +
*> bonus), the attack speed (4 + modifier), the full-charge cooldown in ticks (20 / speed) and the mining speed of the material, each
*> in 1/10000 (damage, speed, cooldown) or in thousandths (mining speed). An item of another kind is not found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-SHOVELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-KEY                PIC X(48).
 01 WS-FOUND              BINARY-LONG.
 01 WS-DURABILITY         BINARY-LONG.
 01 WS-DAMAGE             BINARY-LONG.
 01 WS-SPEED              BINARY-LONG.
 01 WS-COOLDOWN           BINARY-LONG.
 01 WS-MINING             BINARY-LONG.
 01 WS-E1                 PIC -(9)9.
 01 WS-E2                 PIC -(9)9.
 01 WS-E3                 PIC -(9)9.
 01 WS-E4                 PIC -(9)9.
 01 WS-E5                 PIC -(9)9.
 01 WS-E6                 PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "acceptance US14 wooden_shovel durability 59, damage 2.5, speed 1, cooldown 20 ticks, mining speed 2" TO TL-CASE
     MOVE "wooden_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 59 damage 25000 speed 10000 cooldown 200000 mining 2000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 stone_shovel durability 131, damage 3.5, speed 1, cooldown 20 ticks, mining speed 4" TO TL-CASE
     MOVE "stone_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 131 damage 35000 speed 10000 cooldown 200000 mining 4000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 copper_shovel durability 190, damage 3.5, speed 1, cooldown 20 ticks, mining speed 5" TO TL-CASE
     MOVE "copper_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 190 damage 35000 speed 10000 cooldown 200000 mining 5000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 iron_shovel durability 250, damage 4.5, speed 1, cooldown 20 ticks, mining speed 6" TO TL-CASE
     MOVE "iron_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 250 damage 45000 speed 10000 cooldown 200000 mining 6000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 golden_shovel durability 32, damage 2.5, speed 1, cooldown 20 ticks, mining speed 12" TO TL-CASE
     MOVE "golden_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 32 damage 25000 speed 10000 cooldown 200000 mining 12000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 diamond_shovel durability 1561, damage 5.5, speed 1, cooldown 20 ticks, mining speed 8" TO TL-CASE
     MOVE "diamond_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 1561 damage 55000 speed 10000 cooldown 200000 mining 8000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 netherite_shovel durability 2031, damage 6.5, speed 1, cooldown 20 ticks, mining speed 9" TO TL-CASE
     MOVE "netherite_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 2031 damage 65000 speed 10000 cooldown 200000 mining 9000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 minecraft:iron_shovel with its namespace is the same item" TO TL-CASE
     MOVE "minecraft:iron_shovel" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 250 damage 45000 speed 10000 cooldown 200000 mining 6000" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 iron_axe is not one of the shovels" TO TL-CASE
     MOVE "iron_axe" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 0 durability 0 damage 0 speed 0 cooldown 0 mining 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 LOOKUP.
     CALL "TOOL-SHOVEL-STATS" USING WS-KEY WS-FOUND WS-DURABILITY WS-DAMAGE WS-SPEED WS-COOLDOWN WS-MINING
     MOVE WS-FOUND TO WS-E1
     MOVE WS-DURABILITY TO WS-E2
     MOVE WS-DAMAGE TO WS-E3
     MOVE WS-SPEED TO WS-E4
     MOVE WS-COOLDOWN TO WS-E5
     MOVE WS-MINING TO WS-E6
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " durability " FUNCTION TRIM(WS-E2) " damage " FUNCTION TRIM(WS-E3)
         " speed " FUNCTION TRIM(WS-E4) " cooldown " FUNCTION TRIM(WS-E5) " mining " FUNCTION TRIM(WS-E6)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-SHOVELS.

 COPY CORETEST.
