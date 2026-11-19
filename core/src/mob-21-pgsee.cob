*> The visibility of a player to a mob (docs/protocol/18-mob-framework.md section 4.3 getVisibilityPercent, 44-3 section 4.7, 44-6 section 2.7 detection range; lane 002-lane-p49s, T38540 to T38545).
*>   MOB-PLAYER-VIS USING mob row, player row, v out (FLOAT-LONG)       1.0, x 0.8 crouching (pose 5), invisible (Invisibility, effect id 13): x max(worn armour slots / 4, 0.1) x 0.7, a head item
*>                                                                       with the mob_visibility component (skeleton skull for a skeleton, zombie head for a zombie, creeper head for a
*>                                                                       creeper, piglin head for a piglin or brute) x 0.5; the clamp of 0 to 10 never acts (every factor is between 0 and 1)
*>   MOB-SEE-RANGE2 USING follow range, v (FLOAT-LONG), squared range out   max(R x v, 2) squared: the squared distance a TargetingConditions test accepts (a brute: R = 12, a piglin 16)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PLAYER-VIS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-INVISIBILITY        BINARY-LONG VALUE 13.
 01 WS-S                   BINARY-LONG.
 01 WS-WORN                BINARY-LONG.
 01 WS-COVER               FLOAT-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-MOB                 PIC X(24).
 LINKAGE SECTION.
 01 L-MOB                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-V                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-MOB L-PLAYER L-V.
     MOVE 1 TO L-V
     IF PL-POSE(L-PLAYER) = 5
         COMPUTE L-V = L-V * 0.8
     END-IF
     CALL "EFFECT-LEVEL" USING L-PLAYER WS-INVISIBILITY WS-LEVEL WS-TICKS
     IF WS-LEVEL > 0
         MOVE 0 TO WS-WORN
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 4
             IF MN-EQUIP-COUNT(L-PLAYER, WS-S) > 0
                 ADD 1 TO WS-WORN
             END-IF
         END-PERFORM
         COMPUTE WS-COVER = WS-WORN / 4
         IF WS-COVER < 0.1
             MOVE 0.1 TO WS-COVER
         END-IF
         COMPUTE L-V = L-V * WS-COVER * 0.7
     END-IF
     MOVE SPACES TO WS-MOB
     CALL "STDMOB-INDEX" USING EN-TYPE(L-MOB) WS-M
     IF WS-M > 0
         MOVE SM-KEY(WS-M) TO WS-MOB
     END-IF
     IF MN-EQUIP-COUNT(L-PLAYER, 4) > 0
         MOVE MN-EQUIP-ITEM(L-PLAYER, 4) TO WS-ITEM
         IF WS-ITEM >= 0 AND WS-ITEM < IT-COUNT
             MOVE IT-KEY(WS-ITEM + 1) TO WS-KEY
             IF (WS-KEY = "skeleton_skull" OR WS-KEY = "minecraft:skeleton_skull") AND WS-MOB = "skeleton"
                 COMPUTE L-V = L-V * 0.5
             END-IF
             IF (WS-KEY = "zombie_head" OR WS-KEY = "minecraft:zombie_head") AND WS-MOB = "zombie"
                 COMPUTE L-V = L-V * 0.5
             END-IF
             IF (WS-KEY = "creeper_head" OR WS-KEY = "minecraft:creeper_head") AND WS-MOB = "creeper"
                 COMPUTE L-V = L-V * 0.5
             END-IF
             IF (WS-KEY = "piglin_head" OR WS-KEY = "minecraft:piglin_head") AND (WS-MOB = "piglin" OR WS-MOB = "piglin_brute")
                 COMPUTE L-V = L-V * 0.5
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-PLAYER-VIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SEE-RANGE2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EFFECTIVE           FLOAT-LONG.
 LINKAGE SECTION.
 01 L-RANGE                FLOAT-LONG.
 01 L-V                    FLOAT-LONG.
 01 L-RANGE2               FLOAT-LONG.
 PROCEDURE DIVISION USING L-RANGE L-V L-RANGE2.
     COMPUTE WS-EFFECTIVE = L-RANGE * L-V
     IF WS-EFFECTIVE < 2
         MOVE 2 TO WS-EFFECTIVE
     END-IF
     COMPUTE L-RANGE2 = WS-EFFECTIVE * WS-EFFECTIVE
     GOBACK.
 END PROGRAM MOB-SEE-RANGE2.
