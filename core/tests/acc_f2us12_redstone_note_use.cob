*> Acceptance test (T29502..T29506, US12-4; docs/protocol/30-redstone-5 section 8.2 and 8.4): the instrument of a note block follows the block below (and a head above) at placement and on every vertical
*> neighbour change (8.2); a right click tunes it and plays the note (the Block Event 7 and the Sound Effect 119 reach the viewers, not under a block above that is no head), a left click (Player Action start) plays
*> it without a change of state (8.4). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-NOTE-USE.
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
 01 WS-P1N                 PIC X(16).
 01 WS-P1V                 PIC X(16).
 01 WS-P2N                 PIC X(16).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEED1               BINARY-DOUBLE.
 01 WS-SEED2               BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone note use: no generated packs here, skipped" TO TL-CASE
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
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
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
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-Z
     PERFORM DRAIN
*>   8.2 at placement: a gold block below gives bell
     MOVE 3 TO WS-X MOVE 100 TO WS-Y MOVE "gold_block" TO WS-K PERFORM PUT-DEF
     MOVE "note_block" TO WS-K PERFORM MAKE-DEF
     MOVE 101 TO WS-Y
     CALL "REDSTONE-PLACE-STATE" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     CALL "BLOCKS-STATE-PROPS" USING WS-ST WS-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.2 a note block placed above a gold block takes bell" TO WS-CASE
     MOVE "instrument=bell,note=0,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   8.2 vertical shape updates: stone, then gold below; a zombie head above wins; air above again
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "note_block" TO WS-K PERFORM PUT-DEF
     MOVE 100 TO WS-Y MOVE "gold_block" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.2 a gold block put below an existing note block changes it to bell" TO WS-CASE
     MOVE "instrument=bell,note=0,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 102 TO WS-Y MOVE "zombie_head" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.2 a zombie head above wins" TO WS-CASE
     MOVE "instrument=zombie,note=0,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 102 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.2 the head removed, the block below gives bell again" TO WS-CASE
     MOVE "instrument=bell,note=0,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 100 TO WS-Y MOVE "zombie_head" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.2 a head below gives harp" TO WS-CASE
     MOVE "instrument=harp,note=0,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   8.4 right click: tune and play
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "note_block" TO WS-K PERFORM PUT-DEF
     PERFORM PLAYER-NEAR
     PERFORM DRAIN
     MOVE 1 TO WS-FACE MOVE 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.4 a right click tunes the note block to note 1" TO WS-CASE
     MOVE "instrument=harp,note=1,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM DRAIN
     PERFORM COUNT-EVENT
     MOVE "acceptance US12-4 live redstone 30-5 8.4 the right click sends the Block Event (7)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM COUNT-SOUND
     MOVE "acceptance US12-4 live redstone 30-5 8.5 and the Sound Effect (119)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   8.4 left click: plays, no change
     PERFORM DRAIN
     MOVE 0 TO WS-FACE MOVE 2 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ZERO WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.4 a left click does not change the state" TO WS-CASE
     MOVE "instrument=harp,note=1,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     PERFORM DRAIN
     PERFORM COUNT-SOUND
     MOVE "acceptance US12-4 live redstone 30-5 8.4 a left click plays the note (Sound Effect 119)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   8.4 a stone block above mutes a harp note block, for both clicks
     MOVE 6 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "note_block" TO WS-K PERFORM PUT-DEF
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM PLAYER-NEAR
     PERFORM DRAIN
     MOVE 1 TO WS-FACE MOVE 3 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 0 TO WS-FACE MOVE 4 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ZERO WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM DRAIN
     PERFORM COUNT-SOUND
     MOVE "acceptance US12-4 live redstone 30-5 8.4 a block above mutes the note block: no Sound Effect for either click" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 8.4 the right click still tuned it (stone below: basedrum)" TO WS-CASE
     MOVE "instrument=basedrum,note=1,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   8.4 a head above: the instrument works above, so the click plays
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "note_block" TO WS-K PERFORM PUT-DEF
     MOVE 102 TO WS-Y MOVE "zombie_head" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     PERFORM PLAYER-NEAR
     PERFORM DRAIN
     MOVE 0 TO WS-FACE MOVE 5 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ZERO WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM DRAIN
     PERFORM COUNT-SOUND
     MOVE "acceptance US12-4 live redstone 30-5 8.4 a head above does not mute it" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   8.5 step 4: the seed of the sound is drawn from the level's random, not 0, and differs from note to note
     CALL "RL-NOTE-SEED" USING WS-SEED1
     CALL "RL-NOTE-SEED" USING WS-SEED2
     MOVE 0 TO WS-P
     IF WS-SEED1 NOT = 0 AND WS-SEED2 NOT = 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 live redstone 30-5 8.5 the sound seed is drawn (not 0)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 0 TO WS-P
     IF WS-SEED1 NOT = WS-SEED2
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 live redstone 30-5 8.5 two notes have different seeds" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     STOP RUN.

 COUNT-EVENT.
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL " 7 "
     MOVE WS-HITS TO WS-P
     IF WS-P > 0
         MOVE 1 TO WS-P
     END-IF.

 COUNT-SOUND.
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "119"
     MOVE WS-HITS TO WS-P
     IF WS-P > 0
         MOVE 1 TO WS-P
     END-IF.

 PLAYER-NEAR.
*>   the player stands beside the cell of row WS-Z
     MOVE 1.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW).

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS.

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

 END PROGRAM ACC-F2US12-REDSTONE-NOTE-USE.

 COPY CORETEST.
 COPY PORTALTEST.
