*> Implementation test of the End's seam to the dimension plumbing (core/src/end-dim.cob; docs/protocol/38-end.md sections 2, 8 and 12; T1735 to T1744): an open standard
*> world with the real End (ND-PLACEHOLDER 0) generates the End chunks from END-GEN-CHUNK and END-GEN-FEATURES: the central island has end stone round (0, 0), the platform
*> of chunk (6, 0) stands at y 48, the pillar of spike 0 in chunk (2, 0) asks for an end_crystal entity that the chunk load spawns in the End, the biome of the central
*> chunks is the_end; with ND-PLACEHOLDER 1 the placeholder island is kept. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-DIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY CELLS.
 COPY END.
 COPY ENDSPIKE.
 COPY CONTENT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-CRYSTAL             BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-THE-END             BINARY-LONG.
 01 WS-NAME                PIC X(40) VALUE "minecraft:the_end".
 01 WS-I                   BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 38§2 End dimension seam: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "obsidian" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-OBSIDIAN
     MOVE "end_stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE
     CALL "SURFACE-BIOME-ID" USING WS-NAME WS-THE-END

     CALL "END-DIM-READY" USING WS-READY
     MOVE "acceptance US12 38§2 End seam: the placeholder switch (ND-PLACEHOLDER 1) keeps the placeholder island" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-READY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The placeholder keeps the single biome the_end for every chunk.
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "WORLDGEN-DIM-BIOMES" USING DIM-STANDARD-END WS-CX WS-CZ WS-BIOMES
     MOVE "acceptance US12 38§2 End seam: the placeholder's biome of a far chunk is the_end in every column" TO TL-CASE
     MOVE 1 TO WS-ALL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-BIOME(WS-I) NOT = WS-THE-END
             MOVE 0 TO WS-ALL
         END-IF
     END-PERFORM
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ALL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO ND-PLACEHOLDER
*>   a fixed level seed: the generated terrain is then the same on every run
     MOVE 12345 TO CW-SEED
     CALL "END-DIM-READY" USING WS-READY
     MOVE "acceptance US12 38§2 End seam: with the real End on and the tables complete the generator is ready" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-READY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "end_crystal" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-CRYSTAL WS-ROW-TEXT WS-STATUS

*>   Chunk (0, 0): the central island.
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING DIM-STANDARD-END WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-X WS-Z
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
         CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = WS-STONE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 38§12 End seam: a standard world's End chunk (0, 0) has the central island (end stone in the column at 0, 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 38§2 End seam: the biome of a central chunk is the_end in every column" TO TL-CASE
     CALL "WORLDGEN-DIM-BIOMES" USING DIM-STANDARD-END WS-CX WS-CZ WS-BIOMES
     MOVE 1 TO WS-ALL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-BIOME(WS-I) NOT = WS-THE-END
             MOVE 0 TO WS-ALL
         END-IF
     END-PERFORM
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ALL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Chunk (6, 0): the platform at (100, 48, 0).
     MOVE 6 TO WS-CX
     CALL "WORLD-CHUNK" USING DIM-STANDARD-END WS-CX WS-CZ WS-ROW
     MOVE 100 TO WS-X
     MOVE 48 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 38§8 End seam: chunk (6, 0) holds the obsidian platform at (100, 48, 0)" TO TL-CASE
     MOVE WS-OBSIDIAN TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Chunk (2, 0): the pillar of spike 0 asks for a crystal.
     MOVE 2 TO WS-CX
     CALL "WORLD-CHUNK" USING DIM-STANDARD-END WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-CRYSTAL AND EN-DIM(WS-I) = DIM-STANDARD-END
                 AND EN-X(WS-I) = 42.5 AND EN-Z(WS-I) = 0.5
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 38§8 End seam: the pillar of chunk (2, 0) spawned one end_crystal entity at (42.5, 0.5) in the End" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A set without the end_crystal entity type spawns nothing.
     MOVE 1 TO EC-COUNT
     MOVE 5 TO EC-X(1)
     MOVE 70 TO EC-Y(1)
     MOVE 5 TO EC-Z(1)
     MOVE 0 TO EC-YAW(1)
     MOVE 0 TO CT-OPEN
     CALL "END-CRYSTAL-SPAWN" USING DIM-STANDARD-END CRYSTAL-LIST
     MOVE 1 TO CT-OPEN
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-CRYSTAL AND EN-X(WS-I) = 5.5
             ADD 1 TO WS-A
         END-IF
     END-PERFORM
     MOVE "acceptance US12 38§8 End seam: a content set without end_crystal gets no crystal entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-END-DIM.

 COPY CORETEST.
 COPY PORTALTEST.
