*> The status effects of mobs (core/src/mob-effects.cob; 002-lane-mobsb3 T8100), EXTERNAL, a side table of one entry per (entity id, effect id) pair (ME-ENT 0 = free).
*> Effect ids are the registry ids of 49 section 2.4 (0 to 39). ME-DUR is the ticks left, -1 infinite; ME-FLAGS the 05b 0x87 flags (1 ambient, 2 particles, 4 icon).
 78 ME-MAX                VALUE 256.
 01 ME-STATE EXTERNAL.
    05 ME-ENTRY              OCCURS 256 TIMES.
       10 ME-ENT             BINARY-LONG.
       10 ME-ID              BINARY-LONG.
       10 ME-AMP             BINARY-LONG.
       10 ME-DUR             BINARY-LONG.
       10 ME-FLAGS           BINARY-LONG.
       10 ME-HCOUNT          BINARY-LONG.        *> hidden instances beneath the active one (44-x1 sections 8.2, 11.2): at most 4
       10 ME-HID             OCCURS 4 TIMES.
          15 ME-H-AMP        BINARY-LONG.
          15 ME-H-DUR        BINARY-LONG.
          15 ME-H-FLAGS      BINARY-LONG.
