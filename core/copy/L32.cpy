*> The state of the light engine of docs/protocol/32-light-engine.md (core/src/light-32*.cob, programs L32-*): one EXTERNAL record.
*> The world is a sliding window of 6 x 6 chunk columns: chunk (x, z) lives in slot c = EN-SLOTMAP(((z + 1) mod 6) * 6 + (x + 1) mod 6 + 1), 1 to 36 (the
*> slots of the default window, chunks -1 to 2, keep the numbers c = (z + 1) * 4 + x + 2 of the first engine, the others follow), and owns it while EN-OWN-X / EN-OWN-Z of the slot name it (L32-CLAIM-CHUNK
*> moves a slot to another chunk and clears it; a cell of a chunk that does not own its slot is outside the window). Six columns hold the 5 x 5 chunks around a chunk, which is what a
*> chunk's light and that of its neighbours need.
*> Engine state ids 0 (air) and 1 (bedrock, the state of a cell outside the window) are presets; the registry's block state s is engine state s + 2
*> (EN-ST index id + 1, loaded by L32-LOAD-REGISTRY) except the air states (EN-ISAIR index s + 1), which are engine state 0 (L32-ENGINE-STATE).
*> A column has EN-NS block sections (section Y EN-MINSEC upwards; default 4 sections from 0, at most 24) and EN-NL = EN-NS + 2 light sections
*> (section Y EN-LOWL = EN-MINSEC - 1 upwards), section id = (c - 1) * EN-NL + (section Y - EN-LOWL) + 1, at most 936 (L32-SET-DIMENSION sets them).
*> EN-PAST-INIT is 1 for a chunk whose generation status is at or after INITIALIZE_LIGHT (8.1). Layer 1 is the block-light storage and layer 2 the sky-light storage (section 6), each with its own state bytes, working map,
*> published map and queued layers (a layer is 2048 bytes of nibbles). Chunk states are BINARY-SHORT ids of the state table.
 01 L32-ENGINE EXTERNAL.
    05 EN-SKY-ON               BINARY-LONG.
    05 EN-NS                   BINARY-LONG.
    05 EN-MINSEC               BINARY-LONG.
    05 EN-NL                   BINARY-LONG.
    05 EN-LOWL                 BINARY-LONG.
    05 EN-MINY                 BINARY-LONG.
    05 EN-SLOTMAP              BINARY-LONG OCCURS 36 TIMES.
*>  L32-LOCATE's tables and memo: EN-TL16 the low four bits of a byte (the local coordinate of a coordinate's low byte), EN-T256 and EN-T16 the multiples of 256 and 16,
*>  EN-SYTAB the section index (from the lowest light section) of a Y offset from the bottom of it, EN-LOWY / EN-NLY the Y of the bottom of the light sections and their height,
*>  EN-M-* the last chunk column found (valid until a slot changes owner).
    05 EN-TL16                 BINARY-LONG OCCURS 256 TIMES.
    05 EN-T256                 BINARY-LONG OCCURS 16 TIMES.
    05 EN-T16                  BINARY-LONG OCCURS 16 TIMES.
    05 EN-SYTAB                BINARY-LONG OCCURS 416 TIMES.
    05 EN-LOWY                 BINARY-LONG.
    05 EN-NLY                  BINARY-LONG.
    05 EN-M-VALID              BINARY-LONG.
    05 EN-M-OX                 BINARY-LONG.
    05 EN-M-OZ                 BINARY-LONG.
    05 EN-M-COL                BINARY-LONG.
    05 EN-OWN-X                BINARY-LONG OCCURS 36 TIMES.
    05 EN-OWN-Z                BINARY-LONG OCCURS 36 TIMES.
    05 EN-STATES.
       10 EN-ST                OCCURS 40002 TIMES.
          15 EN-EMIT           BINARY-LONG.
          15 EN-DAMP           BINARY-LONG.
          15 EN-OCC            BINARY-LONG.
          15 EN-USE            BINARY-LONG.
          15 EN-FACE           BINARY-LONG OCCURS 6 TIMES.
    05 EN-AIRS.
       10 EN-ISAIR             BINARY-CHAR UNSIGNED OCCURS 40000 TIMES.
    05 EN-AVAIL                BINARY-LONG OCCURS 36 TIMES.
    05 EN-PAST-INIT            BINARY-LONG OCCURS 36 TIMES.
    05 EN-LIGHT-CORRECT        BINARY-LONG OCCURS 36 TIMES.
    05 EN-EMPTYNOTE            BINARY-LONG OCCURS 936 TIMES.
    05 EN-TK-N                 BINARY-LONG.
    05 EN-TK                   OCCURS 4096 TIMES.
       10 TK-PHASE             BINARY-LONG.
       10 TK-KIND              BINARY-LONG.
       10 TK-A                 BINARY-LONG.
       10 TK-B                 BINARY-LONG.
       10 TK-C                 BINARY-LONG.
       10 TK-D                 BINARY-LONG.
       10 TK-E                 BINARY-LONG.
    05 EN-CT-N                 BINARY-LONG.
    05 EN-CT                   OCCURS 2048 TIMES.
       10 CT-KIND              BINARY-LONG.
       10 CT-CX                BINARY-LONG.
       10 CT-CZ                BINARY-LONG.
    05 EN-NONAIR               BINARY-LONG OCCURS 864 TIMES.
    05 EN-LOW                  OCCURS 36 TIMES.
       10 EN-LS                BINARY-LONG OCCURS 256 TIMES.
    05 EN-DIRTY                BINARY-LONG OCCURS 936 TIMES.
    05 EN-LY                   OCCURS 2 TIMES.
       10 LY-STATE             BINARY-LONG OCCURS 936 TIMES.
       10 LY-WP                BINARY-LONG OCCURS 936 TIMES.
       10 LY-VP                BINARY-LONG OCCURS 936 TIMES.
       10 LY-QP                BINARY-LONG OCCURS 936 TIMES.
       10 LY-PR                BINARY-LONG OCCURS 936 TIMES.
       10 LY-CH                BINARY-LONG OCCURS 936 TIMES.
       10 LY-AF                BINARY-LONG OCCURS 936 TIMES.
       10 LY-ON                BINARY-LONG OCCURS 36 TIMES.
       10 LY-RETAIN            BINARY-LONG OCCURS 36 TIMES.
       10 LY-TOP               BINARY-LONG OCCURS 36 TIMES.
       10 LY-TOPSET            BINARY-LONG OCCURS 36 TIMES.
       10 LY-NOTIFY            BINARY-LONG OCCURS 936 TIMES.
       10 LY-VTOP              BINARY-LONG OCCURS 36 TIMES.
       10 LY-VTOPSET           BINARY-LONG OCCURS 36 TIMES.
       10 LY-VLOWEST           BINARY-LONG.
       10 LY-INCONS            BINARY-LONG.
       10 LY-LOWEST            BINARY-LONG.
       10 LY-WD                OCCURS 936 TIMES.
          15 LY-WB             BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
       10 LY-VD                OCCURS 936 TIMES.
          15 LY-VB             BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
       10 LY-QD                OCCURS 936 TIMES.
          15 LY-QB             BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
    05 EN-QU                   OCCURS 2 TIMES.
       10 QU-CK-N              BINARY-LONG.
       10 QU-CK                OCCURS 4096 TIMES.
          15 QU-CKX            BINARY-LONG.
          15 QU-CKY            BINARY-LONG.
          15 QU-CKZ            BINARY-LONG.
       10 QU-INC-HEAD          BINARY-LONG.
       10 QU-INC-TAIL          BINARY-LONG.
       10 QU-INC               OCCURS 50000 TIMES.
          15 QU-INC-X          BINARY-LONG.
          15 QU-INC-Y          BINARY-LONG.
          15 QU-INC-Z          BINARY-LONG.
          15 QU-INC-E          BINARY-LONG.
       10 QU-DEC-HEAD          BINARY-LONG.
       10 QU-DEC-TAIL          BINARY-LONG.
       10 QU-DEC               OCCURS 50000 TIMES.
          15 QU-DEC-X          BINARY-LONG.
          15 QU-DEC-Y          BINARY-LONG.
          15 QU-DEC-Z          BINARY-LONG.
          15 QU-DEC-E          BINARY-LONG.
    05 EN-BLKS.
       10 EN-BLK             BINARY-SHORT UNSIGNED OCCURS 3538944 TIMES.
    05 EN-BLK-X REDEFINES EN-BLKS PIC X(7077888).
