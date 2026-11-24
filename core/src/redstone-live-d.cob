*> Live redstone, analog output (docs/protocol/30-redstone-2 sections 4.2 and 5, 29 sections 2.2 and 3.4): what a comparator reads from the cell it faces (a container's fullness, a composter,
*> a cauldron, a cake, a beehive, an end portal frame (the property `eye`, listed as has_eye in 30-2 5.3), a respawn anchor, a copper bulb, a lectern, a crafter, a chiseled bookshelf, an item frame behind one conductor), and the notice that
*> tells the comparators around a block when its analog output may have changed (a setBlock of a block with an analog output, a container whose fullness changed).
*> Not read (named gaps of the table of 5.3): the jukebox (the song's comparator_output, 31-4 section 2, needs the song table), command blocks (31-6 success count), the sculk sensors
*> (31-8 last vibration frequency), the copper golem statue pose, the creaking heart, the shelf, the detector rail (30-6 minecart container); each reads as no analog output.
*> A double chest reads the merged 54 slots of the chest and its partner; a chest that cannot be opened (a conductor above, a sitting cat, 31-1 section 9.5) is not tested.
*> Entry points:
*>   RL-ANALOG-AT USING dimension row, x, y, z, reader direction, has out, value out    hasAnalogOutputSignal and getAnalogOutputSignal of the block at the position (5.3)
*>   RL-FRAME-AT USING dimension row, x, y, z, facing, frames out, output out           the item frames of the cell that hang with that facing: their count and the output of the first (4.2 step 4)
*>   RL-ANALOG-NOTICE USING dimension row, x, y, z, block    updateNeighbourForOutputSignal (5.1)
*>   RL-CONTAINER-TICK    once per game tick (CORE-TICK): a container block entity whose fullness changed gives the notice

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-PROP-NUM.
*> USING state, property name (PIC X(16)), value out: the numeric value of a property (true 1, false 0), 0 when the state has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(160).
 01 WS-VALUE               PIC X(16).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-VALUE.
     CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-TEXT
     CALL "RL-PROP" USING WS-TEXT L-NAME WS-VALUE
     MOVE 0 TO L-VALUE
     EVALUATE WS-VALUE
         WHEN "true"
             MOVE 1 TO L-VALUE
         WHEN "false"
             MOVE 0 TO L-VALUE
         WHEN OTHER
             COMPUTE L-VALUE = FUNCTION NUMVAL(WS-VALUE)
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-PROP-NUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SLOTS-ADD.
*> USING block entity index, first table position, slot count, the counts table, the limits table: appends the stacks of the entity's first slots (30-2 5.2 limit(i) = the stack size, 99 at most).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-S                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FROM                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COUNT.
    05 L-COUNT-E           BINARY-LONG OCCURS 64 TIMES.
 01 L-LIMIT.
    05 L-LIMIT-E           BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-INDEX L-FROM L-N L-COUNT L-LIMIT.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > L-N
         COMPUTE WS-POS = L-FROM + WS-S - 1
         MOVE 0 TO L-COUNT-E(WS-POS)
         MOVE 64 TO L-LIMIT-E(WS-POS)
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             MOVE BE-SLOT-COUNT(L-INDEX, WS-S) TO L-COUNT-E(WS-POS)
             MOVE FUNCTION MIN(99, IT-MAX-STACK(BE-SLOT-ITEM(L-INDEX, WS-S) + 1)) TO L-LIMIT-E(WS-POS)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-SLOTS-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ANALOG-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 COPY BESTATE.
 01 WS-LEVEL               PIC X(16) VALUE "level".
 01 WS-BITES               PIC X(16) VALUE "bites".
 01 WS-HONEY               PIC X(16) VALUE "honey_level".
 01 WS-EYE                 PIC X(16) VALUE "eye".
 01 WS-CHARGES             PIC X(16) VALUE "charges".
 01 WS-LIT                 PIC X(16) VALUE "lit".
 01 WS-HAS-BOOK            PIC X(16) VALUE "has_book".
 01 WS-PHASE-NAME          PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-POSE-NAME           PIC X(32) VALUE "copper_golem_pose".
 01 WS-HEART-NAME          PIC X(32) VALUE "creaking_heart_state".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-OLD-TEXT            PIC X(16).
 01 WS-FAM                 BINARY-LONG.
 01 WS-CDIR                BINARY-LONG.
 01 WS-CTYPE               BINARY-LONG.
 01 WS-CFLAG               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX2              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-VALUE               PIC X(16).
 01 WS-CLIENT              BINARY-LONG VALUE 0.
 01 WS-COUNTS.
    05 WS-COUNT-E          BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIMITS.
    05 WS-LIMIT-E          BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIR L-HAS L-VALUE.
     CALL "REDSTONE-IDS-ENSURE"
     MOVE 0 TO L-HAS L-VALUE
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE RL-ANALOG(WS-BLOCK + 1) TO WS-KIND
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 1 TO L-HAS
     MOVE 0 TO WS-A WS-B WS-C
     EVALUATE WS-KIND
         WHEN 1 THRU 8
*>           the container signal of the block entity (5.2): its slot count by block, the merged slots of a double chest
             EVALUATE WS-KIND
                 WHEN 1
                     MOVE 27 TO WS-N
                 WHEN 2
                 WHEN 3
                     MOVE 27 TO WS-N
                 WHEN 4
                     MOVE 3 TO WS-N
                 WHEN 5
                 WHEN 6
                     MOVE 5 TO WS-N
                 WHEN 7
                     MOVE 9 TO WS-N
                 WHEN OTHER
                     MOVE 1 TO WS-N
             END-EVALUATE
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             MOVE 0 TO WS-BLOCKED
             IF WS-INDEX > 0 AND WS-KIND = 1
*>               a chest with a conductor or a sitting cat above has no container for the comparator (31-1 section 10.2: getContainer with ignoreBlocked false), a double chest when either half is so
                 CALL "BE-CHEST-COVERED" USING L-DIM L-X L-Y L-Z WS-BLOCKED
             END-IF
             IF WS-INDEX > 0 AND WS-BLOCKED = 0
                 CALL "RL-SLOTS-ADD" USING WS-INDEX 1 WS-N WS-COUNTS WS-LIMITS
                 IF WS-KIND = 1
*>                   a half of a double chest reads its partner's slots too (31-1 section 10.2)
                     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAM WS-CDIR WS-CTYPE WS-CFLAG
                     IF WS-FAM = 1 AND WS-CTYPE NOT = 0
                         CALL "BE-CHEST-CONNECTED" USING WS-CDIR WS-CTYPE WS-DX WS-DZ
                         COMPUTE WS-PX = L-X + WS-DX
                         COMPUTE WS-PZ = L-Z + WS-DZ
                         CALL "BE-FIND" USING L-DIM WS-PX L-Y WS-PZ WS-INDEX2
                         IF WS-INDEX2 > 0
                             CALL "BE-CHEST-COVERED" USING L-DIM WS-PX L-Y WS-PZ WS-BLOCKED
                             CALL "RL-SLOTS-ADD" USING WS-INDEX2 28 WS-N WS-COUNTS WS-LIMITS
                             COMPUTE WS-N = WS-N * 2
                         END-IF
                     END-IF
                 END-IF
                 IF WS-BLOCKED = 0
                     CALL "RS1-CONTAINER-SIGNAL" USING WS-N WS-COUNTS WS-LIMITS L-VALUE
                 END-IF
             END-IF
         WHEN 9
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0
                 CALL "BE2-CRAFTER-SIGNAL" USING WS-INDEX L-VALUE
             END-IF
         WHEN 10
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0
                 MOVE BE-COOLDOWN(WS-INDEX) TO WS-B
                 IF WS-B >= 0
                     MOVE 7 TO WS-F
                     CALL "RS1-ANALOG-VALUE" USING WS-F WS-CLIENT WS-B WS-C L-VALUE
                 END-IF
             END-IF
         WHEN 11
*>           the lectern (5.3): has_book of the block, the page and page count of the entity
             CALL "RL-PROP-NUM" USING WS-STATE WS-HAS-BOOK WS-A
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0
                 MOVE BE-XI(WS-INDEX, 1) TO WS-B
                 MOVE BE-XI(WS-INDEX, 2) TO WS-C
                 IF BE-SLOT-COUNT(WS-INDEX, 1) = 0
                     MOVE 0 TO WS-A
                 END-IF
                 MOVE 9 TO WS-F
                 CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
             END-IF
         WHEN 12
         WHEN 13
             CALL "RL-PROP-NUM" USING WS-STATE WS-LEVEL L-VALUE
         WHEN 14
             MOVE 3 TO L-VALUE
         WHEN 15
             MOVE 0 TO L-VALUE
         WHEN 16
             CALL "RL-PROP-NUM" USING WS-STATE WS-BITES WS-A
             MOVE 2 TO WS-F
             CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
         WHEN 17
             MOVE 3 TO WS-F
             CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
         WHEN 18
             CALL "RL-PROP-NUM" USING WS-STATE WS-HONEY L-VALUE
         WHEN 19
             CALL "RL-PROP-NUM" USING WS-STATE WS-EYE WS-A
             MOVE 4 TO WS-F
             CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
         WHEN 20
             CALL "RL-PROP-NUM" USING WS-STATE WS-CHARGES WS-A
             MOVE 5 TO WS-F
             CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
         WHEN 21
             CALL "RL-PROP-NUM" USING WS-STATE WS-LIT WS-A
             MOVE 4 TO WS-F
             CALL "RS1-ANALOG-VALUE" USING WS-F WS-A WS-B WS-C L-VALUE
         WHEN 22
*>           the jukebox (30-5 9): the comparator output of the stored disc's song (BE4-JUKEBOX-SET-ITEM keeps it)
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0
                 MOVE BE-XI(WS-INDEX, 5) TO L-VALUE
             END-IF
         WHEN 23
*>           the command blocks (30-2 5.3): the success count of the entity
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0
                 MOVE BE-XI(WS-INDEX, 4) TO L-VALUE
             END-IF
         WHEN 24
*>           the sculk sensors (4.7): the last vibration frequency while the phase is active
             CALL "SW-SET-PROP-L" USING WS-STATE WS-PHASE-NAME WS-KEEP WS-NEW-STATE WS-OLD-TEXT
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0 AND WS-OLD-TEXT = "active"
                 MOVE BE-XI(WS-INDEX, 1) TO L-VALUE
             END-IF
         WHEN 25
*>           the copper golem statue: ordinal(pose) + 1 (standing, sitting, running, star)
             CALL "SW-SET-PROP-L" USING WS-STATE WS-POSE-NAME WS-KEEP WS-NEW-STATE WS-OLD-TEXT
             EVALUATE WS-OLD-TEXT
                 WHEN "sitting"
                     MOVE 2 TO L-VALUE
                 WHEN "running"
                     MOVE 3 TO L-VALUE
                 WHEN "star"
                     MOVE 4 TO L-VALUE
                 WHEN OTHER
                     MOVE 1 TO L-VALUE
             END-EVALUATE
         WHEN 26
*>           the creaking heart: 0 uprooted, else the entity's output signal
             CALL "SW-SET-PROP-L" USING WS-STATE WS-HEART-NAME WS-KEEP WS-NEW-STATE WS-OLD-TEXT
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
             IF WS-INDEX > 0 AND WS-OLD-TEXT NOT = "uprooted"
                 MOVE BE-XI(WS-INDEX, 5) TO L-VALUE
             END-IF
         WHEN 27
*>           the shelf: only read from the side opposite its facing, the occupancy of its three slots as bits
             CALL "PST-FACING-OF" USING WS-STATE WS-F
             COMPUTE WS-N = WS-F + 1 - 2 * FUNCTION MOD(WS-F, 2)
             IF L-DIR = WS-N
                 CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
                 IF WS-INDEX > 0
                     IF BE-SLOT-COUNT(WS-INDEX, 1) > 0
                         ADD 1 TO L-VALUE
                     END-IF
                     IF BE-SLOT-COUNT(WS-INDEX, 2) > 0
                         ADD 2 TO L-VALUE
                     END-IF
                     IF BE-SLOT-COUNT(WS-INDEX, 3) > 0
                         ADD 4 TO L-VALUE
                     END-IF
                 END-IF
             END-IF
         WHEN 28
*>           the detector rail (6.4): 0 unpowered; powered: the success count of a command block cart or the fullness of a container cart,
*>           neither of which this core keeps in a readable container, so 0
             MOVE 0 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-ANALOG-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-FRAME-AT.
*> USING dimension row, x, y, z, facing, frames out, output out: the item frames whose position lies in the cell and whose direction is the facing (decor-44b.cob), and the output of the first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-FRAMES               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-FRAMES L-OUT.
     MOVE 0 TO L-FRAMES L-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 12 AND PJ-I1(WS-I) = L-FACING
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = L-DIM
                     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E))
                     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(WS-E))
                     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E))
                     IF WS-CX = L-X AND WS-CY = L-Y AND WS-CZ = L-Z
                         ADD 1 TO L-FRAMES
                         MOVE 1 TO WS-EMPTY
                         IF PJ-I2(WS-I) > 0
                             MOVE 0 TO WS-EMPTY
                         END-IF
                         MOVE FUNCTION MOD(PJ-I3(WS-I), 8) TO WS-VALUE
                         CALL "RS1-FRAME-ANALOG" USING WS-EMPTY WS-VALUE L-OUT
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-FRAME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ANALOG-NOTICE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 WS-ORDER               PIC X(4) VALUE "2534".
 01 WS-DIGIT               PIC 9.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-CLASS2              BINARY-LONG.
 01 WS-COND2               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-CMP                 BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-ORDER(WS-I:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-D
         CALL "RS1-STEP" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-QX = L-X + WS-DX
         COMPUTE WS-QZ = L-Z + WS-DZ
         COMPUTE WS-CX = (WS-QX - FUNCTION MOD(WS-QX, 16)) / 16
         COMPUTE WS-CZ = (WS-QZ - FUNCTION MOD(WS-QZ, 16)) / 16
         CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
         MOVE 0 TO WS-LOADED WS-CMP WS-FAR
         IF WS-ROW > 0
             MOVE 1 TO WS-LOADED
             CALL "RL-LOOK" USING L-DIM WS-QX L-Y WS-QZ WS-STATE WS-CLASS WS-COND
             IF WS-CLASS = 8
                 MOVE 1 TO WS-CMP
             END-IF
             COMPUTE WS-RX = WS-QX + WS-DX
             COMPUTE WS-RZ = WS-QZ + WS-DZ
             COMPUTE WS-CX = (WS-RX - FUNCTION MOD(WS-RX, 16)) / 16
             COMPUTE WS-CZ = (WS-RZ - FUNCTION MOD(WS-RZ, 16)) / 16
             CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0
                 CALL "RL-LOOK" USING L-DIM WS-RX L-Y WS-RZ WS-STATE2 WS-CLASS2 WS-COND2
                 IF WS-CLASS2 = 8
                     MOVE 1 TO WS-FAR
                 END-IF
             END-IF
         END-IF
         CALL "RS1-OUTPUT-NOTIFY" USING WS-LOADED WS-CMP WS-COND WS-FAR WS-ACTION
         EVALUATE WS-ACTION
             WHEN 1
                 CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM WS-QX L-Y WS-QZ L-BLOCK
             WHEN 2
                 CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM WS-RX L-Y WS-RZ L-BLOCK
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM RL-ANALOG-NOTICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CONTAINER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG VALUE 1.
 01 WS-HAS                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "REDSTONE-IDS-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) > 0
             CALL "WORLD-GET-BLOCK" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-STATE
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             MOVE RL-ANALOG(WS-BLOCK + 1) TO WS-KIND
             IF WS-KIND = 9
                 CALL "RL-CRAFTER-TICK" USING WS-I
             END-IF
             IF WS-KIND >= 1 AND WS-KIND <= 11
                 CALL "RL-ANALOG-AT" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-DIR WS-HAS WS-VALUE
                 IF WS-VALUE NOT = RL-LAST(WS-I)
                     MOVE WS-VALUE TO RL-LAST(WS-I)
                     CALL "RL-ANALOG-NOTICE" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-BLOCK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-CONTAINER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ANALOG-NOTICE-OF RECURSIVE.
*> USING dimension row, x, y, z, block: RL-ANALOG-NOTICE when the block has an analog output (29 section 2.2 step 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     CALL "REDSTONE-IDS-ENSURE"
     IF RL-ANALOG(L-BLOCK + 1) > 0
         CALL "RL-ANALOG-NOTICE" USING L-DIM L-X L-Y L-Z L-BLOCK
     END-IF
     GOBACK.
 END PROGRAM RL-ANALOG-NOTICE-OF.
