*> Acceptance test (wrap agent B, T63111 and T63110; docs/protocol/30-redstone-1 section 2.4, 30-redstone-2 section 5.3, 31-block-entities-1 section 10.2): (1) the redstone conductor rule takes the
*> collision shape of the state, RL-LOOK: stone, a double slab, soul sand (the always list) and iron blocks conduct; a bottom or top slab, stairs, a fence, a chest, glass (the never list) and air do not.
*> (2) The comparator reads a placed chest: 14 stacks of 64 give 8 (31-1 example 3); a conductor above gives 0 (a blocked chest has no container), a slab above does not block; the copper chest reads
*> as a chest; a double chest reads both halves (54 slots) and is blocked when either half is; a hopper over a copper chest fills it. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-CONDUCTOR-CHEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-conductor-chest-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
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
 01 WS-CASE                PIC X(240).
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-STATE-OUT           BINARY-LONG.
 01 WS-DIR                 BINARY-LONG VALUE 2.
 01 WS-HAS                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 01 WS-BLOCKKEY            PIC X(48).
 01 WS-BLOCKPN             PIC X(16).
 01 WS-BLOCKPV             PIC X(16).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb conductor chest: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 14
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "stone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STONE

*>   1. the conductor rule by collision shape (30-1 2.4): a block of the always list or a full cube conducts, the never list and every partial shape do not
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE 1 TO WS-Z
     MOVE "stone" TO WS-K MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 stone conducts" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "iron_block" TO WS-K MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 an iron block conducts" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "soul_sand" TO WS-K MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 soul sand conducts (the always list)" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "oak_slab" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 a bottom slab does not conduct" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "type" TO WS-BLOCKPN MOVE "top" TO WS-BLOCKPV
     MOVE "acceptance wrapb conductor 30-1 2.4 a top slab does not conduct" TO WS-CASE
     PERFORM CHECK-COND-PROP
     MOVE "double" TO WS-BLOCKPV MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 a double slab conducts" TO WS-CASE
     PERFORM CHECK-COND-PROP
     MOVE "oak_stairs" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 stairs do not conduct" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "oak_fence" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 a fence does not conduct" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "chest" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 a chest does not conduct" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "glass" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 glass does not conduct (the never list)" TO WS-CASE
     PERFORM CHECK-COND
     MOVE "air" TO WS-K MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb conductor 30-1 2.4 air does not conduct" TO WS-CASE
     PERFORM CHECK-COND

*>   2. the comparator reads a single chest of 14 stacks of 64 stone as 8 (31-1 example 3), a conductor above gives 0, a slab above does not block it
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE 3 TO WS-Z
     MOVE "chest" TO WS-K PERFORM PUT-DEF
     PERFORM FILL-14
     PERFORM READ-ANALOG
     MOVE 8 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 the comparator reads a chest of 14 full stacks as 8" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-ANALOG
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a chest with stone above it reads 0 (blocked)" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 102 TO WS-Y MOVE "oak_slab" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-ANALOG
     MOVE 8 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a chest with a slab above it reads 8 (a slab does not block)" TO WS-CASE
     PERFORM ASSERT-N

*>   3. a copper chest reads like a chest, and 0 under stone
     MOVE 5 TO WS-X MOVE "copper_chest" TO WS-K PERFORM PUT-DEF
     PERFORM FILL-14
     PERFORM READ-ANALOG
     MOVE 8 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 the comparator reads a copper chest of 14 full stacks as 8" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-ANALOG
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a copper chest with stone above it reads 0" TO WS-CASE
     PERFORM ASSERT-N

*>   4. a double chest (right half at x 3, left half at x 4, facing south: the left half joins the block clockwise of the facing, west) with 14 stacks in the half at x 3 reads 14 of 54 slots: floor(14 / 54 * 14) + 1 = 4 from either half, and 0 when stone is above the other half
     MOVE 5 TO WS-Z
*>   two plain chests first (flags 3 give them their block entities), then the states of a double chest over them with flags 18 (no shape updates: a half beside air would turn single again)
     MOVE 3 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X PERFORM PUT-DEF
     MOVE 18 TO WS-FLAGS
     MOVE 3 TO WS-X MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "south" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "right" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE "chest" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "south" TO WS-PV PERFORM SET-P
     MOVE "type" TO WS-PN MOVE "left" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 3 TO WS-FLAGS
     MOVE 3 TO WS-X
     MOVE 3 TO WS-X
     PERFORM FILL-14
     PERFORM READ-ANALOG
     MOVE 4 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a double chest reads its 54 slots from the half at x 3" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 4 TO WS-X
     PERFORM READ-ANALOG
     MOVE 4 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a double chest reads its 54 slots from the half at x 4" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-ANALOG
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 a double chest with stone above the half at x 4 reads 0 there" TO WS-CASE
     PERFORM ASSERT-N
     MOVE 3 TO WS-X
     PERFORM READ-ANALOG
     MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-1 10.2 and 0 from the half at x 3, whose partner is blocked" TO WS-CASE
     PERFORM ASSERT-N

*>   5. a hopper over a copper chest fills it (31-2 5.7 the container of the block below, ignoring a block above the chest)
     MOVE 7 TO WS-Z
     MOVE 3 TO WS-X MOVE "copper_chest" TO WS-K PERFORM PUT-DEF
     MOVE 102 TO WS-Y MOVE "hopper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "down" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 101 TO WS-Y
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-OBS-N
     MOVE 2 TO WS-EXP-N
     MOVE "acceptance wrapb chest 31-2 5.7 a hopper over a copper chest moves its two items into it" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-COND.
*>   the default state of block WS-K at (WS-X, WS-Y, WS-Z): the conductor flag of RL-LOOK against WS-EXP-N
     PERFORM PUT-DEF
     CALL "RL-LOOK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OUT WS-CLASS WS-COND
     MOVE WS-COND TO WS-OBS-N
     PERFORM ASSERT-N.

 CHECK-COND-PROP.
*>   the same with the property WS-BLOCKPN set to WS-BLOCKPV
     PERFORM MAKE-DEF
     MOVE WS-BLOCKPN TO WS-PN
     MOVE WS-BLOCKPV TO WS-PV
     PERFORM SET-P
     PERFORM PUT-ST
     CALL "RL-LOOK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OUT WS-CLASS WS-COND
     MOVE WS-COND TO WS-OBS-N
     PERFORM ASSERT-N.

 FILL-14.
*>   14 full stacks of stone in the first slots of the block entity at (WS-X, WS-Y, WS-Z)
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, WS-I)
         MOVE 64 TO BE-SLOT-COUNT(WS-BE, WS-I)
     END-PERFORM.

 READ-ANALOG.
*>   the comparator's reading of the block at (WS-X, WS-Y, WS-Z) from the north (reader direction 2): the value in WS-OBS-N
     CALL "RL-ANALOG-AT" USING WS-DIM WS-X WS-Y WS-Z WS-DIR WS-HAS WS-VALUE
     MOVE WS-VALUE TO WS-OBS-N.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP-N TO TL-EXPECTED-N
     MOVE WS-OBS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
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

 END PROGRAM ACC-WRAPB-CONDUCTOR-CHEST.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
