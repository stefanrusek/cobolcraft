*> The state of the End generator (core/src/end-38.cob; docs/protocol/38-end.md sections 3 to 7). EXTERNAL.
*> EN-GEN is the noise store generation (NZ-GEN) the handles were built for: a NOISE-RESET invalidates them. EN-PERM is the permutation
*> of the island simplex noise (4.3, SimplexNoise(r, true)), EN-C-* a direct-mapped memo of its values at integer points (4096 entries,
*> index mod(px * 73 + pz * 151, 4096) + 1). EN-CORNER holds the 3 x 33 x 3 corner values 0.64 * A_blend of the chunk being made (index
*> ((i * 3 + k) * 33 + j) + 1 for corner x i, corner z k, corner row j = y / 4), EN-COL the 128 squeezed densities of one column.
 01 END-STATE EXTERNAL.
    05 EN-READY             BINARY-LONG.
    05 EN-GEN               BINARY-LONG.
    05 EN-SEED              BINARY-DOUBLE UNSIGNED.
    05 EN-H-MIN             BINARY-LONG.
    05 EN-H-MAX             BINARY-LONG.
    05 EN-H-MAIN            BINARY-LONG.
    05 EN-XZ-MUL            FLOAT-LONG.
    05 EN-Y-MUL             FLOAT-LONG.
    05 EN-K064              FLOAT-LONG.
    05 EN-PERM              BINARY-LONG OCCURS 256 TIMES.
    05 EN-C-HAVE            BINARY-LONG OCCURS 4096 TIMES.
    05 EN-C-X               BINARY-LONG OCCURS 4096 TIMES.
    05 EN-C-Z               BINARY-LONG OCCURS 4096 TIMES.
    05 EN-C-VAL             FLOAT-LONG OCCURS 4096 TIMES.
    05 EN-S-END-STONE       BINARY-LONG.
    05 EN-BIOME-ID          BINARY-LONG OCCURS 5 TIMES.
    05 EN-CORNER            FLOAT-LONG OCCURS 297 TIMES.
    05 EN-COL               FLOAT-LONG OCCURS 128 TIMES.
