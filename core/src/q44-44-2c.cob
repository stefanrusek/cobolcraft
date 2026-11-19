*> The custom spawners of the Overworld (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 6 and 13; 44-3 sections 1.6 and 1.7; lane 002-lane-p49g). State: CUSTOMSP.cpy.
*>
*> Entry points:
*>   CUSTOM-SPAWNERS-TICK            ServerChunkCache.tickCustomSpawners (called once a tick by STDMOB-SPAWN-TICK): nothing runs when spawn_mobs is false; spawnEnemies is spawn_mobs and
*>     spawn_monsters (and the hostile mobs setting); the five spawners then run in this order: 1 phantom (spawnEnemies and spawn_phantoms), 2 patrol (spawnEnemies and spawn_patrols), 3 cat
*>     (no gate), 4 village siege (spawnEnemies, false resets it), 5 wandering trader (spawn_wandering_traders)
*>   CAT-SPAWNER-TICK                CatSpawner (44-3 1.6): every 1200 calls a random player's neighbourhood (8 to 31 blocks each way) is tried for one cat
*>   SIEGE-TICK USING spawnEnemies   VillageSiege (44-3 1.7): one night in ten, 20 zombies from a ring 32 blocks out of a player standing in a village
*>   SPW-NEXT-BOOL, SPW-NEXT-FLOAT USING state (XORO), value out    RandomSource.nextBoolean (the top bit of nextLong) and nextFloat (nextLong >>> 40 over 2^24)
*>   SPW-VILLAGE-NEAR USING dim, x, y, z, sections, yes out    isCloseToVillage(pos, sections): a village point of interest (a bed, a bell or a job site) lies within that many sections
*>     (Chebyshev) of the position's section
*>   SPW-SURFACE USING dim, x, z, y hint, y out    the WORLD_SURFACE height of the column, found by a scan from 48 above the hint down (the core keeps no heightmap)
*>   MTH-SIN, MTH-COS USING angle (FLOAT-LONG), value out (FLOAT-LONG)    Mth.sin and Mth.cos (44-3 1.7a): the entry of a 65536 table (the sine of i / 10430.378350470453 as a float)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-NEXT-BOOL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-HALF                BINARY-DOUBLE UNSIGNED VALUE 9223372036854775808.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-VALUE.
     CALL "XORO-NEXT-LONG" USING L-STATE WS-LONG
     MOVE 0 TO L-VALUE
     IF WS-LONG >= WS-HALF
         MOVE 1 TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM SPW-NEXT-BOOL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-NEXT-FLOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-BITS                BINARY-DOUBLE UNSIGNED.
 01 WS-N40                 BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-VALUE.
     CALL "XORO-NEXT-LONG" USING L-STATE WS-LONG
     CALL STATIC "cc_u64_shr" USING BY REFERENCE WS-LONG WS-N40 WS-BITS
     COMPUTE L-VALUE = WS-BITS / 16777216
     GOBACK.
 END PROGRAM SPW-NEXT-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MTH-SIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 10430.378350470453.
 01 WS-IDX                 BINARY-DOUBLE.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-F                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-VALUE.
     COMPUTE WS-IDX = FUNCTION INTEGER-PART(L-X * WS-SCALE)
     COMPUTE WS-IDX = FUNCTION MOD(WS-IDX, 65536)
     COMPUTE WS-ANGLE = WS-IDX / WS-SCALE
     COMPUTE WS-F = FUNCTION SIN(WS-ANGLE)
     MOVE WS-F TO L-VALUE
     GOBACK.
 END PROGRAM MTH-SIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MTH-COS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCALE               FLOAT-LONG VALUE 10430.378350470453.
 01 WS-IDX                 BINARY-DOUBLE.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-F                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-VALUE.
     COMPUTE WS-IDX = FUNCTION INTEGER-PART(L-X * WS-SCALE + 16384.0)
     COMPUTE WS-IDX = FUNCTION MOD(WS-IDX, 65536)
     COMPUTE WS-ANGLE = WS-IDX / WS-SCALE
     COMPUTE WS-F = FUNCTION SIN(WS-ANGLE)
     MOVE WS-F TO L-VALUE
     GOBACK.
 END PROGRAM MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-VILLAGE-NEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SECTIONS             BINARY-LONG.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SECTIONS L-YES.
     MOVE 0 TO L-YES
     COMPUTE WS-SX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(L-Y / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX OR L-YES = 1
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = L-DIM
             COMPUTE WS-EX = FUNCTION INTEGER(PX-X(WS-I) / 16) - WS-SX
             COMPUTE WS-EY = FUNCTION INTEGER(PX-Y(WS-I) / 16) - WS-SY
             COMPUTE WS-EZ = FUNCTION INTEGER(PX-Z(WS-I) / 16) - WS-SZ
             IF FUNCTION ABS(WS-EX) <= L-SECTIONS AND FUNCTION ABS(WS-EY) <= L-SECTIONS AND FUNCTION ABS(WS-EZ) <= L-SECTIONS
                 MOVE 1 TO L-YES
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPW-VILLAGE-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HINT                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-HINT L-Y.
     COMPUTE WS-LOW = L-HINT - 96
     COMPUTE WS-Y = L-HINT + 48
     MOVE WS-LOW TO L-Y
     PERFORM UNTIL WS-Y < WS-LOW
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
         IF WS-STATE NOT = 0
             COMPUTE L-Y = WS-Y + 1
             MOVE WS-LOW TO WS-Y
             SUBTRACT 1 FROM WS-Y
         ELSE
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPW-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-CATS-NEAR.
*> USING dim, x, y, z (the block), reach x, reach y (BINARY-LONG), count out: the cats whose position lies in the box of the block inflated by (reach x, reach y, reach x).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:cat".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RX L-RY L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X0 = L-X - L-RX
     COMPUTE WS-X1 = L-X + 1 + L-RX
     COMPUTE WS-Y0 = L-Y - L-RY
     COMPUTE WS-Y1 = L-Y + 1 + L-RY
     COMPUTE WS-Z0 = L-Z - L-RX
     COMPUTE WS-Z1 = L-Z + 1 + L-RX
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = L-DIM
                 AND EN-X(WS-E) >= WS-X0 AND EN-X(WS-E) <= WS-X1 AND EN-Y(WS-E) >= WS-Y0 AND EN-Y(WS-E) <= WS-Y1
                 AND EN-Z(WS-E) >= WS-Z0 AND EN-Z(WS-E) <= WS-Z1
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPW-CATS-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPW-RANDOM-PLAYER.
*> USING state (XORO), player row out (0 none): ServerLevel.getRandomPlayer for the Overworld spawners: one nextInt(n) over the alive players of the Overworld (not the Nether or the End), in row order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-P                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     MOVE 0 TO L-ROW WS-N
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) NOT = DIM-STANDARD-NETHER AND PL-DIM(WS-P) NOT = DIM-STANDARD-END
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N > 0
         CALL "XORO-NEXT-INT" USING L-STATE WS-N WS-PICK
         MOVE 0 TO WS-K
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) NOT = DIM-STANDARD-NETHER AND PL-DIM(WS-P) NOT = DIM-STANDARD-END
                 IF WS-K = WS-PICK
                     MOVE WS-P TO L-ROW
                 END-IF
                 ADD 1 TO WS-K
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SPW-RANDOM-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-SPAWNER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CUSTOMSP.
 COPY VILPOI.
 COPY STRUCTOVR.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260614.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-24                  BINARY-LONG VALUE 24.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CX1                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-CZ1                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-HOMES               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-R48                 BINARY-LONG VALUE 48.
 01 WS-R16                 BINARY-LONG VALUE 16.
 01 WS-R8                  BINARY-LONG VALUE 8.
 01 WS-CATS                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-SPAWN               BINARY-LONG.
 01 WS-PERSIST             BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:cat".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 PROCEDURE DIVISION.
     SUBTRACT 1 FROM CSP-CAT-NEXT
     IF CSP-CAT-NEXT > 0
         GOBACK
     END-IF
     MOVE 1200 TO CSP-CAT-NEXT
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "SPW-RANDOM-PLAYER" USING WS-STATE WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
*>   the offsets: x amount, x sign, z amount, z sign (a true sign is -1)
     CALL "XORO-NEXT-INT" USING WS-STATE WS-24 WS-A
     COMPUTE WS-DX = 8 + WS-A
     CALL "SPW-NEXT-BOOL" USING WS-STATE WS-S
     IF WS-S = 1
         COMPUTE WS-DX = - WS-DX
     END-IF
     CALL "XORO-NEXT-INT" USING WS-STATE WS-24 WS-A
     COMPUTE WS-DZ = 8 + WS-A
     CALL "SPW-NEXT-BOOL" USING WS-STATE WS-S
     IF WS-S = 1
         COMPUTE WS-DZ = - WS-DZ
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + WS-DX
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW)) + WS-DZ
*>   the chunks within 10 blocks of the position must be loaded
     COMPUTE WS-X = WS-BX - 10
     COMPUTE WS-CX0 = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-X = WS-BX + 10
     COMPUTE WS-CX1 = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-Z = WS-BZ - 10
     COMPUTE WS-CZ0 = FUNCTION INTEGER(WS-Z / 16)
     COMPUTE WS-Z = WS-BZ + 10
     COMPUTE WS-CZ1 = FUNCTION INTEGER(WS-Z / 16)
     MOVE 1 TO WS-ALL
     PERFORM VARYING WS-CX FROM WS-CX0 BY 1 UNTIL WS-CX > WS-CX1
         PERFORM VARYING WS-CZ FROM WS-CZ0 BY 1 UNTIL WS-CZ > WS-CZ1
             CALL "STDMOB-READY" USING PL-DIM(WS-ROW) WS-CX WS-CZ WS-READY
             IF WS-READY = 0
                 MOVE 0 TO WS-ALL
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-ALL = 0
         GOBACK
     END-IF
     CALL "MS6-PLACEMENT-OK" USING WS-ONE PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SPAWN WS-PERSIST
     CALL "SPW-VILLAGE-NEAR" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-TWO WS-NEAR
     IF WS-NEAR = 1
*>       the village case: more than 4 occupied home points of interest within 48 blocks and fewer than 5 cats in the (48, 8, 48) box
         MOVE 0 TO WS-HOMES
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
             IF PO-OWNER(WS-I) > 0 AND PO-KIND(WS-I) = 2 AND PO-DIM(WS-I) = PL-DIM(WS-ROW)
                 COMPUTE WS-D2 = (PO-X(WS-I) - WS-BX) * (PO-X(WS-I) - WS-BX) + (PO-Y(WS-I) - WS-BY) * (PO-Y(WS-I) - WS-BY)
                     + (PO-Z(WS-I) - WS-BZ) * (PO-Z(WS-I) - WS-BZ)
                 IF WS-D2 <= 2304
                     ADD 1 TO WS-HOMES
                 END-IF
             END-IF
         END-PERFORM
         CALL "SPW-CATS-NEAR" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-R48 WS-R8 WS-CATS
         IF WS-HOMES > 4 AND WS-CATS < 5
             MOVE 1 TO WS-SPAWN
         END-IF
     ELSE
*>       the hut case: a piece of a swamp hut holds the position and no cat is within (16, 8, 16): the cat is persistent
         CALL "SO-LOOKUP" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-TWO WS-LIST
         IF WS-LIST > 0
             IF SO-L-KIND(WS-LIST) = 4
                 CALL "SPW-CATS-NEAR" USING PL-DIM(WS-ROW) WS-BX WS-BY WS-BZ WS-R16 WS-R8 WS-CATS
                 IF WS-CATS = 0
                     MOVE 1 TO WS-SPAWN
                     MOVE 1 TO WS-PERSIST
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-SPAWN = 1
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-FX = WS-BX + 0.5
         MOVE WS-BY TO WS-FY
         COMPUTE WS-FZ = WS-BZ + 0.5
         CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
         CALL "STDMOB-FINALIZE" USING WS-STATE WS-NEW
         MOVE WS-PERSIST TO EN-PERSISTENT(WS-NEW)
     END-IF
     GOBACK.
 END PROGRAM CAT-SPAWNER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIEGE-FIND-POS.
*> USING state (XORO), dim, centre x, y, z, found out, x, y, z out: findRandomSpawnPos (44-3 1.7 4c): up to 10 attempts, each x = centre x + nextInt(16) - 8, z likewise, y the surface height
*> of the column; the cell must be in a village (one section) and the zombie's spawn rule for the reason EVENT must hold (MS6-RULE-AT with the natural reason: the monster light test and the floor
*> test); the result is the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-16                  BINARY-LONG VALUE 16.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-KEY48               PIC X(48) VALUE "zombie".
 01 WS-ROW                 BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-CX L-CY L-CZ L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 10 OR L-FOUND = 1
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
         COMPUTE WS-X = L-CX + WS-A - 8
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-A
         COMPUTE WS-Z = L-CZ + WS-A - 8
         CALL "SPW-SURFACE" USING L-DIM WS-X WS-Z L-CY WS-Y
         CALL "RAID-IS-VILLAGE" USING L-DIM WS-X WS-Y WS-Z WS-YES
         IF WS-YES = 1
             CALL "MS6-RULE-AT" USING L-STATE L-DIM WS-ROW WS-X WS-Y WS-Z WS-REASON WS-OK
             IF WS-OK = 1
                 MOVE 1 TO L-FOUND
                 MOVE WS-X TO L-X
                 MOVE WS-Y TO L-Y
                 MOVE WS-Z TO L-Z
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SIEGE-FIND-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIEGE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CUSTOMSP.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260615.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-A                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-MUSH                BINARY-LONG.
 01 WS-BIOME-KEY           PIC X(48) VALUE "minecraft:mushroom_fields".
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-TWO-PI              FLOAT-LONG VALUE 6.2831855.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:zombie".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENEMIES              BINARY-LONG.
 PROCEDURE DIVISION USING L-ENEMIES.
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
     IF WS-DARKEN < 4 OR L-ENEMIES = 0
         MOVE 0 TO CSP-SG-STATE CSP-SG-SETUP
         GOBACK
     END-IF
     IF FUNCTION MOD(CW-TIME, 24000) = 18000
         CALL "XORO-NEXT-INT" USING WS-STATE WS-TEN WS-A
         MOVE 0 TO CSP-SG-STATE
         IF WS-A = 0
             MOVE 1 TO CSP-SG-STATE
         END-IF
     END-IF
     IF CSP-SG-STATE = 0
         GOBACK
     END-IF
     IF CSP-SG-SETUP = 0
*>       the setup (4a): each player in order that is not a spectator and stands in a village outside a mushroom fields biome gets up to 10 attempts
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR WS-DONE = 1
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3
                 COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-P))
                 COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-P))
                 COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-P))
                 CALL "RAID-IS-VILLAGE" USING PL-DIM(WS-P) WS-BX WS-BY WS-BZ WS-YES
                 CALL "MS6-BIOME-AT" USING PL-DIM(WS-P) WS-BX WS-BY WS-BZ WS-BIOME
                 CALL "MS6-BIOME-FIND" USING WS-BIOME-KEY WS-MUSH
                 IF WS-YES = 1 AND WS-BIOME NOT = WS-MUSH
                     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 10 OR WS-DONE = 1
                         CALL "SPW-NEXT-FLOAT" USING WS-STATE WS-F
                         COMPUTE WS-ANGLE = WS-F * WS-TWO-PI
                         CALL "MTH-COS" USING WS-ANGLE WS-COS
                         CALL "MTH-SIN" USING WS-ANGLE WS-SIN
                         COMPUTE WS-SX = FUNCTION INTEGER(WS-COS * 32) + WS-BX
                         MOVE WS-BY TO WS-SY
                         COMPUTE WS-SZ = FUNCTION INTEGER(WS-SIN * 32) + WS-BZ
                         CALL "SIEGE-FIND-POS" USING WS-STATE PL-DIM(WS-P) WS-SX WS-SY WS-SZ WS-FOUND WS-X WS-Y WS-Z
                         IF WS-FOUND = 1
                             MOVE 0 TO CSP-SG-NEXT
                             MOVE 20 TO CSP-SG-ZOMBIES
                             MOVE WS-SX TO CSP-SG-X
                             MOVE WS-SY TO CSP-SG-Y
                             MOVE WS-SZ TO CSP-SG-Z
                             MOVE PL-DIM(WS-P) TO WS-DIM
                             MOVE 1 TO WS-DONE
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
         IF WS-DONE = 0
             GOBACK
         END-IF
         MOVE 1 TO CSP-SG-SETUP
     END-IF
     IF CSP-SG-NEXT > 0
         SUBTRACT 1 FROM CSP-SG-NEXT
         GOBACK
     END-IF
     MOVE 2 TO CSP-SG-NEXT
     IF CSP-SG-ZOMBIES > 0
         CALL "SIEGE-FIND-POS" USING WS-STATE WS-DIM CSP-SG-X CSP-SG-Y CSP-SG-Z WS-FOUND WS-X WS-Y WS-Z
         IF WS-FOUND = 1
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
             COMPUTE WS-FX = WS-X + 0.5
             MOVE WS-Y TO WS-FY
             COMPUTE WS-FZ = WS-Z + 0.5
             CALL "SPW-NEXT-FLOAT" USING WS-STATE WS-D
             COMPUTE WS-YAW = WS-D * 360
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
             CALL "STDMOB-FINALIZE" USING WS-STATE WS-NEW
         END-IF
         SUBTRACT 1 FROM CSP-SG-ZOMBIES
     ELSE
         MOVE 0 TO CSP-SG-STATE
     END-IF
     GOBACK.
 END PROGRAM SIEGE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSTOM-SPAWNERS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RULE-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-RULE-MONSTERS       PIC X(40) VALUE "spawn_monsters".
 01 WS-RULE-PHANTOMS       PIC X(40) VALUE "spawn_phantoms".
 01 WS-V                   BINARY-DOUBLE.
 01 WS-ENEMIES             BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "BR-RULE-GET" USING WS-RULE-MOBS WS-V
     IF WS-V = 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-MONSTERS WS-V
     MOVE 0 TO WS-ENEMIES
     IF WS-V = 1 AND CS-HOSTILE-MOBS = 1
         MOVE 1 TO WS-ENEMIES
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-PHANTOMS WS-V
     IF WS-ENEMIES = 1 AND WS-V = 1
         CALL "STDMOB-PHANTOM-SPAWNER"
     END-IF
     IF WS-ENEMIES = 1
         CALL "PATROL-TICK"
     END-IF
     CALL "CAT-SPAWNER-TICK"
     CALL "SIEGE-TICK" USING WS-ENEMIES
     CALL "TRADER-TICK"
     GOBACK.
 END PROGRAM CUSTOM-SPAWNERS-TICK.
