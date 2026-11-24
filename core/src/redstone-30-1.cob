*> Redstone part 1 (docs/protocol/30-redstone-1-model-signal-and-wire.md) as programs of plain numbers (RS1- prefix): the decisions of each section take the facts the caller read
*> from the level (signal values, flags, the random draws) and return the decision, like the 29b helpers; nothing here is wired into the block-update hooks.
*> Directions are the data values of Direction.values(): 0 down, 1 up, 2 north, 3 south, 4 west, 5 east. Booleans are 0 and 1. Sides of wire: 0 up, 1 side, 2 none.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONSTANTS.
*> USING SIGNAL_MIN, SIGNAL_MAX, SIGNAL_NONE, BITS, MASK out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-NONE                 BINARY-LONG.
 01 L-BITS                 BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN L-MAX L-NONE L-BITS L-MASK.
     MOVE 0 TO L-MIN L-NONE
     MOVE 15 TO L-MAX L-MASK
     MOVE 4 TO L-BITS
     GOBACK.
 END PROGRAM RS1-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-IS-POWERED.
*> USING the signal, the kind of test (0 greater than 0, 1 equals 15), result out (section 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-KIND L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-KIND = 0 AND L-SIGNAL > 0
         MOVE 1 TO L-RESULT
     END-IF
     IF L-KIND = 1 AND L-SIGNAL = 15
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-IS-POWERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BURNOUT-CONST.
*> USING RECENT_TOGGLE_TIMER, MAX_RECENT_TOGGLES, RESTART_DELAY out (sections 1 and 8.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WINDOW               BINARY-LONG.
 01 L-TOGGLES              BINARY-LONG.
 01 L-RESTART              BINARY-LONG.
 PROCEDURE DIVISION USING L-WINDOW L-TOGGLES L-RESTART.
     MOVE 60 TO L-WINDOW
     MOVE 8 TO L-TOGGLES
     MOVE 160 TO L-RESTART
     GOBACK.
 END PROGRAM RS1-BURNOUT-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-OPP.
*> USING direction, its opposite out (section 2.2): the data values pair up as 0 1, 2 3, 4 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-OPP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-OPP.
     COMPUTE L-OPP = L-D + 1 - 2 * FUNCTION MOD(L-D, 2)
     GOBACK.
 END PROGRAM RS1-OPP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-STEP.
*> USING direction, dx, dy, dz out (sections 2.2, 2.3): the offset of the neighbour in that direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-DX L-DY L-DZ.
     EVALUATE L-D
         WHEN 0
             MOVE 0 TO L-DX
             MOVE -1 TO L-DY
             MOVE 0 TO L-DZ
         WHEN 1
             MOVE 0 TO L-DX
             MOVE 1 TO L-DY
             MOVE 0 TO L-DZ
         WHEN 2
             MOVE 0 TO L-DX
             MOVE 0 TO L-DY
             MOVE -1 TO L-DZ
         WHEN 3
             MOVE 0 TO L-DX
             MOVE 0 TO L-DY
             MOVE 1 TO L-DZ
         WHEN 4
             MOVE -1 TO L-DX
             MOVE 0 TO L-DY
             MOVE 0 TO L-DZ
         WHEN 5
             MOVE 1 TO L-DX
             MOVE 0 TO L-DY
             MOVE 0 TO L-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIR-ORDER.
*> USING the order (1 Direction.values(), 2 neighbour-changed W E D U N S, 3 shape update W E N S D U, 4 Plane.HORIZONTAL, 5 Plane.VERTICAL), the index from 1, direction out (sections 2.3, 2.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.

 01 ORD-V                  PIC X(30) VALUE "012345450123452301253400100000".
 01 ORD-T REDEFINES ORD-V.
    05 ORD-ROW             OCCURS 5 TIMES.
       10 ORD-D            PIC 9 OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-INDEX L-DIR.
     MOVE ORD-D(L-KIND, L-INDEX) TO L-DIR
     GOBACK.
 END PROGRAM RS1-DIR-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HOOK-DEFAULTS.
*> USING isSignalSource, ownSignal, getDirectSignal, hasAnalogOutputSignal, getAnalogOutputSignal of the base block out (section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 01 L-HASANALOG            BINARY-LONG.
 01 L-ANALOG               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-OWN L-DIRECT L-HASANALOG L-ANALOG.
     MOVE 0 TO L-SOURCE L-OWN L-DIRECT L-HASANALOG L-ANALOG
     GOBACK.
 END PROGRAM RS1-HOOK-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HOOK-SIGNAL.
*> USING ownSignal, getSignal out (section 2.1): the default getSignal is ownSignal in every direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-OWN L-SIGNAL.
     MOVE L-OWN TO L-SIGNAL
     GOBACK.
 END PROGRAM RS1-HOOK-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-CONNECT-DEFAULT.
*> USING isSignalSource, direction is not null, connects out (section 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-HASDIR               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-HASDIR L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SOURCE = 1 AND L-HASDIR = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-CONNECT-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DIRECT-SIGNAL-TO.
*> USING the direct signals of the neighbours below, above, north, south, west, east, the maximum out, the neighbours asked out (section 2.3 getDirectSignalTo): it stops at once at 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VG.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-S5                   BINARY-LONG.
 01 L-S6                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-VISITED              BINARY-LONG.
 PROCEDURE DIVISION USING L-S1 L-S2 L-S3 L-S4 L-S5 L-S6 L-RESULT L-VISITED.
     MOVE L-S1 TO WS-V(1)
     MOVE L-S2 TO WS-V(2)
     MOVE L-S3 TO WS-V(3)
     MOVE L-S4 TO WS-V(4)
     MOVE L-S5 TO WS-V(5)
     MOVE L-S6 TO WS-V(6)
     MOVE 0 TO L-RESULT L-VISITED WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-DONE = 1
         ADD 1 TO L-VISITED
         IF WS-V(WS-I) > L-RESULT
             MOVE WS-V(WS-I) TO L-RESULT
         END-IF
         IF L-RESULT >= 15
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-DIRECT-SIGNAL-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-LEVEL-SIGNAL.
*> USING the weak signal of the state, it is a conductor, getDirectSignalTo, getSignal out (section 2.3): a conductor gives the stronger of the two.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-CONDUCTOR L-DIRECT L-RESULT.
     MOVE L-S TO L-RESULT
     IF L-CONDUCTOR = 1 AND L-DIRECT > L-RESULT
         MOVE L-DIRECT TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-LEVEL-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HAS-SIGNAL.
*> USING getSignal, hasSignal out (section 2.3): greater than 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-S                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-S > 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-HAS-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BEST-NEIGHBOR.
*> USING getSignal(pos + d, d) for d in the order D U N S W E, the best out, the neighbours asked out (section 2.3 getBestNeighborSignal): it returns at once at 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VG.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-S5                   BINARY-LONG.
 01 L-S6                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-VISITED              BINARY-LONG.
 PROCEDURE DIVISION USING L-S1 L-S2 L-S3 L-S4 L-S5 L-S6 L-RESULT L-VISITED.
     MOVE L-S1 TO WS-V(1)
     MOVE L-S2 TO WS-V(2)
     MOVE L-S3 TO WS-V(3)
     MOVE L-S4 TO WS-V(4)
     MOVE L-S5 TO WS-V(5)
     MOVE L-S6 TO WS-V(6)
     MOVE 0 TO L-RESULT L-VISITED WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-DONE = 1
         ADD 1 TO L-VISITED
         IF WS-V(WS-I) > L-RESULT
             MOVE WS-V(WS-I) TO L-RESULT
         END-IF
         IF L-RESULT >= 15
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-BEST-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-HAS-NEIGHBOR.
*> USING getSignal(pos + d, d) for d in the order D U N S W E, result out, the index (from 1) of the first hit out, 0 for none (section 2.3 hasNeighborSignal).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VG.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-S1                   BINARY-LONG.
 01 L-S2                   BINARY-LONG.
 01 L-S3                   BINARY-LONG.
 01 L-S4                   BINARY-LONG.
 01 L-S5                   BINARY-LONG.
 01 L-S6                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-S1 L-S2 L-S3 L-S4 L-S5 L-S6 L-RESULT L-FIRST.
     MOVE L-S1 TO WS-V(1)
     MOVE L-S2 TO WS-V(2)
     MOVE L-S3 TO WS-V(3)
     MOVE L-S4 TO WS-V(4)
     MOVE L-S5 TO WS-V(5)
     MOVE L-S6 TO WS-V(6)
     MOVE 0 TO L-RESULT L-FIRST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR L-RESULT = 1
         IF WS-V(WS-I) > 0
             MOVE 1 TO L-RESULT
             MOVE WS-I TO L-FIRST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-HAS-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BEST-OWN.
*> USING getBestNeighborSignal, the state at the position is a signal source, its own signal, result out (section 2.3 getBestOwnOrNeighbourSignal).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BEST                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-BEST L-SOURCE L-OWN L-RESULT.
     MOVE L-BEST TO L-RESULT
     IF L-SOURCE = 1 AND L-OWN > L-RESULT
         MOVE L-OWN TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-BEST-OWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONTROL-INPUT.
*> USING onlyDiodes, the state is a diode, is redstone_block, is redstone wire, the wire power, is a signal source, getDirectSignal(pos, d), result out (section 2.3 getControlInputSignal).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ONLY                 BINARY-LONG.
 01 L-DIODE                BINARY-LONG.
 01 L-RBLOCK               BINARY-LONG.
 01 L-WIRE                 BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ONLY L-DIODE L-RBLOCK L-WIRE L-POWER L-SOURCE L-DIRECT L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-ONLY = 1 AND L-DIODE = 1
             MOVE L-DIRECT TO L-RESULT
         WHEN L-ONLY = 1
             MOVE 0 TO L-RESULT
         WHEN L-RBLOCK = 1
             MOVE 15 TO L-RESULT
         WHEN L-WIRE = 1
             MOVE L-POWER TO L-RESULT
         WHEN L-SOURCE = 1
             MOVE L-DIRECT TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-CONTROL-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONDUCTOR-KIND.
*> USING the block name (PIC X(40)), kind out (section 2.4): 1 the predicate is never, 2 always, 0 the default (the collision shape is a full block). Families: every stained glass colour
*> (name ends with _stained_glass), the copper grate and copper bulb weathering stages with or without waxed_ (waxed reuse of the lambdas is inferred in the document, Open question 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CK-T.
 05 FILLER PIC X(41) VALUE "1oak_leaves".
 05 FILLER PIC X(41) VALUE "1spruce_leaves".
 05 FILLER PIC X(41) VALUE "1birch_leaves".
 05 FILLER PIC X(41) VALUE "1jungle_leaves".
 05 FILLER PIC X(41) VALUE "1acacia_leaves".
 05 FILLER PIC X(41) VALUE "1dark_oak_leaves".
 05 FILLER PIC X(41) VALUE "1mangrove_leaves".
 05 FILLER PIC X(41) VALUE "1red_poplar_leaves".
 05 FILLER PIC X(41) VALUE "1orange_poplar_leaves".
 05 FILLER PIC X(41) VALUE "1yellow_poplar_leaves".
 05 FILLER PIC X(41) VALUE "1azalea_leaves".
 05 FILLER PIC X(41) VALUE "1flowering_azalea_leaves".
 05 FILLER PIC X(41) VALUE "1cherry_leaves".
 05 FILLER PIC X(41) VALUE "1pale_oak_leaves".
 05 FILLER PIC X(41) VALUE "1piston".
 05 FILLER PIC X(41) VALUE "1sticky_piston".
 05 FILLER PIC X(41) VALUE "1glass".
 05 FILLER PIC X(41) VALUE "1moving_piston".
 05 FILLER PIC X(41) VALUE "1tnt".
 05 FILLER PIC X(41) VALUE "1ice".
 05 FILLER PIC X(41) VALUE "1glowstone".
 05 FILLER PIC X(41) VALUE "1beacon".
 05 FILLER PIC X(41) VALUE "1redstone_block".
 05 FILLER PIC X(41) VALUE "1sea_lantern".
 05 FILLER PIC X(41) VALUE "1chorus_flower".
 05 FILLER PIC X(41) VALUE "1frosted_ice".
 05 FILLER PIC X(41) VALUE "1observer".
 05 FILLER PIC X(41) VALUE "1bamboo".
 05 FILLER PIC X(41) VALUE "1scaffolding".
 05 FILLER PIC X(41) VALUE "1tinted_glass".
 05 FILLER PIC X(41) VALUE "1powder_snow".
 05 FILLER PIC X(41) VALUE "1pointed_dripstone".
 05 FILLER PIC X(41) VALUE "1sulfur_spike".
 05 FILLER PIC X(41) VALUE "2soul_sand".
 05 FILLER PIC X(41) VALUE "2mud".
 01 CK-R REDEFINES CK-T.
    05 CK-ROW              OCCURS 35 TIMES.
       10 CK-KIND          PIC 9.
       10 CK-NAME          PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-B                   PIC X(40).
 01 WS-C                   PIC X(40).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-KIND.
     MOVE 0 TO L-KIND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         IF CK-NAME(WS-I) = L-NAME
             MOVE CK-KIND(WS-I) TO L-KIND
         END-IF
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-NAME TRAILING))
     IF WS-LEN >= 15
         COMPUTE WS-OFF = WS-LEN - 13
         IF L-NAME(WS-OFF:14) = "_stained_glass"
             MOVE 1 TO L-KIND
         END-IF
     END-IF
     MOVE L-NAME TO WS-B
     IF WS-B(1:6) = "waxed_"
         MOVE WS-B(7:34) TO WS-C
         MOVE WS-C TO WS-B
     END-IF
     EVALUATE TRUE
         WHEN WS-B(1:8) = "exposed_"
             MOVE WS-B(9:32) TO WS-C
         WHEN WS-B(1:10) = "weathered_"
             MOVE WS-B(11:30) TO WS-C
         WHEN WS-B(1:9) = "oxidized_"
             MOVE WS-B(10:31) TO WS-C
         WHEN OTHER
             MOVE WS-B TO WS-C
     END-EVALUATE
     IF WS-C = "copper_grate" OR WS-C = "copper_bulb"
         MOVE 1 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM RS1-CONDUCTOR-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CENSUS.
*> USING the hook (1 isSignalSource and ownSignal, 2 getSignal, 3 getDirectSignal, 4 hasAnalogOutputSignal and getAnalogOutputSignal, 5 shouldRedstoneWireConnectTo), the class name
*> (PIC X(40)), the owning part out (section 2.5): -1 when the class does not declare the hook; 0 for the analog hooks, whose values belong to the family parts; 31 for TestBlock (31-6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CN-T.
 05 FILLER PIC X(43) VALUE "105BasePressurePlateBlock".
 05 FILLER PIC X(43) VALUE "105ButtonBlock".
 05 FILLER PIC X(43) VALUE "105DaylightDetectorBlock".
 05 FILLER PIC X(43) VALUE "106DetectorRailBlock".
 05 FILLER PIC X(43) VALUE "102DiodeBlock".
 05 FILLER PIC X(43) VALUE "105JukeboxBlock".
 05 FILLER PIC X(43) VALUE "105LecternBlock".
 05 FILLER PIC X(43) VALUE "105LeverBlock".
 05 FILLER PIC X(43) VALUE "105LightningRodBlock".
 05 FILLER PIC X(43) VALUE "102ObserverBlock".
 05 FILLER PIC X(43) VALUE "101PoweredBlock".
 05 FILLER PIC X(43) VALUE "101RedstoneTorchBlock".
 05 FILLER PIC X(43) VALUE "101RedstoneWireBlock".
 05 FILLER PIC X(43) VALUE "108SculkSensorBlock".
 05 FILLER PIC X(43) VALUE "105TargetBlock".
 05 FILLER PIC X(43) VALUE "105TrappedChestBlock".
 05 FILLER PIC X(43) VALUE "108TripWireHookBlock".
 05 FILLER PIC X(43) VALUE "131TestBlock".
 05 FILLER PIC X(43) VALUE "208CalibratedSculkSensorBlock".
 05 FILLER PIC X(43) VALUE "202DiodeBlock".
 05 FILLER PIC X(43) VALUE "202ObserverBlock".
 05 FILLER PIC X(43) VALUE "201RedstoneTorchBlock".
 05 FILLER PIC X(43) VALUE "201RedstoneWallTorchBlock".
 05 FILLER PIC X(43) VALUE "201RedstoneWireBlock".
 05 FILLER PIC X(43) VALUE "305BasePressurePlateBlock".
 05 FILLER PIC X(43) VALUE "305ButtonBlock".
 05 FILLER PIC X(43) VALUE "306DetectorRailBlock".
 05 FILLER PIC X(43) VALUE "302DiodeBlock".
 05 FILLER PIC X(43) VALUE "305LecternBlock".
 05 FILLER PIC X(43) VALUE "305LeverBlock".
 05 FILLER PIC X(43) VALUE "305LightningRodBlock".
 05 FILLER PIC X(43) VALUE "302ObserverBlock".
 05 FILLER PIC X(43) VALUE "301RedstoneTorchBlock".
 05 FILLER PIC X(43) VALUE "301RedstoneWireBlock".
 05 FILLER PIC X(43) VALUE "308SculkSensorBlock".
 05 FILLER PIC X(43) VALUE "305TrappedChestBlock".
 05 FILLER PIC X(43) VALUE "308TripWireHookBlock".
 05 FILLER PIC X(43) VALUE "400AbstractCauldronBlock".
 05 FILLER PIC X(43) VALUE "400AbstractFurnaceBlock".
 05 FILLER PIC X(43) VALUE "400BarrelBlock".
 05 FILLER PIC X(43) VALUE "400BeehiveBlock".
 05 FILLER PIC X(43) VALUE "400BrewingStandBlock".
 05 FILLER PIC X(43) VALUE "400CakeBlock".
 05 FILLER PIC X(43) VALUE "400CandleCakeBlock".
 05 FILLER PIC X(43) VALUE "400ChestBlock".
 05 FILLER PIC X(43) VALUE "400ChiseledBookShelfBlock".
 05 FILLER PIC X(43) VALUE "400CommandBlock".
 05 FILLER PIC X(43) VALUE "400ComposterBlock".
 05 FILLER PIC X(43) VALUE "400CopperBulbBlock".
 05 FILLER PIC X(43) VALUE "400CopperGolemStatueBlock".
 05 FILLER PIC X(43) VALUE "400CrafterBlock".
 05 FILLER PIC X(43) VALUE "400CreakingHeartBlock".
 05 FILLER PIC X(43) VALUE "400DecoratedPotBlock".
 05 FILLER PIC X(43) VALUE "400DetectorRailBlock".
 05 FILLER PIC X(43) VALUE "400DispenserBlock".
 05 FILLER PIC X(43) VALUE "400EndPortalFrameBlock".
 05 FILLER PIC X(43) VALUE "400HopperBlock".
 05 FILLER PIC X(43) VALUE "400JukeboxBlock".
 05 FILLER PIC X(43) VALUE "400LecternBlock".
 05 FILLER PIC X(43) VALUE "400RespawnAnchorBlock".
 05 FILLER PIC X(43) VALUE "400SculkSensorBlock".
 05 FILLER PIC X(43) VALUE "400ShelfBlock".
 05 FILLER PIC X(43) VALUE "400ShulkerBoxBlock".
 05 FILLER PIC X(43) VALUE "502ObserverBlock".
 05 FILLER PIC X(43) VALUE "502RepeaterBlock".
 05 FILLER PIC X(43) VALUE "501RedstoneWireBlock".
 01 CN-R REDEFINES CN-T.
    05 CN-ROW              OCCURS 66 TIMES.
       10 CN-HOOK          PIC 9.
       10 CN-OWNER         PIC 99.
       10 CN-NAME          PIC X(40).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-HOOK L-NAME L-OWNER.
     MOVE -1 TO L-OWNER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 66
         IF CN-HOOK(WS-I) = L-HOOK AND CN-NAME(WS-I) = L-NAME
             MOVE CN-OWNER(WS-I) TO L-OWNER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-CENSUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-EXPERIMENTAL.
*> USING the redstone_experiments flag is enabled, the experimental evaluator is used out (section 2.7): the default flags (vanilla only) leave it off.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-RESULT.
     MOVE L-FLAG TO L-RESULT
     GOBACK.
 END PROGRAM RS1-EXPERIMENTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-GAME-TICKS.
*> USING redstone ticks, game ticks out (section 3): one redstone tick is 2 game ticks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REDSTONE             BINARY-LONG.
 01 L-GAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REDSTONE L-GAME.
     COMPUTE L-GAME = 2 * L-REDSTONE
     GOBACK.
 END PROGRAM RS1-GAME-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DUE-TICK.
*> USING the game time T and the delay, the game tick whose drain runs the tick out (section 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOW                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NOW L-DELAY L-DUE.
     COMPUTE L-DUE = L-NOW + L-DELAY
     GOBACK.
 END PROGRAM RS1-DUE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-SCHEDULE-NEW.
*> USING a tick for the same block at the same position is pending, a new tick is queued out (section 3: identity; the torch guard of 8.3 is the same shape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PENDING              BINARY-LONG.
 01 L-ADD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PENDING L-ADD.
     MOVE 1 TO L-ADD
     IF L-PENDING = 1
         MOVE 0 TO L-ADD
     END-IF
     GOBACK.
 END PROGRAM RS1-SCHEDULE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-PRIORITY-VALUE.
*> USING the index of the TickPriority (1 EXTREMELY_HIGH ... 4 NORMAL ... 7 EXTREMELY_LOW), its value out (section 3): -3 to 3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-VALUE.
     COMPUTE L-VALUE = L-INDEX - 4
     GOBACK.
 END PROGRAM RS1-PRIORITY-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TICK-BEFORE.
*> USING priority and sub-tick order of tick A and of tick B, 1 out when A runs first (section 3): lower priority first, then the order scheduled.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PA                   BINARY-LONG.
 01 L-SA                   BINARY-LONG.
 01 L-PB                   BINARY-LONG.
 01 L-SB                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-PA L-SA L-PB L-SB L-FIRST.
     MOVE 0 TO L-FIRST
     IF L-PA < L-PB OR (L-PA = L-PB AND L-SA < L-SB)
         MOVE 1 TO L-FIRST
     END-IF
     GOBACK.
 END PROGRAM RS1-TICK-BEFORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BLOCK-ROW.
*> USING the row (1 redstone_wire, 2 redstone_ore, 3 deepslate_redstone_ore, 4 redstone_torch, 5 redstone_wall_torch, 6 redstone_block), block id, first state id, state count out (section 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID L-FIRST L-COUNT.
     EVALUATE L-ROW
         WHEN 1
             MOVE 246 TO L-ID
             MOVE 5567 TO L-FIRST
             MOVE 1296 TO L-COUNT
         WHEN 2
             MOVE 320 TO L-ID
             MOVE 8551 TO L-FIRST
             MOVE 2 TO L-COUNT
         WHEN 3
             MOVE 321 TO L-ID
             MOVE 8553 TO L-FIRST
             MOVE 2 TO L-COUNT
         WHEN 4
             MOVE 322 TO L-ID
             MOVE 8555 TO L-FIRST
             MOVE 2 TO L-COUNT
         WHEN 5
             MOVE 323 TO L-ID
             MOVE 8557 TO L-FIRST
             MOVE 8 TO L-COUNT
         WHEN 6
             MOVE 439 TO L-ID
             MOVE 13078 TO L-FIRST
             MOVE 1 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-BLOCK-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-STATE.
*> USING the sides north, east, south, west (0 up, 1 side, 2 none), the power, the state id out (section 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-POWER L-ID.
     COMPUTE L-ID = 5567 + L-E * 432 + L-N * 144 + L-POWER * 9 + L-S * 3 + L-W
     GOBACK.
 END PROGRAM RS1-WIRE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-DECODE.
*> USING a wire state id, then north, east, south, west and the power out (section 4.3: the inverse of the index).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IDX                 BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-N L-E L-S L-W L-POWER.
     COMPUTE WS-IDX = L-ID - 5567
     DIVIDE WS-IDX BY 432 GIVING L-E REMAINDER WS-REM
     DIVIDE WS-REM BY 144 GIVING L-N REMAINDER WS-REM
     DIVIDE WS-REM BY 9 GIVING L-POWER REMAINDER WS-REM
     DIVIDE WS-REM BY 3 GIVING L-S REMAINDER L-W
     GOBACK.
 END PROGRAM RS1-WIRE-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-LIT-STATE.
*> USING the block (1 redstone_torch, 2 redstone_ore, 3 deepslate_redstone_ore), lit, state id out (section 4.3): lit is the first state.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-LIT L-ID.
     EVALUATE L-KIND
         WHEN 1
             MOVE 8555 TO L-ID
         WHEN 2
             MOVE 8551 TO L-ID
         WHEN 3
             MOVE 8553 TO L-ID
     END-EVALUATE
     IF L-LIT = 0
         ADD 1 TO L-ID
     END-IF
     GOBACK.
 END PROGRAM RS1-LIT-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WALL-TORCH-STATE.
*> USING facing (2 north, 3 south, 4 west, 5 east), lit, state id out (section 4.3): 8557 + facing index * 2 + (lit ? 0 : 1), the facing order north, south, west, east.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-LIT L-ID.
     COMPUTE L-ID = 8557 + (L-FACING - 2) * 2
     IF L-LIT = 0
         ADD 1 TO L-ID
     END-IF
     GOBACK.
 END PROGRAM RS1-WALL-TORCH-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-DELAY-ROW.
*> USING the row (1 torch re-check, 2 torch restart after burnout, 3 wire, 4 redstone block and ore), delay in game ticks (-1 for none), priority (0 NORMAL) out (section 4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DELAY L-PRIORITY.
     MOVE 0 TO L-PRIORITY
     EVALUATE L-ROW
         WHEN 1
             MOVE 2 TO L-DELAY
         WHEN 2
             MOVE 160 TO L-DELAY
         WHEN 3
             MOVE -1 TO L-DELAY
         WHEN 4
             MOVE -1 TO L-DELAY
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-DELAY-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-SIDE-CONNECTED.
*> USING a side of wire (0 up, 1 side, 2 none), connected out (section 5.1): isConnected is true unless none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIDE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIDE L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-SIDE = 2
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-SIDE-CONNECTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ALLOW-UP.
*> USING the block above P is a redstone conductor, allowUp out (section 5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COND L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-COND = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-ALLOW-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONNECTING-SIDE.
*> USING allowUp, N supports (trapdoor or canSurviveOn), shouldConnectTo(N.above, null), the face of N towards P is sturdy, shouldConnectTo(S, d), S is a conductor,
*> *> shouldConnectTo(N.below, null), the side out (0 up, 1 side, 2 none) (section 5.2 getConnectingSide).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALLOWUP              BINARY-LONG.
 01 L-SUPPORTS             BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-CONNECT              BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ALLOWUP L-SUPPORTS L-ABOVE L-STURDY L-CONNECT L-CONDUCTOR L-BELOW L-SIDE.
     MOVE 2 TO L-SIDE
     IF L-ALLOWUP = 1 AND L-SUPPORTS = 1 AND L-ABOVE = 1
         IF L-STURDY = 1
             MOVE 0 TO L-SIDE
         ELSE
             MOVE 1 TO L-SIDE
         END-IF
     ELSE
         IF L-CONNECT = 1 OR (L-CONDUCTOR = 0 AND L-BELOW = 1)
             MOVE 1 TO L-SIDE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CONNECTING-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-MISSING-CONNECTIONS.
*> USING the current north, east, south, west, then the freshly resolved four, the merged four out (section 5.2 getMissingConnections): connected sides stay.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-C1                   BINARY-LONG.
 01 L-C2                   BINARY-LONG.
 01 L-C3                   BINARY-LONG.
 01 L-C4                   BINARY-LONG.
 01 L-M1                   BINARY-LONG.
 01 L-M2                   BINARY-LONG.
 01 L-M3                   BINARY-LONG.
 01 L-M4                   BINARY-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-O3                   BINARY-LONG.
 01 L-O4                   BINARY-LONG.
 PROCEDURE DIVISION USING L-C1 L-C2 L-C3 L-C4 L-M1 L-M2 L-M3 L-M4 L-O1 L-O2 L-O3 L-O4.
     MOVE L-C1 TO L-O1
     MOVE L-C2 TO L-O2
     MOVE L-C3 TO L-O3
     MOVE L-C4 TO L-O4
     IF L-C1 = 2
         MOVE L-M1 TO L-O1
     END-IF
     IF L-C2 = 2
         MOVE L-M2 TO L-O2
     END-IF
     IF L-C3 = 2
         MOVE L-M3 TO L-O3
     END-IF
     IF L-C4 = 2
         MOVE L-M4 TO L-O4
     END-IF
     GOBACK.
 END PROGRAM RS1-MISSING-CONNECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-CONNECTION-STATE.
*> USING wasDot (the state had four none sides), the resolved north, east, south, west, the final four out (section 5.2 getConnectionState steps 3 and 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WASDOT               BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-OS                   BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WASDOT L-N L-E L-S L-W L-ON L-OE L-OS L-OW.
     MOVE L-N TO L-ON
     MOVE L-E TO L-OE
     MOVE L-S TO L-OS
     MOVE L-W TO L-OW
     MOVE 0 TO WS-N WS-E WS-S WS-W
     IF L-N NOT = 2
         MOVE 1 TO WS-N
     END-IF
     IF L-E NOT = 2
         MOVE 1 TO WS-E
     END-IF
     IF L-S NOT = 2
         MOVE 1 TO WS-S
     END-IF
     IF L-W NOT = 2
         MOVE 1 TO WS-W
     END-IF
     IF L-WASDOT = 0 OR WS-N + WS-E + WS-S + WS-W > 0
         IF WS-W = 0 AND WS-N = 0 AND WS-S = 0
             MOVE 1 TO L-OW
         END-IF
         IF WS-E = 0 AND WS-N = 0 AND WS-S = 0
             MOVE 1 TO L-OE
         END-IF
         IF WS-N = 0 AND WS-E = 0 AND WS-W = 0
             MOVE 1 TO L-ON
         END-IF
         IF WS-S = 0 AND WS-E = 0 AND WS-W = 0
             MOVE 1 TO L-OS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-CONNECTION-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-IS-DOT.
*> USING the four sides north, east, south, west, dot out (section 5.2 getConnectionState step 1): all four none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-N = 2 AND L-E = 2 AND L-S = 2 AND L-W = 2
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-IS-DOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-SURVIVE-ON.
*> USING the top face of the block below is sturdy, it is a hopper, canSurviveOn out (section 5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-HOPPER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-HOPPER L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-STURDY = 1 OR L-HOPPER = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-SURVIVE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-UPDATE-SHAPE.
*> USING the direction towards the changed neighbour, canSurviveOn(neighbour), getConnectingSide(d), the state side of d, the state is a cross, the action out (section 5.3 updateShape):
*> *> 0 air, 1 the state, 2 getConnectionState(state), 3 the state with d set to the side, 4 getConnectionState(cross with power and d = side).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-CANON                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-STATED               BINARY-LONG.
 01 L-CROSS                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-CANON L-SIDE L-STATED L-CROSS L-ACTION.
     EVALUATE TRUE
         WHEN L-D = 0 AND L-CANON = 1
             MOVE 1 TO L-ACTION
         WHEN L-D = 0
             MOVE 0 TO L-ACTION
         WHEN L-D = 1
             MOVE 2 TO L-ACTION
         WHEN OTHER
             MOVE 4 TO L-ACTION
             MOVE 0 TO WS-A WS-B
             IF L-SIDE NOT = 2
                 MOVE 1 TO WS-A
             END-IF
             IF L-STATED NOT = 2
                 MOVE 1 TO WS-B
             END-IF
             IF WS-A = WS-B AND L-CROSS = 0
                 MOVE 3 TO L-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-WIRE-UPDATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-INDIRECT.
*> USING the side of d in the state, the block at N is wire, the block at N.below is wire, the block at N.above is wire, then send below, send above out (section 5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIDE                 BINARY-LONG.
 01 L-NWIRE                BINARY-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-SENDB                BINARY-LONG.
 01 L-SENDA                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIDE L-NWIRE L-BELOW L-ABOVE L-SENDB L-SENDA.
     MOVE 0 TO L-SENDB L-SENDA
     IF L-SIDE NOT = 2 AND L-NWIRE = 0
         MOVE L-BELOW TO L-SENDB
         MOVE L-ABOVE TO L-SENDA
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-INDIRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-USE.
*> USING mayBuild, the state is a cross, the state is a dot, the resolved new state differs, result out (0 PASS, 1 SUCCESS) (section 5.3 use).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAYBUILD             BINARY-LONG.
 01 L-CROSS                BINARY-LONG.
 01 L-DOT                  BINARY-LONG.
 01 L-DIFF                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MAYBUILD L-CROSS L-DOT L-DIFF L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-MAYBUILD = 1 AND (L-CROSS = 1 OR L-DOT = 1) AND L-DIFF = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-USE-TEMPLATE.
*> USING the state is a cross, the template out (0 the default state, 1 the cross state) (section 5.3 use).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CROSS                BINARY-LONG.
 01 L-TEMPLATE             BINARY-LONG.
 PROCEDURE DIVISION USING L-CROSS L-TEMPLATE.
     MOVE 1 TO L-TEMPLATE
     IF L-CROSS = 1
         MOVE 0 TO L-TEMPLATE
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-USE-TEMPLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-SHAPE-NOTIFY.
*> USING connected before, connected after, the state at N is a conductor, notify out (section 5.3 updatesOnShapeChange).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-COND                 BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-NEW L-COND L-NOTIFY.
     MOVE 0 TO L-NOTIFY
     IF L-OLD NOT = L-NEW AND L-COND = 1
         MOVE 1 TO L-NOTIFY
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-SHAPE-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-ROTATE.
*> USING north, east, south, west, the rotation (0 none, 1 clockwise 90, 2 counter-clockwise 90, 3 180), the four out (section 5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-OS                   BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-ROT L-ON L-OE L-OS L-OW.
     EVALUATE L-ROT
         WHEN 0
             MOVE L-N TO L-ON
             MOVE L-E TO L-OE
             MOVE L-S TO L-OS
             MOVE L-W TO L-OW
         WHEN 1
             MOVE L-W TO L-ON
             MOVE L-N TO L-OE
             MOVE L-E TO L-OS
             MOVE L-S TO L-OW
         WHEN 2
             MOVE L-E TO L-ON
             MOVE L-S TO L-OE
             MOVE L-W TO L-OS
             MOVE L-N TO L-OW
         WHEN 3
             MOVE L-S TO L-ON
             MOVE L-W TO L-OE
             MOVE L-N TO L-OS
             MOVE L-E TO L-OW
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-WIRE-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-MIRROR.
*> USING north, east, south, west, the mirror (0 none, 1 left-right, 2 front-back), the four out (section 5.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-OS                   BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-MIRROR L-ON L-OE L-OS L-OW.
     MOVE L-N TO L-ON
     MOVE L-E TO L-OE
     MOVE L-S TO L-OS
     MOVE L-W TO L-OW
     EVALUATE L-MIRROR
         WHEN 1
             MOVE L-S TO L-ON
             MOVE L-N TO L-OS
         WHEN 2
             MOVE L-W TO L-OE
             MOVE L-E TO L-OW
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-WIRE-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-INCOMING-STEP.
*> USING r, the wire power at N (0 when not wire), N is a conductor, the cell above P is a conductor, the wire power at N.above, the wire power at N.below, r out (section 5.4 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-PN                   BINARY-LONG.
 01 L-NCOND                BINARY-LONG.
 01 L-ACOND                BINARY-LONG.
 01 L-PABOVE               BINARY-LONG.
 01 L-PBELOW               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-PN L-NCOND L-ACOND L-PABOVE L-PBELOW L-OUT.
     MOVE L-R TO L-OUT
     IF L-PN > L-OUT
         MOVE L-PN TO L-OUT
     END-IF
     EVALUATE TRUE
         WHEN L-NCOND = 1 AND L-ACOND = 0
             IF L-PABOVE > L-OUT
                 MOVE L-PABOVE TO L-OUT
             END-IF
         WHEN L-NCOND = 0
             IF L-PBELOW > L-OUT
                 MOVE L-PBELOW TO L-OUT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-WIRE-INCOMING-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-INCOMING-END.
*> USING r, the incoming wire signal out (section 5.4 step 2): max(0, r - 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-OUT.
     MOVE 0 TO L-OUT
     IF L-R > 1
         COMPUTE L-OUT = L-R - 1
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-INCOMING-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-TARGET.
*> USING getBlockSignal, the incoming wire signal, the target power out (section 5.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-INCOMING             BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-INCOMING L-TARGET.
     MOVE L-BLOCK TO L-TARGET
     IF L-BLOCK < 15 AND L-INCOMING > L-BLOCK
         MOVE L-INCOMING TO L-TARGET
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-APPLY.
*> USING the target, the stored power, the block at P is still the same state, changed, written (flag 2), positions told out (section 5.4 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TARGET               BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 01 L-TOLD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TARGET L-STORED L-SAME L-CHANGED L-WRITTEN L-TOLD.
     MOVE 0 TO L-CHANGED L-WRITTEN L-TOLD
     IF L-TARGET NOT = L-STORED
         MOVE 1 TO L-CHANGED
         MOVE 7 TO L-TOLD
         IF L-SAME = 1
             MOVE 1 TO L-WRITTEN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-NOTIFY-ORDER.
*> USING x y z of the wire, then the seven calls out (section 5.4 step 4): -1 is P, 0 to 5 the direction of the neighbour, in the Java HashSet order of BlockPos hashes
*> *> ((y + z * 31) * 31 + x, 32 bit), 16 buckets, spread h ^ (h >>> 16), insertion order P, D, U, N, S, W, E inside a bucket.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-U                   BINARY-DOUBLE.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO4                 BINARY-LONG.
 01 WS-HI4                 BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-PW                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEYS.
    05 WS-KEY              BINARY-LONG OCCURS 7 TIMES.
 01 WS-OUTS.
    05 WS-OUT              BINARY-LONG OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-O1                   BINARY-LONG.
 01 L-O2                   BINARY-LONG.
 01 L-O3                   BINARY-LONG.
 01 L-O4                   BINARY-LONG.
 01 L-O5                   BINARY-LONG.
 01 L-O6                   BINARY-LONG.
 01 L-O7                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-O1 L-O2 L-O3 L-O4 L-O5 L-O6 L-O7.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE L-X TO WS-PX
         MOVE L-Y TO WS-PY
         MOVE L-Z TO WS-PZ
         IF WS-I > 1
             COMPUTE WS-D = WS-I - 2
             CALL "RS1-STEP" USING WS-D WS-DX WS-DY WS-DZ
             ADD WS-DX TO WS-PX
             ADD WS-DY TO WS-PY
             ADD WS-DZ TO WS-PZ
         END-IF
         COMPUTE WS-H = (WS-PY + WS-PZ * 31) * 31 + WS-PX
         COMPUTE WS-U = FUNCTION MOD(WS-H, 4294967296)
         DIVIDE WS-U BY 65536 GIVING WS-HI
         COMPUTE WS-LO4 = FUNCTION MOD(WS-U, 16)
         COMPUTE WS-HI4 = FUNCTION MOD(WS-HI, 16)
         MOVE 0 TO WS-BUCKET
         MOVE 1 TO WS-PW
         PERFORM 4 TIMES
             COMPUTE WS-A = FUNCTION MOD(WS-LO4, 2)
             COMPUTE WS-B = FUNCTION MOD(WS-HI4, 2)
             IF WS-A NOT = WS-B
                 ADD WS-PW TO WS-BUCKET
             END-IF
             DIVIDE WS-LO4 BY 2 GIVING WS-LO4
             DIVIDE WS-HI4 BY 2 GIVING WS-HI4
             MULTIPLY 2 BY WS-PW
         END-PERFORM
         COMPUTE WS-KEY(WS-I) = WS-BUCKET * 8 + WS-I - 1
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7 - WS-I
             IF WS-KEY(WS-J) > WS-KEY(WS-J + 1)
                 MOVE WS-KEY(WS-J) TO WS-T
                 MOVE WS-KEY(WS-J + 1) TO WS-KEY(WS-J)
                 MOVE WS-T TO WS-KEY(WS-J + 1)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         COMPUTE WS-IDX = FUNCTION MOD(WS-KEY(WS-I), 8)
         COMPUTE WS-OUT(WS-I) = WS-IDX - 1
     END-PERFORM
     MOVE WS-OUT(1) TO L-O1
     MOVE WS-OUT(2) TO L-O2
     MOVE WS-OUT(3) TO L-O3
     MOVE WS-OUT(4) TO L-O4
     MOVE WS-OUT(5) TO L-O5
     MOVE WS-OUT(6) TO L-O6
     MOVE WS-OUT(7) TO L-O7
     GOBACK.
 END PROGRAM RS1-WIRE-NOTIFY-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-ON-PLACE.
*> USING the old state is the same block, a client level, evaluate and update out (section 5.5 onPlace): then UP and DOWN are told and the neighbouring wires.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-CLIENT               BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-CLIENT L-RUN.
     MOVE 1 TO L-RUN
     IF L-SAME = 1 OR L-CLIENT = 1
         MOVE 0 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-ON-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-REMOVAL.
*> USING moved by a piston, update out (section 5.5 affectNeighborsAfterRemoval): the six neighbours, the evaluation and the neighbouring wires, unless moved.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOVED                BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MOVED L-RUN.
     MOVE 1 TO L-RUN
     IF L-MOVED = 1
         MOVE 0 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-REMOVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-NEIGHBOR.
*> USING a client level, canSurvive, the action out (0 nothing, 1 re-evaluate, 2 drop resources and remove) (section 5.5 neighborChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLIENT               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-CLIENT L-SURVIVE L-ACTION.
     MOVE 2 TO L-ACTION
     IF L-CLIENT = 1
         MOVE 0 TO L-ACTION
     END-IF
     IF L-CLIENT = 0 AND L-SURVIVE = 1
         MOVE 1 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-CORNER-TARGET.
*> USING the state at N is a conductor, the cell checked out (1 N.above, 0 N.below) (section 5.5 updateNeighborsOfNeighboringWires).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COND                 BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-COND L-ABOVE.
     MOVE L-COND TO L-ABOVE
     GOBACK.
 END PROGRAM RS1-WIRE-CORNER-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-CHECK-CORNER.
*> USING the block at X is wire, the updateNeighborsAt calls out (section 5.5 checkCornerChangeAt): X and its six neighbours.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WIRE                 BINARY-LONG.
 01 L-CALLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WIRE L-CALLS.
     MOVE 0 TO L-CALLS
     IF L-WIRE = 1
         MOVE 7 TO L-CALLS
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-CHECK-CORNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-GET-SIGNAL.
*> USING the shouldSignal flag, the direction asked, the power, the side of the opposite direction is connected, the signal out (section 5.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-CONNECTED            BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-D L-POWER L-CONNECTED L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     EVALUATE TRUE
         WHEN L-FLAG = 0
             MOVE 0 TO L-SIGNAL
         WHEN L-D = 0
             MOVE 0 TO L-SIGNAL
         WHEN L-POWER = 0
             MOVE 0 TO L-SIGNAL
         WHEN L-D = 1
             MOVE L-POWER TO L-SIGNAL
         WHEN L-CONNECTED = 1
             MOVE L-POWER TO L-SIGNAL
     END-EVALUATE
     GOBACK.
 END PROGRAM RS1-WIRE-GET-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-SOURCE.
*> USING the shouldSignal flag, the power, isSignalSource out, ownSignal out (section 5.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG L-POWER L-SOURCE L-OWN.
     MOVE L-FLAG TO L-SOURCE
     MOVE L-POWER TO L-OWN
     GOBACK.
 END PROGRAM RS1-WIRE-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-CONNECTS.
*> USING connects out (section 5.6): shouldRedstoneWireConnectTo of wire is always true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT.
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM RS1-WIRE-CONNECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-PARTICLE-CALLS.
*> USING the power, the side, then the number of line calls, and per call the line direction (1 UP, 0 DOWN), from and to in tenths out (section 5.7 animateTick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-B1                   BINARY-LONG.
 01 L-F1                   BINARY-LONG.
 01 L-T1                   BINARY-LONG.
 01 L-B2                   BINARY-LONG.
 01 L-F2                   BINARY-LONG.
 01 L-T2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-SIDE L-N L-B1 L-F1 L-T1 L-B2 L-F2 L-T2.
     MOVE 0 TO L-N L-B1 L-F1 L-T1 L-B2 L-F2 L-T2
     IF L-POWER > 0
         EVALUATE L-SIDE
             WHEN 0
                 MOVE 2 TO L-N
                 MOVE 1 TO L-B1
                 MOVE -5 TO L-F1
                 MOVE 5 TO L-T1
                 MOVE 5 TO L-T2
             WHEN 1
                 MOVE 1 TO L-N
                 MOVE 5 TO L-T1
             WHEN OTHER
                 MOVE 1 TO L-N
                 MOVE 3 TO L-T1
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-PARTICLE-CALLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-LINE.
*> USING the first nextFloat, from, to, the second nextFloat (FLOAT-LONG holding binary32 values), spawn out, t in millionths out (section 5.7 line spawner):
*> *> len = to - from; the particle is made only when the first draw is below 0.2 * len (a draw of at least that returns); t = from + second * len, all in single precision.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAW                 FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-DENS                FLOAT-LONG.
 01 WS-M1                  FLOAT-LONG.
 01 WS-LIM                 FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-M3                  FLOAT-LONG.
 01 WS-M4                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-TEXT                PIC X(4) VALUE Z"0.2".
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-FROM                 FLOAT-LONG.
 01 L-TO                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-R1 L-FROM L-TO L-R2 L-SPAWN L-T.
     MOVE 0 TO L-SPAWN L-T
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-TO L-FROM WS-RAW
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW WS-LEN
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT WS-D0
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D0 WS-DENS
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DENS WS-LEN WS-M1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M1 WS-LIM
     CALL "FCMP-GT" USING WS-LIM L-R1 WS-GT
     IF WS-GT = 1
         MOVE 1 TO L-SPAWN
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-R2 WS-LEN WS-M2
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M2 WS-M3
         CALL STATIC "cc_f64_add" USING BY REFERENCE L-FROM WS-M3 WS-M4
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M4 WS-T
         COMPUTE L-T ROUNDED = WS-T * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS1-WIRE-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-PARTICLE-POS.
*> USING the wire x y z, direction A, direction B, t (FLOAT-LONG), the position x y z in millionths out (section 5.7): P + 0.5 + 0.4375 * step(A) + t * step(B) per axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DA                   BINARY-LONG.
 01 L-DB                   BINARY-LONG.
 01 L-T                    FLOAT-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DA L-DB L-T L-OX L-OY L-OZ.
     CALL "RS1-STEP" USING L-DA WS-AX WS-AY WS-AZ
     CALL "RS1-STEP" USING L-DB WS-BX WS-BY WS-BZ
     COMPUTE L-OX ROUNDED = (L-X + 0.5 + 0.4375 * WS-AX + L-T * WS-BX) * 1000000
     COMPUTE L-OY ROUNDED = (L-Y + 0.5 + 0.4375 * WS-AY + L-T * WS-BY) * 1000000
     COMPUTE L-OZ ROUNDED = (L-Z + 0.5 + 0.4375 * WS-AZ + L-T * WS-BZ) * 1000000
     GOBACK.
 END PROGRAM RS1-WIRE-PARTICLE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-COLOR.
*> USING the power 0 to 15, red, green, blue out (section 5.7): the 16 values of the table of the document (single-precision result of the formulas).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CL-T.
 05 FILLER PIC X(9) VALUE "076000000".
 05 FILLER PIC X(9) VALUE "112000000".
 05 FILLER PIC X(9) VALUE "122000000".
 05 FILLER PIC X(9) VALUE "132000000".
 05 FILLER PIC X(9) VALUE "142000000".
 05 FILLER PIC X(9) VALUE "153000000".
 05 FILLER PIC X(9) VALUE "163000000".
 05 FILLER PIC X(9) VALUE "173000000".
 05 FILLER PIC X(9) VALUE "183000000".
 05 FILLER PIC X(9) VALUE "193000000".
 05 FILLER PIC X(9) VALUE "204000000".
 05 FILLER PIC X(9) VALUE "214000000".
 05 FILLER PIC X(9) VALUE "224000000".
 05 FILLER PIC X(9) VALUE "234006000".
 05 FILLER PIC X(9) VALUE "244027000".
 05 FILLER PIC X(9) VALUE "255050000".
 01 CL-X REDEFINES CL-T.
    05 CL-ROW              OCCURS 16 TIMES.
       10 CL-R             PIC 999.
       10 CL-G             PIC 999.
       10 CL-B             PIC 999.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-R L-G L-B.
     MOVE CL-R(L-POWER + 1) TO L-R
     MOVE CL-G(L-POWER + 1) TO L-G
     MOVE CL-B(L-POWER + 1) TO L-B
     GOBACK.
 END PROGRAM RS1-WIRE-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-ARM-BOX.
*> USING the arm (1 side arm, 2 up arm), the direction (2 north, 5 east, 3 south, 4 west), x0 y0 z0 x1 y1 z1 in sixteenths out (section 5.1): the north box turned clockwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TURNS                BINARY-LONG.
 01 WS-OX0                 BINARY-LONG.
 01 WS-OZ0                 BINARY-LONG.
 01 WS-OX1                 BINARY-LONG.
 01 WS-OZ1                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ARM                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ARM L-DIR L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 3 TO L-X0
     MOVE 0 TO L-Y0 L-Z0
     MOVE 13 TO L-X1
     MOVE 8 TO L-Z1
     MOVE 1 TO L-Y1
     IF L-ARM = 2
         MOVE 16 TO L-Y1
         MOVE 1 TO L-Z1
     END-IF
     EVALUATE L-DIR
         WHEN 2
             MOVE 0 TO WS-TURNS
         WHEN 5
             MOVE 1 TO WS-TURNS
         WHEN 3
             MOVE 2 TO WS-TURNS
         WHEN 4
             MOVE 3 TO WS-TURNS
     END-EVALUATE
     PERFORM WS-TURNS TIMES
         MOVE L-X0 TO WS-OX0
         MOVE L-Z0 TO WS-OZ0
         MOVE L-X1 TO WS-OX1
         MOVE L-Z1 TO WS-OZ1
         COMPUTE L-X0 = 16 - WS-OZ1
         MOVE WS-OX0 TO L-Z0
         COMPUTE L-X1 = 16 - WS-OZ0
         MOVE WS-OX1 TO L-Z1
     END-PERFORM
     GOBACK.
 END PROGRAM RS1-WIRE-ARM-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-SHAPE-COUNT.
*> USING north, east, south, west, the number of boxes of the shape out (section 5.1): the dot plus nothing (none), the side arm (side) or the side arm and the up arm (up) per side; independent of power.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-COUNT.
     COMPUTE L-COUNT = 1 + (2 - L-N) + (2 - L-E) + (2 - L-S) + (2 - L-W)
     GOBACK.
 END PROGRAM RS1-WIRE-SHAPE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-POWERED-BLOCK.
*> USING a direction, then isSignalSource, ownSignal, getSignal(d), getDirectSignal(d), isRedstoneConductor, getControlInputSignal out (section 6): redstone_block gives 15 in every direction, no strong power, no conduction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-CONTROL              BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-SOURCE L-OWN L-SIGNAL L-DIRECT L-CONDUCTOR L-CONTROL.
     MOVE 1 TO L-SOURCE
     MOVE 15 TO L-OWN L-SIGNAL L-CONTROL
     MOVE 0 TO L-DIRECT L-CONDUCTOR
     GOBACK.
 END PROGRAM RS1-POWERED-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-INTERACT.
*> USING lit, particles spawned, set lit true out (section 7 interact).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 01 L-SETLIT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-PARTICLES L-SETLIT.
     MOVE 1 TO L-PARTICLES
     MOVE 0 TO L-SETLIT
     IF L-LIT = 0
         MOVE 1 TO L-SETLIT
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-STEP.
*> USING the entity steps carefully (sneaking), interact out (section 7 stepOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SNEAK                BINARY-LONG.
 01 L-INTERACT             BINARY-LONG.
 PROCEDURE DIVISION USING L-SNEAK L-INTERACT.
     MOVE 1 TO L-INTERACT
     IF L-SNEAK = 1
         MOVE 0 TO L-INTERACT
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-USE.
*> USING server level, the held item is a BlockItem, a BlockPlaceContext canPlace, interact called, result (0 PASS, 1 SUCCESS), particles spawned out (section 7 useItemOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-BLOCKITEM            BINARY-LONG.
 01 L-CANPLACE             BINARY-LONG.
 01 L-INTERACT             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-BLOCKITEM L-CANPLACE L-INTERACT L-RESULT L-PARTICLES.
     MOVE 1 TO L-PARTICLES
     MOVE 1 TO L-RESULT
     MOVE 0 TO L-INTERACT
     IF L-SERVER = 1
         MOVE 1 TO L-INTERACT
     END-IF
     IF L-BLOCKITEM = 1 AND L-CANPLACE = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-RANDOM.
*> USING lit, isRandomlyTicking, randomTick sets lit false out (section 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-UNLIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-TICKING L-UNLIT.
     MOVE L-LIT TO L-TICKING L-UNLIT
     GOBACK.
 END PROGRAM RS1-ORE-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-ANIMATE.
*> USING lit, client particles out (section 7 animateTick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-PARTICLES.
     MOVE L-LIT TO L-PARTICLES
     GOBACK.
 END PROGRAM RS1-ORE-ANIMATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-XP.
*> USING dropExperience, the experience minimum and maximum out (section 7 spawnAfterBreak: UniformInt(1, 5)).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DROP                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DROP L-MIN L-MAX.
     MOVE 0 TO L-MIN L-MAX
     IF L-DROP = 1
         MOVE 1 TO L-MIN
         MOVE 5 TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-DRAWS.
*> USING the face direction, the neighbour is solid-rendering, the random draws out (section 7 spawnParticles): a skipped face draws nothing, else one draw for each of the two axes that are not the face axis.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-SOLID                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-SOLID L-DRAWS.
     MOVE 2 TO L-DRAWS
     IF L-SOLID = 1
         MOVE 0 TO L-DRAWS
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-ORE-COORD.
*> USING the axis is the face axis, the face step, the random value (FLOAT-LONG), the coordinate in millionths out (section 7 spawnParticles).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ONAXIS               BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ONAXIS L-STEP L-R L-VALUE.
     IF L-ONAXIS = 1
         COMPUTE L-VALUE ROUNDED = (0.5 + 0.5625 * L-STEP) * 1000000
     ELSE
         COMPUTE L-VALUE ROUNDED = L-R * 1000000
     END-IF
     GOBACK.
 END PROGRAM RS1-ORE-COORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-INPUT-DIR.
*> USING the kind (1 standing, 2 wall), facing, the direction of the attachment block out (section 8.3 input).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FACING L-DIR.
     MOVE 0 TO L-DIR
     IF L-KIND = 2
         CALL "RS1-OPP" USING L-FACING L-DIR
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-INPUT-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-SIGNAL.
*> USING the kind (1 standing, 2 wall), facing, lit, the direction asked, ownSignal, getSignal, getDirectSignal out (section 8.3 output).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FACING L-LIT L-D L-OWN L-SIGNAL L-DIRECT.
     MOVE 0 TO L-OWN L-DIRECT
     IF L-LIT = 1
         MOVE 15 TO L-OWN
     END-IF
     MOVE L-OWN TO L-SIGNAL
     IF L-KIND = 1 AND L-D = 1
         MOVE 0 TO L-SIGNAL
     END-IF
     IF L-KIND = 2 AND L-D = L-FACING
         MOVE 0 TO L-SIGNAL
     END-IF
     IF L-D = 0
         MOVE L-SIGNAL TO L-DIRECT
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-NEIGHBOR.
*> USING lit, the input is powered, willTickThisTick, schedule out, the delay out (section 8.3 neighborChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WILL                 BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-POWERED L-WILL L-SCHEDULE L-DELAY.
     MOVE 0 TO L-SCHEDULE L-DELAY
     IF L-LIT = L-POWERED AND L-WILL = 0
         MOVE 1 TO L-SCHEDULE
         MOVE 2 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-TICK-A.
*> USING lit, powered, step out (section 8.3 tick): 1 a lit torch with power turns off and records the toggle, 2 an unlit torch without power checks the list, 0 nothing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-POWERED L-STEP.
     MOVE 0 TO L-STEP
     IF L-LIT = 1 AND L-POWERED = 1
         MOVE 1 TO L-STEP
     END-IF
     IF L-LIT = 0 AND L-POWERED = 0
         MOVE 2 TO L-STEP
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-TICK-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-TICK-B.
*> USING the step of tick A, isToggledTooFrequently, set lit, burnout effect (level event 1502), the delay of the retry tick out (section 8.3 tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEP                 BINARY-LONG.
 01 L-TOO                  BINARY-LONG.
 01 L-SETLIT               BINARY-LONG.
 01 L-BURN                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-STEP L-TOO L-SETLIT L-BURN L-DELAY.
     MOVE 0 TO L-SETLIT L-BURN L-DELAY
     IF L-STEP = 1 AND L-TOO = 1
         MOVE 1 TO L-BURN
         MOVE 160 TO L-DELAY
     END-IF
     IF L-STEP = 2 AND L-TOO = 0
         MOVE 1 TO L-SETLIT
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-TICK-B.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-PRUNE.
*> USING the game time, the list size, the positions table, the times table (64 entries each) (section 8.3 step 2): while the list is not empty and gameTime - first.when is above 60 the first entry goes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NOW                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-POS.
    05 L-POS-E BINARY-LONG OCCURS 64 TIMES.
 01 L-TIME.
    05 L-TIME-E BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-NOW L-N L-POS L-TIME.
     MOVE 0 TO WS-K
     MOVE 1 TO WS-GO
     PERFORM UNTIL WS-GO = 0 OR WS-K >= L-N
         COMPUTE WS-AGE = L-NOW - L-TIME-E(WS-K + 1)
         IF WS-AGE > 60
             ADD 1 TO WS-K
         ELSE
             MOVE 0 TO WS-GO
         END-IF
     END-PERFORM
     COMPUTE WS-M = L-N - WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-M
         COMPUTE WS-J = WS-I + WS-K
         MOVE L-POS-E(WS-J) TO L-POS-E(WS-I)
         MOVE L-TIME-E(WS-J) TO L-TIME-E(WS-I)
     END-PERFORM
     MOVE WS-M TO L-N
     GOBACK.
 END PROGRAM RS1-TORCH-PRUNE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-RECORD.
*> USING the position id, the game time, the list size, the positions table, the times table (section 8.3): appends (pos, when).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POS                  BINARY-LONG.
 01 L-WHEN                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-POSTAB.
    05 L-POSTAB-E BINARY-LONG OCCURS 64 TIMES.
 01 L-TIMETAB.
    05 L-TIMETAB-E BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-POS L-WHEN L-N L-POSTAB L-TIMETAB.
     ADD 1 TO L-N
     MOVE L-POS TO L-POSTAB-E(L-N)
     MOVE L-WHEN TO L-TIMETAB-E(L-N)
     GOBACK.
 END PROGRAM RS1-TORCH-RECORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-COUNT.
*> USING the position id, the list size, the positions table, the count out, too often out (section 8.3 isToggledTooFrequently): the entries of this position, true once the count reaches 8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-POS                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-POSTAB.
    05 L-POSTAB-E BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-TOO                  BINARY-LONG.
 PROCEDURE DIVISION USING L-POS L-N L-POSTAB L-COUNT L-TOO.
     MOVE 0 TO L-COUNT L-TOO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-COUNT >= 8
         IF L-POSTAB-E(WS-I) = L-POS
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     IF L-COUNT >= 8
         MOVE 1 TO L-TOO
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WALL-TORCH-SU.
*> USING the direction of the update, facing, canSurvive, air out (section 8.1 updateShape): the update from the attachment side of a torch that cannot survive gives air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-FACING L-SURVIVE L-AIR.
     MOVE 0 TO L-AIR
     CALL "RS1-OPP" USING L-FACING WS-OPP
     IF L-D = WS-OPP AND L-SURVIVE = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM RS1-WALL-TORCH-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-NOTIFY.
*> USING onPlace (1) or removal (0), moved by a piston, notifyNeighbors runs out (section 8.2): onPlace always, removal unless moved.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLACE                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACE L-MOVED L-NOTIFY.
     MOVE 1 TO L-NOTIFY
     IF L-PLACE = 0 AND L-MOVED = 1
         MOVE 0 TO L-NOTIFY
     END-IF
     GOBACK.
 END PROGRAM RS1-TORCH-NOTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BURNOUT-EFFECT.
*> USING the level event id, the sound volume x 100, the smoke particles out (section 8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-SMOKE                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-VOLUME L-SMOKE.
     MOVE 1502 TO L-EVENT
     MOVE 50 TO L-VOLUME
     MOVE 5 TO L-SMOKE
     GOBACK.
 END PROGRAM RS1-BURNOUT-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BURNOUT-PITCH.
*> USING the first and second nextFloat (FLOAT-LONG), the pitch in millionths out (section 8.5): 2.6 + (first - second) * 0.8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-PITCH.
     COMPUTE L-PITCH ROUNDED = (2.6 + (L-A - L-B) * 0.8) * 1000000
     GOBACK.
 END PROGRAM RS1-BURNOUT-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-BURNOUT-SMOKE.
*> USING the block x y z, three nextDouble draws a b c (FLOAT-LONG), the smoke position in millionths out (section 8.5): pos + draw * 0.6 + 0.2 per axis.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-C                    FLOAT-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-A L-B L-C L-OX L-OY L-OZ.
     COMPUTE L-OX ROUNDED = (L-X + L-A * 0.6 + 0.2) * 1000000
     COMPUTE L-OY ROUNDED = (L-Y + L-B * 0.6 + 0.2) * 1000000
     COMPUTE L-OZ ROUNDED = (L-Z + L-C * 0.6 + 0.2) * 1000000
     GOBACK.
 END PROGRAM RS1-BURNOUT-SMOKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-TORCH-PARTICLE.
*> USING the kind (1 standing, 2 wall), facing, the block x y z, three nextDouble draws (FLOAT-LONG), the particle position in millionths out (section 8.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPP                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-EY                  PIC 9V99.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FACING L-X L-Y L-Z L-R1 L-R2 L-R3 L-OX L-OY L-OZ.
     MOVE 0 TO WS-SX WS-SZ WS-EY
     IF L-KIND = 2
         CALL "RS1-OPP" USING L-FACING WS-OPP
         CALL "RS1-STEP" USING WS-OPP WS-SX WS-SY WS-SZ
         COMPUTE WS-EY = 0.22
     END-IF
     COMPUTE L-OX ROUNDED = (L-X + 0.5 + (L-R1 - 0.5) * 0.2 + 0.27 * WS-SX) * 1000000
     COMPUTE L-OY ROUNDED = (L-Y + 0.7 + (L-R2 - 0.5) * 0.2 + WS-EY) * 1000000
     COMPUTE L-OZ ROUNDED = (L-Z + 0.5 + (L-R3 - 0.5) * 0.2 + 0.27 * WS-SZ) * 1000000
     GOBACK.
 END PROGRAM RS1-TORCH-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS1-WIRE-DOT-BOX.
*> USING x0 y0 z0 x1 y1 z1 in sixteenths out (section 5.1): column(10, 0, 1) is box(3, 0, 3, 13, 1, 13).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     MOVE 3 TO L-X0 L-Z0
     MOVE 0 TO L-Y0
     MOVE 13 TO L-X1 L-Z1
     MOVE 1 TO L-Y1
     GOBACK.
 END PROGRAM RS1-WIRE-DOT-BOX.

