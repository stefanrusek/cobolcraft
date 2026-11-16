*> Implementation test (US15; docs/protocol/18-mob-framework.md section 7.3 and 17 section 4.5): the armour and toughness of a mob reduce a hit
*> (CombatRules.getDamageAfterAbsorb); the fraction of a point is carried in EN-HEALTH-MILLI (thousandths of a point already lost).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FY                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-EKEY               PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-AMOUNT             BINARY-LONG.
 01 WS-CAUSE              BINARY-LONG.
 01 WS-ZERO               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:zombie" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
*>   A zombie has armor 2: 6 damage becomes 6 x (1 - 0.4 / 25) = 5.904.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 6 TO WS-AMOUNT
     MOVE CAUSE-MOB TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: a zombie's base armor 2 turns 6 into 5.904 (whole points lost)" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§7.3 Damage: the fraction of the hit is carried (904 thousandths)" TO WS-CASE
     MOVE 904 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: a second hit adds its fraction to the carry (5.904 + 5.904 + 0.904 loses 6)" TO WS-CASE
     MOVE 9 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     MOVE 808 TO WS-E
     MOVE "acceptance US15 18§7.3 Damage: the carry after the second hit is 808" TO WS-CASE
     PERFORM CHECK-N
*>   A cause in bypasses_armor (fall) takes the whole amount.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE CAUSE-FALL TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: fall damage bypasses armor (6 lost)" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A full iron set (tier 4, 4 pieces: 2 + 6 + 5 + 2 = 15) and the base 2: armor 17; 10 damage: e = 17 - 10 / 2 = 12, q 0.48, 5.2.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 54 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 10 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: armor 17 turns 10 damage into 5.2 (15 left)" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§7.3 Damage: armor 17 leaves a carry of 200" TO WS-CASE
     MOVE 200 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A diamond helmet (tier 5, 1 piece: 3 armor, 2 toughness) and the base 2: armor 5, f = 2.5; 10 damage: e = max(5 - 4, 1) = 1, q 0.04, 9.6.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 61 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: toughness 2 with armor 5 turns 10 into 9.6 (11 left)" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§7.3 Damage: that hit leaves a carry of 600" TO WS-CASE
     MOVE 600 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A broken helmet (EN-HEAD-WEAR -1) gives no armor: the iron set is then 13 + 2 = 15; 10 damage: e = 10, q 0.4, 6.0.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 54 TO EN-EQUIP(WS-ROW)
     MOVE -1 TO EN-HEAD-WEAR(WS-ROW)
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: a broken helmet counts no armor (armor 15: 10 becomes 6.0, 14 left)" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§7.3 Damage: armor 15 leaves no carry" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A full diamond set (3 + 8 + 6 + 3 = 20) and the base 2: armor 22; 1 damage: e = 21.4 is clamped to 20, q 0.8, 0.2.
     MOVE "minecraft:zombie" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 64 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: the armor term is clamped to 20 (1 damage becomes 0.2, no whole point lost)" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§7.3 Damage: the clamped hit leaves a carry of 200" TO WS-CASE
     MOVE 200 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   A species without armor (a pig) takes the whole amount.
     MOVE "minecraft:pig" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW)
     MOVE 10 TO EN-HEALTH(WS-ROW)
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§7.3 Damage: a pig without armor loses the whole 3" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-7-ARMOR.
 COPY CORETEST.
 COPY MOBSPTEST.
