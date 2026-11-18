*> The bat (docs/protocol/21 section 8.10; lane p49f, T21100 to T21120): the row, the spawn rule checkBatSpawnRules (truth table and the rule at real cells), the resting state (hangs 0.9 below the ceiling, metadata 16
*> bit 0, the take-off when the block above is no redstone conductor, a player within 4 blocks, the hurt), the flying state (one tick of steering, a new target within the cube of the formula) and the 1 in 100 return
*> to rest under a conductor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY RULES.
 COPY DIMENSIONS.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-CASE                PIC X(140).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BAT-TYPE            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-SM                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-GLASS               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EXPECT              PIC X(300).
 01 WS-ID                  PIC Z(8)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 2.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-COMMAND.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 21008.
 01 WS-TARGET-Y            BINARY-LONG.
 01 WS-LAST-YAW            FLOAT-LONG.
 01 WS-CHANGES             BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-TOP-Y               BINARY-LONG.
 01 WS-TREG                PIC X(48) VALUE "block".
 01 WS-TTAG                PIC X(112) VALUE "minecraft:base_stone_overworld".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-A3                  BINARY-LONG.
 01 WS-A4                  BINARY-LONG.
 01 WS-A5                  BINARY-LONG.
 01 WS-A6                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The test world has no tags of the data pack: the bats_spawnable_on tag (= base_stone_overworld) is registered with stone as its only member.
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ID TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TREG WS-TTAG WS-ONE WS-MEMBERS WS-STATUS
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-DIRT
     MOVE "minecraft:glass" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GLASS
     MOVE "minecraft:soul_sand" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAND
     MOVE "minecraft:oak_leaves" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LEAVES
     MOVE "minecraft:bat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BAT-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-BAT-TYPE WS-SM
     MOVE "acceptance US15 minecraft:bat 21§8.10 the bat has a mob row" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SM > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 max health 6" TO WS-CASE
     MOVE 6 TO WS-E
     CALL "STDMOB-HEALTH" USING WS-BAT-TYPE WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 18§1.2 the bat is the ambient category (3)" TO WS-CASE
     MOVE 3 TO WS-E
     CALL "MS6-ROW-CAT" USING WS-SM WS-O
     PERFORM CHECK-N
     MOVE "bat" TO WS-KEY
     CALL "MS6-SPECIES" USING WS-KEY WS-O
     MOVE "acceptance US15 minecraft:bat 21§8.10 the biome entry bat has a species row (natural spawn)" TO WS-CASE
     MOVE WS-SM TO WS-E
     PERFORM CHECK-N
*>   The spawn rule truth table (below surface, nextBoolean false, brightness not above nextInt(4), tag, mob rules).
     MOVE "acceptance US15 minecraft:bat 21§8.10 the spawn rule holds when every test holds" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 1 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 at or above the surface height it fails" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 0 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 1 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 nextBoolean true fails" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 1 TO WS-A2
     MOVE 1 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 a brightness above the nextInt(4) draw fails (3 above 2)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 3 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 a brightness equal to the draw passes (2 and 2)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 2 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 a block below outside bats_spawnable_on fails" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 1 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 0 TO WS-A5
     MOVE 1 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 a failing mob rule (checkMobSpawnRules) fails" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 1 TO WS-A1
     MOVE 0 TO WS-A2
     MOVE 1 TO WS-A3
     MOVE 2 TO WS-A4
     MOVE 1 TO WS-A5
     MOVE 0 TO WS-A6
     CALL "BAT-SPAWN-OK" USING WS-A1 WS-A2 WS-A3 WS-A4 WS-A5 WS-A6 WS-O
     PERFORM CHECK-N
*>   A conductor test of the block above (30 section 2.4).
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 8
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 8
     COMPUTE WS-CY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STONE
     CALL "BAT-CONDUCTOR" USING WS-DIM WS-BX WS-CY WS-BZ WS-COND
     MOVE "acceptance US15 minecraft:bat 21§8.10 stone above is a redstone conductor" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COND TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-GLASS
     CALL "BAT-CONDUCTOR" USING WS-DIM WS-BX WS-CY WS-BZ WS-COND
     MOVE "acceptance US15 minecraft:bat 21§8.10 glass above is not (never list)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COND TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-LEAVES
     CALL "BAT-CONDUCTOR" USING WS-DIM WS-BX WS-CY WS-BZ WS-COND
     MOVE "acceptance US15 minecraft:bat 21§8.10 leaves above are not (never list)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COND TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-SAND
     CALL "BAT-CONDUCTOR" USING WS-DIM WS-BX WS-CY WS-BZ WS-COND
     MOVE "acceptance US15 minecraft:bat 21§8.10 soul sand above is (always list)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-COND TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     CALL "BAT-CONDUCTOR" USING WS-DIM WS-BX WS-CY WS-BZ WS-COND
     MOVE "acceptance US15 minecraft:bat 21§8.10 air above is not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COND TO WS-O
     PERFORM CHECK-N
*>   The rule at real cells: a roof of stone 3 above the floor; over 200 draws about half pass (nextBoolean false), none under open sky or over dirt.
     PERFORM VARYING WS-I FROM -6 BY 1 UNTIL WS-I > 6
         PERFORM VARYING WS-J FROM -6 BY 1 UNTIL WS-J > 6
             COMPUTE WS-CX = WS-BX + WS-I
             COMPUTE WS-CZ = WS-BZ + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
         END-PERFORM
     END-PERFORM
     CALL "XORO-SEED" USING WS-SEED WS-STATE
     COMPUTE WS-CY = WS-FY + 1
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         CALL "BAT-RULE-AT" USING WS-STATE WS-DIM WS-SM WS-BX WS-CY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-HITS
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 under a roof over stone about half of 200 draws pass (60 to 140)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HITS >= 60 AND WS-HITS <= 140
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-TOP-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 2
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "BAT-RULE-AT" USING WS-STATE WS-DIM WS-SM WS-BX WS-TOP-Y WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-HITS
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 above the surface height of the column the rule never passes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HITS TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CX = WS-BX + 2
     COMPUTE WS-TARGET-Y = WS-FY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-TARGET-Y WS-BZ WS-DIRT
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "BAT-RULE-AT" USING WS-STATE WS-DIM WS-SM WS-CX WS-CY WS-BZ WS-REASON WS-OK
         ADD WS-OK TO WS-HITS
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 over dirt (not bats_spawnable_on) the rule never passes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HITS TO WS-O
     PERFORM CHECK-N
*>   Resting: a bat spawned under the stone roof hangs.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     COMPUTE WS-X = WS-BX - 4 + 0.5
     COMPUTE WS-Y = WS-FY + 2
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-BAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";16=I1)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:bat 21§8.10 a new bat is sent resting: Add Entity then metadata 16 = 1" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 a resting bat hangs at floor(y) + 1 - 0.9 (thousandths)" TO WS-CASE
     COMPUTE WS-E = (WS-FY + 2) * 1000 + 100
     COMPUTE WS-O = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 and is still resting" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 and has no velocity" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION ABS(EN-VX(WS-ROW)) + FUNCTION ABS(EN-VY(WS-ROW)) + FUNCTION ABS(EN-VZ(WS-ROW))
     PERFORM CHECK-N
*>   The head yaw draw (1 in 200): over 2000 ticks it changes a few times.
     MOVE EN-YAW(WS-ROW) TO WS-LAST-YAW
     MOVE 0 TO WS-CHANGES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2000
         CALL "STDMOB-STEP" USING WS-ROW
         IF EN-YAW(WS-ROW) NOT = WS-LAST-YAW
             ADD 1 TO WS-CHANGES
             MOVE EN-YAW(WS-ROW) TO WS-LAST-YAW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 a resting bat turns its head 1 tick in 200 (2 to 40 changes in 2000 ticks)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-CHANGES >= 2 AND WS-CHANGES <= 40
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 and is still resting afterwards (the player is far)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   Hurt while resting: it stops resting, then takes the damage.
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-NONE
     MOVE "acceptance US15 minecraft:bat 21§8.10 a hurt resting bat stops resting" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 and takes the damage (6 - 2)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 minecraft:bat 21§8.10 the viewers are told the flag fell (metadata 16 = 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE 0 TO WS-O
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL ";16=I0)"
     IF WS-HITS > 0
         MOVE 1 TO WS-O
     END-IF
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Taking off: the block above is removed.
     CALL "MOB-SPAWN" USING WS-DIM WS-BAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CY = WS-FY + 3
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:bat 21§8.10 no conductor above: the bat stops resting at once" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "54 47 101(" FUNCTION TRIM(WS-ID) ";16=I0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:bat 21§8.10 the take-off: level event 1025 (a Level Event packet) then metadata 16 = 0" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   A player within 4 blocks wakes a resting bat; a spectator does not.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     COMPUTE WS-Z = PL-Z(WS-PLAYER)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-CY = WS-FY + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
     COMPUTE WS-Y = WS-FY + 2
     COMPUTE WS-X = WS-CX + 0.5
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-BAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 3 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:bat 21§8.10 a spectator within 4 blocks does not wake the bat" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:bat 21§8.10 a survival player within 4 blocks wakes it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-PH-PHASE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Flying: one tick of steering toward the cell 3 east, level with the bat (21 section 8.10): vx = 0.05, vy = 0.07, then the air acceleration and the drag.
     COMPUTE WS-X = WS-BX - 8 + 0.5
     COMPUTE WS-Y = WS-FY + 2
     COMPUTE WS-Z = WS-BZ - 8 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-BAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-PH-PHASE(WS-ROW)
     MOVE 1 TO EN-PH-SET(WS-ROW)
     COMPUTE EN-PH-TX(WS-ROW) = FUNCTION INTEGER(WS-X) + 3
     COMPUTE EN-PH-TY(WS-ROW) = WS-FY + 2
     COMPUTE EN-PH-TZ(WS-ROW) = FUNCTION INTEGER(WS-Z)
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:bat 21§8.10 steering: vx after acceleration 0.01 and drag 0.91 is 0.0546 (ten-thousandths)" TO WS-CASE
     MOVE 546 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 steering: vy is 0.07 x 0.91 = 0.0637 (ten-thousandths)" TO WS-CASE
     MOVE 637 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 steering: the yaw turns to heading - 90 = -90 (tenths)" TO WS-CASE
     MOVE -900 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-YAW(WS-ROW) * 10 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 steering: the bat moved by 0.06 east (ten-thousandths)" TO WS-CASE
     MOVE 600 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER((EN-X(WS-ROW) - WS-X) * 10000 + 0.5)
     PERFORM CHECK-N
*>   A bat without a target draws one in the cube of the formula.
     MOVE 0 TO EN-PH-SET(WS-ROW)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 minecraft:bat 21§8.10 a new target is set" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-PH-SET(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:bat 21§8.10 the target is within x +- 6, y - 2 to y + 3, z +- 6 of the bat's cell" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-PH-TX(WS-ROW) >= WS-CX - 6 AND EN-PH-TX(WS-ROW) <= WS-CX + 6
             AND EN-PH-TY(WS-ROW) >= WS-CY - 2 AND EN-PH-TY(WS-ROW) <= WS-CY + 3
             AND EN-PH-TZ(WS-ROW) >= WS-CZ - 6 AND EN-PH-TZ(WS-ROW) <= WS-CZ + 6
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   The 1 in 100 return to rest: 2000 flying ticks of a bat put back under the roof sheet each time rest about 20 times (5 to 50); outside the sheet (air above) never.
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-FY + 2
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-BAT-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2000
         MOVE 0 TO EN-PH-PHASE(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
         CALL "STDMOB-STEP" USING WS-ROW
         IF EN-PH-PHASE(WS-ROW) = 1
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 a flying bat under a conductor rests 1 tick in 100 (5 to 50 of 2000)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HITS >= 5 AND WS-HITS <= 50
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-X = WS-BX + 10.5
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2000
         MOVE 0 TO EN-PH-PHASE(WS-ROW)
         MOVE WS-X TO EN-X(WS-ROW)
         MOVE WS-Y TO EN-Y(WS-ROW)
         MOVE WS-Z TO EN-Z(WS-ROW)
         MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
         CALL "STDMOB-STEP" USING WS-ROW
         IF EN-PH-PHASE(WS-ROW) = 1
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:bat 21§8.10 with air above a flying bat never starts resting (2000 ticks)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HITS TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-10.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
