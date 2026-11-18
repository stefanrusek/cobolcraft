*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 3.1 to 3.3 and 4.11 with 18 section 6): natural spawning of the water animals. The spawn rules: a surface
*> water animal (cod, salmon, pufferfish, squid, dolphin, tropical fish) needs y in [sea - 13, sea], water below and water above; a glow squid y <= sea - 33, raw brightness 0 and
*> water at the position. The category lists of a warm ocean give squid and dolphin (water creature, 6), pufferfish and tropical fish (water ambient, 7); plains gives glow squid only
*> (underground water creature, 5) and nothing in 6 or 7. A water ambient mob despawns beyond 64 blocks, a water creature beyond 128. Open: the biome tag
*> allows_tropical_fish_spawns_at_any_height (tropical fish use the surface rule only), babies.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 COPY XORO.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-COD                 BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-SQUID               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CAT                 BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-J                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     MOVE 6000 TO CW-TIME
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "N" TO TL-MODE
*>   Column A (x + 20): water from sea - 14 up to sea + 1. Column B (x + 25): water from sea - 14 up to sea - 3 only.
     COMPUTE WS-X = WS-PX + 20
     MOVE WS-PZ TO WS-Z
     COMPUTE WS-LO = WS-SEA - 15
     COMPUTE WS-HI = WS-SEA + 2
     PERFORM VARYING WS-Y FROM WS-LO BY 1 UNTIL WS-Y > WS-HI
         MOVE WS-WATER TO WS-J
         IF WS-Y = WS-SEA - 15
             MOVE WS-STONE TO WS-J
         END-IF
         IF WS-Y = WS-SEA + 2
             MOVE WS-AIR TO WS-J
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-J
     END-PERFORM
     COMPUTE WS-X = WS-PX + 25
     COMPUTE WS-LO = WS-SEA - 15
     COMPUTE WS-HI = WS-SEA - 2
     PERFORM VARYING WS-Y FROM WS-LO BY 1 UNTIL WS-Y > WS-HI
         MOVE WS-WATER TO WS-J
         IF WS-Y = WS-SEA - 15
             MOVE WS-STONE TO WS-J
         END-IF
         IF WS-Y = WS-SEA - 2
             MOVE WS-AIR TO WS-J
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-J
     END-PERFORM
*>   Column C (x + 30): glow squid depth, water from sea - 40 to sea - 30 in the rock.
     COMPUTE WS-X = WS-PX + 30
     COMPUTE WS-LO = WS-SEA - 40
     COMPUTE WS-HI = WS-SEA - 30
     PERFORM VARYING WS-Y FROM WS-LO BY 1 UNTIL WS-Y > WS-HI
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     END-PERFORM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SQUID WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:glow_squid" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GLOW WS-ENTITY-ROW WS-STATUS

*>   The surface rule (cod row for 7; tropical fish row for 8).
     MOVE "cod" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     COMPUTE WS-X = WS-PX + 20
     COMPUTE WS-Y = WS-SEA - 5
     MOVE "acceptance US15 21§3.2 surface water animal: y in band, water below and above passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA
     MOVE "acceptance US15 21§3.2 y = sea level passes (the band is inclusive)" TO TL-CASE
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA - 13
     MOVE "acceptance US15 21§3.2 y = sea - 13 passes (the band is inclusive)" TO TL-CASE
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA + 1
     MOVE "acceptance US15 21§3.2 y above sea level fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA - 14
     MOVE "acceptance US15 21§3.2 y = sea - 14 fails (below the band)" TO TL-CASE
     PERFORM RULE
     COMPUTE WS-X = WS-PX + 25
     COMPUTE WS-Y = WS-SEA - 4
     MOVE "acceptance US15 21§3.2 water below and above (surface just over the cell) passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA - 3
     MOVE "acceptance US15 21§3.2 the block above is air: fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM RULE
     MOVE "tropical_fish" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     COMPUTE WS-X = WS-PX + 20
     COMPUTE WS-Y = WS-SEA - 5
     MOVE "acceptance US15 21§3.2 minecraft:tropical_fish uses the surface rule (any-height tag open)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM RULE
*>   Glow squid: deep enough, dark, in water.
     MOVE "glow_squid" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     COMPUTE WS-X = WS-PX + 30
     COMPUTE WS-Y = WS-SEA - 34
     MOVE "acceptance US15 21§3.2 glow squid: y <= sea - 33, brightness 0, water at the position passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA - 29
     MOVE "acceptance US15 21§3.2 glow squid above sea - 33 fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM RULE
     COMPUTE WS-Y = WS-SEA - 45
     MOVE "acceptance US15 21§3.2 glow squid in rock (no water at the position) fails" TO TL-CASE
     PERFORM RULE
     COMPUTE WS-X = WS-PX + 20
     COMPUTE WS-Y = WS-SEA - 5
     MOVE "acceptance US15 21§3.2 glow squid in the lit shallows fails" TO TL-CASE
     PERFORM RULE

*>   Pool for packs: 24 x 24 water from sea - 14 to sea - 2 (cells sea - 12 to sea - 3 have water around).
     COMPUTE WS-QX = WS-PX + 16
     COMPUTE WS-QZ = WS-PZ - 12
     COMPUTE WS-LO = WS-SEA - 15
     COMPUTE WS-HI = WS-SEA - 1
     COMPUTE WS-CX = WS-QX + 23
     COMPUTE WS-CZ = WS-QZ + 23
     PERFORM VARYING WS-X FROM WS-QX BY 1 UNTIL WS-X > WS-CX
         PERFORM VARYING WS-Z FROM WS-QZ BY 1 UNTIL WS-Z > WS-CZ
             COMPUTE WS-LO = WS-SEA - 15
     COMPUTE WS-HI = WS-SEA - 1
     PERFORM VARYING WS-Y FROM WS-LO BY 1 UNTIL WS-Y > WS-HI
                 MOVE WS-WATER TO WS-J
                 IF WS-Y = WS-SEA - 15
                     MOVE WS-STONE TO WS-J
                 END-IF
                 IF WS-Y = WS-SEA - 1
                     MOVE WS-AIR TO WS-J
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-J
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-QX = WS-PX + 28
     MOVE WS-PZ TO WS-QZ
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     IF WS-QX < 0
         COMPUTE WS-CX = (WS-QX - 15) / 16
     END-IF
     IF WS-QZ < 0
         COMPUTE WS-CZ = (WS-QZ - 15) / 16
     END-IF
     COMPUTE WS-PY = WS-SEA - 6
     MOVE SPACES TO WS-KEY48
     MOVE "minecraft:warm_ocean" TO WS-KEY48
     CALL "MS6-BIOME-FIND" USING WS-KEY48 WS-BIOME
     MOVE 6 TO WS-CAT
     PERFORM RUN-PACKS
     MOVE "acceptance US15 21§3.3 warm_ocean water_creature packs spawn in the water" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.3 and are all squid, dolphins or nautilus (the nautilus has a row since lane p49d)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 7 TO WS-CAT
     PERFORM RUN-PACKS
     MOVE "acceptance US15 21§3.3 warm_ocean water_ambient packs spawn in the water" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION MIN(WS-TOTAL, 1)
     PERFORM CHECK-N
     MOVE "acceptance US15 21§3.3 and are all pufferfish or tropical fish" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE SPACES TO WS-KEY48
     MOVE "minecraft:plains" TO WS-KEY48
     CALL "MS6-BIOME-FIND" USING WS-KEY48 WS-BIOME
     MOVE 6 TO WS-CAT
     PERFORM RUN-PACKS
     MOVE "acceptance US15 21§3.3 plains has no water_creature entry: nothing spawns in water" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     PERFORM CHECK-N

*>   Despawn: a water ambient mob beyond 64 blocks goes, a water creature at 100 blocks stays (6.11).
     COMPUTE WS-FX = PL-X(WS-PLAYER) + 80
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE WS-ROW TO WS-M
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 650
         CALL "MS6-DESPAWN-TICK" USING WS-M
     END-PERFORM
     MOVE "acceptance US15 21§6.11 a cod 80 blocks from the player despawns (water ambient limit 64)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-M) TO TL-OBSERVED-N
     PERFORM CHECK-N
     COMPUTE WS-FX = PL-X(WS-PLAYER) + 100
     CALL "MOB-SPAWN" USING WS-DIM WS-SQUID WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     CALL "MS6-DESPAWN-TICK" USING WS-ROW
     MOVE "acceptance US15 21§6.11 a squid 100 blocks away stays (water creature limit 128)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK-N
     STOP RUN.
 RULE.
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 RUN-PACKS.
     MOVE 0 TO WS-TOTAL WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK" USING XR-STATE WS-DIM WS-CAT WS-BIOME WS-CX WS-CZ WS-QX WS-PY WS-QZ WS-SPAWNED
         ADD WS-SPAWNED TO WS-TOTAL
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-M
             IF WS-M = 0
                 ADD 1 TO WS-BAD
             ELSE
                 IF WS-CAT = 6 AND SM-KEY(WS-M) NOT = "squid" AND SM-KEY(WS-M) NOT = "dolphin" AND SM-KEY(WS-M) NOT = "nautilus"
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-CAT = 7 AND SM-KEY(WS-M) NOT = "pufferfish" AND SM-KEY(WS-M) NOT = "tropical_fish"
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
             CALL "ENTITY-REMOVE" USING WS-ROW
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-21-3.
 COPY CORETEST.
 COPY MOBSPTEST.
