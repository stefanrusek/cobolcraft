*> Acceptance test, the end crystal (docs/protocol/21 section 6.3, 44 part 9 section 11.1; lane 002-lane-mobsb6, T9013): the item on obsidian or bedrock with free space above, the fire placed in an
*> air cell of a dragon fight level, the first hit removing the crystal with an explosion of power 6 (none when the damage is itself an explosion), no damage from the dragon or while invulnerable.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-CRYSTAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PLAYPKT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CRYSTAL-ITEM        BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DRAGON              BINARY-LONG.
 01 WS-EXPLOSION           BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-N2                  BINARY-LONG VALUE 0.
 01 WS-N3                  BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BEFORE              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 6
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 40
     COMPUTE WS-FZ = WS-Z0 - 40
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:obsidian" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-OBSIDIAN
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:end_crystal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CRYSTAL-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE WS-CRYSTAL-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
*>   On stone: refused.
     CALL "TEST-USE-ON" USING WS-CONN WS-X0 WS-GY WS-Z0 WS-FACE WS-SEQ
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 11.1 an end crystal item on stone makes no crystal" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   On obsidian: a crystal in the cell above (bottom centre) with no base shown, one item used.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-GY WS-Z0 WS-OBSIDIAN
     CALL "TEST-USE-ON" USING WS-CONN WS-X0 WS-GY WS-Z0 WS-FACE WS-SEQ
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-SLOT
             MOVE PJ-ENT(WS-I) TO WS-STATE
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-STATE AND WS-COUNT > 0
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 11.1 on obsidian one crystal appears and one item is used" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT * 10 + PL-SLOT-COUNT(WS-PLAYER, WS-HELD) - 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.3 it stands at the bottom centre of the cell above (y)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.3 the base is hidden (show bottom 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fire in a dragon fight level: the air cell at the crystal's position gets fire.
     CALL "CRYSTAL-FIRE" USING WS-ROW WS-YES
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE "acceptance US16 21 6.3 a crystal on a level with a dragon fight sets fire in its air cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Immune to the dragon and while invulnerable; the player's hit removes it with an explosion (the floor stone block beside the stand is destroyed).
     MOVE 1 TO WS-DRAGON
     CALL "CRYSTAL-HURT" USING WS-ROW WS-DRAGON WS-N2 WS-N3 WS-DONE
     MOVE "acceptance US16 21 6.3 the dragon cannot damage a crystal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PJ-I2(WS-SLOT)
     CALL "CRYSTAL-HURT" USING WS-ROW WS-NO WS-N2 WS-N3 WS-DONE
     MOVE "acceptance US16 21 6.3 a permanently invulnerable crystal ignores a hit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I2(WS-SLOT)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-STONE
     MOVE EN-ID(WS-ROW) TO WS-STATE
     CALL "CRYSTAL-HURT" USING WS-ROW WS-NO WS-N2 WS-N3 WS-DONE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) = WS-STATE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.3 the first hit removes the crystal" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X0 WS-Y0 WS-Z0 WS-STATE
     MOVE "acceptance US16 21 6.3 and its explosion of power 6 destroyed the stone block in its cell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hit that already is an explosion does not explode again.
     COMPUTE WS-X = WS-X0 + 3.5
     MOVE WS-Y0 TO WS-Y
     COMPUTE WS-Z = WS-Z0 + 0.5
     COMPUTE WS-CX = WS-X0 + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-STONE
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YES WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-STATE
     CALL "CRYSTAL-HURT" USING WS-ROW WS-NO WS-YES WS-N3 WS-DONE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) = WS-STATE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-BEFORE
     MOVE "acceptance US16 21 6.3 an explosion hit removes the crystal without a second explosion (the stone stays)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT = 0 AND WS-BEFORE = WS-STONE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-CRYSTAL.
 COPY CORETEST.
 COPY MOBSPTEST.
