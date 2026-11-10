*> Test of the spears (17 section 2.4; core/src/tools-spears.cob TOOL-SPEAR-STATS): every row of the table, the durability, the attack damage (1 + modifier +
*> bonus), the attack speed (4 + modifier), the full-charge cooldown in ticks (20 / speed) and the mining speed of the material, each
*> in 1/10000 (damage, speed, cooldown) or in thousandths (mining speed). An item of another kind is not found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-SPEARS.
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
 01 WS-K-DELAY            BINARY-LONG.
 01 WS-K-DT               BINARY-LONG.
 01 WS-K-DS               BINARY-LONG.
 01 WS-K-KT               BINARY-LONG.
 01 WS-K-KS               BINARY-LONG.
 01 WS-K-AT               BINARY-LONG.
 01 WS-K-AS               BINARY-LONG.
 01 WS-K-MULT             BINARY-LONG.
 01 WS-K-CHARGE           PIC X(8).
 01 WS-K-RANGE            PIC X(24).
 01 WS-K-E                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE "acceptance US14 wooden_spear durability 59, damage 1, speed 1.5385, cooldown 13 ticks, mining speed 2" TO TL-CASE
     MOVE "wooden_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 59 damage 10000 speed 15385 cooldown 130000 mining 2000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 stone_spear durability 131, damage 2, speed 1.3333, cooldown 15 ticks, mining speed 4" TO TL-CASE
     MOVE "stone_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 131 damage 20000 speed 13333 cooldown 150000 mining 4000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 copper_spear durability 190, damage 2, speed 1.1765, cooldown 17 ticks, mining speed 5" TO TL-CASE
     MOVE "copper_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 190 damage 20000 speed 11765 cooldown 170000 mining 5000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 iron_spear durability 250, damage 3, speed 1.0526, cooldown 19 ticks, mining speed 6" TO TL-CASE
     MOVE "iron_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 250 damage 30000 speed 10526 cooldown 190000 mining 6000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 golden_spear durability 32, damage 1, speed 1.0526, cooldown 19 ticks, mining speed 12" TO TL-CASE
     MOVE "golden_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 32 damage 10000 speed 10526 cooldown 190000 mining 12000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 diamond_spear durability 1561, damage 4, speed 0.9524, cooldown 21 ticks, mining speed 8" TO TL-CASE
     MOVE "diamond_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 1561 damage 40000 speed 9524 cooldown 210000 mining 8000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 netherite_spear durability 2031, damage 5, speed 0.8696, cooldown 23 ticks, mining speed 9" TO TL-CASE
     MOVE "netherite_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 2031 damage 50000 speed 8696 cooldown 230000 mining 9000" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 minecraft:iron_spear with its namespace is the same item" TO TL-CASE
     MOVE "minecraft:iron_spear" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 1 durability 250 damage 30000 speed 10526 cooldown 190000 mining 6000" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 iron_sword is not one of the spears" TO TL-CASE
     MOVE "iron_sword" TO WS-KEY
     PERFORM LOOKUP
     MOVE "found 0 durability 0 damage 0 speed 0 cooldown 0 mining 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 wooden_spear jab: delay 15 ticks, dismount 100 ticks from speed 14.0, knockback 200 from 5.1, damage 300 from 4.6, multiplier 700/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "wooden_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 15 dismount 100 140 knockback 200 51 damage 300 46 multiplier 700 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 stone_spear jab: delay 14 ticks, dismount 90 ticks from speed 13.0, knockback 180 from 5.1, damage 275 from 4.6, multiplier 820/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "stone_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 14 dismount 90 130 knockback 180 51 damage 275 46 multiplier 820 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 copper_spear jab: delay 13 ticks, dismount 80 ticks from speed 12.0, knockback 165 from 5.1, damage 250 from 4.6, multiplier 820/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "copper_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 13 dismount 80 120 knockback 165 51 damage 250 46 multiplier 820 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 iron_spear jab: delay 12 ticks, dismount 50 ticks from speed 11.0, knockback 135 from 5.1, damage 225 from 4.6, multiplier 950/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "iron_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 12 dismount 50 110 knockback 135 51 damage 225 46 multiplier 950 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 golden_spear jab: delay 14 ticks, dismount 70 ticks from speed 13.0, knockback 170 from 5.1, damage 275 from 4.6, multiplier 700/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "golden_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 14 dismount 70 130 knockback 170 51 damage 275 46 multiplier 700 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 diamond_spear jab: delay 10 ticks, dismount 60 ticks from speed 10.0, knockback 130 from 5.1, damage 200 from 4.6, multiplier 1075/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "diamond_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 10 dismount 60 100 knockback 130 51 damage 200 46 multiplier 1075 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 netherite_spear jab: delay 8 ticks, dismount 50 ticks from speed 9.0, knockback 110 from 5.1, damage 175 from 4.6, multiplier 1200/1000, minimum charge 1.0, range 2.0 to 4.5" TO TL-CASE
     MOVE "netherite_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 8 dismount 50 90 knockback 110 51 damage 175 46 multiplier 1200 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 minecraft:iron_spear with its namespace has the same jab numbers" TO TL-CASE
     MOVE "minecraft:iron_spear" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 1 delay 12 dismount 50 110 knockback 135 51 damage 225 46 multiplier 950 charge 1.0 range 2.0 4.5" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 iron_sword has no kinetic weapon" TO TL-CASE
     MOVE "iron_sword" TO WS-KEY
     PERFORM KINETIC
     MOVE "found 0 delay 0 dismount 0 0 knockback 0 0 damage 0 0 multiplier 0 charge 0.0 range 0.0 0.0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 LOOKUP.
     CALL "TOOL-SPEAR-STATS" USING WS-KEY WS-FOUND WS-DURABILITY WS-DAMAGE WS-SPEED WS-COOLDOWN WS-MINING
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

 KINETIC.
     CALL "TOOL-SPEAR-KINETIC" USING WS-KEY WS-FOUND WS-K-DELAY WS-K-DT WS-K-DS WS-K-KT WS-K-KS WS-K-AT WS-K-AS
         WS-K-MULT WS-K-CHARGE WS-K-RANGE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-E1
     MOVE WS-K-DELAY TO WS-E2
     STRING "found " FUNCTION TRIM(WS-E1) " delay " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-K-DT TO WS-E1
     MOVE WS-K-DS TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " dismount " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-K-KT TO WS-E1
     MOVE WS-K-KS TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " knockback " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-K-AT TO WS-E1
     MOVE WS-K-AS TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " damage " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-K-MULT TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " multiplier " FUNCTION TRIM(WS-E1) " charge " FUNCTION TRIM(WS-K-CHARGE)
         " range " FUNCTION TRIM(WS-K-RANGE) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-SPEARS.

 COPY CORETEST.
