*> The Brigadier-style command framework state (docs/protocol/15-commands-framework.md, 15a-brigadier-
*> command-library.md; core/src/cmd-tree.cob, cmd-reader.cob, cmd-dispatch.cob): one command tree
*> (BR-TREE, node 1 is the root, children kept in insertion order as a linked list), the input line
*> being parsed (BR-IN) and the last raised exception (BR-ERR). Cursors are 0-based offsets as in
*> 15a, so the character at cursor c is BR-IN-TEXT(c + 1:1). Requirements are permission levels
*> (15 §2.1: 0 all to 4 owners; a source holds level L or more).
 78 BR-MAX-NODES           VALUE 1024.
 78 BR-LINE-MAX            VALUE 1024.
 78 BR-LITERAL             VALUE 1.
 78 BR-ARGUMENT            VALUE 2.
*> Argument parser ids of 05a (the ones the framework parses itself; others read one word).
 78 BR-P-BOOL              VALUE 0.
 78 BR-P-FLOAT             VALUE 1.
 78 BR-P-DOUBLE            VALUE 2.
 78 BR-P-INTEGER           VALUE 3.
 78 BR-P-LONG              VALUE 4.
 78 BR-P-STRING            VALUE 5.
 78 BR-S-WORD              VALUE 0.
 78 BR-S-PHRASE            VALUE 1.
 78 BR-S-GREEDY            VALUE 2.
 01 BR-TREE EXTERNAL.
    05 BR-NODE-COUNT        BINARY-LONG.
    05 BR-NODE              OCCURS 1024 TIMES.
       10 BR-N-KIND          BINARY-LONG.   *> 0 root, BR-LITERAL, BR-ARGUMENT
       10 BR-N-NAME-LENGTH   BINARY-LONG.
       10 BR-N-NAME          PIC X(32).
       10 BR-N-LEVEL         BINARY-LONG.   *> requirement: permission level 0 to 4
       10 BR-N-COMMAND       BINARY-LONG.   *> 0 = not executable, else the command id
       10 BR-N-REDIRECT      BINARY-LONG.   *> target node, 0 = none
       10 BR-N-FORK          BINARY-LONG.   *> 1 = fork
       10 BR-N-FIRST         BINARY-LONG.   *> first child, 0 = none
       10 BR-N-LAST          BINARY-LONG.
       10 BR-N-NEXT          BINARY-LONG.   *> next sibling
       10 BR-N-TYPE          BINARY-LONG.   *> argument parser id
       10 BR-N-STRING-KIND   BINARY-LONG.
       10 BR-N-HAS-MIN       BINARY-LONG.
       10 BR-N-HAS-MAX       BINARY-LONG.
       10 BR-N-IMIN          BINARY-DOUBLE.
       10 BR-N-IMAX          BINARY-DOUBLE.
       10 BR-N-DMIN          FLOAT-LONG.
       10 BR-N-DMAX          FLOAT-LONG.
       10 BR-N-SUGGEST       BINARY-LONG.   *> 0 none, 1 ask_server
 01 BR-IN EXTERNAL.
    05 BR-IN-LENGTH         BINARY-LONG.
    05 BR-IN-CURSOR         BINARY-LONG.
    05 BR-IN-LEVEL          BINARY-LONG.    *> permission level of the source
    05 BR-IN-TEXT           PIC X(1024).
*> The exception being raised: translation key (spaces = none), up to two string arguments, cursor.
 01 BR-ERR EXTERNAL.
    05 BR-E-KEY             PIC X(48).
    05 BR-E-ARG-COUNT       BINARY-LONG.
    05 BR-E-ARG-LENGTH      BINARY-LONG OCCURS 2 TIMES.
    05 BR-E-ARG             PIC X(64) OCCURS 2 TIMES.
    05 BR-E-CURSOR          BINARY-LONG.
