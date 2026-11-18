*> Acceptance test (002-lane-p49b; docs/protocol/20 section 18.2): the sulfur cube's base form. Entity sulfur_cube, a cube mob (size in EN-VARIANT, metadata 18): a new cube
*> has size 2 and health size x size = 4; it never deals contact damage and takes no target; it splits in two (not 2 + nextInt(3)) into size 1 cubes of health 1 when a size 2 cube
*> dies and a size 1 cube does not split; its loot table is empty; it stays in Peaceful (a zombie is removed there). Not here (named in the lane report): the body item and
*> the archetypes (the 12 modifier sets), the explosive archetype's fuse and explosion, shearing, the bucket, tempt and item search goals, the spawn rule and biome entry.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-18-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-CHILDREN            BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:sulfur_cube" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE "acceptance US15 minecraft:sulfur_cube is a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-MOB
     MOVE "acceptance US15 20§18.2 Sulfur cube spawns at size 2 with health 4" TO TL-CASE
     MOVE 204 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-VARIANT(WS-MOB) * 100 + EN-HEALTH(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   It takes no target, never hits and stays in Peaceful.
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-X0 TO EN-X(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§18.2 Sulfur cube takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§18.2 Sulfur cube deals no contact damage" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "unhurt" TO TL-EXPECTED
     MOVE "hurt" TO TL-OBSERVED
     IF PL-HEALTH(WS-PLAYER) = WS-HEALTH
         MOVE "unhurt" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO BW-DIFFICULTY
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ZOMBIE
     CALL "MOB-STEP" USING WS-MOB
     CALL "MOB-STEP" USING WS-ZOMBIE
     MOVE "acceptance US15 20§18.2 Sulfur cube stays in Peaceful (a zombie does not)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-USED(WS-MOB) * 10 + EN-USED(WS-ZOMBIE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO BW-DIFFICULTY

*>   Death of a size 2 cube: exactly two size 1 cubes of health 1, no item.
     MOVE 0 TO EN-HURT(WS-MOB)
     MOVE 100 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     PERFORM COUNT-CUBES
     MOVE "acceptance US15 20§18.2 Sulfur cube size 2 splits into exactly 2 cubes" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-CHILDREN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§18.2 Sulfur cube children are size 1 with health 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§18.2 Sulfur cube drops no item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ITEMS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A size 1 cube does not split.
     MOVE WS-CHILDREN TO WS-E
     PERFORM FIND-CHILD
     MOVE 0 TO EN-HURT(WS-MOB)
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     PERFORM COUNT-CUBES
     MOVE "acceptance US15 20§18.2 Sulfur cube of size 1 does not split" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CHILDREN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-CUBES.
     MOVE 0 TO WS-CHILDREN WS-BAD WS-ITEMS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-HEALTH(WS-E) > 0
             ADD 1 TO WS-CHILDREN
             IF EN-VARIANT(WS-E) NOT = 1 OR EN-HEALTH(WS-E) NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-ITEM-TYPE
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.
 FIND-CHILD.
     MOVE 0 TO WS-MOB
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-MOB > 0
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-HEALTH(WS-E) > 0
             MOVE WS-E TO WS-MOB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-18-2.
 COPY CORETEST.
 COPY MOBSPTEST.
