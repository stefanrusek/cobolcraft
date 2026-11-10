*> Particle definitions and sprite sets (docs/protocol/42-particles-1-shared-model-engine.md section 6).
*> PDEF is one parsed particles/<name>.json: the sprite ids of "textures" (namespace minecraft: added
*> when absent). PDEF-ATLAS is the particles atlas as a list of sprite ids (index 0 is the atlas's
*> "missing" sprite). PSET is a bound sprite set: PS-SPRITE holds atlas indexes (0 = missing).
 78 PD-MAX                  VALUE 64.
 01 PDEF.
    05 PD-ERROR             BINARY-LONG.
    05 PD-COUNT             BINARY-LONG.
    05 PD-TEXTURE           PIC X(64) OCCURS 64 TIMES.
 01 PDEF-ATLAS.
    05 PA-COUNT             BINARY-LONG.
    05 PA-ID                PIC X(64) OCCURS 512 TIMES.
 01 PSET.
    05 PS-COUNT             BINARY-LONG.
    05 PS-BOUND             BINARY-LONG.
    05 PS-SPRITE            BINARY-LONG OCCURS 64 TIMES.
 01 PDEF-LISTING.
    05 PL-COUNT             BINARY-LONG.
    05 PL-ENTRY             OCCURS 256 TIMES.
       10 PL-PACK           BINARY-LONG.
       10 PL-ID             PIC X(64).
       10 PL-FILTER         BINARY-LONG.
 01 PDEF-MAP.
    05 PM-COUNT             BINARY-LONG.
    05 PM-ENTRY             OCCURS 256 TIMES.
       10 PM-ID             PIC X(64).
       10 PM-PACK           BINARY-LONG.
