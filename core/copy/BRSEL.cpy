*> A parsed entity selector (docs/protocol/15-commands-framework.md §7; core/src/cmd-selector.cob BR-SEL-READ), EXTERNAL: the
*> last selector read. Text ranges (nbt, advancements) are 0-based offsets into BR-IN-TEXT (core/copy/BRIGADIER.cpy).
*> SL-TYPE 1 @p, 2 @a, 3 @r, 4 @s, 5 @e, 6 @n, 7 a player name, 8 a UUID; SL-LIMIT 2147483647 is unlimited; SL-SORT 0
*> arbitrary, 1 nearest, 2 furthest, 3 random; SL-INCLUDES-ENTITIES 0 when only players can match. A range has an aux of
*> 1 minimum, 2 maximum, 3 both. SL-GM-ALLOW and SL-GM-DENY are masks of game modes (survival 1, creative 2, adventure 4,
*> spectator 8). Position components 1 to 6 are x y z dx dy dz.
 78 SL-MAX-LIST            VALUE 8.
 01 BR-SEL EXTERNAL.
    05 SL-TYPE              BINARY-LONG.
    05 SL-LIMIT             BINARY-LONG.
    05 SL-SORT              BINARY-LONG.
    05 SL-INCLUDES-ENTITIES BINARY-LONG.
    05 SL-WORLD-LIMITED     BINARY-LONG.
    05 SL-TEXT-LENGTH       BINARY-LONG.
    05 SL-TEXT              PIC X(64).
    05 SL-HAS-POS           BINARY-LONG OCCURS 6 TIMES.
    05 SL-POS               FLOAT-LONG OCCURS 6 TIMES.
    05 SL-DIST-AUX          BINARY-LONG.
    05 SL-DIST-MIN          FLOAT-LONG.
    05 SL-DIST-MAX          FLOAT-LONG.
    05 SL-LEVEL-AUX         BINARY-LONG.
    05 SL-LEVEL-MIN         BINARY-DOUBLE.
    05 SL-LEVEL-MAX         BINARY-DOUBLE.
    05 SL-XROT-AUX          BINARY-LONG.
    05 SL-XROT-MIN          FLOAT-LONG.
    05 SL-XROT-MAX          FLOAT-LONG.
    05 SL-YROT-AUX          BINARY-LONG.
    05 SL-YROT-MIN          FLOAT-LONG.
    05 SL-YROT-MAX          FLOAT-LONG.
    05 SL-LIMIT-SET         BINARY-LONG.
    05 SL-SORT-SET          BINARY-LONG.
    05 SL-SCORES-SET        BINARY-LONG.
    05 SL-ADV-SET           BINARY-LONG.
    05 SL-NAME-STATE        BINARY-LONG.
    05 SL-GM-STATE          BINARY-LONG.
    05 SL-TEAM-STATE        BINARY-LONG.
    05 SL-TYPE-STATE        BINARY-LONG.
    05 SL-GM-ALLOW          BINARY-LONG.
    05 SL-GM-DENY           BINARY-LONG.
    05 SL-NAME-COUNT        BINARY-LONG.
    05 SL-NAME-ENTRY        OCCURS 8 TIMES.
       10 SL-NAME-NEG        BINARY-LONG.
       10 SL-NAME-LENGTH     BINARY-LONG.
       10 SL-NAME-TEXT       PIC X(48).
    05 SL-TEAM-COUNT        BINARY-LONG.
    05 SL-TEAM-ENTRY        OCCURS 8 TIMES.
       10 SL-TEAM-NEG        BINARY-LONG.
       10 SL-TEAM-LENGTH     BINARY-LONG.
       10 SL-TEAM-TEXT       PIC X(48).
    05 SL-TYPE-COUNT        BINARY-LONG.
    05 SL-TYPE-ENTRY        OCCURS 8 TIMES.
       10 SL-TYPE-NEG        BINARY-LONG.
       10 SL-TYPE-TAG        BINARY-LONG.
       10 SL-TYPE-LENGTH     BINARY-LONG.
       10 SL-TYPE-TEXT       PIC X(48).
    05 SL-TAG-COUNT         BINARY-LONG.
    05 SL-TAG-ENTRY         OCCURS 8 TIMES.
       10 SL-TAG-NEG         BINARY-LONG.
       10 SL-TAG-LENGTH      BINARY-LONG.
       10 SL-TAG-TEXT        PIC X(48).
    05 SL-NBT-COUNT         BINARY-LONG.
    05 SL-NBT-ENTRY         OCCURS 8 TIMES.
       10 SL-NBT-NEG         BINARY-LONG.
       10 SL-NBT-START       BINARY-LONG.
       10 SL-NBT-END         BINARY-LONG.
    05 SL-SCORE-COUNT       BINARY-LONG.
    05 SL-SCORE-ENTRY       OCCURS 8 TIMES.
       10 SL-SCORE-LENGTH    BINARY-LONG.
       10 SL-SCORE-OBJECTIVE PIC X(48).
       10 SL-SCORE-AUX       BINARY-LONG.
       10 SL-SCORE-MIN       BINARY-DOUBLE.
       10 SL-SCORE-MAX       BINARY-DOUBLE.
    05 SL-ADV-START         BINARY-LONG.
    05 SL-ADV-END           BINARY-LONG.
    05 SL-PRED-COUNT        BINARY-LONG.
    05 SL-PRED-ENTRY        OCCURS 8 TIMES.
       10 SL-PRED-NEG        BINARY-LONG.
       10 SL-PRED-LENGTH     BINARY-LONG.
       10 SL-PRED-TEXT       PIC X(48).
