*> The built-in entity layer of the cobolcraft world type (T0207; docs/design/standin-content.md section 3 and 12.1,
*> cobolcraft-standard-core.md section 5.5): the four entity types as rows of the same CT-ENTITY-ROW shape the
*> generated standard table has (id, key, size, category), and the mob values the shared engines read as
*> attribute rows (name and value text; eye height, tracking range and update interval are named like the
*> attributes). Each row line below separates its columns by "|"; each attribute line is "id|name|value".
*> The operator and the loose item are the player and item entity roles (WT-22): their category is the
*> standard player's and item's (MISC).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-ENTITY-ROW.
*> USING entity id (BINARY-LONG), row out (PIC X(66)), status out (CT-OK; CT-NOT-FOUND for an id outside 0 to 3,
*> the row left as it was), count out (BINARY-LONG: 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(80) VALUE "0|cobolcraft:operator|0.6 x 1.8|MISC".
    05 FILLER PIC X(80) VALUE "1|cobolcraft:loose_item|0.25 x 0.25|MISC".
    05 FILLER PIC X(80) VALUE "2|cobolcraft:sodgrazer|0.9 x 0.9|CREATURE".
    05 FILLER PIC X(80) VALUE "3|cobolcraft:abend|0.75 x 0.75|MONSTER".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-LINE             PIC X(80) OCCURS 4 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BUILT.
    05 WS-B-ID             PIC X(3).
    05 WS-B-KEY            PIC X(22).
    05 WS-B-SIZE           PIC X(15).
    05 WS-B-CATEGORY       PIC X(26).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(66).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE 4 TO L-COUNT
     IF L-ID < 0 OR L-ID > 3
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-INDEX = L-ID + 1
     MOVE SPACES TO WS-BUILT
     UNSTRING WS-LINE(WS-INDEX) DELIMITED BY "|" INTO WS-B-ID WS-B-KEY WS-B-SIZE WS-B-CATEGORY
     MOVE WS-BUILT TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM BUILTIN-ENTITY-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-ENTITY-ATTRIBUTE.
*> USING entity id (BINARY-LONG), attribute name (PIC X(32)), value out (PIC X(20)), status out (CT-OK, or
*> CT-NOT-FOUND for an entity or name without a row, the value left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(40) VALUE "0|eye_height|1.62".
    05 FILLER PIC X(40) VALUE "1|eye_height|0.2125".
    05 FILLER PIC X(40) VALUE "2|max_health|8.0".
    05 FILLER PIC X(40) VALUE "2|movement_speed|0.1".
    05 FILLER PIC X(40) VALUE "2|step_height|1.0".
    05 FILLER PIC X(40) VALUE "2|eye_height|0.7".
    05 FILLER PIC X(40) VALUE "2|tracking_range|5".
    05 FILLER PIC X(40) VALUE "2|update_interval|3".
    05 FILLER PIC X(40) VALUE "3|max_health|12.0".
    05 FILLER PIC X(40) VALUE "3|movement_speed|0.12".
    05 FILLER PIC X(40) VALUE "3|attack_damage|3.0".
    05 FILLER PIC X(40) VALUE "3|follow_range|20.0".
    05 FILLER PIC X(40) VALUE "3|step_height|1.0".
    05 FILLER PIC X(40) VALUE "3|eye_height|0.5".
    05 FILLER PIC X(40) VALUE "3|tracking_range|5".
    05 FILLER PIC X(40) VALUE "3|update_interval|3".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-LINE             PIC X(40) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW-ID              PIC X(4).
 01 WS-ROW-NAME            PIC X(32).
 01 WS-ROW-VALUE           PIC X(20).
 01 WS-WANTED              PIC 9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(20).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-VALUE L-STATUS.
     MOVE CT-NOT-FOUND TO L-STATUS
     IF L-ID < 0 OR L-ID > 9
         GOBACK
     END-IF
     MOVE L-ID TO WS-WANTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR L-STATUS = CT-OK
         MOVE SPACES TO WS-ROW-ID WS-ROW-NAME WS-ROW-VALUE
         UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-ROW-ID WS-ROW-NAME WS-ROW-VALUE
         IF WS-ROW-ID(1:1) = WS-WANTED AND WS-ROW-NAME = L-NAME
             MOVE WS-ROW-VALUE TO L-VALUE
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUILTIN-ENTITY-ATTRIBUTE.
