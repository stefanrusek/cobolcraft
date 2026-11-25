*> Acceptance test, lane bugupdateorder (operator report of try18: place dirt, a lantern on the dirt, sand on the lantern and another sand on that sand, break the dirt: the lantern must
*> break first (its shape update runs synchronously inside the removal of the dirt, 29 section 3.2 and 13.2: updateShape returns air and updateOrDestroy destroys the lantern with its drop at
*> once), the sand only SCHEDULES its fall tick (29b part 1 section 3.1: PL and SU rows, delay 2) and turns into a falling block entity two ticks later, when the cell below is free, so
*> the two sand blocks fall through the cleared cells and end stacked on the ground where the dirt was; one lantern item, no sand item). A standard world (CC_GENERATED_DIR; skipped as a pass
*> without it) driven through the packet path: Use Item On places each block, Player Action breaks the support, CORE-TICK runs the world one tick at a time. The falling block's per-tick
*> motion is compared with the table of 29b part 1 section 8.1 (0.04 gravity, 0.98 drag).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-UPDATE-ORDER-STANDARD.
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
 01 WS-FB-TYPE             BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-LAYER-SPEC          PIC X(120) OCCURS 5 TIMES.
 01 WS-LAYER-STATE         BINARY-LONG OCCURS 5 TIMES.
 01 WS-LAYER-ITEM          PIC X(112) OCCURS 5 TIMES.
 01 WS-WANT-STATE          BINARY-LONG.
 01 WS-WANT-ITEM-KEY       PIC X(112).
 01 WS-WANT-COUNT          BINARY-LONG.
 01 WS-WANT-DELAY          BINARY-LONG.
 01 WS-FIRST-SEEN          BINARY-LONG.
 01 WS-LAST-SEEN           BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-EARLY               BINARY-LONG.
 01 WS-TRACE               PIC X(400).
 01 WS-TRACE-AT            BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DIGIT               PIC 99.
 01 WS-CUM                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-EXPECTED-TAB.
    05 WS-EXPECTED-FALL    FLOAT-LONG OCCURS 9 TIMES.
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
         MOVE "acceptance update order standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "UpdateOrder" TO CS-NEW-WORLD-NAME
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
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PZ = WS-BZ + 5
     COMPUTE PL-X(WS-PLAYER) = WS-PX + 3.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-PZ + 0.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

*>   Table of 29b part 1 section 8.1: the fall distance of a falling block after each tick (gravity 0.04, drag 0.98)
     MOVE 0.04 TO WS-EXPECTED-FALL(1)
     MOVE 0.1192 TO WS-EXPECTED-FALL(2)
     MOVE 0.236816 TO WS-EXPECTED-FALL(3)
     MOVE 0.39208 TO WS-EXPECTED-FALL(4)
     MOVE 0.584238 TO WS-EXPECTED-FALL(5)
     MOVE 0.812553 TO WS-EXPECTED-FALL(6)
     MOVE 1.076302 TO WS-EXPECTED-FALL(7)
     MOVE 1.374776 TO WS-EXPECTED-FALL(8)
     MOVE 1.707281 TO WS-EXPECTED-FALL(9)

*>   1. The operator's stack, creative: dirt, lantern, sand, sand; the dirt broken.
     MOVE "creative: dirt, lantern, sand, sand; the dirt is broken" TO WS-LABEL
     MOVE "dirt" TO WS-LAYER-SPEC(1)
     MOVE "lantern" TO WS-LAYER-SPEC(2)
     MOVE "sand" TO WS-LAYER-SPEC(3)
     MOVE "sand" TO WS-LAYER-SPEC(4)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
*>   2. The same in survival, the dirt dug by hand.
     MOVE "survival: dirt, lantern, sand, sand; the dirt is dug" TO WS-LABEL
     MOVE 0 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
*>   3. Gravel over a lantern over a dirt, and a soul lantern under red sand.
     MOVE "gravel over a soul lantern" TO WS-LABEL
     MOVE "soul_lantern" TO WS-LAYER-SPEC(2)
     MOVE "gravel" TO WS-LAYER-SPEC(3)
     MOVE "gravel" TO WS-LAYER-SPEC(4)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
     MOVE "lantern" TO WS-LAYER-SPEC(2)
     MOVE "sand" TO WS-LAYER-SPEC(3)
     MOVE "sand" TO WS-LAYER-SPEC(4)
*>   4. A torch instead of the lantern.
     MOVE "torch instead of the lantern" TO WS-LABEL
     MOVE "torch" TO WS-LAYER-SPEC(2)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
*>   5. A sign, a button, a carpet on the dirt.
     MOVE "oak_sign instead of the lantern" TO WS-LABEL
     MOVE "oak_sign" TO WS-LAYER-SPEC(2)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
     MOVE "stone_button instead of the lantern" TO WS-LABEL
     MOVE "stone_button" TO WS-LAYER-SPEC(2)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
     MOVE "white_carpet instead of the lantern" TO WS-LABEL
     MOVE "white_carpet" TO WS-LAYER-SPEC(2)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
*>   6. Concrete powder over the lantern.
     MOVE "white_concrete_powder over the lantern" TO WS-LABEL
     MOVE "lantern" TO WS-LAYER-SPEC(2)
     MOVE "white_concrete_powder" TO WS-LAYER-SPEC(3)
     MOVE "white_concrete_powder" TO WS-LAYER-SPEC(4)
     MOVE 1 TO WS-MODE
     PERFORM RUN-STACK
     PERFORM CHECK-STACK-STANDARD
     MOVE "sand" TO WS-LAYER-SPEC(3)
     MOVE "sand" TO WS-LAYER-SPEC(4)

*>   7. The motion of a falling block, tick by tick, against the table of 29b part 1 section 8.1.
     PERFORM CHECK-MOTION
*>   8. A block of every falling kind over a drop of 10 cells: it is an entity for many ticks and lands only when it arrives (never settled within one tick).
     MOVE "sand" TO WS-LAYER-SPEC(1)
     MOVE 2 TO WS-WANT-DELAY
     PERFORM DROP-CASE
     MOVE "gravel" TO WS-LAYER-SPEC(1)
     PERFORM DROP-CASE
     MOVE "red_sand" TO WS-LAYER-SPEC(1)
     PERFORM DROP-CASE
     MOVE "white_concrete_powder" TO WS-LAYER-SPEC(1)
     PERFORM DROP-CASE
     MOVE "anvil" TO WS-LAYER-SPEC(1)
     PERFORM DROP-CASE
     MOVE "dragon_egg" TO WS-LAYER-SPEC(1)
     MOVE 5 TO WS-WANT-DELAY
     PERFORM DROP-CASE
     STOP RUN.

*> WS-LAYER-SPEC(1) placed at floor + 11 through the level (its onPlace schedules the fall check): no entity before the delay WS-WANT-DELAY (29b part 1 section 3.1: 2, the dragon egg 5),
*> then an entity that lives at least 8 ticks (10 cells take 12 to 13), the landing cell floor + 1 stays empty while it lives, the block is there afterwards, and the cell it came from is air.
 DROP-CASE.
     MOVE WS-LAYER-SPEC(1) TO WS-LABEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-DY FROM 1 BY 1 UNTIL WS-DY > 12
         COMPUTE WS-Y = WS-FLOOR + WS-DY
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-AIR
     END-PERFORM
     MOVE WS-LAYER-SPEC(1) TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-WANT-STATE
     COMPUTE WS-Y = WS-FLOOR + 11
     CALL "BLOCK-CHANGE" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
     MOVE 0 TO WS-FIRST-SEEN WS-ALIVE WS-EARLY WS-LAST-SEEN
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 40
         MOVE 1 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         MOVE 0 TO WS-FALLING
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
             IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-FB-TYPE
                 ADD 1 TO WS-FALLING
             END-IF
         END-PERFORM
         COMPUTE WS-Y = WS-FLOOR + 1
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         IF WS-FALLING > 0
             ADD 1 TO WS-ALIVE
             IF WS-FIRST-SEEN = 0
                 MOVE WS-T TO WS-FIRST-SEEN
             END-IF
             MOVE WS-T TO WS-LAST-SEEN
             IF WS-STATE NOT = 0
                 ADD 1 TO WS-EARLY
             END-IF
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-CASE
     MOVE WS-WANT-DELAY TO WS-DIGIT
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) " placed in the air becomes a falling block entity after its delay of " WS-DIGIT " ticks"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT-DELAY TO TL-EXPECTED-N
     MOVE WS-FIRST-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) " falls over many ticks (the entity lives at least 8 ticks for a drop of 10 cells)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ALIVE >= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) " is not placed on the ground while its entity still flies"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EARLY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) " lies on the ground afterwards" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WANT-STATE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Clears the column, then builds layers 1 to 4 at floor + 1 .. floor + 4 with Use Item On from the hotbar (every placement on the top face of the block below), checks that all
*> four stand, breaks layer 1 (creative: Player Action start; survival: start, 20 ticks, finish) and traces the column.
 RUN-STACK.
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
     MOVE WS-MODE TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-LAYER-SPEC(WS-I) TO WS-SPEC
         PERFORM SPEC-STATE
         MOVE WS-STATE TO WS-LAYER-STATE(WS-I)
         MOVE SPACES TO WS-LAYER-ITEM(WS-I)
         STRING "minecraft:" FUNCTION TRIM(WS-LAYER-SPEC(WS-I)) DELIMITED BY SIZE INTO WS-LAYER-ITEM(WS-I)
         MOVE WS-LAYER-ITEM(WS-I) TO WS-KEY112
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
         MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
         MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
         MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
         MOVE 0 TO PL-HELD(WS-PLAYER)
         COMPUTE WS-Y = WS-FLOOR + WS-I - 1
         ADD 1 TO WS-SEQ
         CALL "TEST-USE-ON" USING WS-CONN WS-PX WS-Y WS-PZ WS-FACE WS-SEQ
         CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
*>       The state of the layer is what the placement made (a button's face and facing, a sign's rotation depend on the click). A click on a sign opens its editor instead of
*>       placing the block (31 part 3 section 2.5), so a block above a sign is placed by the level (BLOCK-CHANGE, the placement's own update path).
         IF WS-STATE = 0 AND WS-I > 1
             MOVE WS-LAYER-STATE(WS-I) TO WS-STATE
             CALL "BLOCK-CHANGE" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         END-IF
         MOVE WS-STATE TO WS-LAYER-STATE(WS-I)
     END-PERFORM
*>   The placement ticks of the sand (delay 2) run now; nothing falls (the cells below are not free).
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
*>   A button pressed by the click on it is back to rest after the ticks: the layer states are read once the column has settled.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-LAYER-STATE(WS-I)
     END-PERFORM
     PERFORM CHECK-BUILT
*>   Break layer 1 through Player Action
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO WS-ACTION
     COMPUTE WS-Y = WS-FLOOR + 1
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-PX WS-Y WS-PZ WS-FACE WS-SEQ
     IF WS-MODE = 0
         MOVE 20 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         MOVE 3 TO WS-ACTION
         ADD 1 TO WS-SEQ
         CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-PX WS-Y WS-PZ WS-FACE WS-SEQ
     END-IF
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
*>   Trace: the state of the break at once (before any tick) and after every tick
     MOVE SPACES TO WS-TRACE
     MOVE 1 TO WS-TRACE-AT
     PERFORM TRACE-COLUMN
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         MOVE 1 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         PERFORM TRACE-COLUMN
     END-PERFORM
     DISPLAY "TRACE " FUNCTION TRIM(WS-LABEL) ": " FUNCTION TRIM(WS-TRACE).

*> Appends " <c1><c2><c3><c4>/<falling><items>" to WS-TRACE: per cell '.' air, the layer number when the cell holds that layer's state, '?' another block.
 TRACE-COLUMN.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         MOVE "?" TO WS-CH
         IF WS-STATE = 0
             MOVE "." TO WS-CH
         END-IF
         PERFORM VARYING WS-K FROM 4 BY -1 UNTIL WS-K < 1
             IF WS-STATE = WS-LAYER-STATE(WS-K)
                 MOVE WS-K TO WS-DIGIT
                 MOVE WS-DIGIT(2:1) TO WS-CH
             END-IF
         END-PERFORM
         MOVE WS-CH TO WS-TRACE(WS-TRACE-AT:1)
         ADD 1 TO WS-TRACE-AT
     END-PERFORM
     MOVE 0 TO WS-FALLING
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-FB-TYPE
             ADD 1 TO WS-FALLING
         END-IF
     END-PERFORM
     MOVE WS-FALLING TO WS-DIGIT
     MOVE WS-DIGIT(2:1) TO WS-TRACE(WS-TRACE-AT:1)
     ADD 1 TO WS-TRACE-AT
     MOVE " " TO WS-TRACE(WS-TRACE-AT:1)
     ADD 1 TO WS-TRACE-AT.

*> Each of the four layers stands where it was placed.
 CHECK-BUILT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-Y = WS-FLOOR + WS-I
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
         MOVE WS-I TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": layer " WS-DIGIT " (" FUNCTION TRIM(WS-LAYER-SPEC(WS-I))
             ") stands after the build" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-LAYER-STATE(WS-I) TO TL-EXPECTED-N
         MOVE WS-STATE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO WS-CASE
         STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": layer " WS-DIGIT " is a block" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-STATE NOT = 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

*> The outcome of the operator's report after the trace of RUN-STACK: layer 3 and 4 (the falling blocks) end stacked at floor + 1 and floor + 2 (where the dirt and the attached block
*> stood), floor + 3 and + 4 are air, one item of layer 2 lies on the ground, no item of layer 3 or 4, no falling block entity is left; and the falling block entities appear only after
*> the delay of 2 ticks (no entity in the first tick after the break, 29b part 1 section 3.1).
 CHECK-STACK-STANDARD.
     MOVE 1 TO WS-DY
     MOVE WS-LAYER-STATE(3) TO WS-WANT-STATE
     PERFORM CHECK-CELL
     MOVE 2 TO WS-DY
     MOVE WS-LAYER-STATE(4) TO WS-WANT-STATE
     PERFORM CHECK-CELL
     MOVE 3 TO WS-DY
     MOVE 0 TO WS-WANT-STATE
     PERFORM CHECK-CELL
     MOVE 4 TO WS-DY
     MOVE 0 TO WS-WANT-STATE
     PERFORM CHECK-CELL
     MOVE WS-LAYER-ITEM(2) TO WS-WANT-ITEM-KEY
     MOVE 1 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     MOVE WS-LAYER-ITEM(3) TO WS-WANT-ITEM-KEY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-ITEMS
     PERFORM CHECK-TIMELINE.

*> The first trace entry is the column right after the break, before any tick: the dirt and the attached block are gone (the shape update destroyed it at once), the two falling blocks
*> have not moved and no entity exists yet; the entry after tick 1 is the same (the fall check was scheduled with delay 2, 29b part 1 section 3.1).
 CHECK-TIMELINE.
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": right after the break the attached block is destroyed and the sand has not moved yet" DELIMITED BY SIZE
         INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "..330" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TRACE(1:5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": one tick after the break the sand has still not turned into an entity (delay 2)" DELIMITED BY SIZE
         INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "..330" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TRACE(7:5) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The state at floor + WS-DY in the column must be WS-WANT-STATE.
 CHECK-CELL.
     COMPUTE WS-Y = WS-FLOOR + WS-DY
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE
     MOVE WS-DY TO WS-DIGIT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": the cell " WS-DIGIT " above the floor ends as expected" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT-STATE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The ground items of WS-WANT-ITEM-KEY (the sum of their counts) must equal WS-WANT-COUNT, and no falling block entity may be left.
 CHECK-ITEMS.
     MOVE WS-WANT-ITEM-KEY TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE 0 TO WS-DROPPED WS-FALLING
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0 AND EN-ITEM-COUNT(WS-K) > 0 AND EN-ITEM(WS-K) = WS-ITEM-ID
             ADD EN-ITEM-COUNT(WS-K) TO WS-DROPPED
         END-IF
         IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-FB-TYPE
             ADD 1 TO WS-FALLING
         END-IF
     END-PERFORM
     MOVE WS-WANT-COUNT TO WS-DIGIT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": " WS-DIGIT " x " FUNCTION TRIM(WS-WANT-ITEM-KEY) " lie on the ground" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-WANT-COUNT TO TL-EXPECTED-N
     MOVE WS-DROPPED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-CASE
     STRING "acceptance update order standard: " FUNCTION TRIM(WS-LABEL) ": no falling block entity is left" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FALLING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> A falling block spawned 25 cells above the floor with nothing in the way: after each of ticks 1 to 9 its fall distance is that of the table of 29b part 1 section 8.1.
 CHECK-MOTION.
     MOVE "motion" TO WS-LABEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0
             MOVE 0 TO EN-USED(WS-K)
         END-IF
     END-PERFORM
     MOVE "sand" TO WS-SPEC
     PERFORM SPEC-STATE
     COMPUTE WS-Y = WS-FLOOR + 25
     CALL "FB-SPAWN" USING WS-DIM WS-PX WS-Y WS-PZ WS-STATE WS-E
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 9
         MOVE 1 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         COMPUTE WS-CUM = (WS-FLOOR + 25) - EN-Y(WS-E)
         COMPUTE WS-DIFF = FUNCTION ABS(WS-CUM - WS-EXPECTED-FALL(WS-T)) * 1000000
         MOVE WS-T TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "acceptance update order standard: a falling block has fallen the distance of the table of 29b part 1 section 8.1 after tick " WS-DIGIT
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE 0 TO TL-EXPECTED-N
         IF WS-DIFF < 5
             MOVE 0 TO TL-OBSERVED-N
         ELSE
             COMPUTE TL-OBSERVED-N = WS-DIFF
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

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
 END PROGRAM ACC-UPDATE-ORDER-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
