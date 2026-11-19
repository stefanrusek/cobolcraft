*> Acceptance test of the End's exit portal podium as a player meets it (operator report on db901a9a: "the 0, ~, 0 end fountain didn't generate"; docs/protocol/21 section 6.4.5,
*> 35-7 section 10.3, 38 section 9): a player who travels to the End through a portal and stands near the central island sees, once the dragon fight controller has scanned the state (the
*> first tick after the 20-tick bar sync that has her in range), the inactive podium at (0, P, 0) with P = surface of the column - 1: the bedrock pillar P..P+3, the portal layer's
*> bedrock rim, the end stone ring below, the four torches. The blocks must be in the world AND reach the viewer (a Block Update or a Section Blocks Update, id 86, after the chunk went out),
*> the stored portal location survives a save and reload, and the first kill makes the portal active (end_portal blocks in the middle, again sent to the viewer) with the dragon egg above the pillar.
*> Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGENDFOUNTAIN-PODIUM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY ENDTRAVEL.
 COPY ENDFIGHT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-END-STONE           BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-EGG                 BINARY-LONG.
 01 WS-TORCH               BINARY-LONG OCCURS 4 TIMES.
 01 WS-WANT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-IDS                 PIC X(1024).
 01 WS-SP                  PIC X(1030).
 01 WS-SENT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-FORGET              BINARY-LONG VALUE 5.
 01 WS-LOAD                BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugendfountain podium: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
*>   the real End generator (the portal tests keep the placeholder island)
     MOVE 0 TO ND-PLACEHOLDER
     MOVE 12345 TO CW-SEED
     MOVE "bedrock" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-BEDROCK
     MOVE "end_stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-END-STONE
     MOVE "end_portal" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-PORTAL
     MOVE "dragon_egg" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-EGG
     MOVE "wall_torch" TO WS-KEY
     MOVE "facing=north" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-TORCH(1)
     MOVE "facing=east" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-TORCH(2)
     MOVE "facing=south" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-TORCH(3)
     MOVE "facing=west" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-TORCH(4)
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

*>   The column (0, 0) of the End before anyone is there: its surface is the first non-air block from the top; the podium centre is one below.
     MOVE 0 TO WS-TOP
     MOVE 0 TO WS-X MOVE 0 TO WS-Z
     PERFORM VARYING WS-Y FROM 255 BY -1 UNTIL WS-Y < 0 OR WS-TOP > 0
         CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE NOT = 0
             COMPUTE WS-TOP = WS-Y + 1
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance bugendfountain: the central island has a surface at (0, 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-TOP > 1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-P = WS-TOP - 1

*>   She travels through an end portal block of the overworld, then stands on the island's side (chunk 1) so that chunk (0, 0) is in her view.
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-PORTAL
     MOVE 10.5 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-DIM(WS-ROW) TO TL-OBSERVED-N
     MOVE "acceptance bugendfountain: she arrived in the End" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24.5 TO PL-X(WS-ROW)
     COMPUTE PL-Y(WS-ROW) = WS-P + 2
     MOVE 0.5 TO PL-Z(WS-ROW)
     MOVE 1 TO PL-MODE(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS

*>   Forty more ticks: the 20-tick bar syncs have her in range, the fight scans the state and builds the inactive podium.
     MOVE 0 TO WS-SENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "TEST-TICKS" USING WS-TEN
         CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
         PERFORM COUNT-BLOCK-PACKETS
     END-PERFORM
     MOVE 0 TO WS-ACTIVE
     PERFORM CHECK-PODIUM
     MOVE "acceptance bugendfountain: the inactive podium is in the world at (0, P, 0) (every cell of 35-7 10.3)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugendfountain: the viewer in the End was sent the podium blocks (Block Update or Section Blocks Update)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SENT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance bugendfountain: the fight stored the portal location (0, P, 0)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000000 + WS-P
     COMPUTE TL-OBSERVED-N = 1000000 * EF-HAS-PORTAL + EF-PORTAL(2) + EF-PORTAL(1) * 7 + EF-PORTAL(3) * 13
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The saved location survives a save and a reload of the fight state.
     CALL "CORE-SAVE"
     CALL "END-FIGHT-IO" USING WS-FORGET END-FIGHT
     INITIALIZE END-FIGHT
     CALL "END-FIGHT-IO" USING WS-LOAD END-FIGHT
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE "acceptance bugendfountain: after a save and a reload the fight state still holds the portal location" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000000 + WS-P
     COMPUTE TL-OBSERVED-N = 1000000 * EF-HAS-PORTAL + EF-PORTAL(2) + EF-PORTAL(1) * 7 + EF-PORTAL(3) * 13
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The first kill: the portal turns active, the viewer is told, the egg sits above the pillar.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "FIGHT-KILLED" USING DIM-STANDARD-END
     MOVE 0 TO WS-SENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         CALL "TEST-TICKS" USING WS-TWO
         CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
         PERFORM COUNT-BLOCK-PACKETS
     END-PERFORM
     MOVE 1 TO WS-ACTIVE
     PERFORM CHECK-PODIUM
     MOVE "acceptance bugendfountain: after the kill the active podium is in the world (end_portal in the middle layer)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugendfountain: the viewer was sent the portal blocks of the kill" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SENT > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE 0 TO WS-Z
     COMPUTE WS-Y = WS-P + 4
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance bugendfountain: the first kill put the dragon egg on top of the pillar" TO TL-CASE
     MOVE WS-EGG TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-BAD = the cells of the 10.3 box whose block differs from the doc's table (the shadow model: inner = distSqr < 6.25, outer = distSqr < 12.25), for WS-ACTIVE.
 CHECK-PODIUM.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 4
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 32
             PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 4
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-D2 <= 12
                     PERFORM WANT-CELL
                     COMPUTE WS-X = WS-DX
                     COMPUTE WS-Y = WS-P + WS-DY
                     COMPUTE WS-Z = WS-DZ
                     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-STATE
                     IF WS-STATE NOT = WS-WANT
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 WANT-CELL.
     EVALUATE TRUE
         WHEN WS-DX = 0 AND WS-DZ = 0 AND WS-DY >= 0 AND WS-DY <= 3
             MOVE WS-BEDROCK TO WS-WANT
         WHEN WS-DY = 2 AND WS-DX = 0 AND WS-DZ = -1
             MOVE WS-TORCH(1) TO WS-WANT
         WHEN WS-DY = 2 AND WS-DX = 1 AND WS-DZ = 0
             MOVE WS-TORCH(2) TO WS-WANT
         WHEN WS-DY = 2 AND WS-DX = 0 AND WS-DZ = 1
             MOVE WS-TORCH(3) TO WS-WANT
         WHEN WS-DY = 2 AND WS-DX = -1 AND WS-DZ = 0
             MOVE WS-TORCH(4) TO WS-WANT
         WHEN WS-DY < 0 AND WS-D2 <= 6
             MOVE WS-BEDROCK TO WS-WANT
         WHEN WS-DY < 0
             MOVE WS-END-STONE TO WS-WANT
         WHEN WS-DY = 0 AND WS-D2 <= 6 AND WS-ACTIVE = 1
             MOVE WS-PORTAL TO WS-WANT
         WHEN WS-DY = 0 AND WS-D2 <= 6
             MOVE 0 TO WS-WANT
         WHEN WS-DY = 0
             MOVE WS-BEDROCK TO WS-WANT
         WHEN OTHER
             MOVE 0 TO WS-WANT
     END-EVALUATE.

*> WS-SENT counts the Block Update (id 8) and Section Blocks Update (id 86) packets of the drained ids WS-IDS.
 COUNT-BLOCK-PACKETS.
     MOVE SPACES TO WS-SP
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SP
     MOVE 0 TO WS-N
     INSPECT WS-SP TALLYING WS-N FOR ALL " 86x"
     ADD WS-N TO WS-SENT
     MOVE 0 TO WS-N
     INSPECT WS-SP TALLYING WS-N FOR ALL " 8x"
     ADD WS-N TO WS-SENT.
 END PROGRAM ACC-BUGENDFOUNTAIN-PODIUM.

 COPY CORETEST.
 COPY PORTALTEST.
