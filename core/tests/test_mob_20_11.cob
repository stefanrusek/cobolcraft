*> Implementation test (002-lane-mobsfull-h11; docs/protocol/20 section 11 Witch, 25 section 9.3, 17 section 4.9): the witch (row 35) drinks one of four potions chosen by four
*> tests in order (water breathing in water 0.15, fire resistance on fire 0.15, healing when hurt 0.05, swiftness 0.5 with a target farther than 11 blocks), each
*> test with its own random float; the drink lasts 32 ticks (the default drink of 17), the witch stands still meanwhile (the drinking modifier -0.25 takes its
*> speed 0.25 to 0), then the effect applies (water breathing, fire resistance, speed 3600 ticks; healing 4 points) and the hand is empty. The ranged goal keeps the
*> witch walking toward its target until it is within 10 blocks (radius 10.0). Thrown potions need splash potion entities, which the core does not have (open).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-R4                  BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-SPEED-N             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 20
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 26 TO EN-HEALTH(WS-MOB)
     MOVE 0 TO WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4

*>   The four tests in order (11, Drinking). Rolls are 0 to 999: a float below 0.15 is a roll below 150.
     MOVE 100 TO WS-R1
     MOVE 1 TO WS-WATER
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: eyes in water and a roll below 0.15 give Water Breathing" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 150 TO WS-R1
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: a roll of 0.15 or more drinks nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-R1
     MOVE 3600 TO EN-FX-WATER(WS-MOB)
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: with Water Breathing active it does not drink it again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FX-WATER(WS-MOB) WS-WATER
     MOVE 1 TO WS-FIRE
     MOVE 100 TO WS-R2
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: on fire and a roll below 0.15 give Fire Resistance" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3600 TO EN-FX-FIRE(WS-MOB)
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: with Fire Resistance active it does not drink it again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FX-FIRE(WS-MOB) WS-FIRE
     MOVE 100 TO WS-R3
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: at full health a roll never gives Healing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO EN-HEALTH(WS-MOB)
     MOVE 49 TO WS-R3
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: hurt and a roll below 0.05 give Healing" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-R3
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: a roll of 0.05 drinks no Healing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Swiftness: a target, no Speed, the target farther than 11 blocks, roll below 0.5.
     MOVE 26 TO EN-HEALTH(WS-MOB)
     MOVE 1 TO WS-FAR
     MOVE 499 TO WS-R4
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: without a target no Swiftness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: a far target and a roll below 0.5 give Swiftness" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO WS-R4
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: a roll of 0.5 gives no Swiftness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 499 TO WS-R4
     MOVE 0 TO WS-FAR
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: a target within 11 blocks gives no Swiftness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FAR
     MOVE 3600 TO EN-FX-SPEED(WS-MOB)
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: with Speed active no Swiftness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FX-SPEED(WS-MOB)
     MOVE 1 TO WS-WATER
     MOVE 1 TO WS-FIRE
     MOVE 100 TO WS-R1 WS-R2
     CALL "STDMOB-WITCH-PICK" USING WS-MOB WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     MOVE "acceptance US15 20§11 Witch: the first test that succeeds decides (Water Breathing before Fire Resistance)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-POTION TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drinking: 32 ticks standing still, then the effect. Healing from 10 to 14.
     MOVE 0 TO EN-TARGET(WS-MOB) EN-TARGET-ID(WS-MOB)
     MOVE 10 TO EN-HEALTH(WS-MOB)
     MOVE 7 TO EN-HAND(WS-MOB)
     MOVE 32 TO EN-DRAW(WS-MOB)
     CALL "STDMOB-SPEED" USING WS-MOB WS-M WS-SPEED
     MOVE "acceptance US15 20§11 Witch: while drinking the speed is 0.25 - 0.25 = 0" TO TL-CASE
     COMPUTE WS-SPEED-N = WS-SPEED * 1000
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SPEED-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch: after 31 ticks of drinking it is still drinking and standing" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 7 * 100 + 1
     COMPUTE TL-OBSERVED-N = EN-HAND(WS-MOB) * 100 + WS-STOP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     MOVE "acceptance US15 20§11 Witch: Healing heals 4 points, the hand is emptied" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 14 * 100 + 0
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-MOB) * 100 + EN-HAND(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 25 TO EN-HEALTH(WS-MOB)
     MOVE 7 TO EN-HAND(WS-MOB)
     MOVE 1 TO EN-DRAW(WS-MOB)
     CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     MOVE "acceptance US15 20§11 Witch: Healing does not pass the maximum health 26" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 5 BY 1 UNTIL WS-I > 8
         MOVE WS-I TO EN-HAND(WS-MOB)
         MOVE 1 TO EN-DRAW(WS-MOB)
         CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch: Water Breathing, Fire Resistance and Speed last 3600 ticks (25 section 9.3)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3600 * 1000000 + 3600 * 1000 + 3600
     COMPUTE TL-OBSERVED-N = EN-FX-WATER(WS-MOB) * 1000000 + EN-FX-FIRE(WS-MOB) * 1000 + EN-FX-SPEED(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-SPEED" USING WS-MOB WS-M WS-SPEED
     MOVE "acceptance US15 20§11 Witch: Speed raises the walk speed by 20 percent (0.138 x 1.2 blocks a tick)" TO TL-CASE
     COMPUTE WS-SPEED-N ROUNDED = WS-SPEED * 1000000
     MOVE 165600 TO TL-EXPECTED-N
     MOVE WS-SPEED-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Starting to drink: a hurt witch eventually rolls Healing (0.05 a tick) and takes the potion in hand for 32 ticks.
     MOVE 0 TO EN-FX-WATER(WS-MOB) EN-FX-FIRE(WS-MOB) EN-FX-SPEED(WS-MOB) EN-DRAW(WS-MOB) EN-HAND(WS-MOB)
     MOVE 5 TO EN-HEALTH(WS-MOB)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2000 OR EN-DRAW(WS-MOB) > 0
         CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch: a hurt witch starts drinking Healing (32 ticks)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 7 * 100 + 32
     COMPUTE TL-OBSERVED-N = EN-HAND(WS-MOB) * 100 + EN-DRAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Ranged goal: with a target the witch walks until it is within 10 blocks and then stands.
     MOVE 0 TO EN-DRAW(WS-MOB) EN-HAND(WS-MOB)
     MOVE 26 TO EN-HEALTH(WS-MOB)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE -1 TO EN-FX-SPEED(WS-MOB)
     CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     MOVE "acceptance US15 20§11 Witch: a target 20 blocks away: the witch keeps walking" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-MOB) = WS-X + 9
     CALL "STDMOB-WITCH-TICK" USING WS-MOB WS-M WS-STOP
     MOVE "acceptance US15 20§11 Witch: a target 9 blocks away (radius 10): the witch stands" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STOP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.
 END PROGRAM TEST-MOB-20-11.
 COPY CORETEST.
 COPY MOBSPTEST.
