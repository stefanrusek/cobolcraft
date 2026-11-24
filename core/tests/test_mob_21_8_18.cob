*> Wind charge and breeze wind charge (docs/protocol/21 section 8.18, 44-8 section 8, 17 section 3.15, 20 section 6.2, 42-7 section 3.1; lane p49f, T21400). PJ-KIND 42: a charge flies straight at
*> constant speed (no gravity, no drag); a hit entity takes 1.0 and the burst follows at the charge; a block hit bursts 0.25 outside the face; above the world top + 30 it bursts where it is.
*> The burst (radius 1.2 and knockback multiplier 1.22, or 3.0 and none) does no damage: a living entity within 2R is pushed by (1 - dist) x seen x multiplier along the direction from the centre to its eyes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-WIND-TYPE           BINARY-LONG.
 01 WS-BREEZE-TYPE         BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-BREEZE              BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-SEEN                FLOAT-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-FLYING              BINARY-LONG.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TALLY               BINARY-LONG.
 01 WS-FLOOR-Y             FLOAT-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:wind_charge" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WIND-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:breeze_wind_charge" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BREEZE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-FLOOR-Y
*>   The strength of the push: (1 - dist) x seen x multiplier, 0 for a flying player.
     MOVE 0.5 TO WS-DIST
     MOVE 1 TO WS-SEEN
     MOVE 1220 TO WS-MULT
     MOVE 0 TO WS-FLYING
     CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN WS-MULT WS-FLYING WS-STRENGTH
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 strength at dist 0.5, seen 1, multiplier 1.22 is 0.61" TO WS-CASE
     MOVE 610 TO WS-E
     COMPUTE WS-O ROUNDED = WS-STRENGTH * 1000
     PERFORM CHECK-N
     MOVE 0.5 TO WS-SEEN
     CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN WS-MULT WS-FLYING WS-STRENGTH
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 half seen is 0.305" TO WS-CASE
     MOVE 305 TO WS-E
     COMPUTE WS-O ROUNDED = WS-STRENGTH * 1000
     PERFORM CHECK-N
     MOVE 1000 TO WS-MULT
     MOVE 1 TO WS-SEEN
     CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN WS-MULT WS-FLYING WS-STRENGTH
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 no multiplier: 0.5" TO WS-CASE
     MOVE 500 TO WS-E
     COMPUTE WS-O ROUNDED = WS-STRENGTH * 1000
     PERFORM CHECK-N
     MOVE 1 TO WS-FLYING
     CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN WS-MULT WS-FLYING WS-STRENGTH
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 a flying player is not pushed (multiplier 0)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = WS-STRENGTH * 1000
     PERFORM CHECK-N
*>   Spawn: a tracker row of the right type, sent without entity data.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FLOOR-Y + 30
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0.5 TO WS-VX
     MOVE 0 TO WS-VY
     MOVE 0 TO WS-VZ
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 the charge is a wind_charge entity" TO WS-CASE
     MOVE WS-WIND-TYPE TO WS-E
     MOVE EN-TYPE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 the viewer gets Add Entity and no entity data" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Flight: no gravity and no drag, 4 ticks of 0.5.
     MOVE EN-X(WS-ROW) TO WS-X0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "THROWN-TICK"
     END-PERFORM
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 four ticks at 0.5 move it 2.0 along x" TO WS-CASE
     MOVE 2000 TO WS-E
     COMPUTE WS-O ROUNDED = (EN-X(WS-ROW) - WS-X0) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 it does not fall (no gravity)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = (EN-Y(WS-ROW) - WS-FLOOR-Y - 30) * 1000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 its speed stays 0.5 (no drag)" TO WS-CASE
     MOVE 500 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-ROW) * 1000
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW
*>   The burst: a pig in the air 3 blocks from a breeze burst (R 3.0, no multiplier).
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FLOOR-Y + 40
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 8
     MOVE 0 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     MOVE EN-HEALTH(WS-PIG) TO WS-HEALTH0
     COMPUTE WS-X = PL-X(WS-PLAYER) - 3
     MOVE 3.0 TO WS-RADIUS
     MOVE 1000 TO WS-MULT
     CALL "WIND-EXPLODE" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-MULT WS-OWNER
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 push x at dist 0.5: 0.4845" TO WS-CASE
     MOVE 4845 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-PIG) * 10000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 push y toward its eyes (0.85 of 0.9): 0.1235" TO WS-CASE
     MOVE 1235 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VY(WS-PIG) * 10000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 no z push" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VZ(WS-PIG) * 10000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 the burst does no damage" TO WS-CASE
     MOVE WS-HEALTH0 TO WS-E
     MOVE EN-HEALTH(WS-PIG) TO WS-O
     PERFORM CHECK-N
*>   The same for a wind charge (R 1.2, multiplier 1.22), pig 1.2 blocks away.
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     COMPUTE WS-X = PL-X(WS-PLAYER) - 1.2
     MOVE 1.2 TO WS-RADIUS
     MOVE 1220 TO WS-MULT
     CALL "WIND-EXPLODE" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-MULT WS-OWNER
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 R 1.2 x 1.22 push x: 0.5144" TO WS-CASE
     MOVE 5144 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-PIG) * 10000
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 R 1.2 x 1.22 push y: 0.3279" TO WS-CASE
     MOVE 3279 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VY(WS-PIG) * 10000
     PERFORM CHECK-N
*>   Beyond 2R nothing happens.
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     COMPUTE WS-X = PL-X(WS-PLAYER) - 2.5
     CALL "WIND-EXPLODE" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-MULT WS-OWNER
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 2.5 blocks away is beyond 2R = 2.4: not pushed" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-PIG) * 10000
     PERFORM CHECK-N
*>   A charge flying into the pig hurts it for 1.0 and bursts there.
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     COMPUTE WS-X = PL-X(WS-PLAYER) - 0.4
     MOVE 0 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     CALL "THROWN-TICK"
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 hitting a pig takes 1 point of health" TO WS-CASE
     COMPUTE WS-E = WS-HEALTH0 - 1
     MOVE EN-HEALTH(WS-PIG) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 the charge is gone after the hit" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 the burst pushed the pig away (+x)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VX(WS-PIG) > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A block hit: dropping onto the floor bursts 0.25 above it and the charge is gone; the Explode packet reaches the player.
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 4
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 4
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-Y = WS-FY + 3
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-VX
     MOVE -1 TO WS-VY
     MOVE 1 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 the charge is a breeze_wind_charge entity" TO WS-CASE
     MOVE WS-BREEZE-TYPE TO WS-E
     MOVE EN-TYPE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "THROWN-TICK"
     CALL "THROWN-TICK"
     CALL "THROWN-TICK"
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 a floor hit removes the charge" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-TALLY
     INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL "36"
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 the player is sent an Explode packet (0x24)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TALLY > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A charge flying into a player hurts it for 1.0 (2 half hearts).
     COMPUTE WS-X = PL-X(WS-PLAYER) - 0.4
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 1
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0.5 TO WS-VX
     MOVE 0 TO WS-VY
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     CALL "THROWN-TICK"
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 a charge that hits a player hurts it for 1.0" TO WS-CASE
     COMPUTE WS-E = WS-HEALTH0 - 1
     MOVE PL-HEALTH(WS-PLAYER) TO WS-O
     PERFORM CHECK-N
*>   A burst centred on a mob's eyes has no direction: no push.
     MOVE 0 TO EN-VX(WS-PIG) EN-VY(WS-PIG) EN-VZ(WS-PIG)
     MOVE EN-X(WS-PIG) TO WS-X
     COMPUTE WS-Y = EN-Y(WS-PIG) + 0.765
     MOVE EN-Z(WS-PIG) TO WS-Z
     MOVE 3.0 TO WS-RADIUS
     MOVE 1000 TO WS-MULT
     CALL "WIND-EXPLODE" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-MULT WS-OWNER
     MOVE "acceptance US15 minecraft:breeze_wind_charge 44-8§8 a burst on the mob's eyes pushes nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VX(WS-PIG) * 10000
     PERFORM CHECK-N
*>   A row without a state entry is ignored.
     CALL "WIND-STEP" USING PL-ENTITY-ROW(WS-PLAYER)
*>   Far above the world top (319 + 30): the charge bursts where it is and is discarded.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE 400 TO WS-Y
     MOVE 0 TO WS-BREEZE
     MOVE 0.2 TO WS-VY
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     CALL "THROWN-TICK"
     MOVE "acceptance US15 minecraft:wind_charge 44-8§8 above the world top plus 30 the charge is discarded" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-18.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
