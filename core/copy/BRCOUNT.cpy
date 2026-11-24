*> Random-tick bookkeeping of the chunk sections (docs/protocol/29 section 5): per cache row (CORESTATE CK-ENTRY) and section,
*> the four counts of LevelChunkSection: BR-NONEMPTY (states that are not air), BR-TICKING-BLOCKS (states whose block is
*> randomly ticking: a rule of kind 11 in BUSTATE.cpy), BR-FLUID (states with a non-empty fluid: a rule of kind 12) and
*> BR-TICKING-FLUIDS (fluid randomly ticking: kind 13). Kept by BR-COUNT-ROW (chunk load) and BR-ADJUST (every state written).
 01 BR-COUNTS EXTERNAL.
    05 BR-ROW OCCURS 4096 TIMES.
       10 BR-SECTION OCCURS 24 TIMES.
          15 BR-NONEMPTY         BINARY-LONG.
          15 BR-TICKING-BLOCKS   BINARY-LONG.
          15 BR-FLUID            BINARY-LONG.
          15 BR-TICKING-FLUIDS   BINARY-LONG.
