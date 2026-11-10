*> Test of the loot conditions and predicates (core/src/loot-condition.cob; docs/protocol/26-loot-and-predicates.md sections 8 and 10.1 to
*> 10.3, 10.10, 13.2 T10 to T12, T18, T20): the 20 condition types, evaluated through LOOT-PREDICATE from the named predicates of
*> core/tests/fixtures/loot (the registry predicate) under 20 numbered contexts (the scenarios of SETUP-SCENARIO). Every case checks the
*> result and, after it, the next nextInt(1000) of the context's random (a Java LCG of a fixed seed): the probe tells how many random
*> numbers the condition consumed (all_of and any_of stop at the first decisive term and draw nothing after it, 8). The expected
*> values come from an independent Python implementation of the LCG (10 2.6) and of the rules of the sections.
*> The enchantment of the scenarios is minecraft:efficiency (id 0), the only enchantment of the cobolcraft content set; tools are
*> cobolcraft:pry_bar and trowel (the item tag minecraft:enchantable/mining), blocks cobolcraft:greystone and cardstack.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-CONDITIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CSTACK.
 COPY LOOTCTX.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "c_killed|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_killed|1|3|1|734".
    05 FILLER PIC X(60) VALUE "c_inverted|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_inverted|1|3|0|734".
    05 FILLER PIC X(60) VALUE "c_inverted_ref|1|3|0|734".
    05 FILLER PIC X(60) VALUE "c_inverted_ref|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_all_of|0|5|0|487".
    05 FILLER PIC X(60) VALUE "c_all_of|1|5|0|92".
    05 FILLER PIC X(60) VALUE "c_any_of|1|5|1|487".
    05 FILLER PIC X(60) VALUE "c_any_of|0|5|0|92".
    05 FILLER PIC X(60) VALUE "c_all_of_empty|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_any_of_empty|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_all_of_ref|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_all_of_ref|1|3|0|734".
    05 FILLER PIC X(60) VALUE "c_all_of_ref|17|5|1|92".
    05 FILLER PIC X(60) VALUE "c_random_chance|0|7|0|164".
    05 FILLER PIC X(60) VALUE "c_random_chance|0|9|0|596".
    05 FILLER PIC X(60) VALUE "c_rcwb|0|5|0|92".
    05 FILLER PIC X(60) VALUE "c_rcwb|8|5|1|92".
    05 FILLER PIC X(60) VALUE "c_rcwb|8|11|1|668".
    05 FILLER PIC X(60) VALUE "c_rcwb_const|8|5|1|92".
    05 FILLER PIC X(60) VALUE "c_survives|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_survives|4|5|0|92".
    05 FILLER PIC X(60) VALUE "c_survives|4|7|0|164".
    05 FILLER PIC X(60) VALUE "c_table_bonus|0|5|0|92".
    05 FILLER PIC X(60) VALUE "c_table_bonus|2|5|0|92".
    05 FILLER PIC X(60) VALUE "c_table_bonus|11|5|0|92".
    05 FILLER PIC X(60) VALUE "c_table_bonus|11|7|0|164".
    05 FILLER PIC X(60) VALUE "c_tool_none|2|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_none|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_tag|2|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_tag|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ids|2|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_id|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_count|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_count|11|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_count_exact|11|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_count_exact|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench|3|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench|12|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench|11|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench_any|3|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench_any|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench_levels|12|3|1|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench_levels|3|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_ench_levels|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_components|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_tool_other_predicate|2|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_id|5|3|1|734".
    05 FILLER PIC X(60) VALUE "c_block_id|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_id|13|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_tag|5|3|1|734".
    05 FILLER PIC X(60) VALUE "c_block_tag|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_state|13|3|1|734".
    05 FILLER PIC X(60) VALUE "c_block_state|14|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_state|5|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_state_missing|13|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_state_range|13|3|0|734".
    05 FILLER PIC X(60) VALUE "c_block_nbt|13|3|0|734".
    05 FILLER PIC X(60) VALUE "c_weather_rain|6|3|1|734".
    05 FILLER PIC X(60) VALUE "c_weather_rain|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_weather_clear|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_weather_clear|6|3|0|734".
    05 FILLER PIC X(60) VALUE "c_weather_thunder|7|3|1|734".
    05 FILLER PIC X(60) VALUE "c_weather_thunder|6|3|0|734".
    05 FILLER PIC X(60) VALUE "c_time_range|9|3|1|734".
    05 FILLER PIC X(60) VALUE "c_time_range|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_time_period|9|3|1|734".
    05 FILLER PIC X(60) VALUE "c_time_period|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_time_point_no|9|3|0|734".
    05 FILLER PIC X(60) VALUE "c_int_check|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_int_check_no|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_int_check_point|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_float_check|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_float_check_point|0|3|1|734".
    05 FILLER PIC X(60) VALUE "c_float_check_max|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_active|10|3|1|734".
    05 FILLER PIC X(60) VALUE "c_active|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_active|19|3|0|734".
    05 FILLER PIC X(60) VALUE "c_inactive|19|3|1|734".
    05 FILLER PIC X(60) VALUE "c_inactive|10|3|0|734".
    05 FILLER PIC X(60) VALUE "c_inactive|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_env|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_this|15|3|1|734".
    05 FILLER PIC X(60) VALUE "c_entity_this|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_type|15|3|1|734".
    05 FILLER PIC X(60) VALUE "c_entity_type|16|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_attacker|16|3|1|734".
    05 FILLER PIC X(60) VALUE "c_entity_attacker|15|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_player|16|3|1|734".
    05 FILLER PIC X(60) VALUE "c_entity_player|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_direct|16|3|0|734".
    05 FILLER PIC X(60) VALUE "c_entity_other_part|15|3|0|734".
    05 FILLER PIC X(60) VALUE "c_scores_empty|15|3|1|734".
    05 FILLER PIC X(60) VALUE "c_scores_empty|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_scores|15|3|0|734".
    05 FILLER PIC X(60) VALUE "c_damage_source|15|3|0|734".
    05 FILLER PIC X(60) VALUE "c_location|15|3|1|734".
    05 FILLER PIC X(60) VALUE "c_location|0|3|0|734".
    05 FILLER PIC X(60) VALUE "c_location_pred|15|3|0|734".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(60) OCCURS 101 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-SCENARIO            PIC X(4).
 01 WS-SEED                PIC X(12).
 01 WS-RESULT-TEXT         PIC X(4).
 01 WS-PROBE-TEXT          PIC X(8).
 01 WS-KEY                 PIC X(112).
 01 WS-RESULT              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PROBE               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-TOOL                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-PAIRS               PIC X(64).
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot condition the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "cobolcraft:pry_bar" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TOOL WS-ROW WS-STATUS
     MOVE "minecraft:efficiency" TO WS-ENCH-KEY
     CALL "LOOT-ENCH-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE "test loot condition the enchantment id of minecraft:efficiency" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ENCH-ID TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "minecraft:fortune" TO WS-ENCH-KEY
     CALL "LOOT-ENCH-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE "test loot condition an enchantment the set does not hold has id -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-ENCH-ID TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 101
         MOVE SPACES TO WS-NAME WS-SCENARIO WS-SEED WS-RESULT-TEXT WS-PROBE-TEXT
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-SCENARIO WS-SEED WS-RESULT-TEXT WS-PROBE-TEXT
         INITIALIZE LOOT-CONTEXT
         COMPUTE LC-SEED = FUNCTION NUMVAL(WS-SEED)
         PERFORM SETUP-SCENARIO
         MOVE SPACES TO WS-KEY
         STRING "test:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-FOUND
         CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
         MOVE WS-RESULT TO WS-EDIT
         MOVE SPACES TO TL-OBSERVED
         STRING FUNCTION TRIM(WS-EDIT) "|" DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-PROBE TO WS-EDIT
         STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED
         STRING FUNCTION TRIM(WS-RESULT-TEXT) "|" FUNCTION TRIM(WS-PROBE-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE SPACES TO TL-CASE
         STRING "test loot condition " FUNCTION TRIM(WS-NAME) " scenario " FUNCTION TRIM(WS-SCENARIO) " seed "
             FUNCTION TRIM(WS-SEED) DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK
     END-PERFORM
     MOVE "test loot condition a missing predicate is not found" TO TL-CASE
     MOVE "test:no_such" TO WS-KEY
     CALL "LOOT-PREDICATE" USING WS-KEY LOOT-CONTEXT WS-RESULT WS-FOUND
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     GOBACK.

*> The numbered contexts of the cases (docs of this test): 0 empty; 1 killed by a player; 2 tool pry_bar; 3 the tool with efficiency 2;
*> 4 explosion radius 4.0; 5 block greystone; 6 raining; 7 raining and thundering; 8 an attacker with efficiency 2; 9 clock at 12345
*> ticks; 10 enchantment level 2 and active; 11 tool x5 with efficiency 5; 12 tool with efficiency 1; 13 block cardstack axis x;
*> 14 cardstack axis z; 15 origin and this_entity sodgrazer; 16 this_entity abend, attacker sodgrazer, killed by a player;
*> 17 killed by a player and radius 4.0; 19 enchantment inactive.
 SETUP-SCENARIO.
     EVALUATE FUNCTION NUMVAL(WS-SCENARIO)
         WHEN 1
             MOVE 1 TO LC-KILLER
         WHEN 2
             MOVE 1 TO LC-TOOL-SET
             MOVE WS-TOOL TO LC-TOOL-ITEM
             MOVE 1 TO LC-TOOL-COUNT
         WHEN 3
             PERFORM SET-TOOL
             MOVE 2 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 4
             MOVE 1 TO LC-RADIUS-SET
             MOVE 4.0 TO LC-RADIUS
         WHEN 5
             MOVE "cobolcraft:greystone" TO WS-BLOCK-KEY
             MOVE SPACES TO WS-PAIRS
             PERFORM SET-BLOCK
         WHEN 6
             MOVE 1 TO LC-RAINING
         WHEN 7
             MOVE 1 TO LC-RAINING LC-THUNDERING
         WHEN 8
             MOVE 1 TO LC-ATTACKER-SET
             MOVE 1 TO LC-ATTACKER-ENCH-COUNT
             MOVE 0 TO LC-AE-ID(1)
             MOVE 2 TO LC-AE-LEVEL(1)
         WHEN 9
             MOVE 1 TO LC-CLOCK-SET
             MOVE 12345 TO LC-CLOCK-TICKS
         WHEN 10
             MOVE 1 TO LC-ENCH-SET LC-ACTIVE-SET LC-ACTIVE
             MOVE 2 TO LC-ENCH-LEVEL
         WHEN 11
             PERFORM SET-TOOL
             MOVE 5 TO LC-TOOL-COUNT
             MOVE 5 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 12
             PERFORM SET-TOOL
             MOVE 1 TO WS-LEVEL
             PERFORM ENCHANT-TOOL
         WHEN 13
             MOVE "cobolcraft:cardstack" TO WS-BLOCK-KEY
             MOVE "axis=x,punched=false" TO WS-PAIRS
             PERFORM SET-BLOCK
         WHEN 14
             MOVE "cobolcraft:cardstack" TO WS-BLOCK-KEY
             MOVE "axis=z,punched=false" TO WS-PAIRS
             PERFORM SET-BLOCK
         WHEN 15
             MOVE 1 TO LC-ORIGIN-SET LC-THIS-SET
             MOVE "cobolcraft:sodgrazer" TO LC-THIS-TYPE
         WHEN 16
             MOVE 1 TO LC-THIS-SET LC-ATTACKER-SET LC-KILLER
             MOVE "cobolcraft:abend" TO LC-THIS-TYPE
             MOVE "cobolcraft:sodgrazer" TO LC-ATTACKER-TYPE
         WHEN 17
             MOVE 1 TO LC-KILLER LC-RADIUS-SET
             MOVE 4.0 TO LC-RADIUS
         WHEN 19
             MOVE 1 TO LC-ACTIVE-SET
             MOVE 0 TO LC-ACTIVE
     END-EVALUATE.

 SET-TOOL.
     MOVE 1 TO LC-TOOL-SET
     MOVE WS-TOOL TO LC-TOOL-ITEM
     MOVE 1 TO LC-TOOL-COUNT
     MOVE 0 TO LC-TOOL-HANDLE.

 ENCHANT-TOOL.
     MOVE 0 TO WS-ID
     CALL "SP-ADD-ENCHANT" USING LC-TOOL-HANDLE WS-ID WS-LEVEL.

 SET-BLOCK.
     MOVE SPACES TO WS-KEY
     MOVE WS-BLOCK-KEY TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE 1 TO LC-STATE-SET
     MOVE WS-STATE TO LC-STATE.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOOT-CONDITIONS.
 COPY CORETEST.
