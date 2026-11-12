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
     GOBACK.
 END PROGRAM LAZY-STATE-BAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-SPRITE-OF.
*> USING CLIENT-STATE, item id, sprite out (0 = draw no icon): the atlas sprite of the item's icon. With the
*> standard set open it is found on the item's first use (assets/<namespace>/items/<path>.json of the top-most
*> pack, its model chain: a flat item's layer0, a block item's up face, else the first face of its first
*> element; the missing sprite 1 when the definition or model gives none) and kept in IS-SPRITE; otherwise
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
 01 WS-JPATHS.
    05 FILLER              PIC X(24) VALUE "model.model".
    05 FILLER              PIC X(24) VALUE "model.fallback.model".
    05 FILLER              PIC X(24) VALUE "model.on_false.model".
    05 FILLER              PIC X(24) VALUE "model.models".
 01 WS-JPATH-TABLE REDEFINES WS-JPATHS.
    05 WS-JPATH            PIC X(24) OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-JP                  PIC X(32).
 01 WS-JP-LENGTH           BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-GENERATED           BINARY-LONG.
 01 WS-LAYER               PIC X(80) VALUE "#layer0".
 01 WS-SPRITE              BINARY-LONG.
 01 WS-F                   BINARY-LONG.
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
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3 OR WS-ID-LENGTH > 0
                     MOVE SPACES TO WS-JP
                     MOVE WS-JPATH(WS-K) TO WS-JP
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JP)) TO WS-JP-LENGTH
                     CALL "JSON-FIND" USING JSON-DOC WS-JP WS-JP-LENGTH WS-NODE
                     CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ID WS-CAP WS-ID-LENGTH
                 END-PERFORM
             END-IF
             IF WS-ID-LENGTH > 0
                 CALL "ITEM-MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
                     WS-GENERATED
                 IF WS-GENERATED = 1
                     CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-LAYER WS-SPRITE
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
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     MOVE WS-SPRITE TO IS-SPRITE(L-ITEM + 1)
     MOVE WS-SPRITE TO L-SPRITE
     GOBACK.
 END PROGRAM ITEM-SPRITE-OF.
