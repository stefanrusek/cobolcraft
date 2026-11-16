*> Implementation test (002-lane-mobsa4; 44 part 4 section 15, 31 part 4 section 8): the branches of the bee brain and the hive release that the main test does not take: forgotten flower and hive,
*> full hive, fire, travel to the hive and its time-out, the known flower, night entry, the hive tag of the block entity, a blocked or daytime release and the flower of the hive.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-BEE2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY BESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-HIVE                BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HNAME               PIC X(24) VALUE "honey_level".
 01 WS-AT                 BINARY-LONG.
 01 WS-DAY                BINARY-LONG.
 01 WS-HX                 BINARY-LONG.
 01 WS-HY                 BINARY-LONG.
 01 WS-HZ                 BINARY-LONG.
 01 WS-SUN                BINARY-LONG.
 01 WS-TNAME              PIC X(24).
 01 WS-TVAL               PIC X(32).
 01 WS-CHEST              BINARY-LONG.
 01 WS-FIRE               BINARY-LONG.
 01 WS-AIR                BINARY-LONG VALUE 0.
 01 WS-GOT                BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-TWO                BINARY-LONG VALUE 2.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     COMPUTE WS-PX = WS-X0 + 24.5
     COMPUTE WS-PZ = WS-Z0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 2
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "minecraft:beehive" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-HIVE
     MOVE "minecraft:chest" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-CHEST
     MOVE "minecraft:fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FIRE
     MOVE "minecraft:poppy" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-HX = FUNCTION INTEGER(WS-PX) + 4
     COMPUTE WS-HY = WS-FLOOR + 3
     COMPUTE WS-HZ = FUNCTION INTEGER(WS-PZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HIVE
     CALL "BE-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-BE
     MOVE 0 TO BE-XI(WS-BE, 5) BE-XI(WS-BE, 1)
     MOVE WS-FLOOR TO WS-FY
     ADD 1 TO WS-FY

*>   A bee that remembers a flower that is gone and a chest as its hive forgets both at the validation.
     PERFORM SPAWN-BEE
     MOVE 1 TO EN-BEE-FL-ON(WS-A)
     COMPUTE EN-BEE-FL-X(WS-A) = WS-HX + 1
     MOVE WS-FY TO EN-BEE-FL-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-FL-Z(WS-A)
     COMPUTE WS-RX = WS-HX + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-RX WS-HY WS-HZ WS-CHEST
     MOVE 1 TO EN-BEE-HV-ON(WS-A)
     MOVE WS-RX TO EN-BEE-HV-X(WS-A)
     MOVE WS-HY TO EN-BEE-HV-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-HV-Z(WS-A)
     MOVE 0 TO EN-BEE-VAL(WS-A)
     MOVE 5 TO EN-BEE-CD(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: a gone flower and a hive position without a hive are forgotten (the validation timer is 20 to 40)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-BEE-FL-ON(WS-A) = 0 AND EN-BEE-HV-ON(WS-A) = 0 AND EN-BEE-VAL(WS-A) >= 20 AND EN-BEE-VAL(WS-A) <= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hive more than 48 blocks away is forgotten too.
     MOVE 1 TO EN-BEE-HV-ON(WS-A)
     MOVE WS-HX TO EN-BEE-HV-X(WS-A)
     MOVE WS-HY TO EN-BEE-HV-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-HV-Z(WS-A)
     MOVE 0 TO EN-BEE-VAL(WS-A)
     COMPUTE WS-X = WS-HX - 30
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: it is within 48 blocks of the hive, which it keeps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BEE-HV-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-HX - 60
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     MOVE 0 TO EN-BEE-VAL(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: a hive 60 blocks away is forgotten" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BEE-HV-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   Travel: a bee with nectar 10 blocks from its hive flies to it; after 2400 ticks of travel it gives up.
     PERFORM SPAWN-BEE
     COMPUTE WS-X = WS-HX - 10
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     MOVE 1 TO EN-BEE-NECTAR(WS-A) EN-BEE-HV-ON(WS-A)
     MOVE WS-HX TO EN-BEE-HV-X(WS-A)
     MOVE WS-HY TO EN-BEE-HV-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-HV-Z(WS-A)
     MOVE 30 TO EN-BEE-VAL(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: with nectar it flies to its hive (the wanted point is the hive centre)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FLY-ON(WS-A) = 1 AND EN-FLY-X(WS-A) = WS-HX + 0.5 AND EN-FLY-Y(WS-A) = WS-HY + 0.5 AND EN-BEE-TRIP(WS-A) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2400 TO EN-BEE-TRIP(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: after 2400 ticks of travel it gives up the hive" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BEE-HV-ON(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   The known flower: no nectar, more than 600 ticks since pollination, the retry cooldown running.
     PERFORM SPAWN-BEE
     MOVE 1 TO EN-BEE-FL-ON(WS-A)
     MOVE WS-HX TO EN-BEE-FL-X(WS-A)
     MOVE WS-FY TO EN-BEE-FL-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-FL-Z(WS-A)
     CALL "WORLD-SET-BLOCK" USING WS-DIM EN-BEE-FL-X(WS-A) WS-FY WS-HZ WS-STATE
     MOVE 700 TO EN-BEE-NONECT(WS-A)
     MOVE 100 TO EN-BEE-CD(WS-A)
     MOVE 30 TO EN-BEE-VAL(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: after 600 ticks without nectar it goes to the flower it knows (0.6 above its centre)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FLY-ON(WS-A) = 1 AND FUNCTION ABS(EN-FLY-X(WS-A) - WS-HX - 0.5) < 0.001 AND FUNCTION ABS(EN-FLY-Y(WS-A) - WS-FY - 0.6) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   A target or a sting: the brain does nothing but count.
     PERFORM SPAWN-BEE
     MOVE 1 TO EN-TARGET(WS-A)
     MOVE 0 TO EN-BEE-CD(WS-A) EN-BEE-FL-ON(WS-A)
     MOVE 5 TO EN-BEE-STAY(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: with a target it neither pollinates nor looks for flowers (the stay-out countdown still runs)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 10 + 0
     COMPUTE TL-OBSERVED-N = EN-BEE-STAY(WS-A) * 10 + EN-BEE-FL-ON(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   Entering: at night without nectar, with the hive at 1.5 blocks; fire beside it stops it; a full hive is forgotten.
     PERFORM SPAWN-BEE
     COMPUTE WS-X = WS-HX - 1
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     MOVE 1 TO EN-BEE-HV-ON(WS-A)
     MOVE WS-HX TO EN-BEE-HV-X(WS-A)
     MOVE WS-HY TO EN-BEE-HV-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-HV-Z(WS-A)
     MOVE 30 TO EN-BEE-VAL(WS-A)
     MOVE 3 TO BE-XI(WS-BE, 5)
     MOVE 13000 TO CW-TIME
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: a full hive is forgotten and the bee stays" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-BEE-HV-ON(WS-A) * 10 + EN-USED(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BE-XI(WS-BE, 5)
     MOVE 1 TO EN-BEE-HV-ON(WS-A)
     COMPUTE WS-RX = WS-HX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-RX WS-HY WS-HZ WS-FIRE
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: a fire beside the hive keeps the bee out" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-RX WS-HY WS-HZ WS-AIR
     MOVE 1 TO EN-BEE-FL-ON(WS-A)
     MOVE WS-HX TO EN-BEE-FL-X(WS-A)
     MOVE WS-FY TO EN-BEE-FL-Y(WS-A)
     MOVE WS-HZ TO EN-BEE-FL-Z(WS-A)
     PERFORM TICK-BRAIN
     MOVE "acceptance US15 44-4§15 Bee: at night it enters without nectar; the hive adopts its flower and holds one bee of 600 ticks" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100000 + 1 * 10000 + 600 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-USED(WS-A) * 100000 + BE-XI(WS-BE, 5) * 10000 + BE-XI(WS-BE, 7) * 10 + BE-XI(WS-BE, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Release: at night nobody leaves; by day a blocked front keeps it in; then it comes out and the hive's flower is given to it (nine times in ten).
     MOVE 3000 TO BE-XI(WS-BE, 6)
     MOVE 13000 TO CW-TIME
     CALL "BEE-HIVES-TICK"
     MOVE "acceptance US15 44-4§15 Hive: in the stay-in-hive span (tick 12542 to 23460) no bee leaves" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BE-XI(WS-BE, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO CW-TIME
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-STATE
     MOVE "facing" TO WS-TNAME
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-TNAME WS-TVAL WS-AT
     MOVE "north" TO WS-TVAL
     CALL "BLOCK-STATE-PROP" USING WS-TWO WS-STATE WS-TNAME WS-TVAL WS-SUN
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-SUN
     COMPUTE WS-RZ = WS-HZ - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-RZ WS-STONE
     CALL "BEE-HIVES-TICK"
     MOVE "acceptance US15 44-4§15 Hive: a block in front of the hive keeps the bee inside" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BE-XI(WS-BE, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-RZ WS-AIR
     MOVE 0 TO WS-GOT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 8
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
                 CALL "ENTITY-REMOVE" USING WS-I
             END-IF
         END-PERFORM
         MOVE 1 TO BE-XI(WS-BE, 5)
         MOVE 3000 TO BE-XI(WS-BE, 6)
         MOVE 600 TO BE-XI(WS-BE, 7)
         MOVE 0 TO BE-XI(WS-BE, 8)
         MOVE 1 TO BE-XI(WS-BE, 1)
         ADD 1 TO CW-TICKS
         CALL "BEE-HIVES-TICK"
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND EN-BEE-FL-ON(WS-I) = 1
                 ADD 1 TO WS-GOT
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 44-4§15 Hive: the flower of the hive is given to a released bee without one (chance 0.9)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GOT >= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The attraction test reads the state: a sunflower counts by its upper half only, a waterlogged flowering azalea leaf not.
     MOVE "minecraft:sunflower" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SUN
     MOVE "half" TO WS-TNAME
     MOVE "lower" TO WS-TVAL
     CALL "BLOCK-STATE-PROP" USING WS-TWO WS-SUN WS-TNAME WS-TVAL WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-FY WS-HZ WS-STATE
     CALL "M44-BEE-ATTRACTS-AT" USING WS-DIM WS-HX WS-FY WS-HZ WS-AT
     MOVE "acceptance US15 44-4§15 Bee: the lower half of a sunflower is not attractive" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "upper" TO WS-TVAL
     CALL "BLOCK-STATE-PROP" USING WS-TWO WS-SUN WS-TNAME WS-TVAL WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-FY WS-HZ WS-STATE
     CALL "M44-BEE-ATTRACTS-AT" USING WS-DIM WS-HX WS-FY WS-HZ WS-AT
     MOVE "acceptance US15 44-4§15 Bee: the upper half of a sunflower is attractive" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:cherry_leaves" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SUN
     MOVE "waterlogged" TO WS-TNAME
     MOVE "true" TO WS-TVAL
     CALL "BLOCK-STATE-PROP" USING WS-TWO WS-SUN WS-TNAME WS-TVAL WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-FY WS-HZ WS-STATE
     CALL "M44-BEE-ATTRACTS-AT" USING WS-DIM WS-HX WS-FY WS-HZ WS-AT
     MOVE "acceptance US15 44-4§15 Bee: waterlogged cherry leaves are not attractive" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SPAWN-BEE.
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-Y WS-PZ WS-YAW WS-A
     MOVE 0 TO EN-BEE-NECTAR(WS-A) EN-BEE-STUNG(WS-A) EN-BEE-CD(WS-A) EN-BEE-LOC(WS-A) EN-BEE-NONECT(WS-A)
     MOVE 100 TO EN-BEE-LOC(WS-A) EN-BEE-CD(WS-A)
     MOVE 40 TO EN-BEE-VAL(WS-A).

 TICK-BRAIN.
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A.
 END PROGRAM TEST-MOB-44-BEE2.
 COPY CORETEST.
 COPY MOBSPTEST.
