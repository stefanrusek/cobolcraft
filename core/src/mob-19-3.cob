*> Equines (docs/protocol/19 section 3, 25.3; lane 002-lane-mobsfull-h4). Pure decision programs; the callers own the draws and the entities.
*>
*>   M19-GENE-HEALTH USING d1 (0..7), d2 (0..8), health out                    3.2  15 + nextInt(8) + nextInt(9)
*>   M19-GENE-JUMP USING r1, r2, r3 (FLOAT-LONG 0..1), jump out                3.2  0.4 + 0.2 (r1 + r2 + r3)
*>   M19-GENE-SPEED USING r1, r2, r3, speed out                                3.2  (0.45 + 0.3 (r1 + r2 + r3)) x 0.25
*>   M19-FOAL-STAT USING a, b, min, max, r1, r2, r3, value out                 3.2  foal genes
*>   M19-HORSE-FOOD USING kind, item, found, heal, age-up s, temper, love      3.4  feeding table (kind 0 horse family, 1 llama, 2 camel, 3 zombie horse)
*>   M19-HORSE-JUMP-SCALE USING power (0..100), scale out (thousandths)        3.1
*>   M19-FOAL-COAT USING draw (0..8), this, other, random, coat out            3.3
*>   M19-FOAL-MARKINGS USING draw (0..4), this, other, random, markings out    3.3
*>   M19-HORSE-TAME USING temper, draw (0..99), tamed out                      3.4  RunAroundLikeCrazy
*>   M19-HORSE-TEMPER USING temper (changed), delta                            3.4  modifyTemper

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-GENE-HEALTH.
*> USING d1 (nextInt(8)), d2 (nextInt(9)), health out: the random max health of a horse, donkey, mule or llama (3.2), 15 to 30.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-HEALTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-D2 L-HEALTH.
     COMPUTE L-HEALTH = 15 + L-D1 + L-D2
     GOBACK.
 END PROGRAM M19-GENE-HEALTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-GENE-JUMP.
*> USING r1, r2, r3 (nextDouble draws), jump out: the jump strength gene, 0.4 to 1.0 (3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-JUMP                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-R3 L-JUMP.
     COMPUTE L-JUMP = 0.4 + 0.2 * L-R1 + 0.2 * L-R2 + 0.2 * L-R3
     GOBACK.
 END PROGRAM M19-GENE-JUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-GENE-SPEED.
*> USING r1, r2, r3, speed out: the movement speed gene (attribute value), 0.1125 to 0.3375 (3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-R3 L-SPEED.
     COMPUTE L-SPEED = (0.45 + 0.3 * L-R1 + 0.3 * L-R2 + 0.3 * L-R3) * 0.25
     GOBACK.
 END PROGRAM M19-GENE-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FOAL-STAT.
*> USING a, b (the parents' base values), min, max (the gene range), r1, r2, r3 (nextDouble draws), value out: setOffspringAttributes (3.2): clamp A
*> and B into the range, spread = |A - B| + 2 x 0.15 x range, mean = (A + B) / 2, noise = (r1 + r2 + r3) / 3 - 0.5, value = mean + spread x noise,
*> reflected at the range ends.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-B L-MIN L-MAX L-R1 L-R2 L-R3 L-VALUE.
     COMPUTE WS-A = FUNCTION MIN(FUNCTION MAX(L-A, L-MIN), L-MAX)
     COMPUTE WS-B = FUNCTION MIN(FUNCTION MAX(L-B, L-MIN), L-MAX)
     COMPUTE WS-RANGE = L-MAX - L-MIN
     COMPUTE WS-DIFF = FUNCTION ABS(WS-A - WS-B)
     COMPUTE WS-SPREAD = WS-DIFF + 2 * 0.15 * WS-RANGE
     COMPUTE L-VALUE = (WS-A + WS-B) / 2 + WS-SPREAD * ((L-R1 + L-R2 + L-R3) / 3 - 0.5)
     IF L-VALUE > L-MAX
         COMPUTE L-VALUE = L-MAX - (L-VALUE - L-MAX)
     END-IF
     IF L-VALUE < L-MIN
         COMPUTE L-VALUE = L-MIN + (L-MIN - L-VALUE)
     END-IF
     GOBACK.
 END PROGRAM M19-FOAL-STAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-HORSE-FOOD.
*> USING kind (0 horse, donkey, mule and skeleton horse; 1 llama and trader llama; 2 camel; 3 zombie horse), item (key without minecraft:, PIC X(24)),
*> found out (1 when the kind accepts the item), heal (HP), age-up (seconds, babies), temper, love out (1 when the food can start love in a tamed adult):
*> the feeding table of 3.4 and the llama and camel rows under it. Camel food ages by nothing the document gives (open item) and has no temper.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOODS.
    05 FILLER PIC X(35) VALUE "0wheat                   0020200030".
    05 FILLER PIC X(35) VALUE "0sugar                   0010300030".
    05 FILLER PIC X(35) VALUE "0hay_block               0201800000".
    05 FILLER PIC X(35) VALUE "0apple                   0030600030".
    05 FILLER PIC X(35) VALUE "0carrot                  0030600030".
    05 FILLER PIC X(35) VALUE "0golden_carrot           0040600051".
    05 FILLER PIC X(35) VALUE "0golden_apple            0102400101".
    05 FILLER PIC X(35) VALUE "0enchanted_golden_apple  0102400101".
    05 FILLER PIC X(35) VALUE "3red_mushroom            0030000030".
    05 FILLER PIC X(35) VALUE "1wheat                   0020100031".
    05 FILLER PIC X(35) VALUE "1hay_block               0100900061".
    05 FILLER PIC X(35) VALUE "2cactus                  0020000001".
 01 WS-FOOD-TABLE REDEFINES WS-FOODS.
    05 WS-FOOD               OCCURS 12 TIMES.
       10 WS-F-KIND          PIC 9.
       10 WS-F-ITEM          PIC X(24).
       10 WS-F-HEAL          PIC 999.
       10 WS-F-AGE           PIC 999.
       10 WS-F-TEMPER        PIC 999.
       10 WS-F-LOVE          PIC 9.
 01 WS-I                   BINARY-LONG.
 01 WS-WANT                PIC 9.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ITEM                 PIC X(24).
 01 L-FOUND                BINARY-LONG.
 01 L-HEAL                 BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-TEMPER               BINARY-LONG.
 01 L-LOVE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ITEM L-FOUND L-HEAL L-AGE L-TEMPER L-LOVE.
     MOVE 0 TO L-FOUND L-HEAL L-AGE L-TEMPER L-LOVE
     MOVE L-KIND TO WS-WANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF WS-F-KIND(WS-I) = WS-WANT AND WS-F-ITEM(WS-I) = L-ITEM
             MOVE 1 TO L-FOUND
             MOVE WS-F-HEAL(WS-I) TO L-HEAL
             MOVE WS-F-AGE(WS-I) TO L-AGE
             MOVE WS-F-TEMPER(WS-I) TO L-TEMPER
             MOVE WS-F-LOVE(WS-I) TO L-LOVE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M19-HORSE-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-HORSE-JUMP-SCALE.
*> USING power (the jump power 0 to 100 the client sends), scale out (thousandths): 0.4 + 0.4 p / 90 below 90, the full scale 1.0 from 90 up (3.1);
*> a power below 0 counts as 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-SCALE.
     MOVE FUNCTION MAX(L-POWER, 0) TO WS-P
     IF WS-P >= 90
         MOVE 1000 TO L-SCALE
     ELSE
         COMPUTE L-SCALE = 400 + 400 * WS-P / 90
     END-IF
     GOBACK.
 END PROGRAM M19-HORSE-JUMP-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FOAL-COAT.
*> USING draw (nextInt(9)), this coat, other coat, random coat (a uniform draw of the 7 coats), coat out: 0 to 3 this parent's, 4 to 7 the other's, 8 random (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-THIS                 BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 01 L-COAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-THIS L-OTHER L-RANDOM L-COAT.
     EVALUATE TRUE
         WHEN L-DRAW < 4
             MOVE L-THIS TO L-COAT
         WHEN L-DRAW < 8
             MOVE L-OTHER TO L-COAT
         WHEN OTHER
             MOVE L-RANDOM TO L-COAT
     END-EVALUATE
     GOBACK.
 END PROGRAM M19-FOAL-COAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FOAL-MARKINGS.
*> USING draw (nextInt(5)), this markings, other markings, random markings, markings out: 0 to 1 this parent's, 2 to 3 the other's, 4 random (3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-THIS                 BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 01 L-MARKINGS             BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-THIS L-OTHER L-RANDOM L-MARKINGS.
     EVALUATE TRUE
         WHEN L-DRAW < 2
             MOVE L-THIS TO L-MARKINGS
         WHEN L-DRAW < 4
             MOVE L-OTHER TO L-MARKINGS
         WHEN OTHER
             MOVE L-RANDOM TO L-MARKINGS
     END-EVALUATE
     GOBACK.
 END PROGRAM M19-FOAL-MARKINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-HORSE-TAME.
*> USING temper, draw (nextInt(100)), tamed out: the RunAroundLikeCrazy goal tames its rider when the temper is above 0 and the draw is below it (3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TEMPER               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-TAMED                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMPER L-DRAW L-TAMED.
     MOVE 0 TO L-TAMED
     IF L-TEMPER > 0 AND L-DRAW < L-TEMPER
         MOVE 1 TO L-TAMED
     END-IF
     GOBACK.
 END PROGRAM M19-HORSE-TAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-HORSE-TEMPER.
*> USING temper (changed), delta: modifyTemper, clamped to 0 .. 100 (3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TEMPER               BINARY-LONG.
 01 L-DELTA                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMPER L-DELTA.
     COMPUTE L-TEMPER = FUNCTION MIN(FUNCTION MAX(L-TEMPER + L-DELTA, 0), 100)
     GOBACK.
 END PROGRAM M19-HORSE-TEMPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LLAMA-STRENGTH.
*> USING roll (0 to 9999 for nextFloat), draw (a draw below 60, uniform for 3 and 5), strength out: the strength of a new llama (3.7, 44 part 4 section 2.2): bound 5 when nextFloat < 0.04, else 3;
*> strength = 1 + nextInt(bound).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROLL                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-DRAW L-STRENGTH.
     MOVE 3 TO WS-BOUND
     IF L-ROLL < 400
         MOVE 5 TO WS-BOUND
     END-IF
     COMPUTE L-STRENGTH = 1 + FUNCTION MOD(L-DRAW, WS-BOUND)
     GOBACK.
 END PROGRAM LLAMA-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LLAMA-FOAL-STRENGTH.
*> USING strength a, strength b, draw (below 60), roll (0 to 9999), strength out: nextInt(max(a, b)) + 1, plus 1 with probability 0.03 (nextFloat < 0.03), at most 5 (44 part 4 section 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SA                   BINARY-LONG.
 01 L-SB                   BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-SA L-SB L-DRAW L-ROLL L-STRENGTH.
     COMPUTE WS-MAX = FUNCTION MAX(L-SA, L-SB)
     COMPUTE L-STRENGTH = FUNCTION MOD(L-DRAW, WS-MAX) + 1
     IF L-ROLL < 300
         ADD 1 TO L-STRENGTH
     END-IF
     IF L-STRENGTH > 5
         MOVE 5 TO L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM LLAMA-FOAL-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LLAMA-BORN.
*> USING row: a new llama's strength (LLAMA-STRENGTH) and a variant of the four (uniform; the group's shared variant is an open item).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-ROLL           BINARY-LONG VALUE 81.
 01 WS-SALT-DRAW           BINARY-LONG VALUE 82.
 01 WS-SALT-VARIANT        BINARY-LONG VALUE 83.
 01 WS-BOUND-ROLL          BINARY-LONG VALUE 10000.
 01 WS-BOUND-DRAW          BINARY-LONG VALUE 60.
 01 WS-BOUND-VARIANT       BINARY-LONG VALUE 4.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT-ROLL WS-BOUND-ROLL WS-ROLL
     CALL "XP-RANDOM" USING WS-SALT-DRAW WS-BOUND-DRAW WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW EN-STRENGTH(L-ROW)
     CALL "XP-RANDOM" USING WS-SALT-VARIANT WS-BOUND-VARIANT EN-WOOL(L-ROW)
     GOBACK.
 END PROGRAM LLAMA-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LLAMA-BRED.
*> USING parent a, parent b, baby, coin: the foal's strength (LLAMA-FOAL-STRENGTH) and the variant of the parent the coin names (44 part 4 section 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-ROLL           BINARY-LONG VALUE 84.
 01 WS-SALT-DRAW           BINARY-LONG VALUE 85.
 01 WS-BOUND-ROLL          BINARY-LONG VALUE 10000.
 01 WS-BOUND-DRAW          BINARY-LONG VALUE 60.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY L-COIN.
     CALL "XP-RANDOM" USING WS-SALT-ROLL WS-BOUND-ROLL WS-ROLL
     CALL "XP-RANDOM" USING WS-SALT-DRAW WS-BOUND-DRAW WS-DRAW
     CALL "LLAMA-FOAL-STRENGTH" USING EN-STRENGTH(L-A) EN-STRENGTH(L-B) WS-DRAW WS-ROLL EN-STRENGTH(L-BABY)
     MOVE EN-WOOL(L-A) TO EN-WOOL(L-BABY)
     IF L-COIN = 1
         MOVE EN-WOOL(L-B) TO EN-WOOL(L-BABY)
     END-IF
     GOBACK.
 END PROGRAM LLAMA-BRED.
