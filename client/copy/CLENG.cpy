*> Particle engine core state (docs/protocol/42-particles-1-shared-model-engine.md section 5). A particle
*> is a handle (BINARY-LONG chosen by the caller). Groups: 1 SINGLE_QUADS (SQ), 2 ITEM_PICKUP (IP),
*> 3 ELDER_GUARDIANS (EG), 4 NO_RENDER (NR). EN-LIMITED is 1 for a particle with a ParticleLimit
*> (spore_blossom_air), else 0. EN-G-DEAD and EN-EM-DEAD are set to 1 by the caller after ticking a
*> particle that is no longer alive; PENG-REAP then does steps 1 to 3 of the tick order of 5.5.
 78 EN-GROUP-MAX             VALUE 16384.
 78 EN-QUEUE-MAX             VALUE 4096.
 01 ENGINE.
    05 EN-GROUP               OCCURS 4 TIMES.
       10 EN-G-EXISTS         BINARY-LONG.
       10 EN-G-COUNT          BINARY-LONG.
       10 EN-G-SLOT           OCCURS 16384 TIMES.
          15 EN-G-HANDLE      BINARY-LONG.
          15 EN-G-LIMITED     BINARY-LONG.
          15 EN-G-DEAD       BINARY-LONG.
    05 EN-ADD-COUNT           BINARY-LONG.
    05 EN-ADD                 OCCURS 4096 TIMES.
       10 EN-A-HANDLE         BINARY-LONG.
       10 EN-A-GROUP          BINARY-LONG.
       10 EN-A-LIMITED        BINARY-LONG.
    05 EN-EM-COUNT            BINARY-LONG.
    05 EN-EM                  OCCURS 64 TIMES.
       10 EN-EM-HANDLE        BINARY-LONG.
       10 EN-EM-DEAD         BINARY-LONG.
    05 EN-LIMIT-COUNT         BINARY-LONG.
    05 EN-DRAW-INDEX          BINARY-LONG.
