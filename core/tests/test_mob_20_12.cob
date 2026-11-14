*> Implementation test (002-lane-mobsfull-h11; docs/protocol/20 section 12 Phantom, 20.5, 44-5 section 10C item 2): insomnia (the effective difficulty must exceed
*> nextFloat x 3, then nextInt(rest) >= 72000, rest at least 1); the spawner countdown ((60 + nextInt(60)) x 20 ticks); the time_since_rest statistic (+1 a tick
*> unless sleeping); a round at night under open sky above sea level puts 1 + nextInt(difficulty + 1) phantoms 20 to 34 blocks up and within 10 blocks on each
*> horizontal axis; finalizeSpawn sets the anchor 5 blocks up; the next circle point; the anchor above a target (20 + nextInt(20) up, at least sea level + 1);
*> the move control (approach the heading by 4 degrees, speed approach 0.005 x (1.8 / speed) or 0.025, velocity blend 0.2); the target scan (counter 20, then every 60
*> ticks the highest player within 16, 64, 16); the CIRCLE to SWOOP timer; the swoop hit (6 + size damage, back to CIRCLE). Open: the cats of the sweep, size scaling
*> of the box, the horizontal-collision turn, the flying friction (taken as none: the move control blends the velocity), the size metadata.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 COPY WSIM2.
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
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-FY                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EFF                 BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COUNTER             BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 3.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-A3                  BINARY-LONG.
 01 WS-A4                  BINARY-LONG.
 01 WS-A5                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE

*>   Insomnia (20.5).
     MOVE 3000 TO WS-EFF
     MOVE 2999 TO WS-D3
     MOVE 144000 TO WS-REST
     MOVE 72000 TO WS-DRAW
     CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
     MOVE "acceptance US15 20§12 Phantom: rest 144000, draw 72000 and a low float pass" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 71999 TO WS-DRAW
     CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
     MOVE "acceptance US15 20§12 Phantom: a rest draw below 72000 fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 72000 TO WS-DRAW
     MOVE 3000 TO WS-D3
     CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
     MOVE "acceptance US15 20§12 Phantom: the effective difficulty must exceed nextFloat x 3 (3.000 is not above 3.000)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1500 TO WS-D3
     MOVE 2000 TO WS-EFF
     CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
     MOVE "acceptance US15 20§12 Phantom: difficulty 2.0 beats a float of 1.5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Spawner countdown.
     MOVE 2 TO WS-COUNTER
     MOVE 0 TO WS-ROLL
     CALL "STDMOB-PHANTOM-COUNTDOWN" USING WS-COUNTER WS-ROLL WS-DUE
     MOVE "acceptance US15 20§12 Phantom: the countdown 2 becomes 1, not due" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = WS-COUNTER * 10 + WS-DUE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-PHANTOM-COUNTDOWN" USING WS-COUNTER WS-ROLL WS-DUE
     MOVE "acceptance US15 20§12 Phantom: at 0 it is due and takes (60 + 0) x 20 = 1200" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1200 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-COUNTER * 10 + WS-DUE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-COUNTER
     MOVE 59 TO WS-ROLL
     CALL "STDMOB-PHANTOM-COUNTDOWN" USING WS-COUNTER WS-ROLL WS-DUE
     MOVE "acceptance US15 20§12 Phantom: roll 59 gives (60 + 59) x 20 = 2380" TO TL-CASE
     MOVE 2380 TO TL-EXPECTED-N
     MOVE WS-COUNTER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   time_since_rest: +1 a tick unless the player sleeps.
     MOVE 100 TO PL-REST(WS-PLAYER)
     MOVE 0 TO W2-SLEEPING(WS-PLAYER)
     CALL "STDMOB-REST-TICK"
     MOVE "acceptance US15 44-5§10C time_since_rest grows by 1 a tick" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     MOVE PL-REST(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO W2-SLEEPING(WS-PLAYER)
     CALL "STDMOB-REST-TICK"
     MOVE "acceptance US15 44-5§10C time_since_rest stands still while sleeping" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     MOVE PL-REST(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO W2-SLEEPING(WS-PLAYER)

*>   A spawner round: the player stands on a floor high up, under open sky.
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X0 = WS-PX - 4
     COMPUTE WS-Z0 = WS-PZ - 4
     COMPUTE WS-FY = WS-PY + 60
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FY + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-PZ + 0.5
     MOVE 10000000 TO PL-REST(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "STDMOB-PHANTOM-ROUND"
     END-PERFORM
     PERFORM COUNT-PHANTOMS
     MOVE "acceptance US15 20§12 Phantom: by day (sky darkness below 5) no phantom spawns" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO CW-TIME
     MOVE 1 TO PL-REST(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "STDMOB-PHANTOM-ROUND"
     END-PERFORM
     PERFORM COUNT-PHANTOMS
     MOVE "acceptance US15 20§12 Phantom: a rested player (rest 1) never attracts phantoms" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10000000 TO PL-REST(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR WS-N > 0
         CALL "STDMOB-PHANTOM-ROUND"
         PERFORM COUNT-PHANTOMS
     END-PERFORM
     MOVE "acceptance US15 20§12 Phantom: at night an unrested player under open sky gets 1 to 3 phantoms" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1 AND WS-N <= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-PHANTOM
     MOVE "acceptance US15 20§12 Phantom: it appears 20 to 34 blocks up, within 10 blocks east-west and north-south" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Y(WS-MOB) >= WS-FY + 1 + 20 - 1 AND EN-Y(WS-MOB) <= WS-FY + 1 + 34 + 1
             AND FUNCTION ABS(EN-X(WS-MOB) - PL-X(WS-PLAYER)) <= 10.6 AND FUNCTION ABS(EN-Z(WS-MOB) - PL-Z(WS-PLAYER)) <= 10.6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom: finalizeSpawn puts the anchor 5 blocks above the spawn block, size 0, speed 0.1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 1000 + 100
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-PH-AY(WS-MOB) - FUNCTION INTEGER(EN-Y(WS-MOB))) * 1000 + EN-PH-SPEED(WS-MOB) * 1000 + EN-VARIANT(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO CW-TIME

*>   Select the next circle point.
     MOVE 10 TO EN-PH-AX(WS-MOB)
     MOVE 80 TO EN-PH-AY(WS-MOB)
     MOVE 20 TO EN-PH-AZ(WS-MOB)
     MOVE 10 TO EN-PH-DIST(WS-MOB)
     MOVE 2 TO EN-PH-HEIGHT(WS-MOB)
     MOVE 1 TO EN-PH-CW(WS-MOB)
     MOVE 0 TO EN-PH-ANGLE(WS-MOB)
     CALL "STDMOB-PHANTOM-SELECT" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: the next point is the anchor + (10 cos 15 degrees, -4 + 2, 10 sin 15 degrees)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 19659 * 1000000 + 78000 * 1000 + 22588
     COMPUTE WS-V ROUNDED = EN-PH-TX(WS-MOB) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000000 + EN-PH-TY(WS-MOB) * 1000 * 1000 + EN-PH-TZ(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO EN-PH-CW(WS-MOB)
     CALL "STDMOB-PHANTOM-SELECT" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: clockwise -1 turns the angle back to 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PH-ANGLE(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The anchor above a target.
     MOVE 100 TO WS-TY
     MOVE 5 TO WS-ROLL
     MOVE 7 TO WS-TX
     MOVE 9 TO WS-TZ
     CALL "STDMOB-PHANTOM-ANCHOR" USING WS-MOB WS-TX WS-TY WS-TZ WS-ROLL
     MOVE "acceptance US15 20§12 Phantom: the anchor is the target block + (0, 20 + 5, 0)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 7 * 1000000 + 125 * 1000 + 9
     COMPUTE TL-OBSERVED-N = EN-PH-AX(WS-MOB) * 1000000 + EN-PH-AY(WS-MOB) * 1000 + EN-PH-AZ(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-TY
     CALL "STDMOB-PHANTOM-ANCHOR" USING WS-MOB WS-TX WS-TY WS-TZ WS-ROLL
     MOVE "acceptance US15 20§12 Phantom: an anchor below sea level (63) becomes sea level + 1 = 64" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE EN-PH-AY(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Move control: phantom at the origin of a 100-high sky, target 10 east, yaw 0, speed 0.1.
     MOVE 0 TO EN-X(WS-MOB) EN-Z(WS-MOB)
     MOVE 200 TO EN-Y(WS-MOB)
     MOVE 10 TO EN-PH-TX(WS-MOB)
     MOVE 200 TO EN-PH-TY(WS-MOB)
     MOVE 0 TO EN-PH-TZ(WS-MOB)
     MOVE 0 TO EN-YAW(WS-MOB) EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     MOVE 0.1 TO EN-PH-SPEED(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: turning 4 degrees (yaw 0 to -4) sets speed approach(0.1, 0.2, 0.025) = 0.125" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (0 - 4) * 1000 + 125
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB) * 1000 + EN-PH-SPEED(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom: velocity = 0.2 x speed x cos(86 degrees) = 0.001744 along x" TO TL-CASE
     MOVE 1744 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -90 TO EN-YAW(WS-MOB)
     MOVE 0.1 TO EN-PH-SPEED(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: aligned (turn under 3 degrees) the speed grows by 0.005 x 1.8 / 0.1 = 0.09" TO TL-CASE
     MOVE 190 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PH-SPEED(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Attack damage 6 + size.
     MOVE 2 TO EN-VARIANT(WS-MOB)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-MOB) WS-M
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-MOB WS-M WS-DAMAGE
     MOVE "acceptance US15 20§12 Phantom: attack damage is 6 + size (8 at size 2)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-VARIANT(WS-MOB)

*>   The ticks: scan, target, CIRCLE to SWOOP, the swoop hit.
     COMPUTE EN-X(WS-MOB) = PL-X(WS-PLAYER)
     COMPUTE EN-Y(WS-MOB) = PL-Y(WS-PLAYER) + 30
     COMPUTE EN-Z(WS-MOB) = PL-Z(WS-PLAYER)
     MOVE 0 TO EN-TARGET(WS-MOB) EN-TARGET-ID(WS-MOB) EN-PH-PHASE(WS-MOB) EN-VX(WS-MOB) EN-VY(WS-MOB) EN-VZ(WS-MOB)
     MOVE 20 TO EN-PH-SCAN(WS-MOB)
     MOVE 1 TO EN-PH-SET(WS-MOB)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     END-PERFORM
     MOVE "acceptance US15 20§12 Phantom: the scan counter 20 delays the first target query by 20 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§12 Phantom: the 21st tick takes the player in range as the target (scan reset to 60)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-PLAYER * 1000 + 60
     COMPUTE TL-OBSERVED-N = EN-TARGET(WS-MOB) * 1000 + EN-PH-SCAN(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom: attacking it starts in CIRCLE with the timer 10" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100 + 10
     COMPUTE TL-OBSERVED-N = EN-PH-PHASE(WS-MOB) * 100 + EN-PH-TIMER(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     END-PERFORM
     MOVE "acceptance US15 20§12 Phantom: after 10 ticks the phase is SWOOP" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-PH-PHASE(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom: the swoop timer is (8 + nextInt(4)) x 20 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PH-TIMER(WS-MOB) >= 100 AND EN-PH-TIMER(WS-MOB) <= 220
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hit: the phantom's box (inflated by 0.2) meets the player's.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-MOB)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-MOB)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-MOB)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§12 Phantom: a swoop that touches the player hurts it (6) and returns to CIRCLE" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 14 * 10 + 0
     COMPUTE TL-OBSERVED-N = PL-HEALTH(WS-PLAYER) * 10 + EN-PH-PHASE(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A target that is gone ends the attack: the phantom circles its anchor with no target.
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§12 Phantom: a spectator target is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The circle goal's per-tick changes with chosen draws.
     MOVE 100 TO EN-PH-AX(WS-MOB)
     MOVE 100 TO EN-PH-AY(WS-MOB)
     MOVE 100 TO EN-PH-AZ(WS-MOB)
     MOVE 10 TO EN-PH-DIST(WS-MOB)
     MOVE 3 TO EN-PH-HEIGHT(WS-MOB)
     MOVE 1 TO EN-PH-CW(WS-MOB)
     MOVE 0 TO EN-PH-ANGLE(WS-MOB)
     MOVE 0 TO EN-X(WS-MOB) EN-Y(WS-MOB) EN-Z(WS-MOB)
     MOVE 500 TO WS-N
     MOVE 500 TO WS-A1
     MOVE 500 TO WS-A2
     MOVE 500 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 500 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: no change when no draw hits 0" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 3 * 100 + 10
     COMPUTE TL-OBSERVED-N = EN-PH-HEIGHT(WS-MOB) * 100 + EN-PH-DIST(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-V
     MOVE 500 TO WS-N
     MOVE 0 TO WS-A1
     MOVE 500 TO WS-A2
     MOVE 500 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 500 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: draw (a) 0 sets the height to -4 + 0.5 x 9 = 0.5" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PH-HEIGHT(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 500 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 500 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: draw (b) 0 adds 1 to the distance" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-PH-DIST(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO EN-PH-DIST(WS-MOB)
     MOVE 500 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 500 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 500 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: a distance above 15 returns to 5 and reverses the direction" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-PH-DIST(WS-MOB) * 10 - EN-PH-CW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 250 TO WS-ROLL
     MOVE 1 TO EN-PH-CW(WS-MOB)
     MOVE 500 TO WS-A1
     MOVE 500 TO WS-A2
     MOVE 0 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 250 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: draw (c) 0 sets the angle to a quarter turn, then one step of 15 degrees" TO TL-CASE
     MOVE 1833 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PH-ANGLE(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO EN-X(WS-MOB)
     MOVE 96 TO EN-Y(WS-MOB)
     MOVE 100 TO EN-Z(WS-MOB)
     MOVE 0 TO EN-PH-TX(WS-MOB) EN-PH-TY(WS-MOB) EN-PH-TZ(WS-MOB)
     MOVE 0 TO EN-PH-TX(WS-MOB)
     MOVE EN-X(WS-MOB) TO EN-PH-TX(WS-MOB)
     MOVE EN-Y(WS-MOB) TO EN-PH-TY(WS-MOB)
     MOVE EN-Z(WS-MOB) TO EN-PH-TZ(WS-MOB)
     MOVE 500 TO WS-A1
     MOVE 500 TO WS-A2
     MOVE 500 TO WS-A3
     MOVE 500 TO WS-A4
     MOVE 500 TO WS-A5
     CALL "STDMOB-PHANTOM-CIRCLE" USING WS-MOB WS-A1 WS-A2 WS-A3 WS-A4 WS-A5
     MOVE "acceptance US15 20§12 Phantom circle: touching the move target selects the next point" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PH-TX(WS-MOB) NOT = EN-X(WS-MOB) OR EN-PH-TZ(WS-MOB) NOT = EN-Z(WS-MOB)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Anchor and point selection of a phantom whose anchor is not set yet.
     MOVE 0 TO EN-PH-SET(WS-MOB) EN-PH-AX(WS-MOB)
     COMPUTE EN-X(WS-MOB) = 5.5
     COMPUTE EN-Y(WS-MOB) = 100.2
     COMPUTE EN-Z(WS-MOB) = 7.5
     MOVE 1 TO EN-PH-CW(WS-MOB)
     MOVE 0 TO EN-PH-DIST(WS-MOB) EN-PH-HEIGHT(WS-MOB) EN-PH-ANGLE(WS-MOB)
     MOVE 9 TO WS-TX WS-TY WS-TZ
     MOVE 0 TO WS-ROLL
     CALL "STDMOB-PHANTOM-ANCHOR" USING WS-MOB WS-TX WS-TY WS-TZ WS-ROLL
     MOVE "acceptance US15 20§12 Phantom: setting the anchor above a target does nothing while the anchor is unset" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-PH-AX(WS-MOB) + EN-PH-SET(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-PHANTOM-SELECT" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: selecting a point with no anchor makes the phantom's own block the anchor" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 10000 + 100 * 100 + 7
     COMPUTE TL-OBSERVED-N = EN-PH-AX(WS-MOB) * 10000 + EN-PH-AY(WS-MOB) * 100 + EN-PH-AZ(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The heading in all four quadrants (yaw -90 means facing along +x: the turn is at most 4 degrees a tick).
     MOVE 0 TO EN-X(WS-MOB) EN-Z(WS-MOB)
     MOVE 200 TO EN-Y(WS-MOB) EN-PH-TY(WS-MOB)
     MOVE 0 TO EN-PH-TX(WS-MOB)
     MOVE 10 TO EN-PH-TZ(WS-MOB)
     MOVE -90 TO EN-YAW(WS-MOB)
     MOVE 1 TO EN-PH-SPEED(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: heading 90 (target due +z) turns yaw -90 to -86" TO TL-CASE
     MOVE -86 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§12 Phantom: a turn of 4 degrees at speed 1.0 slows by 0.025 toward 0.2 (0.975)" TO TL-CASE
     MOVE 975 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PH-SPEED(WS-MOB) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10 TO EN-PH-TZ(WS-MOB)
     MOVE -90 TO EN-YAW(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: heading -90 (target due -z) turns yaw -90 to -94" TO TL-CASE
     MOVE -94 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10 TO EN-PH-TX(WS-MOB)
     MOVE 10 TO EN-PH-TZ(WS-MOB)
     MOVE -90 TO EN-YAW(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: heading 135 (target -x, +z) turns yaw -90 to -86" TO TL-CASE
     MOVE -86 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -10 TO EN-PH-TZ(WS-MOB)
     MOVE -90 TO EN-YAW(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: heading -135 (target -x, -z) turns yaw -90 to -94" TO TL-CASE
     MOVE -94 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A target straight above (dx = dz = 0) has no horizontal part: the move control does nothing.
     MOVE 0 TO EN-PH-TX(WS-MOB) EN-PH-TZ(WS-MOB)
     MOVE 300 TO EN-PH-TY(WS-MOB)
     MOVE -90 TO EN-YAW(WS-MOB)
     CALL "STDMOB-PHANTOM-MOVE" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: no horizontal offset leaves the yaw alone" TO TL-CASE
     MOVE -90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The standard-mob step runs the phantom's own tick, and the spawner's tick runs a round.
     MOVE 0 TO EN-PH-DIST(WS-MOB) EN-TARGET(WS-MOB) EN-TARGET-ID(WS-MOB)
     MOVE 1 TO EN-PH-SET(WS-MOB)
     MOVE 5 TO EN-PH-SCAN(WS-MOB)
     MOVE 50 TO EN-PH-AX(WS-MOB) EN-PH-AY(WS-MOB) EN-PH-AZ(WS-MOB)
     COMPUTE EN-X(WS-MOB) = WS-PX + 20.5
     COMPUTE EN-Y(WS-MOB) = WS-FY + 10
     COMPUTE EN-Z(WS-MOB) = WS-PZ + 0.5
     MOVE 1 TO PL-STATE(WS-PLAYER)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§12 Phantom: the standard-mob step runs the phantom tick (circle values are drawn)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PH-DIST(WS-MOB) >= 5 AND EN-PH-DIST(WS-MOB) <= 15
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-HEALTH(WS-MOB)
     CALL "STDMOB-PHANTOM-TICK" USING WS-MOB WS-M
     CALL "STDMOB-PHANTOM-SPAWNER"
     CALL "STDMOB-PHANTOM-SPAWNER"
     STOP RUN.
 COUNT-PHANTOMS.
     MOVE 0 TO WS-N
     MOVE "minecraft:phantom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > EN-COUNT
         IF EN-USED(WS-V) = 1 AND EN-TYPE(WS-V) = WS-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 FIND-PHANTOM.
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > EN-COUNT OR WS-MOB > 0
         IF EN-USED(WS-V) = 1 AND EN-TYPE(WS-V) = WS-TYPE
             MOVE WS-V TO WS-MOB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-12.
 COPY CORETEST.
 COPY MOBSPTEST.
