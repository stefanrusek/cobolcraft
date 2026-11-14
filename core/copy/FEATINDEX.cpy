*> The feature index lists of the decoration steps (core/src/feat-stage.cob FR-INDEX-BUILD). EXTERNAL. FI-COUNT(step + 1) placed feature ids per step in index order.
 01 FEAT-INDEX EXTERNAL.
    05 FI-STAMP             BINARY-LONG.
*>  FI-GATE 1: the stage runs only the placed features of the supported families (core/src/feat-veg.cob FR-GATE: a table of id prefixes; set by WORLD-GEN-DATA-OPEN for a standard world); 0 runs every compiled one
    05 FI-GATE              BINARY-LONG.
    05 FI-STEP OCCURS 11 TIMES.
       10 FI-COUNT          BINARY-LONG.
       10 FI-KEY            PIC X(80) OCCURS 1024 TIMES.
