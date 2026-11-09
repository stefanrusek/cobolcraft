*> The registry loader's working state, shared by the loader programs of registry.cob (EXTERNAL: the recursive
*> directory walk and the sort use one record). The elements of the registry being loaded are collected in
*> RS-ELEMENT in scan order, their file bytes appended to the payload buffer at RS-PAYLOAD-ADDR; the sort
*> orders RS-ORDER by element id (path first, then namespace; 23 section 1). Package-private.
 78 RS-MAX-ELEMENTS         VALUE 8192.
 01 RS-STATE EXTERNAL.
    05 RS-COUNT              BINARY-LONG.
    05 RS-ERRORS             BINARY-LONG.
    05 RS-MODE               BINARY-LONG.   *> 0 elements of a registry, 1 tag files of a registry
    05 RS-PAYLOAD-ADDR       USAGE POINTER.
    05 RS-PAYLOAD-CAPACITY   BINARY-LONG.
    05 RS-PAYLOAD-LENGTH     BINARY-LONG.
    05 RS-REGISTRY           PIC X(48).
    05 RS-NS                 PIC X(32).
    05 RS-ELEMENT OCCURS 8192 TIMES.
       10 RS-E-PATH          PIC X(64).
       10 RS-E-NS            PIC X(32).
       10 RS-E-OFFSET        BINARY-LONG.
       10 RS-E-LENGTH        BINARY-LONG.
    05 RS-ORDER              BINARY-LONG OCCURS 8192 TIMES.
