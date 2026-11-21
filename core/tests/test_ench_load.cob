*> Test of the enchantment definitions parsed from the loaded enchantment registry rows (docs/protocol/28 sections 3 to 7, 17 section 6.3;
*> core/src/ench-load.cob ENCH-FOLD): the JSON of a row becomes the prefix expressions of the evaluator (ench-4, ench-5) and the requirement
*> terms are evaluated against a context. Fixture rows: core/tests/fixtures/wire-registry (efficiency 0, knockback 1, protection 2,
*> sharpness 3, smite 4, sweeping_edge 5, unbreaking 6). Values are ten-thousandths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENCH-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CONTENT.
 COPY ENCHCTX.
 COPY JSONDOC.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/wire-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "entity_type".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:sensitive_to_smite".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 2 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-COMPONENT           PIC X(48).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FOLD-STATUS         BINARY-LONG.
 01 WS-FIRST              BINARY-LONG.
 01 WS-JSON                PIC X(700).
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-OUT                 PIC X(200).
 01 WS-POINTER             BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-EFFECT-STATUS       BINARY-LONG.
 01 WS-REQ-RESULT          BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-STATUS
     MOVE 77 TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE 0 TO WS-START
     MOVE 1 TO EC-DIRECT
     MOVE "player_attack" TO EC-DAMAGE-KEY
     MOVE -1 TO EC-VICTIM-ID
     MOVE "player" TO EC-VICTIM-KEY

     MOVE "acceptance US14 sharpness 1 parsed from its registry row adds 1.0 to a direct hit" TO TL-CASE
     MOVE 3 TO WS-ID
     MOVE "minecraft:damage" TO WS-COMPONENT
     MOVE 1 TO WS-LEVEL
     PERFORM FOLD
     MOVE "10000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 sharpness 3 adds 1 + 0.5 x 2 = 2.0" TO TL-CASE
     MOVE 3 TO WS-LEVEL
     PERFORM FOLD
     MOVE "20000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 sharpness requirement is_direct false: an indirect hit gets nothing" TO TL-CASE
     MOVE 0 TO EC-DIRECT
     PERFORM FOLD
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE 1 TO EC-DIRECT

     MOVE "acceptance US14 smite 2 adds 2.5 + 2.5 = 5.0 against a victim type of the sensitive_to_smite tag" TO TL-CASE
     MOVE 4 TO WS-ID
     MOVE 2 TO WS-LEVEL
     MOVE 77 TO EC-VICTIM-ID
     PERFORM FOLD
     MOVE "50000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 smite 2 adds nothing against a victim type outside the tag" TO TL-CASE
     MOVE 78 TO EC-VICTIM-ID
     PERFORM FOLD
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 protection 4 gives 4.0 protection points to player_attack, 0 to out_of_world (bypasses_invulnerability)" TO TL-CASE
     MOVE 2 TO WS-ID
     MOVE 4 TO WS-LEVEL
     MOVE "minecraft:damage_protection" TO WS-COMPONENT
     PERFORM FOLD
     MOVE WS-RESULT TO WS-FIRST
     MOVE "out_of_world" TO EC-DAMAGE-KEY
     PERFORM FOLD
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FIRST TO WS-E2
     STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "40000 0" TO TL-EXPECTED
     MOVE "player_attack" TO EC-DAMAGE-KEY
     PERFORM CHECK-OBSERVED

     MOVE "acceptance US14 knockback 2 adds 2.0 to the knockback component" TO TL-CASE
     MOVE 1 TO WS-ID
     MOVE 2 TO WS-LEVEL
     MOVE "minecraft:knockback" TO WS-COMPONENT
     PERFORM FOLD
     MOVE "20000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a component the enchantment does not define leaves the value unchanged" TO TL-CASE
     MOVE "minecraft:damage" TO WS-COMPONENT
     MOVE 5000 TO WS-START
     PERFORM FOLD
     MOVE "5000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value number becomes its prefix expression" TO TL-CASE
     MOVE '2.5' TO WS-JSON
     MOVE "2.500000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value string (not an object) becomes its prefix expression" TO TL-CASE
     MOVE '"x"' TO WS-JSON
     MOVE SPACES TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value levels_squared becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:levels_squared","added":1.0}' TO WS-JSON
     MOVE "squared 1.000000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value constant becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:constant","value":3.0}' TO WS-JSON
     MOVE "3.000000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value lookup becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:lookup","values":[1.0,2.0],"fallback":{"type":"minecraft:linear","base":1.0,"per_level_above_first":0.5}}' TO WS-JSON
     MOVE "lookup 2 1.000000 2.000000 linear 1.000000 0.500000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value fraction becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:fraction","numerator":1.0,"denominator":2.0}' TO WS-JSON
     MOVE "fraction 1.000000 2.000000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value clamped becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:clamped","min":0.0,"max":5.0,"value":{"type":"minecraft:linear","base":1.0,"per_level_above_first":1.0}}' TO WS-JSON
     MOVE "clamped 0.000000 5.000000 linear 1.000000 1.000000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 level-based value exponent becomes its prefix expression" TO TL-CASE
     MOVE '{"type":"minecraft:exponent","base":2.0,"power":3.0}' TO WS-JSON
     MOVE "exponent 2.000000 3.000000" TO TL-EXPECTED
     PERFORM RUN-LBV
     PERFORM CHECK-DONE
     MOVE "acceptance US14 effect multiply becomes its prefix text" TO TL-CASE
     MOVE '{"type":"minecraft:multiply","value":2.0}' TO WS-JSON
     PERFORM RUN-EFFECT
     MOVE "multiply 2.000000 status 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 effect set becomes its prefix text" TO TL-CASE
     MOVE '{"type":"minecraft:set","value":1.0}' TO WS-JSON
     PERFORM RUN-EFFECT
     MOVE "set 1.000000 status 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 effect exponential becomes its prefix text" TO TL-CASE
     MOVE '{"type":"minecraft:exponential","base":2.0,"power":3.0}' TO WS-JSON
     PERFORM RUN-EFFECT
     MOVE "exponential 2.000000 3.000000 status 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 effect all_of becomes its prefix text" TO TL-CASE
     MOVE '{"type":"minecraft:all_of","effects":[{"type":"minecraft:add","value":1.0},{"type":"minecraft:set","value":2.0}]}' TO WS-JSON
     PERFORM RUN-EFFECT
     MOVE "all_of add 1.000000 set 2.000000 status 0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 effect remove_binomial (no word in the evaluator) becomes its prefix text" TO TL-CASE
     MOVE '{"type":"minecraft:remove_binomial","chance":0.5}' TO WS-JSON
     PERFORM RUN-EFFECT
     MOVE " status 3" TO TL-EXPECTED
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement any_of with one matching term holds" TO TL-CASE
     MOVE '{"condition":"minecraft:any_of","terms":[{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":false}},{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":true}}]}' TO WS-JSON
     MOVE "1" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement any_of without a matching term fails" TO TL-CASE
     MOVE '{"condition":"minecraft:any_of","terms":[{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":false}},{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":false}}]}' TO WS-JSON
     MOVE "0" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement all_of with a failing term fails" TO TL-CASE
     MOVE '{"condition":"minecraft:all_of","terms":[{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":true}},{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":false}}]}' TO WS-JSON
     MOVE "0" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement inverted of a failing term holds" TO TL-CASE
     MOVE '{"condition":"minecraft:inverted","term":{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":false}}}' TO WS-JSON
     MOVE "1" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement inverted of a holding term fails" TO TL-CASE
     MOVE '{"condition":"minecraft:inverted","term":{"condition":"minecraft:damage_source_properties","predicate":{"is_direct":true}}}' TO WS-JSON
     MOVE "0" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement a source_entity predicate is undecided and does not apply" TO TL-CASE
     MOVE '{"condition":"minecraft:damage_source_properties","predicate":{"source_entity":{}}}' TO WS-JSON
     MOVE "0" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement a direct_entity predicate is undecided and does not apply" TO TL-CASE
     MOVE '{"condition":"minecraft:damage_source_properties","predicate":{"direct_entity":{}}}' TO WS-JSON
     MOVE "0" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement a damage tag without namespace expected true holds for player_attack" TO TL-CASE
     MOVE '{"condition":"minecraft:damage_source_properties","predicate":{"tags":[{"id":"is_player_attack","expected":true}]}}' TO WS-JSON
     MOVE "1" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE
     MOVE "acceptance US14 requirement an entity type key matches the victim key" TO TL-CASE
     MOVE '{"condition":"minecraft:entity_properties","entity":"this","predicate":{"type":"minecraft:zombie"}}' TO WS-JSON
     MOVE "1" TO TL-EXPECTED
     PERFORM RUN-REQ
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a row without effects leaves the value unchanged" TO TL-CASE
     MOVE 7 TO WS-ID
     MOVE "minecraft:damage" TO WS-COMPONENT
     MOVE 3 TO WS-LEVEL
     MOVE 5000 TO WS-START
     PERFORM FOLD
     MOVE "5000 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 an id outside the registry is status 4 and leaves the value unchanged" TO TL-CASE
     MOVE 99 TO WS-ID
     PERFORM FOLD
     MOVE "5000 4" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a node 0 has no text and no effect" TO TL-CASE
     MOVE 0 TO WS-NODE
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-POINTER
     CALL "ENCH-LBV-TEXT" USING JSON-DOC WS-NODE WS-OUT WS-POINTER
     CALL "ENCH-EFFECT-TEXT" USING JSON-DOC WS-NODE WS-OUT WS-POINTER WS-EFFECT-STATUS
     MOVE WS-EFFECT-STATUS TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "3" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 PARSE-JSON.
     COMPUTE WS-JSON-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-JSON TRAILING))
     CALL "JSON-PARSE" USING JSON-DOC WS-JSON WS-JSON-LENGTH
     MOVE 1 TO WS-NODE
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-POINTER.

 RUN-LBV.
     PERFORM PARSE-JSON
     CALL "ENCH-LBV-TEXT" USING JSON-DOC WS-NODE WS-OUT WS-POINTER
     MOVE WS-OUT TO TL-OBSERVED.

 RUN-EFFECT.
     PERFORM PARSE-JSON
     CALL "ENCH-EFFECT-TEXT" USING JSON-DOC WS-NODE WS-OUT WS-POINTER WS-EFFECT-STATUS
     MOVE WS-EFFECT-STATUS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-OUT) " status " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED.

 RUN-REQ.
     PERFORM PARSE-JSON
     MOVE "zombie" TO EC-VICTIM-KEY
     CALL "ENCH-REQ-EVAL" USING JSON-DOC WS-NODE ENCH-CTX WS-REQ-RESULT
     MOVE WS-REQ-RESULT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED.

 FOLD.
     CALL "ENCH-FOLD" USING WS-ID WS-COMPONENT WS-LEVEL ENCH-CTX WS-START WS-RESULT WS-FOLD-STATUS
     MOVE WS-RESULT TO WS-E1
     MOVE WS-FOLD-STATUS TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-OBSERVED.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENCH-LOAD.

 COPY CORETEST.
