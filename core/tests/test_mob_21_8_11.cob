*> The happy ghast (docs/protocol/21 section 8.11, 44-9 section 9; lane p49f, T21200 to T21230): the row, the restriction radius and home (checkRestriction), continuousHeal, the still timeout (a player above, the
*> countdown after 60 ticks of life), metadata 18 and 19 to the viewers, feeding a baby (E8) and the harness of an adult, the tempt predicate, the rider input and rotation (E13) and the quad leash offsets.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(140).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SM                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-EXPECT              PIC X(300).
 01 WS-ID                  PIC Z(8)9.
 01 WS-HELD                BINARY-LONG.
 01 WS-SNOWBALL            BINARY-LONG.
 01 WS-HARNESS             BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-A3                  BINARY-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-OFFSETS.
    05 WS-OFFSET           FLOAT-LONG OCCURS 12 TIMES.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-STORE-Y             FLOAT-LONG.
 01 WS-LEASH-ROW           BINARY-LONG VALUE 1.
 01 WS-TID                 BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-FILL-ID             BINARY-LONG.
 01 WS-FILL-KIND           BINARY-LONG VALUE 1.
 01 WS-FILL-SLOT           BINARY-LONG.
 01 WS-TEN-S               BINARY-LONG VALUE 10.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:happy_ghast" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-SM
     MOVE "minecraft:snowball" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SNOWBALL WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:white_harness" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-HARNESS WS-ITEM-ROW WS-STATUS
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 the happy ghast has a mob row" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SM > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 max health 20" TO WS-CASE
     MOVE 20 TO WS-E
     CALL "STDMOB-HEALTH" USING WS-TYPE WS-O
     PERFORM CHECK-N
*>   The restriction radius: 64 for an adult with an empty body slot, else 32 (a baby, or a harness).
     MOVE 0 TO WS-A1 WS-A2
     CALL "HG-RADIUS" USING WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 radius of an adult with no harness is 64" TO WS-CASE
     MOVE 64 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A1
     CALL "HG-RADIUS" USING WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 radius of a baby is 32" TO WS-CASE
     MOVE 32 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-A1
     MOVE 1 TO WS-A2
     CALL "HG-RADIUS" USING WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 radius of an adult with a harness is 32" TO WS-CASE
     MOVE 32 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
*>   getSpeedUpSecondsWhenFeeding (E8): -24000 gives 120, -100 gives 0, -200 gives 1, -199 gives 0.
     MOVE -24000 TO WS-AGE
     CALL "HG-FEED-SECONDS" USING WS-AGE WS-SECONDS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 feeding seconds at age -24000 are 120" TO WS-CASE
     MOVE 120 TO WS-E
     MOVE WS-SECONDS TO WS-O
     PERFORM CHECK-N
     MOVE -100 TO WS-AGE
     CALL "HG-FEED-SECONDS" USING WS-AGE WS-SECONDS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 feeding seconds at age -100 are 0 (5 x 0.1f = 0.5)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SECONDS TO WS-O
     PERFORM CHECK-N
     MOVE -200 TO WS-AGE
     CALL "HG-FEED-SECONDS" USING WS-AGE WS-SECONDS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 feeding seconds at age -200 are 1 (10 x 0.1f)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SECONDS TO WS-O
     PERFORM CHECK-N
     MOVE -199 TO WS-AGE
     CALL "HG-FEED-SECONDS" USING WS-AGE WS-SECONDS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 feeding seconds at age -199 are 0 (199 div 20 = 9)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SECONDS TO WS-O
     PERFORM CHECK-N
*>   The tempt predicate.
     MOVE "snowball" TO WS-KEY48
     MOVE 0 TO WS-A1 WS-A2
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 an adult is tempted by a snowball" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE "red_harness" TO WS-KEY48
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 an unarmored adult is tempted by a harness" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A1
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 an armored adult is not tempted by a harness" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE "snowball" TO WS-KEY48
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 an armored adult is tempted by a snowball" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE "red_harness" TO WS-KEY48
     MOVE 0 TO WS-A1
     MOVE 1 TO WS-A2
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 a baby is not tempted by a harness" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
     MOVE "stick" TO WS-KEY48
     MOVE 0 TO WS-A2
     CALL "HG-TEMPTED" USING WS-KEY48 WS-A1 WS-A2 WS-A3
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 a stick tempts no one" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A3 TO WS-O
     PERFORM CHECK-N
*>   Rider input (E13): pitch 0, forward, not jumping: (strafe x 0.195, 0, 0.195); looking down 30 degrees backward and jumping: f = -0.433, v = 0.75.
     MOVE 1 TO WS-F1
     MOVE 1 TO WS-F2
     MOVE 0 TO WS-F3
     MOVE 0 TO WS-A1
     CALL "HG-RIDDEN-INPUT" USING WS-F1 WS-F2 WS-F3 WS-A1 WS-R1 WS-R2 WS-R3
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E13 strafe 1 forward 1: x 0.195 (microblocks)" TO WS-CASE
     MOVE 195000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R1 * 1000000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E13 level, forward: vertical 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(FUNCTION ABS(WS-R2) * 1000000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E13 forward z 0.195" TO WS-CASE
     MOVE 195000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R3 * 1000000 + 0.5)
     PERFORM CHECK-N
     MOVE 0 TO WS-F1
     MOVE -1 TO WS-F2
     MOVE 30 TO WS-F3
     MOVE 1 TO WS-A1
     CALL "HG-RIDDEN-INPUT" USING WS-F1 WS-F2 WS-F3 WS-A1 WS-R1 WS-R2 WS-R3
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E13 pitch 30 backward and jumping: vertical 0.75 x 0.195 = 0.14625" TO WS-CASE
     MOVE 146250 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R2 * 1000000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E13 pitch 30 backward: z = -0.433 x 0.195 = -0.08444" TO WS-CASE
     MOVE -84437 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R3 * 1000000 + 0.5)
     PERFORM CHECK-N
     MOVE 1 TO WS-F1
     MOVE 0 TO WS-F2
     MOVE 90 TO WS-F3
     MOVE 0 TO WS-A1
     CALL "HG-RIDDEN-INPUT" USING WS-F1 WS-F2 WS-F3 WS-A1 WS-R1 WS-R2 WS-R3
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.7 no forward input: only the strafe applies, f and v stay 0" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(FUNCTION ABS(WS-R2) * 1000000 + FUNCTION ABS(WS-R3) * 1000000 + 0.5)
     PERFORM CHECK-N
*>   Rider rotation: 8 percent of the wrapped yaw difference, pitch x 0.5.
     MOVE 0 TO WS-F1
     MOVE 100 TO WS-F2
     MOVE 60 TO WS-F3
     CALL "HG-RIDDEN-ROTATE" USING WS-F1 WS-F2 WS-F3 WS-R1 WS-R2
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.7 yaw 0 toward the rider's 100: 8.0 (thousandths)" TO WS-CASE
     MOVE 8000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R1 * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.7 the pitch is the rider's x 0.5" TO WS-CASE
     MOVE 30000 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R2 * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE 170 TO WS-F1
     MOVE -170 TO WS-F2
     CALL "HG-RIDDEN-ROTATE" USING WS-F1 WS-F2 WS-F3 WS-R1 WS-R2
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.7 yaw 170 toward -170 turns the short way: 171.6" TO WS-CASE
     MOVE 171600 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(WS-R1 * 1000 + 0.5)
     PERFORM CHECK-N
*>   The quad leash offsets of a 4 x 4 ghast.
     MOVE 4 TO WS-F1
     MOVE 4 TO WS-F2
     CALL "HG-QUAD-OFFSETS" USING WS-F1 WS-F2 WS-OFFSETS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 the first quad point is (-1.875, 0.125, 1.625)" TO WS-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(WS-OFFSET(1) + 1.875) < 0.0000001 AND FUNCTION ABS(WS-OFFSET(2) - 0.125) < 0.0000001
             AND FUNCTION ABS(WS-OFFSET(3) - 1.625) < 0.0000001
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 the second is (-1.875, 0.125, -1.875)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(WS-OFFSET(4) + 1.875) < 0.0000001 AND FUNCTION ABS(WS-OFFSET(5) - 0.125) < 0.0000001
             AND FUNCTION ABS(WS-OFFSET(6) + 1.875) < 0.0000001
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 the third is (1.875, 0.125, -1.875)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(WS-OFFSET(7) - 1.875) < 0.0000001 AND FUNCTION ABS(WS-OFFSET(8) - 0.125) < 0.0000001
             AND FUNCTION ABS(WS-OFFSET(9) + 1.875) < 0.0000001
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 the fourth is (1.875, 0.125, 1.625)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF FUNCTION ABS(WS-OFFSET(10) - 1.875) < 0.0000001 AND FUNCTION ABS(WS-OFFSET(11) - 0.125) < 0.0000001
             AND FUNCTION ABS(WS-OFFSET(12) - 1.625) < 0.0000001
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A ghast with a player standing above it: the viewer gets Add Entity and the metadata, and the still timeout is 10 after the first tick.
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) - 5
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "1 101(" FUNCTION TRIM(WS-ID) ";18=Z0,19=Z0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 a new ghast is sent with metadata 18 and 19 false" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 minecraft:happy_ghast 21§8.11 a new ghast has the 20 health of its row" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "STDMOB-STEP" USING WS-ROW
     CALL "HG-STATE" USING WS-ROW WS-SLOT
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 a player above the ghast sets the still timeout to 10" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE PJ-I2(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 STDMOB-STEP gives the ghast its tick (ticks lived 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I5(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";18=Z0,19=Z1)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 the viewers are told it stays still (metadata 19 true)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The player leaves: for the first 60 ticks of life the timeout does not count down; after them it falls 1 a tick and metadata 19 follows.
     MOVE PL-Y(WS-PLAYER) TO WS-STORE-Y
     COMPUTE PL-Y(WS-PLAYER) = WS-STORE-Y + 40
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "HG-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 within the first 60 ticks of life the timeout does not count down" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE PJ-I2(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE 61 TO PJ-I5(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         CALL "HG-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 after 60 ticks it counts down 1 a tick (9 ticks: 1 left)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PJ-I2(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     CALL "HG-TICK" USING WS-ROW
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";18=Z0,19=Z0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 when the timeout ends the viewers are told metadata 19 false" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Leash holder: notifyLeashHolder sets 5; metadata 18 is true while it counts down.
     CALL "HG-NOTIFY-LEASH" USING WS-ROW
     CALL "HG-TICK" USING WS-ROW
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";18=Z1,19=Z0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "A" TO TL-MODE
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 the leash holder flag (metadata 18) is true after notifyLeashHolder" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "HG-TICK" USING WS-ROW
     END-PERFORM
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 it stays true for 4 ticks (nothing sent meanwhile)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HG-TICK" USING WS-ROW
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-EXPECT
     STRING "101(" FUNCTION TRIM(WS-ID) ";18=Z0,19=Z0)" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.8 on the fifth tick the flag falls (leashHolderTime 0)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   checkRestriction: the first tick sets the home at the block with radius 64.
     MOVE "N" TO TL-MODE
     MOVE 64 TO WS-E
     MOVE PJ-I4(WS-SLOT) TO WS-O
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 an adult with an empty body slot is given a home of radius 64" TO WS-CASE
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 the home is the block position (x)" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
     MOVE EN-X(WS-ROW) TO WS-X
     COMPUTE EN-X(WS-ROW) = WS-X + 79
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 79 blocks from the home (closer than 64 + 16): the home stays" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(WS-X)
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
     COMPUTE EN-X(WS-ROW) = WS-X + 80
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 80 blocks away (not closer than 80): the home moves to the block" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(WS-X) + 80
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
     MOVE WS-X TO EN-X(WS-ROW)
     MOVE 1 TO EN-LEASH(WS-ROW)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 a leashed ghast keeps its home however far it is" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(WS-X) + 80
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
     MOVE 0 TO EN-LEASH(WS-ROW)
     MOVE 1 TO EN-PASS(WS-ROW)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 a ghast carrying a passenger keeps its home too" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(WS-X) + 80
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
     MOVE 0 TO EN-PASS(WS-ROW)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 free again it is brought home to its block" TO WS-CASE
     COMPUTE WS-E = FUNCTION INTEGER(WS-X)
     COMPUTE WS-O = FUNCTION INTEGER(PJ-R1(WS-SLOT))
     PERFORM CHECK-N
*>   A harness changes the radius to 32 and the home is made again.
     MOVE WS-HARNESS TO PJ-I3(WS-SLOT)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 wearing a harness the home radius is 32" TO WS-CASE
     MOVE 32 TO WS-E
     MOVE PJ-I4(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PJ-I3(WS-SLOT)
*>   continuousHeal: 1 point when the ticks lived are a multiple of 600 (clear) or 20 (rain).
     MOVE 10 TO EN-HEALTH(WS-ROW)
     MOVE 598 TO PJ-I5(WS-SLOT)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 at 599 ticks lived there is no heal" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 at 600 ticks lived it heals 1" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 at 601 not again" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     MOVE 38 TO PJ-I5(WS-SLOT)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 in rain the period is 20: 39 ticks lived no heal" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 in rain 40 ticks lived heals 1" TO WS-CASE
     MOVE 12 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO CW-RAIN-LEVEL(WS-DIM)
     MOVE 20 TO EN-HEALTH(WS-ROW)
     MOVE 599 TO PJ-I5(WS-SLOT)
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.6 a ghast at full health does not heal" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "PJ-DROP" USING WS-ROW
*>   Feeding a baby (E8).
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE WS-SNOWBALL TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E8 a snowball for a new baby is used" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E8 -24000 + 120 x 20 = -21600" TO WS-CASE
     MOVE -21600 TO WS-E
     MOVE EN-MOBAGE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 one snowball is consumed" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     PERFORM CHECK-N
     MOVE -100 TO EN-MOBAGE(WS-ROW)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E8 at age -100 the snowball is consumed and the age stays" TO WS-CASE
     MOVE -100 TO WS-E
     MOVE EN-MOBAGE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E8 and the stack lost one" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     PERFORM CHECK-N
     CALL "HG-STATE" USING WS-ROW WS-SLOT
     MOVE 1 TO PJ-I6(WS-SLOT)
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 an age-locked baby is not fed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PJ-I6(WS-SLOT)
     MOVE WS-HARNESS TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 a baby takes no harness (body slot only for an adult)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
*>   An adult takes the harness once.
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 an adult with an empty body slot takes the harness" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 the body slot holds the harness item" TO WS-CASE
     MOVE WS-HARNESS TO WS-E
     MOVE PJ-I3(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 one harness is used" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     PERFORM CHECK-N
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 a second harness is not taken (the slot is full)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
*>   An interact packet on a baby ghast reaches HG-INTERACT through MOB-INTERACT (a snowball is used).
     MOVE -24000 TO EN-MOBAGE(WS-ROW)
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE WS-SNOWBALL TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE EN-ID(WS-ROW) TO WS-TID
     CALL "TEST-INTERACT" USING WS-CONN WS-TID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§14 E8 an interact packet feeds the baby (one snowball used)" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO WS-O
     PERFORM CHECK-N
*>   AgeableMob.ageUp: age + seconds x 20 is capped at 0; reaching 0 makes an adult.
     MOVE -100 TO EN-MOBAGE(WS-ROW)
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE 10 TO WS-SECONDS
     CALL "HG-AGE-UP" USING WS-ROW WS-SECONDS
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 ageUp past 0 is capped at age 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-MOBAGE(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.2 at age 0 the baby flag falls" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-VARIANT(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The rider's yaw 200 is -160 from the ghast's 0: the wrap subtracts 360 once.
     MOVE 0 TO WS-F1
     MOVE 200 TO WS-F2
     MOVE 0 TO WS-F3
     CALL "HG-RIDDEN-ROTATE" USING WS-F1 WS-F2 WS-F3 WS-R1 WS-R2
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.7 yaw 0 toward the rider's 200 turns the short way: -12.8" TO WS-CASE
     COMPUTE WS-E = -12.8 * 1000
     COMPUTE WS-O ROUNDED = WS-R1 * 1000
     PERFORM CHECK-N
*>   HG-INTERACT ignores a row that is not a happy ghast and an empty hand.
     CALL "HG-INTERACT" USING WS-PLAYER PL-ENTITY-ROW(WS-PLAYER) WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 a row that is no happy ghast is not used" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 an empty hand uses nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
*>   A full side table (128 entries): the ghast gets no state, so nothing is used and the tick does nothing.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     INITIALIZE PJ-ENTRY(WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE WS-SNOWBALL TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         COMPUTE WS-FILL-ID = 900000 + WS-I
         CALL "PJ-ALLOC" USING WS-FILL-ID WS-FILL-KIND WS-FILL-SLOT
     END-PERFORM
     CALL "HG-INTERACT" USING WS-PLAYER WS-ROW WS-USED
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.3 with the side table full a ghast gets no state and is not used" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     CALL "HG-TICK" USING WS-ROW
     MOVE "acceptance US15 minecraft:happy_ghast 44-9§9.4 with the side table full the tick does nothing (the health stays)" TO WS-CASE
     MOVE EN-HEALTH(WS-ROW) TO WS-E
     MOVE EN-HEALTH(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-11.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
