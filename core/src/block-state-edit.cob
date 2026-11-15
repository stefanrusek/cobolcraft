*> Reading and writing one property of a block state by name, and copying properties from one state to another (what the structure processors do:
*> docs/protocol/36-structures-2 sections 5.4, 9.8, 9.9: placeLiquid sets waterlogged, blackstone_replace copies facing, half and type, block_age
*> copies every property the target block has). Built on the property layout of block-rotate.cob.
*>
*> Entry points:
*>   BLOCK-STATE-PROP USING mode, state, name (PIC X(24)), text (PIC X(32)), result (BINARY-LONG)
*>     mode 1: the value text of the property: result 1 and text, or result 0 and spaces when the block has no such property
*>     mode 2: the state with the property set to text: result is that state id; the state itself when the block has no such property or text is not one of its values
*>   BLOCK-STATE-COPY USING source state, target state, names (PIC X(80): property names separated by commas, spaces for every property), result (BINARY-LONG)
*>     the target with each property of the source (of the listed ones) that the target's block has set to the source's value (Block.withPropertiesOf)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-STATE-PROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-LAYOUT-BLOCK        BINARY-LONG VALUE -1.
 01 WS-LAYOUT.
    05 LY-COUNT            BINARY-LONG.
    05 LY-FACING           BINARY-LONG.
    05 LY-AXIS             BINARY-LONG.
    05 LY-ROTATION         BINARY-LONG.
    05 LY-SHAPE            BINARY-LONG.
    05 LY-HINGE            BINARY-LONG.
    05 LY-ORIENTATION      BINARY-LONG.
    05 LY-SIDE             BINARY-LONG OCCURS 4 TIMES.
    05 LY-PROP OCCURS 16 TIMES.
       10 LY-NAME          PIC X(24).
       10 LY-SPEC          PIC X(280).
       10 LY-KIND          PIC X.
       10 LY-N             BINARY-LONG.
       10 LY-LOW           BINARY-LONG.
       10 LY-STRIDE        BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-TEXT                 PIC X(32).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-STATE L-NAME L-TEXT L-RESULT.
     IF L-MODE = 1
         MOVE 0 TO L-RESULT
         MOVE SPACES TO L-TEXT
     ELSE
         MOVE L-STATE TO L-RESULT
     END-IF
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     IF CB-EPOCH NOT = WS-EPOCH
         MOVE CB-EPOCH TO WS-EPOCH
         MOVE -1 TO WS-LAYOUT-BLOCK
     END-IF
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     IF WS-LAYOUT-BLOCK NOT = WS-BLOCK
         CALL "BLOCK-ROT-LAYOUT" USING WS-BLOCK WS-LAYOUT
         MOVE WS-BLOCK TO WS-LAYOUT-BLOCK
     END-IF
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LY-COUNT
         IF LY-NAME(WS-I) = L-NAME
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     IF WS-SLOT = 0
         GOBACK
     END-IF
     COMPUTE WS-INDEX = L-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
     DIVIDE WS-INDEX BY LY-STRIDE(WS-SLOT) GIVING WS-QUOTIENT
     COMPUTE WS-DIGIT = FUNCTION MOD(WS-QUOTIENT, LY-N(WS-SLOT))
     IF L-MODE = 1
         MOVE 1 TO WS-MODE
         CALL "BLOCK-ROT-VALUE" USING WS-MODE LY-KIND(WS-SLOT) LY-SPEC(WS-SLOT) LY-LOW(WS-SLOT) WS-DIGIT L-TEXT
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     MOVE 2 TO WS-MODE
     CALL "BLOCK-ROT-VALUE" USING WS-MODE LY-KIND(WS-SLOT) LY-SPEC(WS-SLOT) LY-LOW(WS-SLOT) WS-NEW L-TEXT
     IF WS-NEW >= 0 AND WS-NEW < LY-N(WS-SLOT)
         COMPUTE L-RESULT = L-STATE + (WS-NEW - WS-DIGIT) * LY-STRIDE(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM BLOCK-STATE-PROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-STATE-COPY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PROPS               PIC X(160).
 01 WS-LIST                PIC X(84).
 01 WS-POINTER             BINARY-LONG.
 01 WS-PAIR                PIC X(60).
 01 WS-PAIR-LENGTH         BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(32).
 01 WS-NEEDLE              PIC X(26).
 01 WS-TALLY               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-NAMES                PIC X(80).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-TARGET L-NAMES L-RESULT.
     MOVE L-TARGET TO L-RESULT
     CALL "BLOCKS-STATE-PROPS" USING L-SOURCE WS-PROPS
     MOVE SPACES TO WS-LIST
     STRING "," FUNCTION TRIM(L-NAMES) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 160 OR WS-PROPS(WS-POINTER:1) = SPACE
         MOVE SPACES TO WS-PAIR
         MOVE 0 TO WS-PAIR-LENGTH
         UNSTRING WS-PROPS DELIMITED BY "," OR SPACE INTO WS-PAIR COUNT IN WS-PAIR-LENGTH WITH POINTER WS-POINTER
         MOVE 0 TO WS-NAME-LENGTH
         INSPECT WS-PAIR TALLYING WS-NAME-LENGTH FOR CHARACTERS BEFORE INITIAL "="
         MOVE SPACES TO WS-NAME WS-VALUE WS-NEEDLE
         MOVE WS-PAIR(1:WS-NAME-LENGTH) TO WS-NAME
         COMPUTE WS-LAST = WS-PAIR-LENGTH - WS-NAME-LENGTH - 1
         MOVE WS-PAIR(WS-NAME-LENGTH + 2:WS-LAST) TO WS-VALUE
         STRING "," FUNCTION TRIM(WS-NAME) "," DELIMITED BY SIZE INTO WS-NEEDLE
         MOVE 0 TO WS-TALLY
         INSPECT WS-LIST TALLYING WS-TALLY FOR ALL FUNCTION TRIM(WS-NEEDLE)
         IF L-NAMES = SPACES OR WS-TALLY > 0
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-RESULT WS-NAME WS-VALUE WS-STATE
             MOVE WS-STATE TO L-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-STATE-COPY.
