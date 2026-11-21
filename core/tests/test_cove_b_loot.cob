*> Coverage test, group B (loot conditions, core/src/loot-condition.cob): the entity predicate member minecraft:type_specific/sheep is tested on this_entity through LOOT-PREDICATE from the
*> fixture tree core/tests/fixtures/cove_b_loot: a sheep that is not sheared holds {sheared: false}; the same predicate does not hold for an entity that is no sheep (whatever its sheared flag
*> says); a member of the sheep predicate other than sheared is not evaluated, so the predicate does not hold either.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-B-LOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY LOOTCTX.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/cove_b_loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-RESULT              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "test cove b loot: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-THIS-SET
     MOVE "cobolcraft:sodgrazer" TO LC-THIS-TYPE
     MOVE 1 TO LC-THIS-SHEEP
     MOVE 0 TO LC-THIS-SHEARED
     MOVE "test:c_sheep_sheared" TO WS-KEY
     CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-FOUND
     MOVE "test cove b loot: a sheep that is not sheared holds sheared false" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO LC-THIS-SHEEP
     CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-FOUND
     MOVE "test cove b loot: an entity that is no sheep never holds a sheep predicate" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO LC-THIS-SHEEP
     MOVE "test:c_sheep_other_key" TO WS-KEY
     CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-FOUND
     MOVE "test cove b loot: a member of the sheep predicate other than sheared is not evaluated, the predicate fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-COVE-B-LOOT.
 COPY CORETEST.
