*> Witch (002-lane-mobsfull-h11; docs/protocol/20 section 11, 25 section 9.3, 17 section 4.9).
*>
*> Entry points:
*>   STDMOB-WITCH-PICK USING row, in water, on fire, target far, roll 1 to 4 (0 to 999), potion out: the four tests in order, the first that succeeds decides:
*>     (1) eyes in water, no Water Breathing, roll 1 below 150 (float 0.15): 5; (2) on fire, no Fire Resistance, roll 2 below 150: 6; (3) health below the maximum
*>     and roll 3 below 50: 7 Healing; (4) roll 4 below 500, a target, no Speed and the target farther than 11 blocks (far = 1): 8 Swiftness; else 0.
*>   STDMOB-WITCH-TICK USING row, table row, stop out: one tick of the witch's own logic. A potion in hand (EN-HAND 5 to 8) is drunk for EN-DRAW ticks left
*>     (32, the default drink of 1.6 s) and the witch stands still (stop 1; the drinking modifier takes its speed 0.25 to 0); at the end Water Breathing,
*>     Fire Resistance and Speed last 3600 ticks (EN-FX-WATER, -FIRE, -SPEED) and Healing heals 4 up to the maximum health. Not drinking, the four tests run with
*>     random rolls and a hit takes the potion in hand; with a target within 10 blocks (radius 10.0 of the ranged goal) the witch stands (stop 1).
*>   STDMOB-WITCH-SPARKLE USING roll (0 to 99999), hit out: nextFloat < 7.5E-4 (roll below 75): the witch broadcasts entity event 15 (witch particles) that tick; the tick draws the
*>     roll with its own salt after the drinking logic. The eyes-in-water test reads the block at feet + 1.62 (a water block).
*>   Open: the witch's thrown potions (no splash potion entity in the core), the 0.15 resistance to magic damage (damage kinds are not tracked), the raider goals.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-WITCH-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-FAR                  BINARY-LONG.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-R3                   BINARY-LONG.
 01 L-R4                   BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WATER L-FIRE L-FAR L-R1 L-R2 L-R3 L-R4 L-POTION.
     MOVE 0 TO L-POTION
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     EVALUATE TRUE
         WHEN L-WATER = 1 AND EN-FX-WATER(L-ROW) = 0 AND L-R1 < 150
             MOVE 5 TO L-POTION
         WHEN L-FIRE = 1 AND EN-FX-FIRE(L-ROW) = 0 AND L-R2 < 150
             MOVE 6 TO L-POTION
         WHEN EN-HEALTH(L-ROW) < SM-HEALTH(WS-M) AND L-R3 < 50
             MOVE 7 TO L-POTION
         WHEN L-R4 < 500 AND EN-TARGET(L-ROW) > 0 AND EN-FX-SPEED(L-ROW) = 0 AND L-FAR = 1
             MOVE 8 TO L-POTION
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-WITCH-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-WITCH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY CBLOCKS.
 01 WS-SALT                BINARY-LONG VALUE 11.
 01 WS-SALT-EVENT          BINARY-LONG VALUE 12.
 01 WS-BOUND-EVENT         BINARY-LONG VALUE 100000.
 01 WS-ROLL-EVENT          BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 15.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEYBLOCK            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-R4                  BINARY-LONG.
 01 WS-WATER               BINARY-LONG VALUE 0.
 01 WS-FIRE                BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-STOP.
     MOVE 0 TO L-STOP
     CALL "XP-RANDOM" USING WS-SALT-EVENT WS-BOUND-EVENT WS-ROLL-EVENT
     CALL "STDMOB-WITCH-SPARKLE" USING WS-ROLL-EVENT WS-HIT
     IF WS-HIT = 1
         CALL "MOB-ENTITY-EVENT" USING L-ROW WS-EVENT
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     MOVE 0 TO WS-D2
     IF WS-P > 0
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
             + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     END-IF
     IF EN-DRAW(L-ROW) > 0
         SUBTRACT 1 FROM EN-DRAW(L-ROW)
         MOVE 1 TO L-STOP
         IF EN-DRAW(L-ROW) = 0
             EVALUATE EN-HAND(L-ROW)
                 WHEN 5
                     MOVE 3600 TO EN-FX-WATER(L-ROW)
                 WHEN 6
                     MOVE 3600 TO EN-FX-FIRE(L-ROW)
                 WHEN 7
                     ADD 4 TO EN-HEALTH(L-ROW)
                     IF EN-HEALTH(L-ROW) > SM-HEALTH(L-M)
                         MOVE SM-HEALTH(L-M) TO EN-HEALTH(L-ROW)
                     END-IF
                 WHEN 8
                     MOVE 3600 TO EN-FX-SPEED(L-ROW)
             END-EVALUATE
             MOVE 0 TO EN-HAND(L-ROW)
         END-IF
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R3
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R4
     MOVE 0 TO WS-FIRE WS-FAR WS-WATER
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW) + 1.62)
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
     IF WS-STATE > 0
         COMPUTE WS-KEYBLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-KEYBLOCK) TALLYING WS-N FOR ALL "water"
         IF WS-N > 0
             MOVE 1 TO WS-WATER
         END-IF
     END-IF
     IF EN-BURN(L-ROW) > 0
         MOVE 1 TO WS-FIRE
     END-IF
     IF WS-D2 > 121
         MOVE 1 TO WS-FAR
     END-IF
     CALL "STDMOB-WITCH-PICK" USING L-ROW WS-WATER WS-FIRE WS-FAR WS-R1 WS-R2 WS-R3 WS-R4 WS-POTION
     IF WS-POTION > 0
         MOVE WS-POTION TO EN-HAND(L-ROW)
         MOVE 32 TO EN-DRAW(L-ROW)
         MOVE 1 TO L-STOP
         GOBACK
     END-IF
     IF WS-P > 0 AND WS-D2 <= 100
         MOVE 1 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM STDMOB-WITCH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-WITCH-SPARKLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL                 BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-HIT.
     MOVE 0 TO L-HIT
     IF L-ROLL < 75
         MOVE 1 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM STDMOB-WITCH-SPARKLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-ENTITY-EVENT.
*> USING tracker row, event id: an Entity Event (0x22) to the players that see the mob.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EVENT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) L-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-ENTITY-EVENT.
