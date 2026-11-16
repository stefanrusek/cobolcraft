*> Fox (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 7; 44-residual-mob-questions-4-land-animals.md section 4).
*> - Held item: a new adult gets one with chance 0.2 (FOX-HELD-ITEM; the rolls are draws of 0 to 9999 for nextFloat): r < 0.05 emerald, < 0.2 egg, < 0.4 rabbit hide or rabbit foot (the boolean decides:
*>   true is the hide, the docs leave the mapping open), < 0.6 wheat, < 0.8 leather, else feather. The item is dropped when the fox dies (FOX-DROP-HELD, inside the mob_drops rule). A baby has an empty hand.
*> - Trust: the baby of two foxes trusts the players that fed the parents (the love causes; EN-FOX-TRUST-A and -B, metadata 20 and 21), FOX-TRUSTS tests the membership.
*> - Avoid player (AvoidEntity, 16 blocks, speeds 1.6 and 1.4): a survival or adventure player who is not sneaking and not trusted within 16 blocks makes the fox walk straight away from the nearest one, at
*>   the walk speed x 1.6, x 1.4 within 7 blocks (squares of the attribute speeds as in the row columns: 507 and 388 thousandths of a block a tick).
*> - The type (metadata 18: 0 red, 1 snow) is EN-WOOL; the biome rule (spawns_snow_foxes) has no biome data in the open set yet, so every fox spawns red; breeding takes the type of a parent by the coin.
*> Open items: the snow type by biome, eating and picking up items, stalking and pouncing on prey (the mob target is player-only), the defend-trusted goal, sleeping, shelter, the flags byte (19), the
*>   other avoid targets (wolf, polar bear), berries, the leap, perching, the faceplant.
*>
*> Entry points:
*>   FOX-HELD-ITEM USING roll1, roll2, boolean, key out (PIC X(24), spaces: none)
*>   FOX-BORN USING row                     FOX-BRED USING parent a, parent b, baby, coin
*>   FOX-TRUSTS USING fox row, player row, trusts out    FOX-DROP-HELD USING row
*>   FOX-TICK USING row, hx, hz, walk out   the flight from a player; walk is 1 when hx and hz are this tick's walk

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-HELD-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-BOOL                 BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-R1 L-R2 L-BOOL L-KEY.
     MOVE SPACES TO L-KEY
     IF L-R1 < 2000
         EVALUATE TRUE
             WHEN L-R2 < 500
                 MOVE "emerald" TO L-KEY
             WHEN L-R2 < 2000
                 MOVE "egg" TO L-KEY
             WHEN L-R2 < 4000 AND L-BOOL = 1
                 MOVE "rabbit_hide" TO L-KEY
             WHEN L-R2 < 4000
                 MOVE "rabbit_foot" TO L-KEY
             WHEN L-R2 < 6000
                 MOVE "wheat" TO L-KEY
             WHEN L-R2 < 8000
                 MOVE "leather" TO L-KEY
             WHEN OTHER
                 MOVE "feather" TO L-KEY
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM FOX-HELD-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-BORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-1              BINARY-LONG VALUE 71.
 01 WS-SALT-2              BINARY-LONG VALUE 72.
 01 WS-SALT-3              BINARY-LONG VALUE 73.
 01 WS-BOUND               BINARY-LONG VALUE 10000.
 01 WS-BOUND-2             BINARY-LONG VALUE 2.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT-1 WS-BOUND WS-R1
     CALL "XP-RANDOM" USING WS-SALT-2 WS-BOUND WS-R2
     CALL "XP-RANDOM" USING WS-SALT-3 WS-BOUND-2 WS-BOOL
     CALL "FOX-HELD-ITEM" USING WS-R1 WS-R2 WS-BOOL WS-KEY
     MOVE 0 TO EN-FOX-HELD(L-ROW)
     IF WS-KEY NOT = SPACES
         CALL "MOB-ITEM-ID" USING WS-KEY EN-FOX-HELD(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM FOX-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-BRED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY L-COIN.
     MOVE 0 TO EN-FOX-HELD(L-BABY)
     MOVE EN-WOOL(L-A) TO EN-WOOL(L-BABY)
     IF L-COIN = 1
         MOVE EN-WOOL(L-B) TO EN-WOOL(L-BABY)
     END-IF
     IF EN-LOVE-CAUSE(L-A) > 0
         MOVE PL-UUID(EN-LOVE-CAUSE(L-A)) TO EN-FOX-TRUST-A(L-BABY)
     END-IF
     IF EN-LOVE-CAUSE(L-B) > 0
         MOVE PL-UUID(EN-LOVE-CAUSE(L-B)) TO EN-FOX-TRUST-B(L-BABY)
     END-IF
     GOBACK.
 END PROGRAM FOX-BRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-TRUSTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-TRUSTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-TRUSTS.
     MOVE 0 TO L-TRUSTS
     IF EN-FOX-TRUST-A(L-ROW) = PL-UUID(L-PLAYER) OR EN-FOX-TRUST-B(L-ROW) = PL-UUID(L-PLAYER)
         MOVE 1 TO L-TRUSTS
     END-IF
     GOBACK.
 END PROGRAM FOX-TRUSTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-DROP-HELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "fox" AND EN-FOX-HELD(L-ROW) > 0
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET EN-FOX-HELD(L-ROW) WS-ONE
             WS-PATCH WS-ITEM-ENTITY
         MOVE 0 TO EN-FOX-HELD(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM FOX-DROP-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FOX-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-TRUSTS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK WS-BEST
*>   A sleeping or faceplanted fox stands still (44 part 4 section 4: SleepGoal, FaceplantGoal).
     IF FUNCTION MOD(EN-FOX-FLAGS(L-ROW), 128) >= 32
         CALL "M44-FOX-IDLE" USING L-ROW L-HX L-HZ L-WALK
         IF L-WALK = 2
             GOBACK
         END-IF
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-SNEAKING(WS-P) = 0
                 AND PL-MODE(WS-P) NOT = 1 AND PL-MODE(WS-P) NOT = 3
             CALL "FOX-TRUSTS" USING L-ROW WS-P WS-TRUSTS
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-TRUSTS = 0 AND WS-D2 < 256 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE WS-P TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST = 0
         CALL "M44-FOX-HUNT" USING L-ROW L-HX L-HZ L-WALK
         IF L-WALK = 0 AND EN-FOE(L-ROW) = 0
             CALL "M44-FOX-IDLE" USING L-ROW L-HX L-HZ L-WALK
         END-IF
     END-IF
     IF WS-BEST > 0
         MOVE 1 TO L-WALK
         COMPUTE WS-DX = EN-X(L-ROW) - PL-X(WS-BEST)
         COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(WS-BEST)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         MOVE 0.507 TO WS-SPEED
         IF WS-BEST-D2 < 49
             MOVE 0.388 TO WS-SPEED
         END-IF
         IF WS-H > 0
             COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
             COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FOX-TICK.
