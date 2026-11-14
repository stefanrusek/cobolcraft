*> Tame pets and the mob-versus-mob target path (lane 002-lane-mobsfull-h9; docs/protocol/18 section 8.2, 19 section 6.1).
*>
*> Entry points:
*>   PET-OWNER USING row, owner player row out          the alive player whose UUID is the pet's owner, in the pet's dimension (0 none)
*>   PET-FIND-FOE USING row, owner player row           a hostile standard mob that targets the owner (EN-FOE, EN-FOE-ID)
*>   PET-TICK USING row, hx, hz, walk out               one tick of a tame wolf: sit, defend the owner, follow the owner

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PET-OWNER.
*> USING pet row, owner player row out: the alive player of the pet's dimension whose UUID is EN-OWNER-UUID and who is not a spectator (unableToMoveToOwner, 8.2), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OWNER.
     MOVE 0 TO L-OWNER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-UUID(WS-P) = EN-OWNER-UUID(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3
             MOVE WS-P TO L-OWNER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PET-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PET-FIND-FOE.
*> USING pet row, owner player row: the nearest alive hostile standard mob of the pet's dimension within 16 blocks whose target is the owner (OwnerHurtByTargetGoal: the mob that
*> attacks the owner); it becomes the pet's foe (EN-FOE, EN-FOE-ID). Nothing changes when there is none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OWNER.
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                 AND EN-TARGET(WS-N) = L-OWNER AND EN-TARGET-ID(WS-N) = PL-ENTITY-ID(L-OWNER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-M
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-M > 0 AND WS-D2 <= 256 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE WS-N TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE WS-BEST TO EN-FOE(L-ROW)
         MOVE EN-ID(WS-BEST) TO EN-FOE-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM PET-FIND-FOE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PET-TICK.
*> USING pet row, hx out, hz out, walk out: one tick of the goals of a tame wolf (19 section 6.1): SitWhenOrdered (walk 2: the wolf stands still, its foe is dropped), the owner's
*> attackers as the foe (OwnerHurtByTarget, PET-FIND-FOE) that it walks to and bites in reach (MeleeAttack 1.0: the attack damage of the row once every SM-ATTACK-TICKS ticks,
*> HEALTH-MOB-DAMAGE) and FollowOwner(1.0, 10.0, 2.0) (M188-FOLLOW: walk beyond 10 blocks until within 2, teleport to the owner at 12 blocks or more). walk 1 means hx and hz are the
*> walk of this tick (they may be 0 while biting); walk 0 leaves the other goals to the caller.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 01 WS-OWNER               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     IF EN-SIT(L-ROW) = 1
         MOVE 0 TO EN-PET-MOVING(L-ROW) EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     CALL "PET-OWNER" USING L-ROW WS-OWNER
     IF EN-PET-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) NOT = 1 OR EN-ID(WS-F) NOT = EN-FOE-ID(L-ROW) OR EN-HEALTH(WS-F) = 0
             MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     IF EN-FOE(L-ROW) = 0 AND WS-OWNER > 0
         CALL "PET-FIND-FOE" USING L-ROW WS-OWNER
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         COMPUTE WS-DX = EN-X(WS-F) - EN-X(L-ROW)
         COMPUTE WS-DY = EN-Y(WS-F) - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-Z(WS-F) - EN-Z(L-ROW)
         COMPUTE WS-REACH = SM-REACH-MILLI / 1000
         MOVE 1 TO L-WALK
         IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
             COMPUTE WS-GX = FUNCTION INTEGER(EN-X(WS-F))
             COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-F))
             COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(WS-F))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
         END-IF
         IF EN-PET-CD(L-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
                 AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
             MOVE SM-ATTACK-TICKS TO EN-PET-CD(L-ROW)
             MOVE SM-ATTACK(WS-M) TO WS-DAMAGE
             CALL "HEALTH-MOB-DAMAGE" USING WS-F WS-DAMAGE CAUSE-MOB WS-NONE
         END-IF
         GOBACK
     END-IF
     IF WS-OWNER = 0
         MOVE 0 TO EN-PET-MOVING(L-ROW)
         GOBACK
     END-IF
     COMPUTE WS-D2 = (PL-X(WS-OWNER) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-OWNER) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-OWNER) - EN-Z(L-ROW)) ** 2
     CALL "M188-FOLLOW" USING WS-D2 EN-PET-MOVING(L-ROW) WS-ACTION
     EVALUATE WS-ACTION
         WHEN 2
             MOVE 0 TO EN-PET-MOVING(L-ROW)
             MOVE EN-YAW(L-ROW) TO WS-YAW
             MOVE EN-PITCH(L-ROW) TO WS-PITCH
             CALL "ENTITY-MOVE" USING L-ROW PL-X(WS-OWNER) PL-Y(WS-OWNER) PL-Z(WS-OWNER) WS-YAW WS-PITCH WS-GROUND
         WHEN 1
             MOVE 1 TO EN-PET-MOVING(L-ROW)
             MOVE 1 TO L-WALK
             COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-OWNER))
             COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-OWNER))
             COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-OWNER))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
         WHEN OTHER
             MOVE 0 TO EN-PET-MOVING(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM PET-TICK.
