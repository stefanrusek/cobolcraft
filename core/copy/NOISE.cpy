*> The noise store (docs/protocol/10 section 3; core/src/noise.cob). EXTERNAL: every program that copies this
*> book shares it. A perlin row is one improved-noise octave (offsets and the 256 entry permutation table;
*> NZ-FUDGE is the smear scale of a SmearedPerlinNoise, 0 for a plain one). A layer is (perlin, frequency,
*> amplitude as the value of a float32); a normal noise is NZ-LAYER-N consecutive layers from NZ-FIRST.
*> A noise handle is the row of NZ-NOISE. NOISE-RESET empties the store.
 78 NZ-MAX-PERLIN          VALUE 2048.
 78 NZ-MAX-LAYERS          VALUE 4096.
 78 NZ-MAX-NOISES          VALUE 512.
 01 NZ-STORE EXTERNAL.
    05 NZ-GEN               BINARY-LONG.
    05 NZ-PERLIN-COUNT      BINARY-LONG.
    05 NZ-LAYER-COUNT       BINARY-LONG.
    05 NZ-NOISE-COUNT       BINARY-LONG.
    05 NZ-PERLIN OCCURS 2048 TIMES.
       10 NZ-OX             FLOAT-LONG.
       10 NZ-OY             FLOAT-LONG.
       10 NZ-OZ             FLOAT-LONG.
       10 NZ-FUDGE          FLOAT-LONG.
       10 NZ-PERM           BINARY-LONG OCCURS 256 TIMES.
    05 NZ-NOISE OCCURS 512 TIMES.
       10 NZ-FIRST          BINARY-LONG.
       10 NZ-LAYER-N        BINARY-LONG.
    05 NZ-LAYER OCCURS 4096 TIMES.
       10 NZ-L-PERLIN       BINARY-LONG.
       10 NZ-L-FREQ         FLOAT-LONG.
       10 NZ-L-AMP          FLOAT-LONG.
