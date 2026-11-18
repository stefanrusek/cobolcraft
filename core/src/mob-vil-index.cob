*> The POI index of villagers (lane 002-lane-mobsb3, T8105; docs/protocol/54 section 4, 19 section 22.7, 44 section 1.3). Points of interest are found by scanning the loaded chunks
*> one 16-high section (y -64 to 319) per call and kept in VILPOIX.cpy; an entry is validated when it is used. Kinds: 1 bed (a block whose key ends in _bed, one ticket), 2 bell (the meeting
*> point, 32 tickets), 3 job site (the 13 workstation blocks of VIL-PROFESSION, one ticket). Claims are VILPOI.cpy entries with PO-KIND 2 and 3 (job sites keep PO-KIND 0 from VP-CLAIM).
*> A block placed while the world runs is indexed by PXI-NOTE when it is set, so a placed workstation, bed or bell does not wait for the scan of its chunk. Gaps: the beds are not checked for being occupied or as
*> two halves (both halves are indexed, the foot and the head), no path check.
*>
*>   PXI-KIND-OF USING dim, x, y, z, kind out        the kind of the block at a position now (0 none)
*>   PXI-SCAN USING dim, chunk x, chunk z            advance the scan of that chunk by one section (does nothing when it is done or not loaded)
*>   PXI-ADD USING dim, x, y, z, kind                adds a point (no duplicate)
*>   PXI-NOTE USING dim, x, y, z, block state        a block was placed: a point of interest of its kind is indexed at once (WORLD-SET-BLOCK)
*>   PXI-NEAREST USING dim, x, y, z, kind, range, ox, oy, oz, found out   the nearest valid point of the kind with a free ticket within range (a taken one is skipped)
*>   PXI-TICKETS USING dim, x, y, z, kind, count out the claims on a point

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY VILPOIX.
 01 WS-B                    BINARY-LONG.
 01 WS-KEY                  PIC X(48).
 01 WS-KEY32                PIC X(32).
 01 WS-PROF                 PIC X(16).
 01 WS-LEN                  BINARY-LONG.
 PROCEDURE DIVISION.
     IF PX-EPOCH = CB-EPOCH + 1
         GOBACK
     END-IF
     COMPUTE PX-EPOCH = CB-EPOCH + 1
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CB-MAX-BLOCKS
         MOVE 0 TO PX-BKIND(WS-B)
     END-PERFORM
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CB-BLOCK-COUNT
         MOVE CB-KEY(WS-B) TO WS-KEY
         MOVE CB-KEY-LENGTH(WS-B) TO WS-LEN
         MOVE SPACES TO WS-KEY32
         IF WS-KEY(1:10) = "minecraft:"
             MOVE WS-KEY(11:32) TO WS-KEY32
         ELSE
             MOVE WS-KEY(1:32) TO WS-KEY32
         END-IF
         IF WS-LEN > 4 AND WS-KEY(WS-LEN - 3:4) = "_bed"
             MOVE 1 TO PX-BKIND(WS-B)
         END-IF
         IF WS-KEY32 = "bell"
             MOVE 2 TO PX-BKIND(WS-B)
         END-IF
         CALL "VIL-PROFESSION" USING WS-KEY32 WS-PROF
         IF WS-PROF NOT = "none"
             MOVE 3 TO PX-BKIND(WS-B)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PXI-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-KIND-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY VILPOIX.
 01 WS-STATE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND.
     MOVE 0 TO L-KIND
     CALL "PXI-INIT"
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         MOVE PX-BKIND(CB-S-BLOCK(WS-STATE + 1) + 1) TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM PXI-KIND-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-FREE                 BINARY-LONG.
 01 WS-DUP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND.
     MOVE 0 TO WS-FREE WS-DUP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) = 0
             IF WS-FREE = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         ELSE
             IF PX-DIM(WS-I) = L-DIM AND PX-X(WS-I) = L-X AND PX-Y(WS-I) = L-Y AND PX-Z(WS-I) = L-Z
                 MOVE 1 TO WS-DUP
             END-IF
         END-IF
     END-PERFORM
     IF WS-DUP = 0 AND WS-FREE > 0
         MOVE L-KIND TO PX-KIND(WS-FREE)
         MOVE L-DIM TO PX-DIM(WS-FREE)
         MOVE L-X TO PX-X(WS-FREE)
         MOVE L-Y TO PX-Y(WS-FREE)
         MOVE L-Z TO PX-Z(WS-FREE)
     END-IF
     GOBACK.
 END PROGRAM PXI-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-NOTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY VILPOIX.
 01 WS-KIND                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-STATE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "PXI-INIT"
     IF L-STATE > 0 AND L-STATE < CB-STATE-COUNT
         MOVE PX-BKIND(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-KIND
         IF WS-KIND > 0
             CALL "PXI-ADD" USING L-DIM L-X L-Y L-Z WS-KIND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PXI-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-ROW                  BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-X0                   BINARY-LONG.
 01 WS-Z0                   BINARY-LONG.
 01 WS-Y0                   BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-CX                    BINARY-LONG.
 01 L-CZ                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-DONE-N
         IF PX-D-DIM(WS-I) = L-DIM AND PX-D-CX(WS-I) = L-CX AND PX-D-CZ(WS-I) = L-CZ
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     IF WS-DONE = 1
         GOBACK
     END-IF
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     IF PX-SC-ON = 0 OR PX-SC-DIM NOT = L-DIM OR PX-SC-CX NOT = L-CX OR PX-SC-CZ NOT = L-CZ
         IF PX-SC-ON = 1
             GOBACK
         END-IF
         MOVE 1 TO PX-SC-ON
         MOVE L-DIM TO PX-SC-DIM
         MOVE L-CX TO PX-SC-CX
         MOVE L-CZ TO PX-SC-CZ
         MOVE 0 TO PX-SC-SEC
     END-IF
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     COMPUTE WS-Y0 = PX-SC-SEC * 16 - 64
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X0 + 15
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z0 + 15
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 15
                 CALL "PXI-KIND-OF" USING L-DIM WS-X WS-Y WS-Z WS-KIND
                 IF WS-KIND > 0
                     CALL "PXI-ADD" USING L-DIM WS-X WS-Y WS-Z WS-KIND
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     ADD 1 TO PX-SC-SEC
     IF PX-SC-SEC >= 24
         MOVE 0 TO PX-SC-ON
         IF PX-DONE-N < PX-DONE-MAX
             ADD 1 TO PX-DONE-N
             MOVE L-DIM TO PX-D-DIM(PX-DONE-N)
             MOVE L-CX TO PX-D-CX(PX-DONE-N)
             MOVE L-CZ TO PX-D-CZ(PX-DONE-N)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PXI-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-TICKETS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
         IF PO-OWNER(WS-I) > 0 AND PO-DIM(WS-I) = L-DIM AND PO-X(WS-I) = L-X AND PO-Y(WS-I) = L-Y AND PO-Z(WS-I) = L-Z
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PXI-TICKETS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-NEAREST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-TICKS                BINARY-LONG.
 01 WS-CAP                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-RANGE                 BINARY-LONG.
 01 L-OX                    BINARY-LONG.
 01 L-OY                    BINARY-LONG.
 01 L-OZ                    BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-RANGE L-OX L-OY L-OZ L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE 1 TO WS-CAP
     IF L-KIND = 2
         MOVE 32 TO WS-CAP
     END-IF
     COMPUTE WS-BEST = L-RANGE * L-RANGE + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) = L-KIND AND PX-DIM(WS-I) = L-DIM
             COMPUTE WS-DX = PX-X(WS-I) - L-X
             COMPUTE WS-DY = PX-Y(WS-I) - L-Y
             COMPUTE WS-DZ = PX-Z(WS-I) - L-Z
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 < WS-BEST
                 CALL "PXI-KIND-OF" USING L-DIM PX-X(WS-I) PX-Y(WS-I) PX-Z(WS-I) WS-KIND
                 IF WS-KIND NOT = L-KIND
                     INITIALIZE PX-ENTRY(WS-I)
                 ELSE
                     CALL "PXI-TICKETS" USING L-DIM PX-X(WS-I) PX-Y(WS-I) PX-Z(WS-I) L-KIND WS-TICKS
                     IF WS-TICKS < WS-CAP
                         MOVE WS-D2 TO WS-BEST
                         MOVE PX-X(WS-I) TO L-OX
                         MOVE PX-Y(WS-I) TO L-OY
                         MOVE PX-Z(WS-I) TO L-OZ
                         MOVE 1 TO L-FOUND
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PXI-NEAREST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VPX-CLAIM.
*> USING owner id, kind (2 home, 3 meeting), dim, x, y, z: a claim of the villager on a point (an owner holds one claim of a kind: the old one goes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWNER                 BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-KIND L-DIM L-X L-Y L-Z.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
         IF PO-OWNER(WS-I) = L-OWNER AND PO-KIND(WS-I) = L-KIND
             INITIALIZE PO-ENTRY(WS-I)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX OR WS-DONE = 1
         IF PO-OWNER(WS-I) = 0
             MOVE L-OWNER TO PO-OWNER(WS-I)
             MOVE L-KIND TO PO-KIND(WS-I)
             MOVE L-DIM TO PO-DIM(WS-I)
             MOVE L-X TO PO-X(WS-I)
             MOVE L-Y TO PO-Y(WS-I)
             MOVE L-Z TO PO-Z(WS-I)
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VPX-CLAIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VPX-OF.
*> USING owner id, kind (0 job site, 2 home, 3 meeting), dim out, x, y, z, found out: the claim of the villager of that kind.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWNER                 BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-KIND L-DIM L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX OR L-FOUND = 1
         IF PO-OWNER(WS-I) = L-OWNER AND PO-KIND(WS-I) = L-KIND
             MOVE PO-DIM(WS-I) TO L-DIM
             MOVE PO-X(WS-I) TO L-X
             MOVE PO-Y(WS-I) TO L-Y
             MOVE PO-Z(WS-I) TO L-Z
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VPX-OF.
