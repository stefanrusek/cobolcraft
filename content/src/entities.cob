*> Entity type and static id lookups of the content library (content-api section 2; 21 section 2, 46). An entity row is
*> the CT-ENTITY-ROW view of a generated row (content/copy/gen/entities.cpy) or of a row of the built-in
*> layer (builtin-entities.cob); the set type chooses which rows exist (ENTITY-ROW-AT). The static registries
*> other than block, item and entity_type keep the vanilla numbering in both world types (04 section 5), so
*> they are read from one table (content/copy/gen/staticids.cpy). An unknown key is CT-NOT-FOUND with id 0;
*> without an open set CT-NOT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ENTITY-BY-KEY.
*> USING key (PIC X(112), space padded; "minecraft:" is optional in the standard set), entity id out
*> (BINARY-LONG), row out (PIC X(66), CT-ENTITY-ROW), status out (CT-OK, CT-NOT-FOUND with id 0 and the
*> row of entity 0, CT-NOT-OPEN with the row left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-ROW                 PIC X(66).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(3).
    05 WS-R-KEY            PIC X(22).
    05 FILLER              PIC X(41).
 01 WS-ROW-KEY             PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(66).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID L-ROW L-STATUS.
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         MOVE 0 TO L-ID
         GOBACK
     END-IF
     MOVE 0 TO L-ID
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "ENTITY-ROW-AT" USING L-ID L-ROW WS-STATUS WS-COUNT
     MOVE L-KEY TO WS-KEY
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:54) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR L-STATUS = CT-OK
         CALL "ENTITY-ROW-AT" USING WS-I WS-ROW WS-STATUS WS-COUNT
         MOVE WS-R-KEY TO WS-ROW-KEY
         IF WS-ROW-KEY = WS-KEY
             MOVE WS-I TO L-ID
             MOVE WS-ROW TO L-ROW
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONTENT-ENTITY-BY-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ENTITY-ATTRIBUTE.
*> USING entity id (BINARY-LONG), attribute name (PIC X(32), space padded), value out (PIC X(20), the value text,
*> blank when none), status out (CT-OK; CT-NOT-FOUND for an entity or a name the table does not have; CT-NOT-OPEN).
*> Only the built-in layer has attribute rows (cobolcraft-standard-core.md section 5.5); the standard set
*> has none here (the vanilla values are rules of 18 to 21), so it answers CT-NOT-FOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(20).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-VALUE L-STATUS.
     MOVE SPACES TO L-VALUE
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         CALL "BUILTIN-ENTITY-ATTRIBUTE" USING L-ID L-NAME L-VALUE L-STATUS
     END-IF
     GOBACK.
 END PROGRAM CONTENT-ENTITY-ATTRIBUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-STATIC-ID.
*> USING registry (PIC X(48), "minecraft:" optional), key (PIC X(112), "minecraft:" optional), id out
*> (BINARY-LONG), status out (CT-OK; CT-NOT-FOUND with id 0 for an unknown registry or key, and for a key
*> of another registry; CT-NOT-OPEN). block, item and entity_type answer through the lookups of the set
*> (a cobolcraft set has its own numbering); every other registry is the vanilla table of 46.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY STATICIDS.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ROW-REGISTRY        PIC X(48).
 01 WS-ROW-KEY             PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-ID-TEXT             PIC X(4).
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-ID L-STATUS.
     MOVE 0 TO L-ID
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     MOVE L-REGISTRY TO WS-REGISTRY
     IF WS-REGISTRY(1:10) = "minecraft:"
         MOVE WS-REGISTRY(11:38) TO WS-ROW-REGISTRY
         MOVE WS-ROW-REGISTRY TO WS-REGISTRY
     END-IF
     MOVE L-KEY TO WS-KEY
     EVALUATE WS-REGISTRY
         WHEN "block"
             CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY L-ID WS-BLOCK-ROW L-STATUS
         WHEN "item"
             CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ID WS-ITEM-ROW L-STATUS
         WHEN "entity_type"
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY L-ID WS-ENTITY-ROW L-STATUS
         WHEN OTHER
             IF WS-KEY(1:10) = "minecraft:"
                 MOVE WS-KEY(11:54) TO WS-REST
                 MOVE WS-REST TO WS-KEY
             END-IF
             IF WS-KEY NOT = SPACES
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GEN-STATIC-ROWS OR L-STATUS = CT-OK
                     COMPUTE WS-START = WS-I * GEN-STATIC-ROW-WIDTH + 1
                     IF GEN-STATIC-DATA(WS-START:GEN-STATIC-W-REGISTRY) = WS-REGISTRY
                         MOVE GEN-STATIC-DATA(WS-START + GEN-STATIC-OFF-KEY:GEN-STATIC-W-KEY) TO WS-ROW-KEY
                         IF WS-ROW-KEY = WS-KEY
                             MOVE GEN-STATIC-DATA(WS-START + GEN-STATIC-OFF-ID:GEN-STATIC-W-ID) TO WS-ID-TEXT
                             COMPUTE L-ID = FUNCTION NUMVAL(WS-ID-TEXT)
                             MOVE CT-OK TO L-STATUS
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTENT-STATIC-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-ROW-AT.
*> USING entity id (BINARY-LONG), row out (PIC X(66)), status out (CT-OK, or CT-NOT-FOUND for an id outside
*> the set, the row left as it was), count out (BINARY-LONG: the rows of the set). The set type chooses the rows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(66).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         CALL "BUILTIN-ENTITY-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     ELSE
         CALL "ENTITY-STD-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     END-IF
     GOBACK.
 END PROGRAM ENTITY-ROW-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-STD-ROW.
*> Same parameters as ENTITY-ROW-AT: row N of the generated entity table (content/copy/gen/entities.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY ENTITIES.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(66).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE GEN-ENTITY-ROWS TO L-COUNT
     IF L-ID < 0 OR L-ID >= GEN-ENTITY-ROWS
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-START = L-ID * GEN-ENTITY-ROW-WIDTH + 1
     MOVE GEN-ENTITY-DATA(WS-START:GEN-ENTITY-ROW-WIDTH) TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM ENTITY-STD-ROW.
