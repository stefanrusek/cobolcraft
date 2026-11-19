*> Acceptance test, trading with a villager at night (operator report, play-testing try17: "villagers don't trade at night"; docs/protocol/19 sections 22.4, 22.8 and 23, 40-menus-5 section 2.1;
*> lane 002-lane-bugnighttrade, T59600). Through the real Interact packet (0x1A, main hand), world time 14000 to 23000: an awake villager with a profession trades at night, in the open and under
*> a roof with no bed (mobInteract refuses only a sleeping villager); a villager that sleeps in its bed ignores the click (22.4) and lies on the bed (startSleeping puts it at the bed position,
*> 22.8), so the refusal is the one a player sees on a villager that is visibly in bed, not on one standing a block or two off; it stays there while it sleeps (no stroll), and trades again when
*> it wakes in the morning.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGNIGHTTRADE-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-SPACED              PIC X(1030).
 01 WS-N60                 PIC 9.
 01 WS-N53                 PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
*>   A farmer standing in the open one block in front of the player (profession set directly: the brain is not under test here; xp 1 keeps ResetProfession away).
     COMPUTE WS-X = WS-PX + 0.5
     MOVE WS-PY TO WS-Y
     COMPUTE WS-Z = WS-PZ + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     MOVE "farmer" TO VL-PROF(WS-S1)
     MOVE 1 TO VL-XP(WS-S1)
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   Night, awake, in the open, no bed anywhere: the window opens at 14000 and at 22900.
     MOVE 14000 TO CW-TIME
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 at night (14000) an awake villager in the open trades" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     PERFORM CLOSE-WINDOW
     MOVE 22900 TO CW-TIME
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 at night (22900) an awake villager in the open trades" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     PERFORM CLOSE-WINDOW
*>   A roof over it and no bed in the house: the same.
     COMPUTE WS-BX = WS-PX
     COMPUTE WS-BY = WS-PY + 2
     COMPUTE WS-BZ = WS-PZ + 1
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 18000 TO CW-TIME
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 at night under a roof with no bed an awake villager trades" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     PERFORM CLOSE-WINDOW
*>   A bed beside it: the villager claims it by day and goes to sleep in it at night.
     COMPUTE WS-BX = WS-PX + 1
     MOVE WS-PY TO WS-BY
     COMPUTE WS-BZ = WS-PZ + 1
     MOVE "minecraft:red_bed" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-ROW) / 16)
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     CALL "VPX-OF" USING EN-ID(WS-V1) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "N" TO TL-MODE
     MOVE "acceptance 19§22.8 the villager has claimed the bed as its home" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE 14000 TO CW-TIME
     MOVE 1200 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     MOVE "acceptance 19§22.8 at night next to its bed the villager sleeps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
*>   It lies on the bed: the middle of the bed block, above the floor and not above the block (mattress top 9/16, 51 R-E3; a body resting on a full-cube bed shape stands at 1).
     COMPUTE WS-WANT = WS-BX * 1000 + 500
     COMPUTE WS-N ROUNDED = EN-X(WS-V1) * 1000
     MOVE "acceptance 19§22.8 a sleeping villager lies at the bed position (x)" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     PERFORM CHECK
     COMPUTE WS-WANT = WS-BZ * 1000 + 500
     COMPUTE WS-N ROUNDED = EN-Z(WS-V1) * 1000
     MOVE "acceptance 19§22.8 a sleeping villager lies at the bed position (z)" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     PERFORM CHECK
     COMPUTE WS-LOW = WS-BY * 1000 + 500
     COMPUTE WS-HIGH = WS-BY * 1000 + 1000
     COMPUTE WS-N ROUNDED = EN-Y(WS-V1) * 1000
     MOVE 0 TO WS-FOUND
     IF WS-N >= WS-LOW AND WS-N <= WS-HIGH
         MOVE 1 TO WS-FOUND
     END-IF
     MOVE "acceptance 19§22.8 a sleeping villager lies on the bed (y between the mattress and the top of the cell)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     PERFORM CHECK
*>   Asleep in the bed: the click is ignored (22.4).
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 a villager asleep in its bed ignores the click" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
*>   It stays there while it sleeps: the stroll of the mob step is held off (cooldown 1, destination its own cell).
     MOVE 1210 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     MOVE "N" TO TL-MODE
     MOVE "acceptance 19§22.8 a sleeping villager has no stroll walk running (cooldown held at 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-COOLDOWN(WS-V1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 19§22.8 a sleeping villager still sleeps on the next brain tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
*>   Morning: it wakes and trades again.
     MOVE 2500 TO CW-TIME
     MOVE 1300 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V1
     MOVE "acceptance 19§22.8 in the morning the villager is awake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-SLEEP(WS-S1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 the awake villager trades again in the morning" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     PERFORM CHECK
     STOP RUN.

*> COUNT-OPEN: TL-OBSERVED = "<Open Screen packets> <Merchant Offers packets>" (0 or 1 each) of the packet ids listed in WS-IDS
 COUNT-OPEN.
     MOVE SPACES TO WS-SPACED
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N60 WS-N53
     INSPECT WS-SPACED TALLYING WS-N60 FOR ALL " 60 " ALL " 60x"
     INSPECT WS-SPACED TALLYING WS-N53 FOR ALL " 53 " ALL " 53x"
     IF WS-N60 > 1
         MOVE 1 TO WS-N60
     END-IF
     IF WS-N53 > 1
         MOVE 1 TO WS-N53
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING WS-N60 " " WS-N53 DELIMITED BY SIZE INTO TL-OBSERVED.

 CLOSE-WINDOW.
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGNIGHTTRADE-INTERACT.
 COPY CORETEST.
 COPY BETEST.
