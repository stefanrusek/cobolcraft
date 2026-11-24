*> The jigsaw assembly tables (docs/protocol/36-structures-2 sections 1.5, 3.5, 36-structures-3; core/src/struct-jigsaw.cob, struct-jig-pool.cob, struct-jig.cob). EXTERNAL, core-private.
*> STRUCT-JIGSAWS: the jigsaw records of a placed template (STRUCT-GET-JIGSAWS): JG-COUNT records in the order of the template's block list: the world position (the origin plus the rotated
*> template position), JG-STATE the rotated block state, JG-FRONT and JG-TOP the two directions of its orientation (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), JG-JOINT 1 aligned or 2
*> rollable (the default of a horizontal front is aligned, 1.5) and JG-TAG the row of its block entity tag in STRUCT-TPL-BE (TN-NAME, TN-POOL, TN-TARGET, TN-PRIO-PLACE, TN-PRIO-SELECT, TN-TEXT).
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
*> STRUCT-JIG-LIST: the jigsaws of an element at a position and rotation after the shuffle and the stable sort by selection priority (4.3), JW-TAG 0 for the synthetic jigsaw of a feature
*> element (name absent, pool and target empty, both priorities 0).
 78 JW-MAX                VALUE 128.
 01 STRUCT-JIG-LIST EXTERNAL.
    05 JW-COUNT             BINARY-LONG.
    05 JW-REC OCCURS 128 TIMES.
       10 JW-X              BINARY-LONG.
       10 JW-Y              BINARY-LONG.
       10 JW-Z              BINARY-LONG.
       10 JW-FRONT          BINARY-LONG.
       10 JW-TOP            BINARY-LONG.
       10 JW-JOINT          BINARY-LONG.
       10 JW-TAG            BINARY-LONG.
       10 JW-PLACE          BINARY-LONG.
       10 JW-SELECT         BINARY-LONG.
*> STRUCT-JIG-POOLS: the template pools read on demand (worldgen/template_pool, 36-3 3.2 and 3.3) and their elements. A pool (JP) has its raw entries in JN (JN-ELEM the element row, JN-WEIGHT),
*> JP-TOTAL the length of the expanded list, JP-FALLBACK the row of its fallback pool (row 1 is minecraft:empty: no entry, fallback itself), JP-MAXSIZE the cached getMaxSize (-1 unknown).
*> An element (JE): JE-KIND 1 single_pool_element, 2 legacy_single_pool_element, 3 list_pool_element (its sub-elements are the JS rows JE-SUB-FIRST on, JE-SUB-N of them), 4 feature_pool_element
*> (JE-FEATURE), 5 empty_pool_element (row 1); JE-PROJ 0 rigid, 1 terrain_matching; JE-LOC the template, JE-PROC the processor list key (spaces for none or an inline empty list).
 78 JP-MAX                VALUE 200.
 78 JN-MAX                VALUE 4096.
 78 JE-MAX                VALUE 2048.
 78 JS-MAX                VALUE 512.
 01 STRUCT-JIG-POOLS EXTERNAL.
    05 JP-COUNT             BINARY-LONG.
    05 JN-USED              BINARY-LONG.
    05 JE-COUNT             BINARY-LONG.
    05 JS-COUNT             BINARY-LONG.
    05 JP-REC OCCURS 200 TIMES.
       10 JP-KEY            PIC X(80).
       10 JP-STATUS         BINARY-LONG.
       10 JP-FALLBACK       BINARY-LONG.
       10 JP-FIRST          BINARY-LONG.
       10 JP-N              BINARY-LONG.
       10 JP-TOTAL          BINARY-LONG.
       10 JP-MAXSIZE        BINARY-LONG.
    05 JN-REC OCCURS 4096 TIMES.
       10 JN-ELEM           BINARY-LONG.
       10 JN-WEIGHT         BINARY-LONG.
    05 JS-ELEM              BINARY-LONG OCCURS 512 TIMES.
    05 JE-REC OCCURS 2048 TIMES.
       10 JE-KIND           BINARY-LONG.
       10 JE-PROJ           BINARY-LONG.
       10 JE-SUB-FIRST      BINARY-LONG.
       10 JE-SUB-N          BINARY-LONG.
       10 JE-LOC            PIC X(96).
       10 JE-PROC           PIC X(80).
       10 JE-FEATURE        PIC X(80).
*> STRUCT-JIG-TPLS: the jigsaw records of a template, found once (by template cache row, valid while JT-KEY is the row's TP-KEY): the template-local position, front, top, joint (1 aligned,
*> 2 rollable) and tag row of each, in block order.
 78 JX-MAX                VALUE 4096.
 01 STRUCT-JIG-TPLS EXTERNAL.
    05 JX-COUNT             BINARY-LONG.
    05 JT-REC OCCURS 256 TIMES.
       10 JT-KEY            PIC X(96).
       10 JT-FIRST          BINARY-LONG.
       10 JT-N              BINARY-LONG.
    05 JX-REC OCCURS 4096 TIMES.
       10 JX-X              BINARY-LONG.
       10 JX-Y              BINARY-LONG.
       10 JX-Z              BINARY-LONG.
       10 JX-FRONT          BINARY-LONG.
       10 JX-TOP            BINARY-LONG.
       10 JX-JOINT          BINARY-LONG.
       10 JX-TAG            BINARY-LONG.
*> STRUCT-JIG-STATE: JIG-GEN counts the JIG-RESETs (what a remembered start holds are rows of the pool tables).
*> JJ: the junctions of the start being built (JJ-OWNER the piece row): JJ-X, JJ-Y (source ground y), JJ-Z, JJ-DELTA, JJ-PROJ (the destination projection).
 78 JJ-MAX                VALUE 4096.
 01 STRUCT-JIG-STATE EXTERNAL.
    05 JIG-GEN              BINARY-LONG.
    05 JJ-COUNT             BINARY-LONG.
    05 JJ-REC OCCURS 4096 TIMES.
       10 JJ-OWNER          BINARY-LONG.
       10 JJ-X              BINARY-LONG.
       10 JJ-Y              BINARY-LONG.
       10 JJ-Z              BINARY-LONG.
       10 JJ-DELTA          BINARY-LONG.
       10 JJ-PROJ           BINARY-LONG.
*> STRUCT-JIG-ALIASES: the pool alias map of the start being built (36-3 7.2): JM-COUNT pairs, JM-DUP 1 when a resolution bound one alias twice (the game throws; no structure is made).
 78 JM-MAX                VALUE 32.
 01 STRUCT-JIG-ALIASES EXTERNAL.
    05 JM-COUNT             BINARY-LONG.
    05 JM-DUP               BINARY-LONG.
    05 JM-REC OCCURS 32 TIMES.
       10 JM-ALIAS          PIC X(80).
       10 JM-TARGET         PIC X(80).
*> STRUCT-JIG-OPTS: the entry point generateJigsaw of 36-3 section 15 (JIG-GENERATE, struct-36-3.cob). JO-AT 1 makes JIG-ASSEMBLE start at (JO-X, JO-Y, JO-Z) instead of at the minimum corner of the
*> chunk (the structure row it is given is then a scratch row filled by JIG-GENERATE, and the biome test is left out: the predicate of that entry point is always true); JO-KEEP 1 is keepJigsaws:
*> JIG-PROCS then leaves the jigsaw replacement processor out of the lists. Both are 0 outside that entry point.
 01 STRUCT-JIG-OPTS EXTERNAL.
    05 JO-AT                BINARY-LONG.
    05 JO-KEEP              BINARY-LONG.
    05 JO-X                 BINARY-LONG.
    05 JO-Y                 BINARY-LONG.
    05 JO-Z                 BINARY-LONG.
