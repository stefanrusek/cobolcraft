*> Implementation test (002-lane-mobsa3; 19 section 5.1): a tame cat relaxes on its sleeping owner and gives a morning gift (19 section 5.1): the chance track, the gift table and the goal.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-CATGIFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY WSIM2.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SCUTE               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-GKEY                PIC X(24).
 01 WS-STATE               BINARY-LONG.
 01 WS-BKEY                PIC X(112).
 01 WS-WALK2               BINARY-LONG.
 01 WS-GIFTS               BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-BRUSH-ROW           PIC X(270).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:cat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:armadillo_scute" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SCUTE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   The chance track.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1 MOVE 0 TO WS-N
             WHEN 2 MOVE 361 TO WS-N
             WHEN 3 MOVE 362 TO WS-N
             WHEN 4 MOVE 12000 TO WS-N
             WHEN 5 MOVE 23666 TO WS-N
             WHEN OTHER MOVE 23667 TO WS-N
         END-EVALUATE
         CALL "M44-CAT-GIFT-CHANCE" USING WS-N WS-A
         IF WS-I = 1 OR WS-I = 2 OR WS-I = 6
             MOVE 700 TO TL-EXPECTED-N
         ELSE
             MOVE 0 TO TL-EXPECTED-N
         END-IF
         MOVE "acceptance US15 19§5.1 Morning gift: the chance is 0.7 from tick 23667 to 361 of the next day and 0.0 from 362 to 23666" TO TL-CASE
         MOVE WS-A TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The table: weights 10 x 6 and 2.
     MOVE 0 TO WS-N
     MOVE 0 TO WS-GIFTS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 61
         CALL "M44-CAT-GIFT-PICK" USING WS-I WS-GKEY
         IF WS-GKEY = "phantom_membrane"
             ADD 1 TO WS-N
         END-IF
         IF WS-GKEY = "rabbit_hide"
             ADD 1 TO WS-GIFTS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§5.1 Morning gift: phantom membrane has weight 2 of 62, rabbit hide 10" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 100 + 10
     COMPUTE TL-OBSERVED-N = WS-N * 100 + WS-GIFTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The goal: a bed at the owner's feet, the owner asleep with the counter at 100, the cat tame beside it.
     MOVE "minecraft:white_bed" TO WS-BKEY
     CALL "MS-TEST-STATE" USING WS-BKEY WS-STATE
     COMPUTE WS-A = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-N = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-A WS-N WS-Z WS-STATE
     CALL "WORLDSIM-ENSURE2"
     COMPUTE WS-X = WS-PX + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-ROW
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW)
     MOVE 0 TO EN-SIT(WS-ROW)
     MOVE 1 TO W2-SLEEPING(WS-PLAYER)
     MOVE 50 TO W2-SLEEP-COUNTER(WS-PLAYER)
     CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 19§5.1 Cat relax: a cat beside its sleeping owner stays still (walk 2) and relaxes (1)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 2 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-WALK2 * 10 + EN-CAT-RELAX(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO W2-SLEEP-COUNTER(WS-PLAYER)
     CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 19§5.1 Cat relax: the owner's counter at 100 is remembered (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-CAT-RELAX(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The owner wakes in the morning (day tick 23700): some tries give a gift, each a single item; by day (6000) none.
     MOVE 0 TO W2-SLEEPING(WS-PLAYER)
     MOVE 0 TO W2-SLEEP-COUNTER(WS-PLAYER)
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-N0
     MOVE 0 TO WS-GIFTS
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 40
         COMPUTE CW-TIME = 24000 * 5 + 23700 + WS-TRY * 7
         MOVE 2 TO EN-CAT-RELAX(WS-ROW)
         CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
         IF EN-CAT-RELAX(WS-ROW) NOT = 0
             ADD 1000 TO WS-GIFTS
         END-IF
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 19§5.1 Morning gift: on waking in the morning some of 40 tries give a gift, not all (0.7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GIFTS = 0 AND WS-N - WS-N0 >= 10 AND WS-N - WS-N0 < 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-N TO WS-N0
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 40
         COMPUTE CW-TIME = 24000 * 5 + 6000 + WS-TRY * 7
         MOVE 2 TO EN-CAT-RELAX(WS-ROW)
         CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 19§5.1 Morning gift: at day tick 6000 the chance is 0 and nothing is given" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A relax that never saw 100 ticks (counter below 100) gives nothing.
     MOVE 1 TO W2-SLEEPING(WS-PLAYER)
     MOVE 10 TO W2-SLEEP-COUNTER(WS-PLAYER)
     MOVE 0 TO EN-CAT-RELAX(WS-ROW)
     COMPUTE CW-TIME = 24000 * 5 + 23700
     CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE WS-N TO WS-N0
     MOVE 0 TO W2-SLEEPING(WS-PLAYER)
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 40
         COMPUTE CW-TIME = 24000 * 5 + 23700 + WS-TRY * 7
         MOVE 1 TO EN-CAT-RELAX(WS-ROW)
         CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     END-PERFORM
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 19§5.1 Morning gift: an owner who did not sleep 100 ticks gives no gift" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not usable when the cat is too far (squared distance above 100).
     MOVE 1 TO W2-SLEEPING(WS-PLAYER)
     MOVE 0 TO EN-CAT-RELAX(WS-ROW)
     COMPUTE EN-X(WS-ROW) = WS-PX + 12
     CALL "CAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 19§5.1 Cat relax: a cat 12 blocks away does not relax" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-CAT-RELAX(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM-COUNT(WS-J) > 0
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-44-CATGIFT.
 COPY CORETEST.
 COPY MOBSPTEST.
