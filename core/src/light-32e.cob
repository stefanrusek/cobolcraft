*> The light engine of docs/protocol/32-light-engine.md, sections 7 to 9 (T0692, T0694, T0696): the block-state overrides, when the engine is fed (block
*> changes, the client, the server's task batches, chunk generation stages, stored light) and the packaging state of a layer.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-BLOCK-RULES.
*> USING block class name (PIC X(32), the class names of 7), solidRender (the occlusion shape is a full block), the default propagatesSkylightDown, the fluid
*> is empty, waterlogged, slab type is DOUBLE, `extended` property; gives getLightDampening, propagatesSkylightDown and useShapeForLightOcclusion (7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "LeavesBlock".
    05 FILLER              PIC X(32) VALUE "TintedGlassBlock".
    05 FILLER              PIC X(32) VALUE "LiquidBlock".
    05 FILLER              PIC X(32) VALUE "PipeBlock".
    05 FILLER              PIC X(32) VALUE "ShulkerBoxBlock".
    05 FILLER              PIC X(32) VALUE "BambooStalkBlock".
    05 FILLER              PIC X(32) VALUE "HangingMossBlock".
    05 FILLER              PIC X(32) VALUE "MossyCarpetBlock".
    05 FILLER              PIC X(32) VALUE "TransparentBlock".
    05 FILLER              PIC X(32) VALUE "VineBlock".
    05 FILLER              PIC X(32) VALUE "BarrierBlock".
    05 FILLER              PIC X(32) VALUE "GlowLichenBlock".
    05 FILLER              PIC X(32) VALUE "LightBlock".
    05 FILLER              PIC X(32) VALUE "VegetationBlock".
    05 FILLER              PIC X(32) VALUE "CrossCollisionBlock".
    05 FILLER              PIC X(32) VALUE "WallBlock".
    05 FILLER              PIC X(32) VALUE "SlabBlock".
    05 FILLER              PIC X(32) VALUE "StairBlock".
    05 FILLER              PIC X(32) VALUE "SnowLayerBlock".
    05 FILLER              PIC X(32) VALUE "DaylightDetectorBlock".
    05 FILLER              PIC X(32) VALUE "EnchantingTableBlock".
    05 FILLER              PIC X(32) VALUE "EndPortalFrameBlock".
    05 FILLER              PIC X(32) VALUE "FarmlandBlock".
    05 FILLER              PIC X(32) VALUE "LecternBlock".
    05 FILLER              PIC X(32) VALUE "PathBlock".
    05 FILLER              PIC X(32) VALUE "SculkSensorBlock".
    05 FILLER              PIC X(32) VALUE "SculkShriekerBlock".
    05 FILLER              PIC X(32) VALUE "ShelfBlock".
    05 FILLER              PIC X(32) VALUE "StonecutterBlock".
    05 FILLER              PIC X(32) VALUE "PistonHeadBlock".
    05 FILLER              PIC X(32) VALUE "PistonBaseBlock".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 31 TIMES.
 01 WS-CATS.
    05 FILLER              PIC X(31) VALUE "1233344444555566788888888888889".
 01 WS-CAT-TABLE REDEFINES WS-CATS.
    05 WS-CAT              PIC 9 OCCURS 31 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-CATEGORY            BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(32).
 01 L-SOLID                BINARY-LONG.
 01 L-PROP-DEFAULT         BINARY-LONG.
 01 L-FLUID-EMPTY          BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-DOUBLE               BINARY-LONG.
 01 L-EXTENDED             BINARY-LONG.
 01 L-DAMPENING            BINARY-LONG.
 01 L-PROPAGATES           BINARY-LONG.
 01 L-USE-SHAPE            BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-SOLID L-PROP-DEFAULT L-FLUID-EMPTY L-WATERLOGGED L-DOUBLE L-EXTENDED
         L-DAMPENING L-PROPAGATES L-USE-SHAPE.
     MOVE 0 TO WS-CATEGORY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         IF L-CLASS = WS-NAME(WS-I)
             MOVE WS-CAT(WS-I) TO WS-CATEGORY
         END-IF
     END-PERFORM
     MOVE L-PROP-DEFAULT TO L-PROPAGATES
     MOVE 0 TO L-USE-SHAPE
     MOVE -1 TO WS-OVERRIDE
     EVALUATE WS-CATEGORY
         WHEN 1
             MOVE 1 TO WS-OVERRIDE
         WHEN 2
             MOVE 15 TO WS-OVERRIDE
             MOVE 0 TO L-PROPAGATES
         WHEN 3
             MOVE 0 TO L-PROPAGATES
         WHEN 4
             MOVE 1 TO L-PROPAGATES
         WHEN 5
             MOVE L-FLUID-EMPTY TO L-PROPAGATES
         WHEN 6
             COMPUTE L-PROPAGATES = 1 - L-WATERLOGGED
         WHEN 7
             COMPUTE L-USE-SHAPE = 1 - L-DOUBLE
         WHEN 8
             MOVE 1 TO L-USE-SHAPE
         WHEN 9
             MOVE L-EXTENDED TO L-USE-SHAPE
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-OVERRIDE >= 0
             MOVE WS-OVERRIDE TO L-DAMPENING
         WHEN L-SOLID = 1
             MOVE 15 TO L-DAMPENING
         WHEN L-PROPAGATES = 1
             MOVE 0 TO L-DAMPENING
         WHEN OTHER
             MOVE 1 TO L-DAMPENING
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-BLOCK-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHECK-COUNT.
*> USING layer; gives the number of positions in the engine's check set (4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COUNT.
     MOVE QU-CK-N(L-K) TO L-COUNT
     GOBACK.
 END PROGRAM L32-CHECK-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-EMPTY-NOTE.
*> USING section x, y, z; gives the last onSectionEmptinessChanged notification the chunk source got for the section: 0 none, 1 became empty, 2 became
*> non-empty (8.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-NOTE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-NOTE.
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     MOVE EN-EMPTYNOTE(WS-SID) TO L-NOTE
     GOBACK.
 END PROGRAM L32-EMPTY-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DIRTY-AT.
*> USING section x, y, z; gives 1 when the client has marked the render section dirty (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-DIRTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-DIRTY.
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     MOVE EN-DIRTY(WS-SID) TO L-DIRTY
     GOBACK.
 END PROGRAM L32-DIRTY-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-COLUMN-FLAGS.
*> USING layer, chunk x, chunk z; gives the column's light-enabled flag, its retain-data flag (6.5) and the chunk's light-correct flag (8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-RETAIN               BINARY-LONG.
 01 L-CORRECT              BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-CX L-CZ L-ON L-RETAIN L-CORRECT.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     MOVE LY-ON(L-K, WS-COL) TO L-ON
     MOVE LY-RETAIN(L-K, WS-COL) TO L-RETAIN
     MOVE EN-LIGHT-CORRECT(WS-COL) TO L-CORRECT
     GOBACK.
 END PROGRAM L32-COLUMN-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PAST-INIT.
*> USING chunk x, chunk z, flag: records whether the chunk's generation status is at or after INITIALIZE_LIGHT (8.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-FLAG.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     MOVE L-FLAG TO EN-PAST-INIT(WS-COL)
     GOBACK.
 END PROGRAM L32-PAST-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-UPDATE-STATUS-BOTH.
*> USING section x, y, z, section is empty: LevelLightEngine.updateSectionStatus: forwarded to the block engine and to the sky engine when it exists (1, 6.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-EMPTY.
     CALL "L32-STORAGE-STATUS" USING WS-LAYER L-SX L-SY L-SZ L-EMPTY
     IF EN-SKY-ON = 1
         CALL "L32-STORAGE-STATUS" USING WS-SKY L-SX L-SY L-SZ L-EMPTY
     END-IF
     GOBACK.
 END PROGRAM L32-UPDATE-STATUS-BOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHECK-BOTH.
*> USING x, y, z: LevelLightEngine.checkBlock: forwarded to the block engine and to the sky engine when it exists (1, 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z.
     CALL "L32-CHECK-BLOCK" USING WS-LAYER L-X L-Y L-Z
     IF EN-SKY-ON = 1
         CALL "L32-CHECK-BLOCK" USING WS-SKY L-X L-Y L-Z
     END-IF
     GOBACK.
 END PROGRAM L32-CHECK-BOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-RETAIN-BOTH.
*> USING chunk x, chunk z, flag: retainData on both engines (6.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-FLAG.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     MOVE L-FLAG TO LY-RETAIN(1, WS-COL)
     IF EN-SKY-ON = 1
         MOVE L-FLAG TO LY-RETAIN(2, WS-COL)
     END-IF
     GOBACK.
 END PROGRAM L32-RETAIN-BOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-RUN-BOTH.
*> USING nothing but the result: LevelLightEngine.runLightUpdates: the block engine, then the sky engine when it exists; gives the pairs processed (1, 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAIRS                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAIRS.
     CALL "L32-RUN-UPDATES" USING WS-LAYER L-PAIRS
     IF EN-SKY-ON = 1
         CALL "L32-RUN-UPDATES" USING WS-SKY WS-N
         ADD WS-N TO L-PAIRS
     END-IF
     GOBACK.
 END PROGRAM L32-RUN-BOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SET-BLOCK.
*> USING mode (0 LevelChunk.setBlockState, 1 ProtoChunk.setBlockState), x, y, z, new state id: stores the state in an available chunk and feeds the engines
*> (8.1). Nothing for a Y outside the build height or an identical state. Light work (LevelChunk always, ProtoChunk once the status is at or after
*> INITIALIZE_LIGHT): updateSectionStatus on both engines when the section's only-air status changed (LevelChunk also tells the chunk source), then when
*> hasDifferentLightProperties: the sky source table update and checkBlock on both engines.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-RM                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-WAS-EMPTY           BINARY-LONG.
 01 WS-NOW-EMPTY           BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-WORK                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-X L-Y L-Z L-STATE.
     IF L-Y >= EN-MINY AND L-Y < EN-MINY + EN-NS * 16
         CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
         CALL "L32-STATE-AT" USING L-X L-Y L-Z WS-OLD
         IF WS-OLD NOT = L-STATE
             COMPUTE WS-RM = FUNCTION MOD(L-X, 16)
             COMPUTE WS-SX = (L-X - WS-RM) / 16
             COMPUTE WS-RM = FUNCTION MOD(L-Z, 16)
             COMPUTE WS-SZ = (L-Z - WS-RM) / 16
             COMPUTE WS-SY = (L-Y - EN-MINY) / 16 + EN-MINSEC
             COMPUTE WS-SEC = (WS-COL - 1) * EN-NS + WS-SY - EN-MINSEC + 1
             MOVE 0 TO WS-WAS-EMPTY WS-NOW-EMPTY
             IF EN-NONAIR(WS-SEC) = 0
                 MOVE 1 TO WS-WAS-EMPTY
             END-IF
             CALL "L32-SET-CELL" USING L-X L-Y L-Z L-STATE
             IF EN-NONAIR(WS-SEC) = 0
                 MOVE 1 TO WS-NOW-EMPTY
             END-IF
             CALL "L32-DIFF-PROPS" USING WS-OLD L-STATE WS-DIFF
             MOVE 1 TO WS-WORK
             IF L-MODE = 1
                 MOVE EN-PAST-INIT(WS-COL) TO WS-WORK
             END-IF
             IF WS-WORK = 1
                 IF WS-WAS-EMPTY NOT = WS-NOW-EMPTY
                     CALL "L32-UPDATE-STATUS-BOTH" USING WS-SX WS-SY WS-SZ WS-NOW-EMPTY
                     IF L-MODE = 0
                         CALL "L32-SECTION-ID" USING WS-SX WS-SY WS-SZ WS-SID WS-COL
                         COMPUTE EN-EMPTYNOTE(WS-SID) = 2 - WS-NOW-EMPTY
                     END-IF
                 END-IF
                 IF WS-DIFF = 1
                     CALL "L32-SKY-UPDATE" USING L-X L-Y L-Z WS-CHANGED
                     CALL "L32-CHECK-BOTH" USING L-X L-Y L-Z
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SET-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-MARK-DIRTY.
*> USING section x, y, z: marks the render section and its 26 neighbours dirty (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ.
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-X = L-SX + WS-DX
                 COMPUTE WS-Y = L-SY + WS-DY
                 COMPUTE WS-Z = L-SZ + WS-DZ
                 CALL "L32-SECTION-ID" USING WS-X WS-Y WS-Z WS-SID WS-COL
                 IF WS-SID > 0
                     MOVE 1 TO EN-DIRTY(WS-SID)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM L32-MARK-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-APPLY-LIGHT.
*> USING chunk x, chunk z, mark dirty, sky mask, sky empty mask, block mask, block empty mask, the arrays (PIC X(24576): the layers taken by set mask bits,
*> sky list first, 2048 bytes each): the apply step of a light packet (8.2). For each light section index i (section Y = i - 1) of each list: a set mask bit
*> queues a layer copied from the next array, else a set empty bit an all-zero layer, else nothing; the sky list does nothing when the sky engine is
*> missing; with mark dirty the updated section and its neighbours are marked dirty; light is enabled for the chunk at the end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-J                   BINARY-LONG.
 01 WS-LST                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-MBIT                BINARY-LONG.
 01 WS-EBIT                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-APPLY               BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-DIRTY                BINARY-LONG.
 01 L-SKY-MASK             BINARY-LONG.
 01 L-SKY-EMPTY            BINARY-LONG.
 01 L-BLOCK-MASK           BINARY-LONG.
 01 L-BLOCK-EMPTY          BINARY-LONG.
 01 L-DATA                 PIC X(24576).
 PROCEDURE DIVISION USING L-CX L-CZ L-DIRTY L-SKY-MASK L-SKY-EMPTY L-BLOCK-MASK L-BLOCK-EMPTY L-DATA.
     MOVE 0 TO WS-J
     PERFORM VARYING WS-LST FROM 1 BY 1 UNTIL WS-LST > 2
         MOVE 2 TO WS-K
         MOVE L-SKY-MASK TO WS-MASK
         MOVE L-SKY-EMPTY TO WS-EMPTY
         IF WS-LST = 2
             MOVE 1 TO WS-K
             MOVE L-BLOCK-MASK TO WS-MASK
             MOVE L-BLOCK-EMPTY TO WS-EMPTY
         END-IF
         MOVE 1 TO WS-POW
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
             DIVIDE WS-MASK BY WS-POW GIVING WS-T
             DIVIDE WS-T BY 2 GIVING WS-Q REMAINDER WS-MBIT
             DIVIDE WS-EMPTY BY WS-POW GIVING WS-T
             DIVIDE WS-T BY 2 GIVING WS-Q REMAINDER WS-EBIT
             COMPUTE WS-POW = WS-POW * 2
             COMPUTE WS-SY = WS-I - 1
             CALL "L32-SECTION-ID" USING L-CX WS-SY L-CZ WS-SID WS-COL
             MOVE 0 TO WS-APPLY
             IF WS-MBIT = 1
                 COMPUTE WS-OFF = WS-J * 2048 + 1
                 ADD 1 TO WS-J
                 IF WS-LST = 2 OR EN-SKY-ON = 1
                     MOVE L-DATA(WS-OFF:2048) TO LY-QD(WS-K, WS-SID)
                     MOVE 1 TO WS-APPLY
                 END-IF
             END-IF
             IF WS-MBIT = 0 AND WS-EBIT = 1 AND (WS-LST = 2 OR EN-SKY-ON = 1)
                 MOVE LOW-VALUES TO LY-QD(WS-K, WS-SID)
                 MOVE 1 TO WS-APPLY
             END-IF
             IF WS-APPLY = 1
                 MOVE 1 TO LY-QP(WS-K, WS-SID)
                 MOVE 1 TO LY-INCONS(WS-K)
                 IF L-DIRTY = 1
                     CALL "L32-MARK-DIRTY" USING L-CX WS-SY L-CZ
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "L32-SET-LIGHT-ENABLED" USING L-CX L-CZ WS-ONE
     GOBACK.
 END PROGRAM L32-APPLY-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-ENABLE-CHUNK-LIGHT.
*> USING chunk x, chunk z: ClientLevel enableChunkLight (8.2): updateSectionStatus(section, hasOnlyAir) for every block section, then the sections of the
*> 3 x 3 columns around the chunk are marked dirty for rendering.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SY                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     PERFORM VARYING WS-SY FROM EN-MINSEC BY 1 UNTIL WS-SY >= EN-MINSEC + EN-NS
         MOVE 0 TO WS-EMPTY
         IF EN-NONAIR((WS-COL - 1) * EN-NS + WS-SY - EN-MINSEC + 1) = 0
             MOVE 1 TO WS-EMPTY
         END-IF
         CALL "L32-UPDATE-STATUS-BOTH" USING L-CX WS-SY L-CZ WS-EMPTY
     END-PERFORM
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             PERFORM VARYING WS-SY FROM EN-LOWL BY 1 UNTIL WS-SY >= EN-LOWL + EN-NL
                 COMPUTE WS-X = L-CX + WS-DX
                 COMPUTE WS-Z = L-CZ + WS-DZ
                 CALL "L32-SECTION-ID" USING WS-X WS-SY WS-Z WS-SID WS-COL
                 IF WS-SID > 0
                     MOVE 1 TO EN-DIRTY(WS-SID)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM L32-ENABLE-CHUNK-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-FORGET-CHUNK.
*> USING chunk x, chunk z: the client's forget-chunk task (8.2): setLightEnabled(false), a null layer queued for every light section of both engines (this
*> clears queued data), and every block section reported empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SY                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 01 WS-NULL                BINARY-LONG VALUE -1.
 01 WS-EMPTY               BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     CALL "L32-SET-LIGHT-ENABLED" USING L-CX L-CZ WS-OFF
     PERFORM VARYING WS-SY FROM EN-LOWL BY 1 UNTIL WS-SY >= EN-LOWL + EN-NL
         CALL "L32-QUEUE-DATA" USING WS-LAYER L-CX WS-SY L-CZ WS-NULL
         IF EN-SKY-ON = 1
             CALL "L32-QUEUE-DATA" USING WS-SKY L-CX WS-SY L-CZ WS-NULL
         END-IF
     END-PERFORM
     PERFORM VARYING WS-SY FROM EN-MINSEC BY 1 UNTIL WS-SY >= EN-MINSEC + EN-NS
         CALL "L32-UPDATE-STATUS-BOTH" USING L-CX WS-SY L-CZ WS-EMPTY
     END-PERFORM
     GOBACK.
 END PROGRAM L32-FORGET-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHUNK-UNLOAD.
*> USING chunk x, chunk z: ClientLevel.unload: setLightEnabled(false) (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     CALL "L32-SET-LIGHT-ENABLED" USING L-CX L-CZ WS-OFF
     GOBACK.
 END PROGRAM L32-CHUNK-UNLOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-POLL-COUNT.
*> USING queued task count n; gives the tasks pollLightUpdates runs (8.2): all n when n >= 1000, else max(10, n / 10) but never more than n.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-TASKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-TASKS.
     MOVE L-N TO L-TASKS
     IF L-N < 1000
         COMPUTE L-TASKS = L-N / 10
         IF L-TASKS < 10
             MOVE 10 TO L-TASKS
         END-IF
         IF L-TASKS > L-N
             MOVE L-N TO L-TASKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-POLL-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CLIENT-QUEUE.
*> USING task kind (1 enable chunk light, 2 forget chunk, 3 unload), chunk x, chunk z: ClientLevel.queueLightUpdate appends a task to the deque (8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-CX L-CZ.
     ADD 1 TO EN-CT-N
     MOVE L-KIND TO CT-KIND(EN-CT-N)
     MOVE L-CX TO CT-CX(EN-CT-N)
     MOVE L-CZ TO CT-CZ(EN-CT-N)
     GOBACK.
 END PROGRAM L32-CLIENT-QUEUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CLIENT-UPDATE.
*> USING nothing but the results: ClientLevel.update (8.2), once per rendered frame: pollLightUpdates runs the first L32-POLL-COUNT tasks of the deque, then the
*> light engines run once; gives the tasks run and the engine pairs processed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RAN                  BINARY-LONG.
 01 L-PAIRS                BINARY-LONG.
 PROCEDURE DIVISION USING L-RAN L-PAIRS.
     CALL "L32-POLL-COUNT" USING EN-CT-N L-RAN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-RAN
         EVALUATE CT-KIND(WS-I)
             WHEN 1
                 CALL "L32-ENABLE-CHUNK-LIGHT" USING CT-CX(WS-I) CT-CZ(WS-I)
             WHEN 2
                 CALL "L32-FORGET-CHUNK" USING CT-CX(WS-I) CT-CZ(WS-I)
             WHEN 3
                 CALL "L32-CHUNK-UNLOAD" USING CT-CX(WS-I) CT-CZ(WS-I)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-CT-N - L-RAN
         COMPUTE WS-FROM = WS-I + L-RAN
         MOVE EN-CT(WS-FROM) TO EN-CT(WS-I)
     END-PERFORM
     SUBTRACT L-RAN FROM EN-CT-N
     CALL "L32-RUN-BOTH" USING L-PAIRS
     GOBACK.
 END PROGRAM L32-CLIENT-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SERVER-SUBMIT.
*> USING phase (0 PRE_UPDATE, 1 POST_UPDATE), kind, a, b, c, d, e: ThreadedLevelLightEngine: every call becomes a task (8.3). Kinds and arguments: 1 checkBlock
*> (x y z), 2 updateSectionStatus (section x y z, empty), 3 setLightEnabled (chunk x z, flag), 4 propagateLightSources (chunk x z), 5 queueSectionData
*> (layer, section x y z, fill or -1), 6 retainData (chunk x z, flag), 7 updateChunkStatus (chunk x z), 8 setLightCorrect (chunk x z, flag).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-KIND L-A L-B L-C L-D L-E.
     ADD 1 TO EN-TK-N
     MOVE L-PHASE TO TK-PHASE(EN-TK-N)
     MOVE L-KIND TO TK-KIND(EN-TK-N)
     MOVE L-A TO TK-A(EN-TK-N)
     MOVE L-B TO TK-B(EN-TK-N)
     MOVE L-C TO TK-C(EN-TK-N)
     MOVE L-D TO TK-D(EN-TK-N)
     MOVE L-E TO TK-E(EN-TK-N)
     GOBACK.
 END PROGRAM L32-SERVER-SUBMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SERVER-EXEC.
*> USING kind, a, b, c, d, e: runs one task of L32-SERVER-SUBMIT (8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-A L-B L-C L-D L-E.
     EVALUATE L-KIND
         WHEN 1
             CALL "L32-CHECK-BOTH" USING L-A L-B L-C
         WHEN 2
             CALL "L32-UPDATE-STATUS-BOTH" USING L-A L-B L-C L-D
         WHEN 3
             CALL "L32-SET-LIGHT-ENABLED" USING L-A L-B L-C
         WHEN 4
             CALL "L32-CHUNK-START-BLOCK" USING L-A L-B
             IF EN-SKY-ON = 1
                 CALL "L32-CHUNK-START-SKY" USING L-A L-B
             END-IF
         WHEN 5
             CALL "L32-QUEUE-DATA" USING L-A L-B L-C L-D L-E
         WHEN 6
             CALL "L32-RETAIN-BOTH" USING L-A L-B L-C
         WHEN 7
             CALL "L32-RETAIN-BOTH" USING L-A L-B WS-OFF
             CALL "L32-FORGET-CHUNK" USING L-A L-B
         WHEN 8
             COMPUTE WS-COL = FUNCTION MOD(L-B + 1, 4) * 4 + FUNCTION MOD(L-A + 1, 4) + 1
             MOVE L-C TO EN-LIGHT-CORRECT(WS-COL)
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-SERVER-EXEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SERVER-RUN.
*> USING nothing but the results: ThreadedLevelLightEngine.runUpdate (8.3): at most 1000 tasks: the PRE_UPDATE ones, one light update run of the engines, the
*> POST_UPDATE ones of the same batch; the processed tasks are removed. Gives the tasks processed and the engine pairs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROCESSED            BINARY-LONG.
 01 L-PAIRS                BINARY-LONG.
 PROCEDURE DIVISION USING L-PROCESSED L-PAIRS.
     MOVE EN-TK-N TO L-PROCESSED
     IF L-PROCESSED > 1000
         MOVE 1000 TO L-PROCESSED
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-PROCESSED
         IF TK-PHASE(WS-I) = 0
             CALL "L32-SERVER-EXEC" USING TK-KIND(WS-I) TK-A(WS-I) TK-B(WS-I) TK-C(WS-I) TK-D(WS-I) TK-E(WS-I)
         END-IF
     END-PERFORM
     CALL "L32-RUN-BOTH" USING L-PAIRS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-PROCESSED
         IF TK-PHASE(WS-I) = 1
             CALL "L32-SERVER-EXEC" USING TK-KIND(WS-I) TK-A(WS-I) TK-B(WS-I) TK-C(WS-I) TK-D(WS-I) TK-E(WS-I)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-TK-N - L-PROCESSED
         COMPUTE WS-FROM = WS-I + L-PROCESSED
         MOVE EN-TK(WS-FROM) TO EN-TK(WS-I)
     END-PERFORM
     SUBTRACT L-PROCESSED FROM EN-TK-N
     GOBACK.
 END PROGRAM L32-SERVER-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SERVER-NEEDS.
*> USING nothing but the result: tryScheduleUpdate: 1 while tasks are pending or either engine has light work (8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NEEDS                BINARY-LONG.
 PROCEDURE DIVISION USING L-NEEDS.
     MOVE 0 TO L-NEEDS
     IF EN-TK-N > 0
         MOVE 1 TO L-NEEDS
     END-IF
     CALL "L32-HAS-WORK" USING WS-LAYER WS-FLAG
     IF WS-FLAG = 1
         MOVE 1 TO L-NEEDS
     END-IF
     IF EN-SKY-ON = 1
         CALL "L32-HAS-WORK" USING WS-SKY WS-FLAG
         IF WS-FLAG = 1
             MOVE 1 TO L-NEEDS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SERVER-NEEDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-INIT-LIGHT.
*> USING chunk x, chunk z, lighted: ChunkStatusTasks.initializeLight (8.3): fills the chunk's sky sources, then a PRE_UPDATE task per non-air section runs
*> updateSectionStatus(section, false) and POST_UPDATE tasks run setLightEnabled(chunk, lighted) and retainData(chunk, false).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LIGHTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-LIGHTED.
     CALL "L32-SKY-FILL" USING L-CX L-CZ
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     PERFORM VARYING WS-SY FROM EN-MINSEC BY 1 UNTIL WS-SY >= EN-MINSEC + EN-NS
         IF EN-NONAIR((WS-COL - 1) * EN-NS + WS-SY - EN-MINSEC + 1) > 0
             MOVE 0 TO WS-PHASE
             MOVE 2 TO WS-KIND
             CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX WS-SY L-CZ WS-ZERO WS-Z2
         END-IF
     END-PERFORM
     MOVE 1 TO WS-PHASE
     MOVE 3 TO WS-KIND
     CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX L-CZ L-LIGHTED WS-ZERO WS-Z2
     MOVE 6 TO WS-KIND
     CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX L-CZ WS-ZERO WS-Z2 WS-Z3
     GOBACK.
 END PROGRAM L32-INIT-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-STAGE.
*> USING chunk x, chunk z, lighted: ChunkStatusTasks.light (8.3): setLightCorrect(false), a PRE_UPDATE task propagateLightSources only when the chunk is not
*> lighted, a POST_UPDATE task setLightCorrect(true).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LIGHTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-LIGHTED.
     COMPUTE WS-COL = FUNCTION MOD(L-CZ + 1, 4) * 4 + FUNCTION MOD(L-CX + 1, 4) + 1
     MOVE 0 TO EN-LIGHT-CORRECT(WS-COL)
     IF L-LIGHTED = 0
         MOVE 0 TO WS-PHASE
         MOVE 4 TO WS-KIND
         CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX L-CZ WS-ZERO WS-Z2 WS-Z3
     END-IF
     MOVE 1 TO WS-PHASE
     MOVE 8 TO WS-KIND
     CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX L-CZ WS-ONE WS-ZERO WS-Z2
     GOBACK.
 END PROGRAM L32-LIGHT-STAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CHUNK-LEAVE.
*> USING chunk x, chunk z: updateChunkStatus (a chunk leaving the lighting stage, 8.3): a PRE_UPDATE task that runs retainData(false), setLightEnabled(false),
*> queues null data for every light section of both engines and reports every block section empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PHASE               BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 7.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     CALL "L32-SERVER-SUBMIT" USING WS-PHASE WS-KIND L-CX L-CZ WS-ZERO WS-Z2 WS-Z3
     GOBACK.
 END PROGRAM L32-CHUNK-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LOAD-STORED.
*> USING 16 BINARY-LONG: chunk x, chunk z, then for the block sections 0 to 3 the block layer's nibble fill (-1 none) and for sections 0 to 3 the sky layer's fill
*> (-1 none): SerializableChunkData (8.4): a stored sky layer is ignored without a sky engine; on the first section with a layer retainData(chunk, true) once,
*> then queueSectionData for the layers present.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SY                  BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-HAS-BLOCK           BINARY-LONG.
 01 WS-HAS-SKY             BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 1.
 01 WS-SKY                 BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-IN.
    05 L-CX                BINARY-LONG.
    05 L-CZ                BINARY-LONG.
    05 L-BLOCK-FILL        BINARY-LONG OCCURS 4 TIMES.
    05 L-SKY-FILL          BINARY-LONG OCCURS 4 TIMES.
    05 FILLER              BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-IN.
     MOVE 1 TO WS-FIRST
     PERFORM VARYING WS-SY FROM 0 BY 1 UNTIL WS-SY > 3
         MOVE 0 TO WS-HAS-BLOCK WS-HAS-SKY
         IF L-BLOCK-FILL(WS-SY + 1) >= 0
             MOVE 1 TO WS-HAS-BLOCK
         END-IF
         IF L-SKY-FILL(WS-SY + 1) >= 0 AND EN-SKY-ON = 1
             MOVE 1 TO WS-HAS-SKY
         END-IF
         IF WS-HAS-BLOCK = 1 OR WS-HAS-SKY = 1
             IF WS-FIRST = 1
                 CALL "L32-RETAIN-BOTH" USING L-CX L-CZ WS-ONE
                 MOVE 0 TO WS-FIRST
             END-IF
             IF WS-HAS-BLOCK = 1
                 CALL "L32-QUEUE-DATA" USING WS-LAYER L-CX WS-SY L-CZ L-BLOCK-FILL(WS-SY + 1)
             END-IF
             IF WS-HAS-SKY = 1
                 CALL "L32-QUEUE-DATA" USING WS-SKY L-CX WS-SY L-CZ L-SKY-FILL(WS-SY + 1)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-LOAD-STORED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-PACKET-STATE.
*> USING layer, section x, y, z; gives how the published layer of a section goes into a Light Update or chunk packet (9 item 4, 06 section 7): 0 no layer (no bit
*> in any mask; also the sky layer of a dimension without a sky engine), 1 all 4096 values 0 (the empty mask), 2 anything else (the 2048-byte array).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SX L-SY L-SZ L-STATE.
     MOVE 0 TO L-STATE
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     IF WS-SID > 0 AND (L-K = 1 OR EN-SKY-ON = 1)
         IF LY-VP(L-K, WS-SID) = 1
             MOVE 2 TO L-STATE
             IF LY-VD(L-K, WS-SID) = LOW-VALUES
                 MOVE 1 TO L-STATE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-PACKET-STATE.
