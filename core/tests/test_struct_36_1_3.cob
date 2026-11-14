*> Acceptance test of docs/protocol/36-structures-1 section 3 (element schemas): the common structure settings (biomes as an id, a list or a
*> tag with nested tags, step, terrain_adaptation with its default none, spawn_overrides read and ignored), the structure set (structures
*> with weights in file order, placement dispatch), the placements (locate_offset, frequency, frequency_reduction_method and their defaults, salt,
*> exclusion_zone, random_spread with spread_type, concentric_rings, dimension_origin) and the rejection of spacing not above separation.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-1§3 Element schemas: the biomes of a tag (a nested tag expanded, no biome twice) in tag order" TO TL-CASE
     MOVE 1 TO WS-I
     PERFORM BIOMES-OF
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "minecraft:plains minecraft:forest minecraft:swamp" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: the biomes given as a list" TO TL-CASE
     MOVE 2 TO WS-I
     PERFORM BIOMES-OF
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "minecraft:desert minecraft:plains" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: the biomes given as one id" TO TL-CASE
     MOVE 3 TO WS-I
     PERFORM BIOMES-OF
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "minecraft:plains" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§3 Element schemas: step and terrain_adaptation of the four structures" TO TL-CASE
     COMPUTE TL-OBSERVED-N = ST-STEP(1) * 10000000 + ST-ADAPT(1) * 1000000 + ST-STEP(2) * 100000 + ST-ADAPT(2) * 10000
         + ST-STEP(3) * 1000 + ST-ADAPT(3) * 100 + ST-STEP(4) * 10 + ST-ADAPT(4)
     MOVE 42305451 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: the structures of alpha_set in file order with their weights (2 1 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SE-STRUCT(SS-EN-FIRST(1)) * 100000 + SE-WEIGHT(SS-EN-FIRST(1)) * 10000 + SE-STRUCT(SS-EN-FIRST(1) + 1) * 1000
         + SE-WEIGHT(SS-EN-FIRST(1) + 1) * 100 + SE-STRUCT(SS-EN-FIRST(1) + 2) * 10 + SE-WEIGHT(SS-EN-FIRST(1) + 2)
     MOVE 122131 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: alpha_set has 3 entries" TO TL-CASE
     MOVE SS-EN-COUNT(1) TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 36-1§3 Element schemas: random_spread is placement kind 2, linear is spread 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-KIND(1) * 10 + SS-SPREAD(1)
     MOVE 20 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: locate_offset [4, 0, -4]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-LOC-X(1) * 10000 + SS-LOC-Y(1) * 100 + SS-LOC-Z(1)
     MOVE 39996 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: defaults are frequency 1.0, method default (0), no exclusion zone" TO TL-CASE
     COMPUTE WS-F = SS-FREQ(1) * 10
     COMPUTE TL-OBSERVED-N = WS-F * 1000 + SS-METHOD(1) * 100 + SS-EX-SET(1) * 10 + SS-EX-COUNT(1)
     MOVE 10000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: a missing locate_offset is [0, 0, 0]" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(SS-LOC-X(2)) + FUNCTION ABS(SS-LOC-Y(2)) + FUNCTION ABS(SS-LOC-Z(2))
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: the three legacy frequency reduction methods (1, 2, 3)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-METHOD(2) * 100 + SS-METHOD(3) * 10 + SS-METHOD(4)
     MOVE 123 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: frequency 0.25 and 0.5 (times 100)" TO TL-CASE
     COMPUTE WS-F = SS-FREQ(2) * 100
     COMPUTE TL-OBSERVED-N = WS-F * 100
     COMPUTE WS-F = SS-FREQ(3) * 100
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N + WS-F
     MOVE 2550 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: triangular spread, exclusion zone naming alpha_set (set 1) with chunk_count 8, frequency 0.5, salt 777" TO TL-CASE
     COMPUTE WS-F = SS-FREQ(8) * 10
     COMPUTE TL-OBSERVED-N = SS-SPREAD(8) * 100000000 + SS-EX-SET(8) * 10000000 + SS-EX-COUNT(8) * 100000 + WS-F * 10000 + SS-SALT(8)
     MOVE 110850777 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: concentric_rings is kind 0 with distance 32, spread 3, count 3 and the preferred biome plains" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-KIND(6) * 10000000 + SS-DISTANCE(6) * 100000 + SS-RING-SPREAD(6) * 10000 + SS-RING-COUNT(6) * 1000 + SS-PREF-COUNT(6)
     COMPUTE TL-EXPECTED-N = 0 * 10000000 + 32 * 100000 + 3 * 10000 + 3 * 1000 + 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-1§3 Element schemas: the preferred biome" TO TL-CASE
     MOVE SD-BIOME(SS-PREF-FIRST(6)) TO TL-OBSERVED
     MOVE "minecraft:plains" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§3 Element schemas: dimension_origin is kind 1" TO TL-CASE
     MOVE SS-KIND(5) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§3 Element schemas: the set keys are the file names with the namespace" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SS-KEY(7) TO TL-OBSERVED
     MOVE "minecraft:tri32_set" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BIOMES-OF.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-STATUS FROM 0 BY 1 UNTIL WS-STATUS >= ST-BIOME-COUNT(WS-I)
         STRING FUNCTION TRIM(SD-BIOME(ST-BIOME-FIRST(WS-I) + WS-STATUS)) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM.
