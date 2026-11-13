*> Implementation test of COMMANDS-READ with the full tree of the server (T4801; 05a 0x10, 15 section 3.4):
*> a tree written with every kind of argument parser (block_pos, vec3, entity, ...) and more nodes than the
*> old 160 is kept whole, so the command names of the operator's tree complete in the chat line. Before T4801
*> the client read nodes with the 5-parser reader and dropped the whole tree at the first other parser.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE-FULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-TEXT                PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 402.
 01 WS-ROOT                BINARY-LONG VALUE 0.
 01 WS-NUM                 PIC 9(3).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
*>   Node 0 the root with the literal children 1 to 200; node 1 has the literals 201 to 400 as children; node 401 is an
*>   argument (block_pos), the one child of node 200.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     INITIALIZE PB-COMMAND-NODE-X
     MOVE 0 TO PB-CX-FLAGS
     MOVE 200 TO PB-CX-CHILD-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO PB-CX-CHILD(WS-I)
     END-PERFORM
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         INITIALIZE PB-COMMAND-NODE-X
         MOVE 1 TO PB-CX-FLAGS
         MOVE 0 TO PB-CX-CHILD-COUNT
         IF WS-I = 200
             MOVE 1 TO PB-CX-CHILD-COUNT
             MOVE 401 TO PB-CX-CHILD(1)
         END-IF
         IF WS-I = 1
             MOVE 200 TO PB-CX-CHILD-COUNT
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 200
                 COMPUTE PB-CX-CHILD(WS-N) = 200 + WS-N
             END-PERFORM
         END-IF
         MOVE WS-I TO WS-NUM
         STRING "c" WS-NUM DELIMITED BY SIZE INTO PB-CX-NAME
         MOVE 4 TO PB-CX-NAME-LENGTH
         CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     END-PERFORM
     INITIALIZE PB-COMMAND-NODE-X
     MOVE 2 TO PB-CX-FLAGS
     MOVE "pos" TO PB-CX-NAME
     MOVE 3 TO PB-CX-NAME-LENGTH
     MOVE PB-PX-BLOCK-POS TO PB-CX-PARSER
     CALL "PB-PUT-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ROOT
     MOVE 0 TO PB-POS
     CALL "COMMANDS-READ" USING CLIENT-STATE PB-BUFFER
     MOVE "N" TO TL-MODE
     MOVE "test command tree full a tree with a block_pos argument and 402 nodes is kept whole" TO TL-CASE
     MOVE 402 TO TL-EXPECTED-N
     MOVE CM-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test command tree full the root keeps its 200 children and node 200 has the argument as its one child" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CM-CHILDREN(1) TO WS-E1
     MOVE CM-CHILDREN(201) TO WS-E2
     MOVE CM-NAME-LENGTH(402) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "200 1 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COMMAND-TREE-FULL.

 COPY CLTEST.
