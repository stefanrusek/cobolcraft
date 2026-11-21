*> The state of the ender dragon (core/src/dragon-44*.cob; docs/protocol/21 section 6.4, 44 part 9 section 1), EXTERNAL, one dragon at a time (the fight has one), keyed by the entity id
*> DG-ENT (0 = none) and also entered in PROJSTATE.cpy (PJ-KIND 17) so THROWN-TICK steps it. DG-HP is the exact health (the tracker row's EN-HEALTH is its ceiling).
*> The path is a list of node numbers 0 to 23 with 24 for the extra node (DG-EX, DG-EY, DG-EZ); DG-PATH-I is the next one, the path is done when it is past DG-PATH-N.
*> DG-HIST is the ring of the flight history, 64 samples of (y, yaw), DG-HIST-I the newest. DG-PART holds the eight part positions (1 head, 2 neck, 3 body, 4 to 6 tails, 7 and 8 wings).
 01 DG-STATE EXTERNAL.
    05 DG-ENT               BINARY-LONG.
    05 DG-PHASE             BINARY-LONG.
    05 DG-HP                FLOAT-LONG.
    05 DG-HAS-PATH          BINARY-LONG.
    05 DG-PATH-N            BINARY-LONG.
    05 DG-PATH-I            BINARY-LONG.
    05 DG-PATH-NODE         BINARY-LONG OCCURS 26 TIMES.
    05 DG-EX                BINARY-LONG.
    05 DG-EY                BINARY-LONG.
    05 DG-EZ                BINARY-LONG.
    05 DG-HAS-TARGET        BINARY-LONG.
    05 DG-TX                FLOAT-LONG.
    05 DG-TY                FLOAT-LONG.
    05 DG-TZ                FLOAT-LONG.
    05 DG-CW                BINARY-LONG.
    05 DG-SCW               BINARY-LONG.
    05 DG-CHARGE            BINARY-LONG.
    05 DG-PROW              BINARY-LONG.
    05 DG-YOFF              FLOAT-LONG.
    05 DG-SCAN              BINARY-LONG.
    05 DG-FLAMES            BINARY-LONG.
    05 DG-FLAME-T           BINARY-LONG.
    05 DG-ROAR              BINARY-LONG.
    05 DG-CHARGE-T          BINARY-LONG.
    05 DG-SIT-DMG           FLOAT-LONG.
    05 DG-DEATH-T           BINARY-LONG.
    05 DG-HURT-T            BINARY-LONG.
    05 DG-TICK              BINARY-LONG.
    05 DG-YROT-A            FLOAT-LONG.
    05 DG-WALL              BINARY-LONG.
    05 DG-HIST-I            BINARY-LONG.
    05 DG-HIST              OCCURS 64 TIMES.
       10 DG-HIST-Y         FLOAT-LONG.
       10 DG-HIST-YAW       FLOAT-LONG.
    05 DG-NODE-Y            BINARY-LONG OCCURS 24 TIMES.
    05 DG-CRYSTAL           BINARY-LONG.
    05 DG-PART              OCCURS 8 TIMES.
       10 DG-PART-X         FLOAT-LONG.
       10 DG-PART-Y         FLOAT-LONG.
       10 DG-PART-Z         FLOAT-LONG.
    05 DG-FIGHT             BINARY-LONG.
