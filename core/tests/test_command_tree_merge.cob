*> Test of the shared nodes of the Commands packet (docs/protocol/57-client-closures-4 section 2.2) on a small tree built with BR-REG: nodes with the same kind, name and children
*> and no command are one entry (two `int` literals each over the argument `scale`, a double without bounds, and the `float` pair likewise), nodes with a command are not merged
*> (two `x` arguments that are executable), nor are bounded numbers; the shared children give the parents the same indices. The marks of a registration line are
*> tested too: `!` after an argument's type gives it the ask_server provider and `@N` the requirement level of the node.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-TREE-MERGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY BRIGADIER.
 COPY BRREGLAST.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-HIGH                BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-NODES.
    05 WS-NODE-KIDS        PIC X(40) OCCURS 40 TIMES.
 01 WS-TEXT                PIC X(40).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-LAST                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BR-TREE-RESET"
     MOVE "T" TO TL-MODE
     MOVE "ex store result int <scale:double>" TO WS-PATH
     PERFORM REGISTER-OPEN
     MOVE "ex store success int <scale:double>" TO WS-PATH
     PERFORM REGISTER-OPEN
     MOVE "ex store result float <scale:double>" TO WS-PATH
     PERFORM REGISTER-OPEN
     MOVE "ex store success float <scale:double>" TO WS-PATH
     PERFORM REGISTER-OPEN
     MOVE "ex a <x:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ex b <x:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ex c <y:int:1:5>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ex d <y:int:1:5>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BR-TREE-BUILD" USING WS-LEVEL PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "PB-GET-COMMAND-NODE-X" USING PB-BUFFER PB-COMMAND-NODE-X
         MOVE SPACES TO WS-NODE-KIDS(WS-I)
         MOVE 1 TO WS-J
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-CX-CHILD-COUNT
             MOVE PB-CX-CHILD(WS-J) TO WS-E1
             MOVE SPACES TO WS-TEXT
             STRING FUNCTION TRIM(WS-NODE-KIDS(WS-I)) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
             MOVE FUNCTION TRIM(WS-TEXT) TO WS-NODE-KIDS(WS-I)
         END-PERFORM
     END-PERFORM
     MOVE "test command tree merge the 21 nodes of the unmerged tree (root, ex, store, result, success, 2 int, 2 float, 4 scale, a, b with their x, c, d with their y) are 16 entries: the shared int, float and scale nodes are one each" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test command tree merge result and success list the same children (the shared int and float entries)" TO TL-CASE
     MOVE FUNCTION TRIM(WS-NODE-KIDS(8)) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-NODE-KIDS(9)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test command tree merge the shared children of result are the entries 13 and 14 (breadth first numbering)" TO TL-CASE
     MOVE "13 14" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-NODE-KIDS(8)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The marks of a line: the node after `!` and `@2` is an ask_server argument of level 2.
     CALL "BR-TREE-RESET"
     MOVE "m <p:word!@2>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-LAST
     MOVE BR-N-SUGGEST(WS-LAST) TO WS-E1
     MOVE BR-N-LEVEL(WS-LAST) TO WS-E2
     MOVE "test command tree merge the argument of `m <p:word!@2>` has the ask_server provider and the requirement level 2" TO TL-CASE
     MOVE "1 2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> A line whose last node is not executable: the nodes of the doc's `execute store` leaves have a redirect and no command.
 REGISTER-OPEN.
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE 0 TO BR-N-COMMAND(BR-REG-LAST-NODE).
 END PROGRAM TEST-COMMAND-TREE-MERGE.
