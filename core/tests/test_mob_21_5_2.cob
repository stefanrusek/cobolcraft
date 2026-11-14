*> Implementation test (002-lane-mobsfull-h19; docs/protocol/21 section 5.2 Blaze and small fireball with doc 44 part 6 section 9.2, 17 section 3.15): the blaze row
*> (health 20, attack 6, follow range 48, XP 10), the attack goal (attackTime 60 with the charged flag, three small fireballs 6 ticks apart, a pause of 100; a melee hit
*> within 2 blocks; nothing without line of sight), the height keeping (vy += (0.3 - vy) x 0.3 when the target's eyes are above eyeY + the offset) and the glide
*> (vy x 0.6 while falling), and the snowball that hurts a blaze for 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FB-TYPE             BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-M                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FB                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GX                  FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-GZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-STONE-KIND          BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-SNOW-KIND           BINARY-LONG VALUE 3.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG VALUE 1.
 01 WS-DY                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
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
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:blaze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "PROJ-TYPE" USING WS-KIND WS-FB-TYPE
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 2 TO BW-DIFFICULTY

     MOVE "acceptance US15 21§5.2 minecraft:blaze has a species row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-M > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 minecraft:blaze max health 20" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE SM-HEALTH(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 minecraft:blaze attack damage 6" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE SM-ATTACK(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 minecraft:blaze follow range 48" TO WS-CASE
     MOVE 48 TO WS-EXP
     MOVE SM-FOLLOW(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 minecraft:blaze XP 10" TO WS-CASE
     MOVE 10 TO WS-EXP
     MOVE SM-XP(WS-M) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 minecraft:blaze is a monster that does not burn" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF SM-KIND(WS-M) = 1 AND SM-BURNS(WS-M) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   The attack cycle at 8 blocks with a clear line: the blaze west of the player.
     COMPUTE WS-GX = WS-X - 8
     MOVE WS-Y TO WS-GY
     MOVE WS-Z TO WS-GZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.2 blaze: tick 1 starts step 1 with attackTime 60" TO WS-CASE
     MOVE 60 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the charged flag is on in step 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the charged flag goes to the viewers as metadata index 16" TO WS-CASE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 60
         CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: no fireball during the 60 ticks of charging" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: the first fireball on tick 61 (step 2)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: attackTime 6 after a fireball step" TO WS-CASE
     MOVE 6 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the small fireball starts at half height + 0.5 (y + 1.4)" TO WS-CASE
     MOVE 14 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-Y(WS-FB) - EN-Y(WS-ROW)) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the small fireball starts at the blaze's x" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER((EN-X(WS-FB) - EN-X(WS-ROW)) * 10 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the small fireball flies toward the player (vx > 0)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-VX(WS-FB) > 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the blaze owns the small fireball" TO WS-CASE
     MOVE EN-ID(WS-ROW) TO WS-EXP
     MOVE EN-TARGET-ID(WS-FB) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: the second fireball 6 ticks later (step 3)" TO WS-CASE
     MOVE 2 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: the third fireball 6 ticks later (step 4)" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: step 5 fires nothing and resets the cycle" TO WS-CASE
     MOVE 3 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the pause is 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the charged flag is off after the cycle" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-VARIANT(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: attackStep is back to 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-DRAW(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-OK FROM 1 BY 1 UNTIL WS-OK > EN-COUNT
         IF EN-USED(WS-OK) = 1 AND EN-TYPE(WS-OK) = WS-FB-TYPE
             CALL "ENTITY-REMOVE" USING WS-OK
         END-IF
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Within 2 blocks (distance squared below 4) the blaze hits in melee: attackTime 20.
     COMPUTE WS-GX = WS-X - 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.2 blaze: a melee hit within 2 blocks hurts the player" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: attackTime 20 after a melee hit" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.2 blaze: no second melee hit while attackTime runs" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   No line of sight (a wall between): nothing is fired and the cycle waits.
     COMPUTE WS-GX = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 4
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-I
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-STONE
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     END-PERFORM
     PERFORM COUNT-FIREBALLS
     MOVE "acceptance US15 21§5.2 blaze: no fireball without line of sight" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: lastSeen counts the ticks without sight" TO WS-CASE
     MOVE 80 TO WS-EXP
     MOVE EN-SWELL(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) + WS-I
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-FY WS-FZ WS-AIR
         END-PERFORM
     END-PERFORM
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.2 blaze: seeing the target again resets lastSeen" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-SWELL(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A blaze with no target does nothing.
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     MOVE 5 TO EN-SHOOT-TIME(WS-ROW)
     CALL "BLAZE-ATTACK" USING WS-ROW WS-M
     MOVE "acceptance US15 21§5.2 blaze: no target, no timer" TO WS-CASE
     MOVE 5 TO WS-EXP
     MOVE EN-SHOOT-TIME(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   Height keeping: offset 0 (no new draw for 50 ticks), the player's eyes 10 above the blaze's: vy becomes (0.3 - 0) x 0.3 = 0.09.
     COMPUTE WS-GX = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW)
     COMPUTE PL-Y(WS-PLAYER) = WS-Y + 10
     MOVE 0 TO EN-PH-HEIGHT(WS-ROW)
     MOVE 50 TO EN-WAKE(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     MOVE 0 TO EN-ON-GROUND(WS-ROW)
     CALL "BLAZE-HEIGHT" USING WS-ROW
     MOVE "acceptance US15 21§5.2 blaze: a target above its height offset lifts it (vy 0.09)" TO WS-CASE
     MOVE 900 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the height counter counts down" TO WS-CASE
     MOVE 49 TO WS-EXP
     MOVE EN-WAKE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The offset is drawn again when the counter runs out: 100 ticks and an offset within 0.5 +- 6.891.
     MOVE 1 TO EN-WAKE(WS-ROW)
     CALL "BLAZE-HEIGHT" USING WS-ROW
     MOVE "acceptance US15 21§5.2 blaze: the counter restarts at 100" TO WS-CASE
     MOVE 100 TO WS-EXP
     MOVE EN-WAKE(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 21§5.2 blaze: the drawn offset lies within -6.391 and 7.391" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-PH-HEIGHT(WS-ROW) >= -6.391 AND EN-PH-HEIGHT(WS-ROW) <= 7.391
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A target below the offset leaves the velocity alone; falling in the air it glides (x 0.6).
     COMPUTE PL-Y(WS-PLAYER) = WS-Y - 3
     MOVE 0 TO EN-PH-HEIGHT(WS-ROW)
     MOVE 50 TO EN-WAKE(WS-ROW)
     MOVE -1 TO EN-VY(WS-ROW)
     CALL "BLAZE-HEIGHT" USING WS-ROW
     MOVE "acceptance US15 21§5.2 blaze: falling in the air glides, vy x 0.6" TO WS-CASE
     MOVE -6000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 - 0.5) + 1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     MOVE -1 TO EN-VY(WS-ROW)
     CALL "BLAZE-HEIGHT" USING WS-ROW
     MOVE "acceptance US15 21§5.2 blaze: on the ground vy is left alone" TO WS-CASE
     MOVE -10000 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 - 0.5) + 1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Without a target the offset still counts but nothing lifts it.
     MOVE 0 TO EN-TARGET(WS-ROW) EN-TARGET-ID(WS-ROW)
     MOVE 0 TO EN-VY(WS-ROW)
     CALL "BLAZE-HEIGHT" USING WS-ROW
     MOVE "acceptance US15 21§5.2 blaze: no target, no lift" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION INTEGER(EN-VY(WS-ROW) * 10000 + 0.5)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   The snowball hurts a blaze for 3 and a cow for 0 (17 section 3.15).
     COMPUTE WS-GX = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-GX WS-GY WS-GZ WS-YAW WS-ROW
     COMPUTE WS-GX = WS-X - 4
     COMPUTE WS-GY = WS-Y + 0.8
     COMPUTE WS-DX = -1
     CALL "PROJ-SPAWN" USING WS-SNOW-KIND WS-DIM WS-GX WS-GY WS-GZ WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-FB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-FB) = 0
         CALL "PROJ-STEP" USING WS-FB
     END-PERFORM
     MOVE "acceptance US15 17§3.15 a snowball hurts a blaze for 3" TO WS-CASE
     MOVE 17 TO WS-EXP
     MOVE EN-HEALTH(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 COUNT-FIREBALLS.
*>   Counts the small fireball rows and leaves the last one in WS-FB.
     MOVE 0 TO WS-COUNT WS-FB
     PERFORM VARYING WS-OK FROM 1 BY 1 UNTIL WS-OK > EN-COUNT
         IF EN-USED(WS-OK) = 1 AND EN-TYPE(WS-OK) = WS-FB-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-OK TO WS-FB
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-21-5-2.

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
