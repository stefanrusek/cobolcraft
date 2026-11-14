*> Implementation test (002-lane-mobsfull-h19; docs/protocol/20 section 8.2 Endermite): the row (health 8, attack 2, XP 3, a monster), the melee hit on a player in reach (generic
*> monster melee, 2 points on Normal) and the lifetime: a non-persistent endermite is discarded when its tick counter reaches 2400.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-8-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-STONE-KIND
     MOVE "minecraft:endermite" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 2 TO BW-DIFFICULTY
     MOVE "acceptance US15 20§8.2 minecraft:endermite has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.2 minecraft:endermite max health 8" TO WS-CASE
     MOVE 8 TO WS-EXP
     MOVE SM-HEALTH(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.2 minecraft:endermite attack damage 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE SM-ATTACK(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.2 minecraft:endermite XP 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE SM-XP(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.2 minecraft:endermite is a monster" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE SM-KIND(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Lifetime: still there at 100, gone when the counter reaches 2400.
     COMPUTE WS-SX = WS-X + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-SX WS-Y WS-Z WS-YAW WS-ROW
     MOVE 100 TO EN-WAKE(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 20§8.2 endermite: the lifetime counter counts up a tick" TO WS-CASE
     MOVE 101 TO WS-EXP
     MOVE EN-WAKE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2398 TO EN-WAKE(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 20§8.2 endermite: alive at counter 2399" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 20§8.2 endermite: discarded when the counter reaches 2400" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Melee: standing next to the player it hits for 2 after the first target tick.
     COMPUTE WS-SX = WS-X + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-SX WS-Y WS-Z WS-YAW WS-ROW
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "MOB-STEP" USING WS-ROW
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 20§8.2 endermite: a melee hit does 2 damage" TO WS-CASE
     MOVE 18 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-MOB-20-8-2.

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
