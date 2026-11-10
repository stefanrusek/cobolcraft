*> The packets a server-side emitter hands to ServerLevel.sendParticles (42-7 section 1; field names of 05a 0x30). PS-COUNT rows of PS-ROW:
*>   PS-NAME particle type; PS-FORCE override limiter and PS-ALWAYS always show (0/1, as in the PIC 9 pair); PS-X..PS-Z position; PS-COUNT-OF the particle
*>   count; PS-DX..PS-DZ the distances; PS-SX..PS-SZ the maximum speeds; PS-MODE randomisation (0 DEFAULT, 1 ALTERNATIVE, 2 ALTERNATIVE_WITH_SPEED);
*>   PS-STATE a block state option (0 none).
 01 P7-PACKETS.
    05 PS-COUNT            BINARY-LONG.
    05 PS-ROW OCCURS 64 TIMES.
       10 PS-NAME          PIC X(40).
       10 PS-FORCE         PIC 9.
       10 PS-ALWAYS        PIC 9.
       10 PS-X             FLOAT-LONG.
       10 PS-Y             FLOAT-LONG.
       10 PS-Z             FLOAT-LONG.
       10 PS-COUNT-OF      BINARY-LONG.
       10 PS-DX            FLOAT-LONG.
       10 PS-DY            FLOAT-LONG.
       10 PS-DZ            FLOAT-LONG.
       10 PS-SX            FLOAT-LONG.
       10 PS-SY            FLOAT-LONG.
       10 PS-SZ            FLOAT-LONG.
       10 PS-MODE          BINARY-LONG.
       10 PS-STATE         BINARY-LONG.
