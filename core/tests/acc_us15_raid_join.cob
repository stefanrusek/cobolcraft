*> Acceptance test, finding a raid and raiders joining it (docs/protocol/44 section 5 and 20 section 14.2; lane 002-lane-mobsb5, T8904): getRaidAt (the nearest active raid within 96
*> blocks), a raider without a raid joins it on a 20 tick beat at wave groups + 1 and only for an ongoing raid, Bad Omen stays in a village whose raid has the maximum omen level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAID-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RAIDSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 01 WS-BAD                 BINARY-LONG VALUE 30.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 120000.
 01 WS-FLAGS               BINARY-LONG VALUE 4.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 2 TO BW-DIFFICULTY
*>   Two raids: slot 1 at 80 blocks, slot 2 at 50 blocks; the nearest one wins; a stopped raid is ignored.
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE WS-DIM TO RD-DIM(1)
     COMPUTE RD-CX(1) = WS-X + 80
     MOVE WS-Y TO RD-CY(1)
     MOVE WS-Z TO RD-CZ(1)
     MOVE 1 TO RD-USED(2)
     MOVE 1 TO RD-STATUS(2)
     MOVE WS-DIM TO RD-DIM(2)
     COMPUTE RD-CX(2) = WS-X + 50
     MOVE WS-Y TO RD-CY(2)
     MOVE WS-Z TO RD-CZ(2)
     CALL "RAID-AT" USING WS-DIM WS-X WS-Y WS-Z WS-SLOT
     MOVE "acceptance US15 44§5 the nearest raid within 96 blocks" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO RD-STATUS(2)
     CALL "RAID-AT" USING WS-DIM WS-X WS-Y WS-Z WS-SLOT
     MOVE "acceptance US15 44§5 a stopped raid is not found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE RD-CX(1) = WS-X + 97
     CALL "RAID-AT" USING WS-DIM WS-X WS-Y WS-Z WS-SLOT
     MOVE "acceptance US15 44§5 beyond 96 blocks there is none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A raider joins the raid at its position on a tick that is a multiple of 20, at wave groups + 1.
     COMPUTE RD-CX(1) = WS-X + 10
     MOVE 2 TO RD-GROUPS(1)
     COMPUTE WS-FX = WS-X
     COMPUTE WS-FY = WS-Y
     COMPUTE WS-FZ = WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-FX WS-FY WS-FZ WS-YAW WS-E
     MOVE 41 TO CW-TICKS
     CALL "RAID-RAIDER-STEP" USING WS-E
     MOVE 0 TO WS-MEMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(WS-E)
             MOVE WS-I TO WS-MEMBER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§14.2 off the 20 tick beat nothing happens" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MEMBER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO CW-TICKS
     CALL "RAID-RAIDER-STEP" USING WS-E
     MOVE 0 TO WS-MEMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(WS-E)
             MOVE WS-I TO WS-MEMBER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§14.2 on the beat the raider joins raid 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MEMBER > 0
         MOVE RR-RAID(WS-MEMBER) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§14.2 at wave groups + 1" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE RR-WAVE(WS-MEMBER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-HEALTH(WS-E) TO WS-N
     MOVE "acceptance US15 20§14.2 its health is added to the total" TO TL-CASE
     MOVE RD-TOTAL(1) TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Joining twice does not add a second membership.
     CALL "RAID-RAIDER-STEP" USING WS-E
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RR-MAX
         IF RR-ID(WS-I) = EN-ID(WS-E)
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§14.2 a member does not join again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Bad Omen in a village with a raid at the maximum omen level stays.
     MOVE 5 TO RD-OMEN(1)
     COMPUTE WS-N = WS-X + 3
     CALL "PXI-ADD" USING WS-DIM WS-N WS-Y WS-Z WS-KIND2
     CALL "EFFECT-ADD" USING WS-PLAYER WS-BAD WS-AMP WS-DUR WS-FLAGS
     CALL "RAID-PLAYER-TICK" USING WS-PLAYER
     CALL "EFFECT-LEVEL" USING WS-PLAYER WS-BAD WS-LEVEL WS-LEFT
     MOVE "acceptance US15 20§14.2 a raid at omen 5 leaves Bad Omen alone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEVEL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-RAID-JOIN.

 COPY CORETEST.
 COPY MOBSPTEST.
