*> Test-owned stand-in for the production program WORLDSIM-NEW-WORLD-SPAWN (core/src/worldsim-new-spawn.cob, a file of its own): COPY this after the
*> END PROGRAM of a test that opens a new standard world for its generation and neither joins a player nor reads the world spawn. The test object defines
*> the program name, so the linker does not take the library's: opening the world stores the provisional spawn (33 section 6.2: chunk (0, 0), height 64)
*> and runs no spawn search, so it generates no chunk. What the first generated chunk of the search would have left behind for the test is done here: the
*> generator is set up for the world seed (GEN-WORLD-SETUP, when the terrain data are loaded), the biome source's climate points are built as
*> GEN-STAGE-BIOMES builds them (OVB-BUILD while there are none) and the possible structure sets as STRUCT-STAGE-HOOK builds them (while a structure is
*> gated on and they are not built yet). A test of the spawn point or of a joining player does not COPY it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-NEW-WORLD-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTDATA.
 COPY CLIMATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 64.
 01 WS-READY               BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-WORLD-TYPE = "standard"
         CALL "WP-PROVISIONAL" USING WS-ZERO WS-ZERO2 WS-HEIGHT WS-X WS-Y WS-Z
         MOVE WS-X TO CW-SPAWN-X
         MOVE WS-Y TO CW-SPAWN-Y
         MOVE WS-Z TO CW-SPAWN-Z
         MOVE 0 TO CW-SPAWN-YAW
         CALL "GEN-DATA-READY" USING WS-READY
         IF WS-READY = 1
             CALL "GEN-WORLD-SETUP"
             IF CL-COUNT = 0
                 CALL "OVB-BUILD"
             END-IF
             IF SD-GATE-COUNT > 0 AND SD-POSS-DONE = 0
                 CALL "STRUCT-POSSIBLE-BUILD"
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-NEW-WORLD-SPAWN.
