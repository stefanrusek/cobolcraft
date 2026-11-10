*> Acceptance test, feature 002 US2-4 (tasks T0338; FR-037, FR-003 to FR-005, SC-011; docs/protocol/17
*> section 4.7, 4.9 and 4.11, 33 section 3): the shared standard rules apply in both world types.
*> Maximum health and food 20, start saturation 5.0; the hurt window (a hit is accepted when the
*> remaining invulnerable time is at most 10, which starts a window of 20; within the first 10 ticks a
*> hit of at most the last damage is ignored and a stronger one applies only its excess); fall damage
*> floor(distance + 1e-6 - 3); FoodData (exhaustion 4.0 drops saturation, then food; regeneration every
*> 10 ticks while saturated at food 20, every 80 ticks from food 18, starvation every 80 ticks at food
*> 0 down to health 1 (Normal difficulty)); Set Health carries the saturation; a player with food of 6
*> or less cannot start sprinting; the day is 24,000 ticks. Alice (survival) stands on greystone at
*> (20, 100, 20); Alice's vitals are set directly before each case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-SHARED-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY RULES.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-EXHAUST             FLOAT-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-TMP                 PIC X(4096).
 01 WS-FOUND               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-FOOD                BINARY-LONG.
 01 WS-SAT                 FLOAT-SHORT.
 01 WS-R1                  PIC -(5)9.99.
 01 WS-R2                  PIC -(5)9.99.
 01 WS-R3                  PIC -(5)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-MOB-TYPE            BINARY-LONG VALUE 3.
 01 WS-MOB-ROW             BINARY-LONG.
 01 WS-MOB-X               FLOAT-LONG VALUE 30.5.
 01 WS-MOB-Y               FLOAT-LONG VALUE 101.
 01 WS-MOB-Z               FLOAT-LONG VALUE 30.5.
 01 WS-MOB-CAUSE           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM VARYING WS-I FROM 20 BY 1 UNTIL WS-I > 23
         MOVE WS-I TO WS-X
         MOVE 100 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         MOVE 101 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
         MOVE 102 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 0 TO CW-WEATHER-LEFT(1)
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT

*>   Vitals of a new player.
     MOVE "acceptance US2-4 given a new survival player when they join then health and food are "
         & "20 and saturation is 5.0" TO TL-CASE
     PERFORM STATE-LINE
     MOVE "h 20.00 f 20 s 5.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

*>   Fall damage (17 section 4.11): floor(D + 1e-6 - 3). Food 17 and saturation 0: no regeneration.
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE "acceptance US2-4 given a survival player when they land after a fall of 4 blocks then "
         & "they lose 1 health" TO TL-CASE
     MOVE 105 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 19 food 17" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a survival player when they land after a fall of 3 blocks then "
         & "they take no damage" TO TL-CASE
     PERFORM SETTLE
     MOVE 104 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a survival player when they land after a fall of 10 blocks then "
         & "they lose 7 health" TO TL-CASE
     PERFORM SETTLE
     MOVE 111 TO WS-FY
     PERFORM FALL-TO-101
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 12 food 17" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a survival player at full health when they land after a fall "
         & "of 23 blocks then they lose 20 health and die" TO TL-CASE
     PERFORM SETTLE
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 124 TO WS-FY
     PERFORM FALL-TO-101
     MOVE PL-STATE(WS-ROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "2" TO TL-EXPECTED
     PERFORM CHECK

*>   Respawn: new vitals.
     MOVE "acceptance US2-4 given a dead player when they respawn then health and food are 20 and "
         & "saturation is 5.0" TO TL-CASE
     MOVE 0 TO WS-ACTION
     CALL "TEST-CLIENT-COMMAND" USING WS-ALICE WS-ACTION
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM STATE-LINE
     MOVE "h 20.00 f 20 s 5.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK
     PERFORM PLACE-ALICE

*>   The hurt window (17 section 4.7). Food 17 and saturation 0: no regeneration.
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-ROW)
     MOVE CAUSE-ABEND TO WS-CAUSE
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "acceptance US2-4 given a player with no window when a hit of 3 lands then health "
         & "falls to 17, the window is 20 ticks and the hit is announced" TO TL-CASE
     MOVE PL-HURT-COOLDOWN(WS-ROW) TO WS-E1
     MOVE WS-TEXT TO WS-TMP
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TMP) " window " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "damage 1 type 28 source 0 | hurt 1 | health 17 food 17 window 20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a window of 15 ticks left when a hit of 3 (not above the last "
         & "damage) lands then it is ignored" TO TL-CASE
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a window of 15 ticks left when a hit of 5 lands then only the "
         & "excess 2 is applied, no Damage Event is sent and the window is not renewed" TO TL-CASE
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE PL-HURT-COOLDOWN(WS-ROW) TO WS-E1
     MOVE WS-TEXT TO WS-TMP
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TMP) " window " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "health 15 food 17 window 15" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given the window has 10 ticks left when a hit of 3 lands then it is "
         & "accepted in full and a new window of 20 starts" TO TL-CASE
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE PL-HURT-COOLDOWN(WS-ROW) TO WS-E1
     MOVE WS-TEXT TO WS-TMP
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TMP) " window " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "damage 1 type 28 source 0 | hurt 1 | health 12 food 17 window 20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given three accepted hits of the mob type when they land then each "
         & "adds the damage type's exhaustion 0.1" TO TL-CASE
     PERFORM STATE-LINE
     MOVE "h 12.00 f 17 s 0.00 e 0.30" TO TL-EXPECTED
     PERFORM CHECK

*>   The same window for a mob (a sodgrazer of 8 health).
     MOVE "acceptance US2-4 given a mob when it is hit by 3, again by 3 and then by 5 within the "
         & "window then it loses 3 and then the excess 2" TO TL-CASE
     MOVE 2 TO WS-MOB-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-MOB-TYPE WS-MOB-X WS-MOB-Y WS-MOB-Z WS-YAW WS-MOB-ROW
     MOVE CAUSE-PLAYER TO WS-MOB-CAUSE
     MOVE 3 TO WS-AMOUNT
     MOVE 0 TO WS-NO-ATTACKER
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-MOB-CAUSE WS-NO-ATTACKER
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-MOB-CAUSE WS-NO-ATTACKER
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-MOB-CAUSE WS-NO-ATTACKER
     MOVE EN-HEALTH(WS-MOB-ROW) TO WS-E1
     MOVE EN-HURT(WS-MOB-ROW) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "health " FUNCTION TRIM(WS-E1) " window " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "health 3 window 20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a mob hit by 3 when a hit of 9 follows within the window then "
         & "the excess 6 defeats it" TO TL-CASE
     CALL "MOB-SPAWN" USING WS-DIM WS-MOB-TYPE WS-MOB-X WS-MOB-Y WS-MOB-Z WS-YAW WS-MOB-ROW
     MOVE 3 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-MOB-CAUSE WS-NO-ATTACKER
     MOVE 9 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB-ROW WS-AMOUNT WS-MOB-CAUSE WS-NO-ATTACKER
     MOVE EN-HEALTH(WS-MOB-ROW) TO WS-E1
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   FoodData: exhaustion (17 section 4.9).
     PERFORM SETTLE
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 2 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 4.0 TO WS-EXHAUST
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
     MOVE "acceptance US2-4 given exhaustion of 4.0 and saturation 2.0 when a tick runs then "
         & "exhaustion is 0 and saturation 1.0 and food is unchanged" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 17 s 1.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given saturation 1.0 when exhaustion reaches 4.0 and a tick runs "
         & "then saturation is 0 and food is unchanged, and the next 4.0 takes a food point" TO TL-CASE
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 16 s 0.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given food 16 when a food point is lost then the player is sent "
         & "Set Health with health 20, food 16 and saturation 0.0" TO TL-CASE
     PERFORM LAST-SET-HEALTH
     MOVE "h 20.00 f 16 s 0.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given saturation 3.0 when exhaustion 4.0 is spent then the player is "
         & "sent Set Health carrying saturation 2.0" TO TL-CASE
     MOVE 3 TO PL-SATURATION(WS-ROW)
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM LAST-SET-HEALTH
     MOVE "h 20.00 f 16 s 2.00" TO TL-EXPECTED
     PERFORM CHECK

*>   Regeneration.
     MOVE "acceptance US2-4 given food 20, saturation 5.0 and health 10 when 10 ticks pass then "
         & "health rises by 5 / 6 and exhaustion by 5.0" TO TL-CASE
     PERFORM SETTLE
     MOVE 20 TO PL-FOOD(WS-ROW)
     MOVE 5 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 10 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 10.83 f 20 s 5.00 e 5.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given food 18, saturation 0 and health 10 when 79 ticks pass then "
         & "health is unchanged" TO TL-CASE
     PERFORM SETTLE
     MOVE 18 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 10 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 79 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 10.00 f 18 s 0.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given the 80th tick when food is 18 then health rises by 1 and "
         & "exhaustion by 6.0" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 11.00 f 18 s 0.00 e 6.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given food 17 and health 10 when 100 ticks pass then health is "
         & "unchanged (no regeneration below food 18)" TO TL-CASE
     PERFORM SETTLE
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 10 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 10.00 f 17 s 0.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

*>   Starvation.
     MOVE "acceptance US2-4 given food 0 and health 20 when 80 ticks pass then the player takes "
         & "1 starvation damage" TO TL-CASE
     PERFORM SETTLE
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 0 TO PL-STARVE-TICKS(WS-ROW)
     MOVE 79 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 30 source 0 | hurt 1 | health 19 food 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given food 0 and health 1 when 80 ticks pass then the player does "
         & "not starve (Normal difficulty)" TO TL-CASE
     PERFORM SETTLE
     MOVE 1 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     MOVE 80 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM STATE-LINE
     MOVE "h 1.00 f 0 s 0.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

*>   Sprinting needs food above 6, and costs 0.1 per block; walking costs nothing; a jump 0.05
*>   and a sprinting jump 0.2.
     MOVE "acceptance US2-4 given food 6 when the player starts sprinting then the request is "
         & "refused" TO TL-CASE
     PERFORM SETTLE
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 5 TO PL-SATURATION(WS-ROW)
     MOVE 6 TO PL-FOOD(WS-ROW)
     MOVE 1 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE PL-SPRINTING(WS-ROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given food 7 when the player starts sprinting then the player "
         & "sprints" TO TL-CASE
     MOVE 7 TO PL-FOOD(WS-ROW)
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE PL-SPRINTING(WS-ROW) TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a sprinting player when they move one block on the ground then "
         & "exhaustion is 0.1" TO TL-CASE
     PERFORM PLACE-ALICE
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 21.5 TO WS-FX
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 7 s 5.00 e 0.10" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a walking player when they move one block on the ground then "
         & "exhaustion is unchanged" TO TL-CASE
     MOVE 2 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 22.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 7 s 5.00 e 0.00" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a walking player when they jump then exhaustion is 0.05" TO TL-CASE
     MOVE 101.4 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 7 s 5.00 e 0.05" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US2-4 given a sprinting player when they jump then exhaustion is 0.2" TO TL-CASE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 1 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 22.5 TO WS-FX
     MOVE 101.4 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM STATE-LINE
     MOVE "h 20.00 f 7 s 5.00 e 0.20" TO TL-EXPECTED
     PERFORM CHECK

*>   Day length (33 section 3).
     MOVE "acceptance US2-4 given time 23999 when a tick runs then the time of day is 0" TO TL-CASE
     MOVE 23999 TO CW-TIME
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE CW-TIME TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Alice rises (on-ground false) to WS-FY, then lands on the greystone (feet y 101, on-ground true).
 FALL-TO-101.
     MOVE 20.5 TO WS-FX
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

*> Lets the hurt window pass and clears the output.
 SETTLE.
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.

*> Alice stands at (20.5, 101, 20.5) again, on the ground.
 PLACE-ALICE.
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 20.5 TO WS-FX
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.

*> TL-OBSERVED becomes Alice's vitals.
 STATE-LINE.
     MOVE PL-HEALTH(WS-ROW) TO WS-HEALTH
     MOVE PL-FOOD(WS-ROW) TO WS-E1
     COMPUTE WS-R1 ROUNDED = PL-HEALTH(WS-ROW)
     COMPUTE WS-R2 ROUNDED = PL-SATURATION(WS-ROW)
     COMPUTE WS-R3 ROUNDED = PL-EXHAUSTION(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING "h " FUNCTION TRIM(WS-R1) " f " FUNCTION TRIM(WS-E1) " s " FUNCTION TRIM(WS-R2)
         " e " FUNCTION TRIM(WS-R3) DELIMITED BY SIZE INTO WS-TEXT.

*> WS-TEXT becomes the health, food and saturation of the first Set Health sent to Alice.
 LAST-SET-HEALTH.
     MOVE SPACES TO WS-TEXT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 106 TO WS-PACKET-ID
     CALL "TEST-DRAIN-PACKET" USING WS-ALICE WS-PACKET-ID PB-BUFFER WS-FOUND
     IF WS-FOUND = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-GET-FLOAT" USING PB-BUFFER WS-HEALTH
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-FOOD
         CALL "PB-GET-FLOAT" USING PB-BUFFER WS-SAT
         COMPUTE WS-R1 ROUNDED = WS-HEALTH
         COMPUTE WS-R2 ROUNDED = WS-SAT
         MOVE WS-FOOD TO WS-E1
         STRING "h " FUNCTION TRIM(WS-R1) " f " FUNCTION TRIM(WS-E1) " s " FUNCTION TRIM(WS-R2)
             DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     CALL "PB-FREE" USING PB-BUFFER.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US2-SHARED-RULES.

 COPY CORETEST.
