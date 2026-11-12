*> Acceptance test of the tree of docs/protocol/15a-brigadier-command-library.md §2 (nodes and the
*> same-name rule of §2.3): children are kept in insertion order, one name space for literals and
*> arguments, a child added under an existing name is that node (not created: its kind, level and
*> command stay), children added under it merge, the table holds BR-MAX-NODES nodes, a reset leaves
*> only the root.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15A-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 01 WS-PARENT              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-POS                 BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "BR-TREE-RESET"
     MOVE 1 TO WS-PARENT
     MOVE "a" TO WS-NAME
     PERFORM ADD-LITERAL
     MOVE WS-NODE TO WS-A
     MOVE "b" TO WS-NAME
     PERFORM ADD-ARGUMENT
     MOVE WS-NODE TO WS-B
     MOVE "c" TO WS-NAME
     PERFORM ADD-LITERAL
     PERFORM CHILDREN-OF-ROOT
     MOVE "acceptance US13 15a§2 The tree children are kept in insertion order" TO TL-CASE
     MOVE "a b c" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE 3 TO BR-N-LEVEL(WS-A)
     MOVE 9 TO BR-N-COMMAND(WS-A)
     MOVE "a" TO WS-NAME
     PERFORM ADD-ARGUMENT
     MOVE "acceptance US13 15a§2 The tree an argument added under a literal's name is that literal, not created"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1003 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CREATED * 1000000 + BR-N-KIND(WS-NODE) * 1000 + BR-N-LEVEL(WS-NODE)
         + (WS-NODE - WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US13 15a§2 The tree the old node keeps its command" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE BR-N-COMMAND(WS-NODE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "b" TO WS-NAME
     PERFORM ADD-LITERAL
     MOVE "acceptance US13 15a§2 The tree a literal added under an argument's name is that argument"
         TO TL-CASE
     MOVE 2000000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BR-N-KIND(WS-NODE) * 1000000 + WS-CREATED + (WS-NODE - WS-B)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE WS-A TO WS-PARENT
     MOVE "x" TO WS-NAME
     PERFORM ADD-LITERAL
     MOVE 1 TO WS-PARENT
     MOVE "a" TO WS-NAME
     PERFORM ADD-LITERAL
     MOVE WS-NODE TO WS-PARENT
     MOVE "y" TO WS-NAME
     PERFORM ADD-LITERAL
     MOVE WS-A TO WS-PARENT
     PERFORM CHILDREN-OF-PARENT
     MOVE "acceptance US13 15a§2 The tree children added under an existing node merge in order" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "x y" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     CALL "BR-TREE-RESET"
     MOVE 1 TO WS-PARENT
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-NODE = 0 AND WS-I > 0
         ADD 1 TO WS-I
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-NAME
         STRING "n" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-NAME
         PERFORM ADD-LITERAL
     END-PERFORM
     MOVE "acceptance US13 15a§2 The tree the table holds 4096 nodes (the root and 4095) and then adds none" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4096004096 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BR-NODE-COUNT * 1000000 + WS-I
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BR-TREE-RESET"
     MOVE "acceptance US13 15a§2 The tree a reset leaves only the root" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BR-NODE-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-LITERAL.
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     PERFORM ADD-NODE.

 ADD-ARGUMENT.
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE BR-P-BOOL TO WS-TYPE
     PERFORM ADD-NODE.

 ADD-NODE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-PARENT WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-NODE WS-CREATED.

 CHILDREN-OF-ROOT.
     MOVE 1 TO WS-PARENT
     PERFORM CHILDREN-OF-PARENT.

 CHILDREN-OF-PARENT.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     MOVE BR-N-FIRST(WS-PARENT) TO WS-CHILD
     PERFORM UNTIL WS-CHILD = 0
         IF WS-POS > 1
             STRING " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         STRING BR-N-NAME(WS-CHILD)(1:BR-N-NAME-LENGTH(WS-CHILD)) DELIMITED BY SIZE
             INTO WS-TEXT WITH POINTER WS-POS
         MOVE BR-N-NEXT(WS-CHILD) TO WS-CHILD
     END-PERFORM.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CMD-15A-2.
