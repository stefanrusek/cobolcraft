*> Acceptance test, the raid lifecycle (docs/protocol/20 sections 14.2 and 14.3; lane 002-lane-mobsb5, T8902): the wave spawn position, the first wave with its leader and members,
*> the pause and cooldown between waves, loss without a village, peaceful stop, far raiders dropped, victory with the Hero of the Village, the celebration end, hero credit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAID-WAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-F0                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-HERO                BINARY-LONG VALUE 31.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HIT                 BINARY-LONG.
 01 WS-P49-OWNER           BINARY-LONG VALUE 900000.
 01 WS-P49-MEET            BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-N = WS-X - 24
     COMPUTE WS-S = WS-Z - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-N WS-S 48 WS-Y 1
*>   The village: two bells beside the player.
     COMPUTE WS-N = WS-X + 3
     CALL "PXI-ADD" USING WS-DIM WS-N WS-Y WS-Z WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-N WS-Y WS-Z
*>   The spawn position at cooldown 5 (n = 0, f = -0.24) lies within 9 blocks of the centre, on the floor.
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE WS-X TO RD-CX(1)
     MOVE WS-Y TO RD-CY(1)
     MOVE WS-Z TO RD-CZ(1)
     MOVE 5 TO RD-COOLDOWN(1)
     MOVE 1 TO RD-OMEN(1)
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO RD-SPAWN-SET(1)
     MOVE 1 TO WS-SLOT
     CALL "RAID-SPAWN-POS" USING WS-SLOT WS-FOUND
     MOVE "acceptance US15 20§14.2 a spawn position is found near the centre at cooldown 5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 within 10 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RD-SX(1) - WS-X) <= 10 AND FUNCTION ABS(RD-SZ(1) - WS-Z) <= 10
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   First wave on Normal: cooldown 0, nothing spawned yet: 4 or 5 pillagers with one leader, started.
     MOVE 0 TO RD-COOLDOWN(1)
     MOVE 0 TO RD-GROUPS(1)
     MOVE 0 TO RD-SPAWN-SET(1)
     MOVE 0 TO RD-STARTED(1)
     MOVE 0 TO WS-F0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-PTYPE
             ADD 1 TO WS-F0
         END-IF
     END-PERFORM
     CALL "RAID-TICK" USING WS-SLOT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-PTYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     COMPUTE WS-N = WS-N - WS-F0
     MOVE "acceptance US15 20§14.3 wave 1 on Normal spawns 4 or 5 pillagers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N = 4 OR WS-N = 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 the raid has started with one wave" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RD-STARTED(1) * 10 + RD-GROUPS(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0 AND RR-RAID(WS-I) = 1
             ADD 1 TO WS-HIT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§14.2 every raider is a member (pillagers plus 0 or 1 bonus vindicator)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HIT = WS-N OR WS-HIT = WS-N + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.3 the wave has a leader" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RD-LEADER(1) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 the total health is the sum of the raiders" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HIT * 24000
     MOVE RD-TOTAL(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With raiders alive no second wave comes.
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 raiders alive: still one wave" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RD-GROUPS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   All raiders dead: the tick pauses (cooldown 300), then 300 ticks count down and the second wave spawns on the tick the cooldown reaches 0.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) > 0
             PERFORM VARYING WS-ENTITY FROM 1 BY 1 UNTIL WS-ENTITY > EN-COUNT
                 IF EN-USED(WS-ENTITY) = 1 AND EN-ID(WS-ENTITY) = RR-ID(WS-I)
                     MOVE 0 TO EN-HEALTH(WS-ENTITY)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 after the wave is cleared the cooldown is set to 300" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     MOVE RD-COOLDOWN(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 299 TIMES
         CALL "RAID-TICK" USING WS-SLOT
     END-PERFORM
     MOVE "acceptance US15 20§14.2 one tick before 0 no second wave" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RD-GROUPS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 the cooldown is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RD-COOLDOWN(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Victory: all waves done (Easy: 3 plus the bonus wave of omen 3), no raiders: 40 post ticks then Hero of the Village level 3.
     MOVE 1 TO RD-USED(2)
     MOVE 1 TO RD-STATUS(2)
     MOVE WS-DIM TO RD-DIM(2)
     MOVE WS-X TO RD-CX(2)
     MOVE WS-Y TO RD-CY(2)
     MOVE WS-Z TO RD-CZ(2)
     MOVE 4 TO RD-GROUPS(2)
     MOVE 1 TO RD-STARTED(2)
     MOVE 0 TO RD-COOLDOWN(2)
     MOVE 3 TO RD-OMEN(2)
     MOVE 0 TO RD-POST(2)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO RD-HERO(2, 1)
     MOVE 1 TO BW-DIFFICULTY
     MOVE 2 TO WS-SLOT
     PERFORM 40 TIMES
         CALL "RAID-TICK" USING WS-SLOT
     END-PERFORM
     MOVE "acceptance US15 20§14.2 40 post-raid ticks are not yet a victory" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RD-STATUS(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 then the status is victory" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE RD-STATUS(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-HERO WS-LEVEL WS-LEFT
     MOVE "acceptance US15 20§14.2 the hero gets Hero of the Village with amplifier omen - 1" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 for 48000 ticks" TO TL-CASE
     MOVE 48000 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 600 TIMES
         CALL "RAID-TICK" USING WS-SLOT
     END-PERFORM
     MOVE "acceptance US15 20§14.2 600 celebration ticks end the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Loss: a centre far from every village after a wave.
     MOVE 1 TO RD-USED(3)
     MOVE 1 TO RD-STATUS(3)
     MOVE WS-DIM TO RD-DIM(3)
     COMPUTE RD-CX(3) = WS-X + 5000
     MOVE WS-Y TO RD-CY(3)
     MOVE WS-Z TO RD-CZ(3)
     MOVE 1 TO RD-GROUPS(3)
     MOVE 3 TO WS-SLOT
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 no village at the centre after a wave is a loss" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE RD-STATUS(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without a wave yet the raid just stops.
     MOVE 1 TO RD-USED(4)
     MOVE 1 TO RD-STATUS(4)
     MOVE WS-DIM TO RD-DIM(4)
     COMPUTE RD-CX(4) = WS-X + 5000
     MOVE 0 TO RD-GROUPS(4)
     MOVE 4 TO WS-SLOT
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 no village and no wave stops the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Peaceful stops a raid.
     MOVE 1 TO RD-USED(5)
     MOVE 1 TO RD-STATUS(5)
     MOVE WS-DIM TO RD-DIM(5)
     MOVE WS-X TO RD-CX(5)
     MOVE WS-Y TO RD-CY(5)
     MOVE WS-Z TO RD-CZ(5)
     MOVE 0 TO BW-DIFFICULTY
     MOVE 5 TO WS-SLOT
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "acceptance US15 20§14.2 Peaceful stops the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A raider 112 blocks from the centre is dropped from the raid at the 20 tick refresh.
     MOVE 2 TO BW-DIFFICULTY
     MOVE 1 TO RD-USED(6)
     MOVE 1 TO RD-STATUS(6)
     MOVE WS-DIM TO RD-DIM(6)
     MOVE WS-X TO RD-CX(6)
     MOVE WS-Y TO RD-CY(6)
     MOVE WS-Z TO RD-CZ(6)
     MOVE 1 TO RD-GROUPS(6)
     MOVE 1 TO RD-STARTED(6)
     MOVE 100 TO RD-COOLDOWN(6)
     COMPUTE WS-FX = WS-X + 112
     MOVE WS-Y TO WS-FY
     ADD 1 TO WS-FY
     MOVE WS-Z TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-FX WS-FY WS-FZ WS-YAW WS-ENTITY
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX OR WS-SLOT > 0
         IF RR-ID(WS-I) = 0
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE EN-ID(WS-ENTITY) TO RR-ID(WS-SLOT)
     MOVE 6 TO RR-RAID(WS-SLOT)
     MOVE 1 TO RR-WAVE(WS-SLOT)
     MOVE 0 TO RR-OUTSIDE(WS-SLOT)
     MOVE 6 TO WS-N
     MOVE 19 TO RD-TICKS(6)
     CALL "RAID-TICK" USING WS-N
     MOVE "acceptance US15 20§14.2 a raider 112 blocks away leaves the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RR-ID(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hero credit: a player killing a raider is added to the heroes.
     MOVE EN-ID(WS-ENTITY) TO RR-ID(WS-SLOT)
     MOVE 6 TO RR-RAID(WS-SLOT)
     MOVE 1 TO RR-LEADER(WS-SLOT)
     MOVE EN-ID(WS-ENTITY) TO RD-LEADER(6)
     CALL "RAID-RAIDER-DIED" USING WS-ENTITY WS-PLAYER
     MOVE "acceptance US15 20§14.2 the killer is a hero of the village" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO TL-EXPECTED-N
     MOVE RD-HERO(6, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.3 a dead leader clears the wave leader" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-LEADER(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-RAID-WAVE.

 COPY CORETEST.
 COPY MOBSPTEST.
