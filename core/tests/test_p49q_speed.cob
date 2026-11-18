*> Walk speed multipliers of the villager brain (lane 002-lane-p49q, T37002; docs/protocol/19 section 22.3 and 44 part 3 section 2.17): a walk_target carries a speed modifier (a multiple of the
*> base speed s = 0.5, 1.0 = the standard mob speed) and the walk follows it: a villager walking at 1.5 s covers 1.5 times the ground of one walking at s. The brain's own modifiers: LocateHidingPlace
*> 1.25 s in HIDE and 1.4 s in RAID, the pre-raid walk to the meeting point 1.5 s (Q3-BLOCKMEM-PARAMS), StrollToPoi and StrollAroundPoi speed 0.4 (written as an absolute number: 0.8 s), SocializeAtBell
*> 0.3 (0.6 s), HarvestFarmland 0.5 (= s).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49Q-SPEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-XA                  FLOAT-LONG.
 01 WS-XB                  FLOAT-LONG.
 01 WS-DA                  FLOAT-LONG.
 01 WS-DB                  FLOAT-LONG.
 01 WS-SLOW                FLOAT-LONG VALUE 1.0.
 01 WS-FAST                FLOAT-LONG VALUE 1.5.
 01 WS-CLOSE               BINARY-LONG VALUE 1.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-BELL-X              BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 15
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-Z1 = WS-Z0 + 4
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-TX = WS-X0 + 28
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-A WS-SA
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z1 WS-B WS-SB
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM 3 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-A
         CALL "STDMOB-STEP" USING WS-B
     END-PERFORM
     MOVE EN-X(WS-A) TO WS-XA
     MOVE EN-X(WS-B) TO WS-XB
     CALL "VL-WALK-SET" USING WS-A WS-SA WS-DIM WS-TX WS-Y WS-Z0 WS-SLOW WS-CLOSE
     CALL "VL-WALK-SET" USING WS-B WS-SB WS-DIM WS-TX WS-Y WS-Z1 WS-FAST WS-CLOSE
     PERFORM 12 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-A
         CALL "STDMOB-STEP" USING WS-B
     END-PERFORM
     COMPUTE WS-DA = EN-X(WS-A) - WS-XA
     COMPUTE WS-DB = EN-X(WS-B) - WS-XB
     MOVE "test p49q a villager walking at s walks (the base case)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DA > 1.0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test p49q a villager walking at 1.5 s covers 1.5 times the ground of one at s (within 5 percent)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DB > WS-DA * 1.43 AND WS-DB < WS-DA * 1.57
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The hide walk of the brain: LocateHidingPlace in HIDE at 1.25 s and in RAID at 1.4 s (the speed is stored in thousandths in the walk target).
     MOVE 13000 TO CW-TIME
     CALL "VL-WALK-STOP" USING WS-A WS-SA
     COMPUTE WS-BELL-X = WS-X0 + 12
     CALL "VM-AT" USING WS-SA MT-HIDING-PLACE WS-DIM WS-BELL-X WS-Y WS-Z0
     MOVE CW-TICKS TO WS-NOW
     CALL "VM-NOTE" USING WS-SA MT-HEARD-BELL-TIME WS-NOW
     CALL "VM-ACT-SET" USING WS-SA VA-HIDE
     ADD 1 TO CW-TICKS
     CALL "VL-CORE-TICK" USING WS-A WS-SA WS-NO
     CALL "VM-GET" USING WS-SA MT-WALK-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "test p49q the hide walk (HIDE activity) is at 1.25 s" TO WS-CASE
     MOVE 1250 TO WS-E
     MOVE WS-N1 TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-P49Q-SPEED.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
