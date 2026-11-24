*> Implementation test (lane genlimits; docs/protocol/56 sections 4.1 and 5.2, docs/protocol/21 section 3.2 with 18 section 6): the water animals' spawn rules of
*> a superflat world use its sea level -63, not 63. Surface water animals (y in [sea - 13, sea]) fit y -76 to -63, a glow squid (y <= sea - 33, raw brightness 0)
*> never fits above y -96 (under the world). Before the fix MS6-WATER-RULE read DM-SEA-LEVEL 63 for superflat, so a cod fitted y 50 to 63 (no water there in a flat world) and a glow squid
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
 COPY PROTO.
 COPY COREAPI.
 COPY BRWORLD.
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
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 PROCEDURE DIVISION.
*>   A real superflat world (the flat generator is cheap): needs the generated packs; without them the test is skipped with one passing marker case.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "implementation genlimits no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Flat" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "implementation genlimits the superflat world holds the player in the standard overworld (dimension 3)" TO TL-CASE
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
*>   One column of water from y -64 (over the void under the world) to -58 in the flat ground, air at -57.
     COMPUTE WS-X = WS-PX + 3
     MOVE WS-PZ TO WS-Z
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > -57
         MOVE WS-WATER TO WS-OK
         IF WS-Y = -57
             MOVE 0 TO WS-OK
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OK
     END-PERFORM
     MOVE "cod" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     MOVE "glow_squid" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-GLOW-ROW

*>   The same world read as a standard one (CW-WORLD-TYPE): sea 63, the cod needs y 50 to 63, so y -63 fails.
     MOVE "standard" TO CW-WORLD-TYPE
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

*>   The world as it is: superflat.
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
     MOVE -62 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a cod at y -62 (above sea level) fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The village well case: dark water far above -96 (y -63 here): no glow squid in a flat world.
     MOVE -63 TO WS-Y
     CALL "MS6-WATER-RULE" USING WS-DIM WS-GLOW-ROW WS-X WS-Y WS-Z WS-OK
     MOVE "implementation genlimits superflat: a glow squid in water at y -63 fails (needs y <= -96)" TO TL-CASE
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
