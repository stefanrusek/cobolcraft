*> Implementation test (002-lane-mobsfull-h12; docs/protocol/21 section 5.5.1): the piglin, basics. Row (health 16, attack 5, experience 5, anger-neutral kind 4,
*> spawn rule 11: only the floor test); it attacks a player in range that wears no golden armor piece (safe armor, PiglinSpecificSensor), ignores one that does,
*> and a hit by a player gives it anger of 600 ticks at that player whatever it wears, alerting the other piglins within 16 blocks.
*> PARTIAL: the brain (bartering, admiring, hoglin hunting, crossbow, zombification, equipment) is not modelled.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY CMENU.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
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
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-GOLD-KEY            PIC X(112) VALUE "minecraft:golden_helmet".
 01 WS-IRON-KEY            PIC X(112) VALUE "minecraft:iron_helmet".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-GOLD                BINARY-LONG.
 01 WS-IRON                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "CONTENT-ITEM-BY-KEY" USING WS-GOLD-KEY WS-GOLD WS-ITEM-ROW WS-STATUS
     CALL "CONTENT-ITEM-BY-KEY" USING WS-IRON-KEY WS-IRON WS-ITEM-ROW WS-STATUS
     MOVE "piglin" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-M
     MOVE "acceptance US15 minecraft:piglin has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 41 AND SM-KEY(WS-M) = "piglin"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.1 minecraft:piglin max health 16" TO WS-CASE
     MOVE 16 TO WS-EXP
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.5.1 minecraft:piglin attack 5, experience 5, neutral 4, rule 11" TO WS-CASE
     MOVE 29 TO WS-EXP
     COMPUTE WS-OBS = SM-ATTACK(WS-M) + SM-XP(WS-M) + SM-NEUTRAL(WS-M) * 2 + SM-SPAWN(WS-M)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Safe armor: any golden piece in the four armor slots.
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 1) MN-EQUIP-COUNT(WS-PLAYER, 2) MN-EQUIP-COUNT(WS-PLAYER, 3) MN-EQUIP-COUNT(WS-PLAYER, 4)
     CALL "NETHER-GOLD-WORN" USING WS-PLAYER WS-OBS
     MOVE "acceptance US15 21§5.5.1 a player without armor wears no gold" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-IRON TO MN-EQUIP-ITEM(WS-PLAYER, 1)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 1)
     CALL "NETHER-GOLD-WORN" USING WS-PLAYER WS-OBS
     MOVE "acceptance US15 21§5.5.1 an iron helmet is not safe armor" TO WS-CASE
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-GOLD TO MN-EQUIP-ITEM(WS-PLAYER, 1)
     CALL "NETHER-GOLD-WORN" USING WS-PLAYER WS-OBS
     MOVE "acceptance US15 21§5.5.1 a golden helmet is safe armor" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 1)
*>   A piglin 3 blocks from the player on a stone floor.
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
     MOVE WS-X2 TO EN-X(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.1 a piglin targets a player without gold" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-TARGET(WS-A)
     MOVE WS-GOLD TO MN-EQUIP-ITEM(WS-PLAYER, 2)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 2)
     MOVE WS-X2 TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.1 a piglin ignores a player wearing gold" TO WS-CASE
     MOVE 0 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-TARGET(WS-A)
*>   A hit by the golden player: anger 600 at that player; another piglin within 16 blocks joins, one farther does not.
     COMPUTE WS-X = WS-X2 + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z2 WS-YAW WS-B
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 21§5.5.1 a hit gives anger of 600 ticks at the attacker" TO WS-CASE
     MOVE 600 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-ANGER(WS-A)
     MOVE "acceptance US15 21§5.5.1 the angry piglin targets the golden player" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-TARGET(WS-A)
     MOVE "acceptance US15 21§5.5.1 another piglin within 16 blocks of it is angered too" TO WS-CASE
     MOVE 600 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP EN-ANGER(WS-B)
*>   The anger keeps the target against the gold rule and counts down; at its end the gold rule applies again.
     MOVE 2 TO EN-ANGER(WS-A)
     MOVE 0 TO EN-HURT(WS-A)
     MOVE WS-X2 TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.1 the anger of a piglin counts down and keeps the target" TO WS-CASE
     COMPUTE WS-OBS = EN-ANGER(WS-A) * 10 + EN-TARGET(WS-A) - WS-PLAYER
     MOVE 10 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-X2 TO EN-X(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 21§5.5.1 when the anger ends a golden player is ignored again" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = EN-ANGER(WS-A) + EN-TARGET(WS-A)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 2)
     GOBACK.
 END PROGRAM TEST-MOB-21-5-5-1.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
