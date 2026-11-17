*> The workstation scan and claim of villagers (docs/protocol/44 sections 1.3, 2.1 and 2.6, 54 section 4.4; lane 002-lane-mobsb2, T7102). The state is VILPOI.cpy; the profession of a
*> block is VIL-PROFESSION (the 13 acquirable_job_site types). Gaps: the scan box is 2 blocks around the villager (the document's 48 needs a POI index
*> the core does not have), villagers do not walk to a workstation (no pathing target: only a workstation within 2 blocks of the villager is claimed and assigned at once), no
*> competitor scan or YieldJobSite, no ResetProfession, beds and the meeting point are not claimed.
*>
*>   VP-OWNER USING dim, x, y, z, owner out      the entity id that holds the workstation at the block (0 none)
*>   VP-CLAIM USING dim, x, y, z, owner id       claims it (one ticket)
*>   VP-RELEASE USING owner id                   releases the claims of the villager (it is gone)
*>   VL-SCAN USING entity row                    the AcquirePoi scan of a villager without profession (every 20 to 39 ticks)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VP-OWNER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OWNER.
     MOVE 0 TO L-OWNER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX OR L-OWNER > 0
         IF PO-OWNER(WS-I) > 0 AND PO-DIM(WS-I) = L-DIM AND PO-X(WS-I) = L-X AND PO-Y(WS-I) = L-Y AND PO-Z(WS-I) = L-Z
             MOVE PO-OWNER(WS-I) TO L-OWNER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VP-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VP-CLAIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OWNER.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX OR WS-DONE = 1
         IF PO-OWNER(WS-I) = 0
             MOVE L-OWNER TO PO-OWNER(WS-I)
             MOVE L-DIM TO PO-DIM(WS-I)
             MOVE L-X TO PO-X(WS-I)
             MOVE L-Y TO PO-Y(WS-I)
             MOVE L-Z TO PO-Z(WS-I)
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VP-CLAIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VP-RELEASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWNER                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
         IF PO-OWNER(WS-I) = L-OWNER
             INITIALIZE PO-ENTRY(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VP-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-SCAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-SALT                 BINARY-LONG VALUE 81.
 01 WS-TWENTY               BINARY-LONG VALUE 20.
 01 WS-R                    BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-BX                   BINARY-LONG.
 01 WS-BY                   BINARY-LONG.
 01 WS-BZ                   BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-OWNER                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-KEY48                PIC X(48).
 01 WS-PROF                 PIC X(16).
 01 WS-D2                   FLOAT-LONG.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-HIT                  BINARY-LONG.
 01 WS-HX                   BINARY-LONG.
 01 WS-HY                   BINARY-LONG.
 01 WS-HZ                   BINARY-LONG.
 01 WS-HKEY                 PIC X(32).
 01 WS-CHANGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     IF VL-KIND(WS-SLOT) NOT = 1 OR VL-PROF(WS-SLOT) NOT = "none" OR VL-POT(WS-SLOT) = 1
         GOBACK
     END-IF
*>   A scan every 20 to 39 ticks; the first evaluation only sets the timer (44 section 2.1 step 2).
     IF VL-NEXT-SCAN(WS-SLOT) = 0
         CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
         COMPUTE VL-NEXT-SCAN(WS-SLOT) = CW-TICKS + WS-R + 1
         GOBACK
     END-IF
     IF CW-TICKS < VL-NEXT-SCAN(WS-SLOT)
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
     COMPUTE VL-NEXT-SCAN(WS-SLOT) = CW-TICKS + 20 + WS-R
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-HIT
     MOVE 5 TO WS-BEST
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-BX = WS-PX + WS-DX
                 COMPUTE WS-BY = WS-PY + WS-DY
                 COMPUTE WS-BZ = WS-PZ + WS-DZ
                 COMPUTE WS-FX = WS-BX + 0.5 - EN-X(L-ROW)
                 COMPUTE WS-FY = WS-BY + 0.5 - EN-Y(L-ROW)
                 COMPUTE WS-FZ = WS-BZ + 0.5 - EN-Z(L-ROW)
                 COMPUTE WS-D2 = WS-FX * WS-FX + WS-FY * WS-FY + WS-FZ * WS-FZ
                 IF WS-D2 <= 4 AND WS-D2 < WS-BEST
                     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
                     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
                         MOVE SPACES TO WS-KEY
                         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY48
                         IF WS-KEY48(1:10) = "minecraft:"
                             MOVE WS-KEY48(11:32) TO WS-KEY
                         ELSE
                             MOVE WS-KEY48(1:32) TO WS-KEY
                         END-IF
                         CALL "VIL-PROFESSION" USING WS-KEY WS-PROF
                         IF WS-PROF NOT = "none"
                             CALL "VP-OWNER" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-OWNER
                             IF WS-OWNER = 0
                                 MOVE 1 TO WS-HIT
                                 MOVE WS-D2 TO WS-BEST
                                 MOVE WS-BX TO WS-HX
                                 MOVE WS-BY TO WS-HY
                                 MOVE WS-BZ TO WS-HZ
                                 MOVE WS-KEY TO WS-HKEY
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-HIT = 1
         CALL "VP-CLAIM" USING EN-DIM(L-ROW) WS-HX WS-HY WS-HZ EN-ID(L-ROW)
         CALL "VL-CLAIM" USING WS-SLOT WS-HKEY WS-CHANGED
     END-IF
     GOBACK.
 END PROGRAM VL-SCAN.
