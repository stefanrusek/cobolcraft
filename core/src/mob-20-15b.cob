*> The warden's brain (lane 002-lane-p49r; docs/protocol/20 section 15, 15.1, 15.4 and 44-residual-mob-questions-5 section 3). State: WD-ENTRY of WARDENSTATE.cpy. The activity is chosen at the end of a
*> tick (the first valid of EMERGE, DIG, ROAR, FIGHT, INVESTIGATE, SNIFF, IDLE) and its behaviours start in the next one; a behaviour that has started runs to its own end whatever the activity
*> (Roar 84, Sniffing 84, Digging 100 ticks, counted from its start tick). Memories count down at the start of a tick. Changing the activity erases the memory of the one left (is_emerging,
*> roar_target, attack_target, disturbance_location, is_sniffing). Targets are players (EN-TARGET is a player row).
*>   WARDEN-CAN-TARGET USING warden row, player row, ok out: canTargetEntity for a player: alive, in the warden's dimension, not creative or spectator.
*>   WARDEN-INCREASE USING warden row, player row, amount: increaseAngerAt: ignored unless the player can be targeted; refreshes the dig cooldown when present; adds to the anger (cap 150).
*>   WARDEN-ACTIVE USING warden row, level out, top player out: the anger level (0 CALM, 1 AGITATED, 2 ANGRY) of the active anger (the attack target's value, else the highest) and the top
*>     suspect that can be targeted (highest anger first; 0 none).
*>   WARDEN-DISTURB USING warden row, block x, y, z: setDisturbanceLocation: nothing when the warden is ANGRY at someone; else (dig cooldown refresh with an attack target) sniff cooldown 100,
*>     the location for 100 ticks, the walk target erased.
*>   WARDEN-EMERGE USING warden row: finalizeSpawn for a sculk shrieker (spawn reason TRIGGERED): is_emerging for 134 ticks.
*>   WARDEN-HEAR USING dim, x, y, z (FLOAT-LONG), source player row (0 not a living entity), projectile owner player row (0 none), sneak-filtered flag (1: a sneaking source's event of the tag
*>     ignore_vibrations_sneaking): the game event as the warden's listener sees it (15.1): every warden in range puts it in flight (arrival floor(distance to its listener point) ticks later, at least 1).
*>   WARDEN-BRAIN USING warden row: one tick of the brain (called by STDMOB-AGGRO in the place of the old anger targeting).
*>   WARDEN-WALK USING warden row, hx, hz (FLOAT-LONG out), walk out: 1 the investigation walks (hx, hz), 2 the warden stands (roar, sniff, emerge, dig, arrived), 0 other activities.
*>   WARDEN-INVULNERABLE USING warden row, cause, flag out: 1 while digging or emerging, except for damage that bypasses invulnerability (out of the world, the kill command).
*> Not here: poses, sounds, the occlusion of vibrations by wool, a non-player target (entities other than players have no anger), the look targets, the stroll pause group.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-CAN-TARGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-OK.
     MOVE 0 TO L-OK
     IF L-PLAYER > 0
         IF PL-USED(L-PLAYER) = 1 AND PL-STATE(L-PLAYER) = PS-ALIVE AND PL-DIM(L-PLAYER) = EN-DIM(L-ROW)
                 AND (PL-MODE(L-PLAYER) = 0 OR PL-MODE(L-PLAYER) = 2)
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-CAN-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-INCREASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OK                  BINARY-LONG.
 01 WS-DIG                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-AMOUNT.
     CALL "WARDEN-CAN-TARGET" USING L-ROW L-PLAYER WS-OK
     IF WS-OK = 1
         CALL "WARDEN-ANGER-ADD" USING L-ROW L-PLAYER L-AMOUNT WS-DIG
     END-IF
     GOBACK.
 END PROGRAM WARDEN-INCREASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-ACTIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-TOP-VALUE           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEVEL L-TOP.
     MOVE 0 TO L-LEVEL L-TOP WS-HIGH WS-TOP-VALUE
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF WD-ANGER(WS-SLOT, WS-P) > WS-HIGH
             MOVE WD-ANGER(WS-SLOT, WS-P) TO WS-HIGH
         END-IF
         IF WD-ANGER(WS-SLOT, WS-P) > WS-TOP-VALUE
             CALL "WARDEN-CAN-TARGET" USING L-ROW WS-P WS-OK
             IF WS-OK = 1
                 MOVE WD-ANGER(WS-SLOT, WS-P) TO WS-TOP-VALUE
                 MOVE WS-P TO L-TOP
             END-IF
         END-IF
     END-PERFORM
*>   With an attack target the level is that of the target's own anger.
     IF EN-TARGET(L-ROW) > 0
         MOVE WD-ANGER(WS-SLOT, EN-TARGET(L-ROW)) TO WS-HIGH
     END-IF
     EVALUATE TRUE
         WHEN WS-HIGH >= 80
             MOVE 2 TO L-LEVEL
         WHEN WS-HIGH >= 40
             MOVE 1 TO L-LEVEL
     END-EVALUATE
     GOBACK.
 END PROGRAM WARDEN-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-DISTURB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     CALL "WARDEN-ACTIVE" USING L-ROW WS-LEVEL WS-TOP
*>   getEntityAngryAt: the active entity while the level is ANGRY.
     IF WS-LEVEL = 2 AND WS-TOP > 0
         GOBACK
     END-IF
     IF EN-TARGET(L-ROW) > 0 AND WD-DIG-CD(WS-SLOT) > 0
         MOVE 1200 TO WD-DIG-CD(WS-SLOT)
     END-IF
     MOVE 100 TO WD-SNIFF-CD(WS-SLOT) WD-DISTURB(WS-SLOT)
     MOVE L-X TO WD-DX(WS-SLOT)
     MOVE L-Y TO WD-DY(WS-SLOT)
     MOVE L-Z TO WD-DZ(WS-SLOT)
     MOVE 0 TO WD-WALK-ON(WS-SLOT)
     GOBACK.
 END PROGRAM WARDEN-DISTURB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-EMERGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT > 0
         MOVE 134 TO WD-EMERGE(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM WARDEN-EMERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-INVULNERABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 COPY RULES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAUSE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT > 0
         IF (WD-EMERGE(WS-SLOT) > 0 OR WD-DIGGING(WS-SLOT) > 0) AND L-CAUSE NOT = CAUSE-VOID AND L-CAUSE NOT = CAUSE-COMMAND
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-INVULNERABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-HEAR-ONE.
*> USING warden row, event x, y, z (FLOAT-LONG), source player row, projectile owner player row: the filters and the flight of one event for one warden (15.1). The listener point is the warden's
*> feet + 2.4650001525878906 (the standing eye height captured at construction); the event is in range at a block distance of at most 16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-TRAVEL              BINARY-LONG.
 01 WS-REACH               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-SOURCE L-OWNER.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     COMPUTE WS-EX = FUNCTION INTEGER(L-X)
     COMPUTE WS-EY = FUNCTION INTEGER(L-Y)
     COMPUTE WS-EZ = FUNCTION INTEGER(L-Z)
     COMPUTE WS-LX = EN-X(L-ROW)
     COMPUTE WS-LY = EN-Y(L-ROW) + 2.4650001525878906
     COMPUTE WS-LZ = EN-Z(L-ROW)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-LX)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-LY)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-LZ)
     MOVE 1 TO WS-REACH
     IF (WS-BX - WS-EX) ** 2 + (WS-BY - WS-EY) ** 2 + (WS-BZ - WS-EZ) ** 2 > 256
         MOVE 0 TO WS-REACH
     END-IF
     IF WD-V-DUE(WS-SLOT) > 0 OR WD-VIB-CD(WS-SLOT) > 0 OR WD-EMERGE(WS-SLOT) > 0 OR WD-DIGGING(WS-SLOT) > 0
         MOVE 0 TO WS-REACH
     END-IF
     IF L-SOURCE > 0 AND WS-REACH = 1
         CALL "WARDEN-CAN-TARGET" USING L-ROW L-SOURCE WS-OK
         IF WS-OK = 0
             MOVE 0 TO WS-REACH
         END-IF
     END-IF
     IF WS-REACH = 1
         COMPUTE WS-D = FUNCTION SQRT((L-X - WS-LX) ** 2 + (L-Y - WS-LY) ** 2 + (L-Z - WS-LZ) ** 2)
         COMPUTE WS-TRAVEL = FUNCTION MAX(FUNCTION INTEGER(WS-D), 1)
         COMPUTE WD-V-DUE(WS-SLOT) = CW-TICKS + WS-TRAVEL
         MOVE L-SOURCE TO WD-V-SRC(WS-SLOT)
         MOVE L-OWNER TO WD-V-OWNER(WS-SLOT)
         MOVE L-X TO WD-V-X(WS-SLOT)
         MOVE L-Y TO WD-V-Y(WS-SLOT)
         MOVE L-Z TO WD-V-Z(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM WARDEN-HEAR-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-HEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-SNEAK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOURCE L-OWNER L-SNEAK.
     IF L-SNEAK = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 IF SM-KEY(WS-M) = "warden"
                     CALL "WARDEN-HEAR-ONE" USING WS-E L-X L-Y L-Z L-SOURCE L-OWNER
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-HEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-SENSE.
*> USING warden row, slot: the entity sensor's scan (44-5 section 3.5): the first player, nearest first, within the follow range (24) on each axis that can be targeted becomes nearest_attackable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 0 TO WD-NEAR(L-SLOT)
     MOVE 1000000 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         CALL "WARDEN-CAN-TARGET" USING L-ROW WS-P WS-OK
         IF WS-OK = 1
             IF FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= 24 AND FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW)) <= 24
                     AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= 24
                 COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                 IF WS-D2 < WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE WS-P TO WD-NEAR(L-SLOT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WARDEN-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-RECEIVE.
*> USING warden row, slot: the vibration in flight arrives (Warden$VibrationUser.onReceiveVibration, 15): vibration cooldown 40, entity event 61; a projectile owner within 30 blocks gets 10 anger
*> (35 with recent_projectile present) and recent_projectile is set for 100 ticks; without an owner the source gets 35; then the disturbance location, when the warden is not ANGRY and (an owner
*> exists, or nobody is its active entity, or the active entity is the source): the vibration's block, or the owner's block when the owner was within 30 blocks with a recent projectile.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-EVENT               BINARY-LONG VALUE 61.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NEAR30              BINARY-LONG.
 01 WS-RECENT              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 40 TO WD-VIB-CD(L-SLOT)
     CALL "WARDEN-EVENT" USING L-ROW WS-EVENT
     MOVE WD-V-OWNER(L-SLOT) TO WS-OWNER
     MOVE WD-V-SRC(L-SLOT) TO WS-SOURCE
     COMPUTE WS-BX = FUNCTION INTEGER(WD-V-X(L-SLOT))
     COMPUTE WS-BY = FUNCTION INTEGER(WD-V-Y(L-SLOT))
     COMPUTE WS-BZ = FUNCTION INTEGER(WD-V-Z(L-SLOT))
     MOVE 0 TO WS-RECENT
     IF WD-PROJ-CD(L-SLOT) > 0
         MOVE 1 TO WS-RECENT
     END-IF
     IF WS-OWNER > 0
         MOVE 0 TO WS-NEAR30
         IF (PL-X(WS-OWNER) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-OWNER) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-OWNER) - EN-Z(L-ROW)) ** 2 < 900
             MOVE 1 TO WS-NEAR30
         END-IF
         IF WS-NEAR30 = 1
             MOVE 10 TO WS-AMOUNT
             IF WS-RECENT = 1
                 MOVE 35 TO WS-AMOUNT
             END-IF
             CALL "WARDEN-INCREASE" USING L-ROW WS-OWNER WS-AMOUNT
             CALL "WARDEN-CAN-TARGET" USING L-ROW WS-OWNER WS-OK
             IF WS-RECENT = 1 AND WS-OK = 1
                 COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-OWNER))
                 COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-OWNER))
                 COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-OWNER))
             END-IF
         END-IF
         MOVE 100 TO WD-PROJ-CD(L-SLOT)
     ELSE
         MOVE 35 TO WS-AMOUNT
         IF WS-SOURCE > 0
             CALL "WARDEN-INCREASE" USING L-ROW WS-SOURCE WS-AMOUNT
         END-IF
     END-IF
     CALL "WARDEN-ACTIVE" USING L-ROW WS-LEVEL WS-TOP
     IF WS-LEVEL < 2
         IF WS-OWNER > 0 OR WS-TOP = 0 OR WS-TOP = WS-SOURCE
             CALL "WARDEN-DISTURB" USING L-ROW WS-BX WS-BY WS-BZ
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-START.
*> USING warden row, slot: the start phase of the behaviours of the active activity (15.4): SetRoarTarget (IDLE, INVESTIGATE, SNIFF), TryToSniff (IDLE), Sniffing (SNIFF), Roar (ROAR), the dig
*> cooldown refresh and the stop check (FIGHT), Digging (DIG; it starts only on the ground: in a liquid the warden stops at once, not built).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-SALT                BINARY-LONG VALUE 92.
 01 WS-B101                BINARY-LONG VALUE 101.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF WD-ACT(L-SLOT) = 5 OR WD-ACT(L-SLOT) = 6 OR WD-ACT(L-SLOT) = 7
         IF WD-ROAR-TARGET(L-SLOT) = 0 AND EN-TARGET(L-ROW) = 0
             CALL "WARDEN-ACTIVE" USING L-ROW WS-LEVEL WS-TOP
             IF WS-LEVEL = 2 AND WS-TOP > 0
                 MOVE WS-TOP TO WD-ROAR-TARGET(L-SLOT)
             END-IF
         END-IF
     END-IF
     IF WD-ACT(L-SLOT) = 7
         IF WD-SNIFF-CD(L-SLOT) = 0 AND WD-NEAR(L-SLOT) > 0 AND WD-DISTURB(L-SLOT) = 0
             CALL "XP-RANDOM" USING WS-SALT WS-B101 WS-DRAW
             MOVE 1 TO WD-SNIFFING(L-SLOT)
             COMPUTE WD-SNIFF-CD(L-SLOT) = 100 + WS-DRAW
             MOVE 0 TO WD-WALK-ON(L-SLOT)
         END-IF
     END-IF
     IF WD-ACT(L-SLOT) = 6
         IF WD-SNIFF(L-SLOT) = 0 AND WD-SNIFFING(L-SLOT) = 1 AND EN-TARGET(L-ROW) = 0
             MOVE 1 TO WD-SNIFF(L-SLOT)
         END-IF
     END-IF
     IF WD-ACT(L-SLOT) = 3
         IF WD-ROAR(L-SLOT) = 0 AND WD-ROAR-TARGET(L-SLOT) > 0 AND EN-TARGET(L-ROW) = 0
             MOVE 1 TO WD-ROAR(L-SLOT)
             CALL "WARDEN-INCREASE" USING L-ROW WD-ROAR-TARGET(L-SLOT) WS-TWENTY
         END-IF
     END-IF
     IF WD-ACT(L-SLOT) = 4
         IF WD-DIG-CD(L-SLOT) > 0
             MOVE 1200 TO WD-DIG-CD(L-SLOT)
         END-IF
         MOVE EN-TARGET(L-ROW) TO WS-P
         IF WS-P > 0
             CALL "WARDEN-CAN-TARGET" USING L-ROW WS-P WS-OK
             CALL "WARDEN-ACTIVE" USING L-ROW WS-LEVEL WS-TOP
             IF WS-OK = 0 OR WS-LEVEL < 2
                 MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
                 IF WS-OK = 0
                     MOVE 0 TO WD-ANGER(L-SLOT, WS-P)
                 END-IF
                 IF WD-DIG-CD(L-SLOT) > 0
                     MOVE 1200 TO WD-DIG-CD(L-SLOT)
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WD-ACT(L-SLOT) = 2
         IF WD-DIGGING(L-SLOT) = 0 AND EN-TARGET(L-ROW) = 0 AND EN-ON-GROUND(L-ROW) = 1
             MOVE 1 TO WD-DIGGING(L-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WARDENSTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-THIRTY-FIVE         BINARY-LONG VALUE 35.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   The memories count down.
     IF WD-SONIC-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-SONIC-CD(WS-SLOT)
     END-IF
     IF WD-DIG-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-DIG-CD(WS-SLOT)
     END-IF
     IF WD-VIB-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-VIB-CD(WS-SLOT)
     END-IF
     IF WD-SNIFF-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-SNIFF-CD(WS-SLOT)
     END-IF
     IF WD-DISTURB(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-DISTURB(WS-SLOT)
     END-IF
     IF WD-EMERGE(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-EMERGE(WS-SLOT)
     END-IF
     IF WD-PROJ-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM WD-PROJ-CD(WS-SLOT)
     END-IF
*>   Warden.tick: the vibration ticker, before the brain.
     IF WD-V-DUE(WS-SLOT) > 0 AND CW-TICKS >= WD-V-DUE(WS-SLOT)
         MOVE 0 TO WD-V-DUE(WS-SLOT)
         CALL "WARDEN-RECEIVE" USING L-ROW WS-SLOT
     END-IF
*>   The sensor scans every 20 ticks.
     SUBTRACT 1 FROM WD-SENSOR(WS-SLOT)
     IF WD-SENSOR(WS-SLOT) <= 0
         MOVE 20 TO WD-SENSOR(WS-SLOT)
         CALL "WARDEN-SENSE" USING L-ROW WS-SLOT
     END-IF
*>   The running behaviours: Roar (84), Sniffing (84), Digging (100).
     IF WD-ROAR(WS-SLOT) > 0
         ADD 1 TO WD-ROAR(WS-SLOT)
         IF WD-ROAR(WS-SLOT) > 84
             MOVE 0 TO WD-ROAR(WS-SLOT)
             IF WD-ROAR-TARGET(WS-SLOT) > 0
                 MOVE WD-ROAR-TARGET(WS-SLOT) TO EN-TARGET(L-ROW)
                 MOVE PL-ENTITY-ID(WD-ROAR-TARGET(WS-SLOT)) TO EN-TARGET-ID(L-ROW)
                 MOVE 200 TO WD-SONIC-CD(WS-SLOT)
             END-IF
             MOVE 0 TO WD-ROAR-TARGET(WS-SLOT)
         END-IF
     END-IF
     IF WD-SNIFF(WS-SLOT) > 0
         ADD 1 TO WD-SNIFF(WS-SLOT)
         IF WD-SNIFF(WS-SLOT) > 84
             MOVE 0 TO WD-SNIFF(WS-SLOT) WD-SNIFFING(WS-SLOT)
             MOVE WD-NEAR(WS-SLOT) TO WS-P
             CALL "WARDEN-CAN-TARGET" USING L-ROW WS-P WS-OK
             IF WS-OK = 1
                 COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                 COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                 IF WS-DX * WS-DX + WS-DZ * WS-DZ < 36 AND FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW)) < 20
                     CALL "WARDEN-INCREASE" USING L-ROW WS-P WS-THIRTY-FIVE
                     IF WD-DISTURB(WS-SLOT) = 0
                         COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-P))
                         COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-P))
                         COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-P))
                         CALL "WARDEN-DISTURB" USING L-ROW WS-BX WS-BY WS-BZ
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WD-DIGGING(WS-SLOT) > 0
         ADD 1 TO WD-DIGGING(WS-SLOT)
         IF WD-DIGGING(WS-SLOT) > 100
             CALL "ENTITY-REMOVE" USING L-ROW
             GOBACK
         END-IF
     END-IF
     CALL "WARDEN-START" USING L-ROW WS-SLOT
*>   The anger manager ticks every 20 ticks of the warden: a value of 1 or less, or of a player that can no longer be targeted, is dropped, the others fall by 1.
     IF FUNCTION MOD(EN-WAKE(L-ROW), 20) = 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF WD-ANGER(WS-SLOT, WS-P) > 0
                 CALL "WARDEN-CAN-TARGET" USING L-ROW WS-P WS-OK
                 IF WD-ANGER(WS-SLOT, WS-P) <= 1 OR WS-OK = 0
                     MOVE 0 TO WD-ANGER(WS-SLOT, WS-P)
                 ELSE
                     SUBTRACT 1 FROM WD-ANGER(WS-SLOT, WS-P)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
*>   updateActivity: the first valid activity; leaving an activity erases its memory.
     EVALUATE TRUE
         WHEN WD-EMERGE(WS-SLOT) > 0
             MOVE 1 TO WS-NEW
         WHEN WD-ROAR-TARGET(WS-SLOT) = 0 AND WD-DIG-CD(WS-SLOT) = 0
             MOVE 2 TO WS-NEW
         WHEN WD-ROAR-TARGET(WS-SLOT) > 0
             MOVE 3 TO WS-NEW
         WHEN EN-TARGET(L-ROW) > 0
             MOVE 4 TO WS-NEW
         WHEN WD-DISTURB(WS-SLOT) > 0
             MOVE 5 TO WS-NEW
         WHEN WD-SNIFFING(WS-SLOT) = 1
             MOVE 6 TO WS-NEW
         WHEN OTHER
             MOVE 7 TO WS-NEW
     END-EVALUATE
     IF WS-NEW NOT = WD-ACT(WS-SLOT)
         EVALUATE WD-ACT(WS-SLOT)
             WHEN 1
                 MOVE 0 TO WD-EMERGE(WS-SLOT)
             WHEN 3
                 MOVE 0 TO WD-ROAR-TARGET(WS-SLOT)
             WHEN 4
                 MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
             WHEN 5
                 MOVE 0 TO WD-DISTURB(WS-SLOT) WD-WALK-ON(WS-SLOT)
             WHEN 6
                 MOVE 0 TO WD-SNIFFING(WS-SLOT)
         END-EVALUATE
         MOVE WS-NEW TO WD-ACT(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM WARDEN-BRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WARDEN-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 93.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "WD-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF WD-ACT(WS-SLOT) = 1 OR WD-ACT(WS-SLOT) = 2 OR WD-ACT(WS-SLOT) = 3 OR WD-ACT(WS-SLOT) = 6 OR WD-ROAR(WS-SLOT) > 0 OR WD-SNIFF(WS-SLOT) > 0
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     IF WD-ACT(WS-SLOT) = 5
         MOVE 2 TO L-WALK
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
*>       GoToTargetLocation: with the warden's block not closer than 2.0 to the location, a walk target near it (+ nextInt(3) - 1 on x, then z), speed modifier 0.7 with completion distance 2.
         IF WD-WALK-ON(WS-SLOT) = 0
             IF (WS-BX - WD-DX(WS-SLOT)) ** 2 + (WS-BZ - WD-DZ(WS-SLOT)) ** 2 >= 4
                 CALL "XP-RANDOM" USING WS-SALT WS-B3 WS-DRAW
                 COMPUTE WD-WALK-X(WS-SLOT) = WD-DX(WS-SLOT) + WS-DRAW - 1
                 CALL "XP-RANDOM" USING WS-SALT WS-B3 WS-DRAW
                 COMPUTE WD-WALK-Z(WS-SLOT) = WD-DZ(WS-SLOT) + WS-DRAW - 1
                 MOVE 1 TO WD-WALK-ON(WS-SLOT)
             END-IF
         END-IF
         IF WD-WALK-ON(WS-SLOT) = 1
             IF (WS-BX - WD-WALK-X(WS-SLOT)) ** 2 + (WS-BZ - WD-WALK-Z(WS-SLOT)) ** 2 < 4
                 MOVE 0 TO WD-WALK-ON(WS-SLOT)
             ELSE
                 CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
                 MOVE WD-WALK-X(WS-SLOT) TO WS-DX
                 MOVE WD-WALK-Z(WS-SLOT) TO WS-DZ
                 COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(L-ROW))
                 CALL "STDMOB-HEAD" USING L-ROW WS-M WS-DX WS-GY WS-DZ L-HX L-HZ WS-ARRIVED
*>               The table speed is that of modifier 1.2; the investigation walks at 0.7 and the motion goes with the square of the speed.
                 COMPUTE L-HX = L-HX * 0.3402777777777778
                 COMPUTE L-HZ = L-HZ * 0.3402777777777778
                 MOVE 1 TO L-WALK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WARDEN-WALK.
