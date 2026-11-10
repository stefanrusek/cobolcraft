*> The heart, armour, food, air and mount rows of the HUD (docs/protocol/49 section 5; 12 5.4). HB-RNG-SEED and HB-RNG-NEXT are the random source of a frame
*> (the Java LCG, seeded with the HUD tick count x 312871, one call per drawn jitter); HEALTH-HURT-TO takes a Set Health (the first only arms the
*> flash, later ones set the damage cooldown: 20 on a fall, 10 on a rise); HEARTS-FRAME does the per-frame blink state (5.1); HEART-MAX and HEART-ROWS give
*> the shown maximum and the rows; METER-ICON gives one icon of a row (position with jitter and sprite rows); METER-AIR-SHOWN tells whether the air row
*> is drawn. EFFECT-HAS asks the effect list. Kinds of row (the argument of a meter widget): 1 hearts, 2 food, 3 armour, 4 air, 5 mount health.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HB-XOR48.
*> USING a, b, result (BINARY-DOUBLE, below 2^48): a exclusive or b, bit by bit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-BIT                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-DOUBLE.
 01 L-B                    BINARY-DOUBLE.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     MOVE L-A TO WS-A
     MOVE L-B TO WS-B
     MOVE 0 TO L-RESULT
     MOVE 1 TO WS-BIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 48
         IF FUNCTION MOD(WS-A, 2) NOT = FUNCTION MOD(WS-B, 2)
             ADD WS-BIT TO L-RESULT
         END-IF
         COMPUTE WS-A = WS-A / 2
         COMPUTE WS-B = WS-B / 2
         COMPUTE WS-BIT = WS-BIT * 2
     END-PERFORM
     GOBACK.
 END PROGRAM HB-XOR48.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HB-RNG-SEED.
*> USING CLIENT-STATE: HB-RNG becomes the state of new Random(tick x 312871): the product as a 32-bit int (it wraps), widened, exclusive-or
*> 0x5DEECE66D, kept to 48 bits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-MASK                BINARY-DOUBLE VALUE 281474976710656.
 01 WS-SCRAMBLE            BINARY-DOUBLE VALUE 25214903917.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     COMPUTE WS-V = FUNCTION MOD(HB-TICK * 312871, 4294967296)
     IF WS-V >= 2147483648
         COMPUTE WS-V = WS-V - 4294967296
     END-IF
     COMPUTE WS-V = FUNCTION MOD(WS-V, WS-MASK)
     CALL "HB-XOR48" USING WS-V WS-SCRAMBLE HB-RNG
     GOBACK.
 END PROGRAM HB-RNG-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HB-RNG-STEP.
*> USING CLIENT-STATE, value (out): one step of the LCG (state x 0x5DEECE66D + 11 mod 2^48) and next(31), the top 31 bits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MASK                BINARY-DOUBLE VALUE 281474976710656.
 01 WS-LOW-MASK            BINARY-DOUBLE VALUE 16777216.
 01 WS-AL                  BINARY-DOUBLE VALUE 15525485.
 01 WS-AH                  BINARY-DOUBLE VALUE 1502.
 01 WS-SL                  BINARY-DOUBLE.
 01 WS-SH                  BINARY-DOUBLE.
 01 WS-MID                 BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-R                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-R.
     COMPUTE WS-SL = FUNCTION MOD(HB-RNG, WS-LOW-MASK)
     COMPUTE WS-SH = HB-RNG / WS-LOW-MASK
     COMPUTE WS-MID = FUNCTION MOD(WS-AH * WS-SL + WS-AL * WS-SH, WS-LOW-MASK)
     COMPUTE HB-RNG = FUNCTION MOD(WS-AL * WS-SL + WS-MID * WS-LOW-MASK + 11, WS-MASK)
     COMPUTE L-R = HB-RNG / 131072
     GOBACK.
 END PROGRAM HB-RNG-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HB-RNG-NEXT.
*> USING CLIENT-STATE, bound (2 or 3 and the like), value (out): Random.nextInt(bound): the bound 2 takes the top bit of next(31); another bound
*> draws next(31) again while the remainder would overflow.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BOUND                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BOUND L-VALUE.
     CALL "HB-RNG-STEP" USING CLIENT-STATE WS-R
     IF L-BOUND = 2
         COMPUTE L-VALUE = WS-R / 1073741824
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         COMPUTE L-VALUE = FUNCTION MOD(WS-R, L-BOUND)
         IF WS-R - L-VALUE + L-BOUND - 1 < 2147483648
             MOVE 1 TO WS-DONE
         ELSE
             CALL "HB-RNG-STEP" USING CLIENT-STATE WS-R
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HB-RNG-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEALTH-HURT-TO.
*> USING CLIENT-STATE, new health (FLOAT-SHORT): Set Health for the local player (LocalPlayer.hurtTo, 49 section 5.1). The first one received by this
*> player only stores the health; later ones set the damage cooldown to 20 when the health fell and to 10 when it rose.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HEALTH               FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-HEALTH.
     IF HB-FLASH-ARMED = 1
         EVALUATE TRUE
             WHEN PL-HEALTH > L-HEALTH
                 MOVE 20 TO HB-COOLDOWN
             WHEN PL-HEALTH < L-HEALTH
                 MOVE 10 TO HB-COOLDOWN
         END-EVALUATE
     END-IF
     MOVE 1 TO HB-FLASH-ARMED
     MOVE L-HEALTH TO PL-HEALTH
     GOBACK.
 END PROGRAM HEALTH-HURT-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEARTS-FRAME.
*> USING CLIENT-STATE, now (milliseconds): the per-frame state of the hearts (49 section 5.1). The blink flag is on when the blink time is later than
*> the tick and (blink time - tick) div 3 is odd, from the values of the previous frame; then a fall with the cooldown above 0 sets the blink time to
*> tick + 20 and a rise to tick + 10 (and the last-change clock to now); after more than 1000 ms without a change displayHealth is the health.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-THIRDS              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NOW                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-NOW.
     MOVE 0 TO HB-BLINK
     IF HB-BLINK-TIME > HB-TICK
         COMPUTE WS-LEFT = HB-BLINK-TIME - HB-TICK
         COMPUTE WS-THIRDS = WS-LEFT / 3
         IF FUNCTION MOD(WS-THIRDS, 2) = 1
             MOVE 1 TO HB-BLINK
         END-IF
     END-IF
     COMPUTE WS-H = FUNCTION INTEGER(PL-HEALTH)
     IF PL-HEALTH > WS-H
         ADD 1 TO WS-H
     END-IF
     EVALUATE TRUE
         WHEN WS-H < HB-LAST-HEALTH AND HB-COOLDOWN > 0
             MOVE L-NOW TO HB-LAST-TIME
             COMPUTE HB-BLINK-TIME = HB-TICK + 20
         WHEN WS-H > HB-LAST-HEALTH AND HB-COOLDOWN > 0
             MOVE L-NOW TO HB-LAST-TIME
             COMPUTE HB-BLINK-TIME = HB-TICK + 10
     END-EVALUATE
     IF L-NOW - HB-LAST-TIME > 1000
         MOVE WS-H TO HB-DISPLAY-HEALTH
         MOVE L-NOW TO HB-LAST-TIME
     END-IF
     MOVE WS-H TO HB-LAST-HEALTH
     GOBACK.
 END PROGRAM HEARTS-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EFFECT-HAS.
*> USING CLIENT-STATE, effect id, has (out 1/0): whether the local player has the effect.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-HAS.
     MOVE 0 TO L-HAS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
         IF EF-ID(WS-I) = L-ID
             MOVE 1 TO L-HAS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EFFECT-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-MAX.
*> USING CLIENT-STATE, maximum (out, in half hearts, whole): max(max health attribute, displayHealth, ceil health) rounded up (49 section 5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MAX.
     COMPUTE L-MAX = FUNCTION INTEGER(PL-MAX-HEALTH)
     IF PL-MAX-HEALTH > L-MAX
         ADD 1 TO L-MAX
     END-IF
     COMPUTE WS-H = FUNCTION INTEGER(PL-HEALTH)
     IF PL-HEALTH > WS-H
         ADD 1 TO WS-H
     END-IF
     MOVE FUNCTION MAX(L-MAX, WS-H, HB-DISPLAY-HEALTH) TO L-MAX
     GOBACK.
 END PROGRAM HEART-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-ROWS.
*> USING CLIENT-STATE, rows (out), row height (out): R = ceil((M + A) / 2 / 10) and max(10 - (R - 2), 3) (49 section 5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROWS                 BINARY-LONG.
 01 L-ROW-HEIGHT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROWS L-ROW-HEIGHT.
     CALL "HEART-MAX" USING CLIENT-STATE WS-M
     COMPUTE WS-A = FUNCTION INTEGER(PL-ABSORPTION)
     IF PL-ABSORPTION > WS-A
         ADD 1 TO WS-A
     END-IF
     COMPUTE L-ROWS = (WS-M + WS-A + 19) / 20
     COMPUTE L-ROW-HEIGHT = FUNCTION MAX(10 - (L-ROWS - 2), 3)
     GOBACK.
 END PROGRAM HEART-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-AIR-SHOWN.
*> USING CLIENT-STATE, shown (out 1/0): the air row is drawn while the eyes are in water or the air supply is below the maximum (49 section 5.5).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SHOWN                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SHOWN.
     MOVE 0 TO L-SHOWN
     IF PL-EYES-WATER = 1 OR PL-AIR < PL-MAX-AIR
         MOVE 1 TO L-SHOWN
     END-IF
     GOBACK.
 END PROGRAM METER-AIR-SHOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HEART-VARIANT.
*> USING type (0 normal, 1 poisoned, 2 withered, 3 frozen, 4 absorbing), hardcore, half (1 half, 0 full), blinking, row (out): the sprite row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-HARDCORE             BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-BLINK                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-HARDCORE L-HALF L-BLINK L-ROW.
     COMPUTE L-ROW = GSP-HEART-VARIANT-0 + ((L-TYPE * 2 + L-HARDCORE) * 2 + L-HALF) * 2 + L-BLINK
     GOBACK.
 END PROGRAM HEART-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIR-CEIL.
*> USING numerator, divisor, ceil (out): ceil(numerator / divisor); the truncating division rounds a negative quotient up already.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NUM                  BINARY-LONG.
 01 L-DIV                  BINARY-LONG.
 01 L-CEIL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NUM L-DIV L-CEIL.
     IF L-NUM >= 0
         COMPUTE L-CEIL = (L-NUM + L-DIV - 1) / L-DIV
     ELSE
         COMPUTE L-CEIL = L-NUM / L-DIV
     END-IF
     GOBACK.
 END PROGRAM AIR-CEIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON-HEARTS.
*> USING CLIENT-STATE, icon number, anchor x, anchor y, out (see METER-ICON): the hearts row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW-HEIGHT          BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HARD                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RND                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIVISOR             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MAXAIR              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-POP                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT.
     MOVE L-X0 TO O-X
     MOVE L-Y0 TO O-Y
     MOVE 0 TO O-BASE O-ABSORB O-GHOST O-CURRENT
     CALL "HEART-MAX" USING CLIENT-STATE WS-M
     CALL "HEART-ROWS" USING CLIENT-STATE WS-ROWS WS-ROW-HEIGHT
     COMPUTE WS-H = FUNCTION INTEGER(PL-HEALTH)
     IF PL-HEALTH > WS-H
         ADD 1 TO WS-H
     END-IF
     COMPUTE WS-A = FUNCTION INTEGER(PL-ABSORPTION)
     IF PL-ABSORPTION > WS-A
         ADD 1 TO WS-A
     END-IF
     COMPUTE WS-HH = (WS-M + 1) / 2
     COMPUTE WS-AH = (WS-A + 1) / 2
     COMPUTE WS-R = L-K / 10
     COMPUTE O-X = L-X0 + 8 * (L-K - WS-R * 10)
     COMPUTE O-Y = L-Y0 - WS-R * WS-ROW-HEIGHT
     IF WS-H + WS-A <= 4
         MOVE 2 TO WS-BOUND
         CALL "HB-RNG-NEXT" USING CLIENT-STATE WS-BOUND WS-RND
         ADD WS-RND TO O-Y
     END-IF
     CALL "EFFECT-HAS" USING CLIENT-STATE WS-REGEN WS-HAS
     IF WS-HAS = 1 AND L-K < WS-HH AND L-K = FUNCTION MOD(HB-TICK, WS-M + 5)
         SUBTRACT 2 FROM O-Y
     END-IF
*>   The type of the hearts: poison, else wither, else frozen, else normal.
     MOVE 0 TO WS-TYPE
     CALL "EFFECT-HAS" USING CLIENT-STATE WS-WITHER WS-HAS
     IF WS-HAS = 1
         MOVE 2 TO WS-TYPE
     END-IF
     IF WS-TYPE = 0 AND PL-TICKS-FROZEN >= CL-FREEZE-TICKS
         MOVE 3 TO WS-TYPE
     END-IF
     CALL "EFFECT-HAS" USING CLIENT-STATE WS-POISON WS-HAS
     IF WS-HAS = 1
         MOVE 1 TO WS-TYPE
     END-IF
     MOVE PL-HARDCORE TO WS-HARD
     MOVE GSP-HEART-CONTAINER TO O-BASE
     EVALUATE TRUE
         WHEN WS-HARD = 1 AND HB-BLINK = 1
             MOVE GSP-HEART-CONTAINER-HARDCORE-BLINK TO O-BASE
         WHEN WS-HARD = 1
             MOVE GSP-HEART-CONTAINER-HARDCORE TO O-BASE
         WHEN HB-BLINK = 1
             MOVE GSP-HEART-CONTAINER-BLINK TO O-BASE
     END-EVALUATE
     COMPUTE WS-U = 2 * L-K - 2 * WS-HH
     IF L-K >= WS-HH AND WS-U < WS-A
         MOVE 0 TO WS-HALF
         IF WS-U + 1 = WS-A
             MOVE 1 TO WS-HALF
         END-IF
         MOVE 4 TO WS-R
         IF WS-TYPE = 2
             MOVE 2 TO WS-R
         END-IF
         MOVE 0 TO WS-J
         CALL "HEART-VARIANT" USING WS-R WS-HARD WS-HALF WS-J O-ABSORB
     END-IF
     IF HB-BLINK = 1 AND 2 * L-K < HB-DISPLAY-HEALTH
         MOVE 0 TO WS-HALF
         IF 2 * L-K + 1 = HB-DISPLAY-HEALTH
             MOVE 1 TO WS-HALF
         END-IF
         CALL "HEART-VARIANT" USING WS-TYPE WS-HARD WS-HALF WS-ONE O-GHOST
     END-IF
     IF 2 * L-K < WS-H
         MOVE 0 TO WS-HALF
         IF 2 * L-K + 1 = WS-H
             MOVE 1 TO WS-HALF
         END-IF
         MOVE 0 TO WS-J
         CALL "HEART-VARIANT" USING WS-TYPE WS-HARD WS-HALF WS-J O-CURRENT
     END-IF
     GOBACK.
 END PROGRAM METER-ICON-HEARTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON-FOOD.
*> USING CLIENT-STATE, icon number, anchor x, anchor y, out (see METER-ICON): the food row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW-HEIGHT          BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HARD                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RND                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIVISOR             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MAXAIR              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-POP                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT.
     MOVE L-X0 TO O-X
     MOVE L-Y0 TO O-Y
     MOVE 0 TO O-BASE O-ABSORB O-GHOST O-CURRENT
     COMPUTE O-X = L-X0 - 8 * L-K
     CALL "EFFECT-HAS" USING CLIENT-STATE WS-HUNGER WS-HAS
     MOVE GSP-FOOD-EMPTY TO O-BASE
     IF WS-HAS = 1
         MOVE GSP-FOOD-EMPTY-HUNGER TO O-BASE
     END-IF
     IF 2 * L-K + 1 < PL-FOOD
         MOVE GSP-FOOD-FULL TO O-CURRENT
         IF WS-HAS = 1
             MOVE GSP-FOOD-FULL-HUNGER TO O-CURRENT
         END-IF
     END-IF
     IF 2 * L-K + 1 = PL-FOOD
         MOVE GSP-FOOD-HALF TO O-CURRENT
         IF WS-HAS = 1
             MOVE GSP-FOOD-HALF-HUNGER TO O-CURRENT
         END-IF
     END-IF
     COMPUTE WS-DIVISOR = PL-FOOD * 3 + 1
     IF PL-SATURATION <= 0 AND FUNCTION MOD(HB-TICK, WS-DIVISOR) = 0
         MOVE 3 TO WS-BOUND
         CALL "HB-RNG-NEXT" USING CLIENT-STATE WS-BOUND WS-RND
         COMPUTE O-Y = O-Y + WS-RND - 1
     END-IF
     GOBACK.
 END PROGRAM METER-ICON-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON-ARMOUR.
*> USING CLIENT-STATE, icon number, anchor x, anchor y, out (see METER-ICON): the armour row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW-HEIGHT          BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HARD                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RND                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIVISOR             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MAXAIR              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-POP                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT.
     MOVE L-X0 TO O-X
     MOVE L-Y0 TO O-Y
     MOVE 0 TO O-BASE O-ABSORB O-GHOST O-CURRENT
     COMPUTE O-X = L-X0 + 8 * L-K
     EVALUATE TRUE
         WHEN 2 * L-K + 1 < PL-ARMOR
             MOVE GSP-ARMOR-FULL TO O-CURRENT
         WHEN 2 * L-K + 1 = PL-ARMOR
             MOVE GSP-ARMOR-HALF TO O-CURRENT
         WHEN OTHER
             MOVE GSP-ARMOR-EMPTY TO O-CURRENT
     END-EVALUATE
     GOBACK.
 END PROGRAM METER-ICON-ARMOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON-AIR.
*> USING CLIENT-STATE, icon number, anchor x, anchor y, out (see METER-ICON): the air row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW-HEIGHT          BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HARD                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RND                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIVISOR             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MAXAIR              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-POP                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT.
     MOVE L-X0 TO O-X
     MOVE L-Y0 TO O-Y
     MOVE 0 TO O-BASE O-ABSORB O-GHOST O-CURRENT
     COMPUTE O-X = L-X0 - 8 * (L-K - 1)
     MOVE PL-MAX-AIR TO WS-MAXAIR
     COMPUTE WS-AIR = FUNCTION MAX(0, FUNCTION MIN(PL-AIR, WS-MAXAIR))
     COMPUTE WS-NUM = (WS-AIR - 2) * 10
     CALL "AIR-CEIL" USING WS-NUM WS-MAXAIR WS-CEIL
     MOVE WS-CEIL TO WS-FULL
     COMPUTE WS-NUM = WS-AIR * 10
     CALL "AIR-CEIL" USING WS-NUM WS-MAXAIR WS-CEIL
     MOVE WS-CEIL TO WS-POP
     MOVE 0 TO WS-DELAY
     IF WS-AIR = 0 AND PL-EYES-WATER = 1
         MOVE 1 TO WS-DELAY
     END-IF
     COMPUTE WS-NUM = (WS-AIR + WS-DELAY) * 10
     CALL "AIR-CEIL" USING WS-NUM WS-MAXAIR WS-CEIL
     COMPUTE WS-EMPTY = 10 - WS-CEIL
     EVALUATE TRUE
         WHEN L-K <= WS-FULL
             MOVE GSP-AIR TO O-CURRENT
         WHEN WS-FULL NOT = WS-POP AND L-K = WS-POP AND PL-EYES-WATER = 1
             MOVE GSP-AIR-BURSTING TO O-CURRENT
         WHEN L-K > 10 - WS-EMPTY
             MOVE GSP-AIR-EMPTY TO O-CURRENT
             IF WS-EMPTY = 10 AND FUNCTION MOD(HB-TICK, 2) = 0
                 MOVE 2 TO WS-BOUND
                 CALL "HB-RNG-NEXT" USING CLIENT-STATE WS-BOUND WS-RND
                 ADD WS-RND TO O-Y
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM METER-ICON-AIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON-MOUNT.
*> USING CLIENT-STATE, icon number, anchor x, anchor y, out (see METER-ICON): the mount row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-AH                  BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW-HEIGHT          BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-HARD                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RND                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DIVISOR             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MAXAIR              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-POP                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CEIL                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT.
     MOVE L-X0 TO O-X
     MOVE L-Y0 TO O-Y
     MOVE 0 TO O-BASE O-ABSORB O-GHOST O-CURRENT
     COMPUTE WS-R = L-K / 10
     COMPUTE WS-J = L-K - WS-R * 10
     COMPUTE O-X = L-X0 - 8 * WS-J
     COMPUTE O-Y = L-Y0 - 10 * WS-R
     MOVE GSP-VEHICLE-CONTAINER TO O-BASE
     COMPUTE WS-LEVEL = 2 * WS-J + 1 + 20 * WS-R
     EVALUATE TRUE
         WHEN WS-LEVEL < PL-MOUNT-HEALTH
             MOVE GSP-VEHICLE-FULL TO O-CURRENT
         WHEN WS-LEVEL = PL-MOUNT-HEALTH
             MOVE GSP-VEHICLE-HALF TO O-CURRENT
     END-EVALUATE
     GOBACK.
 END PROGRAM METER-ICON-MOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. METER-ICON.
*> USING CLIENT-STATE, kind, icon number, anchor x, anchor y, out (x, y, base, absorb, ghost, current: six BINARY-LONG): one icon of a row; base is the
*> sprite drawn first (container, empty icon), absorb the absorption heart, ghost the blinking heart under the current one, current the sprite drawn
*> last; 0 draws nothing. Hearts: icon = slot (the caller goes from the last slot down to 0, the order of the random numbers); food 0 to 9, armour 0
*> to 9, air 1 to 10, mount 0 to the last heart.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-OUT.
    05 O-X                 BINARY-LONG.
    05 O-Y                 BINARY-LONG.
    05 O-BASE              BINARY-LONG.
    05 O-ABSORB            BINARY-LONG.
    05 O-GHOST             BINARY-LONG.
    05 O-CURRENT           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-K L-X0 L-Y0 L-OUT.
     EVALUATE L-KIND
         WHEN 1
             CALL "METER-ICON-HEARTS" USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT
         WHEN 2
             CALL "METER-ICON-FOOD" USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT
         WHEN 3
             CALL "METER-ICON-ARMOUR" USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT
         WHEN 4
             CALL "METER-ICON-AIR" USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT
         WHEN OTHER
             CALL "METER-ICON-MOUNT" USING CLIENT-STATE L-K L-X0 L-Y0 L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM METER-ICON.
