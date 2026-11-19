*> Acceptance test, lane bugfallblock (operator report of try15: "falling blocks still delete torches rather than breaking"; docs/protocol/29b part 1 sections 3.1 and 4.3, 29 section 3.2):
*> a superflat world of the standard content set (CC_GENERATED_DIR; skipped as a pass without it) driven through the real tick path. A falling block lands in the cell it ends in only when the block
*> there is replaceable (the registry flag: air, short grass, water ...); a torch, a rail or a slab is not, so the falling block is discarded and its own item drops
*> (4.3 step 6) and the block that stood there stays. A replaced block is simply overwritten (setBlockAndUpdate, no drops). A block over a cell that is not free (air, fire, a liquid or a
*> replaceable block, 3.1) does not fall at all. A block that hangs on a falling block loses its support when the cell is cleared and pops with its item (29 section 3.2); a gravel column falls as a column.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FALLING-BLOCK-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-SPEC                PIC X(120).
 01 WS-SPEC-KEY            PIC X(48).
 01 WS-SPEC-PROPS          PIC X(120).
 01 WS-PAIR                PIC X(48).
 01 WS-PAIR-NAME           PIC X(24).
 01 WS-PAIR-VALUE          PIC X(32).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-BRACKET             BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-LABEL               PIC X(120).
 01 WS-TICKS               BINARY-LONG.
 01 WS-WANT-ITEM           BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-FB-TYPE             BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-F-SPEC              PIC X(120) VALUE "stone".
 01 WS-A-SPEC              PIC X(120).
 01 WS-A-DY                BINARY-LONG.
 01 WS-B-SPEC              PIC X(120).
 01 WS-B-DY                BINARY-LONG.
 01 WS-C-SPEC              PIC X(120).
 01 WS-C-DX                BINARY-LONG.
 01 WS-C-DY                BINARY-LONG.
 01 WS-WANT-SPEC           PIC X(120).
 01 WS-WANT-STATE          BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-WANT-COUNT          BINARY-LONG.
 01 WS-DIGIT               PIC 99.
 01 WS-DIGIT2              PIC 99.
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
         MOVE "test falling block standard no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "FallBlock" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-STONE
     MOVE "minecraft:falling_block" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-FB-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 12.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PZ = WS-BZ + 5
*>   1. Sand falls from 4 cells above a torch that stands on the floor: it flies through the torch's cell and lands in it. A torch is not replaceable, so
*>      the sand is discarded and its item drops; the torch stays.
     MOVE "sand falling onto a standing torch: the torch stays, the sand becomes an item" TO WS-LABEL
     MOVE "torch" TO WS-A-SPEC
     MOVE 1 TO WS-A-DY
     MOVE "sand" TO WS-B-SPEC
     MOVE 5 TO WS-B-DY
     MOVE SPACES TO WS-C-SPEC
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "torch" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE 2 TO WS-DY
     MOVE "air" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:sand" TO WS-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE "minecraft:torch" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
*>   2. Sand placed directly above the torch: the torch's cell is not free (3.1), so the sand stays where it is and nothing is destroyed.
     MOVE "sand resting above a torch does not fall and the torch stays" TO WS-LABEL
     MOVE "torch" TO WS-A-SPEC
     MOVE 1 TO WS-A-DY
     MOVE "sand" TO WS-B-SPEC
     MOVE 2 TO WS-B-DY
     MOVE SPACES TO WS-C-SPEC
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "torch" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE 2 TO WS-DY
     MOVE "sand" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:sand" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
*>   3. Gravel onto a rail (a thin block with no collision that is not replaceable, as flowers are in the doc; the generated table gives the fifteen flowers no noCollision flag,
*>      see the lane file): the rail stays and the gravel drops as an item.
     MOVE "gravel falling onto a rail: the rail stays, the gravel becomes an item" TO WS-LABEL
     MOVE "rail" TO WS-A-SPEC
     MOVE 1 TO WS-A-DY
     MOVE "gravel" TO WS-B-SPEC
     MOVE 5 TO WS-B-DY
     MOVE SPACES TO WS-C-SPEC
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "rail" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:gravel" TO WS-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE "minecraft:rail" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
*>   4. Gravel onto short grass (replaceable): the grass is overwritten without a drop and the gravel is placed in its cell.
     MOVE "gravel falling onto short grass replaces it: the gravel is placed, nothing drops" TO WS-LABEL
     MOVE "dirt" TO WS-F-SPEC
     MOVE "short_grass" TO WS-A-SPEC
     MOVE 1 TO WS-A-DY
     MOVE "gravel" TO WS-B-SPEC
     MOVE 5 TO WS-B-DY
     MOVE SPACES TO WS-C-SPEC
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "gravel" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:gravel" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE "minecraft:short_grass" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE "stone" TO WS-F-SPEC
*>   5. An anvil onto a wall torch's cell: not replaceable either.
     MOVE "an anvil falling onto a wall torch's cell: the torch stays, the anvil becomes an item" TO WS-LABEL
     MOVE "wall_torch[facing=east]" TO WS-A-SPEC
     MOVE 1 TO WS-A-DY
     MOVE "stone" TO WS-C-SPEC
     MOVE -1 TO WS-C-DX
     MOVE 1 TO WS-C-DY
     MOVE "anvil" TO WS-B-SPEC
     MOVE 5 TO WS-B-DY
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "wall_torch[facing=east]" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:anvil" TO WS-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
*>   6. A wall torch hangs on a sand block that falls: the support goes, the torch pops and its item lies on the ground; the sand lands on the floor.
     MOVE "a wall torch on a falling sand block pops with its torch item, the sand lands" TO WS-LABEL
     MOVE SPACES TO WS-A-SPEC
     MOVE 0 TO WS-A-DY
     MOVE "sand" TO WS-B-SPEC
     MOVE 3 TO WS-B-DY
     MOVE "wall_torch[facing=east]" TO WS-C-SPEC
     MOVE 1 TO WS-C-DX
     MOVE 3 TO WS-C-DY
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "sand" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:torch" TO WS-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE 3 TO WS-DY
     MOVE 1 TO WS-DX
     MOVE "air" TO WS-WANT-SPEC
     PERFORM CHECK-CELL-AT
     MOVE 0 TO WS-DX
*>   7. A torch stands on a sand block that falls: the torch pops and drops its item, the sand lands.
     MOVE "a torch standing on a falling sand block pops with its torch item, the sand lands" TO WS-LABEL
     MOVE SPACES TO WS-A-SPEC
     MOVE 0 TO WS-A-DY
     MOVE "sand" TO WS-B-SPEC
     MOVE 3 TO WS-B-DY
     MOVE "torch" TO WS-C-SPEC
     MOVE 0 TO WS-C-DX
     MOVE 4 TO WS-C-DY
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "sand" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE 2 TO WS-DY
     MOVE "air" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:torch" TO WS-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
*>   8. A column of two gravel blocks in the air lands as a column on the floor, nothing lost.
     MOVE "a gravel column falls as a column and lands stacked" TO WS-LABEL
     MOVE SPACES TO WS-A-SPEC
     MOVE 0 TO WS-A-DY
     MOVE "gravel" TO WS-B-SPEC
     MOVE 4 TO WS-B-DY
     MOVE "gravel" TO WS-C-SPEC
     MOVE 0 TO WS-C-DX
     MOVE 5 TO WS-C-DY
     PERFORM RUN-CASE
     MOVE 1 TO WS-DY
     MOVE "gravel" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE 2 TO WS-DY
     PERFORM CHECK-CELL
     MOVE 3 TO WS-DY
     MOVE "air" TO WS-WANT-SPEC
     PERFORM CHECK-CELL
     MOVE "minecraft:gravel" TO WS-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     STOP RUN.

*> One case: the cube above the floor is cleared and the loose entities dropped; block A at floor + A-DY (when set), block C at floor + C-DY and dx C-DX (when set), then block B at
*> floor + B-DY is placed through BLOCK-CHANGE (it schedules its fall tick; a C equal to B is placed the same way) and the world runs 60 ticks.
 RUN-CASE.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             PERFORM VARYING WS-DY FROM 1 BY 1 UNTIL WS-DY > 9
                 COMPUTE WS-X = WS-PX + WS-DX
                 COMPUTE WS-Y = WS-FLOOR + WS-DY
                 COMPUTE WS-Z = WS-PZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     MOVE WS-F-SPEC TO WS-SPEC
     PERFORM SPEC-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-FLOOR WS-PZ WS-STATE
     IF WS-A-SPEC NOT = SPACES
         MOVE WS-A-SPEC TO WS-SPEC
         PERFORM SPEC-STATE
         COMPUTE WS-Y = WS-FLOOR + WS-A-DY
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
     END-IF
     IF WS-C-SPEC NOT = SPACES
         MOVE WS-C-SPEC TO WS-SPEC
         PERFORM SPEC-STATE
         COMPUTE WS-X = WS-PX + WS-C-DX
         COMPUTE WS-Y = WS-FLOOR + WS-C-DY
         IF WS-C-SPEC = WS-B-SPEC
             CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-PZ WS-STATE
         ELSE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-PZ WS-STATE
         END-IF
     END-IF
     MOVE WS-B-SPEC TO WS-SPEC
     PERFORM SPEC-STATE
     COMPUTE WS-Y = WS-FLOOR + WS-B-DY
     CALL "BLOCK-CHANGE" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS.

*> The state at floor + WS-DY in the case's column (dx WS-DX) must be that of WS-WANT-SPEC.
 CHECK-CELL.
     MOVE 0 TO WS-DX
     PERFORM CHECK-CELL-AT.
 CHECK-CELL-AT.
     MOVE WS-WANT-SPEC TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-WANT-STATE
     COMPUTE WS-X = WS-PX + WS-DX
     COMPUTE WS-Y = WS-FLOOR + WS-DY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-PZ WS-STATE
     MOVE WS-DY TO WS-DIGIT
     MOVE SPACES TO WS-CASE
     STRING "test falling block standard: " FUNCTION TRIM(WS-LABEL) ": the cell " WS-DIGIT " above the floor holds " FUNCTION TRIM(WS-WANT-SPEC)
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT-STATE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ground items of WS-ITEM-KEY (the sum of their counts) must equal WS-WANT-COUNT, and no falling block entity may be left.
 CHECK-ITEMS.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-WANT-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 0 TO WS-DROPPED WS-FALLING
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0 AND EN-ITEM-COUNT(WS-K) > 0 AND EN-ITEM(WS-K) = WS-WANT-ITEM
             ADD EN-ITEM-COUNT(WS-K) TO WS-DROPPED
         END-IF
         IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-FB-TYPE
             ADD 1 TO WS-FALLING
         END-IF
     END-PERFORM
     MOVE WS-WANT-COUNT TO WS-DIGIT2
     MOVE SPACES TO WS-CASE
     STRING "test falling block standard: " FUNCTION TRIM(WS-LABEL) ": " WS-DIGIT2 " x " FUNCTION TRIM(WS-ITEM-KEY) " lie on the ground"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT-COUNT TO TL-EXPECTED-N
     MOVE WS-DROPPED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "test falling block standard: " FUNCTION TRIM(WS-LABEL) ": no falling block entity is left" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FALLING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-STATE: the state of WS-SPEC, "key[name=value,name=value]": the block's default state with each property set.
 SPEC-STATE.
     MOVE 0 TO WS-STATE
     MOVE SPACES TO WS-SPEC-KEY WS-SPEC-PROPS
     MOVE 0 TO WS-BRACKET
     INSPECT WS-SPEC TALLYING WS-BRACKET FOR CHARACTERS BEFORE INITIAL "["
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC))
     IF WS-BRACKET < WS-LEN
         MOVE WS-SPEC(1:WS-BRACKET) TO WS-SPEC-KEY
         COMPUTE WS-LEFT = WS-LEN - WS-BRACKET - 2
         COMPUTE WS-E = WS-BRACKET + 2
         MOVE WS-SPEC(WS-E:WS-LEFT) TO WS-SPEC-PROPS
     ELSE
         MOVE FUNCTION TRIM(WS-SPEC) TO WS-SPEC-KEY
     END-IF
     MOVE SPACES TO WS-KEY112
     STRING "minecraft:" FUNCTION TRIM(WS-SPEC-KEY) DELIMITED BY SIZE INTO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-E
     IF WS-E >= 0
         MOVE CB-DEFAULT-STATE(WS-E + 1) TO WS-STATE
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-SPEC-PROPS = SPACES OR WS-POINTER > FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC-PROPS))
             MOVE SPACES TO WS-PAIR
             UNSTRING WS-SPEC-PROPS DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POINTER
             MOVE SPACES TO WS-PAIR-NAME WS-PAIR-VALUE
             UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-PAIR-NAME WS-PAIR-VALUE
             CALL "PS-PUT" USING WS-STATE WS-PAIR-NAME WS-PAIR-VALUE
         END-PERFORM
     END-IF.
 END PROGRAM TEST-FALLING-BLOCK-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
