*> Section test of 36-structures-4-scattered-and-small.md section 6 (igloo; core/src/struct-tpl-gen.cob, struct-tpl-piece.cob) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as
*> a pass without it). The expectations are the document's: the piece table of 6.2 (template, rotation pivot, position offset, size), the worked example of 12.4 (chunk origin (160, 96), n = 6: the
*> laboratory at (160, 69, 94), five ladders at (162, 87 - 3 i, 100), the top at (160, 90, 96); the offsets are not rotated), the reference point and the move of 6.3 steps 1 to 3 (rotation 2.2 with the
*> piece's pivot; the position moves by h - 91 and the saved TPY stays the construction value) and the snow block of 6.3 step 5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-4-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPROC.
 COPY STRUCTSET.
 COPY STRUCTPLACE.
 COPY GENENT.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-PROC-KEY            PIC X(80) VALUE "cobolcraft:inline/ignore_structure_block".
 01 WS-ROW                 BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-OFX                 BINARY-LONG.
 01 WS-OFZ                 BINARY-LONG.
 01 WS-PVX                 BINARY-LONG.
 01 WS-PVZ                 BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-REFX                BINARY-LONG.
 01 WS-REFZ                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HKIND               BINARY-LONG VALUE 0.
 01 WS-OLD-Y               BINARY-LONG.
 01 WS-WANT-Y              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ED                  PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-ED3                 PIC -(5)9.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-WCZ                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-NO-PROPS            PIC X(600) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-LADDER              BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG VALUE 1.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LAST-X              BINARY-LONG.
 01 WS-LAST-Y              BINARY-LONG.
 01 WS-LAST-Z              BINARY-LONG.
 01 WS-WANT-X              BINARY-LONG.
 01 WS-WANT-Z              BINARY-LONG.
 01 WS-WANT-PY             BINARY-LONG.
 01 WS-PIV-OK              BINARY-LONG.
 01 WS-ER                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ZV                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-ID                  PIC X(96).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-4§6 Igloo: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-LIST
     PERFORM TABLE-CASES
     PERFORM EXAMPLE-CASES
     PERFORM MOVE-CASES
     PERFORM SNOW-CASES
     PERFORM ENTITY-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 6.2: template, size, rotation pivot and the liquid setting of each piece kind; the position offset is checked by the example below
 TABLE-CASES.
     CALL "SPB-RESET"
     MOVE 160 TO WS-X0
     MOVE 96 TO WS-Z0
     MOVE 2 TO WS-ROT
     MOVE 1 TO WS-KIND
     MOVE 0 TO WS-DEPTH
     CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
     MOVE 2 TO WS-KIND
     CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
     MOVE 3 TO WS-KIND
     CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
     MOVE SP-T-ROW(1) TO WS-ROW
     MOVE "acceptance US12 36-4§6.2 Igloo: igloo/top is 7 x 5 x 8 with the pivot (3,5,5), ignore_waterlogging, rotation as given" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF TP-KEY(WS-ROW) = "minecraft:igloo/top" AND TP-SX(WS-ROW) = 7 AND TP-SY(WS-ROW) = 5 AND TP-SZ(WS-ROW) = 8
        AND SP-T-PIV-X(1) = 3 AND SP-T-PIV-Y(1) = 5 AND SP-T-PIV-Z(1) = 5 AND SP-T-LIQ(1) = 1 AND SP-T-ROT(1) = 2 AND SP-T-MIR(1) = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE SP-T-ROW(2) TO WS-ROW
     MOVE "acceptance US12 36-4§6.2 Igloo: igloo/middle is 3 x 3 x 3 with the pivot (1,3,1), ignore_waterlogging" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF TP-KEY(WS-ROW) = "minecraft:igloo/middle" AND TP-SX(WS-ROW) = 3 AND TP-SY(WS-ROW) = 3 AND TP-SZ(WS-ROW) = 3
        AND SP-T-PIV-X(2) = 1 AND SP-T-PIV-Y(2) = 3 AND SP-T-PIV-Z(2) = 1 AND SP-T-LIQ(2) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE SP-T-ROW(3) TO WS-ROW
     MOVE "acceptance US12 36-4§6.2 Igloo: igloo/bottom is 7 x 6 x 9 with the pivot (3,6,7), ignore_waterlogging" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF TP-KEY(WS-ROW) = "minecraft:igloo/bottom" AND TP-SX(WS-ROW) = 7 AND TP-SY(WS-ROW) = 6 AND TP-SZ(WS-ROW) = 9
        AND SP-T-PIV-X(3) = 3 AND SP-T-PIV-Y(3) = 6 AND SP-T-PIV-Z(3) = 7 AND SP-T-LIQ(3) = 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-4§6.2 Igloo: the processor of each piece is the ignore list of STRUCTURE_BLOCK only" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SPL-KEY(SP-T-PROC(1)) = "cobolcraft:inline/ignore_structure_block" AND SP-T-PROC(1) = SP-T-PROC(2) AND SP-T-PROC(2) = SP-T-PROC(3)
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 12.4: chunk origin (160, 96), pos (160, 90, 96), n = 6: the laboratory with depth offset 18 at (160, 69, 94), the ladders i = 0 to 4 at (162, 87 - 3 i, 100), the top at (160, 90, 96);
*> the offsets are world-axis offsets, not rotated: the same positions in every rotation
 EXAMPLE-CASES.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         CALL "SPB-RESET"
         MOVE 3 TO WS-KIND
         MOVE 18 TO WS-DEPTH
         CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
         IF SP-T-X(1) NOT = 160 OR SP-T-Y(1) NOT = 69 OR SP-T-Z(1) NOT = 94
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
             MOVE 2 TO WS-KIND
             COMPUTE WS-DEPTH = WS-I * 3
             CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
             COMPUTE WS-J = WS-I + 2
             COMPUTE WS-WANT-Y = 87 - 3 * WS-I
             IF SP-T-X(WS-J) NOT = 162 OR SP-T-Y(WS-J) NOT = WS-WANT-Y OR SP-T-Z(WS-J) NOT = 100
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE 1 TO WS-KIND
         MOVE 0 TO WS-DEPTH
         CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
         IF SP-COUNT NOT = 7 OR SP-T-X(7) NOT = 160 OR SP-T-Y(7) NOT = 90 OR SP-T-Z(7) NOT = 96
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§12 Igloo basement positions: laboratory, five ladders and the top of the worked example, in all four rotations (7 pieces)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 6.3 steps 1 to 3 for each piece kind and rotation at six chunk origins: the reference point (3 - ox, 0, -oz) transformed by the piece's own rotation and pivot (36-6 2.2), the surface height h there,
*> the move to h - 91 and the construction y kept for the end of the pass
 MOVE-CASES.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 5
         COMPUTE WS-X0 = WS-K * 96 - 200
         COMPUTE WS-Z0 = 400 - WS-K * 64
         PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
             PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 3
                 CALL "SPB-RESET"
                 MOVE 6 TO WS-DEPTH
                 IF WS-KIND = 1
                     MOVE 0 TO WS-DEPTH
                 END-IF
                 CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
                 EVALUATE WS-KIND
                     WHEN 1
                         MOVE 0 TO WS-OFX
                         MOVE 0 TO WS-OFZ
                         MOVE 3 TO WS-PVX
                         MOVE 5 TO WS-PVZ
                     WHEN 2
                         MOVE 2 TO WS-OFX
                         MOVE 4 TO WS-OFZ
                         MOVE 1 TO WS-PVX
                         MOVE 1 TO WS-PVZ
                     WHEN OTHER
                         MOVE 0 TO WS-OFX
                         COMPUTE WS-OFZ = 0 - 2
                         MOVE 3 TO WS-PVX
                         MOVE 7 TO WS-PVZ
                 END-EVALUATE
*>               the point (3 - ox, -oz) through the rotation about the pivot (2.2 of 36-6)
                 COMPUTE WS-OX = 3 - WS-OFX
                 COMPUTE WS-OZ = 0 - WS-OFZ
                 EVALUATE WS-ROT
                     WHEN 0
                         MOVE WS-OX TO WS-RX
                         MOVE WS-OZ TO WS-RZ
                     WHEN 1
                         COMPUTE WS-RX = WS-PVX + WS-PVZ - WS-OZ
                         COMPUTE WS-RZ = WS-PVZ - WS-PVX + WS-OX
                     WHEN 2
                         COMPUTE WS-RX = 2 * WS-PVX - WS-OX
                         COMPUTE WS-RZ = 2 * WS-PVZ - WS-OZ
                     WHEN OTHER
                         COMPUTE WS-RX = WS-PVX - WS-PVZ + WS-OZ
                         COMPUTE WS-RZ = WS-PVX + WS-PVZ - WS-OX
                 END-EVALUATE
                 COMPUTE WS-REFX = SP-T-X(1) + WS-RX
                 COMPUTE WS-REFZ = SP-T-Z(1) + WS-RZ
                 CALL "STRUCT-BASE-HEIGHT" USING WS-REFX WS-REFZ WS-HKIND WS-H
                 MOVE SP-T-Y(1) TO WS-OLD-Y
                 COMPUTE WS-WANT-Y = WS-OLD-Y + (WS-H - 90) - 1
                 CALL "STRUCT-TPL-PRE" USING WS-ONE
                 IF SP-T-Y(1) NOT = WS-WANT-Y OR SP-F1(1) NOT = WS-OLD-Y
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-4§6.3 Igloo: 72 pieces (kind, rotation, origin) move by h - 91 from the surface height at their own reference point and keep the construction y" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 6.3 step 5: the snow block at q = templatePosition + transform((3, 0, 5)) of the top piece when the block below is neither air nor a ladder (stone: yes; air: no; ladder: no)
 SNOW-CASES.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE "stone" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-NO-PROPS WS-STONE
     MOVE "ladder" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-NO-PROPS WS-LADDER
     MOVE "snow_block" TO WS-KEY
     CALL "STRUCT-TPL-STATE" USING WS-KEY WS-NO-PROPS WS-SNOW
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         CALL "SPB-RESET"
         MOVE 4 TO WS-X0
         MOVE 4 TO WS-Z0
         MOVE 1 TO WS-KIND
         MOVE 0 TO WS-DEPTH
         CALL "STRUCT-IGLOO-ADD" USING WS-X0 WS-Z0 WS-ROT WS-KIND WS-DEPTH WS-LIST
         MOVE 70 TO SP-T-Y(1)
         MOVE 70 TO SP-F1(1)
*>       q: (3, 0, 5) through the rotation about the pivot (3, 5)
         EVALUATE WS-ROT
             WHEN 0
                 MOVE 3 TO WS-RX
                 MOVE 5 TO WS-RZ
             WHEN 1
                 COMPUTE WS-RX = 3 + 5 - 5
                 COMPUTE WS-RZ = 5 - 3 + 3
             WHEN 2
                 COMPUTE WS-RX = 2 * 3 - 3
                 COMPUTE WS-RZ = 2 * 5 - 5
             WHEN OTHER
                 COMPUTE WS-RX = 3 - 5 + 5
                 COMPUTE WS-RZ = 3 + 5 - 3
         END-EVALUATE
         COMPUTE WS-QX = SP-T-X(1) + WS-RX
         COMPUTE WS-QY = 70
         COMPUTE WS-QZ = SP-T-Z(1) + WS-RZ
         COMPUTE WS-BELOW = WS-QY - 1
         PERFORM CLEAR-CELLS
         CALL "FL-SET-STATE" USING WS-QX WS-BELOW WS-QZ WS-STONE WS-THREE WS-OX
         CALL "STRUCT-TPL-AFTER" USING WS-ONE WS-RESULT
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         MOVE WS-ROT TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§6.3 Igloo: rotation " FUNCTION TRIM(WS-ED) " puts a snow block at q over stone" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-STATE = WS-SNOW
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         PERFORM CLEAR-CELLS
         CALL "FL-SET-STATE" USING WS-QX WS-BELOW WS-QZ WS-LADDER WS-THREE WS-OX
         CALL "STRUCT-TPL-AFTER" USING WS-ONE WS-RESULT
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§6.3 Igloo: rotation " FUNCTION TRIM(WS-ED) " puts no snow over a ladder" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-STATE NOT = WS-SNOW
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
         PERFORM CLEAR-CELLS
         CALL "STRUCT-TPL-AFTER" USING WS-ONE WS-RESULT
         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§6.3 Igloo: rotation " FUNCTION TRIM(WS-ED) " puts no snow over air" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-STATE NOT = WS-SNOW
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
     END-PERFORM.

*> air in the cells of the window at the layers 68 to 71
 CLEAR-CELLS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 * 256
         COMPUTE WS-J = (68 - WS-MIN-Y) * 256 + WS-I
         MOVE 0 TO CE-STATE(WS-J)
     END-PERFORM.

*> 6.3 and 2.8: igloo/bottom placed at (4, 60, 1) with each rotation and the pivot (3, 6, 7), ignore_waterlogging, finalizeEntities off: its two entities (a villager and a zombie villager) are asked
*> for at the positions of the table of 2.8 (x' = px + pz + 1 - z, z' = pz - px + x for clockwise 90; 2 px + 1 - x, 2 pz + 1 - z for 180; px - pz + z, px + pz + 1 - x for counterclockwise 90),
*> moved by the template position
 ENTITY-CASES.
     MOVE "minecraft:igloo/bottom" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE 3 TO WS-PX
     MOVE 7 TO WS-PZ
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
         CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
         SET ADDRESS OF CE-CHUNK TO WS-PTR
         CALL "MSP-OPEN"
         MOVE 0 TO GEL-COUNT GEL-LOST
         INITIALIZE STRUCT-SETTINGS
         MOVE WS-ROT TO PS-ROTATION
         MOVE WS-PX TO PS-PIVOT-X
         MOVE WS-PZ TO PS-PIVOT-Z
         MOVE 1 TO PS-LIQUID
         MOVE WS-LIST TO PS-PROCESSORS
         MOVE 1 TO PS-BOX-SET
         MOVE SW-X0 TO PS-BOX(1)
         MOVE SW-Y0 TO PS-BOX(2)
         MOVE SW-Z0 TO PS-BOX(3)
         MOVE SW-X1 TO PS-BOX(4)
         MOVE SW-Y1 TO PS-BOX(5)
         MOVE SW-Z1 TO PS-BOX(6)
         MOVE 4 TO WS-TX
         MOVE 60 TO WS-TY
         MOVE 1 TO WS-TZ
         MOVE 4 TO WS-AX
         MOVE 60 TO WS-AY
         MOVE 1 TO WS-AZ
         CALL "STRUCT-PLACE" USING WS-ROW WS-TX WS-TY WS-TZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT
         IF GEL-COUNT NOT = 2 OR TP-ENT-N(WS-ROW) NOT = 2
             ADD 1 TO WS-BAD
         ELSE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-ER = TP-ENT-BASE(WS-ROW) + WS-K
                 EVALUATE WS-ROT
                     WHEN 0
                         COMPUTE WS-FX = TE-PX(WS-ER)
                         COMPUTE WS-FZ = TE-PZ(WS-ER)
                     WHEN 1
                         COMPUTE WS-FX = WS-PX + WS-PZ + 1 - TE-PZ(WS-ER)
                         COMPUTE WS-FZ = WS-PZ - WS-PX + TE-PX(WS-ER)
                     WHEN 2
                         COMPUTE WS-FX = 2 * WS-PX + 1 - TE-PX(WS-ER)
                         COMPUTE WS-FZ = 2 * WS-PZ + 1 - TE-PZ(WS-ER)
                     WHEN OTHER
                         COMPUTE WS-FX = WS-PX - WS-PZ + TE-PZ(WS-ER)
                         COMPUTE WS-FZ = WS-PX + WS-PZ + 1 - TE-PX(WS-ER)
                 END-EVALUATE
                 COMPUTE WS-FX = WS-FX + WS-TX
                 COMPUTE WS-FZ = WS-FZ + WS-TZ
                 IF FUNCTION ABS(GEL-X(WS-K) - WS-FX) > 0.0001 OR FUNCTION ABS(GEL-Z(WS-K) - WS-FZ) > 0.0001
                    OR FUNCTION ABS(GEL-Y(WS-K) - (TE-PY(WS-ER) + WS-TY)) > 0.0001
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
             MOVE 0 TO WS-ZV
             INSPECT GEL-NBT(1) TALLYING WS-ZV FOR ALL "zombie_villager"
             INSPECT GEL-NBT(2) TALLYING WS-ZV FOR ALL "zombie_villager"
             IF WS-ZV NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§6.3 Igloo: the basement's villager and zombie villager are asked for at the 2.8 positions in all four rotations" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-36-4-6.

 COPY NOSPAWN.
 COPY CORETEST.
