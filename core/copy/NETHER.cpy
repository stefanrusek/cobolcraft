*> The state of the Nether generator (core/src/nether-37-2.cob, nether-37-3.cob, nether-37-4.cob; docs/protocol/37-nether-2 to 4).
*> EXTERNAL. The legacy (Java LCG) factory seed F of the master positional factory P (37-2 section 4.2), the handles of the noises in
*> the noise store (NOISE.cpy; NH-GEN is the NZ-GEN they were built for: a NOISE-RESET invalidates them), the blended 3D noise (37-2
*> section 5.2), the block states and biome ids the generator places, the 5 x 17 x 5 corner values of the chunk being made
*> (37-2 section 6.1, index ((i * 5 + k) * 17 + j) + 1 for corner x i, corner z k, corner row j), the 128 densities of one
*> column, the biome ring of the chunk (37-3: quart cells x from 4 cx - 1 to 4 cx + 4, z likewise, index (z cell * 6 + x cell) + 1)
*> and a one-column cache of the surface-rule noises (37-4 section 4.1).
 01 NETHER-STATE EXTERNAL.
    05 NH-READY             BINARY-LONG.
    05 NH-GEN               BINARY-LONG.
    05 NH-SEED              BINARY-DOUBLE UNSIGNED.
    05 NH-FS                BINARY-DOUBLE UNSIGNED.
    05 NH-FLOOR-FS          BINARY-DOUBLE UNSIGNED.
    05 NH-ROOF-FS           BINARY-DOUBLE UNSIGNED.
    05 NH-ZOOM-SEED         BINARY-DOUBLE UNSIGNED.
    05 NH-H-TEMP            BINARY-LONG.
    05 NH-H-VEG             BINARY-LONG.
    05 NH-H-MIN             BINARY-LONG.
    05 NH-H-MAX             BINARY-LONG.
    05 NH-H-MAIN            BINARY-LONG.
    05 NH-XZ-MUL            FLOAT-LONG.
    05 NH-Y-MUL             FLOAT-LONG.
    05 NH-K064              FLOAT-LONG.
    05 NH-H-NOISE           BINARY-LONG OCCURS 7 TIMES.
    05 NH-STATES.
       10 NH-S-NETHERRACK   BINARY-LONG.
       10 NH-S-LAVA         BINARY-LONG.
       10 NH-S-BEDROCK      BINARY-LONG.
       10 NH-S-BASALT       BINARY-LONG.
       10 NH-S-GRAVEL       BINARY-LONG.
       10 NH-S-BLACKSTONE   BINARY-LONG.
       10 NH-S-SOUL-SAND    BINARY-LONG.
       10 NH-S-SOUL-SOIL    BINARY-LONG.
       10 NH-S-WARPED-WART  BINARY-LONG.
       10 NH-S-WARPED-NYL   BINARY-LONG.
       10 NH-S-WART-BLOCK   BINARY-LONG.
       10 NH-S-CRIMSON-NYL  BINARY-LONG.
    05 NH-BIOME-ID          BINARY-LONG OCCURS 5 TIMES.
    05 NH-CORNER            FLOAT-LONG OCCURS 425 TIMES.
    05 NH-COL               FLOAT-LONG OCCURS 128 TIMES.
    05 NH-RING              BINARY-LONG OCCURS 36 TIMES.
    05 NH-RING-QX           BINARY-LONG.
    05 NH-RING-QZ           BINARY-LONG.
    05 NH-CC-X              BINARY-LONG.
    05 NH-CC-Z              BINARY-LONG.
    05 NH-CC-HAVE           BINARY-LONG OCCURS 7 TIMES.
    05 NH-CC-VAL            FLOAT-LONG OCCURS 7 TIMES.
