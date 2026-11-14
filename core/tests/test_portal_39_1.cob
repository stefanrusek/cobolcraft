*> Implementation test (T1745; docs/protocol/39-portals.md section 1.1): the constants the portal rules read, as PORTAL.cpy holds them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PORTAL.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-F                   PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE PQ-MIN-WIDTH TO WS-A
     MOVE PQ-MAX-WIDTH TO WS-B
     MOVE PQ-MIN-HEIGHT TO WS-C
     MOVE PQ-MAX-HEIGHT TO WS-D
     MOVE PQ-PLACE-FLAGS TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§1 Constants, data inputs and cross-document hooks: interior width 2 to 21, height 3 to 21, "
         & "placement flags 18" TO TL-CASE
     MOVE "2 21 3 21 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PQ-RADIUS-NETHER TO WS-A
     MOVE PQ-RADIUS-OVERWORLD TO WS-B
     MOVE PQ-SPIRAL-RADIUS TO WS-C
     MOVE PQ-PLAYER-COOLDOWN TO WS-D
     MOVE PQ-DECAY TO WS-E
     MOVE PQ-DEFAULT-DELAY TO WS-F
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) " " FUNCTION TRIM(WS-F) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§1 Constants, data inputs and cross-document hooks: search radius 16 and 128, creation spiral 16, "
         & "player cooldown 10, decay 4, default delay 80" TO TL-CASE
     MOVE "16 128 16 10 4 80" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PORTAL-39-1.
