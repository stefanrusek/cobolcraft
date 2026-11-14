*> Acceptance test of the usage strings of docs/protocol/15a-brigadier-command-library.md §7 (§9.3
*> U1 to U4, on the tree of §9): BR-ALL-USAGE (a line per executable node and per redirect, depth
*> first; a redirect to the root prints "...", to another node "-> <usage text>") and BR-SMART-USAGE
*> (optional groups in [ ], alternatives joined by |). Usable nodes are those whose requirement
*> level the source holds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15A-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FOO                 BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-EACH                BINARY-LONG.
 01 WS-TP                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-RESTRICTED          BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-PART                PIC X(64).
 01 WS-PART-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM BUILD-TREE
     MOVE 1 TO WS-NODE
     CALL "BR-ALL-USAGE" USING WS-NODE WS-LEVEL WS-RESTRICTED
     PERFORM LIST-LINES
     MOVE "acceptance US13 15a§7 Usage strings U1 getAllUsage of the root" TO TL-CASE
     MOVE "foo | foo <n> | foo bar | say <msg> | tp <x> <y> | name <s> | d <v> | f <v> | b <flag> | run ... | each ..."
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "BR-SMART-USAGE" USING WS-FOO WS-LEVEL
     PERFORM SMART-LINES
     MOVE "acceptance US13 15a§7 Usage strings U2 getSmartUsage of foo" TO TL-CASE
     MOVE "n = [<n>] | bar = [bar]" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "BR-SMART-USAGE" USING WS-NODE WS-LEVEL
     PERFORM SMART-LINES
     MOVE "acceptance US13 15a§7 Usage strings U3 getSmartUsage of the root" TO TL-CASE
     MOVE "foo = foo [<n>|bar] | say = say <msg> | tp = tp <x> <y> | name = name <s> | d = d <v> | f = f <v> | b = b <flag> | run = run ... | each = each ..."
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
*>   U4: a redirect to a node other than the root prints "-> <usage text of the target>".
     MOVE WS-FOO TO BR-N-REDIRECT(WS-EACH)
     MOVE 0 TO BR-N-REDIRECT(WS-RUN)
     MOVE WS-RUN TO WS-NODE
     MOVE 1 TO WS-NODE
     CALL "BR-SMART-USAGE" USING WS-NODE WS-LEVEL
     PERFORM SMART-LINES
     MOVE "acceptance US13 15a§7 Usage strings U4 a redirect to a non-root node reads -> foo" TO TL-CASE
     MOVE "foo = foo [<n>|bar] | say = say <msg> | tp = tp <x> <y> | name = name <s> | d = d <v> | f = f <v> | b = b <flag> | run = run | each = each -> foo"
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
*>   Requirements: with a restricted walk, nodes above the source's level vanish.
     MOVE 2 TO BR-N-LEVEL(WS-TP)
     MOVE 1 TO WS-RESTRICTED
     MOVE 1 TO WS-NODE
     CALL "BR-ALL-USAGE" USING WS-NODE WS-LEVEL WS-RESTRICTED
     PERFORM LIST-LINES
     MOVE "acceptance US13 15a§7 Usage strings a restricted walk hides a node the source cannot use"
         TO TL-CASE
     MOVE "foo | foo <n> | foo bar | say <msg> | name <s> | d <v> | f <v> | b <flag> | each -> foo"
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "BR-SMART-USAGE" USING WS-NODE WS-LEVEL
     PERFORM SMART-LINES
     MOVE "acceptance US13 15a§7 Usage strings a smart usage lists only usable children" TO TL-CASE
     MOVE "foo = foo [<n>|bar] | say = say <msg> | name = name <s> | d = d <v> | f = f <v> | b = b <flag> | run = run | each = each -> foo"
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
*>   A start node with a redirect takes its own usage text as the prefix; the root's usage text is empty.
     MOVE 0 TO WS-RESTRICTED
     MOVE 4 TO WS-LEVEL
     CALL "BR-ALL-USAGE" USING WS-EACH WS-LEVEL WS-RESTRICTED
     PERFORM LIST-LINES
     MOVE "acceptance US13 15a§7 Usage strings a redirected start node prints its own text" TO TL-CASE
     MOVE "each -> foo" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-NODE
     CALL "BR-USAGE-TEXT" USING WS-NODE WS-PART WS-PART-LENGTH
     MOVE "acceptance US13 15a§7 Usage strings the usage text of the root is empty" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PART-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A parent with a command and one child makes the child optional: opt [<v>].
     MOVE 1 TO WS-NODE
     MOVE "opt" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE 20 TO BR-N-COMMAND(WS-CHILD)
     MOVE WS-CHILD TO WS-NODE
     MOVE "v" TO WS-NAME
     MOVE BR-P-BOOL TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 21 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     CALL "BR-SMART-USAGE" USING WS-NODE WS-LEVEL
     PERFORM SMART-LINES
     MOVE "acceptance US13 15a§7 Usage strings a command with a single child shows it optional"
         TO TL-CASE
     MOVE "foo = foo [<n>|bar] | say = say <msg> | tp = tp <x> <y> | name = name <s> | d = d <v> | f = f <v> | b = b <flag> | run = run | each = each -> foo | opt = opt [<v>]"
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
*>   More lines than the table holds are cut at BR-U-MAX (128).
     MOVE 1 TO WS-NODE
     MOVE "many" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 130
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO WS-NAME
         STRING "c" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-NAME
         PERFORM LITERAL-NODE
         MOVE 30 TO BR-N-COMMAND(WS-CHILD)
     END-PERFORM
     CALL "BR-ALL-USAGE" USING WS-NODE WS-LEVEL WS-RESTRICTED
     MOVE "acceptance US13 15a§7 Usage strings the lines are cut at 128" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 128 TO TL-EXPECTED-N
     MOVE BR-U-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 LIST-LINES.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-U-COUNT
         IF WS-I > 1
             STRING " | " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         IF BR-U-LENGTH(WS-I) > 0
             STRING BR-U-TEXT(WS-I)(1:BR-U-LENGTH(WS-I)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
     END-PERFORM.

 SMART-LINES.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-U-COUNT
         IF WS-I > 1
             STRING " | " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         STRING FUNCTION TRIM(BR-N-NAME(BR-U-NODE(WS-I))) " = " BR-U-TEXT(WS-I)(1:BR-U-LENGTH(WS-I))
             DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-PERFORM.

 ADD-NODE.
*> parent in WS-NODE, WS-KIND, WS-NAME (trimmed), WS-TYPE: the child id in WS-CHILD.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED.

 LITERAL-NODE.
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     PERFORM ADD-NODE.

 ARGUMENT-NODE.
     MOVE BR-ARGUMENT TO WS-KIND
     PERFORM ADD-NODE.

 BUILD-TREE.
     CALL "BR-TREE-RESET"
     MOVE 1 TO WS-NODE
     MOVE "foo" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-FOO
     MOVE 1 TO BR-N-COMMAND(WS-FOO)
     MOVE WS-FOO TO WS-NODE
     MOVE "n" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 2 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MAX(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MIN(WS-CHILD)
     MOVE 1 TO BR-N-IMIN(WS-CHILD)
     MOVE 10 TO BR-N-IMAX(WS-CHILD)
     MOVE "bar" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE 3 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "say" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "msg" TO WS-NAME
     MOVE BR-P-STRING TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 4 TO BR-N-COMMAND(WS-CHILD)
     MOVE BR-S-GREEDY TO BR-N-STRING-KIND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "tp" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-TP
     MOVE WS-TP TO WS-NODE
     MOVE "x" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "y" TO WS-NAME
     PERFORM ARGUMENT-NODE
     MOVE 5 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "name" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "s" TO WS-NAME
     MOVE BR-P-STRING TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 6 TO BR-N-COMMAND(WS-CHILD)
     MOVE BR-S-PHRASE TO BR-N-STRING-KIND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "d" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "v" TO WS-NAME
     MOVE BR-P-DOUBLE TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 7 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "f" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "v" TO WS-NAME
     MOVE BR-P-FLOAT TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 8 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MIN(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MAX(WS-CHILD)
     MOVE 0 TO BR-N-DMIN(WS-CHILD)
     MOVE 1 TO BR-N-DMAX(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "b" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "flag" TO WS-NAME
     MOVE BR-P-BOOL TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 9 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "run" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-RUN
     MOVE 1 TO BR-N-REDIRECT(WS-RUN)
     MOVE "each" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-EACH
     MOVE 1 TO BR-N-REDIRECT(WS-EACH)
     MOVE 1 TO BR-N-FORK(WS-EACH).

 END PROGRAM TEST-CMD-15A-7.
