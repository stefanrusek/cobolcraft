*> The shulker's armour, arrow immunity and peek goal (lane p49d; docs/protocol/21 section 6.2). The raw peek amount is EN-VARIANT (0 closed, 30 a peek, 100 fully open); EN-WAKE is peekTime.
*> Entry points:
*>   SHULKER-HURT USING row, cause, ignored out: 1 for an arrow-type hit (CAUSE-ARROW) on a shulker that is closed (raw peek 0): the hit is ignored (hurtServer returns false).
*>   SHULKER-PEEK USING row: the goals of a shulker with no target: a lid that is open without a peek in progress closes (the attack goal's stop); a peek counts peekTime down and closes at
*>     0; a closed shulker opens by 30 with probability 1 / 40 a tick (ShulkerPeekGoal.canUse) and sets peekTime to 20 x (1 + nextInt(3)). The closed shulker's +20 armour is
*>     MOB-ARMOR-POINTS. Not done: the check that the shulker can stay at its position and face, the attach face and the teleport.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-IGNORED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-IGNORED.
     MOVE 0 TO L-IGNORED
     IF L-CAUSE = CAUSE-ARROW
         CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
         IF WS-M > 0
             IF SM-KEY(WS-M) = "shulker" AND EN-VARIANT(L-ROW) = 0
                 MOVE 1 TO L-IGNORED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHULKER-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-PEEK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 91.
 01 WS-B40                 BINARY-LONG VALUE 40.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-WAKE(L-ROW) > 0
         SUBTRACT 1 FROM EN-WAKE(L-ROW)
         IF EN-WAKE(L-ROW) = 0
             MOVE 0 TO EN-VARIANT(L-ROW)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
     IF EN-VARIANT(L-ROW) NOT = 0
         MOVE 0 TO EN-VARIANT(L-ROW)
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B40 WS-R
     IF WS-R = 0
         CALL "XP-RANDOM" USING WS-SALT WS-B3 WS-R
         COMPUTE EN-WAKE(L-ROW) = 20 * (1 + WS-R)
         MOVE 30 TO EN-VARIANT(L-ROW)
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM SHULKER-PEEK.
