*> Acceptance test (lane p49a, T14506; docs/protocol/18-mob-framework.md section 10.4 Damage, invulnerability and knockback numbers, with
*> 7.3 and 7.5): armor 10 turns 6 into 4.32, the invulnerability window (first hit 4, a stronger 6 at 15 applies 2, a weaker 3 is ignored,
*> a hit at 9 is fresh), death at tick T with removal at T + 20, and the experience of a mob wearing equipment: xpReward 5 plus 1 + nextInt(3)
*> for every worn slot (7 to 11 for two armor pieces), spawned as orbs of the largest values (the knockback numbers are in test_mob_18_7_4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-10-4.
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
 01 WS-ZOMBIE             BINARY-LONG.
 01 WS-PIG                BINARY-LONG.
 01 WS-ORB-TYPE           BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-AMOUNT             BINARY-LONG.
 01 WS-CAUSE              BINARY-LONG.
 01 WS-ZERO               BINARY-LONG VALUE 0.
 01 WS-I                  BINARY-LONG.
 01 WS-SUM                BINARY-LONG.
 01 WS-ORBS               BINARY-LONG.
 01 WS-REST               BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-TICK               BINARY-LONG.
 01 WS-LEFT.
    05 FILLER             BINARY-LONG VALUE 2477.
    05 FILLER             BINARY-LONG VALUE 1237.
    05 FILLER             BINARY-LONG VALUE 617.
    05 FILLER             BINARY-LONG VALUE 307.
    05 FILLER             BINARY-LONG VALUE 149.
    05 FILLER             BINARY-LONG VALUE 73.
    05 FILLER             BINARY-LONG VALUE 37.
    05 FILLER             BINARY-LONG VALUE 17.
    05 FILLER             BINARY-LONG VALUE 7.
    05 FILLER             BINARY-LONG VALUE 3.
    05 FILLER             BINARY-LONG VALUE 1.
 01 WS-VALUES REDEFINES WS-LEFT.
    05 WS-VALUE           BINARY-LONG OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     MOVE "minecraft:zombie" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-ZOMBIE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-PIG WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:experience_orb" TO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS

*>   Armor: damage 6, armor 10 (the base 2 and an iron helmet and chestplate: 2 + 6), toughness 0: 6 x (1 - 0.28) = 4.32.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 52 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW) EN-HEAD-WEAR(WS-ROW) EN-HURT(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 6 TO WS-AMOUNT
     MOVE CAUSE-MOB TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Damage: armor 10 turns 6 into 4.32 (4 whole points lost)" TO WS-CASE
     MOVE 16 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§10.4 Damage: the 0.32 is carried" TO WS-CASE
     MOVE 320 TO WS-E
     MOVE EN-HEALTH-MILLI(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The window: a first hit of 4 sets the window to 20; at 15 a hit of 6 applies 2; a hit of 3 is ignored; at 9 a hit of 1 is fresh.
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 4 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Damage: a first hit of 4 takes 4 health" TO WS-CASE
     MOVE 16 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§10.4 Damage: and sets the window to 20 ticks" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE EN-HURT(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 15 TO EN-HURT(WS-ROW)
     MOVE 6 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Damage: a stronger hit of 6 at 15 applies only 2" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Damage: a hit of 3 is ignored (not above the last 6)" TO WS-CASE
     MOVE 14 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO EN-HURT(WS-ROW)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Damage: at 9 a hit of 1 is fresh and applied in full" TO WS-CASE
     MOVE 13 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§10.4 Damage: and sets the window to 20 again" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE EN-HURT(WS-ROW) TO WS-O
     PERFORM CHECK-N

*>   Death: health reaches 0 and the row stays for 19 more ticks; the 20th removes it (Entity Events 3 and 60 are in test_stdmob_death).
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 50 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-ZERO
     MOVE "acceptance US15 18§10.4 Death: health 0 leaves a dying row" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-USED(WS-ROW) = 1 AND EN-HEALTH(WS-ROW) = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 19
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§10.4 Death: 19 ticks later the mob is still there" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "STDMOB-STEP" USING WS-ROW
     MOVE "acceptance US15 18§10.4 Death: at tick T + 20 it is removed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N

*>   Experience: xpReward 5; with no equipment exactly 5.
     PERFORM KILL-ZOMBIE-0
     MOVE "acceptance US15 18§10.4 Experience: a zombie without equipment gives 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-N
     PERFORM CLEAR-ORBS
*>   Two armor pieces (drop chance 0.085 <= 1.0): 5 + 2 x (1 + nextInt(3)) = 7 to 11, spawned as the orbs of the largest values.
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 6
         CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         MOVE 0 TO EN-VARIANT(WS-ROW) EN-HAND(WS-ROW) EN-HEAD-WEAR(WS-ROW) EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
         MOVE 52 TO EN-EQUIP(WS-ROW)
         MOVE 50 TO WS-AMOUNT
         MOVE CAUSE-PLAYER TO WS-CAUSE
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
         PERFORM ORB-SUM
         MOVE "acceptance US15 18§10.4 Experience: two armor pieces give 7 to 11" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-SUM >= 7 AND WS-SUM <= 11
             MOVE 1 TO WS-O
         END-IF
         PERFORM CHECK-N
         PERFORM PARTITION-COUNT
         MOVE "acceptance US15 18§10.4 Experience: the total is spawned as orbs of the largest values" TO WS-CASE
         MOVE WS-PARTS TO WS-E
         MOVE WS-ORBS TO WS-O
         PERFORM CHECK-N
         PERFORM CLEAR-ORBS
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
*>   A broken helmet is an empty slot: one piece worn, 6 to 8.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-VARIANT(WS-ROW) EN-HAND(WS-ROW) EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
     MOVE 51 TO EN-EQUIP(WS-ROW)
     MOVE -1 TO EN-HEAD-WEAR(WS-ROW)
     MOVE 50 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM ORB-SUM
     MOVE "acceptance US15 18§10.4 Experience: a broken helmet is an empty slot (only xpReward)" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-N
     PERFORM CLEAR-ORBS
*>   A weapon in the main hand counts too: 6 to 8.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-VARIANT(WS-ROW) EN-EQUIP(WS-ROW) EN-HEAD-WEAR(WS-ROW) EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
     MOVE 1 TO EN-HAND(WS-ROW)
     MOVE 50 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM ORB-SUM
     MOVE "acceptance US15 18§10.4 Experience: a held weapon is a worn slot (6 to 8)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SUM >= 6 AND WS-SUM <= 8
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM CLEAR-ORBS
     STOP RUN.

 KILL-ZOMBIE-0.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     MOVE 0 TO EN-VARIANT(WS-ROW) EN-EQUIP(WS-ROW) EN-HAND(WS-ROW) EN-HEAD-WEAR(WS-ROW) EN-HEALTH-MILLI(WS-ROW) EN-HURT(WS-ROW)
     MOVE 50 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM ORB-SUM.
 ORB-SUM.
     MOVE 0 TO WS-SUM WS-ORBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             COMPUTE WS-SUM = WS-SUM + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
             ADD EN-ITEM-COUNT(WS-I) TO WS-ORBS
         END-IF
     END-PERFORM.
 CLEAR-ORBS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 PARTITION-COUNT.
     MOVE WS-SUM TO WS-REST
     MOVE 0 TO WS-PARTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         PERFORM UNTIL WS-REST < WS-VALUE(WS-I)
             SUBTRACT WS-VALUE(WS-I) FROM WS-REST
             ADD 1 TO WS-PARTS
         END-PERFORM
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-10-4.
 COPY CORETEST.
 COPY MOBSPTEST.
