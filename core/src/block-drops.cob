*> Block drops from loot tables (T0437; docs/protocol/26-loot-and-predicates.md section 11.1 and 11.2, 5.1; 41 section 2 for the ground item). The table of a
*> block is blocks/<path of its key> in the namespace of its key (a key without namespace is minecraft:), for example
*> cobolcraft:blocks/greystone for cobolcraft:greystone and minecraft:blocks/diamond_ore for diamond_ore. The context is the block set
*> (11.1 step 1): block_state, origin (the block's centre), tool and, for an explosion that decays its drops, explosion_radius
*> (11.2 step 3); the roll uses the table's random sequence of the world seed (CW-SEED). Each stack is spawned as a ground item
*> through GI-SPAWN at (x + 0.5, y + 0.25, z + 0.5) with the pickup delay of a block break (RULES.cpy), as GI-BLOCK-YIELD does.
*> A stack's component patch (damage, enchantments) cannot ride a ground item yet (the ground item row has no patch handle): the
*> item and the count are spawned and the handle is dropped (BLOCKED on GI-SPAWN-X of the play lane).
*> Entry points:
*>   BLOCK-DROPS-SPAWN USING dimension row, x, y, z, state (the state that was broken), tool item, tool count, tool handle
*>     (a tool of count 0 is the empty hand), radius set (1 when the explosion decays its drops), radius (FLOAT-LONG), found out
*>     (1 when the block has a table: its stacks were spawned; 0 when it has none: nothing happened)
*>   BLOCK-DROPS USING dimension row, x, y, z, state, block id (0 based), player row: a survival player's break (BREAK-FINISH): the
*>     drops of the table of the block when the held tool is the correct tool for drops (11.1 step 3: a block that requires a
*>     tool gives nothing to another tool), or, for a block that has no table, the stand-in yield (GI-BLOCK-YIELD)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-DROPS-KEY.
*> USING state, key out (PIC X(112)): the loot table key of the block of a state (11.1 step 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAMESPACE           PIC X(48).
 01 WS-PATH                PIC X(48).
 01 WS-COLON               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-KEY                  PIC X(112).
 PROCEDURE DIVISION USING L-STATE L-KEY.
     COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     MOVE 0 TO WS-COLON
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-COLON FOR ALL ":"
     MOVE SPACES TO L-KEY WS-NAMESPACE WS-PATH
     IF WS-COLON = 0
         MOVE "minecraft" TO WS-NAMESPACE
         MOVE CB-KEY(WS-BLOCK) TO WS-PATH
     ELSE
         UNSTRING CB-KEY(WS-BLOCK) DELIMITED BY ":" INTO WS-NAMESPACE WS-PATH
     END-IF
     STRING FUNCTION TRIM(WS-NAMESPACE) ":blocks/" FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO L-KEY
     GOBACK.
 END PROGRAM BLOCK-DROPS-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-DROPS-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY RULES.
 COPY LOOTCTX.
 01 WS-REGISTRY            PIC X(48) VALUE "loot_table".
 01 WS-KEY                 PIC X(112).
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TOOL                 BINARY-LONG.
 01 L-TOOL-COUNT           BINARY-LONG.
 01 L-TOOL-HANDLE          BINARY-LONG.
 01 L-RADIUS-SET           BINARY-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-TOOL L-TOOL-COUNT L-TOOL-HANDLE L-RADIUS-SET L-RADIUS
         L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "BLOCK-DROPS-KEY" USING L-STATE WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-FOUND
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET LC-STATE-SET LC-TOOL-SET
     COMPUTE LC-X = L-X + 0.5
     COMPUTE LC-Y = L-Y + 0.5
     COMPUTE LC-Z = L-Z + 0.5
     MOVE L-STATE TO LC-STATE
     MOVE L-TOOL TO LC-TOOL-ITEM
     MOVE L-TOOL-COUNT TO LC-TOOL-COUNT
     MOVE L-TOOL-HANDLE TO LC-TOOL-HANDLE
     MOVE L-RADIUS-SET TO LC-RADIUS-SET
     MOVE L-RADIUS TO LC-RADIUS
     MOVE CW-SEED TO LC-WORLD-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     MOVE RULE-GI-BREAK-DELAY TO WS-DELAY
     COMPUTE WS-X = L-X + RULE-GI-BREAK-DXZ-MILLI / 1000
     COMPUTE WS-Y = L-Y + RULE-GI-BREAK-DY-MILLI / 1000
     COMPUTE WS-Z = L-Z + RULE-GI-BREAK-DXZ-MILLI / 1000
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
         CALL "GI-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ LR-ITEM(WS-I) LR-AMOUNT(WS-I) WS-DELAY WS-ROW
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-DROPS-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-DROPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-CLASS-OK            BINARY-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-CORRECT             BINARY-LONG.
 01 WS-BLOCK-ROW           BINARY-LONG.
 01 WS-NO-RADIUS           BINARY-LONG VALUE 0.
 01 WS-RADIUS              FLOAT-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "loot_table".
 01 WS-KEY                 PIC X(112).
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-BLOCK L-PLAYER.
     COMPUTE WS-HELD = PL-HELD(L-PLAYER) + 1
     MOVE 0 TO WS-ITEM WS-COUNT WS-HANDLE
     IF PL-SLOT-COUNT(L-PLAYER, WS-HELD) > 0
         MOVE PL-SLOT-ITEM(L-PLAYER, WS-HELD) TO WS-ITEM
         MOVE PL-SLOT-COUNT(L-PLAYER, WS-HELD) TO WS-COUNT
         MOVE PL-SLOT-VAR(L-PLAYER, WS-HELD) TO WS-HANDLE
     END-IF
*>   hasCorrectToolForDrops: any tool when the block does not require one, else a tool of the block's class whose tier
*>   reaches the block's (the rule of BREAK-CORRECT).
     COMPUTE WS-BLOCK-ROW = L-BLOCK + 1
     MOVE 0 TO WS-CLASS-OK WS-TIER
     IF CB-CLASS(WS-BLOCK-ROW) NOT = CB-CLASS-NONE AND IT-TOOL-CLASS(WS-ITEM + 1) = CB-CLASS(WS-BLOCK-ROW)
         MOVE 1 TO WS-CLASS-OK
         MOVE IT-TOOL-TIER(WS-ITEM + 1) TO WS-TIER
     END-IF
     CALL "BREAK-CORRECT" USING CB-TOOL-REQ(WS-BLOCK-ROW) WS-CLASS-OK WS-TIER CB-NEED-TIER(WS-BLOCK-ROW) WS-CORRECT
     CALL "BLOCK-DROPS-KEY" USING L-STATE WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     EVALUATE TRUE
         WHEN WS-SLOT = 0
             CALL "GI-BLOCK-YIELD" USING L-DIM L-X L-Y L-Z L-BLOCK
         WHEN WS-CORRECT = 1
             CALL "BLOCK-DROPS-SPAWN" USING L-DIM L-X L-Y L-Z L-STATE WS-ITEM WS-COUNT WS-HANDLE WS-NO-RADIUS
                 WS-RADIUS WS-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCK-DROPS.
