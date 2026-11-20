*> Live redstone, the sensors that look at the world (docs/protocol/30-redstone-5 sections 5 and 7, 30-redstone-6 section 6): the daylight detector's ticker and its use, the lightning rod's strike and release, the
*> detector rail pressed by minecarts.
*> Deviations: the lightning bolt strikes the rod at its own position (the redirect to the nearest rod within 128 blocks of 30-5 7.3 needs the point-of-interest search that this core does not have); the sun angle
*> is the keyframe curve of 12 section 3.3 (0 to 360 degrees over a day from tick 6000, eased by the cubic bezier of that document: inferred there); the detector rail's updatePowerToConnected (the rails it
*> links) is not done and a comparator reads no cart's container (the analog output of the detector rail is 0).
*> Entry points:
*>   RL-SUN-ANGLE USING clock ticks, sun angle in degrees out (FLOAT-LONG)
*>   RL-DAYLIGHT-UPDATE USING dim, x, y, z, state                    DaylightDetectorBlock.updateSignalStrength (5)
*>   RL-DAYLIGHT-TICK-ALL                                            the block entity tickers of the daylight detectors (every 20th game tick), called by CORE-TICK
*>   RL-ROD-STRUCK USING dim, x, y, z, state                         LightningRodBlock.onLightningStrike (7.1)
*>   RL-ROD-STRIKE USING bolt entity row                             powerLightningRod: the rod at the bolt's strike position
*>   RL-ROD-HOOK USING kind, dim, x, y, z, state, a                  kinds 1 onPlace, 2 removal, 7 scheduled tick of a lightning rod
*>   RL-DETECTOR-CHECK USING dim, x, y, z, state                     DetectorRailBlock.checkPressed (6.3)
*>   RL-DETECTOR-HOOK USING kind, dim, x, y, z, state                kinds 1 onPlace and 7 scheduled tick of a detector rail

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SUN-ANGLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-ANGLE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-TIME L-ANGLE.
*>   the position in the period that starts at tick 6000
     COMPUTE WS-T = FUNCTION MOD(L-TIME - 6000, 24000)
     COMPUTE WS-F = WS-T / 24000
     MOVE 0 TO WS-LO
     MOVE 1 TO WS-HI
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         COMPUTE WS-U = (WS-LO + WS-HI) / 2
         COMPUTE WS-X = 3 * (1 - WS-U) * (1 - WS-U) * WS-U * 0.362 + 3 * (1 - WS-U) * WS-U * WS-U * 0.638 + WS-U * WS-U * WS-U
         IF WS-X < WS-F
             MOVE WS-U TO WS-LO
         ELSE
             MOVE WS-U TO WS-HI
         END-IF
     END-PERFORM
     COMPUTE WS-U = (WS-LO + WS-HI) / 2
     COMPUTE WS-Y = 3 * (1 - WS-U) * (1 - WS-U) * WS-U * 0.241 + 3 * (1 - WS-U) * WS-U * WS-U * 0.759 + WS-U * WS-U * WS-U
     COMPUTE L-ANGLE = WS-Y * 360
     GOBACK.
 END PROGRAM RL-SUN-ANGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DAYLIGHT-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-INVERTED            PIC X(16) VALUE "inverted".
 01 WS-POWER               PIC X(16) VALUE "power".
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-EFFECTIVE           BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-INV                 BINARY-LONG.
 01 WS-NEW-POWER           BINARY-LONG.
 01 WS-OLD-POWER           BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 01 WS-DIGITS              PIC Z9.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK-LIGHT WS-RAW
     CALL "WORLDSIM-DARKEN" USING L-DIM WS-DARKEN
     CALL "L32-EFFECTIVE-SKY" USING WS-SKY WS-DARKEN WS-EFFECTIVE
     MOVE CW-TIME TO WS-TIME
     CALL "RL-SUN-ANGLE" USING WS-TIME WS-ANGLE
     CALL "RL-GET-BOOL" USING L-STATE WS-INVERTED WS-INV
     CALL "RS2-DAYLIGHT-POWER" USING WS-EFFECTIVE WS-ANGLE WS-INV WS-NEW-POWER
     CALL "RL-PROP-NUM" USING L-STATE WS-POWER WS-OLD-POWER
     IF WS-NEW-POWER NOT = WS-OLD-POWER
         MOVE WS-NEW-POWER TO WS-DIGITS
         MOVE SPACES TO WS-TEXT
         MOVE FUNCTION TRIM(WS-DIGITS) TO WS-TEXT
         CALL "SW-SET-PROP" USING L-STATE WS-POWER WS-TEXT WS-NEW WS-OLD
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-DAYLIGHT-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DAYLIGHT-TICK-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY DIMENSIONS.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 PROCEDURE DIVISION.
     IF FUNCTION MOD(CW-TICKS, 20) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) > 0 AND BE-TYPE(WS-I) = 17
             IF DM-SKYLIGHT(BE-DIM(WS-I)) = 1
                 CALL "WORLD-GET-BLOCK" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-STATE
                 CALL "RL-DAYLIGHT-UPDATE" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-STATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-DAYLIGHT-TICK-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ROD-STRUCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-OLD                 PIC X(16).
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 8.
 01 WS-PRIORITY            BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 3002.
 01 WS-AXIS                BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     CALL "SW-SET-PROP" USING L-STATE WS-POWERED WS-TRUE WS-NEW WS-OLD
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     CALL "PST-FACING-OF" USING L-STATE WS-FACING
     COMPUTE WS-OPP = WS-FACING + 1 - 2 * FUNCTION MOD(WS-FACING, 2)
     CALL "BU-DIRECTION" USING WS-OPP WS-DX WS-DY WS-DZ
     COMPUTE WS-SX = L-X + WS-DX
     COMPUTE WS-SY = L-Y + WS-DY
     COMPUTE WS-SZ = L-Z + WS-DZ
     CALL "BU-NEIGHBORS-AT" USING L-DIM WS-SX WS-SY WS-SZ WS-BLOCK
     CALL "BT-SCHEDULE" USING L-DIM WS-TYPE WS-BLOCK L-X L-Y L-Z WS-DELAY WS-PRIORITY WS-RESULT
*>   level event 3002: the ordinal of the rod's axis (X 0, Y 1, Z 2)
     COMPUTE WS-AXIS = (WS-FACING - FUNCTION MOD(WS-FACING, 2)) / 2
     EVALUATE WS-AXIS
         WHEN 0
             MOVE 1 TO WS-AXIS
         WHEN 1
             MOVE 2 TO WS-AXIS
         WHEN OTHER
             MOVE 0 TO WS-AXIS
     END-EVALUATE
     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT L-X L-Y L-Z WS-AXIS WS-NONE
     GOBACK.
 END PROGRAM RL-ROD-STRUCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ROD-STRIKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "REDSTONE-IDS-ENSURE"
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-V = EN-Y(L-ROW) - 0.000001
     COMPUTE WS-Y = FUNCTION INTEGER(WS-V)
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
     IF RL-CLASS(CB-S-BLOCK(WS-STATE + 1) + 1) = 22
         CALL "RL-ROD-STRUCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
     END-IF
     GOBACK.
 END PROGRAM RL-ROD-STRIKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ROD-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-FALSE               PIC X(16) VALUE "false".
 LOCAL-STORAGE SECTION.
 01 LS-ON                  BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-FACING              BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-SX                  BINARY-LONG.
 01 LS-SY                  BINARY-LONG.
 01 LS-SZ                  BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-DELAY               BINARY-LONG VALUE 8.
 01 LS-PRIORITY            BINARY-LONG VALUE 0.
 01 LS-PENDING             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A.
     CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-ON
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     CALL "PST-FACING-OF" USING L-STATE LS-FACING
     COMPUTE LS-OPP = LS-FACING + 1 - 2 * FUNCTION MOD(LS-FACING, 2)
     CALL "BU-DIRECTION" USING LS-OPP LS-DX LS-DY LS-DZ
     COMPUTE LS-SX = L-X + LS-DX
     COMPUTE LS-SY = L-Y + LS-DY
     COMPUTE LS-SZ = L-Z + LS-DZ
     EVALUATE L-KIND
         WHEN 7
*>           the release (7.2): powered false, the support's neighbours are told
             CALL "SW-SET-PROP" USING L-STATE WS-POWERED WS-FALSE LS-NEW LS-OLD
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             CALL "BU-NEIGHBORS-AT" USING L-DIM LS-SX LS-SY LS-SZ LS-BLOCK
         WHEN 1
*>           onPlace: a rod that arrives powered without a tick pending releases after 8 ticks
             IF LS-ON = 1 AND CB-S-BLOCK(L-A + 1) NOT = LS-BLOCK
                 CALL "BT-HAS" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-PENDING
                 IF LS-PENDING = 0
                     CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
                 END-IF
             END-IF
         WHEN 2
*>           removal: a powered rod tells the support
             IF LS-ON = 1
                 CALL "BU-NEIGHBORS-AT" USING L-DIM LS-SX LS-SY LS-SZ LS-BLOCK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-ROD-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DETECTOR-CHECK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-WAS                 BINARY-LONG.
 01 LS-ANY                 BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-KEY                 PIC X(48).
 01 LS-HITS                BINARY-LONG.
 01 LS-HALF                FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 01 LS-LO-X                FLOAT-LONG.
 01 LS-HI-X                FLOAT-LONG.
 01 LS-LO-Z                FLOAT-LONG.
 01 LS-HI-Z                FLOAT-LONG.
 01 LS-HI-Y                FLOAT-LONG.
 01 LS-NEW-ON              BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-BELOW               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-DELAY               BINARY-LONG VALUE 20.
 01 LS-PRIORITY            BINARY-LONG VALUE 0.
 01 LS-CUR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-CUR
     IF CB-S-BLOCK(LS-CUR + 1) NOT = CB-S-BLOCK(L-STATE + 1)
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(LS-CUR + 1) TO LS-BLOCK
     CALL "RL-GET-BOOL" USING LS-CUR WS-POWERED LS-WAS
*>   the search box (6.2): (x + 0.2, y, z + 0.2) to (x + 0.8, y + 0.8, z + 0.8); a minecart counts when its own box overlaps it
     COMPUTE LS-LO-X = L-X + 0.2
     COMPUTE LS-HI-X = L-X + 0.8
     COMPUTE LS-LO-Z = L-Z + 0.2
     COMPUTE LS-HI-Z = L-Z + 0.8
     COMPUTE LS-HI-Y = L-Y + 0.8
     MOVE 0 TO LS-ANY
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > EN-COUNT
         IF EN-USED(LS-I) = 1 AND EN-DIM(LS-I) = L-DIM
             MOVE ET-KEY(EN-TYPE(LS-I) + 1) TO LS-KEY
             MOVE 0 TO LS-HITS
             INSPECT LS-KEY TALLYING LS-HITS FOR ALL "minecart"
             IF LS-HITS > 0
                 COMPUTE LS-HALF = ET-WIDTH-MILLI(EN-TYPE(LS-I) + 1) / 2000
                 COMPUTE LS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(LS-I) + 1) / 1000
                 IF EN-X(LS-I) + LS-HALF > LS-LO-X AND EN-X(LS-I) - LS-HALF < LS-HI-X AND EN-Z(LS-I) + LS-HALF > LS-LO-Z
                         AND EN-Z(LS-I) - LS-HALF < LS-HI-Z AND EN-Y(LS-I) + LS-HEIGHT > L-Y AND EN-Y(LS-I) < LS-HI-Y
                     MOVE 1 TO LS-ANY
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF LS-ANY NOT = LS-WAS
         MOVE LS-ANY TO LS-NEW-ON
         CALL "RL-SET-BOOL" USING LS-CUR WS-POWERED LS-NEW-ON LS-NEW
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         COMPUTE LS-BELOW = L-Y - 1
         CALL "BU-NEIGHBORS-AT" USING L-DIM L-X LS-BELOW L-Z LS-BLOCK
     END-IF
     IF LS-ANY = 1
         CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-DETECTOR-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DETECTOR-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-ON                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE.
     CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-ON
*>   the tick runs only while powered (6.3); onPlace checks once
     IF L-KIND = 1 OR (L-KIND = 7 AND LS-ON = 1)
         CALL "RL-DETECTOR-CHECK" USING L-DIM L-X L-Y L-Z L-STATE
     END-IF
     GOBACK.
 END PROGRAM RL-DETECTOR-HOOK.
