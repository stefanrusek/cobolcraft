*> Test of the loot tables (core/src/loot.cob; docs/protocol/26-loot-and-predicates.md sections 4, 5, 6, 12 and 13.2 T1 to T3, T21 to T23): LOOT-ROLL of the
*> fixture tables of core/tests/fixtures/loot (pools, rolls and bonus rolls, the nine entry types except slot sources, entry and
*> pool conditions, effective weights under luck, the modifier chain of entry, pool and table, the infinite loop guard of nested
*> tables, dynamic drops, splitting into stacks of the item's size, a table's random sequence). A case with a seed rolls with the
*> Java LCG of that seed and, after the roll, checks the next nextInt(1000), which shows how many random numbers the roll consumed;
*> the expected stacks (item id:count) and probes come from an independent Python implementation of the LCG (10 2.6) and of the rules
*> of the sections; the two sequence cases use the world seed in the case and continue one saved sequence (probe -1: not checked).
*> Items are the stand-in set's (grit 5, loam 3, turf 4, pry_bar 10, trowel 11, dump_shard 15).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOT-TABLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY LOOTCTX.
 COPY LOOTSTATE.
 01 WS-CASES.
    05 FILLER PIC X(100) VALUE "t_single|0|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_rolls2|0|3|0|3:1 3:1|734".
    05 FILLER PIC X(100) VALUE "t_weights|0|5|0|3:1|92".
    05 FILLER PIC X(100) VALUE "t_weights|0|8|0|3:1|956".
    05 FILLER PIC X(100) VALUE "t_weights|0|12|0|3:1|812".
    05 FILLER PIC X(100) VALUE "t_quality|26|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_quality_all|26|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_luck_weights|28|5|0|4:1|92".
    05 FILLER PIC X(100) VALUE "t_luck_weights|28|6|0|3:1|876".
    05 FILLER PIC X(100) VALUE "t_luck_weights|28|7|0|4:1|164".
    05 FILLER PIC X(100) VALUE "t_luck_weights|28|8|0|4:1|956".
    05 FILLER PIC X(100) VALUE "t_bonus|24|3|0|4:1 4:1 4:1|734".
    05 FILLER PIC X(100) VALUE "t_bonus|25|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_bonus|0|3|0|4:1|734".
    05 FILLER PIC X(100) VALUE "t_pool_cond|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_pool_cond|1|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_pool_cond_ref|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_pool_cond_ref|1|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_alt|0|3|0|5:1|734".
    05 FILLER PIC X(100) VALUE "t_alt|1|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_seq|0|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_seq|1|5|0|4:1|92".
    05 FILLER PIC X(100) VALUE "t_seq|1|6|0|5:1|876".
    05 FILLER PIC X(100) VALUE "t_group|0|5|0|4:1|92".
    05 FILLER PIC X(100) VALUE "t_group|0|6|0|5:1|876".
    05 FILLER PIC X(100) VALUE "t_group|0|7|0|5:1|164".
    05 FILLER PIC X(100) VALUE "t_empty|0|5|0|-|92".
    05 FILLER PIC X(100) VALUE "t_empty|0|6|0|-|876".
    05 FILLER PIC X(100) VALUE "t_empty|0|9|0|-|596".
    05 FILLER PIC X(100) VALUE "t_empty|0|11|0|-|668".
    05 FILLER PIC X(100) VALUE "t_tag_all|0|3|0|10:1 11:1|734".
    05 FILLER PIC X(100) VALUE "t_tag_each|0|5|0|11:1|92".
    05 FILLER PIC X(100) VALUE "t_tag_each|0|6|0|11:1|876".
    05 FILLER PIC X(100) VALUE "t_tag_list|0|5|0|5:1|92".
    05 FILLER PIC X(100) VALUE "t_tag_list|0|6|0|5:1|876".
    05 FILLER PIC X(100) VALUE "t_nested|0|3|0|3:1 3:1|734".
    05 FILLER PIC X(100) VALUE "t_nested_list|0|5|0|3:1 3:1|92".
    05 FILLER PIC X(100) VALUE "t_nested_list|0|8|0|3:1 3:1|956".
    05 FILLER PIC X(100) VALUE "t_nested_each|0|5|0|5:1|474".
    05 FILLER PIC X(100) VALUE "t_nested_each|0|6|0|3:1|666".
    05 FILLER PIC X(100) VALUE "t_nested_inline|0|3|0|4:1|734".
    05 FILLER PIC X(100) VALUE "t_nested_missing|0|3|0|5:1|734".
    05 FILLER PIC X(100) VALUE "t_loop|0|3|0|3:1|734".
    05 FILLER PIC X(100) VALUE "t_dynamic|27|3|0|15:3|734".
    05 FILLER PIC X(100) VALUE "t_dynamic|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_dynamic_none|27|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_slots|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_chain|0|3|0|5:15|734".
    05 FILLER PIC X(100) VALUE "t_split130|0|3|0|5:64 5:64 5:2|734".
    05 FILLER PIC X(100) VALUE "t_split70|0|3|0|5:64 5:6|734".
    05 FILLER PIC X(100) VALUE "t_split64|0|3|0|5:64|734".
    05 FILLER PIC X(100) VALUE "t_zero|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_discard|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_nopools|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_inline_list|0|3|0|11:1 11:1|734".
    05 FILLER PIC X(100) VALUE "t_entry_cond_fail|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_two_pools|0|3|0|3:1 5:1|734".
    05 FILLER PIC X(100) VALUE "t_rolls_uniform|0|5|0|4:1 4:1 4:1|92".
    05 FILLER PIC X(100) VALUE "t_rolls_uniform|0|6|0|4:1 4:1|876".
    05 FILLER PIC X(100) VALUE "t_rolls_uniform|0|7|0|4:1 4:1|164".
    05 FILLER PIC X(100) VALUE "t_nested_mod|0|3|0|5:15 4:1|734".
    05 FILLER PIC X(100) VALUE "t_alt_weight|1|5|0|4:1|92".
    05 FILLER PIC X(100) VALUE "t_alt_weight|1|6|0|3:1|876".
    05 FILLER PIC X(100) VALUE "t_alt_weight|0|5|0|4:1|92".
    05 FILLER PIC X(100) VALUE "t_looted|23|5|0|-|92".
    05 FILLER PIC X(100) VALUE "t_looted|23|6|0|-|876".
    05 FILLER PIC X(100) VALUE "t_looted|0|3|0|5:1|734".
    05 FILLER PIC X(100) VALUE "t_alt_empty|0|3|0|-|734".
    05 FILLER PIC X(100) VALUE "t_seq_state|0|0|12345|5:1 3:1 3:1|-1".
    05 FILLER PIC X(100) VALUE "t_seq_state|0|0|12345|5:1 3:1 5:1|-1".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(100) OCCURS 70 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-SCENARIO            PIC X(4).
 01 WS-SEED                PIC X(12).
 01 WS-WORLD               PIC X(12).
 01 WS-STACKS-TEXT         PIC X(60).
 01 WS-PROBE-TEXT          PIC X(8).
 01 WS-KEY                 PIC X(112).
 01 WS-PROBE               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-TEXT                PIC X(200).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
     MOVE "test loot table the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 0 TO LQ-SALT LQ-NO-WORLD-SEED LQ-NO-SEQUENCE-ID LQ-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70
         MOVE SPACES TO WS-NAME WS-SCENARIO WS-SEED WS-WORLD WS-STACKS-TEXT WS-PROBE-TEXT
         UNSTRING WS-CASE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-SCENARIO WS-SEED WS-WORLD WS-STACKS-TEXT
             WS-PROBE-TEXT
         INITIALIZE LOOT-CONTEXT
         COMPUTE LC-SEED = FUNCTION NUMVAL(WS-SEED)
         COMPUTE LC-WORLD-SEED = FUNCTION NUMVAL(WS-WORLD)
         PERFORM SETUP-SCENARIO
         MOVE SPACES TO WS-KEY
         STRING "test:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
         CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
         MOVE SPACES TO WS-TEXT
         IF LR-COUNT = 0
             MOVE "-" TO WS-TEXT
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > LR-COUNT
             MOVE LR-ITEM(WS-J) TO WS-EDIT
             MOVE LR-AMOUNT(WS-J) TO WS-EDIT2
             IF WS-J = 1
                 STRING FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
             ELSE
                 STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) ":" FUNCTION TRIM(WS-EDIT2)
                     DELIMITED BY SIZE INTO WS-TEXT
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-OBSERVED
         MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
         MOVE SPACES TO TL-EXPECTED
         MOVE FUNCTION TRIM(WS-STACKS-TEXT) TO TL-EXPECTED
         IF WS-PROBE-TEXT NOT = "-1"
             CALL "LOOT-RNG-INT" USING WS-BOUND WS-PROBE
             MOVE WS-PROBE TO WS-EDIT
             STRING FUNCTION TRIM(TL-OBSERVED) "|" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
             STRING FUNCTION TRIM(WS-STACKS-TEXT) "|" FUNCTION TRIM(WS-PROBE-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "test loot table " FUNCTION TRIM(WS-NAME) " scenario " FUNCTION TRIM(WS-SCENARIO) " seed "
             FUNCTION TRIM(WS-SEED) " world " FUNCTION TRIM(WS-WORLD) DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK
     END-PERFORM
     MOVE "test loot table a missing table has status 1 and no stacks" TO TL-CASE
     MOVE "test:no_such" TO WS-KEY
     INITIALIZE LOOT-CONTEXT
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     MOVE 1 TO TL-EXPECTED-N
     MOVE LR-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "test loot table a rolled table has status 0" TO TL-CASE
     MOVE "test:t_single" TO WS-KEY
     INITIALIZE LOOT-CONTEXT
     MOVE 3 TO LC-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     MOVE 0 TO TL-EXPECTED-N
     MOVE LR-STATUS TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     GOBACK.

*> Numbered contexts: 0 empty; 1 killed by a player; 23 explosion radius 2.0; 24 luck 2.7; 25 luck -0.5; 26 luck 25; 27 a dynamic
*> drop test:extra (item 15, count 3); 28 luck 3.0.
 SETUP-SCENARIO.
     EVALUATE FUNCTION NUMVAL(WS-SCENARIO)
         WHEN 1
             MOVE 1 TO LC-KILLER
         WHEN 23
             MOVE 1 TO LC-RADIUS-SET
             MOVE 2.0 TO LC-RADIUS
         WHEN 24
             MOVE 2.7 TO LC-LUCK
         WHEN 25
             MOVE -0.5 TO LC-LUCK
         WHEN 26
             MOVE 25 TO LC-LUCK
         WHEN 27
             MOVE 1 TO LC-DYNAMIC-COUNT
             MOVE "test:extra" TO LC-DY-NAME(1)
             MOVE 15 TO LC-DY-ITEM(1)
             MOVE 3 TO LC-DY-COUNT(1)
             MOVE 0 TO LC-DY-HANDLE(1)
         WHEN 28
             MOVE 3 TO LC-LUCK
     END-EVALUATE.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-LOOT-TABLES.
 COPY CORETEST.
