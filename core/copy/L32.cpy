*> The state of the light engine of docs/protocol/32-light-engine.md (core/src/light-32*.cob, programs L32-*): one EXTERNAL record.
*> The world is a window of 4 x 4 chunks (chunk x and z -1 to 2; column c = (z + 1) * 4 + x + 1 + 1, 1 to 16) of 4 block sections
*> (Y 0 to 63); a column has 6 light sections (section Y -1 to 4, index 1 to 6), section id = (c - 1) * 6 + index, 1 to 96.
*> Layer 1 is the block-light storage and layer 2 the sky-light storage (section 6), each with its own state bytes, working map,
*> published map and queued layers (a layer is 2048 bytes of nibbles). Chunk states are BINARY-SHORT ids of the state table.
 01 L32-ENGINE EXTERNAL.
    05 EN-SKY-ON               BINARY-LONG.
    05 EN-ST                   OCCURS 64 TIMES.
       10 EN-EMIT              BINARY-LONG.
       10 EN-DAMP              BINARY-LONG.
       10 EN-OCC               BINARY-LONG.
       10 EN-USE               BINARY-LONG.
       10 EN-FACE              BINARY-LONG OCCURS 6 TIMES.
    05 EN-AVAIL                BINARY-LONG OCCURS 16 TIMES.
    05 EN-PROTO-LIT            BINARY-LONG OCCURS 16 TIMES.
    05 EN-NONAIR               BINARY-LONG OCCURS 64 TIMES.
    05 EN-LOW                  OCCURS 16 TIMES.
       10 EN-LS                BINARY-LONG OCCURS 256 TIMES.
    05 EN-DIRTY                BINARY-LONG OCCURS 96 TIMES.
    05 EN-LY                   OCCURS 2 TIMES.
       10 LY-STATE             BINARY-LONG OCCURS 96 TIMES.
       10 LY-WP                BINARY-LONG OCCURS 96 TIMES.
       10 LY-VP                BINARY-LONG OCCURS 96 TIMES.
       10 LY-QP                BINARY-LONG OCCURS 96 TIMES.
       10 LY-PR                BINARY-LONG OCCURS 96 TIMES.
       10 LY-CH                BINARY-LONG OCCURS 96 TIMES.
       10 LY-AF                BINARY-LONG OCCURS 96 TIMES.
       10 LY-ON                BINARY-LONG OCCURS 16 TIMES.
       10 LY-RETAIN            BINARY-LONG OCCURS 16 TIMES.
       10 LY-TOP               BINARY-LONG OCCURS 16 TIMES.
       10 LY-TOPSET            BINARY-LONG OCCURS 16 TIMES.
       10 LY-NOTIFY            BINARY-LONG OCCURS 96 TIMES.
       10 LY-VTOP              BINARY-LONG OCCURS 16 TIMES.
       10 LY-VTOPSET           BINARY-LONG OCCURS 16 TIMES.
       10 LY-VLOWEST           BINARY-LONG.
       10 LY-INCONS            BINARY-LONG.
       10 LY-LOWEST            BINARY-LONG.
       10 LY-WD                OCCURS 96 TIMES.
          15 LY-WB             BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
       10 LY-VD                OCCURS 96 TIMES.
          15 LY-VB             BINARY-CHAR UNSIGNED OCCURS 2048 TIMES.
       10 LY-QD                OCCURS 96 TIMES.
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
    05 EN-BLK                  BINARY-SHORT UNSIGNED OCCURS 262144 TIMES.
