*> Implementation test (lane covB; docs/protocol/20 section 14): the raid paths the acceptance tests leave out: wave sizes of the bonus wave and of an Easy raid, the enchant odds of the
*> omen levels, raiders members that are gone or are no raider species, the hero list not listing a hero twice, the raid centre moving to the nearest village section, the defeat title,
*> a raid dropped after 48000 ticks or when no wave position can be found, the bonus wave after a raid omen above 1, and the world tick running the raids while the rule is on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-RAID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DEF                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-WAVE                BINARY-LONG VALUE 1.
 01 WS-DIFF                BINARY-LONG VALUE 1.
 01 WS-BONUS               BINARY-LONG VALUE 1.
 01 WS-OMEN                BINARY-LONG.
 01 WS-ODDS                BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KILLER              BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-P49-OWNER           BINARY-LONG VALUE 900000.
 01 WS-P49-MEET            BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-N = WS-X - 24
     COMPUTE WS-S = WS-Z - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-N WS-S 48 WS-Y 1
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-FX WS-FY WS-FZ WS-YAW WS-COW
*>   The bonus wave counts waves by the number of groups; on Easy a pillager or vindicator wave gets 0 or 1 fewer or more by a draw.
     CALL "RAID-WAVE-COUNT" USING WS-TYPE WS-WAVE WS-DIFF WS-BONUS WS-COUNT
     CALL "RAID-NUM-GROUPS" USING WS-DIFF WS-INDEX
     CALL "RAID-DEFAULT" USING WS-TYPE WS-INDEX WS-DEF
     MOVE "covB 20 14.3 the bonus wave of an Easy raid has at least the default count of its wave index" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT >= WS-DEF
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Enchant odds of the raid omen levels 2 and 4.
     MOVE 2 TO WS-OMEN
     CALL "RAID-ENCHANT-ODDS" USING WS-OMEN WS-ODDS
     MOVE "covB 20 14.2 omen level 2 enchants 10 per cent of the banners' items (100 thousandths)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-ODDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-OMEN
     CALL "RAID-ENCHANT-ODDS" USING WS-OMEN WS-ODDS
     MOVE "covB 20 14.2 omen level 4 enchants 50 per cent (500 thousandths)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-ODDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A row that is no raider species (the player's) neither joins a raid nor walks to one.
     MOVE 0 TO CW-TICKS
     CALL "RAID-RAIDER-STEP" USING PL-ENTITY-ROW(WS-PLAYER)
     CALL "RAID-WALK" USING PL-ENTITY-ROW(WS-PLAYER) WS-HX WS-HZ WS-WALK
     MOVE "covB 20 13 a row of no raider species does not walk to the raid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The defeat title.
     MOVE 1 TO WS-SLOT
     MOVE 1 TO RD-USED(1)
     MOVE 3 TO RD-STATUS(1)
     CALL "RAID-BAR-NAME" USING WS-SLOT WS-TEXT WS-LEN
     MOVE "covB 20 14.2 the boss bar of a lost raid is titled Raid - Defeat" TO TL-CASE
     MOVE "Raid - Defeat" TO TL-EXPECTED
     MOVE WS-TEXT(1:WS-LEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A raid slot that is not in use is not ticked.
     MOVE 0 TO RD-USED(1)
     MOVE 0 TO RD-TICKS(1)
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "covB 20 14.2 an unused raid slot is not ticked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-TICKS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The raid centre in a village, one bell beside it.
     COMPUTE WS-N = WS-X + 3
     CALL "PXI-ADD" USING WS-DIM WS-N WS-Y WS-Z WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-N WS-Y WS-Z
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE WS-X TO RD-CX(1)
     MOVE WS-Y TO RD-CY(1)
     MOVE WS-Z TO RD-CZ(1)
     MOVE 2 TO BW-DIFFICULTY
     MOVE 1 TO RD-OMEN(1)
     MOVE 5 TO RD-COOLDOWN(1)
     MOVE 47999 TO RD-TICKS(1)
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "covB 20 14.2 a raid that has lasted 48000 ticks is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The raid's members: one that is gone leaves (and a gone leader clears the wave's leader).
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE 77 TO RD-LEADER(1)
     MOVE 999999 TO RR-ID(1)
     MOVE 1 TO RR-RAID(1)
     MOVE 1 TO RR-LEADER(1)
     CALL "RAID-REFRESH" USING WS-SLOT
     MOVE "covB 20 14.2 a gone raider leaves the raid and a gone leader clears the leader" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RR-ID(1) + RD-LEADER(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hero is listed once: a second kill by the same player adds nothing.
     MOVE EN-ID(WS-COW) TO RR-ID(1)
     MOVE 1 TO RR-RAID(1)
     MOVE 0 TO RR-LEADER(1)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO RD-HERO(1, 3)
     MOVE WS-PLAYER TO WS-KILLER
     CALL "RAID-RAIDER-DIED" USING WS-COW WS-KILLER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         IF RD-HERO(1, WS-I) = PL-ENTITY-ID(WS-PLAYER)
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "covB 20 14.2 a hero of the village is listed once" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The centre moves to the section centre of the nearest village point within two sections.
     INITIALIZE RD-ENTRY(2)
     MOVE 1 TO RD-USED(2)
     MOVE WS-DIM TO RD-DIM(2)
     MOVE 1000 TO RD-CX(2) RD-CZ(2)
     MOVE 64 TO RD-CY(2)
     MOVE 64 TO WS-I
     MOVE 1000 TO WS-N2
     MOVE 1030 TO WS-N
     CALL "PXI-ADD" USING WS-DIM WS-N WS-I WS-N2 WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-N WS-I WS-N2
     MOVE 1010 TO WS-N
     CALL "PXI-ADD" USING WS-DIM WS-N WS-I WS-N2 WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-N WS-I WS-N2
     MOVE 2 TO WS-SLOT
     CALL "RAID-MOVE-CENTER" USING WS-SLOT
     MOVE "covB 20 14.2 the raid centre moves to the nearest village section centre (x 1016)" TO TL-CASE
     MOVE 1016 TO TL-EXPECTED-N
     MOVE RD-CX(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 72 TO TL-EXPECTED-N
     MOVE RD-CY(2) TO TL-OBSERVED-N
     MOVE "covB 20 14.2 and its y is the section centre too" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO RD-USED(2)
*>   The bonus wave: with the last regular wave spawned and a raid omen above 1 one more group comes.
     MOVE 1 TO WS-SLOT
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE WS-X TO RD-CX(1)
     MOVE WS-Y TO RD-CY(1)
     MOVE WS-Z TO RD-CZ(1)
     MOVE 3 TO RD-OMEN(1)
     MOVE 5 TO RD-GROUPS(1)
     MOVE 1 TO RD-COOLDOWN(1)
     MOVE 0 TO RD-TICKS(1)
     MOVE 1 TO RD-SPAWN-SET(1)
     MOVE WS-X TO RD-SX(1)
     MOVE WS-Y TO RD-SY(1)
     MOVE WS-Z TO RD-SZ(1)
     INITIALIZE RR-STATE
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "covB 20 14.2 an omen above 1 gives a sixth, bonus group on Normal" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RD-GROUPS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No wave position found six times (the centre 400 high is out of reach of the ground): the raid is dropped.
     INITIALIZE RR-STATE
     MOVE 1 TO RD-USED(1)
     MOVE 400 TO RD-CY(1)
     MOVE 0 TO RD-GROUPS(1) RD-STARTED(1) RD-COOLDOWN(1) RD-SPAWN-SET(1) RD-TICKS(1)
     MOVE 1 TO RD-OMEN(1)
     CALL "PXI-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-X WS-Y WS-Z
     COMPUTE WS-N = WS-X + 3
     MOVE 400 TO WS-I
     CALL "PXI-ADD" USING WS-DIM WS-N WS-I WS-Z WS-KIND2
     ADD 1 TO WS-P49-OWNER
     CALL "VPX-CLAIM" USING WS-P49-OWNER WS-P49-MEET WS-DIM WS-N WS-I WS-Z
     CALL "RAID-TICK" USING WS-SLOT
     MOVE "covB 20 14.2 a raid with no valid wave position after six tries is dropped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RD-USED(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The world tick runs the raids while the raids rule is on (default): a raid in its celebration counts it.
     MOVE 1 TO RD-USED(1)
     MOVE 2 TO RD-STATUS(1)
     MOVE 0 TO RD-CELEB(1)
     CALL "RAID-WORLD-TICK"
     MOVE "covB 20 14.2 the world tick ticks a raid while the raids rule is on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RD-CELEB(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-RAID.
 COPY CORETEST.
 COPY MOBSPTEST.
