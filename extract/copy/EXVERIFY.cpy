*> State of --verify (22 §7.6), shared by EX-VERIFY and the programs it calls. EXTERNAL; package-private.
*> The index text is read whole (at most EXV-CAPACITY bytes, assumption A6); EXV-SLOT is a hash table of its paths:
*> the 1-based start and the length of each path in EXV-INDEX (start 0 = empty slot).
 78 EXV-CAPACITY           VALUE 16777216.
 78 EXV-SLOTS              VALUE 131072.
 01 EX-VFY EXTERNAL.
    05 EXV-LENGTH           BINARY-LONG.
    05 EXV-LINES            BINARY-LONG.
    05 EXV-PROBLEMS         BINARY-LONG.
    05 EXV-FIRST            PIC X(1500).
    05 EXV-SLOT-AREA.
       10 EXV-SLOT          OCCURS 131072 TIMES.
          15 EXV-START      BINARY-LONG.
          15 EXV-PATH-LENGTH BINARY-LONG.
    05 EXV-INDEX            PIC X(16777216).
