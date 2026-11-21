*> Implementation test (002-lane-mobsfull-h19; docs/protocol/44 part 8 section 6.4 and 6.5, 21 sections 5.1 and 5.2, 19 section 20, 17 section 3.15): the generic
*> projectile entity of core/src/mob-21-proj.cob: large fireball, small fireball and snowball (the shulker bullet is test_mob_21_6_2).
*> Fireball motion v = (v + normalize(v) x 0.1) x 0.95 from a start of 0.1; snowball gravity 0.03 and drag 0.99; a direct hit does 6 (fireball),
*> 5 and 5 seconds of fire (small fireball), 0 (snowball); a fireball explodes with its power, a small fireball sets fire on the hit face, a projectile
*> whose owner is gone or whose chunk is not loaded is discarded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-PROJ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-DIRT                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DESTROYED           BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-GONE-ID             BINARY-LONG VALUE 999999.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BASE-Y              BINARY-LONG.
 01 WS-OWNER-ROW           BINARY-LONG.
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
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-DIRT
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FIRE
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 2 TO BW-DIFFICULTY
*>   The kinds have their own entity types.
     MOVE 1 TO WS-KIND
     CALL "PROJ-TYPE" USING WS-KIND WS-T1
     MOVE 2 TO WS-KIND
     CALL "PROJ-TYPE" USING WS-KIND WS-T2
     MOVE 3 TO WS-KIND
     CALL "PROJ-TYPE" USING WS-KIND WS-T3
     MOVE "acceptance US15 21§5.1 fireball, small_fireball, snowball are three types" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-T1 > 0 AND WS-T2 > 0 AND WS-T3 > 0 AND WS-T1 NOT = WS-T2 AND WS-T2 NOT = WS-T3 AND WS-T1 NOT = WS-T3
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   A fireball in free air: starts at 0.1 along the direction, then v = (v + 0.1) x 0.95 and the position moves by the new v (44-8 section 6.4, 12.6).
     COMPUTE WS-X0 = WS-X + 2
     COMPUTE WS-Y = WS-Y + 6
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-POWER
     MOVE 0 TO WS-OWNER
     MOVE 1 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     MOVE "acceptance US15 21§5.1 fireball: the type of the row is the fireball type" TO WS-CASE
     MOVE WS-T1 TO WS-EXP
     MOVE EN-TYPE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 fireball: launched with speed 0.1 (ten-thousandths)" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PROJ-STEP" USING WS-ROW
     MOVE "acceptance US15 21§5.1 fireball: after tick 1 the speed is 0.19" TO WS-CASE
     MOVE 1900 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 fireball: after tick 1 it moved by 0.19" TO WS-CASE
     MOVE 1900 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-X(WS-ROW) - WS-X0) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PROJ-STEP" USING WS-ROW
     MOVE "acceptance US15 21§5.1 fireball: after tick 2 the speed is 0.2755" TO WS-CASE
     MOVE 2755 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The row of a projectile whose owner entity is gone is discarded by the tick (44-8 section 6.4 step 2); an owner of 0 has none to lose.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE WS-GONE-ID TO WS-OWNER
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 44-8§6.4 a projectile whose owner is gone is discarded" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   One owned by a living entity (the player) flies on through PROJECTILES-TICK.
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-OWNER
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 44-8§6.4 a projectile of a living owner is stepped by the tick" TO WS-CASE
     MOVE 1900 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-X(WS-ROW) - WS-X0) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   In a chunk that is not loaded it is discarded.
     COMPUTE WS-X0 = WS-X + 5000
     MOVE 0 TO WS-OWNER
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 44-8§6.4 a projectile in an unloaded chunk is discarded" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   An owner that is a mob (a cow far from the action) for the flights below.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-X0 = WS-X - 18
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-OWNER-ROW
     MOVE EN-ID(WS-OWNER-ROW) TO WS-OWNER
*>   A fireball that hits the player: hurt, the fireball gone.
     COMPUTE WS-X0 = WS-X + 3
     COMPUTE WS-Y = WS-Y + 1
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     COMPUTE WS-DX = -1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§5.1 large fireball: a hit on a player hurts it" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PL-HEALTH(WS-PLAYER) < 20 AND EN-USED(WS-ROW) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
*>   A fireball that hits a cow: 6 direct damage (and the explosion), the fireball is gone.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-X0 = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-COW
     MOVE 10 TO EN-HEALTH(WS-COW)
     COMPUTE WS-X0 = WS-X - 3
     COMPUTE WS-Y = WS-Y + 0.5
     COMPUTE WS-DX = -1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§5.1 large fireball: a direct hit removes the fireball" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.1 large fireball: a direct hit does at least 6" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-HEALTH(WS-COW) <= 4
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   A fireball into a dirt wall: the explosion destroys dirt; with mob_griefing false the wall stays.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 1
         MOVE 0 TO WS-DESTROYED
         PERFORM VARYING WS-BX FROM 6 BY 1 UNTIL WS-BX > 6
             PERFORM VARYING WS-BY FROM 0 BY 1 UNTIL WS-BY > 2
                 PERFORM VARYING WS-BZ FROM -1 BY 1 UNTIL WS-BZ > 1
                     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) + WS-BX
                     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-BY
                     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-BZ
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-DIRT
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         COMPUTE WS-BASE-Y = FUNCTION INTEGER(WS-Y)
         MOVE "mob_griefing" TO WS-RULE-NAME
         CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
         MOVE WS-J TO WS-RULE-VALUE
         CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
         COMPUTE WS-X0 = WS-X + 2.5
         COMPUTE WS-Y = WS-Y + 1.5
         MOVE 1 TO WS-DX
         CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR EN-USED(WS-ROW) = 0
             CALL "PROJ-STEP" USING WS-ROW
         END-PERFORM
         PERFORM VARYING WS-BY FROM 0 BY 1 UNTIL WS-BY > 2
             PERFORM VARYING WS-BZ FROM -1 BY 1 UNTIL WS-BZ > 1
                 COMPUTE WS-FX = FUNCTION INTEGER(WS-X) + 6
                 COMPUTE WS-FY = WS-BASE-Y + WS-BY
                 COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-BZ
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
                 IF WS-STATE NOT = WS-DIRT
                     ADD 1 TO WS-DESTROYED
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE 1 TO WS-EXP
         MOVE 0 TO WS-OBS
         IF WS-J = 1
             MOVE "acceptance US15 21§5.1 large fireball: the explosion destroys blocks of the wall" TO WS-CASE
             IF WS-DESTROYED > 0
                 MOVE 1 TO WS-OBS
             END-IF
         ELSE
             MOVE "acceptance US15 21§5.1 large fireball: with mob_griefing false the wall stays" TO WS-CASE
             MOVE 0 TO WS-EXP
             MOVE WS-DESTROYED TO WS-OBS
         END-IF
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
         COMPUTE WS-Y = WS-Y - 1.5
     END-PERFORM
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   A small fireball hits a cow: 5 damage and 5 seconds of fire (100 ticks).
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-Z = WS-Z + 6
     COMPUTE WS-X0 = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-COW
     MOVE 10 TO EN-HEALTH(WS-COW)
     MOVE 2 TO WS-KIND
     COMPUTE WS-X0 = WS-X - 4
     COMPUTE WS-Y = WS-Y + 0.5
     MOVE 1 TO WS-DX
     COMPUTE WS-DX = -1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§5.2 small fireball: a hit on a mob does 5 damage" TO WS-CASE
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS = 10 - EN-HEALTH(WS-COW)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 small fireball: the mob burns 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-BURN(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 small fireball: any hit discards the projectile" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A small fireball on the player: 5 damage.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 3
     COMPUTE WS-Y = WS-Y + 1
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 21§5.2 small fireball: a hit on a player does 5 damage" TO WS-CASE
     MOVE 15 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Into a stone wall: a fire block in the free cell in front of the hit face.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-Z = WS-Z + 3
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 3
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + 1
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
     COMPUTE WS-X0 = WS-X + 3
     COMPUTE WS-Y = WS-Y + 1.5
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     COMPUTE WS-FX = WS-FX + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE "acceptance US15 21§5.2 small fireball: a block hit sets fire in front of the face" TO WS-CASE
     MOVE WS-FIRE TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   With mob_griefing false no fire.
     MOVE "mob_griefing" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STATE
     MOVE "acceptance US15 21§5.2 small fireball: with mob_griefing false no fire is set" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE

*>   A snowball: gravity 0.03 then drag 0.99; a hit on a cow does no damage and the snowball is gone (17 section 3.15).
     MOVE 3 TO WS-KIND
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X + 2
     COMPUTE WS-Y = WS-Y + 6
     MOVE 1 TO WS-DX
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     MOVE "acceptance US15 19§20 snowball: launched with speed 1.6 along the direction" TO WS-CASE
     MOVE 16000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "PROJ-STEP" USING WS-ROW
     MOVE "acceptance US15 44-8§6.5 snowball: drag 0.99 on x after one tick" TO WS-CASE
     MOVE 15840 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VX(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§6.5 snowball: gravity then drag give vy = -0.0297" TO WS-CASE
     MOVE -297 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Y = WS-Y + 0.5
     COMPUTE WS-Z = WS-Z - 6
     COMPUTE WS-X0 = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-COW
     MOVE 10 TO EN-HEALTH(WS-COW)
     COMPUTE WS-X0 = WS-X - 3
     COMPUTE WS-Y = WS-Y + 0.5
     COMPUTE WS-DX = -1
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X0 WS-Y WS-Z WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0
         CALL "PROJ-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 17§3.15 snowball: a hit removes the snowball" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 17§3.15 snowball: a hit on a cow does no damage" TO WS-CASE
     MOVE 10 TO WS-EXP
     MOVE EN-HEALTH(WS-COW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-MOB-21-PROJ.

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
