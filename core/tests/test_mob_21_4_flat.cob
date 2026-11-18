*> Implementation test (lane genlimits; docs/protocol/56 sections 4.1 and 5.2, docs/protocol/21 section 3.2 with 18 section 6): the water animals' spawn rules of
*> a superflat world use its sea level -63, not 63. Surface water animals (y in [sea - 13, sea]) fit y -76 to -63, a glow squid (y <= sea - 33, raw brightness 0)
*> never fits above -96. Before the fix MS6-WATER-RULE read DM-SEA-LEVEL 63 for superflat, so a cod fitted y 50 to 63 (nowhere in a flat world) and a glow squid
*> fitted any dark water cell below y 30 (the village well). A standard world and the Nether keep their own sea levels; DIM-SEA-LEVEL-OF is the one place that decides.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-FLAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY DIMENSIONS.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-GLOW-ROW            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "implementation genlimits the test world is the standard overworld (dimension 3)" TO TL-CASE
     MOVE DIM-STANDARD-OVERWORLD TO TL-EXPECTED-N
     MOVE WS-DIM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO CW-TIME
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
*>   One column of water from y -70 to -60 over a stone floor at -71, water also above (the cell at -59 is water, -58 air).
     COMPUTE WS-X = WS-PX + 20
     MOVE WS-PZ TO WS-Z
     PERFORM VARYING WS-Y FROM -71 BY 1 UNTIL WS-Y > -58
         MOVE WS-WATER TO WS-OK
         IF WS-Y = -71
             MOVE WS-STONE TO WS-OK
         END-IF
         IF WS-Y = -58
             MOVE 0 TO WS-OK
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OK
     END-PERFORM
     MOVE "cod" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     MOVE "glow_squid" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-GLOW-ROW

*>   A standard overworld: sea 63, the cod needs y 50 to 63: y -63 fails, y -60 glow squid (dark water, below 30) passes.
     CALL "DIM-SEA-LEVEL-OF" USING WS-DIM WS-SEA
     MOVE "implementation genlimits a standard world's overworld sea level is 63" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     MOVE WS-SEA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -63 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits standard world: a cod at y -63 fails (the band is 50 to 63)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same world as superflat.
     MOVE "superflat" TO CW-WORLD-TYPE
     CALL "DIM-SEA-LEVEL-OF" USING WS-DIM WS-SEA
     MOVE "implementation genlimits superflat overworld sea level is -63 (56 4.1)" TO TL-CASE
     MOVE -63 TO TL-EXPECTED-N
     MOVE WS-SEA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -63 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a cod at y -63 (sea level) with water around passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -76 TO WS-Y
     MOVE -76 TO WS-LO
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a cod at y -76 (sea - 13) passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -77 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a cod at y -77 (below the band) fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -62 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a cod at y -62 (above sea level) fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The village well case: dark water at y -65, far above -96: no glow squid in a flat world.
     MOVE -65 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-GLOW-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a glow squid in water at y -65 fails (needs y <= -96)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Nether of a superflat world keeps its own sea level (56 5.2: the flag is the same, the sea level is the flat generator's in the overworld only).
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     CALL "DIM-SEA-LEVEL-OF" USING WS-DIM WS-SEA
     MOVE "implementation genlimits superflat world: the Nether keeps its dimension sea level" TO TL-CASE
     MOVE DM-SEA-LEVEL(DIM-STANDARD-NETHER) TO TL-EXPECTED-N
     MOVE WS-SEA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-4-FLAT.
 COPY CORETEST.
 COPY MOBSPTEST.
