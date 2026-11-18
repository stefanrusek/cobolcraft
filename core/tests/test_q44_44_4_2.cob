*> Equines (docs/protocol/44-residual-mob-questions-4-land-animals.md section 2, worked example 2 of section 19; lane 002-lane-p49i, T22590; phase task T2732): the jump scale, the llama
*> (strength, foal strength, inventory) and the camel and camel husk constants. The llama caravan and spit, the camel sitting, dash and pose and the riding jump are proven by
*> test_mob_44_llama, test_mob_44_beecamel and test_mob_44_ridejump (their case names start 44§2.x); programs of core/src/q44-44-4.cob and mob-19-3.cob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-GAME                BINARY-DOUBLE.
 01 WS-LAST                BINARY-DOUBLE.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-SA                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
*>   2.1 jump scale.
     MOVE 90 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L1 WS-A WS-B
     MOVE "jump scale: power 90 and above is 1.0 (read, not inferred), and the saddled horse may rear" TO WS-CASE
     MOVE 11000 TO WS-E
     COMPUTE WS-O = WS-B * 10 + WS-A * 1000
     PERFORM CHECK-N
     MOVE 100 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L1 WS-A WS-B
     MOVE "jump scale: power 100 is 1.0" TO WS-CASE
     MOVE 1000 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     MOVE 45 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L1 WS-A WS-B
     MOVE "jump scale: power 45 is 0.4 + 0.4 x 45 / 90 = 0.6" TO WS-CASE
     MOVE 600 TO WS-E
     MOVE WS-B TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L1 WS-A WS-B
     MOVE "jump scale: power 0 is 0.4 and the horse may rear" TO WS-CASE
     MOVE 1400 TO WS-E
     COMPUTE WS-O = WS-B + WS-A * 1000
     PERFORM CHECK-N
     MOVE -10 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L1 WS-A WS-B
     MOVE "jump scale: a power below 0 becomes 0 (scale 0.4) and does not make the horse stand" TO WS-CASE
     MOVE 400 TO WS-E
     COMPUTE WS-O = WS-B + WS-A * 1000
     PERFORM CHECK-N
     MOVE 70 TO WS-P
     CALL "Q4-PLAYER-JUMP" USING WS-P WS-L0 WS-A WS-B
     MOVE "an unsaddled horse stores no pending scale and does not rear" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-B + WS-A * 1000
     PERFORM CHECK-N
     MOVE 30.0 TO WS-FA
     CALL "Q4-RIDDEN-PITCH" USING WS-FA WS-FB
     MOVE "ridden rotation: the pitch is half the rider's pitch (30 gives 15)" TO WS-CASE
     MOVE 150 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FB * 10
     PERFORM CHECK-N
*>   2.2 llama strength at spawn: nextFloat < 0.04 selects the bound 5, else 3.
     MOVE 399 TO WS-ROLL
     MOVE 4 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-A
     MOVE "llama strength: nextFloat below 0.04 gives the bound 5: draw 4 is strength 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 400 TO WS-ROLL
     MOVE 2 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-A
     MOVE "llama strength: nextFloat 0.04 or more gives the bound 3: draw 2 is strength 3" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-DRAW
     CALL "LLAMA-STRENGTH" USING WS-ROLL WS-DRAW WS-A
     MOVE "llama strength: draw 0 is strength 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Offspring (worked example 2): parents 3 and 5: nextInt(5) + 1, plus 1 with probability 0.03, clamped to 5.
     MOVE 3 TO WS-SA
     MOVE 5 TO WS-SB
     MOVE 4 TO WS-DRAW
     MOVE 5000 TO WS-ROLL
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-A
     MOVE "foal strength of parents 3 and 5: draw 4 gives 5 with no bonus" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 100 TO WS-ROLL
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-A
     MOVE "foal strength: the 3 percent bonus on 5 would be 6 and is clamped to 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-DRAW
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-A
     MOVE "foal strength: draw 0 with the bonus is 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 5000 TO WS-ROLL
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-A
     MOVE "foal strength: draw 0 without the bonus is 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-SA
     MOVE 2 TO WS-SB
     MOVE 59 TO WS-DRAW
     CALL "LLAMA-FOAL-STRENGTH" USING WS-SA WS-SB WS-DRAW WS-ROLL WS-A
     MOVE "foal strength is drawn below the larger parent strength: parents 1 and 2, draw 59 is 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   Inventory: columns = strength with a chest; slots = 3 x columns (a strength-4 chested llama has 12); the donkey and mule 5 columns, 15 slots.
     MOVE 4 TO WS-P
     CALL "Q4-LLAMA-SLOTS" USING WS-L1 WS-P WS-L0 WS-A WS-B
     MOVE "llama inventory: a chested llama of strength 4 has 4 columns and 12 slots" TO WS-CASE
     MOVE 412 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     CALL "Q4-LLAMA-SLOTS" USING WS-L0 WS-P WS-L0 WS-A WS-B
     MOVE "llama inventory: without a chest no columns and no slots" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     MOVE 1 TO WS-P
     CALL "Q4-LLAMA-SLOTS" USING WS-L1 WS-P WS-L0 WS-A WS-B
     MOVE "llama inventory: strength 1 has 3 chest slots (the minimum)" TO WS-CASE
     MOVE 103 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     MOVE 5 TO WS-P
     CALL "Q4-LLAMA-SLOTS" USING WS-L1 WS-P WS-L0 WS-A WS-B
     MOVE "llama inventory: strength 5 has 15 chest slots (the maximum)" TO WS-CASE
     MOVE 515 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     CALL "Q4-LLAMA-SLOTS" USING WS-L1 WS-P WS-L1 WS-A WS-B
     MOVE "donkey and mule: 5 columns, 15 slots" TO WS-CASE
     MOVE 515 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
*>   2.3 camel: pose time, standing up instantly, the sitting start conditions, the constants.
     MOVE 1000 TO WS-GAME
     MOVE -600 TO WS-LAST
     CALL "Q4-CAMEL-POSE-TIME" USING WS-GAME WS-LAST WS-TIME
     MOVE "camel pose time: game time - |stored tick| (the absolute value is of the stored tick only): 1000 - 600 = 400" TO WS-CASE
     MOVE 400 TO WS-E
     MOVE WS-TIME TO WS-O
     PERFORM CHECK-N
     MOVE 600 TO WS-LAST
     CALL "Q4-CAMEL-POSE-TIME" USING WS-GAME WS-LAST WS-TIME
     MOVE "camel pose time with a positive stored tick is the same 400" TO WS-CASE
     MOVE 400 TO WS-E
     MOVE WS-TIME TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CAMEL-STAND-INSTANT" USING WS-GAME WS-LAST
     MOVE "standUpInstantly: the last change tick is game time - 52 - 1 = 947" TO WS-CASE
     MOVE 947 TO WS-E
     MOVE WS-LAST TO WS-O
     PERFORM CHECK-N
     MOVE 30 TO WS-GAME
     CALL "Q4-CAMEL-STAND-INSTANT" USING WS-GAME WS-LAST
     MOVE "standUpInstantly early in the world: max(0, 30 - 53) = 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LAST TO WS-O
     PERFORM CHECK-N
     MOVE 400 TO WS-TIME
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "RandomSitting starts at pose time 400 on the ground, unleashed, with no controlling passenger and room to change" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 399 TO WS-TIME
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "RandomSitting does not start at pose time 399" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 400 TO WS-TIME
     CALL "Q4-CAMEL-SIT-OK" USING WS-L1 WS-TIME WS-L0 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "RandomSitting does not start in water" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L1 WS-L1 WS-L0 WS-L1 WS-A
     MOVE "RandomSitting does not start when leashed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L0 WS-L0 WS-L0 WS-L1 WS-A
     MOVE "RandomSitting does not start in the air" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L0 WS-L1 WS-L1 WS-L1 WS-A
     MOVE "RandomSitting does not start with a controlling passenger" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q4-CAMEL-SIT-OK" USING WS-L0 WS-TIME WS-L0 WS-L1 WS-L0 WS-L0 WS-A
     MOVE "RandomSitting does not start when the pose change would suffocate" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "Q4-CAMEL-CONST" USING WS-I WS-A
         EVALUATE WS-I
             WHEN 1
                 MOVE 55 TO WS-E
             WHEN 2
                 MOVE 5 TO WS-E
             WHEN 3
                 MOVE 40 TO WS-E
             WHEN 4
                 MOVE 52 TO WS-E
             WHEN 5
                 MOVE 80 TO WS-E
             WHEN 6
                 MOVE 600 TO WS-E
             WHEN 7
                 MOVE 1430 TO WS-E
             WHEN 8
                 MOVE 100 TO WS-E
             WHEN 9
                 MOVE 14285 TO WS-E
             WHEN OTHER
                 MOVE 222222 TO WS-E
         END-EVALUATE
         MOVE "camel constant (dash cooldown 55, dash minimum 5, sit down 40, stand up 52, idle minimum 80, baby scale 0.6, sitting height difference 1.43, running speed bonus 0.1, dash 1.4285 and 22.2222)" TO WS-CASE
         MOVE WS-A TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     CALL "Q4-CAMEL-TEMPT" USING WS-L1 WS-FA WS-FB
     MOVE "FollowTemptation: the close-enough value for a baby is 2.5 (a squared distance)" TO WS-CASE
     MOVE 25 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FA * 10
     PERFORM CHECK-N
     CALL "Q4-CAMEL-TEMPT" USING WS-L0 WS-FA WS-FB
     MOVE "FollowTemptation: the close-enough value for an adult is 3.5" TO WS-CASE
     MOVE 35 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FA * 10
     PERFORM CHECK-N
     MOVE "FollowTemptation: the speed is 2.5 for everyone" TO WS-CASE
     MOVE 25 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FB * 10
     PERFORM CHECK-N
*>   The camel husk.
     MOVE 1 TO WS-I
     CALL "Q4-HUSK-TRAIT" USING WS-I WS-A
     MOVE "camel husk: removeWhenFarAway is true" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-I
     CALL "Q4-HUSK-TRAIT" USING WS-I WS-A
     MOVE 3 TO WS-I
     CALL "Q4-HUSK-TRAIT" USING WS-I WS-B
     MOVE 4 TO WS-I
     CALL "Q4-HUSK-TRAIT" USING WS-I WS-C
     MOVE "camel husk: canMate, canFallInLove and canBeABaby are all false" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A + WS-B + WS-C
     PERFORM CHECK-N
     MOVE 5 TO WS-I
     CALL "Q4-HUSK-TRAIT" USING WS-I WS-A
     MOVE "camel husk: the charge speed modifier is 4.0" TO WS-CASE
     MOVE 4000 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-4§2 Equines: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-4-2.
