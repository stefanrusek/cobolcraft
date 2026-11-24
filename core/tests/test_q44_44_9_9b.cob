*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 9.3 to 9.8, lane 002-lane-p49j-a): the happy ghast server rules as functions: body slot, restriction radius, regeneration period, cloud band, rider input, yaw step, collision, leash offsets (no happy ghast in the core).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-9b.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                     BINARY-LONG.
 01 WB                     BINARY-LONG.
 01 WC                     BINARY-LONG.
 01 WD                     BINARY-LONG.
 01 WE                     BINARY-LONG.
 01 WF1                    FLOAT-LONG.
 01 WF2                    FLOAT-LONG.
 01 WF3                    FLOAT-LONG.
 01 WF4                    FLOAT-LONG.
 01 WF5                    FLOAT-LONG.
 01 WF6                    FLOAT-LONG.
 01 WF7                    FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-GHAST-SLOT" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.3 an alive adult accepts the BODY slot" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WB
     CALL "Q9-GHAST-SLOT" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.3 a baby does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     CALL "Q9-GHAST-SLOT" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.3 a dead ghast does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-GHAST-RADIUS" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 an adult without a harness: radius 64" TO WS-NAME
     MOVE 64 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WB
     CALL "Q9-GHAST-RADIUS" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 an adult with a harness: 32" TO WS-NAME
     MOVE 32 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     CALL "Q9-GHAST-RADIUS" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 a baby: 32" TO WS-NAME
     MOVE 32 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 600 TO WB
     CALL "Q9-GHAST-HEAL" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 outside clouds the heal period is 600: tick 600 heals" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 20 TO WB
     CALL "Q9-GHAST-HEAL" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 tick 20 does not heal outside clouds" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 20 TO WB
     CALL "Q9-GHAST-HEAL" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 in clouds or rain the period is 20: tick 20 heals" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 30 TO WB
     CALL "Q9-GHAST-HEAL" USING WA WB WC
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 in clouds tick 30 does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 98 TO WF1
     MOVE 4 TO WF2
     MOVE 100 TO WF3
     CALL "Q9-IN-CLOUDS" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 cloud band: a ghast of height 4 with feet 2 below the cloud layer reaches it" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 105 TO WF1
     CALL "Q9-IN-CLOUDS" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 feet 5 above the layer is out of the band (y <= cloud + 4)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 90 TO WF1
     CALL "Q9-IN-CLOUDS" USING WF1 WF2 WF3 WA
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.6 a top below the layer is out of the band" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 1 TO WF2
     MOVE 0 TO WF3
     MOVE 0 TO WA
     MOVE 0.05 TO WF4
     CALL "Q9-GHAST-INPUT" USING WF1 WF2 WF3 WA WF4 WF5 WF6 WF7
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 forward on the level with flying speed 0.05: z = 3.9 x 0.05 = 0.195 (x1000)" TO WS-NAME
     MOVE 195 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF7 * 1000
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 1 TO WF2
     MOVE 0 TO WF3
     MOVE 1 TO WA
     MOVE 0.05 TO WF4
     CALL "Q9-GHAST-INPUT" USING WF1 WF2 WF3 WA WF4 WF5 WF6 WF7
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 jumping adds 0.5 to the vertical part: 0.5 x 0.195 = 0.0975 (x10000)" TO WS-NAME
     MOVE 975 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF6 * 10000
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE -1 TO WF2
     MOVE 0 TO WF3
     MOVE 0 TO WA
     MOVE 0.05 TO WF4
     CALL "Q9-GHAST-INPUT" USING WF1 WF2 WF3 WA WF4 WF5 WF6 WF7
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 reverse looking level: z = -0.5 x 0.195 (x10000 = -975)" TO WS-NAME
     MOVE -975 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF7 * 10000
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 100 TO WF2
     CALL "Q9-GHAST-YAW" USING WF1 WF2
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 the yaw moves 8 percent toward the rider: 0 to 100 gives 8 (x100)" TO WS-NAME
     MOVE 800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 100
     PERFORM EXPECT
     MOVE 170 TO WF1
     MOVE -170 TO WF2
     CALL "Q9-GHAST-YAW" USING WF1 WF2
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 the yaw takes the short way: 170 toward -170 moves +1.6 (x100)" TO WS-NAME
     MOVE 17160 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 100
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 1 TO WB
     MOVE 1 TO WC
     MOVE 1 TO WD
     MOVE 1 TO WE
     CALL "Q9-GHAST-COLLIDE" USING WA WB WC WD WE WS-OBS
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 a baby is never collided with" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 1 TO WB
     MOVE 0 TO WC
     MOVE 0 TO WD
     MOVE 0 TO WE
     CALL "Q9-GHAST-COLLIDE" USING WA WB WC WD WE WS-OBS
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 a player above the top can stand on an adult (client)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WB
     MOVE 0 TO WE
     CALL "Q9-GHAST-COLLIDE" USING WA WB WC WD WE WS-OBS
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 a flying ghast (no still timeout) is not solid" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WE
     CALL "Q9-GHAST-COLLIDE" USING WA WB WC WD WE WS-OBS
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.7 a still ghast is solid" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 4 TO WF1
     MOVE 4 TO WF2
     CALL "Q9-GHAST-LEASH" USING WA WF1 WF2 WF3 WF4 WF5
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.8 quad leash point 1 for a 4 x 4 ghast: x = -0.46875 x 4 = -1.875 (x1000)" TO WS-NAME
     MOVE -1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.8 point 1 z = 0.4375 w - 0.03125 w = 1.625 (x1000)" TO WS-NAME
     MOVE 1625 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF5 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.8 the height offset is 0.03125 h = 0.125 (x1000)" TO WS-NAME
     MOVE 125 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF4 * 1000
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-GHAST-LEASH" USING WA WF1 WF2 WF3 WF4 WF5
     MOVE "acceptance US15 44-9§9.3 to 9.8 9.8 point 3 sits at x = +1.875, z = -1.875 (-1.75 - 0.125) (x1000)" TO WS-NAME
     MOVE -1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF5 * 1000
     PERFORM EXPECT
     MOVE 0 TO WA WB WE
     MOVE 2 TO WC
     MOVE 1 TO WD
     CALL "Q9-GHAST-COLLIDE" USING WA WB WC WD WE WS-OBS
     MOVE "acceptance US15 44-9§9.7 a flying ghast with passengers collides with another happy ghast" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 2 TO WA
     MOVE 4 TO WF1
     MOVE 4 TO WF2
     CALL "Q9-GHAST-LEASH" USING WA WF1 WF2 WF3 WF4 WF5
     MOVE "acceptance US15 44-9§9.8 point 2 sits at z = -0.4375 w - 0.03125 w = -1.875 (x1000)" TO WS-NAME
     MOVE -1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF5 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.8 and x = -1.875 (x1000)" TO WS-NAME
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE 4 TO WA
     CALL "Q9-GHAST-LEASH" USING WA WF1 WF2 WF3 WF4 WF5
     MOVE "acceptance US15 44-9§9.8 point 4 sits at x = +1.875 (x1000)" TO WS-NAME
     MOVE 1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.8 and z = 1.625 (x1000)" TO WS-NAME
     MOVE 1625 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF5 * 1000
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-GHAST-LEASH" USING WA WF1 WF2 WF3 WF4 WF5
     MOVE "acceptance US15 44-9§9.8 point 3 sits at x = +1.875 (x1000)" TO WS-NAME
     MOVE 1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-9b.
