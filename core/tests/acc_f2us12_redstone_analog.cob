*> Acceptance test (T29040..T29060, US12-4; docs/protocol/30-redstone-2 sections 4.2 and 5, 29 section 3.4): a comparator reads the analog output of the cell it faces. A barrel's fullness
*> (5.2: 14 full stacks of 27 slots read 8, 27 read 15), a double chest's merged 54 slots, a composter, a layered cauldron, a lava cauldron, a cake, a respawn anchor, an end portal frame, a
*> beehive, a lit copper bulb (5.3), and an item frame behind one conductor block (4.2 step 4). A container whose stacks changed tells the comparator at its side, a block whose state changed
*> does (29 3.4). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-ANALOG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROJSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-EXP                 PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-PX                  FLOAT-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FKEY                PIC X(112).
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FROW                BINARY-LONG.
 01 WS-FSLOT               BINARY-LONG.
 01 WS-FDIR                BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-K2                  PIC X(48).
 01 WS-NSLOTS              BINARY-LONG.
 01 WS-P1N                 PIC X(16).
 01 WS-P1V                 PIC X(16).
 01 WS-P2N                 PIC X(16).
 01 WS-BLOCK               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone analog: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CB-BLOCK-COUNT
         IF CB-KEY(WS-ID) = "redstone_wire"
             COMPUTE WS-WIRE-BLOCK = WS-ID
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 36
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 6
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     PERFORM PLAYER-AWAY
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS

*>   the comparator of row z sits at x 3 facing east: it reads x 4 and feeds the wire at x 2
     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM

*>   A. a barrel (z 0) with 14 full stacks reads 8
     MOVE 0 TO WS-Z
     PERFORM BUILD-ROW
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "barrel" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-BE TO WS-P
     MOVE "acceptance US12-4 live redstone 31-1 a barrel placed in the world has its block entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     IF WS-BE > 0
         MOVE 1 TO WS-P
     END-IF
     PERFORM ASSERT-POWER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-I)
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 5.2 and 4.2 step 3 a comparator facing a barrel of 14 full stacks outputs floor(14/27 * 14) + 1 = 8 (the container changed after the comparator was placed)" TO WS-CASE
     MOVE "8" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM VARYING WS-I FROM 15 BY 1 UNTIL WS-I > 27
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-I)
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 5.2 a full barrel reads 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE 0 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 5.2 an emptied barrel reads 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER

*>   B. a double chest (z 2): the left half at x 4 faces north, its partner at x 5; 27 full stacks in the half read 8 of 54
     MOVE 2 TO WS-Z
     PERFORM BUILD-ROW
     MOVE 5 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "north" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "right" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "north" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "left" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-I)
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     MOVE CB-S-BLOCK(WS-ST + 1) TO WS-BLOCK
     CALL "RL-ANALOG-NOTICE" USING WS-DIM WS-X WS-Y WS-Z WS-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a double chest merges its 54 slots: 27 full stacks read floor(27/54 * 14) + 1 = 8" TO WS-CASE
     MOVE "8" TO WS-EXP
     PERFORM ASSERT-POWER

*>   C. state based outputs (z 4 and up, one block each): the setBlock of the block tells the comparator
     MOVE 4 TO WS-Z
     MOVE "composter" TO WS-K MOVE "level" TO WS-P1N MOVE "5" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "5" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a comparator reads the composter level: 5" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 6 TO WS-Z
     MOVE "water_cauldron" TO WS-K MOVE "level" TO WS-P1N MOVE "2" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "2" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a layered cauldron reads its level: 2" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 8 TO WS-Z
     MOVE "lava_cauldron" TO WS-K MOVE SPACES TO WS-P1N WS-P2N
     MOVE "3" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a lava cauldron reads 3" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 10 TO WS-Z
     MOVE "cake" TO WS-K MOVE "bites" TO WS-P1N MOVE "2" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "10" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a cake with 2 bites reads (7 - 2) * 2 = 10" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 12 TO WS-Z
     MOVE "respawn_anchor" TO WS-K MOVE "charges" TO WS-P1N MOVE "2" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "7" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a respawn anchor with 2 charges reads floor(2 / 4 * 15) = 7" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 14 TO WS-Z
     MOVE "end_portal_frame" TO WS-K MOVE "eye" TO WS-P1N MOVE "true" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "15" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 an end portal frame with an eye reads 15" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 16 TO WS-Z
     MOVE "beehive" TO WS-K MOVE "honey_level" TO WS-P1N MOVE "3" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "3" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a beehive reads its honey level: 3" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 18 TO WS-Z
     MOVE "copper_bulb" TO WS-K MOVE "lit" TO WS-P1N MOVE "true" TO WS-P1V MOVE SPACES TO WS-P2N
     MOVE "15" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-7 7.3 a lit copper bulb reads 15" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 20 TO WS-Z
     MOVE "cauldron" TO WS-K MOVE SPACES TO WS-P1N WS-P2N
     MOVE "0" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 an empty cauldron reads 0" TO WS-CASE
     PERFORM STATE-CASE
     MOVE 22 TO WS-Z
     MOVE "candle_cake" TO WS-K MOVE SPACES TO WS-P1N WS-P2N
     MOVE "14" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a candle cake reads 14" TO WS-CASE
     PERFORM STATE-CASE

*>   C2. block entity containers by their slots (z 26 and up): the block at x 4 gets its entity filled, the container tick tells the comparator
     MOVE 26 TO WS-Z
     MOVE "furnace" TO WS-K MOVE SPACES TO WS-P1N
     MOVE 1 TO WS-NSLOTS
     MOVE "5" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a furnace holding one full stack of its 3 slots reads floor(1/3 * 14) + 1 = 5" TO WS-CASE
     PERFORM FILL-CASE
     MOVE 28 TO WS-Z
     MOVE "decorated_pot" TO WS-K MOVE SPACES TO WS-P1N
     MOVE 1 TO WS-NSLOTS
     MOVE "15" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a decorated pot holding a full stack of its one slot reads 15" TO WS-CASE
     PERFORM FILL-CASE
     MOVE 30 TO WS-Z
     MOVE "crafter" TO WS-K MOVE SPACES TO WS-P1N
     MOVE 3 TO WS-NSLOTS
     MOVE "3" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a crafter with 3 filled slots reads 3" TO WS-CASE
     PERFORM FILL-CASE
     MOVE 32 TO WS-Z
     MOVE "chiseled_bookshelf" TO WS-K MOVE SPACES TO WS-P1N
     MOVE 0 TO WS-NSLOTS
     MOVE "3" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 30-2 5.3 a chiseled bookshelf whose last interacted slot is 2 reads 3" TO WS-CASE
     PERFORM FILL-CASE
     MOVE 34 TO WS-Z
     MOVE "lectern" TO WS-K MOVE "has_book" TO WS-P1N MOVE "true" TO WS-P1V
     MOVE 1 TO WS-NSLOTS
     MOVE "5" TO WS-EXP
     MOVE "acceptance US12-4 live redstone 31-4 3.3 a lectern on page 3 of 11 reads floor(3/10 * 14) + 1 = 5" TO WS-CASE
     PERFORM FILL-CASE

*>   D. an item frame behind a conductor (z 24): stone at x 4, the frame at x 5 faces east with a stack turned 3 times: 4
     MOVE 24 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE "minecraft:item_frame" TO WS-FKEY
     MOVE 12 TO WS-FKIND
     MOVE 5.03125 TO WS-PX
     MOVE 101.0 TO WS-FY
     COMPUTE WS-FZ = WS-Z + 0.5
     MOVE 5 TO WS-FDIR
     CALL "DECOR-SPAWN" USING WS-FKIND WS-FKEY WS-DIM WS-PX WS-FY WS-FZ WS-FDIR WS-FROW
     CALL "PJ-FIND" USING EN-ID(WS-FROW) WS-FSLOT
     MOVE WS-ITEM TO PJ-I2(WS-FSLOT)
     MOVE 3 TO PJ-I3(WS-FSLOT)
     MOVE 3 TO WS-X MOVE "comparator" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 30-2 4.2 step 4 an item frame with rotation 3 behind one conductor block gives the comparator 4" TO WS-CASE
     MOVE "4" TO WS-EXP
     PERFORM ASSERT-POWER
     STOP RUN.

 FILL-CASE.
*>   the row of WS-Z with the block WS-K (property WS-P1N set to WS-P1V when named) at x 4; its entity gets WS-NSLOTS full stacks of the item,
*>   the chiseled bookshelf last slot 2 (WS-NSLOTS 0), the lectern page 3 of 11; the expected output is WS-EXP
     MOVE WS-K TO WS-K2
     PERFORM BUILD-ROW
     MOVE WS-K2 TO WS-K
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-DEF
     IF WS-P1N NOT = SPACES
         MOVE WS-P1N TO WS-PN MOVE WS-P1V TO WS-PV PERFORM SET-P
     END-IF
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NSLOTS
         MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, WS-I)
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM
     IF WS-K2 = "chiseled_bookshelf"
         MOVE 2 TO BE-COOLDOWN(WS-BE)
     END-IF
     IF WS-K2 = "lectern"
         MOVE 3 TO BE-XI(WS-BE, 1)
         MOVE 11 TO BE-XI(WS-BE, 2)
     END-IF
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     PERFORM ASSERT-POWER.

 STATE-CASE.
*>   the row of WS-Z: the wire, the comparator, then the block WS-K with the property WS-P1N set to WS-P1V at x 4
     MOVE WS-K TO WS-K2
     PERFORM BUILD-ROW
     MOVE WS-K2 TO WS-K
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM MAKE-DEF
     IF WS-P1N NOT = SPACES
         MOVE WS-P1N TO WS-PN MOVE WS-P1V TO WS-PV PERFORM SET-P
     END-IF
     PERFORM PUT-ST
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     PERFORM ASSERT-POWER.

 BUILD-ROW.
*>   the wire at x 2 and the comparator at x 3 facing east, powered=false, mode compare (z = WS-Z)
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "comparator" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST.

 MAKE-DEF.
*>   the default state of the block of key WS-K into WS-ST
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
*>   the default state of the block of key WS-K at (WS-X, WS-Y, WS-Z) into WS-ST and the world
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
*>   property WS-PN of WS-ST set to WS-PV
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 PLAYER-AWAY.
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW).

 PLAYER-ON-PLATE.
*>   the player stands on the plate of row WS-Z at x 3 (feet at the floor of the cell)
     MOVE 3.5 TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW).

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 READ-WIRE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 READ-SIGNAL.
*>   level.getSignal at (WS-X, WS-Y, WS-Z) asked with direction WS-D
     CALL "RL-SIGNAL" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-SIG
     MOVE WS-SIG TO WS-P.

 ASSERT-POWER.
     MOVE WS-P TO WS-ED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SIGNAL.
     PERFORM ASSERT-POWER.

 ASSERT-PROPS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-F2US12-REDSTONE-ANALOG.

 COPY CORETEST.
 COPY PORTALTEST.
