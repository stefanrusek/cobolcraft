*> Bee (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 16), without a hive: it is a neutral mob (SM-NEUTRAL 5) that a hit by a player angers
*> (NETHER-HURT: anger, the player as target, every bee within the follow range alerted; NETHER-AGGRO counts it down), it walks at its target and stings it once, then it is stung and dies
*> by the sting countdown. In water for more than 20 consecutive ticks it takes 1 drowning damage a tick. The flags byte of metadata 18 is 2 rolling, 4 stung, 8 nectar (MOB-DATA-VALUES).
*> Flowers, pollination and the hive trips are in core/src/mob-44-k.cob (M44-BEE-BRAIN, 002-lane-mobsa4).
*> Open items: flight (BeeAttack 1.4, the flying speed), crops grown (the timings of the
*> flower and hive goals are not in the docs), the anger end time (metadata 19), the stinger count of the victim, the sting damage type for death messages (mob_attack is used), temptation
*> and growing up faster.
*>
*> Entry points:
*>   BEE-TICK USING row, hx out, hz out, walk out        one tick of a bee: anger, water, the sting countdown, the sting; walk 1 means hx and hz are the walk of this tick
*>   M1916-BEE-FOOD USING item, found                    1 when the item is in the tag bee_food (the flowers)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M1916-BEE-FOOD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-ITEM                 PIC X(24).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-FOUND.
     MOVE 0 TO L-FOUND
     EVALUATE L-ITEM
         WHEN "dandelion" WHEN "open_eyeblossom" WHEN "poppy" WHEN "blue_orchid" WHEN "allium" WHEN "azure_bluet" WHEN "red_tulip"
         WHEN "orange_tulip" WHEN "white_tulip" WHEN "pink_tulip" WHEN "oxeye_daisy" WHEN "cornflower" WHEN "lily_of_the_valley"
         WHEN "wither_rose" WHEN "torchflower" WHEN "sunflower" WHEN "lilac" WHEN "peony" WHEN "rose_bush" WHEN "pitcher_plant"
         WHEN "flowering_azalea_leaves" WHEN "flowering_azalea" WHEN "mangrove_propagule" WHEN "cherry_leaves" WHEN "pink_petals"
         WHEN "wildflowers" WHEN "chorus_flower" WHEN "spore_blossom" WHEN "cactus_flower"
             MOVE 1 TO L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM M1916-BEE-FOOD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY RULES.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-KIND-WATER          BINARY-LONG VALUE 1.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-CAUSE-MOB           BINARY-LONG VALUE CAUSE-MOB.
 01 WS-NECTAR-BEFORE       BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     CALL "NETHER-AGGRO" USING L-ROW WS-M
*>   Water: the count of consecutive ticks in water; beyond 20 each tick costs 1 drowning damage.
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-ZERO WS-KIND-WATER WS-WET
     IF WS-WET = 1
         ADD 1 TO EN-BEE-WET(L-ROW)
     ELSE
         MOVE 0 TO EN-BEE-WET(L-ROW)
     END-IF
     IF EN-BEE-WET(L-ROW) > 20
         MOVE 1 TO WS-AMOUNT
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT CAUSE-DROWN WS-NO-ATTACKER
     END-IF
*>   A stung bee counts timeSinceSting up; every 5 ticks it dies with chance 1 / clamp(1200 - ticks, 1, 1200).
     IF EN-BEE-STUNG(L-ROW) = 1
         ADD 1 TO EN-BEE-T(L-ROW)
         IF FUNCTION MOD(EN-BEE-T(L-ROW), 5) = 0
             COMPUTE WS-LIMIT = 1200 - EN-BEE-T(L-ROW)
             IF WS-LIMIT < 1
                 MOVE 1 TO WS-LIMIT
             END-IF
             MOVE EN-ID(L-ROW) TO WS-ARG(1)
             MOVE CW-TIME TO WS-ARG(2)
             MOVE 51 TO WS-ARG(3)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
             IF FUNCTION MOD(WS-R, WS-LIMIT) = 0
                 MOVE EN-HEALTH(L-ROW) TO WS-AMOUNT
                 CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT CAUSE-GENERIC WS-NO-ATTACKER
             END-IF
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO WS-ROLL
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF WS-D2 <= 4
             MOVE 1 TO WS-ROLL
         END-IF
         CALL "BR-WORLD-READY"
         COMPUTE WS-REACH = SM-REACH-MILLI / 1000
         IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
             COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-P))
             COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-P))
             COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-P))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
             MOVE 1 TO L-WALK
         END-IF
*>       The sting (not on Peaceful): the attack damage as an int, no difficulty scaling; Poison 0, 10 or 18 seconds by difficulty (peaceful and easy 0).
         IF BW-DIFFICULTY > 0 AND FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
                 AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
             COMPUTE WS-MILLI = SM-ATTACK(WS-M) * 1000
             CALL "STDMOB-NAME" USING EN-TYPE(L-ROW) PL-KILLER-NAME(WS-P) PL-KILLER-LENGTH(WS-P)
             MOVE 0 TO PL-KILLER-ITEM-LENGTH(WS-P)
             MOVE PL-KILLER-NAME(WS-P) TO PL-CREDIT-NAME(WS-P)
             MOVE PL-KILLER-LENGTH(WS-P) TO PL-CREDIT-LENGTH(WS-P)
             MOVE CW-TICKS TO PL-CREDIT-TICK(WS-P)
             CALL "HEALTH-HURT" USING WS-P WS-MILLI WS-CAUSE-MOB EN-ID(L-ROW) WS-NO-ATTACKER WS-RESULT
             MOVE 0 TO WS-SECONDS
             IF BW-DIFFICULTY = 2
                 MOVE 10 TO WS-SECONDS
             END-IF
             IF BW-DIFFICULTY = 3
                 MOVE 18 TO WS-SECONDS
             END-IF
             COMPUTE WS-DURATION = WS-SECONDS * 20
             IF WS-DURATION > 0
                 CALL "EFFECT-ADD" USING WS-P WS-POISON WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
             MOVE 1 TO EN-BEE-STUNG(L-ROW)
             MOVE 0 TO EN-BEE-T(L-ROW) EN-ANGER(L-ROW) EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) WS-ROLL
             MOVE 0 TO L-WALK
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     IF WS-ROLL NOT = EN-BEE-ROLL(L-ROW)
         MOVE WS-ROLL TO EN-BEE-ROLL(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
*>   Flowers, pollination and the hive (core/src/mob-44-k.cob); the nectar flag is metadata 18 bit 8. A bee that went into a hive is no longer a row.
     MOVE EN-BEE-NECTAR(L-ROW) TO WS-NECTAR-BEFORE
     CALL "M44-BEE-BRAIN" USING L-ROW
     IF EN-USED(L-ROW) = 1 AND EN-BEE-NECTAR(L-ROW) NOT = WS-NECTAR-BEFORE
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM BEE-TICK.
