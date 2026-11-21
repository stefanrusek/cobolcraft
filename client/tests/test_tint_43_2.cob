*> Acceptance test of docs/protocol/43-tint-sources.md section 2 (block tint sources): the
*> registration table 2.1, the constants of the source kinds in hand, in world and as terrain
*> particle, the redstone table 2.2 (all 16 rows), the stem table 2.3 (all 8 rows) and the terrain
*> particle colour rule 2.4. The biome-dependent colours are tested with the biome pipeline
*> (sections 3 and 4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY CLTINTQ.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-NAME                PIC X(32).
 01 WS-KIND                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-C2                  BINARY-DOUBLE.
 01 WS-EXPECT              PIC X(8).
 01 WS-I                   BINARY-LONG.
 01 WS-DI                  PIC 99.
 01 WS-DX                  PIC 9.
 01 WS-DN                  PIC 9.
 01 WS-R                   COMP-2.
 01 WS-G                   COMP-2.
 01 WS-B                   COMP-2.
 01 WS-EDIT                PIC 9.999.
 01 WS-REDSTONE            PIC X(96) VALUE
     "4C0000700000" & "7A0000840000" & "8E0000990000" & "A30000AD0000"
     & "B70000C10000" & "CC0000D60000" & "E00000EA0600" & "F41B00FF3200".
 01 WS-RED-ROWS REDEFINES WS-REDSTONE.
    05 WS-RED-ROW          PIC X(6) OCCURS 16 TIMES.
 01 WS-STEMS               PIC X(48) VALUE
     "00FF0020F70440EF0860E70C80DF10A0D714C0CF18E0C71C".
 01 WS-STEM-ROWS REDEFINES WS-STEMS.
    05 WS-STEM-ROW         PIC X(6) OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
*>   The registration table: one row per (block, index) with the kind it must give.
     MOVE "tall_grass" TO WS-NAME
     MOVE 0 TO TQ-INDEX
     MOVE 5 TO WS-WANT
     PERFORM CHECK-KIND
     MOVE "large_fern" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 3 TO WS-WANT
     MOVE "fern" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "short_grass" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "potted_fern" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "bush" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 4 TO WS-WANT
     MOVE "grass_block" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 1 TO WS-WANT
     MOVE "pink_petals" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "wildflowers" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 3 TO WS-WANT
     MOVE 1 TO TQ-INDEX
     PERFORM CHECK-KIND
     MOVE "pink_petals" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 0 TO WS-WANT
     MOVE 2 TO TQ-INDEX
     PERFORM CHECK-KIND
     MOVE 0 TO TQ-INDEX
     MOVE 1 TO WS-WANT
     MOVE "spruce_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "birch_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "attached_melon_stem" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "attached_pumpkin_stem" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 7 TO WS-WANT
     MOVE "oak_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "jungle_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "acacia_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "dark_oak_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "vine" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "mangrove_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 8 TO WS-WANT
     MOVE "leaf_litter" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 9 TO WS-WANT
     MOVE "water_cauldron" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 10 TO WS-WANT
     MOVE "water" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "bubble_column" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 11 TO WS-WANT
     MOVE "redstone_wire" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 6 TO WS-WANT
     MOVE "sugar_cane" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 12 TO WS-WANT
     MOVE "melon_stem" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "pumpkin_stem" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 2 TO WS-WANT
     MOVE "lily_pad" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE 0 TO WS-WANT
     MOVE "cherry_leaves" TO WS-NAME
     PERFORM CHECK-KIND
     MOVE "azalea_leaves" TO WS-NAME
     PERFORM CHECK-KIND
*>   Constants: lily pad in hand FF71C35C, in world FF208030 (the terrain particle takes the world one).
     MOVE "lily_pad" TO TQ-NAME
     MOVE 0 TO TQ-INDEX TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: lily pad in hand" TO WS-CASE
     MOVE "FF71C35C" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 1 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: lily pad in world" TO WS-CASE
     MOVE "FF208030" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE 2 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: lily pad terrain particle" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   In hand constants of the biome sources.
     MOVE "oak_leaves" TO TQ-NAME
     MOVE 0 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: foliage in hand" TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "leaf_litter" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: dry foliage in hand" TO WS-CASE
     MOVE "FF5C3C32" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "sugar_cane" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: sugar cane in hand is white" TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "water_cauldron" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: water in hand is white" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "water" TO TQ-NAME
     MOVE 1 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: waterParticles in world is white" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     MOVE "grass_block" TO TQ-NAME
     MOVE 2 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: grassBlock terrain particle is white" TO WS-CASE
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   2.2: redstone by power, the same in hand, in world and as particle.
     MOVE "redstone_wire" TO TQ-NAME
     MOVE 0 TO TQ-INDEX
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         MOVE WS-I TO TQ-POWER
         MOVE FUNCTION MOD(WS-I, 3) TO TQ-MODE
         CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
         MOVE WS-I TO WS-DI
         MOVE SPACES TO WS-CASE
         STRING "acceptance US11 43§2 Block tint sources: redstone power " WS-DI
             DELIMITED BY SIZE INTO WS-CASE
         MOVE SPACES TO WS-EXPECT
         STRING "FF" WS-RED-ROW(WS-I + 1) DELIMITED BY SIZE INTO WS-EXPECT
         CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     END-PERFORM
*>   2.3: stem by age; V5.
     MOVE "melon_stem" TO TQ-NAME
     MOVE 0 TO TQ-POWER
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         MOVE WS-I TO TQ-AGE
         CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
         MOVE WS-I TO WS-DX
         MOVE SPACES TO WS-CASE
         STRING "acceptance US11 43§2 Block tint sources: stem age " WS-DX
             DELIMITED BY SIZE INTO WS-CASE
         MOVE SPACES TO WS-EXPECT
         STRING "FF" WS-STEM-ROW(WS-I + 1) DELIMITED BY SIZE INTO WS-EXPECT
         CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
     END-PERFORM
     MOVE "attached_pumpkin_stem" TO TQ-NAME
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§2 Block tint sources: V5 attached stem" TO WS-CASE
     MOVE "FFE0C71C" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   2.4 and V10: the break particle of a grass block is 0.6 grey; V11 the water one 0.6 x channel.
     MOVE "grass_block" TO TQ-NAME
     CALL "TINT-PARTICLE-RGB" USING CLIENT-STATE TINT-QUERY WS-R WS-G WS-B
     COMPUTE WS-EDIT ROUNDED = WS-R
     MOVE "acceptance US11 43§2 Block tint sources: V10 grass block particle red 0.600"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.600" TO TL-EXPECTED
     MOVE WS-EDIT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-EDIT ROUNDED = WS-B
     MOVE "acceptance US11 43§2 Block tint sources: V10 grass block particle blue 0.600"
         TO TL-CASE
     MOVE WS-EDIT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stone" TO TQ-NAME
     CALL "TINT-PARTICLE-RGB" USING CLIENT-STATE TINT-QUERY WS-R WS-G WS-B
     COMPUTE WS-EDIT ROUNDED = WS-G
     MOVE "acceptance US11 43§2 Block tint sources: block without source particle is 0.600"
         TO TL-CASE
     MOVE WS-EDIT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "lily_pad" TO TQ-NAME
     CALL "TINT-PARTICLE-RGB" USING CLIENT-STATE TINT-QUERY WS-R WS-G WS-B
     COMPUTE WS-EDIT ROUNDED = WS-R
     MOVE "acceptance US11 43§2 Block tint sources: lily pad particle red 0.6 x 32 / 255"
         TO TL-CASE
     MOVE "0.075" TO TL-EXPECTED
     MOVE WS-EDIT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-KIND.
     MOVE WS-NAME TO TQ-NAME
     MOVE TQ-INDEX TO WS-DN
     CALL "TINT-BLOCK-SOURCE" USING WS-NAME TQ-INDEX WS-KIND WS-C1 WS-C2
     MOVE SPACES TO TL-CASE
     STRING "acceptance US11 43§2 Block tint sources: " FUNCTION TRIM(WS-NAME) " index " WS-DN
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TINT-43-2.
 COPY TINTTEST.
