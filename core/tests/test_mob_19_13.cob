*> Implementation test (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 13): the armadillo. A new adult has scuteTime 6000 to 11999; at 0 it drops one armadillo
*> scute (a baby does not) and draws the next time; every 80 ticks it looks for danger within 7 x 2 x 7 blocks (a sprinting player, an undead mob) and a hit by a player is danger too, kept 80
*> ticks (danger_detected_recently); danger rolls it up (state 1 for 10 ticks, then 2 scared) and when the memory is gone it unrolls (3 for 30 ticks, then 0); a rolled armadillo stands still;
*> while scared the damage is (amount - 1) / 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
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
     MOVE "minecraft:armadillo" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:armadillo_scute" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SCUTE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   Scutes.
     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE "acceptance US15 19§13 Armadillo: a new one has scuteTime 6000 to 11999" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SCUTE(WS-A) >= 6000 AND EN-SCUTE(WS-A) <= 11999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-SCUTE(WS-A)
     PERFORM COUNT-SCUTES
     MOVE WS-N TO WS-N0
     PERFORM 4 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     PERFORM COUNT-SCUTES
     MOVE "acceptance US15 19§13 Armadillo: nothing drops before scuteTime ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     PERFORM COUNT-SCUTES
     MOVE "acceptance US15 19§13 Armadillo: at 0 it sheds one scute" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§13 Armadillo: and draws the next time, 6000 to 11999" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SCUTE(WS-A) >= 6000 AND EN-SCUTE(WS-A) <= 11999
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-VARIANT(WS-A)
     MOVE -24000 TO EN-MOBAGE(WS-A)
     MOVE 1 TO EN-SCUTE(WS-A)
     PERFORM COUNT-SCUTES
     MOVE WS-N TO WS-N0
     CALL "MOB-STEP" USING WS-A
     PERFORM COUNT-SCUTES
     MOVE "acceptance US15 19§13 Armadillo: a baby sheds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-N0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-VARIANT(WS-A)
     MOVE 0 TO EN-MOBAGE(WS-A)
     MOVE 9000 TO EN-SCUTE(WS-A)

*>   No danger: a player who walks, a sprinting player outside the box.
     MOVE 79 TO EN-ARMA-SCAN(WS-A)
     MOVE 1 TO PL-SPRINTING(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-PX - 8
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§13 Armadillo: a sprinting player 12 blocks away is no danger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PX TO PL-X(WS-PLAYER)
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)
     MOVE 79 TO EN-ARMA-SCAN(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§13 Armadillo: a player who is not sprinting is no danger" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A sprinting player in the box: roll up, scared, unroll.
     MOVE 1 TO PL-SPRINTING(WS-PLAYER)
     MOVE 79 TO EN-ARMA-SCAN(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§13 Armadillo: a sprinting player near it rolls it up (state 1, 10 ticks, danger 80)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10000 + 10 * 100 + 80
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) * 10000 + EN-ARMA-T(WS-A) * 100 + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)
     PERFORM 10 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§13 Armadillo: after the 10 ticks of rolling it is scared (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-X(WS-A) TO WS-X
     PERFORM 20 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§13 Armadillo: a rolled armadillo stands still" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-A) = WS-X
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§13 Armadillo: a rolled state is entity data to send" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The danger memory (80 ticks) is gone after 50 more ticks: unroll.
     PERFORM 50 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§13 Armadillo: with the memory running out it unrolls (state 3, at most 30 ticks left; 44 part 4 section 12 starts at 30 remaining)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ARMA(WS-A) = 3 AND EN-ARMA-T(WS-A) >= 1 AND EN-ARMA-T(WS-A) <= 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 30 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§13 Armadillo: and is idle again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A

*>   An undead mob near it is danger.
     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-PZ WS-YAW WS-Z
     MOVE 79 TO EN-ARMA-SCAN(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§13 Armadillo: an undead mob within 7 blocks rolls it up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A
     CALL "ENTITY-REMOVE" USING WS-Z

*>   A hit by a player is danger, and a scared armadillo takes (amount - 1) / 2.
     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§13 Armadillo: a hit by a player rolls it up (danger 80)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 80
     COMPUTE TL-OBSERVED-N = EN-ARMA(WS-A) * 100 + EN-DANGER(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§13 Armadillo: an unrolled one takes the whole hit" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO EN-ARMA(WS-A)
     MOVE 0 TO EN-HURT(WS-A)
     MOVE 12 TO EN-HEALTH(WS-A)
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-NO
     MOVE "acceptance US15 19§13 Armadillo: scared, 5 damage become 2" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-HURT(WS-A)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-NO
     MOVE "acceptance US15 19§13 Armadillo: scared, 1 damage becomes 0" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-SCUTES.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-SCUTE AND EN-ITEM-COUNT(WS-J) > 0
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-13.
 COPY CORETEST.
 COPY MOBSPTEST.
