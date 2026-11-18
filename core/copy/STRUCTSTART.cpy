*> The StructureStart records with their pieces and the chunk reference sets (docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 6.7, 7.1, 7.4, 7.5; core/src/struct-start.cob). EXTERNAL,
*> core-private. A start is the structure row of SD-STRUCT (STRUCTDATA.cpy), the chunk that holds it (SST-CX, SST-CZ), its references count (5.6: canBeReferenced is references < 1) and a run of SST-PIECE rows
*> (SST-FIRST, SST-N); a start is valid when it has a piece. A piece keeps the base fields of 6.1 (SPC-TYPE the registry id of 2.4 or the builder's own type number when the piece type has no registry name,
*> SPC-ORIENT -1 or the 2D data value of 6.7, SPC-DEPTH the genDepth, the box) and for a jigsaw piece SPC-JIG 1 (rigid) or 2 (terrain_matching), SPC-GROUND the ground level delta and its junctions (SPC-J-FIRST,
*> SPC-J-N rows of SST-JUNC: source x, ground y, z). A reference is the set entry of 7.1: chunk C (SSR-CX, SSR-CZ) is reached by the start of SSR-STRUCT held by chunk S (SSR-SX, SSR-SZ), in insertion order.
*> The store is a working set: a full table is emptied and refilled (the starts are a pure function of the seed, so a lost start is rebuilt by STRUCT-DECORATE).
 78 SST-MAX-STARTS        VALUE 512.
 78 SST-MAX-PIECES        VALUE 4096.
 78 SST-MAX-JUNC          VALUE 2048.
 78 SST-MAX-REFS          VALUE 2048.
 01 STRUCT-STORE EXTERNAL.
    05 SST-COUNT            BINARY-LONG.
    05 SST-PIECE-COUNT      BINARY-LONG.
    05 SST-JUNC-COUNT       BINARY-LONG.
    05 SST-REF-COUNT        BINARY-LONG.
    05 SST-LOST             BINARY-LONG.
*>  the world seed and the structure data epoch the stored starts belong to (STRUCT-STORE-SYNC empties the store when either changes)
    05 SST-SEED             BINARY-DOUBLE UNSIGNED.
    05 SST-EPOCH            BINARY-LONG.
    05 SST-START OCCURS 512 TIMES.
       10 SST-STRUCT        BINARY-LONG.
       10 SST-CX            BINARY-LONG.
       10 SST-CZ            BINARY-LONG.
       10 SST-REFS          BINARY-LONG.
       10 SST-FIRST         BINARY-LONG.
       10 SST-N             BINARY-LONG.
    05 SST-PIECE OCCURS 4096 TIMES.
       10 SPC-TYPE          BINARY-LONG.
       10 SPC-ORIENT        BINARY-LONG.
       10 SPC-DEPTH         BINARY-LONG.
       10 SPC-JIG           BINARY-LONG.
       10 SPC-GROUND        BINARY-LONG.
       10 SPC-J-FIRST       BINARY-LONG.
       10 SPC-J-N           BINARY-LONG.
       10 SPC-X0            BINARY-LONG.
       10 SPC-Y0            BINARY-LONG.
       10 SPC-Z0            BINARY-LONG.
       10 SPC-X1            BINARY-LONG.
       10 SPC-Y1            BINARY-LONG.
       10 SPC-Z1            BINARY-LONG.
    05 SST-JUNC OCCURS 2048 TIMES.
       10 SJ-X              BINARY-LONG.
       10 SJ-Y              BINARY-LONG.
       10 SJ-Z              BINARY-LONG.
    05 SST-REF OCCURS 2048 TIMES.
       10 SSR-CX            BINARY-LONG.
       10 SSR-CZ            BINARY-LONG.
       10 SSR-STRUCT        BINARY-LONG.
       10 SSR-SX            BINARY-LONG.
       10 SSR-SZ            BINARY-LONG.
*> the list of starts a query returns (STRUCT-STARTS-FOR): up to 64 start rows
 78 SST-LIST-MAX          VALUE 64.
