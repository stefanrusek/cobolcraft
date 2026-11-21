*> Update Recipes (05b 0x88, docs/protocol 27 4.3; T3662): the recipe property sets (item id lists by key) and the stonecutter
*> single-input list (HolderSet input and SlotDisplay per entry, no recipe key). The record is PB-UPDATE-RECIPES of PROTO.cpy, the
*> displays are nodes of one PB-SLOT-DISPLAY-TABLE. The packet id is the caller's (0x88).
*> A writer appends nothing and sets PB-ERROR for a value it cannot encode; a reader that fails sets PB-ERROR, leaves PB-POS where it
*> was and yields an all-zero record and an empty table.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-UPDATE-RECIPES.
*> USING PB-BUFFER, PB-UPDATE-RECIPES, PB-SLOT-DISPLAY-TABLE: VarInt set count, per set the key as an Identifier and a Prefixed
*> Array of RegistryId<item>; VarInt cut count, per entry a HolderSet<item> (selector 0 and a tag key when PB-UC-TAG-LENGTH is above
*> 0, else selector count + 1 and the ids of PB-UC-INPUT) and the SlotDisplay of node PB-UC-DISPLAY. A count outside its range, a
*> negative item id, an invalid key or a display PB-PUT-SLOT-DISPLAY-NODE rejects appends nothing and sets PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SELECTOR            BINARY-LONG.
 01 WS-NO-PARENT           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE.
     MOVE PB-LENGTH TO WS-START
     IF PB-UR-SET-COUNT < 0 OR PB-UR-SET-COUNT > PB-UR-MAX-SETS
             OR PB-UR-CUT-COUNT < 0 OR PB-UR-CUT-COUNT > PB-UR-MAX-CUTS
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-UR-SET-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-SET-COUNT
         IF PB-UR-ITEM-COUNT(WS-I) < 0 OR PB-UR-ITEM-COUNT(WS-I) > PB-UR-MAX-ITEMS
             MOVE 1 TO PB-ERROR
         END-IF
         IF PB-ERROR = 0
             CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER PB-UR-KEY(WS-I) PB-UR-KEY-LENGTH(WS-I)
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-UR-ITEM-COUNT(WS-I)
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(WS-I) OR PB-ERROR = 1
             IF PB-UR-ITEM(WS-I, WS-J) < 0
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-UR-ITEM(WS-I, WS-J)
             END-IF
         END-PERFORM
     END-PERFORM
     IF PB-ERROR = 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-UR-CUT-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-CUT-COUNT OR PB-ERROR = 1
         EVALUATE TRUE
             WHEN PB-UC-TAG-LENGTH(WS-I) > 0
                 CALL "PB-PUT-SLOT-TAG" USING PB-BUFFER PB-UC-TAG(WS-I) PB-UC-TAG-LENGTH(WS-I)
             WHEN PB-UC-INPUT-COUNT(WS-I) < 0 OR PB-UC-INPUT-COUNT(WS-I) > PB-UR-MAX-INPUTS
                 MOVE 1 TO PB-ERROR
             WHEN OTHER
                 COMPUTE WS-SELECTOR = PB-UC-INPUT-COUNT(WS-I) + 1
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SELECTOR
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UC-INPUT-COUNT(WS-I)
                     IF PB-UC-INPUT(WS-I, WS-J) < 0
                         MOVE 1 TO PB-ERROR
                     ELSE
                         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-UC-INPUT(WS-I, WS-J)
                     END-IF
                 END-PERFORM
         END-EVALUATE
         IF PB-ERROR = 0
             CALL "PB-PUT-SLOT-DISPLAY-NODE" USING PB-BUFFER PB-SLOT-DISPLAY-TABLE PB-UC-DISPLAY(WS-I)
                 WS-NO-PARENT
         END-IF
     END-PERFORM
     IF PB-ERROR = 1
         MOVE WS-START TO PB-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-UPDATE-RECIPES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-UPDATE-RECIPES.
*> USING PB-BUFFER, PB-UPDATE-RECIPES out, PB-SLOT-DISPLAY-TABLE out: one Update Recipes body (layout of PB-PUT-UPDATE-RECIPES); the
*> display nodes are numbered in the order read. A count outside its range, an invalid key, a slot display
*> PB-GET-SLOT-DISPLAY-NODE rejects or a short read sets PB-ERROR, leaves PB-POS where it was and yields an all-zero record and an
*> empty table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SELECTOR            BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-UR-SET-COUNT
     IF PB-UR-SET-COUNT < 0 OR PB-UR-SET-COUNT > PB-UR-MAX-SETS
         MOVE 1 TO PB-ERROR
         MOVE 0 TO PB-UR-SET-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-SET-COUNT OR PB-ERROR = 1
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PB-UR-KEY(WS-I) WS-CAPACITY PB-UR-KEY-LENGTH(WS-I)
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-UR-ITEM-COUNT(WS-I)
         IF PB-UR-ITEM-COUNT(WS-I) < 0 OR PB-UR-ITEM-COUNT(WS-I) > PB-UR-MAX-ITEMS
             MOVE 1 TO PB-ERROR
             MOVE 0 TO PB-UR-ITEM-COUNT(WS-I)
         END-IF
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(WS-I)
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-UR-ITEM(WS-I, WS-J)
         END-PERFORM
     END-PERFORM
     IF PB-ERROR = 0
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-UR-CUT-COUNT
     END-IF
     IF PB-UR-CUT-COUNT < 0 OR PB-UR-CUT-COUNT > PB-UR-MAX-CUTS
         MOVE 1 TO PB-ERROR
         MOVE 0 TO PB-UR-CUT-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-CUT-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SELECTOR
         EVALUATE TRUE
             WHEN WS-SELECTOR = 0
                 CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PB-UC-TAG(WS-I) WS-CAPACITY PB-UC-TAG-LENGTH(WS-I)
             WHEN WS-SELECTOR < 0 OR WS-SELECTOR > PB-UR-MAX-INPUTS + 1
                 MOVE 1 TO PB-ERROR
             WHEN OTHER
                 COMPUTE PB-UC-INPUT-COUNT(WS-I) = WS-SELECTOR - 1
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UC-INPUT-COUNT(WS-I)
                     CALL "PB-GET-VARINT" USING PB-BUFFER PB-UC-INPUT(WS-I, WS-J)
                 END-PERFORM
         END-EVALUATE
         IF PB-ERROR = 0
             CALL "PB-GET-SLOT-DISPLAY-NODE" USING PB-BUFFER PB-SLOT-DISPLAY-TABLE WS-NODE
             MOVE WS-NODE TO PB-UC-DISPLAY(WS-I)
         END-IF
     END-PERFORM
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     END-IF
     GOBACK.
 END PROGRAM PB-GET-UPDATE-RECIPES.
