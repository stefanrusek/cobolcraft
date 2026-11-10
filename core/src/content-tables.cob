*> The core's item, entity-type and recipe tables (CITEMS.cpy), built once when a world opens from the content set
*> (CORE-TABLES-OPEN, called by CORE-WORLD-OPEN after BLOCKS-OPEN): the same rows for either world type, so a caller
*> never tests the type. Item, entity and recipe rows are those of content-api section 2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TABLES-NUMBER-AFTER.
*> USING text (PIC X(160)), marker (PIC X(20), space padded; trailing spaces do not count), value out (BINARY-DOUBLE, thousandths: 3.0 gives 3000),
*> found out (BINARY-LONG 1 or 0): the number that follows the marker in the text, up to a comma or space.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BEFORE              PIC X(160).
 01 WS-REST                PIC X(160).
 01 WS-TOKEN               PIC X(40).
 01 WS-MARK                PIC X(20).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(160).
 01 L-MARKER               PIC X(20).
 01 L-VALUE                BINARY-DOUBLE.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-MARKER L-VALUE L-FOUND.
     MOVE 0 TO L-VALUE L-FOUND
     MOVE SPACES TO WS-BEFORE WS-REST WS-TOKEN
     MOVE FUNCTION TRIM(L-MARKER) TO WS-MARK
     UNSTRING L-TEXT DELIMITED BY FUNCTION TRIM(WS-MARK) INTO WS-BEFORE WS-REST
     IF WS-REST NOT = SPACES
         MOVE FUNCTION TRIM(WS-REST LEADING) TO WS-REST
         UNSTRING WS-REST DELIMITED BY "," OR SPACE INTO WS-TOKEN
         IF FUNCTION TEST-NUMVAL(WS-TOKEN) = 0
             COMPUTE L-VALUE ROUNDED = FUNCTION NUMVAL(WS-TOKEN) * 1000
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TABLES-NUMBER-AFTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEMS-OPEN.
*> No parameters: fills CORE-ITEMS from CONTENT-ITEM-BY-ID for every item of the open set (rules of CITEMS.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MARKER              PIC X(20).
 01 WS-TEXT                PIC X(160).
 01 WS-HITS                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO IT-COUNT
     MOVE CT-OK TO WS-STATUS
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= CT-ITEM-COUNT OR WS-ID >= CI-MAX-ITEMS
             OR WS-STATUS NOT = CT-OK
         CALL "CONTENT-ITEM-BY-ID" USING WS-ID WS-ROW WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE WS-ROW TO CT-ITEM-ROW
             COMPUTE WS-INDEX = WS-ID + 1
             ADD 1 TO IT-COUNT
             MOVE SPACES TO IT-KEY(WS-INDEX)
             MOVE FUNCTION TRIM(CT-IR-KEY) TO IT-KEY(WS-INDEX)
             MOVE FUNCTION LENGTH(FUNCTION TRIM(CT-IR-KEY)) TO IT-KEY-LENGTH(WS-INDEX)
             MOVE -1 TO IT-PLACES-STATE(WS-INDEX)
             IF CT-IR-BLOCK NOT = SPACES
                 COMPUTE WS-BLOCK = FUNCTION NUMVAL(CT-IR-BLOCK)
                 MOVE CB-DEFAULT-STATE(WS-BLOCK + 1) TO IT-PLACES-STATE(WS-INDEX)
             END-IF
             MOVE 0 TO IT-MAX-STACK(WS-INDEX)
             IF CT-IR-STACK-SIZE NOT = SPACES
                 COMPUTE IT-MAX-STACK(WS-INDEX) = FUNCTION NUMVAL(CT-IR-STACK-SIZE)
             END-IF
             MOVE CT-IR-COMPONENTS(1:160) TO WS-TEXT
             MOVE 0 TO IT-TOOL-CLASS(WS-INDEX) IT-FOOD(WS-INDEX)
             MOVE 1 TO IT-ATTACK(WS-INDEX)
             MOVE 0 TO WS-HITS
             INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "tool #minecraft:mineable/pickaxe"
             IF WS-HITS > 0
                 MOVE 1 TO IT-TOOL-CLASS(WS-INDEX)
             END-IF
             MOVE 0 TO WS-HITS
             INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "tool #minecraft:mineable/shovel"
             IF WS-HITS > 0
                 MOVE 2 TO IT-TOOL-CLASS(WS-INDEX)
             END-IF
             MOVE "food " TO WS-MARKER
             CALL "TABLES-NUMBER-AFTER" USING WS-TEXT WS-MARKER WS-VALUE WS-FOUND
             IF WS-FOUND = 1
                 COMPUTE IT-FOOD(WS-INDEX) = WS-VALUE / 1000
             END-IF
             MOVE "attack_damage " TO WS-MARKER
             CALL "TABLES-NUMBER-AFTER" USING WS-TEXT WS-MARKER WS-VALUE WS-FOUND
             IF WS-FOUND = 1
                 COMPUTE IT-ATTACK(WS-INDEX) = 1 + WS-VALUE / 1000
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEMS-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITIES-OPEN.
*> No parameters: fills CORE-ENTITY-TYPES from the entity rows of the open set (size text "w x h" in blocks) and the
*> roles of CORE-ENTITY-ROLES by key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CITEMS.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-WIDTH               PIC X(15).
 01 WS-HEIGHT              PIC X(15).
 01 WS-KEY                 PIC X(112).
 01 WS-ROLE-ID             BINARY-LONG.
 01 WS-ROLE-ROW            PIC X(66).
 PROCEDURE DIVISION.
     MOVE 0 TO ET-COUNT
     MOVE CT-OK TO WS-STATUS
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= CT-ENTITY-COUNT OR WS-ID >= CI-MAX-ENTITIES
             OR WS-STATUS NOT = CT-OK
         CALL "ENTITY-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
         IF WS-STATUS = CT-OK
             MOVE WS-ROW TO CT-ENTITY-ROW
             COMPUTE WS-INDEX = WS-ID + 1
             ADD 1 TO ET-COUNT
             MOVE SPACES TO ET-KEY(WS-INDEX) WS-WIDTH WS-HEIGHT
             MOVE FUNCTION TRIM(CT-ER-KEY) TO ET-KEY(WS-INDEX)
             MOVE FUNCTION LENGTH(FUNCTION TRIM(CT-ER-KEY)) TO ET-KEY-LENGTH(WS-INDEX)
             UNSTRING CT-ER-SIZE DELIMITED BY " x " INTO WS-WIDTH WS-HEIGHT
             COMPUTE ET-WIDTH-MILLI(WS-INDEX) ROUNDED = FUNCTION NUMVAL(WS-WIDTH) * 1000
             COMPUTE ET-HEIGHT-MILLI(WS-INDEX) ROUNDED = FUNCTION NUMVAL(WS-HEIGHT) * 1000
         END-IF
     END-PERFORM
     MOVE "cobolcraft:operator" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY CR-OPERATOR WS-ROLE-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO CR-OPERATOR
     END-IF
     MOVE "cobolcraft:loose_item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY CR-LOOSE-ITEM WS-ROLE-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO CR-LOOSE-ITEM
     END-IF
     MOVE "cobolcraft:sodgrazer" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY CR-SODGRAZER WS-ROLE-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO CR-SODGRAZER
     END-IF
     MOVE "cobolcraft:abend" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY CR-ABEND WS-ROLE-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO CR-ABEND
     END-IF
     GOBACK.
 END PROGRAM ENTITIES-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-OPEN.
*> No parameters: fills CORE-RECIPES from the recipe store of the content set (the cobolcraft set's built-in
*> recipes are loaded here, BUILTIN-RECIPES-LOAD; a standard set's recipes come with its reloadable layer).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-LINES               BINARY-LONG.
 01 WS-FIT                 BINARY-LONG.
 01 WS-LINE-ITEMS.
    05 WS-LINE-ITEM        BINARY-LONG OCCURS 9 TIMES.
 01 WS-LINE-COUNTS.
    05 WS-LINE-COUNT       BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO RP-COUNT
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         GOBACK
     END-IF
     CALL "BUILTIN-RECIPES-LOAD"
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT
         IF RR-SERIALIZER(WS-R) = 1
             MOVE 0 TO WS-LINES
             MOVE 1 TO WS-FIT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-ING-COUNT(WS-R)
                 MOVE SPACES TO WS-KEY
                 MOVE RR-ING(WS-R, WS-I)(1:112) TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
                 MOVE 0 TO WS-L
                 PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > WS-LINES OR WS-LINE-ITEM(WS-L) = WS-ID
                     CONTINUE
                 END-PERFORM
                 IF WS-L > WS-LINES
                     ADD 1 TO WS-LINES
                     MOVE WS-ID TO WS-LINE-ITEM(WS-LINES)
                     MOVE 0 TO WS-LINE-COUNT(WS-LINES)
                 END-IF
                 ADD 1 TO WS-LINE-COUNT(WS-L)
             END-PERFORM
             IF WS-LINES <= RP-MAX-LINES AND RP-COUNT < RP-MAX
                 ADD 1 TO RP-COUNT
                 INITIALIZE RP-ENTRY(RP-COUNT)
                 MOVE WS-LINES TO RP-LINE-COUNT(RP-COUNT)
                 PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > WS-LINES
                     MOVE WS-LINE-ITEM(WS-L) TO RP-IN-ITEM(RP-COUNT, WS-L)
                     MOVE WS-LINE-COUNT(WS-L) TO RP-IN-COUNT(RP-COUNT, WS-L)
                 END-PERFORM
                 MOVE SPACES TO WS-KEY
                 MOVE RR-RESULT-ID(WS-R) TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
                 MOVE WS-ID TO RP-RESULT-ITEM(RP-COUNT)
                 MOVE RR-RESULT-COUNT(WS-R) TO RP-RESULT-COUNT(RP-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPES-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-TABLES-OPEN.
*> No parameters: BLOCKS-OPEN must have run. Builds the item, entity-type and recipe tables of CITEMS.cpy.
 PROCEDURE DIVISION.
     CALL "ITEMS-OPEN"
     CALL "ENTITIES-OPEN"
     CALL "RECIPES-OPEN"
     GOBACK.
 END PROGRAM CORE-TABLES-OPEN.
