*> Acceptance test, US14 periodic mob-effect ticks (docs/protocol/17 section 4.9a; core/src/effects.cob EFFECTS-TICK through CORE-TICK): poison
*> (interval 25 >> amplifier, 1.0 magic damage while health is above 1.0), regeneration (50 >> amplifier, heal 1.0 below the maximum), wither
*> (40 >> amplifier, 1.0 damage, may kill) and hunger (0.005 x (amplifier + 1) exhaustion every tick). The effect fires before the duration step with
*> the duration it had at the start of the tick; an interval of 0 or less is every tick; an infinite duration uses the tick count. The hurt window
*> of 4.7 applies to poison and wither. Alice survival, food 17 and saturation 0 (no natural regeneration, no starvation).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-EFFECTS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-START-HEALTH        FLOAT-SHORT.
 01 WS-HUNDREDTHS          BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-RA

     MOVE "acceptance US14 poison I for 100 ticks fires at d 100, 75, 50, 25: 4 damage" TO TL-CASE
     MOVE 18 TO WS-ID
     MOVE 0 TO WS-AMP
     MOVE 100 TO WS-DURATION
     MOVE 100 TO WS-TICKS
     MOVE 20 TO WS-START-HEALTH
     PERFORM RUN-EFFECT
     MOVE "health 1600" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 poison II for 60 ticks (interval 12) fires 5 times at d 60, 48, 36, 24, 12" TO TL-CASE
     MOVE 1 TO WS-AMP
     MOVE 60 TO WS-DURATION
     MOVE 60 TO WS-TICKS
     PERFORM RUN-EFFECT
     MOVE "health 1500" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 poison never kills: at health 1.5 it hurts once (to 0.5) and then does nothing" TO TL-CASE
     MOVE 0 TO WS-AMP
     MOVE 50 TO WS-DURATION
     MOVE 50 TO WS-TICKS
     MOVE 1.5 TO WS-START-HEALTH
     PERFORM RUN-EFFECT
     MOVE "health 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 regeneration I for 100 ticks fires at d 100 and 50: heals 2" TO TL-CASE
     MOVE 7 TO WS-ID
     MOVE 100 TO WS-DURATION
     MOVE 100 TO WS-TICKS
     MOVE 10 TO WS-START-HEALTH
     PERFORM RUN-EFFECT
     MOVE "health 1200" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 regeneration does not heal past the maximum health of 20" TO TL-CASE
     MOVE 19.5 TO WS-START-HEALTH
     PERFORM RUN-EFFECT
     MOVE "health 2000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 wither I for 100 ticks fires at d 80 and 40: 2 damage" TO TL-CASE
     MOVE 19 TO WS-ID
     MOVE 20 TO WS-START-HEALTH
     PERFORM RUN-EFFECT
     MOVE "health 1800" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 an interval of 0 or less (wither amplifier 6) fires every tick but the hurt window lets only the first 1.0 through" TO TL-CASE
     MOVE 6 TO WS-AMP
     MOVE 3 TO WS-DURATION
     MOVE 3 TO WS-TICKS
     PERFORM RUN-EFFECT
     MOVE "health 1900" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 an infinite poison uses the tick count: 4 firings in 100 ticks" TO TL-CASE
     MOVE 18 TO WS-ID
     MOVE 0 TO WS-AMP
     MOVE -1 TO WS-DURATION
     MOVE 100 TO WS-TICKS
     PERFORM RUN-EFFECT
     MOVE "health 1600" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 hunger I adds 0.005 exhaustion per tick: 10 ticks 0.05" TO TL-CASE
     MOVE 16 TO WS-ID
     MOVE 10 TO WS-DURATION
     MOVE 10 TO WS-TICKS
     MOVE 20 TO WS-START-HEALTH
     PERFORM PREPARE
     MOVE 0 TO PL-EXHAUSTION(WS-RA)
     CALL "EFFECT-ADD" USING WS-RA WS-ID WS-AMP WS-DURATION WS-FLAGS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-HUNDREDTHS ROUNDED = PL-EXHAUSTION(WS-RA) * 1000
     MOVE WS-HUNDREDTHS TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "exhaustion " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "exhaustion 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US14 wither kills: at health 1.0 one firing leaves the player dead" TO TL-CASE
     MOVE 19 TO WS-ID
     MOVE 40 TO WS-DURATION
     MOVE 40 TO WS-TICKS
     MOVE 1 TO WS-START-HEALTH
     PERFORM PREPARE
     CALL "EFFECT-ADD" USING WS-RA WS-ID WS-AMP WS-DURATION WS-FLAGS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     IF PL-STATE(WS-RA) = PS-DEAD
         MOVE "dead" TO TL-OBSERVED
     ELSE
         MOVE "alive" TO TL-OBSERVED
     END-IF
     MOVE "dead" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Alice at WS-START-HEALTH, out of the hurt window, food 17, saturation 0, no effects.
 PREPARE.
     CALL "EFFECT-CLEAR-ALL" USING WS-RA
     MOVE WS-START-HEALTH TO PL-HEALTH(WS-RA)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-RA)
     MOVE 17 TO PL-FOOD(WS-RA)
     MOVE 0 TO PL-SATURATION(WS-RA)
     MOVE 0 TO PL-EXHAUSTION(WS-RA).

*> Applies the effect and runs the ticks; observes the health in hundredths.
 RUN-EFFECT.
     PERFORM PREPARE
     CALL "EFFECT-ADD" USING WS-RA WS-ID WS-AMP WS-DURATION WS-FLAGS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-HUNDREDTHS ROUNDED = PL-HEALTH(WS-RA) * 100
     MOVE WS-HUNDREDTHS TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "health " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-EFFECTS-TICK.

 COPY CORETEST.
