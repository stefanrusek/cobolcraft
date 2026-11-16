*> Implementation test (002-lane-fire, T11100; docs/protocol/17 sections 4.11 and 4.13, 18 section 2.5, 29a section 4.2, 29b-8 section 2.10): a player in a standard world burns.
*> Lava hurts 4.0 and sets the player alight for fifteen seconds (300 ticks), a fire block hurts 1.0 (soul fire 2.0) and sets it alight for eight seconds (160), a burning
*> player takes 1.0 every 20 ticks while the count is a multiple of 20 (not in lava) and the count falls by 1 a tick; water, rain and powder snow put it out; Fire Resistance
*> takes no damage; a creative player neither burns nor is hurt; death clears the fire; the shared flags (entry 0 bit 0) show it; the death messages name the cause.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAYER-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY RULES.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ER                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-SOUL                BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 11.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 6000.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-TEXT-KEY            PIC X(40).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-ER
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FIRE
     MOVE "minecraft:soul_fire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SOUL
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SNOW
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND

     MOVE "acceptance fire: the joined player has a tracker row" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-ER > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK

*>   Lava: 4.0 damage and 300 ticks of fire (17 4.11, 29a 4.2), and the flag shows it.
     PERFORM RESET-PLAYER
     MOVE WS-LAVA TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 17-4.11: a survival player in lava takes 4 damage" TO WS-CASE
     MOVE 16 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 29a-4.2: lava sets the player alight for 300 ticks" TO WS-CASE
     MOVE 300 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: the on-fire bit (entry 0 bit 0) is set in the player's flags" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION MOD(PL-POSE-FLAGS(WS-PLAYER), 2)
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: the viewers were sent the burning state" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-FIRE-SENT(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET

*>   A burning player in the air: 1.0 every 20 ticks from a multiple of 20, the count falling by 1 a tick.
     PERFORM RESET-PLAYER
     MOVE 160 TO EN-BURN(WS-ER)
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: the first burning tick (count 160) takes 1 damage" TO WS-CASE
     MOVE 19 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: the count falls by 1 a tick" TO WS-CASE
     MOVE 159 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     PERFORM 19 TIMES
         CALL "HEALTH-TICK"
     END-PERFORM
     MOVE "acceptance fire 18-2.5: no more damage inside the second (tick 20)" TO WS-CASE
     MOVE 19 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: 1 damage a second (tick 21 at count 140)" TO WS-CASE
     MOVE 18 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     PERFORM 139 TIMES
         CALL "HEALTH-TICK"
     END-PERFORM
     MOVE "acceptance fire 18-2.5: eight seconds of fire cost 8 damage in all" TO WS-CASE
     MOVE 12 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: the fire burns out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: the on-fire bit is cleared with it" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION MOD(PL-POSE-FLAGS(WS-PLAYER), 2)
     PERFORM CHK

*>   Water puts it out.
     PERFORM RESET-PLAYER
     MOVE 100 TO EN-BURN(WS-ER)
     MOVE WS-WATER TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: standing in water puts the fire out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET

*>   Powder snow puts it out too.
     PERFORM RESET-PLAYER
     MOVE 100 TO EN-BURN(WS-ER)
     MOVE WS-SNOW TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 29a-4.3: powder snow puts the fire out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET

*>   Rain puts it out (a precipitation biome and an open sky); the case is skipped when the spawn biome has none.
     PERFORM RESET-PLAYER
     MOVE 100 TO EN-BURN(WS-ER)
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     CALL "WEATHER-RAINING" USING WS-DIM WS-OBS
     MOVE 1 TO WS-EXP
     MOVE "acceptance fire: the test world is raining" TO WS-CASE
     PERFORM CHK
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: rain on an exposed player puts the fire out" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM)

*>   A fire block: 1.0 and eight seconds; soul fire 2.0.
     PERFORM RESET-PLAYER
     MOVE WS-FIRE TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 17-4.11: standing in fire takes 1 damage" TO WS-CASE
     MOVE 19 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 29b-8 2.10: fire sets the player alight for 160 ticks" TO WS-CASE
     MOVE 160 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     PERFORM RESET-PLAYER
     MOVE WS-SOUL TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 17-4.11: standing in soul fire takes 2 damage" TO WS-CASE
     MOVE 18 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET

*>   Fire Resistance (effect 11): no damage, the flames still show.
     PERFORM RESET-PLAYER
     CALL "EFFECT-ADD" USING WS-PLAYER WS-EFFECT WS-AMP WS-DUR WS-FLAGS
     MOVE WS-LAVA TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: Fire Resistance takes no lava damage" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET
     MOVE 160 TO EN-BURN(WS-ER)
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 18-2.5: Fire Resistance takes no burning damage" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     CALL "EFFECT-REMOVE" USING WS-PLAYER WS-EFFECT

*>   A creative player is not hurt and does not burn.
     PERFORM RESET-PLAYER
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE WS-LAVA TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire: a creative player in lava takes no damage" TO WS-CASE
     MOVE 20 TO WS-EXP
     MOVE PL-HEALTH(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire: a creative player does not burn" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   Dying in lava clears the fire and records the cause.
     PERFORM RESET-PLAYER
     MOVE 3 TO PL-HEALTH(WS-PLAYER)
     MOVE WS-LAVA TO WS-AT
     PERFORM PUT-AT-FEET
     CALL "HEALTH-TICK"
     MOVE "acceptance fire 17-4.13: lava kills a player with 3 health" TO WS-CASE
     MOVE PS-DEAD TO WS-EXP
     MOVE PL-STATE(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 17-4.13: the death cause is lava" TO WS-CASE
     MOVE CAUSE-LAVA TO WS-EXP
     MOVE PL-DEATH-CAUSE(WS-PLAYER) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance fire 18-2.5: death clears the fire" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-BURN(WS-ER) TO WS-OBS
     PERFORM CHK
     MOVE WS-AIR TO WS-AT
     PERFORM PUT-AT-FEET

*>   The death messages (17 4.13.3).
     MOVE CAUSE-ON-FIRE TO WS-CAUSE
     PERFORM TEXT-OF
     MOVE "acceptance fire 17-4.13: burning is death.attack.onFire" TO WS-CASE
     PERFORM CHK-TEXT-ONFIRE
     MOVE CAUSE-LAVA TO WS-CAUSE
     PERFORM TEXT-OF
     MOVE "acceptance fire 17-4.13: lava is death.attack.lava" TO WS-CASE
     PERFORM CHK-TEXT-LAVA
     MOVE CAUSE-IN-FIRE TO WS-CAUSE
     PERFORM TEXT-OF
     MOVE "acceptance fire 17-4.13: a fire block is death.attack.inFire" TO WS-CASE
     PERFORM CHK-TEXT-INFIRE
     STOP RUN.
 RESET-PLAYER.
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 17 TO PL-FOOD(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) PL-EXHAUSTION(WS-PLAYER) PL-DEATH-CAUSE(WS-PLAYER)
     MOVE 0 TO EN-BURN(WS-ER) EN-FIRE-SENT(WS-ER)
     MOVE 0 TO PL-POSE-FLAGS(WS-PLAYER) PL-POSE-SENT(WS-PLAYER).
 PUT-AT-FEET.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AT.
 CHK.
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS.
 TEXT-OF.
     CALL "DEATH-TEXT-STD" USING WS-PLAYER WS-CAUSE PB-TEXT.
 CHK-TEXT-ONFIRE.
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-TX-VALUE(1:PB-TX-LENGTH) = "death.attack.onFire"
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK.
 CHK-TEXT-LAVA.
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-TX-VALUE(1:PB-TX-LENGTH) = "death.attack.lava"
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK.
 CHK-TEXT-INFIRE.
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-TX-VALUE(1:PB-TX-LENGTH) = "death.attack.inFire"
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK.
 END PROGRAM TEST-PLAYER-FIRE.

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
