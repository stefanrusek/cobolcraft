*> Piglins hunting hoglins (docs/protocol/21 sections 5.5.1 and 5.5.2, 5.6; lane 002-lane-mobsb5, T8911). State: core/copy/HUNT.cpy; the fight itself is MOBVS-TICK (EN-FOE).
*>   PIGLIN-HUNT-STEP USING piglin row   every tick: the HUNTED_RECENTLY gap counts down (30 to 120 s from the piglin's first step, and again after a kill); an adult piglin (not a
*>                                       brute: canHunt is false) with no player target and no foe, once the gap is over, takes the nearest visible adult hoglin within its follow range
*>                                       as its foe (EN-FOE)
*>   PIGLIN-HUNT-DONE USING piglin row   a kill: the foe is cleared and the gap restarts
*> The celebration after a kill is PGB-CELEBRATE (mob-21-brain.cob). Gaps: the exact branch conditions the document did not expand (hoglin counts, baby piglins), a crossbow piglin shoots
*> instead of hitting (it hits here), a piglin fleeing hoglins that outnumber it, the zoglin and zombified piglin fights, hoglin repellents.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PH-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY HUNT.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                    BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX OR L-SLOT > 0
         IF PH-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PH-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PH-GAP.
*> USING gap out: the hunting gap in ticks, 20 x (30 + nextInt(91)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                 BINARY-LONG VALUE 79.
 01 WS-BOUND                BINARY-LONG VALUE 91.
 01 WS-DRAW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-GAP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-GAP.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     COMPUTE L-GAP = 20 * (30 + WS-DRAW)
     GOBACK.
 END PROGRAM PH-GAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-HUNT-DONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY HUNT.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-FOE                  BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 103.
 01 WS-BOUND                BINARY-LONG VALUE 10.
 01 WS-DRAW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*>   The kill is celebrated (StartCelebratingIfTargetDead: 300 ticks at the place, dancing with probability 1/10).
     MOVE EN-FOE(L-ROW) TO WS-FOE
     IF WS-FOE > 0
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         CALL "PGB-CELEBRATE" USING L-ROW WS-FOE WS-DRAW
     END-IF
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
     CALL "PH-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         CALL "PH-GAP" USING PH-TIMER(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-HUNT-DONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-HUNT-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY HUNT.
 01 WS-M                    BINARY-LONG.
 01 WS-S                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-F                    BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-LIMIT                FLOAT-LONG.
 01 WS-AX                   FLOAT-LONG.
 01 WS-AY                   FLOAT-LONG.
 01 WS-AZ                   FLOAT-LONG.
 01 WS-BY                   FLOAT-LONG.
 01 WS-SEES                 BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-BLOCKED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "piglin" OR EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     CALL "PH-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX OR WS-SLOT > 0
             IF PH-ID(WS-I) = 0
                 MOVE EN-ID(L-ROW) TO PH-ID(WS-I)
                 CALL "PH-GAP" USING PH-TIMER(WS-I)
                 MOVE WS-I TO WS-SLOT
             END-IF
         END-PERFORM
     END-IF
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PH-TIMER(WS-SLOT) > 0
         SUBTRACT 1 FROM PH-TIMER(WS-SLOT)
         GOBACK
     END-IF
     IF EN-TARGET(L-ROW) > 0 OR EN-FOE(L-ROW) > 0
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = SM-FOLLOW(WS-M) * SM-FOLLOW(WS-M)
     MOVE 0 TO WS-F
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-N) >= 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             IF WS-S > 0
                 IF SM-KEY(WS-S) = "hoglin"
                     COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 <= WS-LIMIT AND (WS-F = 0 OR WS-D2 < WS-BEST)
                         MOVE EN-X(L-ROW) TO WS-AX
                         COMPUTE WS-AY = EN-Y(L-ROW) + 1.5
                         MOVE EN-Z(L-ROW) TO WS-AZ
                         COMPUTE WS-BY = EN-Y(WS-N) + 1
                         CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ EN-X(WS-N) WS-BY EN-Z(WS-N) WS-SEES
                         IF WS-SEES = 1
                             MOVE WS-N TO WS-F
                             MOVE WS-D2 TO WS-BEST
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   44-6 section 2.8: none of the visible adult piglins may have hunted recently.
     IF WS-F > 0
         MOVE EN-X(L-ROW) TO WS-AX
         COMPUTE WS-AY = EN-Y(L-ROW) + 1.5
         MOVE EN-Z(L-ROW) TO WS-AZ
         MOVE 0 TO WS-BLOCKED
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                     AND EN-MOBAGE(WS-N) >= 0 AND FUNCTION ABS(EN-X(WS-N) - EN-X(L-ROW)) <= 16
                     AND FUNCTION ABS(EN-Y(WS-N) - EN-Y(L-ROW)) <= 16 AND FUNCTION ABS(EN-Z(WS-N) - EN-Z(L-ROW)) <= 16
                 CALL "PGAI-KIND" USING WS-N WS-K
                 IF WS-K = 1
                     COMPUTE WS-BY = EN-Y(WS-N) + 1
                     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ EN-X(WS-N) WS-BY EN-Z(WS-N) WS-SEES
                     CALL "PH-FIND" USING EN-ID(WS-N) WS-I
                     IF WS-SEES = 1 AND WS-I > 0
                         IF PH-TIMER(WS-I) > 0
                             MOVE 1 TO WS-BLOCKED
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BLOCKED = 1
             MOVE 0 TO WS-F
         END-IF
     END-IF
     IF WS-F > 0
         MOVE WS-F TO EN-FOE(L-ROW)
         MOVE EN-ID(WS-F) TO EN-FOE-ID(L-ROW)
*>       The hunter and every piglin near it start their pause together; the others join the hunt (broadcastAngerTarget).
         CALL "PGAI-GAP" USING L-ROW
         CALL "PGAI-BROADCAST" USING L-ROW WS-F
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-HUNT-STEP.
