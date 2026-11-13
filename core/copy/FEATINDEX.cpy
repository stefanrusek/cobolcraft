*> The feature index lists of the decoration steps (core/src/feat-stage.cob FR-INDEX-BUILD). EXTERNAL. FI-COUNT(step + 1) placed feature ids per step in index order.
 01 FEAT-INDEX EXTERNAL.
    05 FI-STAMP             BINARY-LONG.
*>  FI-ONLY 1: the stage runs only the placed features whose id starts with minecraft:trees_ (set by WORLD-GEN-DATA-OPEN for a standard world: the tree features of the biomes, not yet the rest of the vegetation); 0 runs every supported one
    05 FI-ONLY              BINARY-LONG.
    05 FI-STEP OCCURS 11 TIMES.
       10 FI-COUNT          BINARY-LONG.
       10 FI-KEY            PIC X(80) OCCURS 1024 TIMES.
