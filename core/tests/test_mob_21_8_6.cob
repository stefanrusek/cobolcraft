*> The first tick of a lightning bolt (docs/protocol/21 section 8.6, 29b-3 sections 9.2 to 9.4, 29b-5 section 8; lane p49f, T21600): at life 2 the block containing (x, y - 1e-6, z) is struck: a lightning rod
*> (any weathering or waxed variant) becomes powered, gets a scheduled tick of 8 that makes it unpowered again and level event 3002 (the axis of its facing); an unwaxed weathering copper block is
*> reset to the unaffected variant; then 3 + nextInt(3) walks of 1 + nextInt(8) steps each scrape one oxidation step off a weathering copper block of the 3 x 3 x 3 cube around the cursor (level event 3002
*> with data -1) and move on. A visual-only bolt does all of this too (29b-3 9.4); waxed copper is never changed. spawnFire(4) on Normal and Hard is not built (the placement rule is not in the documents).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VISUAL              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TALLY               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(24) VALUE "powered".
 01 WS-VALUE               PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-LONG                PIC X(48).
 01 WS-CHANGED             BINARY-LONG.
 01 WS-WRONG               BINARY-LONG.
 01 WS-WAXED               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 3.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME-FACING         PIC X(24) VALUE "facing".
 01 WS-DIR-TEXT            PIC X(32).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "SW-RULES-OPEN"
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-BX = WS-FX + 5
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-BZ = WS-FZ + 5
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
*>   A lightning rod struck by a bolt standing on its top face.
     MOVE "lightning_rod" TO WS-KEY
     PERFORM PLACE-BLOCK
     PERFORM STRIKE
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 a struck lightning rod becomes powered" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
     CALL "P49-DRAIN-DATA" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-TALLY
     INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL "47"
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 the viewer gets level event 3002 (Level Event 0x2F)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TALLY > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 7 TO WS-I
     CALL "TEST-TICKS" USING WS-I
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 7 ticks later the rod is still powered (tick delay 8)" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-I
     CALL "TEST-TICKS" USING WS-I
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 after 8 ticks the scheduled tick makes it unpowered" TO WS-CASE
     MOVE "false" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   A waxed rod is a LightningRodBlock too, and a visual-only bolt strikes as well (9.4).
     MOVE "waxed_lightning_rod" TO WS-KEY
     PERFORM PLACE-BLOCK
     MOVE 1 TO WS-VISUAL
     PERFORM STRIKE
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.4 a visual-only bolt powers a waxed rod too" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-VISUAL
*>   A rod lying on its side (facing north or east) is powered as well; the level event carries the axis of its facing.
     MOVE "lightning_rod" TO WS-KEY
     MOVE "north" TO WS-DIR-TEXT
     PERFORM PLACE-FACING
     PERFORM STRIKE
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 a rod facing north is powered (axis Z)" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "east" TO WS-DIR-TEXT
     PERFORM PLACE-FACING
     PERFORM STRIKE
     PERFORM READ-POWERED
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.2 a rod facing east is powered (axis X)" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   Plain stone is struck and nothing happens to it.
     MOVE "stone" TO WS-KEY
     PERFORM PLACE-BLOCK
     MOVE WS-STATE TO WS-I
     PERFORM STRIKE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 a bolt on stone changes nothing" TO WS-CASE
     MOVE WS-I TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
*>   An oxidized copper block is reset to the unaffected variant.
     MOVE "oxidized_copper" TO WS-KEY
     PERFORM PLACE-BLOCK
     PERFORM STRIKE
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 a struck oxidized copper block becomes plain copper" TO WS-CASE
     MOVE "copper_block" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   Waxed copper is never changed, however weathered.
     MOVE "waxed_oxidized_copper" TO WS-KEY
     PERFORM PLACE-BLOCK
     PERFORM STRIKE
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 a struck waxed copper block stays as it is" TO WS-CASE
     MOVE "waxed_oxidized_copper" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   A cube of oxidized copper: the strike block is reset, the walks scrape other blocks by one step.
     MOVE "oxidized_copper" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 4
             PERFORM VARYING WS-K FROM -2 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-BY = WS-FY + 3
     PERFORM STRIKE
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 the strike block of the cube is plain copper" TO WS-CASE
     MOVE "copper_block" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-CHANGED WS-WRONG
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 4
             PERFORM VARYING WS-K FROM -2 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-FY + 1 + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-RESULT
                 IF WS-RESULT NOT = WS-STATE
                     ADD 1 TO WS-CHANGED
                     MOVE CB-KEY(CB-S-BLOCK(WS-RESULT + 1) + 1) TO WS-LONG
                     CALL "KEY-BARE" USING WS-LONG WS-BARE
                     CALL "TOOL-COPPER-PARSE" USING WS-BARE WS-WAXED WS-LEVEL WS-FAMILY
                     IF WS-WAXED = 1 OR WS-FAMILY NOT = 1
                         ADD 1 TO WS-WRONG
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 the walks scraped at least one other block" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-CHANGED >= 2
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§9.3 every changed block is an unwaxed block of the copper family" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WRONG TO WS-O
     PERFORM CHECK-N
     STOP RUN.

*> WS-KEY: the block of that key (its default state) at (WS-BX, WS-BY, WS-BZ); WS-STATE its state.
 PLACE-FACING.
     PERFORM PLACE-BLOCK
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-NAME-FACING WS-DIR-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

 PLACE-BLOCK.
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

*> A bolt standing on the top face of the block (its feet 1 above the block's bottom).
 STRIKE.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 1
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VISUAL WS-ROW
     CALL "THROWN-TICK"
     CALL "PJ-DROP" USING WS-ROW.

 READ-POWERED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE SPACES TO WS-LONG
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-LONG WS-RESULT
     MOVE WS-LONG TO WS-BARE.

 READ-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG WS-BARE.

 CHECK-TEXT.
     MOVE "A" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-VALUE TO TL-EXPECTED
     MOVE WS-BARE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY P49FTEST.
