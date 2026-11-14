*> The node memo of the density function evaluator (core/src/density.cob, DENSITY-NODE). EXTERNAL.
*> The value of a node at a position is a pure function of the node, the position, the noise store and the content, unless the
*> evaluation reaches a grid or blend node (DM-IMPURE). Each node keeps its last evaluation: the position, the value and whether
*> the value read y (DM-UY; a node that did not read y is a hit for every y of its column). DM-USES-Y and DM-IMPURE are the
*> flags of the evaluation in progress, folded into the parent. An entry is valid while DM-STAMP is the content generation
*> (WG-LOAD-GEN) plus the noise generation (NZ-GEN) plus 1; every load or reset raises one of them, a never written entry holds 0.
 78 DM-SIZE               VALUE 32768.
 01 DM-STORE EXTERNAL.
    05 DM-USES-Y            BINARY-LONG.
    05 DM-IMPURE            BINARY-LONG.
    05 DM-ENTRY OCCURS 32768 TIMES.
       10 DM-STAMP          BINARY-LONG.
       10 DM-X              BINARY-LONG.
       10 DM-Y              BINARY-LONG.
       10 DM-Z              BINARY-LONG.
       10 DM-UY             BINARY-LONG.
       10 DM-RES            FLOAT-LONG.
*> The root a reference node (type 0) resolved to, valid while DM-REF-STAMP is the stamp above: WG-FIND scans every function by key.
       10 DM-REF-STAMP      BINARY-LONG.
       10 DM-REF            BINARY-LONG.
