*> Note block right click: tune and play event (002-lane-mobsa5; docs/protocol/30 part 5 section 8.4, 44 part 4 section 14: the allay hears NOTE_BLOCK_PLAY).
*> - M44-NOTE-USE USING player row, clicked state, x, y, z, face, used out: Use Item On a note_block: when the clicked face is up and the held item is in the item tag note_block_top_instruments the
*>   block passes (the item is used on it: a head); otherwise the note goes up by one (RS2-NOTE-TUNE: (n + 1) mod 25, the property note), the block changes and, with air above it, the play event
*>   reaches the allays (ALLAY-NOTE-EVENT, listener radius 16). The note sound, the note particle, the statistic and the redstone side (power, left click, instrument by the block below) are not
*>   written here (gap: the sound packet needs the instrument lookup of 30 part 5 section 8.5; the redstone helper of 30-5 is not wired to power).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-NOTE-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:note_block_top_instruments".
 01 WS-HELD                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "note".
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-NOTE                BINARY-LONG.
 01 WS-NEW-NOTE            BINARY-LONG.
 01 WS-PLAYED              BINARY-LONG.
 01 WS-STAT                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-STATE L-X L-Y L-Z L-FACE L-USED.
     MOVE 0 TO L-USED
     CALL "IP-BLOCK-KEY" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-KEY WS-LENGTH
     IF WS-LENGTH = 20 AND WS-KEY(1:20) = "minecraft:note_block"
         MOVE 0 TO WS-TOP WS-HELD
         IF PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) > 0
             MOVE PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WS-HELD
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-HELD WS-TOP
         END-IF
         IF NOT (L-FACE = 1 AND WS-TOP = 1)
             MOVE 1 TO L-USED
             CALL "BLOCK-STATE-PROP" USING WS-MODE-READ L-STATE WS-PROP WS-TEXT WS-RESULT
             COMPUTE WS-NOTE = FUNCTION NUMVAL(WS-TEXT)
             CALL "RS2-NOTE-TUNE" USING WS-NOTE WS-NEW-NOTE WS-PLAYED WS-STAT
             MOVE SPACES TO WS-TEXT
             MOVE WS-NEW-NOTE TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE-SET L-STATE WS-PROP WS-TEXT WS-NEW
             CALL "BLOCK-CHANGE" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-NEW
             CALL "RL-NOTE-PLAY" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-NOTE-USE.
