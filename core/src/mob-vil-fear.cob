*> Villager panic from hostiles (docs/protocol/44 sections 2.14, 4.2 and 2.18; lane 002-lane-mobsb5, T8905).
*>   VL-FEAR-STEP USING villager row    on the 20 tick beat the villager_hostiles sensor finds the nearest listed hostile within its distance (drowned 8, evoker 12, husk 8,
*>                                      illusioner 12, pillager 15, ravager 12, vex 8, vindicator 10, zoglin 10, zombie 8, zombie villager 8); the panic (EN-FLEE, 21 ticks, fleeing
*>                                      from the hostile's position) starts, and while it runs a hostile within 6 blocks (squared 36) keeps it going.
*> Gaps: "visible" entities (no line of sight test), the panic does not erase the villager's other memories, hurt_by as a panic cause is the existing player flee.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-ROSTER.
*> USING count out, row table out (64 rows), limit table out (64 distances in blocks): the hostiles of the villager_hostiles table (44 section 4.2) among the living entities, found once per game tick (and per new entity id)
*> however many villagers ask (a type's table entry is looked up once per refresh, not once per entity).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-STAMP                BINARY-DOUBLE VALUE -1.
 01 WS-STAMP-ID             BINARY-LONG VALUE -1.
 01 WS-N                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG VALUE 0.
 01 WS-S                    BINARY-LONG.
 01 WS-LIMIT                BINARY-LONG.
 01 WS-ROWS.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIMITS.
    05 WS-LIM               BINARY-LONG OCCURS 64 TIMES.
 01 WS-MEMO.
    05 WS-MEMO-LIMIT        BINARY-LONG OCCURS 512 TIMES.
 01 WS-T                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                 BINARY-LONG.
 01 L-ROWS.
    05 L-ROW                BINARY-LONG OCCURS 64 TIMES.
 01 L-LIMITS.
    05 L-LIM                BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-ROWS L-LIMITS.
     IF WS-STAMP NOT = CW-TICKS OR WS-STAMP-ID NOT = CW-NEXT-ENTITY-ID
         MOVE CW-TICKS TO WS-STAMP
         MOVE CW-NEXT-ENTITY-ID TO WS-STAMP-ID
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 512
             MOVE -1 TO WS-MEMO-LIMIT(WS-T)
         END-PERFORM
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-TYPE(WS-N) < 512
                 COMPUTE WS-T = EN-TYPE(WS-N) + 1
                 IF WS-MEMO-LIMIT(WS-T) < 0
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                     MOVE 0 TO WS-LIMIT
                     IF WS-S > 0
                         EVALUATE SM-KEY(WS-S)
                             WHEN "drowned" MOVE 8 TO WS-LIMIT
                             WHEN "evoker" MOVE 12 TO WS-LIMIT
                             WHEN "husk" MOVE 8 TO WS-LIMIT
                             WHEN "illusioner" MOVE 12 TO WS-LIMIT
                             WHEN "pillager" MOVE 15 TO WS-LIMIT
                             WHEN "ravager" MOVE 12 TO WS-LIMIT
                             WHEN "vex" MOVE 8 TO WS-LIMIT
                             WHEN "vindicator" MOVE 10 TO WS-LIMIT
                             WHEN "zoglin" MOVE 10 TO WS-LIMIT
                             WHEN "zombie" MOVE 8 TO WS-LIMIT
                             WHEN "zombie_villager" MOVE 8 TO WS-LIMIT
                         END-EVALUATE
                     END-IF
                     MOVE WS-LIMIT TO WS-MEMO-LIMIT(WS-T)
                 END-IF
                 IF WS-MEMO-LIMIT(WS-T) > 0 AND WS-COUNT < 64
                     ADD 1 TO WS-COUNT
                     MOVE WS-N TO WS-ROW(WS-COUNT)
                     MOVE WS-MEMO-LIMIT(WS-T) TO WS-LIM(WS-COUNT)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-COUNT TO L-COUNT
     MOVE WS-ROWS TO L-ROWS
     MOVE WS-LIMITS TO L-LIMITS
     GOBACK.
 END PROGRAM VL-ROSTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FEAR-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY VLMEM.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-LIMIT                BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-HOSTILE              BINARY-LONG.
 01 WS-R-COUNT              BINARY-LONG.
 01 WS-R-ROWS.
    05 WS-R-ROW             BINARY-LONG OCCURS 64 TIMES.
 01 WS-R-LIMITS.
    05 WS-R-LIM             BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FUNCTION MOD(CW-TICKS, 20) NOT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND
     CALL "VL-ROSTER" USING WS-R-COUNT WS-R-ROWS WS-R-LIMITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-R-COUNT
         MOVE WS-R-ROW(WS-I) TO WS-N
         MOVE WS-R-LIM(WS-I) TO WS-LIMIT
         IF EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-USED(WS-N) = 1 AND EN-HEALTH(WS-N) > 0
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= WS-LIMIT * WS-LIMIT AND (WS-FOUND = 0 OR WS-D2 < WS-BEST)
                 MOVE 1 TO WS-FOUND
                 MOVE WS-D2 TO WS-BEST
                 MOVE WS-N TO WS-HOSTILE
             END-IF
         END-IF
     END-PERFORM
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         IF WS-FOUND = 1
             CALL "VM-NOTE-TTL" USING WS-SLOT MT-NEAREST-HOSTILE WS-HOSTILE EN-ID(WS-HOSTILE) WS-ZERO
         ELSE
             CALL "VM-ERASE" USING WS-SLOT MT-NEAREST-HOSTILE
         END-IF
     END-IF
     IF WS-FOUND = 1
         IF EN-FLEE(L-ROW) = 0 OR WS-BEST <= 36
             MOVE 21 TO EN-FLEE(L-ROW)
         END-IF
         MOVE 1 TO EN-FLEE-PLAYER(L-ROW)
         MOVE -1 TO EN-FLEE-ID(L-ROW)
         MOVE EN-X(WS-HOSTILE) TO EN-FLEE-X(L-ROW)
         MOVE EN-Z(WS-HOSTILE) TO EN-FLEE-Z(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM VL-FEAR-STEP.
