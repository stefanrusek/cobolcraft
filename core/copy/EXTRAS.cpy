*> The keys of a saved entity or block entity that the core does not model (docs/protocol/07 section 10.7), kept from the load
*> to the next save in a world of the 26.3 layout (CW-LAYOUT 1): the whole compound payload as the file had it (children and
*> the End tag), per tracker row (EX-E-*, as CORE-ENTITIES) and per block entity index (EX-B-*, as CORE-BE). A length of 0
*> means nothing is kept (a compound longer than EX-CAP is not kept). EXTRA-CAPTURE fills, EXTRA-APPEND writes back.
 78 EX-CAP                VALUE 2048.
 01 CORE-EXTRA EXTERNAL.
    05 EX-ENTITY OCCURS 1024 TIMES.
       10 EX-E-LEN          BINARY-LONG.
       10 EX-E-DATA         PIC X(2048).
    05 EX-BE OCCURS 512 TIMES.
       10 EX-B-LEN          BINARY-LONG.
       10 EX-B-DATA         PIC X(2048).
