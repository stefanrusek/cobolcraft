*> Opening and closing a content set (content-api section 2; world-types WT-14, WT-25; 22 section 8.2 and 8.3).
*> CONTENT-OPEN builds the set of one world or connection and CONTENT-CLOSE frees it, so a process that
*> leaves one world and opens another keeps no stale ids. The standard type (and the hidden debug type, which
*> opens as the standard set) is refused unless the packs check of 22 8.2 says ok, then loads the 51 world
*> registries and the tags of vanilla-data (feature packs are not loaded; the world's datapacks/ folder is
*> not read here); the cobolcraft type reads nothing from the generated directory: it attaches the built-in
*> layer (builtin-blocks.cob, builtin-items.cob, builtin-entities.cob) and its tags. After a failed open
*> no set is open.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-OPEN.
*> USING type (BINARY-LONG: CT-TYPE-STANDARD, CT-TYPE-COBOLCRAFT or CT-TYPE-DEBUG), generated directory (PIC
*> X(1100), z-string or space padded; ignored by the cobolcraft type), status out: CT-OK; CT-WRONG-TYPE (a set
*> that was open stays open); CT-PACKS-NOT-OK (CT-PACKS-STATUS holds the check's answer); CT-BAD-DATA (a
*> registry or tag file failed, with ERROR lines on standard error). An open set is closed first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKS               BINARY-LONG.
 01 WS-REASON              PIC X(128).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIR L-STATUS.
     IF L-TYPE < CT-TYPE-STANDARD OR L-TYPE > CT-TYPE-DEBUG
         MOVE CT-WRONG-TYPE TO L-STATUS
         GOBACK
     END-IF
     CALL "CONTENT-CLOSE"
     MOVE L-TYPE TO CT-SET-TYPE
     MOVE L-DIR(1:1024) TO CT-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CT-GENERATED-DIR TRAILING)) TO CT-GENERATED-LENGTH
     IF CT-GENERATED-DIR = SPACES
         MOVE 0 TO CT-GENERATED-LENGTH
     END-IF
     MOVE CT-PACKS-OK TO CT-PACKS-STATUS
     IF L-TYPE NOT = CT-TYPE-COBOLCRAFT
         CALL "CONTENT-PACKS-CHECK" USING L-DIR WS-PACKS WS-REASON
         MOVE WS-PACKS TO CT-PACKS-STATUS
         IF WS-PACKS NOT = CT-PACKS-OK
             MOVE CT-PACKS-NOT-OK TO L-STATUS
             GOBACK
         END-IF
     END-IF
*>   The counts and the open flag come first: the tag builder looks elements up through the set.
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     IF L-TYPE = CT-TYPE-COBOLCRAFT
         CALL "BUILTIN-BLOCK-TAGS"
         CALL "BUILTIN-ITEM-TAGS"
     ELSE
         CALL "REGISTRY-LOAD-ALL" USING L-DIR WS-STATUS
         IF WS-STATUS = CT-OK
             CALL "TAGS-LOAD-ALL" USING L-DIR WS-STATUS
         END-IF
         IF WS-STATUS NOT = CT-OK
             CALL "CONTENT-CLOSE"
             MOVE CT-BAD-DATA TO L-STATUS
             GOBACK
         END-IF
     END-IF
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM CONTENT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-CLOSE.
*> No parameters: frees the registries and tags of the set and clears CT-SET. Safe with no set open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 PROCEDURE DIVISION.
     CALL "REGISTRY-FREE"
     CALL "TAGS-FREE"
     MOVE 0 TO CT-OPEN CT-SET-TYPE CT-PACKS-STATUS CT-GENERATED-LENGTH CT-BLOCK-COUNT CT-STATE-COUNT
         CT-ITEM-COUNT CT-ENTITY-COUNT
     MOVE SPACES TO CT-GENERATED-DIR
     GOBACK.
 END PROGRAM CONTENT-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-REGISTRY-NAME.
*> USING index (BINARY-LONG, 1 to 57), registry path out (PIC X(48)): the registries whose tag files are read:
*> the 51 world registries, then the six static registries that have tags in the data (block, item,
*> entity_type, fluid, game_event, point_of_interest_type).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATIC.
    05 FILLER              PIC X(48) VALUE "block".
    05 FILLER              PIC X(48) VALUE "item".
    05 FILLER              PIC X(48) VALUE "entity_type".
    05 FILLER              PIC X(48) VALUE "fluid".
    05 FILLER              PIC X(48) VALUE "game_event".
    05 FILLER              PIC X(48) VALUE "point_of_interest_type".
 01 WS-STATIC-TABLE REDEFINES WS-STATIC.
    05 WS-STATIC-NAME      PIC X(48) OCCURS 6 TIMES.
 01 WS-FLAG                PIC X.
 01 WS-STATIC-INDEX        BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(48).
 PROCEDURE DIVISION USING L-INDEX L-NAME.
     IF L-INDEX <= 51
         CALL "REGISTRY-NAME-AT" USING L-INDEX L-NAME WS-FLAG
     ELSE
         COMPUTE WS-STATIC-INDEX = L-INDEX - 51
         MOVE WS-STATIC-NAME(WS-STATIC-INDEX) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM TAGS-REGISTRY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TAGS-LOAD-ALL.
*> USING generated directory (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): reads the tag files of
*> <dir>/vanilla-data/data/<namespace>/tags/<registry path>/ for the 51 world registries and the six static
*> registries that have tags in the data (block, item, entity_type, fluid, game_event, point_of_interest_type),
*> then resolves and binds them registry by registry (tags.cob). Bad tag files are logged and skipped (23 6.3);
*> a freeze error or a bad file name fails the load.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTLOAD.
 01 WS-DIR-Z               PIC X(1101).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-BASE                PIC X(1101).
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-BUILD               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "FILE-PATH-Z" USING L-DIR WS-DIR-Z WS-DIR-LENGTH WS-PATH-STATUS
     MOVE LOW-VALUES TO WS-BASE
     STRING WS-DIR-Z(1:WS-DIR-LENGTH) "/vanilla-data/data" DELIMITED BY SIZE INTO WS-BASE
     CALL "TAGS-BEGIN"
     MOVE 0 TO RS-ERRORS
     MOVE 1 TO RS-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 57
         CALL "TAGS-REGISTRY-NAME" USING WS-I WS-NAME
         CALL "REGISTRY-LOAD-ONE" USING WS-BASE WS-NAME WS-I
     END-PERFORM
     MOVE 0 TO RS-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 57
         CALL "TAGS-REGISTRY-NAME" USING WS-I WS-NAME
         CALL "TAGS-BUILD" USING WS-NAME WS-BUILD
         IF WS-BUILD NOT = CT-OK
             ADD 1 TO RS-ERRORS
         END-IF
     END-PERFORM
     IF RS-ERRORS > 0
         MOVE CT-BAD-DATA TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     GOBACK.

 END PROGRAM TAGS-LOAD-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-SET-COUNTS.
*> No parameters: sets the counts of CT-SET (blocks, block states, items, entity types) from the rows of the set
*> type in CT-SET-TYPE: the generated tables for the standard and debug types, the built-in layer for cobolcraft.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-ID
     CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS CT-BLOCK-COUNT
     COMPUTE WS-ID = CT-BLOCK-COUNT - 1
     CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
     COMPUTE CT-STATE-COUNT = FUNCTION NUMVAL(WS-R-FIRST) + FUNCTION NUMVAL(WS-R-COUNT)
     MOVE 0 TO WS-ID
     CALL "ITEM-ROW-AT" USING WS-ID WS-ITEM-ROW WS-STATUS CT-ITEM-COUNT
     CALL "ENTITY-ROW-AT" USING WS-ID WS-ENTITY-ROW WS-STATUS CT-ENTITY-COUNT
     GOBACK.
 END PROGRAM CONTENT-SET-COUNTS.
