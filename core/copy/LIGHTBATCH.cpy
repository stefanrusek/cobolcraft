*> Deferred light recompute (light.cob LIGHT-BATCH-*): while LB-DEPTH > 0, WORLD-SET-BLOCK only notes the chunk row it changed a block in; the
*> outermost LIGHT-BATCH-END recomputes the light of every noted row once.
 01 LIGHT-BATCH EXTERNAL.
    05 LB-DEPTH               BINARY-LONG.
    05 LB-COUNT               BINARY-LONG.
    05 LB-ROW                 BINARY-LONG OCCURS 64 TIMES.
