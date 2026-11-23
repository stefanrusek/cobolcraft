*> Block models of a standard world, baked on first use (docs/protocol/08-resource-packs.md §4, §5).
*> The standard set has about 30,000 block states, all named minecraft:, and the generated vanilla pack
*> holds a block state file under assets/minecraft/blockstates for each block; baking every state at
*> load would read thousands of files and fill the table, while a view shows a few hundred distinct
*> states. So MODEL-SLOT-OF gives each state a row of BM-STATE the first time a section shows it
*> (LAZY-STATE-BAKE: the block state file of its block, selected by the state's properties, then the
*> same STATE-BAKE as the stand-in states). Without a standard set open the rows are the stand-in
*> table's: row = state + 1 for the 18 states baked by MODELS-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MODEL-SLOT-OF.
*> USING CLIENT-STATE, state id, row out: the row of BM-STATE holding the state's quads (0 = none: the
*> state is void, unknown, or the table of rows is full). Brings the baked table in line with the
*> open content set first (MODELS-BAKE when the set has changed from the standard one to another or
*> back), bakes the state when it has no row yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-ROW.
     MOVE 0 TO L-ROW
     MOVE 1 TO WS-WANT
     IF CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         MOVE 2 TO WS-WANT
     END-IF
     IF BM-MODE NOT = WS-WANT
         CALL "MODELS-BAKE" USING CLIENT-STATE
     END-IF
     IF L-STATE <= 0 OR L-STATE >= CL-MAX-STATES
         GOBACK
     END-IF
     IF BM-MODE = 1
         IF L-STATE < CL-MAX-BAKED
             COMPUTE L-ROW = L-STATE + 1
         END-IF
         GOBACK
     END-IF
     MOVE BM-SLOT(L-STATE + 1) TO L-ROW
     IF L-ROW = 0 AND BM-NEXT <= CL-MAX-ROWS AND L-STATE < CT-STATE-COUNT
         MOVE BM-NEXT TO L-ROW
         ADD 1 TO BM-NEXT
         MOVE L-ROW TO BM-SLOT(L-STATE + 1)
         CALL "LAZY-STATE-BAKE" USING CLIENT-STATE L-STATE L-ROW
     END-IF
     GOBACK.
 END PROGRAM MODEL-SLOT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LAZY-STATE-BAKE.
*> USING CLIENT-STATE, state id of the open standard set, row: bakes the state into the row. The block
*> state file is assets/<namespace>/blockstates/<path>.json of the top-most pack that has it; the
*> variant key is the state's "name=value" pairs, sorted by name, separated by commas. No file, or a file
*> naming no model for the state: the missing model (STATE-BAKE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 COPY JSONDOC.
 COPY CLMODEL.
 01 WS-CODE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 01 WS-KEY                 PIC X(96).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NS                  PIC X(35).
 01 WS-NAME                PIC X(35).
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-FACING              PIC X(8).
 01 WS-CTYPE               PIC X(8).
 01 WS-CNAME               PIC X(48).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-BM-ROW               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-BM-ROW.
     MOVE L-STATE TO WS-CODE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-CODE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     MOVE 0 TO SX-COUNT
     IF WS-STATUS = CT-OK
         CALL "CONTENT-STATE-PROPS" USING WS-CODE WS-PROPS WS-STATUS
         MOVE SPACES TO WS-KEY WS-NS WS-NAME WS-PATH
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-P-COUNT
             IF WS-I > 1
                 STRING "," DELIMITED BY SIZE INTO WS-KEY WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-P-NAME(WS-I)) "=" FUNCTION TRIM(WS-P-VALUE(WS-I))
                 DELIMITED BY SIZE INTO WS-KEY WITH POINTER WS-PTR
         END-PERFORM
         COMPUTE WS-KEY-LENGTH = WS-PTR - 1
         UNSTRING CT-BR-KEY DELIMITED BY ":" OR SPACE INTO WS-NS WS-NAME
         IF WS-NAME = SPACES
             MOVE WS-NS TO WS-NAME
             MOVE "minecraft" TO WS-NS
         END-IF
         STRING "assets/" FUNCTION TRIM(WS-NS) "/blockstates/" FUNCTION TRIM(WS-NAME) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY
             WS-LENGTH WS-FOUND
         IF WS-FOUND = 1
             CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
             CALL "BLOCKSTATE-SELECT" USING JSON-DOC WS-KEY WS-KEY-LENGTH STATE-MODELS
         END-IF
     END-IF
     CALL "STATE-BAKE" USING CLIENT-STATE L-BM-ROW STATE-MODELS
*>   The chest family has no elements in its block model: the closed entity model of 52 is baked instead (models-chest.cob).
     MOVE 0 TO WS-HITS
     INSPECT WS-NAME TALLYING WS-HITS FOR ALL "chest"
     IF WS-HITS > 0 AND WS-STATUS = CT-OK
         MOVE "south" TO WS-FACING
         MOVE "single" TO WS-CTYPE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-P-COUNT
             IF WS-P-NAME(WS-I) = "facing"
                 MOVE WS-P-VALUE(WS-I) TO WS-FACING
             END-IF
             IF WS-P-NAME(WS-I) = "type"
                 MOVE WS-P-VALUE(WS-I) TO WS-CTYPE
             END-IF
         END-PERFORM
         MOVE WS-NAME TO WS-CNAME
         CALL "CHEST-BAKE" USING CLIENT-STATE L-BM-ROW WS-CNAME WS-FACING WS-CTYPE
     END-IF
     GOBACK.
 END PROGRAM LAZY-STATE-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-SPRITE-OF.
*> USING CLIENT-STATE, item id, sprite out (0 = draw no icon): the atlas sprite of the item's icon. With the
*> standard set open it is found on the item's first use (assets/<namespace>/items/<path>.json of the top-most
*> pack, its model chain: a flat item's layer0, a block item's up face, else the first face of its first
*> element; the missing sprite 1 when the definition or model gives none) and kept in IS-SPRITE, with the quads of the model for the GUI (ITEM-GUI-BAKE); otherwise
*> it is the stand-in table's IT-SPRITE (ITEMDEFS-LOAD) for the 18 items of standin-content.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 COPY JSONDOC.
 COPY CLMODEL.
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
 *> The model of a definition (08 5.7): the first of these that holds a string. The first ten reach a "minecraft:model" (directly, or as
*> the fallback, the false branch, the first composite member or the first entry of a select, condition, composite or range_dispatch, also through a select case);
*> the last four reach the "base" of a code-drawn "minecraft:special" model, whose icon is its particle texture.
 01 WS-JPATHS.
    05 FILLER              PIC X(48) VALUE "model.model".
    05 FILLER              PIC X(48) VALUE "model.fallback.model".
    05 FILLER              PIC X(48) VALUE "model.on_false.model".
    05 FILLER              PIC X(48) VALUE "model.models[0].model".
    05 FILLER              PIC X(48) VALUE "model.fallback.on_false.model".
    05 FILLER              PIC X(48) VALUE "model.fallback.fallback.model".
    05 FILLER              PIC X(48) VALUE "model.fallback.entries[0].model.model".
    05 FILLER              PIC X(48) VALUE "model.on_false.entries[0].model.model".
    05 FILLER              PIC X(48) VALUE "model.entries[0].model.model".
    05 FILLER              PIC X(48) VALUE "model.cases[0].model.entries[0].model.model".
    05 FILLER              PIC X(48) VALUE "model.base".
    05 FILLER              PIC X(48) VALUE "model.fallback.base".
    05 FILLER              PIC X(48) VALUE "model.on_false.base".
    05 FILLER              PIC X(48) VALUE "model.fallback.on_false.base".
 01 WS-JPATH-TABLE REDEFINES WS-JPATHS.
    05 WS-JPATH            PIC X(48) OCCURS 14 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-JP                  PIC X(48).
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-PARTICLE            PIC X(80) VALUE "#particle".
 01 WS-JP-LENGTH           BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-GENERATED           BINARY-LONG.
 01 WS-LAYER               PIC X(80) VALUE "#layer0".
 01 WS-LAYER1              PIC X(80) VALUE "#layer1".
 01 WS-LAYER1-SPRITE       BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-FACES               PIC 9.
 01 WS-FACE-SPRITE         BINARY-LONG OCCURS 6 TIMES.
 01 WS-D                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-SPRITE.
     MOVE 0 TO L-SPRITE
     IF L-ITEM < 0
         GOBACK
     END-IF
     IF NOT (CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT)
         IF L-ITEM < CL-ITEM-COUNT
             MOVE IT-SPRITE(L-ITEM + 1) TO L-SPRITE
         END-IF
         GOBACK
     END-IF
     IF L-ITEM >= 2048
         MOVE 1 TO L-SPRITE
         GOBACK
     END-IF
     IF IS-SPRITE(L-ITEM + 1) > 0
         MOVE IS-SPRITE(L-ITEM + 1) TO L-SPRITE
         GOBACK
     END-IF
     MOVE 1 TO WS-SPRITE
     MOVE 0 TO WS-FACES WS-LAYER1-SPRITE
     MOVE 0 TO MR-FP-PRESENT WS-SPECIAL MR-DX-PRESENT(1) MR-DX-PRESENT(2) MR-DX-PRESENT(3)
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD
         WS-KNOWN
     IF WS-KNOWN = 1
         MOVE SPACES TO WS-PATH
         STRING "assets/" FUNCTION TRIM(WS-NS) "/items/" FUNCTION TRIM(WS-NAME) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
             WS-FOUND
         IF WS-FOUND = 1
             CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
             MOVE SPACES TO WS-ID
             MOVE 0 TO WS-ID-LENGTH
             IF JD-ERROR = 0
                 MOVE 0 TO WS-SPECIAL
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 14 OR WS-ID-LENGTH > 0
                     MOVE SPACES TO WS-JP
                     MOVE WS-JPATH(WS-K) TO WS-JP
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JP)) TO WS-JP-LENGTH
                     CALL "JSON-FIND" USING JSON-DOC WS-JP WS-JP-LENGTH WS-NODE
                     CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ID WS-CAP WS-ID-LENGTH
                     IF WS-K > 10
                         MOVE 1 TO WS-SPECIAL
                     END-IF
                 END-PERFORM
             END-IF
             IF WS-ID-LENGTH > 0
                 CALL "ITEM-MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
                     WS-GENERATED
                 IF WS-GENERATED = 1
                     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-LAYER WS-SPRITE
*>                   The second layer of the flat model (the leather armour's overlay, the potion's bottle, the spots of a spawn egg): drawn over layer 0 (item-tint.cob ITEM-FLAT-ICON).
                     PERFORM VARYING WS-LS FROM 1 BY 1 UNTIL WS-LS > MR-SLOT-COUNT
                         IF MS-NAME(WS-LS) = "layer1"
                             CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-LAYER1 WS-LAYER1-SPRITE
                         END-IF
                     END-PERFORM
                 ELSE
                 IF WS-SPECIAL = 1
                     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-PARTICLE WS-SPRITE
                 ELSE
                     CALL "MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
                     MOVE 0 TO WS-F
                     IF MR-MISSING = 0 AND MR-ELEMENT-COUNT > 0
                         IF MF-PRESENT(1, DIR-UP) = 1
                             MOVE DIR-UP TO WS-F
                         ELSE
                             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6 OR WS-F > 0
                                 IF MF-PRESENT(1, WS-K) = 1
                                     MOVE WS-K TO WS-F
                                 END-IF
                             END-PERFORM
                         END-IF
                     END-IF
                     IF WS-F > 0
                         CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED MF-TEXTURE(1, WS-F)
                             WS-SPRITE
*>                       The sprite of each face of the first element (the icon's face where the element has none).
                         MOVE 1 TO WS-FACES
                         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                             MOVE WS-SPRITE TO WS-FACE-SPRITE(WS-D)
                             IF MF-PRESENT(1, WS-D) = 1
                                 CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED MF-TEXTURE(1, WS-D)
                                     WS-FACE-SPRITE(WS-D)
                             END-IF
                         END-PERFORM
*>                       The GUI icon: the model's quads under its gui display transform (item-gui.cob), the isometric cube of a block item.
                         CALL "ITEM-GUI-BAKE" USING CLIENT-STATE L-ITEM MODEL-RESOLVED
                     END-IF
                 END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-SPECIAL = 1
*>       A code-drawn model (a shield, a chest, a banner ...): the hand has no model of it to draw (state 2).
         MOVE 2 TO IS-FP-STATE(L-ITEM + 1)
     END-IF
     IF MR-FP-PRESENT = 1 AND WS-SPECIAL = 0
         MOVE 1 TO IS-FP-STATE(L-ITEM + 1)
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 9
             COMPUTE WS-SLOT = L-ITEM * 9 + WS-D
             MOVE MR-FP(WS-D) TO IS-FP-VAL(WS-SLOT)
         END-PERFORM
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         IF MR-DX-PRESENT(WS-D) = 1 AND WS-SPECIAL = 0
             COMPUTE WS-SLOT = L-ITEM * 3 + WS-D
             MOVE 1 TO IS-DX-STATE(WS-SLOT)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
                 COMPUTE WS-SLOT = L-ITEM * 27 + (WS-D - 1) * 9 + WS-K
                 MOVE MR-DX((WS-D - 1) * 9 + WS-K) TO IS-DX-VAL(WS-SLOT)
             END-PERFORM
         END-IF
     END-PERFORM
     IF WS-FACES = 1
         MOVE 1 TO IS-FACE-DONE(L-ITEM + 1)
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             COMPUTE WS-SLOT = L-ITEM * 6 + WS-D
             MOVE WS-FACE-SPRITE(WS-D) TO IS-FACE-SPRITE(WS-SLOT)
         END-PERFORM
     END-IF
     MOVE WS-LAYER1-SPRITE TO IS-LAYER1(L-ITEM + 1)
     MOVE WS-SPRITE TO IS-SPRITE(L-ITEM + 1)
     MOVE WS-SPRITE TO L-SPRITE
     GOBACK.
 END PROGRAM ITEM-SPRITE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FACE-SPRITE.
*> USING CLIENT-STATE, item id, direction (BINARY-LONG, DIR-DOWN 1 to DIR-EAST 6), sprite out: the atlas sprite of that face of a block item's model
*> (standard set, found with the item's icon on first use). 0 for an item with no block model (a flat item, a stand-in item, an id out of range):
*> the hand then extrudes the icon of ITEM-SPRITE-OF instead of drawing a cube.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ICON                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-DIRECTION L-SPRITE.
     MOVE 0 TO L-SPRITE
     IF L-ITEM >= 0 AND L-ITEM < 2048 AND L-DIRECTION >= 1 AND L-DIRECTION <= 6
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-ICON
         IF IS-FACE-DONE(L-ITEM + 1) = 1
             COMPUTE WS-SLOT = L-ITEM * 6 + L-DIRECTION
             MOVE IS-FACE-SPRITE(WS-SLOT) TO L-SPRITE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEM-FACE-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-HAND-DISPLAY.
*> USING CLIENT-STATE, item id, present out (1 when the item's model chain names display.firstperson_righthand; 2 for a code-drawn "special" model, which the hand does not draw), values out (9 FLOAT-LONG: rotation x y z in
*> degrees, translation x y z in sixteenths, scale x y z). The standard set's models are read on the item's first use (ITEM-SPRITE-OF); a stand-in item
*> and an item whose models name none have present 0 (the caller uses the defaults of 12 section 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ICON                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-VALUES.
    05 L-VALUE             FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-PRESENT L-VALUES.
     MOVE 0 TO L-PRESENT
     IF L-ITEM >= 0 AND L-ITEM < 2048
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-ICON
         IF IS-FP-STATE(L-ITEM + 1) = 2
             MOVE 2 TO L-PRESENT
         END-IF
         IF IS-FP-STATE(L-ITEM + 1) = 1
             MOVE 1 TO L-PRESENT
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 9
                 COMPUTE WS-SLOT = L-ITEM * 9 + WS-D
                 MOVE IS-FP-VAL(WS-SLOT) TO L-VALUE(WS-D)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEM-HAND-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-DISPLAY.
*> USING CLIENT-STATE, item id, context (1 thirdperson_righthand, 2 thirdperson_lefthand, 3 fixed), present out (1 when the item's model chain names that context, else 0),
*> values out (9 FLOAT-LONG: rotation x y z in degrees, translation x y z in sixteenths, scale x y z). Read on the item's first use (ITEM-SPRITE-OF); a stand-in item, an item whose
*> models name none and a code-drawn "special" model have present 0 (the caller uses the defaults of 12 section 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ICON                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-CONTEXT              BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-VALUES.
    05 L-VALUE             FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-CONTEXT L-PRESENT L-VALUES.
     MOVE 0 TO L-PRESENT
     IF L-ITEM >= 0 AND L-ITEM < 2048 AND L-CONTEXT >= 1 AND L-CONTEXT <= 3
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE L-ITEM WS-ICON
         COMPUTE WS-SLOT = L-ITEM * 3 + L-CONTEXT
         IF IS-DX-STATE(WS-SLOT) = 1
             MOVE 1 TO L-PRESENT
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 9
                 COMPUTE WS-SLOT = L-ITEM * 27 + (L-CONTEXT - 1) * 9 + WS-D
                 MOVE IS-DX-VAL(WS-SLOT) TO L-VALUE(WS-D)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEM-DISPLAY.
