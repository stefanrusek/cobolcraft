*> Acceptance test (002-lane-p49b fork u; docs/protocol/20 section 11): the witch's eyes-in-water test (a witch whose eyes are in water drinks Water Breathing with probability 0.15 a
*> tick; one in the air never does) and the witch particle event (entity event 15 with probability 7.5E-4 a tick: roll below 75 of 100000). Not here: the 0.15 resistance to magic
*> damage (the core has no magic damage kinds), the raider goals (no raid wiring for witches).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-11-MORE.
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
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-GOT                 BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HAS                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "N" TO TL-MODE
     MOVE "minecraft:witch" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 74 TO WS-ROLL
     CALL "STDMOB-WITCH-SPARKLE" USING WS-ROLL WS-HIT
     MOVE "acceptance US15 20§11 Witch particle event: roll 74 of 100000 sends it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 75 TO WS-ROLL
     CALL "STDMOB-WITCH-SPARKLE" USING WS-ROLL WS-HIT
     MOVE "acceptance US15 20§11 Witch particle event: roll 75 of 100000 does not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X = FUNCTION INTEGER(WS-X) + 4.5
     COMPUTE WS-Z = FUNCTION INTEGER(WS-Z) + 0.5
     MOVE WS-Y TO WS-Y

*>   In the air: no Water Breathing in 300 ticks.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 0 TO WS-GOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-X TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE 0 TO EN-HAND(WS-MOB) EN-DRAW(WS-MOB) EN-FX-WATER(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF EN-HAND(WS-MOB) = 5
             MOVE 1 TO WS-GOT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch with its eyes in the air never drinks Water Breathing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Eyes in water (the cell at feet + 1.62 is a water block): Water Breathing within 300 ticks.
     MOVE "minecraft:water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 0 TO WS-GOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR WS-GOT = 1
         MOVE WS-X TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE WS-Y TO EN-Y(WS-MOB)
         MOVE 40 TO EN-HEALTH(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF EN-HAND(WS-MOB) = 5
             MOVE 1 TO WS-GOT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch with its eyes in water drinks Water Breathing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     COMPUTE WS-BY = WS-BY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE

*>   The particle event: one in 1333 ticks on average, entity event 34 to the viewers; the player sees it within 30000 ticks.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE 0 TO WS-GOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30000 OR WS-GOT = 1
         MOVE WS-X TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE WS-Y TO EN-Y(WS-MOB)
         MOVE 0 TO EN-HAND(WS-MOB) EN-DRAW(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF FUNCTION MOD(WS-I, 200) = 0
             CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
             MOVE SPACES TO WS-PADDED
             STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
             MOVE 0 TO WS-HAS
             INSPECT WS-PADDED TALLYING WS-HAS FOR ALL " 34 "
             IF WS-HAS > 0
                 MOVE 1 TO WS-GOT
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§11 Witch broadcasts entity event 15 now and then" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-11-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
