*> Acceptance test of the notation of the nether fortress geometry lists (docs/protocol/36-structures-8-nether-and-end.md section 1, 1.1 and 1.2; core/src/struct-fortress-post.cob): a fill and a
*> put overwrite whatever is there (canBeReplaced true), the column under a piece fills downward through air and liquid but stops at a solid block, a fence's sides written for the north frame
*> are mirrored and turned for the other orientations (FENCE(E,W) facing east is S,N), and every cell is clipped to the write box.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENBE.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-NAME                PIC X(60).
 01 WS-REST                PIC X(60).
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BADC                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 4.
 01 WS-BY                  BINARY-LONG VALUE 60.
 01 WS-BZ                  BINARY-LONG VALUE 4.
 01 WS-LAST-CASE           BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEEDS               BINARY-DOUBLE UNSIGNED.
 01 WS-N                   BINARY-LONG.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SEEN                PIC X(240).
 01 WS-NBR                 BINARY-LONG.
 01 WS-AIRS                BINARY-LONG VALUE 0.
 01 WS-STRIPS.
    05 WS-STRIP OCCURS 27 TIMES.
       10 WS-ST-X          BINARY-LONG.
       10 WS-ST-Y          BINARY-LONG.
       10 WS-ST-N          BINARY-LONG.
 01 WS-NSTRIP              BINARY-LONG.
 01 WS-COVER               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-CHEST-STATE         BINARY-LONG.
 01 WS-SPAWNER-STATE       BINARY-LONG.
 01 WS-STONE               BINARY-LONG.

 01 WS-WATER               BINARY-LONG.
 01 WS-FENCE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 0 TO SW-X0
     MOVE -63 TO SW-Y0
     MOVE 0 TO SW-Z0
     MOVE 15 TO SW-X1
     MOVE 319 TO SW-Y1
     MOVE 15 TO SW-Z1
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:water" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WATER
     MOVE "minecraft:nether_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-NBR
     CALL "SPB-RESET"
     MOVE LOW-VALUES TO CE-CHUNK
*>   a room crossing facing north at (4, 60, 4)
     MOVE 16 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     CALL "FORT-SIZE" USING WS-TYPE WS-OX WS-OY WS-OZ WS-W WS-H WS-D
     MOVE 4 TO A-X0
     MOVE 60 TO A-Y0
     MOVE 4 TO A-Z0
     COMPUTE A-X1 = 4 + WS-W - 1
     COMPUTE A-Y1 = 60 + WS-H - 1
     COMPUTE A-Z1 = 4 + WS-D - 1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEP WS-MST WS-BOX WS-ROW
*>   the world before: stone where the hall will be carved (local 3, 3, 3), stone at y 55 under the column of local (3, *, 3), water in the column of local (1, *, 1) from y 58 to 57
     MOVE 3 TO WS-X MOVE 3 TO WS-Y MOVE 3 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-STONE WS-FLAGS WS-OK
     MOVE 55 TO WS-WY
     CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-STONE WS-FLAGS WS-OK
     MOVE 1 TO WS-X MOVE 1 TO WS-Z MOVE -1 TO WS-Y
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-SET-STATE" USING WS-WX WS-WY WS-WZ WS-WATER WS-FLAGS WS-OK
     CALL "FORT-POST" USING WS-ROW
     MOVE 3 TO WS-X MOVE 3 TO WS-Y MOVE 3 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§1 A. Reading guide: a fill overwrites the stone that was in the box (the hall is carved to air)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 56 TO WS-WY
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§1 A. Reading guide: the column fills downward through air from local y -1" TO TL-CASE
     MOVE WS-NBR TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 55 TO WS-WY
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§1 A. Reading guide: the column stops at a solid block" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-X MOVE 1 TO WS-Z MOVE -1 TO WS-Y
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§1 A. Reading guide: the column replaces a liquid" TO TL-CASE
     MOVE WS-NBR TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the fence of local (2, 5, 0) is FENCE(E,W) in the north frame: facing east it is the fence with south and north
     CALL "SPB-RESET"
     MOVE LOW-VALUES TO CE-CHUNK
     MOVE 3 TO WS-ORIENT
     MOVE 4 TO A-X0
     MOVE 60 TO A-Y0
     MOVE 4 TO A-Z0
     COMPUTE A-X1 = 4 + WS-D - 1
     COMPUTE A-Y1 = 60 + WS-H - 1
     COMPUTE A-Z1 = 4 + WS-W - 1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEP WS-MST WS-BOX WS-ROW
     CALL "FORT-POST" USING WS-ROW
     MOVE 2 TO WS-X MOVE 5 TO WS-Y MOVE 0 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "minecraft:nether_brick_fence" TO WS-KEY
     MOVE "north=true,south=true" TO WS-PAIRS
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-FENCE
     MOVE "acceptance US12 36-8§1 A. Reading guide: FENCE(E,W) of the north frame is the fence with south and north in a piece facing east" TO TL-CASE
     MOVE WS-FENCE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the piece's own cells are clipped to the write box: a window of x 0 to 5 leaves local cells beyond it untouched
     CALL "SPB-RESET"
     MOVE LOW-VALUES TO CE-CHUNK
     MOVE 5 TO SW-X1
     MOVE 2 TO WS-ORIENT
     MOVE 4 TO A-X0
     COMPUTE A-X1 = 4 + WS-W - 1
     MOVE 4 TO A-Z0
     COMPUTE A-Z1 = 4 + WS-D - 1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEP WS-MST WS-BOX WS-ROW
     CALL "FORT-POST" USING WS-ROW
     MOVE 6 TO WS-X MOVE 0 TO WS-Y MOVE 3 TO WS-Z
     CALL "SPB-WORLD" USING WS-ROW WS-X WS-Y WS-Z WS-WX WS-WY WS-WZ
     CALL "FL-GET-STATE" USING WS-WX WS-WY WS-WZ WS-STATE
     MOVE "acceptance US12 36-8§1 A. Reading guide: a cell beyond the write box is not written" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-1.

 COPY NOSPAWN.
 COPY CORETEST.
