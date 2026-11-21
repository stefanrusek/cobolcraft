*> The loot table engine (T0436; docs/protocol/26-loot-and-predicates.md sections 4 to 6): LOOT-ROLL rolls a table of the shape store (content/src/loot.cob
*> loads and validates them) for a context and returns the stacks. The parts: random sources (loot-random.cob), JSON access
*> (loot-json.cob), number providers (loot-provider.cob), conditions and predicates (loot-condition.cob) and functions
*> (loot-function.cob); this file holds the tables, pools and entries.
*> THE ENTRY POINT FOR THE OTHER PARTS OF THE GAME (the mobs lane, chests, fishing and the rest):
*>   LOOT-ROLL USING table key (PIC X(112), "namespace:path", for example "minecraft:entities/zombie"), LOOT-CONTEXT, LOOT-RESULT
*> with the records of core/copy/LOOTCTX.cpy. The caller INITIALIZEs the context and sets the keys of the table's parameter set
*> (docs 26 section 3.2): LC-ORIGIN-*, LC-STATE (block_state), LC-TOOL-* (tool), LC-RADIUS (explosion_radius), LC-KILLER
*> (last_damage_player), LC-ATTACKER-* (attacking entity: its enchantments), LC-THIS-* (this_entity: its type key), LC-LUCK,
*> LC-WEATHER and clock fields, LC-DYNAMIC (dynamic drops) and, for the random source, LC-SEED (an explicit seed rolls with
*> the Java LCG, 26 section 4 step 2) or LC-WORLD-SEED (the table's random_sequence, else the level's own random, steps 4 and 5).
*> The result: LR-STATUS 0 and the stacks LR-STACK(1 to LR-COUNT) (item id, count, patch handle), or LR-STATUS 1 for a table the
*> store does not hold. Stacks are split to the item's stack size (5.1 step 5; an item without a stack size is split at 64) and stacks of
*> count 0 or less are left out.
*> A leaf whose item the open content set does not know yields nothing. A table's parameter set is not checked against the context.
*> slot sources (the slots entry) are not evaluated: that entry yields nothing.
*> Entry points of this file:
*>   LOOT-ROLL USING table key, LOOT-CONTEXT, LOOT-RESULT

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-EMIT.
*> USING item, count, handle: one stack of a leaf passes through the modifier chain (innermost first) and is appended to the output.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-COUNT L-HANDLE.
     MOVE L-ITEM TO WS-ITEM
     MOVE L-COUNT TO WS-COUNT
     MOVE L-HANDLE TO WS-HANDLE
     CALL "LOOT-APPLY-CHAIN" USING WS-ITEM WS-COUNT WS-HANDLE
     IF LW-OUT-COUNT < LW-MAX-OUT
         ADD 1 TO LW-OUT-COUNT
         MOVE WS-ITEM TO LW-OUT-ITEM(LW-OUT-COUNT)
         MOVE WS-COUNT TO LW-OUT-AMOUNT(LW-OUT-COUNT)
         MOVE WS-HANDLE TO LW-OUT-HANDLE(LW-OUT-COUNT)
     END-IF
     GOBACK.
 END PROGRAM LOOT-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-PUSH-MODIFIER.
*> USING slot, node of an entry, pool or table: pushes its "modifier" member on the chain (nothing when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-MODIFIER          PIC X(32) VALUE "modifier".
 01 WS-MEMBER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MODIFIER WS-MEMBER
     IF WS-MEMBER > 0
         ADD 1 TO LW-CHAIN-COUNT
         MOVE L-SLOT TO LW-CH-SLOT(LW-CHAIN-COUNT)
         MOVE WS-MEMBER TO LW-CH-NODE(LW-CHAIN-COUNT)
     END-IF
     GOBACK.
 END PROGRAM LOOT-PUSH-MODIFIER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-LEAF-ADD.
*> USING slot, entry node, sub: collects a leaf with the effective weight max(0, floor(weight + quality * luck)) (5.3 step 1; float
*> arithmetic) when it is above 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-WEIGHT            PIC X(32) VALUE "weight".
 01 WS-N-QUALITY           PIC X(32) VALUE "quality".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-WEIGHT              FLOAT-LONG.
 01 WS-QUALITY             FLOAT-LONG.
 01 WS-LUCK                FLOAT-LONG.
 01 WS-PRODUCT             FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-FLOOR               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EFFECTIVE           BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-SUB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-SUB.
     MOVE 1 TO WS-WEIGHT
     MOVE 0 TO WS-QUALITY
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-WEIGHT WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-J-NUMBER" USING L-SLOT WS-MEMBER WS-WEIGHT WS-OK
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-QUALITY WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-J-NUMBER" USING L-SLOT WS-MEMBER WS-QUALITY WS-OK
     END-IF
     MOVE LW-C-LUCK TO WS-LUCK
     CALL "LOOT-F32" USING WS-LUCK
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-QUALITY BY REFERENCE WS-LUCK BY REFERENCE WS-PRODUCT
     CALL "LOOT-F32" USING WS-PRODUCT
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-WEIGHT BY REFERENCE WS-PRODUCT BY REFERENCE WS-SUM
     CALL "LOOT-F32" USING WS-SUM
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-SUM BY REFERENCE WS-FLOOR
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FLOOR BY REFERENCE WS-EFFECTIVE
     IF WS-EFFECTIVE > 0 AND LW-LEAF-COUNT < 128
         ADD 1 TO LW-LEAF-COUNT
         MOVE L-SLOT TO LW-LF-SLOT(LW-LEAF-COUNT)
         MOVE L-NODE TO LW-LF-NODE(LW-LEAF-COUNT)
         MOVE L-SUB TO LW-LF-SUB(LW-LEAF-COUNT)
         MOVE WS-EFFECTIVE TO LW-LF-WEIGHT(LW-LEAF-COUNT)
         ADD WS-EFFECTIVE TO LW-TOTAL
     END-IF
     GOBACK.
 END PROGRAM LOOT-LEAF-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TAG-ITEMS.
*> USING slot, items node (an item id, "#tag" or a list of those), count out, ids out (64 BINARY-LONG): the item ids in order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-CHILD               BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-IDS.
    05 L-ID                BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-COUNT L-IDS.
     MOVE 0 TO L-COUNT
     IF L-NODE = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-ARRAY
         MOVE LDS-JN-FIRST(L-SLOT, L-NODE) TO WS-CHILD
     ELSE
         MOVE L-NODE TO WS-CHILD
     END-IF
     PERFORM UNTIL WS-CHILD = 0
         CALL "LOOT-J-TEXT" USING L-SLOT WS-CHILD WS-TEXT WS-LENGTH
         IF WS-TEXT(1:1) = "#"
             MOVE WS-TEXT(2:) TO WS-KEY
             MOVE 64 TO WS-CAPACITY
             CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-KEY WS-TAG-COUNT WS-TAG-IDS WS-CAPACITY WS-STATUS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TAG-COUNT OR L-COUNT >= 64
                 ADD 1 TO L-COUNT
                 MOVE WS-TAG-ID(WS-I) TO L-ID(L-COUNT)
             END-PERFORM
         ELSE
             CALL "LOOT-ITEM-ID" USING WS-TEXT WS-ID
             IF WS-ID >= 0 AND L-COUNT < 64
                 ADD 1 TO L-COUNT
                 MOVE WS-ID TO L-ID(L-COUNT)
             END-IF
         END-IF
         IF L-NODE = WS-CHILD
             MOVE 0 TO WS-CHILD
         ELSE
             MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-TAG-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TABLE-REF.
*> USING slot, value node of a loot_table entry, index (1 based), slot out, node out, key out (PIC X(112)): the index-th table the
*> value names: an id (one table), a list of ids and inline tables, or an inline table object. Node 0 when there is none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY LOOTSTATE.
 01 WS-REGISTRY            PIC X(48) VALUE "loot_table".
 01 WS-CHILD               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-DOC                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-OUT-SLOT             BINARY-LONG.
 01 L-OUT-NODE             BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING L-SLOT L-NODE L-INDEX L-OUT-SLOT L-OUT-NODE L-KEY.
     MOVE 0 TO L-OUT-SLOT L-OUT-NODE
     MOVE "(inline table)" TO L-KEY
     IF L-NODE = 0
         GOBACK
     END-IF
     MOVE L-NODE TO WS-CHILD
     IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-ARRAY
         MOVE LDS-JN-FIRST(L-SLOT, L-NODE) TO WS-CHILD
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-INDEX OR WS-CHILD = 0
             MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
         END-PERFORM
     ELSE
         IF L-INDEX > 1
             MOVE 0 TO WS-CHILD
         END-IF
     END-IF
     IF WS-CHILD = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, WS-CHILD) = JT-OBJECT
         MOVE L-SLOT TO L-OUT-SLOT
         MOVE WS-CHILD TO L-OUT-NODE
         GOBACK
     END-IF
     CALL "LOOT-J-TEXT" USING L-SLOT WS-CHILD WS-TEXT WS-LENGTH
     IF WS-LENGTH = 0 OR WS-TEXT(1:1) = "#"
         GOBACK
     END-IF
     MOVE 0 TO WS-COLON
     INSPECT WS-TEXT TALLYING WS-COLON FOR ALL ":"
     MOVE SPACES TO L-KEY
     IF WS-COLON = 0
         STRING "minecraft:" FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO L-KEY
     ELSE
         MOVE WS-TEXT TO L-KEY
     END-IF
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-KEY WS-DOC
     IF WS-DOC > 0
         MOVE WS-DOC TO L-OUT-SLOT
         MOVE 1 TO L-OUT-NODE
     END-IF
     GOBACK.
 END PROGRAM LOOT-TABLE-REF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENTRY-EXPAND IS RECURSIVE.
*> USING slot, entry node, ran out: expand (section 6): the entry's condition, then the leaves it collects; ran is whether the
*> entry counts as having run for alternatives and sequence.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-N-CONDITION         PIC X(32) VALUE "condition".
 01 WS-N-CHILDREN          PIC X(32) VALUE "children".
 01 WS-N-EXPAND            PIC X(32) VALUE "expand".
 01 WS-N-ITEMS             PIC X(32) VALUE "items".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 LOCAL-STORAGE SECTION.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-EXPAND              BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-IDS.
    05 LS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 LS-I                   BINARY-LONG.
 01 LS-OUT-SLOT            BINARY-LONG.
 01 LS-OUT-NODE            BINARY-LONG.
 01 LS-KEY                 PIC X(112).
 01 LS-RAN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-RAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-RAN.
     MOVE 0 TO L-RAN
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-CONDITION LS-MEMBER
     IF LS-MEMBER > 0
         CALL "LOOT-COND-EVAL" USING L-SLOT LS-MEMBER LS-OK
         IF LS-OK = 0
             GOBACK
         END-IF
     END-IF
     CALL "LOOT-J-KIND" USING L-SLOT L-NODE LS-KIND
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-EXPAND LS-MEMBER
     CALL "LOOT-J-TRUE" USING L-SLOT LS-MEMBER LS-EXPAND
     EVALUATE LS-KIND
         WHEN "alternatives"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-CHILDREN LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0 OR L-RAN = 1
                 CALL "LOOT-ENTRY-EXPAND" USING L-SLOT LS-CHILD L-RAN
                 MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN "sequence"
             MOVE 1 TO L-RAN
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-CHILDREN LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0 OR L-RAN = 0
                 CALL "LOOT-ENTRY-EXPAND" USING L-SLOT LS-CHILD L-RAN
                 MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN "group"
             MOVE 1 TO L-RAN
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-CHILDREN LS-MEMBER
             MOVE 0 TO LS-CHILD
             IF LS-MEMBER > 0
                 MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
             END-IF
             PERFORM UNTIL LS-CHILD = 0
                 CALL "LOOT-ENTRY-EXPAND" USING L-SLOT LS-CHILD LS-RAN
                 MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN "tag"
             MOVE 1 TO L-RAN
             IF LS-EXPAND = 1
                 CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ITEMS LS-MEMBER
                 CALL "LOOT-TAG-ITEMS" USING L-SLOT LS-MEMBER LS-COUNT LS-IDS
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                     COMPUTE LS-SUB = LS-ID(LS-I) + 1
                     CALL "LOOT-LEAF-ADD" USING L-SLOT L-NODE LS-SUB
                 END-PERFORM
             ELSE
                 MOVE 0 TO LS-SUB
                 CALL "LOOT-LEAF-ADD" USING L-SLOT L-NODE LS-SUB
             END-IF
         WHEN "loot_table"
             MOVE 1 TO L-RAN
             IF LS-EXPAND = 1
                 CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-VALUE LS-MEMBER
                 MOVE 1 TO LS-I
                 CALL "LOOT-TABLE-REF" USING L-SLOT LS-MEMBER LS-I LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 PERFORM UNTIL LS-OUT-NODE = 0
                     CALL "LOOT-LEAF-ADD" USING L-SLOT L-NODE LS-I
                     ADD 1 TO LS-I
                     CALL "LOOT-TABLE-REF" USING L-SLOT LS-MEMBER LS-I LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 END-PERFORM
             ELSE
                 MOVE 0 TO LS-SUB
                 CALL "LOOT-LEAF-ADD" USING L-SLOT L-NODE LS-SUB
             END-IF
         WHEN OTHER
*>           item, empty, dynamic and slots: one leaf.
             MOVE 1 TO L-RAN
             MOVE 0 TO LS-SUB
             CALL "LOOT-LEAF-ADD" USING L-SLOT L-NODE LS-SUB
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-ENTRY-EXPAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-LEAF-PRODUCE IS RECURSIVE.
*> USING slot, entry node, sub: the stacks of a chosen leaf, through the entry's modifier and the rest of the chain (5.3 step 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-NAME              PIC X(32) VALUE "name".
 01 WS-N-ITEMS             PIC X(32) VALUE "items".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-KIND                PIC X(48).
 01 LS-MEMBER              BINARY-LONG.
 01 LS-SAVED               BINARY-LONG.
 01 LS-ITEM                BINARY-LONG.
 01 LS-KEY                 PIC X(112).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-IDS.
    05 LS-ID               BINARY-LONG OCCURS 64 TIMES.
 01 LS-I                   BINARY-LONG.
 01 LS-OUT-SLOT            BINARY-LONG.
 01 LS-OUT-NODE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-SUB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-SUB.
     MOVE LW-CHAIN-COUNT TO LS-SAVED
     CALL "LOOT-PUSH-MODIFIER" USING L-SLOT L-NODE
     CALL "LOOT-J-KIND" USING L-SLOT L-NODE LS-KIND
     EVALUATE LS-KIND
         WHEN "item"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-NAME LS-MEMBER
             CALL "LOOT-J-TEXT" USING L-SLOT LS-MEMBER LS-KEY LS-LENGTH
             CALL "LOOT-ITEM-ID" USING LS-KEY LS-ITEM
             IF LS-ITEM >= 0
                 CALL "LOOT-EMIT" USING LS-ITEM WS-ONE WS-ZERO
             END-IF
         WHEN "dynamic"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-NAME LS-MEMBER
             CALL "LOOT-J-TEXT" USING L-SLOT LS-MEMBER LS-KEY LS-LENGTH
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LW-C-DYNAMIC-COUNT
                 IF LW-C-DY-NAME(LS-I) = LS-KEY(1:48)
                     CALL "LOOT-EMIT" USING LW-C-DY-ITEM(LS-I) LW-C-DY-COUNT(LS-I) LW-C-DY-HANDLE(LS-I)
                 END-IF
             END-PERFORM
         WHEN "tag"
             IF L-SUB > 0
                 COMPUTE LS-ITEM = L-SUB - 1
                 CALL "LOOT-EMIT" USING LS-ITEM WS-ONE WS-ZERO
             ELSE
                 CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ITEMS LS-MEMBER
                 CALL "LOOT-TAG-ITEMS" USING L-SLOT LS-MEMBER LS-COUNT LS-IDS
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                     CALL "LOOT-EMIT" USING LS-ID(LS-I) WS-ONE WS-ZERO
                 END-PERFORM
             END-IF
         WHEN "loot_table"
             CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-VALUE LS-MEMBER
             IF L-SUB > 0
                 CALL "LOOT-TABLE-REF" USING L-SLOT LS-MEMBER L-SUB LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 IF LS-OUT-NODE > 0
                     CALL "LOOT-TABLE-RUN" USING LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 END-IF
             ELSE
                 MOVE 1 TO LS-I
                 CALL "LOOT-TABLE-REF" USING L-SLOT LS-MEMBER LS-I LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 PERFORM UNTIL LS-OUT-NODE = 0
                     CALL "LOOT-TABLE-RUN" USING LS-OUT-SLOT LS-OUT-NODE LS-KEY
                     ADD 1 TO LS-I
                     CALL "LOOT-TABLE-REF" USING L-SLOT LS-MEMBER LS-I LS-OUT-SLOT LS-OUT-NODE LS-KEY
                 END-PERFORM
             END-IF
         WHEN OTHER
*>           empty and slots: nothing.
             CONTINUE
     END-EVALUATE
     MOVE LS-SAVED TO LW-CHAIN-COUNT
     GOBACK.
 END PROGRAM LOOT-LEAF-PRODUCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-POOL-DRAW IS RECURSIVE.
*> USING slot, pool node: one draw of a pool (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-N-ENTRIES           PIC X(32) VALUE "entries".
 LOCAL-STORAGE SECTION.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-RAN                 BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-PICK                BINARY-LONG.
 01 LS-SLOT                BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE.
     MOVE 0 TO LW-LEAF-COUNT LW-TOTAL
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ENTRIES LS-MEMBER
     MOVE 0 TO LS-CHILD
     IF LS-MEMBER > 0
         MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
     END-IF
     PERFORM UNTIL LS-CHILD = 0
         CALL "LOOT-ENTRY-EXPAND" USING L-SLOT LS-CHILD LS-RAN
         MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
     END-PERFORM
     IF LW-LEAF-COUNT = 0
         GOBACK
     END-IF
     MOVE 1 TO LS-PICK
     IF LW-LEAF-COUNT > 1
         CALL "LOOT-RNG-INT" USING LW-TOTAL LS-DRAW
         PERFORM VARYING LS-PICK FROM 1 BY 1 UNTIL LS-PICK >= LW-LEAF-COUNT
             SUBTRACT LW-LF-WEIGHT(LS-PICK) FROM LS-DRAW
             IF LS-DRAW < 0
                 EXIT PERFORM
             END-IF
         END-PERFORM
     END-IF
     MOVE LW-LF-SLOT(LS-PICK) TO LS-SLOT
     MOVE LW-LF-NODE(LS-PICK) TO LS-NODE
     MOVE LW-LF-SUB(LS-PICK) TO LS-SUB
     CALL "LOOT-LEAF-PRODUCE" USING LS-SLOT LS-NODE LS-SUB
     GOBACK.
 END PROGRAM LOOT-POOL-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-POOL-RUN IS RECURSIVE.
*> USING slot, pool node: a pool (5.2): the condition, the pool modifier, the number of rolls plus the bonus rolls by luck.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-CONDITION         PIC X(32) VALUE "condition".
 01 WS-N-ROLLS             PIC X(32) VALUE "rolls".
 01 WS-N-BONUS             PIC X(32) VALUE "bonus_rolls".
 LOCAL-STORAGE SECTION.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-SAVED               BINARY-LONG.
 01 LS-ROLLS               BINARY-LONG.
 01 LS-BONUS               FLOAT-LONG.
 01 LS-LUCK                FLOAT-LONG.
 01 LS-PRODUCT             FLOAT-LONG.
 01 LS-FLOOR               FLOAT-LONG.
 01 LS-EXTRA               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-CONDITION LS-MEMBER
     IF LS-MEMBER > 0
         CALL "LOOT-COND-EVAL" USING L-SLOT LS-MEMBER LS-OK
         IF LS-OK = 0
             GOBACK
         END-IF
     END-IF
     MOVE LW-CHAIN-COUNT TO LS-SAVED
     CALL "LOOT-PUSH-MODIFIER" USING L-SLOT L-NODE
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ROLLS LS-MEMBER
     CALL "LOOT-INT-GET" USING L-SLOT LS-MEMBER LS-ROLLS
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-BONUS LS-MEMBER
     CALL "LOOT-FLOAT-GET" USING L-SLOT LS-MEMBER LS-BONUS
     MOVE LW-C-LUCK TO LS-LUCK
     CALL "LOOT-F32" USING LS-LUCK
     CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-BONUS BY REFERENCE LS-LUCK BY REFERENCE LS-PRODUCT
     CALL "LOOT-F32" USING LS-PRODUCT
     CALL STATIC "cc_f64_floor" USING BY REFERENCE LS-PRODUCT BY REFERENCE LS-FLOOR
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE LS-FLOOR BY REFERENCE LS-EXTRA
     ADD LS-EXTRA TO LS-ROLLS
     PERFORM LS-ROLLS TIMES
         CALL "LOOT-POOL-DRAW" USING L-SLOT L-NODE
     END-PERFORM
     MOVE LS-SAVED TO LW-CHAIN-COUNT
     GOBACK.
 END PROGRAM LOOT-POOL-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TABLE-RUN IS RECURSIVE.
*> USING slot, table node, key (PIC X(112)): a table (5.1 steps 2 to 4): not rolled again while it is being rolled (a loop through
*> loot_table entries produces nothing), the table modifier, every pool in order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-N-POOLS             PIC X(32) VALUE "pools".
 LOCAL-STORAGE SECTION.
 01 LS-MEMBER              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SAVED               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-LOOPING             BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING L-SLOT L-NODE L-KEY.
     MOVE 0 TO LS-LOOPING
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LW-VIS-COUNT
         IF LW-VIS(LS-I) = L-KEY
             MOVE 1 TO LS-LOOPING
         END-IF
     END-PERFORM
     IF LS-LOOPING = 1 OR LW-VIS-COUNT >= 16
         GOBACK
     END-IF
     ADD 1 TO LW-VIS-COUNT
     MOVE L-KEY TO LW-VIS(LW-VIS-COUNT)
     MOVE LW-CHAIN-COUNT TO LS-SAVED
     CALL "LOOT-PUSH-MODIFIER" USING L-SLOT L-NODE
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-POOLS LS-MEMBER
     MOVE 0 TO LS-CHILD
     IF LS-MEMBER > 0
         MOVE LDS-JN-FIRST(L-SLOT, LS-MEMBER) TO LS-CHILD
     END-IF
     PERFORM UNTIL LS-CHILD = 0
         CALL "LOOT-POOL-RUN" USING L-SLOT LS-CHILD
         MOVE LDS-JN-NEXT(L-SLOT, LS-CHILD) TO LS-CHILD
     END-PERFORM
     MOVE LS-SAVED TO LW-CHAIN-COUNT
     SUBTRACT 1 FROM LW-VIS-COUNT
     GOBACK.
 END PROGRAM LOOT-TABLE-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ROLL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY CITEMS.
 01 WS-REGISTRY            PIC X(48) VALUE "loot_table".
 01 WS-N-SEQUENCE          PIC X(32) VALUE "random_sequence".
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-SEQUENCE            PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 COPY LOOTCTX.
 PROCEDURE DIVISION USING L-KEY LOOT-CONTEXT LOOT-RESULT.
     MOVE 1 TO LR-STATUS
     MOVE 0 TO LR-COUNT
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-KEY WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 0 TO LR-STATUS
     MOVE 1 TO WS-NODE
     CALL "LOOT-J-MEMBER" USING WS-SLOT WS-NODE WS-N-SEQUENCE WS-MEMBER
     CALL "LOOT-J-TEXT" USING WS-SLOT WS-MEMBER WS-SEQUENCE WS-LENGTH
     CALL "LOOT-ENTER" USING LOOT-CONTEXT WS-SEQUENCE
     CALL "LOOT-DOC-GET" USING WS-REGISTRY L-KEY WS-SLOT
     CALL "LOOT-TABLE-RUN" USING WS-SLOT WS-NODE L-KEY
     CALL "LOOT-RNG-SAVE"
*>   The final consumer (5.1 step 5): stacks of at most the item's stack size, in order; empty stacks are dropped.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LW-OUT-COUNT
         MOVE LW-OUT-AMOUNT(WS-I) TO WS-REST
         MOVE 64 TO WS-MAX
         IF IT-MAX-STACK(LW-OUT-ITEM(WS-I) + 1) > 0
             MOVE IT-MAX-STACK(LW-OUT-ITEM(WS-I) + 1) TO WS-MAX
         END-IF
         PERFORM UNTIL WS-REST <= 0 OR LR-COUNT >= LR-MAX-STACKS
             MOVE WS-REST TO WS-CHUNK
             IF WS-CHUNK > WS-MAX
                 MOVE WS-MAX TO WS-CHUNK
             END-IF
             ADD 1 TO LR-COUNT
             MOVE LW-OUT-ITEM(WS-I) TO LR-ITEM(LR-COUNT)
             MOVE WS-CHUNK TO LR-AMOUNT(LR-COUNT)
             MOVE LW-OUT-HANDLE(WS-I) TO LR-HANDLE(LR-COUNT)
             SUBTRACT WS-CHUNK FROM WS-REST
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-ROLL.
