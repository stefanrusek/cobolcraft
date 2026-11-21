*> Test of the armor material chainmail (17 section 2.5, 4.4 and 4.5; core/src/tools-armor.cob TOOL-ARMOR-MATERIAL, TOOL-ARMOR-ITEM, TOOL-ARMOR-TOTAL,
*> TOOL-ARMOR-REDUCE): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair ingredient, the item
*> rows of the pieces (durability = multiplier x slot base), the armor attribute and toughness with the pieces worn, and the damage reduction
*> with them (damage 10: f = 2 + T / 4, e = clamp(R - d / f, R x 0.2, 20), q = e / 25, d x (1 - q)). Expected values computed by hand from the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-ARMOR-CHAINMAIL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-MATERIAL            PIC X(16).
 01 WS-PIECE               PIC X(12).
 01 WS-KEY                 PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 01 WS-WORN.
    05 WS-WORN-KEY         PIC X(48) OCCURS 5 TIMES.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-DAMAGE              FLOAT-SHORT.
 01 WS-RESULT              FLOAT-SHORT.
 01 WS-SHOWN               PIC -(5)9.999.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE

     MOVE "acceptance US14 chainmail_material boots: durability 195, defense 1, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail" TO WS-MATERIAL
     MOVE "boots" TO WS-PIECE
     PERFORM MATERIAL-ROW
     MOVE "found 1 durability 195 defense 1 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_material leggings: durability 225, defense 4, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail" TO WS-MATERIAL
     MOVE "leggings" TO WS-PIECE
     PERFORM MATERIAL-ROW
     MOVE "found 1 durability 225 defense 4 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_material chestplate: durability 240, defense 5, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail" TO WS-MATERIAL
     MOVE "chestplate" TO WS-PIECE
     PERFORM MATERIAL-ROW
     MOVE "found 1 durability 240 defense 5 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_material helmet: durability 165, defense 2, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail" TO WS-MATERIAL
     MOVE "helmet" TO WS-PIECE
     PERFORM MATERIAL-ROW
     MOVE "found 1 durability 165 defense 2 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_material body: durability 240, defense 4, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail" TO WS-MATERIAL
     MOVE "body" TO WS-PIECE
     PERFORM MATERIAL-ROW
     MOVE "found 1 durability 240 defense 4 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_boots item: durability 195, defense 1, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail_boots" TO WS-KEY
     PERFORM ITEM-ROW
     MOVE "found 1 durability 195 defense 1 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_leggings item: durability 225, defense 4, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail_leggings" TO WS-KEY
     PERFORM ITEM-ROW
     MOVE "found 1 durability 225 defense 4 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_chestplate item: durability 240, defense 5, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail_chestplate" TO WS-KEY
     PERFORM ITEM-ROW
     MOVE "found 1 durability 240 defense 5 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail_helmet item: durability 165, defense 2, toughness 0.0, knockback 0.0, enchantability 12, repair #minecraft:repairs_chain_armor" TO TL-CASE
     MOVE "chainmail_helmet" TO WS-KEY
     PERFORM ITEM-ROW
     MOVE "found 1 durability 165 defense 2 toughness 0 knockback 0 enchantability 12 repair #minecraft:repairs_chain_armor" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 chainmail worn: armor attribute 12, toughness 0.0, damage 10 reduced to 7.200" TO TL-CASE
     MOVE "chainmail_boots" TO WS-WORN-KEY(1)
     MOVE "chainmail_leggings" TO WS-WORN-KEY(2)
     MOVE "chainmail_chestplate" TO WS-WORN-KEY(3)
     MOVE "chainmail_helmet" TO WS-WORN-KEY(4)
     MOVE SPACES TO WS-WORN-KEY(5)
     PERFORM WORN-SET
     MOVE "armor 12 toughness 0 knockback 0 reduced      7.200" TO TL-EXPECTED
     PERFORM CHECK-DONE

     STOP RUN.

 MATERIAL-ROW.
     CALL "TOOL-ARMOR-MATERIAL" USING WS-MATERIAL WS-PIECE WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS
         WS-KNOCKBACK WS-ENCHANT WS-REPAIR
     PERFORM SHOW-ROW.

 ITEM-ROW.
     CALL "TOOL-ARMOR-ITEM" USING WS-KEY WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS WS-KNOCKBACK
         WS-ENCHANT WS-REPAIR
     PERFORM SHOW-ROW.

 SHOW-ROW.
     MOVE WS-FOUND TO WS-E1
     MOVE WS-DURABILITY TO WS-E2
     MOVE WS-DEFENSE TO WS-E3
     MOVE WS-TOUGHNESS TO WS-E4
     MOVE WS-KNOCKBACK TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " durability " FUNCTION TRIM(WS-E2) " defense " FUNCTION TRIM(WS-E3)
         " toughness " FUNCTION TRIM(WS-E4) " knockback " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-ENCHANT TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " enchantability " FUNCTION TRIM(WS-E1) " repair " FUNCTION TRIM(WS-REPAIR)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 WORN-SET.
     CALL "TOOL-ARMOR-TOTAL" USING WS-WORN WS-ARMOR WS-TOUGHNESS WS-KNOCKBACK
     MOVE 10.0 TO WS-DAMAGE
     CALL "TOOL-ARMOR-REDUCE" USING WS-DAMAGE WS-ARMOR WS-TOUGHNESS WS-RESULT
     COMPUTE WS-SHOWN ROUNDED = WS-RESULT
     MOVE WS-ARMOR TO WS-E1
     MOVE WS-TOUGHNESS TO WS-E2
     MOVE WS-KNOCKBACK TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "armor " FUNCTION TRIM(WS-E1) " toughness " FUNCTION TRIM(WS-E2) " knockback " FUNCTION TRIM(WS-E3)
         " reduced " WS-SHOWN DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-ARMOR-CHAINMAIL.

 COPY CORETEST.
