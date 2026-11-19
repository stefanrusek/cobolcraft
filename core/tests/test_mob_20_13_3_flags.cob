*> Acceptance test (lane p49r; docs/protocol/20 section 13.3.1): the damage sources of an evoker fang's bite.
*> - An owner-less fang (no Owner, as made by /summon) bites every living entity but the dead and the invulnerable with the plain `magic` source: 6.0 whatever the difficulty (no
*>   causing entity, so no difficulty scaling), ignoring armor, the Damage Event has no source entity.
*> - A fang with an owner (the evoker) spares the owner and its allies, and hurts the rest with `indirect_magic` caused by the owner: scaled for a player by the difficulty (Easy 4.0,
*>   Normal 6.0, Hard 9.0), ignoring armor, the Damage Event carries the damage type `indirect_magic`.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-13-3-FLAGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(1024).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EVOKER-TYPE         BINARY-LONG.
 01 WS-EVOKER              BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-WARM                BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-NEEDLE              PIC X(40).
 01 WS-WANT-SOURCE         BINARY-LONG.
 01 WS-SOURCE-TEXT         PIC Z(5)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-LABEL               PIC X(160).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:evoker" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-EVOKER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X2 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-EVOKER-TYPE WS-X2 WS-Y WS-Z WS-YAW WS-EVOKER
*>   1. Owner-less: 6.0 on Hard and on Easy, and through an iron chestplate; the Damage Event is `magic`.
     MOVE 3 TO BW-DIFFICULTY
     MOVE "owner-less bite on Hard does 6 (no difficulty scaling)" TO WS-LABEL
     MOVE 0 TO WS-OWNER
     MOVE 14000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     MOVE 1 TO BW-DIFFICULTY
     MOVE "owner-less bite on Easy does 6" TO WS-LABEL
     MOVE 14000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     MOVE 2 TO BW-DIFFICULTY
     PERFORM WEAR-CHEST
     MOVE "owner-less bite on Normal ignores an iron chestplate" TO WS-LABEL
     MOVE 14000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     PERFORM REMOVE-CHEST
     MOVE 0 TO WS-WANT-SOURCE
     MOVE "the Damage Event of an owner-less bite has no source entity" TO WS-LABEL
     PERFORM CHECK-SOURCE
*>   2. Owned by the evoker: Easy 4, Hard 9, Normal 6 through armor; the Damage Event is `indirect_magic`.
     MOVE EN-ID(WS-EVOKER) TO WS-OWNER
     MOVE 1 TO BW-DIFFICULTY
     MOVE "owned bite on Easy does 4" TO WS-LABEL
     MOVE 16000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     MOVE 3 TO BW-DIFFICULTY
     MOVE "owned bite on Hard does 9" TO WS-LABEL
     MOVE 11000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     MOVE 0 TO BW-DIFFICULTY
     MOVE "owned bite on Peaceful does 0 (scaled)" TO WS-LABEL
     MOVE 20000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     MOVE 2 TO BW-DIFFICULTY
     PERFORM WEAR-CHEST
     MOVE "owned bite on Normal ignores an iron chestplate" TO WS-LABEL
     MOVE 14000 TO TL-EXPECTED-N
     PERFORM BITE-PLAYER
     PERFORM REMOVE-CHEST
     COMPUTE WS-WANT-SOURCE = EN-ID(WS-EVOKER) + 1
     MOVE "the Damage Event of an owned bite names the owner (entity id + 1)" TO WS-LABEL
     PERFORM CHECK-SOURCE
*>   3. An owner-less fang hurts the evoker itself; an owned one spares it (it is the owner).
     MOVE 0 TO WS-OWNER
     MOVE EN-HEALTH(WS-EVOKER) TO WS-HEALTH
     MOVE 0 TO EN-HURT(WS-EVOKER)
     CALL "EVK-FANG-ADD" USING WS-DIM WS-X2 WS-Y WS-Z WS-WARM WS-OWNER
     PERFORM 8 TIMES
         CALL "EVK-FANG-TICK"
     END-PERFORM
     MOVE "owner-less bite hurts an evoker for 6" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-HEALTH - 6) * 1000
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-EVOKER) * 1000
     PERFORM CASE-LINE
     MOVE EN-HEALTH(WS-EVOKER) TO WS-HEALTH
     MOVE 0 TO EN-HURT(WS-EVOKER)
     MOVE EN-ID(WS-EVOKER) TO WS-OWNER
     CALL "EVK-FANG-ADD" USING WS-DIM WS-X2 WS-Y WS-Z WS-WARM WS-OWNER
     PERFORM 8 TIMES
         CALL "EVK-FANG-TICK"
     END-PERFORM
     MOVE "an owned bite spares its owner" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HEALTH * 1000
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-EVOKER) * 1000
     PERFORM CASE-LINE
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-LABEL
     STRING "acceptance US15 20§13.3.1 " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A fang on the player's feet with WS-OWNER, eight ticks; TL-EXPECTED-N holds the expected health in thousandths (the label in WS-LABEL).
 BITE-PLAYER.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "TEST-DRAIN-HEALTH" USING PL-CONN(WS-PLAYER) WS-TEXT
     CALL "EVK-FANG-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-WARM WS-OWNER
     PERFORM 8 TIMES
         CALL "EVK-FANG-TICK"
     END-PERFORM
     CALL "TEST-DRAIN-HEALTH" USING PL-CONN(WS-PLAYER) WS-TEXT
     MOVE WS-LABEL TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     PERFORM CASE-LINE
     .

 WEAR-CHEST.
     MOVE WS-CHEST TO MN-EQUIP-ITEM(WS-PLAYER, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 3)
     .

 REMOVE-CHEST.
     MOVE 0 TO MN-EQUIP-ITEM(WS-PLAYER, 3) MN-EQUIP-COUNT(WS-PLAYER, 3)
     .

*> The last drained health text (the bite of the case before) has the Damage Event with that source.
 CHECK-SOURCE.
     MOVE WS-WANT-SOURCE TO WS-SOURCE-TEXT
     MOVE SPACES TO WS-NEEDLE
     STRING " source " DELIMITED BY SIZE FUNCTION TRIM(WS-SOURCE-TEXT LEADING) DELIMITED BY SIZE " |" DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE TRAILING)
     MOVE WS-LABEL TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HITS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     .
 END PROGRAM TEST-MOB-20-13-3-FLAGS.
 COPY CORETEST.
 COPY MOBSPTEST.
