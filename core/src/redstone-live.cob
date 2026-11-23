*> Live redstone wiring (docs/protocol/30-redstone-1 sections 2, 5, 6 and 8, 30-2 sections 1 to 4, 30-5 sections 2 and 3): the signal model of the level (getSignal, getDirectSignal,
*> getDirectSignalTo, getBestNeighborSignal, the conductor rule) over the sources of this core, and the block hooks that make the sources and the wire live inside BU-HOOK.
*> Sources and conductors read: the redstone block, the standing and the wall redstone torch, the lever, every button, the repeater, the comparator (signal input only), redstone wire.
*> Deviations, each a gap of what this core knows of a block rather than a rule of the documents: a redstone conductor is the solid opaque block of CBLOCKS (30-1 2.4 never and always
*> lists apply on top), so a slab or a stair counts as a conductor when the content marks it solid and opaque; "top face sturdy" is the same test; willTickThisTick is not tracked (a
*> torch asks for its tick again, which the identity rule of the tick queue ignores while one is pending); the comparator reads signals only (no container, cauldron or item frame
*> analog output: 30-2 sections 4.2 steps 3 and 4 and 5); observers, pressure plates and the other sources are not read. A repeater or comparator placed next to a live input schedules its
*> tick as `setPlacedBy` does (30-2 2.3), whatever placed it.
*>
*> Entry points:
*>   REDSTONE-IDS-ENSURE                                     resolves RSLIVE.cpy from the open block table (once per CB-EPOCH)
*>   REDSTONE-HOOK USING kind, dimension row, x, y, z, state, a, b, out state     the BU-HOOK part (29 section 3 hook kinds): 1 onPlace, 2 removal, 3 neighborChanged, 4 updateShape (the
*>        lock of a repeater), 7 scheduled block tick (torch, repeater, comparator)
*>   REDSTONE-EVALUATE USING dimension row, x, y, z, state   updatePowerStrength (5.4): the target power, the resolved sides (5.2), the write with flags 2 and, when the power changed, the seven
*>        updateNeighborsAt calls in the order of 5.4 step 4
*>   REDSTONE-SWITCH-NOTIFY USING dimension row, x, y, z, state of a lever or button   the neighbour update pair of a lever or button (30-5 sections 2.4 and 3.7), called after the block changed
*>   RL-SIGNAL USING dimension row, x, y, z, direction, signal out        level.getSignal(pos, direction) (30-1 section 2.3)
*>   RL-BEST-NEIGHBOR USING dimension row, x, y, z, signal out            level.getBestNeighborSignal(pos)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-PROP.
*> USING the property text of a state (PIC X(160)), a name (PIC X(16)), the value out (PIC X(16), spaces when the state has no such property).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PAIR                PIC X(160).
 01 WS-NAME                PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(160).
 01 L-NAME                 PIC X(16).
 01 L-VALUE                PIC X(16).
 PROCEDURE DIVISION USING L-TEXT L-NAME L-VALUE.
     MOVE SPACES TO L-VALUE
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > 160
         MOVE SPACES TO WS-PAIR WS-NAME WS-VALUE
         UNSTRING L-TEXT DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POS
         UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-NAME WS-VALUE
         IF WS-NAME = L-NAME
             MOVE WS-VALUE TO L-VALUE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-PROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-IDS-ENSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 COPY CONTENT.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-NAME40              PIC X(40).
 01 WS-KIND                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-VALUE               PIC X(16).
 01 WS-N-FACING            PIC X(16) VALUE "facing".
 01 WS-N-FACE              PIC X(16) VALUE "face".
 01 WS-N-LIT               PIC X(16) VALUE "lit".
 01 WS-N-POWERED           PIC X(16) VALUE "powered".
 01 WS-N-DELAY             PIC X(16) VALUE "delay".
 01 WS-N-LOCKED            PIC X(16) VALUE "locked".
 01 WS-N-MODE              PIC X(16) VALUE "mode".
 01 WS-N-POWER             PIC X(16) VALUE "power".
 01 WS-DIR                 BINARY-LONG.
 PROCEDURE DIVISION.
     IF RL-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO RL-EPOCH
     MOVE -1 TO RL-WIRE RL-SOURCE
     MOVE 0 TO RL-WIRE-FIRST RL-SILENT RL-TOG-COUNT RL-CMP-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE CB-KEY(WS-I) TO WS-KEY
         CALL "KEY-BARE" USING WS-KEY WS-BARE
         COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-BARE))
         MOVE 0 TO WS-CLASS
         EVALUATE TRUE
             WHEN WS-BARE = "redstone_wire"
                 MOVE 1 TO WS-CLASS
                 COMPUTE RL-WIRE = WS-I - 1
                 MOVE CB-FIRST-STATE(WS-I) TO RL-WIRE-FIRST
             WHEN WS-BARE = "redstone_block"
                 MOVE 2 TO WS-CLASS
                 COMPUTE RL-SOURCE = WS-I - 1
             WHEN WS-BARE = "redstone_torch"
                 MOVE 3 TO WS-CLASS
             WHEN WS-BARE = "redstone_wall_torch"
                 MOVE 4 TO WS-CLASS
             WHEN WS-BARE = "lever"
                 MOVE 5 TO WS-CLASS
             WHEN WS-BARE = "repeater"
                 MOVE 7 TO WS-CLASS
             WHEN WS-BARE = "comparator"
                 MOVE 8 TO WS-CLASS
             WHEN WS-BARE = "hopper"
                 MOVE 10 TO WS-CLASS
             WHEN WS-BARE = "redstone_lamp"
                 MOVE 11 TO WS-CLASS
             WHEN WS-BARE = "tnt"
                 MOVE 14 TO WS-CLASS
             WHEN WS-BARE = "note_block"
                 MOVE 16 TO WS-CLASS
             WHEN WS-BARE = "observer"
                 MOVE 17 TO WS-CLASS
             WHEN WS-BARE = "light_weighted_pressure_plate" OR "heavy_weighted_pressure_plate"
                 MOVE 19 TO WS-CLASS
             WHEN WS-BARE = "daylight_detector"
                 MOVE 20 TO WS-CLASS
             WHEN WS-BARE = "target"
                 MOVE 21 TO WS-CLASS
             WHEN WS-BARE = "detector_rail"
                 MOVE 23 TO WS-CLASS
             WHEN WS-BARE = "tripwire_hook"
                 MOVE 24 TO WS-CLASS
             WHEN WS-BARE = "tripwire"
                 MOVE 25 TO WS-CLASS
             WHEN WS-BARE = "sculk_sensor"
                 MOVE 26 TO WS-CLASS
             WHEN WS-BARE = "calibrated_sculk_sensor"
                 MOVE 27 TO WS-CLASS
             WHEN WS-BARE = "lectern"
                 MOVE 28 TO WS-CLASS
             WHEN WS-BARE = "dispenser"
                 MOVE 29 TO WS-CLASS
             WHEN WS-BARE = "dropper"
                 MOVE 30 TO WS-CLASS
             WHEN WS-BARE = "piston"
                 MOVE 31 TO WS-CLASS
             WHEN WS-BARE = "sticky_piston"
                 MOVE 32 TO WS-CLASS
             WHEN WS-BARE = "piston_head"
                 MOVE 33 TO WS-CLASS
             WHEN WS-BARE = "moving_piston"
                 MOVE 34 TO WS-CLASS
             WHEN WS-LEN >= 10 AND WS-BARE(WS-LEN - 6:7) = "_button"
                 MOVE 6 TO WS-CLASS
             WHEN WS-LEN >= 15 AND WS-BARE(WS-LEN - 14:15) = "_pressure_plate"
                 MOVE 18 TO WS-CLASS
             WHEN WS-LEN >= 13 AND WS-BARE(WS-LEN - 12:13) = "lightning_rod"
                 MOVE 22 TO WS-CLASS
             WHEN WS-LEN >= 11 AND WS-BARE(WS-LEN - 10:11) = "copper_bulb"
                 MOVE 15 TO WS-CLASS
             WHEN WS-LEN >= 11 AND WS-BARE(WS-LEN - 10:11) = "_fence_gate"
                 MOVE 13 TO WS-CLASS
             WHEN WS-LEN >= 5 AND WS-BARE(WS-LEN - 4:5) = "_door"
                 MOVE 12 TO WS-CLASS
             WHEN WS-LEN >= 10 AND WS-BARE(WS-LEN - 8:9) = "_trapdoor"
                 MOVE 9 TO WS-CLASS
         END-EVALUATE
         MOVE WS-CLASS TO RL-CLASS(WS-I)
*>       the conductor rule (30-1 2.4): the never and always lists, else the solid opaque block
         MOVE WS-BARE TO WS-NAME40
         CALL "RS1-CONDUCTOR-KIND" USING WS-NAME40 WS-KIND
         EVALUATE WS-KIND
             WHEN 1
                 MOVE 0 TO RL-COND(WS-I)
             WHEN 2
                 MOVE 1 TO RL-COND(WS-I)
             WHEN OTHER
*>               the default rule: the collision shape of the state is the full cube (2 asks RL-LOOK to read it per state: a slab, stairs, fence or chest is not a conductor, a double slab is); the
*>               stand-in set has no shapes, so there a solid opaque block conducts
                 MOVE 0 TO RL-COND(WS-I)
                 IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
                     IF CB-SOLID(WS-I) = 1
                         MOVE 2 TO RL-COND(WS-I)
                     END-IF
                 ELSE
                     IF CB-SOLID(WS-I) = 1 AND CB-OPAQUE(WS-I) = 1
                         MOVE 1 TO RL-COND(WS-I)
                     END-IF
                 END-IF
         END-EVALUATE
*>       the analog output kind (30-2 section 5.3)
         MOVE 0 TO RL-ANALOG(WS-I)
         EVALUATE TRUE
             WHEN WS-BARE = "chest" OR "trapped_chest"
                 MOVE 1 TO RL-ANALOG(WS-I)
             WHEN WS-LEN >= 12 AND WS-BARE(WS-LEN - 11:12) = "copper_chest"
                 MOVE 1 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "barrel"
                 MOVE 2 TO RL-ANALOG(WS-I)
             WHEN WS-LEN >= 11 AND WS-BARE(WS-LEN - 10:11) = "shulker_box"
                 MOVE 3 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "furnace" OR "smoker" OR "blast_furnace"
                 MOVE 4 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "brewing_stand"
                 MOVE 5 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "hopper"
                 MOVE 6 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "dispenser" OR "dropper"
                 MOVE 7 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "decorated_pot"
                 MOVE 8 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "crafter"
                 MOVE 9 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "chiseled_bookshelf"
                 MOVE 10 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "lectern"
                 MOVE 11 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "composter"
                 MOVE 12 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "water_cauldron" OR "powder_snow_cauldron"
                 MOVE 13 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "lava_cauldron"
                 MOVE 14 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "cauldron"
                 MOVE 15 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "cake"
                 MOVE 16 TO RL-ANALOG(WS-I)
             WHEN WS-LEN >= 11 AND WS-BARE(WS-LEN - 10:11) = "candle_cake"
                 MOVE 17 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "beehive" OR "bee_nest"
                 MOVE 18 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "end_portal_frame"
                 MOVE 19 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "respawn_anchor"
                 MOVE 20 TO RL-ANALOG(WS-I)
             WHEN WS-CLASS = 15
                 MOVE 21 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "jukebox"
                 MOVE 22 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "command_block" OR "chain_command_block" OR "repeating_command_block"
                 MOVE 23 TO RL-ANALOG(WS-I)
             WHEN WS-CLASS = 26 OR WS-CLASS = 27
                 MOVE 24 TO RL-ANALOG(WS-I)
             WHEN WS-LEN >= 19 AND WS-BARE(WS-LEN - 18:19) = "copper_golem_statue"
                 MOVE 25 TO RL-ANALOG(WS-I)
             WHEN WS-BARE = "creaking_heart"
                 MOVE 26 TO RL-ANALOG(WS-I)
             WHEN WS-LEN >= 6 AND WS-BARE(WS-LEN - 5:6) = "_shelf"
                 MOVE 27 TO RL-ANALOG(WS-I)
             WHEN WS-CLASS = 23
                 MOVE 28 TO RL-ANALOG(WS-I)
         END-EVALUATE
*>       the decoded states of the signal blocks
         IF (WS-CLASS >= 3 AND WS-CLASS <= 8) OR (WS-CLASS >= 17 AND WS-CLASS <= 30)
             COMPUTE WS-LAST = CB-FIRST-STATE(WS-I) + CB-STATES(WS-I) - 1
             PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-I) BY 1 UNTIL WS-S > WS-LAST
                 CALL "BLOCKS-STATE-PROPS" USING WS-S WS-TEXT
                 COMPUTE WS-START = WS-S + 1
                 MOVE 0 TO RL-S-DIR(WS-START) RL-S-ON(WS-START) RL-S-DELAY(WS-START) RL-S-LOCKED(WS-START) RL-S-MODE(WS-START)
                     RL-S-POWER(WS-START)
                 CALL "RL-PROP" USING WS-TEXT WS-N-FACING WS-VALUE
                 EVALUATE WS-VALUE
                     WHEN "north"
                         MOVE 2 TO WS-DIR
                     WHEN "south"
                         MOVE 3 TO WS-DIR
                     WHEN "west"
                         MOVE 4 TO WS-DIR
                     WHEN "east"
                         MOVE 5 TO WS-DIR
                     WHEN "up"
                         MOVE 1 TO WS-DIR
                     WHEN OTHER
                         MOVE 0 TO WS-DIR
                 END-EVALUATE
                 IF WS-CLASS = 5 OR WS-CLASS = 6
                     CALL "RL-PROP" USING WS-TEXT WS-N-FACE WS-VALUE
                     EVALUATE WS-VALUE
                         WHEN "floor"
                             MOVE 1 TO WS-DIR
                         WHEN "ceiling"
                             MOVE 0 TO WS-DIR
                     END-EVALUATE
                 END-IF
                 MOVE WS-DIR TO RL-S-DIR(WS-START)
                 IF WS-CLASS = 3 OR WS-CLASS = 4
                     CALL "RL-PROP" USING WS-TEXT WS-N-LIT WS-VALUE
                 ELSE
                     CALL "RL-PROP" USING WS-TEXT WS-N-POWERED WS-VALUE
                 END-IF
                 IF WS-VALUE = "true"
                     MOVE 1 TO RL-S-ON(WS-START)
                 END-IF
                 IF WS-CLASS = 19 OR WS-CLASS = 20 OR WS-CLASS = 21 OR WS-CLASS = 26 OR WS-CLASS = 27
                     CALL "RL-PROP" USING WS-TEXT WS-N-POWER WS-VALUE
                     MOVE FUNCTION NUMVAL(WS-VALUE) TO RL-S-POWER(WS-START)
                 END-IF
                 IF WS-CLASS = 7
                     CALL "RL-PROP" USING WS-TEXT WS-N-DELAY WS-VALUE
                     MOVE FUNCTION NUMVAL(WS-VALUE) TO RL-S-DELAY(WS-START)
                     CALL "RL-PROP" USING WS-TEXT WS-N-LOCKED WS-VALUE
                     IF WS-VALUE = "true"
                         MOVE 1 TO RL-S-LOCKED(WS-START)
                     END-IF
                 END-IF
                 IF WS-CLASS = 8
                     CALL "RL-PROP" USING WS-TEXT WS-N-MODE WS-VALUE
                     IF WS-VALUE = "subtract"
                         MOVE 1 TO RL-S-MODE(WS-START)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REDSTONE-IDS-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-LOOK.
*> USING dimension row, x, y, z, state out, class out, conductor out: the state at the position with the redstone role and the conductor flag of its block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-CLASS L-COND.
     CALL "REDSTONE-IDS-ENSURE"
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE RL-CLASS(WS-BLOCK + 1) TO L-CLASS
     MOVE RL-COND(WS-BLOCK + 1) TO L-COND
     IF L-COND = 2
*>       30-1 2.4: a conductor when the collision shape of this state is the full cube
         MOVE 0 TO L-COND
         CALL "BSH-COLL-ID" USING L-STATE WS-SHAPE
         IF WS-SHAPE = 1
             MOVE 1 TO L-COND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-LOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-STURDY.
*> USING a state, sturdy out: the top face (or any face) of the block is sturdy: the solid opaque block of CBLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-STURDY.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE 0 TO L-STURDY
     IF CB-SOLID(WS-BLOCK + 1) = 1 AND CB-OPAQUE(WS-BLOCK + 1) = 1
         MOVE 1 TO L-STURDY
     END-IF
     GOBACK.
 END PROGRAM RL-STURDY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-WIRE-FRESH.
*> USING dimension row, x, y, z of a wire, north, east, south, west out: getConnectingSide (30-1 section 5.2) of the four horizontal sides (0 up, 1 side, 2 none) with allowUp
*> taken from the block above the wire.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ORDER               PIC X(4) VALUE "2534".
 01 WS-DIGIT               PIC 9.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-ACOND               BINARY-LONG.
 01 WS-ALLOW-UP            BINARY-LONG.
 01 WS-STURDY              BINARY-LONG.
 01 WS-HOPPER              BINARY-LONG.
 01 WS-SURVIVE             BINARY-LONG.
 01 WS-SUPPORTS            BINARY-LONG.
 01 WS-ABOVE-WIRE          BINARY-LONG.
 01 WS-BELOW-WIRE          BINARY-LONG.
 01 WS-CONNECT             BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 COPY RSLIVE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-N L-E L-S L-W.
     COMPUTE WS-QY = L-Y + 1
     CALL "RL-LOOK" USING L-DIM L-X WS-QY L-Z WS-STATE WS-CLASS WS-ACOND
     CALL "RS1-ALLOW-UP" USING WS-ACOND WS-ALLOW-UP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-ORDER(WS-I:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-D
         CALL "RS1-STEP" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "RL-LOOK" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-CLASS WS-COND
         CALL "RL-STURDY" USING WS-STATE WS-STURDY
         MOVE 0 TO WS-HOPPER WS-CONNECT
         IF WS-CLASS = 10
             MOVE 1 TO WS-HOPPER
         END-IF
         CALL "RS1-WIRE-SURVIVE-ON" USING WS-STURDY WS-HOPPER WS-SURVIVE
         MOVE WS-SURVIVE TO WS-SUPPORTS
         IF WS-CLASS = 9
             MOVE 1 TO WS-SUPPORTS
         END-IF
*>       shouldConnectTo(S, d): a wire, or a source (a repeater only along its axis)
         EVALUATE WS-CLASS
             WHEN 1
             WHEN 2
             WHEN 3
             WHEN 4
             WHEN 5
             WHEN 6
             WHEN 8
             WHEN 18 THRU 24
             WHEN 26 THRU 28
                 MOVE 1 TO WS-CONNECT
             WHEN 17
                 MOVE RL-S-DIR(WS-STATE + 1) TO WS-FACING
                 CALL "RS1-OBS-CONNECT" USING WS-D WS-FACING WS-CONNECT
             WHEN 7
                 MOVE RL-S-DIR(WS-STATE + 1) TO WS-FACING
                 CALL "RS1-OPP" USING WS-FACING WS-OPP
                 IF WS-D = WS-FACING OR WS-D = WS-OPP
                     MOVE 1 TO WS-CONNECT
                 END-IF
         END-EVALUATE
         COMPUTE WS-QY = L-Y + 1
         CALL "RL-LOOK" USING L-DIM WS-NX WS-QY WS-NZ WS-STATE WS-CLASS WS-ACOND
         MOVE 0 TO WS-ABOVE-WIRE
         IF WS-CLASS = 1
             MOVE 1 TO WS-ABOVE-WIRE
         END-IF
         COMPUTE WS-QY = L-Y - 1
         CALL "RL-LOOK" USING L-DIM WS-NX WS-QY WS-NZ WS-STATE WS-CLASS WS-ACOND
         MOVE 0 TO WS-BELOW-WIRE
         IF WS-CLASS = 1
             MOVE 1 TO WS-BELOW-WIRE
         END-IF
         CALL "RS1-CONNECTING-SIDE" USING WS-ALLOW-UP WS-SUPPORTS WS-ABOVE-WIRE WS-STURDY WS-CONNECT WS-COND WS-BELOW-WIRE WS-SIDE
         EVALUATE WS-D
             WHEN 2
                 MOVE WS-SIDE TO L-N
             WHEN 3
                 MOVE WS-SIDE TO L-S
             WHEN 4
                 MOVE WS-SIDE TO L-W
             WHEN OTHER
                 MOVE WS-SIDE TO L-E
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM RL-WIRE-FRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-WIRE-RESOLVE.
*> USING dimension row, x, y, z, the wire state, north, east, south, west out: getConnectionState (30-1 section 5.2): the four sides of the state recomputed from its neighbours.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-ID                  BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-CUR.
    05 WS-CN               BINARY-LONG.
    05 WS-CE               BINARY-LONG.
    05 WS-CS               BINARY-LONG.
    05 WS-CW               BINARY-LONG.
 01 WS-FRESH.
    05 WS-FN               BINARY-LONG.
    05 WS-FE               BINARY-LONG.
    05 WS-FS               BINARY-LONG.
    05 WS-FW               BINARY-LONG.
 01 WS-DOT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-N L-E L-S L-W.
     COMPUTE WS-ID = L-STATE - RL-WIRE-FIRST + 5567
     CALL "RS1-WIRE-DECODE" USING WS-ID WS-CN WS-CE WS-CS WS-CW WS-POWER
     CALL "RS1-IS-DOT" USING WS-CN WS-CE WS-CS WS-CW WS-DOT
     CALL "RL-WIRE-FRESH" USING L-DIM L-X L-Y L-Z WS-FN WS-FE WS-FS WS-FW
     CALL "RS1-CONNECTION-STATE" USING WS-DOT WS-FN WS-FE WS-FS WS-FW L-N L-E L-S L-W
     GOBACK.
 END PROGRAM RL-WIRE-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-OUTPUT.
*> USING a state, dimension row, x, y, z of that block, the direction asked d (30-1 section 2.2: the direction from the asker towards this block), direct (0 getSignal, 1
*> getDirectSignal), signal out: what the block outputs towards the asker.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-SIDES.
    05 WS-T                BINARY-LONG OCCURS 4 TIMES.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SN                  BINARY-LONG.
 01 WS-SE                  BINARY-LONG.
 01 WS-SS                  BINARY-LONG.
 01 WS-SW                  BINARY-LONG.
 01 WS-CN                  BINARY-LONG.
 01 WS-CE                  BINARY-LONG.
 01 WS-CS                  BINARY-LONG.
 01 WS-CW                  BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-X L-Y L-Z L-D L-DIRECT L-OUT.
     MOVE 0 TO L-OUT
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE RL-CLASS(WS-BLOCK + 1) TO WS-CLASS
     MOVE RL-S-ON(L-STATE + 1) TO WS-ON
     MOVE RL-S-DIR(L-STATE + 1) TO WS-FACING
     EVALUATE WS-CLASS
         WHEN 1
*>           wire (5.6): nothing while it evaluates or towards DOWN, its power towards UP and towards a side it connects
             IF RL-SILENT = 0 AND L-D NOT = 0
                 COMPUTE WS-ID = L-STATE - RL-WIRE-FIRST + 5567
                 CALL "RS1-WIRE-DECODE" USING WS-ID WS-CN WS-CE WS-CS WS-CW WS-POWER
                 IF WS-POWER > 0
                     IF L-D = 1
                         MOVE WS-POWER TO L-OUT
                     ELSE
                         CALL "RL-WIRE-RESOLVE" USING L-DIM L-X L-Y L-Z L-STATE WS-SN WS-SE WS-SS WS-SW
                         MOVE WS-SN TO WS-T(1)
                         MOVE WS-SS TO WS-T(2)
                         MOVE WS-SW TO WS-T(3)
                         MOVE WS-SE TO WS-T(4)
                         CALL "RS1-OPP" USING L-D WS-OPP
                         COMPUTE WS-IDX = WS-OPP - 1
                         MOVE WS-T(WS-IDX) TO WS-SIDE
                         IF WS-SIDE NOT = 2
                             MOVE WS-POWER TO L-OUT
                         END-IF
                     END-IF
                 END-IF
             END-IF
         WHEN 2
*>           the redstone block (6): 15 every way, never direct
             IF L-DIRECT = 0
                 MOVE 15 TO L-OUT
             END-IF
         WHEN 3
*>           the standing torch (8.3): weak to every side but UP, strong to the block above (asked with DOWN)
             IF WS-ON = 1
                 IF L-DIRECT = 0 AND L-D NOT = 1
                     MOVE 15 TO L-OUT
                 END-IF
                 IF L-DIRECT = 1 AND L-D = 0
                     MOVE 15 TO L-OUT
                 END-IF
             END-IF
         WHEN 4
*>           the wall torch: weak to every side but its facing, strong to the block above
             IF WS-ON = 1
                 IF L-DIRECT = 0 AND L-D NOT = WS-FACING
                     MOVE 15 TO L-OUT
                 END-IF
                 IF L-DIRECT = 1 AND L-D = 0
                     MOVE 15 TO L-OUT
                 END-IF
             END-IF
         WHEN 5
         WHEN 6
*>           the lever and the button (30-5 2.1): 15 every way when powered, strong only towards the connected direction
             IF WS-ON = 1
                 IF L-DIRECT = 0
                     MOVE 15 TO L-OUT
                 END-IF
                 IF L-DIRECT = 1 AND L-D = WS-FACING
                     MOVE 15 TO L-OUT
                 END-IF
             END-IF
         WHEN 7
*>           the repeater (30-2 2.2 item 5): its output towards the side it faces
             IF WS-ON = 1 AND L-D = WS-FACING
                 MOVE 15 TO L-OUT
             END-IF
         WHEN 8
             IF WS-ON = 1 AND L-D = WS-FACING
                 CALL "RL-CMP-GET" USING L-DIM L-X L-Y L-Z L-OUT
             END-IF
         WHEN 17
*>           the observer (30-2 6.2): 15 towards its back, weak and strong alike
             CALL "RS1-OBS-SIGNAL" USING WS-ON WS-FACING L-D WS-OWN L-OUT
         WHEN 18
         WHEN 19
         WHEN 23
         WHEN 28
*>           pressure plates (30-5 4.1), the detector rail (30-6) and the lectern: the own signal every way, strong only towards UP (asked by the block below)
             MOVE 0 TO WS-OWN
             IF WS-CLASS = 19
                 MOVE RL-S-POWER(L-STATE + 1) TO WS-OWN
             ELSE
                 IF WS-ON = 1
                     MOVE 15 TO WS-OWN
                 END-IF
             END-IF
             IF L-DIRECT = 0 OR L-D = 1
                 MOVE WS-OWN TO L-OUT
             END-IF
         WHEN 20
         WHEN 21
*>           the daylight detector (30-5 5) and the target block (30-5 6): the power every way, never strong
             IF L-DIRECT = 0
                 MOVE RL-S-POWER(L-STATE + 1) TO L-OUT
             END-IF
         WHEN 22
         WHEN 24
*>           the lightning rod (30-5 7) and the tripwire hook (30-8): 15 while powered every way, strong towards the facing
             IF WS-ON = 1 AND (L-DIRECT = 0 OR L-D = WS-FACING)
                 MOVE 15 TO L-OUT
             END-IF
         WHEN 26
*>           the sculk sensor (30-8): the power every way, strong towards UP
             IF L-DIRECT = 0 OR L-D = 1
                 MOVE RL-S-POWER(L-STATE + 1) TO L-OUT
             END-IF
         WHEN 27
*>           the calibrated sculk sensor: nothing towards its facing, else as the sensor
             IF L-D NOT = WS-FACING AND (L-DIRECT = 0 OR L-D = 1)
                 MOVE RL-S-POWER(L-STATE + 1) TO L-OUT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CMP-GET.
*> USING dimension row, x, y, z, output out: the stored output of the comparator block entity at the position (0 when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OUT.
     MOVE 0 TO L-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-CMP-COUNT
         IF RL-CMP-DIM(WS-I) = L-DIM AND RL-CMP-X(WS-I) = L-X AND RL-CMP-Y(WS-I) = L-Y AND RL-CMP-Z(WS-I) = L-Z
             MOVE RL-CMP-OUT(WS-I) TO L-OUT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-CMP-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CMP-SET.
*> USING dimension row, x, y, z, output: stores the output of the comparator block entity at the position (the entity is made when there is none; at most 256 exist, a further one reads as 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OUT.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-CMP-COUNT
         IF RL-CMP-DIM(WS-I) = L-DIM AND RL-CMP-X(WS-I) = L-X AND RL-CMP-Y(WS-I) = L-Y AND RL-CMP-Z(WS-I) = L-Z
             MOVE L-OUT TO RL-CMP-OUT(WS-I)
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0 AND RL-CMP-COUNT < 256
         ADD 1 TO RL-CMP-COUNT
         MOVE L-DIM TO RL-CMP-DIM(RL-CMP-COUNT)
         MOVE L-X TO RL-CMP-X(RL-CMP-COUNT)
         MOVE L-Y TO RL-CMP-Y(RL-CMP-COUNT)
         MOVE L-Z TO RL-CMP-Z(RL-CMP-COUNT)
         MOVE L-OUT TO RL-CMP-OUT(RL-CMP-COUNT)
     END-IF
     GOBACK.
 END PROGRAM RL-CMP-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DIRECT-TO.
*> USING dimension row, x, y, z, signal out: getDirectSignalTo (30-1 section 2.3): the strongest getDirectSignal of the six neighbours in the order down, up, north, south, west, east,
*> at once at 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OUT.
     MOVE 0 TO L-OUT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5 OR L-OUT >= 15
         CALL "RS1-STEP" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "RL-LOOK" USING L-DIM WS-NX WS-NY WS-NZ WS-STATE WS-CLASS WS-COND
         IF WS-CLASS NOT = 0
             CALL "RL-OUTPUT" USING WS-STATE L-DIM WS-NX WS-NY WS-NZ WS-D WS-ONE WS-S
             IF WS-S > L-OUT
                 MOVE WS-S TO L-OUT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-DIRECT-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SIGNAL.
*> USING dimension row, x, y, z, direction, signal out: SignalGetter.getSignal(pos, direction) (30-1 section 2.3): the block's own weak output, and for a conductor the stronger of
*> that and the strong power its neighbours give it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DIRECT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-D L-OUT.
     MOVE 0 TO L-OUT
     CALL "RL-LOOK" USING L-DIM L-X L-Y L-Z WS-STATE WS-CLASS WS-COND
     IF WS-CLASS NOT = 0
         CALL "RL-OUTPUT" USING WS-STATE L-DIM L-X L-Y L-Z L-D WS-ZERO L-OUT
     END-IF
     IF WS-COND = 1
         CALL "RL-DIRECT-TO" USING L-DIM L-X L-Y L-Z WS-DIRECT
         IF WS-DIRECT > L-OUT
             MOVE WS-DIRECT TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BEST-NEIGHBOR.
*> USING dimension row, x, y, z, signal out: getBestNeighborSignal (30-1 section 2.3): getSignal(pos + d, d) over the six directions, at once at 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OUT.
     MOVE 0 TO L-OUT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5 OR L-OUT >= 15
         CALL "RS1-STEP" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "RL-SIGNAL" USING L-DIM WS-NX WS-NY WS-NZ WS-D WS-S
         IF WS-S > L-OUT
             MOVE WS-S TO L-OUT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-BEST-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-WIRE-POWER.
*> USING dimension row, x, y, z, power out: the power property of the wire at the position, 0 when the block there is not wire.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CN                  BINARY-LONG.
 01 WS-CE                  BINARY-LONG.
 01 WS-CS                  BINARY-LONG.
 01 WS-CW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-POWER.
     MOVE 0 TO L-POWER
     CALL "RL-LOOK" USING L-DIM L-X L-Y L-Z WS-STATE WS-CLASS WS-COND
     IF WS-CLASS = 1
         COMPUTE WS-ID = WS-STATE - RL-WIRE-FIRST + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-CN WS-CE WS-CS WS-CW L-POWER
     END-IF
     GOBACK.
 END PROGRAM RL-WIRE-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-EVALUATE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-QY                  BINARY-LONG.
 01 LS-ID                  BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 01 LS-ACOND               BINARY-LONG.
 01 LS-BLOCK-SIGNAL        BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-R2                  BINARY-LONG.
 01 LS-PN                  BINARY-LONG.
 01 LS-PABOVE              BINARY-LONG.
 01 LS-PBELOW              BINARY-LONG.
 01 LS-INCOMING            BINARY-LONG.
 01 LS-TARGET              BINARY-LONG.
 01 LS-POWER               BINARY-LONG.
 01 LS-ORDER               PIC X(4) VALUE "2534".
 01 LS-DIGIT               PIC 9.
 01 LS-I                   BINARY-LONG.
 01 LS-CUR.
    05 LS-CN               BINARY-LONG.
    05 LS-CE               BINARY-LONG.
    05 LS-CS               BINARY-LONG.
    05 LS-CW               BINARY-LONG.
 01 LS-FRESH.
    05 LS-FN               BINARY-LONG.
    05 LS-FE               BINARY-LONG.
    05 LS-FS               BINARY-LONG.
    05 LS-FW               BINARY-LONG.
 01 LS-MERGED.
    05 LS-MN               BINARY-LONG.
    05 LS-ME               BINARY-LONG.
    05 LS-MS               BINARY-LONG.
    05 LS-MW               BINARY-LONG.
 01 LS-FINAL.
    05 LS-ON               BINARY-LONG.
    05 LS-OE               BINARY-LONG.
    05 LS-OS               BINARY-LONG.
    05 LS-OW               BINARY-LONG.
 01 LS-WAS-DOT             BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-CALLS.
    05 LS-CALL             BINARY-LONG OCCURS 7 TIMES.
 01 LS-C1                  BINARY-LONG.
 01 LS-C2                  BINARY-LONG.
 01 LS-C3                  BINARY-LONG.
 01 LS-C4                  BINARY-LONG.
 01 LS-C5                  BINARY-LONG.
 01 LS-C6                  BINARY-LONG.
 01 LS-C7                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     COMPUTE LS-ID = L-STATE - RL-WIRE-FIRST + 5567
     CALL "RS1-WIRE-DECODE" USING LS-ID LS-CN LS-CE LS-CS LS-CW LS-POWER
*>   getBlockSignal (5.4 step 1): the strongest neighbour signal with the wire itself silent
     MOVE 1 TO RL-SILENT
     CALL "RL-BEST-NEIGHBOR" USING L-DIM L-X L-Y L-Z LS-BLOCK-SIGNAL
     MOVE 0 TO RL-SILENT
*>   the incoming wire signal (5.4 step 2): the horizontal neighbours, a wire on top of a conductor, a wire diagonally below a non-conductor
     MOVE 0 TO LS-R
     COMPUTE LS-QY = L-Y + 1
     CALL "RL-LOOK" USING L-DIM L-X LS-QY L-Z LS-NSTATE LS-CLASS LS-ACOND
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-ORDER(LS-I:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-D
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "RL-LOOK" USING L-DIM LS-NX L-Y LS-NZ LS-NSTATE LS-CLASS LS-COND
         CALL "RL-WIRE-POWER" USING L-DIM LS-NX L-Y LS-NZ LS-PN
         COMPUTE LS-QY = L-Y + 1
         CALL "RL-WIRE-POWER" USING L-DIM LS-NX LS-QY LS-NZ LS-PABOVE
         COMPUTE LS-QY = L-Y - 1
         CALL "RL-WIRE-POWER" USING L-DIM LS-NX LS-QY LS-NZ LS-PBELOW
         CALL "RS1-WIRE-INCOMING-STEP" USING LS-R LS-PN LS-COND LS-ACOND LS-PABOVE LS-PBELOW LS-R2
         MOVE LS-R2 TO LS-R
     END-PERFORM
     CALL "RS1-WIRE-INCOMING-END" USING LS-R LS-INCOMING
     CALL "RS1-WIRE-TARGET" USING LS-BLOCK-SIGNAL LS-INCOMING LS-TARGET
*>   the sides (5.2): the connecting side of the four directions, merged with the connected sides of the state, and the dot rule
     CALL "RL-WIRE-FRESH" USING L-DIM L-X L-Y L-Z LS-FN LS-FE LS-FS LS-FW
     CALL "RS1-IS-DOT" USING LS-CN LS-CE LS-CS LS-CW LS-WAS-DOT
     CALL "RS1-MISSING-CONNECTIONS" USING LS-CN LS-CE LS-CS LS-CW LS-FN LS-FE LS-FS LS-FW LS-MN LS-ME LS-MS LS-MW
     CALL "RS1-CONNECTION-STATE" USING LS-WAS-DOT LS-MN LS-ME LS-MS LS-MW LS-ON LS-OE LS-OS LS-OW
     CALL "RS1-WIRE-STATE" USING LS-ON LS-OE LS-OS LS-OW LS-TARGET LS-NEW
     COMPUTE LS-NEW = LS-NEW - 5567 + RL-WIRE-FIRST
     IF LS-NEW = L-STATE
         GOBACK
     END-IF
*>   the write reaches the clients only (flags 2), then the seven neighbour updates when the power changed
     MOVE 2 TO LS-FLAGS
     MOVE 512 TO LS-BUDGET
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
     IF LS-TARGET NOT = LS-POWER
         CALL "RS1-WIRE-NOTIFY-ORDER" USING L-X L-Y L-Z LS-C1 LS-C2 LS-C3 LS-C4
             LS-C5 LS-C6 LS-C7
         MOVE LS-C1 TO LS-CALL(1)
         MOVE LS-C2 TO LS-CALL(2)
         MOVE LS-C3 TO LS-CALL(3)
         MOVE LS-C4 TO LS-CALL(4)
         MOVE LS-C5 TO LS-CALL(5)
         MOVE LS-C6 TO LS-CALL(6)
         MOVE LS-C7 TO LS-CALL(7)
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 7
             MOVE L-X TO LS-NX
             MOVE L-Y TO LS-NY
             MOVE L-Z TO LS-NZ
             IF LS-CALL(LS-I) >= 0
                 CALL "RS1-STEP" USING LS-CALL(LS-I) LS-DX LS-DY LS-DZ
                 ADD LS-DX TO LS-NX
                 ADD LS-DY TO LS-NY
                 ADD LS-DZ TO LS-NZ
             END-IF
             CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM REDSTONE-EVALUATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-SWITCH-NOTIFY RECURSIVE.
*> USING dimension row, x, y, z, the state of the lever or button: the neighbour update pair (30-5 sections 2.4 and 3.7): the neighbours of the switch, then the neighbours of the
*> support block at pos + opposite(C), with the switch block as the source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-C                   BINARY-LONG.
 01 LS-S                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "REDSTONE-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-S-DIR(L-STATE + 1) TO LS-C
     CALL "RS1-OPP" USING LS-C LS-S
     CALL "RS1-STEP" USING LS-S LS-DX LS-DY LS-DZ
     COMPUTE LS-NX = L-X + LS-DX
     COMPUTE LS-NY = L-Y + LS-DY
     COMPUTE LS-NZ = L-Z + LS-DZ
     CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z LS-BLOCK
     CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ LS-BLOCK
     GOBACK.
 END PROGRAM REDSTONE-SWITCH-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TORCH-NOTIFY RECURSIVE.
*> USING dimension row, x, y, z, torch block: notifyNeighbors (30-1 section 8.2): updateNeighborsAt of each of the six neighbours in Direction.values() order.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NY = L-Y + LS-DY
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ L-BLOCK
     END-PERFORM
     GOBACK.
 END PROGRAM RL-TORCH-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TOG-COUNT-OF.
*> USING dimension row, x, y, z, too often out: isToggledTooFrequently without recording (30-1 section 8.3): the entries of the position in the toggle list, true once there are 8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOO                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TOO.
     MOVE 0 TO WS-COUNT L-TOO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-TOG-COUNT
         IF RL-TOG-DIM(WS-I) = L-DIM AND RL-TOG-X(WS-I) = L-X AND RL-TOG-Y(WS-I) = L-Y AND RL-TOG-Z(WS-I) = L-Z
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT >= 8
         MOVE 1 TO L-TOO
     END-IF
     GOBACK.
 END PROGRAM RL-TOG-COUNT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TOG-RECORD.
*> USING dimension row, x, y, z: appends (pos, game time) to the toggle list; nothing is recorded beyond 256 entries.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RSLIVE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     IF RL-TOG-COUNT < 256
         ADD 1 TO RL-TOG-COUNT
         MOVE L-DIM TO RL-TOG-DIM(RL-TOG-COUNT)
         MOVE L-X TO RL-TOG-X(RL-TOG-COUNT)
         MOVE L-Y TO RL-TOG-Y(RL-TOG-COUNT)
         MOVE L-Z TO RL-TOG-Z(RL-TOG-COUNT)
         MOVE CW-TICKS TO RL-TOG-WHEN(RL-TOG-COUNT)
     END-IF
     GOBACK.
 END PROGRAM RL-TOG-RECORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TOG-PRUNE.
*> USING nothing: the head of the toggle list goes while it is older than 60 game ticks (30-1 section 8.3 step 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 01 WS-AGE                 BINARY-DOUBLE.
 PROCEDURE DIVISION.
     PERFORM UNTIL RL-TOG-COUNT = 0
         COMPUTE WS-AGE = CW-TICKS - RL-TOG-WHEN(1)
         IF WS-AGE <= 60
             EXIT PERFORM
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= RL-TOG-COUNT
             MOVE RL-TOG(WS-I + 1) TO RL-TOG(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM RL-TOG-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM RL-TOG-PRUNE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TORCH-TICK RECURSIVE.
*> USING dimension row, x, y, z, state, torch block, lit, powered: the scheduled tick of a redstone torch (30-1 section 8.3 tick): prune, flip, record, burnout.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME-LIT            PIC X(16) VALUE "lit".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-FALSE               PIC X(16) VALUE "false".
 LOCAL-STORAGE SECTION.
 01 LS-STEP                BINARY-LONG.
 01 LS-TOO                 BINARY-LONG.
 01 LS-SETLIT              BINARY-LONG.
 01 LS-BURN                BINARY-LONG.
 01 LS-RETRY               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-TYPE                BINARY-LONG.
 01 LS-PRIO                BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-DATA                BINARY-LONG.
 01 LS-EXCLUDED            BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-BLOCK L-LIT L-POWERED.
     CALL "RL-TOG-PRUNE"
     CALL "RS1-TORCH-TICK-A" USING L-LIT L-POWERED LS-STEP
     IF LS-STEP = 1
         CALL "SW-SET-PROP" USING L-STATE WS-NAME-LIT WS-FALSE LS-NEW LS-OLD
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z LS-NEW
         CALL "RL-TOG-RECORD" USING L-DIM L-X L-Y L-Z
     END-IF
     IF LS-STEP > 0
         CALL "RL-TOG-COUNT-OF" USING L-DIM L-X L-Y L-Z LS-TOO
         CALL "RS1-TORCH-TICK-B" USING LS-STEP LS-TOO LS-SETLIT LS-BURN LS-RETRY
         IF LS-BURN = 1
             MOVE 1502 TO LS-EVENT
             MOVE 0 TO LS-DATA LS-EXCLUDED
             CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
             MOVE 1 TO LS-TYPE
             MOVE 0 TO LS-PRIO
             CALL "BT-SCHEDULE" USING L-DIM LS-TYPE L-BLOCK L-X L-Y L-Z LS-RETRY LS-PRIO LS-RESULT
         END-IF
         IF LS-SETLIT = 1
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-LIT WS-TRUE LS-NEW LS-OLD
             CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z LS-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-TORCH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TORCH-HOOK RECURSIVE.
*> USING kind, dimension row, x, y, z, state, a, b: the hooks of the standing and the wall redstone torch (30-1 section 8): notifyNeighbors on place and removal (8.2), the tick request
*> of neighborChanged (2 ticks ahead) and the inverter tick with the toggle list and the burnout (8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-LIT                 BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-O                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-DELAY               BINARY-LONG.
 01 LS-PRIO                BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     MOVE RL-S-ON(L-STATE + 1) TO LS-LIT
*>   the input (8.3): the block it stands on (DOWN), or the block it is attached to, asked from the torch's side
     IF L-KIND = 3 OR L-KIND = 7
         IF LS-CLASS = 3
             MOVE 0 TO LS-D
         ELSE
             MOVE RL-S-DIR(L-STATE + 1) TO LS-O
             CALL "RS1-OPP" USING LS-O LS-D
         END-IF
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NY = L-Y + LS-DY
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "RL-SIGNAL" USING L-DIM LS-NX LS-NY LS-NZ LS-D LS-SIGNAL
         MOVE 0 TO LS-POWERED
         IF LS-SIGNAL > 0
             MOVE 1 TO LS-POWERED
         END-IF
     END-IF
     EVALUATE L-KIND
         WHEN 1
             CALL "RL-TORCH-NOTIFY" USING L-DIM L-X L-Y L-Z LS-BLOCK
         WHEN 2
             IF L-B = 0
                 CALL "RL-TORCH-NOTIFY" USING L-DIM L-X L-Y L-Z LS-BLOCK
             END-IF
         WHEN 3
             IF LS-LIT = LS-POWERED
                 MOVE 1 TO LS-TYPE
                 MOVE 2 TO LS-DELAY
                 MOVE 0 TO LS-PRIO
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
             END-IF
         WHEN 7
             CALL "RL-TORCH-TICK" USING L-DIM L-X L-Y L-Z L-STATE LS-BLOCK LS-LIT LS-POWERED
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-TORCH-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-FRONT RECURSIVE.
*> USING dimension row, x, y, z, facing, block: updateNeighborsInFront (30-2 section 1.3): the output cell is told, then its neighbours except the one at O + facing (the diode).
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-O                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-BLOCK.
     CALL "RS1-OPP" USING L-FACING LS-O
     CALL "RS1-STEP" USING LS-O LS-DX LS-DY LS-DZ
     COMPUTE LS-NX = L-X + LS-DX
     COMPUTE LS-NY = L-Y + LS-DY
     COMPUTE LS-NZ = L-Z + LS-DZ
     CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM LS-NX LS-NY LS-NZ L-BLOCK
     CALL "BU-NEIGHBORS-EXCEPT" USING L-DIM LS-NX LS-NY LS-NZ L-BLOCK L-FACING
     GOBACK.
 END PROGRAM RL-FRONT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DIODE-SIDE.
*> USING dimension row, x, y, z, facing, diodes only (1 repeater, 0 comparator), signal out: getAlternateSignal (30-2 section 2.2 item 2) over the cells at cw(facing) and ccw(facing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIODES-ONLY          BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-DIODES-ONLY L-OUT.
     MOVE 0 TO L-OUT
     EVALUATE L-FACING
         WHEN 2
             MOVE 5 TO WS-A
         WHEN 5
             MOVE 3 TO WS-A
         WHEN 3
             MOVE 4 TO WS-A
         WHEN OTHER
             MOVE 2 TO WS-A
     END-EVALUATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         CALL "RS1-STEP" USING WS-A WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "RL-LOOK" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-CLASS WS-COND
         MOVE 0 TO WS-S
*>       getControlInputSignal (30-1 section 2.3): only a diode's direct output, or any source
         IF L-DIODES-ONLY = 1
             IF WS-CLASS = 7 OR WS-CLASS = 8
                 CALL "RL-OUTPUT" USING WS-STATE L-DIM WS-NX L-Y WS-NZ WS-A WS-ONE WS-S
             END-IF
         ELSE
             EVALUATE WS-CLASS
                 WHEN 1
                     CALL "RL-WIRE-POWER" USING L-DIM WS-NX L-Y WS-NZ WS-S
                 WHEN 2
                     MOVE 15 TO WS-S
                 WHEN 3 THRU 8
                     CALL "RL-OUTPUT" USING WS-STATE L-DIM WS-NX L-Y WS-NZ WS-A WS-ONE WS-S
             END-EVALUATE
         END-IF
         IF WS-S > L-OUT
             MOVE WS-S TO L-OUT
         END-IF
         CALL "RS1-OPP" USING WS-A WS-DX
         MOVE WS-DX TO WS-A
     END-PERFORM
     GOBACK.
 END PROGRAM RL-DIODE-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DIODE-EVAL.
*> USING dimension row, x, y, z, state of a repeater or comparator, input out, side out, calculated output out (comparator rule 4.3; 15 for a repeater when it would turn on, else 0), shouldTurnOn out,
*> shouldPrioritize out (30-2 sections 2.2, 3 and 4.2 to 4.3; the comparator input is the signal input only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NCLASS              BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DIODES-ONLY         BINARY-LONG.
 01 WS-AHAS                BINARY-LONG.
 01 WS-AVAL                BINARY-LONG.
 01 WS-ACOND               BINARY-LONG.
 01 WS-ACLASS              BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-FVAL                BINARY-LONG.
 01 WS-S2HAS               BINARY-LONG.
 01 WS-S2VAL               BINARY-LONG.
 01 WS-INPUT2              BINARY-LONG.
 01 WS-OPP-F               BINARY-LONG.
 01 WS-AX2                 BINARY-LONG.
 01 WS-AY2                 BINARY-LONG.
 01 WS-AZ2                 BINARY-LONG.
 01 WS-ASTATE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-INPUT                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-CALC                 BINARY-LONG.
 01 L-TURN                 BINARY-LONG.
 01 L-PRIO                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-INPUT L-SIDE L-CALC L-TURN L-PRIO.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE RL-CLASS(WS-BLOCK + 1) TO WS-CLASS
     MOVE RL-S-DIR(L-STATE + 1) TO WS-F
*>   getInputSignal (2.2 item 1): the signal of the cell in front of the input side. The explicit wire power read of the document is not made: wire always connects to a
*>   repeater or comparator on its axis, so the signal it reports towards this block is its power already.
     CALL "RS1-STEP" USING WS-F WS-DX WS-DY WS-DZ
     COMPUTE WS-NX = L-X + WS-DX
     COMPUTE WS-NY = L-Y + WS-DY
     COMPUTE WS-NZ = L-Z + WS-DZ
     CALL "RL-SIGNAL" USING L-DIM WS-NX WS-NY WS-NZ WS-F WS-S
     MOVE WS-S TO L-INPUT
     IF WS-CLASS = 8
*>       getInputSignal of the comparator (30-2 4.2): the analog output of the cell it faces replaces the input, else a frame or an analog block behind one conductor
         CALL "RS1-OPP" USING WS-F WS-OPP-F
         CALL "RL-ANALOG-AT" USING L-DIM WS-NX WS-NY WS-NZ WS-OPP-F WS-AHAS WS-AVAL
         CALL "RL-LOOK" USING L-DIM WS-NX WS-NY WS-NZ WS-ASTATE WS-ACLASS WS-ACOND
         MOVE 0 TO WS-FRAMES WS-FVAL WS-S2HAS WS-S2VAL
         IF WS-ACOND = 1
             COMPUTE WS-AX2 = WS-NX + WS-DX
             COMPUTE WS-AY2 = WS-NY + WS-DY
             COMPUTE WS-AZ2 = WS-NZ + WS-DZ
             CALL "RL-FRAME-AT" USING L-DIM WS-AX2 WS-AY2 WS-AZ2 WS-F WS-FRAMES WS-FVAL
             CALL "RL-ANALOG-AT" USING L-DIM WS-AX2 WS-AY2 WS-AZ2 WS-OPP-F WS-S2HAS WS-S2VAL
         END-IF
         CALL "RS1-CMP-INPUT" USING L-INPUT WS-AHAS WS-AVAL WS-ACOND WS-FRAMES WS-FVAL WS-S2HAS WS-S2VAL WS-INPUT2
         MOVE WS-INPUT2 TO L-INPUT
     END-IF
     MOVE 0 TO WS-DIODES-ONLY
     IF WS-CLASS = 7
         MOVE 1 TO WS-DIODES-ONLY
     END-IF
     CALL "RL-DIODE-SIDE" USING L-DIM L-X L-Y L-Z WS-F WS-DIODES-ONLY L-SIDE
     MOVE 0 TO L-CALC L-TURN
     IF WS-CLASS = 7
         IF L-INPUT > 0
             MOVE 1 TO L-TURN
             MOVE 15 TO L-CALC
         END-IF
     ELSE
*>       calculateOutputSignal and shouldTurnOn (4.3)
         IF L-INPUT > 0 AND L-SIDE <= L-INPUT
             MOVE L-INPUT TO L-CALC
             IF RL-S-MODE(L-STATE + 1) = 1
                 COMPUTE L-CALC = L-INPUT - L-SIDE
             END-IF
         END-IF
         IF L-INPUT > L-SIDE
             MOVE 1 TO L-TURN
         END-IF
         IF L-INPUT > 0 AND L-INPUT = L-SIDE AND RL-S-MODE(L-STATE + 1) = 0
             MOVE 1 TO L-TURN
         END-IF
     END-IF
*>   shouldPrioritize (2.2 item 6): the cell behind is a diode that does not face away from this one
     MOVE 0 TO L-PRIO
     CALL "RS1-OPP" USING WS-F WS-OPP
     CALL "RS1-STEP" USING WS-OPP WS-DX WS-DY WS-DZ
     COMPUTE WS-NX = L-X + WS-DX
     COMPUTE WS-NZ = L-Z + WS-DZ
     CALL "RL-LOOK" USING L-DIM WS-NX L-Y WS-NZ WS-STATE WS-NCLASS WS-COND
     IF (WS-NCLASS = 7 OR WS-NCLASS = 8) AND RL-S-DIR(WS-STATE + 1) NOT = WS-OPP
         MOVE 1 TO L-PRIO
     END-IF
     GOBACK.
 END PROGRAM RL-DIODE-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DIODE-TICK RECURSIVE.
*> USING dimension row, x, y, z, state, block: the scheduled tick of a repeater (30-2 section 2.4) or a comparator (refreshOutputState, 4.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 01 WS-NAME-POWERED        PIC X(16) VALUE "powered".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-FALSE               PIC X(16) VALUE "false".
 LOCAL-STORAGE SECTION.
 01 LS-INPUT               BINARY-LONG.
 01 LS-SIDE                BINARY-LONG.
 01 LS-CALC                BINARY-LONG.
 01 LS-TURN                BINARY-LONG.
 01 LS-PRIO                BINARY-LONG.
 01 LS-ON                  BINARY-LONG.
 01 LS-OLD-OUT             BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-FLAGS               BINARY-LONG VALUE 2.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-DELAY               BINARY-LONG.
 01 LS-VERY-HIGH           BINARY-LONG VALUE -2.
 01 LS-FACING              BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-BLOCK.
     MOVE RL-CLASS(L-BLOCK + 1) TO LS-CLASS
     MOVE RL-S-ON(L-STATE + 1) TO LS-ON
     MOVE RL-S-DIR(L-STATE + 1) TO LS-FACING
     CALL "RL-DIODE-EVAL" USING L-DIM L-X L-Y L-Z L-STATE LS-INPUT LS-SIDE LS-CALC LS-TURN LS-PRIO
     IF LS-CLASS = 7
*>       a locked repeater ignores the tick (3.4); else the powered bit follows the input (2.4)
         IF LS-SIDE > 0
             GOBACK
         END-IF
         IF LS-ON = 1 AND LS-TURN = 0
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-POWERED WS-FALSE LS-NEW LS-OLD
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         END-IF
         IF LS-ON = 0
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-POWERED WS-TRUE LS-NEW LS-OLD
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             IF LS-TURN = 0
                 COMPUTE LS-DELAY = RL-S-DELAY(L-STATE + 1) * 2
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE L-BLOCK L-X L-Y L-Z LS-DELAY LS-VERY-HIGH LS-RESULT
             END-IF
         END-IF
     ELSE
*>       refreshOutputState: store the output; a subtract comparator whose value did not change stops
         CALL "RL-CMP-GET" USING L-DIM L-X L-Y L-Z LS-OLD-OUT
         CALL "RL-CMP-SET" USING L-DIM L-X L-Y L-Z LS-CALC
         IF LS-OLD-OUT = LS-CALC AND RL-S-MODE(L-STATE + 1) = 1
             GOBACK
         END-IF
         IF LS-ON = 1 AND LS-TURN = 0
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-POWERED WS-FALSE LS-NEW LS-OLD
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         END-IF
         IF LS-ON = 0 AND LS-TURN = 1
             CALL "SW-SET-PROP" USING L-STATE WS-NAME-POWERED WS-TRUE LS-NEW LS-OLD
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         END-IF
         CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-FACING L-BLOCK
     END-IF
     GOBACK.
 END PROGRAM RL-DIODE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DIODE-HOOK RECURSIVE.
*> USING kind, dimension row, x, y, z, state, a, b, out state: the hooks of the repeater and the comparator (30-2 sections 2 to 4): the front is told on place and removal, the tick of a
*> neighbour change, setPlacedBy's tick, the repeater lock through the shape update, and the scheduled tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-NAME-LOCKED         PIC X(16) VALUE "locked".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-FALSE               PIC X(16) VALUE "false".
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-F                   BINARY-LONG.
 01 LS-INPUT               BINARY-LONG.
 01 LS-SIDE                BINARY-LONG.
 01 LS-CALC                BINARY-LONG.
 01 LS-TURN                BINARY-LONG.
 01 LS-PRIO                BINARY-LONG.
 01 LS-ON                  BINARY-LONG.
 01 LS-OLD-OUT             BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-DELAY               BINARY-LONG.
 01 LS-PRIORITY            BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-OLD-BLOCK           BINARY-LONG.
 01 LS-AXIS-D              BINARY-LONG.
 01 LS-AXIS-F              BINARY-LONG.
 01 LS-LOCKED-NOW          BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     MOVE RL-S-DIR(L-STATE + 1) TO LS-F
     MOVE RL-S-ON(L-STATE + 1) TO LS-ON
     EVALUATE L-KIND
         WHEN 1
             CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-F LS-BLOCK
*>           setPlacedBy: a diode placed on a live input ticks one tick later; a new comparator has no output yet
             MOVE CB-S-BLOCK(L-A + 1) TO LS-OLD-BLOCK
             IF LS-OLD-BLOCK NOT = LS-BLOCK
                 IF LS-CLASS = 8
                     CALL "RL-CMP-SET" USING L-DIM L-X L-Y L-Z LS-ZERO
                 END-IF
                 CALL "RL-DIODE-EVAL" USING L-DIM L-X L-Y L-Z L-STATE LS-INPUT LS-SIDE LS-CALC LS-TURN LS-PRIO
                 IF LS-TURN = 1
                     MOVE 1 TO LS-DELAY
                     MOVE 0 TO LS-PRIORITY
                     CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
                 END-IF
             END-IF
         WHEN 2
             IF L-B = 0
                 CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-F LS-BLOCK
             END-IF
         WHEN 3
             CALL "RL-DIODE-EVAL" USING L-DIM L-X L-Y L-Z L-STATE LS-INPUT LS-SIDE LS-CALC LS-TURN LS-PRIO
             IF LS-CLASS = 7
*>               checkTickOnNeighbor (2.3): not when locked or when nothing would change
                 IF LS-SIDE = 0 AND LS-ON NOT = LS-TURN
                     MOVE -1 TO LS-PRIORITY
                     COMPUTE LS-DELAY = RL-S-DELAY(L-STATE + 1) * 2
                     IF LS-PRIO = 1
                         MOVE -3 TO LS-PRIORITY
                     END-IF
                     IF LS-PRIO = 0 AND LS-ON = 1
                         MOVE -2 TO LS-PRIORITY
                     END-IF
                     CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
                 END-IF
             ELSE
*>               the comparator (4.4): a tick when the output or the powered bit would change
                 CALL "RL-CMP-GET" USING L-DIM L-X L-Y L-Z LS-OLD-OUT
                 IF LS-CALC NOT = LS-OLD-OUT OR LS-ON NOT = LS-TURN
                     MOVE 2 TO LS-DELAY
                     MOVE 0 TO LS-PRIORITY
                     IF LS-PRIO = 1
                         MOVE -1 TO LS-PRIORITY
                     END-IF
                     CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
                 END-IF
             END-IF
         WHEN 4
*>           the repeater lock (3.5 step 2): a side neighbour changed, the locked property follows the side diodes
             IF LS-CLASS = 7
                 MOVE 0 TO LS-AXIS-D LS-AXIS-F
                 IF L-A = 2 OR L-A = 3
                     MOVE 1 TO LS-AXIS-D
                 END-IF
                 IF L-A = 4 OR L-A = 5
                     MOVE 2 TO LS-AXIS-D
                 END-IF
                 IF LS-F = 2 OR LS-F = 3
                     MOVE 1 TO LS-AXIS-F
                 ELSE
                     MOVE 2 TO LS-AXIS-F
                 END-IF
                 IF LS-AXIS-D NOT = LS-AXIS-F
                     CALL "RL-DIODE-EVAL" USING L-DIM L-X L-Y L-Z L-STATE LS-INPUT LS-SIDE LS-CALC LS-TURN LS-PRIO
                     IF LS-SIDE > 0
                         CALL "SW-SET-PROP" USING L-STATE WS-NAME-LOCKED WS-TRUE L-OUT LS-OLD
                     ELSE
                         CALL "SW-SET-PROP" USING L-STATE WS-NAME-LOCKED WS-FALSE L-OUT LS-OLD
                     END-IF
                 END-IF
             END-IF
         WHEN 7
             CALL "RL-DIODE-TICK" USING L-DIM L-X L-Y L-Z L-STATE LS-BLOCK
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-DIODE-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-CORNER-CHECK RECURSIVE.
*> USING dimension row, x, y, z: checkCornerChangeAt (30-1 section 5.5): a wire there is told (updateNeighborsAt) at its own position and at each of its six neighbours.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "RL-LOOK" USING L-DIM L-X L-Y L-Z LS-STATE LS-CLASS LS-COND
     IF LS-CLASS NOT = 1
         GOBACK
     END-IF
     CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z RL-WIRE
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NY = L-Y + LS-DY
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
     END-PERFORM
     GOBACK.
 END PROGRAM RL-CORNER-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-WIRE-CORNERS RECURSIVE.
*> USING dimension row, x, y, z: updateNeighborsOfNeighboringWires (30-1 section 5.5): the four horizontal cells, then the cell above a conductor or below a non-conductor beside the wire.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-ORDER               PIC X(4) VALUE "2534".
 01 LS-DIGIT               PIC 9.
 01 LS-I                   BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-QY                  BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-COND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-ORDER(LS-I:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-D
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "RL-CORNER-CHECK" USING L-DIM LS-NX L-Y LS-NZ
     END-PERFORM
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-ORDER(LS-I:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-D
         CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
         COMPUTE LS-NX = L-X + LS-DX
         COMPUTE LS-NZ = L-Z + LS-DZ
         CALL "RL-LOOK" USING L-DIM LS-NX L-Y LS-NZ LS-STATE LS-CLASS LS-COND
         COMPUTE LS-QY = L-Y - 1
         IF LS-COND = 1
             COMPUTE LS-QY = L-Y + 1
         END-IF
         CALL "RL-CORNER-CHECK" USING L-DIM LS-NX LS-QY LS-NZ
     END-PERFORM
     GOBACK.
 END PROGRAM RL-WIRE-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-WIRE-HOOK RECURSIVE.
*> USING kind, dimension row, x, y, z, state, a, b: the hooks of redstone wire (30-1 section 5.5): onPlace, removal and neighborChanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-OLD-BLOCK           BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B.
     EVALUATE L-KIND
         WHEN 1
*>           onPlace (5.5): nothing when the old state is the same block
             MOVE CB-S-BLOCK(L-A + 1) TO LS-OLD-BLOCK
             IF LS-OLD-BLOCK NOT = RL-WIRE
                 CALL "REDSTONE-EVALUATE" USING L-DIM L-X L-Y L-Z L-STATE
                 PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 1
                     CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
                     COMPUTE LS-NX = L-X + LS-DX
                     COMPUTE LS-NY = L-Y + LS-DY
                     COMPUTE LS-NZ = L-Z + LS-DZ
                     CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
                 END-PERFORM
                 CALL "RL-WIRE-CORNERS" USING L-DIM L-X L-Y L-Z
             END-IF
         WHEN 2
*>           affectNeighborsAfterRemoval (5.5): every neighbour is told, the neighbouring wires follow (not for a piston move)
             IF L-B = 0
                 PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5
                     CALL "RS1-STEP" USING LS-D LS-DX LS-DY LS-DZ
                     COMPUTE LS-NX = L-X + LS-DX
                     COMPUTE LS-NY = L-Y + LS-DY
                     COMPUTE LS-NZ = L-Z + LS-DZ
                     CALL "BU-NEIGHBORS-AT" USING L-DIM LS-NX LS-NY LS-NZ RL-WIRE
                 END-PERFORM
                 CALL "RL-WIRE-CORNERS" USING L-DIM L-X L-Y L-Z
             END-IF
         WHEN 3
             CALL "REDSTONE-EVALUATE" USING L-DIM L-X L-Y L-Z L-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-WIRE-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     IF L-KIND NOT = 1 AND L-KIND NOT = 2 AND L-KIND NOT = 3 AND L-KIND NOT = 4 AND L-KIND NOT = 7 AND L-KIND NOT = 10
         GOBACK
     END-IF
     CALL "REDSTONE-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     EVALUATE LS-CLASS
         WHEN 1
             CALL "RL-WIRE-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
         WHEN 3
         WHEN 4
             CALL "RL-TORCH-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
         WHEN 5
         WHEN 6
*>           a powered lever or button removed (not moved) tells its neighbours (30-5 sections 2.3 and 3.7)
             IF L-KIND = 2 AND L-B = 0 AND RL-S-ON(L-STATE + 1) = 1
                 CALL "REDSTONE-SWITCH-NOTIFY" USING L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 7
         WHEN 8
             CALL "RL-DIODE-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
         WHEN 11
             IF L-KIND = 3 OR L-KIND = 7
                 CALL "RL-LAMP-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 9
         WHEN 12
         WHEN 13
             IF L-KIND = 3
                 CALL "RL-OPEN-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 14
             IF L-KIND = 1 OR L-KIND = 3
                 CALL "RL-TNT-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 15
             IF L-KIND = 1 OR L-KIND = 3
                 CALL "RL-BULB-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 10
             IF L-KIND = 1 OR L-KIND = 3
                 CALL "RL-HOPPER-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 29
         WHEN 30
             IF L-KIND = 3 OR L-KIND = 7
                 CALL "RL-DISP-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 16
             IF L-KIND = 3 OR L-KIND = 4 OR L-KIND = 10
                 CALL "RL-NOTE-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
             END-IF
         WHEN 24
             IF L-KIND = 1 OR L-KIND = 2 OR L-KIND = 7
                 CALL "RL-HOOK-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
             END-IF
         WHEN 25
             CALL "RL-TRIP-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
         WHEN 21
             IF L-KIND = 1 OR L-KIND = 7
                 CALL "RL-TARGET-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 17
             CALL "RL-OBS-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
         WHEN 18
         WHEN 19
             CALL "RL-PLATE-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
         WHEN 26
         WHEN 27
             IF L-KIND = 7
                 CALL "SCULK-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B
             END-IF
         WHEN 22
             IF L-KIND = 1 OR L-KIND = 2 OR L-KIND = 7
                 CALL "RL-ROD-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A
             END-IF
         WHEN 23
             IF L-KIND = 1 OR L-KIND = 7
                 CALL "RL-DETECTOR-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE
             END-IF
         WHEN 31
         WHEN 32
         WHEN 33
             CALL "PST-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM REDSTONE-HOOK.
