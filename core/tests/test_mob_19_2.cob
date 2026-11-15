*> Acceptance test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md section 2: farm animals, and 25.1, 25.5 worked examples):
*> sheep colours, shearing and grass eating, chicken eggs, mooshroom types and milk.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-C                  BINARY-LONG.
 01 WS-D                  BINARY-LONG.
 01 WS-R                  BINARY-LONG.
 01 WS-KEY                PIC X(24).
 01 WS-HELD               PIC X(24).
 01 WS-I                  BINARY-LONG.
 01 WS-MIX.
    05 FILLER PIC X(12) VALUE "011013009000".
    05 FILLER PIC X(12) VALUE "015000007000".
    05 FILLER PIC X(12) VALUE "011000003000".
    05 FILLER PIC X(12) VALUE "007000008000".
    05 FILLER PIC X(12) VALUE "013000005000".
    05 FILLER PIC X(12) VALUE "010006002000".
    05 FILLER PIC X(12) VALUE "014004001000".
    05 FILLER PIC X(12) VALUE "014000006000".
    05 FILLER PIC X(12) VALUE "011014010000".
 01 WS-MIX-TABLE REDEFINES WS-MIX.
    05 WS-MIX-ROW            OCCURS 9 TIMES.
       10 WS-MIX-A           PIC 999.
       10 WS-MIX-B           PIC 999.
       10 WS-MIX-R           PIC 999.
       10 FILLER             PIC 999.
 PROCEDURE DIVISION.
*> 2.4 spawn colour: config 0 temperate, 1 warm, 2 cold
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         EVALUATE WS-I
             WHEN 1 MOVE 0 TO WS-A MOVE 0 TO WS-B MOVE 15 TO WS-E
             WHEN 2 MOVE 0 TO WS-A MOVE 4 TO WS-B MOVE 15 TO WS-E
             WHEN 3 MOVE 0 TO WS-A MOVE 5 TO WS-B MOVE 7 TO WS-E
             WHEN 4 MOVE 0 TO WS-A MOVE 10 TO WS-B MOVE 8 TO WS-E
             WHEN 5 MOVE 0 TO WS-A MOVE 15 TO WS-B MOVE 12 TO WS-E
             WHEN 6 MOVE 0 TO WS-A MOVE 18 TO WS-B MOVE 0 TO WS-E
             WHEN 7 MOVE 1 TO WS-A MOVE 0 TO WS-B MOVE 7 TO WS-E
             WHEN 8 MOVE 1 TO WS-A MOVE 5 TO WS-B MOVE 8 TO WS-E
             WHEN 9 MOVE 1 TO WS-A MOVE 10 TO WS-B MOVE 0 TO WS-E
             WHEN 10 MOVE 1 TO WS-A MOVE 15 TO WS-B MOVE 15 TO WS-E
             WHEN 11 MOVE 1 TO WS-A MOVE 99 TO WS-B MOVE 12 TO WS-E
             WHEN 12 MOVE 2 TO WS-A MOVE 0 TO WS-B MOVE 8 TO WS-E
             WHEN 13 MOVE 2 TO WS-A MOVE 5 TO WS-B MOVE 7 TO WS-E
             WHEN 14 MOVE 2 TO WS-A MOVE 10 TO WS-B MOVE 0 TO WS-E
             WHEN 15 MOVE 2 TO WS-A MOVE 15 TO WS-B MOVE 12 TO WS-E
             WHEN 16 MOVE 2 TO WS-A MOVE 18 TO WS-B MOVE 15 TO WS-E
             WHEN 17 MOVE 0 TO WS-A MOVE 99 TO WS-B MOVE 0 TO WS-E
             WHEN 18 MOVE 1 TO WS-A MOVE 17 TO WS-B MOVE 15 TO WS-E
         END-EVALUATE
         MOVE 0 TO WS-C
         CALL "M19-SHEEP-COLOR" USING WS-A WS-B WS-C WS-R
         MOVE "acceptance US15 19§2.4 Sheep colour at spawn: weighted provider table" TO WS-CASE
         MOVE WS-R TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE 0 TO WS-A
     MOVE 50 TO WS-B
     MOVE 499 TO WS-C
     CALL "M19-SHEEP-COLOR" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 Sheep colour at spawn: the 500th draw of a common provider is pink (6)" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 498 TO WS-C
     CALL "M19-SHEEP-COLOR" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 Sheep colour at spawn: draw 498 of the common provider keeps the common colour (white)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
*> 25.1 breeding colour
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-MIX-A(WS-I) TO WS-A
         MOVE WS-MIX-B(WS-I) TO WS-B
         MOVE 0 TO WS-D
         CALL "M19-SHEEP-MIX" USING WS-A WS-B WS-D WS-R
         MOVE "acceptance US15 19§25.1 Sheep dye mix: the recipe pair in the listed order gives the mixed colour" TO WS-CASE
         MOVE WS-MIX-R(WS-I) TO WS-E
         MOVE WS-R TO WS-O
         PERFORM CHECK-N
         CALL "M19-SHEEP-MIX" USING WS-B WS-A WS-D WS-R
         MOVE "acceptance US15 19§25.1 Sheep dye mix: the reversed pair gives the same colour" TO WS-CASE
         MOVE WS-R TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE 14 TO WS-A
     MOVE 13 TO WS-B
     MOVE 0 TO WS-D
     CALL "M19-SHEEP-MIX" USING WS-A WS-B WS-D WS-R
     MOVE "acceptance US15 19§25.1 Sheep dye mix: red and green have no recipe, draw 0 takes the first parent" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-D
     CALL "M19-SHEEP-MIX" USING WS-A WS-B WS-D WS-R
     MOVE "acceptance US15 19§25.1 Sheep dye mix: draw 1 takes the second parent" TO WS-CASE
     MOVE 13 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 14 TO WS-B
     CALL "M19-SHEEP-MIX" USING WS-A WS-B WS-D WS-R
     MOVE "acceptance US15 19§25.1 Sheep dye mix: two equal colours have no recipe" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
*> metadata byte
     MOVE 11 TO WS-A
     MOVE 0 TO WS-B
     CALL "M19-SHEEP-BYTE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.4 Sheep metadata: a blue sheep is byte 11" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-B
     CALL "M19-SHEEP-BYTE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.4 Sheep metadata: sheared adds 16" TO WS-CASE
     MOVE 27 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
*> shearing
     MOVE 11 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-D
     CALL "M19-SHEEP-SHEAR" USING WS-A WS-B WS-D WS-C
     MOVE "acceptance US15 19§2.4 Shearing: an adult sheep drops 1 + draw wool (draw 2 gives 3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§2.4 Shearing: the sheared flag is set (byte 27)" TO WS-CASE
     MOVE 27 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "M19-SHEEP-SHEAR" USING WS-A WS-B WS-D WS-C
     MOVE "acceptance US15 19§2.4 Shearing: a sheared sheep gives nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 11 TO WS-A
     MOVE 1 TO WS-B
     CALL "M19-SHEEP-SHEAR" USING WS-A WS-B WS-D WS-C
     MOVE "acceptance US15 19§2.4 Shearing: a baby gives nothing and keeps its byte" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-C + WS-A - 11
     PERFORM CHECK-N
*> eating grass
     MOVE 0 TO WS-A
     CALL "M19-SHEEP-EAT-BOUND" USING WS-A WS-B
     MOVE "acceptance US15 19§2.4 EatBlock: an adult starts with probability 1/1000" TO WS-CASE
     MOVE 1000 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     CALL "M19-SHEEP-EAT-BOUND" USING WS-A WS-B
     MOVE "acceptance US15 19§2.4 EatBlock: a baby starts with probability 1/50" TO WS-CASE
     MOVE 50 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "M19-SHEEP-EAT-STEP" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 EatBlock: an edible plant at the feet is destroyed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "M19-SHEEP-EAT-STEP" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 EatBlock: grass below turns into dirt" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-C
     CALL "M19-SHEEP-EAT-STEP" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 EatBlock: with mob griefing off no block changes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "M19-SHEEP-EAT-STEP" USING WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§2.4 EatBlock: nothing edible, nothing eaten" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 27 TO WS-A
     MOVE 0 TO WS-B
     MOVE -100 TO WS-C
     CALL "M19-SHEEP-ATE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.4 EatBlock: eating clears the sheared flag (wool regrows)" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§2.4 EatBlock: an adult's age is unchanged" TO WS-CASE
     MOVE -100 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-B
     CALL "M19-SHEEP-ATE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.4 EatBlock: a baby ages up by 60 ticks" TO WS-CASE
     MOVE -40 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE -30 TO WS-C
     CALL "M19-SHEEP-ATE" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.4 EatBlock: a baby's age stops at 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
*> 2.5 chicken
     MOVE 3 TO WS-A
     MOVE 100 TO WS-B
     CALL "M19-CHICKEN-EGG-TICK" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.5 Egg laying: the timer counts down" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§2.5 Egg laying: no egg before the timer ends" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     CALL "M19-CHICKEN-EGG-TICK" USING WS-A WS-B WS-C
     MOVE "acceptance US15 19§2.5 Egg laying: the egg drops when the timer reaches 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§2.5 Egg laying: the next timer is 6000 + nextInt(6000)" TO WS-CASE
     MOVE 6100 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-A
     CALL "M19-CHICKEN-EGG-ITEM" USING WS-A WS-KEY
     MOVE "acceptance US15 19§2.5 Egg laying: a temperate chicken lays an egg" TO WS-CASE
     MOVE "egg" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 2 TO WS-A
     CALL "M19-CHICKEN-EGG-ITEM" USING WS-A WS-KEY
     MOVE "acceptance US15 19§2.5 Egg laying: a warm chicken lays a brown egg" TO WS-CASE
     MOVE "brown_egg" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 1 TO WS-A
     CALL "M19-CHICKEN-EGG-ITEM" USING WS-A WS-KEY
     MOVE "acceptance US15 19§2.5 Egg laying: a cold chicken lays a blue egg" TO WS-CASE
     MOVE "blue_egg" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
*> 2.3 mooshroom
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "M19-MOOSHROOM-BREED" USING WS-A WS-B WS-C WS-D WS-R
     MOVE "acceptance US15 19§2.3 Breeding: a red pair with draw 0 of 1024 gives a brown baby" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "M19-MOOSHROOM-BREED" USING WS-A WS-B WS-C WS-D WS-R
     MOVE "acceptance US15 19§2.3 Breeding: a brown pair with draw 0 gives a red baby" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 5 TO WS-C
     MOVE 1 TO WS-D
     CALL "M19-MOOSHROOM-BREED" USING WS-A WS-B WS-C WS-D WS-R
     MOVE "acceptance US15 19§2.3 Breeding: a same-type pair otherwise gives that type" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-B
     MOVE 0 TO WS-D
     CALL "M19-MOOSHROOM-BREED" USING WS-A WS-B WS-C WS-D WS-R
     MOVE "acceptance US15 19§2.3 Breeding: a mixed pair takes the first parent on coin 0" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-D
     CALL "M19-MOOSHROOM-BREED" USING WS-A WS-B WS-C WS-D WS-R
     MOVE "acceptance US15 19§2.3 Breeding: a mixed pair takes the second parent on coin 1" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-A
     CALL "M19-MOOSHROOM-SHEAR" USING WS-A WS-KEY WS-C
     MOVE "acceptance US15 19§25.5 Shears: a red mooshroom drops red mushrooms" TO WS-CASE
     MOVE "red_mushroom" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "acceptance US15 19§25.5 Shears: five of them" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-C TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     CALL "M19-MOOSHROOM-SHEAR" USING WS-A WS-KEY WS-C
     MOVE "acceptance US15 19§25.5 Shears: a brown mooshroom drops brown mushrooms" TO WS-CASE
     MOVE "brown_mushroom" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 0 TO WS-A
     CALL "M19-MOOSHROOM-BOWL" USING WS-A WS-KEY
     MOVE "acceptance US15 19§2.3 Bowl: without stored effects the bowl becomes mushroom stew" TO WS-CASE
     MOVE "mushroom_stew" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 1 TO WS-A
     CALL "M19-MOOSHROOM-BOWL" USING WS-A WS-KEY
     MOVE "acceptance US15 19§2.3 Bowl: with stored effects it becomes suspicious stew" TO WS-CASE
     MOVE "suspicious_stew" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
*> 2.2 milking
     MOVE "bucket" TO WS-HELD
     MOVE 1 TO WS-A
     CALL "M19-COW-MILK" USING WS-HELD WS-A WS-KEY
     MOVE "acceptance US15 19§2.2 Milking: an empty bucket on an adult cow gives a milk bucket" TO WS-CASE
     MOVE "milk_bucket" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 0 TO WS-A
     CALL "M19-COW-MILK" USING WS-HELD WS-A WS-KEY
     MOVE "acceptance US15 19§2.2 Milking: a calf cannot be milked" TO WS-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "wheat" TO WS-HELD
     MOVE 1 TO WS-A
     CALL "M19-COW-MILK" USING WS-HELD WS-A WS-KEY
     MOVE "acceptance US15 19§2.2 Milking: another item gives nothing" TO WS-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM CHECK-T
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-T.
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-2.
