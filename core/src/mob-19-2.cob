*> Farm animals (docs/protocol/19 section 2 and the worked examples 25.1, 25.5; lane 002-lane-mobsfull-h4). Pure decision programs: the callers
*> own the random draws (any uniform generator is allowed, 44 part 1 section 1.4), the world and the items.
*>
*>   M19-SHEEP-COLOR USING config, w (0..99), c (0..499), colour out         2.4  colour at spawn (config 0 temperate, 1 warm, 2 cold)
*>   M19-SHEEP-MIX USING a, b, coin (0/1), colour out                        25.1 colour of a lamb
*>   M19-SHEEP-BYTE USING colour, sheared, byte out                          2.4  metadata 18
*>   M19-SHEEP-SHEAR USING byte in/out, baby, draw (0..2), count out         2.4  shearing
*>   M19-SHEEP-EAT-BOUND USING baby, bound out                               2.4  the start chance is 1 in bound
*>   M19-SHEEP-EAT-STEP USING edible at feet, grass below, griefing, action out
*>   M19-SHEEP-ATE USING byte in/out, baby, age in/out
*>   M19-CHICKEN-EGG-TICK USING egg time in/out, draw (0..5999), laid out    2.5
*>   M19-CHICKEN-EGG-ITEM USING variant, item key out
*>   M19-MOOSHROOM-BREED USING type a, type b, draw (0..1023), coin, type out 2.3
*>   M19-MOOSHROOM-SHEAR USING type, item key out, count out                 25.5
*>   M19-MOOSHROOM-BOWL USING stored effects, item key out                   2.3
*>   M19-COW-MILK USING held item key, adult, result key out                 2.2

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-COLOR.
*> USING config (0 temperate, 1 warm, 2 cold), w (the draw 0 to 99 over the provider weights), c (0 to 499 inside a "common" provider), colour out
*> (dye id): each configuration is a list of providers of total weight 100 (2.4): temperate black 5, gray 5, light gray 5, brown 3, common white 82;
*> warm gray 5, light gray 5, white 5, black 3, common brown 82; cold light gray 5, gray 5, white 5, brown 3, common black 82. A common provider gives
*> its colour with weight 499 and pink (6) with weight 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CONFIGS.
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 15.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 15.
 01 WS-CONFIG-TABLE REDEFINES WS-CONFIGS.
    05 WS-COLOR               BINARY-LONG OCCURS 15 TIMES.
 01 WS-BASE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CONFIG               BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-CONFIG L-W L-C L-COLOR.
     COMPUTE WS-BASE = L-CONFIG * 5
     EVALUATE TRUE
         WHEN L-W < 5
             MOVE 1 TO WS-SLOT
         WHEN L-W < 10
             MOVE 2 TO WS-SLOT
         WHEN L-W < 15
             MOVE 3 TO WS-SLOT
         WHEN L-W < 18
             MOVE 4 TO WS-SLOT
         WHEN OTHER
             MOVE 5 TO WS-SLOT
     END-EVALUATE
     MOVE WS-COLOR(WS-BASE + WS-SLOT) TO L-COLOR
     IF WS-SLOT = 5 AND L-C >= 499
         MOVE 6 TO L-COLOR
     END-IF
     GOBACK.
 END PROGRAM M19-SHEEP-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-MIX.
*> USING a, b (dye ids of the parents), coin (0 or 1), colour out: the result of the two-dye shapeless recipe for the pair, either order (25.1);
*> without a recipe the lamb takes the first parent on coin 0, the second on coin 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RECIPES.
    05 FILLER PIC X(9) VALUE "011013009".
    05 FILLER PIC X(9) VALUE "015000007".
    05 FILLER PIC X(9) VALUE "011000003".
    05 FILLER PIC X(9) VALUE "007000008".
    05 FILLER PIC X(9) VALUE "013000005".
    05 FILLER PIC X(9) VALUE "010006002".
    05 FILLER PIC X(9) VALUE "014004001".
    05 FILLER PIC X(9) VALUE "014000006".
    05 FILLER PIC X(9) VALUE "011014010".
 01 WS-RECIPE-TABLE REDEFINES WS-RECIPES.
    05 WS-RECIPE              OCCURS 9 TIMES.
       10 WS-R-A              PIC 999.
       10 WS-R-B              PIC 999.
       10 WS-R-RESULT         PIC 999.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 01 L-COLOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-COIN L-COLOR.
     IF L-COIN = 0
         MOVE L-A TO L-COLOR
     ELSE
         MOVE L-B TO L-COLOR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF (WS-R-A(WS-I) = L-A AND WS-R-B(WS-I) = L-B) OR (WS-R-A(WS-I) = L-B AND WS-R-B(WS-I) = L-A)
             MOVE WS-R-RESULT(WS-I) TO L-COLOR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M19-SHEEP-MIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-BYTE.
*> USING colour (dye id 0 to 15), sheared (0/1), byte out: metadata 18 of a sheep, the colour in the low nibble and 16 when sheared (1.3, 2.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-LONG.
 01 L-SHEARED              BINARY-LONG.
 01 L-BYTE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COLOR L-SHEARED L-BYTE.
     COMPUTE L-BYTE = L-COLOR + 16 * L-SHEARED
     GOBACK.
 END PROGRAM M19-SHEEP-BYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-SHEAR.
*> USING byte (metadata 18, changed), baby, draw (0 to 2: uniform(1,3) rolls of one wool each), count out: shears on a sheep that is not sheared and
*> not a baby (readyForShearing) drop 1 + draw wool of its colour and set the sheared flag (2.4); otherwise nothing changes and the count is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-BYTE                 BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-BYTE L-BABY L-DRAW L-COUNT.
     MOVE 0 TO L-COUNT
     IF L-BABY = 0 AND L-BYTE < 16
         COMPUTE L-COUNT = L-DRAW + 1
         ADD 16 TO L-BYTE
     END-IF
     GOBACK.
 END PROGRAM M19-SHEEP-SHEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-EAT-BOUND.
*> USING baby, bound out: the EatBlock goal starts on a tick when nextInt(bound) = 0: 1000 for an adult, 50 for a baby (2.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-BOUND.
     MOVE 1000 TO L-BOUND
     IF L-BABY = 1
         MOVE 50 TO L-BOUND
     END-IF
     GOBACK.
 END PROGRAM M19-SHEEP-EAT-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-EAT-STEP.
*> USING edible (the block at the feet is in the tag edible_for_sheep), grass (the block below is a grass block), griefing (the mob-griefing game
*> rule), action out: what the goal does when its timer reaches 4 (2.4): 1 destroy the plant at the feet, 2 turn the grass block below into dirt,
*> 0 nothing (no such block, or griefing off).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-EDIBLE               BINARY-LONG.
 01 L-GRASS                BINARY-LONG.
 01 L-GRIEFING             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-EDIBLE L-GRASS L-GRIEFING L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-GRIEFING = 1
         EVALUATE TRUE
             WHEN L-EDIBLE = 1
                 MOVE 1 TO L-ACTION
             WHEN L-GRASS = 1
                 MOVE 2 TO L-ACTION
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM M19-SHEEP-EAT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SHEEP-ATE.
*> USING byte (changed), baby, age (ticks, negative for a baby, changed): the sheep ate (2.4): the sheared flag is cleared and a baby ages up by 60
*> ticks, up to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-BYTE                 BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BYTE L-BABY L-AGE.
     IF L-BYTE >= 16
         SUBTRACT 16 FROM L-BYTE
     END-IF
     IF L-BABY = 1
         COMPUTE L-AGE = FUNCTION MIN(L-AGE + 60, 0)
     END-IF
     GOBACK.
 END PROGRAM M19-SHEEP-ATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-CHICKEN-EGG-TICK.
*> USING egg time (changed), draw (0 to 5999), laid out: one tick of an adult chicken's egg timer (2.5): it counts down and at 0 an egg is laid
*> (laid 1) and the timer restarts at 6000 + draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-LAID                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-DRAW L-LAID.
     MOVE 0 TO L-LAID
     SUBTRACT 1 FROM L-TIME
     IF L-TIME <= 0
         MOVE 1 TO L-LAID
         COMPUTE L-TIME = 6000 + L-DRAW
     END-IF
     GOBACK.
 END PROGRAM M19-CHICKEN-EGG-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-CHICKEN-EGG-ITEM.
*> USING variant (0 temperate, 1 cold, 2 warm), item key out (PIC X(24)): the loot of gameplay/chicken_lay: egg, blue_egg (cold), brown_egg (warm) (2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-VARIANT L-KEY.
     MOVE "egg" TO L-KEY
     EVALUATE L-VARIANT
         WHEN 1
             MOVE "blue_egg" TO L-KEY
         WHEN 2
             MOVE "brown_egg" TO L-KEY
     END-EVALUATE
     GOBACK.
 END PROGRAM M19-CHICKEN-EGG-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-MOOSHROOM-BREED.
*> USING type a, type b (0 red, 1 brown), draw (0 to 1023), coin (0/1), type out: the baby of two mooshrooms (2.3): when both parents have the same type
*> and the draw is 0 the baby has the opposite type; otherwise the first parent's type on coin 0, the second's on coin 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-DRAW L-COIN L-TYPE.
     IF L-COIN = 0
         MOVE L-A TO L-TYPE
     ELSE
         MOVE L-B TO L-TYPE
     END-IF
     IF L-A = L-B AND L-DRAW = 0
         COMPUTE L-TYPE = 1 - L-A
     END-IF
     GOBACK.
 END PROGRAM M19-MOOSHROOM-BREED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-MOOSHROOM-SHEAR.
*> USING type (0 red, 1 brown), item key out (PIC X(24)), count out: the loot table shearing/mooshroom: five mushrooms of the colour of the type (2.3, 25.5);
*> the mooshroom becomes a cow.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KEY L-COUNT.
     MOVE "red_mushroom" TO L-KEY
     IF L-TYPE = 1
         MOVE "brown_mushroom" TO L-KEY
     END-IF
     MOVE 5 TO L-COUNT
     GOBACK.
 END PROGRAM M19-MOOSHROOM-SHEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-MOOSHROOM-BOWL.
*> USING stored (1 when the mooshroom holds suspicious stew effects), item key out (PIC X(24)): what a bowl becomes (2.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-STORED               BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-STORED L-KEY.
     MOVE "mushroom_stew" TO L-KEY
     IF L-STORED = 1
         MOVE "suspicious_stew" TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM M19-MOOSHROOM-BOWL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-COW-MILK.
*> USING held (item key, PIC X(24)), adult (1/0), result key out (PIC X(24)): right-click an adult cow or mooshroom with an empty bucket: a milk bucket
*> (2.2); spaces for any other case.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-HELD                 PIC X(24).
 01 L-ADULT                BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-HELD L-ADULT L-KEY.
     MOVE SPACES TO L-KEY
     IF L-ADULT = 1 AND L-HELD = "bucket"
         MOVE "milk_bucket" TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM M19-COW-MILK.
