*> The state of the command being run (docs/protocol/15a-brigadier-command-library.md §4, 15-commands-framework.md §10;
*> core/src/cmd-exec.cob): the command source, the sources a modifier produced, and the nodes of the context being run.
*> BS-SIZE bytes per source: a source is moved to and from a list entry as one area.
 78 BS-SIZE               VALUE 96.
 78 BR-MAX-SOURCES        VALUE 1024.
 78 BR-MAX-RUN-NODES      VALUE 24.
*> The source of the command: the player row (0 = the console), the permission level, the position (in the dimension
*> row BS-DIM), the rotation, the entity anchor (0 feet, 1 eyes), silent (1: no feedback is sent) and forked; BS-OUT the player row (0 = the console) that is told what the commands report (it stays
*> the sender while execute as changes the executing entity BS-ROW).
 01 BR-SRC EXTERNAL.
    05 BS-ROW               BINARY-LONG.
    05 BS-LEVEL             BINARY-LONG.
    05 BS-SILENT            BINARY-LONG.
    05 BS-DIM               BINARY-LONG.
    05 BS-X                 FLOAT-LONG.
    05 BS-Y                 FLOAT-LONG.
    05 BS-Z                 FLOAT-LONG.
    05 BS-YAW               FLOAT-SHORT.
    05 BS-PITCH             FLOAT-SHORT.
    05 BS-ANCHOR            BINARY-LONG.
    05 BS-NAME-LENGTH       BINARY-LONG.
    05 BS-NAME              PIC X(16).
    05 BS-FORKED            BINARY-LONG.
    05 BS-EXTRA             BINARY-LONG.
    05 BS-OUT               BINARY-LONG.
    05 FILLER               PIC X(8).
*> The sources a modifier returned for the current one.
 01 BR-MOD EXTERNAL.
    05 BM-COUNT             BINARY-LONG.
    05 BM-ENTRY             PIC X(96) OCCURS 1024 TIMES.
*> The command being run: its id, the line, the nodes of its context (literals and arguments, in order, with the values the
*> parser stored), its result, and BR-R-FAILED 1 when it raised the exception in BR-ERR.
 01 BR-RUN EXTERNAL.
    05 BR-R-COMMAND         BINARY-LONG.
    05 BR-R-RESULT          BINARY-LONG.
    05 BR-R-FAILED          BINARY-LONG.
    05 BR-R-MODIFIER        BINARY-LONG.
    05 BR-R-LENGTH          BINARY-LONG.
    05 BR-R-LINE            PIC X(1024).
    05 BR-R-COUNT           BINARY-LONG.
    05 BR-R-ARG             OCCURS 24 TIMES.
       10 BA-NAME            PIC X(64).
       10 BA-NAME-LENGTH     BINARY-LONG.
       10 BA-NODE            BINARY-LONG.
       10 BA-ARG             BINARY-LONG.    *> 1 for an argument, 0 for a literal
       10 BA-TYPE            BINARY-LONG.    *> the parser id of an argument (0 for a literal and for bool)
       10 BA-START           BINARY-LONG.
       10 BA-END             BINARY-LONG.
       10 BA-INF             BINARY-LONG.
       10 BA-IVAL            BINARY-DOUBLE.
       10 BA-DVAL            FLOAT-LONG.
       10 BA-AUX             BINARY-LONG.
       10 BA-IVAL2           BINARY-DOUBLE.
       10 BA-DVAL2           FLOAT-LONG.
       10 BA-KIND            BINARY-LONG OCCURS 3 TIMES.
       10 BA-NUM             FLOAT-LONG OCCURS 3 TIMES.
