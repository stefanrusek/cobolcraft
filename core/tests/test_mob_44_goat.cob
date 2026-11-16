*> Implementation test (US15; docs/protocol/44-residual-mob-questions-4-land-animals.md section 4, Goat): the ram.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-GOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CLEAR              BINARY-LONG.
 01 WS-DX                 FLOAT-LONG.
 01 WS-DY                 FLOAT-LONG.
 01 WS-DZ                 FLOAT-LONG.
 01 WS-STARTED            BINARY-LONG.
 01 WS-ALIVE              BINARY-LONG.
 01 WS-CONT               BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-LEN0               BINARY-LONG.
 01 WS-CAPACITY           BINARY-LONG VALUE 256.
 01 WS-SPEED              FLOAT-LONG.
 01 WS-BABY               BINARY-LONG.
 01 WS-BLOCKED            BINARY-LONG.
 01 WS-KB                 FLOAT-LONG.
 01 WS-SCREAM             BINARY-LONG.
 01 WS-DRAW               BINARY-LONG.
 01 WS-HX                 FLOAT-LONG.
 01 WS-HZ                 FLOAT-LONG.
 01 WS-HIT                BINARY-LONG.
 01 WS-GOAT               BINARY-LONG.
 01 WS-GZ                 FLOAT-LONG.
 01 WS-WALK2              BINARY-LONG.
 01 WS-HEALTH0            FLOAT-LONG.

 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:goat" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
*>   Knockback: S = clamp(speed x 1.65, 0.2, 3.0), x 1.0 or 0.5 when blocked, x 2.5 (adult) or 1.0 (baby).
     MOVE 0.2 TO WS-SPEED
     MOVE 0 TO WS-BABY WS-BLOCKED
     CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-BLOCKED WS-KB
     MOVE "acceptance US15 44§9 Goat ram: adult knockback at speed 0.2 = 0.33 x 2.5 = 0.825" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-KB * 10000
     MOVE 8250 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-BABY
     CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-BLOCKED WS-KB
     MOVE "acceptance US15 44§9 Goat ram: baby knockback = 0.33 x 1.0" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-KB * 10000
     MOVE 3300 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-BABY
     MOVE 1 TO WS-BLOCKED
     CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-BLOCKED WS-KB
     MOVE "acceptance US15 44§9 Goat ram: a blocked hit (shield) halves it: 0.4125" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-KB * 10000
     MOVE 4125 TO WS-E
     PERFORM CHECK-N
     MOVE 0.05 TO WS-SPEED
     MOVE 0 TO WS-BLOCKED
     CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-BLOCKED WS-KB
     MOVE "acceptance US15 44§9 Goat ram: the speed term is clamped to 0.2 at least: 0.2 x 2.5 = 0.5" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-KB * 10000
     MOVE 5000 TO WS-E
     PERFORM CHECK-N
     MOVE 5 TO WS-SPEED
     CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-BLOCKED WS-KB
     MOVE "acceptance US15 44§9 Goat ram: and to 3.0 at most: 3.0 x 2.5 = 7.5" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-KB * 10000
     MOVE 75000 TO WS-E
     PERFORM CHECK-N
*>   Cooldown after a ram: U(600, 6000), a screaming goat U(100, 300).
     MOVE 0 TO WS-SCREAM
     MOVE 0 TO WS-DRAW
     CALL "M44-RAM-COOLDOWN" USING WS-SCREAM WS-DRAW WS-KB
     MOVE "acceptance US15 44§9 Goat ram: the cooldown draw 0 gives 600" TO WS-CASE
     MOVE WS-KB TO WS-O
     MOVE 600 TO WS-E
     PERFORM CHECK-N
     MOVE 5400 TO WS-DRAW
     CALL "M44-RAM-COOLDOWN" USING WS-SCREAM WS-DRAW WS-KB
     MOVE "acceptance US15 44§9 Goat ram: the draw 5400 gives 6000" TO WS-CASE
     MOVE WS-KB TO WS-O
     MOVE 6000 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-SCREAM
     MOVE 200 TO WS-DRAW
     CALL "M44-RAM-COOLDOWN" USING WS-SCREAM WS-DRAW WS-KB
     MOVE "acceptance US15 44§9 Goat ram: a screaming goat's top is 300" TO WS-CASE
     MOVE WS-KB TO WS-O
     MOVE 300 TO WS-E
     PERFORM CHECK-N
     MOVE 201 TO WS-DRAW
     CALL "M44-RAM-COOLDOWN" USING WS-SCREAM WS-DRAW WS-KB
     MOVE "acceptance US15 44§9 Goat ram: a screaming goat's draw wraps in 201 values: 201 gives 100" TO WS-CASE
     MOVE WS-KB TO WS-O
     MOVE 100 TO WS-E
     PERFORM CHECK-N
*>   The ram: a target 4 to 7 blocks away starts a 20-tick preparation, then a charge at 3.0 x speed 0.2.
     MOVE 0 TO EN-RAM-CD(WS-ROW)
     MOVE 0 TO WS-DRAW
     MOVE 0 TO WS-DX
     MOVE 5 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: a target 5 blocks away starts the preparation (state 1), no walk" TO WS-CASE
     COMPUTE WS-O = EN-RAM-STATE(WS-ROW) * 10 + WS-HIT
     MOVE 10 TO WS-E
     PERFORM CHECK-N
     MOVE 9 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: a target that moved beyond 7 blocks cancels the preparation" TO WS-CASE
     MOVE EN-RAM-STATE(WS-ROW) TO WS-O
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     MOVE 5 TO WS-DZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     END-PERFORM
     MOVE "acceptance US15 44§9 Goat ram: after 20 ticks of preparation the goat rams (state 2)" TO WS-CASE
     MOVE EN-RAM-STATE(WS-ROW) TO WS-O
     MOVE 2 TO WS-E
     PERFORM CHECK-N
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: the charge walks along the stored direction (+z) at 0.6 a tick" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-HZ * 1000
     MOVE 600 TO WS-E
     PERFORM CHECK-N
     MOVE 1 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: a target within 1.2 blocks is hit; the ram ends with the cooldown 600" TO WS-CASE
     COMPUTE WS-O = WS-HIT * 10000 + EN-RAM-STATE(WS-ROW) * 1000 + EN-RAM-CD(WS-ROW)
     MOVE 10600 TO WS-E
     PERFORM CHECK-N
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: the cooldown runs down by 1 a tick and blocks a new ram" TO WS-CASE
     COMPUTE WS-O = EN-RAM-STATE(WS-ROW) * 10000 + EN-RAM-CD(WS-ROW)
     MOVE 599 TO WS-E
     PERFORM CHECK-N
*>   A charge that reaches the ram target without a hit ends (within 0.25 of the point, here the goat is moved onto it).
     MOVE 0 TO EN-RAM-CD(WS-ROW)
     MOVE 5 TO WS-DZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     END-PERFORM
     COMPUTE EN-Z(WS-ROW) = EN-Z(WS-ROW) + 5
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: reaching the ram point ends it without a hit" TO WS-CASE
     COMPUTE WS-O = WS-HIT * 10000 + EN-RAM-STATE(WS-ROW) * 1000 + EN-RAM-CD(WS-ROW)
     MOVE 600 TO WS-E
     PERFORM CHECK-N

*>   The tick: a goat 5 blocks from a survival player prepares (stands still), then charges at the player and hurts it.
     COMPUTE WS-GZ = WS-FZ - 5
     MOVE "minecraft:goat" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-GZ WS-YAW WS-GOAT
     MOVE 1 TO EN-ON-GROUND(WS-GOAT)
     MOVE 0 TO EN-RAM-CD(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: a player 5 blocks away: the goat prepares and stands still (walk 2)" TO WS-CASE
     MOVE WS-WALK2 TO WS-O
     MOVE 2 TO WS-E
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     END-PERFORM
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: the charge walks toward the player (walk 1, hz 0.6)" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-WALK2 * 10000 + WS-HZ * 1000
     MOVE 10600 TO WS-E
     PERFORM CHECK-N
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     COMPUTE EN-Z(WS-GOAT) = WS-FZ - 1
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: the hit hurts the player and ends the ram" TO WS-CASE
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH0
         ADD 1 TO WS-O
     END-IF
     IF EN-RAM-STATE(WS-GOAT) = 0
         ADD 10 TO WS-O
     END-IF
     MOVE 11 TO WS-E
     PERFORM CHECK-N
     COMPUTE WS-GZ = WS-FZ + 30
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-GZ WS-YAW WS-ROW
     MOVE 5 TO EN-RAM-CD(WS-ROW)
     CALL "M44-GOAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: with no player in range only the cooldown runs down" TO WS-CASE
     COMPUTE WS-O = WS-WALK2 * 10 + EN-RAM-CD(WS-ROW)
     MOVE 4 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-RAM-CD(WS-ROW)
     CALL "M44-GOAT-TICK" USING WS-ROW WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: cooldown 0 and no player: nothing happens" TO WS-CASE
     COMPUTE WS-O = WS-WALK2 * 10 + EN-RAM-CD(WS-ROW) + EN-RAM-STATE(WS-ROW)
     MOVE 0 TO WS-E
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-44-GOAT.
 COPY CORETEST.
 COPY MOBSPTEST.
