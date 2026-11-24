*> Rule functions of docs/protocol/44-residual-mob-questions-x2-continuation.md (lane 002-lane-p49j-b, tasks T24400 to T24499), sections 1.2, 2, 5 to 8 and 10 to 15. Each program is one deterministic rule
*> of the document with its random draws and world facts passed in. The dispenser engine of sections 3 and 4 is the RS2-* programs of redstone-30-4.cob. The mobs, blocks and goals the rules belong to either
*> have no engine yet (brain memories and sensors, the warden tracker, chest vehicle containers) or live under other files, so these functions are proven by tests but not called by a tick (lane task list).

*> x2 1.2 PrepareRamNearestTarget candidates: from the target block T, per direction north, east, south, west the walkable run (R1 to R4, steps before a non-walkable block, capped at maxRamDistance) gives a candidate when its Manhattan distance (= steps) is at least minRamDistance; the list is sorted stably by squared distance to the goat. TAB gets the count and the (x, z) of each.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-RAM-CANDIDATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D  BINARY-LONG.
 01 WS-I  BINARY-LONG.
 01 WS-J  BINARY-LONG.
 01 WS-STEPS  BINARY-LONG.
 01 WS-DX  BINARY-LONG.
 01 WS-DZ  BINARY-LONG.
 01 WS-KA  BINARY-LONG.
 01 WS-KB  BINARY-LONG.
 01 WS-KD  BINARY-LONG.
 01 WS-JD  BINARY-LONG.
 01 WS-STOP  BINARY-LONG.
 LINKAGE SECTION.
 01 L-TX                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-GX                   BINARY-LONG.
 01 L-GZ                   BINARY-LONG.
 01 L-WALKT                BINARY-LONG.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-R3                   BINARY-LONG.
 01 L-R4                   BINARY-LONG.
 01 L-MINR                 BINARY-LONG.
 01 L-MAXR                 BINARY-LONG.
 01 L-TAB.
    05 L-TN                BINARY-LONG.
    05 L-TC OCCURS 6 TIMES.
       10 L-TA             BINARY-LONG.
       10 L-TB             BINARY-LONG.
       10 L-TD             BINARY-LONG.
 PROCEDURE DIVISION USING L-TX L-TZ L-GX L-GZ L-WALKT L-R1 L-R2 L-R3 L-R4 L-MINR L-MAXR L-TAB.
     MOVE 0 TO L-TN
     IF L-WALKT = 1
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
             EVALUATE WS-D
                 WHEN 1
                     MOVE L-R1 TO WS-STEPS
                     MOVE 0 TO WS-DX
                     MOVE -1 TO WS-DZ
                 WHEN 2
                     MOVE L-R2 TO WS-STEPS
                     MOVE 1 TO WS-DX
                     MOVE 0 TO WS-DZ
                 WHEN 3
                     MOVE L-R3 TO WS-STEPS
                     MOVE 0 TO WS-DX
                     MOVE 1 TO WS-DZ
                 WHEN OTHER
                     MOVE L-R4 TO WS-STEPS
                     MOVE -1 TO WS-DX
                     MOVE 0 TO WS-DZ
             END-EVALUATE
             IF WS-STEPS > L-MAXR
                 MOVE L-MAXR TO WS-STEPS
             END-IF
             IF WS-STEPS >= L-MINR
                 ADD 1 TO L-TN
                 COMPUTE L-TA(L-TN) = L-TX + WS-DX * WS-STEPS
                 COMPUTE L-TB(L-TN) = L-TZ + WS-DZ * WS-STEPS
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-TN
             MOVE L-TA(WS-I) TO WS-KA
             MOVE L-TB(WS-I) TO WS-KB
             COMPUTE WS-KD = (WS-KA - L-GX) * (WS-KA - L-GX) + (WS-KB - L-GZ) * (WS-KB - L-GZ)
             COMPUTE WS-J = WS-I - 1
             MOVE 0 TO WS-STOP
             PERFORM UNTIL WS-J < 1 OR WS-STOP = 1
                 COMPUTE WS-JD = (L-TA(WS-J) - L-GX) * (L-TA(WS-J) - L-GX) + (L-TB(WS-J) - L-GZ) * (L-TB(WS-J) - L-GZ)
                 IF WS-JD > WS-KD
                     MOVE L-TA(WS-J) TO L-TA(WS-J + 1)
                     MOVE L-TB(WS-J) TO L-TB(WS-J + 1)
                     SUBTRACT 1 FROM WS-J
                 ELSE
                     MOVE 1 TO WS-STOP
                 END-IF
             END-PERFORM
             MOVE WS-KA TO L-TA(WS-J + 1)
             MOVE WS-KB TO L-TB(WS-J + 1)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM X2-RAM-CANDIDATES.

*> x2 2.1 per-tick update of the warden spawn tracker: at 12000 the level drops by 1 and the counter restarts at 0, else it counts up; a positive cooldown counts down.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-WT-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SINCE                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-CD                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SINCE L-LEVEL L-CD.
     IF L-SINCE >= 12000
         IF L-LEVEL > 0
             SUBTRACT 1 FROM L-LEVEL
         END-IF
         MOVE 0 TO L-SINCE
     ELSE
         ADD 1 TO L-SINCE
     END-IF
     IF L-CD > 0
         SUBTRACT 1 FROM L-CD
     END-IF
     GOBACK.
 END PROGRAM X2-WT-TICK.

*> x2 2.1 increaseWarningLevel: nothing while on cooldown; else counter 0, cooldown 200, level + 1 clamped to 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-WT-INCREASE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SINCE                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-CD                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SINCE L-LEVEL L-CD.
     IF L-CD <= 0
         MOVE 0 TO L-SINCE
         MOVE 200 TO L-CD
         ADD 1 TO L-LEVEL
         IF L-LEVEL > 4
             MOVE 4 TO L-LEVEL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-WT-INCREASE.

*> x2 2.1 setWarningLevel clamps to 0..4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-WT-CLAMP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL.
     IF L-LEVEL < 0
         MOVE 0 TO L-LEVEL
     END-IF
     IF L-LEVEL > 4
         MOVE 4 TO L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM X2-WT-CLAMP.

*> x2 2.2 tryWarn: TAB holds the candidates as (level, cooldown, ticks since); empty (RESULT 0) with a warden in the box or any candidate on cooldown; else the highest level (first on a tie) is increased and its three counters copied into every candidate; WINNER is the new level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-WARN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I  BINARY-LONG.
 01 WS-COOL  BINARY-LONG.
 01 WS-BEST  BINARY-LONG.
 01 WS-LV  BINARY-LONG.
 01 WS-CDV  BINARY-LONG.
 01 WS-SV  BINARY-LONG.
 LINKAGE SECTION.
 01 L-WARDEN               BINARY-LONG.
 01 L-TAB.
    05 L-TN                BINARY-LONG.
    05 L-TC OCCURS 6 TIMES.
       10 L-TA             BINARY-LONG.
       10 L-TB             BINARY-LONG.
       10 L-TD             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-WINNER               BINARY-LONG.
 PROCEDURE DIVISION USING L-WARDEN L-TAB L-RESULT L-WINNER.
     MOVE 0 TO L-RESULT L-WINNER
     MOVE 0 TO WS-COOL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-TN
         IF L-TB(WS-I) > 0
             MOVE 1 TO WS-COOL
         END-IF
     END-PERFORM
     IF L-WARDEN = 0 AND WS-COOL = 0 AND L-TN > 0
         MOVE 1 TO WS-BEST
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-TN
             IF L-TA(WS-I) > L-TA(WS-BEST)
                 MOVE WS-I TO WS-BEST
             END-IF
         END-PERFORM
         CALL "X2-WT-INCREASE" USING L-TD(WS-BEST) L-TA(WS-BEST) L-TB(WS-BEST)
         MOVE L-TA(WS-BEST) TO WS-LV
         MOVE L-TB(WS-BEST) TO WS-CDV
         MOVE L-TD(WS-BEST) TO WS-SV
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-TN
             MOVE WS-LV TO L-TA(WS-I)
             MOVE WS-CDV TO L-TB(WS-I)
             MOVE WS-SV TO L-TD(WS-I)
         END-PERFORM
         MOVE 1 TO L-RESULT
         MOVE WS-LV TO L-WINNER
     END-IF
     GOBACK.
 END PROGRAM X2-WARN.

*> x2 2.3 canRespond: can_summon, difficulty not Peaceful (0) and the game rule spawn_wardens.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SHRIEK-CAN-RESPOND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-SUMMON           BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-SUMMON L-DIFFICULTY L-RULE L-OUT.
     MOVE 0 TO L-OUT
     IF L-CAN-SUMMON = 1 AND L-DIFFICULTY NOT = 0 AND L-RULE = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-SHRIEK-CAN-RESPOND.

*> x2 2.3 tryShriek: nothing without a player or while shrieking; with canRespond a failed tryToWarn returns without shrieking; without canRespond the warning is skipped and the shriek goes ahead.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SHRIEK-TRY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-CAN-RESPOND          BINARY-LONG.
 01 L-WARNED               BINARY-LONG.
 01 L-SHRIEK               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-SHRIEKING L-CAN-RESPOND L-WARNED L-SHRIEK.
     MOVE 1 TO L-SHRIEK
     IF L-PLAYER = 0 OR L-SHRIEKING = 1
         MOVE 0 TO L-SHRIEK
     END-IF
     IF L-SHRIEK = 1 AND L-CAN-RESPOND = 1 AND L-WARNED = 0
         MOVE 0 TO L-SHRIEK
     END-IF
     GOBACK.
 END PROGRAM X2-SHRIEK-TRY.

*> x2 2.3 tryRespond: only with canRespond and a stored level above 0; Darkness in every case; the reply sound (1 nearby_close, 2 nearby_closer, 3 nearby_closest, 4 listening_angry, 0 none) unless a warden was spawned at level 4 or more (a level above 4 plays nothing).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SHRIEK-RESPOND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-RESPOND          BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SPAWNED              BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-RESPOND L-LEVEL L-SPAWNED L-SOUND L-DARK.
     MOVE 0 TO L-SOUND L-DARK
     IF L-CAN-RESPOND = 1 AND L-LEVEL > 0
         MOVE 1 TO L-DARK
         IF NOT (L-LEVEL >= 4 AND L-SPAWNED = 1)
             IF L-LEVEL >= 1 AND L-LEVEL <= 4
                 MOVE L-LEVEL TO L-SOUND
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-SHRIEK-RESPOND.

*> x2 2.3 tryGetPlayer order: the entity itself (1), its controlling passenger (2), a projectile's owner (3), an item entity's owner (4), else none (0); the arguments say which of them is a ServerPlayer.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-TRY-PLAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IS-PLAYER            BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-PROJECTILE           BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-PLAYER L-PASSENGER L-PROJECTILE L-ITEM L-OUT.
     EVALUATE TRUE
         WHEN L-IS-PLAYER = 1
             MOVE 1 TO L-OUT
         WHEN L-PASSENGER = 1
             MOVE 2 TO L-OUT
         WHEN L-PROJECTILE = 1
             MOVE 3 TO L-OUT
         WHEN L-ITEM = 1
             MOVE 4 TO L-OUT
         WHEN OTHER
             MOVE 0 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM X2-TRY-PLAYER.

*> x2 2.4 ON_TOP_OF_COLLIDER: the above state has an empty collision shape and the floor has a full upward face; the NO_LEAVES variant also refuses a floor in the leaves tag.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SPAWN-STRATEGY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABOVE-EMPTY          BINARY-LONG.
 01 L-FLOOR-FULL           BINARY-LONG.
 01 L-LEAVES               BINARY-LONG.
 01 L-NO-LEAVES            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE-EMPTY L-FLOOR-FULL L-LEAVES L-NO-LEAVES L-OUT.
     MOVE 0 TO L-OUT
     IF L-ABOVE-EMPTY = 1 AND L-FLOOR-FULL = 1 AND NOT (L-NO-LEAVES = 1 AND L-LEAVES = 1)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-SPAWN-STRATEGY.

*> x2 2.4 floor search: COL cell 1 is the start block, cell i the block i - 1 below it (E: empty collision shape, F: full upward face); for k = v down to -v the cursor moves one block down and the first cursor whose floor is accepted (above empty, floor full) gives the candidate one block above it. OFFSET is the number of blocks the candidate lies below the start, -1 for none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SPAWN-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I  BINARY-LONG.
 01 WS-K  BINARY-LONG.
 LINKAGE SECTION.
 01 L-V                    BINARY-LONG.
 01 L-COL.
    05 L-CELL OCCURS 14 TIMES.
       10 L-CE             BINARY-LONG.
       10 L-CF             BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-COL L-OFFSET.
     MOVE -1 TO L-OFFSET
     MOVE 1 TO WS-I
     PERFORM VARYING WS-K FROM L-V BY -1 UNTIL WS-K < 0 - L-V OR L-OFFSET >= 0
         ADD 1 TO WS-I
         IF L-CE(WS-I - 1) = 1 AND L-CF(WS-I) = 1
             COMPUTE L-OFFSET = WS-I - 2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM X2-SPAWN-FIND.

*> x2 5 unpackChestVehicleLootTable: only on a server with a loot table key; the key is cleared (not the seed); the generate_loot criterion and the luck parameter only with a player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-LOOT-UNPACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-KEY              BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-UNPACK               BINARY-LONG.
 01 L-CRITERION            BINARY-LONG.
 01 L-LUCK                 BINARY-LONG.
 01 L-CLEAR-KEY            BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-KEY L-SERVER L-PLAYER L-UNPACK L-CRITERION L-LUCK L-CLEAR-KEY.
     MOVE 0 TO L-UNPACK L-CRITERION L-LUCK L-CLEAR-KEY
     IF L-SERVER = 1 AND L-HAS-KEY = 1
         MOVE 1 TO L-UNPACK L-CLEAR-KEY
         IF L-PLAYER = 1
             MOVE 1 TO L-CRITERION L-LUCK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-LOOT-UNPACK.

*> x2 5 save format: with a loot table the key and, when the seed is not 0, LootTableSeed, and no Items; else Items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-CHEST-SAVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-LOOT             BINARY-LONG.
 01 L-SEED                 BINARY-LONG.
 01 L-ITEMS                BINARY-LONG.
 01 L-LOOT-KEY             BINARY-LONG.
 01 L-SEED-SAVED           BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-LOOT L-SEED L-ITEMS L-LOOT-KEY L-SEED-SAVED.
     MOVE 1 TO L-ITEMS
     MOVE 0 TO L-LOOT-KEY L-SEED-SAVED
     IF L-HAS-LOOT = 1
         MOVE 0 TO L-ITEMS
         MOVE 1 TO L-LOOT-KEY
         IF L-SEED NOT = 0
             MOVE 1 TO L-SEED-SAVED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-CHEST-SAVE.

*> x2 5 chestVehicleDestroyed: nothing unless entity_drops; the contents drop; a Player as the direct entity angers nearby piglins.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-CHEST-DESTROY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY-DROPS         BINARY-LONG.
 01 L-DIRECT-PLAYER        BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-ANGER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-DROPS L-DIRECT-PLAYER L-DROPS L-ANGER.
     MOVE 0 TO L-DROPS L-ANGER
     IF L-ENTITY-DROPS = 1
         MOVE 1 TO L-DROPS
         IF L-DIRECT-PLAYER = 1
             MOVE 1 TO L-ANGER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-CHEST-DESTROY.

*> x2 5.1 angerNearbyPiglins filters: the piglin is idle and, when requireSight is true, can see the player.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-ANGER-FILTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IDLE                 BINARY-LONG.
 01 L-REQUIRE-SIGHT        BINARY-LONG.
 01 L-CAN-SEE              BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IDLE L-REQUIRE-SIGHT L-CAN-SEE L-OUT.
     MOVE 0 TO L-OUT
     IF L-IDLE = 1 AND (L-REQUIRE-SIGHT = 0 OR L-CAN-SEE = 1)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-ANGER-FILTER.

*> x2 6.2 llama spit particle i (0 to 6): velocity movement x (0.4 + 0.1 x i).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SPIT-FACTOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-F                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-I L-F.
     COMPUTE L-F = 0.4 + 0.1 * L-I
     GOBACK.
 END PROGRAM X2-SPIT-FACTOR.

*> x2 6.2 snowball hit damage: 3 for a Blaze (any subclass), else 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SNOWBALL-DAMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLAZE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BLAZE L-OUT.
     MOVE 0 TO L-OUT
     IF L-BLAZE = 1
         MOVE 3 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-SNOWBALL-DAMAGE.

*> x2 6.2 egg hatching: nextInt(8) == 0 hatches one chick, four when nextInt(32) == 0 as well.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-EGG-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL8                BINARY-LONG.
 01 L-ROLL32               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL8 L-ROLL32 L-OUT.
     MOVE 0 TO L-OUT
     IF L-ROLL8 = 0
         MOVE 1 TO L-OUT
         IF L-ROLL32 = 0
             MOVE 4 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-EGG-COUNT.

*> x2 6.4 / 44-8 6.3 entity.deflection(projectile): 1 REVERSE for an entity of tag deflects_projectiles; the breeze gives NONE (0) for a wind charge, else its own deflection (2: the deflect sound, then REVERSE) when it is in the tag.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-DEFLECT-KIND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-TAG               BINARY-LONG.
 01 L-BREEZE               BINARY-LONG.
 01 L-WIND-CHARGE          BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-TAG L-BREEZE L-WIND-CHARGE L-OUT.
     MOVE 0 TO L-OUT
     IF L-BREEZE = 1
         IF L-WIND-CHARGE = 0 AND L-IN-TAG = 1
             MOVE 2 TO L-OUT
         END-IF
     ELSE
         IF L-IN-TAG = 1
             MOVE 1 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-DEFLECT-KIND.

*> x2 7.1 TryLaySpawnOnFluidNearLand: fails in water or off the ground; else the first of north, east, south, west (TAB rows: top face open, supports_frogspawn, air above) that passes gets the spawn (DIR 1 to 4) and the pregnancy is erased; with none the trigger still returns true and keeps it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-FROG-LAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN-WATER             BINARY-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 01 L-TAB.
    05 L-TN                BINARY-LONG.
    05 L-TC OCCURS 6 TIMES.
       10 L-TA             BINARY-LONG.
       10 L-TB             BINARY-LONG.
       10 L-TD             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ERASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-WATER L-ON-GROUND L-TAB L-RESULT L-DIR L-ERASE.
     MOVE 0 TO L-RESULT L-DIR L-ERASE
     IF L-IN-WATER = 0 AND L-ON-GROUND = 1
         MOVE 1 TO L-RESULT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR L-DIR > 0
             IF L-TA(WS-I) = 1 AND L-TB(WS-I) = 1 AND L-TD(WS-I) = 1
                 MOVE WS-I TO L-DIR
                 MOVE 1 TO L-ERASE
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM X2-FROG-LAY.

*> x2 7.2 CopyMemoryWithExpiry: the source present, the target absent and the predicate true copies the value with an expiry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-COPY-MEMORY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-PREDICATE            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-TARGET L-PREDICATE L-OUT.
     MOVE 0 TO L-OUT
     IF L-SOURCE = 1 AND L-TARGET = 0 AND L-PREDICATE = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-COPY-MEMORY.

*> x2 7.3 feeding: ticksLeft = max(0, 24000 - age); seconds = (int)((ticksLeft / 20) x 0.1f); age + 20 x seconds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-TADPOLE-FEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEFT  BINARY-LONG.
 01 WS-Q  BINARY-LONG.
 01 WS-SECS  BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-NEW-AGE.
     COMPUTE WS-LEFT = FUNCTION MAX(0, 24000 - L-AGE)
     COMPUTE WS-Q = WS-LEFT / 20
     COMPUTE WS-SECS = WS-Q * 0.10000000149011612
     COMPUTE L-NEW-AGE = L-AGE + 20 * WS-SECS
     GOBACK.
 END PROGRAM X2-TADPOLE-FEED.

*> x2 7.3 aiStep: age + 1 while not age-locked; at 24000 the tadpole becomes a frog.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-TADPOLE-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-LOCKED L-GROWN.
     MOVE 0 TO L-GROWN
     IF L-LOCKED = 0
         ADD 1 TO L-AGE
         IF L-AGE >= 24000
             MOVE 1 TO L-GROWN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-TADPOLE-TICK.

*> x2 8.2 Markings.byId wraps: id n gives n mod 5 (the positive modulo for a negative id; FUNCTION MOD already is one).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-MARKING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-OUT.
     COMPUTE L-OUT = FUNCTION MOD(L-ID, 5)
     GOBACK.
 END PROGRAM X2-MARKING.

*> x2 8.1 copper golem oxidation levels: weather state 0 unaffected, 1 exposed (same sounds, own textures), 2 weathered, 3 oxidized (infixed sounds); texture names are the file stems under textures/entity/copper_golem/.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-COPPER-LEVEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-SPIN                 PIC X(32).
 01 L-HURT                 PIC X(32).
 01 L-DEATH                PIC X(32).
 01 L-STEP                 PIC X(32).
 01 L-TEXTURE              PIC X(32).
 01 L-EYES                 PIC X(32).
 PROCEDURE DIVISION USING L-STATE L-SPIN L-HURT L-DEATH L-STEP L-TEXTURE L-EYES.
     MOVE "copper_golem.spin" TO L-SPIN
     MOVE "copper_golem.hurt" TO L-HURT
     MOVE "copper_golem.death" TO L-DEATH
     MOVE "copper_golem.step" TO L-STEP
     EVALUATE L-STATE
         WHEN 0
             MOVE "copper_golem" TO L-TEXTURE
             MOVE "copper_golem_eyes" TO L-EYES
         WHEN 1
             MOVE "copper_golem_exposed" TO L-TEXTURE
             MOVE "copper_golem_eyes_exposed" TO L-EYES
         WHEN 2
             MOVE "copper_golem.weathered_spin" TO L-SPIN
             MOVE "copper_golem.weathered_hurt" TO L-HURT
             MOVE "copper_golem.weathered_death" TO L-DEATH
             MOVE "copper_golem.weathered_step" TO L-STEP
             MOVE "copper_golem_weathered" TO L-TEXTURE
             MOVE "copper_golem_eyes_weathered" TO L-EYES
         WHEN OTHER
             MOVE "copper_golem.oxidized_spin" TO L-SPIN
             MOVE "copper_golem.oxidized_hurt" TO L-HURT
             MOVE "copper_golem.oxidized_death" TO L-DEATH
             MOVE "copper_golem.oxidized_step" TO L-STEP
             MOVE "copper_golem_oxidized" TO L-TEXTURE
             MOVE "copper_golem_eyes_oxidized" TO L-EYES
     END-EVALUATE
     GOBACK.
 END PROGRAM X2-COPPER-LEVEL.

*> x2 10.1 SitWhenOrderedToGoal.canUse (OWNER 1 when the owner exists in the same level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SIT-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SITTING              BINARY-LONG.
 01 L-TAME                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SITTING L-TAME L-WATER L-GROUND L-OWNER L-D2 L-HURT L-OUT.
     EVALUATE TRUE
         WHEN L-SITTING = 0 AND L-TAME = 0
             MOVE 0 TO L-OUT
         WHEN L-WATER = 1
             MOVE 0 TO L-OUT
         WHEN L-GROUND = 0
             MOVE 0 TO L-OUT
         WHEN L-OWNER = 0
             MOVE 1 TO L-OUT
         WHEN L-D2 < 144.0 AND L-HURT = 1
             MOVE 0 TO L-OUT
         WHEN OTHER
             MOVE L-SITTING TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM X2-SIT-CAN-USE.

*> x2 10.2 OwnerHurtByTargetGoal.canUse: tame, not ordered to sit, owner present, a damage source no older than 100 ticks and not in NO_WOLF_RETALIATION, a new hurt-by timestamp, canAttack and wantsToAttack.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-OWNER-TARGET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAME                 BINARY-LONG.
 01 L-SITTING              BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-TAGGED               BINARY-LONG.
 01 L-STAMP                BINARY-LONG.
 01 L-OSTAMP               BINARY-LONG.
 01 L-CAN-ATTACK           BINARY-LONG.
 01 L-WANTS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAME L-SITTING L-OWNER L-AGE L-SOURCE L-TAGGED L-STAMP L-OSTAMP L-CAN-ATTACK L-WANTS L-OUT.
     MOVE 0 TO L-OUT
     IF L-TAME = 1 AND L-SITTING = 0 AND L-OWNER = 1 AND L-SOURCE = 1 AND L-AGE <= 100 AND L-TAGGED = 0
             AND L-STAMP NOT = L-OSTAMP AND L-CAN-ATTACK = 1 AND L-WANTS = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-OWNER-TARGET.

*> x2 10.2 OwnerHurtTargetGoal.canUse: as the hurt-by goal with the last-hurt-mob timestamp and no damage source check.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-OWNER-HURT-TARGET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAME                 BINARY-LONG.
 01 L-SITTING              BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-STAMP                BINARY-LONG.
 01 L-OSTAMP               BINARY-LONG.
 01 L-CAN-ATTACK           BINARY-LONG.
 01 L-WANTS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAME L-SITTING L-OWNER L-STAMP L-OSTAMP L-CAN-ATTACK L-WANTS L-OUT.
     MOVE 0 TO L-OUT
     IF L-TAME = 1 AND L-SITTING = 0 AND L-OWNER = 1 AND L-STAMP NOT = L-OSTAMP AND L-CAN-ATTACK = 1 AND L-WANTS = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-OWNER-HURT-TARGET.

*> x2 10.2 NonTameRandomTargetGoal.canUse: not tame and the base canUse.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-NONTAME-TARGET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAME                 BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAME L-BASE L-OUT.
     MOVE 0 TO L-OUT
     IF L-TAME = 0 AND L-BASE = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-NONTAME-TARGET.

*> x2 10.3 TradeWithPlayerGoal.canUse: alive, not in water, on the ground, not hurt recently, a trading player within 4 blocks (squared distance at most 16).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-TRADE-CAN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-GROUND               BINARY-LONG.
 01 L-HURT                 BINARY-LONG.
 01 L-TRADER               BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-WATER L-GROUND L-HURT L-TRADER L-D2 L-OUT.
     MOVE 0 TO L-OUT
     IF L-ALIVE = 1 AND L-WATER = 0 AND L-GROUND = 1 AND L-HURT = 0 AND L-TRADER = 1 AND L-D2 <= 16.0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-TRADE-CAN.

*> x2 10.3 UseItemGoal.stop finish sound pitch: 0.9 + 0.2 x nextFloat.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-USEITEM-PITCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PITCH.
     COMPUTE L-PITCH = 0.9 + 0.2 * L-DRAW
     GOBACK.
 END PROGRAM X2-USEITEM-PITCH.

*> x2 10.4 DoorInteractGoal.tick: passed when dx x doorOpenDirX + dz x doorOpenDirZ < 0 (the mob crossed the door plane).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-DOOR-PASSED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-DIRX                 FLOAT-LONG.
 01 L-DIRZ                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DZ L-DIRX L-DIRZ L-OUT.
     MOVE 0 TO L-OUT
     IF L-DX * L-DIRX + L-DZ * L-DIRZ < 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-DOOR-PASSED.

*> x2 10.4 canUse: a path node is considered when the squared distance from its door cell to the mob (at the mob's y) is at most 2.25.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-DOOR-NODE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-OUT.
     MOVE 0 TO L-OUT
     IF NOT L-D2 > 2.25
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-DOOR-NODE.

*> x2 10.5 MoveThroughVillageGoal: one removal of the oldest visited entry per call while more than 15.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-VILLAGE-TRIM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     IF L-COUNT > 15
         SUBTRACT 1 FROM L-COUNT
     END-IF
     GOBACK.
 END PROGRAM X2-VILLAGE-TRIM.

*> x2 10.5 stop: the POI is recorded as visited when the navigation is done or the mob is within distanceToPoi of it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-VILLAGE-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DONE                 BINARY-LONG.
 01 L-WITHIN               BINARY-LONG.
 01 L-RECORD               BINARY-LONG.
 PROCEDURE DIVISION USING L-DONE L-WITHIN L-RECORD.
     MOVE 0 TO L-RECORD
     IF L-DONE = 1 OR L-WITHIN = 1
         MOVE 1 TO L-RECORD
     END-IF
     GOBACK.
 END PROGRAM X2-VILLAGE-STOP.

*> x2 10.5 canContinueToUse: not done and not yet within bbWidth + distanceToPoi of the POI.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-VILLAGE-CONTINUE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DONE                 BINARY-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-POI                  FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DONE L-D L-WIDTH L-POI L-OUT.
     MOVE 0 TO L-OUT
     IF L-DONE = 0 AND L-D >= L-WIDTH + L-POI
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-VILLAGE-CONTINUE.

*> x2 10.6 PathfindToRaidGoal.tick: when tickCount > recruitmentTick the recruitment runs and recruitmentTick = tickCount + 20.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-RAID-RECRUIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK-COUNT           BINARY-LONG.
 01 L-RECRUIT              BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK-COUNT L-RECRUIT L-FIRE.
     MOVE 0 TO L-FIRE
     IF L-TICK-COUNT > L-RECRUIT
         MOVE 1 TO L-FIRE
         COMPUTE L-RECRUIT = L-TICK-COUNT + 20
     END-IF
     GOBACK.
 END PROGRAM X2-RAID-RECRUIT.

*> x2 11.1 memory conditions (STATUS 0 registered, 1 present, 2 absent): an unregistered memory fails every condition.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-MEM-CONDITION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-REGISTERED           BINARY-LONG.
 01 L-HAS-VALUE            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS L-REGISTERED L-HAS-VALUE L-OUT.
     MOVE 0 TO L-OUT
     IF L-REGISTERED = 1
         EVALUATE L-STATUS
             WHEN 0
                 MOVE 1 TO L-OUT
             WHEN 1
                 MOVE L-HAS-VALUE TO L-OUT
             WHEN OTHER
                 COMPUTE L-OUT = 1 - L-HAS-VALUE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM X2-MEM-CONDITION.

*> x2 11.2 Brain.setMemory: a no-op when unregistered (0); a null or empty value clears the slot (1); otherwise the value is stored (2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-MEM-SET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REGISTERED           BINARY-LONG.
 01 L-NULL-OR-EMPTY        BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTERED L-NULL-OR-EMPTY L-ACTION.
     MOVE 2 TO L-ACTION
     IF L-REGISTERED = 0
         MOVE 0 TO L-ACTION
     ELSE
         IF L-NULL-OR-EMPTY = 1
             MOVE 1 TO L-ACTION
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-MEM-SET.

*> x2 12.1 Sensor.tick: timeToTick - 1; at 0 or below it is reset to the scan rate and the sensor scans.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SENSOR-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-RATE                 BINARY-LONG.
 01 L-SCAN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-RATE L-SCAN.
     MOVE 0 TO L-SCAN
     SUBTRACT 1 FROM L-TIME
     IF L-TIME <= 0
         MOVE L-RATE TO L-TIME
         MOVE 1 TO L-SCAN
     END-IF
     GOBACK.
 END PROGRAM X2-SENSOR-TICK.

*> x2 12.1 rememberPositives(n, predicate): a true inner result sets the counter to n; a false one decrements it and is true while the decremented counter is still >= 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-REMEMBER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-COUNTER              BINARY-LONG.
 01 L-PRED                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-COUNTER L-PRED L-OUT.
     IF L-PRED = 1
         MOVE L-N TO L-COUNTER
         MOVE 1 TO L-OUT
     ELSE
         SUBTRACT 1 FROM L-COUNTER
         MOVE 0 TO L-OUT
         IF L-COUNTER >= 0
             MOVE 1 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-REMEMBER.

*> x2 12.2 NearestItemSensor: wantsToPickUp, within 32 blocks (squared distance below 1024) and line of sight.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-ITEM-FILTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WANTS                BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-LOS                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WANTS L-D2 L-LOS L-OUT.
     MOVE 0 TO L-OUT
     IF L-WANTS = 1 AND L-D2 < 1024.0 AND L-LOS = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-ITEM-FILTER.

*> x2 12.3 PlayerSensor: a non-spectator closer than the follow_range attribute.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-PLAYER-IN-RANGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-FOLLOW               FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SPECTATOR L-D2 L-FOLLOW L-OUT.
     MOVE 0 TO L-OUT
     IF L-SPECTATOR = 0 AND L-D2 < L-FOLLOW * L-FOLLOW
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-PLAYER-IN-RANGE.

*> x2 13 StrollAroundPoi: applies when the stored position is in the dimension and within maxDistance; picks a new target when the game time is above the timer (timer = time + 180), else returns true and does nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-STROLL-POI.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-DIM               BINARY-LONG.
 01 L-WITHIN               BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-TIMER                BINARY-LONG.
 01 L-APPLIES              BINARY-LONG.
 01 L-PICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-DIM L-WITHIN L-TIME L-TIMER L-APPLIES L-PICK.
     MOVE 0 TO L-APPLIES L-PICK
     IF L-IN-DIM = 1 AND L-WITHIN = 1
         MOVE 1 TO L-APPLIES
         IF L-TIME > L-TIMER
             MOVE 1 TO L-PICK
             COMPUTE L-TIMER = L-TIME + 180
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-STROLL-POI.

*> x2 13 VillageBoundRandomStroll: in a village or with the closest village section being its own: LandRandomPos (1); else getPosTowards the closest section (2); close-enough distance 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-VILLAGE-STROLL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IS-VILLAGE           BINARY-LONG.
 01 L-CLOSEST-OWN          BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-VILLAGE L-CLOSEST-OWN L-MODE.
     IF L-IS-VILLAGE = 1 OR L-CLOSEST-OWN = 1
         MOVE 1 TO L-MODE
     ELSE
         MOVE 2 TO L-MODE
     END-IF
     GOBACK.
 END PROGRAM X2-VILLAGE-STROLL.

*> x2 13 SetLookAndInteract: the closest visible entity of the type within distance (squared distance <= distance squared, the square taken as an int).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-LOOK-INTERACT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-DISTANCE             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-DISTANCE L-OUT.
     MOVE 0 TO L-OUT
     IF L-D2 <= L-DISTANCE * L-DISTANCE
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X2-LOOK-INTERACT.

*> x2 14 reputation events (1 zombie_villager_cured, 2 trade, 3 villager_hurt, 4 villager_killed, 5 golem_killed) to gossip (type 1 major_negative, 2 minor_negative, 3 major_positive, 4 minor_positive, 5 trading; amount): golem_killed has no producer and no gossip.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-REPUTATION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-A1                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 01 L-A2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-T1 L-A1 L-T2 L-A2.
     MOVE 0 TO L-T1 L-A1 L-T2 L-A2
     EVALUATE L-EVENT
         WHEN 1
             MOVE 3 TO L-T1
             MOVE 20 TO L-A1
             MOVE 4 TO L-T2
             MOVE 25 TO L-A2
         WHEN 2
             MOVE 5 TO L-T1
             MOVE 2 TO L-A1
         WHEN 3
             MOVE 2 TO L-T1
             MOVE 25 TO L-A1
         WHEN 4
             MOVE 1 TO L-T1
             MOVE 25 TO L-A1
     END-EVALUATE
     GOBACK.
 END PROGRAM X2-REPUTATION.

*> x2 15.1 ShootWhenStuck: attack target present, inhaling, jump target, walk target and shoot absent, and the breeze a passenger, in water or levitating: breeze_shoot for 60 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-SHOOT-WHEN-STUCK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGET               BINARY-LONG.
 01 L-INHALING             BINARY-LONG.
 01 L-JUMP-TARGET          BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-SHOOT                BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-LEVITATION           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 01 L-EXPIRY               BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGET L-INHALING L-JUMP-TARGET L-WALK L-SHOOT L-PASSENGER L-WATER L-LEVITATION L-OUT L-EXPIRY.
     MOVE 0 TO L-OUT L-EXPIRY
     IF L-TARGET = 1 AND L-INHALING = 0 AND L-JUMP-TARGET = 0 AND L-WALK = 0 AND L-SHOOT = 0
             AND (L-PASSENGER = 1 OR L-WATER = 1 OR L-LEVITATION = 1)
         MOVE 1 TO L-OUT
         MOVE 60 TO L-EXPIRY
     END-IF
     GOBACK.
 END PROGRAM X2-SHOOT-WHEN-STUCK.

*> x2 15.2 milking: an empty bucket on a non-baby cow succeeds; the stack loses one bucket (a creative player keeps it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X2-COW-MILK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUCKET               BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-NEW-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-BUCKET L-BABY L-CREATIVE L-COUNT L-SUCCESS L-NEW-COUNT.
     MOVE 0 TO L-SUCCESS
     MOVE L-COUNT TO L-NEW-COUNT
     IF L-BUCKET = 1 AND L-BABY = 0
         MOVE 1 TO L-SUCCESS
         IF L-CREATIVE = 0
             SUBTRACT 1 FROM L-NEW-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X2-COW-MILK.

