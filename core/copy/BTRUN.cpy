*> The ticks one drain of a scheduled-tick queue collected (BT-COLLECT, 29 section 4.3): count, then for each the identity and position, in the order
*> they run.
 01 BT-RUN-LIST.
    05 BT-R-COUNT                BINARY-LONG.
    05 BT-R OCCURS 32768 TIMES.
       10 BT-R-ID                BINARY-LONG.
       10 BT-R-X                 BINARY-LONG.
       10 BT-R-Y                 BINARY-LONG.
       10 BT-R-Z                 BINARY-LONG.
