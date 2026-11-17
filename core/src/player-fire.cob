*> A burning player (002-lane-fire, T11101; docs/protocol/17 sections 4.11 and 4.13, 18 section 2.5, 29a section 4.2, 29b-8 section 2.10): the fire ticks of a player of a
*> standard world are EN-BURN of its tracker row (PL-ENTITY-ROW), the same count the standard mobs use.
*>   PLAYER-FIRE-TICK USING player row   one tick for an alive player (HEALTH-TICK): a creative player has the fire cleared; otherwise, in the order of Entity.baseTick:
*>     water, rain on an exposed player and powder snow put the fire out; a burning count above 0 takes 1.0 on_fire damage on every tick where it is a multiple of 20 and
*>     the player is not in lava, then falls by 1; lava sets the count to at least 300 (fifteen seconds) and takes 4.0 lava damage; a fire block in the box (fire 1.0,
*>     soul fire 2.0, in_fire damage) adds nextInt(1, 3) to the count and sets it to at least 160 (eight seconds, GC8-FIRE-IGNITE); water puts out what lava or fire lit
*>     in the same tick. Fire Resistance (effect 11) takes no fire damage (the flames still show). Not done: Fire Protection shortening the burn time, the lava cauldron,
*>     the fall distance halved in lava, the sound.
*>   PLAYER-FIRE-SYNC USING player row   when the burning state differs from the last one sent (EN-FIRE-SENT) the flags byte (entry 0 bit 0, POSE-UPDATE) is sent to the
*>     viewers, and to the player itself
*>   PLAYER-IGNITE USING player row, ticks   igniteForTicks: the count rises to at least the given ticks (a creative player is not set alight)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-IGNITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TICKS.
     IF PL-ENTITY-ROW(L-ROW) > 0 AND PL-MODE(L-ROW) = 0
         IF EN-BURN(PL-ENTITY-ROW(L-ROW)) < L-TICKS
             MOVE L-TICKS TO EN-BURN(PL-ENTITY-ROW(L-ROW))
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAYER-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-FIRE-SYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-BURNING             BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-ENTITY-ROW(L-ROW) TO WS-T
     MOVE 0 TO WS-BURNING
     IF EN-BURN(WS-T) > 0
         MOVE 1 TO WS-BURNING
     END-IF
     IF WS-BURNING NOT = EN-FIRE-SENT(WS-T)
         MOVE WS-BURNING TO EN-FIRE-SENT(WS-T)
         CALL "POSE-UPDATE" USING L-ROW
         IF PL-CONN(L-ROW) > 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "POSE-DATA-BUILD" USING EN-ID(WS-T) PL-POSE-FLAGS(L-ROW) PL-POSE(L-ROW) PB-BUFFER
             CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAYER-FIRE-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-FIRE-SCAN.
*> USING player row, fire damage out (0 none, 1 fire, 2 soul fire), powder snow out (1 when a cell of the box holds powder snow or a water cauldron): the cells of the
*> player's box (0.6 wide, 1.8 high) read by the block effects (FIRE-SCAN-BOX).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HALF                FLOAT-LONG VALUE 0.3.
 01 WS-HEIGHT              FLOAT-LONG VALUE 1.8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-SNOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FIRE L-SNOW.
     CALL "FIRE-SCAN-BOX" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-HALF WS-HEIGHT L-FIRE L-SNOW
     GOBACK.
 END PROGRAM PLAYER-FIRE-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-FIRE-WET.
*> USING player row, wet out: 1 when water, rain on an exposed player or powder snow puts a burning player out (isInWaterOrRain and the EXTINGUISH block effect).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RAINING             BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 1800.
 01 WS-FIRE                BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WET.
     CALL "FLUID-TOUCHES-WATER" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) L-WET
     CALL "PLAYER-FIRE-SCAN" USING L-ROW WS-FIRE WS-SNOW
     IF WS-SNOW = 1
         MOVE 1 TO L-WET
     END-IF
     IF L-WET = 0
         CALL "WEATHER-RAINING" USING PL-DIM(L-ROW) WS-RAINING
         IF WS-RAINING = 1
             CALL "WEATHER-EXPOSED" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-HEIGHT WS-EXPOSED
             MOVE WS-EXPOSED TO L-WET
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAYER-FIRE-WET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-FIRE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY RULES.
 01 WS-T                   BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-HEIGHT              FLOAT-LONG VALUE 1.8.
 01 WS-KIND-LAVA           BINARY-LONG VALUE 2.
 01 WS-RESISTANCE-ID       BINARY-LONG VALUE 11.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-IMMUNE              BINARY-LONG VALUE 0.
 01 WS-IS-PLAYER           BINARY-LONG VALUE 1.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-DREW                BINARY-LONG.
 01 WS-LAVA-TICKS          BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-ENTITY-ROW(L-ROW) TO WS-T
     IF WS-T = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         GOBACK
     END-IF
     IF PL-MODE(L-ROW) NOT = 0
         MOVE 0 TO EN-BURN(WS-T)
         CALL "PLAYER-FIRE-SYNC" USING L-ROW
         GOBACK
     END-IF
     CALL "EFFECT-LEVEL" USING L-ROW WS-RESISTANCE-ID WS-LEVEL WS-LEFT
     CALL "M182-FLUID" USING PL-DIM(L-ROW) PL-X(L-ROW) PL-Y(L-ROW) PL-Z(L-ROW) WS-HEIGHT WS-KIND-LAVA WS-LAVA
     CALL "PLAYER-FIRE-WET" USING L-ROW WS-WET
     IF WS-WET = 1
         MOVE 0 TO EN-BURN(WS-T)
     END-IF
*>   The burning count (18 section 2.5 step 2).
     IF EN-BURN(WS-T) > 0
         IF FUNCTION MOD(EN-BURN(WS-T), 20) = 0 AND WS-LAVA = 0 AND WS-LEVEL = 0
             MOVE 1 TO WS-AMOUNT
             MOVE CAUSE-ON-FIRE TO WS-CAUSE
             CALL "HEALTH-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
         END-IF
         IF EN-BURN(WS-T) > 0
             SUBTRACT 1 FROM EN-BURN(WS-T)
         END-IF
     END-IF
*>   Lava (step 3): fifteen seconds of fire, then 4.0 damage.
     IF WS-LAVA = 1 AND PL-STATE(L-ROW) = PS-ALIVE
         CALL "FL-IGNITE" USING WS-IMMUNE EN-BURN(WS-T) WS-LAVA-TICKS
         MOVE WS-LAVA-TICKS TO EN-BURN(WS-T)
         IF WS-LEVEL = 0
             MOVE 4 TO WS-AMOUNT
             MOVE CAUSE-LAVA TO WS-CAUSE
             CALL "HEALTH-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
         END-IF
     END-IF
*>   A fire block in the box (29b-8 section 2.10): the count first, then eight seconds, then 1.0 (soul fire 2.0).
     IF PL-STATE(L-ROW) = PS-ALIVE
         CALL "PLAYER-FIRE-SCAN" USING L-ROW WS-FIRE WS-SNOW
         IF WS-FIRE > 0
             COMPUTE WS-DRAW = FUNCTION MOD(CW-TICKS + L-ROW, 2)
             CALL "GC8-FIRE-IGNITE" USING WS-IMMUNE EN-BURN(WS-T) WS-IS-PLAYER WS-DRAW WS-TICKS WS-SECONDS WS-DREW
             MOVE WS-TICKS TO EN-BURN(WS-T)
             IF WS-SECONDS > 0
                 COMPUTE WS-TICKS = WS-SECONDS * 20
                 CALL "PLAYER-IGNITE" USING L-ROW WS-TICKS
             END-IF
             IF WS-LEVEL = 0
                 MOVE WS-FIRE TO WS-AMOUNT
                 MOVE CAUSE-IN-FIRE TO WS-CAUSE
                 CALL "HEALTH-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE WS-NONE2
             END-IF
         END-IF
     END-IF
*>   Water puts out what lava or fire lit in the same tick.
     IF WS-WET = 1
         MOVE 0 TO EN-BURN(WS-T)
     END-IF
     CALL "PLAYER-FIRE-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM PLAYER-FIRE-TICK.
