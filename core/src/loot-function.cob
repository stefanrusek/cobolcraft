*> The loot functions of the loot engine (T0436; docs/protocol/26-loot-and-predicates.md section 7). A function is a JSON node (slot, node): an
*> object with a "type", a string naming an entry of the registry item_modifier, or an array (a sequence, 7.1: the inline form
*> of a list). A stack is (item id, count, patch handle of core/copy/CSTACK.cpy). Every function but discard and filtered has an
*> optional condition: when it fails the stack is left alone.
*> Evaluated (7.1 to 7.3): set_count, set_item, limit_count, explosion_decay, enchanted_count_increase, apply_bonus (uniform_bonus_count,
*> ore_drops, binomial_with_bonus_count), discard (count 0), sequence, filtered, set_enchantments, set_damage, set_name (a text component {"text"};
*> target custom_name or item_name). Left alone (the stack passes unchanged): the functions that
*> need systems the core does not hold yet: furnace_smelt (smelting recipes), enchant_with_levels and enchant_randomly (the
*> enchanting table selection), copy_name, copy_state, copy_components, set_components, set_custom_data, copy_custom_data,
*> set_attributes, the potion, stew, instrument, dye, banner, book, firework, custom model data, tooltip, player head, map, container and
*> loot table functions. Gaps inside the evaluated ones: set_enchantments does not convert a book to an enchanted book and a level
*> of 0 does not remove an enchantment; set_name does not resolve selector, score or NBT components.
*> Entry points:
*>   LOOT-FN-APPLY USING slot, node, item, count, handle (BINARY-LONG; the stack, in and out)
*>   LOOT-APPLY-CHAIN USING item, count, handle (in and out): the modifiers of LW-CHAIN, innermost first (5.1 step 3, 5.3 step 5)
*>   LOOT-MODIFIER USING name (PIC X(112)), LOOT-CONTEXT, item, count, handle (in and out), found out   a named item modifier

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SET-DAMAGE.
*> USING slot, function node, item, handle (in and out): set_damage (7.3), every step in float32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-DAMAGE            PIC X(32) VALUE "damage".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-CF                  FLOAT-LONG.
 01 WS-MF                  FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-CLAMPED             FLOAT-LONG.
 01 WS-REST                FLOAT-LONG.
 01 WS-PRODUCT             FLOAT-LONG.
 01 WS-FLOOR               FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-ITEM L-HANDLE.
     CALL "SP-GET-MAX-DAMAGE" USING L-ITEM L-HANDLE WS-MAX
     IF WS-MAX = 0
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-DAMAGE WS-MEMBER
     CALL "LOOT-FLOAT-GET" USING L-SLOT WS-MEMBER WS-P
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ADD WS-MEMBER
     CALL "LOOT-J-TRUE" USING L-SLOT WS-MEMBER WS-ADD
     MOVE 0 TO WS-BASE
     IF WS-ADD = 1
         CALL "SP-GET-DAMAGE" USING L-ITEM L-HANDLE WS-CURRENT
         CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-CURRENT BY REFERENCE WS-CF
         CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-MAX BY REFERENCE WS-MF
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-CF BY REFERENCE WS-MF BY REFERENCE WS-Q
         CALL "LOOT-F32" USING WS-Q
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ONE BY REFERENCE WS-Q BY REFERENCE WS-BASE
         CALL "LOOT-F32" USING WS-BASE
     END-IF
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE WS-MAX BY REFERENCE WS-MF
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-P BY REFERENCE WS-BASE BY REFERENCE WS-SUM
     CALL "LOOT-F32" USING WS-SUM
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-SUM BY REFERENCE WS-ZERO BY REFERENCE WS-ONE
         BY REFERENCE WS-CLAMPED
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ONE BY REFERENCE WS-CLAMPED BY REFERENCE WS-REST
     CALL "LOOT-F32" USING WS-REST
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-REST BY REFERENCE WS-MF BY REFERENCE WS-PRODUCT
     CALL "LOOT-F32" USING WS-PRODUCT
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-PRODUCT BY REFERENCE WS-FLOOR
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FLOOR BY REFERENCE WS-DAMAGE
     CALL "SP-SET-DAMAGE" USING L-HANDLE WS-DAMAGE
     GOBACK.
 END PROGRAM LOOT-SET-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SET-NAME.
*> USING slot, function node, handle (in and out): set_name (7.3): the name is a text component with a "text" string.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-NAME              PIC X(32) VALUE "name".
 01 WS-N-TARGET            PIC X(32) VALUE "target".
 01 WS-N-TEXT              PIC X(32) VALUE "text".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KIND                PIC X(112).
 01 WS-KIND-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-VALUE               PIC X(64).
 01 WS-ITEM-NAME           BINARY-LONG VALUE 5.
 01 WS-BYTES               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-NAME WS-MEMBER
     CALL "LOOT-J-MEMBER" USING L-SLOT WS-MEMBER WS-N-TEXT WS-TARGET
     CALL "LOOT-J-TEXT" USING L-SLOT WS-TARGET WS-TEXT WS-LENGTH
     IF WS-LENGTH = 0
         GOBACK
     END-IF
     IF WS-LENGTH > 60
         MOVE 60 TO WS-LENGTH
     END-IF
     MOVE SPACES TO WS-NAME
     MOVE WS-TEXT(1:WS-LENGTH) TO WS-NAME
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-TARGET WS-TARGET
     CALL "LOOT-J-TEXT" USING L-SLOT WS-TARGET WS-KIND WS-KIND-LENGTH
     IF WS-KIND = "item_name"
         MOVE SPACES TO WS-VALUE
         MOVE FUNCTION CHAR(9) TO WS-VALUE(1:1)
         MOVE FUNCTION CHAR(1) TO WS-VALUE(2:1)
         COMPUTE WS-BYTES = WS-LENGTH + 1
         MOVE FUNCTION CHAR(WS-BYTES) TO WS-VALUE(3:1)
         MOVE WS-NAME(1:WS-LENGTH) TO WS-VALUE(4:WS-LENGTH)
         COMPUTE WS-BYTES = WS-LENGTH + 3
         CALL "SP-SET-COMPONENT" USING L-HANDLE WS-ITEM-NAME WS-VALUE WS-BYTES
     ELSE
         CALL "SP-SET-NAME" USING L-HANDLE WS-NAME WS-LENGTH
     END-IF
     GOBACK.
 END PROGRAM LOOT-SET-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SET-ENCHANTMENTS.
*> USING slot, function node, handle (in and out): set_enchantments (7.2) for the enchantments the registry holds.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-ENCHANTMENTS      PIC X(32) VALUE "enchantments".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ADD WS-MEMBER
     CALL "LOOT-J-TRUE" USING L-SLOT WS-MEMBER WS-ADD
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ENCHANTMENTS WS-MEMBER
     MOVE LDS-JN-FIRST(L-SLOT, WS-MEMBER) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0
         CALL "LOOT-J-KEY" USING L-SLOT WS-CHILD WS-KEY WS-KEY-LENGTH
         MOVE SPACES TO WS-NAME
         MOVE WS-KEY TO WS-NAME
         CALL "LOOT-ENCH-ID" USING WS-NAME WS-ID
         CALL "LOOT-INT-GET" USING L-SLOT WS-CHILD WS-VALUE
         IF WS-ID >= 0
             MOVE 0 TO WS-CURRENT
             IF WS-ADD = 1
                 CALL "SP-ENCHANT-LEVEL" USING L-HANDLE WS-ID WS-CURRENT
             END-IF
             COMPUTE WS-LEVEL = WS-CURRENT + WS-VALUE
             IF WS-LEVEL > 255
                 MOVE 255 TO WS-LEVEL
             END-IF
             IF WS-LEVEL > 0
                 CALL "SP-ADD-ENCHANT" USING L-HANDLE WS-ID WS-LEVEL
             END-IF
         END-IF
         MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-SET-ENCHANTMENTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-APPLY-BONUS.
*> USING slot, function node, count (in and out): apply_bonus (7.1); without a tool the count stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-ENCHANTMENT       PIC X(32) VALUE "enchantment".
 01 WS-N-FORMULA           PIC X(32) VALUE "formula".
 01 WS-N-PARAMETERS        PIC X(32) VALUE "parameters".
 01 WS-N-MULTIPLIER        PIC X(32) VALUE "bonusMultiplier".
 01 WS-N-EXTRA             PIC X(32) VALUE "extra".
 01 WS-N-PROBABILITY       PIC X(32) VALUE "probability".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-PARAMETERS          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-FORMULA             PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MULTIPLIER          BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PROBABILITY         FLOAT-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-TRIALS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-COUNT.
     IF LW-C-TOOL-SET = 0
         GOBACK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ENCHANTMENT WS-MEMBER
     CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-KEY WS-LENGTH
     CALL "LOOT-TOOL-LEVEL" USING WS-KEY WS-LEVEL
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-FORMULA WS-MEMBER
     CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-FORMULA WS-LENGTH
     IF WS-FORMULA(1:10) = "minecraft:"
         MOVE WS-FORMULA(11:) TO WS-FORMULA
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-PARAMETERS WS-PARAMETERS
     EVALUATE WS-FORMULA
         WHEN "uniform_bonus_count"
             CALL "LOOT-J-MEMBER" USING L-SLOT WS-PARAMETERS WS-N-MULTIPLIER WS-MEMBER
             CALL "LOOT-INT-GET" USING L-SLOT WS-MEMBER WS-MULTIPLIER
             COMPUTE WS-BOUND = WS-MULTIPLIER * WS-LEVEL + 1
             CALL "LOOT-RNG-INT" USING WS-BOUND WS-DRAW
             ADD WS-DRAW TO L-COUNT
         WHEN "ore_drops"
             IF WS-LEVEL > 0
                 COMPUTE WS-BOUND = WS-LEVEL + 2
                 CALL "LOOT-RNG-INT" USING WS-BOUND WS-DRAW
                 COMPUTE WS-DRAW = FUNCTION MAX(0, WS-DRAW - 1)
                 COMPUTE L-COUNT = L-COUNT * (WS-DRAW + 1)
             END-IF
         WHEN "binomial_with_bonus_count"
             CALL "LOOT-J-MEMBER" USING L-SLOT WS-PARAMETERS WS-N-EXTRA WS-MEMBER
             CALL "LOOT-INT-GET" USING L-SLOT WS-MEMBER WS-EXTRA
             CALL "LOOT-J-MEMBER" USING L-SLOT WS-PARAMETERS WS-N-PROBABILITY WS-MEMBER
             CALL "LOOT-J-NUMBER" USING L-SLOT WS-MEMBER WS-PROBABILITY WS-OK
             CALL "LOOT-F32" USING WS-PROBABILITY
             COMPUTE WS-TRIALS = WS-LEVEL + WS-EXTRA
             PERFORM WS-TRIALS TIMES
                 CALL "LOOT-RNG-FLOAT" USING WS-FLOAT
                 IF WS-FLOAT < WS-PROBABILITY
                     ADD 1 TO L-COUNT
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-APPLY-BONUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-FN-APPLY IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(48) VALUE "item_modifier".
 01 WS-N-CONDITION         PIC X(32) VALUE "condition".
 01 WS-N-COUNT             PIC X(32) VALUE "count".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-N-ITEM              PIC X(32) VALUE "item".
 01 WS-N-LIMIT             PIC X(32) VALUE "limit".
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-N-ENCHANTMENT       PIC X(32) VALUE "enchantment".
 01 WS-N-FUNCTIONS         PIC X(32) VALUE "functions".
 01 WS-N-FILTER            PIC X(32) VALUE "item_filter".
 01 WS-N-PASS              PIC X(32) VALUE "on_pass".
 01 WS-N-FAIL              PIC X(32) VALUE "on_fail".
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-OTHER               BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-VALUE               BINARY-LONG.
 01 LS-LOW                 BINARY-LONG.
 01 LS-HIGH                BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-LEVEL               BINARY-LONG.
 01 LS-KEY                 PIC X(112).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-KEPT                BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-ITEM L-COUNT L-HANDLE.
     MOVE L-SLOT TO LS-SLOT
     MOVE L-NODE TO LS-NODE
     IF LS-NODE = 0
         GOBACK
     END-IF
     EVALUATE LDS-JN-TYPE(LS-SLOT, LS-NODE)
         WHEN JT-STRING
             CALL "LOOT-HOLDER" USING WS-REGISTRY LS-SLOT LS-NODE
             CALL "LOOT-FN-APPLY" USING LS-SLOT LS-NODE L-ITEM L-COUNT L-HANDLE
             GOBACK
         WHEN JT-ARRAY
             MOVE LDS-JN-FIRST(LS-SLOT, LS-NODE) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-FN-APPLY" USING LS-SLOT LS-CHILD L-ITEM L-COUNT L-HANDLE
                 MOVE LDS-JN-NEXT(LS-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
             GOBACK
         WHEN JT-OBJECT
             CONTINUE
         WHEN OTHER
             GOBACK
     END-EVALUATE
     CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-CONDITION LS-MEMBER
     IF LS-MEMBER > 0
         CALL "LOOT-COND-EVAL" USING LS-SLOT LS-MEMBER LS-OK
         IF LS-OK = 0
             GOBACK
         END-IF
     END-IF
     CALL "LOOT-J-KIND" USING LS-SLOT LS-NODE LS-KIND
     EVALUATE LS-KIND
         WHEN "set_count"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-COUNT LS-MEMBER
             CALL "LOOT-INT-GET" USING LS-SLOT LS-MEMBER LS-VALUE
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ADD LS-MEMBER
             CALL "LOOT-J-TRUE" USING LS-SLOT LS-MEMBER LS-OK
             IF LS-OK = 1
                 ADD LS-VALUE TO L-COUNT
             ELSE
                 MOVE LS-VALUE TO L-COUNT
             END-IF
         WHEN "set_item"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ITEM LS-MEMBER
             CALL "LOOT-J-TEXT" USING LS-SLOT LS-MEMBER LS-KEY LS-LENGTH
             CALL "LOOT-ITEM-ID" USING LS-KEY LS-VALUE
             IF LS-VALUE >= 0
                 MOVE LS-VALUE TO L-ITEM
             END-IF
         WHEN "limit_count"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-LIMIT LS-OTHER
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-OTHER WS-N-MIN LS-MEMBER
             IF LS-MEMBER > 0
                 CALL "LOOT-INT-GET" USING LS-SLOT LS-MEMBER LS-LOW
                 IF L-COUNT < LS-LOW
                     MOVE LS-LOW TO L-COUNT
                 END-IF
             END-IF
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-OTHER WS-N-MAX LS-MEMBER
             IF LS-MEMBER > 0
                 CALL "LOOT-INT-GET" USING LS-SLOT LS-MEMBER LS-HIGH
                 IF L-COUNT > LS-HIGH
                     MOVE LS-HIGH TO L-COUNT
                 END-IF
             END-IF
         WHEN "explosion_decay"
             IF LW-C-RADIUS-SET = 1
                 CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE BY REFERENCE LW-C-RADIUS BY REFERENCE LS-A
                 CALL "LOOT-F32" USING LS-A
                 MOVE 0 TO LS-KEPT
                 MOVE L-COUNT TO LS-N
                 PERFORM LS-N TIMES
                     CALL "LOOT-RNG-FLOAT" USING LS-B
                     IF LS-B <= LS-A
                         ADD 1 TO LS-KEPT
                     END-IF
                 END-PERFORM
                 MOVE LS-KEPT TO L-COUNT
             END-IF
         WHEN "enchanted_count_increase"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-ENCHANTMENT LS-MEMBER
             CALL "LOOT-J-TEXT" USING LS-SLOT LS-MEMBER LS-KEY LS-LENGTH
             CALL "LOOT-ATTACKER-LEVEL" USING LS-KEY LS-LEVEL
             IF LS-LEVEL > 0
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-COUNT LS-MEMBER
                 CALL "LOOT-FLOAT-GET" USING LS-SLOT LS-MEMBER LS-A
                 MOVE LS-LEVEL TO LS-B
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-B BY REFERENCE LS-A BY REFERENCE LS-B
                 CALL "LOOT-F32" USING LS-B
                 CALL STATIC "cc_f64_round_f32" USING BY REFERENCE LS-B BY REFERENCE LS-VALUE
                 ADD LS-VALUE TO L-COUNT
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-LIMIT LS-MEMBER
                 CALL "LOOT-INT-GET" USING LS-SLOT LS-MEMBER LS-HIGH
                 IF LS-HIGH > 0 AND L-COUNT > LS-HIGH
                     MOVE LS-HIGH TO L-COUNT
                 END-IF
             END-IF
         WHEN "apply_bonus"
             CALL "LOOT-APPLY-BONUS" USING LS-SLOT LS-NODE L-COUNT
         WHEN "discard"
             MOVE 0 TO L-COUNT
         WHEN "sequence"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-FUNCTIONS LS-MEMBER
             CALL "LOOT-FN-APPLY" USING LS-SLOT LS-MEMBER L-ITEM L-COUNT L-HANDLE
         WHEN "filtered"
             CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-FILTER LS-MEMBER
             CALL "LOOT-ITEM-MATCH" USING LS-SLOT LS-MEMBER L-ITEM L-COUNT L-HANDLE LS-OK
             IF LS-OK = 1
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-PASS LS-MEMBER
             ELSE
                 CALL "LOOT-J-MEMBER" USING LS-SLOT LS-NODE WS-N-FAIL LS-MEMBER
             END-IF
             CALL "LOOT-FN-APPLY" USING LS-SLOT LS-MEMBER L-ITEM L-COUNT L-HANDLE
         WHEN "set_enchantments"
             CALL "LOOT-SET-ENCHANTMENTS" USING LS-SLOT LS-NODE L-HANDLE
         WHEN "set_damage"
             CALL "LOOT-SET-DAMAGE" USING LS-SLOT LS-NODE L-ITEM L-HANDLE
         WHEN "set_name"
             CALL "LOOT-SET-NAME" USING LS-SLOT LS-NODE L-HANDLE
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-FN-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-APPLY-CHAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-COUNT L-HANDLE.
     PERFORM VARYING WS-I FROM LW-CHAIN-COUNT BY -1 UNTIL WS-I < 1
         CALL "LOOT-FN-APPLY" USING LW-CH-SLOT(WS-I) LW-CH-NODE(WS-I) L-ITEM L-COUNT L-HANDLE
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-APPLY-CHAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-MODIFIER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "item_modifier".
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SEQUENCE            PIC X(112) VALUE SPACES.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(112).
 COPY LOOTCTX.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME LOOT-CONTEXT L-ITEM L-COUNT L-HANDLE L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-NAME WS-SLOT
     IF WS-SLOT > 0
         MOVE 1 TO WS-NODE
         MOVE 1 TO L-FOUND
         CALL "LOOT-FN-APPLY" USING WS-SLOT WS-NODE L-ITEM L-COUNT L-HANDLE
     END-IF
     GOBACK.
 END PROGRAM LOOT-MODIFIER.
