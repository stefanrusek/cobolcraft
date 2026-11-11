*> The feature index lists of the decoration steps (core/src/feat-stage.cob FR-INDEX-BUILD). EXTERNAL. FI-COUNT(step + 1) placed feature ids per step in index order.
 01 FEAT-INDEX EXTERNAL.
    05 FI-STAMP             BINARY-LONG.
    05 FI-STEP OCCURS 11 TIMES.
       10 FI-COUNT          BINARY-LONG.
       10 FI-KEY            PIC X(80) OCCURS 1024 TIMES.
