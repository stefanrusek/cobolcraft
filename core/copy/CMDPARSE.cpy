*> The parsed command line (core/src/commands.cob CMD-PARSE; standin-content §16.1, §16.3), shared
*> by the programs of that file (EXTERNAL). The line is the text after the leading `/` (chat) or the
*> console line, split into words at single spaces (two spaces make an empty word). Word 1 is the
*> command name; CQ-STEP(k) is the tree node (COMMANDS.cpy) that word k + 1 matched, with the value
*> of an argument node: an integer, a double, or the text (CQ-STEP-START, CQ-STEP-LENGTH into
*> CQ-LINE; a greedy phrase runs to the end of the line). CQ-COMMAND is the command row (0 when the
*> name is unknown) and CQ-USAGE the usage row an error names.
 78 CMD-MAX-WORDS           VALUE 800.
 78 CMD-MAX-STEPS           VALUE 16.
 01 CMD-STATE EXTERNAL.
    05 CQ-SENDER             BINARY-LONG.        *> player row, 0 = the console
    05 CQ-LINE               PIC X(768).
    05 CQ-LINE-LENGTH        BINARY-LONG.
    05 CQ-WORD-COUNT         BINARY-LONG.
    05 CQ-WORD OCCURS 800 TIMES.
       10 CQ-WORD-START      BINARY-LONG.
       10 CQ-WORD-LENGTH     BINARY-LONG.
    05 CQ-COMMAND            BINARY-LONG.
    05 CQ-USAGE              BINARY-LONG.
    05 CQ-NODE               BINARY-LONG.        *> the node the matched words reached
    05 CQ-STEP-COUNT         BINARY-LONG.
    05 CQ-STEP OCCURS 16 TIMES.
       10 CQ-STEP-NODE       BINARY-LONG.
       10 CQ-STEP-INT        BINARY-LONG.
       10 CQ-STEP-DOUBLE     FLOAT-LONG.
       10 CQ-STEP-START      BINARY-LONG.
       10 CQ-STEP-LENGTH     BINARY-LONG.
*> The answer to a Command Suggestion (09 §3.3 row 0x0F, §3.4 rule 5): the start (characters before
*> the word being completed, the leading `/` included) and length of that word, and the
*> suggestions (CMD-SUGGEST fills it, CMD-SUGGESTIONS-BUILD writes it).
 78 CMD-MAX-SUGGESTIONS     VALUE 64.
 01 CMD-SUGGESTIONS EXTERNAL.
    05 CG-START              BINARY-LONG.
    05 CG-LENGTH             BINARY-LONG.
    05 CG-WORD               PIC X(768).         *> the word being completed
    05 CG-WORD-LENGTH        BINARY-LONG.
    05 CG-COUNT              BINARY-LONG.
    05 CG-ENTRY OCCURS 64 TIMES.
       10 CG-TEXT            PIC X(32).
       10 CG-TEXT-LENGTH     BINARY-LONG.
