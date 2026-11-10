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
     STOP RUN.

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
