*> The recipe book of the players (docs/protocol/27-recipes-and-unlocks.md sections 4 and 5.9; docs/protocol/13 section 3.8;
*> docs/protocol/05b 0x4B and 0x4D): what a player knows (RECBOOK.cpy, the operations of recipes-27.cob), when a recipe becomes
*> known, the packets that tell the client, and Place Recipe.
*>
*> A recipe of RC-STORE with no unlock criteria is known from the join (the cobolcraft built-ins, core 5.7 "Unlock"). Any other
*> recipe becomes known when one criterion of its recipe advancement holds (27 5.9: the criteria are one OR group): a "tick"
*> criterion at the join, an "inventory_changed" criterion when every item predicate of it is held by some inventory slot. The
*> check runs at the join and whenever the inventory differs from the one the last check ran over (CRAFT-REFRESH-ALL, after
*> every packet and tick). Persistence of the known set is not done here.
*>
*> Entry points:
*>   RECBOOK-JOIN USING player row            an empty book, the recipes known from the start and the unlocks of the first
*>                                            tick, then Recipe Book Settings and Recipe Book Add (replace) to the player
*>   RECBOOK-SEND USING player row, replace   Recipe Book Add: replace 1 holds every known recipe (notification 0,
*>                                            highlight as unseen), replace 0 the recipes unlocked since the last send
*>                                            (notification as the recipe says, highlight), nothing when there are none
*>   RECIPE-UNLOCK-CHECK USING player row     unlocks by the criteria above (RECBOOK-ADD)
*>   RECIPE-ENTRY-BUILD USING recipe row, display index, flags, PB-RECIPE-ENTRY, PB-SLOT-DISPLAY-TABLE, built out
*>   CRAFT-REFRESH-ALL                        the check and the send for each player whose inventory changed
*>   RECIPE-PLACE USING connection id, PLAY-SERVERBOUND   Place Recipe

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-ING-NODE.
*> USING ingredient (PIC X(800)), PB-SLOT-DISPLAY-TABLE, node out: appends the SlotDisplay of an ingredient (an item, a
*> "#" tag, several of them as a composite, nothing as empty) and returns its node number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-TOKEN               PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 8 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INGREDIENT           PIC X(800).
 COPY PROTO.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INGREDIENT PB-SLOT-DISPLAY-TABLE L-NODE.
     MOVE 0 TO WS-N
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(L-INGREDIENT TRAILING))
     MOVE 1 TO WS-POINTER
     IF L-INGREDIENT = SPACES
         MOVE 0 TO WS-END
     END-IF
     PERFORM UNTIL WS-POINTER > WS-END OR WS-N >= 8
         MOVE SPACES TO WS-TOKEN
         UNSTRING L-INGREDIENT DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF PB-SDT-COUNT < PB-SDT-MAX-NODES AND WS-TOKEN NOT = SPACES
             ADD 1 TO PB-SDT-COUNT
             ADD 1 TO WS-N
             MOVE PB-SDT-COUNT TO WS-L(WS-N)
             INITIALIZE PB-SDT-NODE(PB-SDT-COUNT)
             IF WS-TOKEN(1:1) = "#"
                 MOVE PB-SDX-TAG TO PB-SDN-TYPE(PB-SDT-COUNT)
                 MOVE WS-TOKEN(2:63) TO PB-SDN-TAG(PB-SDT-COUNT)
                 COMPUTE PB-SDN-TAG-LENGTH(PB-SDT-COUNT)
                     = FUNCTION LENGTH(FUNCTION TRIM(PB-SDN-TAG(PB-SDT-COUNT) TRAILING))
             ELSE
                 MOVE WS-TOKEN TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
                 MOVE PB-SDX-ITEM TO PB-SDN-TYPE(PB-SDT-COUNT)
                 MOVE WS-ID TO PB-SDN-ITEM(PB-SDT-COUNT)
             END-IF
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-N = 1
             MOVE WS-L(1) TO L-NODE
         WHEN WS-N = 0 OR PB-SDT-COUNT >= PB-SDT-MAX-NODES
             IF PB-SDT-COUNT < PB-SDT-MAX-NODES
                 ADD 1 TO PB-SDT-COUNT
                 INITIALIZE PB-SDT-NODE(PB-SDT-COUNT)
                 MOVE PB-SDX-EMPTY TO PB-SDN-TYPE(PB-SDT-COUNT)
                 MOVE PB-SDT-COUNT TO L-NODE
             ELSE
                 MOVE 1 TO L-NODE
             END-IF
         WHEN OTHER
             ADD 1 TO PB-SDT-COUNT
             MOVE PB-SDT-COUNT TO WS-NODE
             INITIALIZE PB-SDT-NODE(WS-NODE)
             MOVE PB-SDX-COMPOSITE TO PB-SDN-TYPE(WS-NODE)
             MOVE WS-N TO PB-SDN-LIST-COUNT(WS-NODE)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 MOVE WS-L(WS-I) TO PB-SDN-LIST(WS-NODE, WS-I)
             END-PERFORM
             MOVE WS-NODE TO L-NODE
     END-EVALUATE
     GOBACK.
 END PROGRAM RECIPE-ING-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-ING-PLAIN.
*> USING ingredient (PIC X(800)), item id out, plain out: plain 1 when the ingredient is exactly one item key (no tag, no
*> alternatives), with its item id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SPACES              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INGREDIENT           PIC X(800).
 01 L-ID                   BINARY-LONG.
 01 L-PLAIN                BINARY-LONG.
 PROCEDURE DIVISION USING L-INGREDIENT L-ID L-PLAIN.
     MOVE 0 TO L-PLAIN L-ID WS-SPACES
     IF L-INGREDIENT = SPACES OR L-INGREDIENT(1:1) = "#" OR L-INGREDIENT(113:688) NOT = SPACES
         GOBACK
     END-IF
     MOVE L-INGREDIENT(1:112) TO WS-KEY
     INSPECT FUNCTION TRIM(WS-KEY TRAILING) TALLYING WS-SPACES FOR ALL SPACE
     IF WS-SPACES > 0
         GOBACK
     END-IF
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ID WS-ROW WS-STATUS
     IF WS-STATUS = CT-OK
         MOVE 1 TO L-PLAIN
     END-IF
     GOBACK.
 END PROGRAM RECIPE-ING-PLAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-ENTRY-BUILD.
*> USING recipe row, display index (0 to count - 1), flags (PB-RE-FLAG-*), PB-RECIPE-ENTRY out, PB-SLOT-DISPLAY-TABLE out,
*> built out (1, or 0 for a recipe family the book has no display for): the RecipeDisplayEntry of one display of a recipe
*> (27 4.2): shaped and shapeless crafting, transmute (a shapeless display per material count), the cooking family
*> (furnace display) and stonecutting. The requirements are present when every ingredient is one plain item.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-PLAIN               BINARY-LONG.
 01 WS-ALL-PLAIN           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MATERIALS           BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-CATEGORY-NAME       PIC X(24).
 01 WS-CATEGORY            BINARY-LONG.
 01 WS-GROUP               BINARY-LONG.
 01 WS-ING                 PIC X(800).
 LINKAGE SECTION.
 01 L-RECIPE               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 COPY PROTO.
 01 L-BUILT                BINARY-LONG.
 PROCEDURE DIVISION USING L-RECIPE L-INDEX L-FLAGS PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE L-BUILT.
     MOVE 0 TO L-BUILT
     MOVE RR-SERIALIZER(L-RECIPE) TO WS-SERIALIZER
     IF NOT (WS-SERIALIZER = 0 OR WS-SERIALIZER = 1 OR WS-SERIALIZER = 4
             OR (WS-SERIALIZER >= 14 AND WS-SERIALIZER <= 18))
         GOBACK
     END-IF
     INITIALIZE PB-RECIPE-ENTRY PB-SLOT-DISPLAY-TABLE
     CALL "RECIPE-DISPLAY-FIRST" USING L-RECIPE PB-RE-DISPLAY-ID
     ADD L-INDEX TO PB-RE-DISPLAY-ID
     MOVE 0 TO PB-RE-INGREDIENT-COUNT PB-RE-REQ-COUNT PB-RE-REQ-PRESENT
     MOVE 1 TO WS-ALL-PLAIN
     EVALUATE TRUE
         WHEN WS-SERIALIZER = 0
             MOVE PB-RT-SHAPED TO PB-RE-TYPE
             MOVE RR-WIDTH(L-RECIPE) TO PB-RE-WIDTH
             MOVE RR-HEIGHT(L-RECIPE) TO PB-RE-HEIGHT
             COMPUTE WS-N = RR-WIDTH(L-RECIPE) * RR-HEIGHT(L-RECIPE)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-I > 9
                 ADD 1 TO PB-RE-INGREDIENT-COUNT
                 MOVE RR-ING(L-RECIPE, WS-I) TO WS-ING
                 CALL "RECIPE-ING-NODE" USING WS-ING PB-SLOT-DISPLAY-TABLE WS-NODE
                 MOVE WS-NODE TO PB-RE-INGREDIENT(WS-I)
                 PERFORM ADD-REQUIREMENT
             END-PERFORM
         WHEN WS-SERIALIZER = 1
             MOVE PB-RT-SHAPELESS TO PB-RE-TYPE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-ING-COUNT(L-RECIPE) OR WS-I > 9
                 ADD 1 TO PB-RE-INGREDIENT-COUNT
                 MOVE RR-ING(L-RECIPE, WS-I) TO WS-ING
                 CALL "RECIPE-ING-NODE" USING WS-ING PB-SLOT-DISPLAY-TABLE WS-NODE
                 MOVE WS-NODE TO PB-RE-INGREDIENT(WS-I)
                 PERFORM ADD-REQUIREMENT
             END-PERFORM
         WHEN WS-SERIALIZER = 4
             MOVE PB-RT-SHAPELESS TO PB-RE-TYPE
             COMPUTE WS-MATERIALS = RR-MATERIAL-MIN(L-RECIPE) + L-INDEX
             COMPUTE PB-RE-INGREDIENT-COUNT = FUNCTION MIN(WS-MATERIALS + 1, 9)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RE-INGREDIENT-COUNT
                 IF WS-I = 1
                     MOVE RR-ING(L-RECIPE, 1) TO WS-ING
                 ELSE
                     MOVE RR-ING(L-RECIPE, 2) TO WS-ING
                 END-IF
                 CALL "RECIPE-ING-NODE" USING WS-ING PB-SLOT-DISPLAY-TABLE WS-NODE
                 MOVE WS-NODE TO PB-RE-INGREDIENT(WS-I)
                 PERFORM ADD-REQUIREMENT
             END-PERFORM
         WHEN WS-SERIALIZER >= 14 AND WS-SERIALIZER <= 17
             MOVE PB-RT-FURNACE TO PB-RE-TYPE
             MOVE RR-ING(L-RECIPE, 1) TO WS-ING
             CALL "RECIPE-ING-NODE" USING WS-ING PB-SLOT-DISPLAY-TABLE WS-NODE
             MOVE WS-NODE TO PB-RE-INGREDIENT(1)
             ADD 1 TO PB-SDT-COUNT
             MOVE PB-SDX-ANY-FUEL TO PB-SDN-TYPE(PB-SDT-COUNT)
             MOVE PB-SDT-COUNT TO PB-RE-INGREDIENT(2)
             MOVE RR-COOK-TIME(L-RECIPE) TO PB-RE-DURATION
             COMPUTE PB-RE-EXPERIENCE = RR-EXPERIENCE(L-RECIPE)
             MOVE 0 TO WS-ALL-PLAIN
         WHEN OTHER
             MOVE PB-RT-STONECUTTER TO PB-RE-TYPE
             MOVE RR-ING(L-RECIPE, 1) TO WS-ING
             CALL "RECIPE-ING-NODE" USING WS-ING PB-SLOT-DISPLAY-TABLE WS-NODE
             MOVE WS-NODE TO PB-RE-INGREDIENT(1)
             MOVE 0 TO WS-ALL-PLAIN
     END-EVALUATE
*>   The result as an item stack, the station empty.
     MOVE RR-RESULT-ID(L-RECIPE) TO WS-KEY
     IF WS-KEY = SPACES
         MOVE RR-ING(L-RECIPE, 1) TO WS-KEY
     END-IF
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     ADD 1 TO PB-SDT-COUNT
     MOVE PB-SDX-ITEM-STACK TO PB-SDN-TYPE(PB-SDT-COUNT)
     MOVE WS-ID TO PB-SDN-ITEM(PB-SDT-COUNT)
     MOVE RR-RESULT-COUNT(L-RECIPE) TO PB-SDN-COUNT(PB-SDT-COUNT)
     IF WS-SERIALIZER = 4 AND RR-ADD-COUNT(L-RECIPE) = 1
         ADD WS-MATERIALS TO PB-SDN-COUNT(PB-SDT-COUNT)
     END-IF
     MOVE PB-SDT-COUNT TO PB-RE-RESULT
     ADD 1 TO PB-SDT-COUNT
     MOVE PB-SDX-EMPTY TO PB-SDN-TYPE(PB-SDT-COUNT)
     MOVE PB-SDT-COUNT TO PB-RE-STATION
     CALL "RECIPE-GROUP-NUMBER" USING L-RECIPE PB-RE-GROUP
     MOVE RR-CATEGORY(L-RECIPE) TO WS-CATEGORY-NAME
     CALL "RECIPE-BOOK-CATEGORY" USING WS-SERIALIZER WS-CATEGORY-NAME PB-RE-CATEGORY
     IF WS-ALL-PLAIN = 1 AND PB-RE-REQ-COUNT > 0
         MOVE 1 TO PB-RE-REQ-PRESENT
     END-IF
     MOVE L-FLAGS TO PB-RE-FLAGS
     MOVE 1 TO L-BUILT
     GOBACK.

*> Adds the ingredient of slot WS-I (WS-ING) to the requirements when it is one plain item; an empty cell adds none; a
*> tag or alternatives make the requirements absent.
 ADD-REQUIREMENT.
     IF WS-ING = SPACES
         CONTINUE
     ELSE
         CALL "RECIPE-ING-PLAIN" USING WS-ING WS-ID WS-PLAIN
         IF WS-PLAIN = 1 AND PB-RE-REQ-COUNT < 9
             ADD 1 TO PB-RE-REQ-COUNT
             MOVE WS-ID TO PB-RE-REQ-ITEM(PB-RE-REQ-COUNT)
         ELSE
             MOVE 0 TO WS-ALL-PLAIN
         END-IF
     END-IF.
 END PROGRAM RECIPE-ENTRY-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-BUILD.
*> USING player row, replace (BINARY-LONG), PB-BUFFER (initialised, appended to), entries out: the Recipe Book Add (0x4B)
*> of RECBOOK-SEND, always built (an empty list when nothing is selected); the recipes sent are no longer pending.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY RECBOOK.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 75.
 01 WS-K                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUILT               BINARY-LONG.
 01 WS-SEND                PIC 9.
 01 WS-REPLACE-FLAG        BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 COPY PROTO.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-REPLACE PB-BUFFER L-TOTAL.
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         PERFORM SELECT-ROW
         IF WS-SEND = 1
             CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D >= WS-N
                 MOVE 0 TO WS-FLAGS
                 CALL "RECIPE-ENTRY-BUILD" USING WS-K WS-D WS-FLAGS WK-RECIPE-ENTRY WK-SLOT-DISPLAY-TABLE
                     WS-BUILT
                 ADD WS-BUILT TO L-TOTAL
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TOTAL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         PERFORM SELECT-ROW
         IF WS-SEND = 1
             CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D >= WS-N
                 MOVE 0 TO WS-FLAGS
                 IF L-REPLACE = 1
                     IF RB-HIGHLIGHT(L-ROW, WS-K) = 1
                         MOVE PB-RE-FLAG-HIGHLIGHT TO WS-FLAGS
                     END-IF
                 ELSE
                     MOVE PB-RE-FLAG-HIGHLIGHT TO WS-FLAGS
                     IF RR-NOTIFY(WS-K) = 1
                         ADD PB-RE-FLAG-NOTIFY TO WS-FLAGS
                     END-IF
                 END-IF
                 CALL "RECIPE-ENTRY-BUILD" USING WS-K WS-D WS-FLAGS WK-RECIPE-ENTRY WK-SLOT-DISPLAY-TABLE
                     WS-BUILT
                 IF WS-BUILT = 1
                     CALL "PB-PUT-RECIPE-ENTRY" USING PB-BUFFER WK-RECIPE-ENTRY WK-SLOT-DISPLAY-TABLE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE L-REPLACE TO WS-REPLACE-FLAG
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-REPLACE-FLAG
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         MOVE 0 TO RB-PENDING(L-ROW, WS-K)
     END-PERFORM
     GOBACK.

 SELECT-ROW.
     MOVE 0 TO WS-SEND
     IF L-REPLACE = 1
         MOVE RB-KNOWN(L-ROW, WS-K) TO WS-SEND
     ELSE
         MOVE RB-PENDING(L-ROW, WS-K) TO WS-SEND
     END-IF.
 END PROGRAM RECBOOK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-SEND.
*> USING player row, replace (BINARY-LONG): see the header.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-REPLACE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "RECBOOK-BUILD" USING L-ROW L-REPLACE PB-BUFFER WS-TOTAL
     IF L-REPLACE = 1 OR WS-TOTAL > 0
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM RECBOOK-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-UNLOCK-CHECK.
*> USING player row: the unlock criteria of 27 5.9 over the player's inventory.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTRECIPE.
 COPY RECBOOK.
 01 WS-K                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-PREDICATE           PIC X(800).
 01 WS-ALL                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF RR-UNLOCK-N(WS-K) > 0 AND RB-KNOWN(L-ROW, WS-K) = 0 AND RR-SPECIAL(WS-K) = 0
             MOVE 0 TO WS-HIT
             COMPUTE WS-LAST = RR-UNLOCK-FIRST(WS-K) + RR-UNLOCK-N(WS-K) - 1
             PERFORM VARYING WS-U FROM RR-UNLOCK-FIRST(WS-K) BY 1 UNTIL WS-U > WS-LAST OR WS-HIT = 1
                 EVALUATE TRUE
                     WHEN RU-TRIGGER(WS-U) = "tick"
                         MOVE 1 TO WS-HIT
                     WHEN RU-TRIGGER(WS-U) = "inventory_changed"
                         PERFORM CHECK-PREDICATES
                 END-EVALUATE
             END-PERFORM
             IF WS-HIT = 1
                 CALL "RECBOOK-ADD" USING L-ROW WS-K WS-ADDED
             END-IF
         END-IF
     END-PERFORM
     GOBACK.

*> Every predicate of RU-ITEMS (WS-U), separated by " & ", must be passed by some inventory slot; no predicate passes.
 CHECK-PREDICATES.
     MOVE 1 TO WS-ALL
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(RU-ITEMS(WS-U) TRAILING))
     IF RU-ITEMS(WS-U) = SPACES
         MOVE 0 TO WS-END
     END-IF
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > WS-END OR WS-ALL = 0
         MOVE SPACES TO WS-PREDICATE
         UNSTRING RU-ITEMS(WS-U) DELIMITED BY " & " INTO WS-PREDICATE WITH POINTER WS-POINTER
         MOVE 0 TO WS-ANY
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR WS-ANY = 1
             IF PL-SLOT-COUNT(L-ROW, WS-S) > 0
                 CALL "CRAFT-ING-TEST" USING PL-SLOT-ITEM(L-ROW, WS-S) WS-PREDICATE WS-PASS
                 MOVE WS-PASS TO WS-ANY
             END-IF
         END-PERFORM
         IF WS-ANY = 0
             MOVE 0 TO WS-ALL
         END-IF
     END-PERFORM
     IF WS-ALL = 1
         MOVE 1 TO WS-HIT
     END-IF.
 END PROGRAM RECIPE-UNLOCK-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-JOIN.
*> USING player row: see the header.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTRECIPE.
 COPY RECBOOK.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG VALUE 77.
 01 WS-K                   BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG VALUE 1.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "RECBOOK-RESET" USING L-ROW
     MOVE 1 TO RB-SENT(L-ROW)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
         IF RR-UNLOCK-N(WS-K) = 0
             CALL "RECBOOK-ADD" USING L-ROW WS-K WS-ADDED
             CALL "RECBOOK-SEEN" USING L-ROW WS-K
         END-IF
     END-PERFORM
     CALL "RECIPE-UNLOCK-CHECK" USING L-ROW
     MOVE PL-INVENTORY(L-ROW) TO RB-INVENTORY(L-ROW)
     INITIALIZE PB-RECIPE-BOOK-SETTINGS
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 4
         MOVE RB-OPEN(L-ROW, WS-T) TO PB-RBS-OPEN(WS-T)
         MOVE RB-FILTER(L-ROW, WS-T) TO PB-RBS-FILTERING(WS-T)
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-RECIPE-BOOK-SETTINGS" USING PB-BUFFER PB-RECIPE-BOOK-SETTINGS
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "RECBOOK-SEND" USING L-ROW WS-REPLACE
     GOBACK.
 END PROGRAM RECBOOK-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-REFRESH-ALL.
*> Runs the unlock check of every player whose inventory changed since the last check and sends what became known.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RECBOOK.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NO-REPLACE          BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND RB-SENT(WS-ROW) = 1
                 AND PL-INVENTORY(WS-ROW) NOT = RB-INVENTORY(WS-ROW)
             MOVE PL-INVENTORY(WS-ROW) TO RB-INVENTORY(WS-ROW)
             CALL "RECIPE-UNLOCK-CHECK" USING WS-ROW
             CALL "RECBOOK-SEND" USING WS-ROW WS-NO-REPLACE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-REFRESH-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-PLACE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Place Recipe): 13 3.8 and 27 4.7. The grid goes back into the inventory
*> (nothing happens when it does not fit), then sets of the recipe are moved from the inventory into the grid: shapeless
*> recipes fill the cells in order, shaped recipes keep their pattern from the top left of the grid. One set, or with use
*> max items as many as the inventory supplies and the stacks allow. A recipe the inventory cannot supply for one set leaves
*> the grid emptied into the inventory; the Place Ghost Recipe packet that 13 3.8 sends then is not built yet (BLOCKED:
*> proto has no builder for 0x40).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CTRECIPE.
 COPY CITEMS.
 COPY CMENU.
 COPY RECBOOK.
 COPY PROTO.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-GRID-W              BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-SAVED-INV           PIC X(288).
 01 WS-SET-INV             PIC X(288).
 01 WS-GRID.
    05 WS-CELL OCCURS 9 TIMES.
       10 WS-CELL-ITEM     BINARY-LONG.
       10 WS-CELL-COUNT    BINARY-LONG.
 01 WS-SAVED-SET           PIC X(72).
 01 WS-SET-GRID.
    05 WS-SET-CELL OCCURS 9 TIMES.
       10 WS-SET-ITEM      BINARY-LONG.
       10 WS-SET-COUNT     BINARY-LONG.
 01 WS-TARGETS.
    05 WS-TARGET           BINARY-LONG OCCURS 9 TIMES.
 01 WS-INGS.
    05 WS-ING              PIC X(800) OCCURS 9 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-OFF-C               BINARY-LONG.
 01 WS-OFF-R               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SETS                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MAX-SETS            BINARY-LONG VALUE 64.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF WS-ROW = 0 OR PL-MODE(WS-ROW) = 3 OR PSB-CONTAINER NOT = MN-WINDOW(WS-ROW)
         GOBACK
     END-IF
     CALL "RECIPE-DISPLAY-ROW" USING PSB-RECIPE WS-RC WS-INDEX
     IF WS-RC = 0
         GOBACK
     END-IF
     CALL "RECBOOK-CONTAINS" USING WS-ROW WS-RC WS-KNOWN
     IF WS-KNOWN = 0 OR (RR-SERIALIZER(WS-RC) NOT = 0 AND RR-SERIALIZER(WS-RC) NOT = 1)
         GOBACK
     END-IF
     IF MN-WINDOW(WS-ROW) = 0
         MOVE 2 TO WS-GRID-W
     ELSE
         MOVE 3 TO WS-GRID-W
     END-IF
     COMPUTE WS-CELLS = WS-GRID-W * WS-GRID-W
*>   The recipe as the grid cell each ingredient goes to (top-left aligned when at least half the grid, else centred).
     MOVE 0 TO WS-N
     IF RR-SERIALIZER(WS-RC) = 1
         IF RR-ING-COUNT(WS-RC) > WS-CELLS
             GOBACK
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-ING-COUNT(WS-RC)
             ADD 1 TO WS-N
             MOVE RR-ING(WS-RC, WS-I) TO WS-ING(WS-N)
             MOVE WS-I TO WS-TARGET(WS-N)
         END-PERFORM
     ELSE
         IF RR-WIDTH(WS-RC) > WS-GRID-W OR RR-HEIGHT(WS-RC) > WS-GRID-W
             GOBACK
         END-IF
         MOVE 0 TO WS-OFF-C WS-OFF-R
         IF RR-WIDTH(WS-RC) * 2 < WS-GRID-W
             COMPUTE WS-OFF-C = (WS-GRID-W - RR-WIDTH(WS-RC)) / 2
         END-IF
         IF RR-HEIGHT(WS-RC) * 2 < WS-GRID-W
             COMPUTE WS-OFF-R = (WS-GRID-W - RR-HEIGHT(WS-RC)) / 2
         END-IF
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= RR-HEIGHT(WS-RC)
             PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C >= RR-WIDTH(WS-RC)
                 COMPUTE WS-I = WS-R * RR-WIDTH(WS-RC) + WS-C + 1
                 IF RR-ING(WS-RC, WS-I) NOT = SPACES
                     ADD 1 TO WS-N
                     MOVE RR-ING(WS-RC, WS-I) TO WS-ING(WS-N)
                     COMPUTE WS-TARGET(WS-N) = (WS-R + WS-OFF-R) * WS-GRID-W + WS-C + WS-OFF-C + 1
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
*>   The grid back into the inventory: when it does not fit nothing happens.
     MOVE PL-INVENTORY(WS-ROW) TO WS-SAVED-INV
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-CELL-ITEM(WS-I) WS-CELL-COUNT(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         IF MN-WINDOW(WS-ROW) = 0
             MOVE MN-IGRID-ITEM(WS-ROW, WS-I) TO WS-CELL-ITEM(WS-I)
             MOVE MN-IGRID-COUNT(WS-ROW, WS-I) TO WS-CELL-COUNT(WS-I)
         ELSE
             MOVE MN-BGRID-ITEM(WS-ROW, WS-I) TO WS-CELL-ITEM(WS-I)
             MOVE MN-BGRID-COUNT(WS-ROW, WS-I) TO WS-CELL-COUNT(WS-I)
         END-IF
         IF WS-CELL-COUNT(WS-I) > 0
             CALL "INV-ADD" USING WS-ROW WS-CELL-ITEM(WS-I) WS-CELL-COUNT(WS-I) WS-LEFT
             IF WS-LEFT > 0
                 MOVE WS-SAVED-INV TO PL-INVENTORY(WS-ROW)
                 GOBACK
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE 0 TO WS-SET-ITEM(WS-I) WS-SET-COUNT(WS-I)
     END-PERFORM
*>   Sets of the recipe: one, or the most the inventory supplies with use max items.
     MOVE 0 TO WS-SETS
     MOVE 1 TO WS-MORE
     PERFORM UNTIL WS-MORE = 0
         MOVE PL-INVENTORY(WS-ROW) TO WS-SET-INV
         MOVE WS-SET-GRID TO WS-SAVED-SET
         MOVE 1 TO WS-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-OK = 0
             MOVE WS-TARGET(WS-I) TO WS-C
             MOVE 0 TO WS-SLOT
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR WS-SLOT > 0
                 IF PL-SLOT-COUNT(WS-ROW, WS-S) > 0
                     IF WS-SET-COUNT(WS-C) > 0
                         IF PL-SLOT-ITEM(WS-ROW, WS-S) = WS-SET-ITEM(WS-C)
                             MOVE WS-S TO WS-SLOT
                         END-IF
                     ELSE
                         CALL "CRAFT-ING-TEST" USING PL-SLOT-ITEM(WS-ROW, WS-S) WS-ING(WS-I) WS-PASS
                         IF WS-PASS = 1
                             MOVE WS-S TO WS-SLOT
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-SLOT = 0
                 MOVE 0 TO WS-OK
             ELSE
                 MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT) TO WS-SET-ITEM(WS-C)
                 ADD 1 TO WS-SET-COUNT(WS-C)
                 COMPUTE WS-LIMIT = WS-SLOT - 1
                 MOVE 1 TO WS-PASS
                 CALL "INV-REMOVE" USING WS-ROW WS-LIMIT WS-PASS
                 IF WS-SET-COUNT(WS-C) > IT-MAX-STACK(WS-SET-ITEM(WS-C) + 1)
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-PERFORM
         IF WS-OK = 1
             ADD 1 TO WS-SETS
             IF PSB-USE-MAX = 0 OR WS-SETS >= WS-MAX-SETS
                 MOVE 0 TO WS-MORE
             END-IF
         ELSE
*>           This set could not be taken: it is put back and the sets before it stay.
             MOVE WS-SET-INV TO PL-INVENTORY(WS-ROW)
             MOVE WS-SAVED-SET TO WS-SET-GRID
             MOVE 0 TO WS-MORE
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         PERFORM STORE-CELL
     END-PERFORM
     CALL "MENU-CRAFT-UPDATE" USING WS-ROW
     CALL "MENU-STATE-RAISE" USING WS-ROW WS-OLD WS-NEW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

*> The cell WS-I of the open menu takes the set table's contents (an empty cell has item 0).
 STORE-CELL.
     IF WS-SET-COUNT(WS-I) = 0
         MOVE 0 TO WS-SET-ITEM(WS-I)
     END-IF
     IF MN-WINDOW(WS-ROW) = 0
         MOVE WS-SET-ITEM(WS-I) TO MN-IGRID-ITEM(WS-ROW, WS-I)
         MOVE WS-SET-COUNT(WS-I) TO MN-IGRID-COUNT(WS-ROW, WS-I)
     ELSE
         MOVE WS-SET-ITEM(WS-I) TO MN-BGRID-ITEM(WS-ROW, WS-I)
         MOVE WS-SET-COUNT(WS-I) TO MN-BGRID-COUNT(WS-ROW, WS-I)
     END-IF.
 END PROGRAM RECIPE-PLACE.
