*> Acceptance test (lane p49r; docs/protocol/20 section 16.3): the breeze wind charge. A direct hit does 1.0 scaled for a player by the difficulty (Easy 1.0, Normal 1.0, Hard 1.5; Peaceful 0), armor
*> applies (damage type wind_charge), and the charge then bursts at its position: the burst deals no damage and destroys no block, it pushes every standard mob and player within 6 blocks of the
*> centre by (1 - distance / 6) x seen along the direction from the centre to the eyes (1.0 at the centre, 0.5 at 3 blocks, 0.0833 at 5.5, none at 6). The charge flies straight: its velocity is the same
*> after 10 ticks (no drag, no gravity).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CMENU.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(1024).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-BTYPE               BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-BREEZE              BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 30.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-SOURCE              BINARY-LONG VALUE 0.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-MOBHP               BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-VX0                 FLOAT-LONG.
 01 WS-VY0                 FLOAT-LONG.
 01 WS-VZ0                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:iron_chestplate" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 15
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 15
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
*>   1. The hit on a player (the charge's owner is a breeze 6 blocks away).
     COMPUTE WS-X0 = WS-X - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-BTYPE WS-X0 WS-Y WS-Z WS-YAW WS-BREEZE
     MOVE 0 TO WS-D
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         MOVE WS-D TO BW-DIFFICULTY
         MOVE "a wind charge hit on a player at difficulty " TO TL-CASE
         EVALUATE WS-D
             WHEN 0
                 MOVE "Peaceful does nothing" TO WS-ITEM-ROW
                 MOVE 20000 TO TL-EXPECTED-N
             WHEN 1
                 MOVE "Easy does 1.0" TO WS-ITEM-ROW
                 MOVE 19000 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "Normal does 1.0" TO WS-ITEM-ROW
                 MOVE 19000 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "Hard does 1.5" TO WS-ITEM-ROW
                 MOVE 18500 TO TL-EXPECTED-N
         END-EVALUATE
         PERFORM HIT-PLAYER
     END-PERFORM
     MOVE WS-CHEST TO MN-EQUIP-ITEM(WS-PLAYER, 3)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 3)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 3)
     MOVE 2 TO BW-DIFFICULTY
     MOVE "Normal through an iron chestplate does 0.78" TO WS-ITEM-ROW
     MOVE 19220 TO TL-EXPECTED-N
     PERFORM HIT-PLAYER
     MOVE 0 TO MN-EQUIP-ITEM(WS-PLAYER, 3) MN-EQUIP-COUNT(WS-PLAYER, 3)
     CALL "ENTITY-REMOVE" USING WS-BREEZE
*>   2. The burst: a zombie at 1, 3, 5.5 and 6 blocks from a centre in the open; the push is (1 - d / 6), no damage.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X + 40
     COMPUTE WS-CX = WS-X
     COMPUTE WS-CY = WS-Y + 3
     MOVE WS-Z TO WS-CZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 COMPUTE WS-X0 = WS-X + 1
             WHEN 2 COMPUTE WS-X0 = WS-X + 3
             WHEN 3 COMPUTE WS-X0 = WS-X + 5.5
             WHEN OTHER COMPUTE WS-X0 = WS-X + 6
         END-EVALUATE
*>       In the open air (a block of free space around the centre, so that every sample ray sees it): the mob is 3 blocks above the floor.
         COMPUTE WS-DY = WS-Y + 3
         CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-DY WS-Z WS-YAW WS-ZOMBIE
         MOVE 0 TO EN-VX(WS-ZOMBIE) EN-VY(WS-ZOMBIE) EN-VZ(WS-ZOMBIE)
         MOVE EN-HEALTH(WS-ZOMBIE) TO WS-MOBHP
         CALL "WIND-BURST" USING WS-DIM WS-CX WS-CY WS-CZ WS-SOURCE
         COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-ZOMBIE) ** 2 + EN-VY(WS-ZOMBIE) ** 2 + EN-VZ(WS-ZOMBIE) ** 2)
         EVALUATE WS-I
             WHEN 1
                 MOVE "the burst pushes a mob 1 block away by 1 - 1/6 (thousandths)" TO TL-CASE
                 MOVE 833 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "the burst pushes a mob 3 blocks away by 0.5 (thousandths)" TO TL-CASE
                 MOVE 500 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "the burst pushes a mob 5.5 blocks away by 0.0833 (thousandths)" TO TL-CASE
                 MOVE 83 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "the burst does not reach a mob 6 blocks away (thousandths)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         STRING "acceptance US15 20§16.3 Wind burst: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ITEM-ROW
         MOVE WS-ITEM-ROW TO TL-CASE
         COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 1000
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US15 20§16.3 Wind burst: it does no damage" TO TL-CASE
         MOVE WS-MOBHP TO TL-EXPECTED-N
         MOVE EN-HEALTH(WS-ZOMBIE) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     END-PERFORM
*>   3. The charge itself: it flies straight (same velocity after 10 ticks); at a stone block it bursts: a zombie beside the block is pushed, the block stays.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-X0 = WS-X + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     MOVE 0 TO EN-VX(WS-ZOMBIE) EN-VY(WS-ZOMBIE) EN-VZ(WS-ZOMBIE)
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     COMPUTE WS-CX = WS-X + 0.5
     COMPUTE WS-CY = WS-Y + 0.9
     COMPUTE WS-CZ = WS-Z + 0.5
     MOVE 6 TO WS-I
     CALL "PROJ-SPAWN" USING WS-I WS-DIM WS-CX WS-CY WS-CZ WS-DX WS-DY WS-DZ WS-SOURCE WS-SOURCE WS-CHARGE
     MOVE EN-VX(WS-CHARGE) TO WS-VX0
     PERFORM 3 TIMES
         CALL "PROJ-STEP" USING WS-CHARGE
     END-PERFORM
     MOVE "the charge keeps its velocity (no drag, no gravity): x after 3 ticks (thousandths)" TO TL-CASE
     MOVE 700 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CHARGE) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "and y stays 0 (thousandths)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-CHARGE) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-USED(WS-CHARGE) = 0
         CALL "PROJ-STEP" USING WS-CHARGE
     END-PERFORM
     MOVE "the charge bursts at the stone block: the zombie beside it is pushed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-ZOMBIE) NOT = 0 OR EN-VY(WS-ZOMBIE) NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "and the stone block is still there (TRIGGER interaction)" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> One charge hit on the player: PROJ-HIT of a breeze wind charge owned by the breeze row; TL-EXPECTED-N the health left (thousandths), WS-ITEM-ROW the label.
 HIT-PLAYER.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 6 TO WS-I
     COMPUTE WS-CX = WS-X - 3
     MOVE WS-Y TO WS-CY
     MOVE WS-Z TO WS-CZ
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     CALL "PROJ-SPAWN" USING WS-I WS-DIM WS-CX WS-CY WS-CZ WS-DX WS-DY WS-DZ WS-SOURCE EN-ID(WS-BREEZE) WS-CHARGE
     MOVE 0 TO WS-ZOMBIE
     CALL "PROJ-HIT" USING WS-CHARGE WS-ZOMBIE WS-PLAYER WS-X WS-Y WS-Z
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 20§16.3 Wind charge: a hit on a player at " DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-ROW) DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-16-4.
 COPY CORETEST.
 COPY MOBSPTEST.
