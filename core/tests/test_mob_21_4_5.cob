*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.5 with doc 44 part 7 sections 2.6 and 6.1): squid and glow squid. A squid's movement vector m is
*> (cos a x 0.2, -0.1 + r x 0.2, sin a x 0.2); it thrusts along m late in the first half of its tentacle phase; with no player within 32 blocks for 100 ticks it stops; it flees an
*> attacker within 10 blocks (push scaled to 3, / 20, no Y part when the target cell is air, unused when it is a block); out of water it falls; a glow squid goes dark for 100 ticks when hit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-SQUID               BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-MAG                 FLOAT-LONG.
 01 WS-TS0                 FLOAT-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:glow_squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GLOW WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     PERFORM PLACE-SQUID
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     COMPUTE WS-MAG = FUNCTION SQRT(EN-SQ-MX(WS-ROW) * EN-SQ-MX(WS-ROW) + EN-SQ-MZ(WS-ROW) * EN-SQ-MZ(WS-ROW))
     MOVE "acceptance US15 21§4.5 minecraft:squid first tick: m has horizontal length 0.2 and Y in -0.1 to 0.1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAG > 0.1999 AND WS-MAG < 0.2001 AND EN-SQ-MY(WS-ROW) >= -0.1 AND EN-SQ-MY(WS-ROW) <= 0.1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE EN-X(WS-ROW) TO WS-MINX WS-MAXX
     MOVE EN-Y(WS-ROW) TO WS-MINY WS-MAXY
     MOVE EN-Z(WS-ROW) TO WS-MINZ WS-MAXZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MINX = FUNCTION MIN(WS-MINX, EN-X(WS-ROW))
         COMPUTE WS-MAXX = FUNCTION MAX(WS-MAXX, EN-X(WS-ROW))
         COMPUTE WS-MINY = FUNCTION MIN(WS-MINY, EN-Y(WS-ROW))
         COMPUTE WS-MAXY = FUNCTION MAX(WS-MAXY, EN-Y(WS-ROW))
         COMPUTE WS-MINZ = FUNCTION MIN(WS-MINZ, EN-Z(WS-ROW))
         COMPUTE WS-MAXZ = FUNCTION MAX(WS-MAXZ, EN-Z(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 21§4.5 a squid thrusts about the tank for 150 ticks and moves 1 block or more" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-MAXX - WS-MINX) + (WS-MAXZ - WS-MINZ) + (WS-MAXY - WS-MINY) >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.5 a squid stays inside the stone shell" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MINX > WS-X0 + 0.5 AND WS-MAXX < WS-X0 + 9.5 AND WS-MINZ > WS-Z0 + 0.5 AND WS-MAXZ < WS-Z0 + 9.5
             AND WS-MINY >= WS-Y0 + 1 AND WS-MAXY < WS-Y0 + 7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   No player within 32 blocks for over 100 ticks: m = 0.
     MOVE 101 TO EN-IDLE(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 noActionTime above 100 stops the squid (m = 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = 1000 * FUNCTION ABS(EN-SQ-MX(WS-ROW)) + 1000 * FUNCTION ABS(EN-SQ-MY(WS-ROW))
         + 1000 * FUNCTION ABS(EN-SQ-MZ(WS-ROW))
     PERFORM CHECK-N
*>   The tentacle speed is redrawn at a wrap with probability 1/10.
     MOVE 0 TO WS-CHANGED
     MOVE 1 TO EN-IDLE(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE 6.25 TO EN-SQ-PHASE(WS-ROW)
         MOVE 0.2 TO EN-SQ-TSPEED(WS-ROW)
         MOVE WS-I TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         IF EN-SQ-TSPEED(WS-ROW) NOT = 0.2
             MOVE 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§4.5 at a phase wrap the tentacle speed is redrawn with probability 1/10 (seen in 120 wraps)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Flee: the player stands 2 blocks west; push (2, 0, 0), target cell 2 east.
     PERFORM PLACE-SQUID
     PERFORM PLACE-PLAYER
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 flee into water: m = push / |push| x 3 / 20 = 0.15 east" TO TL-CASE
     MOVE 150 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SQ-MX(WS-ROW) * 1000
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM PLACE-SQUID
     PERFORM PLACE-PLAYER
     COMPUTE WS-BX = WS-X0 + 7
     COMPUTE WS-BY = WS-Y0 + 3
     COMPUTE WS-BZ = WS-Z0 + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 flee towards air: the vector loses its Y part" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-SQ-MY(WS-ROW) * 1000
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM PLACE-SQUID
     PERFORM PLACE-PLAYER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 flee towards a block: the vector is not used (m stays the random one, not 0.15)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     COMPUTE WS-MAG ROUNDED = EN-SQ-MX(WS-ROW) * 1000
     IF WS-MAG NOT = 150
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A far attacker (over 5 blocks): the push is scaled down; a very far one (10 or more) is ignored.
     PERFORM PLACE-SQUID
     PERFORM PLACE-PLAYER
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW) - 7
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 flee from 7 blocks: scale 3 - 0.2 = 2.8, m = 0.14" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-SQ-MX(WS-ROW) * 1000
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Out of water: it falls to the ground and stays there; the air runs out like a fish's (2 damage at 320 ticks).
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§4.5 a squid out of water falls and rests on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ON-GROUND(WS-ROW) = 1 AND EN-Y(WS-ROW) > WS-Y0 + 0.99 AND EN-Y(WS-ROW) < WS-Y0 + 1.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 319 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§2.6 a squid out of water for 320 ticks takes 2 drown damage (10 to 8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Glow squid: a hit makes it dark for 100 ticks, counting down.
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-GLOW WS-X WS-Y WS-Z WS-YAW WS-ROW
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 minecraft:glow_squid glows (dark ticks 0) until it is hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DARK(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 a hit glow squid goes dark: 100 dark ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE EN-DARK(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 21§4.5 the dark counter falls by one each tick (99)" TO TL-CASE
     MOVE 99 TO TL-EXPECTED-N
     MOVE EN-DARK(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 PLACE-SQUID.
     COMPUTE WS-X = WS-X0 + 5.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 5.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-SQ-PHASE(WS-ROW)
     MOVE 0.2 TO EN-SQ-TSPEED(WS-ROW)
     MOVE 3 TO EN-FLEE(WS-ROW)
     MOVE 0 TO EN-FLEE(WS-ROW).
 PLACE-PLAYER.
*>   The player 2 blocks west of the squid at the same height, the attacker it flees.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 3.5
     COMPUTE PL-Y(WS-PLAYER) = WS-Y0 + 3.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 5.5
     MOVE 5 TO EN-FLEE(WS-ROW)
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-ROW).
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-5.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
