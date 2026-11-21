*> Acceptance test, US5-3 core half (spec US5 scenario 3; tasks T471; docs/protocol/41 section 2.3; 09 §3.3
*> rows 0x29 actions 4 and 5, §3.4 rule 6): Player Action 5 DROP_ITEM throws one item and 4
*> DROP_ALL_ITEMS the whole stack of the held hotbar slot; the item appears at the thrower's eyes - 0.3 (feet + 1.32) with
*> the motion mx = -sin(yaw) cos(pitch) 0.3 + cos(a) b, my = -sin(pitch) 0.3 + 0.1 + (r1 - r2) 0.1, mz = cos(yaw) cos(pitch)
*> 0.3 + sin(a) b (a random in a full circle, b in 0 to 0.02, r1 and r2 in 0 to 1: the motion is asserted by its ranges,
*> the draws themselves by test_itemphys_41_2; Set Entity Motion follows Add Entity and Set Entity Data) and lands in front
*> of the player; the thrower cannot pick it up before its pickup delay of 40 ticks is over (the 41st tick is the first
*> that can); a throw from an empty slot does nothing. Alice (entity 1, survival, starting items) stands
*> at (20.5, 101, 20.5) on greystone at (20, 100, 20), facing east (yaw -90).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-ZX                  BINARY-LONG VALUE 0.
 01 WS-ZY                  BINARY-LONG VALUE 0.
 01 WS-ZZ                  BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG VALUE 101.0.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE -90.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEXT-ID             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-SIDE                PIC X(4).
 01 WS-R1                  PIC -(4)9.9(5).
 01 WS-R2                  PIC -(4)9.9(5).
 01 WS-R3                  PIC -(4)9.9(5).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-LX                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-INRANGE             PIC X(12).
 01 WS-BEFORE              PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
*>   No mob spawns during the test: night (standin §4.8) with hostile mobs off, where §12.4
*>   names only the abend for cobolcraft:main.
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "acceptance US5-3 given a held stack of 64 when throw is used then one item leaves the "
         & "held slot and a ground item of one appears at y 102.32 with the thrown motion "
         & "(0.3 +- 0.02, 0.1 +- 0.1, +- 0.02) for yaw -90, pitch 0 and delay 40" TO TL-CASE
     MOVE 0.28 TO WS-LX
     MOVE 0.32 TO WS-HX
     MOVE 0.0 TO WS-LY
     MOVE 0.2 TO WS-HY
     MOVE -0.02 TO WS-LZ
     MOVE 0.02 TO WS-HZ
     MOVE 5 TO WS-ACTION
     PERFORM ACT
     MOVE 2 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "20(36=2x63) 1(2,1@20.50,102.32,20.50) 101(2=2x1) 103(2) motion in range delay 40"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-3 given a thrown item when it has flown then it lands in front of the "
         & "player (east, same z) and rests there" TO TL-CASE
     MOVE 300 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E1
     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-E2
     MOVE "west" TO WS-SIDE
     IF EN-X(WS-ROW) > 21.75
         MOVE "east" TO WS-SIDE
     END-IF
     MOVE "off line" TO WS-INRANGE
     IF EN-Z(WS-ROW) > 20.3 AND EN-Z(WS-ROW) < 20.7
         MOVE "same z" TO WS-INRANGE
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "resting " FUNCTION TRIM(WS-E1) " " WS-SIDE " of 21.75 " FUNCTION TRIM(WS-INRANGE)
         " count " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "resting 1 east of 21.75 same z count 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-3 given a held stack when throw is used with the whole-stack modifier "
         & "(DROP_ALL_ITEMS) then the whole stack (63) leaves the slot as one ground item"
         TO TL-CASE
     MOVE 4 TO WS-ACTION
     PERFORM ACT
     MOVE 3 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE "20(36=0x0) 1(3,1@20.50,102.32,20.50) 101(3=2x63) 103(3) motion in range delay 40"
         TO TL-EXPECTED
     PERFORM CHECK
     MOVE 300 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT

     MOVE "acceptance US5-3 given an item thrown straight down (pitch 90) when it lies within "
         & "the thrower's pickup range then the thrower cannot take it while the delay of 40 runs: after 29 ticks 11 are left"
         TO TL-CASE
     MOVE 1 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 90 TO WS-PITCH
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE -0.02 TO WS-LX
     MOVE 0.02 TO WS-HX
     MOVE -0.3 TO WS-LY
     MOVE -0.1 TO WS-HY
     MOVE -0.02 TO WS-LZ
     MOVE 0.02 TO WS-HZ
     MOVE 5 TO WS-ACTION
     PERFORM ACT
     MOVE 4 TO WS-ENTITY
     PERFORM DESCRIBE
     MOVE 29 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE EN-DELAY(WS-ROW) TO WS-E1
     MOVE EN-ON-GROUND(WS-ROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT(1:6) " delay " FUNCTION TRIM(WS-E1) " resting "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "128(4) delay 11 resting 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-3 given the thrown item when its pickup delay of 40 ticks is over "
         & "then the thrower picks it up again, on the 41st tick and not before" TO TL-CASE
     MOVE 11 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE WS-TEXT TO WS-BEFORE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING "before [" FUNCTION TRIM(WS-BEFORE) "] after [" FUNCTION TRIM(WS-TEXT) "]"
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "before [] after [127(4,1,1) 20(37=3x64) 78(4)]" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-3 given an empty held slot when throw is used then nothing happens"
         TO TL-CASE
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE CW-NEXT-ENTITY-ID TO WS-NEXT-ID
     MOVE 5 TO WS-ACTION
     PERFORM ACT
     MOVE 4 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE CW-NEXT-ENTITY-ID TO WS-E1
     MOVE WS-NEXT-ID TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " next id " FUNCTION TRIM(WS-E1) " was "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE "next id 5 was 5" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-ZX WS-ZY WS-ZZ WS-FACE WS-SEQ.

*> Drains Alice into WS-TEXT and appends the motion and pickup delay of ground item WS-ENTITY.
 DESCRIBE.
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE "out of range" TO WS-INRANGE
     IF EN-VX(WS-ROW) >= WS-LX AND EN-VX(WS-ROW) <= WS-HX AND EN-VY(WS-ROW) >= WS-LY
             AND EN-VY(WS-ROW) <= WS-HY AND EN-VZ(WS-ROW) >= WS-LZ AND EN-VZ(WS-ROW) <= WS-HZ
         MOVE "in range" TO WS-INRANGE
     END-IF
     MOVE EN-DELAY(WS-ROW) TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " motion " FUNCTION TRIM(WS-INRANGE)
         " delay " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US5-THROW.

 COPY CORETEST.
