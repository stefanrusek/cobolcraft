*> Test of the content source of the feature data (core/src/feat-data.cob FD-FETCH): with a content set open, a placed feature and a feature are read from the registries
*> worldgen/placed_feature and worldgen/feature of the set (core/tests/fixtures/feat-registry), not from a folder.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-CONTENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CONTENT.
 COPY FEATDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:test_flowers".
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 2 TIMES.
 01 WS-COUNT               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 7 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 1 TO CB-SOLID(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE "minecraft:dandelion" TO CB-KEY(4)
     MOVE "minecraft:poppy" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     MOVE 1 TO CB-SOLID(8)
     MOVE "minecraft:lava" TO CB-KEY(9)
     MOVE "minecraft:tall_grass" TO CB-KEY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     CALL "FD-RESET"
     MOVE SPACES TO FD-DIR
     MOVE "minecraft:content_pf" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature content: a placed feature is read from the registry of the open content set" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PF-STATUS(WS-PF) * 10 + PF-MD-COUNT(WS-PF)
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PF-FT(WS-PF) TO WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "acceptance feature content: a feature is read from the registry too (simple_block, 42)" TO TL-CASE
     MOVE FT-TYPE(WS-FT) TO TL-OBSERVED-N
     MOVE 42 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:other_pf" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature content: an id the registry does not hold is unsupported (no folder is set)" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-ID(1)
     MOVE 4 TO WS-ID(2)
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:content_tag" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance feature content: a #tag of a predicate is resolved by the open content set (two flowers)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = PF-STATUS(WS-PF) * 10 + PR-N(MD-PR(PF-MD-FIRST(WS-PF)))
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     GOBACK.
