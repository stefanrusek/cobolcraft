*> The surface rule engine's shared state (core/src/surface.cob; docs/protocol/10 sections 10.1 to 10.9). EXTERNAL.
*> SF-ZOOM-SEED is the obfuscated world seed of the biome zoom (7.7), SF-BAND the 192 terracotta band states of 10.6 built
*> from the positional factory SF-BAND-LO/HI of the world. SF-NODE holds what is remembered per node of the content's node
*> store (reset with the world): the root a reference resolves to, the state of a block rule, the handle of a noise,
*> the last biome tested with its answer and the positional factory of a vertical gradient. SC-* is the context of the
*> block being decided (10.1, 10.2): the rule and condition evaluators read it.
 78 SF-NODES               VALUE 32768.
 01 SURFACE-STATE EXTERNAL.
    05 SF-SEED-READY        BINARY-LONG.
    05 SF-ZOOM-SEED         BINARY-DOUBLE UNSIGNED.
    05 SF-BANDS-READY       BINARY-LONG.
    05 SF-BAND-LO           BINARY-DOUBLE UNSIGNED.
    05 SF-BAND-HI           BINARY-DOUBLE UNSIGNED.
    05 SF-BAND              BINARY-LONG OCCURS 192 TIMES.
    05 SF-NODE OCCURS 32768 TIMES.
       10 SF-N-REF          BINARY-LONG.
       10 SF-N-STATE        BINARY-LONG.
       10 SF-N-HANDLE       BINARY-LONG.
       10 SF-N-BIOME        BINARY-LONG.
       10 SF-N-ANSWER       BINARY-LONG.
       10 SF-N-VG-READY     BINARY-LONG.
       10 SF-N-VG-LO        BINARY-DOUBLE UNSIGNED.
       10 SF-N-VG-HI        BINARY-DOUBLE UNSIGNED.
 01 SURFACE-CTX EXTERNAL.
    05 SC-X                 BINARY-LONG.
    05 SC-Y                 BINARY-LONG.
    05 SC-Z                 BINARY-LONG.
    05 SC-ABOVE             BINARY-LONG.
    05 SC-BELOW             BINARY-LONG.
    05 SC-WATER-SET         BINARY-LONG.
    05 SC-WATER             BINARY-LONG.
    05 SC-DEPTH             BINARY-LONG.
    05 SC-MIN-LEVEL         BINARY-LONG.
    05 SC-STEEP             BINARY-LONG.
    05 SC-SEC-READY         BINARY-LONG.
    05 SC-SEC               FLOAT-LONG.
    05 SC-BIO-Q             BINARY-LONG.
    05 SC-BIO-ID            BINARY-LONG.
    05 SC-STONE-STATE      BINARY-LONG.
    05 SC-WATER-STATE      BINARY-LONG.
    05 SC-LAVA-STATE       BINARY-LONG.
    05 SC-ROOT             BINARY-LONG.
