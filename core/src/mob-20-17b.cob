*> The creaking's freeze-when-watched rule (lane 002-lane-p49r; docs/protocol/20 section 17, 17.1, 17.2, 17.3). State: CRK-ENTRY of CREAKSTATE.cpy.
*>   CRK-FIND USING entity id, create, slot out        the state slot of a creaking (0 none); a new one can move, is not active and scans at a draw of 0 to 19
*>   CREAKING-CLIP USING dim, from x, y, z, to x, y, z (FLOAT-LONG), hit out: Level.clip (17.1.2) for a visual-shape ray with fluids ignored: the cell walk with the 1e-7 outward adjustment and its
*>     tie rule, and the box clip of each solid cell. A cell blocks when its block has a collision shape (CB-SOLID), except the empty visual shapes: glass and its panes and families, iron and copper bars,
*>     powder snow; every blocking shape is taken as the whole cube (partial shapes, fences, snow layers are not told apart).
*>   CREAKING-LOOKING USING creaking row, player row, looking out: LivingEntity.isLookingAtMe(player, 0.5, false, true, [eye, body, middle]) (17.1.1): the player's view vector (yaw, pitch) against the
*>     samples y = eye 2.3, body 0.5, middle of the two above the creaking's feet, a cone of 60 degrees at every distance, then the line of sight of at most 128 blocks.
*>   CREAKING-SENSE USING creaking row, slot: the nearest_players sensor (17.2): every non-spectator player of the dimension within the follow range 32 (squared distance below 1024), nearest first.
*>   CREAKING-SET-ACTIVE USING creaking row, slot, player row (0 = deactivate): activate / deactivate.
*>   CREAKING-CAN-MOVE USING creaking row, slot, can move out: Creaking.checkCanMove (17.1): activates, deactivates and says whether the creaking may move.
*>   CREAKING-ACTIVE-ATTR USING dim (the dimension row: 1 the cobolcraft main dimension and 3 the standard Overworld have the Overworld's timeline), day time, flag out: gameplay/creaking_active (17.3).
*>   CREAKING-BRAIN USING creaking row: one tick: checkCanMove (metadata 16 CAN_MOVE and 17 IS_ACTIVE are sent when they change; a frozen creaking stops in place), then the sensor.
*>   CREAKING-FROZEN USING creaking row, flag out: 1 while CAN_MOVE is false (STDMOB-STEP: no walk, no attack).
*> Not here: the scoreboard allies (core has no teams), the heart itself (mob-20-17c.cob; the bound creaking's death when unlisted and its teardown are in CREAKING-BRAIN), the target selection of the brain's other behaviours, the head turn, the sounds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRK-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CREAKSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 96.
 01 WS-B20                 BINARY-LONG VALUE 20.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CRK-MAX OR L-SLOT > 0
         IF CRK-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CRK-MAX OR L-SLOT > 0
             IF CRK-ID(WS-I) = 0
                 INITIALIZE CRK-ENTRY(WS-I)
                 MOVE L-ID TO CRK-ID(WS-I)
                 MOVE 1 TO CRK-CAN-MOVE(WS-I)
                 CALL "XP-RANDOM" USING WS-SALT WS-B20 WS-DRAW
                 MOVE WS-DRAW TO CRK-SENSOR(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CRK-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-BLOCKS.
*> USING dim, x, y, z (BINARY-LONG block), blocks out (0/1): whether the cell blocks a visual-shape ray (see the file header).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCKS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCKS.
     MOVE 0 TO L-BLOCKS
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     IF CB-SOLID(WS-BLOCK) = 1
         MOVE 1 TO L-BLOCKS
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "glass" ALL "bars" ALL "powder_snow"
         IF WS-N > 0
             MOVE 0 TO L-BLOCKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREAKING-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-CUBE-CLIP.
*> USING cell x, y, z (BINARY-LONG), from x, y, z, to x, y, z (FLOAT-LONG), hit out: VoxelShape.clip of the whole cube of a cell (17.1.2): the start-inside rule (the probe point
*> from + 0.001 x delta in the cube, half open) or the nearest face looking towards `from` (0 < u < t, the rectangle widened by 1e-7, strict).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D.
    05 WS-DA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-F.
    05 WS-FA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C.
    05 WS-CA               BINARY-LONG OCCURS 3 TIMES.
 01 WS-P                   FLOAT-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-FACE                FLOAT-LONG.
 01 WS-PB                  FLOAT-LONG.
 01 WS-PC                  FLOAT-LONG.
 01 WS-LEN2                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CY L-CZ L-FX L-FY L-FZ L-TX L-TY L-TZ L-HIT.
     MOVE 0 TO L-HIT
     MOVE L-CX TO WS-CA(1)
     MOVE L-CY TO WS-CA(2)
     MOVE L-CZ TO WS-CA(3)
     MOVE L-FX TO WS-FA(1)
     MOVE L-FY TO WS-FA(2)
     MOVE L-FZ TO WS-FA(3)
     COMPUTE WS-DA(1) = L-TX - L-FX
     COMPUTE WS-DA(2) = L-TY - L-FY
     COMPUTE WS-DA(3) = L-TZ - L-FZ
     COMPUTE WS-LEN2 = WS-DA(1) * WS-DA(1) + WS-DA(2) * WS-DA(2) + WS-DA(3) * WS-DA(3)
     IF WS-LEN2 < 0.0000001
         GOBACK
     END-IF
*>   The start-inside rule: the probe point 0.001 along the segment lies in the cube [0, 1) on every axis.
     MOVE 1 TO WS-INSIDE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-P = WS-FA(WS-I) + 0.001 * WS-DA(WS-I) - WS-CA(WS-I)
         IF WS-P < 0 OR WS-P >= 1
             MOVE 0 TO WS-INSIDE
         END-IF
     END-PERFORM
     IF WS-INSIDE = 1
         MOVE 1 TO L-HIT
         GOBACK
     END-IF
*>   AABB.clip: for the axes x, y, z the face looking towards `from`; the nearest accepted u wins.
     MOVE 1.0 TO WS-T
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF WS-DA(WS-I) > 0.0000001
             COMPUTE WS-FACE = WS-CA(WS-I)
         ELSE
             IF WS-DA(WS-I) < -0.0000001
                 COMPUTE WS-FACE = WS-CA(WS-I) + 1
             ELSE
                 MOVE -1000 TO WS-FACE
             END-IF
         END-IF
         IF WS-FACE > -1000
             COMPUTE WS-U = (WS-FACE - WS-FA(WS-I)) / WS-DA(WS-I)
             IF WS-U > 0 AND WS-U < WS-T
*>               The other two axes in the cyclic order (y, z) for x, (z, x) for y, (x, y) for z.
                 COMPUTE WS-J = FUNCTION MOD(WS-I, 3) + 1
                 COMPUTE WS-K = FUNCTION MOD(WS-I + 1, 3) + 1
                 COMPUTE WS-PB = WS-FA(WS-J) + WS-U * WS-DA(WS-J)
                 COMPUTE WS-PC = WS-FA(WS-K) + WS-U * WS-DA(WS-K)
                 IF WS-PB > WS-CA(WS-J) - 0.0000001 AND WS-PB < WS-CA(WS-J) + 1 + 0.0000001
                         AND WS-PC > WS-CA(WS-K) - 0.0000001 AND WS-PC < WS-CA(WS-K) + 1 + 0.0000001
                     MOVE WS-U TO WS-T
                     MOVE 1 TO L-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREAKING-CUBE-CLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-CLIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S.
    05 WS-SA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-D.
    05 WS-DA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CELL.
    05 WS-CA               BINARY-LONG OCCURS 3 TIMES.
 01 WS-SIGN.
    05 WS-SG               BINARY-LONG OCCURS 3 TIMES.
 01 WS-STEP.
    05 WS-ST               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-T.
    05 WS-TA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-FRAC                FLOAT-LONG.
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LEN2                FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-CHIT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-FX L-FY L-FZ L-TX L-TY L-TZ L-HIT.
     MOVE 0 TO L-HIT
     MOVE L-FX TO WS-FX
     MOVE L-FY TO WS-FY
     MOVE L-FZ TO WS-FZ
     MOVE L-TX TO WS-TX
     MOVE L-TY TO WS-TY
     MOVE L-TZ TO WS-TZ
     COMPUTE WS-LEN2 = (L-TX - L-FX) ** 2 + (L-TY - L-FY) ** 2 + (L-TZ - L-FZ) ** 2
     IF WS-LEN2 = 0
         GOBACK
     END-IF
*>   Both ends are moved outward by 1e-7 of the segment.
     COMPUTE WS-SA(1) = L-FX - 0.0000001 * (L-TX - L-FX)
     COMPUTE WS-SA(2) = L-FY - 0.0000001 * (L-TY - L-FY)
     COMPUTE WS-SA(3) = L-FZ - 0.0000001 * (L-TZ - L-FZ)
     COMPUTE WS-DA(1) = L-TX + 0.0000001 * (L-TX - L-FX) - WS-SA(1)
     COMPUTE WS-DA(2) = L-TY + 0.0000001 * (L-TY - L-FY) - WS-SA(2)
     COMPUTE WS-DA(3) = L-TZ + 0.0000001 * (L-TZ - L-FZ) - WS-SA(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-CA(WS-I) = FUNCTION INTEGER(WS-SA(WS-I))
         COMPUTE WS-FRAC = WS-SA(WS-I) - WS-CA(WS-I)
         EVALUATE TRUE
             WHEN WS-DA(WS-I) > 0
                 MOVE 1 TO WS-SG(WS-I)
                 COMPUTE WS-ST(WS-I) = 1 / WS-DA(WS-I)
                 COMPUTE WS-TA(WS-I) = WS-ST(WS-I) * (1 - WS-FRAC)
             WHEN WS-DA(WS-I) < 0
                 MOVE -1 TO WS-SG(WS-I)
                 COMPUTE WS-ST(WS-I) = 1 / (- WS-DA(WS-I))
                 COMPUTE WS-TA(WS-I) = WS-ST(WS-I) * WS-FRAC
             WHEN OTHER
*>               A zero component: the step is the largest double (1.0E300 here, which no walk reaches) and the first crossing 0 when the start coordinate is a whole number.
                 MOVE 0 TO WS-SG(WS-I)
                 MOVE 1.0E300 TO WS-ST(WS-I)
                 COMPUTE WS-TA(WS-I) = WS-ST(WS-I) * WS-FRAC
         END-EVALUATE
     END-PERFORM
     CALL "CREAKING-BLOCKS" USING L-DIM WS-CA(1) WS-CA(2) WS-CA(3) WS-BLOCKS
     IF WS-BLOCKS = 1
         CALL "CREAKING-CUBE-CLIP" USING WS-CA(1) WS-CA(2) WS-CA(3) WS-FX WS-FY WS-FZ WS-TX WS-TY WS-TZ WS-CHIT
         IF WS-CHIT = 1
             MOVE 1 TO L-HIT
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         IF WS-TA(1) > 1 AND WS-TA(2) > 1 AND WS-TA(3) > 1
             MOVE 1 TO WS-DONE
         ELSE
*>           x only when strictly below both, else y when below z, else z.
             IF WS-TA(1) < WS-TA(2) AND WS-TA(1) < WS-TA(3)
                 MOVE 1 TO WS-AXIS
             ELSE
                 IF WS-TA(2) < WS-TA(3)
                     MOVE 2 TO WS-AXIS
                 ELSE
                     MOVE 3 TO WS-AXIS
                 END-IF
             END-IF
             ADD WS-SG(WS-AXIS) TO WS-CA(WS-AXIS)
             IF WS-TA(WS-AXIS) < 1.0E299
                 COMPUTE WS-TA(WS-AXIS) = WS-TA(WS-AXIS) + WS-ST(WS-AXIS)
             END-IF
             CALL "CREAKING-BLOCKS" USING L-DIM WS-CA(1) WS-CA(2) WS-CA(3) WS-BLOCKS
             IF WS-BLOCKS = 1
                 CALL "CREAKING-CUBE-CLIP" USING WS-CA(1) WS-CA(2) WS-CA(3) WS-FX WS-FY WS-FZ WS-TX WS-TY WS-TZ WS-CHIT
                 IF WS-CHIT = 1
                     MOVE 1 TO L-HIT
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREAKING-CLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-LOOKING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-R                   FLOAT-SHORT VALUE 0.01745329238474369.
 01 WS-A                   FLOAT-SHORT.
 01 WS-B                   FLOAT-SHORT.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-SINA                FLOAT-LONG.
 01 WS-COSA                FLOAT-LONG.
 01 WS-SINB                FLOAT-LONG.
 01 WS-COSB                FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-VL                  FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-SAMPLES.
    05 WS-SAMPLE           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-WL                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-LOOKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-LOOKING.
     MOVE 0 TO L-LOOKING
*>   The view vector: a = pitch x r, b = -yaw x r (floats), (sin b x cos a, -sin a, cos b x cos a), the products in float.
     COMPUTE WS-A = PL-PITCH(L-PLAYER) * WS-R
     COMPUTE WS-B = - PL-YAW(L-PLAYER) * WS-R
     MOVE WS-A TO WS-ARG
     CALL "IP-MTH-SIN" USING WS-ARG WS-SINA
     CALL "IP-MTH-COS" USING WS-ARG WS-COSA
     MOVE WS-B TO WS-ARG
     CALL "IP-MTH-SIN" USING WS-ARG WS-SINB
     CALL "IP-MTH-COS" USING WS-ARG WS-COSB
     COMPUTE WS-VX = WS-SINB * WS-COSA
     COMPUTE WS-VY = - WS-SINA
     COMPUTE WS-VZ = WS-COSB * WS-COSA
     COMPUTE WS-VL = FUNCTION SQRT(WS-VX * WS-VX + WS-VY * WS-VY + WS-VZ * WS-VZ)
     COMPUTE WS-VX = WS-VX / WS-VL
     COMPUTE WS-VY = WS-VY / WS-VL
     COMPUTE WS-VZ = WS-VZ / WS-VL
     COMPUTE WS-EYE = PL-Y(L-PLAYER) + 1.62
*>   The sample heights: eye (2.3 above the feet), body (0.5), middle of the eye and the feet.
     COMPUTE WS-SAMPLE(1) = EN-Y(L-ROW) + 2.3
     COMPUTE WS-SAMPLE(2) = EN-Y(L-ROW) + 0.5
     COMPUTE WS-SAMPLE(3) = (WS-SAMPLE(1) + EN-Y(L-ROW)) / 2
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE PL-X(L-PLAYER) TO WS-FX
     MOVE PL-Z(L-PLAYER) TO WS-FZ
     MOVE EN-X(L-ROW) TO WS-TX
     MOVE EN-Z(L-ROW) TO WS-TZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3 OR L-LOOKING = 1
         COMPUTE WS-WX = EN-X(L-ROW) - PL-X(L-PLAYER)
         COMPUTE WS-WY = WS-SAMPLE(WS-I) - WS-EYE
         COMPUTE WS-WZ = EN-Z(L-ROW) - PL-Z(L-PLAYER)
         COMPUTE WS-WL = FUNCTION SQRT(WS-WX * WS-WX + WS-WY * WS-WY + WS-WZ * WS-WZ)
         IF WS-WL > 0
             COMPUTE WS-DOT = (WS-VX * WS-WX + WS-VY * WS-WY + WS-VZ * WS-WZ) / WS-WL
             IF WS-DOT > 0.5 AND WS-WL <= 128
                 CALL "CREAKING-CLIP" USING WS-DIM WS-FX WS-EYE WS-FZ WS-TX WS-SAMPLE(WS-I) WS-TZ WS-HIT
                 IF WS-HIT = 0
                     MOVE 1 TO L-LOOKING
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREAKING-LOOKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-SENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIST.
    05 WS-DI               FLOAT-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE 0 TO CRK-COUNT(L-SLOT)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 < 1024 AND CRK-COUNT(L-SLOT) < 16
*>               Inserted in ascending order of squared distance (a stable insertion: an equal distance goes after).
                 ADD 1 TO CRK-COUNT(L-SLOT)
                 MOVE CRK-COUNT(L-SLOT) TO WS-K
                 PERFORM UNTIL WS-K = 1
                     COMPUTE WS-J = WS-K - 1
                     IF WS-DI(WS-J) <= WS-D2
                         EXIT PERFORM
                     END-IF
                     MOVE WS-DI(WS-J) TO WS-DI(WS-K)
                     MOVE CRK-LIST(L-SLOT, WS-J) TO CRK-LIST(L-SLOT, WS-K)
                     SUBTRACT 1 FROM WS-K
                 END-PERFORM
                 MOVE WS-D2 TO WS-DI(WS-K)
                 MOVE WS-P TO CRK-LIST(L-SLOT, WS-K)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CREAKING-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-SEND.
*> USING creaking row, metadata index, value (0/1): Set Entity Data of a BOOLEAN entry to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID            BINARY-LONG VALUE 101.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-INDEX                 BINARY-LONG.
 01 L-VALUE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-INDEX L-VALUE.
     CALL "PB-INIT" USING MD-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING MD-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING MD-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE L-INDEX TO MD-MD-INDEX
     MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
     MOVE L-VALUE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING MD-BUFFER MD-METADATA-ENTRY
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW MD-BUFFER
     CALL "PB-FREE" USING MD-BUFFER
     GOBACK.
 END PROGRAM CREAKING-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-SET-ACTIVE.
*> USING creaking row, slot, player row (0 deactivates): Creaking.activate (attack target and IS_ACTIVE true) or Creaking.deactivate (the attack target erased, IS_ACTIVE false); the flag is sent (17).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 01 WS-ACTIVE-FLAG         BINARY-LONG VALUE 17.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-PLAYER.
     IF L-PLAYER > 0
         MOVE L-PLAYER TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(L-PLAYER) TO EN-TARGET-ID(L-ROW)
         MOVE 1 TO CRK-ACTIVE(L-SLOT) WS-VALUE
     ELSE
         MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
         MOVE 0 TO CRK-ACTIVE(L-SLOT) WS-VALUE
     END-IF
     CALL "CREAKING-SEND" USING L-ROW WS-ACTIVE-FLAG WS-VALUE
     GOBACK.
 END PROGRAM CREAKING-SET-ACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-CAN-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 COPY CMENU.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-K                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-LOOK                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-CAN.
     MOVE 1 TO L-CAN
     IF CRK-COUNT(L-SLOT) = 0
         IF CRK-ACTIVE(L-SLOT) = 1
             CALL "CREAKING-SET-ACTIVE" USING L-ROW L-SLOT WS-ZERO
         END-IF
         GOBACK
     END-IF
     CALL "BR-WORLD-READY"
     MOVE 0 TO WS-FOUND WS-DONE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > CRK-COUNT(L-SLOT) OR WS-DONE = 1
         MOVE CRK-LIST(L-SLOT, WS-K) TO WS-P
*>       canAttack: not in Peaceful, the player alive, not creative (invulnerable) and not spectator; no scoreboard team exists to ally with.
         MOVE 0 TO WS-SKIP
         IF BW-DIFFICULTY = 0 OR PL-STATE(WS-P) NOT = PS-ALIVE OR (PL-MODE(WS-P) NOT = 0 AND PL-MODE(WS-P) NOT = 2)
             MOVE 1 TO WS-SKIP
         END-IF
         IF WS-SKIP = 0
             MOVE 1 TO WS-FOUND
*>           An active creaking ignores a player who wears a carved pumpkin (item tag gaze_disguise_equipment).
             IF CRK-ACTIVE(L-SLOT) = 1 AND MN-EQUIP-COUNT(WS-P, 4) > 0
                 MOVE MN-EQUIP-ITEM(WS-P, 4) TO WS-ITEM
                 IF WS-ITEM > 0 AND WS-ITEM < IT-COUNT
                     IF IT-KEY(WS-ITEM + 1) = "minecraft:carved_pumpkin" OR "carved_pumpkin"
                         MOVE 1 TO WS-SKIP
                     END-IF
                 END-IF
             END-IF
         END-IF
         IF WS-SKIP = 0
             CALL "CREAKING-LOOKING" USING L-ROW WS-P WS-LOOK
             IF WS-LOOK = 1
                 IF CRK-ACTIVE(L-SLOT) = 1
                     MOVE 0 TO L-CAN
                     MOVE 1 TO WS-DONE
                 ELSE
                     COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                     IF WS-D2 < 144
                         CALL "CREAKING-SET-ACTIVE" USING L-ROW L-SLOT WS-P
                         MOVE 0 TO L-CAN
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-DONE = 0 AND WS-FOUND = 0 AND CRK-ACTIVE(L-SLOT) = 1
         CALL "CREAKING-SET-ACTIVE" USING L-ROW L-SLOT WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM CREAKING-CAN-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-ACTIVE-ATTR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TIME L-FLAG.
     MOVE 0 TO L-FLAG
*>   The timeline `day` of the Overworld: true from the time of day 12600 up to 23400, false from 23401 around to 12599 (17.3).
     IF (L-DIM = 1 OR L-DIM = 3) AND FUNCTION MOD(L-TIME, 24000) >= 12600 AND FUNCTION MOD(L-TIME, 24000) <= 23400
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM CREAKING-ACTIVE-ATTR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CREAKSTATE.
 COPY HEARTSTATE.
 COPY RULES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HEART               BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-GENERIC.
 01 WS-CAN                 BINARY-LONG.
 01 WS-CAN-FLAG            BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   A creaking in its teardown (IS_TEARING_DOWN) counts 45 ticks and is then removed; it does not move meanwhile.
     IF CRK-TEAR(WS-SLOT) > 0
         SUBTRACT 1 FROM CRK-TEAR(WS-SLOT)
         MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW) EN-COOLDOWN(L-ROW)
         IF CRK-TEAR(WS-SLOT) = 0
             CALL "ENTITY-REMOVE" USING L-ROW
         END-IF
         GOBACK
     END-IF
*>   A creaking bound to a heart dies (its health becomes 0) when the heart no longer lists it as its protector.
     IF CRK-HOME(WS-SLOT) = 1
         CALL "HEART-FIND" USING EN-DIM(L-ROW) CRK-HX(WS-SLOT) CRK-HY(WS-SLOT) CRK-HZ(WS-SLOT) WS-ZERO WS-HEART
         IF WS-HEART = 0
             CALL "HEALTH-MOB-DAMAGE" USING L-ROW EN-HEALTH(L-ROW) WS-CAUSE WS-ZERO
             GOBACK
         END-IF
         IF HT-LINK(WS-HEART) NOT = EN-ID(L-ROW)
             CALL "HEALTH-MOB-DAMAGE" USING L-ROW EN-HEALTH(L-ROW) WS-CAUSE WS-ZERO
             GOBACK
         END-IF
     END-IF
*>   Creaking.aiStep: checkCanMove first; a change is sent (metadata 16) and a creaking that must stop stops in place.
     CALL "CREAKING-CAN-MOVE" USING L-ROW WS-SLOT WS-CAN
     IF WS-CAN NOT = CRK-CAN-MOVE(WS-SLOT)
         MOVE WS-CAN TO CRK-CAN-MOVE(WS-SLOT)
         CALL "CREAKING-SEND" USING L-ROW WS-CAN-FLAG WS-CAN
     END-IF
     IF CRK-CAN-MOVE(WS-SLOT) = 0
         MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW) EN-COOLDOWN(L-ROW)
     END-IF
*>   The sensor after it: every 20 ticks.
     SUBTRACT 1 FROM CRK-SENSOR(WS-SLOT)
     IF CRK-SENSOR(WS-SLOT) <= 0
         MOVE 20 TO CRK-SENSOR(WS-SLOT)
         CALL "CREAKING-SENSE" USING L-ROW WS-SLOT
     END-IF
     GOBACK.
 END PROGRAM CREAKING-BRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREAKING-FROZEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CREAKSTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "CRK-FIND" USING EN-ID(L-ROW) WS-ZERO WS-SLOT
     IF WS-SLOT > 0
         IF CRK-CAN-MOVE(WS-SLOT) = 0 OR CRK-TEAR(WS-SLOT) > 0
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CREAKING-FROZEN.
