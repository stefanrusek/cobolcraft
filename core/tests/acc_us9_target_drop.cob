*> Acceptance test, the US9 edge case on targets (spec "US9 - A hostile mob's target switches to
*> creative mode, disconnects, dies or changes dimension: the mob stops pursuing that player"; tasks
*> T536; standin-content §12.3 Target): an abend drops its target when that player switches to
*> creative, disconnects, dies, changes dimension or is farther than the give-up range of 20.0, and
*> then stops walking towards it. Alice (entity 1, survival) stands at (4.5, 54, 8.5) on the flat
*> ground of column x = 4 (§5.2: top 53 for z -10 to 25); the abend (entity 2) starts at (4.5, 54,
*> 14.5) and takes her as its target on the first tick (z 14.38). Changing dimension is set directly
*> on the player row (travel is US12). The test runs at night, in windows without a spawn tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-TARGET-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ETIDS.
 COPY RULES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 30.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-SOURCE           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-X                   FLOAT-LONG VALUE 4.5.
 01 WS-Y                   FLOAT-LONG VALUE 54.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-R1                  PIC -(5)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE

     MOVE "US9 edge given an abend pursuing Alice when she switches to creative then it drops "
         & "her as its target and stops walking towards her" TO TL-CASE
     PERFORM START-PURSUIT
     MOVE 1 TO PL-MODE(CN-PLAYER(WS-ALICE))
     PERFORM TWO-TICKS
     MOVE "target 0 z 14.38" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given an abend pursuing Alice when she dies then it drops her as its target "
         & "and stops walking towards her" TO TL-CASE
     PERFORM START-PURSUIT
     MOVE CAUSE-FALL TO WS-CAUSE
     CALL "HEALTH-DAMAGE" USING CN-PLAYER(WS-ALICE) WS-AMOUNT WS-CAUSE WS-NO-SOURCE
         WS-NO-ATTACKER
     PERFORM TWO-TICKS
     MOVE "target 0 z 14.38" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given an abend pursuing Alice when she disconnects then it drops her as its "
         & "target and stops walking" TO TL-CASE
     PERFORM START-PURSUIT
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     PERFORM TWO-TICKS
     MOVE "target 0 z 14.38" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given Alice disconnected and Bobby (entity 3) joined into her player row and "
         & "stands where she stood then the abend pursues Bobby, not the player who left"
         TO TL-CASE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 8.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DESCRIBE-MOB
     MOVE "target 3 z 14.26" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given an abend pursuing Alice when she changes dimension then it drops her as "
         & "its target and stops walking towards her" TO TL-CASE
     PERFORM START-PURSUIT
     MOVE 2 TO PL-DIM(CN-PLAYER(WS-ALICE))
     PERFORM TWO-TICKS
     MOVE "target 0 z 14.38" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given an abend pursuing Alice when she moves to 19.4 blocks away (beyond the "
         & "notice range, within the give-up range of 20.0) then it keeps her as its target"
         TO TL-CASE
     PERFORM START-PURSUIT
     MOVE -5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DESCRIBE-MOB
     MOVE "target 1 z 14.26" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US9 edge given an abend pursuing Alice when she moves to 20.9 blocks away (beyond the "
         & "give-up range) then it drops her as its target and stops" TO TL-CASE
     PERFORM START-PURSUIT
     MOVE -6.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     PERFORM TWO-TICKS
     MOVE "target 0 z 14.38" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world at night; survival Alice joins and stands at (4.5, 54, 8.5); the abend appears
*> at (4.5, 54, 14.5) and, after one tick, pursues her (target 1, z 14.38).
 START-PURSUIT.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 8.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     MOVE 14.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-TICKS" USING WS-ONE.

*> Two ticks pass (the abend would have walked 0.24 further had it kept its target).
 TWO-TICKS.
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-TICKS" USING WS-ONE
     PERFORM DESCRIBE-MOB.

 DESCRIBE-MOB.
     MOVE EN-TARGET-ID(WS-ROW) TO WS-E1
     COMPUTE WS-R1 ROUNDED = EN-Z(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING "target " FUNCTION TRIM(WS-E1) " z " FUNCTION TRIM(WS-R1) DELIMITED BY SIZE
         INTO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-TARGET-DROP.

 COPY CORETEST.
