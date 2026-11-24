*> The lazy fill of a container that carries a loot table (docs/protocol/26-loot-and-predicates.md section 11.6 and 5.4; 31-block-entities-1 section 9.3).
*> Worldgen leaves BE-LOOT (the table key) and BE-SEED in a chest (gen-be.cob); the first open (MENU-CONT-OPEN, each half of a double chest) or the
*> break of the block (BE-DROP-CONTENTS, no player) calls BE-LOOT-FILL, which clears the key (BE-LOOT-UNPACK) and rolls the table with LOOT-ROLL:
*> origin = the block centre, this_entity = the player when there is one (luck 0: no luck attribute is held), seed = BE-SEED (0: the level's random,
*> section 4 step 4). The fill (LootTable.fill, 5.4) then runs on the context random, the same source the roll used: the empty slots shuffled
*> (Util.shuffle, section 4 step 7), the stacks with count above 1 split while there are more slots than stacks (Mth.nextInt picks; the remainder and then the
*> split-off stack go back to the split list when their count is above 1 and nextBoolean is true), the list shuffled, and each stack put in the last
*> remaining slot. A table the content set does not hold fills nothing (the key is cleared all the same). The generate_loot advancement trigger is not
*> fired (the core has no advancements). Splitting an item entity of a hopper's access is not done: the core has no hopper transfer.
*> Entry point: BE-LOOT-FILL USING block entity index, player row (0: none)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-LOOT-FILL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY LOOTCTX.
 01 WS-TABLE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-SLOT-COUNT          BINARY-LONG.
 01 WS-SLOT-LIST.
    05 WS-SLOT-AT          BINARY-LONG OCCURS 27 TIMES.
 01 WS-L-COUNT             BINARY-LONG.
 01 WS-L-LIST.
    05 WS-L                OCCURS 160 TIMES.
       10 WS-L-ITEM        BINARY-LONG.
       10 WS-L-AMOUNT      BINARY-LONG.
       10 WS-L-HANDLE      BINARY-LONG.
 01 WS-S-COUNT             BINARY-LONG.
 01 WS-S-LIST.
    05 WS-S                OCCURS 160 TIMES.
       10 WS-S-ITEM        BINARY-LONG.
       10 WS-S-AMOUNT      BINARY-LONG.
       10 WS-S-HANDLE      BINARY-LONG.
 01 WS-CUR-ITEM            BINARY-LONG.
 01 WS-CUR-AMOUNT          BINARY-LONG.
 01 WS-CUR-HANDLE          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-PIECE-AMOUNT        BINARY-LONG.
 01 WS-REST-AMOUNT         BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROW.
     CALL "BE-LOOT-UNPACK" USING L-INDEX WS-TABLE WS-LENGTH WS-SEED WS-RESULT
     IF WS-RESULT = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE WS-TABLE(1:WS-LENGTH) TO WS-KEY
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET
     COMPUTE LC-X = BE-X(L-INDEX) + 0.5
     COMPUTE LC-Y = BE-Y(L-INDEX) + 0.5
     COMPUTE LC-Z = BE-Z(L-INDEX) + 0.5
     IF L-ROW > 0
         MOVE 1 TO LC-THIS-SET
         MOVE "minecraft:player" TO LC-THIS-TYPE
     END-IF
     MOVE WS-SEED TO LC-SEED
     MOVE CW-SEED TO LC-WORLD-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     IF LR-STATUS NOT = 0
         GOBACK
     END-IF
*>   The empty slots, shuffled.
     MOVE 0 TO WS-SLOT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         IF BE-SLOT-COUNT(L-INDEX, WS-I) = 0
             ADD 1 TO WS-SLOT-COUNT
             MOVE WS-I TO WS-SLOT-AT(WS-SLOT-COUNT)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM WS-SLOT-COUNT BY -1 UNTIL WS-I < 2
         CALL "LOOT-RNG-INT" USING WS-I WS-J
         ADD 1 TO WS-J
         MOVE WS-SLOT-AT(WS-I) TO WS-K
         MOVE WS-SLOT-AT(WS-J) TO WS-SLOT-AT(WS-I)
         MOVE WS-K TO WS-SLOT-AT(WS-J)
     END-PERFORM
*>   Stacks above 1 go to the split list, the rest stay.
     MOVE 0 TO WS-L-COUNT WS-S-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
         IF LR-AMOUNT(WS-I) > 1
             ADD 1 TO WS-S-COUNT
             MOVE LR-ITEM(WS-I) TO WS-S-ITEM(WS-S-COUNT)
             MOVE LR-AMOUNT(WS-I) TO WS-S-AMOUNT(WS-S-COUNT)
             MOVE LR-HANDLE(WS-I) TO WS-S-HANDLE(WS-S-COUNT)
         ELSE
             ADD 1 TO WS-L-COUNT
             MOVE LR-ITEM(WS-I) TO WS-L-ITEM(WS-L-COUNT)
             MOVE LR-AMOUNT(WS-I) TO WS-L-AMOUNT(WS-L-COUNT)
             MOVE LR-HANDLE(WS-I) TO WS-L-HANDLE(WS-L-COUNT)
         END-IF
     END-PERFORM
*>   Split while there are more slots than stacks.
     PERFORM UNTIL WS-SLOT-COUNT - WS-L-COUNT - WS-S-COUNT <= 0 OR WS-S-COUNT = 0
         MOVE 1 TO WS-J
         IF WS-S-COUNT > 1
             CALL "LOOT-RNG-INT" USING WS-S-COUNT WS-J
             ADD 1 TO WS-J
         END-IF
         MOVE WS-S-ITEM(WS-J) TO WS-CUR-ITEM
         MOVE WS-S-AMOUNT(WS-J) TO WS-CUR-AMOUNT
         MOVE WS-S-HANDLE(WS-J) TO WS-CUR-HANDLE
         PERFORM VARYING WS-I FROM WS-J BY 1 UNTIL WS-I >= WS-S-COUNT
             MOVE WS-S(WS-I + 1) TO WS-S(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM WS-S-COUNT
         COMPUTE WS-HALF = WS-CUR-AMOUNT / 2
         MOVE 1 TO WS-K
         IF WS-HALF > 1
             CALL "LOOT-RNG-INT" USING WS-HALF WS-K
             ADD 1 TO WS-K
         END-IF
         MOVE WS-K TO WS-PIECE-AMOUNT
         COMPUTE WS-REST-AMOUNT = WS-CUR-AMOUNT - WS-K
*>       The remainder first, then the split-off stack.
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
             IF WS-I = 1
                 MOVE WS-REST-AMOUNT TO WS-TARGET
             ELSE
                 MOVE WS-PIECE-AMOUNT TO WS-TARGET
             END-IF
             MOVE 0 TO WS-BOOL
             IF WS-TARGET > 1
                 CALL "LOOT-RNG-BOOL" USING WS-BOOL
             END-IF
             IF WS-BOOL = 1
                 ADD 1 TO WS-S-COUNT
                 MOVE WS-CUR-ITEM TO WS-S-ITEM(WS-S-COUNT)
                 MOVE WS-TARGET TO WS-S-AMOUNT(WS-S-COUNT)
                 MOVE WS-CUR-HANDLE TO WS-S-HANDLE(WS-S-COUNT)
             ELSE
                 ADD 1 TO WS-L-COUNT
                 MOVE WS-CUR-ITEM TO WS-L-ITEM(WS-L-COUNT)
                 MOVE WS-TARGET TO WS-L-AMOUNT(WS-L-COUNT)
                 MOVE WS-CUR-HANDLE TO WS-L-HANDLE(WS-L-COUNT)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-S-COUNT
         ADD 1 TO WS-L-COUNT
         MOVE WS-S(WS-I) TO WS-L(WS-L-COUNT)
     END-PERFORM
     PERFORM VARYING WS-I FROM WS-L-COUNT BY -1 UNTIL WS-I < 2
         CALL "LOOT-RNG-INT" USING WS-I WS-J
         ADD 1 TO WS-J
         MOVE WS-L(WS-I) TO WS-S(1)
         MOVE WS-L(WS-J) TO WS-L(WS-I)
         MOVE WS-S(1) TO WS-L(WS-J)
     END-PERFORM
     CALL "LOOT-RNG-SAVE"
*>   Each stack goes to the last remaining slot; with no slot left the rest is lost (the over-fill of 5.4).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-L-COUNT OR WS-SLOT-COUNT = 0
         MOVE WS-SLOT-AT(WS-SLOT-COUNT) TO WS-K
         SUBTRACT 1 FROM WS-SLOT-COUNT
         MOVE WS-L-ITEM(WS-I) TO BE-SLOT-ITEM(L-INDEX, WS-K)
         MOVE WS-L-AMOUNT(WS-I) TO BE-SLOT-COUNT(L-INDEX, WS-K)
         MOVE WS-L-HANDLE(WS-I) TO BE-SLOT-VAR(L-INDEX, WS-K)
     END-PERFORM
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM BE-LOOT-FILL.
