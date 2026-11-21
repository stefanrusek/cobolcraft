*> The creeper's lingering cloud (docs/protocol/20 section 6.1, spawnLingeringCloud; lane 002-lane-mobsb7, T9515). The charge by lightning is LIGHTNING-HIT of lane mobsb6 (EN-VARIANT 1,
*> metadata 17, double power in STDMOB-SWELL).
*>   CREEPER-CLOUD USING creeper row    when the creeper has active mob effects (MOBEFFECT.cpy): an area effect cloud at it with radius 2.5, radius on use -0.5, wait time 10, duration 300,
*>                                      potion duration scale 0.25, radius per tick -radius / duration and a copy of each active effect (up to the 4 a cloud holds)
*> Gaps: triggerOnDeathMobEffects, the charged creeper's skull drop (charged_creeper/root: needs the killer bookkeeping and head items), the cloud's colour from the effects.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREEPER-CLOUD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY MOBEFFECT.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CLOUD               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RADIUS              FLOAT-LONG VALUE 2.5.
 01 WS-DURATION            BINARY-LONG VALUE 300.
 01 WS-WAIT                BINARY-LONG VALUE 10.
 01 WS-REAPP               BINARY-LONG VALUE 20.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX
         IF ME-ENT(WS-I) = EN-ID(L-ROW)
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-OWNER WS-CLOUD
     IF WS-CLOUD = 0
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(WS-CLOUD) WS-SLOT
     MOVE -0.5 TO PJ-ROU(WS-SLOT)
     COMPUTE PJ-RPT(WS-SLOT) = -2.5 / 300
     MOVE 250 TO PJ-SCALE(WS-SLOT)
     MOVE 0 TO PJ-FXN(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ME-MAX
         IF ME-ENT(WS-I) = EN-ID(L-ROW) AND PJ-FXN(WS-SLOT) < 4
             ADD 1 TO PJ-FXN(WS-SLOT)
             MOVE ME-ID(WS-I) TO PJ-FX-ID(WS-SLOT, PJ-FXN(WS-SLOT))
             MOVE ME-AMP(WS-I) TO PJ-FX-AMP(WS-SLOT, PJ-FXN(WS-SLOT))
             MOVE ME-DUR(WS-I) TO PJ-FX-DUR(WS-SLOT, PJ-FXN(WS-SLOT))
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREEPER-CLOUD.
