*> Acceptance test of the starts and the ground adjuster of the scattered feature pieces (docs/protocol/36-structures-4 sections 2.2 item 6, 2.3, 4.1, 5.1; core/src/struct-scatter.cob) over the fixture
*> terrain core/tests/fixtures/height (land above the sea level and water columns). The swamp hut (onTopOfChunkCenter, no sea level test) and the jungle temple (SinglePieceStructure: none when the lowest
*> of the four corner heights, base height - 1, is below 63) are built for 64 chunks of seed 12345: validity, stub, piece type, orientation (eight chunks against an independent Java LCG model:
*> setLargeFeatureSeed, then nextInt(4) of north, east, south, west) and box; then updateAverageGroundHeight (the average of every column of the box) and the lowest-column adjuster with an offset against
*> plain loops, and SCP-POST end to end (the cauldron of the hut at the adjusted height).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-SCATTER-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CLIMATE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-GEN-DIR             PIC X(1100) VALUE "core/tests/fixtures/height".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-H                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-NOT-HUT             BINARY-LONG VALUE 0.
 01 WS-BAD-STUB            BINARY-LONG VALUE 0.
 01 WS-BAD-VALID           BINARY-LONG VALUE 0.
 01 WS-BAD-EMPTY           BINARY-LONG VALUE 0.
 01 WS-BAD-BOX             BINARY-LONG VALUE 0.
 01 WS-VALIDS              BINARY-LONG VALUE 0.
 01 WS-INVALIDS            BINARY-LONG VALUE 0.
 01 WS-HUT                 BINARY-LONG VALUE 1.
 01 WS-JUNGLE              BINARY-LONG VALUE 2.
 01 WS-OTHER               BINARY-LONG VALUE 3.
 01 WS-DESERT              BINARY-LONG VALUE 4.
 01 WS-FOUND-D             BINARY-LONG VALUE 0.
 01 WS-RNGCOPY             BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND3              BINARY-LONG VALUE 3.
 01 WS-ADJ                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TREASURE            BINARY-LONG VALUE 5.
 01 WS-KIND-FLOOR          BINARY-LONG VALUE 1.
 01 WS-ROW1                BINARY-LONG VALUE 1.
 01 WS-DIRS.
    05 WS-DIR-OF           BINARY-LONG OCCURS 8 TIMES.
 01 WS-MODEL-CX.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -3.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE -4.
    05 FILLER              BINARY-LONG VALUE 3.
 01 WS-MCX REDEFINES WS-MODEL-CX.
    05 WS-M-CX             BINARY-LONG OCCURS 8 TIMES.
 01 WS-MODEL-CZ.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE -6.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE -2.
 01 WS-MCZ REDEFINES WS-MODEL-CZ.
    05 WS-M-CZ             BINARY-LONG OCCURS 8 TIMES.
 01 WS-MODEL-DIR.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-MDIR REDEFINES WS-MODEL-DIR.
    05 WS-M-DIR            BINARY-LONG OCCURS 8 TIMES.
 01 WS-BAD-DIR             BINARY-LONG VALUE 0.
 01 WS-SUM                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-ADJUST              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-WCX                 BINARY-LONG.
 01 WS-WCZ                 BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-STATE               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-FOUND-HUT           BINARY-LONG VALUE 0.
 01 WS-LAND-X              BINARY-LONG.
 01 WS-LAND-Z              BINARY-LONG.
 01 WS-OK-ROW              BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-SPAN-Y              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-GEN-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-GEN-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "GEN-DATA-READY" USING WS-STATUS
     MOVE 5 TO SD-ST-COUNT
     MOVE "minecraft:buried_treasure" TO SDT-KEY(5)
     MOVE "minecraft:swamp_hut" TO SDT-KEY(1)
     MOVE "minecraft:jungle_pyramid" TO SDT-KEY(2)
     MOVE "minecraft:igloo" TO SDT-KEY(3)
     MOVE "minecraft:desert_pyramid" TO SDT-KEY(4)

*>   the hut: every chunk is valid, the stub is the top block of the chunk centre, one piece of type 103
     PERFORM VARYING WS-CX FROM -4 BY 1 UNTIL WS-CX > 3
         PERFORM VARYING WS-CZ FROM -4 BY 1 UNTIL WS-CZ > 3
             CALL "STRUCT-SCATTER-FIND-POINT" USING WS-HUT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
             COMPUTE WS-X0 = WS-CX * 16 + 8
             COMPUTE WS-Z0 = WS-CZ * 16 + 8
             CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z0 WS-KIND WS-H
             IF WS-DONE NOT = 1 OR WS-VALID NOT = 1 OR SP-COUNT NOT = 1 OR SP-TYPE(1) NOT = 103
                 ADD 1 TO WS-NOT-HUT
             END-IF
             IF WS-X NOT = WS-X0 OR WS-Z NOT = WS-Z0 OR WS-Y NOT = WS-H - 1
                 ADD 1 TO WS-BAD-STUB
             END-IF
*>           the box of 7 x 7 x 9 at (16 cx, 64, 16 cz): width along x for north and south, along z for west and east
             IF SP-Y0(1) NOT = 64 OR SP-Y1(1) NOT = 70 OR SP-X0(1) NOT = WS-CX * 16 OR SP-Z0(1) NOT = WS-CZ * 16
                 ADD 1 TO WS-BAD-BOX
             END-IF
             IF SP-ORIENT(1) = 0 OR SP-ORIENT(1) = 2
                 IF SP-X1(1) NOT = SP-X0(1) + 6 OR SP-Z1(1) NOT = SP-Z0(1) + 8
                     ADD 1 TO WS-BAD-BOX
                 END-IF
             ELSE
                 IF SP-X1(1) NOT = SP-X0(1) + 8 OR SP-Z1(1) NOT = SP-Z0(1) + 6
                     ADD 1 TO WS-BAD-BOX
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-4§5.1 Swamp hut: 64 chunks give one valid piece of type 103 each" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NOT-HUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§2.2 Swamp hut: the stub is the top block of the chunk centre (base height - 1)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-STUB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§2.3 Swamp hut: the box is (16 cx, 64, 16 cz) with width and depth swapped for west and east" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-BOX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the orientation of eight chunks against the Java LCG model
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-M-CX(WS-I) TO WS-CX
         MOVE WS-M-CZ(WS-I) TO WS-CZ
         CALL "STRUCT-SCATTER-FIND-POINT" USING WS-HUT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
         IF SP-ORIENT(1) NOT = WS-M-DIR(WS-I)
             ADD 1 TO WS-BAD-DIR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§2.3 Scattered piece: the direction is nextInt(4) of north, east, south, west from the start random (eight chunks of the model)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-DIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the jungle temple (chunks -11 to -8, 0 to 5: a plateau at 67 around chunk (-10,2) among water): valid exactly when the lowest corner (base height - 1) is 63 or more; an invalid start has no piece
     PERFORM VARYING WS-CX FROM -11 BY 1 UNTIL WS-CX > -8
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 5
             CALL "STRUCT-SCATTER-FIND-POINT" USING WS-JUNGLE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
             MOVE 1000 TO WS-LOW
             COMPUTE WS-X0 = WS-CX * 16
             COMPUTE WS-Z0 = WS-CZ * 16
             COMPUTE WS-X1 = WS-X0 + 12
             COMPUTE WS-Z1 = WS-Z0 + 15
             CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z0 WS-KIND WS-H
             COMPUTE WS-LOW = WS-H - 1
             CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z1 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             CALL "STRUCT-BASE-HEIGHT" USING WS-X1 WS-Z0 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             CALL "STRUCT-BASE-HEIGHT" USING WS-X1 WS-Z1 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             IF WS-LOW >= 63
                 ADD 1 TO WS-VALIDS
                 IF WS-VALID NOT = 1 OR SP-COUNT NOT = 1 OR SP-TYPE(1) NOT = 102
                     ADD 1 TO WS-BAD-VALID
                 END-IF
                 IF SP-Y1(1) - SP-Y0(1) NOT = 9
                     ADD 1 TO WS-BAD-BOX
                 END-IF
                 IF SP-ORIENT(1) = 0 OR SP-ORIENT(1) = 2
                     COMPUTE WS-SPAN = SP-X1(1) - SP-X0(1)
                     IF WS-SPAN NOT = 11 OR SP-Z1(1) - SP-Z0(1) NOT = 14
                         ADD 1 TO WS-BAD-BOX
                     END-IF
                 ELSE
                     IF SP-X1(1) - SP-X0(1) NOT = 14 OR SP-Z1(1) - SP-Z0(1) NOT = 11
                         ADD 1 TO WS-BAD-BOX
                     END-IF
                 END-IF
             ELSE
                 ADD 1 TO WS-INVALIDS
                 IF WS-VALID NOT = 0 OR SP-COUNT NOT = 0
                     ADD 1 TO WS-BAD-EMPTY
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-4§2.2 Jungle temple: a start with the lowest corner height at least 63 is valid with one piece of type 102" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§2.2 Jungle temple: a start with the lowest corner below the sea level has no piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-EMPTY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§4.1 Jungle temple: the box is 12 x 10 x 15 with width and depth swapped for west and east" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-BOX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§2.2 Jungle temple: the fixture terrain has both valid and invalid starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALIDS > 0 AND WS-INVALIDS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a structure that is none of these: nothing is built
     CALL "SPB-RESET"
     CALL "STRUCT-SCATTER-FIND-POINT" USING WS-OTHER WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
     MOVE "acceptance US12 36-4§2.2 Scattered starts: another structure is left alone (done 0, no piece)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DONE + SP-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the ground adjusters over the first hut start: the average of every column of the box, and the lowest column with an offset
     MOVE 1 TO WS-MODE
     MOVE 0 TO WS-ADJUST
     PERFORM TRY-GROUND
     MOVE "acceptance US12 36-4§2.3 updateAverageGroundHeight: the box's min y is the integer average of the base heights of its columns" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-HAVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§2.3 updateAverageGroundHeight: the box keeps its height of 7" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SP-Y1(1) - SP-Y0(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-MODE
     MOVE -2 TO WS-ADJUST
     PERFORM TRY-GROUND
     MOVE "acceptance US12 36-4§2.3 updateHeightPositionToLowestGroundHeight: the box's min y is the lowest column height plus the offset" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-HAVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SCP-POST end to end: a hut in the window of its chunk (2,2): the box moves to the average height and the cauldron of local (4,2,6) stands two above the adjusted min y
     MOVE 1 TO WS-MODE
     MOVE 0 TO WS-ADJUST
     PERFORM FRESH-START
     PERFORM WANT-HEIGHT
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     MOVE SPACES TO WS-PAIRS WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 126 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     CALL "SCP-POST" USING WS-ROW1
     MOVE "acceptance US12 36-4§5.2 Swamp hut: SCP-POST moves the box to the average ground height" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE SP-Y0(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     EVALUATE SP-ORIENT(1)
         WHEN 2
             COMPUTE WS-WX = SP-X0(1) + 4
             COMPUTE WS-WZ = SP-Z1(1) - 6
         WHEN 0
             COMPUTE WS-WX = SP-X0(1) + 4
             COMPUTE WS-WZ = SP-Z0(1) + 6
         WHEN 1
             COMPUTE WS-WX = SP-X1(1) - 6
             COMPUTE WS-WZ = SP-Z0(1) + 4
         WHEN OTHER
             COMPUTE WS-WX = SP-X0(1) + 6
             COMPUTE WS-WZ = SP-Z0(1) + 4
     END-EVALUATE
     COMPUTE WS-WY = SP-Y0(1) + 2
     COMPUTE WS-I = (WS-WY + 64) * 256 + FUNCTION MOD(WS-WZ, 16) * 16 + FUNCTION MOD(WS-WX, 16) + 1
     MOVE CE-STATE(WS-I) TO WS-CELL
     MOVE SPACES TO WS-PAIRS WS-KEY
     MOVE "minecraft:cauldron" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-PAIRS WS-STATE
     MOVE "acceptance US12 36-4§5.2 Swamp hut: the cauldron stands at local (4,2,6) of the adjusted box" TO TL-CASE
     MOVE WS-STATE TO TL-EXPECTED-N
     MOVE WS-CELL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the jungle temple of the plateau chunk (-10,2) through SCP-POST: the box moves to the average height of its columns
     MOVE -10 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "STRUCT-SCATTER-FIND-POINT" USING WS-JUNGLE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
     PERFORM WANT-HEIGHT
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     CALL "SCP-POST" USING WS-ROW1
     MOVE "acceptance US12 36-4§4.2 Jungle temple: SCP-POST moves the box to the average ground height" TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE SP-Y0(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the desert pyramid: valid exactly when the lowest corner (21 x 21) is 63 or more; the first valid start of the area, its box 21 x 15 x 21 and its adjusted height through SCP-POST
     MOVE 0 TO WS-BAD-VALID
     PERFORM VARYING WS-CX FROM -11 BY 1 UNTIL WS-CX > -8
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 5
             CALL "STRUCT-SCATTER-FIND-POINT" USING WS-DESERT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
             COMPUTE WS-X0 = WS-CX * 16
             COMPUTE WS-Z0 = WS-CZ * 16
             COMPUTE WS-X1 = WS-X0 + 21
             COMPUTE WS-Z1 = WS-Z0 + 21
             CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z0 WS-KIND WS-H
             COMPUTE WS-LOW = WS-H - 1
             CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z1 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             CALL "STRUCT-BASE-HEIGHT" USING WS-X1 WS-Z0 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             CALL "STRUCT-BASE-HEIGHT" USING WS-X1 WS-Z1 WS-KIND WS-H
             IF WS-H - 1 < WS-LOW
                 COMPUTE WS-LOW = WS-H - 1
             END-IF
             IF WS-LOW >= 63
                 IF WS-VALID NOT = 1 OR SP-COUNT NOT = 1 OR SP-TYPE(1) NOT = 101 OR SP-Y1(1) - SP-Y0(1) NOT = 14
                     ADD 1 TO WS-BAD-VALID
                 END-IF
                 IF WS-FOUND-D = 0
                     MOVE 1 TO WS-FOUND-D
                     MOVE WS-CX TO WS-DX
                     MOVE WS-CZ TO WS-DZ
                 END-IF
             ELSE
                 IF WS-VALID NOT = 0 OR SP-COUNT NOT = 0
                     ADD 1 TO WS-BAD-VALID
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-4§3.1 Desert pyramid: valid exactly when the lowest 21 x 21 corner is 63 or more, one piece of type 101 of height 15" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§3.1 Desert pyramid: the fixture terrain has a valid start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND-D = 1
         MOVE WS-DX TO WS-CX
         MOVE WS-DZ TO WS-CZ
         CALL "STRUCT-SCATTER-FIND-POINT" USING WS-DESERT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
         MOVE SP-RNG TO WS-RNGCOPY
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNGCOPY WS-BOUND3 WS-ADJ
         MOVE 0 TO WS-MODE
         COMPUTE WS-ADJUST = 0 - WS-ADJ
         PERFORM WANT-HEIGHT
         CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
         CALL "MSP-OPEN"
         CALL "SCP-POST" USING WS-ROW1
         MOVE "acceptance US12 36-4§3.2 Desert pyramid: SCP-POST moves the box to the lowest ground height minus nextInt(3) of the start random" TO TL-CASE
         MOVE WS-WANT TO TL-EXPECTED-N
         MOVE SP-Y0(1) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF

*>   the buried treasure: no draw, the stub on top of the chunk centre by the ocean floor, the piece the block (16 cx + 9, 90, 16 cz + 9) without orientation; SCP-POST dispatches to it
     MOVE -10 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "STRUCT-SCATTER-FIND-POINT" USING WS-TREASURE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE
     COMPUTE WS-X0 = WS-CX * 16 + 8
     COMPUTE WS-Z0 = WS-CZ * 16 + 8
     CALL "STRUCT-BASE-HEIGHT" USING WS-X0 WS-Z0 WS-KIND-FLOOR WS-H
     MOVE "acceptance US12 36-4§7.1 Buried treasure: one piece of type 104, the block (9, 90, 9) of the chunk, no orientation, the stub by the ocean floor" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALID = 1 AND SP-COUNT = 1 AND SP-TYPE(1) = 104 AND SP-ORIENT(1) < 0 AND SP-X0(1) = WS-CX * 16 + 9 AND SP-X1(1) = SP-X0(1)
         AND SP-Z0(1) = WS-CZ * 16 + 9 AND SP-Z1(1) = SP-Z0(1) AND SP-Y0(1) = 90 AND SP-Y1(1) = 90 AND WS-Y = WS-H - 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     CALL "SCP-POST" USING WS-ROW1
     STOP RUN.

 FRESH-START.
*>   a fresh hut start at chunk (2,2) in row 1
     MOVE 2 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "STRUCT-SCATTER-FIND-POINT" USING WS-HUT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-DONE.

 WANT-HEIGHT.
*>   WS-WANT: the average (WS-MODE 1) or the lowest base height plus WS-ADJUST over the columns of the box of row 1, by plain loops
     MOVE 0 TO WS-SUM WS-COUNT
     MOVE 1000 TO WS-LOW
     PERFORM VARYING WS-Z FROM SP-Z0(1) BY 1 UNTIL WS-Z > SP-Z1(1)
         PERFORM VARYING WS-X FROM SP-X0(1) BY 1 UNTIL WS-X > SP-X1(1)
             CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND WS-H
             ADD WS-H TO WS-SUM
             ADD 1 TO WS-COUNT
             IF WS-H < WS-LOW
                 MOVE WS-H TO WS-LOW
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-MODE = 1
         COMPUTE WS-WANT = WS-SUM / WS-COUNT
     ELSE
         COMPUTE WS-WANT = WS-LOW + WS-ADJUST
     END-IF.

 TRY-GROUND.
*>   a fresh hut start: SCP-GROUND with WS-MODE and WS-ADJUST against plain loops over the box
     PERFORM FRESH-START
     PERFORM WANT-HEIGHT
     CALL "SCP-GROUND" USING WS-ROW1 WS-MODE WS-ADJUST
     MOVE SP-Y0(1) TO WS-HAVE.
 END PROGRAM TEST-STRUCT-SCATTER-FIND.

 COPY NOSPAWN.
 COPY CORETEST.
