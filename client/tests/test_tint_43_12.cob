*> Acceptance test of docs/protocol/43-tint-sources.md section 12 (reconciliation with earlier
*> documents): each row of the table is checked against the implementation: 24-1 §9.1 filled cells
*> (in-hand colours, terrain particle defaults), 24-1 §9.2 blend radius (default, presets), 14 §9
*> lookup, 14 Open question 7 (the grass block icon uses the grass source at 0.5 and 1.0), 08 §6.4
*> the seven tint source type names, 12 §3.1 attribute defaults, 12 Open question 8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY CLTINTQ.
 COPY CLTINTI.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-NAME                PIC X(32).
 01 WS-LAYER               BINARY-LONG VALUE 0.
 01 WS-DYED                BINARY-LONG VALUE 0.
 01 WS-MODE                BINARY-LONG.
 01 WS-HAND                BINARY-DOUBLE.
 01 WS-WORLD               BINARY-DOUBLE.
 01 WS-PARTICLE            BINARY-DOUBLE.
 01 WS-PRESET              BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ATTR                PIC X(64).
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES               PIC X(224) VALUE
     "constant                      dye                           grass                         "
     & "firework                      potion                        team                          "
     & "custom_model_data           ".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-TYPE-NAME        PIC X(30) OCCURS 7 TIMES.
 01 WS-LOOKUP              PIC X(32).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
*>   24-1 §9.1: the terrain particle colour defaults to the in-world colour (constant sources,
*>   redstone and stem give the same colour in the three modes).
     MOVE "lily_pad" TO TQ-NAME
     MOVE 0 TO TQ-INDEX TQ-POWER TQ-AGE TQ-X TQ-Y TQ-Z TQ-RADIUS TQ-HALF
     MOVE 1 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-WORLD
     MOVE 2 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: particle defaults to world"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WORLD TO TL-EXPECTED-N
     MOVE TQ-COLOUR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "melon_stem" TO TQ-NAME
     MOVE 5 TO TQ-AGE
     MOVE 1 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE TQ-COLOUR TO WS-WORLD
     MOVE 2 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: stem particle equals world"
         TO TL-CASE
     MOVE WS-WORLD TO TL-EXPECTED-N
     MOVE TQ-COLOUR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   24-1 §9.1: the two exceptions, grassBlock (white particle) and waterParticles (white in
*>   world, the water colour as particle, here the biome table's plains).
     MOVE "grass_block" TO TQ-NAME
     MOVE 2 TO TQ-MODE
     CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: grassBlock particle is white"
         TO WS-CASE
     MOVE "FFFFFFFF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT TQ-COLOUR
*>   24-1 §9.2: the blend radius is an option 0..7 (default 2); presets fast 1, fancy 2, fabulous 2.
     MOVE 0 TO WS-PRESET
     CALL "TINT-RADIUS-PRESET" USING WS-PRESET WS-RADIUS
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: fast preset radius 1"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RADIUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-PRESET
     CALL "TINT-RADIUS-PRESET" USING WS-PRESET WS-RADIUS
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: fancy preset radius 2"
         TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-RADIUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-PRESET
     CALL "TINT-RADIUS-PRESET" USING WS-PRESET WS-RADIUS
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: fabulous preset radius 2"
         TO TL-CASE
     MOVE WS-RADIUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-PRESET
     CALL "TINT-RADIUS-PRESET" USING WS-PRESET WS-RADIUS
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: no preset gives the default 2"
         TO TL-CASE
     MOVE WS-RADIUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   14 Open question 7: the grass block item uses the grass source at temperature 0.5, downfall 1.0.
     MOVE "grass_block" TO WS-NAME
     CALL "TINT-ITEM-SOURCE" USING WS-NAME WS-DYED WS-LAYER TINT-ITEM
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: grass block icon source"
         TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE TI-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: grass block icon climate"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.5 1.0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF TI-TEMP = 0.5 AND TI-DOWN = 1.0
         MOVE "0.5 1.0" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   08 §6.4: the seven item tint source type names.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-LOOKUP
         MOVE WS-TYPE-NAME(WS-I) TO WS-LOOKUP
         CALL "TINT-ITEM-TYPE" USING WS-LOOKUP WS-TYPE
         MOVE "acceptance US11 43§12 Reconciliation with earlier documents: tint source type name"
             TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-I TO TL-EXPECTED-N
         MOVE WS-TYPE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "minecraft:dye" TO WS-LOOKUP
     CALL "TINT-ITEM-TYPE" USING WS-LOOKUP WS-TYPE
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: namespaced type name"
         TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mixed" TO WS-LOOKUP
     CALL "TINT-ITEM-TYPE" USING WS-LOOKUP WS-TYPE
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: unknown type name"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   12 §3.1: attribute defaults agree (section 5).
     MOVE "minecraft:visual/water_fog_color" TO WS-ATTR
     CALL "TINT-ATTRIBUTE-DEFAULT" USING WS-ATTR WS-COLOUR
     MOVE "acceptance US11 43§12 Reconciliation with earlier documents: water fog default"
         TO WS-CASE
     MOVE "FF050533" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     STOP RUN.
 END PROGRAM TEST-TINT-43-12.
 COPY TINTTEST.
