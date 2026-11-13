*> Acceptance test of buckets through the real play path (docs/protocol/29a section 7.2 and 7.3; Use Item 0x43 in, block changes and Container Set Slot out):
*> the server casts the ray (from the eye along the packet's yaw and pitch; here due south, +z) with the fluid mode of the held bucket. An empty bucket
*> picks up a water or lava SOURCE (the block becomes air, the bucket the filled one) and ignores a flowing cell; a filled bucket places a source in the cell
*> before the block it hits (air or a replaceable block) and becomes the empty bucket; a creative player keeps the stack; with nothing to hit nothing happens.
*> The world opens as the cobolcraft set and the core tables are rebuilt from the standard set (TEST-STANDARD-TABLES). Alice stands at (20.5, 101, 20.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-BUCKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CMENU.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROWNO               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG VALUE 101.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(4096).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-BROW                PIC X(819).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-WATER-BUCKET        BINARY-LONG.
 01 WS-LAVA-BUCKET         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 102.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(48).
 01 WS-LONG-KEY            PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROWNO
     MOVE 100 TO WS-Y
     MOVE 20 TO WS-Z
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 102 TO WS-Y
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BUCKET WS-ROW WS-STATUS
     MOVE "water_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-WATER-BUCKET WS-ROW WS-STATUS
     MOVE "lava_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-LAVA-BUCKET WS-ROW WS-STATUS
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
     MOVE "water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-WATER WS-STATUS
     MOVE "lava" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-LAVA WS-STATUS
*>   A stone wall at (20, 102, 24), the ray runs along z through the cells 21 to 23 at y 102.
     MOVE 24 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 1 TO PL-SLOT-COUNT(WS-ROWNO, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-ROWNO, 1)
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE "T" TO TL-MODE

*>   Pick up a source.
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     MOVE 22 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.2 given an empty bucket and a water source in sight when Use Item is sent then the source is gone and the bucket is a water bucket"
         TO TL-CASE
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-WATER-BUCKET TO WS-E2
     STRING "0 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Place the water: the ray runs through the air up to the wall, the source goes into the last air cell (z 23).
     MOVE 23 TO WS-Z
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.3 given a water bucket when Use Item is sent facing a wall then a water source is placed in the cell before it and the bucket is empty"
         TO TL-CASE
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-WATER TO WS-E1
     MOVE WS-BUCKET TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A flowing cell (level 1) is not hit by the empty bucket's ray: the ray reaches the wall, which no bucket picks up.
     MOVE 23 TO WS-Z
     COMPUTE WS-STATE = WS-WATER + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.1 given an empty bucket and a flowing water cell in sight when Use Item is sent then nothing is picked up" TO TL-CASE
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     COMPUTE WS-E1 = WS-WATER + 1
     MOVE WS-BUCKET TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava: a lava bucket places a lava source (the flowing cell is replaceable).
     MOVE WS-LAVA-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.3 given a lava bucket and a flowing water cell before the wall when Use Item is sent then the cell is a lava source and the bucket is empty"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-LAVA TO WS-E1
     MOVE WS-BUCKET TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Creative: the stack stays an empty bucket after a pick-up; a water bucket stays a water bucket after a placing.
     MOVE 1 TO PL-MODE(WS-ROWNO)
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.2 given a creative player with an empty bucket and a lava source in sight when Use Item is sent then the source is gone and the stack stays the bucket"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-BUCKET TO WS-E2
     STRING "0 " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.3 given a creative player with a water bucket when Use Item is sent then the water is placed and the stack stays a water bucket"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-WATER TO WS-E1
     MOVE WS-WATER-BUCKET TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nothing to hit: with the wall removed the filled bucket does nothing.
     MOVE 0 TO PL-MODE(WS-ROWNO)
     MOVE 24 TO WS-Z
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 23 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-USE-ITEM" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance 29a§7.2 given a water bucket and nothing within reach when Use Item is sent then the bucket is unchanged" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E1
     MOVE WS-WATER-BUCKET TO WS-E2
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Guards: an open window, an empty hand and an item that is no bucket do nothing; a stack of 2 empty buckets gives one filled bucket into the
*>   inventory; a filled bucket with the eye inside a block does nothing.
     MOVE 22 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     MOVE 24 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     MOVE 1 TO MN-WINDOW(WS-ROWNO)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 0 TO MN-WINDOW(WS-ROWNO)
     MOVE 0 TO PL-SLOT-COUNT(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 1 TO PL-SLOT-COUNT(WS-ROWNO, 1)
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 22 TO WS-Z
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance 29a§7.2 given an open window, an empty hand or a stone in hand when Use Item is sent then the water source stays" TO TL-CASE
     MOVE WS-STATE TO WS-E1
     MOVE WS-WATER TO WS-E2
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-ROWNO, WS-I) = WS-WATER-BUCKET AND PL-SLOT-COUNT(WS-ROWNO, WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance 29a§7.2 given a stack of 2 empty buckets when a source is taken then 1 empty bucket stays and a water bucket is in the inventory"
         TO TL-CASE
     MOVE WS-N TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROWNO, 1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The eye inside a block: stone at (20, 102, 20), a filled bucket places nothing.
     MOVE 20 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE WS-WATER-BUCKET TO PL-SLOT-ITEM(WS-ROWNO, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROWNO, 1)
     CALL "TEST-USE-ITEM" USING WS-ALICE
     MOVE "acceptance 29a§7.3 given the eye inside a block when Use Item is sent with a water bucket then the bucket is unchanged" TO TL-CASE
     MOVE PL-SLOT-ITEM(WS-ROWNO, 1) TO WS-E1
     MOVE WS-WATER-BUCKET TO WS-E2
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

*>   The standard set's block rows have no namespace; the rules name blocks as minecraft:<name>: a water cell reads as minecraft:water (41's key), and
*>   an ice block matches the key minecraft:ice (FLUID-KEY-IS).
     MOVE 23 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
     CALL "IP-BLOCK-KEY" USING WS-DIM WS-X WS-Y WS-Z WS-BLOCK-KEY WS-KEY-LENGTH
     MOVE "ice" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "minecraft:ice" TO WS-LONG-KEY
     CALL "FLUID-KEY-IS" USING WS-STATE WS-LONG-KEY WS-FLAG
     MOVE "acceptance 41§3 given the standard block rows when a water cell's key is read and an ice state is matched then minecraft:water and the ice match come out"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-KEY-LENGTH TO WS-E1
     MOVE WS-FLAG TO WS-E2
     STRING FUNCTION TRIM(WS-BLOCK-KEY) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:water 15 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US12-BUCKET.

 COPY CORETEST.
