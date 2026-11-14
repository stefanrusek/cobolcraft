*> The jigsaw records of a placed template (core/src/struct-jigsaw.cob STRUCT-GET-JIGSAWS; docs/protocol/36-structures-2 section 3.5, 36-structures-3 sections 3.5 and 4). EXTERNAL, core-private.
*> JG-COUNT records in the order of the template's block list: the world position (the origin plus the rotated template position), JG-STATE the rotated block state, JG-FRONT and JG-TOP the
*> two directions of its orientation (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), JG-JOINT 1 aligned or 2 rollable (the default of a horizontal front is aligned, 1.5) and JG-TAG the
*> row of its block entity tag in STRUCT-TPL-BE (TN-NAME, TN-POOL, TN-TARGET, TN-PRIO-PLACE, TN-PRIO-SELECT, TN-TEXT the final_state).
 78 JG-MAX                VALUE 256.
 01 STRUCT-JIGSAWS EXTERNAL.
    05 JG-COUNT             BINARY-LONG.
    05 JG-REC OCCURS 256 TIMES.
       10 JG-X              BINARY-LONG.
       10 JG-Y              BINARY-LONG.
       10 JG-Z              BINARY-LONG.
       10 JG-STATE          BINARY-LONG.
       10 JG-FRONT          BINARY-LONG.
       10 JG-TOP            BINARY-LONG.
       10 JG-JOINT          BINARY-LONG.
       10 JG-TAG            BINARY-LONG.
