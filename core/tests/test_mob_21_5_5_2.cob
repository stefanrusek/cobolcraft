*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.5.2): the piglin brute. Row (health 50, attack 7, follow range 12, experience 20, no natural
*> spawn: placed by bastions, open question 3); it attacks a player in range whatever armor the player wears and hits for 7.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-GOLD-KEY            PIC X(112) VALUE "minecraft:golden_helmet".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-GOLD                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "CONTENT-ITEM-BY-KEY" USING WS-GOLD-KEY WS-GOLD WS-ITEM-ROW WS-STATUS
     MOVE "piglin_brute" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE "acceptance US15 minecraft:piglin_brute has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 41 AND SM-KEY(WS-M) = "piglin_brute"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.2 minecraft:piglin_brute max health 50" TO WS-CASE
     MOVE 50 TO WS-EXP
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.2 minecraft:piglin_brute attack 7, follow 12, experience 20" TO WS-CASE
     MOVE 39 TO WS-EXP
     COMPUTE WS-OBS = SM-ATTACK(WS-M) + SM-FOLLOW(WS-M) + SM-XP(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.2 minecraft:piglin_brute has no natural spawn rule and is never neutral" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = SM-SPAWN(WS-M) + SM-NEUTRAL(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A player in golden armor is still its target.
     MOVE WS-GOLD TO MN-EQUIP-ITEM(WS-PLAYER, 1)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 1)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 3
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     CALL "TEST-FLOOR-HERE" USING WS-DIM WS-BX WS-BY WS-BZ
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-Y = FUNCTION INTEGER(WS-Y)
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-A
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.2 a brute targets a player wearing gold" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-TARGET(WS-A)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-A)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-A)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-A)
     MOVE 0 TO EN-COOLDOWN(WS-A)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.2 a brute in reach hits for 7 points" TO WS-CASE
     MOVE 13 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 1)
     GOBACK.
 END PROGRAM TEST-MOB-21-5-5-2.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
