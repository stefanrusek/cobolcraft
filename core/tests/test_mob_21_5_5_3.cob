*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.5.3): the zombified piglin. Row (health 20, attack 5, follow range 35, experience 5,
*> neutral kind 3: anger based, spawn rule 10); it takes no target until it is hurt by a player; a hit by a player gives it anger for 20 to 39 seconds
*> (EN-ANGER, a whole number of seconds in ticks) and the target, alerts every other zombified piglin within the follow range (35 horizontally, 10 vertically),
*> an angry one walks 0.05 faster (0.28) and hits; the anger counts down one a tick and ends the target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-5-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/nether-loot".
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-Z2                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-PLAYER.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "LOOT-LOAD" USING WS-LOOT-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "zombified_piglin" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE "acceptance US15 minecraft:zombified_piglin has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 41 AND SM-KEY(WS-M) = "zombified_piglin"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 minecraft:zombified_piglin max health 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 minecraft:zombified_piglin attack damage 5, follow range 35" TO WS-CASE
     MOVE 40 TO WS-EXP
     COMPUTE WS-OBS = SM-ATTACK(WS-M) + SM-FOLLOW(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 minecraft:zombified_piglin is anger-neutral (3), experience 5, rule 10" TO WS-CASE
     MOVE 18 TO WS-EXP
     COMPUTE WS-OBS = SM-NEUTRAL(WS-M) + SM-XP(WS-M) + SM-SPAWN(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A stone floor under the piglin at the player's place.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 3
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     CALL "TEST-FLOOR-HERE" USING WS-DIM WS-BX WS-BY WS-BZ
     COMPUTE WS-X2 = WS-BX + 0.5
     COMPUTE WS-Z2 = WS-BZ + 0.5
     COMPUTE WS-Y = FUNCTION INTEGER(WS-Y)
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X2 WS-Y WS-Z2 WS-YAW WS-A
*>   Calm: no target however near the player is.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-X2 TO EN-X(WS-A)
         MOVE WS-Y TO EN-Y(WS-A)
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 21§5.5.3 a calm zombified piglin takes no target" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = EN-TARGET(WS-A) + EN-ANGER(WS-A)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 a calm zombified piglin walks at 0.23 (117)" TO WS-CASE
     MOVE 117 TO WS-EXP
     CALL "STDMOB-SPEED" USING WS-A WS-M WS-SPEED
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Two more piglins: one 10 blocks away, one 60 blocks away.
     COMPUTE WS-X = WS-X2 + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z2 WS-YAW WS-B
     COMPUTE WS-X = WS-X2 + 60
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z2 WS-YAW WS-C
*>   Hurt by the player: anger of 20 to 39 whole seconds, the target, the alert.
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§5.5.3 a hit by a player gives anger of 20 to 39 whole seconds" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-ANGER(WS-A) >= 400 AND EN-ANGER(WS-A) <= 780 AND FUNCTION MOD(EN-ANGER(WS-A), 20) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 the angry piglin targets the player that hurt it" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-TARGET(WS-A)
     MOVE "acceptance US15 21§5.5.3 another piglin within 35 blocks takes the same anger and target" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-TARGET(WS-B) = WS-PLAYER AND EN-ANGER(WS-B) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 a piglin 60 blocks away is not alerted" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = EN-TARGET(WS-C) + EN-ANGER(WS-C)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 an angry zombified piglin walks at 0.28 (173)" TO WS-CASE
     MOVE 173 TO WS-EXP
     CALL "STDMOB-SPEED" USING WS-A WS-M WS-SPEED
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The anger counts down a tick at a time and ends the target.
     MOVE 3 TO EN-ANGER(WS-A)
     MOVE 0 TO EN-HURT(WS-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-X2 TO EN-X(WS-A)
         MOVE WS-Y TO EN-Y(WS-A)
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 21§5.5.3 the anger counts down one a tick" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-ANGER(WS-A)
     MOVE WS-X2 TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.3 when the anger ends the target ends" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = EN-ANGER(WS-A) + EN-TARGET(WS-A)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Every 4 to 6 seconds an angry piglin alerts again: the piglin B that lost its anger is angered by A's next alert.
     MOVE 0 TO EN-TARGET(WS-B) EN-TARGET-ID(WS-B) EN-ANGER(WS-B)
     MOVE 600 TO EN-ANGER(WS-A)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     MOVE 0 TO EN-ALERT(WS-A)
     MOVE WS-X2 TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.3 the periodic alert angers another piglin in range" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-TARGET(WS-B) = WS-PLAYER AND EN-ANGER(WS-B) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.3 the next alert is 80 to 120 ticks later" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-ALERT(WS-A) >= 80 AND EN-ALERT(WS-A) <= 120
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   An angry piglin beside the player hits it for 5 (Normal).
     MOVE 600 TO EN-ANGER(WS-A)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     MOVE 0 TO EN-COOLDOWN(WS-A)
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-A)
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-A)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-A)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.3 an angry piglin in reach hits for 5 points" TO WS-CASE
     MOVE 15 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A dead target ends the anger.
     MOVE 600 TO EN-ANGER(WS-A)
     MOVE PS-DEAD TO PL-STATE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.3 the anger stops when the target is gone" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = EN-ANGER(WS-A) + EN-TARGET(WS-A)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     GOBACK.
 END PROGRAM TEST-MOB-21-5-5-3.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
