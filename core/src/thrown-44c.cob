*> The fishing bobber of lane 002-lane-mobsb6 (17 section 3.11, 44 part 8 section 10.1), kind 7 of PROJSTATE.cpy: PJ-OWNER the player's entity id, PJ-I1 the state (0 flying,
*> 1 hooked in an entity, 2 bobbing), PJ-I2 the hooked entity id, PJ-I3 timeUntilLured, PJ-I4 timeUntilHooked, PJ-I5 nibble, PJ-I6 the ticks resting on the ground (discard at 1200),
*> PJ-I7 the Lure level, PJ-I8 the Luck of the Sea level (both 0: the rod's enchantments are not read).
*> Cast: yaw Y and pitch P, c1 = cos(-Y - pi), s1 = sin(-Y - pi), c2 = -cos(-P), s2 = sin(-P): the hook starts at (x - s1 x 0.3, eye y, z - c1 x 0.3), v = (-s1, clamp(-(s2 / c2), -5, 5), -c1)
*> and each component is multiplied by 0.6 / len + 0.5. A tick (57-client-closures-2 section 1.2): gravity 0.03 (not in water), the move by the velocity (BOBBER-MOVE; a block stops
*> it, a player or mob hooks it while flying), then the velocity x 0.92 on all three components (BOBBER-GLIDE). Flying in water: the velocity x (0.3, 0.2, 0.3), bobbing, the tick ends there.
*> Bobbing: e = y + vy - cell y - fluid height, |e| < 0.01 adds sign x 0.1, v = (0.9 vx, vy - e x r x 0.2, 0.9 vz); then the open-water flag (PJ-I9 1 = not open, PJ-I10 outOfWaterTime;
*> 1.3a: only lowered while a fish is on its way or biting, BOBBER-OPEN-WATER the layers rule of 17 section 3.11) and, in water, the biting term (nibble > 0: vy - 0.1 x r x r) and the bite
*> timer; out of water outOfWaterTime counts up to 10. The bite dip (1.5): vy = -0.4 x (0.6 + 0.4 f) when the nibble starts. The hook is discarded when the owner
*> is gone, holds no rod in the main hand or is 32 blocks away, or after 1200 ticks on the ground. Retrieve: cost 2 on the ground, 3 an item, 5 another entity, 1 a biting fish (loot), else 0; the loot is the fishing table
*> (fish 60 cod, 25 salmon, 13 pufferfish, 2 tropical fish; junk; treasure) with the weights of TOOL-FISH-WEIGHTS and 1 to 6 experience.
*> Gaps: the launch noise (triangle 0.0103365), rain and the sky for the bite speed,
*> Lure and Luck of the Sea (0), the off hand rod, pulling a hooked entity (mobs have no horizontal velocity), the sounds and particles, the metadata (hooked entity, biting) is not sent,
*> bamboo junk only in jungles, enchanted or damaged treasure.
*>
*>   BOBBER-CAST USING player row, yaw, pitch (degrees, FLOAT-LONG), row out
*>   BOBBER-FIND USING player entity id, row out (0 none)
*>   BOBBER-FISH USING tracker row, slot, amount     catchingFish
*>   BOBBER-STEP USING tracker row
*>   BOBBER-OPEN-WATER USING dimension, block x, y, z of the hook, open out (1 open water)
*>   BOBBER-MOVE USING tracker row, check entities (1 flying), hit out (0 none, 1 block, 2 entity), entity row out, player row out
*>   BOBBER-GLIDE USING tracker row, projectile slot, flying (0/1), in water (0/1): gravity (not in water), BOBBER-MOVE, the contact rules, the drag 0.92 and the sync
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
 01 WS-B1001               BINARY-LONG VALUE 1000.
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
*>               The bite dip (57-client-closures-2 section 1.5): vy = -0.4 x (0.6 + 0.4 f), f in [0, 1).
                 CALL "XP-RANDOM" USING WS-SALT WS-B1001 WS-R
                 COMPUTE EN-VY(L-ROW) = 0 - 0.4 * (0.6 + 0.4 * WS-R / 1000)
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
*>           The treasure branch reads openWater at the moment of the catch (57-client-closures-2 section 1.3a).
             COMPUTE WS-OPEN = 1 - PJ-I9(WS-SLOT)
             CALL "BOBBER-LOOT" USING L-PLAYER L-ROW WS-OPEN WS-LUCK
         END-IF
     END-IF
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM BOBBER-RETRIEVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-OPEN-WATER.
*> USING dimension row, block x, y, z (BINARY-LONG, the hook's block), open out (1 open water): calculateOpenWater (17 section 3.11): four horizontal 5 x 5 layers at y offsets -1 to +2
*> around the block; a layer is ABOVE_WATER (0: every cell air or a lily pad), INSIDE_WATER (1: every cell a water source with no collision shape) or INVALID (2: anything else, also a mix).
*> Scanning from the bottom: an INVALID layer, an ABOVE_WATER first layer and an INSIDE_WATER layer that follows an ABOVE_WATER one all end it (not open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LILY-KEY            PIC X(48) VALUE "minecraft:lily_pad".
 01 WS-DY                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-LILY                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-PREVIOUS            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OPEN.
     MOVE 1 TO L-OPEN
     MOVE -1 TO WS-PREVIOUS
     PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 2 OR L-OPEN = 0
         MOVE -1 TO WS-LAYER
         PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-X = L-X + WS-DX
                 COMPUTE WS-Y = L-Y + WS-DY
                 COMPUTE WS-Z = L-Z + WS-DZ
                 CALL "FLUID-CELL" USING L-DIM WS-X WS-Y WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                     WS-SOLID WS-HOLDS
                 MOVE 0 TO WS-LILY
                 IF WS-STATE NOT = 0
                     CALL "FLUID-KEY-IS" USING WS-STATE WS-LILY-KEY WS-LILY
                 END-IF
                 EVALUATE TRUE
                     WHEN WS-STATE = 0 OR WS-LILY = 1
                         MOVE 0 TO WS-CELL
                     WHEN WS-FLUID = 1 AND WS-KIND = 2 AND WS-SOLID = 0
                         MOVE 1 TO WS-CELL
                     WHEN OTHER
                         MOVE 2 TO WS-CELL
                 END-EVALUATE
                 EVALUATE TRUE
                     WHEN WS-LAYER = -1
                         MOVE WS-CELL TO WS-LAYER
                     WHEN WS-LAYER NOT = WS-CELL
                         MOVE 2 TO WS-LAYER
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
         EVALUATE TRUE
             WHEN WS-LAYER = 2
                 MOVE 0 TO L-OPEN
             WHEN WS-LAYER = 0 AND WS-PREVIOUS = -1
                 MOVE 0 TO L-OPEN
             WHEN WS-LAYER = 1 AND WS-PREVIOUS = 0
                 MOVE 0 TO L-OPEN
         END-EVALUATE
         MOVE WS-LAYER TO WS-PREVIOUS
     END-PERFORM
     GOBACK.
 END PROGRAM BOBBER-OPEN-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-MOVE.
*> USING tracker row, check entities (1 while flying), hit out (0 none, 1 a solid cell, 2 an entity), entity row out, player row out: the hook moves by its velocity (EN-VX to EN-VZ),
*> walked in steps of at most 0.1 block against solid cells and, while flying, against players and standard mobs other than the owner (ARROW-FIND-HIT); the position ends at the last
*> free point (a block hit) or at the sample inside the entity. The viewers are not told here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHECK                BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHECK L-HIT L-ENTITY L-PLAYER.
     MOVE 0 TO L-HIT L-ENTITY L-PLAYER
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     COMPUTE WS-STEPS = FUNCTION INTEGER(WS-SPEED / 0.1) + 1
     MOVE EN-X(L-ROW) TO WS-PX
     MOVE EN-Y(L-ROW) TO WS-PY
     MOVE EN-Z(L-ROW) TO WS-PZ
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-STEPS OR L-HIT > 0
         COMPUTE WS-QX = EN-X(L-ROW) + EN-VX(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QY = EN-Y(L-ROW) + EN-VY(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QZ = EN-Z(L-ROW) + EN-VZ(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-CX = FUNCTION INTEGER(WS-QX)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-QY)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE 1 TO L-HIT
         ELSE
             MOVE WS-QX TO WS-PX
             MOVE WS-QY TO WS-PY
             MOVE WS-QZ TO WS-PZ
             IF L-CHECK = 1
                 CALL "ARROW-FIND-HIT" USING L-ROW WS-QX WS-QY WS-QZ L-ENTITY L-PLAYER
                 IF L-ENTITY > 0 OR L-PLAYER > 0
                     MOVE 2 TO L-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-PX TO EN-X(L-ROW)
     MOVE WS-PY TO EN-Y(L-ROW)
     MOVE WS-PZ TO EN-Z(L-ROW)
     GOBACK.
 END PROGRAM BOBBER-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-GLIDE.
*> USING tracker row, projectile slot, flying (0/1), in water (0/1): steps 8 to 11 of 57-client-closures-2 section 1.2 for a hook that did not end its tick early: gravity 0.03 unless the
*> hook's block has water, the move (BOBBER-MOVE), the contact rules (a block: flying velocity 0, ticks on the ground counted, 1200 discard; an entity while flying: hooked; no contact: the
*> ground count restarts), the velocity x 0.92 on all three components and the viewers told.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FLYING               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-FLYING L-WATER.
     IF L-WATER = 0
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.03
     END-IF
     CALL "BOBBER-MOVE" USING L-ROW L-FLYING WS-HIT WS-ENTITY WS-PLAYER
     EVALUATE WS-HIT
         WHEN 1
             IF L-FLYING = 1
                 MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
             ELSE
                 MOVE 0 TO EN-VY(L-ROW)
             END-IF
             ADD 1 TO PJ-I6(L-SLOT)
             IF PJ-I6(L-SLOT) >= 1200
                 CALL "PJ-DROP" USING L-ROW
                 GOBACK
             END-IF
         WHEN 2
             MOVE 1 TO PJ-I1(L-SLOT)
             MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
             IF WS-PLAYER > 0
                 MOVE PL-ENTITY-ID(WS-PLAYER) TO PJ-I2(L-SLOT)
             ELSE
                 MOVE EN-ID(WS-ENTITY) TO PJ-I2(L-SLOT)
             END-IF
         WHEN OTHER
             MOVE 0 TO PJ-I6(L-SLOT)
     END-EVALUATE
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.92
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.92
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.92
     CALL "THROWN-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM BOBBER-GLIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOBBER-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-STOP                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
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
 01 WS-R3                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-FLYING              BINARY-LONG.
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
*>           The open-water flag (1.3a): lowered only while a fish is on its way or biting, true again between bites.
             IF PJ-I5(WS-SLOT) > 0 OR PJ-I4(WS-SLOT) > 0
                 IF PJ-I9(WS-SLOT) = 0 AND PJ-I10(WS-SLOT) < 10
                     CALL "BOBBER-OPEN-WATER" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-OPEN
                     IF WS-OPEN = 0
                         MOVE 1 TO PJ-I9(WS-SLOT)
                     END-IF
                 ELSE
                     MOVE 1 TO PJ-I9(WS-SLOT)
                 END-IF
             ELSE
                 MOVE 0 TO PJ-I9(WS-SLOT)
             END-IF
             IF WS-WK > 0
                 IF PJ-I10(WS-SLOT) > 0
                     SUBTRACT 1 FROM PJ-I10(WS-SLOT)
                 END-IF
                 IF PJ-I5(WS-SLOT) > 0
                     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-R2
                     CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-R3
                     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.1 * (WS-R2 / 1000) * (WS-R3 / 1000)
                 END-IF
                 MOVE 1 TO WS-AMOUNT
                 CALL "BOBBER-FISH" USING L-ROW WS-SLOT WS-AMOUNT
             ELSE
                 IF PJ-I10(WS-SLOT) < 10
                     ADD 1 TO PJ-I10(WS-SLOT)
                 END-IF
             END-IF
             MOVE 0 TO WS-FLYING
             CALL "BOBBER-GLIDE" USING L-ROW WS-SLOT WS-FLYING WS-WK
         WHEN OTHER
             IF WS-WK > 0
                 COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.3
                 COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.2
                 COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.3
                 MOVE 2 TO PJ-I1(WS-SLOT)
             ELSE
                 MOVE 1 TO WS-FLYING
                 CALL "BOBBER-GLIDE" USING L-ROW WS-SLOT WS-FLYING WS-WK
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
 01 WS-EV-START            PIC X(32) VALUE "item_interact_start".
 01 WS-EV-FINISH           PIC X(32) VALUE "item_interact_finish".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ID L-YAW L-PITCH.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "BOBBER-FIND" USING PL-ENTITY-ID(WS-ROW) WS-HOOK
     IF WS-HOOK > 0
         CALL "BOBBER-RETRIEVE" USING WS-ROW WS-HOOK WS-COST
*>       FishingRodItem.use: item_interact_finish when reeling in (30-8 14.3.8)
         CALL "GAME-EVENT-AT" USING WS-EV-FINISH PL-ENTITY-ROW(WS-ROW)
         IF WS-COST > 0
             CALL "TOOL-HURT-STACK" USING PL-CONN(WS-ROW) PL-HELD(WS-ROW) WS-COST WS-BROKE
         END-IF
     ELSE
         CALL "BOBBER-CAST" USING WS-ROW L-YAW L-PITCH WS-HOOK
*>       FishingRodItem.use: item_interact_start when casting (30-8 14.3.8)
         CALL "GAME-EVENT-AT" USING WS-EV-START PL-ENTITY-ROW(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM BOBBER-USE.
