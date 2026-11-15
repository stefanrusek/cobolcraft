*> Implementation test (T1753; docs/protocol/39-portals.md section 5): PortalForcer. Creating a portal (5.2): the nearest spiral column whose slab can
*> be built (floor solid, 4 x 5 replaceable above), the frame of 14 obsidian cells and the 2 x 3 interior of E5; with no column at all the
*> platform of phase B; finding one (5.1): the portal points of interest within 16 blocks of a nether origin or 128 of an overworld one, the
*> nearest by squared distance with the lower y on a tie (E6). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTALRECT.
 01 WS-SKIP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-PORTAL-X            BINARY-LONG.
 01 WS-PORTAL-Z            BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-KEY-PORTAL          PIC X(48) VALUE "nether_portal".
 01 WS-KEY-OBSIDIAN        PIC X(48) VALUE "obsidian".
 01 WS-PAIRS-NONE          PIC X(160) VALUE SPACES.
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-PAIRS-Z             PIC X(160) VALUE "axis=z".
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-FRAME               PIC X(40).
 01 WS-SECOND              PIC X(40).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§5 PortalForcer: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-X WS-PORTAL-X
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-Z WS-PORTAL-Z
     CALL "PT-STATE" USING WS-KEY-OBSIDIAN WS-PAIRS-NONE WS-OBSIDIAN

*>   5.2, nether chunk (0, 0) (floor to y 40, air from 41): origin (5, 60, 5) gives P = (5, 41, 5) along X.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 5 TO WS-OX MOVE 60 TO WS-OY MOVE 5 TO WS-OZ
     MOVE 0 TO WS-AXIS
     CALL "PORTAL-CREATE" USING WS-DIM WS-OX WS-OY WS-OZ WS-AXIS PORTAL-RECT WS-OK
     PERFORM RECT-TEXT
     MOVE "acceptance US12 39§5 PortalForcer: 5.2 a portal made at origin (5, 60, 5) of the nether sits on the floor at "
         & "(5, 41, 5), 2 x 3, along X" TO TL-CASE
     MOVE "1 5 41 5 2 3" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 6 TO WS-X MOVE 41 TO WS-Y MOVE 5 TO WS-Z
     MOVE 2 TO WS-W MOVE 3 TO WS-H
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-X FROM 4 BY 3 UNTIL WS-X > 7
         PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 44
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = WS-OBSIDIAN
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-X FROM 5 BY 1 UNTIL WS-X > 6
         MOVE 40 TO WS-Y
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = WS-OBSIDIAN
             ADD 1 TO WS-COUNT
         END-IF
         MOVE 44 TO WS-Y
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = WS-OBSIDIAN
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " portal blocks, " FUNCTION TRIM(WS-B) " obsidian" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§5 PortalForcer: 5.2 phase C builds six portal blocks and the 14 obsidian cells of the 4 x 5 ring "
         & "(x 4 and 7 at y 40 to 44, x 5 and 6 at y 40 and 44)" TO TL-CASE
     MOVE "6 portal blocks, 14 obsidian" TO TL-EXPECTED
     PERFORM CHECK

*>   5.1 finding it: from (6, 50, 6) the nearest portal block is (6, 43, 5); radius 16 for a nether destination, 128 for an overworld one.
     MOVE 6 TO WS-OX MOVE 50 TO WS-OY MOVE 6 TO WS-OZ
     MOVE 1 TO WS-NETHER
     CALL "PORTAL-FIND-EXISTING" USING WS-DIM WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-X WS-Y WS-Z
     PERFORM FOUND-TEXT
     MOVE "acceptance US12 39§5 PortalForcer: 5.1 the portal made above is found again from (6, 50, 6): nearest block (6, 43, 5)" TO TL-CASE
     MOVE "1 6 43 5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE 30 TO WS-OX
     CALL "PORTAL-FIND-EXISTING" USING WS-DIM WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-X WS-Y WS-Z
     PERFORM FOUND-TEXT
     MOVE SPACES TO WS-FRAME
     MOVE TL-OBSERVED TO WS-FRAME
     MOVE 0 TO WS-NETHER
     CALL "PORTAL-FIND-EXISTING" USING WS-DIM WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-X WS-Y WS-Z
     PERFORM FOUND-TEXT
     MOVE TL-OBSERVED TO WS-SECOND
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-FRAME) " / " FUNCTION TRIM(WS-SECOND) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§5 PortalForcer: V13 24 blocks away the portal is out of reach for a nether destination (radius 16) "
         & "and found for an overworld one (radius 128)" TO TL-CASE
     MOVE "0 0 0 0 / 1 6 43 5" TO TL-EXPECTED
     PERFORM CHECK

*>   E6: two portal blocks at equal squared distance 18 from (0, 67, 0), at y 70 and y 64: the lower is chosen.
     MOVE 1 TO WS-NETHER
     MOVE 3 TO WS-X MOVE 70 TO WS-Y MOVE 0 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PORTAL-X
     CALL "PORTAL-POI-ADD" USING WS-DIM WS-X WS-Y WS-Z
     MOVE 64 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-PORTAL-X
     CALL "PORTAL-POI-ADD" USING WS-DIM WS-X WS-Y WS-Z
     MOVE 0 TO WS-OX MOVE 67 TO WS-OY MOVE 0 TO WS-OZ
     CALL "PORTAL-FIND-EXISTING" USING WS-DIM WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-X WS-Y WS-Z
     PERFORM FOUND-TEXT
     MOVE "acceptance US12 39§5 PortalForcer: E6 portal blocks at equal squared distance, at y 70 and y 64, give the one at y 64" TO TL-CASE
     MOVE "1 3 64 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 39§5 PortalForcer: a point of interest whose block is no portal any more is not found (the record is stale)" TO TL-CASE
     MOVE 3 TO WS-X MOVE 64 TO WS-Y MOVE 0 TO WS-Z
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "PORTAL-FIND-EXISTING" USING WS-DIM WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-X WS-Y WS-Z
     PERFORM FOUND-TEXT
     MOVE "1 3 70 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Axis Z in an even chunk (13, 19): P = (210, 41, 310), interior z 310 and 311, frame z 309 and 312.
     MOVE 210 TO WS-OX MOVE 60 TO WS-OY MOVE 310 TO WS-OZ
     MOVE 1 TO WS-AXIS
     CALL "PORTAL-CREATE" USING WS-DIM WS-OX WS-OY WS-OZ WS-AXIS PORTAL-RECT WS-OK
     PERFORM RECT-TEXT
     MOVE "acceptance US12 39§5 PortalForcer: E5 along Z the portal made at (210, 60, 310) has P = (210, 41, 310), 2 x 3" TO TL-CASE
     MOVE "1 210 41 310 2 3" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 210 TO WS-X MOVE 41 TO WS-Y MOVE 310 TO WS-Z
     MOVE 2 TO WS-W MOVE 3 TO WS-H
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE 309 TO WS-Z MOVE 40 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-COUNT
     IF WS-STATE = WS-OBSIDIAN ADD 1 TO WS-COUNT END-IF
     MOVE 312 TO WS-Z MOVE 44 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     IF WS-STATE = WS-OBSIDIAN ADD 1 TO WS-COUNT END-IF
     MOVE 310 TO WS-Z MOVE 41 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-COUNT TO WS-B
     MOVE SPACES TO TL-OBSERVED
     IF WS-STATE = WS-PORTAL-Z
         STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " z" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " other" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "acceptance US12 39§5 PortalForcer: E5 along Z the interior is nether_portal axis Z and the frame corners are obsidian" TO TL-CASE
     MOVE "6 2 z" TO TL-EXPECTED
     PERFORM CHECK

*>   Phase B: the end around (500, 60, 500) is void, so no column hosts the frame: a platform at y 69 and the frame at (499, 70, 500).
     MOVE DIM-STANDARD-END TO WS-DIM
     MOVE 500 TO WS-OX MOVE 60 TO WS-OY MOVE 500 TO WS-OZ
     MOVE 0 TO WS-AXIS
     CALL "PORTAL-CREATE" USING WS-DIM WS-OX WS-OY WS-OZ WS-AXIS PORTAL-RECT WS-OK
     PERFORM RECT-TEXT
     MOVE "acceptance US12 39§5 PortalForcer: 5.2 phase B with no hosting column builds the frame at the origin moved back "
         & "one block and raised to y 70: (499, 70, 500)" TO TL-CASE
     MOVE "1 499 70 500 2 3" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-X FROM 499 BY 1 UNTIL WS-X > 500
         PERFORM VARYING WS-Z FROM 499 BY 1 UNTIL WS-Z > 501
             MOVE 69 TO WS-Y
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = WS-OBSIDIAN ADD 1 TO WS-COUNT END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-COUNT TO WS-A
     MOVE 499 TO WS-X MOVE 500 TO WS-Z MOVE 71 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO TL-OBSERVED
     IF WS-STATE = WS-PORTAL-X
         STRING FUNCTION TRIM(WS-A) " x" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-A) " other" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "acceptance US12 39§5 PortalForcer: 5.2 the platform is a 3 x 2 floor of obsidian at y 69 under a portal of axis X" TO TL-CASE
     MOVE "6 x" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 RECT-TEXT.
     MOVE WS-OK TO WS-A
     MOVE PR-X TO WS-B
     MOVE PR-Y TO WS-C
     MOVE PR-Z TO WS-D
     MOVE PR-W TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PR-H TO WS-A
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO TL-OBSERVED.

 FOUND-TEXT.
     MOVE WS-FOUND TO WS-A
     MOVE 0 TO WS-B WS-C WS-D
     IF WS-FOUND = 1
         MOVE WS-X TO WS-B
         MOVE WS-Y TO WS-C
         MOVE WS-Z TO WS-D
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-5.

 COPY CORETEST.
 COPY PORTALTEST.
