*> The jigsaw structure fields the assembler of 36-3 did not read before 36-10 (docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md sections 2.1, 2.2 and 2.6; core/src/struct-jig-alias.cob).
*> EXTERNAL, core-private, indexed like SD-STRUCT (STRUCTDATA.cpy). Per structure: SDA-START the start_jigsaw_name (spaces: absent), SDA-Y-KIND 0 the absolute start height (SDT-JIG-Y) or 1 a uniform provider
*> of SDA-Y-MIN to SDA-Y-MAX inclusive (one nextInt draw), SDA-AL-FIRST and SDA-AL-N the run of pool_aliases bindings (rows of SDA-BIND). A binding: SDB-KIND 1 direct (SDB-ALIAS, SDB-TARGET), 2 random
*> (SDB-ALIAS and the weighted targets SDO-WEIGHT, SDO-TARGET of SDA-OPT rows SDB-OPT-FIRST, SDB-OPT-N), 3 random_group (the weighted groups are SDA-OPT rows of SDB-OPT-N, each with the run of its bindings:
*> SDO-SUB-FIRST, SDO-SUB-N rows of SDA-BIND). SDA-USED and SDA-OPT-USED count the rows in use.
 78 SDA-MAX-BINDS         VALUE 128.
 78 SDA-MAX-OPTS          VALUE 256.
 01 STRUCT-ALIASES EXTERNAL.
    05 SDA-USED             BINARY-LONG.
    05 SDA-OPT-USED         BINARY-LONG.
    05 SDA-STRUCT OCCURS 128 TIMES.
       10 SDA-START         PIC X(80).
       10 SDA-Y-KIND        BINARY-LONG.
       10 SDA-Y-MIN         BINARY-LONG.
       10 SDA-Y-MAX         BINARY-LONG.
       10 SDA-AL-FIRST      BINARY-LONG.
       10 SDA-AL-N          BINARY-LONG.
    05 SDA-BIND OCCURS 128 TIMES.
       10 SDB-KIND          BINARY-LONG.
       10 SDB-ALIAS         PIC X(80).
       10 SDB-TARGET        PIC X(80).
       10 SDB-OPT-FIRST     BINARY-LONG.
       10 SDB-OPT-N         BINARY-LONG.
    05 SDA-OPT OCCURS 256 TIMES.
       10 SDO-WEIGHT        BINARY-LONG.
       10 SDO-TARGET        PIC X(80).
       10 SDO-SUB-FIRST     BINARY-LONG.
       10 SDO-SUB-N         BINARY-LONG.
