*> A compiled regular expression and its matcher state (formats/src/regex.cob). REGEX-PROG is a
*> Thompson program: CHAR (RX-X = byte ordinal), ANY, CLASS (RX-X = class row: one "0"/"1" flag
*> per byte ordinal), SPLIT (to RX-X and RX-Y), JMP (to RX-X), BOL, EOL and MATCH. REGEX-THREADS
*> holds the two thread lists, the per-instruction marks and the closure stack of the matcher.
 78 RX-MAX-OPS              VALUE 1024.
 78 RX-MAX-CLASSES          VALUE 64.
 78 RX-OP-CHAR              VALUE 1.
 78 RX-OP-ANY               VALUE 2.
 78 RX-OP-CLASS             VALUE 3.
 78 RX-OP-SPLIT             VALUE 4.
 78 RX-OP-JMP               VALUE 5.
 78 RX-OP-BOL               VALUE 6.
 78 RX-OP-EOL               VALUE 7.
 78 RX-OP-MATCH             VALUE 8.
 01 REGEX-PROG.
    05 RX-ERROR             BINARY-LONG.
    05 RX-COUNT             BINARY-LONG.
    05 RX-OP OCCURS 1024 TIMES.
       10 RX-KIND           BINARY-LONG.
       10 RX-X              BINARY-LONG.
       10 RX-Y              BINARY-LONG.
    05 RX-CLASS-COUNT       BINARY-LONG.
    05 RX-CLASS             PIC X(256) OCCURS 64 TIMES.
 01 REGEX-THREADS.
    05 RR-MATCHED           BINARY-LONG.
    05 RR-MARK              BINARY-LONG OCCURS 1024 TIMES.
    05 RR-LIST OCCURS 2 TIMES.
       10 RR-N              BINARY-LONG.
       10 RR-PC             BINARY-LONG OCCURS 1024 TIMES.
    05 RR-STACK-N           BINARY-LONG.
    05 RR-STACK             BINARY-LONG OCCURS 2100 TIMES.
