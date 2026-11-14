*> The structure template cache and its loading scratch (core/src/struct-36-2-load.cob; docs/protocol/36-structures-2 sections 1 to 2). EXTERNAL, core-private.
*> A template (TP) is a size, the number of its palettes and, for each palette, the base of its run in the record pool (TB). A palette's run holds the block records in the
*> placement order of section 1.3 (full cubes, then others, then records with block entity data; each group by y, x, z), with the palette's state ids. The block entity tag, the
*> entity records and the jigsaw data are not kept (the generator cannot write a block entity; entities are counted only). TP-STATUS: 0 free, 1 loaded, 2 absent (no file or an
*> unreadable one), 3 unsupported (a size or a block count above the limits below, a record outside the size, a palette list over the limit).
 78 TP-MAX-TEMPLATES     VALUE 256.
 78 TP-MAX-PALETTES      VALUE 16.
 78 TP-POOL              VALUE 600000.
 78 TW-MAX-BLOCKS        VALUE 65536.
 78 TW-MAX-STATES        VALUE 1024.
 78 TW-GRID              VALUE 262144.
 01 STRUCT-TPL EXTERNAL.
    05 TP-COUNT             BINARY-LONG.
    05 TP-USED              BINARY-LONG.
    05 TP-ENTRY OCCURS 256 TIMES.
       10 TP-KEY            PIC X(96).
       10 TP-STATUS         BINARY-LONG.
       10 TP-SX             BINARY-LONG.
       10 TP-SY             BINARY-LONG.
       10 TP-SZ             BINARY-LONG.
       10 TP-PALETTES       BINARY-LONG.
       10 TP-BLOCKS         BINARY-LONG.
       10 TP-ENTITIES       BINARY-LONG.
       10 TP-BASE           BINARY-LONG OCCURS 16 TIMES.
    05 TB-REC OCCURS 600000 TIMES.
       10 TB-X              BINARY-SHORT.
       10 TB-Y              BINARY-SHORT.
       10 TB-Z              BINARY-SHORT.
       10 TB-NBT            BINARY-CHAR UNSIGNED.
       10 TB-STATE          BINARY-LONG.
*> Scratch of one load: the records as read (TW-IDX is the file's state index), the palettes read, and a grid of record chains used to sort one palette.
 01 STRUCT-TPL-WORK EXTERNAL.
    05 TW-BLOCK-COUNT       BINARY-LONG.
    05 TW-PAL-COUNT         BINARY-LONG.
    05 TW-PAL-STATES        BINARY-LONG OCCURS 16 TIMES.
    05 TW-PSTATE            BINARY-LONG OCCURS 16384 TIMES.
    05 TW-REC OCCURS 65536 TIMES.
       10 TW-X              BINARY-SHORT.
       10 TW-Y              BINARY-SHORT.
       10 TW-Z              BINARY-SHORT.
       10 TW-NBT            BINARY-CHAR UNSIGNED.
       10 TW-GROUP          BINARY-CHAR UNSIGNED.
       10 TW-IDX            BINARY-LONG.
       10 TW-NEXT           BINARY-LONG.
    05 TW-HEAD              BINARY-LONG OCCURS 262144 TIMES.
