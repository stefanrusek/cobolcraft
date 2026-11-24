*> Implementation test (002-lane-mobsa4; 44 part 4 section 15, 19 section 16, 31 part 4 section 8): bees find flowers (radius 5, tag bee_attractive), pollinate (nectar after more than 400 good ticks),
*> look for a hive within 20 blocks, fly to it, enter it with nectar (not before), and the hive releases them again (honey level up for a bee that brought nectar).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-BEE.
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
     COMPUTE WS-FX = FUNCTION INTEGER(WS-PX) + 3
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-PZ)
     MOVE "minecraft:poppy" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-Y WS-PZ WS-YAW WS-A

*>   Flower finding: a poppy 3 blocks away is found; stone is not a flower; radius 5 is the limit.
     CALL "M44-BEE-FLOWER-FIND" USING WS-A WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-4§15 Bee: a poppy within 5 blocks is found at its position" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + (WS-FX - WS-X0) * 10000 + (WS-FY - WS-FLOOR) * 100 + (WS-FZ - WS-Z0)
     COMPUTE TL-OBSERVED-N = WS-FOUND * 1000000 + (WS-RX - WS-X0) * 10000 + (WS-RY - WS-FLOOR) * 100 + (WS-RZ - WS-Z0)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     CALL "M44-BEE-FLOWER-FIND" USING WS-A WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-4§15 Bee: stone is not a flower, nothing is found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:poppy" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-FX = FUNCTION INTEGER(WS-PX) + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     CALL "M44-BEE-FLOWER-FIND" USING WS-A WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-4§15 Bee: a flower 6 blocks away is out of the search radius" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without a flower the retry cooldown is set (20 to 60) and no pollination starts.
     MOVE 0 TO EN-BEE-CD(WS-A) EN-BEE-POLL(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: no flower in reach, a retry cooldown of 20 to 60 and no pollination" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-BEE-CD(WS-A) >= 19 AND EN-BEE-CD(WS-A) <= 60 AND EN-BEE-POLL(WS-A) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A flower 3 blocks away: pollination starts, 601 ticks later the bee carries nectar and the cooldown is 200.
     COMPUTE WS-FX = FUNCTION INTEGER(WS-PX) + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE 0 TO EN-BEE-CD(WS-A) EN-BEE-NECTAR(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: with a flower in reach pollination starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-BEE-POLL(WS-A) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM UNTIL EN-BEE-POLL(WS-A) = 0 OR WS-N > 700
         ADD 1 TO WS-N
         ADD 1 TO CW-TIME
         CALL "M44-BEE-BRAIN" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§15 Bee: after the pollination it carries nectar, cooldown 200, counters cleared" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10000 + 200 * 10
     COMPUTE TL-OBSERVED-N = EN-BEE-NECTAR(WS-A) * 10000 + EN-BEE-CD(WS-A) * 10 + EN-BEE-POLL(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§15 Bee: the flower is remembered (flower position stored)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + (WS-FX - WS-X0) * 10000 + (WS-FY - WS-FLOOR) * 100 + (WS-FZ - WS-Z0)
     COMPUTE TL-OBSERVED-N = EN-BEE-FL-ON(WS-A) * 1000000 + (EN-BEE-FL-X(WS-A) - WS-X0) * 10000 + (EN-BEE-FL-Y(WS-A) - WS-FLOOR) * 100
         + (EN-BEE-FL-Z(WS-A) - WS-Z0)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A flower that goes ends the pollination early without nectar.
     MOVE 0 TO EN-BEE-CD(WS-A) EN-BEE-NECTAR(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: the flower broken, the pollination ends without nectar" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 1000 + 0 * 100 + 1
     COMPUTE TL-OBSERVED-N = EN-BEE-NECTAR(WS-A) * 1000 + EN-BEE-POLL(WS-A) * 100 + 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The hive: a beehive 8 blocks away.
     CALL "ENTITY-REMOVE" USING WS-A
     MOVE "minecraft:beehive" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-HIVE
     COMPUTE WS-RX = FUNCTION INTEGER(WS-PX) + 8
     COMPUTE WS-RY = WS-FLOOR + 3
     COMPUTE WS-RZ = FUNCTION INTEGER(WS-PZ)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-RX WS-RY WS-RZ WS-HIVE
     CALL "BE-FIND" USING WS-DIM WS-RX WS-RY WS-RZ WS-BE
     MOVE "acceptance US15 44-4§15 Bee: the placed hive has a block entity (test setup)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BE-XI(WS-BE, 5)
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-Y WS-PZ WS-YAW WS-A
     MOVE 0 TO EN-BEE-NECTAR(WS-A) EN-BEE-STUNG(WS-A) EN-BEE-CD(WS-A) EN-BEE-LOC(WS-A) EN-BEE-NONECT(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: a hive within 20 blocks is located and remembered" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 1000 + (WS-RX - WS-X0)
     COMPUTE TL-OBSERVED-N = EN-BEE-HV-ON(WS-A) * 1000 + (EN-BEE-HV-X(WS-A) - WS-X0)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without nectar, by day, it does not enter even beside the hive.
     COMPUTE WS-X = WS-RX - 1
     CALL "ENTITY-MOVE" USING WS-A WS-X WS-Y WS-PZ WS-YAW WS-PITCH WS-GROUND
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: no nectar and daytime, it stays out of the hive" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With nectar it enters: the hive stores it with minimum 2400 ticks.
     MOVE 1 TO EN-BEE-NECTAR(WS-A)
     ADD 1 TO CW-TIME
     CALL "M44-BEE-BRAIN" USING WS-A
     MOVE "acceptance US15 44-4§15 Bee: with nectar beside the hive it enters (the mob is gone, one bee stored with 2400)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100000 + 1 * 10000 + 2400
     COMPUTE TL-OBSERVED-N = EN-USED(WS-A) * 100000 + BE-XI(WS-BE, 5) * 10000 + BE-XI(WS-BE, 7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Release: after 2400 ticks the bee leaves (daytime), the honey level rises and the nectar is dropped.
     MOVE 6000 TO CW-TIME
     MOVE 2399 TO BE-XI(WS-BE, 6)
     CALL "BEE-HIVES-TICK"
     MOVE "acceptance US15 44-4§15 Hive: the bee is still inside while the counter does not exceed the minimum" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BE-XI(WS-BE, 5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BEE-HIVES-TICK"
     MOVE 0 TO WS-N
     MOVE 0 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             ADD 1 TO WS-N
             MOVE WS-I TO WS-B
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-4§15 Hive: a bee that has spent its minimum time comes out, no bee is left inside" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = WS-N * 10 + BE-XI(WS-BE, 5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-RX WS-RY WS-RZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-HNAME WS-TEXT WS-RESULT
     COMPUTE WS-LEVEL = FUNCTION NUMVAL(WS-TEXT)
     MOVE "acceptance US15 44-4§15 Hive: the honey level rose by 1 or 2 (nectar delivered)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEVEL >= 1 AND WS-LEVEL <= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§15 Hive: the released bee has dropped its nectar and knows the hive" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B > 0
         IF EN-BEE-NECTAR(WS-B) = 0 AND EN-BEE-HV-ON(WS-B) = 1
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-BEE.
 COPY CORETEST.
 COPY MOBSPTEST.
