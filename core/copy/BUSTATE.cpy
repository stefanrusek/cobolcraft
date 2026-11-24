*> State of the block-update machinery (docs/protocol/29 sections 2 to 7), one EXTERNAL record the programs of
*> blockupd-29.cob share. BU-READY is 0 until BU-ENSURE sets the defaults (the chained-update limit 1,000,000 of 3.3).
*>
*> Hook rules (BU-RULE-ADD): the family documents' per-block overrides are rows of this table, not code. A row fires for
*> the hook of its kind when the block of the state the hook is about has the row's block id (-1 = every block):
*>   kind 1 onPlace, 2 affectNeighborsAfterRemoval, 3 neighborChanged   effect 1 = set the hook's position to BU-R-STATE with
*>                                                                    BU-R-FLAGS (a callback that replaces blocks)
*>   kind 4 updateShape                                                effect 2 = the new state is BU-R-STATE (0 = air)
*>   kind 7 scheduled block tick                                       effect 3 = schedule the same block again, delay BU-R-FLAGS
*>   kind 5 redstone wire marker, 6 comparator marker (no effect: asked by BU-MARKED)
*> BU-TRACE (while BU-TRACE-ON is 1) keeps one entry per hook call: a letter (P onPlace, R removal, N neighbour changed, S
*> shape update, T tick, G random tick, F fluid tick, E block event), x y z, the state and two more numbers, separated by spaces, entry ended by ";".
 78 BU-MAX-RULES                 VALUE 512.
 78 BU-QUEUE-SIZE                VALUE 8192.
 01 BU-STATE EXTERNAL.
    05 BU-READY                  BINARY-LONG.
    05 BU-TRACE-ON               BINARY-LONG.
    05 BU-TRACE-LENGTH           BINARY-LONG.
    05 BU-TRACE                  PIC X(16384).
    05 BU-RULE-COUNT             BINARY-LONG.
    05 BU-RULE OCCURS 512 TIMES.
       10 BU-R-KIND              BINARY-LONG.
       10 BU-R-BLOCK             BINARY-LONG.
       10 BU-R-EFFECT            BINARY-LONG.
       10 BU-R-STATE             BINARY-LONG.
       10 BU-R-FLAGS             BINARY-LONG.
    05 BU-CHAINED-LIMIT          BINARY-LONG.
    05 BU-COUNT                  BINARY-LONG.
    05 BU-SKIPPED                BINARY-LONG.
    05 BU-FIRST-SKIPPED-X        BINARY-LONG.
    05 BU-FIRST-SKIPPED-Y        BINARY-LONG.
    05 BU-FIRST-SKIPPED-Z        BINARY-LONG.
    05 BU-STACK-SIZE             BINARY-LONG.
    05 BU-ADDED-SIZE             BINARY-LONG.
    05 BU-STACK OCCURS 8192 TIMES.
       10 BU-S-KIND    BINARY-LONG.
       10 BU-S-DIM     BINARY-LONG.
       10 BU-S-X       BINARY-LONG.
       10 BU-S-Y       BINARY-LONG.
       10 BU-S-Z       BINARY-LONG.
       10 BU-S-BLOCK   BINARY-LONG.
       10 BU-S-SKIP    BINARY-LONG.
       10 BU-S-INDEX   BINARY-LONG.
       10 BU-S-DIR     BINARY-LONG.
       10 BU-S-NX      BINARY-LONG.
       10 BU-S-NY      BINARY-LONG.
       10 BU-S-NZ      BINARY-LONG.
       10 BU-S-STATE   BINARY-LONG.
       10 BU-S-FLAGS   BINARY-LONG.
       10 BU-S-BUDGET  BINARY-LONG.
       10 BU-S-MOVED   BINARY-LONG.
    05 BU-ADDED OCCURS 8192 TIMES.
       10 BU-A-KIND    BINARY-LONG.
       10 BU-A-DIM     BINARY-LONG.
       10 BU-A-X       BINARY-LONG.
       10 BU-A-Y       BINARY-LONG.
       10 BU-A-Z       BINARY-LONG.
       10 BU-A-BLOCK   BINARY-LONG.
       10 BU-A-SKIP    BINARY-LONG.
       10 BU-A-INDEX   BINARY-LONG.
       10 BU-A-DIR     BINARY-LONG.
       10 BU-A-NX      BINARY-LONG.
       10 BU-A-NY      BINARY-LONG.
       10 BU-A-NZ      BINARY-LONG.
       10 BU-A-STATE   BINARY-LONG.
       10 BU-A-FLAGS   BINARY-LONG.
       10 BU-A-BUDGET  BINARY-LONG.
       10 BU-A-MOVED   BINARY-LONG.
