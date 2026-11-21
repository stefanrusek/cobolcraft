*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.4, with doc 44 part 1 section 4): choosing a position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-I                BINARY-LONG.
 01 WS-HITS             BINARY-LONG.
 01 WS-16               BINARY-LONG VALUE 16.
 01 WS-CX               BINARY-LONG VALUE 32.
 01 WS-CZ               BINARY-LONG VALUE -48.
 01 WS-MINY             BINARY-LONG VALUE -64.
 01 WS-TOP              BINARY-LONG VALUE 70.
 01 WS-RANGE            BINARY-LONG VALUE 135.
 01 WS-X                BINARY-LONG.
 01 WS-Y                BINARY-LONG.
 01 WS-Z                BINARY-LONG.
 01 WS-OK               BINARY-LONG.
 01 WS-A                BINARY-LONG.
 01 WS-B                BINARY-LONG.
 01 WS-C                BINARY-LONG.
 01 WS-L1               BINARY-DOUBLE UNSIGNED.
 01 WS-L2               BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "XORO-SEED" USING WS-SEED WS-MIRROR
         CALL "MS6-RANDOM-POS" USING XR-STATE WS-CX WS-CZ WS-MINY WS-TOP WS-X WS-Y WS-Z WS-OK
         CALL "XORO-NEXT-INT" USING WS-MIRROR WS-16 WS-A
         CALL "XORO-NEXT-INT" USING WS-MIRROR WS-16 WS-B
         CALL "XORO-NEXT-INT" USING WS-MIRROR WS-RANGE WS-C
         IF WS-X = WS-CX + WS-A AND WS-Z = WS-CZ + WS-B AND WS-Y = WS-MINY + WS-C
             ADD 1 TO WS-HITS
         END-IF
         CALL "XORO-NEXT-LONG" USING XR-STATE WS-L1
         CALL "XORO-NEXT-LONG" USING WS-MIRROR WS-L2
         IF WS-L1 = WS-L2
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.4 Choosing a position: x, z and y come from nextInt(16), nextInt(16), nextInt(top-minY+1) in that order, and no other draw" TO WS-CASE
     COMPUTE WS-E = 80
     COMPUTE WS-O = WS-HITS
     PERFORM CHECK-N
     MOVE 5 TO WS-SEED
     MOVE -64 TO WS-MINY
     MOVE -64 TO WS-TOP
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MS6-RANDOM-POS" USING XR-STATE WS-CX WS-CZ WS-MINY WS-TOP WS-X WS-Y WS-Z WS-OK
     MOVE "acceptance US15 18§6.4 Choosing a position: y = minY is skipped (y must be at least minY + 1)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 5 TO WS-SEED
     MOVE 70 TO WS-TOP
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RANDOM-POS" USING XR-STATE WS-CX WS-CZ WS-MINY WS-TOP WS-X WS-Y WS-Z WS-OK
         IF WS-Y >= WS-MINY AND WS-Y <= WS-TOP AND WS-X >= WS-CX AND WS-X < WS-CX + 16 AND WS-Z >= WS-CZ AND WS-Z < WS-CZ + 16
             ADD 1 TO WS-HITS
         END-IF
         IF (WS-OK = 1 AND WS-Y > WS-MINY) OR (WS-OK = 0 AND WS-Y = WS-MINY)
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.4 Choosing a position: 200 draws all lie in the chunk and in [minY, top], and are accepted exactly when y > minY " TO WS-CASE
     COMPUTE WS-E = 400
     COMPUTE WS-O = WS-HITS
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-4.
