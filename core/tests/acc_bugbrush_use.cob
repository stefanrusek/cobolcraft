*> Acceptance test, lane bugbrush (operator report try18: "suspicious sand doesn't do the brush animation when I right click on it; if I break the block with the brush it does
*> drop treasure; not the correct behaviors"): the brush through the real packet path in a standard world (generated vanilla data pack, CC_GENERATED_DIR; skipped as a pass
*> without it): Use Item On with the brush in hand over suspicious sand that holds an archaeology loot table starts the use (17 section 3.5, 25 part 8 section 7); the
*> brushing events fall on the used ticks 5, 15, ... (the sound, the dust particles), brushes 1, 3 and 6 raise the block's dusted value to 1, 2 and 3 (31-4 section 7.4),
*> the tenth completes: the buried item drops (rolled from the table with the entity's seed) beside the block on the brushed face, the block becomes sand and the brush loses
*> 1 durability (7.7); releasing early lets the progress decay (7.6, worked example 2); breaking the block drops nothing (the block entity is not a container). The ray is the
*> player's view ray: the player stands on a stone platform high above the terrain, facing +z, with the block three and a half blocks ahead at eye height.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGBRUSH-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY LOOTCTX.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-SUS-SAND            BINARY-LONG.
 01 WS-SUS-GRAVEL          BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-GRAVEL              BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 2.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-N                   BINARY-LONG.
 01 WS-DUSTED              BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "dusted".
 01 WS-PTEXT               PIC X(32).
 01 WS-PMODE               BINARY-LONG VALUE 1.
 01 WS-DIGIT               PIC 9.
 01 WS-STATE               BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-TABLE               PIC X(64) VALUE "minecraft:archaeology/desert_pyramid".
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-WANT-ITEM           BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-LEVEL-FLAGS         BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-SOUNDS              BINARY-LONG.
 01 WS-PARTICLES           BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FALLING-ROW         BINARY-LONG.
 01 WS-FELL                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-BIG                 FLOAT-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-FALL                BINARY-LONG.
 01 WS-CANCELLED           BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ZERO4               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugbrush use no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Bugbrush" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     MOVE "suspicious_sand" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SUS-SAND
     MOVE "suspicious_gravel" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SUS-GRAVEL
     MOVE "sand" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-SAND
     MOVE "gravel" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-GRAVEL
     MOVE "brush" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-BRUSH WS-ITEM-ROW WS-STATUS
     MOVE "stick" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-STICK WS-ITEM-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 12
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 12
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 4.5
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
*>   The block: (bx + 6, floor + 2, bz + 8), on a stone cell; the ray along z hits its north face (the drop cell is bz + 7).
     COMPUTE WS-SX = WS-BX + 6
     COMPUTE WS-SY = WS-FLOOR + 2
     COMPUTE WS-SZ = WS-BZ + 8
     COMPUTE WS-E = WS-FLOOR + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-E WS-SZ WS-STONE
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   What the table gives with the entity's seed, rolled independently.
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET
     MOVE WS-SEED TO LC-SEED
     MOVE CW-SEED TO LC-WORLD-SEED
     MOVE SPACES TO WS-KEY112
     MOVE WS-TABLE TO WS-KEY112
     CALL "LOOT-ROLL" USING WS-KEY112 LOOT-CONTEXT LOOT-RESULT
     MOVE LR-ITEM(1) TO WS-WANT-ITEM

*>   --- Brushing suspicious sand to the end ---
     PERFORM PLACE-SUSPICIOUS
     PERFORM CLICK
     MOVE "acceptance bugbrush: right click with a brush on suspicious sand leaves the block alone at first" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
*>   The first brushing event is the fifth used tick (the click ran the first one): sound and dust go to the viewers, the block turns to dusted 1.
     MOVE 3 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: four used ticks brush nothing yet" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance bugbrush: the fifth used tick brushes once, dusted 1" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-SOUNDS WS-PARTICLES
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-SOUNDS FOR ALL " 119 " ALL " 119x"
     INSPECT WS-PADDED TALLYING WS-PARTICLES FOR ALL " 48 " ALL " 48x"
     MOVE "acceptance bugbrush: a brushing event sends the sound to the viewers" TO WS-CASE
     MOVE 1 TO WS-WANT
     COMPUTE WS-GOT = FUNCTION MIN(WS-SOUNDS, 1)
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: a brushing event sends the dust particles to the viewers" TO WS-CASE
     MOVE 1 TO WS-WANT
     COMPUTE WS-GOT = FUNCTION MIN(WS-PARTICLES, 1)
     PERFORM CHECK-NUMBER
*>   Used tick 25: three counted brushes, dusted 2; used tick 55: six, dusted 3.
     MOVE 19 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: used tick 24 is still dusted 1 (two brushes)" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance bugbrush: the third brush (used tick 25) makes dusted 2" TO WS-CASE
     MOVE 2 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     MOVE 29 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance bugbrush: the sixth brush (used tick 55) makes dusted 3" TO WS-CASE
     MOVE 3 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
*>   Used tick 95: the tenth brush completes.
     MOVE 39 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: the ninth brush has not finished the block" TO WS-CASE
     MOVE 3 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     CALL "TEST-TICKS" USING WS-ONE
     MOVE "acceptance bugbrush: the tenth brush turns the suspicious sand into sand" TO WS-CASE
     MOVE WS-SAND TO WS-WANT
     PERFORM GET-STATE
     PERFORM CHECK-NUMBER
     PERFORM COUNT-ITEMS
     MOVE "acceptance bugbrush: the tenth brush drops one buried item" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE WS-ITEMS TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the item is what the table rolls with the entity's seed" TO WS-CASE
     MOVE WS-WANT-ITEM TO WS-WANT
     MOVE WS-DROPPED TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the item lies at the centre of the cell on the brushed face (x in thousandths)" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-DX TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the item lies at the centre of the cell on the brushed face (z in thousandths)" TO WS-CASE
     MOVE -1000 TO WS-WANT
     MOVE WS-DZ TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the item appears 0.625 above the cell floor (one gravity step of the same tick later: 0.585 to 0.625 over the block base)" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE 0 TO WS-GOT
     IF WS-DY >= 580 AND WS-DY <= 625
         MOVE 1 TO WS-GOT
     END-IF
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the brush loses 1 durability for the finished block" TO WS-CASE
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, 1) PL-SLOT-VAR(WS-PLAYER, 1) WS-GOT
     MOVE 1 TO WS-WANT
     PERFORM CHECK-NUMBER
     PERFORM FORGET-ITEMS
*>   The use is over: nothing more happens to the sand.
     MOVE 15 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: after the block is finished the brush wears no more" TO WS-CASE
     MOVE WS-SAND TO WS-WANT
     PERFORM GET-STATE
     PERFORM CHECK-NUMBER
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, 1) PL-SLOT-VAR(WS-PLAYER, 1) WS-GOT
     MOVE "acceptance bugbrush: the brush still has 1 durability lost after the block is finished" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM CHECK-NUMBER

*>   --- Suspicious gravel has its own sound and turns into gravel ---
     MOVE WS-SUS-GRAVEL TO WS-CELL
     PERFORM PLACE-SUSPICIOUS-OF
     PERFORM CLICK
     MOVE 3 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE 95 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: suspicious gravel brushed to the end turns into gravel" TO WS-CASE
     MOVE WS-GRAVEL TO WS-WANT
     PERFORM GET-STATE
     PERFORM CHECK-NUMBER
     PERFORM FORGET-ITEMS

*>   --- Releasing early: the progress decays (31-4 section 7.10 example 2) ---
     PERFORM PLACE-SUSPICIOUS
     PERFORM CLICK
     MOVE 14 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: two brushes (used ticks 5 and 15) make dusted 1" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-SEQ
     MOVE 30 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: after the release no more brushes come and the progress holds for a while" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     MOVE 30 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: 40 ticks after the last brush the progress has decayed to dusted 0" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     PERFORM COUNT-ITEMS
     MOVE "acceptance bugbrush: the buried item is not dropped by the decay" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-ITEMS TO WS-GOT
     PERFORM CHECK-NUMBER

*>   --- Looking away or changing the slot ends the use ---
     PERFORM PLACE-SUSPICIOUS
     PERFORM CLICK
     MOVE -90 TO PL-PITCH(WS-PLAYER)
     MOVE 40 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: a view ray that misses the block releases the brush, nothing is brushed" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     PERFORM PLACE-SUSPICIOUS
     PERFORM CLICK
     MOVE 1 TO PL-HELD(WS-PLAYER)
     MOVE 40 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: another held slot releases the brush, nothing is brushed" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   --- Only a brush brushes ---
     PERFORM PLACE-SUSPICIOUS
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, 1)
     PERFORM CLICK
     MOVE 40 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: a stick used on suspicious sand brushes nothing" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-DUSTED
     PERFORM CHECK-NUMBER
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, 1)

*>   --- Breaking the block drops nothing (the report: breaking with the brush gave the treasure) ---
     PERFORM PLACE-SUSPICIOUS
     MOVE 1 TO PL-MODE(WS-PLAYER)
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ZERO WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     MOVE 2 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: the suspicious sand is broken by the brush in creative" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM GET-STATE
     PERFORM CHECK-NUMBER
     PERFORM COUNT-ITEMS
     MOVE "acceptance bugbrush: breaking the block with the brush drops no treasure" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-ITEMS TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   --- A suspicious block with the air below falls and never lands as a block or an item ---
     COMPUTE WS-E = WS-SY + 1
     MOVE WS-SUS-SAND TO WS-CELL
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-SX WS-E WS-SZ WS-CELL WS-LEVEL-FLAGS WS-BUDGET WS-RES
     MOVE 3 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE 0 TO WS-FELL
     MOVE 0 TO WS-CANCELLED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-FB-STATE(WS-I) = WS-SUS-SAND
             MOVE 1 TO WS-FELL
             MOVE EN-FB-CANCEL(WS-I) TO WS-CANCELLED
         END-IF
     END-PERFORM
     MOVE "acceptance bugbrush: suspicious sand with air below becomes a falling block entity" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE WS-FELL TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush: the falling suspicious sand has cancelDrop" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE WS-CANCELLED TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE 40 TO WS-N
     CALL "TEST-TICKS-ANSWERED" USING WS-N
     MOVE "acceptance bugbrush: the fallen suspicious sand does not place itself where it lands" TO WS-CASE
     MOVE 0 TO WS-WANT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-GOT
     PERFORM CHECK-NUMBER
     PERFORM COUNT-ITEMS
     MOVE "acceptance bugbrush: the fallen suspicious sand drops no item" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-ITEMS TO WS-GOT
     PERFORM CHECK-NUMBER
     STOP RUN.

*> Suspicious sand (WS-CELL set by the caller, or the default sand) at the block position with the archaeology table and the seed, the brush in the first slot, the player
*> in place looking along +z, the pending packets drained.
 PLACE-SUSPICIOUS.
     MOVE WS-SUS-SAND TO WS-CELL
     PERFORM PLACE-SUSPICIOUS-OF.

 PLACE-SUSPICIOUS-OF.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-CELL
     CALL "BE-FIND" USING WS-DIM WS-SX WS-SY WS-SZ WS-BE
     IF WS-BE > 0
         MOVE WS-TABLE TO BE-LOOT(WS-BE)
         MOVE 37 TO BE-LOOT-LENGTH(WS-BE)
         MOVE WS-SEED TO BE-SEED(WS-BE)
     END-IF
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 4.5
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER) PL-HELD(WS-PLAYER)
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA.

*> The client's right click on the block: Use Item On (north face), then a tick (the first used tick).
 CLICK.
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     CALL "TEST-TICKS" USING WS-ONE.

*> WS-GOT = the dusted value of the block (-1 when it is not a suspicious block).
 GET-DUSTED.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STATE
     MOVE SPACES TO WS-PTEXT
     CALL "BLOCK-STATE-PROP" USING WS-PMODE WS-STATE WS-PROP WS-PTEXT WS-RES
     MOVE -1 TO WS-GOT
     IF WS-RES = 1
         MOVE WS-PTEXT(1:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-GOT
     END-IF.

 GET-STATE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-GOT.

 CHECK-NUMBER.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ground items within 3 blocks of the block: WS-ITEMS their number, WS-DROPPED the last one's item and WS-DX, WS-DY, WS-DZ its offset from the block's corner
*> cell (x and z from the block centre, y from the block's base) in thousandths.
 COUNT-ITEMS.
     MOVE 0 TO WS-ITEMS WS-DROPPED WS-DX WS-DY WS-DZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         COMPUTE WS-BIG = EN-X(WS-I) - WS-SX - 0.5
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
                 AND FUNCTION ABS(WS-BIG) <= 3
             ADD 1 TO WS-ITEMS
             MOVE EN-ITEM(WS-I) TO WS-DROPPED
             COMPUTE WS-DX ROUNDED = (EN-X(WS-I) - WS-SX - 0.5) * 1000
             COMPUTE WS-DY ROUNDED = (EN-Y(WS-I) - WS-SY) * 1000
             COMPUTE WS-DZ ROUNDED = (EN-Z(WS-I) - WS-SZ - 0.5) * 1000
         END-IF
     END-PERFORM.

 FORGET-ITEMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             MOVE 0 TO EN-ITEM-COUNT(WS-I)
             MOVE 0 TO EN-USED(WS-I)
         END-IF
     END-PERFORM.

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGBRUSH-USE.

 COPY CORETEST.
 COPY CMDTEST.
