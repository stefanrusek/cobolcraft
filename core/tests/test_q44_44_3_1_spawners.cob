*> Test of 44 part 3 sections 1.6 and 1.7 (lane 002-lane-p49h, T22001): the cat spawner (counter, offsets, village case counts, worked example 3) and the zombie village siege (Mth.sin and cos
*> table, the ring offset, worked example 2, roll, setup, the 3-tick spawn beat).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-1-SPAWNERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY VILPOIX.
 COPY VILPOI.
 COPY Q3STATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 112.
 01 WS-KIND-FLOOR          BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-KIND-BED            BINARY-LONG VALUE 1.
 01 WS-OWNER               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:cat".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-ZKEY                PIC X(112) VALUE "minecraft:zombie".
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-R48                 BINARY-LONG VALUE 48.
 01 WS-R8                  BINARY-LONG VALUE 8.
 01 WS-R8-B                BINARY-LONG VALUE 8.
 01 WS-R8-C                BINARY-LONG VALUE 8.
 01 WS-R64                 BINARY-LONG VALUE 64.
 01 WS-R64-B               BINARY-LONG VALUE 64.
 01 WS-R64-C               BINARY-LONG VALUE 64.
 01 WS-R32                 BINARY-LONG VALUE 32.
 01 WS-XA                  BINARY-LONG.
 01 WS-XN                  BINARY-LONG.
 01 WS-ZA                  BINARY-LONG.
 01 WS-ZN                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE-B               BINARY-LONG VALUE 1.
 01 WS-ZERO-B              BINARY-LONG VALUE 0.
 01 WS-ZERO-C              BINARY-LONG VALUE 0.
 01 WS-ZERO-D              BINARY-LONG VALUE 0.
 01 WS-R48-B               BINARY-LONG VALUE 48.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FIVE-B              BINARY-LONG VALUE 5.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-ANGLE               FLOAT-SHORT VALUE 1.5707964.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY112              PIC X(112) VALUE "minecraft:red_bed".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY - 1
     COMPUTE WS-X0 = WS-PX - 56
     COMPUTE WS-Z0 = WS-PZ - 56
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND-FLOOR
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CAT WS-ENTITY-ROW WS-STATUS
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-ZKEY WS-ZOMBIE WS-ENTITY-ROW WS-STATUS
*>   The sine table (1.7a): entry 16384 is exactly 1.0, entry 32768 is the sine of the double nearest pi, tiny and positive.
     MOVE 1.5707963705062866 TO WS-A
     CALL "Q3-MTH-SIN" USING WS-A WS-S
     MOVE "acceptance US15 44-3§1 Villages 1.7a sin of 1.5707963705062866 reads entry 16384: exactly 1.0" TO WS-CASE
     MOVE 1000000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-S * 1000000)
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-MTH-COS" USING WS-A WS-S
     MOVE "acceptance US15 44-3§1 Villages 1.7a cos of it reads entry 32768: about +1.2e-16, positive and tiny" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-S > 0 AND WS-S < 0.000000001
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-SIEGE-OFFSET" USING WS-ANGLE WS-OX WS-OZ
     MOVE "acceptance US15 44-3§1 Villages worked 2 the angle 0.25 * 2 pi gives spawnX = px (floor of 3.9e-15 is 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OX TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§1 Villages worked 2 and spawnZ = pz + 32" TO WS-CASE
     MOVE 32 TO WS-E
     MOVE WS-OZ TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 3.1415927 TO WS-ANGLE
     CALL "Q3-SIEGE-OFFSET" USING WS-ANGLE WS-OX WS-OZ
     MOVE "acceptance US15 44-3§1 Villages 1.7 the angle pi gives -32 on x" TO WS-CASE
     MOVE -32 TO WS-E
     MOVE WS-OX TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Cat spawner: the action of step 4.
     MOVE 1 TO WS-N
     CALL "Q3-CAT-DECIDE" USING WS-ONE WS-SIX WS-THREE WS-ZERO WS-ZERO-B WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 village case: 6 homes and 3 cats spawns a cat" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-DECIDE" USING WS-ONE WS-FOUR WS-THREE WS-ZERO WS-ZERO-B WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 village case needs more than 4 homes: 4 does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-DECIDE" USING WS-ONE WS-FIVE WS-FIVE-B WS-ZERO WS-ZERO-B WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 and fewer than 5 cats: 5 does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-DECIDE" USING WS-ZERO WS-ZERO-B WS-ZERO-C WS-ONE WS-ZERO-D WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 hut case: no cat in the (16, 8, 16) box spawns a persistent cat" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-DECIDE" USING WS-ZERO WS-ZERO-B WS-ZERO-C WS-ONE WS-ONE-B WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 hut case: a cat in the box stops it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-DECIDE" USING WS-ZERO WS-SIX WS-ZERO-B WS-ZERO-C WS-ZERO-D WS-ACTION
     MOVE "acceptance US15 44-3§1 Villages 1.6 outside both cases nothing spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Worked example 3: offsets x = +17 (amount 9), z = -21 (amount 13, sign true), 6 occupied homes within 48, 3 cats in the box.
     INITIALIZE PX-STATE
     INITIALIZE PO-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-BX = WS-PX + 17 + WS-I
         COMPUTE WS-BZ = WS-PZ - 21
         CALL "PXI-ADD" USING WS-DIM WS-BX WS-PY WS-BZ WS-KIND-BED
         COMPUTE WS-OWNER = 900000 + WS-I
         CALL "VPX-CLAIM" USING WS-OWNER WS-HOME WS-DIM WS-BX WS-PY WS-BZ
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FX = WS-PX + 17.5
         MOVE WS-PY TO WS-FY2
         COMPUTE WS-FZ = WS-PZ - 20.5
         CALL "MOB-SPAWN" USING WS-DIM WS-CAT WS-FX WS-FY2 WS-FZ WS-YAW WS-ROW
     END-PERFORM
     MOVE 9 TO WS-XA
     MOVE 0 TO WS-XN
     MOVE 13 TO WS-ZA
     MOVE 1 TO WS-ZN
     CALL "Q3-CAT-ATTEMPT" USING WS-PLAYER WS-XA WS-XN WS-ZA WS-ZN WS-RESULT
     MOVE "acceptance US15 44-3§1 Villages worked 3 the cat is spawned (result 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RESULT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     COMPUTE WS-BX = WS-PX + 17
     COMPUTE WS-BZ = WS-PZ - 21
     CALL "Q3-COUNT-TYPE-IN-BOX" USING WS-DIM WS-CAT WS-BX WS-PY WS-BZ WS-R48 WS-R8 WS-R48-B WS-N
     MOVE "acceptance US15 44-3§1 Villages worked 3 four cats are in the box now" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "MOB-SPAWN" USING WS-DIM WS-CAT WS-FX WS-FY2 WS-FZ WS-YAW WS-ROW
     CALL "Q3-CAT-ATTEMPT" USING WS-PLAYER WS-XA WS-XN WS-ZA WS-ZN WS-RESULT
     MOVE "acceptance US15 44-3§1 Villages 1.6 with 5 cats in the box no cat is spawned (result 3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-RESULT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-COUNT-TYPE-IN-BOX" USING WS-DIM WS-CAT WS-BX WS-PY WS-BZ WS-R48 WS-R8 WS-R48-B WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.6 and the count stays 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   A position over a block is not ok for a cat: the offset x = +8 into the floor-free column above.
     MOVE 0 TO WS-XA
     MOVE 0 TO WS-ZA
     MOVE 0 TO WS-XN
     MOVE 0 TO WS-ZN
     MOVE 0 TO WS-I
     CALL "Q3-CAT-ATTEMPT" USING WS-PLAYER WS-XA WS-XN WS-ZA WS-ZN WS-RESULT
     MOVE "acceptance US15 44-3§1 Villages 1.6 an offset of 8 in a village with 5 cats is no spawn (result 3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-RESULT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     COMPUTE WS-BY = WS-PY + 5
     MOVE "minecraft:stone" TO WS-KEY112
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     COMPUTE WS-BX = WS-PX + 8
     COMPUTE WS-BZ = WS-PZ + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-BZ WS-STATE
     CALL "Q3-CAT-ATTEMPT" USING WS-PLAYER WS-XA WS-XN WS-ZA WS-ZN WS-RESULT
     MOVE "acceptance US15 44-3§1 Villages 1.6 a solid block at the position fails the placement check (result 2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-RESULT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   The counter: the first call runs at once and sets 1200, then it counts down.
     MOVE 0 TO Q3-CAT-NEXT
     CALL "Q3-CAT-TICK"
     MOVE "acceptance US15 44-3§1 Villages 1.6 the first call sets the counter to 1200" TO WS-CASE
     MOVE 1200 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CAT-TICK"
     MOVE "acceptance US15 44-3§1 Villages 1.6 the next call only counts down (1199)" TO WS-CASE
     MOVE 1199 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 1 TO Q3-CAT-NEXT
     CALL "Q3-CAT-TICK"
     MOVE "acceptance US15 44-3§1 Villages 1.6 a counter that reaches 0 runs the attempt and is set again (1200)" TO WS-CASE
     MOVE 1200 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Siege: two villages, one at the player (so the player stands in a village) and one 20 blocks south of it.
     INITIALIZE PX-STATE
     INITIALIZE PO-STATE
     INITIALIZE Q3-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-PY WS-BZ WS-ZERO
     MOVE 9 TO WS-OWNER
     CALL "PXI-ADD" USING WS-DIM WS-PX WS-PY WS-PZ WS-KIND-BED
     CALL "VPX-CLAIM" USING WS-OWNER WS-HOME WS-DIM WS-PX WS-PY WS-PZ
     COMPUTE WS-BZ = WS-PZ + 20
     MOVE 10 TO WS-OWNER
     CALL "PXI-ADD" USING WS-DIM WS-PX WS-PY WS-BZ WS-KIND-BED
     CALL "VPX-CLAIM" USING WS-OWNER WS-HOME WS-DIM WS-PX WS-PY WS-BZ
     MOVE 2 TO BW-DIFFICULTY
     MOVE 6000 TO CW-TIME
     MOVE 1 TO Q3-SG-STATE
     MOVE 1 TO Q3-SG-SETUP
     MOVE -1 TO WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 1: by day the siege is done and not set up" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = Q3-SG-STATE + Q3-SG-SETUP
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 18000 TO CW-TIME
     MOVE 0 TO BW-DIFFICULTY
     MOVE 1 TO Q3-SG-STATE
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 1: with no enemies (Peaceful) the siege is done" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE Q3-SG-STATE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 2 TO BW-DIFFICULTY
     MOVE 5 TO WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 2: at day tick 18000 a roll other than 0 leaves it done" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE Q3-SG-STATE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 2: roll 0 makes it SIEGE_TONIGHT" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE Q3-SG-STATE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 4: the setup succeeds with a village at the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE Q3-SG-SETUP TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 5: the first tick has nextSpawnTime 0, so it sets 2 and spawns one of the 20 zombies" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE Q3-SG-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 5: 19 zombies are left (the counter drops even when no spot is found)" TO WS-CASE
     MOVE 19 TO WS-E
     MOVE Q3-SG-ZOMBIES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§1 Villages 1.7 setup: the centre is on the 32 ring, one of 10 attempts, in the same dimension" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF Q3-SG-DIM = WS-DIM AND FUNCTION ABS(Q3-SG-X - WS-PX) <= 32 AND FUNCTION ABS(Q3-SG-Z - WS-PZ) <= 32
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 18001 TO CW-TIME
     MOVE -1 TO WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 5: nextSpawnTime counts down 2 -> 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE Q3-SG-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 the third tick after a spawn spawns the next: 18 left (one per 3 ticks)" TO WS-CASE
     MOVE 18 TO WS-E
     MOVE Q3-SG-ZOMBIES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   4b / 4c: with the centre on a village in loaded chunks (20 blocks away: the 32 ring is outside the view of this world), the zombies appear within +-8 of it, inside the village cubes.
     MOVE WS-DIM TO Q3-SG-DIM
     MOVE WS-PX TO Q3-SG-X
     MOVE WS-PY TO Q3-SG-Y
     COMPUTE Q3-SG-Z = WS-PZ + 20
     MOVE 20 TO Q3-SG-ZOMBIES
     MOVE 0 TO Q3-SG-NEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "Q3-SIEGE-TICK" USING WS-ROLL
     END-PERFORM
     MOVE "acceptance US15 44-3§1 Villages 1.7 in 60 ticks the counter went 20 -> 0 (one per 3 ticks)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE Q3-SG-ZOMBIES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-COUNT-TYPE-IN-BOX" USING WS-DIM WS-ZOMBIE WS-PX WS-PY WS-PZ WS-R64 WS-R64-B WS-R64-C WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.7 4b: zombies stand in the world (at least one found a spot)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N > 0 AND WS-N <= 21
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE Q3-SG-X TO WS-BX
     MOVE Q3-SG-Z TO WS-BZ
     CALL "Q3-COUNT-TYPE-IN-BOX" USING WS-DIM WS-ZOMBIE WS-BX WS-PY WS-BZ WS-R8 WS-R8-B WS-R8-C WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.7 4c: the zombies of the 20 beats stand within +-8 of the centre (15 or more of them)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N >= 15
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 1 TO Q3-SG-NEXT
     MOVE 0 TO Q3-SG-ZOMBIES
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 5: with no zombies left the siege is done" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE Q3-SG-STATE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Setup fails without a village at the player.
     INITIALIZE PX-STATE
     INITIALIZE PO-STATE
     INITIALIZE Q3-STATE
     MOVE 18000 TO CW-TIME
     MOVE 0 TO WS-ROLL
     CALL "Q3-SIEGE-TICK" USING WS-ROLL
     MOVE "acceptance US15 44-3§1 Villages 1.7 step 4: a player outside a village makes the setup fail, no zombies" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = Q3-SG-SETUP + Q3-SG-ZOMBIES
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Step 3: an offset of 31 blocks puts the +-10 block corners beyond the loaded chunks (view distance 2): result 1.
     MOVE 23 TO WS-XA
     MOVE 0 TO WS-XN
     MOVE 23 TO WS-ZA
     MOVE 0 TO WS-ZN
     MOVE PL-X(WS-PLAYER) TO WS-FX
     COMPUTE PL-X(WS-PLAYER) = WS-FX + 4000
     CALL "Q3-CAT-ATTEMPT" USING WS-PLAYER WS-XA WS-XN WS-ZA WS-ZN WS-RESULT
     MOVE WS-FX TO PL-X(WS-PLAYER)
     MOVE "acceptance US15 44-3§1 Villages 1.6 step 3: a player far from every loaded chunk, the chunks round the position that are not loaded end the attempt (result 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-RESULT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Step 2: no player in the world ends the attempt (the counter is still set to 1200).
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-ROW
     MOVE 0 TO PL-ENTITY-ROW(WS-PLAYER)
     MOVE 1 TO Q3-CAT-NEXT
     CALL "Q3-CAT-TICK"
     MOVE WS-ROW TO PL-ENTITY-ROW(WS-PLAYER)
     MOVE "acceptance US15 44-3§1 Villages 1.6 step 2: without a player the counter is still reset to 1200" TO WS-CASE
     MOVE 1200 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   The world hook runs the cat spawner and, at day tick 18000, rolls the siege (nextInt(10)); at other ticks it passes no roll.
     MOVE 5 TO Q3-CAT-NEXT
     MOVE 18000 TO CW-TIME
     INITIALIZE Q3-SG-STATE Q3-SG-SETUP Q3-SG-ZOMBIES Q3-SG-NEXT
     CALL "Q3-SPAWNERS-TICK"
     MOVE "acceptance US15 44-3§1 Villages 1.6 the hook counts the cat spawner down (4)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 6000 TO CW-TIME
     CALL "Q3-SPAWNERS-TICK"
     MOVE "acceptance US15 44-3§1 Villages 1.6 and again at another time of day (3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE Q3-CAT-NEXT TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-1-SPAWNERS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
