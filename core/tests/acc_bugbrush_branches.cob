*> Acceptance test, lane bugbrush (CC-0022; docs/protocol 17 section 3.5, 25 part 8 section 7, 31-4 section 7): the branches of the brush that the use test acc_bugbrush_use does not
*> reach, in a standard world with the generated data pack (CC_GENERATED_DIR; skipped as a pass without it). The view ray of the player (BRUSH-HIT) names the face it came
*> through for a block hit from above, below and each side; the reach is 4.5 blocks and 5.0 in creative; Use Item On with the off hand or with a stack that is not a brush
*> starts nothing; a use of more than 200 ticks is released; a brushing step on a block without a block entity changes nothing, and a second brush in the same tick is
*> refused by the cooldown (31-4 section 7.4 step 3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGBRUSH-BRANCHES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY PLAYPKT.
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
 01 WS-BRUSH               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROP                PIC X(24) VALUE "dusted".
 01 WS-PTEXT               PIC X(32).
 01 WS-PMODE               BINARY-LONG VALUE 1.
 01 WS-DIGIT               PIC 9.
 01 WS-RES                 BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-TABLE               PIC X(64) VALUE "minecraft:archaeology/desert_pyramid".
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-CASE                PIC X(240).
 01 WS-WANT                BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-HFACE               BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-WANT-FACE           BINARY-LONG.
 01 WS-LABEL               PIC X(24).
 01 WS-FACE-TEXT           PIC 9.
 01 WS-FACE                BINARY-LONG VALUE 2.
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
         MOVE "acceptance bugbrush branches no generated packs here, skipped" TO TL-CASE
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
     MOVE "BugbrushBranches" TO CS-NEW-WORLD-NAME
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
     MOVE "brush" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-BRUSH WS-ITEM-ROW WS-STATUS
     MOVE "stick" TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-STICK WS-ITEM-ROW WS-STATUS
*>   A stone platform high above the terrain with eight layers of air over a 13 x 13 area, the target block floating at floor + 4.
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
     COMPUTE WS-SX = WS-BX + 6
     COMPUTE WS-SY = WS-FLOOR + 4
     COMPUTE WS-SZ = WS-BZ + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA

*>   --- The face the view ray came through (up 1, down 0, north 2, south 3, west 4, east 5): the eye is 1.6 above the feet ---
     MOVE "above" TO WS-LABEL
     COMPUTE WS-PX = WS-SX + 0.5
     COMPUTE WS-PY = WS-SY + 0.1
     COMPUTE WS-PZ = WS-SZ + 0.5
     MOVE 0 TO WS-YAW
     MOVE 90 TO WS-PITCH
     MOVE 1 TO WS-WANT-FACE
     PERFORM RAY-CASE
     MOVE "below" TO WS-LABEL
     COMPUTE WS-PY = WS-SY - 2.1
     MOVE -90 TO WS-PITCH
     MOVE 0 TO WS-WANT-FACE
     PERFORM RAY-CASE
     MOVE "the east side" TO WS-LABEL
     COMPUTE WS-PX = WS-SX + 1.5
     COMPUTE WS-PY = WS-SY - 1.1
     MOVE 90 TO WS-YAW
     MOVE 0 TO WS-PITCH
     MOVE 5 TO WS-WANT-FACE
     PERFORM RAY-CASE
     MOVE "the west side" TO WS-LABEL
     COMPUTE WS-PX = WS-SX - 0.5
     MOVE -90 TO WS-YAW
     MOVE 4 TO WS-WANT-FACE
     PERFORM RAY-CASE
     MOVE "the south side" TO WS-LABEL
     COMPUTE WS-PX = WS-SX + 0.5
     COMPUTE WS-PZ = WS-SZ + 1.5
     MOVE 180 TO WS-YAW
     MOVE 3 TO WS-WANT-FACE
     PERFORM RAY-CASE
     MOVE "the north side" TO WS-LABEL
     COMPUTE WS-PZ = WS-SZ - 0.5
     MOVE 0 TO WS-YAW
     MOVE 2 TO WS-WANT-FACE
     PERFORM RAY-CASE

*>   --- The reach: 4.5 blocks, 5.0 in creative (the block is entered 4.8 blocks along the ray) ---
     COMPUTE PL-X(WS-PLAYER) = WS-SX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-SY - 1.1
     COMPUTE PL-Z(WS-PLAYER) = WS-SZ - 4.8
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     CALL "BRUSH-HIT" USING WS-PLAYER WS-HIT WS-HX WS-HY WS-HZ WS-HFACE
     MOVE "acceptance bugbrush branches: a block 4.8 blocks away is out of reach in survival" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-HIT TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "BRUSH-HIT" USING WS-PLAYER WS-HIT WS-HX WS-HY WS-HZ WS-HFACE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance bugbrush branches: the same block is within the creative reach of 5 blocks" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE WS-HIT TO WS-GOT
     PERFORM CHECK-NUMBER

*>   --- Use Item On that starts nothing ---
     COMPUTE PL-X(WS-PLAYER) = WS-SX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-SY - 1.1
     COMPUTE PL-Z(WS-PLAYER) = WS-SZ - 2.5
     MOVE 1 TO PSB-HAND
     CALL "BRUSH-START" USING WS-CONN PLAY-SERVERBOUND WS-STARTED
     MOVE "acceptance bugbrush branches: Use Item On with the off hand does not start the brush" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-STARTED TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE 0 TO PSB-HAND
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "BRUSH-START" USING WS-CONN PLAY-SERVERBOUND WS-STARTED
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE "acceptance bugbrush branches: Use Item On with a stick in the main hand does not start the brush" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE WS-STARTED TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE "acceptance bugbrush branches: neither start left the brush in use" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE PL-BRUSH-ACTIVE(WS-PLAYER) TO WS-GOT
     PERFORM CHECK-NUMBER
     CALL "BRUSH-START" USING WS-CONN PLAY-SERVERBOUND WS-STARTED
     MOVE "acceptance bugbrush branches: Use Item On with the brush in the main hand toward the block starts it" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE WS-STARTED TO WS-GOT
     PERFORM CHECK-NUMBER

*>   --- A use of more than 200 ticks is released (the first tick of the use is 1) ---
     MOVE 200 TO PL-BRUSH-USED(WS-PLAYER)
     CALL "BRUSH-TICK" USING WS-PLAYER
     MOVE "acceptance bugbrush branches: the use is still on at its 201st tick" TO WS-CASE
     MOVE 1 TO WS-WANT
     MOVE PL-BRUSH-ACTIVE(WS-PLAYER) TO WS-GOT
     PERFORM CHECK-NUMBER
     MOVE 201 TO PL-BRUSH-USED(WS-PLAYER)
     CALL "BRUSH-TICK" USING WS-PLAYER
     MOVE "acceptance bugbrush branches: the 202nd tick of the use releases the brush" TO WS-CASE
     MOVE 0 TO WS-WANT
     MOVE PL-BRUSH-ACTIVE(WS-PLAYER) TO WS-GOT
     PERFORM CHECK-NUMBER

*>   --- A brushing step on a suspicious block without a block entity changes nothing ---
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-SUS-SAND
     CALL "BE-FIND" USING WS-DIM WS-SX WS-SY WS-SZ WS-BE
     IF WS-BE > 0
         MOVE 0 TO BE-USED(WS-BE)
     END-IF
     CALL "BRUSH-STEP" USING WS-PLAYER WS-SX WS-SY WS-SZ WS-FACE
     PERFORM GET-DUSTED
     MOVE "acceptance bugbrush branches: a brushing step on a suspicious block without a block entity leaves it undusted" TO WS-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-NUMBER

*>   --- A second brush in the same tick is refused by the cooldown ---
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-SUS-SAND
     CALL "BE-FIND" USING WS-DIM WS-SX WS-SY WS-SZ WS-BE
     IF WS-BE > 0
         MOVE WS-TABLE TO BE-LOOT(WS-BE)
         MOVE 37 TO BE-LOOT-LENGTH(WS-BE)
         MOVE WS-SEED TO BE-SEED(WS-BE)
     END-IF
     CALL "BRUSH-STEP" USING WS-PLAYER WS-SX WS-SY WS-SZ WS-FACE
     PERFORM GET-DUSTED
     MOVE "acceptance bugbrush branches: the first brush of the block raises its dusted value to 1" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM CHECK-NUMBER
     CALL "BRUSH-STEP" USING WS-PLAYER WS-SX WS-SY WS-SZ WS-FACE
     PERFORM GET-DUSTED
     MOVE "acceptance bugbrush branches: a second brush in the same tick is refused by the cooldown, dusted stays 1" TO WS-CASE
     MOVE 1 TO WS-WANT
     PERFORM CHECK-NUMBER
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     STOP RUN.

*> The player stands at WS-PX, WS-PY, WS-PZ looking by WS-YAW and WS-PITCH: BRUSH-HIT must hit the target block (WS-SX, WS-SY, WS-SZ) through the face WS-WANT-FACE.
 RAY-CASE.
     COMPUTE PL-X(WS-PLAYER) = WS-PX
     COMPUTE PL-Y(WS-PLAYER) = WS-PY
     COMPUTE PL-Z(WS-PLAYER) = WS-PZ
     COMPUTE PL-YAW(WS-PLAYER) = WS-YAW
     COMPUTE PL-PITCH(WS-PLAYER) = WS-PITCH
     CALL "BRUSH-HIT" USING WS-PLAYER WS-HIT WS-HX WS-HY WS-HZ WS-HFACE
     MOVE SPACES TO WS-CASE
     MOVE WS-WANT-FACE TO WS-FACE-TEXT
     STRING "acceptance bugbrush branches: the view ray from " FUNCTION TRIM(WS-LABEL) " hits the block through face " WS-FACE-TEXT
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-WANT-FACE TO WS-WANT
     MOVE 99 TO WS-GOT
     IF WS-HIT = 1 AND WS-HX = WS-SX AND WS-HY = WS-SY AND WS-HZ = WS-SZ
         MOVE WS-HFACE TO WS-GOT
     END-IF
     PERFORM CHECK-NUMBER.

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

 CHECK-NUMBER.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGBRUSH-BRANCHES.

 COPY CORETEST.
 COPY CMDTEST.
