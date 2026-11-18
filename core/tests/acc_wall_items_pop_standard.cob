 *> Acceptance test, lane wallitems (CC-0009: "breaking the wall does not pop torches or buttons"; docs/protocol/29 section 3.2 updateShape and canSurvive, 24 parts 2 to 7, 25 part 4 section 9.2): a superflat world of the
*> standard content set (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). Each case builds a stone block in the air, puts a block that hangs on it (a wall or standing torch, sign, hanging sign,
*> ladder, lever, button, grindstone, banner, lantern, vine, glow lichen, coral fan) against it, takes the stone away with BLOCK-CHANGE (Level.setBlock with flags 3, as a break does) and expects the attached block
*> to be gone and its item (the item of the standing block for a wall variant) to lie on the ground; a skull and a head have no support rule and stay.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WALL-ITEMS-POP-STANDARD.
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
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
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
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-WANT-ITEM           BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(96) VALUE "a wall torch falls when its wall is broken                                                      ".
    05 FILLER PIC X(64) VALUE "wall_torch[facing=north]                                        ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "torch                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a soul wall torch falls when its wall is broken                                                 ".
    05 FILLER PIC X(64) VALUE "soul_wall_torch[facing=east]                                    ".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "soul_torch                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a redstone wall torch falls when its wall is broken                                             ".
    05 FILLER PIC X(64) VALUE "redstone_wall_torch[facing=east]                                ".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "redstone_torch                  ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a copper wall torch falls when its wall is broken                                               ".
    05 FILLER PIC X(64) VALUE "copper_wall_torch[facing=west]                                  ".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "copper_torch                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a torch falls when the block under it is broken                                                 ".
    05 FILLER PIC X(64) VALUE "torch                                                           ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "torch                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wall sign falls when its wall is broken                                                       ".
    05 FILLER PIC X(64) VALUE "oak_wall_sign[facing=west]                                      ".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a standing sign falls when the block under it is broken                                         ".
    05 FILLER PIC X(64) VALUE "oak_sign[rotation=4]                                            ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a ceiling hanging sign falls when the block above it is broken                                  ".
    05 FILLER PIC X(64) VALUE "oak_hanging_sign[attached=false,rotation=0]                     ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a ladder falls when its wall is broken                                                          ".
    05 FILLER PIC X(64) VALUE "ladder[facing=north]                                            ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wall lever falls when its wall is broken                                                      ".
    05 FILLER PIC X(64) VALUE "lever[face=wall,facing=south]                                   ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a floor lever falls when the block under it is broken                                           ".
    05 FILLER PIC X(64) VALUE "lever[face=floor,facing=east]                                   ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a ceiling lever falls when the block above it is broken                                         ".
    05 FILLER PIC X(64) VALUE "lever[face=ceiling,facing=east]                                 ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wall button falls when its wall is broken                                                     ".
    05 FILLER PIC X(64) VALUE "stone_button[face=wall,facing=east]                             ".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "stone_button                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wooden button falls when the block under it is broken                                         ".
    05 FILLER PIC X(64) VALUE "oak_button[face=floor,facing=north]                             ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "oak_button                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wall grindstone falls when its wall is broken                                                 ".
    05 FILLER PIC X(64) VALUE "grindstone[face=wall,facing=east]                               ".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "grindstone                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a wall banner falls when its wall is broken                                                     ".
    05 FILLER PIC X(64) VALUE "white_wall_banner[facing=north]                                 ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "white_banner                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a standing banner falls when the block under it is broken                                       ".
    05 FILLER PIC X(64) VALUE "white_banner[rotation=0]                                        ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "white_banner                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a hanging lantern falls when the block above it is broken                                       ".
    05 FILLER PIC X(64) VALUE "lantern[hanging=true]                                           ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a lantern falls when the block under it is broken                                               ".
    05 FILLER PIC X(64) VALUE "lantern[hanging=false]                                          ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a vine goes when the wall it holds on is broken                                                 ".
    05 FILLER PIC X(64) VALUE "vine[south=true]                                                ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "glow lichen goes when the block it holds on is broken                                           ".
    05 FILLER PIC X(64) VALUE "glow_lichen[down=true]                                          ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a dead coral wall fan goes when its wall is broken (a fan drops only with silk touch)                           ".
    05 FILLER PIC X(64) VALUE "dead_tube_coral_wall_fan[facing=north,waterlogged=false]        ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a dead coral fan goes when the block under it is broken                                        ".
    05 FILLER PIC X(64) VALUE "dead_tube_coral_fan[waterlogged=false]                          ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a skull stays when the block under it is broken (a head can float)                              ".
    05 FILLER PIC X(64) VALUE "skeleton_skull[rotation=0]                                      ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+1".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a wall skull stays when its wall is broken                                                      ".
    05 FILLER PIC X(64) VALUE "skeleton_wall_skull[facing=north]                               ".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "+0".
    05 FILLER PIC X(2) VALUE "-1".
    05 FILLER PIC X(32) VALUE "-                               ".
    05 FILLER PIC X(1) VALUE "0".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-ROW OCCURS 25 TIMES.
       10 WS-C-LABEL        PIC X(96).
       10 WS-C-SPEC         PIC X(64).
       10 WS-C-DX           PIC X(2).
       10 WS-C-DY           PIC X(2).
       10 WS-C-DZ           PIC X(2).
       10 WS-C-ITEM         PIC X(32).
       10 WS-C-GONE         PIC 9.
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
         MOVE "acceptance wall items pop standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "WallPop" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-SPEC
     PERFORM SPEC-STATE
     MOVE WS-STATE TO WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PY = WS-FLOOR + 4
     COMPUTE WS-PZ = WS-BZ + 6
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         PERFORM RUN-CASE
     END-PERFORM
     STOP RUN.

*> One case: stone at the middle, the block next to it, the stone taken away.
 RUN-CASE.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-X = WS-PX + WS-DX
                 COMPUTE WS-Y = WS-PY + WS-DY
                 COMPUTE WS-Z = WS-PZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         MOVE 0 TO EN-USED(WS-K)
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-PZ WS-STONE
     MOVE WS-C-SPEC(WS-I) TO WS-SPEC
     PERFORM SPEC-STATE
     COMPUTE WS-X = WS-PX + FUNCTION NUMVAL(WS-C-DX(WS-I))
     COMPUTE WS-Y = WS-PY + FUNCTION NUMVAL(WS-C-DY(WS-I))
     COMPUTE WS-Z = WS-PZ + FUNCTION NUMVAL(WS-C-DZ(WS-I))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-PX WS-PY WS-PZ WS-AIR
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
*>   Gone (state 0) or still there (the state of the block).
     MOVE SPACES TO WS-CASE
     STRING "acceptance wall items pop standard: " FUNCTION TRIM(WS-C-LABEL(WS-I)) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-C-GONE(WS-I) TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATE = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Its item on the ground.
     IF WS-C-ITEM(WS-I) NOT = "-" AND WS-C-GONE(WS-I) = 1
         MOVE FUNCTION TRIM(WS-C-ITEM(WS-I)) TO WS-KEY112
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-WANT-ITEM WS-ITEM-ROW WS-STATUS
         MOVE 0 TO WS-DROPPED
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
             IF EN-USED(WS-K) = 1 AND EN-PLAYER(WS-K) = 0 AND EN-ITEM-COUNT(WS-K) > 0 AND EN-ITEM(WS-K) = WS-WANT-ITEM
                 ADD 1 TO WS-DROPPED
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance wall items pop standard: the item of the fallen block lies on the ground (" FUNCTION TRIM(WS-C-ITEM(WS-I)) ")" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-DROPPED TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF.

*> WS-STATE: the state of WS-SPEC, "key[name=value,name=value]": the block's default state with each property set; 0 for a key the set does not hold.
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
 END PROGRAM ACC-WALL-ITEMS-POP-STANDARD.
 COPY CORETEST.
 COPY CMDTEST.
