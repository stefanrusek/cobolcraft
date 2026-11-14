*> Test (US15; docs/protocol/19 sections 5.1, 5.2 and 6.1): the pure rules of the pet care of cats, ocelots and wolves in core/src/mob-19-5.cob: the dye of a collar (M195-DYE-COLOR,
*> M195-COLLAR), the food lists (M195-FOOD) and the healing of the shared tamable feeding routine (M195-HEAL). The live wiring is tested by acc_us15_petcare.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-KEY                PIC X(24).
 01 WS-SPECIES            PIC X(24).
 01 WS-COLOR              BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-HEALTH             BINARY-LONG.
 01 WS-MAX                BINARY-LONG.
 01 WS-NUTRITION          BINARY-LONG.
 01 WS-MULT               BINARY-LONG.
 01 WS-NEW                BINARY-LONG.
 01 WS-STORED             BINARY-LONG.
 01 WS-FOOD-NUTRITION      BINARY-LONG.
 PROCEDURE DIVISION.
*> Dye items of the tag #dyes: sixteen colours in the dye id order of the wool, "<colour>_dye"
     MOVE "white_dye" TO WS-KEY
     MOVE 0 TO WS-E
     PERFORM DYE-CASE
     MOVE "blue_dye" TO WS-KEY
     MOVE 11 TO WS-E
     PERFORM DYE-CASE
     MOVE "light_gray_dye" TO WS-KEY
     MOVE 8 TO WS-E
     PERFORM DYE-CASE
     MOVE "red_dye" TO WS-KEY
     MOVE 14 TO WS-E
     PERFORM DYE-CASE
     MOVE "black_dye" TO WS-KEY
     MOVE 15 TO WS-E
     PERFORM DYE-CASE
     MOVE "bone_meal" TO WS-KEY
     MOVE -1 TO WS-E
     PERFORM DYE-CASE
     MOVE "blue_wool" TO WS-KEY
     MOVE -1 TO WS-E
     PERFORM DYE-CASE
*> The collar colour: 0 stored is the default red (dye id 14), else the stored value is the dye id + 1
     MOVE 0 TO WS-STORED
     CALL "M195-COLLAR" USING WS-STORED WS-COLOR
     MOVE "acceptance US15 19§5.1 Cat: an undyed collar is red (14)" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE WS-COLOR TO WS-O
     PERFORM CHECK-N
     MOVE 12 TO WS-STORED
     CALL "M195-COLLAR" USING WS-STORED WS-COLOR
     MOVE "acceptance US15 19§6.1 Wolf: a stored collar 12 is the dye id 11" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE WS-COLOR TO WS-O
     PERFORM CHECK-N
*> Food: wolf_food, cat_food and ocelot_food
     MOVE "wolf" TO WS-SPECIES
     MOVE "beef" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM FOOD-CASE
     MOVE "cooked_chicken" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "rotten_flesh" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "tropical_fish" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "rabbit_stew" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "apple" TO WS-KEY
     MOVE 0 TO WS-E
     PERFORM FOOD-CASE
     MOVE "cat" TO WS-SPECIES
     MOVE "cod" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM FOOD-CASE
     MOVE "salmon" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "cooked_cod" TO WS-KEY
     MOVE 0 TO WS-E
     PERFORM FOOD-CASE
     MOVE "beef" TO WS-KEY
     PERFORM FOOD-CASE
     MOVE "ocelot" TO WS-SPECIES
     MOVE "salmon" TO WS-KEY
     MOVE 1 TO WS-E
     PERFORM FOOD-CASE
     MOVE "bone" TO WS-KEY
     MOVE 0 TO WS-E
     PERFORM FOOD-CASE
     MOVE "wolf" TO WS-SPECIES
     MOVE "cooked_beef" TO WS-KEY
     CALL "M195-FOOD" USING WS-SPECIES WS-KEY WS-OK WS-FOOD-NUTRITION
     MOVE "acceptance US15 19§6.1 Wolf: cooked beef has nutrition 8" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-FOOD-NUTRITION TO WS-O
     PERFORM CHECK-N
     MOVE "rabbit_stew" TO WS-KEY
     CALL "M195-FOOD" USING WS-SPECIES WS-KEY WS-OK WS-FOOD-NUTRITION
     MOVE "acceptance US15 19§6.1 Wolf: rabbit stew has nutrition 10" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE WS-FOOD-NUTRITION TO WS-O
     PERFORM CHECK-N
     MOVE "cat" TO WS-SPECIES
     MOVE "cod" TO WS-KEY
     CALL "M195-FOOD" USING WS-SPECIES WS-KEY WS-OK WS-FOOD-NUTRITION
     MOVE "acceptance US15 19§5.1 Cat: raw cod has nutrition 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-FOOD-NUTRITION TO WS-O
     PERFORM CHECK-N
*> Healing: health + multiplier x nutrition, at most the maximum
     MOVE 10 TO WS-HEALTH
     MOVE 40 TO WS-MAX
     MOVE 8 TO WS-NUTRITION
     MOVE 2 TO WS-MULT
     CALL "M195-HEAL" USING WS-HEALTH WS-MAX WS-NUTRITION WS-MULT WS-NEW
     MOVE "acceptance US15 19§6.1 Wolf: cooked beef heals 2 x 8 = 16 points" TO WS-CASE
     MOVE 26 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE 39 TO WS-HEALTH
     CALL "M195-HEAL" USING WS-HEALTH WS-MAX WS-NUTRITION WS-MULT WS-NEW
     MOVE "acceptance US15 19§6.1 Wolf: healing stops at the maximum health 40" TO WS-CASE
     MOVE 40 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-HEALTH
     MOVE 10 TO WS-MAX
     MOVE 2 TO WS-NUTRITION
     MOVE 1 TO WS-MULT
     CALL "M195-HEAL" USING WS-HEALTH WS-MAX WS-NUTRITION WS-MULT WS-NEW
     MOVE "acceptance US15 19§5.1 Cat: raw cod heals 1 x 2 points" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 DYE-CASE.
     CALL "M195-DYE-COLOR" USING WS-KEY WS-COLOR
     MOVE SPACES TO WS-CASE
     STRING "acceptance US15 19§5.1 Cat: dye colour of " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-COLOR TO WS-O
     PERFORM CHECK-N.

 FOOD-CASE.
     CALL "M195-FOOD" USING WS-SPECIES WS-KEY WS-OK WS-FOOD-NUTRITION
     MOVE SPACES TO WS-CASE
     STRING "acceptance US15 19§6.1 Wolf: food of " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE " is "
         DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-5-1.
