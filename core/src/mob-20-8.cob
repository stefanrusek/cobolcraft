*> Enderman (002-lane-mobsfull-h5; docs/protocol/20 section 8.1): gaze anger, random teleport, teleport towards an entity.
*>
*> Entry points:
*>   STDMOB-ENDER-STARE USING view x, y, z, w x, y, z (FLOAT-LONG), disguised (BINARY-LONG), stared out   isBeingStaredBy
*>   STDMOB-ENDER-DEST-RANDOM USING xoro state, x, y, z, dest x, y, z out                              the random teleport destination
*>   STDMOB-ENDER-DEST-TOWARD USING xoro state, enderman x, y, z, entity x, eye y, z, dest x, y, z out  the destination towards an entity
*>   STDMOB-ENDER-TELEPORT USING tracker row, dest x, y, z (FLOAT-LONG), ok out                         randomTeleport: walk down to a floor and move
*>   STDMOB-ENDER-TRY USING xoro state, tracker row, ok out                                             up to 64 random teleports
*>   STDMOB-ENDER-AIM USING tracker row, table row                                                      the target of an enderman for this tick
*>   STDMOB-ENDER-TICK USING tracker row, table row: water and rain damage, the stare and distance teleports of an enderman that holds a target
*>   ENDER-HURT USING tracker row, cause, handled out: the damage reactions (arrow: ignored and up to 64 teleports; no living attacker: teleport with probability 1/10)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-STARE.
*> The player is staring when no gaze-disguise item is worn (carved pumpkin) and dot(v / |v|, w / |w|) > 1 - 0.025 / |w|, where v is the player's view vector
*> and w the vector from the player's eye to the enderman's eye-height position (8.1, gaze anger). The line of sight is not tested (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LV                  FLOAT-LONG.
 01 WS-LW                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-WX                   FLOAT-LONG.
 01 L-WY                   FLOAT-LONG.
 01 L-WZ                   FLOAT-LONG.
 01 L-DISGUISED            BINARY-LONG.
 01 L-STARED               BINARY-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-WX L-WY L-WZ L-DISGUISED L-STARED.
     MOVE 0 TO L-STARED
     IF L-DISGUISED = 1
         GOBACK
     END-IF
     COMPUTE WS-LV = FUNCTION SQRT(L-VX * L-VX + L-VY * L-VY + L-VZ * L-VZ)
     COMPUTE WS-LW = FUNCTION SQRT(L-WX * L-WX + L-WY * L-WY + L-WZ * L-WZ)
     IF WS-LV = 0 OR WS-LW = 0
         GOBACK
     END-IF
     COMPUTE WS-DOT = (L-VX * L-WX + L-VY * L-WY + L-VZ * L-WZ) / (WS-LV * WS-LW)
     IF WS-DOT > 1 - 0.025 / WS-LW
         MOVE 1 TO L-STARED
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ENDER-STARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-DEST-RANDOM.
*> x + (nextDouble - 0.5) x 64, y + (nextInt(64) - 32), z + (nextDouble - 0.5) x 64, drawn in that order (8.1, random teleport).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-64                  BINARY-LONG VALUE 64.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-DX L-DY L-DZ.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE L-DX = L-X + (WS-D - 0.5) * 64
     CALL "XORO-NEXT-INT" USING L-STATE WS-64 WS-N
     COMPUTE L-DY = L-Y + WS-N - 32
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE L-DZ = L-Z + (WS-D - 0.5) * 64
     GOBACK.
 END PROGRAM STDMOB-ENDER-DEST-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-DEST-TOWARD.
*> v = normalize(enderman x - e x, enderman y + 0.5 - e eye y, enderman z - e z); dest x = enderman x + (nextDouble - 0.5) x 8 - v x x 16,
*> y = enderman y + (nextInt(16) - 8) - v y x 16, z likewise (draw order x, y, z): 16 blocks towards the entity, jittered (8.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-N                   BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-EX L-EY L-EZ L-DX L-DY L-DZ.
     COMPUTE WS-VX = L-X - L-EX
     COMPUTE WS-VY = L-Y + 0.5 - L-EY
     COMPUTE WS-VZ = L-Z - L-EZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-VX * WS-VX + WS-VY * WS-VY + WS-VZ * WS-VZ)
     IF WS-LEN > 0
         COMPUTE WS-VX = WS-VX / WS-LEN
         COMPUTE WS-VY = WS-VY / WS-LEN
         COMPUTE WS-VZ = WS-VZ / WS-LEN
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE L-DX = L-X + (WS-D - 0.5) * 8 - WS-VX * 16
     CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-N
     COMPUTE L-DY = L-Y + WS-N - 8 - WS-VY * 16
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE L-DZ = L-Z + (WS-D - 0.5) * 8 - WS-VZ * 16
     GOBACK.
 END PROGRAM STDMOB-ENDER-DEST-TOWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-TELEPORT.
*> USING tracker row, destination x, y, z (FLOAT-LONG), ok out: randomTeleport (8.1): from the destination's block walk down while the block below is not
*> solid (to the world's bottom); at the first stand-able cell (feet and head passable, no liquid in them, solid below: STDMOB-STANDABLE) the enderman moves
*> to the centre of that column and Entity Event 46 goes to the viewers. Liquids below, fire and the other dangerous blocks refuse: a cell of type 2
*> (water, lava, fire) in the feet, head or floor cell fails. Level event 2018 goes out at both ends; a riding enderman (EN-MOUNT) never teleports. The world border and loaded-chunk test are open.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 46.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-STAND               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-DEP-X               FLOAT-LONG.
 01 WS-DEP-Y               FLOAT-LONG.
 01 WS-DEP-Z               FLOAT-LONG.
 01 WS-EV-TELEPORT         PIC X(32) VALUE "teleport".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LEVEL-EVENT         BINARY-LONG VALUE 2018.
 01 WS-DATA                BINARY-LONG VALUE 0.
 01 WS-NO-ONE              BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK WS-DONE
*>   A riding enderman never teleports (8.1).
     IF EN-MOUNT(L-ROW) > 0
         GOBACK
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(L-X)
     COMPUTE WS-BY = FUNCTION INTEGER(L-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
     PERFORM UNTIL WS-DONE = 1
         COMPUTE WS-BELOW = WS-BY - 1
         CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-KIND
         IF WS-KIND = 1 OR WS-BY <= DM-MIN-Y(EN-DIM(L-ROW))
             MOVE 1 TO WS-DONE
         ELSE
             SUBTRACT 1 FROM WS-BY
         END-IF
     END-PERFORM
     COMPUTE WS-HEAD = WS-BY + 1
     CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KIND
     MOVE WS-KIND TO WS-STAND
     CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-BX WS-HEAD WS-BZ WS-KIND
     IF WS-KIND NOT = 0
         MOVE 2 TO WS-STAND
     END-IF
     COMPUTE WS-BELOW = WS-BY - 1
     CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-BX WS-BELOW WS-BZ WS-GROUND
     IF WS-STAND = 0 AND WS-GROUND = 1
         COMPUTE WS-FX = WS-BX + 0.5
         MOVE WS-BY TO WS-FY
         COMPUTE WS-FZ = WS-BZ + 0.5
         MOVE EN-YAW(L-ROW) TO WS-YAW
         MOVE EN-PITCH(L-ROW) TO WS-PITCH
         COMPUTE WS-OX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-OY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-OZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-LEVEL-EVENT WS-OX WS-OY WS-OZ WS-DATA WS-NO-ONE
         MOVE EN-X(L-ROW) TO WS-DEP-X
         MOVE EN-Y(L-ROW) TO WS-DEP-Y
         MOVE EN-Z(L-ROW) TO WS-DEP-Z
         CALL "ENTITY-MOVE" USING L-ROW WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-GROUND
         CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-LEVEL-EVENT WS-BX WS-BY WS-BZ WS-DATA WS-NO-ONE
*>       Enderman.teleport: the game event teleport at the position before the move (the departure point), the enderman as the source (30-8 14.3.10)
         CALL "GAME-EVENT" USING EN-DIM(L-ROW) WS-DEP-X WS-DEP-Y WS-DEP-Z WS-EV-TELEPORT L-ROW WS-NO-STATE
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ENDER-TELEPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-TRY.
*> USING xoro state, tracker row, ok out: repeatedlyTryToTeleport (8.1): up to 64 random teleports, stopping at the first success.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-OK.
     MOVE 0 TO L-OK
     MOVE L-ROW TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64 OR L-OK = 1
         CALL "STDMOB-ENDER-DEST-RANDOM" USING L-STATE EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW) WS-X WS-Y WS-Z
         CALL "STDMOB-ENDER-TELEPORT" USING WS-ROW WS-X WS-Y WS-Z L-OK
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-ENDER-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-AIM.
*> USING tracker row, table row of an enderman: its target for this tick (8.1). A target it has is kept while STDMOB-TARGET allows it (range 64, alive,
*> survival, same dimension). Without one it takes the nearest alive survival player of its dimension within 64 blocks who stares at it
*> (STDMOB-ENDER-STARE; the carved pumpkin disguise is not read yet, open) and the target change time restarts (EN-ENDER-TICKS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-RAD-Y               FLOAT-LONG.
 01 WS-RAD-P               FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-DISGUISE            BINARY-LONG VALUE 0.
 01 WS-STARED              BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     ADD 1 TO EN-ENDER-TICKS(L-ROW)
     CALL "STDMOB-ENDER-TICK" USING L-ROW L-M
     IF EN-USED(L-ROW) = 0 OR EN-HEALTH(L-ROW) = 0
         GOBACK
     END-IF
     IF EN-TARGET(L-ROW) > 0
         CALL "STDMOB-TARGET" USING L-ROW L-M
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-WX = EN-X(L-ROW) - PL-X(WS-P)
             COMPUTE WS-WY = EN-Y(L-ROW) + 2.55 - (PL-Y(WS-P) + 1.62)
             COMPUTE WS-WZ = EN-Z(L-ROW) - PL-Z(WS-P)
             COMPUTE WS-D2 = WS-WX * WS-WX + WS-WY * WS-WY + WS-WZ * WS-WZ
             COMPUTE WS-RAD-Y = PL-YAW(WS-P) * FUNCTION PI / 180
             COMPUTE WS-RAD-P = PL-PITCH(WS-P) * FUNCTION PI / 180
             COMPUTE WS-VX = - FUNCTION SIN(WS-RAD-Y) * FUNCTION COS(WS-RAD-P)
             COMPUTE WS-VY = - FUNCTION SIN(WS-RAD-P)
             COMPUTE WS-VZ = FUNCTION COS(WS-RAD-Y) * FUNCTION COS(WS-RAD-P)
             CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DISGUISE WS-STARED
             IF WS-STARED = 1 AND WS-D2 <= WS-LIMIT AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE WS-P TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE WS-BEST TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
         MOVE 0 TO EN-ENDER-TICKS(L-ROW)
         CALL "ENDER-STARED-SET" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ENDER-AIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ENDER-TICK.
*> USING tracker row, table row of an enderman: called by STDMOB-ENDER-AIM once a tick while it holds a target (8.1). Water-sensitive (18 section 2.6 step 12): standing in a water
*> block, or in rain with the sky open, it takes 1 point (CAUSE-DROWN) every tick. The target's stare: staring (STDMOB-ENDER-STARE) within 4 blocks (squared distance below 16) it
*> teleports (one random teleport); farther than 16 blocks (squared distance above 256) for 30 consecutive ticks (EN-STRAFE-TIME counts them, an enderman never strafes) it teleports towards
*> the target; by day with 600 ticks since the target changed it loses the target and teleports (the daylight rule). The random numbers are seeded from the entity id and the world tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY RULES.
 COPY STDMOBS.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-T                   BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-AMBIENT             BINARY-LONG VALUE 0.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-DROWN.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RAD-Y               FLOAT-LONG.
 01 WS-RAD-P               FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DISGUISE            BINARY-LONG VALUE 0.
 01 WS-STARED              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EYE-Y               FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE 0 TO WS-WET
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
     IF WS-STATE > 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "water"
         IF WS-N > 0
             MOVE 1 TO WS-WET
         END-IF
     END-IF
     COMPUTE WS-EYE = WS-BY + 1
     CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) WS-BX WS-EYE WS-BZ WS-SKY WS-BLK
     CALL "WEATHER-RAINING" USING EN-DIM(L-ROW) WS-RAIN
     IF WS-RAIN = 1 AND WS-SKY >= 15
         MOVE 1 TO WS-WET
     END-IF
     IF WS-WET = 1
         MOVE 0 TO EN-HURT(L-ROW)
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE
         IF EN-USED(L-ROW) = 0 OR EN-HEALTH(L-ROW) = 0
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-SEED = EN-ID(L-ROW) * 1000003 + CW-TICKS
     CALL "XORO-SEED" USING WS-SEED XR-STATE
*>   Daylight (8.1): bright outside (the day half of the monsters_burn window), 600 ticks since the target changed, the sky visible, brightness above 0.5 and
*>   nextFloat x 30 below (B - 0.4) x 2: the target is cleared and it teleports.
     COMPUTE WS-T = FUNCTION MOD(CW-TIME, 24000)
     IF EN-ENDER-TICKS(L-ROW) >= 600 AND WS-SKY >= 15 AND NOT (WS-T >= SM-BURN-DAY-END AND WS-T < SM-BURN-DAY-START)
         CALL "STDMOB-BRIGHTNESS" USING WS-SKY WS-AMBIENT WS-BRIGHT
         CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
         IF WS-BRIGHT > 500 AND WS-DRAW * 30 < (WS-BRIGHT / 1000 - 0.4) * 2
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
             CALL "STDMOB-ENDER-DEST-RANDOM" USING XR-STATE EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-DX WS-DY WS-DZ
             CALL "STDMOB-ENDER-TELEPORT" USING L-ROW WS-DX WS-DY WS-DZ WS-OK
         END-IF
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0
         GOBACK
     END-IF
     COMPUTE WS-WX = EN-X(L-ROW) - PL-X(WS-P)
     COMPUTE WS-WY = EN-Y(L-ROW) + 2.55 - (PL-Y(WS-P) + 1.62)
     COMPUTE WS-WZ = EN-Z(L-ROW) - PL-Z(WS-P)
     COMPUTE WS-D2 = WS-WX * WS-WX + WS-WY * WS-WY + WS-WZ * WS-WZ
     COMPUTE WS-RAD-Y = PL-YAW(WS-P) * FUNCTION PI / 180
     COMPUTE WS-RAD-P = PL-PITCH(WS-P) * FUNCTION PI / 180
     COMPUTE WS-VX = - FUNCTION SIN(WS-RAD-Y) * FUNCTION COS(WS-RAD-P)
     COMPUTE WS-VY = - FUNCTION SIN(WS-RAD-P)
     COMPUTE WS-VZ = FUNCTION COS(WS-RAD-Y) * FUNCTION COS(WS-RAD-P)
     CALL "STDMOB-ENDER-STARE" USING WS-VX WS-VY WS-VZ WS-WX WS-WY WS-WZ WS-DISGUISE WS-STARED
     IF WS-STARED = 1 AND WS-D2 < 16
         CALL "STDMOB-ENDER-DEST-RANDOM" USING XR-STATE EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-DX WS-DY WS-DZ
         CALL "STDMOB-ENDER-TELEPORT" USING L-ROW WS-DX WS-DY WS-DZ WS-OK
     END-IF
     IF WS-D2 > 256
         ADD 1 TO EN-STRAFE-TIME(L-ROW)
         IF EN-STRAFE-TIME(L-ROW) >= 30
             COMPUTE WS-EYE-Y = PL-Y(WS-P) + 1.62
             CALL "STDMOB-ENDER-DEST-TOWARD" USING XR-STATE EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) PL-X(WS-P) WS-EYE-Y
                 PL-Z(WS-P) WS-DX WS-DY WS-DZ
             CALL "STDMOB-ENDER-TELEPORT" USING L-ROW WS-DX WS-DY WS-DZ WS-OK
             MOVE 0 TO EN-STRAFE-TIME(L-ROW)
         END-IF
     ELSE
         MOVE 0 TO EN-STRAFE-TIME(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ENDER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-HURT.
*> USING tracker row, cause, handled out (1: the damage is ignored): hurtServer of an enderman (8.1). An arrow (CAUSE-ARROW, the damage tagged is_projectile; the other projectiles reach
*> the core as CAUSE-MOB hits and are not told apart) is ignored after up to 64 teleports. Any cause whose attacker is no living entity (not CAUSE-PLAYER, CAUSE-MOB) teleports it with
*> probability 1/10 and the damage then applies as usual.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-M                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "enderman"
         GOBACK
     END-IF
     COMPUTE WS-SEED = EN-ID(L-ROW) * 1000003 + CW-TICKS
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     EVALUATE TRUE
         WHEN L-CAUSE = CAUSE-ARROW
             MOVE 1 TO L-HANDLED
             CALL "STDMOB-ENDER-TRY" USING XR-STATE L-ROW WS-OK
         WHEN L-CAUSE NOT = CAUSE-PLAYER AND L-CAUSE NOT = CAUSE-MOB
             CALL "XORO-NEXT-INT" USING XR-STATE WS-TEN WS-ROLL
             IF WS-ROLL = 0
                 CALL "STDMOB-ENDER-DEST-RANDOM" USING XR-STATE EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-DX WS-DY WS-DZ
                 CALL "STDMOB-ENDER-TELEPORT" USING L-ROW WS-DX WS-DY WS-DZ WS-OK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM ENDER-HURT.
