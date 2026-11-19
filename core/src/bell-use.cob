*> A player's use of a bell (31 part 4 section 4.5; 30 part 8 section 8.2 and 8.3). BELL-USE rings the bell of a Use Item On when the hit counts (RS3-BELL-HIT: not on the top or bottom
*> face, not above 0.8124 of the block's height, then by attachment the axes of the face and of the bell's facing equal (floor), different (walls) or always (ceiling)) and the player
*> is not sneaking with an item in the hand (the item is used on the block instead); a ring sends Block Event 1 (play packet 7: position, action 1, the hit face as the click direction
*> in the Direction order, the block id) to every player within 64 blocks (the client swings the bell and draws it, client/src/bell.cob). The sound and the resonance of the bell block
*> entity are not done here.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BELL-USE.
*> USING player row, state id of the clicked block, x, y, z, face (0 down to 5 east), cursor y (FLOAT-SHORT, 0 to 1 in the block), used out (1 when the click rang the bell and takes the use).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-PROP-ATTACHMENT     PIC X(24) VALUE "attachment".
 01 WS-PROP-FACING         PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-NAME40              PIC X(40).
 01 WS-ATTACHMENT          BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-REL                 FLOAT-LONG.
 01 WS-RINGS               BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 7.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG VALUE 1.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-CURSOR-Y             FLOAT-SHORT.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-STATE L-X L-Y L-Z L-FACE L-CURSOR-Y L-USED.
     MOVE 0 TO L-USED
     CALL "IP-BLOCK-KEY" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-KEY WS-LENGTH
     IF WS-LENGTH = 14 AND WS-KEY(1:14) = "minecraft:bell"
         IF NOT (PL-SNEAKING(L-PLAYER) = 1 AND PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) > 0)
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE-READ L-STATE WS-PROP-ATTACHMENT WS-TEXT WS-RESULT
             MOVE WS-TEXT TO WS-NAME40
             CALL "RS3-BELL-ATTACHMENT" USING WS-NAME40 WS-ATTACHMENT
             MOVE SPACES TO WS-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE-READ L-STATE WS-PROP-FACING WS-TEXT WS-RESULT
             EVALUATE FUNCTION TRIM(WS-TEXT)
                 WHEN "north"
                     MOVE 2 TO WS-FACING
                 WHEN "south"
                     MOVE 3 TO WS-FACING
                 WHEN "west"
                     MOVE 4 TO WS-FACING
                 WHEN OTHER
                     MOVE 5 TO WS-FACING
             END-EVALUATE
             MOVE L-CURSOR-Y TO WS-REL
             CALL "RS3-BELL-HIT" USING WS-ATTACHMENT WS-FACING L-FACE WS-REL WS-RINGS
             IF WS-RINGS = 1
                 MOVE 1 TO L-USED
                 MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
                 CALL "PB-PUT-BLOCK-EVENT" USING PB-BUFFER L-X L-Y L-Z WS-ACTION L-FACE WS-BLOCK
                 CALL "LEVEL-BROADCAST" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-NONE PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
*>               The villagers within 32 blocks hear it (docs 44 part 3 section 2.11a; mob-vil-bell.cob).
                 CALL "VL-BELL-RING" USING PL-DIM(L-PLAYER) L-X L-Y L-Z
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BELL-USE.
