*> The structure template cache and its loading scratch (core/src/struct-36-2-load.cob; docs/protocol/36-structures-2 sections 1 to 2). EXTERNAL, core-private.
*> Block entity tags: TB-NBT and TW-NBT are 0 for a record without an nbt tag, else the index of its row in the tag table STRUCT-TPL-BE (TN-REC; row 1 is the empty tag that a rule
*> processor's block entity modifier gives a record, 8.5). A tag keeps the kind of the block entity (TN-KIND: 0 other, dropped by the generator; 1 a randomizable container,
*> TN-LOOT its loot table key or spaces; 2 a spawner, TN-TEXT its SpawnData.entity.id; 3 a structure block in DATA mode, TN-TEXT its metadata; 4 a jigsaw, TN-NAME, TN-POOL,
*> TN-TARGET, TN-JOINT (0 the default of the front direction, 1 aligned, 2 rollable), the two priorities and TN-TEXT the final_state text; 5 a structure block in another mode)
*> and nothing else of the tag (the items of a container, the text of a sign: the channel cannot carry them).
*> A template (TP) is a size, the number of its palettes and, for each palette, the base of its run in the record pool (TB). A palette's run holds the block records in the
*> placement order of section 1.3 (full cubes, then others, then records with block entity data; each group by y, x, z), with the palette's state ids. The block entity tag, the
*> entity records and the jigsaw data are not kept (the generator cannot write a block entity). The entity records are kept in the table STRUCT-TPL-ENT (below): a template's TP-ENT-N records from TP-ENT-BASE + 1, each with
*> its template-local position (TE-PX..), block position (TE-BX..), yaw and the compound of its nbt tag as the file stored it (TE-DATA, TE-LEN bytes with the End tag; a record whose compound is over
*> TE-NBT bytes or does not fit the table is counted in TP-ENTITIES but not kept, TE-LOST counts the ones the table could not hold). TP-STATUS: 0 free, 1 loaded, 2 absent (no file or an
*> unreadable one), 3 unsupported (a size or a block count above the limits below, a record outside the size, a palette list over the limit).
 78 TP-MAX-TEMPLATES     VALUE 256.
 78 TP-MAX-PALETTES      VALUE 16.
 78 TP-POOL              VALUE 600000.
 78 TW-MAX-BLOCKS        VALUE 65536.
 78 TW-MAX-STATES        VALUE 1024.
 78 TW-GRID              VALUE 262144.
 78 TN-MAX              VALUE 8192.
 78 TE-MAX              VALUE 1024.
 78 TE-NBT              VALUE 1344.
 01 STRUCT-TPL-BE EXTERNAL.
    05 TN-USED              BINARY-LONG.
    05 TN-REC OCCURS 8192 TIMES.
       10 TN-KIND           BINARY-LONG.
       10 TN-JOINT          BINARY-LONG.
       10 TN-PRIO-PLACE     BINARY-LONG.
       10 TN-PRIO-SELECT    BINARY-LONG.
       10 TN-LOOT           PIC X(48).
       10 TN-NAME           PIC X(48).
       10 TN-POOL           PIC X(80).
       10 TN-TARGET         PIC X(48).
       10 TN-TEXT           PIC X(96).
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
       10 TP-ENT-BASE       BINARY-LONG.
       10 TP-ENT-N          BINARY-LONG.
       10 TP-BASE           BINARY-LONG OCCURS 16 TIMES.
    05 TB-REC OCCURS 600000 TIMES.
       10 TB-X              BINARY-SHORT.
       10 TB-Y              BINARY-SHORT.
       10 TB-Z              BINARY-SHORT.
       10 TB-NBT            BINARY-LONG.
       10 TB-STATE          BINARY-LONG.
*> The entity records of the template cache (docs/protocol/36-structures-2 section 1.4): the position (pos), the block position (blockPos), the yaw of the stored Rotation (0 when it has none) and the nbt compound.
 01 STRUCT-TPL-ENT EXTERNAL.
    05 TE-USED              BINARY-LONG.
    05 TE-LOST              BINARY-LONG.
    05 TE-REC OCCURS 1024 TIMES.
       10 TE-PX             FLOAT-LONG.
       10 TE-PY             FLOAT-LONG.
       10 TE-PZ             FLOAT-LONG.
       10 TE-BX             BINARY-LONG.
       10 TE-BY             BINARY-LONG.
       10 TE-BZ             BINARY-LONG.
       10 TE-YAW            FLOAT-SHORT.
       10 TE-LEN            BINARY-LONG.
       10 TE-DATA           PIC X(1344).
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
       10 TW-NBT            BINARY-LONG.
       10 TW-GROUP          BINARY-CHAR UNSIGNED.
       10 TW-IDX            BINARY-LONG.
       10 TW-NEXT           BINARY-LONG.
    05 TW-HEAD              BINARY-LONG OCCURS 262144 TIMES.
