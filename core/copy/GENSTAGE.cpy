*> Counters of the generation stages that have run (EXTERNAL; core/src/worldgen-*.cob and the stage modules
*> increment their own at every entry). A test reads them to show that a world type ran or skipped a stage
*> (test_debug_no_terrain: a debug chunk runs none of them). GS-RESET clears them.
 01 GEN-STAGES EXTERNAL.
    05 GS-NOISE             BINARY-DOUBLE.
    05 GS-CLIMATE           BINARY-DOUBLE.
    05 GS-DENSITY           BINARY-DOUBLE.
    05 GS-AQUIFER           BINARY-DOUBLE.
    05 GS-SURFACE           BINARY-DOUBLE.
    05 GS-CARVER            BINARY-DOUBLE.
    05 GS-ORE               BINARY-DOUBLE.
    05 GS-FEATURE           BINARY-DOUBLE.
