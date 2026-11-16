*> The fishing bobber of lane 002-lane-mobsb6 (17 section 3.11, 44 part 8 section 10.1), kind 7 of PROJSTATE.cpy: PJ-OWNER the player's entity id, PJ-I1 the state (0 flying,
*> 1 hooked in an entity, 2 bobbing), PJ-I2 the hooked entity id, PJ-I3 timeUntilLured, PJ-I4 timeUntilHooked, PJ-I5 nibble, PJ-I6 the ticks resting on the ground (discard at 1200),
*> PJ-I7 the Lure level, PJ-I8 the Luck of the Sea level (both 0: the rod's enchantments are not read).
*> Cast: yaw Y and pitch P, c1 = cos(-Y - pi), s1 = sin(-Y - pi), c2 = -cos(-P), s2 = sin(-P): the hook starts at (x - s1 x 0.3, eye y, z - c1 x 0.3), v = (-s1, clamp(-(s2 / c2), -5, 5), -c1)
*> and each component is multiplied by 0.6 / len + 0.5. Flying: gravity 0.03; in water the velocity x (0.3, 0.2, 0.3) and bobbing; a block stops it (rest, life count); a player or mob
*> is hooked. Bobbing: e = y + vy - cell y - fluid height, |e| < 0.01 adds sign x 0.1, v = (0.9 vx, vy - e x r x 0.2, 0.9 vz); the bite timer follows. The hook is discarded when the owner
*> is gone, holds no rod in the main hand or is 32 blocks away. Retrieve: cost 2 on the ground, 3 an item, 5 another entity, 1 a biting fish (loot), else 0; the loot is the fishing table
*> (fish 60 cod, 25 salmon, 13 pufferfish, 2 tropical fish; junk; treasure) with the weights of TOOL-FISH-WEIGHTS and 1 to 6 experience.
*> Gaps: the drag of a flying hook (not in the documents: THROWN-FLY's 0.99 is used), the launch noise (triangle 0.0103365), open water (so no treasure), rain and the sky for the bite speed,
*> Lure and Luck of the Sea (0), the off hand rod, pulling a hooked entity (mobs have no horizontal velocity), the sounds and particles, the metadata (hooked entity, biting) is not sent,
*> bamboo junk only in jungles, enchanted or damaged treasure.
*>
*>   BOBBER-CAST USING player row, yaw, pitch (degrees, FLOAT-LONG), row out
*>   BOBBER-FIND USING player entity id, row out (0 none)
*>   BOBBER-FISH USING tracker row, slot, amount     catchingFish
*>   BOBBER-STEP USING tracker row
*>   BOBBER-RETRIEVE USING player row, tracker row, cost out
*>   BOBBER-USE USING connection id, yaw, pitch (FLOAT-LONG)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-CAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:fishing_bobber".
 01 WS-KIND                BINARY-LONG VALUE 7.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-YAW L-PITCH L-ROW.
     COMPUTE WS-YAW = L-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = L-PITCH * FUNCTION PI / 180
     COMPUTE WS-C1 = FUNCTION COS(0 - WS-YAW - FUNCTION PI)
     COMPUTE WS-S1 = FUNCTION SIN(0 - WS-YAW - FUNCTION PI)
     COMPUTE WS-C2 = 0 - FUNCTION COS(0 - WS-PITCH)
     COMPUTE WS-S2 = FUNCTION SIN(0 - WS-PITCH)
     COMPUTE WS-VX = 0 - WS-S1
     COMPUTE WS-VY = FUNCTION MAX(-5, FUNCTION MIN(5, 0 - (WS-S2 / WS-C2)))
     COMPUTE WS-VZ = 0 - WS-C1
     COMPUTE WS-LEN = FUNCTION SQRT(WS-VX * WS-VX + WS-VY * WS-VY + WS-VZ * WS-VZ)
     COMPUTE WS-F = 0.6 / WS-LEN + 0.5
     COMPUTE WS-VX = WS-VX * WS-F
     COMPUTE WS-VY = WS-VY * WS-F
     COMPUTE WS-VZ = WS-VZ * WS-F
     COMPUTE WS-X = PL-X(L-PLAYER) - WS-S1 * 0.3
     COMPUTE WS-Y = PL-Y(L-PLAYER) + 1.62
     COMPUTE WS-Z = PL-Z(L-PLAYER) - WS-C1 * 0.3
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY PL-DIM(L-PLAYER) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ PL-ENTITY-ID(L-PLAYER) L-ROW
     GOBACK.
 END PROGRAM BOBBER-CAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX OR L-ROW > 0
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 7 AND PJ-OWNER(WS-I) = L-OWNER
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ROW > 0
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I)
                     MOVE WS-E TO L-ROW
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOBBER-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-FISH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SALT                BINARY-LONG VALUE 9071.
 01 WS-B21                 BINARY-LONG VALUE 21.
 01 WS-B61                 BINARY-LONG VALUE 61.
 01 WS-B501                BINARY-LONG VALUE 501.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-AMOUNT.
     EVALUATE TRUE
         WHEN PJ-I5(L-SLOT) > 0
             SUBTRACT 1 FROM PJ-I5(L-SLOT)
             IF PJ-I5(L-SLOT) = 0
                 MOVE 0 TO PJ-I3(L-SLOT) PJ-I4(L-SLOT)
             END-IF
         WHEN PJ-I4(L-SLOT) > 0
             SUBTRACT L-AMOUNT FROM PJ-I4(L-SLOT)
             IF PJ-I4(L-SLOT) <= 0
                 MOVE 0 TO PJ-I4(L-SLOT)
                 CALL "XP-RANDOM" USING WS-SALT WS-B21 WS-R
                 COMPUTE PJ-I5(L-SLOT) = 20 + WS-R
             END-IF
         WHEN PJ-I3(L-SLOT) > 0
             SUBTRACT L-AMOUNT FROM PJ-I3(L-SLOT)
             IF PJ-I3(L-SLOT) <= 0
                 MOVE 0 TO PJ-I3(L-SLOT)
                 CALL "XP-RANDOM" USING WS-SALT WS-B61 WS-R
                 COMPUTE PJ-I4(L-SLOT) = 20 + WS-R
             END-IF
         WHEN OTHER
             CALL "XP-RANDOM" USING WS-SALT WS-B501 WS-R
             CALL "TOOL-FISH-WAIT" USING WS-R PJ-I7(L-SLOT) PJ-I3(L-SLOT)
     END-EVALUATE
     GOBACK.
 END PROGRAM BOBBER-FISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-LOOT.
*> USING player row, hook row, open water, luck: the fishing table roll (17 section 3.11): the items thrown toward the player, one experience orb of 1 to 6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 9072.
 01 WS-FISH                BINARY-LONG.
 01 WS-JUNK                BINARY-LONG.
 01 WS-TREASURE            BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-TABLE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-PICK                PIC X(48).
 01 WS-ROW-KEY             PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DROP                BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-XP                  BINARY-LONG.
 01 WS-ORB                 BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-BIG                 BINARY-LONG VALUE 100000.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-LUCK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-OPEN L-LUCK.
     CALL "TOOL-FISH-WEIGHTS" USING L-LUCK L-OPEN WS-FISH WS-JUNK WS-TREASURE
     COMPUTE WS-TOTAL = WS-FISH + WS-JUNK + WS-TREASURE
     CALL "XP-RANDOM" USING WS-SALT WS-TOTAL WS-R
     EVALUATE TRUE
         WHEN WS-R < WS-FISH
             MOVE 1 TO WS-TABLE
         WHEN WS-R < WS-FISH + WS-JUNK
             MOVE 2 TO WS-TABLE
         WHEN OTHER
             MOVE 3 TO WS-TABLE
     END-EVALUATE
*>   The sum of the weights of the table, then a draw inside it.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "TOOL-FISH-ENTRY" USING WS-TABLE WS-I WS-ITEM-KEY WS-WEIGHT
         ADD WS-WEIGHT TO WS-SUM
     END-PERFORM
     CALL "XP-RANDOM" USING WS-SALT WS-SUM WS-R
     MOVE SPACES TO WS-PICK
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-PICK NOT = SPACES
         ADD 1 TO WS-I
         CALL "TOOL-FISH-ENTRY" USING WS-TABLE WS-I WS-ITEM-KEY WS-WEIGHT
         IF WS-R < WS-WEIGHT
             MOVE WS-ITEM-KEY TO WS-PICK
         ELSE
             SUBTRACT WS-WEIGHT FROM WS-R
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-ROW-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-PICK) DELIMITED BY SIZE INTO WS-ROW-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ROW-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-DX = PL-X(L-PLAYER) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(L-PLAYER) - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(L-PLAYER) - EN-Z(L-ROW)
     COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WS-VX = WS-DX * 0.1
     COMPUTE WS-VY = WS-DY * 0.1 + FUNCTION SQRT(WS-DIST) * 0.08
     COMPUTE WS-VZ = WS-DZ * 0.1
     IF WS-STATUS = 0
         CALL "GI-SPAWN" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-DELAY WS-DROP
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-SIX WS-R
     CALL "TOOL-FISH-XP" USING WS-R WS-XP
     MOVE PL-X(L-PLAYER) TO WS-OX
     COMPUTE WS-OY = PL-Y(L-PLAYER) + 0.5
     COMPUTE WS-OZ = PL-Z(L-PLAYER) + 0.5
     CALL "XP-ORB-SPAWN" USING EN-DIM(L-ROW) WS-OX WS-OY WS-OZ WS-XP WS-ORB
     GOBACK.
 END PROGRAM BOBBER-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-RETRIEVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-FISH                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG VALUE 0.
 01 WS-LUCK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-COST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-COST.
     MOVE 0 TO L-COST
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         MOVE 0 TO WS-GROUND WS-ITEM WS-ENTITY WS-FISH
         IF PJ-I6(WS-SLOT) > 0
             MOVE 1 TO WS-GROUND
         END-IF
         IF PJ-I1(WS-SLOT) = 1
             MOVE 1 TO WS-ENTITY
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-I2(WS-SLOT) AND EN-ITEM-COUNT(WS-E) > 0
                     MOVE 1 TO WS-ITEM
                     MOVE 0 TO WS-ENTITY
                 END-IF
             END-PERFORM
         END-IF
         IF PJ-I5(WS-SLOT) > 0
             MOVE 1 TO WS-FISH
         END-IF
         CALL "TOOL-FISH-RETRIEVE" USING WS-GROUND WS-ITEM WS-ENTITY WS-FISH L-COST
         IF WS-FISH = 1
             MOVE PJ-I8(WS-SLOT) TO WS-LUCK
             CALL "BOBBER-LOOT" USING L-PLAYER L-ROW WS-OPEN WS-LUCK
         END-IF
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM BOBBER-RETRIEVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-SLOT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-STOP                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-WK                  BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9073.
 01 WS-THOUSAND            BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   The owner check (10.1): alive, a rod in the main hand, within 32 blocks.
     MOVE 0 TO WS-OWNER WS-STOP
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = PJ-OWNER(WS-SLOT)
             MOVE WS-P TO WS-OWNER
         END-IF
     END-PERFORM
     IF WS-OWNER = 0
         MOVE 1 TO WS-STOP
     ELSE
         MOVE SPACES TO WS-KEY
         IF PL-SLOT-COUNT(WS-OWNER, PL-HELD(WS-OWNER) + 1) > 0
             CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-OWNER, PL-HELD(WS-OWNER) + 1) WS-KEY
         END-IF
         COMPUTE WS-DX = EN-X(L-ROW) - PL-X(WS-OWNER)
         COMPUTE WS-DY = EN-Y(L-ROW) - PL-Y(WS-OWNER)
         COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(WS-OWNER)
         IF PL-STATE(WS-OWNER) NOT = PS-ALIVE OR WS-KEY NOT = "fishing_rod" OR WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ > 1024
             MOVE 1 TO WS-STOP
         END-IF
     END-IF
     IF WS-STOP = 1
         CALL "PJ-DROP" USING L-ROW
         GOBACK
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "BOAT-FLUID" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-H WS-WK
     EVALUATE PJ-I1(WS-SLOT)
         WHEN 1
*>           Hooked: follow the entity at 0.8 of its height; when it is gone the hook flies again.
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
                 IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = PJ-I2(WS-SLOT)
                     MOVE WS-I TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 MOVE 0 TO PJ-I1(WS-SLOT) PJ-I2(WS-SLOT)
             ELSE
                 COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-FOUND) + 1) / 1000
                 MOVE EN-X(WS-FOUND) TO EN-X(L-ROW)
                 COMPUTE EN-Y(L-ROW) = EN-Y(WS-FOUND) + WS-HEIGHT * 0.8
                 MOVE EN-Z(WS-FOUND) TO EN-Z(L-ROW)
                 CALL "THROWN-SYNC" USING L-ROW
             END-IF
         WHEN 2
             CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-R1
             CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-R2
             COMPUTE WS-E = EN-Y(L-ROW) + EN-VY(L-ROW) - WS-CY - WS-H
             IF FUNCTION ABS(WS-E) < 0.01
                 IF WS-E < 0
                     COMPUTE WS-E = WS-E - 0.1
                 ELSE
                     COMPUTE WS-E = WS-E + 0.1
                 END-IF
             END-IF
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.9
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - WS-E * (WS-R1 / 1000) * 0.2
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.9
             IF PJ-I5(WS-SLOT) > 0
                 COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.1 * (WS-R1 / 1000) * (WS-R2 / 1000)
             END-IF
             COMPUTE EN-X(L-ROW) = EN-X(L-ROW) + EN-VX(L-ROW)
             COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + EN-VY(L-ROW)
             COMPUTE EN-Z(L-ROW) = EN-Z(L-ROW) + EN-VZ(L-ROW)
             CALL "THROWN-SYNC" USING L-ROW
             MOVE 1 TO WS-AMOUNT
             CALL "BOBBER-FISH" USING L-ROW WS-SLOT WS-AMOUNT
         WHEN OTHER
             IF WS-WK > 0
                 COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.3
                 COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.2
                 COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.3
                 MOVE 2 TO PJ-I1(WS-SLOT)
             ELSE
                 CALL "THROWN-FLY" USING L-ROW WS-GRAVITY WS-HIT WS-ENTITY WS-PLAYER
                 EVALUATE WS-HIT
                     WHEN 1
                         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
                         ADD 1 TO PJ-I6(WS-SLOT)
                         IF PJ-I6(WS-SLOT) >= 1200
                             CALL "PJ-DROP" USING L-ROW
                         END-IF
                     WHEN 2
                         MOVE 1 TO PJ-I1(WS-SLOT)
                         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
                         IF WS-PLAYER > 0
                             MOVE PL-ENTITY-ID(WS-PLAYER) TO PJ-I2(WS-SLOT)
                         ELSE
                             MOVE EN-ID(WS-ENTITY) TO PJ-I2(WS-SLOT)
                         END-IF
                     WHEN OTHER
                         MOVE 0 TO PJ-I6(WS-SLOT)
                 END-EVALUATE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BOBBER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-USE.
*> USING connection id, yaw, pitch (FLOAT-LONG): Use Item with a rod: a hook out is retrieved (the rod pays the cost, 3.11), else a cast.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HOOK                BINARY-LONG.
 01 WS-COST                BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ID L-YAW L-PITCH.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "BOBBER-FIND" USING PL-ENTITY-ID(WS-ROW) WS-HOOK
     IF WS-HOOK > 0
         CALL "BOBBER-RETRIEVE" USING WS-ROW WS-HOOK WS-COST
         IF WS-COST > 0
             CALL "TOOL-HURT-STACK" USING PL-CONN(WS-ROW) PL-HELD(WS-ROW) WS-COST WS-BROKE
         END-IF
     ELSE
         CALL "BOBBER-CAST" USING WS-ROW L-YAW L-PITCH WS-HOOK
     END-IF
     GOBACK.
 END PROGRAM BOBBER-USE.
