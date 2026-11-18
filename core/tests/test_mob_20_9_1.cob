*> Implementation test (002-lane-mobsfull-h8; docs/protocol/20 sections 9.1 Silverfish and 9.2 Infested blocks): row 28 (health 8, attack 1, xp 5,
*> no natural spawn), hurt by a player starts the wake-up timer (20 ticks), at its end infested blocks within the box (10, 5, 10) are destroyed
*> and each lets a silverfish out, the scan stopping after a block with probability 1/2; breaking an infested block lets one out (no other block does).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-9-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE "minecraft:silverfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE "acceptance US15 20§9.1 Silverfish: it is table row 34" TO WS-CASE
     MOVE 34 TO WS-EXP
     MOVE WS-M TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§9.1 Silverfish: health 8, attack 1, experience 5, monster, no natural spawn" TO WS-CASE
     MOVE 8015 TO WS-EXP
     COMPUTE WS-OBS = SM-HEALTH(WS-M) * 1000 + SM-ATTACK(WS-M) * 10 + SM-XP(WS-M)
     IF SM-KIND(WS-M) NOT = 1 OR SM-SPAWN(WS-M) NOT = 0
         MOVE -1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE "minecraft:infested_stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE-STATE
*>   Not hurt: no timer. A silverfish and three infested blocks 3 to 5 blocks away.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 3 BY 1 UNTIL WS-I > 5
         COMPUTE WS-PX = WS-BX + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-STATE
     END-PERFORM
     CALL "STDMOB-SILVERFISH-HURT" USING WS-ROW WS-NONE
     MOVE "acceptance US15 20§9.1 Silverfish: damage with no attacker does not wake the friends" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-WAKE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 20§9.1 Silverfish: a hit by a player sets the wake-up timer to 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-WAKE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM COUNT-SILVERFISH
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "STDMOB-SILVERFISH-WAKE" USING WS-ROW
     END-PERFORM
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.1 Silverfish: nothing is destroyed before the timer ends" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "STDMOB-SILVERFISH-WAKE" USING WS-ROW
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.1 Silverfish: at 0 infested blocks break and let 1 to 3 silverfish out" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-COUNT > WS-BEFORE AND WS-COUNT <= WS-BEFORE + 3
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§9.1 Silverfish: the nearest infested block (3 away) is gone" TO WS-CASE
     COMPUTE WS-PX = WS-BX + 3
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-BY WS-BZ WS-OBS
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A tick of the mob (MOB-STEP) with no timer leaves the blocks alone.
     CALL "MOB-STEP" USING WS-ROW
*>   Breaking an infested block lets one silverfish out; breaking stone does not.
     PERFORM COUNT-SILVERFISH
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BLOCK WS-NONE
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.2 Infested blocks: breaking one lets a silverfish out" TO WS-CASE
     COMPUTE WS-EXP = WS-BEFORE + 1
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     CALL "STDMOB-INFESTED-BREAK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BLOCK WS-NONE
     PERFORM COUNT-SILVERFISH
     MOVE "acceptance US15 20§9.2 Infested blocks: breaking plain stone lets none out" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     ADD 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 COUNT-SILVERFISH.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-FOUND FROM 1 BY 1 UNTIL WS-FOUND > EN-COUNT
         IF EN-USED(WS-FOUND) = 1 AND EN-TYPE(WS-FOUND) = WS-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-9-1.

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
