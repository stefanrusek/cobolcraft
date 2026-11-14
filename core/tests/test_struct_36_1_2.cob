*> Acceptance test of docs/protocol/36-structures-1 section 2 (registries and id assignment): the 16 structure types, 3 placement types and
*> 56 structure piece types with their registration-order ids (the tables of 2.2 to 2.4), the lower-casing and the four renames of a stored
*> piece id (6.7), the five enums of 2.5, and the ids a loaded fixture's structures take.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-COUNT               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 16 structure types" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 16 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 3 placement types" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 56 structure piece types" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 56 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 5 terrain adjustments" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 2 spawn override box types" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 2 spread types" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 4 frequency reduction methods" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US12 36-1§2 Registries and id assignment: 11 decoration steps" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-KIND
     MOVE "buried_treasure" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: structure type buried_treasure is 0" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:jigsaw" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: structure type minecraft:jigsaw is 5 (the namespace is optional)" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "woodland_mansion" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: structure type woodland_mansion is 15" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 15 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "castle" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: an unknown structure type is -1" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     MOVE "concentric_rings" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: placement concentric_rings is 0" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:random_spread" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: placement random_spread is 2" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-KIND
     MOVE "minecraft:mscorridor" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: piece mscorridor is 0" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:MSCorridor" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: a stored piece id is lower-cased on read (MSCorridor loads as 0)" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nefos" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: piece nefos is 54" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 54 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:jigsaw" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: piece jigsaw is 55" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 55 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > 4
         EVALUATE WS-ID
             WHEN 1 MOVE "minecraft:nvi" TO WS-NAME
             WHEN 2 MOVE "minecraft:pcp" TO WS-NAME
             WHEN 3 MOVE "minecraft:bastionremnant" TO WS-NAME
             WHEN 4 MOVE "minecraft:runtime" TO WS-NAME
         END-EVALUATE
         MOVE 3 TO WS-KIND
         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-STATUS
         IF WS-STATUS = 55
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-1§2 Registries and id assignment: nvi, pcp, bastionremnant and runtime all load as the jigsaw piece" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:unknownpiece" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: an unknown piece id is -1 (the piece is skipped on load)" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-KIND
     MOVE "beard_box" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: terrain adjustment beard_box is 3" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-KIND
     MOVE "full" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: bounding box type full is 1" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-KIND
     MOVE "triangular" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: spread type triangular is 1" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-KIND
     MOVE "legacy_type_3" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: frequency reduction method legacy_type_3 is 3" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-KIND
     MOVE "top_layer_modification" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: decoration step top_layer_modification is 10" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "surface_structures" TO WS-NAME
     PERFORM ID-OF
     MOVE "acceptance US12 36-1§2 Registries and id assignment: decoration step surface_structures is 4" TO TL-CASE
     MOVE WS-ID TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3 TO WS-KIND
     MOVE 29 TO WS-ID
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-1§2 Registries and id assignment: piece 29 is shstart" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "shstart" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KIND
     MOVE 8 TO WS-ID
     CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
     MOVE "acceptance US12 36-1§2 Registries and id assignment: structure type 8 is nether_fossil" TO TL-CASE
     MOVE WS-NAME TO TL-OBSERVED
     MOVE "nether_fossil" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "N" TO TL-MODE
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 36-1§2 Registries and id assignment: the fixture structures take type 5, 4, 14 and 13 (jigsaw, igloo, swamp_hut, stronghold)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SDT-TYPE(1) * 1000000 + SDT-TYPE(2) * 10000 + SDT-TYPE(3) * 100 + SDT-TYPE(4)
     MOVE 5041413 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-KIND.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 99
         CALL "STRUCT-ENUM-NAME" USING WS-KIND WS-ID WS-NAME
         IF WS-NAME NOT = SPACES
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 ID-OF.
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-ID.
