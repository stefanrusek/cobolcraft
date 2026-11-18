*> Warden (002-lane-p49b; docs/protocol/20-mobs-overworld-hostile.md section 15). State: WD-ENTRY of WARDENSTATE.cpy.
*> Entry points:
*>   WARDEN-DARKNESS USING tracker row: every 120 ticks offset by the entity id ((id + tickCount) mod 120 = 0) the warden gives every player within 20 blocks of it, in its
*>     dimension, the Darkness effect (amplifier 0, 260 ticks, flags 4: icon, no particles). The tick count of an entity is not tracked: the world time CW-TIME stands in.
*>   WD-FIND USING entity id, create, slot out        the state slot of a warden (0 none)
*>   WARDEN-ANGER-ADD USING warden row, player row, amount, dig flag    AngerManager.add: ignored unless the player is alive and in survival; capped at 150; with the flag
*>     (increaseAngerAt) the dig cooldown becomes 1200
*>   WARDEN-LEVEL USING warden row, level out         0 CALM (below 40), 1 AGITATED (40 to 79), 2 ANGRY (80 and above) by the top suspect
*>   WARDEN-AGGRO USING warden row: the manager tick (every 20 ticks of CW-TIME each value falls by 1 and a value of 1 or less is dropped), the cooldown memories count down, and
*>     the target is the alive survival player of the dimension with the highest anger (none when nobody is angry: a warden does not take targets by sight)
*>   WARDEN-HURT USING warden row, attacker player row: hurt by a player: its anger +100 (ANGRY 80 + 20, no sound); with no target and the attacker within 5 blocks, the attacker
*>     becomes the target and the sonic boom cooldown is 200
*>   WARDEN-MELEE USING warden row: a melee hit (entity event 4) sets the sonic boom cooldown to 40
*>   WARDEN-SONIC USING warden row, still out: the sonic boom behaviour: usable with a target within 15 blocks horizontally and 20 vertically and the cooldown absent; it lasts 60
*>     ticks (entity event 62 at the start), on its 34th tick the boom hurts the target for 10 and adds the unit vector from the warden's chest (y + 1.6) to the target's eye
*>     (y + 1.62) scaled by 2.5 on x and z and 0.5 on y to its motion; after it the cooldown is 40; still is 1 while it runs (the warden stands)
*> Not here (named in the lane report): the sonic boom's armor bypass (the sonic_boom damage type's flags are not in the documents: the hurt is CAUSE-MOB), particles, sounds;
*>   vibrations, touch anger, the roar / sniff / emerge / dig / investigate brain activities (their entry conditions are not documented as rules), the shrieker summon wiring,
*>   the anger synced metadata 16, the sculk catalyst drop.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-DARKNESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DARKNESS            BINARY-LONG VALUE 32.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 260.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF FUNCTION MOD(EN-ID(L-ROW) + CW-TIME, 120) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ <= 400
                 CALL "EFFECT-ADD" USING WS-P WS-DARKNESS WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-DARKNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WD-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WARDENSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX OR L-SLOT > 0
         IF WD-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX OR L-SLOT > 0
             IF WD-ID(WS-I) = 0
                 INITIALIZE WD-ENTRY(WS-I)
                 MOVE L-ID TO WD-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WD-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-ANGER-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-DIG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-AMOUNT L-DIG.
     IF PL-USED(L-PLAYER) NOT = 1 OR PL-STATE(L-PLAYER) NOT = PS-ALIVE OR PL-MODE(L-PLAYER) NOT = 0
         GOBACK
     END-IF
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF L-DIG = 1
         MOVE 1200 TO WD-DIG-CD(WS-SLOT)
     END-IF
     COMPUTE WD-ANGER(WS-SLOT, L-PLAYER) = FUNCTION MIN(150, WD-ANGER(WS-SLOT, L-PLAYER) + L-AMOUNT)
     GOBACK.
 END PROGRAM WARDEN-ANGER-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-P                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEVEL.
     MOVE 0 TO L-LEVEL WS-TOP
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF WD-ANGER(WS-SLOT, WS-P) > WS-TOP
             MOVE WD-ANGER(WS-SLOT, WS-P) TO WS-TOP
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-TOP >= 80
             MOVE 2 TO L-LEVEL
         WHEN WS-TOP >= 40
             MOVE 1 TO L-LEVEL
     END-EVALUATE
     GOBACK.
 END PROGRAM WARDEN-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-AGGRO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF WD-SONIC-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-SONIC-CD(WS-SLOT)
     END-IF
     IF WD-DIG-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-DIG-CD(WS-SLOT)
     END-IF
     MOVE 0 TO WS-BEST WS-TOP
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF WD-ANGER(WS-SLOT, WS-P) > 0 AND FUNCTION MOD(CW-TIME, 20) = 0
             COMPUTE WD-ANGER(WS-SLOT, WS-P) = WD-ANGER(WS-SLOT, WS-P) - 1
             IF WD-ANGER(WS-SLOT, WS-P) <= 1
                 MOVE 0 TO WD-ANGER(WS-SLOT, WS-P)
             END-IF
         END-IF
         IF WD-ANGER(WS-SLOT, WS-P) > WS-TOP
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 MOVE WD-ANGER(WS-SLOT, WS-P) TO WS-TOP
                 MOVE WS-P TO WS-BEST
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-BEST TO EN-TARGET(L-ROW)
     IF WS-BEST > 0
         MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
     ELSE
         MOVE 0 TO EN-TARGET-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM WARDEN-AGGRO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-AMOUNT              BINARY-LONG VALUE 100.
 01 WS-NO-DIG              BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     IF L-ATTACKER = 0 OR PL-USED(L-ATTACKER) NOT = 1
         GOBACK
     END-IF
     CALL "WARDEN-ANGER-ADD" USING L-ROW L-ATTACKER WS-AMOUNT WS-NO-DIG
     IF EN-TARGET(L-ROW) = 0 AND PL-MODE(L-ATTACKER) = 0 AND PL-DIM(L-ATTACKER) = EN-DIM(L-ROW)
             AND (PL-X(L-ATTACKER) - EN-X(L-ROW)) ** 2 + (PL-Y(L-ATTACKER) - EN-Y(L-ROW)) ** 2 + (PL-Z(L-ATTACKER) - EN-Z(L-ROW)) ** 2 <= 25
         MOVE L-ATTACKER TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(L-ATTACKER) TO EN-TARGET-ID(L-ROW)
         CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
         IF WS-SLOT > 0
             MOVE 200 TO WD-SONIC-CD(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-MELEE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         MOVE 40 TO WD-SONIC-CD(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM WARDEN-MELEE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-SONIC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 COPY RULES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-P                   BINARY-LONG.
 01 WS-HDIST               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 62.
 01 WS-MILLI               BINARY-LONG VALUE 10000.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STILL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-STILL.
     MOVE 0 TO L-STILL
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WD-BOOM(WS-SLOT) = 0
         IF WS-P = 0 OR WD-SONIC-CD(WS-SLOT) > 0
             GOBACK
         END-IF
         COMPUTE WS-HDIST = FUNCTION SQRT((PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2)
         IF WS-HDIST >= 15 OR FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW)) >= 20
             GOBACK
         END-IF
         MOVE 1 TO WD-BOOM(WS-SLOT)
         CALL "WARDEN-EVENT" USING L-ROW WS-EVENT
         MOVE 1 TO L-STILL
         GOBACK
     END-IF
     MOVE 1 TO L-STILL
     ADD 1 TO WD-BOOM(WS-SLOT)
     IF WD-BOOM(WS-SLOT) = 34 AND WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) + 1.62 - (EN-Y(L-ROW) + 1.6)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
         CALL "HEALTH-HURT" USING WS-P WS-MILLI WS-CAUSE EN-ID(L-ROW) WS-NO-ATTACKER WS-RESULT
         COMPUTE WS-VX = WS-DX / WS-LEN * 2500
         COMPUTE WS-VY = WS-DY / WS-LEN * 500
         COMPUTE WS-VZ = WS-DZ / WS-LEN * 2500
         CALL "COMBAT-MOTION-SEND" USING WS-P WS-VX WS-VY WS-VZ
     END-IF
     IF WD-BOOM(WS-SLOT) >= 60
         MOVE 0 TO WD-BOOM(WS-SLOT)
         MOVE 40 TO WD-SONIC-CD(WS-SLOT)
         MOVE 0 TO L-STILL
     END-IF
     GOBACK.
 END PROGRAM WARDEN-SONIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-EVENT.
*> USING warden row, event id: an Entity Event to the players that see the warden.
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
 END PROGRAM WARDEN-EVENT.
