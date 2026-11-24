*> Implementation test of the container request of a placed template block (core/src/struct-tpl-place.cob STRUCT-PLACE-BE; docs/protocol/36-structures-2 section 5.3 step 7, 36-1 6.5): the
*> worldgen block-entity channel keeps loot keys of 48 bytes (GENBE.cpy), so a key of the minecraft namespace that is longer (the trial chambers' barrel, "minecraft:chests/trial_chambers/
*> intersection_barrel", 51 bytes) travels without its namespace (41 bytes; GBE-APPLY gives it back, test_gen_be); a key of another namespace that does not fit is not requested, and every
*> container still draws its LootTableSeed (one nextLong of the piece random).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-BE-LONGKEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTTPL.
 COPY STRUCTPIECE.
 COPY GENBE.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 6.
 01 WS-Z                   BINARY-LONG VALUE 7.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-TAG                 BINARY-LONG VALUE 2.
 01 WS-LO                  BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO GBL-COUNT GBL-LOST
     MOVE 12345678901 TO SP-XR-LO
     MOVE 98765432109 TO SP-XR-HI
     MOVE 1 TO TN-KIND(2)
     MOVE "minecraft:chests/trial_chambers/intersection_barrel" TO TN-LOOT(2)
     MOVE SP-XR-LO TO WS-LO
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "test struct be longkey: the 51 byte barrel key is requested without its namespace" TO TL-CASE
     MOVE "chests/trial_chambers/intersection_barrel" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF GBL-COUNT = 1
         MOVE FUNCTION TRIM(GBL-LOOT(1)) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test struct be longkey: the request is of kind 1 (a container) at the block" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GBL-KIND(1) * 1000 + GBL-X(1) * 100 + GBL-Y(1) * 10 + GBL-Z(1)
     MOVE 1567 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct be longkey: the container drew its seed from the piece random" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-XR-LO NOT = WS-LO
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a key that fits keeps its namespace
     MOVE "minecraft:chests/underwater_ruin_small" TO TN-LOOT(2)
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "T" TO TL-MODE
     MOVE "test struct be longkey: a key of 48 bytes or less is requested as it is" TO TL-CASE
     MOVE "minecraft:chests/underwater_ruin_small" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF GBL-COUNT = 2
         MOVE FUNCTION TRIM(GBL-LOOT(2)) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a key of another namespace that does not fit is not requested (the limit of the channel), the seed is drawn all the same
     MOVE "mypack:chests/a_very_long_loot_table_path_that_does_not_fit_the_channel" TO TN-LOOT(2)
     MOVE SP-XR-LO TO WS-LO
     CALL "STRUCT-PLACE-BE" USING WS-X WS-Y WS-Z WS-STATE WS-TAG
     MOVE "N" TO TL-MODE
     MOVE "test struct be longkey: a long key of another namespace is not requested" TO TL-CASE
     MOVE GBL-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct be longkey: and its container still drew a seed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-XR-LO NOT = WS-LO
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-BE-LONGKEY.
