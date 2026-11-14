*> The Update Recipes packet of the join (docs/protocol/27 section 4.3, 05b 0x88; T3662): the recipe property sets and the stonecutter
*> list, built from the recipe store (CTRECIPE.cpy) with the proto record PB-UPDATE-RECIPES (PROTO.cpy, proto/src/update-recipes.cob).
*> Property sets, in the order of 27 4.3: smithing_base (field 2 of a smithing recipe), smithing_template (field 1), smithing_addition
*> (field 3), furnace_input, blast_furnace_input, smoker_input and campfire_input (the ingredient of smelting, blasting, smoking and
*> campfire cooking recipes). Each is the union of the ingredient items of the matching recipes, in the order met, a "#" tag expanded to
*> its members; the brewing sets are not built (the loader does not read brewing ingredients). The stonecutter list has an entry
*> for each stonecutting recipe whose ingredient is one tag or one to eight item keys and whose result item is known: the input
*> HolderSet and the result as an item stack display, one node of the table each, so the list holds at most PB-UR-MAX-CUTS (32)
*> entries (the table PB-SLOT-DISPLAY-TABLE holds 32 nodes: a standard data tree with more stonecutting recipes is cut at 32).
*>
*> Entry points:
*>   RECIPES-UPDATE-BUILD USING PB-UPDATE-RECIPES, PB-SLOT-DISPLAY-TABLE   fills both from the store
*>   RECIPES-UPDATE-SEND USING connection id                                the packet 0x88 to the connection
*>   RECIPES-UPDATE-TAG USING registry, tag key, set number, PB-UPDATE-RECIPES   adds the members of a tag to a set
*>   RECIPES-UPDATE-INGREDIENT USING ingredient, set number, PB-UPDATE-RECIPES   adds the items of an ingredient text to a set

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-UPDATE-TAG.
*> USING registry (PIC X(48)), tag key (PIC X(112), without "#"), set number (BINARY-LONG, 1 to 8), PB-UPDATE-RECIPES: every member of
*> the tag that the set does not hold yet is appended to the set (up to PB-UR-MAX-ITEMS); an unknown tag adds nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 1024 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-TAG                  PIC X(112).
 01 L-SET                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-REGISTRY L-TAG L-SET PB-UPDATE-RECIPES.
     CALL "CONTENT-TAG-MEMBERS" USING L-REGISTRY L-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE 0 TO WS-KNOWN
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(L-SET)
             IF PB-UR-ITEM(L-SET, WS-J) = WS-ID(WS-I)
                 MOVE 1 TO WS-KNOWN
             END-IF
         END-PERFORM
         IF WS-KNOWN = 0 AND PB-UR-ITEM-COUNT(L-SET) < PB-UR-MAX-ITEMS
             ADD 1 TO PB-UR-ITEM-COUNT(L-SET)
             MOVE WS-ID(WS-I) TO PB-UR-ITEM(L-SET, PB-UR-ITEM-COUNT(L-SET))
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPES-UPDATE-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-UPDATE-INGREDIENT.
*> USING ingredient (PIC X(800): item keys and "#" tags separated by single spaces), set number, PB-UPDATE-RECIPES: the item of each key
*> that is known and not in the set yet is appended to it; a tag goes through RECIPES-UPDATE-TAG over the item registry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-TOKEN               PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INGREDIENT           PIC X(800).
 01 L-SET                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-INGREDIENT L-SET PB-UPDATE-RECIPES.
     MOVE 1 TO WS-POINTER
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(L-INGREDIENT TRAILING))
     IF L-INGREDIENT = SPACES
         MOVE 0 TO WS-END
     END-IF
     PERFORM UNTIL WS-POINTER > WS-END
         MOVE SPACES TO WS-TOKEN
         UNSTRING L-INGREDIENT DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN(1:1) = "#"
             MOVE WS-TOKEN(2:111) TO WS-KEY
             CALL "RECIPES-UPDATE-TAG" USING WS-REGISTRY WS-KEY L-SET PB-UPDATE-RECIPES
         ELSE
             IF WS-TOKEN NOT = SPACES
                 MOVE WS-TOKEN TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
                 MOVE 0 TO WS-KNOWN
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(L-SET)
                     IF PB-UR-ITEM(L-SET, WS-J) = WS-ID
                         MOVE 1 TO WS-KNOWN
                     END-IF
                 END-PERFORM
                 IF WS-STATUS = CT-OK AND WS-KNOWN = 0 AND PB-UR-ITEM-COUNT(L-SET) < PB-UR-MAX-ITEMS
                     ADD 1 TO PB-UR-ITEM-COUNT(L-SET)
                     MOVE WS-ID TO PB-UR-ITEM(L-SET, PB-UR-ITEM-COUNT(L-SET))
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPES-UPDATE-INGREDIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-UPDATE-CUT.
*> USING recipe row (BINARY-LONG), PB-UPDATE-RECIPES, PB-SLOT-DISPLAY-TABLE: the stonecutter entry of a stonecutting recipe: the input
*> as one tag or one to eight known item keys, the display a new item_stack node of the result. Nothing is added when the ingredient is
*> a tag mixed with items, has an unknown item or more than eight items, the result is unknown, or the list or the table is full.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-TOKEN               PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-ID                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TAGS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-RECIPE               BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-RECIPE PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE.
     IF PB-UR-CUT-COUNT >= PB-UR-MAX-CUTS OR PB-SDT-COUNT >= PB-SDT-MAX-NODES
         GOBACK
     END-IF
     MOVE RR-RESULT-ID(L-RECIPE) TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-RESULT WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE 0 TO WS-N WS-TAGS WS-BAD
     MOVE 1 TO WS-POINTER
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(RR-ING(L-RECIPE, 1) TRAILING))
     IF RR-ING(L-RECIPE, 1) = SPACES
         MOVE 0 TO WS-END
     END-IF
     PERFORM UNTIL WS-POINTER > WS-END
         MOVE SPACES TO WS-TOKEN
         UNSTRING RR-ING(L-RECIPE, 1) DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES
             ADD 1 TO WS-N
             IF WS-TOKEN(1:1) = "#"
                 ADD 1 TO WS-TAGS
                 MOVE WS-TOKEN(2:111) TO WS-KEY
             ELSE
                 MOVE WS-TOKEN TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
                 IF WS-STATUS NOT = CT-OK
                     MOVE 1 TO WS-BAD
                 END-IF
                 IF WS-N <= 9
                     MOVE WS-ID TO WS-L(WS-N)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N = 0 OR WS-BAD = 1 OR WS-N > PB-UR-MAX-INPUTS OR (WS-TAGS > 0 AND WS-N > 1)
             OR FUNCTION LENGTH(FUNCTION TRIM(WS-KEY TRAILING)) > 64
         GOBACK
     END-IF
     ADD 1 TO PB-UR-CUT-COUNT
     IF WS-TAGS = 1
         MOVE WS-KEY TO PB-UC-TAG(PB-UR-CUT-COUNT)
         COMPUTE PB-UC-TAG-LENGTH(PB-UR-CUT-COUNT) = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY TRAILING))
     ELSE
         MOVE WS-N TO PB-UC-INPUT-COUNT(PB-UR-CUT-COUNT)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             MOVE WS-L(WS-I) TO PB-UC-INPUT(PB-UR-CUT-COUNT, WS-I)
         END-PERFORM
     END-IF
     ADD 1 TO PB-SDT-COUNT
     INITIALIZE PB-SDT-NODE(PB-SDT-COUNT)
     MOVE PB-SDX-ITEM-STACK TO PB-SDN-TYPE(PB-SDT-COUNT)
     MOVE WS-RESULT TO PB-SDN-ITEM(PB-SDT-COUNT)
     MOVE RR-RESULT-COUNT(L-RECIPE) TO PB-SDN-COUNT(PB-SDT-COUNT)
     MOVE PB-SDT-COUNT TO PB-UC-DISPLAY(PB-UR-CUT-COUNT)
     GOBACK.
 END PROGRAM RECIPES-UPDATE-CUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-UPDATE-BUILD.
*> USING PB-UPDATE-RECIPES out, PB-SLOT-DISPLAY-TABLE out: the seven property sets (always all seven, an empty one when no recipe
*> feeds it) and the stonecutter entries of the recipe store, as the header describes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-KEYS.
    05 FILLER              PIC X(32) VALUE "minecraft:smithing_base".
    05 FILLER              PIC X(32) VALUE "minecraft:smithing_template".
    05 FILLER              PIC X(32) VALUE "minecraft:smithing_addition".
    05 FILLER              PIC X(32) VALUE "minecraft:furnace_input".
    05 FILLER              PIC X(32) VALUE "minecraft:blast_furnace_input".
    05 FILLER              PIC X(32) VALUE "minecraft:smoker_input".
    05 FILLER              PIC X(32) VALUE "minecraft:campfire_input".
 01 WS-I                   BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE.
     INITIALIZE PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     MOVE 7 TO PB-UR-SET-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         COMPUTE WS-OFFSET = (WS-I - 1) * 32 + 1
         MOVE WS-KEYS(WS-OFFSET:32) TO PB-UR-KEY(WS-I)
         COMPUTE PB-UR-KEY-LENGTH(WS-I) = FUNCTION LENGTH(FUNCTION TRIM(PB-UR-KEY(WS-I) TRAILING))
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         MOVE RR-SERIALIZER(WS-K) TO WS-SERIALIZER
         EVALUATE TRUE
             WHEN WS-SERIALIZER >= 14 AND WS-SERIALIZER <= 17
                 COMPUTE WS-SET = WS-SERIALIZER - 10
                 CALL "RECIPES-UPDATE-INGREDIENT" USING RR-ING(WS-K, 1) WS-SET PB-UPDATE-RECIPES
             WHEN WS-SERIALIZER = 19 OR WS-SERIALIZER = 21
                 MOVE 2 TO WS-SET
                 CALL "RECIPES-UPDATE-INGREDIENT" USING RR-ING(WS-K, 1) WS-SET PB-UPDATE-RECIPES
                 MOVE 1 TO WS-SET
                 CALL "RECIPES-UPDATE-INGREDIENT" USING RR-ING(WS-K, 2) WS-SET PB-UPDATE-RECIPES
                 MOVE 3 TO WS-SET
                 CALL "RECIPES-UPDATE-INGREDIENT" USING RR-ING(WS-K, 3) WS-SET PB-UPDATE-RECIPES
             WHEN WS-SERIALIZER = 18
                 CALL "RECIPES-UPDATE-CUT" USING WS-K PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPES-UPDATE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-UPDATE-SEND.
*> USING connection id (BINARY-LONG): Update Recipes (0x88, id 136) built from the store, sent to the connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-ID           BINARY-LONG VALUE 136.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "RECIPES-UPDATE-BUILD" USING PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UPDATE-RECIPES" USING PB-BUFFER PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RECIPES-UPDATE-SEND.
