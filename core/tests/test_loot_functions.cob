*> Test of the loot functions (core/src/loot-function.cob; docs/protocol/26-loot-and-predicates.md section 7, 13.2 T4 to T9, T13, T14): set_count,
*> set_item, limit_count, explosion_decay, enchanted_count_increase, apply_bonus (the three formulas), discard, sequence, filtered,
*> set_enchantments, set_damage and set_name, the condition gate of a function and the functions the engine does not evaluate (left
*> alone), run through LOOT-MODIFIER from the named item modifiers of core/tests/fixtures/loot. Every case starts from a stack (item,
*> count, damage, max_damage and efficiency level of the patch) in a numbered context (the scenarios of SETUP-SCENARIO), prints
*> "item count damage efficiency-level name" of the result and, after it, the next nextInt(1000) of the context's Java LCG, which
*> shows how many random numbers the function consumed. The expected values come from an independent Python implementation
*> (the LCG of 10 2.6, float32 steps with struct) of the formulas of section 7. Enchantment: minecraft:efficiency (id 0, the only
*> enchantment of the cobolcraft content set) stands for looting, fortune and the rest.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-FUNCTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CSTACK.
 COPY LOOTCTX.
 01 WS-CASES.
    05 FILLER PIC X(80) VALUE "m_set_count|0|3|10|1|0|0|0|10 3 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_count_add|0|3|10|2|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_count_uniform|0|7|10|1|0|0|0|10 2 0 0 -|164".
    05 FILLER PIC X(80) VALUE "m_set_count_cond|0|3|10|1|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_count_cond|1|3|10|1|0|0|0|10 7 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_count_ref|0|3|10|1|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_item|0|3|10|4|0|0|0|11 4 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_both|0|3|10|1|0|0|0|10 2 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_both|0|3|10|3|0|0|0|10 3 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_both|0|3|10|9|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_min|0|3|10|1|0|0|0|10 2 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_min|0|3|10|5|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_max|0|3|10|9|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_limit_max|0|3|10|3|0|0|0|10 3 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_decay|0|3|10|4|0|0|0|10 4 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_decay|23|5|10|4|0|0|0|10 2 0 0 -|506".
    05 FILLER PIC X(80) VALUE "m_ench_count|22|5|10|3|0|0|0|10 5 0 0 -|92".
    05 FILLER PIC X(80) VALUE "m_ench_count|0|5|10|3|0|0|0|10 3 0 0 -|487".
    05 FILLER PIC X(80) VALUE "m_ench_count_limit|22|5|10|3|0|0|0|10 4 0 0 -|487".
    05 FILLER PIC X(80) VALUE "m_bonus_ore|0|5|10|1|0|0|0|10 1 0 0 -|487".
    05 FILLER PIC X(80) VALUE "m_bonus_ore|2|5|10|1|0|0|0|10 1 0 0 -|487".
    05 FILLER PIC X(80) VALUE "m_bonus_ore|12|5|10|1|0|0|0|10 2 0 0 -|92".
    05 FILLER PIC X(80) VALUE "m_bonus_ore|11|5|10|1|0|0|0|10 2 0 0 -|92".
    05 FILLER PIC X(80) VALUE "m_bonus_uniform|20|5|10|1|0|0|0|10 3 0 0 -|92".
    05 FILLER PIC X(80) VALUE "m_bonus_binomial|12|9|10|4|0|0|0|10 5 0 0 -|535".
    05 FILLER PIC X(80) VALUE "m_bonus_other|12|9|10|4|0|0|0|10 4 0 0 -|989".
    05 FILLER PIC X(80) VALUE "m_bonus_ore|12|5|10|1|0|0|0|10 2 0 0 -|92".
    05 FILLER PIC X(80) VALUE "m_discard|0|3|10|5|0|0|0|10 0 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_sequence|0|3|10|1|0|0|0|11 2 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_sequence_cond|0|3|10|1|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_sequence_cond|1|3|10|1|0|0|0|10 2 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_sequence_ref|0|3|10|1|0|0|0|10 5 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_filtered|0|3|10|4|0|0|0|10 9 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_filtered|0|3|11|4|0|0|0|11 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_filtered_nopass|0|3|10|4|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_filtered_nopass|0|3|11|4|0|0|0|11 4 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench|0|3|10|1|0|0|0|10 1 0 3 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench|0|3|10|1|0|0|2|10 1 0 3 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench_add|0|3|10|1|0|0|2|10 1 0 5 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench_add|0|3|10|1|0|0|0|10 1 0 3 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench_big|0|3|10|1|0|0|2|10 1 0 255 -|734".
    05 FILLER PIC X(80) VALUE "m_set_ench_unknown|0|3|10|1|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_damage|0|3|10|1|0|100|0|10 1 75 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_damage_add|0|3|10|1|50|100|0|10 1 25 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_damage_add|0|3|10|1|40|100|0|10 1 14 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_damage|0|3|10|1|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_set_name|0|3|10|1|0|0|0|10 1 0 0 Hi|734".
    05 FILLER PIC X(80) VALUE "m_set_name_item|0|3|10|1|0|0|0|10 1 0 0 item:Ore|734".
    05 FILLER PIC X(80) VALUE "m_set_name_other|0|3|10|1|0|0|0|10 1 0 0 -|734".
    05 FILLER PIC X(80) VALUE "m_identity|0|3|10|6|0|0|0|10 6 0 0 -|734".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(80) OCCURS 50 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-SCENARIO            PIC X(4).
 01 WS-SEED                PIC X(12).
 01 WS-ITEM-TEXT           PIC X(6).
 01 WS-COUNT-TEXT          PIC X(6).
 01 WS-DAMAGE-TEXT         PIC X(6).
 01 WS-MAX-TEXT            PIC X(6).
 01 WS-ENCH-TEXT           PIC X(6).
 01 WS-RESULT-TEXT         PIC X(30).
 01 WS-PROBE-TEXT          PIC X(8).
 01 WS-KEY                 PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 01 WS-PROBE               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-TOOL                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME-OUT            PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME-TEXT           PIC X(70).
 01 WS-FOUND2              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-EDIT5               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot function the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TOOL WS-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         MOVE SPACES TO WS-NAME WS-SCENARIO WS-SEED WS-ITEM-TEXT WS-COUNT-TEXT WS-DAMAGE-TEXT WS-MAX-TEXT
             WS-ENCH-TEXT WS-RESULT-TEXT WS-PROBE-TEXT
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-SCENARIO WS-SEED WS-ITEM-TEXT WS-COUNT-TEXT
             WS-DAMAGE-TEXT WS-MAX-TEXT WS-ENCH-TEXT WS-RESULT-TEXT WS-PROBE-TEXT
         INITIALIZE LOOT-CONTEXT
         COMPUTE LC-SEED = FUNCTION NUMVAL(WS-SEED)
         PERFORM SETUP-SCENARIO
         COMPUTE WS-ITEM = FUNCTION NUMVAL(WS-ITEM-TEXT)
         COMPUTE WS-COUNT = FUNCTION NUMVAL(WS-COUNT-TEXT)
         PERFORM BUILD-HANDLE
         MOVE SPACES TO WS-KEY
         STRING "test:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         CALL "LOOT-MODIFIER" USING WS-KEY LOOT-CONTEXT WS-ITEM WS-COUNT WS-HANDLE WS-FOUND
         CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
         PERFORM DESCRIBE-STACK
         MOVE WS-PROBE TO WS-EDIT
         MOVE SPACES TO TL-OBSERVED
         STRING FUNCTION TRIM(WS-NAME-TEXT) "|" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED
         STRING FUNCTION TRIM(WS-RESULT-TEXT) "|" FUNCTION TRIM(WS-PROBE-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE SPACES TO TL-CASE
         STRING "test loot function " FUNCTION TRIM(WS-NAME) " scenario " FUNCTION TRIM(WS-SCENARIO) " item "
             FUNCTION TRIM(WS-ITEM-TEXT) " count " FUNCTION TRIM(WS-COUNT-TEXT) " damage " FUNCTION TRIM(WS-DAMAGE-TEXT)
             " max " FUNCTION TRIM(WS-MAX-TEXT) " ench " FUNCTION TRIM(WS-ENCH-TEXT)
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK
     END-PERFORM
     MOVE "test loot function a missing item modifier is not found" TO TL-CASE
     MOVE "test:no_such" TO WS-KEY
     CALL "LOOT-MODIFIER" USING WS-KEY LOOT-CONTEXT WS-ITEM WS-COUNT WS-HANDLE WS-FOUND
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     GOBACK.

*> Numbered contexts: 0 empty; 1 killed by a player; 2 tool pry_bar; 11 tool with efficiency 5; 12 tool with efficiency 1; 20 tool
*> with efficiency 3; 22 an attacker with efficiency 3; 23 explosion radius 2.0.
 SETUP-SCENARIO.
     EVALUATE FUNCTION NUMVAL(WS-SCENARIO)
         WHEN 1
             MOVE 1 TO LC-KILLER
         WHEN 2
             PERFORM SET-TOOL
         WHEN 11
             PERFORM SET-TOOL
             MOVE 5 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 12
             PERFORM SET-TOOL
             MOVE 1 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 20
             PERFORM SET-TOOL
             MOVE 3 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 22
             MOVE 1 TO LC-ATTACKER-SET LC-KILLER
             MOVE 1 TO LC-ATTACKER-ENCH-COUNT
             MOVE 0 TO LC-AE-ID(1)
             MOVE 3 TO LC-AE-LEVEL(1)
         WHEN 23
             MOVE 1 TO LC-RADIUS-SET
             MOVE 2.0 TO LC-RADIUS
     END-EVALUATE.

 SET-TOOL.
     MOVE 1 TO LC-TOOL-SET
     MOVE WS-TOOL TO LC-TOOL-ITEM
     MOVE 1 TO LC-TOOL-COUNT
     MOVE 0 TO LC-TOOL-HANDLE.

 ENCHANT-TOOL.
     MOVE 0 TO WS-ID
     CALL "SP-ADD-ENCHANT" USING LC-TOOL-HANDLE WS-ID WS-LEVEL.

*> The stack of a case: max_damage, damage and efficiency level in its patch.
 BUILD-HANDLE.
     MOVE 0 TO WS-HANDLE
     COMPUTE WS-MAX = FUNCTION NUMVAL(WS-MAX-TEXT)
     IF WS-MAX > 0
         MOVE 2 TO WS-TYPE
         MOVE SPACES TO WS-VALUE
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-MAX
         COMPUTE WS-LENGTH = WS-POS - 1
         CALL "SP-SET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     END-IF
     COMPUTE WS-DAMAGE = FUNCTION NUMVAL(WS-DAMAGE-TEXT)
     IF WS-DAMAGE > 0
         CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     END-IF
     COMPUTE WS-LEVEL = FUNCTION NUMVAL(WS-ENCH-TEXT)
     IF WS-LEVEL > 0
         MOVE 0 TO WS-ID
         CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ID WS-LEVEL
     END-IF.

*> "item count damage efficiency-level name": the name is - without one, a custom name as is, an item_name (component 5) as item:text.
 DESCRIBE-STACK.
     CALL "SP-GET-DAMAGE" USING WS-ITEM WS-HANDLE WS-DAMAGE
     MOVE 0 TO WS-ID
     CALL "SP-ENCHANT-LEVEL" USING WS-HANDLE WS-ID WS-LEVEL
     MOVE "-" TO WS-NAME-TEXT
     CALL "SP-GET-NAME" USING WS-HANDLE WS-NAME-OUT WS-NAME-LENGTH
     IF WS-NAME-LENGTH > 0
         MOVE WS-NAME-OUT(1:WS-NAME-LENGTH) TO WS-NAME-TEXT
     END-IF
     MOVE 5 TO WS-TYPE
     CALL "SP-GET-COMPONENT" USING WS-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND2
     IF WS-FOUND2 = 1
         COMPUTE WS-NAME-LENGTH = FUNCTION ORD(WS-VALUE(3:1)) - 1
         MOVE SPACES TO WS-NAME-TEXT
         STRING "item:" WS-VALUE(4:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-NAME-TEXT
     END-IF
     MOVE WS-ITEM TO WS-EDIT
     MOVE WS-COUNT TO WS-EDIT2
     MOVE WS-DAMAGE TO WS-EDIT3
     MOVE WS-LEVEL TO WS-EDIT4
     MOVE SPACES TO WS-VALUE
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) " "
         FUNCTION TRIM(WS-EDIT4) " " FUNCTION TRIM(WS-NAME-TEXT) DELIMITED BY SIZE INTO WS-VALUE
     MOVE WS-VALUE TO WS-NAME-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOOT-FUNCTIONS.
 COPY CORETEST.
