*> Tame pets and the mob-versus-mob target path (lane 002-lane-mobsfull-h9; docs/protocol/18 section 8.2, 19 section 6.1).
*>
*> Entry points:
*>   PET-OWNER USING row, owner player row out          the alive player whose UUID is the pet's owner, in the pet's dimension (0 none)
*>   PET-FIND-FOE USING row, owner player row           a hostile standard mob that targets the owner (EN-FOE, EN-FOE-ID)
*>   PET-TICK USING row, hx, hz, walk out               one tick of a tame wolf: sit, defend the owner, follow the owner
*>   GOLEM-KIND USING dim, x, y, z, kind out            the block at a position: 1 carved pumpkin or jack o'lantern, 2 iron block, 3 snow block, 0 other
*>   GOLEM-BUILD USING dim, x, y, z                     the build patterns of the golems (19 sections 19 and 20) after a block was placed at x, y, z
*>   GOLEM-TICK USING row, hx, hz, walk out             one tick of an iron golem: it fights the nearest hostile mob
*>   GOLEM-HURT USING row, attacker player row          HurtByTarget: a hit by a player angers a golem that no player built
*>   GOLEM-OFFER-TICK USING row, roll                   OfferFlower: the 400 tick flower pose at night near a villager
*>   MOB-GOLEM-USE USING player row, entity row         an iron ingot on an iron golem repairs it

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
 01 WS-BEST-AGE            BINARY-LONG.
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
*>   OwnerHurtTargetGoal: else the mob the owner hit last (EN-KILLER of the mob, 100 ticks), not a creeper, not a tame wolf of the owner.
     IF WS-BEST = 0
         MOVE 0 TO WS-BEST-AGE
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                     AND EN-KILLER(WS-N) = L-OWNER AND EN-KILLER-AGE(WS-N) > WS-BEST-AGE
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-M
                 IF WS-M > 0 AND SM-KEY(WS-M) NOT = "creeper" AND NOT (EN-TAMED(WS-N) = 1 AND EN-OWNER-UUID(WS-N) = EN-OWNER-UUID(L-ROW))
                     MOVE WS-N TO WS-BEST
                     MOVE EN-KILLER-AGE(WS-N) TO WS-BEST-AGE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-KIND.
*> USING dim, x, y, z, kind out: the block at the position as a part of a golem pattern (19 sections 19 and 20): 1 carved pumpkin or jack o'lantern (any facing or lit state), 2 iron
*> block, 3 snow block, 0 anything else.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEYS.
    05 FILLER              PIC X(48) VALUE "minecraft:carved_pumpkin".
    05 FILLER              PIC X(48) VALUE "minecraft:jack_o_lantern".
    05 FILLER              PIC X(48) VALUE "minecraft:iron_block".
    05 FILLER              PIC X(48) VALUE "minecraft:snow_block".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(48) OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND.
     MOVE 0 TO L-KIND
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "WORLDSIM-FIND-BLOCK" USING WS-KEY(WS-I) WS-DEFAULT
         IF WS-DEFAULT > 0 AND CB-S-BLOCK(WS-DEFAULT + 1) = WS-BLOCK
             IF WS-I <= 2
                 MOVE 1 TO L-KIND
             ELSE
                 COMPUTE L-KIND = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GOLEM-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-BUILD.
*> USING dim, x, y, z: after a block was placed at x, y, z, the build patterns of CarvedPumpkinBlock (19 sections 19 and 20): a carved pumpkin or jack o'lantern with two snow blocks below
*> it makes a snow golem; with an iron block below and a T of iron blocks (the body two blocks tall, an arm on each side along x, else along z, the four other cells of the 3 x 3
*> pattern air) it makes an iron golem. The pattern blocks are cleared (BLOCK-CHANGE) and the golem appears at the lowest pattern block, centred, y + 0.05. Only a standard world has the
*> blocks of the patterns (GOLEM-KIND finds them by their standard keys), so no other world builds a golem.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-K3                  BINARY-LONG.
 01 WS-K4                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-S3                  BINARY-LONG.
 01 WS-S4                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-GOLEM               BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "GOLEM-KIND" USING L-DIM L-X L-Y L-Z WS-KIND
     IF WS-KIND NOT = 1
         GOBACK
     END-IF
     COMPUTE WS-Y1 = L-Y - 1
     COMPUTE WS-Y2 = L-Y - 2
     CALL "GOLEM-KIND" USING L-DIM L-X WS-Y1 L-Z WS-K1
     CALL "GOLEM-KIND" USING L-DIM L-X WS-Y2 L-Z WS-K2
     MOVE 0 TO WS-GOLEM
     IF WS-K1 = 3 AND WS-K2 = 3
         MOVE 1 TO WS-GOLEM
     END-IF
     IF WS-K1 = 2 AND WS-K2 = 2
*>       The arms: along x, else along z; the four corner cells of the pattern are air.
         COMPUTE WS-X1 = L-X - 1
         COMPUTE WS-X2 = L-X + 1
         COMPUTE WS-Z1 = L-Z - 1
         COMPUTE WS-Z2 = L-Z + 1
         CALL "GOLEM-KIND" USING L-DIM WS-X1 WS-Y1 L-Z WS-K3
         CALL "GOLEM-KIND" USING L-DIM WS-X2 WS-Y1 L-Z WS-K4
         IF WS-K3 = 2 AND WS-K4 = 2
             MOVE 2 TO WS-GOLEM
             MOVE 0 TO WS-AXIS
         ELSE
             CALL "GOLEM-KIND" USING L-DIM L-X WS-Y1 WS-Z1 WS-K3
             CALL "GOLEM-KIND" USING L-DIM L-X WS-Y1 WS-Z2 WS-K4
             IF WS-K3 = 2 AND WS-K4 = 2
                 MOVE 2 TO WS-GOLEM
                 MOVE 1 TO WS-AXIS
             END-IF
         END-IF
         IF WS-GOLEM = 2
             IF WS-AXIS = 0
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X1 L-Y L-Z WS-S1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X2 L-Y L-Z WS-S2
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X1 WS-Y2 L-Z WS-S3
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X2 WS-Y2 L-Z WS-S4
             ELSE
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y WS-Z1 WS-S1
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y WS-Z2 WS-S2
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y2 WS-Z1 WS-S3
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y2 WS-Z2 WS-S4
             END-IF
             IF WS-S1 NOT = 0 OR WS-S2 NOT = 0 OR WS-S3 NOT = 0 OR WS-S4 NOT = 0
                 MOVE 0 TO WS-GOLEM
             END-IF
         END-IF
     END-IF
     IF WS-GOLEM = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     IF WS-GOLEM = 1
         MOVE "minecraft:snow_golem" TO WS-KEY
     ELSE
         MOVE "minecraft:iron_golem" TO WS-KEY
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW WS-STATUS
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-AIR
     CALL "BLOCK-CHANGE" USING L-DIM L-X WS-Y1 L-Z WS-AIR
     CALL "BLOCK-CHANGE" USING L-DIM L-X WS-Y2 L-Z WS-AIR
     IF WS-GOLEM = 2
         IF WS-AXIS = 0
             CALL "BLOCK-CHANGE" USING L-DIM WS-X1 WS-Y1 L-Z WS-AIR
             CALL "BLOCK-CHANGE" USING L-DIM WS-X2 WS-Y1 L-Z WS-AIR
         ELSE
             CALL "BLOCK-CHANGE" USING L-DIM L-X WS-Y1 WS-Z1 WS-AIR
             CALL "BLOCK-CHANGE" USING L-DIM L-X WS-Y1 WS-Z2 WS-AIR
         END-IF
     END-IF
     COMPUTE WS-FX = L-X + 0.5
     COMPUTE WS-FY = WS-Y2 + 0.05
     COMPUTE WS-FZ = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ENTITY
*>   The golem of the pattern is player created (PlayerCreated: it never targets a player; 44 part 3 section 6).
     IF WS-GOLEM = 2
         MOVE 1 TO EN-PLAYER-MADE(WS-ENTITY)
     END-IF
     GOBACK.
 END PROGRAM GOLEM-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-TICK.
*> USING golem row, hx out, hz out, walk out: one tick of an iron golem (19 section 19, 44 part 3 section 6): the attack timer counts down. Targets, by priority: a player it is
*> angry at (GOLEM-HURT: HurtByTarget, the anger of EN-ANGER ticks; never a creative or spectator player) and else the nearest alive hostile standard mob of the golem's dimension
*> within 16 blocks that is not a creeper (NearestAttackable(Mob): an Enemy that is not a creeper; canAttack). The golem walks to it (STDMOB-HEAD at the row's speed, the chase speed 1.0) and in
*> reach hits it for A / 2 + nextInt(int(A)) points (A = 15; whole points, so A / 2 is 7) with a 20 tick timer, entity event 4 to the viewers; a mob target's vertical speed gets +0.4, a
*> player is hurt through HEALTH-MOB-HIT (difficulty scaling, armor). Without a target the golem may offer a flower (GOLEM-OFFER-TICK, a roll of nextInt(8000) every second tick).
*> Open: DefendVillageTarget (villager reputation), the villager and POI strolls, LookAtPlayer and RandomLookAround.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 COPY PROTO.
 01 WS-M                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-EVAL                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 41.
 01 WS-OFFER-SALT          BINARY-LONG VALUE 43.
 01 WS-OFFER-BOUND         BINARY-LONG VALUE 8000.
 01 WS-BOUND               BINARY-LONG VALUE 15.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 4.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF EN-PET-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     END-IF
     COMPUTE WS-REACH = SM-REACH-MILLI / 1000
*>   Angry at a player who hit it (the player's row must still be the one: in play, alive, in survival or adventure mode, in this dimension).
     IF EN-ANGER(L-ROW) > 0
         SUBTRACT 1 FROM EN-ANGER(L-ROW)
         MOVE EN-GOLEM-PL(L-ROW) TO WS-P
         IF WS-P = 0
             MOVE 0 TO EN-ANGER(L-ROW)
         ELSE
             IF PL-USED(WS-P) NOT = 1 OR PL-STATE(WS-P) NOT = PS-ALIVE OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW)
                     OR PL-MODE(WS-P) = 1 OR PL-MODE(WS-P) > 2
                 MOVE 0 TO EN-ANGER(L-ROW)
             END-IF
         END-IF
         IF EN-ANGER(L-ROW) = 0
             MOVE 0 TO EN-GOLEM-PL(L-ROW)
         END-IF
     END-IF
     IF EN-ANGER(L-ROW) > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         MOVE 1 TO L-WALK
         IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
             COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-P))
             COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-P))
             COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-P))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
         END-IF
         IF EN-PET-CD(L-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
                 AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
             MOVE SM-ATTACK-TICKS TO EN-PET-CD(L-ROW)
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
             COMPUTE WS-DAMAGE = SM-ATTACK(WS-M) / 2 + WS-DRAW
             CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
         GOBACK
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F > 0
         IF EN-USED(WS-F) NOT = 1 OR EN-ID(WS-F) NOT = EN-FOE-ID(L-ROW) OR EN-HEALTH(WS-F) = 0
             MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     IF EN-FOE(L-ROW) = 0
         MOVE 0 TO WS-F
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
                 COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                 IF WS-S > 0 AND WS-D2 <= 256 AND (WS-F = 0 OR WS-D2 < WS-BEST-D2)
                     IF SM-KIND(WS-S) = 1 AND SM-KEY(WS-S) NOT = "creeper"
                         MOVE WS-N TO WS-F
                         MOVE WS-D2 TO WS-BEST-D2
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-F > 0
             MOVE WS-F TO EN-FOE(L-ROW)
             MOVE EN-ID(WS-F) TO EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-F
     IF WS-F = 0
*>       No target: OfferFlower rolls nextInt(8000) at each evaluation of the goal selector (every second tick, 18 section 2.7).
         MOVE 1 TO WS-ROLL
         COMPUTE WS-Q = CW-TICKS + EN-ID(L-ROW)
         COMPUTE WS-EVAL = FUNCTION MOD(WS-Q, 2)
         IF WS-EVAL = 0 AND EN-GOLEM-FLOWER(L-ROW) = 0
             CALL "XP-RANDOM" USING WS-OFFER-SALT WS-OFFER-BOUND WS-ROLL
         END-IF
         CALL "GOLEM-OFFER-TICK" USING L-ROW WS-ROLL
         GOBACK
     END-IF
     MOVE 0 TO EN-GOLEM-FLOWER(L-ROW)
     COMPUTE WS-DX = EN-X(WS-F) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(WS-F) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-F) - EN-Z(L-ROW)
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
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE WS-DAMAGE = SM-ATTACK(WS-M) / 2 + WS-DRAW
         CALL "HEALTH-MOB-DAMAGE" USING WS-F WS-DAMAGE CAUSE-MOB WS-NONE
         COMPUTE EN-VY(WS-F) = EN-VY(WS-F) + 0.4
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM GOLEM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-HURT.
*> USING golem row, attacker player row (BINARY-LONG): HurtByTarget of the iron golem (44 part 3 section 6): a golem not built by a player (PlayerCreated clear) that a player hurt is angry at
*> that player for 20 to 39 seconds (400 to 780 ticks, the uniform range of the persistent anger). A player-created golem never targets a player (canAttack), and any other species ignores the call.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-SALT                BINARY-LONG VALUE 47.
 01 WS-BOUND               BINARY-LONG VALUE 381.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY NOT = "iron_golem" OR EN-PLAYER-MADE(L-ROW) = 1
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
     COMPUTE EN-ANGER(L-ROW) = 400 + WS-DRAW
     MOVE L-ATTACKER TO EN-GOLEM-PL(L-ROW)
     MOVE 0 TO EN-GOLEM-FLOWER(L-ROW)
     GOBACK.
 END PROGRAM GOLEM-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-EVENT.
*> USING row, event id (BINARY-LONG): Entity Event of the golem's entity to the players that see it.
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
 END PROGRAM GOLEM-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GOLEM-OFFER-TICK.
*> USING golem row, roll (BINARY-LONG, the draw of nextInt(8000)): OfferFlowerGoal of the iron golem (19 section 19, 44 part 3 section 6). While the pose lasts (EN-GOLEM-FLOWER ticks left, 400 at
*> the start) it counts down and Entity Event 34 ends it at 0. Otherwise, with the roll 0, at night (not isBrightOutside: the night's darkening of STDMOB-DARKEN at 4 or more) and a villager or a
*> copper golem (the tag candidate_for_iron_golem_gift) within 6 blocks and inside the gift box (the golem's box inflated by 6, 2, 6), the pose starts with Entity Event 11. Nothing is given to a
*> villager; a copper golem's antenna slot is not modelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-DARK                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-START               BINARY-LONG VALUE 11.
 01 WS-STOP                BINARY-LONG VALUE 34.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ROLL.
     IF EN-GOLEM-FLOWER(L-ROW) > 0
         SUBTRACT 1 FROM EN-GOLEM-FLOWER(L-ROW)
         IF EN-GOLEM-FLOWER(L-ROW) = 0
             CALL "GOLEM-EVENT" USING L-ROW WS-STOP
         END-IF
         GOBACK
     END-IF
     IF L-ROLL NOT = 0
         GOBACK
     END-IF
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
     IF WS-DARK < 4
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-FOUND = 1
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             CALL "MOB-SPECIES-KEY" USING WS-N WS-KEY
             IF WS-KEY = "villager" OR "copper_golem"
                 COMPUTE WS-DX = EN-X(WS-N) - EN-X(L-ROW)
                 COMPUTE WS-DY = EN-Y(WS-N) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-N) - EN-Z(L-ROW)
                 IF FUNCTION ABS(WS-DX) <= 6 AND FUNCTION ABS(WS-DZ) <= 6 AND WS-DY >= -2 AND WS-DY <= 4.7
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         MOVE 400 TO EN-GOLEM-FLOWER(L-ROW)
         CALL "GOLEM-EVENT" USING L-ROW WS-START
     END-IF
     GOBACK.
 END PROGRAM GOLEM-OFFER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-GOLEM-USE.
*> USING player row, entity row (an iron golem): an iron ingot in the main hand heals 25 points up to the maximum of 100 and is used up; a golem at its maximum health returns PASS and keeps
*> the ingot (19 section 19; the repair sound is an open item).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ENTITY) WS-M
     IF EN-HEALTH(L-ENTITY) < SM-HEALTH(WS-M)
         COMPUTE EN-HEALTH(L-ENTITY) = FUNCTION MIN(SM-HEALTH(WS-M), EN-HEALTH(L-ENTITY) + 25)
         CALL "MOB-TAKE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MOB-GOLEM-USE.

