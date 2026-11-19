*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.12, with doc 44 part 1 section 4 and part 2 sections 2 and 5): spawn eggs, spawner blocks and trial spawners.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 COPY BRWORLD.
 COPY GAMEEVENT.
 01 WS-GE0               BINARY-DOUBLE.
 01 WS-GLOG              BINARY-LONG.
 01 WS-GSRC              BINARY-LONG.
 01 WS-GX                FLOAT-LONG.
 01 WS-GY                FLOAT-LONG.
 01 WS-GZ                FLOAT-LONG.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-SPAWNER.
    05 WS-DELAY             BINARY-LONG.
    05 WS-MIN               BINARY-LONG.
    05 WS-MAX               BINARY-LONG.
    05 WS-COUNT             BINARY-LONG.
    05 WS-NEARBY            BINARY-LONG.
    05 WS-PRANGE            BINARY-LONG.
    05 WS-SRANGE            BINARY-LONG.
 01 WS-NEAR              BINARY-LONG.
 01 WS-ACTION            BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-PLAYER            BINARY-LONG.
 01 WS-DIM               BINARY-LONG.
 01 WS-BX                BINARY-LONG.
 01 WS-BY                BINARY-LONG.
 01 WS-BZ                BINARY-LONG.
 01 WS-X0                BINARY-LONG.
 01 WS-Z0                BINARY-LONG.
 01 WS-SIZE              BINARY-LONG VALUE 24.
 01 WS-KIND              BINARY-LONG VALUE 1.
 01 WS-FY                BINARY-LONG.
 01 WS-OK                BINARY-LONG.
 01 WS-WINS              BINARY-LONG.
 01 WS-KEY               PIC X(24).
 01 WS-EKEY              PIC X(112).
 01 WS-TYPE              BINARY-LONG.
 01 WS-ENTITY-ROW        PIC X(66).
 01 WS-STATUS            BINARY-LONG.
 01 WS-ROW               BINARY-LONG.
 01 WS-BAD               BINARY-LONG.
 01 WS-FX                FLOAT-LONG.
 01 WS-FY2               FLOAT-LONG.
 01 WS-FZ                FLOAT-LONG.
 01 WS-YAW               FLOAT-SHORT VALUE 0.
 01 WS-DX                FLOAT-LONG.
 01 WS-DZ                FLOAT-LONG.
 01 WS-L1                BINARY-DOUBLE UNSIGNED.
 01 WS-L2                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION.
     CALL "MS6-SPAWNER-NEW" USING WS-SPAWNER
     MOVE "acceptance US15 18§6.12 Spawner block: the default spawnDelay is 20" TO WS-CASE
     COMPUTE WS-E = 20
     COMPUTE WS-O = WS-DELAY
     PERFORM CHECK-N
     MOVE "acceptance US15 44-2§10.1 spawner defaults: minSpawnDelay 200 and maxSpawnDelay 800" TO WS-CASE
     COMPUTE WS-E = 1000
     COMPUTE WS-O = WS-MIN + WS-MAX - 0
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.12 Spawner block: spawnCount 4, maxNearbyEntities 6" TO WS-CASE
     COMPUTE WS-E = 10
     COMPUTE WS-O = WS-COUNT + WS-NEARBY
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.12 Spawner block: requiredPlayerRange 16, spawnRange 4" TO WS-CASE
     COMPUTE WS-E = 20
     COMPUTE WS-O = WS-PRANGE + WS-SRANGE
     PERFORM CHECK-N
     MOVE 3 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "MS6-SPAWNER-ROLL" USING XR-STATE WS-SPAWNER WS-D
     MOVE 600 TO WS-I
     CALL "XORO-NEXT-INT" USING WS-MIRROR WS-I WS-ROW
     COMPUTE WS-E = 200 + WS-ROW
     COMPUTE WS-O = WS-D
     MOVE "acceptance US15 18§6.12 Spawner block: rolling a delay is minSpawnDelay + nextInt(max - min)" TO WS-CASE
     PERFORM CHECK-N
     MOVE 300 TO WS-MAX
     MOVE 300 TO WS-MIN
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-SPAWNER-ROLL" USING XR-STATE WS-SPAWNER WS-D
     MOVE "acceptance US15 18§6.12 Spawner block: when the maximum is not larger the delay is the minimum" TO WS-CASE
     COMPUTE WS-E = 300
     COMPUTE WS-O = WS-D
     PERFORM CHECK-N
     MOVE 0 TO WS-O
     IF XR-LO = WS-M-LO AND XR-HI = WS-M-HI
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 18§6.12 Spawner block: that roll draws no random number" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "MS6-SPAWNER-NEW" USING WS-SPAWNER
     MOVE 0 TO WS-NEAR
     CALL "MS6-SPAWNER-STEP" USING XR-STATE WS-SPAWNER WS-NEAR WS-ACTION
     MOVE "acceptance US15 18§6.12 Spawner block: no player in range does nothing (action 0)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-ACTION
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.12 Spawner block: and the delay is untouched" TO WS-CASE
     COMPUTE WS-E = 20
     COMPUTE WS-O = WS-DELAY
     PERFORM CHECK-N
     MOVE 1 TO WS-NEAR
     CALL "MS6-SPAWNER-STEP" USING XR-STATE WS-SPAWNER WS-NEAR WS-ACTION
     MOVE "acceptance US15 18§6.12 Spawner block: a positive delay counts down and stops (action 1)" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-ACTION
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.12 Spawner block: the delay 20 becomes 19" TO WS-CASE
     COMPUTE WS-E = 19
     COMPUTE WS-O = WS-DELAY
     PERFORM CHECK-N
     MOVE 0 TO WS-DELAY
     CALL "MS6-SPAWNER-STEP" USING XR-STATE WS-SPAWNER WS-NEAR WS-ACTION
     MOVE "acceptance US15 18§6.12 Spawner block: delay 0 makes the spawn attempts (action 2)" TO WS-CASE
     COMPUTE WS-E = 2
     COMPUTE WS-O = WS-ACTION
     PERFORM CHECK-N
     MOVE -1 TO WS-DELAY
     MOVE 200 TO WS-MIN
     MOVE 800 TO WS-MAX
     CALL "MS6-SPAWNER-STEP" USING XR-STATE WS-SPAWNER WS-NEAR WS-ACTION
     MOVE "acceptance US15 18§6.12 Spawner block: delay -1 rolls a delay (action 3)" TO WS-CASE
     COMPUTE WS-E = 3
     COMPUTE WS-O = WS-ACTION
     PERFORM CHECK-N
     MOVE 0 TO WS-O
     IF WS-DELAY >= 200 AND WS-DELAY < 800
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 18§6.12 Spawner block: the rolled delay lies in 200 to 799" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     COMPUTE WS-BX = WS-X0 + 12
     COMPUTE WS-BZ = WS-Z0 + 12
     COMPUTE WS-BY = WS-FY + 1
     CALL "MS6-SPAWNER-NEW" USING WS-SPAWNER
     MOVE "zombie" TO WS-KEY
     MOVE 6000 TO CW-TIME
     PERFORM TRY-SPAWNS
     MOVE "acceptance US15 18§6.12 Spawner block: in daylight the monster light rule still applies (SPAWNER does not ignore light)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-WINS
     PERFORM CHECK-N
     MOVE 18000 TO CW-TIME
     MOVE 0 TO BW-DIFFICULTY
     PERFORM TRY-SPAWNS
     MOVE "acceptance US15 18§6.12 Spawner block: Peaceful stops a monster spawner" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-WINS
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
     MOVE "bat" TO WS-KEY
     PERFORM TRY-SPAWNS
     MOVE "acceptance US15 18§6.12 Spawner block: an entity type without a mob row spawns nothing" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-WINS
     PERFORM CHECK-N
     MOVE "zombie" TO WS-KEY
     MOVE 18000 TO CW-TIME
     MOVE GE-COUNT TO WS-GE0
     PERFORM TRY-SPAWNS
     MOVE "acceptance US15 18§6.12 Spawner block: a zombie spawner spawns in the dark" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(WS-WINS, 1)
     PERFORM CHECK-N
*>   BaseSpawner.serverTick (30-8 14.3.3): every spawned mob posts entity_place at the centre of the cell holding its spawn position, the mob itself as the source.
     MOVE "acceptance US15 30-8 14.3.3 a spawner posts one entity_place for each mob it spawned" TO WS-CASE
     COMPUTE WS-E = WS-WINS
     COMPUTE WS-O = GE-COUNT - WS-GE0
     PERFORM CHECK-N
     COMPUTE WS-GLOG = FUNCTION MOD(GE-COUNT - 1, 128) + 1
     MOVE GE-L-SOURCE(WS-GLOG) TO WS-GSRC
     MOVE "acceptance US15 30-8 14.3.3 the last spawn's event is entity_place" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = 0
     IF GE-L-NAME(WS-GLOG) = "entity_place"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-GX = FUNCTION INTEGER(EN-X(WS-GSRC)) + 0.5
     COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-GSRC)) + 0.5
     COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(WS-GSRC)) + 0.5
     MOVE "acceptance US15 30-8 14.3.3 its position is the centre of the mob's cell and its source the mob" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = 0
     IF GE-L-X(WS-GLOG) = WS-GX AND GE-L-Y(WS-GLOG) = WS-GY AND GE-L-Z(WS-GLOG) = WS-GZ AND WS-GSRC > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             COMPUTE WS-DX = EN-X(WS-ROW) - WS-BX - 0.5
             COMPUTE WS-DZ = EN-Z(WS-ROW) - WS-BZ - 0.5
             IF WS-DX < -4 OR WS-DX > 4 OR WS-DZ < -4 OR WS-DZ > 4 OR EN-Y(WS-ROW) < WS-FY OR EN-Y(WS-ROW) > WS-FY + 3
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.12 Spawner block: every mob appears within the spawn range 4 of the block centre and within a layer of its y" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-BAD
     PERFORM CHECK-N
     MOVE "zombie" TO WS-KEY
     MOVE 1 TO WS-NEARBY
     PERFORM TRY-SPAWNS
     MOVE "acceptance US15 18§6.12 Spawner block: with maxNearbyEntities 1 and zombies already near, no more spawn" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-WINS
     PERFORM CHECK-N
     MOVE SPACES TO WS-EKEY
     MOVE "minecraft:pig" TO WS-EKEY
     MOVE 5.5 TO WS-FX
     MOVE 70.0 TO WS-FY2
     MOVE 5.5 TO WS-FZ
     MOVE "pig" TO WS-KEY
     CALL "MS6-EGG-SPAWN" USING WS-DIM WS-KEY WS-FX WS-FY2 WS-FZ WS-ROW
     MOVE "acceptance US15 18§6.12 Spawn egg: a pig egg creates a pig at the target, no caps, light or placement checks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-ROW > 0
         IF EN-X(WS-ROW) = 5.5 AND EN-Y(WS-ROW) = 70.0 AND EN-Z(WS-ROW) = 5.5
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     MOVE "bat" TO WS-KEY
     CALL "MS6-EGG-SPAWN" USING WS-DIM WS-KEY WS-FX WS-FY2 WS-FZ WS-ROW
     MOVE "acceptance US15 18§6.12 Spawn egg: a species without a mob row creates nothing (row 0)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-ROW
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 TRY-SPAWNS.
     MOVE 0 TO WS-WINS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-SPAWNER-ATTEMPT" USING XR-STATE WS-DIM WS-KEY WS-BX WS-BY WS-BZ WS-SPAWNER WS-OK
         ADD WS-OK TO WS-WINS
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-12.
 COPY CORETEST.
 COPY MOBSPTEST.
