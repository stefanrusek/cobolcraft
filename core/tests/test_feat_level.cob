*> Test of the world-generation level of the feature stage (core/src/feat-level.cob; docs/protocol/35-worldgen-features-1 section 4): reads and writes of a
*> chunk column, the discard of a write outside it, the void air above and below the build height, the heightmaps of section 4.2 over a column with stone,
*> water and leaves (OCEAN_FLOOR, WORLD_SURFACE, MOTION_BLOCKING, MOTION_BLOCKING_NO_LEAVES), an empty column and a column outside the chunk (min y), the biome of
*> a cell, and the block classes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 01 WS-PTR                 USAGE POINTER.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE 8 TO CB-STATE-COUNT
     MOVE 5 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 1 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 0 TO CB-SOLID(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 0 TO CB-SOLID(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 0 TO CB-SOLID(4)
     MOVE "minecraft:oak_leaves" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE 0 TO CB-SOLID(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE 0 TO CB-SOLID(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     MOVE 2 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE "minecraft:desert" TO CBI-KEY(2)
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 1 TO CE-BIOME(1)
     CALL "FL-OPEN" USING WS-PTR BY CONTENT 2 BY CONTENT -1 BY CONTENT -64 BY CONTENT 384 BY CONTENT 63

*>   a column at local (1, 6) of chunk (2, -1): x = 33, z = -10: stone -64 to 60, water 61 to 63, leaves 75
     MOVE 33 TO WS-X
     MOVE -10 TO WS-Z
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 60
         MOVE 1 TO WS-STATE
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     PERFORM VARYING WS-Y FROM 61 BY 1 UNTIL WS-Y > 63
         MOVE 2 TO WS-STATE
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     MOVE 75 TO WS-Y
     MOVE 4 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "acceptance feature level: a write inside the chunk is accepted" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-Y
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance feature level: the state written is read back" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance feature level: the writes are counted" TO TL-CASE
     MOVE FL-WRITES TO TL-OBSERVED-N
     MOVE 129 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 48 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "acceptance feature level: a write outside the chunk's column is refused and counted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OK * 10 + FL-DISCARDED
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance feature level: a read outside the chunk's column gives air" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 33 TO WS-X
     MOVE 320 TO WS-Y
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance feature level: a read above the build height gives void_air (state 6)" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "acceptance feature level: a write above the build height is accepted and discarded silently" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OK * 10 + FL-WRITES - 129
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-ORD FROM 1 BY 1 UNTIL WS-ORD > 6
         CONTINUE
     END-PERFORM
     MOVE 33 TO WS-X
     MOVE 1 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: WORLD_SURFACE is above the highest non-air block (leaves at 75)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 76 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: OCEAN_FLOOR counts leaves but not water (leaves at 75)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 76 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 75 TO WS-Y
     MOVE 0 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: OCEAN_FLOOR ignores the water over the stone (stone to 60)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 61 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: MOTION_BLOCKING counts water (water to 63)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 75 TO WS-Y
     MOVE 4 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 5 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: MOTION_BLOCKING_NO_LEAVES skips the leaves (water to 63)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: MOTION_BLOCKING counts leaves (76)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 76 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 34 TO WS-X
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: an empty column has height min y" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-X
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: a column outside the chunk has height min y" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE -64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 32 TO WS-X
     MOVE -16 TO WS-Z
     MOVE -64 TO WS-Y
     CALL "FL-BIOME-AT" USING WS-X WS-Y WS-Z WS-BIOME
     MOVE "T" TO TL-MODE
     MOVE "acceptance feature level: the biome of the first cell is its table key" TO TL-CASE
     MOVE "minecraft:desert" TO TL-EXPECTED
     MOVE WS-BIOME TO TL-OBSERVED
     MOVE WS-BIOME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         CALL "FL-CLASS" USING WS-I WS-CLASS
         MOVE "acceptance feature level: block class of the state" TO TL-CASE
         EVALUATE WS-I
             WHEN 0
             WHEN 5
             WHEN 6
                 MOVE 1 TO TL-EXPECTED-N
             WHEN 2
                 MOVE 2 TO TL-EXPECTED-N
             WHEN 3
                 MOVE 3 TO TL-EXPECTED-N
             WHEN 7
                 MOVE 4 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-CLASS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the class of a state no block owns, the biome of positions outside the chunk (clamped to its cells), a column of plain stone for the no-leaves map
     MOVE 99 TO WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE "acceptance feature level: a state that no block owns has class 0" TO TL-CASE
     MOVE WS-CLASS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-X
     MOVE -100 TO WS-Z
     MOVE -200 TO WS-Y
     CALL "FL-BIOME-AT" USING WS-X WS-Y WS-Z WS-BIOME
     MOVE "T" TO TL-MODE
     MOVE "acceptance feature level: a biome query left of the chunk, below the world, clamps to the first cell" TO TL-CASE
     MOVE "minecraft:desert" TO TL-EXPECTED
     MOVE WS-BIOME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO WS-X
     MOVE 500 TO WS-Z
     MOVE 900 TO WS-Y
     CALL "FL-BIOME-AT" USING WS-X WS-Y WS-Z WS-BIOME
     MOVE "acceptance feature level: a biome query right of the chunk, above the world, clamps to the last cell (plains, id 0)" TO TL-CASE
     MOVE "minecraft:plains" TO TL-EXPECTED
     MOVE WS-BIOME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 35 TO WS-X
     MOVE -10 TO WS-Z
     MOVE 1 TO WS-STATE
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 10
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     MOVE 5 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "acceptance feature level: MOTION_BLOCKING_NO_LEAVES counts plain stone (stone to 10)" TO TL-CASE
     MOVE WS-H TO TL-OBSERVED-N
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FL-CLOSE"
     FREE WS-PTR
     GOBACK.
