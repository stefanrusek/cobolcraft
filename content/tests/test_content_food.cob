*> Test of CONTENT-FOOD (content/src/foods.cob): the nutrition, saturation, always-edible flag and use time of the food component named
*> in the components summary of an item row (25 part 1 section 8.2). Operator report of try6: food items did nothing, because the
*> rows of a standard set name the food ("food apple", "food Foods.COOKED_BEEF", "food {6,1.2,true}") and the number was never read.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-FOOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-TEXT                PIC X(160).
 01 WS-NUTRITION           BINARY-LONG.
 01 WS-SATURATION          BINARY-LONG.
 01 WS-ALWAYS              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-E1                  PIC 9(3).
 01 WS-E2                  PIC 9(6).
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9(3).
 PROCEDURE DIVISION.
     MOVE "food apple, consumable default food, compostable medium" TO WS-TEXT
     MOVE "test content food apple: nutrition 4, saturation 2.4, not always edible, 32 ticks" TO TL-CASE
     MOVE "004 002400 0 032" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food Foods.COOKED_BEEF, consumable default food" TO WS-TEXT
     MOVE "test content food Foods.COOKED_BEEF: the constant's name in upper case" TO TL-CASE
     MOVE "008 012800 0 032" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food Foods.DRIED_KELP, consumable default food" TO WS-TEXT
     MOVE "test content food dried kelp: 16 ticks" TO TL-CASE
     MOVE "001 000600 0 016" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food golden_apple, consumable golden_apple" TO WS-TEXT
     MOVE "test content food golden apple: always edible" TO TL-CASE
     MOVE "004 009600 1 032" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food honey_bottle, consumable honey" TO WS-TEXT
     MOVE "test content food honey_bottle by name: 40 ticks" TO TL-CASE
     MOVE "006 001200 1 040" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food {6,1.2,true}, consumable honey, use_remainder glass_bottle" TO WS-TEXT
     MOVE "test content food honey bottle inline: nutrition 6, saturation 1.2, always, 40 ticks" TO TL-CASE
     MOVE "006 001200 1 040" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food {2,0.4,false}, consumable default food" TO WS-TEXT
     MOVE "test content food inline berries: nutrition 2, saturation 0.4, not always, 32 ticks" TO TL-CASE
     MOVE "002 000400 0 032" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food 5" TO WS-TEXT
     MOVE "test content food a number only (stand-in rows): nutrition 5, no saturation, the core's default time" TO TL-CASE
     MOVE "005 000000 0 000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "tool #minecraft:mineable/pickaxe 4.0, food porkchop" TO WS-TEXT
     MOVE "test content food after another component, porkchop" TO TL-CASE
     MOVE "003 001800 0 032" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "max_damage 384, not_a_food stew" TO WS-TEXT
     MOVE "test content food no food component" TO TL-CASE
     MOVE "000 000000 0 000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "food unknown_thing" TO WS-TEXT
     MOVE "test content food a name the table lacks" TO TL-CASE
     MOVE "000 000000 0 000" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL "CONTENT-FOOD" USING WS-TEXT WS-NUTRITION WS-SATURATION WS-ALWAYS WS-TICKS
     MOVE WS-NUTRITION TO WS-E1
     MOVE WS-SATURATION TO WS-E2
     MOVE WS-ALWAYS TO WS-E3
     MOVE WS-TICKS TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 " " WS-E3 " " WS-E4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CONTENT-FOOD.
