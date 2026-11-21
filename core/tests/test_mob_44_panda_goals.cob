*> Implementation test (lane 002-lane-p49s, T38620 to T38635; docs/protocol/44-residual-mob-questions-4-land-animals.md sections 7.1 to 7.3): PandaRollGoal and handleRoll (the start rules, the 32 tick
*> roll with the hop at 1 and at 7, 15 and 23), PandaLieOnBackGoal (lazy, cooldown, ends in water or by the 1 in 1000 roll with the 200 tick cooldown) and PandaSitGoal (a held item or food near,
*> walk to the food at 1.2, the drop and the cooldown at the end, pick-up of bamboo).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-PANDA-GOALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 20.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-BAMBOO              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DROP                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-D0                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STEP-ROW            BINARY-LONG.
 01 WS-SPEED-X             FLOAT-LONG.
 01 WS-SPEED-Y             FLOAT-LONG VALUE 0.
 01 WS-GAY                 FLOAT-LONG VALUE 0.5.
 01 WS-SPEED-Z             FLOAT-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
*>   An elevated floor so that the cells around it are air: 20 x 20, the panda's row of cells at its south edge.
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + 40
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X0) + 30
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z0) + 30
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "bamboo" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BAMBOO
     MOVE "minecraft:panda" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
     MOVE 1000 TO CW-TICKS CW-TIME

*>   Roll (7.1). A baby at the south edge facing +Z (yaw 0): the cell ahead and below is air, so it rolls at once.
     COMPUTE WS-GX = WS-FX + 10.5
     COMPUTE WS-GZ = WS-FZ + 19.5
     PERFORM SPAWN-PANDA
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 a baby with air ahead and below starts rolling (flag 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 counter 1: the velocity is the push 0.1 (baby) and a hop of 0.27" TO TL-CASE
     MOVE 127 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000 + EN-VY(WS-ROW) * 100 - 0.0
     COMPUTE TL-EXPECTED-N ROUNDED = 0.1 * 1000 + 0.27 * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 5 TIMES
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44-4§7.1 counter 6: the stored push goes on" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 counter 7: the horizontal velocity is zero and it hops again on the ground" TO TL-CASE
     MOVE 27 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-ROW) * 100 + EN-VZ(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.1 the roll holds the body still (walk 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 25 TIMES
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44-4§7.1 counter 32: still rolling" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 counter 33: the roll is over (flag cleared)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   An adult with normal genes does not roll; a playful adult does (air ahead); a baby in the air does not.
     PERFORM SPAWN-PANDA
     PERFORM 3 TIMES
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44-4§7.1 a normal adult does not roll at the edge" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO EN-GENE-MAIN(WS-ROW) EN-GENE-HIDDEN(WS-ROW)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 a playful adult rolls at the edge" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM SPAWN-PANDA
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.1 a baby that is not on the ground does not roll" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   In the middle of the floor (ground ahead) a baby rolls only by the 1 in 250 draw: it does within 3000 ticks.
     COMPUTE WS-GZ = WS-FZ + 10.5
     PERFORM SPAWN-PANDA
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR WS-N = 1
         ADD 1 TO CW-TIME CW-TICKS
         MOVE 1 TO EN-ON-GROUND(WS-ROW)
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF EN-PANDA-FLAGS(WS-ROW) = 4
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.1 a baby over solid ground rolls by the 1 in 250 draw" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Lie on back (7.2): a lazy adult starts by the 1 in 200 draw; it ends in water at once; a cooldown blocks it.
     PERFORM SPAWN-PANDA
     MOVE 1 TO EN-GENE-MAIN(WS-ROW) EN-GENE-HIDDEN(WS-ROW)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000 OR WS-N = 1
         ADD 1 TO CW-TIME CW-TICKS
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF FUNCTION MOD(EN-PANDA-FLAGS(WS-ROW) / 16, 2) = 1
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.2 a lazy panda lies on its back by the 1 in 200 draw" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.2 lying holds the body still (walk 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40000 OR WS-N = 1
         ADD 1 TO CW-TIME CW-TICKS
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF FUNCTION MOD(EN-PANDA-FLAGS(WS-ROW) / 16, 2) = 0
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.2 it gets up by the 1 in 1000 draw" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.2 and the next lie-down waits 200 ticks (the cooldown stamp)" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-PANDA-LIE-CD(WS-ROW) - CW-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 190
         ADD 1 TO CW-TIME CW-TICKS
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF EN-PANDA-FLAGS(WS-ROW) > 0
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.2 within the 200 ticks it does not lie down again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Lying in water ends at once; a non-lazy panda also ends by the 1 in 300 draw (forced to lie here).
     MOVE 16 TO EN-PANDA-FLAGS(WS-ROW)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.2 a panda on its back in water gets up at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM SPAWN-PANDA
     MOVE 16 TO EN-PANDA-FLAGS(WS-ROW)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4000 OR WS-N = 1
         ADD 1 TO CW-TIME CW-TICKS
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF FUNCTION MOD(EN-PANDA-FLAGS(WS-ROW) / 16, 2) = 0
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.2 a non-lazy panda on its back also gets up by the 1 in 300 draw (sooner than 4000 ticks)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Sit (7.3). A panda with an item in the mouth sits at once; the goal ends by the draws, dropping the item and setting the cooldown (200 to 1180 ticks for a lazy one).
     PERFORM SPAWN-PANDA
     MOVE 1 TO EN-GENE-MAIN(WS-ROW) EN-GENE-HIDDEN(WS-ROW)
     COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 with an item in the mouth the panda sits (flag 8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-PANDA-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 and the goal runs" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-PANDA-SIT-GOAL(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 sitting holds the body still (walk 2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40000 OR WS-N = 1
         ADD 1 TO CW-TIME CW-TICKS
         MOVE 0 TO EN-PANDA-EAT(WS-ROW)
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
         IF EN-PANDA-SIT-GOAL(WS-ROW) = 0
             MOVE 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.3 the goal ends by the draws" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 the mouth is empty and the panda no longer sits" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-PANDA-HAND(WS-ROW) + EN-PANDA-FLAGS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 the cooldown of a lazy panda is 20 x (10 to 59) ticks (200 to 1180)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-N = EN-PANDA-SIT-CD(WS-ROW) - CW-TICKS
     IF WS-N >= 200 AND WS-N <= 1180 AND FUNCTION MOD(WS-N, 20) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-BAMBOO
             ADD EN-ITEM-COUNT(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§7.3 the item was dropped as an item entity" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   During the cooldown it does not sit again (with an item in the mouth).
     COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 during the cooldown the sit goal does not start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-SIT-GOAL(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Food near and an empty mouth: the goal starts and walks to the first food at 1.2 times the speed; a baby does not sit.
     PERFORM CLEAR-ITEMS
     PERFORM SPAWN-PANDA
     COMPUTE WS-SPEED-X = WS-GX + 5
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-SPEED-X EN-Y(WS-ROW) WS-GZ WS-BAMBOO WS-ONE WS-ZERO WS-D0 WS-DROP
     MOVE 0 TO EN-DELAY(WS-DROP)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 bamboo 5 blocks away starts the sit goal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-PANDA-SIT-GOAL(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 the panda walks toward it at 1.2 times its speed" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-SPEED * 1.2 * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-HX * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 and the walk is reported (walk 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM SPAWN-PANDA
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 a baby does not sit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-SIT-GOAL(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Pick-up: bamboo within a block goes into the mouth; food 5 blocks away does not.
     PERFORM CLEAR-ITEMS
     PERFORM SPAWN-PANDA
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-GX EN-Y(WS-ROW) WS-GZ WS-BAMBOO WS-ONE WS-ZERO WS-D0 WS-DROP
     MOVE 0 TO EN-DELAY(WS-DROP)
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 bamboo at the panda's feet goes into its mouth" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-BAMBOO + 1
     MOVE EN-PANDA-HAND(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§7.3 and the item entity is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   An entity that is no table mob is left alone.
     MOVE 0 TO WS-SPEED-X
     CALL "ARROW-SPAWN" USING WS-DIM WS-GX WS-GAY WS-GZ WS-SPEED-X WS-SPEED-Y WS-SPEED-Z WS-BASE WS-ZERO WS-STEP-ROW
     MOVE 5 TO WS-WALK
     CALL "PANDA-GOALS" USING WS-STEP-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7 an arrow is no table mob: the goals do nothing (walk 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-STEP-ROW
*>   The facing decides which cell the roll test looks at: a baby and a playful adult in the middle of the floor facing every way (no assertion on the draws).
     PERFORM SPAWN-PANDA
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         EVALUATE FUNCTION MOD(WS-I, 3)
             WHEN 0 MOVE 90 TO EN-YAW(WS-ROW)
             WHEN 1 MOVE 180 TO EN-YAW(WS-ROW)
             WHEN 2 MOVE 270 TO EN-YAW(WS-ROW)
         END-EVALUATE
         ADD 1 TO CW-TIME CW-TICKS
         MOVE 0 TO EN-PANDA-FLAGS(WS-ROW)
         MOVE 1 TO EN-ON-GROUND(WS-ROW)
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE 0 TO EN-MOBAGE(WS-ROW)
     MOVE 3 TO EN-GENE-MAIN(WS-ROW) EN-GENE-HIDDEN(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD 1 TO CW-TIME CW-TICKS
         MOVE 0 TO EN-PANDA-FLAGS(WS-ROW)
         MOVE 1 TO EN-ON-GROUND(WS-ROW)
         CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A running sit goal with an item in the mouth and the panda not yet sitting sits down.
     PERFORM SPAWN-PANDA
     MOVE 1 TO EN-PANDA-SIT-GOAL(WS-ROW)
     COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 a running goal with an item in the mouth sits the panda down" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION MOD(EN-PANDA-FLAGS(WS-ROW), 16)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   In water the goal ends at once.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER
     CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44-4§7.3 in water the sit goal ends at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PANDA-SIT-GOAL(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Non-lazy pandas end the goal by the 1 in 300 or the 1 in 1000 draw and wait 20 x (10 to 159) ticks (200 to 3180) afterwards.
     MOVE 0 TO WS-K
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         PERFORM SPAWN-PANDA
         MOVE 1 TO EN-PANDA-SIT-GOAL(WS-ROW)
         COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20000 OR WS-N = 1
             ADD 1 TO CW-TIME CW-TICKS
             MOVE 0 TO EN-PANDA-EAT(WS-ROW)
             CALL "PANDA-GOALS" USING WS-ROW WS-HX WS-HZ WS-WALK
             IF EN-PANDA-SIT-GOAL(WS-ROW) = 0
                 MOVE 1 TO WS-N
             END-IF
         END-PERFORM
         ADD WS-N TO WS-K
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-4§7.3 six non-lazy pandas all end the sit goal by the draws" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Through MOB-STEP the panda with an item in the mouth sits.
     PERFORM SPAWN-PANDA
     COMPUTE EN-PANDA-HAND(WS-ROW) = WS-BAMBOO + 1
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-4§7.3 MOB-STEP lets the panda with an item in the mouth sit" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION MOD(EN-PANDA-FLAGS(WS-ROW), 16)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SPAWN-PANDA.
     MOVE WS-Y TO WS-N
     COMPUTE WS-HX = WS-FY + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-HX WS-GZ WS-YAW WS-ROW
     MOVE 0 TO EN-GENE-MAIN(WS-ROW) EN-GENE-HIDDEN(WS-ROW) EN-PANDA-FLAGS(WS-ROW) EN-PANDA-HAND(WS-ROW) EN-PANDA-EAT(WS-ROW)
     MOVE 0 TO EN-PANDA-LIE-CD(WS-ROW) EN-PANDA-SIT-CD(WS-ROW) EN-PANDA-SIT-GOAL(WS-ROW) EN-PANDA-T(WS-ROW) EN-MOBAGE(WS-ROW)
     MOVE 1 TO EN-ON-GROUND(WS-ROW).
 CLEAR-ITEMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-44-PANDA-GOALS.

 COPY CORETEST.
 COPY MOBSPTEST.
 COPY BETEST.
