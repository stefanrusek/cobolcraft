 *> Implementation test of the Player's eye height and fluid box by content set (T58602; docs/protocol/53 section 2.1: standing box 0.6 x 1.8 with eye 1.62, crouching eye 1.27, swimming eye 0.4;
*> client/src/physics.cob PHYS-EYE and PHYS-STAND-BOX, physics-fluid.cob PHYS-FLUID): with a standard content set open the fluid box is 0.6 wide and the eye 1.62 above the feet (the
*> cobolcraft stand-in set and a client with no set keep the operator's 0.7 x 1.75 and eye 1.6, 1.25 crouching).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PHYS-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-BODY                PIC X(8).
 01 WS-BLEN                BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-POSE                BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 01 WS-EDIT2               PIC -(4)9.9(4).
 01 WS-EDIT3               PIC -(4)9.9(4).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
*>   State 4 is a water source (rows are state + 1).
     MOVE 1 TO ST-FLUID(5)
     MOVE 0 TO ST-LEVEL(5) ST-OPAQUE(5)
     MOVE "T" TO TL-MODE

*>   No content set: the operator's eye heights.
     PERFORM EYES
     MOVE "phys eye no content set: standing 1.6, crouching 1.25, swimming 0.4" TO TL-CASE
     MOVE "1.6000 1.2500 0.4000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Water in the cell x 1 of the Player's row, the Player at x 0.7: the operator's box (half width 0.35) reaches it.
     MOVE 4 TO WS-STATE
     MOVE 1 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     PERFORM FLUID-AT-EDGE
     MOVE "phys eye no content set: the box 0.7 wide at x 0.7 touches the water of the next cell" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A standard content set (an empty Update Tags opens it).
     MOVE X"00" TO WS-BODY(1:1)
     CALL "CONTENT-CLIENT-REGISTRY-ADD" USING WS-PACKET-ID WS-BODY WS-BLEN WS-STATUS
     PERFORM EYES
     MOVE "phys eye standard set: standing 1.62, crouching 1.27, swimming 0.4 (53 section 2.1)" TO TL-CASE
     MOVE "1.6200 1.2700 0.4000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FLUID-AT-EDGE
     MOVE "phys eye standard set: the box 0.6 wide at x 0.7 does not reach the next cell" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Water in the cell y 12 of the Player's column, the feet at 10.39: the eye is at 12.01 (1.62) in the cell, at 11.99 (1.6) below it.
     MOVE 0 TO WS-STATE
     MOVE 1 TO WS-X
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 4 TO WS-STATE
     MOVE 0 TO WS-X
     MOVE 12 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO PL-X PL-Z
     MOVE 10.39 TO PL-Y
     MOVE 0 TO PL-POSE
     CALL "PHYS-FLUID" USING CLIENT-STATE
     MOVE "phys eye standard set: feet 10.39 puts the eye (12.01) inside the water of the cell y 12" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING PL-IN-WATER PL-EYE-WATER DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "11" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The three eye heights of the standing (0), crouching (5) and swimming (3) pose in TL-OBSERVED.
 EYES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-POSE
     CALL "PHYS-EYE" USING WS-POSE WS-EYE
     COMPUTE WS-EDIT ROUNDED = WS-EYE
     MOVE 5 TO WS-POSE
     CALL "PHYS-EYE" USING WS-POSE WS-EYE
     COMPUTE WS-EDIT2 ROUNDED = WS-EYE
     MOVE 3 TO WS-POSE
     CALL "PHYS-EYE" USING WS-POSE WS-EYE
     COMPUTE WS-EDIT3 ROUNDED = WS-EYE
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     .

*> The Player standing at x 0.7, y 10, z 0.5: PL-IN-WATER in TL-OBSERVED.
 FLUID-AT-EDGE.
     MOVE 0.7 TO PL-X
     MOVE 0.5 TO PL-Z
     MOVE 10 TO PL-Y
     MOVE 0 TO PL-POSE
     CALL "PHYS-FLUID" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE PL-IN-WATER TO TL-OBSERVED(1:1)
     .
 END PROGRAM TEST-PHYS-EYE.

 COPY CLTEST.
