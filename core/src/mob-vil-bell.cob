*> The entity side of a ringing bell (docs/protocol/44 part 3 section 2.11a; lane 002-lane-p49p). When a bell is rung, every living entity whose position is within 32 blocks of the bell's
*> centre (inside the box of 48) gets the memory heard_bell_time = the game tick. Only villagers have a brain here (gap: other brain mobs do not hear it). The bell block entity's own
*> timing (shaking, resonance, the 60 tick list refresh) is the decision units Q3-BELL-RING, Q3-BELL-TICK and Q3-BELL-REFRESH of core/src/q44-44-3d.cob; the block is hooked to a player's use by VL-BELL-USE below (gaps: no sound, no block event animation, no bell_ring statistic, no resonance).
*>   VL-BELL-RING USING dim, x, y, z (BINARY-LONG block of the bell)    every villager within 32 blocks hears it
*>   VL-BELL-USE USING connection id, PLAY-SERVERBOUND, handled out    a Use Item On with an empty main hand (or a sneaking player with an item: the item is used instead) on a bell: a proper hit (30 part 8 section 8.2:
*>     not the top or bottom face, not above 0.8124 of the block, the axis of the face by the attachment) rings it; handled 1 then (the click is taken: SUCCESS), else 0 (PASS)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BELL-RING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 COPY VILSTATE.
 01 WS-N                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-NOW                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     MOVE CW-TICKS TO WS-NOW
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-DIM(WS-N) = L-DIM AND EN-HEALTH(WS-N) > 0
             COMPUTE WS-D2 = (EN-X(WS-N) - L-X - 0.5) ** 2 + (EN-Y(WS-N) - L-Y - 0.5) ** 2 + (EN-Z(WS-N) - L-Z - 0.5) ** 2
             IF WS-D2 < 1024
                 CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-SLOT
                 IF WS-SLOT > 0 AND VL-KIND(WS-SLOT) = 1
                     CALL "VM-NOTE" USING WS-SLOT MT-HEARD-BELL-TIME WS-NOW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-BELL-RING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BELL-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-ROW                  BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-KEY                  PIC X(48).
 01 WS-BARE                 PIC X(48).
 01 WS-NAME-F               PIC X(16) VALUE "facing".
 01 WS-NAME-A               PIC X(16) VALUE "attachment".
 01 WS-KEEP                 PIC X(16) VALUE "keep".
 01 WS-OUT                  BINARY-LONG.
 01 WS-OLD-F                PIC X(16).
 01 WS-OLD-A                PIC X(16).
 01 WS-ATT-NAME             PIC X(40).
 01 WS-ATT                  BINARY-LONG.
 01 WS-FACING               BINARY-LONG.
 01 WS-REL                  FLOAT-LONG.
 01 WS-RINGS                BINARY-LONG.
 01 WS-HELD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                    BINARY-LONG.
 01 L-HANDLED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-HANDLED.
     MOVE 0 TO L-HANDLED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     IF WS-BARE NOT = "bell"
         GOBACK
     END-IF
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     IF PL-SNEAKING(WS-ROW) = 1 AND PL-SLOT-COUNT(WS-ROW, WS-HELD + 1) > 0
         GOBACK
     END-IF
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-F WS-KEEP WS-OUT WS-OLD-F
     CALL "SW-SET-PROP" USING WS-STATE WS-NAME-A WS-KEEP WS-OUT WS-OLD-A
     MOVE WS-OLD-A TO WS-ATT-NAME
     CALL "RS3-BELL-ATTACHMENT" USING WS-ATT-NAME WS-ATT
     EVALUATE FUNCTION TRIM(WS-OLD-F)
         WHEN "south"
             MOVE 3 TO WS-FACING
         WHEN "west"
             MOVE 4 TO WS-FACING
         WHEN "east"
             MOVE 5 TO WS-FACING
         WHEN OTHER
             MOVE 2 TO WS-FACING
     END-EVALUATE
     MOVE PSB-CURSOR-Y TO WS-REL
     CALL "RS3-BELL-HIT" USING WS-ATT WS-FACING PSB-FACE WS-REL WS-RINGS
     IF WS-RINGS = 1
         MOVE 1 TO L-HANDLED
         CALL "VL-BELL-RING" USING PL-DIM(WS-ROW) PSB-BX PSB-BY PSB-BZ
     END-IF
     GOBACK.
 END PROGRAM VL-BELL-USE.
