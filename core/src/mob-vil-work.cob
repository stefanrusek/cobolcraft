*> WorkAtPoi (docs/protocol/44 part 3 section 2.7; 19 section 22.4; lane 002-lane-p49p), run on the brain beat in the work activity. A villager whose job_site is in its dimension and within 1.73 blocks
*> starts working at most once per 300 ticks (one in two when the check is due: Q3-WORK-START); the start sets last_worked_at_poi to the game tick and restocks the trades when a restock is allowed
*> (VL-RESTOCK, 22.4). Gaps: the check runs on the 20 to 39 tick beat, not every tick; no work sound, look target or workstation effect (useWorkstation).
*>   VL-WORK-TICK USING row, slot, active activity

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-WORK-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-SAME                 BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-TWO                  BINARY-LONG VALUE 2.
 01 WS-SALT                 BINARY-LONG VALUE 167.
 01 WS-NOW                  BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-DID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ACT.
     IF L-ACT NOT = VA-WORK
         GOBACK
     END-IF
     CALL "VM-GET" USING L-SLOT MT-JOB-SITE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-PRESENT = 0
         GOBACK
     END-IF
     MOVE CW-TICKS TO WS-NOW
     MOVE 0 TO WS-SAME
     IF WS-QD = EN-DIM(L-ROW)
         MOVE 1 TO WS-SAME
     END-IF
     CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
     CALL "XP-RANDOM" USING WS-SALT WS-TWO WS-DRAW
     CALL "Q3-WORK-START" USING WS-NOW VM-T(L-SLOT, TM-WORK-CHECK) WS-DRAW WS-SAME WS-D2 WS-YES
     IF WS-YES = 1
         CALL "VM-NOTE" USING L-SLOT MT-LAST-WORKED WS-NOW
         CALL "VL-RESTOCK" USING L-SLOT WS-NOW WS-DID
     END-IF
     GOBACK.
 END PROGRAM VL-WORK-TICK.
