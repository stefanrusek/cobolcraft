*> Deferred light recompute (light.cob LIGHT-BATCH-*): while LB-DEPTH > 0, WORLD-SET-BLOCK only notes the chunk row it changed a block in; the
*> outermost LIGHT-BATCH-END then redoes the light of every noted change (LIGHT-BLOCK-CHANGED, in the order noted). A change beyond the 1024 that are kept
*> is redone at once.
 01 LIGHT-BATCH EXTERNAL.
    05 LB-DEPTH               BINARY-LONG.
    05 LB-COUNT               BINARY-LONG.
    05 LB-ROW                 BINARY-LONG OCCURS 64 TIMES.
    05 LB-CHANGES             BINARY-LONG.
    05 LB-CHANGE OCCURS 1024 TIMES.
       10 LB-CH-ROW           BINARY-LONG.
       10 LB-CH-X             BINARY-LONG.
       10 LB-CH-Y             BINARY-LONG.
       10 LB-CH-Z             BINARY-LONG.
