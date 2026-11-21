*> The /locate structure searches that are carried on from game tick to game tick (docs/design: no command may stall the game frame; core/src/cmd-locate-async.cob). EXTERNAL, core-private.
*> LQ-DIRECT 1 while CMD-RUN-PACKET runs the line of a player that begins with `locate` (the one case a search may be put off: a line nested in execute or a function, and the console, wait for their answer);
*> LQ-SLICE the CPU time in microseconds one tick spends on the searches (0: 10000). A search (LQ-USED 1) belongs to a player row and the entity id the player had (a player who left, or whose row another
*> player took, drops it); LQ-PHASE 0 setup, 1 concentric rings, 2 the random_spread sets, 3 the ring walk (LQ-RING, the set LQ-SI of LQ-SPREAD, the cell cursor LQ-CI LQ-CJ, LQ-ANSWERED 1 once a set answered
*> in the ring); LQ-FOUND, LQ-X, LQ-Z, LQ-D2 the best answer so far; LQ-TEXT the identifier as the command prints it; LQ-TICKS the ticks the search has used.
 78 LQ-MAX               VALUE 8.
 01 LOCATE-QUEUE EXTERNAL.
    05 LQ-DIRECT            BINARY-LONG.
    05 LQ-SLICE             BINARY-LONG.
    05 LQ-ENTRY OCCURS 8 TIMES.
       10 LQ-USED           BINARY-LONG.
       10 LQ-SENDER         BINARY-LONG.
       10 LQ-ENTITY         BINARY-LONG.
       10 LQ-KIND           BINARY-LONG.
       10 LQ-ID             PIC X(80).
       10 LQ-TEXT           PIC X(112).
       10 LQ-TEXT-LENGTH    BINARY-LONG.
       10 LQ-SX             BINARY-LONG.
       10 LQ-SZ             BINARY-LONG.
       10 LQ-SEED           BINARY-DOUBLE.
       10 LQ-PHASE          BINARY-LONG.
       10 LQ-RING           BINARY-LONG.
       10 LQ-SI             BINARY-LONG.
       10 LQ-CI             BINARY-LONG.
       10 LQ-CJ             BINARY-LONG.
       10 LQ-ANSWERED       BINARY-LONG.
       10 LQ-FOUND          BINARY-LONG.
       10 LQ-X              BINARY-LONG.
       10 LQ-Z              BINARY-LONG.
       10 LQ-D2             BINARY-DOUBLE.
       10 LQ-SPREAD-COUNT   BINARY-LONG.
       10 LQ-SPREAD.
          15 LQ-SPREAD-SET  BINARY-LONG OCCURS 64 TIMES.
       10 LQ-TICKS          BINARY-LONG.
