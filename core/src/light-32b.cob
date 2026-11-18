*> The light engine of docs/protocol/32-light-engine.md, section 6 (T0690): the section storage of one layer (layer 1 block light,
*> layer 2 sky light; see core/copy/L32.cpy): state bytes with neighbour counts, layer creation, pending data and removal, the working
*> and published maps, notification, column flags, level reads and the sky predicates.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SECTION-ID.
*> USING section x, y, z (section coordinates); gives the section id and the column 1 to 16 (0 when outside the window).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-SID                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-SID L-COL.
     MOVE 0 TO L-SID L-COL
     COMPUTE WS-SLOT = FUNCTION MOD(L-SZ + 1, 4) * 4 + FUNCTION MOD(L-SX + 1, 4) + 1
     IF EN-OWN-X(WS-SLOT) = L-SX AND EN-OWN-Z(WS-SLOT) = L-SZ
         MOVE WS-SLOT TO L-COL
         IF L-SY >= EN-LOWL AND L-SY < EN-LOWL + EN-NL
             COMPUTE L-SID = (L-COL - 1) * EN-NL + L-SY - EN-LOWL + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-SECTION-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORES.
*> USING layer, x, y, z; gives 1 when the working map holds a layer for the cell's section (storingLightForSection, 6.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     IF WS-SID > 0
         MOVE LY-WP(L-K, WS-SID) TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM L32-STORES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-GET-STORED.
*> USING layer, x, y, z; gives the stored level of the working map (getStoredLevel), 0 when the section stores no light (6.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-LEVEL.
     MOVE 0 TO L-LEVEL
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     IF WS-SID > 0
         IF LY-WP(L-K, WS-SID) = 1
             CALL "L32-NIBBLE-GET" USING LY-WD(L-K, WS-SID) WS-INDEX L-LEVEL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-GET-STORED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SET-STORED.
*> USING layer, x, y, z, level: writes a level into the working layer of the cell's section (setStoredLevel, which the caller has checked
*> stores light), marks the section changed and adds to the affected set the section of the cell and those of the cells at offsets
*> -1 and +1 on each axis (6.4 a).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-LEVEL.
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     CALL "L32-NIBBLE-SET" USING LY-WD(L-K, WS-SID) WS-INDEX L-LEVEL
     MOVE 1 TO LY-CH(L-K, WS-SID)
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-X = L-X + WS-DX
                 COMPUTE WS-Y = L-Y + WS-DY
                 COMPUTE WS-Z = L-Z + WS-DZ
                 CALL "L32-LOCATE" USING WS-X WS-Y WS-Z WS-COL WS-SID WS-INDEX
                 IF WS-SID > 0
                     MOVE 1 TO LY-AF(L-K, WS-SID)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM L32-SET-STORED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-NODE-ADDED.
*> USING layer, column, section Y: the sky storage's onNodeAdded: lowers currentLowestY to the section and raises the column's top table
*> value to Y + 1 (6.8); nothing for the block storage.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COL L-SY.
     IF L-K = 2
         IF L-SY < LY-LOWEST(2)
             MOVE L-SY TO LY-LOWEST(2)
         END-IF
         IF LY-TOPSET(2, L-COL) = 0 OR LY-TOP(2, L-COL) < L-SY + 1
             COMPUTE LY-TOP(2, L-COL) = L-SY + 1
             MOVE 1 TO LY-TOPSET(2, L-COL)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-NODE-ADDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-NODE-REMOVED.
*> USING layer, column, section Y: the sky storage's onNodeRemoved (6.3 step 2): when the column's top is Y + 1, walk down from the removed section
*> while the section stores no light and hasLightDataAtOrBelow holds; the top becomes the section reached + 1 when it stores light, else the
*> entry is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-Y                   BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-STORES              BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COL L-SY.
     IF L-K = 2 AND LY-TOPSET(2, L-COL) = 1
         IF LY-TOP(2, L-COL) = L-SY + 1
             MOVE L-SY TO WS-Y
             MOVE 0 TO WS-STORES
             PERFORM UNTIL WS-STORES = 1 OR WS-Y < LY-LOWEST(2)
                 COMPUTE WS-SID = (L-COL - 1) * EN-NL + WS-Y - EN-LOWL + 1
                 MOVE LY-WP(2, WS-SID) TO WS-STORES
                 IF WS-STORES = 0
                     SUBTRACT 1 FROM WS-Y
                 END-IF
             END-PERFORM
             IF WS-STORES = 1
                 COMPUTE LY-TOP(2, L-COL) = WS-Y + 1
             ELSE
                 MOVE 0 TO LY-TOPSET(2, L-COL)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-NODE-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-CREATE-LAYER.
*> USING layer, section id, column, section Y: creates the working layer of a section (6.6). Block light: the queued layer, else all zero. Sky
*> light: the queued layer; else all 15 (column light enabled) or all zero for a section at or above the column top or without an entry;
*> else the first Y row of the first layer above repeated 16 times.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-S                   BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SID                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SID L-COL L-SY.
     MOVE LOW-VALUES TO LY-WD(L-K, L-SID)
     EVALUATE TRUE
         WHEN LY-QP(L-K, L-SID) NOT = 0
             MOVE LY-QD(L-K, L-SID) TO LY-WD(L-K, L-SID)
             MOVE 2 TO LY-QP(L-K, L-SID)
         WHEN L-K = 1
             CONTINUE
         WHEN LY-TOPSET(2, L-COL) = 0 OR L-SY >= LY-TOP(2, L-COL)
             IF LY-ON(2, L-COL) = 1
                 MOVE ALL X"FF" TO LY-WD(2, L-SID)
             END-IF
         WHEN OTHER
             MOVE 0 TO WS-FOUND
             COMPUTE WS-S = L-SY + 1
             PERFORM UNTIL WS-S >= EN-LOWL + EN-NL OR WS-FOUND = 1
                 COMPUTE WS-SRC = (L-COL - 1) * EN-NL + WS-S - EN-LOWL + 1
                 IF LY-WP(2, WS-SRC) = 1
                     MOVE 1 TO WS-FOUND
                 ELSE
                     ADD 1 TO WS-S
                 END-IF
             END-PERFORM
             IF WS-FOUND = 1
                 PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW > 15
                     COMPUTE WS-OFF = WS-ROW * 128 + 1
                     MOVE LY-WD(2, WS-SRC)(1:128) TO LY-WD(2, L-SID)(WS-OFF:128)
                 END-PERFORM
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-CREATE-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORAGE-SET-BYTE.
*> USING layer, section id, column, section x, y, z, new state byte: stores the state byte of a section (the entry is removed when it is 0) and
*> runs initialise when an entry appeared or remove when it went away (6.2 steps 1 and 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NSID                BINARY-LONG.
 01 WS-NCOL                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SID                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SID L-COL L-SX L-SY L-SZ L-NEW.
     MOVE LY-STATE(L-K, L-SID) TO WS-OLD
     IF L-NEW NOT = WS-OLD
         MOVE L-NEW TO LY-STATE(L-K, L-SID)
         EVALUATE TRUE
             WHEN WS-OLD = 0 AND LY-PR(L-K, L-SID) = 1
                 MOVE 0 TO LY-PR(L-K, L-SID)
             WHEN WS-OLD = 0
                 CALL "L32-CREATE-LAYER" USING L-K L-SID L-COL L-SY
                 MOVE 1 TO LY-WP(L-K, L-SID)
                 MOVE 1 TO LY-CH(L-K, L-SID)
                 CALL "L32-NODE-ADDED" USING L-K L-COL L-SY
                 PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
                     PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                         PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                             COMPUTE WS-X = L-SX + WS-DX
                             COMPUTE WS-Y = L-SY + WS-DY
                             COMPUTE WS-Z = L-SZ + WS-DZ
                             CALL "L32-SECTION-ID" USING WS-X WS-Y WS-Z WS-NSID WS-NCOL
                             IF WS-NSID > 0
                                 MOVE 1 TO LY-AF(L-K, WS-NSID)
                             END-IF
                         END-PERFORM
                     END-PERFORM
                 END-PERFORM
                 MOVE 1 TO LY-INCONS(L-K)
             WHEN L-NEW = 0
                 MOVE 1 TO LY-PR(L-K, L-SID)
                 MOVE 1 TO LY-INCONS(L-K)
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM L32-STORAGE-SET-BYTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORAGE-STATUS.
*> USING layer, section x, y, z, section is empty (updateSectionStatus, 6.2): sets or clears the has-data bit (32) of the section's state byte and,
*> when it changed, adds -1 or +1 to the neighbour count of each of the 26 sections around it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DELTA               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NSID                BINARY-LONG.
 01 WS-NCOL                BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SX L-SY L-SZ L-EMPTY.
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     MOVE LY-STATE(L-K, WS-SID) TO WS-OLD
     COMPUTE WS-NEW = FUNCTION MOD(WS-OLD, 32)
     MOVE -1 TO WS-DELTA
     IF L-EMPTY = 0
         ADD 32 TO WS-NEW
         MOVE 1 TO WS-DELTA
     END-IF
     IF WS-NEW NOT = WS-OLD
         CALL "L32-STORAGE-SET-BYTE" USING L-K WS-SID WS-COL L-SX L-SY L-SZ WS-NEW
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
                 PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                     COMPUTE WS-X = L-SX + WS-DX
                     COMPUTE WS-Y = L-SY + WS-DY
                     COMPUTE WS-Z = L-SZ + WS-DZ
                     CALL "L32-SECTION-ID" USING WS-X WS-Y WS-Z WS-NSID WS-NCOL
                     IF WS-NSID > 0 AND (WS-DX NOT = 0 OR WS-DY NOT = 0 OR WS-DZ NOT = 0)
                         MOVE LY-STATE(L-K, WS-NSID) TO WS-OLD
                         COMPUTE WS-DATA = WS-OLD / 32
                         COMPUTE WS-NEW = WS-DATA * 32 + FUNCTION MOD(WS-OLD, 32) + WS-DELTA
                         CALL "L32-STORAGE-SET-BYTE" USING L-K WS-NSID WS-NCOL WS-X WS-Y WS-Z WS-NEW
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM L32-STORAGE-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-QUEUE-DATA.
*> USING layer, section x, y, z, fill: queueSectionData: a layer (every nibble = fill, 0 to 15) is stored in the queue and sets
*> hasInconsistencies; fill -1 (a null layer) removes the queued entry (6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-FILL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SX L-SY L-SZ L-FILL.
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     IF L-FILL < 0
         MOVE 0 TO LY-QP(L-K, WS-SID)
     ELSE
         COMPUTE WS-BYTE = L-FILL * 17
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2048
             MOVE WS-BYTE TO LY-QB(L-K, WS-SID, WS-I)
         END-PERFORM
         MOVE 1 TO LY-QP(L-K, WS-SID)
         MOVE 1 TO LY-INCONS(L-K)
     END-IF
     GOBACK.
 END PROGRAM L32-QUEUE-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORAGE-FINISH.
*> USING layer: the end of runLightUpdates for one storage: markNewInconsistencies when hasInconsistencies is set (6.3), then swapSectionMap
*> (6.4): publish the working map when a section changed, then notify every section of the affected set once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-SID                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 PROCEDURE DIVISION USING L-K.
     IF LY-INCONS(L-K) = 1
         MOVE 0 TO LY-INCONS(L-K)
         PERFORM VARYING WS-SID FROM 1 BY 1 UNTIL WS-SID > 16 * EN-NL
             IF LY-PR(L-K, WS-SID) = 1
                 COMPUTE WS-COL = (WS-SID - 1) / EN-NL + 1
                 IF LY-RETAIN(L-K, WS-COL) = 1
                     IF LY-QP(L-K, WS-SID) NOT = 1 AND LY-WP(L-K, WS-SID) = 1
                         MOVE LY-WD(L-K, WS-SID) TO LY-QD(L-K, WS-SID)
                     END-IF
                     MOVE 1 TO LY-QP(L-K, WS-SID)
                 ELSE
                     MOVE 0 TO LY-QP(L-K, WS-SID)
                 END-IF
                 MOVE 0 TO LY-WP(L-K, WS-SID)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-SID FROM 1 BY 1 UNTIL WS-SID > 16 * EN-NL
             IF LY-PR(L-K, WS-SID) = 1
                 COMPUTE WS-COL = (WS-SID - 1) / EN-NL + 1
                 COMPUTE WS-SY = WS-SID - (WS-COL - 1) * EN-NL + EN-LOWL - 1
                 CALL "L32-NODE-REMOVED" USING L-K WS-COL WS-SY
                 MOVE 1 TO LY-CH(L-K, WS-SID)
                 MOVE 0 TO LY-PR(L-K, WS-SID)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-SID FROM 1 BY 1 UNTIL WS-SID > 16 * EN-NL
             IF LY-QP(L-K, WS-SID) NOT = 0 AND LY-WP(L-K, WS-SID) = 1
                 IF LY-QP(L-K, WS-SID) = 1
                     MOVE LY-QD(L-K, WS-SID) TO LY-WD(L-K, WS-SID)
                     MOVE 1 TO LY-CH(L-K, WS-SID)
                 END-IF
                 MOVE 0 TO LY-QP(L-K, WS-SID)
             END-IF
         END-PERFORM
     END-IF
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-SID FROM 1 BY 1 UNTIL WS-SID > 16 * EN-NL
         IF LY-CH(L-K, WS-SID) = 1
             MOVE 1 TO WS-ANY
             MOVE LY-WP(L-K, WS-SID) TO LY-VP(L-K, WS-SID)
             IF LY-WP(L-K, WS-SID) = 1
                 MOVE LY-WD(L-K, WS-SID) TO LY-VD(L-K, WS-SID)
             END-IF
             MOVE 0 TO LY-CH(L-K, WS-SID)
         END-IF
     END-PERFORM
     IF WS-ANY = 1
         PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 16
             MOVE LY-TOP(L-K, WS-COL) TO LY-VTOP(L-K, WS-COL)
             MOVE LY-TOPSET(L-K, WS-COL) TO LY-VTOPSET(L-K, WS-COL)
         END-PERFORM
         MOVE LY-LOWEST(L-K) TO LY-VLOWEST(L-K)
     END-IF
     PERFORM VARYING WS-SID FROM 1 BY 1 UNTIL WS-SID > 16 * EN-NL
         IF LY-AF(L-K, WS-SID) = 1
             ADD 1 TO LY-NOTIFY(L-K, WS-SID)
             MOVE 0 TO LY-AF(L-K, WS-SID)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM L32-STORAGE-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORAGE-RETAIN.
*> USING layer, column, flag: retainData (6.5): while set, queued data of the column survives removal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COL L-FLAG.
     MOVE L-FLAG TO LY-RETAIN(L-K, L-COL)
     GOBACK.
 END PROGRAM L32-STORAGE-RETAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-STORAGE-ENABLE.
*> USING layer, column, flag: the column's light-enabled flag of one storage (setLightEnabled without the sky fill, 6.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COL L-FLAG.
     MOVE L-FLAG TO LY-ON(L-K, L-COL)
     GOBACK.
 END PROGRAM L32-STORAGE-ENABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-LIGHT-ON-IN-COLUMN.
*> USING block engine present, sky engine present, column; gives LevelLightEngine.lightOnInColumn (6.5): true without a block engine; false when the
*> block engine's column is not enabled; else true when the sky engine is absent or has the column enabled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-SKY L-COL L-ON.
     EVALUATE TRUE
         WHEN L-BLOCK = 0
             MOVE 1 TO L-ON
         WHEN LY-ON(1, L-COL) = 0
             MOVE 0 TO L-ON
         WHEN L-SKY = 0 OR LY-ON(2, L-COL) = 1
             MOVE 1 TO L-ON
         WHEN OTHER
             MOVE 0 TO L-ON
     END-EVALUATE
     GOBACK.
 END PROGRAM L32-LIGHT-ON-IN-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-GET-LEVEL.
*> USING variant (0 published map, 1 working map), layer, x, y, z; gives the level (6.7). Block light: the layer's nibble, 0 without a layer. Sky
*> light: 15 at or above the column's top section or without a table entry (working variant: only when the column has light enabled, else
*> 0); otherwise the nibble of the section's layer, or of the first layer above (its bottom Y row, x and z unchanged), 15 when the top is passed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 01 WS-COL                 BINARY-LONG.
 01 WS-SID                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SSID                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-TOPSET              BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-VARIANT              BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-VARIANT L-K L-X L-Y L-Z L-LEVEL.
     MOVE 0 TO L-LEVEL
     CALL "L32-LOCATE" USING L-X L-Y L-Z WS-COL WS-SID WS-INDEX
     IF L-K = 1
         IF WS-SID > 0
             IF L-VARIANT = 0
                 MOVE LY-VP(1, WS-SID) TO WS-PRESENT
             ELSE
                 MOVE LY-WP(1, WS-SID) TO WS-PRESENT
             END-IF
             IF WS-PRESENT = 1 AND L-VARIANT = 0
                 CALL "L32-NIBBLE-GET" USING LY-VD(1, WS-SID) WS-INDEX L-LEVEL
             END-IF
             IF WS-PRESENT = 1 AND L-VARIANT = 1
                 CALL "L32-NIBBLE-GET" USING LY-WD(1, WS-SID) WS-INDEX L-LEVEL
             END-IF
         END-IF
     ELSE
         IF EN-SKY-ON = 1
             COMPUTE WS-LX = FUNCTION MOD(L-Y, 16)
             COMPUTE WS-SY = (L-Y - WS-LX) / 16
             MOVE LY-TOP(2, WS-COL) TO WS-TOP
             MOVE LY-TOPSET(2, WS-COL) TO WS-TOPSET
             MOVE 15 TO WS-ABOVE
             IF L-VARIANT = 1
                 MOVE LY-ON(2, WS-COL) TO WS-ABOVE
                 COMPUTE WS-ABOVE = WS-ABOVE * 15
             ELSE
                 MOVE LY-VTOP(2, WS-COL) TO WS-TOP
                 MOVE LY-VTOPSET(2, WS-COL) TO WS-TOPSET
             END-IF
             MOVE WS-ABOVE TO L-LEVEL
             IF WS-TOPSET = 1 AND WS-SY < WS-TOP
                 MOVE 0 TO WS-DONE
                 MOVE WS-SY TO WS-S
                 COMPUTE WS-ROW = FUNCTION MOD(L-Z, 16) * 16 + FUNCTION MOD(L-X, 16)
                 PERFORM UNTIL WS-DONE = 1 OR WS-S >= WS-TOP
                     COMPUTE WS-SSID = (WS-COL - 1) * EN-NL + WS-S - EN-LOWL + 1
                     IF L-VARIANT = 0
                         MOVE LY-VP(2, WS-SSID) TO WS-PRESENT
                     ELSE
                         MOVE LY-WP(2, WS-SSID) TO WS-PRESENT
                     END-IF
                     IF WS-S = WS-SY
                         MOVE WS-INDEX TO WS-LY
                     ELSE
                         MOVE WS-ROW TO WS-LY
                     END-IF
                     IF WS-PRESENT = 1 AND L-VARIANT = 0
                         CALL "L32-NIBBLE-GET" USING LY-VD(2, WS-SSID) WS-LY L-LEVEL
                         MOVE 1 TO WS-DONE
                     END-IF
                     IF WS-PRESENT = 1 AND L-VARIANT = 1
                         CALL "L32-NIBBLE-GET" USING LY-WD(2, WS-SSID) WS-LY L-LEVEL
                         MOVE 1 TO WS-DONE
                     END-IF
                     ADD 1 TO WS-S
                 END-PERFORM
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM L32-GET-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-GET-PUBLISHED.
*> USING layer, x, y, z; gives the published level (getLightValue without the update flag, 6.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VARIANT             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-LEVEL.
     CALL "L32-GET-LEVEL" USING WS-VARIANT L-K L-X L-Y L-Z L-LEVEL
     GOBACK.
 END PROGRAM L32-GET-PUBLISHED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-GET-WORKING.
*> USING layer, x, y, z; gives the level through the working map's variant (6.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VARIANT             BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-X L-Y L-Z L-LEVEL.
     CALL "L32-GET-LEVEL" USING WS-VARIANT L-K L-X L-Y L-Z L-LEVEL
     GOBACK.
 END PROGRAM L32-GET-WORKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-BOTTOM-SECTION.
*> USING layer; gives currentLowestY (getBottomSectionY): the lowest section Y ever initialised in the storage (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-LOWEST               BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-LOWEST.
     MOVE LY-LOWEST(L-K) TO L-LOWEST
     GOBACK.
 END PROGRAM L32-BOTTOM-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-TOP-SECTION.
*> USING layer, column; gives getTopSectionY: highest section of the column that stores light + 1, currentLowestY for a column without an entry (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-K                    BINARY-LONG.
 01 L-COL                  BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-COL L-TOP.
     MOVE LY-LOWEST(L-K) TO L-TOP
     IF LY-TOPSET(L-K, L-COL) = 1
         MOVE LY-TOP(L-K, L-COL) TO L-TOP
     END-IF
     GOBACK.
 END PROGRAM L32-TOP-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-DATA-AT-OR-BELOW.
*> USING section Y; gives hasLightDataAtOrBelow: Y >= currentLowestY of the sky storage (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-Y >= LY-LOWEST(2)
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM L32-DATA-AT-OR-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-IS-ABOVE-DATA.
*> USING column, section Y; gives isAboveData: the column has no table entry or the section Y >= its top value (6.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY L32.
 LINKAGE SECTION.
 01 L-COL                  BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COL L-SY L-FLAG.
     MOVE 0 TO L-FLAG
     IF LY-TOPSET(2, L-COL) = 0 OR L-SY >= LY-TOP(2, L-COL)
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM L32-IS-ABOVE-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. L32-SECTION-INFO.
*> USING layer, section x, y, z; gives the state byte, 1 when the working map stores a layer, 1 when the published map has one, 1 when a layer
*> is queued, 1 when the section is pending removal, and the number of notifications the section has had (6.1 to 6.4).
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
 01 L-STORES               BINARY-LONG.
 01 L-PUBLISHED            BINARY-LONG.
 01 L-QUEUED               BINARY-LONG.
 01 L-PENDING              BINARY-LONG.
 01 L-NOTIFIED             BINARY-LONG.
 PROCEDURE DIVISION USING L-K L-SX L-SY L-SZ L-STATE L-STORES L-PUBLISHED L-QUEUED L-PENDING L-NOTIFIED.
     CALL "L32-SECTION-ID" USING L-SX L-SY L-SZ WS-SID WS-COL
     MOVE LY-STATE(L-K, WS-SID) TO L-STATE
     MOVE LY-WP(L-K, WS-SID) TO L-STORES
     MOVE LY-VP(L-K, WS-SID) TO L-PUBLISHED
     MOVE 0 TO L-QUEUED
     IF LY-QP(L-K, WS-SID) NOT = 0
         MOVE 1 TO L-QUEUED
     END-IF
     MOVE LY-PR(L-K, WS-SID) TO L-PENDING
     MOVE LY-NOTIFY(L-K, WS-SID) TO L-NOTIFIED
     GOBACK.
 END PROGRAM L32-SECTION-INFO.
