*> Zombie family and spider hits of the overworld hostile mobs (002-lane-mobsfull-h3; docs/protocol/20 sections 4.3 and 7.2).
*>
*> Entry points:
*>   STDMOB-HIT-EFFECT USING player row, table row: the effect a melee hit gives its victim (SM-HITFX of core/copy/STDMOBS.cpy). Hunger (1, the husk, 4.3):
*>     amplifier 0 for 140 x floor(effective difficulty) ticks. Poison (2, the cave spider, 7.2): amplifier 0 for 7 s on Normal, 15 s on Hard, none on
*>     Easy. The effective difficulty is STDMOB-DIFFICULTY of the world time, with the chunk's inhabited time and the moon not tracked (0).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HIT-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-GAME-TIME           BINARY-DOUBLE.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-EFF                 BINARY-LONG.
 01 WS-HUNGER              BINARY-LONG VALUE 16.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-WITHER              BINARY-LONG VALUE 19.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-M.
     EVALUATE SM-HITFX(L-M)
         WHEN 1
             *> T of 3.2 is the world game time, not the time of day.
             COMPUTE WS-GAME-TIME = CW-GAME-TIME + CW-TICKS
             CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY WS-GAME-TIME WS-INHABITED WS-MOON WS-EFF
             COMPUTE WS-FLOOR = WS-EFF / 1000
             COMPUTE WS-DURATION = 140 * WS-FLOOR
             IF WS-DURATION > 0
                 CALL "EFFECT-ADD" USING L-PLAYER WS-HUNGER WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         WHEN 2
             MOVE 0 TO WS-DURATION
             IF BW-DIFFICULTY = 2
                 MOVE 140 TO WS-DURATION
             END-IF
             IF BW-DIFFICULTY = 3
                 MOVE 300 TO WS-DURATION
             END-IF
             IF WS-DURATION > 0
                 CALL "EFFECT-ADD" USING L-PLAYER WS-POISON WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         WHEN 3
*>           The wither skeleton (21 section 5.4): Wither, amplifier 0, for 200 ticks on every difficulty.
             MOVE 200 TO WS-DURATION
             CALL "EFFECT-ADD" USING L-PLAYER WS-WITHER WS-AMPLIFIER WS-DURATION WS-FLAGS
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-HIT-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPEED.
*> USING tracker row, table row, speed out (FLOAT-LONG blocks per tick): the walk speed of a standard mob (SM-WALK-MILLI) with the speed modifier of a baby
*> zombie, zombie villager or husk (4.1 step 3: +0.5 multiplied-base on the movement speed, so the squared speed that SM-WALK-MILLI is made of is 2.25 times); a mob with Speed (EN-FX-SPEED) walks 1.2 times as fast; a witch that is drinking does not walk (the drinking modifier -0.25 takes its speed to 0, 11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-SPEED.
     COMPUTE L-SPEED = SM-WALK-MILLI(L-M) / 1000
     IF EN-VARIANT(L-ROW) = 1 AND (SM-KEY(L-M) = "zombie" OR SM-KEY(L-M) = "zombie_villager" OR SM-KEY(L-M) = "husk")
         COMPUTE L-SPEED = L-SPEED * 2.25
     END-IF
     IF EN-FX-SPEED(L-ROW) NOT = 0
         COMPUTE L-SPEED = L-SPEED * 1.2
     END-IF
     IF SM-KEY(L-M) = "witch" AND EN-DRAW(L-ROW) > 0
         MOVE 0 TO L-SPEED
     END-IF
*>   A strider that is not on or in lava is suffocating: the speed modifier -0.34 multiplied-base (21 section 5.7), the squared speed 0.66 squared.
     IF EN-COLD(L-ROW) = 1 AND SM-KEY(L-M) = "strider"
         COMPUTE L-SPEED = L-SPEED * 0.4356
     END-IF
*>   An angry zombified piglin has the transient +0.05 speed modifier (21 section 5.5.3): (0.23 + 0.05) squared / 0.454.
     IF EN-ANGER(L-ROW) > 0 AND SM-KEY(L-M) = "zombified_piglin"
         COMPUTE L-SPEED = 173 / 1000
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-REINFORCE.
*> USING tracker row of a mob that was just hurt, attacker player row (0 none): zombie reinforcements (4.1, hurtServer). Only a zombie, zombie villager or husk
*> on Hard difficulty with hostile mobs on, whose target (else the attacker) is a living player: with probability EN-REINF (ten-thousandths) it calls a
*> zombie of its own type. Up to 50 attempts offset the call by nextInt(7..40) x nextInt(-1..1) on each axis from its block; a spot is taken when the
*> chunk is generated, a two-cell standable place (STDMOB-STANDABLE, which also refuses liquid) and no living player of the dimension within 7 blocks. The
*> new mob is finalized, targets that player, and the caller and the callee each have their chance lowered by 0.05 (500, never below 0). The spawn reason
*> reason REINFORCEMENT does not skip the dark check (54 section 12.1): in the Overworld a spot also needs the check of DARK-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY XORO.
 01 WS-M                   BINARY-LONG.
 01 WS-WHO                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-D                   FLOAT-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SPAN                BINARY-LONG VALUE 34.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 2.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BOUND-SKY           BINARY-LONG VALUE 32.
 01 WS-BOUND-BRIGHT        BINARY-LONG VALUE 8.
 01 WS-SAMPLE              BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-RULE-MONSTERS       PIC X(40) VALUE "spawn_monsters".
 01 WS-RULE-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "zombie" AND SM-KEY(WS-M) NOT = "zombie_villager" AND SM-KEY(WS-M) NOT = "husk"
         GOBACK
     END-IF
     CALL "BR-WORLD-READY"
     IF BW-DIFFICULTY NOT = 3 OR CS-HOSTILE-MOBS NOT = 1 OR EN-REINF(L-ROW) <= 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-MONSTERS WS-RULE-VALUE
     IF WS-RULE-VALUE = 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-MOBS WS-RULE-VALUE
     IF WS-RULE-VALUE = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-WHO
     IF WS-WHO = 0
         MOVE L-ATTACKER TO WS-WHO
     END-IF
     IF WS-WHO = 0
         GOBACK
     END-IF
     IF PL-USED(WS-WHO) NOT = 1 OR PL-STATE(WS-WHO) NOT = PS-ALIVE
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     COMPUTE WS-SEED = EN-ID(L-ROW) * 1000003 + CW-TICKS
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-D
     IF WS-D * 10000 >= EN-REINF(L-ROW)
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > 50 OR WS-DONE = 1
         CALL "XORO-NEXT-INT" USING XR-STATE WS-SPAN WS-R
         CALL "XORO-NEXT-INT" USING XR-STATE WS-THREE WS-S
         COMPUTE WS-CELL-X = FUNCTION INTEGER(EN-X(L-ROW)) + (WS-R + 7) * (WS-S - 1)
         CALL "XORO-NEXT-INT" USING XR-STATE WS-SPAN WS-R
         CALL "XORO-NEXT-INT" USING XR-STATE WS-THREE WS-S
         COMPUTE WS-CELL-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + (WS-R + 7) * (WS-S - 1)
         CALL "XORO-NEXT-INT" USING XR-STATE WS-SPAN WS-R
         CALL "XORO-NEXT-INT" USING XR-STATE WS-THREE WS-S
         COMPUTE WS-CELL-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + (WS-R + 7) * (WS-S - 1)
         COMPUTE WS-CX = FUNCTION INTEGER(WS-CELL-X / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-CELL-Z / 16)
         CALL "STDMOB-READY" USING WS-DIM WS-CX WS-CZ WS-READY
         MOVE 0 TO WS-OK
         IF WS-READY = 1
             CALL "STDMOB-STANDABLE" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-HEIGHT WS-OK
         END-IF
         IF WS-OK = 1
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                 IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = WS-DIM
                     COMPUTE WS-DX = PL-X(WS-P) - (WS-CELL-X + 0.5)
                     COMPUTE WS-DY = PL-Y(WS-P) - WS-CELL-Y
                     COMPUTE WS-DZ = PL-Z(WS-P) - (WS-CELL-Z + 0.5)
                     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 49
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         IF WS-OK = 1 AND WS-DIM = CW-DIM(1)
             *> The monster dark check of the Overworld for the spot (20 section 3.3, 54 section 12.1: the reason REINFORCEMENT does not skip it): sky light (less the night
             *> darkening) not above a fresh nextInt(32), no block light, and the brightness (a flat 10 in a thunderstorm) not above one nextInt(8) sample.
             CALL "STDMOB-LIGHTS" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-SKY WS-BLOCK
             CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
             COMPUTE WS-SKY = FUNCTION MAX(0, WS-SKY - WS-DARK)
             CALL "XORO-NEXT-INT" USING XR-STATE WS-BOUND-SKY WS-SAMPLE
             IF WS-SKY > WS-SAMPLE OR WS-BLOCK > 0
                 MOVE 0 TO WS-OK
             ELSE
                 COMPUTE WS-BRIGHT = FUNCTION MAX(WS-SKY, WS-BLOCK)
                 IF CW-THUNDERING = 1
                     MOVE 10 TO WS-BRIGHT
                 END-IF
                 CALL "XORO-NEXT-INT" USING XR-STATE WS-BOUND-BRIGHT WS-SAMPLE
                 IF WS-BRIGHT > WS-SAMPLE
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
         END-IF
         IF WS-OK = 1
             MOVE 1 TO WS-DONE
             COMPUTE WS-X = WS-CELL-X + 0.5
             COMPUTE WS-Z = WS-CELL-Z + 0.5
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-D
             COMPUTE WS-YAW = WS-D * 360
             MOVE WS-CELL-Y TO WS-Y
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
             CALL "STDMOB-FINALIZE" USING XR-STATE WS-NEW
             MOVE WS-WHO TO EN-TARGET(WS-NEW)
             MOVE PL-ENTITY-ID(WS-WHO) TO EN-TARGET-ID(WS-NEW)
             COMPUTE EN-REINF(WS-NEW) = FUNCTION MAX(0, EN-REINF(WS-NEW) - 500)
             COMPUTE EN-REINF(L-ROW) = FUNCTION MAX(0, EN-REINF(L-ROW) - 500)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-REINFORCE.
