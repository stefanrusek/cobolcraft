*> Natural spawning of standard (minecraft:) mobs (docs/protocol/18-mob-framework.md section 6, with Appendix A and doc 44 parts 1 and 2).
*> Species logic exists for the rows of core/copy/STDMOBS.cpy only: an entry of a biome's spawn list whose species has no such row is skipped.
*> Random draws come from a Xoroshiro state the caller owns (XORO.cpy; any uniform generator is allowed, 44 part 1 section 1.4).
*>
*> Entry points (all BINARY-LONG unless said; state is an XR-STATE of XORO.cpy):
*>   MS6-CATEGORIES USING time (BINARY-DOUBLE), spawn_mobs, spawn_monsters, counts (8), chunks, flags (8) out, n out     6.1, 6.3
*>   MS6-CHUNK-NEAR USING player chunk x, z, chunk x, z, player x, z (FLOAT-LONG), near out                        6.2
*>   MS6-CANDIDATE-COUNT USING dim, count out                                                                      6.2
*>   MS6-CAP-MAX, MS6-GLOBAL-CAP, MS6-LOCAL-CAP                                                                    6.3
*>   MS6-RANDOM-POS USING state, chunk corner x, z, minY, top, x, y, z, ok out                                      6.4
*>   MS6-PACK USING state, dim, category, biome, chunk x, z, start x, y, z, spawned out                            6.5
*>   MS6-BIOME-FIND, MS6-LIST-TOTAL, MS6-ENTRY-PICK, MS6-PACK-SIZE, MS6-SPECIES                                    6.6
*>   MS6-ENERGY, MS6-COST-OK, MS6-COST-ADD                                                                         6.7
*>   MS6-LOCAL-LIGHT, MS6-DARK-ENOUGH, MS6-RULE-CHECK, MS6-RULE-AT, MS6-VALID-SPOT                                 6.8, 6.9
*>   MS6-BLOCK-KIND, MS6-PLACEMENT-OK                                                                              6.9
*>   MS6-CHUNK-GEN-BIOME USING state, dim, chunk x, z, biome, enabled, n out                                       6.10
*>   MS6-CHUNK-GEN-TICK USING n out (the main-thread hook: fresh chunks get their spawns once)                   6.10
*>   MS6-DESPAWN, MS6-DESPAWN-TICK                                                                                 6.11
*>   MS6-SPAWNER-NEW, MS6-SPAWNER-ROLL, MS6-SPAWNER-STEP, MS6-SPAWNER-ATTEMPT, MS6-EGG-SPAWN                        6.12
*>   MS6-SPAWN-CHUNK, MS6-CYCLE                                                                                    6.1 (the tick)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CAP-MAX.
*> USING category (1 to 8), max out: the cap per chunk-unit of the category (6.3, 1.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBCATS.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CAT L-MAX.
     MOVE MC-MAX(L-CAT) TO L-MAX
     GOBACK.
 END PROGRAM MS6-CAP-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-GLOBAL-CAP.
*> USING category, current count, spawnable chunk count, ok out: a category may spawn while count < max x chunks / 289 (integer division; 6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBCATS.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-CHUNKS               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CAT L-COUNT L-CHUNKS L-OK.
     COMPUTE WS-LIMIT = MC-MAX(L-CAT) * L-CHUNKS / 289
     MOVE 0 TO L-OK
     IF L-COUNT < WS-LIMIT
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-GLOBAL-CAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-LOCAL-CAP.
*> USING category, n (the players close to the chunk), players (64 x: has-counters flag, 8 counts), ok out: the category may spawn in the
*> chunk when any close player has no counters yet or a count below the unscaled max; false for no close player (6.3, LocalMobCapCalculator).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBCATS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-PLAYERS.
    05 L-P                 OCCURS 64 TIMES.
       10 L-HAS            BINARY-LONG.
       10 L-PC             BINARY-LONG OCCURS 8 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CAT L-N L-PLAYERS L-OK.
     MOVE 0 TO L-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         IF L-HAS(WS-I) = 0 OR L-PC(WS-I, L-CAT) < MC-MAX(L-CAT)
             MOVE 1 TO L-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-LOCAL-CAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CATEGORIES.
*> USING time (BINARY-DOUBLE, the game time), spawn_mobs, spawn_monsters (1 or 0), counts (8 BINARY-LONG: the non-persistent mobs of each
*> category in the level), chunks (the spawnable chunk count), flags (8 BINARY-LONG out: 1 for a category the tick tries), n out (how many):
*> getFilteredSpawningCategories (6.1): spawn_mobs false gives none; a category (all but MISC) needs (spawnEnemies or friendly) and
*> (spawnFriendlies, which holds when time mod 400 = 0, or not persistent) and its global cap (6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBCATS.
 01 WS-C                   BINARY-LONG.
 01 WS-FRIENDLIES          BINARY-LONG.
 01 WS-ENEMIES             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-MOBS                 BINARY-LONG.
 01 L-MONSTERS             BINARY-LONG.
 01 L-COUNTS.
    05 L-COUNT             BINARY-LONG OCCURS 8 TIMES.
 01 L-CHUNKS               BINARY-LONG.
 01 L-FLAGS.
    05 L-FLAG              BINARY-LONG OCCURS 8 TIMES.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-MOBS L-MONSTERS L-COUNTS L-CHUNKS L-FLAGS L-N.
     MOVE 0 TO L-N WS-FRIENDLIES WS-ENEMIES
     IF FUNCTION MOD(L-TIME, 400) = 0
         MOVE 1 TO WS-FRIENDLIES
     END-IF
     IF L-MOBS = 1 AND L-MONSTERS = 1
         MOVE 1 TO WS-ENEMIES
     END-IF
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 8
         MOVE 0 TO L-FLAG(WS-C)
         IF L-MOBS = 1 AND WS-C < 8
                 AND (WS-ENEMIES = 1 OR MC-FRIENDLY(WS-C) = 1)
                 AND (WS-FRIENDLIES = 1 OR MC-PERSIST(WS-C) = 0)
             CALL "MS6-GLOBAL-CAP" USING WS-C L-COUNT(WS-C) L-CHUNKS WS-OK
             IF WS-OK = 1
                 MOVE 1 TO L-FLAG(WS-C)
                 ADD 1 TO L-N
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-CATEGORIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CHUNK-NEAR.
*> USING player chunk x, player chunk z, chunk x, chunk z (BINARY-LONG), player x, player z (FLOAT-LONG), near out (BINARY-LONG): hasPlayersNearby
*> (6.2): 1 within 5 chunks (Chebyshev), 0 beyond 8; between, 1 when the horizontal squared distance from the player to the chunk centre
*> (minBlock + 8) is strictly below 16384.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PCX                  BINARY-LONG.
 01 L-PCZ                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-NEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PCX L-PCZ L-CX L-CZ L-PX L-PZ L-NEAR.
     MOVE 0 TO L-NEAR
     COMPUTE WS-DX = FUNCTION ABS(L-CX - L-PCX)
     COMPUTE WS-DZ = FUNCTION ABS(L-CZ - L-PCZ)
     COMPUTE WS-FAR = FUNCTION MAX(WS-DX, WS-DZ)
     COMPUTE WS-FX = L-PX - (L-CX * 16 + 8)
     COMPUTE WS-FZ = L-PZ - (L-CZ * 16 + 8)
     COMPUTE WS-D2 = WS-FX * WS-FX + WS-FZ * WS-FZ
     IF WS-FAR <= 5 OR (WS-FAR <= 8 AND WS-D2 < 16384)
         MOVE 1 TO L-NEAR
     END-IF
     GOBACK.
 END PROGRAM MS6-CHUNK-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CANDIDATE-COUNT.
*> USING dim, count out: the distinct chunks within 8 chunks (Chebyshev) of an alive non-spectator player of the dimension (the 17 x 17
*> square of each; 6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-N                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COVERED             BINARY-LONG.
 01 WS-PLAYERS.
    05 WS-PCX              BINARY-LONG OCCURS 64 TIMES.
    05 WS-PCZ              BINARY-LONG OCCURS 64 TIMES.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-COUNT.
     MOVE 0 TO L-COUNT WS-N
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE AND PL-DIM(WS-ROW) = L-DIM AND PL-MODE(WS-ROW) NOT = 3
             ADD 1 TO WS-N
             COMPUTE WS-PCX(WS-N) = FUNCTION INTEGER(PL-X(WS-ROW) / 16)
             COMPUTE WS-PCZ(WS-N) = FUNCTION INTEGER(PL-Z(WS-ROW) / 16)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-N
         PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
             PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
                 COMPUTE WS-CX = WS-PCX(WS-P) + WS-DX
                 COMPUTE WS-CZ = WS-PCZ(WS-P) + WS-DZ
                 MOVE 0 TO WS-COVERED
                 PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q >= WS-P
                     IF FUNCTION ABS(WS-CX - WS-PCX(WS-Q)) <= 8 AND FUNCTION ABS(WS-CZ - WS-PCZ(WS-Q)) <= 8
                         MOVE 1 TO WS-COVERED
                     END-IF
                 END-PERFORM
                 IF WS-COVERED = 0
                     ADD 1 TO L-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-CANDIDATE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-RANDOM-POS.
*> USING state, chunk corner x, chunk corner z, minY, top (the surface height + 1), x out, y out, z out, ok out (BINARY-LONG): getRandomPosWithin
*> (6.4): x = cx + nextInt(16), z = cz + nextInt(16), y = a uniform integer in [minY, top]; ok when y >= minY + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-A                   BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CX L-CZ L-MINY L-TOP L-X L-Y L-Z L-OK.
     CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
     COMPUTE L-X = L-CX + WS-A
     CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
     COMPUTE L-Z = L-CZ + WS-A
     COMPUTE WS-RANGE = L-TOP - L-MINY + 1
     CALL "XORO-NEXT-INT" USING L-STATE WS-RANGE WS-A
     COMPUTE L-Y = L-MINY + WS-A
     MOVE 0 TO L-OK
     IF L-Y > L-MINY
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-RANDOM-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-BIOME-FIND.
*> USING biome key (PIC X(48), "minecraft:<name>"), index out (BINARY-LONG): the row of MOBSPAWN.cpy's biome table (0 for a key it does not hold).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-NAME                PIC X(32).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE SPACES TO WS-NAME
     MOVE 0 TO L-INDEX
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:32) TO WS-NAME
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-BIOMES OR L-INDEX > 0
         IF SPB-NAME(WS-I) = WS-NAME
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-BIOME-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-LIST-TOTAL.
*> USING biome row, category (1 to 7), total out: the sum of the weights of the biome's list of that category (0 for an empty list).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-CAT L-TOTAL.
     MOVE 0 TO L-TOTAL
     COMPUTE WS-LAST = SPB-FIRST(L-BIOME) + SPB-COUNT(L-BIOME)
     PERFORM VARYING WS-I FROM SPB-FIRST(L-BIOME) BY 1 UNTIL WS-I >= WS-LAST
         IF SPE-CAT(WS-I + 1) = L-CAT
             ADD SPE-WEIGHT(WS-I + 1) TO L-TOTAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-LIST-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-ENTRY-PICK.
*> USING state, biome row, category, entry out (BINARY-LONG, a row of the entry table; 0 for an empty list, which draws nothing): WeightedList.getRandom
*> (44 part 2 section 7.1): one nextInt(total), then the first entry in list order whose cumulative weight exceeds the roll. Duplicates keep their own rows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BIOME                BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BIOME L-CAT L-ENTRY.
     MOVE 0 TO L-ENTRY
     CALL "MS6-LIST-TOTAL" USING L-BIOME L-CAT WS-TOTAL
     IF WS-TOTAL = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-TOTAL WS-ROLL
     COMPUTE WS-LAST = SPB-FIRST(L-BIOME) + SPB-COUNT(L-BIOME)
     PERFORM VARYING WS-I FROM SPB-FIRST(L-BIOME) BY 1 UNTIL WS-I >= WS-LAST OR L-ENTRY > 0
         IF SPE-CAT(WS-I + 1) = L-CAT
             SUBTRACT SPE-WEIGHT(WS-I + 1) FROM WS-ROLL
             IF WS-ROLL < 0
                 COMPUTE L-ENTRY = WS-I + 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-ENTRY-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-PACK-SIZE.
*> USING state, entry row, n out: the pack size sampled from the entry's count (6.5 step 3): a constant draws nothing, a uniform count draws
*> nextInt(max - min + 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-SPAN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ENTRY                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ENTRY L-N.
     MOVE SPE-MIN(L-ENTRY) TO L-N
     IF SPE-MAX(L-ENTRY) > SPE-MIN(L-ENTRY)
         COMPUTE WS-SPAN = SPE-MAX(L-ENTRY) - SPE-MIN(L-ENTRY) + 1
         CALL "XORO-NEXT-INT" USING L-STATE WS-SPAN WS-A
         ADD WS-A TO L-N
     END-IF
     GOBACK.
 END PROGRAM MS6-PACK-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPECIES.
*> USING key (PIC X(48), the entity key without "minecraft:"), row out (BINARY-LONG): the row of core/copy/STDMOBS.cpy, 0 when the species has no
*> logic or no natural spawn rule yet (SM-SPAWN 0; its spawn entries are skipped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT OR L-ROW > 0
         IF SM-KEY(WS-I) = L-KEY AND SM-SPAWN(WS-I) > 0
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-SPECIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-ENERGY.
*> USING points (64 x: x, y, z, charge, all FLOAT-LONG), n (BINARY-LONG), x, y, z, charge (FLOAT-LONG), result out (FLOAT-LONG): the energy change of a
*> candidate charge c at the position (6.7): c x (sum of q / sqrt(distance squared)); 0 for c = 0; a point at the same position makes it huge.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-POINTS.
    05 L-PT                OCCURS 64 TIMES.
       10 L-PT-X           FLOAT-LONG.
       10 L-PT-Y           FLOAT-LONG.
       10 L-PT-Z           FLOAT-LONG.
       10 L-PT-CHARGE      FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-CHARGE               FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-POINTS L-N L-X L-Y L-Z L-CHARGE L-RESULT.
     MOVE 0 TO WS-SUM L-RESULT
     IF L-CHARGE NOT = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
             COMPUTE WS-DX = L-PT-X(WS-I) - L-X
             COMPUTE WS-DY = L-PT-Y(WS-I) - L-Y
             COMPUTE WS-DZ = L-PT-Z(WS-I) - L-Z
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 = 0
                 ADD 1000000000000 TO WS-SUM
             END-IF
             IF WS-D2 > 0
                 COMPUTE WS-SUM = WS-SUM + L-PT-CHARGE(WS-I) / FUNCTION SQRT(WS-D2)
             END-IF
         END-PERFORM
         COMPUTE L-RESULT = L-CHARGE * WS-SUM
     END-IF
     GOBACK.
 END PROGRAM MS6-ENERGY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-COST-FIND.
*> USING biome row, key (PIC X(24), the species), index out (BINARY-LONG, a row of the cost table, 0 for a type without a cost).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     COMPUTE WS-LAST = SPB-COST-FIRST(L-BIOME) + SPB-COST-COUNT(L-BIOME)
     PERFORM VARYING WS-I FROM SPB-COST-FIRST(L-BIOME) BY 1 UNTIL WS-I >= WS-LAST
         IF SPC-KEY(WS-I + 1) = L-KEY
             COMPUTE L-INDEX = WS-I + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-COST-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-COST-OK.
*> USING biome row, key (PIC X(24)), points, n, x, y, z (the candidate; FLOAT-LONG), ok out (BINARY-LONG): SpawnState.canSpawn (6.7): a type with a
*> cost entry may spawn when the energy change of its charge is at most its energy budget; types without a cost always pass.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CHARGE              FLOAT-LONG.
 01 WS-BUDGET              FLOAT-LONG.
 01 WS-ENERGY              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-POINTS.
    05 L-PT                OCCURS 64 TIMES.
       10 L-PT-X           FLOAT-LONG.
       10 L-PT-Y           FLOAT-LONG.
       10 L-PT-Z           FLOAT-LONG.
       10 L-PT-CHARGE      FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-KEY L-POINTS L-N L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     CALL "MS6-COST-FIND" USING L-BIOME L-KEY WS-INDEX
     IF WS-INDEX > 0
         COMPUTE WS-CHARGE = SPC-CHARGE(WS-INDEX) / 1000
         COMPUTE WS-BUDGET = SPC-BUDGET(WS-INDEX) / 1000
         CALL "MS6-ENERGY" USING L-POINTS L-N L-X L-Y L-Z WS-CHARGE WS-ENERGY
         IF WS-ENERGY > WS-BUDGET
             MOVE 0 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MS6-COST-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-COST-ADD.
*> USING biome row, key (PIC X(24)), points, n (in and out), x, y, z (FLOAT-LONG): afterSpawn adds the new mob's charge at its position when its type has
*> a cost (at most 64 points are kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-POINTS.
    05 L-PT                OCCURS 64 TIMES.
       10 L-PT-X           FLOAT-LONG.
       10 L-PT-Y           FLOAT-LONG.
       10 L-PT-Z           FLOAT-LONG.
       10 L-PT-CHARGE      FLOAT-LONG.
 01 L-N                    BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-BIOME L-KEY L-POINTS L-N L-X L-Y L-Z.
     CALL "MS6-COST-FIND" USING L-BIOME L-KEY WS-INDEX
     IF WS-INDEX > 0 AND L-N < 64
         ADD 1 TO L-N
         MOVE L-X TO L-PT-X(L-N)
         MOVE L-Y TO L-PT-Y(L-N)
         MOVE L-Z TO L-PT-Z(L-N)
         COMPUTE L-PT-CHARGE(L-N) = SPC-CHARGE(WS-INDEX) / 1000
     END-IF
     GOBACK.
 END PROGRAM MS6-COST-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-LOCAL-LIGHT.
*> USING sky, block, darkening, thundering (BINARY-LONG), local out: getMaxLocalRawBrightness (6.8): the sky part is reduced by the night's darkening, or by
*> 10 while thundering, and the result is the larger of that and the block light (at least 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REDUCE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 01 L-THUNDER              BINARY-LONG.
 01 L-LOCAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-BLOCK L-DARKEN L-THUNDER L-LOCAL.
     MOVE L-DARKEN TO WS-REDUCE
     IF L-THUNDER = 1
         MOVE 10 TO WS-REDUCE
     END-IF
     COMPUTE L-LOCAL = FUNCTION MAX(L-SKY - WS-REDUCE, L-BLOCK, 0)
     GOBACK.
 END PROGRAM MS6-LOCAL-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-DARK-ENOUGH.
*> USING raw sky light, raw block light, nextInt(32) draw, block light limit, local light, sampled spawn light level (BINARY-LONG), ok out: isDarkEnoughToSpawn
*> (6.8): rejected when the sky light is above the draw, or the limit is below 15 and the block light above it; otherwise local light <= level.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-LOCAL                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-BLOCK L-DRAW L-LIMIT L-LOCAL L-LEVEL L-OK.
     MOVE 0 TO L-OK
     IF L-SKY > L-DRAW
         GOBACK
     END-IF
     IF L-LIMIT < 15 AND L-BLOCK > L-LIMIT
         GOBACK
     END-IF
     IF L-LOCAL <= L-LEVEL
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-DARK-ENOUGH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-RULE-CHECK.
*> USING predicate (1 Mob.checkMobSpawnRules, 2 Monster.checkMonsterSpawnRules, 3 Animal.checkAnimalSpawnRules, 4 any-light monster, 5 surface
*> monster), reason (0 natural, 1 chunk generation, 2 spawner, 3 trial spawner), peaceful (1 on Peaceful), dark-ok, bright-ok, valid-below (the block
*> below is a valid spawn floor), grass-below, sees-sky (all 1 or 0), ok out: the truth tables of 6.8. Peaceful rejects the monster predicates; the
*> block-below test is skipped by the two spawner reasons; only the trial spawner ignores light.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-SPAWNER             BINARY-LONG.
 LINKAGE SECTION.
 01 L-PRED                 BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-GRASS                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PRED L-REASON L-PEACEFUL L-DARK L-BRIGHT L-VALID L-GRASS L-SKY L-OK.
     MOVE 0 TO L-OK WS-BASE WS-LIGHT WS-BRIGHT WS-SPAWNER
     IF L-REASON = 2 OR L-REASON = 3
         MOVE 1 TO WS-SPAWNER
     END-IF
     IF WS-SPAWNER = 1 OR L-VALID = 1
         MOVE 1 TO WS-BASE
     END-IF
     IF L-REASON = 3 OR L-DARK = 1
         MOVE 1 TO WS-LIGHT
     END-IF
     IF L-REASON = 3 OR L-BRIGHT = 1
         MOVE 1 TO WS-BRIGHT
     END-IF
     EVALUATE L-PRED
         WHEN 1
             MOVE WS-BASE TO L-OK
         WHEN 2
             IF L-PEACEFUL = 0 AND WS-LIGHT = 1 AND WS-BASE = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN 3
             IF WS-BRIGHT = 1 AND L-GRASS = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN 4
             IF L-PEACEFUL = 0 AND WS-BASE = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN 5
             IF L-PEACEFUL = 0 AND WS-LIGHT = 1 AND WS-BASE = 1 AND (WS-SPAWNER = 1 OR L-SKY = 1)
                 MOVE 1 TO L-OK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MS6-RULE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-BLOCK-KIND.
*> USING dim, x, y, z, kind out (BINARY-LONG): what the cell holds for the spawn rules (6.9): 0 empty (air or a block without collision), 1 a full solid
*> block, 2 water, 3 lava, 4 fire, 5 a rail (tag prevent_mob_spawning_inside).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-RAIL                BINARY-LONG.
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
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-SOLID(WS-BLOCK) TO L-KIND
     MOVE 0 TO WS-WATER WS-LAVA WS-FIRE WS-RAIL
*>   The fluids and the fire are the blocks of those names, not every key that holds the word (a water cauldron is no water, a campfire or a fire coral is no fire).
     IF CB-KEY(WS-BLOCK) = "water"
         MOVE 1 TO WS-WATER
     END-IF
     IF CB-KEY(WS-BLOCK) = "lava"
         MOVE 1 TO WS-LAVA
     END-IF
     IF CB-KEY(WS-BLOCK) = "fire" OR CB-KEY(WS-BLOCK) = "soul_fire"
         MOVE 1 TO WS-FIRE
     END-IF
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-RAIL FOR ALL "rail"
     IF WS-WATER > 0
         MOVE 2 TO L-KIND
     END-IF
     IF WS-LAVA > 0
         MOVE 3 TO L-KIND
     END-IF
     IF WS-FIRE > 0
         MOVE 4 TO L-KIND
     END-IF
     IF WS-RAIL > 0
         MOVE 5 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM MS6-BLOCK-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-FLOOR-ALWAYS.
*> USING dim, x, y, z (the floor cell), ok out (BINARY-LONG): 1 when the block sets isValidSpawn to "always" (44 part 1 RQ-1.10: soul sand, carved pumpkin, jack o'lantern,
*> redstone lamp, mud): a valid floor for every species whatever the shape of its top face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     IF CB-KEY(WS-BLOCK) = "soul_sand" OR "carved_pumpkin" OR "jack_o_lantern" OR "redstone_lamp" OR "mud"
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-FLOOR-ALWAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-FLOOR-DENIED.
*> USING dim, x, y, z (the floor cell), species key (PIC X(24), the STDMOBS key), denied out (BINARY-LONG): 1 when the block's isValidSpawn is a species test that the species fails
*> (44 part 1 RQ-1.10): leaves allow only the ocelot and the parrot, ice and frosted ice only the polar bear, magma block only the fire immune types (M1-FLAGS bit 1 of the mob table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY MOB181.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-DENIED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY L-DENIED.
     MOVE 0 TO L-DENIED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE 0 TO WS-LEAVES
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-LEAVES FOR ALL "_leaves"
     EVALUATE TRUE
         WHEN WS-LEAVES > 0
             IF L-KEY NOT = "ocelot" AND L-KEY NOT = "parrot"
                 MOVE 1 TO L-DENIED
             END-IF
         WHEN CB-KEY(WS-BLOCK) = "ice" OR "frosted_ice"
             IF L-KEY NOT = "polar_bear"
                 MOVE 1 TO L-DENIED
             END-IF
         WHEN CB-KEY(WS-BLOCK) = "magma_block"
             CALL "M181-FIND" USING L-KEY WS-R1
             MOVE 1 TO L-DENIED
             IF WS-R1 > 0
                 IF FUNCTION MOD(M1-FLAGS(WS-R1), 2) = 1
                     MOVE 0 TO L-DENIED
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MS6-FLOOR-DENIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-STURDY-TOP.
*> USING dim, x, y, z, ok out (BINARY-LONG): for the cell of a full solid block (MS6-BLOCK-KIND 1), whether its top face is sturdy, the part of Block.isValidSpawn (18 section 6.8: the top face is sturdy
*> and the light emission is below 14) that the collision flag does not tell. The core keeps no face shapes (24 section 5.2), so the blocks whose top face is smaller than the cell are named by their keys:
*> beds, carpets, farmland, paths, cauldrons, fences, walls, panes and bars, doors and trapdoors, chests and the workstations and lights of a village (campfire, lantern, bell, anvil, grindstone,
*> composter, lectern, hopper, brewing stand, flower pots), and the stairs and slabs that do not hold their full face up (a stair with half top, a slab of type top or double does). The blocks that set
*> isValidSpawn to "never" (44 part 1 RQ-1.10: bedrock, glass, tinted glass, the stained glass, barrier, moving piston, scaffolding, chorus flower, the trapdoors and the copper grates) are never a floor,
*> though their top face is sturdy (the Nether roof and the bedrock layers hold no spawn). The light emission and the blocks that override isValidSpawn the other way (soul sand, mud, carved pumpkin,
*> jack o'lantern, redstone lamp: always; leaves, ice and magma: for some species) are not modelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SMALL               BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-SLAB                BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE 0 TO WS-SMALL WS-STAIRS WS-SLAB WS-UP
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-SMALL FOR ALL "_bed" ALL "carpet" ALL "farmland" ALL "dirt_path" ALL "cauldron" ALL "_fence" ALL "_wall" ALL "_pane"
         ALL "iron_bars" ALL "_door" ALL "chest" ALL "campfire" ALL "lantern" ALL "bell" ALL "anvil" ALL "grindstone" ALL "composter" ALL "lectern" ALL "hopper"
         ALL "brewing_stand" ALL "flower_pot" ALL "potted_" ALL "stonecutter"
         ALL "bedrock" ALL "tinted_glass" ALL "stained_glass" ALL "barrier" ALL "moving_piston" ALL "scaffolding" ALL "chorus_flower" ALL "_trapdoor"
         ALL "copper_grate"
     IF CB-KEY(WS-BLOCK) = "glass"
         ADD 1 TO WS-SMALL
     END-IF
     IF WS-SMALL > 0
         MOVE 0 TO L-OK
         GOBACK
     END-IF
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-STAIRS FOR ALL "_stairs"
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-SLAB FOR ALL "_slab"
     IF WS-STAIRS > 0 OR WS-SLAB > 0
         CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
         INSPECT WS-PROPS TALLYING WS-UP FOR ALL "half=top" ALL "type=top" ALL "type=double"
         IF WS-UP = 0
             MOVE 0 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MS6-STURDY-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-PLACEMENT-OK.
*> USING placement (1 ON_GROUND, 2 IN_WATER, 3 IN_LAVA, 4 NO_RESTRICTIONS), dim, x, y, z, ok out (BINARY-LONG): SpawnPlacements.isSpawnPositionOk (6.9).
*> ON_GROUND: a solid block below with a sturdy top face (MS6-STURDY-TOP; the blocks that are always valid, MS6-FLOOR-ALWAYS, need neither) and valid empty blocks (kind 0: no full block, fluid, fire or rail) at the position and above it. IN_WATER: water at
*> the position and no full block above. IN_LAVA: lava at the position. The world border is not modelled (the dimension is unbounded here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STURDY              BINARY-LONG.
 01 WS-ALWAYS              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLACE                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACE L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X L-Y L-Z WS-KIND
     COMPUTE WS-Y = L-Y + 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-ABOVE
     COMPUTE WS-Y = L-Y - 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-BELOW
     MOVE 1 TO WS-STURDY
     IF WS-BELOW = 1
         CALL "MS6-STURDY-TOP" USING L-DIM L-X WS-Y L-Z WS-STURDY
     END-IF
     CALL "MS6-FLOOR-ALWAYS" USING L-DIM L-X WS-Y L-Z WS-ALWAYS
     EVALUATE L-PLACE
         WHEN 1
             IF WS-KIND = 0 AND WS-ABOVE = 0 AND ((WS-BELOW = 1 AND WS-STURDY = 1) OR WS-ALWAYS = 1)
                 MOVE 1 TO L-OK
             END-IF
         WHEN 2
             IF WS-KIND = 2 AND WS-ABOVE NOT = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN 3
             IF WS-KIND = 3
                 MOVE 1 TO L-OK
             END-IF
         WHEN 4
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM MS6-PLACEMENT-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-IS-GRASS.
*> USING dim, x, y, z, ok out (BINARY-LONG): 1 when the block is a grass_block (the block tag animals_spawnable_on holds only that, 6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-GRASS               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE SPACES TO WS-KEY
         MOVE "minecraft:grass_block" TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-GRASS WS-BLOCK-ROW WS-STATUS
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF CB-S-BLOCK(WS-STATE + 1) = WS-GRASS
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-IS-GRASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-NEAREST.
*> USING dim, x, y, z (FLOAT-LONG), d2 out (FLOAT-LONG): the squared distance to the nearest alive non-spectator player of the dimension (a very large
*> number, 1e15, when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-D2.
     MOVE 1000000000000000 TO L-D2
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE AND PL-DIM(WS-ROW) = L-DIM AND PL-MODE(WS-ROW) NOT = 3
             COMPUTE WS-DX = PL-X(WS-ROW) - L-X
             COMPUTE WS-DY = PL-Y(WS-ROW) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-ROW) - L-Z
             COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D < L-D2
                 MOVE WS-D TO L-D2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-NEAREST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-RULE-AT.
*> USING state, dim, species row (STDMOBS.cpy), x, y, z (BINARY-LONG feet cell), reason (0 natural, 1 chunk generation, 2 spawner, 3 trial), ok out
*> (BINARY-LONG): SpawnPlacements.checkSpawnRules (6.8) of a monster (kind 1: the Overworld light gate, the spawn light level a uniform 0 to 7) or an
*> animal (kind 0: raw brightness above 8 and grass below) at the cell. The draws are nextInt(32) and nextInt(8), only for monsters. The floor is valid
*> when it is a full solid block or an "always" floor (MS6-FLOOR-ALWAYS) and the species passes the floor's species test (MS6-FLOOR-DENIED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-PRED                BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-32                  BINARY-LONG VALUE 32.
 01 WS-8                   BINARY-LONG VALUE 8.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OPEN-SKY            BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-ALWAYS              BINARY-LONG.
 01 WS-DENIED              BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-ROW L-X L-Y L-Z L-REASON L-OK.
     IF SM-SPAWN(L-ROW) = 6
         CALL "STDMOB-SLIME-RULE" USING L-STATE L-DIM L-X L-Y L-Z L-REASON L-OK
         GOBACK
     END-IF
     IF SM-KIND(L-ROW) >= 2
         CALL "MS6-WATER-RULE" USING L-DIM L-ROW L-X L-Y L-Z L-OK
         GOBACK
     END-IF
*>   LIGHT-RAW, not STDMOB-LIGHTS: the stored sky light is 0 at and below a column's topmost non-void block, so a cell holding grass or a flower, or lying
*>   under leaves or glass, would read dark in full daylight; LIGHT-RAW lights such a cell by the sky when no opaque block is above it.
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK WS-RAW
*>   The stored sky light does not spread sideways (light.cob): under the eaves of a house or a porch roof it reads 0 although the sky shines in from the side, which let hostile mobs
*>   spawn there by day. LIGHT-SKY-SPREAD gives the level the sky engine has there (32 section 5.2) for the cells within 7 steps of open sky.
     CALL "LIGHT-SKY-SPREAD" USING L-DIM L-X L-Y L-Z WS-SPREAD WS-SKY
     COMPUTE WS-BELOW = L-Y - 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-BELOW L-Z WS-KIND
     MOVE 0 TO WS-VALID WS-BRIGHT WS-DARK WS-PEACEFUL
     IF WS-KIND = 1
         MOVE 1 TO WS-VALID
     END-IF
*>   The floors whose isValidSpawn is "always" or a species test (44 part 1 RQ-1.10).
     CALL "MS6-FLOOR-ALWAYS" USING L-DIM L-X WS-BELOW L-Z WS-ALWAYS
     IF WS-ALWAYS = 1
         MOVE 1 TO WS-VALID
     END-IF
     CALL "MS6-FLOOR-DENIED" USING L-DIM L-X WS-BELOW L-Z SM-KEY(L-ROW) WS-DENIED
     IF WS-DENIED = 1
         MOVE 0 TO WS-VALID
     END-IF
     CALL "MS6-IS-GRASS" USING L-DIM L-X WS-BELOW L-Z WS-GRASS
     CALL "M19-SPECIES-FLOOR" USING SM-KEY(L-ROW) WS-FLOOR
     IF SM-KIND(L-ROW) = 0 AND WS-FLOOR > 1
         CALL "M19-FLOOR-AT" USING L-DIM L-X WS-BELOW L-Z WS-FLOOR WS-GRASS
     END-IF
     IF FUNCTION MAX(WS-SKY, WS-BLOCK) > 8
         MOVE 1 TO WS-BRIGHT
     END-IF
     IF BW-DIFFICULTY = 0
         MOVE 1 TO WS-PEACEFUL
     END-IF
     MOVE 3 TO WS-PRED
     IF SM-KIND(L-ROW) = 1
         MOVE 2 TO WS-PRED
         CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
         CALL "MS6-LOCAL-LIGHT" USING WS-SKY WS-BLOCK WS-DARKEN WS-ZERO WS-LOCAL
         CALL "XORO-NEXT-INT" USING L-STATE WS-32 WS-DRAW
         CALL "XORO-NEXT-INT" USING L-STATE WS-8 WS-LEVEL
         CALL "MS6-DARK-ENOUGH" USING WS-SKY WS-BLOCK WS-DRAW WS-ZERO WS-LOCAL WS-LEVEL WS-DARK
     END-IF
     MOVE 0 TO WS-OPEN-SKY
     IF SM-SPAWN(L-ROW) = 10
*>       The any-light monster rule (21 section 3.2): no light test, the base and the not-Peaceful tests of predicate 4.
         MOVE 4 TO WS-PRED
     END-IF
     IF SM-SPAWN(L-ROW) = 11
*>       Piglin and hoglin (21 section 3.2): only the floor test of predicate 1, on Peaceful too.
         MOVE 1 TO WS-PRED
     END-IF
     IF SM-SPAWN(L-ROW) = 5
         MOVE 5 TO WS-PRED
         IF WS-SKY = 15
             MOVE 1 TO WS-OPEN-SKY
         END-IF
     END-IF
     CALL "MS6-RULE-CHECK" USING WS-PRED L-REASON WS-PEACEFUL WS-DARK WS-BRIGHT WS-VALID WS-GRASS WS-OPEN-SKY L-OK
     GOBACK.
 END PROGRAM MS6-RULE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-VALID-SPOT.
*> USING state, dim, species row, x, y, z (BINARY-LONG feet cell), reason, ok out (BINARY-LONG): isValidSpawnPostitionForType (6.5 step 4): the ON_GROUND
*> placement (6.9) and the type's spawn rule (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-PLACE               BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-ROW L-X L-Y L-Z L-REASON L-OK.
     MOVE 0 TO L-OK
     MOVE 1 TO WS-PLACE
     IF SM-KIND(L-ROW) >= 2
         MOVE 2 TO WS-PLACE
     END-IF
     CALL "MS6-PLACEMENT-OK" USING WS-PLACE L-DIM L-X L-Y L-Z WS-OK
     IF WS-OK = 1
         CALL "MS6-RULE-AT" USING L-STATE L-DIM L-ROW L-X L-Y L-Z L-REASON L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-VALID-SPOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-PACK.
*> USING state, dim, category (1 to 7), biome row, chunk x, chunk z (the chunk being processed), start x, y, z (BINARY-LONG), spawned out (BINARY-LONG):
*> spawnCategoryForPosition (6.5). A full solid block at the start spawns nothing. Up to 3 packs; a pack has maxPack = ceil(nextFloat x 4) attempts, replaced
*> by the entry's count once an entry is chosen; an attempt moves the cursor by nextInt(6) - nextInt(6) per axis, needs the nearest player more than 24 and at
*> most 128 blocks away in a generated chunk, chooses the weighted entry once per pack (no entry, or a species without a row, ends the pack), needs a valid
*> spot (6.8, 6.9) and the spawn-cost budget (6.7), and then creates the mob with a random yaw. Four mobs in a call end it; four in a pack end the pack.
*> The cost field holds only the mobs this call made. The biome is the one at the start position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MOBSPAWN.
 COPY STDMOBS.
 COPY STRUCTOVR.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-KIND                BINARY-LONG.
 01 WS-DONE-ALL            BINARY-LONG.
 01 WS-DONE-PACK           BINARY-LONG.
 01 WS-PACK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IN-PACK             BINARY-LONG.
 01 WS-MAXPACK             BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-DBL                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-KEY48               PIC X(48).
 01 WS-KEY24               PIC X(24).
 01 WS-EKEY                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PN                  BINARY-LONG.
 01 WS-PICKED              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-OENTRY              BINARY-LONG.
 01 WS-POINTS.
    05 WS-PT               OCCURS 64 TIMES.
       10 WS-PT-X          FLOAT-LONG.
       10 WS-PT-Y          FLOAT-LONG.
       10 WS-PT-Z          FLOAT-LONG.
       10 WS-PT-CHARGE     FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-SPAWNED              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-CAT L-BIOME L-CX L-CZ L-PX L-PY L-PZ L-SPAWNED.
     MOVE 0 TO L-SPAWNED WS-DONE-ALL WS-PN
     CALL "MS6-BLOCK-KIND" USING L-DIM L-PX L-PY L-PZ WS-KIND
     IF WS-KIND = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-PACK FROM 1 BY 1 UNTIL WS-PACK > 3 OR WS-DONE-ALL = 1
         MOVE 0 TO WS-IN-PACK WS-ENTRY WS-ROW WS-DONE-PACK WS-I WS-FIRST WS-PICKED
         MOVE L-PX TO WS-X
         MOVE L-PZ TO WS-Z
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-DBL
         COMPUTE WS-T = WS-DBL * 4
         COMPUTE WS-MAXPACK = FUNCTION INTEGER-PART(WS-T)
         IF WS-T > WS-MAXPACK
             ADD 1 TO WS-MAXPACK
         END-IF
         PERFORM UNTIL WS-I >= WS-MAXPACK OR WS-DONE-PACK = 1 OR WS-DONE-ALL = 1
             ADD 1 TO WS-I
             CALL "XORO-NEXT-INT" USING L-STATE WS-SIX WS-A
             CALL "XORO-NEXT-INT" USING L-STATE WS-SIX WS-B
             COMPUTE WS-X = WS-X + WS-A - WS-B
             CALL "XORO-NEXT-INT" USING L-STATE WS-SIX WS-A
             CALL "XORO-NEXT-INT" USING L-STATE WS-SIX WS-B
             COMPUTE WS-Z = WS-Z + WS-A - WS-B
             COMPUTE WS-FX = WS-X + 0.5
             MOVE L-PY TO WS-FY
             COMPUTE WS-FZ = WS-Z + 0.5
             CALL "MS6-NEAREST" USING L-DIM WS-FX WS-FY WS-FZ WS-D2
             COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
             CALL "STDMOB-READY" USING L-DIM WS-CX WS-CZ WS-READY
             MOVE 1 TO WS-OK
             IF WS-D2 <= 576 OR WS-D2 > 16384 OR WS-READY = 0
                 MOVE 0 TO WS-OK
             END-IF
*>           Not within 24 blocks of the level's respawn position when that is in this dimension (6.5 step 2, closerToCenterThan: the block centre).
             IF L-DIM = CW-DIM(1)
                 COMPUTE WS-SX = WS-FX - (FUNCTION INTEGER(CW-SPAWN-X) + 0.5)
                 COMPUTE WS-SY = WS-FY - (FUNCTION INTEGER(CW-SPAWN-Y) + 0.5)
                 COMPUTE WS-SZ = WS-FZ - (FUNCTION INTEGER(CW-SPAWN-Z) + 0.5)
                 IF WS-SX * WS-SX + WS-SY * WS-SY + WS-SZ * WS-SZ < 576
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
             IF WS-OK = 1 AND WS-PICKED = 0
                 MOVE 1 TO WS-PICKED
*>               a structure that overrides the lists at the position replaces the biome's list (44-2 8.1 step 2b); an empty list draws nothing
                 CALL "SO-LOOKUP" USING L-DIM WS-X L-PY WS-Z L-CAT WS-LIST
                 IF WS-LIST > 0
                     CALL "SO-PICK" USING L-STATE WS-LIST WS-OENTRY
                     IF WS-OENTRY > 0
                         MOVE SO-E-KEY(WS-OENTRY) TO WS-KEY24
                         MOVE WS-KEY24 TO WS-KEY48
                         CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
                         CALL "SO-PACK-SIZE" USING L-STATE WS-OENTRY WS-MAXPACK
                     END-IF
                 ELSE
                     CALL "MS6-ENTRY-PICK" USING L-STATE L-BIOME L-CAT WS-ENTRY
                     IF WS-ENTRY > 0
                         MOVE SPE-KEY(WS-ENTRY) TO WS-KEY24
                         MOVE WS-KEY24 TO WS-KEY48
                         CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
                         CALL "MS6-PACK-SIZE" USING L-STATE WS-ENTRY WS-MAXPACK
                     END-IF
                 END-IF
                 IF WS-ROW = 0
                     MOVE 1 TO WS-DONE-PACK
                     MOVE 0 TO WS-OK
                 END-IF
             END-IF
             IF WS-OK = 1
                 CALL "MS6-VALID-SPOT" USING L-STATE L-DIM WS-ROW WS-X L-PY WS-Z WS-REASON WS-OK
             END-IF
             IF WS-OK = 1
                 CALL "MS6-COST-OK" USING L-BIOME WS-KEY24 WS-POINTS WS-PN WS-FX WS-FY WS-FZ WS-OK
             END-IF
             IF WS-OK = 1
                 CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-DBL
                 COMPUTE WS-YAW = WS-DBL * 360
                 MOVE SPACES TO WS-EKEY
                 STRING "minecraft:" DELIMITED BY SIZE WS-KEY24 DELIMITED BY SPACE INTO WS-EKEY
                 CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
                 CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
                 CALL "STDMOB-FINALIZE" USING L-STATE WS-NEW
*>               A group shares the first member's variant (wolf, fox, llama).
                 IF WS-IN-PACK = 0
                     MOVE WS-NEW TO WS-FIRST
                 END-IF
                 CALL "M19-PACK-SHARE" USING WS-FIRST WS-NEW
                 ADD 1 TO L-SPAWNED WS-IN-PACK
                 CALL "MS6-COST-ADD" USING L-BIOME WS-KEY24 WS-POINTS WS-PN WS-FX WS-FY WS-FZ
                 IF L-SPAWNED >= 4
                     MOVE 1 TO WS-DONE-ALL
                 END-IF
                 IF WS-IN-PACK >= 4
                     MOVE 1 TO WS-DONE-PACK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-GEN-ATTEMPT.
*> USING state, dim, species row, chunk corner x, chunk corner z, x, z (BINARY-LONG), ok out (BINARY-LONG): one attempt of the chunk-generation spawn (6.10):
*> the top non-colliding position of the column (the highest non-air block, stand above it), the placement (6.9) and the rule with the reason
*> CHUNK_GENERATION (6.8) there, then the mob is created with a random yaw at the column centre clamped into the chunk shrunk by half a block width.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 1.
 01 WS-DBL                 FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-KEY                 PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-MINX                 BINARY-LONG.
 01 L-MINZ                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-STATE L-DIM L-ROW L-MINX L-MINZ L-X L-Z L-OK L-KEY.
     MOVE 0 TO L-OK
     IF L-ROW = 0
         GOBACK
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "STDMOB-READY" USING L-DIM WS-CX WS-CZ WS-READY
     COMPUTE WS-Y = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-Y < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     ADD 1 TO WS-Y
     CALL "MS6-VALID-SPOT" USING L-STATE L-DIM L-ROW L-X WS-Y L-Z WS-REASON L-OK
     IF L-OK = 1 AND WS-READY = 1
         COMPUTE WS-FX = FUNCTION MIN(FUNCTION MAX(L-X + 0.5, L-MINX + 0.45), L-MINX + 15.55)
         COMPUTE WS-FZ = FUNCTION MIN(FUNCTION MAX(L-Z + 0.5, L-MINZ + 0.45), L-MINZ + 15.55)
         MOVE WS-Y TO WS-FY
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-DBL
         COMPUTE WS-YAW = WS-DBL * 360
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
     END-IF
     GOBACK.
 END PROGRAM MS6-GEN-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CHUNK-GEN-BIOME.
*> USING state, dim, chunk x, chunk z, biome row, enabled (the spawn_mobs rule), n out (BINARY-LONG): spawnMobsForChunkGeneration (6.10). Only with spawn_mobs
*> and a non-empty creature list: while nextFloat() < the biome's probability (checked again after each group) one weighted entry gives a pack size and a
*> start column; each member makes up to 4 attempts (MS6-GEN-ATTEMPT), the column moving by nextInt(5) - nextInt(5) per axis after each attempt, replaced by
*> a fresh random column when it leaves the chunk. A species without a row makes failed attempts only.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBSPAWN.
 01 WS-CAT                 BINARY-LONG VALUE 2.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-KEY24               PIC X(24).
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-CX L-CZ L-BIOME L-ENABLED L-N.
     MOVE 0 TO L-N
     IF L-ENABLED = 0
         GOBACK
     END-IF
     CALL "MS6-LIST-TOTAL" USING L-BIOME WS-CAT WS-TOTAL
     IF WS-TOTAL = 0
         GOBACK
     END-IF
     COMPUTE WS-MINX = L-CX * 16
     COMPUTE WS-MINZ = L-CZ * 16
     COMPUTE WS-P = SPB-PROB(L-BIOME) / 1000
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     PERFORM UNTIL WS-D >= WS-P
         CALL "MS6-ENTRY-PICK" USING L-STATE L-BIOME WS-CAT WS-ENTRY
         MOVE SPE-KEY(WS-ENTRY) TO WS-KEY24
         MOVE WS-KEY24 TO WS-KEY48
         CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
         CALL "MS6-PACK-SIZE" USING L-STATE WS-ENTRY WS-COUNT
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
         COMPUTE WS-X = WS-MINX + WS-A
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
         COMPUTE WS-Z = WS-MINZ + WS-A
         PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > WS-COUNT
             MOVE 0 TO WS-OK WS-TRY
             PERFORM UNTIL WS-OK = 1 OR WS-TRY >= 4
                 ADD 1 TO WS-TRY
                 CALL "MS6-GEN-ATTEMPT" USING L-STATE L-DIM WS-ROW WS-MINX WS-MINZ WS-X WS-Z WS-OK WS-KEY24
                 CALL "XORO-NEXT-INT" USING L-STATE WS-FIVE WS-A
                 CALL "XORO-NEXT-INT" USING L-STATE WS-FIVE WS-B
                 COMPUTE WS-X = WS-X + WS-A - WS-B
                 CALL "XORO-NEXT-INT" USING L-STATE WS-FIVE WS-A
                 CALL "XORO-NEXT-INT" USING L-STATE WS-FIVE WS-B
                 COMPUTE WS-Z = WS-Z + WS-A - WS-B
                 IF WS-X < WS-MINX OR WS-X > WS-MINX + 15 OR WS-Z < WS-MINZ OR WS-Z > WS-MINZ + 15
                     CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
                     COMPUTE WS-X = WS-MINX + WS-A
                     CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
                     COMPUTE WS-Z = WS-MINZ + WS-A
                 END-IF
                 ADD WS-OK TO L-N
             END-PERFORM
         END-PERFORM
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-CHUNK-GEN-BIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CHUNK-GEN-TICK.
*> USING n out (BINARY-LONG): the main-thread hook of the chunk-generation spawns (6.10). Chunk generation may run on worker threads, so a freshly generated chunk
*> (CK-FRESH, set by WORLD-CHUNK-LOAD when it generates instead of reading a file) is given its spawns here, once, on the next spawn tick: in a standard world
*> each such chunk gets one MS6-CHUNK-GEN-BIOME pass (the spawn_mobs rule, the biome at the chunk's centre column at sea level 64) and the mark is cleared.
*> n is the number of mobs made. Other world types leave the marks alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260610.
 01 WS-NAME-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-V                   BINARY-DOUBLE.
 01 WS-ENABLED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 64.
 01 WS-Z                   BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N.
     MOVE 0 TO L-N
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
*>   The flat generator creates no creatures at chunk generation (56 section 4.2 and 4.9).
     IF CT-OPEN = 0 OR CT-SET-TYPE NOT = CT-TYPE-STANDARD OR CW-WORLD-TYPE = "superflat"
         GOBACK
     END-IF
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "BR-RULE-GET" USING WS-NAME-MOBS WS-V
     MOVE WS-V TO WS-ENABLED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CK-COUNT
         IF CK-USED(WS-I) = 1 AND CK-FRESH(WS-I) = 1
             MOVE 0 TO CK-FRESH(WS-I)
             COMPUTE WS-X = CK-X(WS-I) * 16 + 8
             COMPUTE WS-Z = CK-Z(WS-I) * 16 + 8
             CALL "MS6-BIOME-AT" USING CK-DIM(WS-I) WS-X WS-Y WS-Z WS-BIOME
             CALL "MS6-CHUNK-GEN-BIOME" USING WS-STATE CK-DIM(WS-I) CK-X(WS-I) CK-Z(WS-I) WS-BIOME WS-ENABLED WS-M
             ADD WS-M TO L-N
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-CHUNK-GEN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-DESPAWN.
*> USING category, persistent, removeWhenFarAway, peaceful-discard (1: Peaceful and a type not allowed in it), have-player (a player at any distance),
*> squared distance to the nearest player (BINARY-DOUBLE), noActionTime (in and out), nextInt(800) draw, result out (1 discard): Mob.checkDespawn (6.11).
*> Instant despawn beyond the category's distance (128, 64 for water ambient); random despawn when noActionTime > 600, the draw is 0 and the distance is
*> over 32 blocks; within 32 blocks noActionTime is reset. A persistent mob, or one that keeps when far away, is never removed for distance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBCATS.
 01 WS-LIMIT               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-CAT                  BINARY-LONG.
 01 L-PERSIST              BINARY-LONG.
 01 L-REMOVABLE            BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-HAVE                 BINARY-LONG.
 01 L-D2                   BINARY-DOUBLE.
 01 L-IDLE                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAT L-PERSIST L-REMOVABLE L-PEACEFUL L-HAVE L-D2 L-IDLE L-DRAW L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-PEACEFUL = 1
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     IF L-HAVE = 0
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = MC-DESPAWN(L-CAT) * MC-DESPAWN(L-CAT)
     IF L-PERSIST = 0 AND L-REMOVABLE = 1 AND L-D2 > WS-LIMIT
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     IF L-PERSIST = 0 AND L-REMOVABLE = 1 AND L-IDLE > 600 AND L-DRAW = 0 AND L-D2 > 1024
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     IF L-D2 < 1024
         MOVE 0 TO L-IDLE
     END-IF
     GOBACK.
 END PROGRAM MS6-DESPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-DESPAWN-TICK.
*> USING entity row (BINARY-LONG): Entity.checkDespawn of a standard mob (6.11) every tick: the idle counter (noActionTime) rises, is reset by damage (the
*> hurt cooldown), and MS6-DESPAWN decides; Peaceful discards hostile mobs. Hostile mobs are removable and in category monster; animals never
*> despawn for distance (Animal.removeWhenFarAway is false) and are in category creature. A row that is not a standard mob is left alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 7919.
 01 WS-IDLES.
    05 WS-IDLE-ENTRY       OCCURS 1024 TIMES.
       10 WS-IDLE-ID       BINARY-LONG.
       10 WS-IDLE-N        BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-PERSIST             BINARY-LONG VALUE 0.
 01 WS-ZNO                 BINARY-LONG VALUE 0.
 01 WS-ZSLOT               BINARY-LONG.
 01 WS-REMOVABLE           BINARY-LONG.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-D2F                 FLOAT-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-800                 BINARY-LONG VALUE 800.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-USED(L-ROW) = 0
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-S
     IF WS-S = 0
         GOBACK
     END-IF
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "MS6-ROW-CAT" USING WS-S WS-CAT
     MOVE 0 TO WS-REMOVABLE
     IF SM-KIND(WS-S) > 0
         MOVE 1 TO WS-REMOVABLE
     END-IF
*>   A converting zombie villager is never removed for distance and needs custom persistence (20 section 4.2; T8803).
     MOVE 0 TO WS-PERSIST
     IF SM-KEY(WS-S) = "zombie_villager"
         CALL "ZC-FIND" USING EN-ID(L-ROW) WS-ZNO WS-ZSLOT
         IF WS-ZSLOT > 0
             MOVE 0 TO WS-REMOVABLE
             MOVE 1 TO WS-PERSIST
         END-IF
     END-IF
*>   A mob a structure made (EN-PERSISTENT: PersistenceRequired) is never removed for distance.
     IF EN-PERSISTENT(L-ROW) = 1
         MOVE 1 TO WS-PERSIST
     END-IF
     MOVE 0 TO WS-PEACEFUL WS-HAVE
     IF BW-DIFFICULTY = 0 AND SM-KIND(WS-S) = 1
         MOVE 1 TO WS-PEACEFUL
     END-IF
     IF WS-IDLE-ID(L-ROW) NOT = EN-ID(L-ROW)
         MOVE EN-ID(L-ROW) TO WS-IDLE-ID(L-ROW)
         MOVE 0 TO WS-IDLE-N(L-ROW)
     END-IF
     ADD 1 TO WS-IDLE-N(L-ROW)
     IF EN-HURT(L-ROW) > 0
         MOVE 0 TO WS-IDLE-N(L-ROW)
     END-IF
     CALL "MS6-NEAREST" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-D2F
     IF WS-D2F < 100000000000000
         MOVE 1 TO WS-HAVE
     END-IF
     COMPUTE WS-D2 = FUNCTION MIN(WS-D2F, 100000000000000)
     CALL "XORO-NEXT-INT" USING WS-STATE WS-800 WS-DRAW
     CALL "MS6-DESPAWN" USING WS-CAT WS-PERSIST WS-REMOVABLE WS-PEACEFUL WS-HAVE WS-D2 WS-IDLE-N(L-ROW) WS-DRAW WS-RESULT
     IF WS-RESULT = 1
         CALL "ENTITY-REMOVE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM MS6-DESPAWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPAWNER-NEW.
*> USING spawner (7 BINARY-LONG: spawnDelay, minSpawnDelay, maxSpawnDelay, spawnCount, maxNearbyEntities, requiredPlayerRange, spawnRange): the defaults of
*> a spawner block (6.12; 44 part 2 section 2.1): 20, 200, 800, 4, 6, 16, 4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPAWNER.
    05 L-DELAY             BINARY-LONG.
    05 L-MIN               BINARY-LONG.
    05 L-MAX               BINARY-LONG.
    05 L-COUNT             BINARY-LONG.
    05 L-NEARBY            BINARY-LONG.
    05 L-PRANGE            BINARY-LONG.
    05 L-SRANGE            BINARY-LONG.
 PROCEDURE DIVISION USING L-SPAWNER.
     MOVE 20 TO L-DELAY
     MOVE 200 TO L-MIN
     MOVE 800 TO L-MAX
     MOVE 4 TO L-COUNT
     MOVE 6 TO L-NEARBY
     MOVE 16 TO L-PRANGE
     MOVE 4 TO L-SRANGE
     GOBACK.
 END PROGRAM MS6-SPAWNER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPAWNER-ROLL.
*> USING state, spawner, delay out (BINARY-LONG): rolling a delay (6.12): minSpawnDelay + nextInt(max - min), or just the minimum when the maximum is
*> not larger.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPAN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SPAWNER.
    05 L-DELAY             BINARY-LONG.
    05 L-MIN               BINARY-LONG.
    05 L-MAX               BINARY-LONG.
    05 L-COUNT             BINARY-LONG.
    05 L-NEARBY            BINARY-LONG.
    05 L-PRANGE            BINARY-LONG.
    05 L-SRANGE            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SPAWNER L-OUT.
     MOVE L-MIN TO L-OUT
     IF L-MAX > L-MIN
         COMPUTE WS-SPAN = L-MAX - L-MIN
         CALL "XORO-NEXT-INT" USING L-STATE WS-SPAN WS-A
         ADD WS-A TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM MS6-SPAWNER-ROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPAWNER-STEP.
*> USING state, spawner, player-near (a player within requiredPlayerRange of the block centre), action out (BINARY-LONG): BaseSpawner.serverTick (6.12):
*> 0 nothing (no player in range), 3 the delay was -1 and a delay was rolled, 1 a positive delay counted down, 2 the delay is up: the caller makes
*> spawnCount attempts (MS6-SPAWNER-ATTEMPT) and, when one succeeded, rolls a delay (MS6-SPAWNER-ROLL).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SPAWNER.
    05 L-DELAY             BINARY-LONG.
    05 L-MIN               BINARY-LONG.
    05 L-MAX               BINARY-LONG.
    05 L-COUNT             BINARY-LONG.
    05 L-NEARBY            BINARY-LONG.
    05 L-PRANGE            BINARY-LONG.
    05 L-SRANGE            BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SPAWNER L-NEAR L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-NEAR = 0
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN L-DELAY = -1
             CALL "MS6-SPAWNER-ROLL" USING L-STATE L-SPAWNER L-DELAY
             MOVE 3 TO L-ACTION
         WHEN L-DELAY > 0
             SUBTRACT 1 FROM L-DELAY
             MOVE 1 TO L-ACTION
         WHEN OTHER
             MOVE 2 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM MS6-SPAWNER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPAWNER-ATTEMPT.
*> USING state, dim, key (PIC X(24), the species), block x, y, z (BINARY-LONG), spawner, success out (BINARY-LONG): one spawn attempt of a spawner (6.12): the
*> position is (bx + (nextDouble - nextDouble) x spawnRange + 0.5, by + nextInt(3) - 1, bz + ...); the box must be free (two empty cells), the rule
*> check with the reason SPAWNER must hold (so light matters for monsters and Peaceful stops them), fewer than maxNearbyEntities of that type may stand
*> within spawnRange of the block, and then the mob appears with a random yaw. A species without a mob row spawns nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-KEY48               PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-LO-X                FLOAT-LONG.
 01 WS-HI-X                FLOAT-LONG.
 01 WS-LO-Y                FLOAT-LONG.
 01 WS-HI-Y                FLOAT-LONG.
 01 WS-LO-Z                FLOAT-LONG.
 01 WS-HI-Z                FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-SPAWNER.
    05 L-DELAY             BINARY-LONG.
    05 L-MIN               BINARY-LONG.
    05 L-MAX               BINARY-LONG.
    05 L-COUNT             BINARY-LONG.
    05 L-NEARBY            BINARY-LONG.
    05 L-PRANGE            BINARY-LONG.
    05 L-SRANGE            BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-KEY L-BX L-BY L-BZ L-SPAWNER L-SUCCESS.
     MOVE 0 TO L-SUCCESS
     MOVE L-KEY TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D2
     COMPUTE WS-FX = L-BX + (WS-D1 - WS-D2) * L-SRANGE + 0.5
     CALL "XORO-NEXT-INT" USING L-STATE WS-THREE WS-A
     COMPUTE WS-IY = L-BY + WS-A - 1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D2
     COMPUTE WS-FZ = L-BZ + (WS-D1 - WS-D2) * L-SRANGE + 0.5
     COMPUTE WS-IX = FUNCTION INTEGER(WS-FX)
     COMPUTE WS-IZ = FUNCTION INTEGER(WS-FZ)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-FX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-FZ / 16)
     CALL "STDMOB-READY" USING L-DIM WS-CX WS-CZ WS-READY
     CALL "MS6-BLOCK-KIND" USING L-DIM WS-IX WS-IY WS-IZ WS-K1
     COMPUTE WS-ABOVE = WS-IY + 1
     CALL "MS6-BLOCK-KIND" USING L-DIM WS-IX WS-ABOVE WS-IZ WS-K2
     IF WS-K1 NOT = 0 OR WS-K2 NOT = 0 OR WS-READY = 0
         GOBACK
     END-IF
     CALL "MS6-RULE-AT" USING L-STATE L-DIM WS-ROW WS-IX WS-IY WS-IZ WS-REASON WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-EKEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-LO-X = L-BX - L-SRANGE
     COMPUTE WS-HI-X = L-BX + 1 + L-SRANGE
     COMPUTE WS-LO-Y = L-BY - L-SRANGE
     COMPUTE WS-HI-Y = L-BY + 1 + L-SRANGE
     COMPUTE WS-LO-Z = L-BZ - L-SRANGE
     COMPUTE WS-HI-Z = L-BZ + 1 + L-SRANGE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = L-DIM
                 AND EN-X(WS-E) >= WS-LO-X AND EN-X(WS-E) <= WS-HI-X
                 AND EN-Y(WS-E) >= WS-LO-Y AND EN-Y(WS-E) <= WS-HI-Y
                 AND EN-Z(WS-E) >= WS-LO-Z AND EN-Z(WS-E) <= WS-HI-Z
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N >= L-NEARBY
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     COMPUTE WS-YAW = WS-D1 * 360
     MOVE WS-IY TO WS-FY
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
     MOVE 1 TO L-SUCCESS
     GOBACK.
 END PROGRAM MS6-SPAWNER-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-EGG-SPAWN.
*> USING dim, key (PIC X(24), the species), x, y, z (FLOAT-LONG), row out (BINARY-LONG; 0 when the species has no mob row): a spawn egg used on a block
*> creates the mob at the position with a random yaw; no cap, light or placement check applies (6.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY48               PIC X(48).
 01 WS-SPECIES             BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW
     MOVE L-KEY TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-SPECIES
     IF WS-SPECIES > 0
         MOVE SPACES TO WS-EKEY
         STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-EKEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     END-IF
     GOBACK.
 END PROGRAM MS6-EGG-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-BIOME-AT.
*> USING dim, x, y, z (BINARY-LONG), biome row out (BINARY-LONG): the row of MOBSPAWN.cpy's biome table for the biome of the cell (the chunk's biome cell of
*> that 4 x 4 x 4 block). A biome the table does not hold (a chunk that is not loaded, or a biome of another set) uses the plains list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BIOME.
     MOVE SPACES TO WS-KEY
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK > 0
         SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
         COMPUTE WS-LX = L-X - WS-CX * 16
         COMPUTE WS-LZ = L-Z - WS-CZ * 16
         COMPUTE WS-LY = FUNCTION MIN(FUNCTION MAX(L-Y - DM-MIN-Y(L-DIM), 0), DM-HEIGHT(L-DIM) - 1)
         COMPUTE WS-INDEX = FUNCTION INTEGER(WS-LY / 16) * 64 + FUNCTION MOD(FUNCTION INTEGER(WS-LY / 4), 4) * 16
             + FUNCTION INTEGER(WS-LZ / 4) * 4 + FUNCTION INTEGER(WS-LX / 4) + 1
         MOVE CE-BIOME(WS-INDEX) TO WS-ID
         COMPUTE WS-ID = FUNCTION MIN(WS-ID, CBI-MAX - 1)
         MOVE CBI-KEY(WS-ID + 1) TO WS-KEY
     END-IF
     CALL "MS6-BIOME-FIND" USING WS-KEY L-BIOME
     IF L-BIOME = 0
         MOVE "minecraft:plains" TO WS-KEY
         CALL "MS6-BIOME-FIND" USING WS-KEY L-BIOME
     END-IF
     GOBACK.
 END PROGRAM MS6-BIOME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-COLUMN-TOP.
*> USING dim, x, z (BINARY-LONG), y out (BINARY-LONG): the height of the highest block of the column that is not air (state 0), minY - 1 when the column is all air: what
*> walking down from the top of the dimension with WORLD-GET-BLOCK finds. A loaded chunk is read straight from its cell table (one read for each cell, not a chunk lookup and the
*> coordinate arithmetic of a call: the column walk of every candidate chunk and category cost 25 ms of each tick with 289 chunks near the player); a chunk that is not loaded
*> is walked with WORLD-GET-BLOCK as before (it loads the chunk, or reads void while the generation workers will make it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-Y.
     MOVE DM-MIN-Y(L-DIM) TO WS-MINY
     COMPUTE L-Y = WS-MINY + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE-ID
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         PERFORM UNTIL WS-STATE-ID NOT = 0 OR L-Y < WS-MINY
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE-ID
             IF WS-STATE-ID = 0
                 SUBTRACT 1 FROM L-Y
             END-IF
         END-PERFORM
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (L-Y - WS-MINY) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1
     PERFORM UNTIL WS-STATE-ID NOT = 0 OR L-Y < WS-MINY
         MOVE CE-STATE(WS-CELL) TO WS-STATE-ID
         IF WS-STATE-ID = 0
             SUBTRACT 1 FROM L-Y
             SUBTRACT 256 FROM WS-CELL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-COLUMN-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-SPAWN-CHUNK.
*> USING state, dim, category, chunk x, chunk z, spawned out (BINARY-LONG): spawnCategoryForChunk (6.1, 6.4): one random position of the chunk (the column
*> is drawn from a copy of the state first so that the surface height of that column can bound y), and when y >= minY + 1 one MS6-PACK there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-SPAWNED              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-CAT L-CX L-CZ L-SPAWNED.
     MOVE 0 TO L-SPAWNED
     MOVE L-STATE TO WS-STATE
     COMPUTE WS-MINX = L-CX * 16
     COMPUTE WS-MINZ = L-CZ * 16
     MOVE DM-MIN-Y(L-DIM) TO WS-MINY
     CALL "XORO-NEXT-INT" USING WS-STATE WS-16 WS-A
     COMPUTE WS-X = WS-MINX + WS-A
     CALL "XORO-NEXT-INT" USING WS-STATE WS-16 WS-A
     COMPUTE WS-Z = WS-MINZ + WS-A
     CALL "MS6-COLUMN-TOP" USING L-DIM WS-X WS-Z WS-Y
     COMPUTE WS-TOP = WS-Y + 1
     CALL "MS6-RANDOM-POS" USING L-STATE WS-MINX WS-MINZ WS-MINY WS-TOP WS-X WS-Y WS-Z WS-OK
     IF WS-OK = 1
         CALL "MS6-BIOME-AT" USING L-DIM WS-X WS-Y WS-Z WS-BIOME
         CALL "MS6-PACK" USING L-STATE L-DIM L-CAT WS-BIOME L-CX L-CZ WS-X WS-Y WS-Z L-SPAWNED
     END-IF
     GOBACK.
 END PROGRAM MS6-SPAWN-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-CYCLE.
*> No parameters: the natural spawning tick of a standard world (6.1). For each enabled dimension with players: the non-persistent mobs are counted per category
*> (animals: creature, hostile mobs: monster) globally and for each player's local counters (6.3), the category list is filtered (MS6-CATEGORIES: spawn_mobs,
*> spawn_monsters with the hostile-mobs setting, the 400-tick friendly cycle, the global cap), and each candidate chunk (6.2: a loaded chunk within 8
*> chunks of a player, once even when two players share it) gets one MS6-SPAWN-CHUNK per eligible category (the local cap holds). To bound the work of
*> a tick the candidate chunks are dealt out over 20 ticks (a chunk is tried when its index mod 20 = Time mod 20), and the friendly cycle covers
*> the ticks with Time mod 400 below 20, so each chunk still gets one attempt per cycle of the vanilla tick, 20 ticks apart. The creature and monster categories and the water ones (5, 6, 7) are tried; ambient and axolotls have no species yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260501.
 01 WS-NAME-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-NAME-MONSTERS       PIC X(40) VALUE "spawn_monsters".
 01 WS-V                   BINARY-DOUBLE.
 01 WS-MOBS                BINARY-LONG.
 01 WS-MONSTERS            BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-SLICE               BINARY-LONG.
 01 WS-COUNTS.
    05 WS-COUNT            BINARY-LONG OCCURS 8 TIMES.
 01 WS-FLAGS.
    05 WS-FLAG             BINARY-LONG OCCURS 8 TIMES.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-PLAYERS.
    05 WS-PROW             BINARY-LONG OCCURS 64 TIMES.
    05 WS-PCX              BINARY-LONG OCCURS 64 TIMES.
    05 WS-PCZ              BINARY-LONG OCCURS 64 TIMES.
 01 WS-LOCAL.
    05 WS-LP               OCCURS 64 TIMES.
       10 WS-HAS           BINARY-LONG.
       10 WS-PC            BINARY-LONG OCCURS 8 TIMES.
 01 WS-CLOSE.
    05 WS-CP               OCCURS 64 TIMES.
       10 FILLER           BINARY-LONG.
       10 FILLER           BINARY-LONG OCCURS 8 TIMES.
 01 WS-NC                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MCX                 BINARY-LONG.
 01 WS-MCZ                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-DUP                 BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-PXF                 FLOAT-LONG.
 01 WS-PZF                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF CT-OPEN = 0 OR CT-SET-TYPE NOT = CT-TYPE-STANDARD
         GOBACK
     END-IF
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "BR-WORLD-READY"
     CALL "BR-RULE-GET" USING WS-NAME-MOBS WS-V
     MOVE WS-V TO WS-MOBS
     CALL "BR-RULE-GET" USING WS-NAME-MONSTERS WS-V
     MOVE 0 TO WS-MONSTERS
     IF WS-V = 1 AND CS-HOSTILE-MOBS = 1
         MOVE 1 TO WS-MONSTERS
     END-IF
     COMPUTE WS-SLICE = FUNCTION MOD(CW-TIME, 20)
     COMPUTE WS-TIME = CW-TIME - WS-SLICE
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         MOVE 0 TO WS-NP
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
             IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE AND PL-DIM(WS-ROW) = WS-DIM AND PL-MODE(WS-ROW) NOT = 3
                 ADD 1 TO WS-NP
                 MOVE WS-ROW TO WS-PROW(WS-NP)
                 COMPUTE WS-PCX(WS-NP) = FUNCTION INTEGER(PL-X(WS-ROW) / 16)
                 COMPUTE WS-PCZ(WS-NP) = FUNCTION INTEGER(PL-Z(WS-ROW) / 16)
             END-IF
         END-PERFORM
         INITIALIZE WS-COUNTS WS-LOCAL
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
             IF EN-USED(WS-ROW) = 1 AND EN-DIM(WS-ROW) = WS-DIM
                 CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
                 IF WS-S > 0
                     CALL "MS6-ROW-CAT" USING WS-S WS-CAT
                     ADD 1 TO WS-COUNT(WS-CAT)
                     COMPUTE WS-MCX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
                     COMPUTE WS-MCZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-NP
                         MOVE PL-X(WS-PROW(WS-P)) TO WS-PXF
                         MOVE PL-Z(WS-PROW(WS-P)) TO WS-PZF
                         CALL "MS6-CHUNK-NEAR" USING WS-PCX(WS-P) WS-PCZ(WS-P) WS-MCX WS-MCZ WS-PXF WS-PZF WS-NEAR
                         IF WS-NEAR = 1
                             MOVE 1 TO WS-HAS(WS-P)
                             ADD 1 TO WS-PC(WS-P, WS-CAT)
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
         CALL "MS6-CANDIDATE-COUNT" USING WS-DIM WS-CHUNKS
         CALL "MS6-CATEGORIES" USING WS-TIME WS-MOBS WS-MONSTERS WS-COUNTS WS-CHUNKS WS-FLAGS WS-N
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-NP
             PERFORM VARYING WS-DX FROM -8 BY 1 UNTIL WS-DX > 8
                 PERFORM VARYING WS-DZ FROM -8 BY 1 UNTIL WS-DZ > 8
                     COMPUTE WS-IDX = (WS-DX + 8) * 17 + WS-DZ + 8
                     IF FUNCTION MOD(WS-IDX, 20) = WS-SLICE
                         COMPUTE WS-CX = WS-PCX(WS-P) + WS-DX
                         COMPUTE WS-CZ = WS-PCZ(WS-P) + WS-DZ
                         MOVE 0 TO WS-DUP
                         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q >= WS-P
                             IF FUNCTION ABS(WS-CX - WS-PCX(WS-Q)) <= 8 AND FUNCTION ABS(WS-CZ - WS-PCZ(WS-Q)) <= 8
                                 MOVE 1 TO WS-DUP
                             END-IF
                         END-PERFORM
                         MOVE 0 TO WS-READY
                         IF WS-DUP = 0
                             CALL "STDMOB-READY" USING WS-DIM WS-CX WS-CZ WS-READY
                         END-IF
                         IF WS-READY = 1
                             MOVE 0 TO WS-NC
                             PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-NP
                                 MOVE PL-X(WS-PROW(WS-Q)) TO WS-PXF
                                 MOVE PL-Z(WS-PROW(WS-Q)) TO WS-PZF
                                 CALL "MS6-CHUNK-NEAR" USING WS-PCX(WS-Q) WS-PCZ(WS-Q) WS-CX WS-CZ WS-PXF WS-PZF WS-NEAR
                                 IF WS-NEAR = 1
                                     ADD 1 TO WS-NC
                                     MOVE WS-LP(WS-Q) TO WS-CP(WS-NC)
                                 END-IF
                             END-PERFORM
                             PERFORM VARYING WS-CAT FROM 1 BY 1 UNTIL WS-CAT > 7
                                 IF WS-FLAG(WS-CAT) = 1 AND WS-CAT NOT = 3 AND WS-CAT NOT = 4
                                     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-NC WS-CLOSE WS-OK
                                     IF WS-OK = 1
                                         CALL "MS6-SPAWN-CHUNK" USING WS-STATE WS-DIM WS-CAT WS-CX WS-CZ WS-SPAWNED
                                         ADD WS-SPAWNED TO WS-COUNT(WS-CAT)
                                     END-IF
                                 END-IF
                             END-PERFORM
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MS6-CYCLE.
