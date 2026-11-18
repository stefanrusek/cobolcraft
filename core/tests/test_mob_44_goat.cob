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
 01 WS-X0                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 25.
 01 WS-FLOOR              BINARY-LONG.
 01 WS-ONE                BINARY-LONG VALUE 1.
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
 01 WS-TEXT               PIC X(1024).
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
*>   The charge (state 2) as the preparation leaves it: ram direction +z, ram point 5 blocks on, the goat's speed 0.2 x 3.0.
     MOVE 0 TO EN-RAM-CD(WS-ROW)
     MOVE 0 TO WS-DRAW
     MOVE 0 TO WS-DX
     MOVE 5 TO WS-DZ
     MOVE 2 TO EN-RAM-STATE(WS-ROW)
     MOVE 0 TO EN-RAM-T(WS-ROW) EN-RAM-DX(WS-ROW)
     MOVE 1 TO EN-RAM-DZ(WS-ROW)
     MOVE EN-X(WS-ROW) TO EN-RAM-PX(WS-ROW)
     COMPUTE EN-RAM-PZ(WS-ROW) = EN-Z(WS-ROW) + 5
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: the charge walks along the stored direction (+z) at 0.6 a tick" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-HZ * 1000
     MOVE 600 TO WS-E
     PERFORM CHECK-N
     MOVE 0.8 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: a target 0.8 away is not hit yet (the boxes of goat 0.9 and player 0.6 overlap within 0.75)" TO WS-CASE
     COMPUTE WS-O = WS-HIT * 10000 + EN-RAM-STATE(WS-ROW) * 1000
     MOVE 2000 TO WS-E
     PERFORM CHECK-N
     MOVE 0.7 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: a target within 0.75 is hit; the ram ends with the cooldown 600" TO WS-CASE
     COMPUTE WS-O = WS-HIT * 10000 + EN-RAM-STATE(WS-ROW) * 1000 + EN-RAM-CD(WS-ROW)
     MOVE 10600 TO WS-E
     PERFORM CHECK-N
*>   A charge that reaches the ram target without a hit ends (within 0.25 of the point, here the goat stands on it).
     MOVE 2 TO EN-RAM-STATE(WS-ROW)
     MOVE 0 TO EN-RAM-CD(WS-ROW)
     MOVE EN-Z(WS-ROW) TO EN-RAM-PZ(WS-ROW)
     MOVE 5 TO WS-DZ
     CALL "M44-RAM-TICK" USING WS-ROW WS-DX WS-DZ WS-DRAW WS-HX WS-HZ WS-HIT
     MOVE "acceptance US15 44§9 Goat ram: reaching the ram point ends it without a hit" TO WS-CASE
     COMPUTE WS-O = WS-HIT * 10000 + EN-RAM-STATE(WS-ROW) * 1000 + EN-RAM-CD(WS-ROW)
     MOVE 600 TO WS-E
     PERFORM CHECK-N

*>   The tick on open ground: a stone floor, the player at the origin, the goat 5 blocks north of it.
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-FY) - 1
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-FX) - 12
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-FZ) - 12
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-ONE
     COMPUTE WS-GZ = WS-FZ - 5
     MOVE "minecraft:goat" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-GZ WS-YAW WS-GOAT
     MOVE 1 TO EN-ON-GROUND(WS-GOAT)
     MOVE 0 TO EN-RAM-CD(WS-GOAT)
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 54§7.1 Goat ram: a player 5 blocks away: the first tick chooses the run-up (state 1): the cell 7 blocks north of the player" TO WS-CASE
     COMPUTE WS-O = EN-RAM-STATE(WS-GOAT) * 1000000 + (EN-RAM-SZ(WS-GOAT) - FUNCTION INTEGER(WS-FZ) + 100) * 1000 + EN-RAM-SX(WS-GOAT) - FUNCTION INTEGER(WS-FX) + 500
     MOVE 1093500 TO WS-E
     PERFORM CHECK-N
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 54§7.1 Goat ram: not on S yet: it walks (walk 1) north, toward S" TO WS-CASE
     COMPUTE WS-O = WS-WALK2 * 10 + 0
     IF WS-HZ < 0
         ADD 1 TO WS-O
     END-IF
     MOVE 11 TO WS-E
     PERFORM CHECK-N
*>   On S the head is lowered every tick (Entity Event 58, packet 34) and the goat stands still; the 21st tick on S rams.
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     COMPUTE EN-Z(WS-GOAT) = EN-RAM-SZ(WS-GOAT) + 0.5
     COMPUTE EN-X(WS-GOAT) = EN-RAM-SX(WS-GOAT) + 0.5
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 54§7.1 Goat ram: on S the goat lowers its head (one Entity Event, packet 34) and stands still (walk 2)" TO WS-CASE
     MOVE WS-TEXT(1:2) TO WS-O
     COMPUTE WS-O = WS-O * 10 + WS-WALK2
     MOVE 342 TO WS-E
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     END-PERFORM
     MOVE "acceptance US15 54§7.1 Goat ram: 20 ticks on S are not enough (state 1)" TO WS-CASE
     MOVE EN-RAM-STATE(WS-GOAT) TO WS-O
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 54§7.1 Goat ram: the 21st tick rams (state 2) at the far edge of the player's block: the ram point is 1.0 past T in z (the goat is north of it) and 0.5 in x" TO WS-CASE
     COMPUTE WS-O ROUNDED = EN-RAM-STATE(WS-GOAT) * 1000000 + (EN-RAM-PZ(WS-GOAT) - FUNCTION INTEGER(WS-FZ)) * 1000
         + (EN-RAM-PX(WS-GOAT) - FUNCTION INTEGER(WS-FX)) * 10
     MOVE 2001005 TO WS-E
     PERFORM CHECK-N
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: the charge walks toward the player (walk 1, hz 0.6)" TO WS-CASE
     COMPUTE WS-O ROUNDED = WS-WALK2 * 10000 + WS-HZ * 1000
     MOVE 10600 TO WS-E
     PERFORM CHECK-N
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     COMPUTE EN-Z(WS-GOAT) = WS-FZ - 0.5
     COMPUTE EN-X(WS-GOAT) = WS-FX
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 44§7.2 Goat ram: finishing the ram broadcasts Entity Event 59 (packet 34)" TO WS-CASE
     MOVE WS-TEXT(1:2) TO WS-O
     MOVE 34 TO WS-E
     PERFORM CHECK-N
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
*>   The target moves off T during the run-up: the head rises (Entity Event 59) and a new run-up is chosen.
     MOVE 1 TO EN-RAM-STATE(WS-GOAT)
     MOVE 0 TO EN-RAM-CD(WS-GOAT) EN-RAM-AGE(WS-GOAT)
     COMPUTE EN-X(WS-GOAT) = WS-FX + 0.5
     COMPUTE EN-Z(WS-GOAT) = WS-FZ - 5
     COMPUTE EN-RAM-TX(WS-GOAT) = FUNCTION INTEGER(WS-FX) + 1
     MOVE FUNCTION INTEGER(WS-FY) TO EN-RAM-TY(WS-GOAT)
     COMPUTE EN-RAM-TZ(WS-GOAT) = FUNCTION INTEGER(WS-FZ)
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     CALL "TEST-DRAIN-ENTITIES" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE "acceptance US15 54§7.1 Goat ram: the player left the block T was chosen for: Entity Event 59 and a new run-up for the new block (state 1 stays, T is the player's block)" TO WS-CASE
     MOVE WS-TEXT(1:2) TO WS-O
     COMPUTE WS-O = WS-O * 10 + EN-RAM-STATE(WS-GOAT)
     COMPUTE WS-O = WS-O * 10 + EN-RAM-TX(WS-GOAT) - FUNCTION INTEGER(WS-FX)
     MOVE 3410 TO WS-E
     PERFORM CHECK-N
*>   The goal ends after 160 ticks without a ram: Entity Event 59 and the cooldown 600.
     MOVE 160 TO EN-RAM-AGE(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 54§7.1 Goat ram: the run-up that took 161 ticks is dropped with the cooldown 600" TO WS-CASE
     COMPUTE WS-O = EN-RAM-STATE(WS-GOAT) * 10000 + EN-RAM-CD(WS-GOAT)
     MOVE 600 TO WS-E
     PERFORM CHECK-N
*>   With no player near, the run-up of a goat is dropped (the target is gone).
     COMPUTE WS-GZ = WS-FZ + 30
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-GZ WS-YAW WS-GOAT
     MOVE 1 TO EN-RAM-STATE(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 54§7.1 Goat ram: a run-up whose player is gone ends with the cooldown 600" TO WS-CASE
     COMPUTE WS-O = EN-RAM-STATE(WS-GOAT) * 10000 + EN-RAM-CD(WS-GOAT)
     MOVE 600 TO WS-E
     PERFORM CHECK-N
     MOVE 5 TO EN-RAM-CD(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: with no player in range only the cooldown runs down" TO WS-CASE
     COMPUTE WS-O = WS-WALK2 * 10 + EN-RAM-CD(WS-GOAT)
     MOVE 4 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO EN-RAM-CD(WS-GOAT)
     CALL "M44-GOAT-TICK" USING WS-GOAT WS-HX WS-HZ WS-WALK2
     MOVE "acceptance US15 44§9 Goat ram tick: cooldown 0 and no player: nothing happens" TO WS-CASE
     COMPUTE WS-O = WS-WALK2 * 10 + EN-RAM-CD(WS-GOAT) + EN-RAM-STATE(WS-GOAT)
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
