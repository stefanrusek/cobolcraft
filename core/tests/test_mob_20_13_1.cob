*> Acceptance test (002-lane-p49b; docs/protocol/20 section 13.1): the vindicator. A new vindicator holds an iron axe (EN-HAND 10); it avoids a creaking within 8 blocks (AvoidEntityGoal:
*> it flees, at 1.2 within 7 blocks, 1.0 beyond); target 3 is an iron golem it sees within the follow range 12 (it walks to it and hits for 5); it drops an emerald (U 0..1, the
*> fixture entities/vindicator.json) only when a player killed it. Not here (named in the lane report): Johnny, break-door and open-door goals, hold ground, the raid buffs of 14.4,
*> the raid and patrol membership, looting (the loot context has none), the stroll speed 0.6 and look goals.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-13-1.
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
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CREAKING-TYPE       BINARY-LONG.
 01 WS-GOLEM-TYPE          BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
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
 01 WS-FSIZE               BINARY-LONG VALUE 32.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-AMOUNT              BINARY-LONG VALUE 100.
 01 WS-CAUSE-PLAYER        BINARY-LONG VALUE 3.
 01 WS-CAUSE-FALL          BINARY-LONG VALUE 1.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-GOLEM-HEALTH        BINARY-LONG.
 01 WS-KEY40               PIC X(40).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "N" TO TL-MODE
     MOVE "minecraft:vindicator" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CREAKING-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:iron_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-GOLEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 16
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 16
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND

*>   The axe.
     COMPUTE WS-X0 = WS-X - 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-MOB
     MOVE "acceptance US15 20§13.1 Vindicator holds an iron axe" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HAND(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-HAND-KEY" USING EN-HAND(WS-MOB) WS-KEY40
     MOVE "acceptance US15 20§13.1 Vindicator main hand item key" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "minecraft:iron_axe" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

*>   Avoid creaking: a creaking 4 blocks east of it: it moves west (away). A creaking 12 blocks away: no flight.
     COMPUTE WS-X0 = WS-X - 10
     COMPUTE WS-OTHER = 0
     MOVE WS-X0 TO EN-X(WS-MOB)
     COMPUTE WS-X0 = WS-X0 + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-CREAKING-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-OTHER
     COMPUTE WS-X0 = WS-X - 10
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE 0 TO EN-HEALTH-MILLI(WS-OTHER)
         COMPUTE EN-X(WS-OTHER) = WS-X0 + 4
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator flees a creaking within 8 blocks" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "away" TO TL-EXPECTED
     MOVE "stayed" TO TL-OBSERVED
     IF EN-X(WS-MOB) < WS-X0
         MOVE "away" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-OTHER
     COMPUTE WS-X0 = WS-X - 10
     MOVE WS-X0 TO EN-X(WS-MOB)
     COMPUTE WS-X0 = WS-X0 + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-CREAKING-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-OTHER
     COMPUTE WS-X0 = WS-X - 10
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE EN-X(WS-OTHER) = WS-X0 + 12
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator does not flee a creaking 12 blocks away" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "stayed" TO TL-EXPECTED
     MOVE "away" TO TL-OBSERVED
     IF EN-X(WS-MOB) >= WS-X0 - 0.5
         MOVE "stayed" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-OTHER

*>   Target 3: an iron golem within 12 blocks in sight: walked to and hit for 5.
     COMPUTE WS-X0 = WS-X - 10
     MOVE WS-X0 TO EN-X(WS-MOB)
     COMPUTE WS-X0 = WS-X0 + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-GOLEM-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-OTHER
     MOVE EN-HEALTH(WS-OTHER) TO WS-GOLEM-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         COMPUTE EN-X(WS-OTHER) = WS-X0
         MOVE 0 TO EN-VX(WS-OTHER) EN-VZ(WS-OTHER)
         CALL "MOB-STEP" USING WS-MOB
         CALL "MOB-STEP" USING WS-OTHER
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator walks to an iron golem and hits it" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "hit" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-HEALTH(WS-OTHER) < WS-GOLEM-HEALTH
         MOVE "hit" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-OTHER

*>   An iron golem 20 blocks away is outside the follow range 12: no hit.
     COMPUTE WS-X0 = WS-X - 10
     MOVE WS-X0 TO EN-X(WS-MOB)
     COMPUTE WS-X0 = WS-X0 + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-GOLEM-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-OTHER
     MOVE EN-HEALTH(WS-OTHER) TO WS-GOLEM-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         COMPUTE EN-X(WS-OTHER) = WS-X0
         MOVE 0 TO EN-VX(WS-OTHER) EN-VZ(WS-OTHER)
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator ignores an iron golem beyond its follow range" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "untouched" TO TL-EXPECTED
     MOVE "hit" TO TL-OBSERVED
     IF EN-HEALTH(WS-OTHER) = WS-GOLEM-HEALTH
         MOVE "untouched" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-OTHER
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Drops: killed by a player: 0 or 1 emerald each time; killed by a fall: none.
     MOVE 0 TO WS-TOTAL WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-I TO WS-SEED
         COMPUTE WS-X0 = WS-X - 8
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
         PERFORM COUNT-EMERALDS
         ADD WS-COUNT TO WS-TOTAL
         IF WS-COUNT > WS-MAX
             MOVE WS-COUNT TO WS-MAX
         END-IF
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ITEM(WS-E) = WS-EMERALD
                 CALL "ENTITY-REMOVE" USING WS-E
             END-IF
         END-PERFORM
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator emerald count is at most 1 per kill" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MAX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.1 Vindicator drops an emerald in some kills by a player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL > 0 AND WS-TOTAL < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         COMPUTE WS-X0 = WS-X - 8
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE-FALL WS-NO-PLAYER
         PERFORM COUNT-EMERALDS
         ADD WS-COUNT TO WS-TOTAL
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.1 Vindicator drops no emerald when no player killed it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-EMERALDS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-ITEM(WS-E) = WS-EMERALD
             ADD EN-ITEM-COUNT(WS-E) TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-13-1.
 COPY CORETEST.
 COPY MOBSPTEST.
