*> Implementation test (002-lane-mobsa4; 29b part 7 sections 3 and 5, 44 part 4 section 11): the turtle egg hatches by random ticks (sand below, the day time's hatch chance, three stages, one baby turtle
*> per egg) and frogspawn hatches by a scheduled tick (3600 + nextInt(8400) ticks after placing, 2 to 5 tadpoles; no water below destroys it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-EGGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY BLOCKTICK.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TURTLE              BINARY-LONG.
 01 WS-TADPOLE             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-EGG                 BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-SPAWN               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-NAME                PIC X(24).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DELTA               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:turtle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TURTLE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:tadpole" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TADPOLE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     CALL "EGG-RULES-OPEN"
     COMPUTE WS-X = WS-X0 + 10
     COMPUTE WS-Z = WS-Z0 + 10
     COMPUTE WS-Y = WS-FLOOR
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SAND WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE WS-Y = WS-FLOOR + 1

*>   A turtle egg of 2 on sand: with the chance 1.0 (day tick 21500) it cracks twice and then hatches into 2 babies.
     MOVE "turtle_egg" TO WS-KEY
     MOVE "eggs=2,hatch=0" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-EGG
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-EGG WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 21500 TO CW-TIME
     MOVE 1 TO WS-I
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     PERFORM READ-HATCH
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: the first random tick on sand cracks it to stage 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     PERFORM READ-HATCH
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: the second random tick cracks it to stage 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     PERFORM COUNT-TURTLES
     MOVE WS-N TO WS-A
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM COUNT-TURTLES
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: the third random tick removes the block and 2 baby turtles appear" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100 + 2
     COMPUTE TL-OBSERVED-N = WS-STATE * 100 + (WS-N - WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TURTLE AND EN-MOBAGE(WS-I) = -24000 AND EN-HOME-SET(WS-I) = 1
                 AND EN-HOME-X(WS-I) = WS-X AND EN-HOME-Y(WS-I) = WS-Y AND EN-HOME-Z(WS-I) = WS-Z
             ADD 1 TO WS-B
         END-IF
     END-PERFORM
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: the babies are age -24000 with the egg block as home" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Not on sand it never changes, however often it is ticked at the hatch time.
     COMPUTE WS-Z = WS-Z0 + 12
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-EGG WS-FLAGS WS-BUDGET WS-RESULT
     PERFORM 5 TIMES
         CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     END-PERFORM
     PERFORM READ-HATCH
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: on stone it does not crack" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   By day the chance is 0.002 only: five ticks leave a fresh egg on sand at stage 0 (the generator is the level's own).
     COMPUTE WS-Z = WS-Z0 + 10
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-EGG WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 6000 TO CW-TIME
     PERFORM 5 TIMES
         CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     END-PERFORM
     PERFORM READ-HATCH
     MOVE "acceptance US15 29b-7§3.2 Turtle egg: by day (chance 0.002) it does not hatch within 5 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT

*>   Frogspawn on a water source: placing it schedules the hatch after 3600 to 11999 ticks.
     COMPUTE WS-X = WS-X0 + 20
     COMPUTE WS-Z = WS-Z0 + 20
     COMPUTE WS-Y = WS-FLOOR
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE "minecraft:frogspawn" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SPAWN
     MOVE BT-COUNT TO WS-A
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SPAWN WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 0 TO WS-DELTA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = WS-DIM AND BT-T-X(WS-I) = WS-X AND BT-T-Y(WS-I) = WS-Y AND BT-T-Z(WS-I) = WS-Z AND BT-T-TYPE(WS-I) = 1
             COMPUTE WS-DELTA = BT-T-TRIG(WS-I) - CW-TICKS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 29b-7§5 Frogspawn: placing it schedules a block tick 3600 to 11999 ticks away" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DELTA >= 3600 AND WS-DELTA <= 11999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The tick with water below hatches 2 to 5 tadpoles and removes the block.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-OUT
     MOVE 0 TO WS-ID
     PERFORM COUNT-TADPOLES
     MOVE WS-N TO WS-A
     CALL "BU-HOOK" USING WS-SEVEN WS-DIM WS-X WS-Y WS-Z WS-STATE WS-ID WS-ID WS-OUT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM COUNT-TADPOLES
     MOVE "acceptance US15 29b-7§5 Frogspawn: the scheduled tick removes it and 2 to 5 tadpoles are born" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE = 0 AND WS-N - WS-A >= 2 AND WS-N - WS-A <= 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TADPOLE
             IF EN-X(WS-I) < WS-X + 0.2 OR EN-X(WS-I) > WS-X + 0.8 OR EN-Z(WS-I) < WS-Z + 0.2 OR EN-Z(WS-I) > WS-Z + 0.8
                 ADD 1 TO WS-BAD
             END-IF
             IF FUNCTION ABS(EN-Y(WS-I) - (WS-Y - 0.5)) > 0.001
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 29b-7§5 Frogspawn: the tadpoles are inside the block's x and z (0.2 to 0.8) and half a block below its floor level" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No water below: the tick destroys it without tadpoles, and the shape update turns it to air at once.
     COMPUTE WS-Z = WS-Z0 + 22
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SPAWN WS-FLAGS WS-BUDGET WS-RESULT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US15 29b-7§5 Frogspawn: on stone (no water below) the placing shape update turns it into air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SPAWN
     PERFORM COUNT-TADPOLES
     MOVE WS-N TO WS-A
     CALL "BU-HOOK" USING WS-SEVEN WS-DIM WS-X WS-Y WS-Z WS-SPAWN WS-ID WS-ID WS-OUT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM COUNT-TADPOLES
     MOVE "acceptance US15 29b-7§5 Frogspawn: a tick without water below destroys it and no tadpole is born" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 10 + 0
     COMPUTE TL-OBSERVED-N = WS-STATE * 10 + (WS-N - WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 READ-HATCH.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "hatch" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE 9 TO WS-N
     IF WS-RESULT = 1
         COMPUTE WS-N = FUNCTION NUMVAL(WS-TEXT)
     END-IF.

 COUNT-TURTLES.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TURTLE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.

 COUNT-TADPOLES.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TADPOLE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-44-EGGS.
 COPY CORETEST.
 COPY MOBSPTEST.
