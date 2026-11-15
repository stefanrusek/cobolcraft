*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.3 with doc 44 part 7): the magma cube. Row in STDMOBS.cpy (MOB21ROWS2.cpy), size
*> roll and stats shared with the slime (health s x s, XP s), size in metadata 18, contact damage s + 2 (also at size 1), the split on death, magma cream
*> only from size 2, natural spawn rule 10 (any light, not Peaceful).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/nether-loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-SIZE                BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:magma_cream".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-CREAM               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CORNER-X            BINARY-LONG.
 01 WS-CORNER-Z            BINARY-LONG.
 01 WS-COL-X               BINARY-LONG.
 01 WS-COL-Z               BINARY-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-CREAM WS-ITEM-ROW WS-STATUS
     MOVE "magma_cube" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE "acceptance US15 21§5.3 minecraft:magma_cube has a species row after the slime rows" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 41 AND SM-KEY(WS-M) = "magma_cube"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.3 minecraft:magma_cube is a monster (kind 1) of spawn rule 10" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS = SM-KIND(WS-M) + SM-SPAWN(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.3 minecraft:magma_cube does not burn in daylight" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP SM-BURNS(WS-M)
*>   Spawn size: the slime roll (setSpawnSize); a finalized cube has health s x s and size s in the variant.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-N1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF EN-HEALTH(WS-ROW) NOT = EN-VARIANT(WS-ROW) * EN-VARIANT(WS-ROW)
             ADD 1 TO WS-BAD
         END-IF
         IF EN-VARIANT(WS-ROW) NOT = 1 AND EN-VARIANT(WS-ROW) NOT = 2 AND EN-VARIANT(WS-ROW) NOT = 4
             ADD 1 TO WS-BAD
         END-IF
         IF EN-VARIANT(WS-ROW) = 4
             ADD 1 TO WS-N1
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§5.3 a finalized magma cube is size 1, 2 or 4 with health size squared" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-BAD
     MOVE "acceptance US15 21§5.3 some of 30 finalized cubes are size 4" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-N1 > 0 AND WS-N1 < 30
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The size packet is index 18 INT, as the slime's.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 4 TO EN-VARIANT(WS-ROW)
     MOVE 16 TO EN-HEALTH(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 21§5.3 the size packet is 0x65 (Set Entity Data) for a magma cube" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 5 AND WS-BYTE(1) = X"65"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Contact damage: the attribute (the size) + 2, also at size 1.
     MOVE 1 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-ROW WS-M WS-DAMAGE
     MOVE "acceptance US15 21§5.3 a size 1 magma cube deals 3 (attribute 1 + 2)" TO WS-CASE
     MOVE 3 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
     MOVE 4 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-ROW WS-M WS-DAMAGE
     MOVE "acceptance US15 21§5.3 a size 4 magma cube deals 6 (attribute 4 + 2)" TO WS-CASE
     MOVE 6 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-DAMAGE
*>   Death of a size 2 cube killed by the player: 2 to 4 children of size 1 (health 1), one magma cream, experience 2 (orb).
     MOVE 2 TO EN-VARIANT(WS-ROW)
     MOVE 4 TO EN-HEALTH(WS-ROW)
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW)
     CALL "STDMOB-DIE" USING WS-ROW
     MOVE 0 TO WS-COUNT WS-BAD
     PERFORM VARYING WS-N1 FROM 1 BY 1 UNTIL WS-N1 > EN-COUNT
         IF EN-USED(WS-N1) = 1 AND EN-TYPE(WS-N1) = WS-TYPE AND WS-N1 NOT = WS-ROW
             ADD 1 TO WS-COUNT
             IF EN-VARIANT(WS-N1) NOT = 1 OR EN-HEALTH(WS-N1) NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
             CALL "ENTITY-REMOVE" USING WS-N1
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.3 a size 2 magma cube splits into 2 to 4 size 1 cubes" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-COUNT >= 2 AND WS-COUNT <= 4 AND WS-BAD = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-N1 FROM 1 BY 1 UNTIL WS-N1 > EN-COUNT
         IF EN-USED(WS-N1) = 1 AND EN-ITEM(WS-N1) = WS-CREAM AND EN-ITEM-COUNT(WS-N1) > 0
             ADD EN-ITEM-COUNT(WS-N1) TO WS-COUNT
             CALL "ENTITY-REMOVE" USING WS-N1
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.3 a size 2 magma cube drops its magma cream" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-COUNT
*>   A size 1 cube drops no magma cream and does not split.
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW)
     CALL "STDMOB-SLIME-DIE" USING WS-ROW WS-PLAYER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-N1 FROM 1 BY 1 UNTIL WS-N1 > EN-COUNT
         IF EN-USED(WS-N1) = 1 AND ((EN-ITEM(WS-N1) = WS-CREAM AND EN-ITEM-COUNT(WS-N1) > 0)
                 OR (EN-TYPE(WS-N1) = WS-TYPE AND WS-N1 NOT = WS-ROW))
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.3 a size 1 magma cube leaves no cream and no children" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-COUNT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Spawn rule 10: on a stone floor in the dark and in the light alike while the difficulty is not Peaceful; none on Peaceful.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 30
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-N1 = WS-BY - 1
     CALL "TEST-FLOOR-HERE" USING WS-DIM WS-BX WS-N1 WS-BZ
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE 1 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE 0 TO WS-N1
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-N1 WS-OK
     MOVE "acceptance US15 21§3.2 the magma cube rule passes by day on a stone floor (Normal)" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
     MOVE 0 TO BW-DIFFICULTY
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-N1 WS-OK
     MOVE "acceptance US15 21§3.2 the magma cube rule fails on Peaceful" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-N1 = WS-BY - 1
     MOVE 0 TO WS-I
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-N1 WS-BZ WS-I WS-OK
     MOVE "acceptance US15 21§3.2 the magma cube rule fails inside the floor block (no ground below)" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
*>   Spawn rule 11 (piglin): only the floor test, so it passes on Peaceful too.
     MOVE "piglin" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE 0 TO BW-DIFFICULTY
     MOVE 0 TO WS-N1
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-N1 WS-OK
     MOVE "acceptance US15 21§3.2 the piglin rule needs only the floor and passes on Peaceful" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
     MOVE 2 TO BW-DIFFICULTY
*>   A generation attempt with no species row (0) creates nothing.
     MOVE 0 TO WS-M
     MOVE 0 TO WS-OK
     MOVE WS-BX TO WS-CORNER-X WS-COL-X
     MOVE WS-BZ TO WS-CORNER-Z WS-COL-Z
     MOVE SPACES TO WS-NAME
     CALL "MS6-GEN-ATTEMPT" USING XR-STATE WS-DIM WS-M WS-CORNER-X WS-CORNER-Z WS-COL-X WS-COL-Z WS-OK WS-NAME
     MOVE "acceptance US15 6.10 a chunk-generation attempt with species row 0 fails" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OK
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-MOB-21-5-3.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
