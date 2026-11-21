*> A parsed nbt_path (core/src/nbx-path.cob): up to 16 nodes. NP-KIND 1 root filter (the first node: {..}), 2 name, 3 name with a compound filter, 4 every list
*> element [], 5 list elements matching a compound [{..}], 6 one element by index [n] (negative: from the end). NP-FILTER is a tree node (kinds 1, 3, 5).
 01 NBX-PATH.
    05 NP-COUNT             BINARY-LONG.
    05 NP-ENTRY OCCURS 16 TIMES.
       10 NP-KIND              BINARY-LONG.
       10 NP-KLEN              BINARY-LONG.
       10 NP-KEY               PIC X(64).
       10 NP-INDEX             BINARY-LONG.
       10 NP-FILTER            BINARY-LONG.
