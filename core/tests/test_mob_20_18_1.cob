*> Acceptance test (002-lane-p49b; docs/protocol/20 section 18.1): the giant. Entity giant, max health 100, attack damage 50, experience 5 (the default of a
*> Monster), a monster that spawns by summon only (no natural spawn rule) and that is inert: no goals and no targets are registered, so it never takes a target,
*> never hits and never strolls.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-18-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-GIANT               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-HEALTH0             FLOAT-SHORT.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 12.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:giant" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE "acceptance US15 minecraft:giant is a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE "acceptance US15 20§18.1 Giant health, attack, xp, kind, spawn, burns" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 100 * 1000000 + 50 * 10000 + 5 * 100 + 10 + 0
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-INDEX) * 1000000 + SM-ATTACK(WS-INDEX) * 10000 + SM-XP(WS-INDEX) * 100
         + SM-KIND(WS-INDEX) * 10 + SM-SPAWN(WS-INDEX) + SM-BURNS(WS-INDEX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Inert: a giant 3 blocks from a survival player in the dark or light takes no target, does not hit and does not stroll.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     COMPUTE WS-X0 = WS-X + 3
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 4
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 6
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE WS-Z TO WS-Z0
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-GIANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         CALL "MOB-STEP" USING WS-GIANT
     END-PERFORM
     MOVE "acceptance US15 20§18.1 Giant takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-GIANT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§18.1 Giant does not hit the player" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "unhurt" TO TL-EXPECTED
     MOVE "hurt" TO TL-OBSERVED
     IF PL-HEALTH(WS-PLAYER) = WS-HEALTH0
         MOVE "unhurt" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§18.1 Giant does not walk" TO TL-CASE
     MOVE "still" TO TL-EXPECTED
     MOVE "moved" TO TL-OBSERVED
     IF EN-X(WS-GIANT) = WS-X0 AND EN-Z(WS-GIANT) = WS-Z0
         MOVE "still" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-18-1.
 COPY CORETEST.
 COPY MOBSPTEST.
