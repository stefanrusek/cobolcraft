*> A program of its own (one program per file): a test that needs a standard world's generation but not its spawn point defines a
*> WORLDSIM-NEW-WORLD-SPAWN in its own source (core/tests/NOSPAWN.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-NEW-WORLD-SPAWN.
*> No parameters: CORE-WORLD-OPEN of a new world; a standard world gets the spawn search of 33 section 6.2: the asynchronous one (GEN-SPAWN-BEGIN) when generation
*> workers serve the standard chunks (a host asked for them and the terrain data are loaded), else WORLDSIM-INITIAL-SPAWN; the cobolcraft world keeps the
*> fixed spawn of standin-content.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENQUEUE.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-WORLD-TYPE = "standard"
         CALL "WORLD-GEN-OWN" USING WS-DEBUG
         CALL "GEN-DATA-READY" USING WS-READY
         IF GQ-WORKERS > 0 AND WS-DEBUG = 0 AND WS-READY = 1
             CALL "GEN-SPAWN-BEGIN"
         ELSE
             CALL "WORLDSIM-INITIAL-SPAWN"
         END-IF
     END-IF
*>   A superflat world: the same search with the provisional height of the flat generator (56 section 4.8).
     IF CW-WORLD-TYPE = "superflat"
         CALL "WORLDSIM-INITIAL-SPAWN"
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-NEW-WORLD-SPAWN.
