*> Item lookups of the content library (content-api section 2; 25 part 1 section 2 and 13, 17 section 1). An
*> item row is the CT-ITEM-ROW view of a generated row (content/copy/gen/items.cpy) or of a row of the
*> built-in layer (builtin-items.cob); the set type chooses which rows exist (ITEM-ROW-AT). An unknown key
*> or id is CT-NOT-FOUND with row 0 (air or nothing) and id 0; without an open set CT-NOT-OPEN.
*> Every generated row has a stack size; its summary holds whole "name value" entries (none is cut), and
*> max_damage first when the item has durability; the damage column holds up to four digits. A damage
*> column left blank (an item without durability) is not found.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ITEM-BY-KEY.
*> USING key (PIC X(64), space padded; "minecraft:" is optional in the standard set), item id out
*> (BINARY-LONG), row out (PIC X(270), CT-ITEM-ROW), status out (CT-OK, CT-NOT-FOUND with id 0 and the
*> row of item 0, CT-NOT-OPEN with the row left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(64).
 01 WS-REST                PIC X(64).
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-ROW-KEY             PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(270).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID L-ROW L-STATUS.
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         MOVE 0 TO L-ID
         GOBACK
     END-IF
     MOVE 0 TO L-ID
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "ITEM-ROW-AT" USING L-ID L-ROW WS-STATUS WS-COUNT
     MOVE L-KEY TO WS-KEY
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:54) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR L-STATUS = CT-OK
         CALL "ITEM-ROW-AT" USING WS-I WS-ROW WS-STATUS WS-COUNT
         MOVE WS-R-KEY TO WS-ROW-KEY
         IF WS-ROW-KEY = WS-KEY
             MOVE WS-I TO L-ID
             MOVE WS-ROW TO L-ROW
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONTENT-ITEM-BY-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ITEM-BY-ID.
*> USING item id (BINARY-LONG), row out (PIC X(270)), status out (CT-OK; CT-NOT-FOUND with the row of item 0;
*> CT-NOT-OPEN with the row left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(270).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS.
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE L-ID TO WS-ID
     CALL "ITEM-ROW-AT" USING WS-ID L-ROW L-STATUS WS-COUNT
     IF L-STATUS NOT = CT-OK
         MOVE 0 TO WS-ID
         CALL "ITEM-ROW-AT" USING WS-ID L-ROW WS-STATUS WS-COUNT
     END-IF
     GOBACK.
 END PROGRAM CONTENT-ITEM-BY-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-ITEM-COMPONENT.
*> USING item id (BINARY-LONG), component name (PIC X(32), space padded), value out (PIC X(100), blank when
*> the component has none), status out (CT-OK; CT-NOT-FOUND for an unknown item or a component the row does
*> not have, the value blank; CT-NOT-OPEN). max_stack_size is the stack size column of the row (blank column:
*> not found); max_damage is the damage column (blank column: not found);
*> every other name is looked up among the entries of the row's summary, separated by ", ", each the name, a
*> space and the value (everything after the first space).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(70).
    05 WS-R-STACK          PIC X(2).
    05 WS-R-DAMAGE         PIC X(4).
    05 FILLER              PIC X(34).
    05 WS-R-COMPONENTS     PIC X(160).
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-ENTRY               PIC X(160).
 01 WS-ENTRY-NAME          PIC X(160).
 01 WS-ENTRY-VALUE         PIC X(160).
 01 WS-NAME                PIC X(100).
 01 WS-SPLIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-VALUE L-STATUS.
     MOVE SPACES TO L-VALUE
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     MOVE L-ID TO WS-ID
     CALL "ITEM-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE L-NAME TO WS-NAME
     EVALUATE TRUE
         WHEN L-NAME = "max_stack_size"
             IF WS-R-STACK NOT = SPACES
                 MOVE WS-R-STACK TO L-VALUE
                 MOVE CT-OK TO L-STATUS
             END-IF
         WHEN L-NAME = "max_damage"
             IF WS-R-DAMAGE NOT = SPACES
                 MOVE FUNCTION TRIM(WS-R-DAMAGE) TO L-VALUE
                 MOVE CT-OK TO L-STATUS
             END-IF
         WHEN OTHER
             MOVE 1 TO WS-POINTER
             PERFORM UNTIL WS-POINTER > 160 OR L-STATUS = CT-OK
                 MOVE SPACES TO WS-ENTRY
                 UNSTRING WS-R-COMPONENTS DELIMITED BY ", " INTO WS-ENTRY WITH POINTER WS-POINTER
                 MOVE SPACES TO WS-ENTRY-NAME WS-ENTRY-VALUE
                 UNSTRING WS-ENTRY DELIMITED BY SPACE INTO WS-ENTRY-NAME COUNT IN WS-SPLIT
                 IF WS-ENTRY-NAME NOT = SPACES AND WS-ENTRY-NAME = WS-NAME
                     IF WS-SPLIT < 159
                         MOVE WS-ENTRY(WS-SPLIT + 2:159 - WS-SPLIT) TO L-VALUE
                     END-IF
                     MOVE CT-OK TO L-STATUS
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM CONTENT-ITEM-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-ROW-AT.
*> USING item id (BINARY-LONG), row out (PIC X(270)), status out (CT-OK, or CT-NOT-FOUND for an id outside the
*> set, the row left as it was), count out (BINARY-LONG: the rows of the set). The set type chooses the rows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(270).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         CALL "BUILTIN-ITEM-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     ELSE
         CALL "ITEM-STD-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     END-IF
     GOBACK.
 END PROGRAM ITEM-ROW-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-STD-ROW.
*> Same parameters as ITEM-ROW-AT: row N of the generated item table (content/copy/gen/items.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY ITEMS.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(270).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE GEN-ITEM-ROWS TO L-COUNT
     IF L-ID < 0 OR L-ID >= GEN-ITEM-ROWS
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-START = L-ID * GEN-ITEM-ROW-WIDTH + 1
     MOVE GEN-ITEM-DATA(WS-START:GEN-ITEM-ROW-WIDTH) TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM ITEM-STD-ROW.
