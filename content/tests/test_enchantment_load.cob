*> Test of the enchantment and damage type loader (T0285; docs/protocol/28-enchantment-effects.md sections 2 and 13, 04 section 6
*> enchantment and damage_type, 17 sections 4.12 and 6.1, 23 section 2.1 rows 34 and 37). ENCHANTMENTS-LOAD USING root (PIC X(1100):
*> the folder that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load
*> staying): the files of data/<namespace>/enchantment/ and data/<namespace>/damage_type/ are checked through the shape engine
*> (shapes.cob) against the field lists of 04 and 28 section 13 (weight 1 to 1024, max_level 1 to 255, cost objects, anvil_cost >= 0,
*> slot groups of 28 section 7.4, effect component keys of 28 section 2.2; damage type scaling, effects and death_message_type
*> enums, exhaustion a number). The registries of the fixture tree content/tests/fixtures/load-28 (5 enchantments, 4 damage types);
*> each reject case copies a file of content/tests/fixtures/load-28-bad into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENCHANTMENT-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-T                   PIC X(50).
 01 WS-PATH                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC 99.
 01 WS-CASES.
    05 FILLER PIC X(50) VALUE "an enchantment of weight 0".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment of weight 2000".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment of max_level 0".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment of max_level 256".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment without supported_items".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment without description".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose min_cost is a number".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose max_cost has no base".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment of anvil_cost -1".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose slots is a string".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment of slot group knee".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose exclusive_set is a number".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose primary_items is a number".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment whose effects is an array".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an effect component of no known type".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment without weight".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type without message_id".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type without scaling".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type without exhaustion".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type of scaling sometimes".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type whose exhaustion is a string".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type of effects glowing".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type of death_message_type weird".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "a damage type whose message_id is a number".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment file that is not JSON".
    05 FILLER PIC X(48) VALUE "enchantment/bad.json".
    05 FILLER PIC X(50) VALUE "an enchantment file with a bad identifier".
    05 FILLER PIC X(48) VALUE "enchantment/Bad.json".
    05 FILLER PIC X(50) VALUE "a damage type file that is an array".
    05 FILLER PIC X(48) VALUE "damage_type/bad.json".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 27 TIMES.
       10 WS-CASE-LABEL    PIC X(50).
       10 WS-CASE-PATH     PIC X(48).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-28" TO WS-DIR
     CALL "ENCHANTMENTS-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US14 enchantments the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US14 enchantments nine elements (5 enchantments, 4 damage types)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "enchantment" TO WS-REGISTRY
     MOVE "minecraft:sharpness" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments sharpness is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:quick_charge" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments quick_charge (two slot groups) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:binding_curse" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments binding_curse (unit effect) is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "damage_type" TO WS-REGISTRY
     MOVE "minecraft:fall" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments damage type fall is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:in_fire" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments damage type in_fire is there" TO TL-CASE
     PERFORM ASSERT-FOUND
     MOVE "minecraft:absent" TO WS-KEY
     PERFORM FIND-ELEMENT
     MOVE "acceptance US14 enchantments an absent damage type is not there" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-28/t" TO WS-DIR
     MOVE WS-I TO WS-N-TEXT
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-28 2>/dev/null; rm -rf build/content-test/load-28; "
         "mkdir -p build/content-test/load-28 && cp -R content/tests/fixtures/load-28 build/content-test/load-28/t && "
         "cp content/tests/fixtures/load-28-bad/" WS-N-TEXT ".json build/content-test/load-28/t/data/minecraft/"
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "ENCHANTMENTS-LOAD" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US14 enchantments " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US14 enchantments after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 FIND-ELEMENT.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW.

 ASSERT-FOUND.
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
