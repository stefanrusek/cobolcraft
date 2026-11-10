*> Block and state lookups of the content library (content-api section 2; 24 part 1 section 2 and 3). A block
*> row is the CT-BLOCK-ROW view of a generated row (content/copy/gen/blocks.cpy) or of a row of the built-in
*> layer (builtin-blocks.cob): the set type chooses which rows exist (BLOCK-ROW-AT), nothing else. State rows
*> are never stored: a state id belongs to the block whose first state id is the greatest not above it, its
*> index inside the block is the difference, and the property values come from the block's property list
*> (sorted by name, the first property varying slowest). An unknown key or id is a defined outcome
*> (CT-NOT-FOUND, row 0, id 0), never a crash. Without an open set every lookup answers CT-NOT-OPEN.
*> Every generated multi-state block has a default state id and a property list with its values (up to the
*> 288 characters of the contract copybook; content/copy/gen/gaps.txt names any block that has none, and is
*> empty): CONTENT-STATE-PROPS answers CT-NOT-FOUND only for an unknown state.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-BLOCK-BY-KEY.
*> USING key (PIC X(112), space padded; "minecraft:" is optional in the standard set), block id out
*> (BINARY-LONG), row out (PIC X(819), CT-BLOCK-ROW), status out (CT-OK, CT-NOT-FOUND with id 0 and the
*> row of block 0, CT-NOT-OPEN with the row left as it was).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(35).
    05 FILLER              PIC X(780).
 01 WS-ROW-KEY             PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(819).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID L-ROW L-STATUS.
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         MOVE 0 TO L-ID
         GOBACK
     END-IF
     MOVE 0 TO L-ID
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "BLOCK-ROW-AT" USING L-ID L-ROW WS-STATUS WS-COUNT
     MOVE L-KEY TO WS-KEY
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:54) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     IF WS-KEY = SPACES
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR L-STATUS = CT-OK
         CALL "BLOCK-ROW-AT" USING WS-I WS-ROW WS-STATUS WS-COUNT
         MOVE WS-R-KEY TO WS-ROW-KEY
         IF WS-ROW-KEY = WS-KEY
             MOVE WS-I TO L-ID
             MOVE WS-ROW TO L-ROW
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONTENT-BLOCK-BY-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-BLOCK-OF-STATE.
*> USING state id (BINARY-LONG), block id out, state index out (0 = the block's first state), row out
*> (PIC X(819)), status out (CT-OK; CT-NOT-FOUND with id 0, index 0 and the row of block 0; CT-NOT-OPEN).
*> A binary search over the first state ids, which ascend with the block id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 FILLER              PIC X(451).
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-MID                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ROW                  PIC X(819).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ID L-INDEX L-ROW L-STATUS.
     MOVE 0 TO L-ID L-INDEX
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-NOT-FOUND TO L-STATUS
     CALL "BLOCK-ROW-AT" USING L-ID L-ROW WS-STATUS WS-COUNT
     MOVE 0 TO WS-LOW
     COMPUTE WS-HIGH = WS-COUNT - 1
     PERFORM UNTIL WS-LOW > WS-HIGH OR L-STATUS = CT-OK
         COMPUTE WS-MID = (WS-LOW + WS-HIGH) / 2
         CALL "BLOCK-ROW-AT" USING WS-MID WS-ROW WS-STATUS WS-COUNT
         COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-R-FIRST)
         COMPUTE WS-STATES = FUNCTION NUMVAL(WS-R-COUNT)
         EVALUATE TRUE
             WHEN L-STATE < WS-FIRST
                 COMPUTE WS-HIGH = WS-MID - 1
             WHEN L-STATE >= WS-FIRST + WS-STATES
                 COMPUTE WS-LOW = WS-MID + 1
             WHEN OTHER
                 MOVE WS-MID TO L-ID
                 COMPUTE L-INDEX = L-STATE - WS-FIRST
                 MOVE WS-ROW TO L-ROW
                 MOVE CT-OK TO L-STATUS
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM CONTENT-BLOCK-OF-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-STATE-PROPS.
*> USING state id (BINARY-LONG), CT-PROPS out (CTPROPS.cpy: count, then name and value text of each property in
*> the block's list order), status out (CT-OK, count 0 for a state of a block with no properties;
*> CT-NOT-FOUND, count 0, for an unknown state; CT-NOT-OPEN; every multi-state row lists its properties).
*> The property list of a row is "name[a/b/c]", "name[lo..hi]" or "name[bool]" items separated by spaces, sorted by name, with every value
*> named (the generator checks that the value counts multiply to the state count); the index of the state
*> is split from the last property (fastest, stride 1) to the first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(71).
    05 WS-R-PROPS          PIC X(288).
    05 WS-R-COUNT          PIC X(4).
    05 FILLER              PIC X(456).
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(300).
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-LOW-TEXT            PIC X(12).
 01 WS-HIGH-TEXT           PIC X(12).
 01 WS-LOW-VALUE           BINARY-LONG.
 01 WS-HIGH-VALUE          BINARY-LONG.
 01 WS-LIST-POINTER        BINARY-LONG.
 01 WS-ITEM                PIC X(40).
 01 WS-SLASHES             BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-NUMBER              PIC Z(8)9.
 01 WS-PROPERTIES.
    05 WS-PROPERTY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-SPEC        PIC X(280).
       10 WS-P-KIND        PIC X.
       10 WS-P-COUNT       BINARY-LONG.
       10 WS-P-LOW         BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-PROPS.
    05 L-COUNT             BINARY-LONG.
    05 L-ENTRY OCCURS 16 TIMES.
       10 L-NAME           PIC X(24).
       10 L-VALUE          PIC X(32).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PROPS L-STATUS.
     MOVE 0 TO L-COUNT
     CALL "CONTENT-BLOCK-OF-STATE" USING L-STATE WS-ID WS-INDEX WS-ROW L-STATUS
     IF L-STATUS NOT = CT-OK
         GOBACK
     END-IF
     IF WS-R-PROPS = SPACES
         GOBACK
     END-IF
*>   Split the list into properties and classify each value spec.
     MOVE 0 TO WS-N
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 288
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-R-PROPS DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES
             ADD 1 TO WS-N
             MOVE 0 TO WS-OPEN
             INSPECT WS-TOKEN TALLYING WS-OPEN FOR CHARACTERS BEFORE INITIAL "["
             MOVE 0 TO WS-CLOSE
             INSPECT WS-TOKEN TALLYING WS-CLOSE FOR CHARACTERS BEFORE INITIAL "]"
             COMPUTE WS-LENGTH = WS-CLOSE - WS-OPEN - 1
             MOVE SPACES TO WS-P-NAME(WS-N) WS-P-SPEC(WS-N)
             MOVE WS-TOKEN(1:WS-OPEN) TO WS-P-NAME(WS-N)
             MOVE WS-TOKEN(WS-OPEN + 2:WS-LENGTH) TO WS-P-SPEC(WS-N)
             MOVE 0 TO WS-SLASHES WS-DOTS
             INSPECT WS-P-SPEC(WS-N) TALLYING WS-SLASHES FOR ALL "/"
             INSPECT WS-P-SPEC(WS-N) TALLYING WS-DOTS FOR ALL ".."
             EVALUATE TRUE
                 WHEN WS-SLASHES > 0
                     MOVE "L" TO WS-P-KIND(WS-N)
                     COMPUTE WS-P-COUNT(WS-N) = WS-SLASHES + 1
                 WHEN WS-DOTS > 0
                     MOVE "R" TO WS-P-KIND(WS-N)
                     MOVE SPACES TO WS-LOW-TEXT WS-HIGH-TEXT
                     UNSTRING WS-P-SPEC(WS-N) DELIMITED BY ".." INTO WS-LOW-TEXT WS-HIGH-TEXT
                     COMPUTE WS-LOW-VALUE = FUNCTION NUMVAL(WS-LOW-TEXT)
                     COMPUTE WS-HIGH-VALUE = FUNCTION NUMVAL(WS-HIGH-TEXT)
                     MOVE WS-LOW-VALUE TO WS-P-LOW(WS-N)
                     COMPUTE WS-P-COUNT(WS-N) = WS-HIGH-VALUE - WS-LOW-VALUE + 1
                 WHEN WS-P-SPEC(WS-N) = "bool"
                     MOVE "B" TO WS-P-KIND(WS-N)
                     MOVE 2 TO WS-P-COUNT(WS-N)
             END-EVALUATE
         END-IF
     END-PERFORM
*>   Decode the index from the last property to the first.
     MOVE WS-INDEX TO WS-REMAINDER
     PERFORM VARYING WS-I FROM WS-N BY -1 UNTIL WS-I < 1
         DIVIDE WS-REMAINDER BY WS-P-COUNT(WS-I) GIVING WS-QUOTIENT REMAINDER WS-PICK
         MOVE WS-QUOTIENT TO WS-REMAINDER
         MOVE WS-P-NAME(WS-I) TO L-NAME(WS-I)
         MOVE SPACES TO L-VALUE(WS-I)
         EVALUATE WS-P-KIND(WS-I)
             WHEN "B"
                 IF WS-PICK = 0
                     MOVE "true" TO L-VALUE(WS-I)
                 ELSE
                     MOVE "false" TO L-VALUE(WS-I)
                 END-IF
             WHEN "R"
                 COMPUTE WS-LOW-VALUE = WS-P-LOW(WS-I) + WS-PICK
                 MOVE WS-LOW-VALUE TO WS-NUMBER
                 MOVE FUNCTION TRIM(WS-NUMBER) TO L-VALUE(WS-I)
             WHEN OTHER
                 MOVE 1 TO WS-LIST-POINTER
                 PERFORM VARYING WS-LENGTH FROM 0 BY 1 UNTIL WS-LENGTH > WS-PICK
                     MOVE SPACES TO WS-ITEM
                     UNSTRING WS-P-SPEC(WS-I) DELIMITED BY "/" OR SPACE INTO WS-ITEM
                         WITH POINTER WS-LIST-POINTER
                 END-PERFORM
                 MOVE WS-ITEM TO L-VALUE(WS-I)
         END-EVALUATE
     END-PERFORM
     MOVE WS-N TO L-COUNT
     GOBACK.


 END PROGRAM CONTENT-STATE-PROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-STATE-DEFAULT.
*> USING block id (BINARY-LONG), default state id out (BINARY-LONG), status out (CT-OK; CT-NOT-FOUND for an
*> unknown block with state 0; CT-NOT-OPEN). Every generated row has a default state id; a row without one
*> (a one-state row of the built-in layer) has its first state as its default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(359).
    05 WS-R-COUNT          PIC X(4).
    05 WS-R-FIRST          PIC X(5).
    05 WS-R-DEFAULT        PIC X(5).
    05 FILLER              PIC X(446).
 01 WS-ROW-ID              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-STATE L-STATUS.
     MOVE 0 TO L-STATE
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE L-ID TO WS-ROW-ID
     CALL "BLOCK-ROW-AT" USING WS-ROW-ID WS-ROW WS-STATUS WS-COUNT
     IF WS-STATUS NOT = CT-OK
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE L-STATE = FUNCTION NUMVAL(WS-R-FIRST)
     MOVE CT-OK TO L-STATUS
     IF WS-R-DEFAULT NOT = SPACES
         COMPUTE L-STATE = FUNCTION NUMVAL(WS-R-DEFAULT)
     END-IF
     GOBACK.
 END PROGRAM CONTENT-STATE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROW-AT.
*> USING block id (BINARY-LONG), row out (PIC X(819)), status out (CT-OK, or CT-NOT-FOUND for an id outside
*> the set, the row then left as it was), count out (BINARY-LONG: the rows of the set). The set type of
*> CT-SET chooses the rows: the generated standard table, or the built-in layer of the cobolcraft type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(819).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     IF CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         CALL "BUILTIN-BLOCK-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     ELSE
         CALL "BLOCK-STD-ROW" USING L-ID L-ROW L-STATUS L-COUNT
     END-IF
     GOBACK.
 END PROGRAM BLOCK-ROW-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-STD-ROW.
*> Same parameters as BLOCK-ROW-AT: row N of the generated block table (content/copy/gen/blocks.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY BLOCKS.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(819).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE GEN-BLOCK-ROWS TO L-COUNT
     IF L-ID < 0 OR L-ID >= GEN-BLOCK-ROWS
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-START = L-ID * GEN-BLOCK-ROW-WIDTH + 1
     MOVE GEN-BLOCK-DATA(WS-START:GEN-BLOCK-ROW-WIDTH) TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM BLOCK-STD-ROW.
