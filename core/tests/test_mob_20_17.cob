*> Acceptance test (002-lane-p49b; docs/protocol/20 section 17): the creaking's table row and melee. Entity creaking: max health 1, movement speed 0.4, attack damage 3,
*> follow range 32, experience 0 (no points: SM-XP -1), no natural spawn here (not in a biome list), a monster. Melee in the fight activity has a cooldown of 40 ticks
*> (a zombie's is 20). NOT here (named in the lane report): the freeze-when-watched rule (`isLookingAtMe` has no formula in the document), the heart binding.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17.
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
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 16.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-HITS                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-ZM                  BINARY-LONG.
 01 WS-GAP                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE "acceptance US15 minecraft:creaking is a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE "acceptance US15 20§17 Creaking health, attack, follow, kind, spawn, xp" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 10000000 + 3 * 100000 + 32 * 1000 + 10 + 0
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-INDEX) * 10000000 + SM-ATTACK(WS-INDEX) * 100000 + SM-FOLLOW(WS-INDEX) * 1000
         + SM-KIND(WS-INDEX) * 10 + SM-SPAWN(WS-INDEX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§17 Creaking gives no experience" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE SM-XP(WS-INDEX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§17 Creaking speed 0.4 (squared / 0.454)" TO TL-CASE
     MOVE 352 TO TL-EXPECTED-N
     MOVE SM-WALK-MILLI(WS-INDEX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Melee: a creaking next to a survival player hits every 40 ticks (the player's hurt window counts down by hand: no world tick runs).
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 8
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 8
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     MOVE 0 TO WS-HITS WS-FIRST WS-SECOND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100 OR WS-HITS = 2
         IF PL-HURT-COOLDOWN(WS-PLAYER) > 0
             SUBTRACT 1 FROM PL-HURT-COOLDOWN(WS-PLAYER)
         END-IF
         CALL "MOB-STEP" USING WS-MOB
         IF PL-HEALTH(WS-PLAYER) < WS-HEALTH
             ADD 1 TO WS-HITS
             MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
             IF WS-HITS = 1
                 MOVE WS-I TO WS-FIRST
             ELSE
                 MOVE WS-I TO WS-SECOND
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§17 Creaking melee cooldown 40 ticks" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SECOND - WS-FIRST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-ZM
     CALL "STDMOB-ATTACK-GAP" USING WS-ZM WS-GAP
     MOVE "acceptance US15 20§17 A zombie keeps the melee gap 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-GAP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-17.
 COPY CORETEST.
 COPY MOBSPTEST.
