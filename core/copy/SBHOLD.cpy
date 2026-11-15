*> The score holders a command's holder argument names (core/src/cmds-scoreboard.cob SBX-HOLDERS): the count and, for each, its name and length.
 01 SBH-TABLE.
    05 SBH-COUNT            BINARY-LONG.
    05 SBH-ENTRY            OCCURS 64 TIMES.
       10 SBH-NAME           PIC X(64).
       10 SBH-LENGTH         BINARY-LONG.
