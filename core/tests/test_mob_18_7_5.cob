*> Implementation test (002-lane-mobsfull-h15; docs/protocol/18 section 7.5 dropAllDeathLoot steps 2 and 4): a standard mob killed by a player drops its loot and
*> its experience; with the game rule mob_drops false it drops neither (the Entity Event 3 and the 20 dying ticks stay).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_drops".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 6000 TO CW-TIME
*>   The rule is on by default: a zombie killed by the player gives its 5 experience points as an orb.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW)
     PERFORM COUNT-ROWS
     MOVE WS-OBS TO WS-BEFORE
     CALL "STDMOB-DIE" USING WS-ROW
     PERFORM COUNT-ROWS
     MOVE WS-OBS TO WS-AFTER
     MOVE "acceptance US15 18§7.5 Death: with mob_drops on a player kill drops the experience orb" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-AFTER > WS-BEFORE
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Rule off: nothing drops, the mob is still dying (health 0, Entity Event 3).
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW)
     PERFORM COUNT-ROWS
     MOVE WS-OBS TO WS-BEFORE
     CALL "STDMOB-DIE" USING WS-ROW
     PERFORM COUNT-ROWS
     MOVE WS-OBS TO WS-AFTER
     MOVE "acceptance US15 18§7.5 Death: with mob_drops off nothing drops and no experience" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-BEFORE WS-AFTER
     MOVE "acceptance US15 18§7.5 Death: the mob is still dying (health 0)" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-HEALTH(WS-ROW)
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     STOP RUN.
 COUNT-ROWS.
     MOVE 0 TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         IF EN-USED(WS-I) = 1
             ADD 1 TO WS-OBS
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-18-7-5.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
