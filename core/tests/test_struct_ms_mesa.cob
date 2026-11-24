*> Acceptance test of the mesa mineshaft start (docs/protocol/36-structures-5 section 2.3 "mesa": the centre of the union box is moved to target = sea level when the
*> surface height h at the centre is at most the sea level, else sea level + nextInt(h - sea + 1), with h = getBaseHeight(centre x, centre z, WORLD_SURFACE_WG) from STRUCT-BASE-HEIGHT).
*> Over the fixture terrain core/tests/fixtures/height (land above sea level and water columns): the start is valid, the stub is 50 + dy, the centre of the union box after the shift lies
*> in [sea, max(sea, h)] (and is exactly sea where h <= sea), the same start made twice is the same, and some start is placed above sea level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-MS-MESA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CLIMATE.
 COPY STRUCTPIECE.
 01 WS-GEN-DIR             PIC X(1100) VALUE "core/tests/fixtures/height".
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 1.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-CENTRE-X            BINARY-LONG.
 01 WS-CENTRE-Y            BINARY-LONG.
 01 WS-CENTRE-Z            BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-H                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NOT-VALID           BINARY-LONG VALUE 0.
 01 WS-BAD-RANGE           BINARY-LONG VALUE 0.
 01 WS-BAD-FLAT            BINARY-LONG VALUE 0.
 01 WS-BAD-STUB            BINARY-LONG VALUE 0.
 01 WS-BAD-AGAIN           BINARY-LONG VALUE 0.
 01 WS-ABOVE               BINARY-LONG VALUE 0.
 01 WS-LAND                BINARY-LONG VALUE 0.
 01 WS-DY                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-EDIT                PIC Z(7)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-GEN-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-GEN-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "GEN-DATA-READY" USING WS-STATUS
     MOVE 0 TO WS-COUNT
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-CX FROM -4 BY 1 UNTIL WS-CX > 3
         PERFORM VARYING WS-CZ FROM -4 BY 1 UNTIL WS-CZ > 3
             CALL "MS-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
             ADD 1 TO WS-COUNT
             IF WS-VALID NOT = 1
                 ADD 1 TO WS-NOT-VALID
             END-IF
             COMPUTE WS-DY = WS-Y - 50
*>           the union box after the shift and its centre
             CALL "SPB-UNION-ALL" USING WS-BOX
             CALL "SPB-BOX-CENTER" USING WS-BOX WS-CENTRE-X WS-CENTRE-Y WS-CENTRE-Z
             CALL "STRUCT-BASE-HEIGHT" USING WS-CENTRE-X WS-CENTRE-Z WS-KIND WS-H
             IF WS-H > WS-LAND
                 MOVE WS-H TO WS-LAND
             END-IF
             MOVE WS-H TO WS-TOP
             IF WS-TOP < WS-SEA
                 MOVE WS-SEA TO WS-TOP
             END-IF
             IF WS-CENTRE-Y < WS-SEA OR WS-CENTRE-Y > WS-TOP
                 ADD 1 TO WS-BAD-RANGE
             END-IF
             IF WS-H <= WS-SEA AND WS-CENTRE-Y NOT = WS-SEA
                 ADD 1 TO WS-BAD-FLAT
             END-IF
             IF WS-CENTRE-Y > WS-SEA
                 ADD 1 TO WS-ABOVE
             END-IF
*>           the stub is the chunk's (8, 0) column at 50 + dy
             IF WS-X NOT = WS-CX * 16 + 8 OR WS-Z NOT = WS-CZ * 16 OR SP-Y0(1) NOT = 50 + WS-DY
                 ADD 1 TO WS-BAD-STUB
             END-IF
             CALL "MS-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-MST WS-SEA WS-MIN-Y WS-X2 WS-Y2 WS-Z2 WS-VALID
             IF WS-X2 NOT = WS-X OR WS-Y2 NOT = WS-Y OR WS-Z2 NOT = WS-Z
                 ADD 1 TO WS-BAD-AGAIN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-MS = WS-T0 - WS-T1
     MOVE WS-MS TO WS-EDIT
     DISPLAY "PROBE 64 mesa starts (two builds each, heights cold): " FUNCTION TRIM(WS-EDIT) " ms"
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: every start of the 64 chunks is valid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NOT-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: the centre of the union box lies in [sea level, max(sea level, h)]" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-RANGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: where h is at most the sea level the centre is exactly the sea level" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FLAT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: the stub is the chunk's column (8, 0) at 50 + dy" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-STUB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: the same start made twice is the same" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-AGAIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.3 Mineshaft mesa: some surface is above sea level and some start is placed above it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LAND > WS-SEA AND WS-ABOVE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-MS-MESA.

 COPY NOSPAWN.
 COPY CORETEST.
