*> The in-memory NBT value tree (core/src/nbx-tree.cob, nbx-snbt.cob, nbx-path.cob): one pool of nodes shared by every tree (the storage of /data
*> and the trees of one command). A node is an NBT tag (NX-TYPE 1 byte, 2 short, 3 int, 4 long, 5 float, 6 double, 7 byte array, 8 string, 9 list,
*> 10 compound, 11 int array, 12 long array); the children of a compound, list and array are chained through NX-FIRST / NX-NEXT (a compound entry has
*> its name in NX-KEY; the elements of an array are nodes of type 1, 3 or 4). Integers are in NX-INT, floats and doubles in NX-DBL, a string in NX-STR
*> (at most 256 bytes) with its byte length NX-SLEN. Node 0 is "none"; NX-SINK is the node handed out when the pool is full (NX-FULL is then 1, the
*> command fails with cobolcraft.data.too_large and the caller frees its trees). NX-STORAGE holds the command storage: one compound per namespaced id.
 78 NX-MAX                VALUE 6000.
 78 NX-SINK               VALUE 6001.
 78 NX-STORAGE-MAX        VALUE 32.
 01 NBX-POOL EXTERNAL.
    05 NX-TOP               BINARY-LONG.
    05 NX-FREE-HEAD         BINARY-LONG.
    05 NX-FULL              BINARY-LONG.
    05 NX-STORAGE-COUNT     BINARY-LONG.
    05 NX-STORAGE-ENTRY OCCURS 32 TIMES.
       10 NX-ST-USED           BINARY-LONG.
       10 NX-ST-KLEN           BINARY-LONG.
       10 NX-ST-KEY            PIC X(64).
       10 NX-ST-ROOT           BINARY-LONG.
    05 NX-NODE OCCURS 6001 TIMES.
       10 NX-TYPE              BINARY-LONG.
       10 NX-NEXT              BINARY-LONG.
       10 NX-FIRST             BINARY-LONG.
       10 NX-LAST              BINARY-LONG.
       10 NX-PARENT            BINARY-LONG.
       10 NX-COUNT             BINARY-LONG.
       10 NX-KLEN              BINARY-LONG.
       10 NX-KEY               PIC X(64).
       10 NX-SLEN              BINARY-LONG.
       10 NX-INT               BINARY-DOUBLE.
       10 NX-DBL               FLOAT-LONG.
       10 NX-STR               PIC X(256).
