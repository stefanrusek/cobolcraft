*> Polar bear (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 9, 44-residual-mob-questions-4-land-animals.md section 8). A neutral mob (SM-NEUTRAL 7): the anger,
*> the hit by a player and the alert of the adults around are NETHER-HURT / NETHER-ALERT / NETHER-AGGRO (mob-21-5.cob); this file holds what is the bear's own.
*>   POLAR-BEAR-STAND USING near, reached, cooldown (in/out), standing out, warn out     the standing flag of the melee goal
*>   POLAR-BEAR-GUARDS USING dx, dy, dz, guards out                                      a cub (offset from the adult) inside the adult's box inflated by (8, 4, 8)
*>   POLAR-BEAR-GUARD USING row                                                          an adult near a cub takes a visible player within half the follow range
*>   POLAR-BEAR-TICK USING row                                                           the standing flag of this tick (sent to the viewers when it changes)
*>   POLAR-BEAR-PANIC USING row, flee out                                                an adult does not panic when hurt by a player (panic_environmental_causes only)
*>   MOB-POLAR-DATA USING row, PB-BUFFER                                                 index 18 BOOLEAN (standing) before the end marker
 IDENTIFICATION DIVISION.
 PROGRAM-ID. POLAR-BEAR-STAND.
*> PolarBearMeleeAttackGoal (44 part 4 section 8, 19 section 9): within reach the bear is not standing. In the warning band (squared distance below (target width + 3)^2, outside the
*> reach): when the attack is ready (cooldown 0) it lies down and the cooldown becomes the attack time 20; with 10 or fewer ticks left it stands up and the warning sound plays.
*> Farther away the cooldown is reset and it lies down.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEAR                 BINARY-LONG.
 01 L-REACHED              BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-STANDING             BINARY-LONG.
 01 L-WARN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NEAR L-REACHED L-COOLDOWN L-STANDING L-WARN.
     MOVE 0 TO L-WARN
     EVALUATE TRUE
         WHEN L-REACHED = 1
             MOVE 0 TO L-STANDING
         WHEN L-NEAR = 1
             MOVE 0 TO L-STANDING
             IF L-COOLDOWN = 0
                 MOVE 20 TO L-COOLDOWN
             END-IF
             IF L-COOLDOWN <= 10
                 MOVE 1 TO L-STANDING L-WARN
             END-IF
         WHEN OTHER
             MOVE 0 TO L-COOLDOWN L-STANDING
     END-EVALUATE
     GOBACK.
 END PROGRAM POLAR-BEAR-STAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POLAR-BEAR-GUARDS.
*> USING dx, dy, dz (FLOAT-LONG, the cub's position minus the adult's), guards out: 1 when the cub's box (0.7 x 0.7) meets the adult's box (1.4 x 1.4) inflated by 8, 4 and 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-GUARDS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-GUARDS.
     MOVE 0 TO L-GUARDS
     IF FUNCTION ABS(L-DX) < 9.05 AND FUNCTION ABS(L-DZ) < 9.05 AND L-DY < 5.4 AND L-DY > -4.7
         MOVE 1 TO L-GUARDS
     END-IF
     GOBACK.
 END PROGRAM POLAR-BEAR-GUARDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POLAR-BEAR-GUARD.
*> USING row: PolarBearAttackPlayers (p2): never for a cub; an adult without a target, when a polar bear cub is inside the box (POLAR-BEAR-GUARDS), takes the nearest alive survival
*> player within half the follow range (10 blocks, line of sight) as its target; the anger timer starts (NETHER-ANGER-TICKS, 400 to 779 ticks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-CUB                 BINARY-LONG.
 01 WS-GUARDS              BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-MOBAGE(L-ROW) < 0 OR EN-TARGET(L-ROW) > 0 OR EN-ANGER(L-ROW) > 0
         GOBACK
     END-IF
     MOVE 0 TO WS-CUB
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-CUB > 0
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = EN-TYPE(L-ROW) AND EN-MOBAGE(WS-E) < 0 AND EN-HEALTH(WS-E) > 0
                 AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
             COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
             COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
             CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
             IF WS-GUARDS = 1
                 MOVE WS-E TO WS-CUB
             END-IF
         END-IF
     END-PERFORM
     IF WS-CUB = 0
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
                 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= (SM-FOLLOW(WS-M) / 2) ** 2 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE EN-X(L-ROW) TO WS-AX
                 COMPUTE WS-AY = EN-Y(L-ROW) + 1.19
                 MOVE EN-Z(L-ROW) TO WS-AZ
                 MOVE PL-X(WS-P) TO WS-BX
                 COMPUTE WS-BY = PL-Y(WS-P) + 1.62
                 MOVE PL-Z(WS-P) TO WS-BZ
                 CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ WS-BX WS-BY WS-BZ WS-SEES
                 IF WS-SEES = 1
                     MOVE WS-P TO WS-BEST
                     MOVE WS-D2 TO WS-BEST-D2
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         CALL "NETHER-ANGER-TICKS" USING L-ROW WS-TICKS
         MOVE WS-TICKS TO EN-ANGER(L-ROW)
         MOVE WS-BEST TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM POLAR-BEAR-GUARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POLAR-BEAR-TICK.
*> USING row: the standing flag of the bear this tick (POLAR-BEAR-STAND on the distance to its target, EN-COOLDOWN the attack timer); a change goes to the viewers as entity data.
*> The reach is the one of STDMOB-STEP (SM-REACH-*); the warning band is the squared distance below (0.6 + 3)^2 (a player's width is 0.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-STANDING            BINARY-LONG.
 01 WS-WARN                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-POLAR-STAND(L-ROW) TO WS-BEFORE
     MOVE 0 TO WS-STANDING
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         COMPUTE WS-REACH = SM-REACH-MILLI / 1000
         MOVE 0 TO WS-REACHED WS-NEAR
         IF FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
                 AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
             MOVE 1 TO WS-REACHED
         END-IF
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF WS-D2 < 12.96
             MOVE 1 TO WS-NEAR
         END-IF
         CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED EN-COOLDOWN(L-ROW) WS-STANDING WS-WARN
     END-IF
     MOVE WS-STANDING TO EN-POLAR-STAND(L-ROW)
     IF WS-STANDING NOT = WS-BEFORE
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM POLAR-BEAR-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POLAR-BEAR-PANIC.
*> USING row, flee (BINARY-LONG in/out): the panic of a hurt animal is a baby's only: an adult polar bear uses panic_environmental_causes, so a hit by a player (the caller passes
*> only those) does not make it flee; flee becomes 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLEE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLEE.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "polar_bear" AND EN-MOBAGE(L-ROW) >= 0
         MOVE 0 TO L-FLEE
     END-IF
     GOBACK.
 END PROGRAM POLAR-BEAR-PANIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-POLAR-DATA.
*> USING row, PB-BUFFER: the standing flag of a polar bear (index 18 BOOLEAN, 19 section 9), sent while it stands.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PD-==.
 01 WS-KEY                 PIC X(24).
 01 WS-SERIALIZER-BOOLEAN  BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "polar_bear" AND EN-POLAR-STAND(L-ROW) = 1
         INITIALIZE PD-METADATA-ENTRY-X
         MOVE 18 TO PD-MX-INDEX
         MOVE WS-SERIALIZER-BOOLEAN TO PD-MX-SERIALIZER
         MOVE 1 TO PD-MX-INT
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER PD-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM MOB-POLAR-DATA.
