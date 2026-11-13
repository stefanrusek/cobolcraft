*> The scoreboard and teams (docs/protocol/16-commands-catalog.md §9; core/src/cmds-scoreboard.cob), EXTERNAL and in memory only (not saved with the
*> world): objectives, scores, the display slots (index 1 list, 2 sidebar, 3 below_name, 4 to 19 sidebar.team.<colour> in the colour order of the
*> catalog), teams and their members. A used flag 0 is a free entry. Visibility values 0 always, 1 never, 2 hideForOtherTeams, 3 hideForOwnTeam
*> (collision 0 always, 1 never, 2 pushOtherTeams, 3 pushOwnTeam); colour -1 is none (reset), else the index 0 to 15 of the colour names.
 78 SB-MAX-OBJECTIVES    VALUE 64.
 78 SB-MAX-SCORES        VALUE 2048.
 78 SB-MAX-TEAMS         VALUE 64.
 78 SB-MAX-MEMBERS       VALUE 512.
 01 SB-STATE EXTERNAL.
    05 SB-OBJECTIVE         OCCURS 64 TIMES.
       10 SB-O-USED          BINARY-LONG.
       10 SB-O-NAME          PIC X(64).
       10 SB-O-NAME-LENGTH   BINARY-LONG.
       10 SB-O-CRITERIA      PIC X(64).
       10 SB-O-CRIT-LENGTH   BINARY-LONG.
       10 SB-O-DISPLAY       PIC X(64).
       10 SB-O-DISPLAY-LENGTH BINARY-LONG.
       10 SB-O-RENDER        BINARY-LONG.
       10 SB-O-AUTO          BINARY-LONG.
       10 SB-O-FORMAT        BINARY-LONG.
    05 SB-SCORE             OCCURS 2048 TIMES.
       10 SB-S-USED          BINARY-LONG.
       10 SB-S-OBJECTIVE     BINARY-LONG.
       10 SB-S-HOLDER        PIC X(64).
       10 SB-S-HOLDER-LENGTH BINARY-LONG.
       10 SB-S-VALUE         BINARY-LONG.
       10 SB-S-LOCKED        BINARY-LONG.
       10 SB-S-DISPLAY       PIC X(64).
       10 SB-S-DISPLAY-LENGTH BINARY-LONG.
       10 SB-S-FORMAT        BINARY-LONG.
    05 SB-SLOT              BINARY-LONG OCCURS 19 TIMES.
    05 SB-TEAM              OCCURS 64 TIMES.
       10 SB-T-USED          BINARY-LONG.
       10 SB-T-NAME          PIC X(64).
       10 SB-T-NAME-LENGTH   BINARY-LONG.
       10 SB-T-DISPLAY       PIC X(64).
       10 SB-T-DISPLAY-LENGTH BINARY-LONG.
       10 SB-T-COLOR         BINARY-LONG.
       10 SB-T-FRIENDLY      BINARY-LONG.
       10 SB-T-SEE-INVISIBLE BINARY-LONG.
       10 SB-T-NAMETAG       BINARY-LONG.
       10 SB-T-DEATH         BINARY-LONG.
       10 SB-T-COLLISION     BINARY-LONG.
       10 SB-T-PREFIX        PIC X(64).
       10 SB-T-PREFIX-LENGTH BINARY-LONG.
       10 SB-T-SUFFIX        PIC X(64).
       10 SB-T-SUFFIX-LENGTH BINARY-LONG.
    05 SB-MEMBER            OCCURS 512 TIMES.
       10 SB-M-USED          BINARY-LONG.
       10 SB-M-TEAM          BINARY-LONG.
       10 SB-M-NAME          PIC X(64).
       10 SB-M-NAME-LENGTH   BINARY-LONG.
