*> The strider (docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.7; 44-residual-mob-questions-6-nether.md section 8). Row `strider` is the last row of STDMOBS.cpy (MOBROWS7.cpy).
*> Lava: a strider in lava with no lava above it stands on the surface (the lava block holds it up from its half height, y 0.5), else it rises (0.5 v + 0.05), 8.2; it walks over lava as over
*> ground (the path malus of lava is 0) and goes to the nearest lava within 8 x 2 blocks when it is not in lava (StriderGoToLavaGoal, 8.3), else strolls (1 in 60 a tick, 10 blocks).
*> Cold: not on or in lava (8.2: the block at its position or below is lava, or lava at its position) it is suffocating: speed x 0.66 and metadata 19 (shivering).
*> Steering: a saddled strider with a rider holding a warped fungus on a stick is controlled by that rider's client; the stick boosts it (8.1: 140 + nextInt(841) ticks, speed
*> 1.0 + 1.15 sin(t / total x PI), the stick takes 1 damage and breaks into a fishing rod). Jockey (5.7): a finalized adult strider has with probability 1/30 a zombified piglin on it
*> holding the stick (the strider saddled), else with probability 1/10 a baby strider.
*> Open: natural spawning IN_LAVA (checkStriderSpawnRules), the temptation, breeding and panic goals (the generic panic applies), the 0.5 baby chance of a group, the passenger seat of the
*> strider (none in 18 section 1.1.1: 0), the stick in the off hand, the pig's carrot on a stick, the sounds, sensitivity to water, the rider of a cold strider (ridingWarm).
*>   STRIDER-LAVA-AT USING dim, x, y, z (BINARY-LONG), lava out        1 when the cell holds lava
*>   STRIDER-COLD USING row                                        recompute EN-COLD; the viewers get metadata 19 on a change
*>   STRIDER-TICK USING row, hx out, hz out, walk out               the cold state, the boost timer and the walk (walk 1 when hx and hz are set)
*>   STRIDER-LAVA USING row, previous y                            after MOB-PHYSICS: the surface rule
*>   STRIDER-BOOST USING row, boosted out                          boost(random)
*>   STRIDER-STICK-USE USING connection id, done out                Use Item with the stick on a ridden strider
*>   STRIDER-JOCKEY USING xoro state, row                           the finalizeSpawn riders

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-LAVA-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LAVA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-LAVA.
     MOVE 0 TO L-LAVA
     CALL "FLUID-CELL" USING L-DIM L-X L-Y L-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     IF WS-FLUID = 2
         MOVE 1 TO L-LAVA
     END-IF
     GOBACK.
 END PROGRAM STRIDER-LAVA-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-COLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-HERE                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-COLD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Y2 = FUNCTION INTEGER(EN-Y(L-ROW) - 0.2)
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-HERE
     CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y2 WS-Z WS-BELOW
     MOVE 1 TO WS-COLD
     IF WS-HERE = 1 OR WS-BELOW = 1
         MOVE 0 TO WS-COLD
     END-IF
     IF WS-COLD NOT = EN-COLD(L-ROW)
         MOVE WS-COLD TO EN-COLD(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STRIDER-COLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-BOOST.
*> USING row, boosted out: ItemBasedSteering.boost: false while boosting; else boosting starts at time 0 and the total (metadata 18) is 140 + nextInt(841).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 97.
 01 WS-BOUND               BINARY-LONG VALUE 841.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BOOSTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-BOOSTED.
     MOVE 0 TO L-BOOSTED
     IF EN-BOOSTING(L-ROW) = 0
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE EN-BOOST(L-ROW) = 140 + WS-DRAW
         MOVE 1 TO EN-BOOSTING(L-ROW)
         MOVE 0 TO EN-BOOST-T(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
         MOVE 1 TO L-BOOSTED
     END-IF
     GOBACK.
 END PROGRAM STRIDER-BOOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-FIND-LAVA.
*> USING row, found out, x out, y out, z out (BINARY-LONG): StriderGoToLavaGoal.isValidTarget (8.3): the nearest cell within 8 blocks horizontally and 2 vertically that holds lava with a
*> cell above it that a walker can pass (no collision shape and no lava or water).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND WS-BEST
     PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
         PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
             PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
                 COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DX
                 COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DY
                 COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DZ
                 CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-LAVA
                 IF WS-LAVA = 1
                     COMPUTE WS-Y1 = WS-Y + 1
                     CALL "FLUID-CELL" USING EN-DIM(L-ROW) WS-X WS-Y1 WS-Z WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
                     IF WS-HOLDS = 1 AND WS-FLUID = 0
                         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                         IF WS-BEST = 0 OR WS-D2 < WS-BEST
                             MOVE WS-D2 TO WS-BEST
                             MOVE 1 TO L-FOUND
                             MOVE WS-X TO L-X
                             MOVE WS-Y TO L-Y
                             MOVE WS-Z TO L-Z
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRIDER-FIND-LAVA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-IN-LAVA             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     CALL "STRIDER-COLD" USING L-ROW
     IF EN-BOOSTING(L-ROW) = 1
         ADD 1 TO EN-BOOST-T(L-ROW)
         IF EN-BOOST-T(L-ROW) > EN-BOOST(L-ROW)
             MOVE 0 TO EN-BOOSTING(L-ROW)
         END-IF
     END-IF
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-IN-LAVA
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 31 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     IF EN-PATH-TICKS(L-ROW) = 0
*>       StriderGoToLavaGoal: out of lava a timed scan (1 in 40 a tick here) for the nearest lava within 8 x 2 blocks.
         IF WS-IN-LAVA = 0 AND FUNCTION MOD(WS-R, 40) = 0
             CALL "STRIDER-FIND-LAVA" USING L-ROW WS-FOUND WS-LX WS-LY WS-LZ
             IF WS-FOUND = 1
                 MOVE WS-LX TO EN-DEST-X(L-ROW)
                 MOVE WS-LZ TO EN-DEST-Z(L-ROW)
                 MOVE 100 TO EN-PATH-TICKS(L-ROW)
             END-IF
         END-IF
     END-IF
     IF EN-PATH-TICKS(L-ROW) = 0 AND FUNCTION MOD(WS-R, 60) = 1
         COMPUTE WS-Q = WS-R / 60
         COMPUTE EN-DEST-X(L-ROW) = WS-X + FUNCTION MOD(WS-Q, 21) - 10
         COMPUTE WS-Q = WS-Q / 21
         COMPUTE EN-DEST-Z(L-ROW) = WS-Z + FUNCTION MOD(WS-Q, 21) - 10
         MOVE 100 TO EN-PATH-TICKS(L-ROW)
     END-IF
     IF EN-PATH-TICKS(L-ROW) > 0
         SUBTRACT 1 FROM EN-PATH-TICKS(L-ROW)
         COMPUTE WS-DX = EN-DEST-X(L-ROW) + 0.5 - EN-X(L-ROW)
         COMPUTE WS-DZ = EN-DEST-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         IF WS-H < 0.3
             MOVE 0 TO EN-PATH-TICKS(L-ROW)
         ELSE
             CALL "STDMOB-SPEED" USING L-ROW WS-M WS-SPEED
             IF EN-BOOSTING(L-ROW) = 1
                 COMPUTE WS-SPEED = WS-SPEED * (1 + 1.15 * FUNCTION SIN(EN-BOOST-T(L-ROW) / EN-BOOST(L-ROW) * FUNCTION PI)) ** 2
             END-IF
             COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
             COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
             MOVE 1 TO L-WALK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRIDER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-LAVA.
*> USING row, previous y (FLOAT-LONG; the height before MOB-PHYSICS): in lava (the cell of the feet) a strider whose feet were at or above the surface of the cell (cell y + 0.5) with no lava
*> in the cell above stands on it (y = cell y + 0.5, on the ground, the fall distance reset); else it rises (v = 0.5 v + 0.05, not on the ground).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SURFACE             FLOAT-LONG.
 01 WS-NEW-Y               FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PREV                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-PREV.
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-LAVA
     IF WS-LAVA = 1
         COMPUTE WS-Y1 = WS-Y + 1
         CALL "STRIDER-LAVA-AT" USING EN-DIM(L-ROW) WS-X WS-Y1 WS-Z WS-ABOVE
         COMPUTE WS-SURFACE = WS-Y + 0.5
         IF WS-ABOVE = 0 AND L-PREV >= WS-SURFACE - 0.001
             MOVE WS-SURFACE TO WS-NEW-Y
             MOVE 1 TO WS-GROUND
             MOVE 0 TO EN-VY(L-ROW) EN-FALL(L-ROW)
             IF WS-NEW-Y NOT = EN-Y(L-ROW)
                 CALL "ENTITY-MOVE" USING L-ROW EN-X(L-ROW) WS-NEW-Y EN-Z(L-ROW) EN-YAW(L-ROW) WS-PITCH WS-GROUND
             END-IF
             MOVE 1 TO EN-ON-GROUND(L-ROW)
         ELSE
             COMPUTE EN-VY(L-ROW) = 0.5 * EN-VY(L-ROW) + 0.05
             MOVE 0 TO EN-ON-GROUND(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRIDER-LAVA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-STICK-USE.
*> USING connection id, done out: Use Item with a warped fungus on a stick in the main hand while riding a strider (8.1): a boost that takes (the strider is not boosting) takes 1 durability
*> from the stick, which breaks into a fishing rod; done 1 when the strider boosted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-SPECIES             PIC X(24).
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-BOOSTED             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-ROD-KEY             PIC X(112) VALUE "minecraft:fishing_rod".
 01 WS-ROD                 BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-PLAYER
     MOVE EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER)) TO WS-VEHICLE
     IF WS-VEHICLE = 0
         GOBACK
     END-IF
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     IF PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) = 0
         GOBACK
     END-IF
     CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) WS-KEY
     CALL "MOB-SPECIES-KEY" USING WS-VEHICLE WS-SPECIES
     IF WS-KEY = "warped_fungus_on_a_stick" AND WS-SPECIES = "strider" AND EN-SADDLE(WS-VEHICLE) = 1
         CALL "STRIDER-BOOST" USING WS-VEHICLE WS-BOOSTED
         IF WS-BOOSTED = 1
             MOVE 1 TO L-DONE
             CALL "TOOL-HURT-STACK" USING L-ID PL-HELD(WS-PLAYER) WS-ONE WS-BROKE
             IF WS-BROKE = 1
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-ROD-KEY WS-ROD WS-ITEM-ROW WS-STATUS
                 MOVE WS-ROD TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
                 MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
                 MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, WS-SLOT)
                 CALL "INV-SLOT-SEND" USING L-ID PL-HELD(WS-PLAYER)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRIDER-STICK-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRIDER-JOCKEY.
*> USING xoro state, strider row (called by STDMOB-FINALIZE for a strider): an adult with probability 1/30 (nextInt(30) = 0) gets a finalized zombified piglin riding it with the stick in
*> its hand, and a saddle; otherwise with probability 1/10 a baby strider rides it (age locked is open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-30                  BINARY-LONG VALUE 30.
 01 WS-10                  BINARY-LONG VALUE 10.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PIGLIN-KEY          PIC X(112) VALUE "minecraft:zombified_piglin".
 01 WS-STRIDER-KEY         PIC X(112) VALUE "minecraft:strider".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     IF EN-VARIANT(L-ROW) = 1
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-YAW(L-ROW) TO WS-YAW
     CALL "XORO-NEXT-INT" USING L-STATE WS-30 WS-DRAW
     IF WS-DRAW = 0
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-PIGLIN-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         CALL "STDMOB-FINALIZE" USING L-STATE WS-NEW
         MOVE 9 TO EN-HAND(WS-NEW)
         MOVE 1 TO EN-SADDLE(L-ROW)
         CALL "STDMOB-EQUIP-SEND" USING WS-NEW
         CALL "MOB-MOUNT" USING WS-NEW L-ROW WS-MOUNTED
     ELSE
         CALL "XORO-NEXT-INT" USING L-STATE WS-10 WS-DRAW
         IF WS-DRAW = 0
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-STRIDER-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
             CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
             MOVE 1 TO EN-VARIANT(WS-NEW)
             CALL "MOB-DATA-SEND" USING WS-NEW
             CALL "MOB-MOUNT" USING WS-NEW L-ROW WS-MOUNTED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STRIDER-JOCKEY.
