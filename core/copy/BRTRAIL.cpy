*> A parse result of the command dispatcher (15a §3): the trail of parsed nodes with their ranges
*> and the context each belongs to (a redirect starts a child context, 15a §3.4), the argument
*> values (integer or double), the reader cursor after the parse and the exceptions recorded by the
*> failing candidates of the level that ended it. COPY with REPLACING LEADING ==BT-== BY ==xx-==.
 78 BT-MAX-ENTRIES          VALUE 48.
 78 BT-MAX-CTX              VALUE 8.
 78 BT-MAX-ERRS             VALUE 4.
 01 BT-TRAIL.
    05 BT-COUNT             BINARY-LONG.
    05 BT-ENTRY             OCCURS 48 TIMES.
       10 BT-NODE            BINARY-LONG.
       10 BT-START           BINARY-LONG.
       10 BT-END             BINARY-LONG.
       10 BT-CTX             BINARY-LONG.
       10 BT-INF             BINARY-LONG.   *> 1 = a float or double that parsed to infinity
       10 BT-IVAL            BINARY-DOUBLE.
       10 BT-DVAL            FLOAT-LONG.
       10 BT-AUX             BINARY-LONG.
       10 BT-IVAL2           BINARY-DOUBLE.
       10 BT-DVAL2           FLOAT-LONG.
       10 BT-KIND            BINARY-LONG OCCURS 3 TIMES.
       10 BT-NUM             FLOAT-LONG OCCURS 3 TIMES.
    05 BT-CTX-COUNT         BINARY-LONG.
    05 BT-CTX-START         BINARY-LONG OCCURS 8 TIMES.
    05 BT-CURSOR            BINARY-LONG.
    05 BT-ERR-COUNT         BINARY-LONG.
    05 BT-ERR               OCCURS 4 TIMES.
       10 BT-ERR-KEY         PIC X(48).
       10 BT-ERR-ARGS        BINARY-LONG.
       10 BT-ERR-LEN1        BINARY-LONG.
       10 BT-ERR-ARG1        PIC X(64).
       10 BT-ERR-LEN2        BINARY-LONG.
       10 BT-ERR-ARG2        PIC X(64).
       10 BT-ERR-CURSOR      BINARY-LONG.
