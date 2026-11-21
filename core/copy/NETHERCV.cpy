*> The state of the Nether cave carver (core/src/nether-37-4b.cob; docs/protocol/37-nether-4 section 6). EXTERNAL: the target chunk, the float32 constants
*> (set by NETHER-CV-SETUP), the parameters drawn for the cave and tunnel being walked (so that a test can read them) and the carving mask of the
*> target chunk: one byte per position, "1" when marked, index (y - 1) + (z + 16 x) * 120 + 1 for y 1 to 120 (mask lowest y minGenY + 1, highest
*> y minGenY + genDepth - 1 - 7).
 01 NETHER-CV EXTERNAL.
    05 NC-READY             BINARY-LONG.
    05 NC-CX                BINARY-LONG.
    05 NC-CZ                BINARY-LONG.
    05 NC-PI                FLOAT-LONG.
    05 NC-TWO-PI            FLOAT-LONG.
    05 NC-HALF-PI           FLOAT-LONG.
    05 NC-K092              FLOAT-LONG.
    05 NC-K07               FLOAT-LONG.
    05 NC-K01               FLOAT-LONG.
    05 NC-K09               FLOAT-LONG.
    05 NC-K075              FLOAT-LONG.
    05 NC-FLOOR             FLOAT-LONG.
    05 NC-PROB              FLOAT-LONG.
    05 NC-ROOMV             FLOAT-LONG.
    05 NC-HALF              FLOAT-LONG.
    05 NC-ONE               FLOAT-LONG.
    05 NC-TWO               FLOAT-LONG.
    05 NC-THREE             FLOAT-LONG.
    05 NC-FOUR              FLOAT-LONG.
    05 NC-FIVE              FLOAT-LONG.
    05 NC-SIX               FLOAT-LONG.
    05 NC-SIXTEEN           FLOAT-LONG.
    05 NC-ONE-HALF          FLOAT-LONG.
    05 NC-ZERO              FLOAT-LONG.
    05 NC-CAVE-X            BINARY-LONG.
    05 NC-CAVE-Y            BINARY-LONG.
    05 NC-CAVE-Z            BINARY-LONG.
    05 NC-CAVE-ROOM         BINARY-LONG.
    05 NC-CAVE-ROOMR        FLOAT-LONG.
    05 NC-CAVE-TUNNELS      BINARY-LONG.
    05 NC-TUN-YAW           FLOAT-LONG.
    05 NC-TUN-PITCH         FLOAT-LONG.
    05 NC-TUN-THICK         FLOAT-LONG.
    05 NC-TUN-STEPS         BINARY-LONG.
    05 NC-TUN-SEED          BINARY-DOUBLE UNSIGNED.
    05 NC-MASK              PIC X(30720).
