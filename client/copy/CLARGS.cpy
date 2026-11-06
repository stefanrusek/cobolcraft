*> Argument records of the client (package-private; kept out of CLSTATE.cpy so a program can hold
*> them in WORKING-STORAGE while it receives CLIENT-STATE BY REFERENCE).
*> Command-line arguments as CL-MAIN collects them (ARGS-PARSE input; client-surface §1).
 01 CL-ARGS.
    05 AR-COUNT              BINARY-LONG.
    05 AR-ARG OCCURS 16 TIMES.
       10 AR-LENGTH          BINARY-LONG.
       10 AR-TEXT            PIC X(1024).

*> Arguments of a translated text (LANG-FORMAT: %s and %n$s placeholders, 08 §10.8).
 01 LANG-ARGS.
    05 LA-COUNT              BINARY-LONG.
    05 LA-ARG OCCURS 8 TIMES.
       10 LA-LENGTH          BINARY-LONG.
       10 LA-TEXT            PIC X(256).
