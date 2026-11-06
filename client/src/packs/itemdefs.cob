*> Item icons (docs/protocol/08-resource-packs.md §5.7, §6, §10.7, §10.11; standin-content §2):
*> ITEMDEFS-LOAD gives every item of standin-content §2 its icon sprite: the item definition
*> assets/cobolcraft/items/<item key path>.json of the top-most pack that has it, read by
*> ITEMDEF-SPRITE. The icon is the layer0 sprite of the model a "minecraft:model" definition names,
*> when that model's parent chain reaches minecraft:builtin/generated (08 §5.7); a definition of
*> another type, a chain that does not reach the generated model (or names a model no pack has),
*> malformed JSON or no definition at all give the missing texture (sprite 1). The sprites live in
*> the block-and-item atlas of ATLAS-BUILD (texture 0; the items.json atlas definition adds the
*> textures/item/ sprites to it), so ATLAS-BUILD runs first.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEMDEFS-LOAD.
*> USING CLIENT-STATE: fills IT-SPRITE for item ids 0 to 17.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-ITEM-COUNT
         MOVE SPACES TO WS-PATH
         STRING "assets/cobolcraft/items/" FUNCTION TRIM(CL-IT-KEY(WS-I)) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
             WS-FOUND
         MOVE 1 TO IT-SPRITE(WS-I)
         IF WS-FOUND = 1
             CALL "ITEMDEF-SPRITE" USING CLIENT-STATE WS-TEXT WS-LENGTH IT-SPRITE(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEMDEFS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEMDEF-SPRITE.
*> USING CLIENT-STATE, definition text area, its length, sprite out: the icon sprite of one item
*> definition (above); 1 when it has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY CLMODEL.
 01 WS-PATH                PIC X(32).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-TYPE                PIC X(80).
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-GENERATED           BINARY-LONG.
 01 WS-LAYER               PIC X(80) VALUE "#layer0".
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-SPRITE.
     MOVE 1 TO L-SPRITE
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
     MOVE SPACES TO WS-TYPE WS-ID
     MOVE 0 TO WS-ID-LENGTH
     IF JD-ERROR = 0
         MOVE "model.type" TO WS-PATH
         MOVE 10 TO WS-PATH-LENGTH
         CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-TYPE WS-CAP WS-LENGTH
         MOVE "model.model" TO WS-PATH
         MOVE 11 TO WS-PATH-LENGTH
         CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ID WS-CAP WS-ID-LENGTH
     END-IF
     IF (WS-TYPE = "minecraft:model" OR WS-TYPE = "model") AND WS-ID-LENGTH > 0
         CALL "ITEM-MODEL-RESOLVE" USING CLIENT-STATE WS-ID WS-ID-LENGTH MODEL-RESOLVED
             WS-GENERATED
         IF WS-GENERATED = 1
             CALL "MODEL-SPRITE" USING CLIENT-STATE MODEL-RESOLVED WS-LAYER L-SPRITE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ITEMDEF-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-MODEL-RESOLVE.
*> USING CLIENT-STATE, model id (PIC X(80), "ns:path", namespace minecraft by default), id length,
*> MODEL-RESOLVED out (the texture slots merged along the chain, the child's first), generated out
*> (1 = the chain reaches minecraft:builtin/generated; 0 when it ends elsewhere, names a model no
*> pack has, or is longer than 16 models, a cycle).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NODE                BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   PIC X(80).
 01 L-ID-LENGTH            BINARY-LONG.
 COPY CLMODEL.
 01 L-GENERATED            BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-ID-LENGTH MODEL-RESOLVED L-GENERATED.
     INITIALIZE MODEL-RESOLVED
     MOVE 0 TO L-GENERATED WS-DEPTH
     MOVE L-ID TO WS-ID
     MOVE L-ID-LENGTH TO WS-ID-LENGTH
     PERFORM UNTIL WS-ID-LENGTH = 0 OR WS-DEPTH = 16
         ADD 1 TO WS-DEPTH
         IF WS-ID = "minecraft:builtin/generated" OR WS-ID = "builtin/generated"
             MOVE 1 TO L-GENERATED
             MOVE 0 TO WS-ID-LENGTH
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-COLON
         INSPECT WS-ID(1:WS-ID-LENGTH) TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
         MOVE SPACES TO WS-PATH
         IF WS-COLON < WS-ID-LENGTH
             STRING "assets/" WS-ID(1:WS-COLON) "/models/"
                 WS-ID(WS-COLON + 2:WS-ID-LENGTH - WS-COLON - 1) ".json" DELIMITED BY SIZE
                 INTO WS-PATH
         ELSE
             STRING "assets/minecraft/models/" WS-ID(1:WS-ID-LENGTH) ".json" DELIMITED BY SIZE
                 INTO WS-PATH
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
             WS-FOUND
         MOVE 0 TO WS-ID-LENGTH
         MOVE SPACES TO WS-ID
         IF WS-FOUND = 1
             CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
             MOVE "textures" TO WS-NAME
             MOVE 8 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-NODE
             CALL "MODEL-TEXTURES-PARSE" USING JSON-DOC WS-NODE MODEL-RESOLVED
             MOVE "parent" TO WS-NAME
             MOVE 6 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-NODE
             CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ID WS-CAP WS-ID-LENGTH
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEM-MODEL-RESOLVE.
