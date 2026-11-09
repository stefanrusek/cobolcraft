*> Implementation test of the full command node codec of proto/src/command-nodes.cob (05a 0x10
*> CommandNode with every parser of the registry table, PB-COMMAND-NODE-X of PROTO.cpy): every parser
*> kind with its property bytes, the redirect, restricted and suggestions-type fields, and the values
*> the writer cannot encode (flags, child count, name, parser, string kind, range flags, property
*> byte, registry key or suggestions type out of range), which append nothing and set PB-ERROR. A
*> failed read leaves PB-POS where it was and yields an all-zero node. Expected bytes are written
*> out by hand from the field tables of 05a, not taken from the encoder.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-NODES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-HEX                 PIC X(1024).
 01 WS-EXPECT              PIC X(1024).
 01 WS-NAME                PIC X(120).
 01 WS-EDIT                PIC -(9)9.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-K                  BINARY-LONG.
 01 WS-BYTE                PIC X.
 01 WS-PROPS               PIC X(80).
 01 WS-SAME                PIC X(40).
 01 WS-KEY                 PIC X(14) VALUE "minecraft:item".
 01 WS-KEY-HEX             PIC X(30) VALUE "0e6d696e6563726166743a6974656d".
 01 WS-ASK                 PIC X(20) VALUE "minecraft:ask_server".
 01 WS-ASK-HEX             PIC X(42) VALUE "146d696e6563726166743a61736b5f736572766572".
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
*>   ---- node types ----
     INITIALIZE PB-COMMAND-NODE-X
     MOVE PB-NODE-ROOT TO PB-CX-FLAGS
     MOVE 3 TO PB-CX-CHILD-COUNT
     MOVE 1 TO PB-CX-CHILD(1)
     MOVE 2 TO PB-CX-CHILD(2)
     MOVE 300 TO PB-CX-CHILD(3)
     MOVE "root with three children (300 is a two-byte VarInt)" TO WS-NAME
     MOVE "00 03 01 02 ac02" TO WS-EXPECT
     PERFORM PUT-AND-READ
     INITIALIZE PB-COMMAND-NODE-X
     COMPUTE PB-CX-FLAGS = PB-NODE-LITERAL + PB-NODE-EXECUTABLE + PB-NODE-HAS-REDIRECT
     MOVE 5 TO PB-CX-REDIRECT
     MOVE "tp" TO PB-CX-NAME
     MOVE 2 TO PB-CX-NAME-LENGTH
     MOVE "executable literal tp with redirect 5" TO WS-NAME
     MOVE "0d 00 05 02 7470" TO WS-EXPECT
     PERFORM PUT-AND-READ
     INITIALIZE PB-COMMAND-NODE-X
     COMPUTE PB-CX-FLAGS = PB-NODE-LITERAL + PB-NODE-RESTRICTED
     MOVE "op" TO PB-CX-NAME
     MOVE 2 TO PB-CX-NAME-LENGTH
     MOVE "restricted literal op" TO WS-NAME
     MOVE "21 00 02 6f70" TO WS-EXPECT
     PERFORM PUT-AND-READ
     INITIALIZE PB-COMMAND-NODE-X
     MOVE 3 TO PB-CX-FLAGS
     MOVE "type 3 has no stub" TO WS-NAME
     MOVE "03 00" TO WS-EXPECT
     PERFORM PUT-AND-READ
     INITIALIZE PB-COMMAND-NODE-X
     MOVE PB-NODE-ROOT TO PB-CX-FLAGS
     MOVE 256 TO PB-CX-CHILD-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE WS-I TO PB-CX-CHILD(WS-I)
     END-PERFORM
     MOVE "root with 256 children" TO WS-NAME
     MOVE SPACES TO WS-EXPECT
     PERFORM PUT-AND-READ-ANY
*>   ---- custom suggestions and the flags that go with them ----
     INITIALIZE PB-COMMAND-NODE-X
     COMPUTE PB-CX-FLAGS = PB-NODE-ARGUMENT + PB-NODE-HAS-SUGGEST + PB-NODE-RESTRICTED
     MOVE "foo" TO PB-CX-NAME
     MOVE 3 TO PB-CX-NAME-LENGTH
     MOVE PB-PX-ENTITY TO PB-CX-PARSER
     MOVE 1 TO PB-CX-FLAGS-BYTE
     MOVE WS-ASK TO PB-CX-SUGGEST
     MOVE 20 TO PB-CX-SUGGEST-LENGTH
     MOVE "restricted entity argument with ask_server suggestions" TO WS-NAME
     MOVE SPACES TO WS-EXPECT
     STRING "32 00 03 666f6f 06 01 " WS-ASK-HEX DELIMITED BY SIZE INTO WS-EXPECT
     PERFORM PUT-AND-READ
*>   A literal node writes no parser, whatever the parser field holds.
     INITIALIZE PB-COMMAND-NODE-X
     MOVE PB-NODE-LITERAL TO PB-CX-FLAGS
     MOVE "x" TO PB-CX-NAME
     MOVE 1 TO PB-CX-NAME-LENGTH
     MOVE 99 TO PB-CX-PARSER
     MOVE "literal x ignores an out-of-range parser field" TO WS-NAME
     MOVE "01 00 01 78" TO WS-EXPECT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     PERFORM CHECK-BYTES
*>   ---- every parser of the registry table ----
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 61
         INITIALIZE PB-COMMAND-NODE-X
         COMPUTE PB-CX-FLAGS = PB-NODE-ARGUMENT + PB-NODE-EXECUTABLE
         MOVE "a" TO PB-CX-NAME
         MOVE 1 TO PB-CX-NAME-LENGTH
         MOVE WS-ID TO PB-CX-PARSER
         MOVE SPACES TO WS-PROPS
         EVALUATE WS-ID
             WHEN 1
                 MOVE 3 TO PB-CX-RANGE-FLAGS
                 MOVE 0.5 TO PB-CX-MIN-FLOAT
                 MOVE 2.0 TO PB-CX-MAX-FLOAT
                 MOVE "03 3f000000 40000000" TO WS-PROPS
             WHEN 2
                 MOVE 1 TO PB-CX-RANGE-FLAGS
                 MOVE -2.5 TO PB-CX-MIN-DOUBLE
                 MOVE "01 c004000000000000" TO WS-PROPS
             WHEN 3
                 MOVE 2 TO PB-CX-RANGE-FLAGS
                 MOVE 100000 TO PB-CX-MAX-INT
                 MOVE "02 000186a0" TO WS-PROPS
             WHEN 4
                 MOVE 3 TO PB-CX-RANGE-FLAGS
                 MOVE -1 TO PB-CX-MIN-LONG
                 MOVE 4294967296 TO PB-CX-MAX-LONG
                 MOVE "03 ffffffffffffffff 0000000100000000" TO WS-PROPS
             WHEN 5
                 MOVE 1 TO PB-CX-STRING-KIND
                 MOVE "01" TO WS-PROPS
             WHEN 6
                 MOVE 3 TO PB-CX-FLAGS-BYTE
                 MOVE "03" TO WS-PROPS
             WHEN 31
                 MOVE 1 TO PB-CX-FLAGS-BYTE
                 MOVE "01" TO WS-PROPS
             WHEN 43
                 MOVE 20 TO PB-CX-TIME-MIN
                 MOVE "00000014" TO WS-PROPS
             WHEN 44 THRU 48
                 MOVE WS-KEY TO PB-CX-REGISTRY
                 MOVE 14 TO PB-CX-REGISTRY-LENGTH
                 MOVE WS-KEY-HEX TO WS-PROPS
         END-EVALUATE
         MOVE FUNCTION CHAR(WS-ID + 1) TO WS-BYTE
         MOVE SPACES TO WS-EXPECT
         STRING "06 00 01 61 " FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-BYTE)) " " WS-PROPS DELIMITED BY SIZE
             INTO WS-EXPECT
         MOVE WS-ID TO WS-EDIT
         MOVE SPACES TO WS-NAME
         STRING "argument of parser " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-NAME
         PERFORM PUT-AND-READ
     END-PERFORM
*>   Absent minimum and maximum: the flags byte alone.
     INITIALIZE PB-COMMAND-NODE-X
     COMPUTE PB-CX-FLAGS = PB-NODE-ARGUMENT + PB-NODE-EXECUTABLE
     MOVE "a" TO PB-CX-NAME
     MOVE 1 TO PB-CX-NAME-LENGTH
     MOVE PB-PX-FLOAT TO PB-CX-PARSER
     MOVE "float without a minimum or maximum is one flags byte" TO WS-NAME
     MOVE "06 00 01 61 01 00" TO WS-EXPECT
     PERFORM PUT-AND-READ
     MOVE PB-PX-DOUBLE TO PB-CX-PARSER
     MOVE 2 TO PB-CX-RANGE-FLAGS
     MOVE 1.5 TO PB-CX-MAX-DOUBLE
     MOVE "double with only a maximum" TO WS-NAME
     MOVE "06 00 01 61 02 02 3ff8000000000000" TO WS-EXPECT
     PERFORM PUT-AND-READ
     MOVE PB-PX-INTEGER TO PB-CX-PARSER
     MOVE 1 TO PB-CX-RANGE-FLAGS
     MOVE 0 TO PB-CX-MAX-DOUBLE
     MOVE -7 TO PB-CX-MIN-INT
     MOVE "integer with only a minimum" TO WS-NAME
     MOVE "06 00 01 61 03 01 fffffff9" TO WS-EXPECT
     PERFORM PUT-AND-READ
     MOVE PB-PX-LONG TO PB-CX-PARSER
     MOVE 2 TO PB-CX-RANGE-FLAGS
     MOVE 0 TO PB-CX-MIN-INT
     MOVE 9 TO PB-CX-MAX-LONG
     MOVE "long with only a maximum" TO WS-NAME
     MOVE "06 00 01 61 04 02 0000000000000009" TO WS-EXPECT
     PERFORM PUT-AND-READ
     MOVE PB-PX-FLOAT TO PB-CX-PARSER
     MOVE 1 TO PB-CX-RANGE-FLAGS
     MOVE 0 TO PB-CX-MAX-LONG
     MOVE -1.5 TO PB-CX-MIN-FLOAT
     MOVE "float with only a minimum" TO WS-NAME
     MOVE "06 00 01 61 01 01 bfc00000" TO WS-EXPECT
     PERFORM PUT-AND-READ
*>   ---- writer errors ----
     MOVE "flags 256" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE 256 TO PB-CX-FLAGS
     PERFORM PUT-ERROR
     MOVE "flags -1" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE -1 TO PB-CX-FLAGS
     PERFORM PUT-ERROR
     MOVE "257 children" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE 257 TO PB-CX-CHILD-COUNT
     PERFORM PUT-ERROR
     MOVE "-1 children" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE -1 TO PB-CX-CHILD-COUNT
     PERFORM PUT-ERROR
     MOVE "a 65-byte name" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE 65 TO PB-CX-NAME-LENGTH
     PERFORM PUT-ERROR
     MOVE "name length -1" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE -1 TO PB-CX-NAME-LENGTH
     PERFORM PUT-ERROR
     MOVE "parser 62" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE 62 TO PB-CX-PARSER
     PERFORM PUT-ERROR
     MOVE "parser -1" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE -1 TO PB-CX-PARSER
     PERFORM PUT-ERROR
     MOVE "string kind 3" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE PB-PX-STRING TO PB-CX-PARSER
     MOVE 3 TO PB-CX-STRING-KIND
     PERFORM PUT-ERROR
     MOVE "string kind -1" TO WS-NAME
     MOVE -1 TO PB-CX-STRING-KIND
     PERFORM PUT-ERROR
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > 4
         PERFORM BASE-ARGUMENT
         MOVE WS-ID TO PB-CX-PARSER
         MOVE 4 TO PB-CX-RANGE-FLAGS
         MOVE WS-ID TO WS-EDIT
         MOVE SPACES TO WS-NAME
         STRING "range flags 4 of parser " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
             INTO WS-NAME
         PERFORM PUT-ERROR
         MOVE -1 TO PB-CX-RANGE-FLAGS
         MOVE SPACES TO WS-NAME
         STRING "range flags -1 of parser " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
             INTO WS-NAME
         PERFORM PUT-ERROR
     END-PERFORM
     MOVE "entity flags byte 256" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE PB-PX-ENTITY TO PB-CX-PARSER
     MOVE 256 TO PB-CX-FLAGS-BYTE
     PERFORM PUT-ERROR
     MOVE "score_holder flags byte -1" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE PB-PX-SCORE-HOLDER TO PB-CX-PARSER
     MOVE -1 TO PB-CX-FLAGS-BYTE
     PERFORM PUT-ERROR
     MOVE "resource key of 65 bytes" TO WS-NAME
     PERFORM BASE-ARGUMENT
     MOVE PB-PX-RESOURCE TO PB-CX-PARSER
     MOVE 65 TO PB-CX-REGISTRY-LENGTH
     PERFORM PUT-ERROR
     MOVE "resource key of length -1" TO WS-NAME
     MOVE -1 TO PB-CX-REGISTRY-LENGTH
     PERFORM PUT-ERROR
     MOVE "resource key that is not an identifier" TO WS-NAME
     MOVE "Item" TO PB-CX-REGISTRY
     MOVE 4 TO PB-CX-REGISTRY-LENGTH
     PERFORM PUT-ERROR
     MOVE "suggestions type of 65 bytes" TO WS-NAME
     PERFORM BASE-ARGUMENT
     COMPUTE PB-CX-FLAGS = PB-NODE-ARGUMENT + PB-NODE-HAS-SUGGEST
     MOVE 65 TO PB-CX-SUGGEST-LENGTH
     PERFORM PUT-ERROR
     MOVE "suggestions type of length -1" TO WS-NAME
     MOVE -1 TO PB-CX-SUGGEST-LENGTH
     PERFORM PUT-ERROR
     MOVE "suggestions type that is not an identifier" TO WS-NAME
     MOVE "Ask Server" TO PB-CX-SUGGEST
     MOVE 10 TO PB-CX-SUGGEST-LENGTH
     PERFORM PUT-ERROR
     MOVE "a 65-byte literal name" TO WS-NAME
     INITIALIZE PB-COMMAND-NODE-X
     MOVE PB-NODE-LITERAL TO PB-CX-FLAGS
     MOVE 65 TO PB-CX-NAME-LENGTH
     PERFORM PUT-ERROR
*>   ---- reader errors ----
     MOVE "no bytes" TO WS-NAME
     MOVE SPACES TO WS-HEX
     PERFORM GET-ERROR
     MOVE "257 children" TO WS-NAME
     MOVE "00 8102" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "children cut short" TO WS-NAME
     MOVE "00 03 01 02" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "redirect missing" TO WS-NAME
     MOVE "08 00" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "name missing" TO WS-NAME
     MOVE "01 00" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "65-byte name" TO WS-NAME
     MOVE SPACES TO WS-HEX
     STRING "01 00 41 " DELIMITED BY SIZE INTO WS-HEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65
         STRING "61" DELIMITED BY SIZE INTO WS-HEX(10 + (WS-I - 1) * 2:2)
     END-PERFORM
     PERFORM GET-ERROR
     MOVE "parser 62" TO WS-NAME
     MOVE "02 00 01 61 3e" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "parser missing" TO WS-NAME
     MOVE "02 00 01 61" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "float range flags 4" TO WS-NAME
     MOVE "02 00 01 61 01 04" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "float range without its maximum" TO WS-NAME
     MOVE "02 00 01 61 01 03 3f000000" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "double range without its minimum" TO WS-NAME
     MOVE "02 00 01 61 02 01" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "integer range flags 4" TO WS-NAME
     MOVE "02 00 01 61 03 04" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "long range without its maximum" TO WS-NAME
     MOVE "02 00 01 61 04 03 0000000000000001" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "string kind 3" TO WS-NAME
     MOVE "02 00 01 61 05 03" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "entity without its flags byte" TO WS-NAME
     MOVE "02 00 01 61 06" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "score_holder without its flags byte" TO WS-NAME
     MOVE "02 00 01 61 1f" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "time without its minimum" TO WS-NAME
     MOVE "02 00 01 61 2b 000000" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "resource key that is not an identifier" TO WS-NAME
     MOVE "02 00 01 61 2e 03 49 74 6d" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "suggestions type that is not an identifier" TO WS-NAME
     MOVE "12 00 01 61 07 03 41 42 43" TO WS-HEX
     PERFORM GET-ERROR
     MOVE "suggestions type missing" TO WS-NAME
     MOVE "12 00 01 61 07" TO WS-HEX
     PERFORM GET-ERROR
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.

*> An executable argument node "a" of parser 0 (bool), no children.
 BASE-ARGUMENT.
     INITIALIZE PB-COMMAND-NODE-X
     COMPUTE PB-CX-FLAGS = PB-NODE-ARGUMENT + PB-NODE-EXECUTABLE
     MOVE "a" TO PB-CX-NAME
     MOVE 1 TO PB-CX-NAME-LENGTH.

*> Encodes the node, compares the bytes with WS-EXPECT, then reads them back into PK and compares
*> every field of both records and the position.
 PUT-AND-READ.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     PERFORM CHECK-BYTES
     PERFORM READ-BACK.

*> The same without a byte comparison (the bytes of a 256-child node are long); the read-back
*> still has to reproduce every field.
 PUT-AND-READ-ANY.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     PERFORM READ-BACK.

 CHECK-BYTES.
     MOVE SPACES TO TL-CASE
     STRING "test command nodes " FUNCTION TRIM(WS-NAME) " encodes to " FUNCTION TRIM(WS-EXPECT)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-J
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 1024
         IF WS-EXPECT(WS-K:1) NOT = SPACE
             MOVE WS-EXPECT(WS-K:1) TO TL-EXPECTED(WS-J:1)
             ADD 1 TO WS-J
         END-IF
     END-PERFORM
     CALL "TEST-BUFFER-HEX" USING PB-BUFFER TL-OBSERVED
     IF PB-ERROR NOT = 0
         MOVE "error" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 READ-BACK.
     MOVE 0 TO PB-POS
     CALL "PB-GET-COMMAND-NODE-X" USING PB-BUFFER PK-COMMAND-NODE-X
     MOVE SPACES TO WS-SAME
     IF PB-ERROR = 0 AND PB-POS = PB-LENGTH AND PK-COMMAND-NODE-X = PB-COMMAND-NODE-X
         MOVE "same" TO WS-SAME
     ELSE
         MOVE "different" TO WS-SAME
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "test command nodes " FUNCTION TRIM(WS-NAME) " decodes to the same node"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "same" TO TL-EXPECTED
     MOVE WS-SAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> PB-ERROR 1 and nothing appended; the buffer is reset for the next case.
 PUT-ERROR.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     MOVE SPACES TO TL-CASE
     STRING "test command nodes put of " FUNCTION TRIM(WS-NAME)
         " sets PB-ERROR and appends nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PB-ERROR * 10 + PB-LENGTH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> PB-ERROR 1, PB-POS back at 0 and the node as an INITIALIZEd record.
 GET-ERROR.
     CALL "TEST-FILL-HEX" USING WS-HEX PB-BUFFER
     INITIALIZE PB-COMMAND-NODE-X
     MOVE 77 TO PK-CX-FLAGS
     CALL "PB-GET-COMMAND-NODE-X" USING PB-BUFFER PK-COMMAND-NODE-X
     MOVE SPACES TO TL-CASE
     STRING "test command nodes get of " FUNCTION TRIM(WS-NAME)
         " sets PB-ERROR, keeps PB-POS and yields an all-zero node" DELIMITED BY SIZE
         INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PB-ERROR * 1000 + PB-POS * 100
     IF PK-COMMAND-NODE-X NOT = PB-COMMAND-NODE-X
         ADD 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-COMMAND-NODES.
 COPY PROTOTEST.
