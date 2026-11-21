*> Implementation test (002-lane-mobsfull-h3; docs/protocol/20 sections 4.2, 4.3, 5, 7.2 and 19.3): the rows of the zombie villager (row 10), husk (11),
*> stray (12), bogged (13), parched (14) and cave spider (15) in core/copy/STDMOBS.cpy; the husk's melee hit gives Hunger for 140 x floor(effective difficulty)
*> ticks (4.3), the cave spider's gives Poison for 7 s on Normal, 15 s on Hard and nothing on Easy (7.2); the natural spawner takes the species
*> that have a row (MS6-SPECIES) and skips those that have none; surface monsters (husk, parched, stray) need open sky (3.3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-ROWS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY EFFECTS.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PX                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 8.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-OK                 BINARY-LONG.
 01 WS-FEET               BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-ROWNO              BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-NAMES.
    05 FILLER              PIC X(15) VALUE "zombie_villager".
    05 FILLER              PIC X(15) VALUE "husk".
    05 FILLER              PIC X(15) VALUE "stray".
    05 FILLER              PIC X(15) VALUE "bogged".
    05 FILLER              PIC X(15) VALUE "parched".
    05 FILLER              PIC X(15) VALUE "cave_spider".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(15) OCCURS 6 TIMES.
 01 WS-HEALTHS.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 16.
    05 FILLER              BINARY-LONG VALUE 16.
    05 FILLER              BINARY-LONG VALUE 12.
 01 WS-HEALTH-TABLE REDEFINES WS-HEALTHS.
    05 WS-HEALTH           BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
         STRING "acceptance US15 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " is row " DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = 9 + WS-I
         MOVE WS-INDEX TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 minecraft:" DELIMITED BY SIZE WS-NAME(WS-I) DELIMITED BY SPACE
             " max health" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-HEALTH(WS-I) TO TL-EXPECTED-N
         CALL "STDMOB-HEALTH" USING WS-TYPE TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
     END-PERFORM
     MOVE "acceptance US15 20§4.3 Husk: not sun-sensitive; 4.2 zombie villager burns" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 + SM-BURNS(10) * 10 + SM-BURNS(11)
     MOVE 20 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§19.3 species with a row spawn, others do not" TO TL-CASE
     MOVE "husk" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-INDEX
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "witch" TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-INDEX
     MOVE "acceptance US15 20§19.3 witch spawns by the monster rule (row 42)" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hits: the mob stands 0.9 east of the player at attack timer 0.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 0.9
     MOVE "minecraft:husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) EN-COOLDOWN(WS-MOB)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§4.3 Husk: a hit gives Hunger for 140 ticks (effective difficulty 1.5)" TO TL-CASE
     MOVE 140 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, 17) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

     MOVE "minecraft:cave_spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-I TO BW-DIFFICULTY
         MOVE 0 TO EF-ON(WS-PLAYER, 19) EF-DURATION(WS-PLAYER, 19)
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) EN-COOLDOWN(WS-MOB)
         MOVE 1 TO EN-TARGET(WS-MOB)
         MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
         MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
         MOVE 6000 TO CW-TIME
         CALL "MOB-STEP" USING WS-MOB
         EVALUATE WS-I
             WHEN 1
                 MOVE "acceptance US15 20§7.2 Cave spider: no Poison on Easy" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "acceptance US15 20§7.2 Cave spider: Poison for 7 s on Normal" TO TL-CASE
                 MOVE 140 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "acceptance US15 20§7.2 Cave spider: Poison for 15 s on Hard" TO TL-CASE
                 MOVE 300 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE EF-DURATION(WS-PLAYER, 19) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM

*>   Surface rule (3.3): at night a husk stands on a floor under open sky but not in a cave; a zombie passes in the cave too.
     MOVE 18000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-PX WS-PZ WS-SIZE WS-FY WS-KIND
     MOVE 11 TO WS-ROWNO
     PERFORM COUNT-PASSES
     MOVE "acceptance US15 20§3.3 surface monsters: a husk passes under open sky" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF WS-PASS > 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-FY = WS-PY - 40
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-PX WS-PZ WS-SIZE WS-FY WS-KIND
     PERFORM COUNT-PASSES
     MOVE "acceptance US15 20§3.3 surface monsters: a husk never passes underground" TO TL-CASE
     MOVE "no" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF WS-PASS > 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-ROWNO
     PERFORM COUNT-PASSES
     MOVE "acceptance US15 20§3.3 surface monsters: a zombie passes underground in the dark" TO TL-CASE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF WS-PASS > 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-PASSES.
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         COMPUTE WS-FEET = WS-FY + 1
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-ROWNO WS-PX WS-FEET WS-PZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
 END PROGRAM TEST-MOB-20-ROWS.
 COPY CORETEST.
 COPY MOBSPTEST.
