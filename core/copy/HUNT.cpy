*> Piglins hunting hoglins (docs/protocol/21 section 5.5.1; core/src/mob-21-hunt.cob), EXTERNAL: one entry per piglin entity id (PH-ID 0 = free), PH-TIMER the ticks until the
*> piglin may hunt again (the HUNTED_RECENTLY memory: 30 to 120 s from its spawn and after every kill).
 78 PH-MAX                VALUE 64.
 01 PH-STATE EXTERNAL.
    05 PH-ENTRY              OCCURS 64 TIMES.
       10 PH-ID              BINARY-LONG.
       10 PH-TIMER           BINARY-LONG.
