*> Item data loot functions that need no system the core lacks (T0436; docs/protocol/26-loot-and-predicates.md section 7.3; component ids and wire forms of
*> 46 section 8.1 and 25-3 section 5.2). Called from LOOT-FN-APPLY (loot-function.cob) after the function's condition held.
*>   LOOT-SET-OMINOUS USING slot, function node, handle (in and out): set_ominous_bottle_amplifier: component 65 (ominous_bottle_amplifier, a VarInt)
*>     = clamp(amplifier.getInt, 0, 4).
*>   LOOT-COPY-STATE USING slot, function node, handle (in and out): copy_state: with a block state in the context, the component 78 (block_state:
*>     a map of UTF-8 strings, VarInt count then the pairs) gets the value of each listed property the state has (BlockItemStateProperties.with: a
*>     property already in the map is replaced); the stack's component is set even when no listed property is copied (the update of an empty
*>     default). Assumptions: the entries keep the order of the stack's map then the function's list (the order of a Java map is not specified);
*>     the component value is held in 64 bytes, so entries that would not fit are left out. Without a block state the stack is unchanged.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SET-OMINOUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-AMPLIFIER         PIC X(32) VALUE "amplifier".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 65.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-AMPLIFIER WS-MEMBER
     CALL "LOOT-INT-GET" USING L-SLOT WS-MEMBER WS-LEVEL
     IF WS-LEVEL < 0
         MOVE 0 TO WS-LEVEL
     END-IF
     IF WS-LEVEL > 4
         MOVE 4 TO WS-LEVEL
     END-IF
     MOVE SPACES TO WS-VALUE
     MOVE FUNCTION CHAR(WS-LEVEL + 1) TO WS-VALUE(1:1)
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     GOBACK.
 END PROGRAM LOOT-SET-OMINOUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-COPY-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTPROPS.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-N-PROPERTIES        PIC X(32) VALUE "properties".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 78.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MAP.
    05 WS-ENTRY OCCURS 16 TIMES.
       10 WS-E-NAME        PIC X(24).
       10 WS-E-NAME-LEN    BINARY-LONG.
       10 WS-E-VALUE       PIC X(32).
       10 WS-E-VALUE-LEN   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE.
     IF LW-C-STATE-SET NOT = 1
         GOBACK
     END-IF
     CALL "CONTENT-STATE-PROPS" USING LW-C-STATE CT-PROPS WS-STATUS
*>   The map the stack has (single byte lengths: the value is 64 bytes at most).
     MOVE 0 TO WS-COUNT
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         MOVE FUNCTION ORD(WS-VALUE(1:1)) TO WS-J
         SUBTRACT 1 FROM WS-J
         MOVE 2 TO WS-POS
         PERFORM WS-J TIMES
             IF WS-COUNT < 16
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-E-NAME-LEN(WS-COUNT) = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
                 MOVE SPACES TO WS-E-NAME(WS-COUNT)
                 MOVE WS-VALUE(WS-POS + 1:WS-E-NAME-LEN(WS-COUNT)) TO WS-E-NAME(WS-COUNT)
                 COMPUTE WS-POS = WS-POS + 1 + WS-E-NAME-LEN(WS-COUNT)
                 COMPUTE WS-E-VALUE-LEN(WS-COUNT) = FUNCTION ORD(WS-VALUE(WS-POS:1)) - 1
                 MOVE SPACES TO WS-E-VALUE(WS-COUNT)
                 MOVE WS-VALUE(WS-POS + 1:WS-E-VALUE-LEN(WS-COUNT)) TO WS-E-VALUE(WS-COUNT)
                 COMPUTE WS-POS = WS-POS + 1 + WS-E-VALUE-LEN(WS-COUNT)
             END-IF
         END-PERFORM
     END-IF
*>   Each listed property the state has: replaced when in the map, else appended.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-PROPERTIES WS-MEMBER
     MOVE 0 TO WS-CHILD
     IF WS-MEMBER > 0
         MOVE LDS-JN-FIRST(L-SLOT, WS-MEMBER) TO WS-CHILD
     END-IF
     PERFORM UNTIL WS-CHILD = 0
         CALL "LOOT-J-TEXT" USING L-SLOT WS-CHILD WS-TEXT WS-TEXT-LENGTH
         MOVE SPACES TO WS-NAME
         IF WS-TEXT-LENGTH > 0 AND WS-TEXT-LENGTH <= 24
             MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO WS-NAME
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
                 IF CTP-NAME(WS-I) = WS-NAME
*>                   Set (the name, the state's value) in the map: out of it when there, the rest closes up, then appended.
                     MOVE 0 TO WS-HIT
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                         IF WS-E-NAME(WS-J) = WS-NAME
                             MOVE WS-J TO WS-HIT
                         END-IF
                     END-PERFORM
                     IF WS-HIT > 0
                         PERFORM VARYING WS-J FROM WS-HIT BY 1 UNTIL WS-J >= WS-COUNT
                             MOVE WS-ENTRY(WS-J + 1) TO WS-ENTRY(WS-J)
                         END-PERFORM
                         SUBTRACT 1 FROM WS-COUNT
                     END-IF
                     ADD 1 TO WS-COUNT
                     MOVE WS-NAME TO WS-E-NAME(WS-COUNT)
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-E-NAME-LEN(WS-COUNT)
                     MOVE CTP-VALUE(WS-I) TO WS-E-VALUE(WS-COUNT)
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-VALUE(WS-I))) TO WS-E-VALUE-LEN(WS-COUNT)
                 END-IF
             END-PERFORM
         END-IF
         MOVE LDS-JN-NEXT(L-SLOT, WS-CHILD) TO WS-CHILD
     END-PERFORM
*>   Encode what fits in 64 bytes.
     MOVE SPACES TO WS-VALUE
     MOVE 2 TO WS-POS
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-TOTAL = WS-POS + 2 + WS-E-NAME-LEN(WS-I) + WS-E-VALUE-LEN(WS-I)
         IF WS-TOTAL <= 65
             MOVE FUNCTION CHAR(WS-E-NAME-LEN(WS-I) + 1) TO WS-VALUE(WS-POS:1)
             MOVE WS-E-NAME(WS-I)(1:WS-E-NAME-LEN(WS-I)) TO WS-VALUE(WS-POS + 1:WS-E-NAME-LEN(WS-I))
             COMPUTE WS-POS = WS-POS + 1 + WS-E-NAME-LEN(WS-I)
             MOVE FUNCTION CHAR(WS-E-VALUE-LEN(WS-I) + 1) TO WS-VALUE(WS-POS:1)
             MOVE WS-E-VALUE(WS-I)(1:WS-E-VALUE-LEN(WS-I)) TO WS-VALUE(WS-POS + 1:WS-E-VALUE-LEN(WS-I))
             COMPUTE WS-POS = WS-POS + 1 + WS-E-VALUE-LEN(WS-I)
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     MOVE FUNCTION CHAR(WS-J + 1) TO WS-VALUE(1:1)
     COMPUTE WS-LENGTH = WS-POS - 1
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH
     GOBACK.
 END PROGRAM LOOT-COPY-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SET-POTION.
*> USING slot, function node, handle (in and out): set_potion (26 section 7.3): potion_contents (53) holds the potion of "id" (a key with or without minecraft:), the custom effects, colour and name of
*> an existing component kept as they are; a key that names no potion leaves the stack alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-ID                PIC X(32) VALUE "id".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-POTION              BINARY-LONG.
 COPY POTREC.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-HANDLE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-ID WS-MEMBER
     CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-TEXT WS-LENGTH
     IF WS-LENGTH = 0 OR WS-LENGTH > 32
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE WS-TEXT(1:WS-LENGTH) TO WS-KEY
     CALL "SC-POTION-ID" USING WS-KEY WS-POTION
     IF WS-POTION >= 0
         CALL "SC-POTION-READ" USING L-HANDLE PR-REC
         MOVE WS-POTION TO PR-POTION
         CALL "SC-POTION-WRITE" USING L-HANDLE PR-REC
     END-IF
     GOBACK.
 END PROGRAM LOOT-SET-POTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-ENCH-LEVELS.
*> USING slot, function node, item, handle (item and handle in and out): enchant_with_levels (26 section 7.3, 17 section 6.5): the selection of the enchanting table at "levels" (an int provider)
*> over the pool "options" (a tag with its #; every enchantment of the registry without it) with the loot context's random; a book becomes an enchanted book, the pairs join the stack's
*> enchantments (13) or stored_enchantments (45). Gaps: options as a single key or a list of keys is read as every enchantment; additional_trade_cost is not set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-LEVELS            PIC X(32) VALUE "levels".
 01 WS-N-OPTIONS           PIC X(32) VALUE "options".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-POOL                PIC X(112).
 01 WS-ST                  BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-ITEM L-HANDLE.
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-LEVELS WS-MEMBER
     CALL "LOOT-INT-GET" USING L-SLOT WS-MEMBER WS-LEVELS
     MOVE SPACES TO WS-POOL
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-OPTIONS WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-TEXT WS-LENGTH
         IF WS-LENGTH > 1 AND WS-TEXT(1:1) = "#"
             MOVE WS-TEXT(2:111) TO WS-POOL
         END-IF
     END-IF
     CALL "ENCH-APPLY-LEVELS" USING WS-ST WS-MODE WS-POOL L-ITEM L-HANDLE WS-LEVELS WS-COUNT
     GOBACK.
 END PROGRAM LOOT-ENCH-LEVELS.
