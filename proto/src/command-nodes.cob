*> The full command node codec (docs/protocol/05a 0x10 CommandNode and its argument parser
*> registry; 15 §3.4), on the record PB-COMMAND-NODE-X of contract/copy/PROTO.cpy. Every one of the
*> 62 parsers has its property bytes: NumberRange (Byte flags, then the minimum and the maximum the
*> flags announce) for float, double, integer and long, the string kind for string, a flags Byte for
*> entity and score_holder, an Int minimum for time and an Identifier registry key for the five
*> resource kinds; the others have none. The node count and root index of the packet are the
*> caller's. A writer that cannot encode a value appends nothing and sets PB-ERROR; a reader that
*> fails sets PB-ERROR, leaves PB-POS where it was and yields an INITIALIZEd node.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-COMMAND-NODE-X.
*> USING PB-BUFFER, PB-COMMAND-NODE-X: Byte flags; Prefixed Array of VarInt children; VarInt redirect
*> when flag 0x08 is set; for literal (type 1) and argument (type 2) nodes the String name; for
*> argument nodes the VarInt parser id, its properties and, when flag 0x10 is set, the Identifier
*> suggestions type. Types 0 and 3 have no stub. Flags outside 0 to 255, a child count outside 0 to
*> PB-NODE-MAX-CHILDREN-X, a name longer than PB-CX-NAME, a parser outside 0 to 61, a string kind
*> outside 0 to 2, range flags outside 0 to 3, a property byte outside 0 to 255, a registry key or
*> suggestions type that is over-long or not an Identifier sets PB-ERROR and appends nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALID               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-REDIRECT            BINARY-LONG.
 01 WS-SUGGEST             BINARY-LONG.
 01 WS-HAS-MIN             BINARY-LONG.
 01 WS-HAS-MAX             BINARY-LONG.
 01 WS-IDENTIFIER          BINARY-LONG.
 01 WS-MAX-NAME            BINARY-LONG VALUE 32767.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-COMMAND-NODE-X.
     MOVE 1 TO WS-VALID
     COMPUTE WS-TYPE = FUNCTION MOD(PB-CX-FLAGS, 4)
     DIVIDE PB-CX-FLAGS BY 8 GIVING WS-BITS
     COMPUTE WS-REDIRECT = FUNCTION MOD(WS-BITS, 2)
     DIVIDE PB-CX-FLAGS BY 16 GIVING WS-BITS
     COMPUTE WS-SUGGEST = FUNCTION MOD(WS-BITS, 2)
     DIVIDE PB-CX-RANGE-FLAGS BY 2 GIVING WS-HAS-MAX
     COMPUTE WS-HAS-MIN = FUNCTION MOD(PB-CX-RANGE-FLAGS, 2)
     IF PB-CX-FLAGS < 0 OR PB-CX-FLAGS > 255
             OR PB-CX-CHILD-COUNT < 0 OR PB-CX-CHILD-COUNT > PB-NODE-MAX-CHILDREN-X
         MOVE 0 TO WS-VALID
     END-IF
     IF (WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT)
             AND (PB-CX-NAME-LENGTH < 0 OR PB-CX-NAME-LENGTH > LENGTH OF PB-CX-NAME)
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-TYPE = PB-NODE-ARGUMENT
         EVALUATE TRUE
             WHEN PB-CX-PARSER < PB-PX-BOOL OR PB-CX-PARSER > PB-PX-UUID
                 MOVE 0 TO WS-VALID
             WHEN PB-CX-PARSER >= PB-PX-FLOAT AND PB-CX-PARSER <= PB-PX-LONG
                 IF PB-CX-RANGE-FLAGS < 0 OR PB-CX-RANGE-FLAGS > 3
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN PB-CX-PARSER = PB-PX-STRING
                 IF PB-CX-STRING-KIND < PB-STRING-SINGLE-WORD
                         OR PB-CX-STRING-KIND > PB-STRING-GREEDY
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN PB-CX-PARSER = PB-PX-ENTITY OR PB-CX-PARSER = PB-PX-SCORE-HOLDER
                 IF PB-CX-FLAGS-BYTE < 0 OR PB-CX-FLAGS-BYTE > 255
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN PB-CX-PARSER >= PB-PX-RESOURCE-OR-TAG AND PB-CX-PARSER <= PB-PX-RESOURCE-SELECTOR
                 IF PB-CX-REGISTRY-LENGTH < 0 OR PB-CX-REGISTRY-LENGTH > LENGTH OF PB-CX-REGISTRY
                     MOVE 0 TO WS-VALID
                 ELSE
                     CALL "PB-VALID-IDENTIFIER" USING PB-CX-REGISTRY PB-CX-REGISTRY-LENGTH
                         WS-IDENTIFIER
                     IF WS-IDENTIFIER = 0
                         MOVE 0 TO WS-VALID
                     END-IF
                 END-IF
         END-EVALUATE
         IF WS-SUGGEST = 1
             IF PB-CX-SUGGEST-LENGTH < 0 OR PB-CX-SUGGEST-LENGTH > LENGTH OF PB-CX-SUGGEST
                 MOVE 0 TO WS-VALID
             ELSE
                 CALL "PB-VALID-IDENTIFIER" USING PB-CX-SUGGEST PB-CX-SUGGEST-LENGTH
                     WS-IDENTIFIER
                 IF WS-IDENTIFIER = 0
                     MOVE 0 TO WS-VALID
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-VALID = 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-CX-FLAGS
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CX-CHILD-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-CX-CHILD-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CX-CHILD(WS-I)
     END-PERFORM
     IF WS-REDIRECT = 1
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CX-REDIRECT
     END-IF
     IF WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT
         CALL "PB-PUT-STRING" USING PB-BUFFER PB-CX-NAME PB-CX-NAME-LENGTH WS-MAX-NAME
     END-IF
     IF WS-TYPE = PB-NODE-ARGUMENT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CX-PARSER
         EVALUATE TRUE
             WHEN PB-CX-PARSER >= PB-PX-FLOAT AND PB-CX-PARSER <= PB-PX-LONG
                 CALL "PB-PUT-BYTE" USING PB-BUFFER PB-CX-RANGE-FLAGS
                 EVALUATE PB-CX-PARSER
                     WHEN PB-PX-FLOAT
                         IF WS-HAS-MIN = 1
                             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-CX-MIN-FLOAT
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-CX-MAX-FLOAT
                         END-IF
                     WHEN PB-PX-DOUBLE
                         IF WS-HAS-MIN = 1
                             CALL "PB-PUT-DOUBLE" USING PB-BUFFER PB-CX-MIN-DOUBLE
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-PUT-DOUBLE" USING PB-BUFFER PB-CX-MAX-DOUBLE
                         END-IF
                     WHEN PB-PX-INTEGER
                         IF WS-HAS-MIN = 1
                             CALL "PB-PUT-INT" USING PB-BUFFER PB-CX-MIN-INT
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-PUT-INT" USING PB-BUFFER PB-CX-MAX-INT
                         END-IF
                     WHEN OTHER
                         IF WS-HAS-MIN = 1
                             CALL "PB-PUT-LONG" USING PB-BUFFER PB-CX-MIN-LONG
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-PUT-LONG" USING PB-BUFFER PB-CX-MAX-LONG
                         END-IF
                 END-EVALUATE
             WHEN PB-CX-PARSER = PB-PX-STRING
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CX-STRING-KIND
             WHEN PB-CX-PARSER = PB-PX-ENTITY OR PB-CX-PARSER = PB-PX-SCORE-HOLDER
                 CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-CX-FLAGS-BYTE
             WHEN PB-CX-PARSER = PB-PX-TIME
                 CALL "PB-PUT-INT" USING PB-BUFFER PB-CX-TIME-MIN
             WHEN PB-CX-PARSER >= PB-PX-RESOURCE-OR-TAG AND PB-CX-PARSER <= PB-PX-RESOURCE-SELECTOR
                 CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER PB-CX-REGISTRY PB-CX-REGISTRY-LENGTH
         END-EVALUATE
         IF WS-SUGGEST = 1
             CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER PB-CX-SUGGEST PB-CX-SUGGEST-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-COMMAND-NODE-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-COMMAND-NODE-X.
*> USING PB-BUFFER, PB-COMMAND-NODE-X out: one CommandNode (layout as PB-PUT-COMMAND-NODE-X); the
*> fields the node does not use are 0 (texts spaces), an absent range minimum or maximum is 0. A
*> child count outside 0 to PB-NODE-MAX-CHILDREN-X, a name longer than PB-CX-NAME, a parser outside 0
*> to 61, a string kind outside 0 to 2, range flags outside 0 to 3, a registry key or suggestions
*> type that is over-long or not an Identifier, or a short read sets PB-ERROR, leaves PB-POS where it
*> was and yields an INITIALIZEd node.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-HAS-MIN             BINARY-LONG.
 01 WS-HAS-MAX             BINARY-LONG.
 01 WS-MAX-NAME            BINARY-LONG VALUE 32767.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-COMMAND-NODE-X.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-COMMAND-NODE-X
     CALL "PB-GET-UBYTE" USING PB-BUFFER PB-CX-FLAGS
     COMPUTE WS-TYPE = FUNCTION MOD(PB-CX-FLAGS, 4)
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-CX-CHILD-COUNT
     IF PB-CX-CHILD-COUNT < 0 OR PB-CX-CHILD-COUNT > PB-NODE-MAX-CHILDREN-X
         MOVE 1 TO PB-ERROR
         MOVE 0 TO PB-CX-CHILD-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-CX-CHILD-COUNT
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CX-CHILD(WS-I)
     END-PERFORM
     DIVIDE PB-CX-FLAGS BY 8 GIVING WS-BITS
     IF FUNCTION MOD(WS-BITS, 2) = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CX-REDIRECT
     END-IF
     IF WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT
         MOVE LENGTH OF PB-CX-NAME TO WS-CAPACITY
         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-NAME PB-CX-NAME WS-CAPACITY
             PB-CX-NAME-LENGTH
     END-IF
     IF WS-TYPE = PB-NODE-ARGUMENT
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CX-PARSER
         EVALUATE TRUE
             WHEN PB-CX-PARSER < PB-PX-BOOL OR PB-CX-PARSER > PB-PX-UUID
                 MOVE 1 TO PB-ERROR
             WHEN PB-CX-PARSER >= PB-PX-FLOAT AND PB-CX-PARSER <= PB-PX-LONG
                 CALL "PB-GET-UBYTE" USING PB-BUFFER PB-CX-RANGE-FLAGS
                 IF PB-CX-RANGE-FLAGS > 3
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO PB-CX-RANGE-FLAGS
                 END-IF
                 DIVIDE PB-CX-RANGE-FLAGS BY 2 GIVING WS-HAS-MAX
                 COMPUTE WS-HAS-MIN = FUNCTION MOD(PB-CX-RANGE-FLAGS, 2)
                 EVALUATE PB-CX-PARSER
                     WHEN PB-PX-FLOAT
                         IF WS-HAS-MIN = 1
                             CALL "PB-GET-FLOAT" USING PB-BUFFER PB-CX-MIN-FLOAT
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-GET-FLOAT" USING PB-BUFFER PB-CX-MAX-FLOAT
                         END-IF
                     WHEN PB-PX-DOUBLE
                         IF WS-HAS-MIN = 1
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER PB-CX-MIN-DOUBLE
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-GET-DOUBLE" USING PB-BUFFER PB-CX-MAX-DOUBLE
                         END-IF
                     WHEN PB-PX-INTEGER
                         IF WS-HAS-MIN = 1
                             CALL "PB-GET-INT" USING PB-BUFFER PB-CX-MIN-INT
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-GET-INT" USING PB-BUFFER PB-CX-MAX-INT
                         END-IF
                     WHEN OTHER
                         IF WS-HAS-MIN = 1
                             CALL "PB-GET-LONG" USING PB-BUFFER PB-CX-MIN-LONG
                         END-IF
                         IF WS-HAS-MAX = 1
                             CALL "PB-GET-LONG" USING PB-BUFFER PB-CX-MAX-LONG
                         END-IF
                 END-EVALUATE
             WHEN PB-CX-PARSER = PB-PX-STRING
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-CX-STRING-KIND
                 IF PB-CX-STRING-KIND < PB-STRING-SINGLE-WORD
                         OR PB-CX-STRING-KIND > PB-STRING-GREEDY
                     MOVE 1 TO PB-ERROR
                 END-IF
             WHEN PB-CX-PARSER = PB-PX-ENTITY OR PB-CX-PARSER = PB-PX-SCORE-HOLDER
                 CALL "PB-GET-UBYTE" USING PB-BUFFER PB-CX-FLAGS-BYTE
             WHEN PB-CX-PARSER = PB-PX-TIME
                 CALL "PB-GET-INT" USING PB-BUFFER PB-CX-TIME-MIN
             WHEN PB-CX-PARSER >= PB-PX-RESOURCE-OR-TAG AND PB-CX-PARSER <= PB-PX-RESOURCE-SELECTOR
                 MOVE LENGTH OF PB-CX-REGISTRY TO WS-CAPACITY
                 CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PB-CX-REGISTRY WS-CAPACITY
                     PB-CX-REGISTRY-LENGTH
         END-EVALUATE
         DIVIDE PB-CX-FLAGS BY 16 GIVING WS-BITS
         IF FUNCTION MOD(WS-BITS, 2) = 1
             MOVE LENGTH OF PB-CX-SUGGEST TO WS-CAPACITY
             CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PB-CX-SUGGEST WS-CAPACITY
                 PB-CX-SUGGEST-LENGTH
         END-IF
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-COMMAND-NODE-X
     END-IF
     GOBACK.
 END PROGRAM PB-GET-COMMAND-NODE-X.
