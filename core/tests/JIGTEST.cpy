*> The synthetic terrain of the jigsaw and ruined portal tests (test infrastructure, never linked into production): TJ-SURFACE, shared by a test program and the JIG-SURFACE, JIG-BIOME-OK and
*> STRUCT-PORTAL-BIOME that JIGSEAM.cpy puts into the same test source (the linker takes them in place of the library's). 0 the real terrain and biome source, 1 the synthetic first free height
*> 68 + ((floor(x / 4) + floor(z / 4)) mod 5) (fixtures/gen_jigsaw.py uses the same function) and no biome test, 2 every first free height -40, 3 every first free height 200 (2 and 3 make no
*> biome lookup either). A change of TJ-SURFACE does not clear the start list cache (STRUCT-CHUNK-STARTS): a test that asks for starts under two values adds 1 to SD-EPOCH between them.
 01 TJ-SURFACE-AREA EXTERNAL.
    05 TJ-SURFACE           BINARY-LONG.
