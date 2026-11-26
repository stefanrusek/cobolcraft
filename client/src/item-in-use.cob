*> The model of an item while it is in use (docs/protocol/58-in-use-item-models-and-arm-poses.md sections 3.2 and 4): an item definition that is a `minecraft:condition` on the property
*> `minecraft:using_item` with a plain `minecraft:model` as its `on_true` branch (the goat horn: `item/tooting_goat_horn`) has a model of its own while the stack is the one in use. The client keeps the
*> model data per item id (IS-* of client/copy/CLSTATE.cpy), so such an item gets a virtual item id for its in-use variant (the last CL-USE-VIRT ids below 2048, which no real item reaches):
*> ITEM-SPRITE-OF reads the variant's model from `model.on_true.model` of the real item's definition, and every consumer that takes an item id (the first-person hand, the third-person held
*> item) gets the variant by being passed the virtual id. A bow, crossbow, shield and trident have no plain `on_true` model (a range_dispatch, a select, a code-drawn special model): no variant.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-IN-USE-ID.
*> USING CLIENT-STATE, item id, id out: the item id to draw the stack with while it is in use: the virtual id of the item's in-use variant, else the item id itself (a stand-in set has no definitions;
*> an id out of range, a virtual id and an unknown id come back unchanged). The definition is read once per item (IS-USE-STATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 COPY JSONDOC.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-JP                  PIC X(32).
 01 WS-JP-LENGTH           BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-STR                 PIC X(80).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-OK                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
*> The three members that make a definition an in-use variant: the node is a condition, its property is using_item, its on_true is a plain model.
 01 WS-PATHS.
    05 FILLER              PIC X(32) VALUE "model.type".
    05 FILLER              PIC X(32) VALUE "model.property".
    05 FILLER              PIC X(32) VALUE "model.on_true.model".
 01 WS-PATH-TABLE REDEFINES WS-PATHS.
    05 WS-PATH-OF          PIC X(32) OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-ID.
     MOVE L-ITEM TO L-ID
     IF L-ITEM < 0 OR L-ITEM >= 2048 - CL-USE-VIRT
         GOBACK
     END-IF
     IF NOT (CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT)
         GOBACK
     END-IF
     IF IS-USE-STATE(L-ITEM + 1) = 0
         MOVE 1 TO IS-USE-STATE(L-ITEM + 1)
         MOVE 0 TO WS-OK
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1
             MOVE SPACES TO WS-PATH
             STRING "assets/" FUNCTION TRIM(WS-NS) "/items/" FUNCTION TRIM(WS-NAME) ".json"
                 DELIMITED BY SIZE INTO WS-PATH
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
             CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
             IF WS-FOUND = 1
                 CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
                 IF JD-ERROR = 0
                     MOVE 0 TO WS-OK
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         MOVE WS-PATH-OF(WS-K) TO WS-JP
                         MOVE SPACES TO WS-STR
                         MOVE 0 TO WS-STR-LENGTH
                         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JP)) TO WS-JP-LENGTH
                         CALL "JSON-FIND" USING JSON-DOC WS-JP WS-JP-LENGTH WS-NODE
                         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-STR WS-CAP WS-STR-LENGTH
                         IF (WS-K = 1 AND (WS-STR = "minecraft:condition" OR "condition"))
                                 OR (WS-K = 2 AND (WS-STR = "minecraft:using_item" OR "using_item"))
                                 OR (WS-K = 3 AND WS-STR-LENGTH > 0)
                             ADD 1 TO WS-OK
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-IF
         IF WS-OK = 3 AND IS-USE-COUNT < CL-USE-VIRT
             ADD 1 TO IS-USE-COUNT
             MOVE L-ITEM TO IS-USE-REAL(IS-USE-COUNT)
             COMPUTE IS-USE-VIRT(L-ITEM + 1) = 2048 - IS-USE-COUNT
             MOVE 2 TO IS-USE-STATE(L-ITEM + 1)
         END-IF
     END-IF
     IF IS-USE-STATE(L-ITEM + 1) = 2
         MOVE IS-USE-VIRT(L-ITEM + 1) TO L-ID
     END-IF
     GOBACK.
 END PROGRAM ITEM-IN-USE-ID.
