*> Acceptance test (US12 dimension rules; docs/protocol/37-nether-1 section 3.1 water_evaporates): a survival player in the Nether who empties a water bucket into the air
*> in front of her places no water (the cell stays air), hears the fire.extinguish Sound and sees the 8 large_smoke particles (Sound 0x77 and Level Particles 0x30 reach her), and
*> the bucket is spent (an empty bucket in the hand); the same use in the overworld places the water. The same holds for a water bucket aimed at a dry waterloggable block (a top slab): in the
*> Nether the slab is not waterlogged and the bucket is spent with the sound and the smoke, in the overworld the slab is waterlogged. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-NETHER-WATER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-ROW-TEXT            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-WATER-BUCKET        BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-COUNT               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-SLAB                BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 37§3 3.1 nether water: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE "bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BUCKET WS-ROW-TEXT WS-STATUS
     MOVE "water_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-WATER-BUCKET WS-ROW-TEXT WS-STATUS
     MOVE "stone" TO WS-KEY48
     CALL "PT-STATE" USING WS-KEY48 WS-PAIRS WS-STONE
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 1)
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT

*>   The Nether: a wall at (20, 70, 24), the ray along z through the air cells 21 to 23.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 20 TO WS-X MOVE 70 TO WS-Y MOVE 24 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE WS-DIM TO PL-DIM(WS-ROW)
     MOVE 20.5 TO PL-X(WS-ROW)
     MOVE 69.0 TO PL-Y(WS-ROW)
     MOVE 20.5 TO PL-Z(WS-ROW)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE 23 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 37§3 3.1 nether water: no water was placed in the cell in front of the wall" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37§3 3.1 nether water: the bucket is spent (an empty bucket in the hand)" TO TL-CASE
     MOVE WS-BUCKET TO TL-EXPECTED-N
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     INSPECT WS-IDS TALLYING WS-COUNT FOR ALL "119"
     MOVE "acceptance US12 37§3 3.1 nether water: the fire.extinguish Sound (0x77) was sent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     INSPECT WS-IDS TALLYING WS-COUNT FOR ALL "48"
     MOVE "acceptance US12 37§3 3.1 nether water: the large_smoke Level Particles (0x30) were sent" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The overworld control: the same use places the water.
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 24 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE WS-DIM TO PL-DIM(WS-ROW)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 23 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 37§3 3.1 nether water: in the overworld the water is placed (the cell is no longer air)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A top slab at the wall's cell (the ray at the eye height 70.62 meets its upper half): in the Nether a water bucket does not waterlog it.
     MOVE "oak_slab" TO WS-KEY48
     MOVE "type=top,waterlogged=false" TO WS-PAIRS
     CALL "PT-STATE" USING WS-KEY48 WS-PAIRS WS-SLAB
     MOVE SPACES TO WS-PAIRS
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 24 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SLAB
     MOVE WS-DIM TO PL-DIM(WS-ROW)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE "acceptance US12 37§3 3.1 nether water: a top slab is not waterlogged by a water bucket" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "type=top,waterlogged=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 37§3 3.1 nether water: the bucket on the slab is spent (an empty bucket in the hand)" TO TL-CASE
     MOVE WS-BUCKET TO TL-EXPECTED-N
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     INSPECT WS-IDS TALLYING WS-COUNT FOR ALL "119"
     MOVE "acceptance US12 37§3 3.1 nether water: the slab use sends the fire.extinguish Sound (0x77)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The overworld control: the same slab is waterlogged.
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SLAB
     MOVE WS-DIM TO PL-DIM(WS-ROW)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE "acceptance US12 37§3 3.1 nether water: in the overworld the top slab is waterlogged" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "type=top,waterlogged=true" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US12-NETHER-WATER.

 COPY CORETEST.
 COPY PORTALTEST.
