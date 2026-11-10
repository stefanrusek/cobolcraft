*> The ore features of the standard overworld (core/src/ores.cob; docs/protocol/11 sections 6 to 8). EXTERNAL.
*> OT-ROW: the placed features of 8.2 in the order they run (OT-IDX the feature index of 6.1, OT-STEP the decoration step, OT-MOD the
*> first modifier: 1 count OT-N, 2 count uniform 0..1, 3 rarity filter 1 in OT-N; OT-HKIND 1 uniform 2 triangle over OT-LO..OT-HI;
*> OT-BIOME the limit: 0 none, 1 emerald biomes, 2 badlands, 3 dripstone caves, 4 lush caves, 5 every biome but dripstone caves;
*> OT-SIZE and OT-AIR (percent: the discard chance on air exposure) of the configured feature; OT-KIND 1 the stone and deepslate
*> variants of OT-STONE and OT-DEEP, 2 the single block OT-STONE over the base stones).
*> OB-STATE: the blob being placed (7.1): the axis ends, the box, the block states of the six base stones (stone, granite, diorite, andesite, tuff, deepslate: OB-BASE) and of every row's ores (OB-RS1, OB-RS2, resolved on first use; OB-READY 0 until then), the placed count; OB-LIST 1 records the positions
*> of the whole blob in OB-POS instead of writing (the border test), OB-BITS the handled positions of the box.
 78 OT-MAX               VALUE 30.
 01 OT-TABLE EXTERNAL.
    05 OT-COUNT             BINARY-LONG.
    05 OT-ROW OCCURS 30 TIMES.
       10 OT-NAME           PIC X(24).
       10 OT-IDX            BINARY-LONG.
       10 OT-STEP           BINARY-LONG.
       10 OT-MOD            BINARY-LONG.
       10 OT-N              BINARY-LONG.
       10 OT-HKIND          BINARY-LONG.
       10 OT-LO             BINARY-LONG.
       10 OT-HI             BINARY-LONG.
       10 OT-BIOME          BINARY-LONG.
       10 OT-SIZE           BINARY-LONG.
       10 OT-AIR            BINARY-LONG.
       10 OT-KIND           BINARY-LONG.
       10 OT-STONE          PIC X(40).
       10 OT-DEEP           PIC X(40).
 01 OB-STATE EXTERNAL.
    05 OB-LIST              BINARY-LONG.
    05 OB-NPOS              BINARY-LONG.
    05 OB-PLACED            BINARY-LONG.
    05 OB-READY             BINARY-LONG.
    05 OB-BASE              BINARY-LONG OCCURS 6 TIMES.
    05 OB-RS1               BINARY-LONG OCCURS 30 TIMES.
    05 OB-RS2               BINARY-LONG OCCURS 30 TIMES.
    05 OB-X0                FLOAT-LONG.
    05 OB-X1                FLOAT-LONG.
    05 OB-Z0                FLOAT-LONG.
    05 OB-Z1                FLOAT-LONG.
    05 OB-Y0                BINARY-LONG.
    05 OB-Y1                BINARY-LONG.
    05 OB-START-X           BINARY-LONG.
    05 OB-START-Y           BINARY-LONG.
    05 OB-START-Z           BINARY-LONG.
    05 OB-WIDTH             BINARY-LONG.
    05 OB-HEIGHT            BINARY-LONG.
    05 OB-RR                BINARY-LONG.
    05 OB-POS-X             BINARY-LONG OCCURS 4000 TIMES.
    05 OB-POS-Y             BINARY-LONG OCCURS 4000 TIMES.
    05 OB-POS-Z             BINARY-LONG OCCURS 4000 TIMES.
    05 OB-BITS              PIC X(26000).
