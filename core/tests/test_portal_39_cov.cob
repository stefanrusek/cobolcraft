*> Implementation test (lane nether; docs/protocol/39-portals.md sections 3 to 6): the remaining edge branches of the portal engine that the
*> section tests do not reach. A shape search below the dimension's lowest block, a frame whose right post lacks a block, an empty-shape search
*> in plain air, a portal block that keeps its state next to a portal neighbour or in a complete shape, removing an unknown point of interest,
*> a plant (no collision) that a frame replaces, a portal built from a fallback column and one built on a platform clamped below the creation
*> range, the relative position clamped at both ends, a body pushed out of a wall and a ceiling, and the point-of-interest scan skipping an
*> unresolved block set and a dimension without portals. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-COV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY PORTAL.
 COPY PORTALSHAPE.
 COPY PORTALRECT.
 COPY WSIM2.
 01 WS-SKIP                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG VALUE 7.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-SAVE                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-F                   PIC -(5)9.999999.
 01 WS-G                   PIC -(5)9.999999.
 01 WS-H                   PIC -(5)9.999999.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-EW                  FLOAT-LONG.
 01 WS-EH                  FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-SAVE-CX             FLOAT-LONG.
 01 WS-SAVE-CZ             FLOAT-LONG.
 01 WS-SAVE-SIZE           FLOAT-LONG.
 01 WS-SAVE-PI             BINARY-LONG.
 01 WS-SAVE-DIM            BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ROW-OUT             BINARY-LONG.
 01 WS-UP                  BINARY-LONG VALUE 1.
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-PS                  BINARY-LONG.
 01 WS-T                   PIC -(5)9.999999.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "test portal 39 cov: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "PORTAL-IDS-ENSURE"
     MOVE "stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE

*>   The shape search from y 3 of the Nether walks down no further than the dimension's lowest block (y 0).
     MOVE 2000 TO WS-X
     MOVE 3 TO WS-Y
     MOVE 2000 TO WS-Z
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
         CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-J WS-Z WS-AIR
     END-PERFORM
     CALL "PORTAL-FIND-SHAPE" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-A
     MOVE "acceptance US12-core 39§3 the shape search stops walking down at the dimension's lowest block: no shape from an open column at y 3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   A 2 x 3 frame (axis X, interior from (3000, 150, 3000) towards the west) whose right post lacks the block at row 1: no shape.
     MOVE 3000 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 3000 TO WS-Z
     MOVE 2 TO WS-I
     MOVE 3 TO WS-J
     CALL "PT-FRAME" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AXIS WS-I WS-J
     CALL "PORTAL-FIND-SHAPE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-A
     MOVE 2998 TO WS-X
     MOVE 151 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AIR
     MOVE 3000 TO WS-X
     MOVE 150 TO WS-Y
     CALL "PORTAL-FIND-SHAPE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AXIS PORTAL-SHAPE
     MOVE PQ-VALID TO WS-B
     MOVE "acceptance US12-core 39§3 a whole frame is a shape and the same frame without the right post block at row 1 is none" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     PERFORM CHECK

*>   The empty-shape search in plain air finds nothing.
     MOVE 3300 TO WS-X
     MOVE 200 TO WS-Y
     MOVE 3300 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AIR
     MOVE 9 TO PQ-VALID
     CALL "PORTAL-EMPTY-SHAPE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z PORTAL-SHAPE
     MOVE PQ-VALID TO WS-A
     MOVE "acceptance US12-core 39§3 the empty-shape search in plain air finds no shape (every field 0)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   A complete portal keeps its state when a vertical neighbour changes to air, and when the neighbour is a portal block.
     MOVE 3100 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 3100 TO WS-Z
     MOVE 2 TO WS-I
     MOVE 3 TO WS-J
     CALL "PT-FRAME" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AXIS WS-I WS-J
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-K = 3100 - WS-I
             COMPUTE WS-Y = 150 + WS-J
             CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-K WS-Y WS-Z PI-PORTAL-X
         END-PERFORM
     END-PERFORM
     MOVE 3100 TO WS-X
     MOVE 151 TO WS-Y
     CALL "PORTAL-UPDATE-SHAPE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z PI-PORTAL-X WS-UP WS-AIR WS-OUT
     MOVE WS-OUT TO WS-A
     MOVE PI-PORTAL-X TO WS-B
     MOVE PI-PORTAL-X TO WS-PS
     CALL "PORTAL-UPDATE-SHAPE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z PI-PORTAL-X WS-DOWN WS-PS WS-OUT
     MOVE WS-OUT TO WS-C
     MOVE "acceptance US12-core 39§3 a portal block of a complete shape keeps its state next to air above and next to a portal block below" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

*>   Removing a point of interest that was never recorded changes nothing.
     MOVE PQ-POI-COUNT TO WS-SAVE
     MOVE 77 TO WS-X
     MOVE 78 TO WS-Y
     MOVE 79 TO WS-Z
     CALL "PORTAL-POI-REMOVE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z
     COMPUTE WS-A = PQ-POI-COUNT - WS-SAVE
     MOVE "acceptance US12-core 39§5 removing a point of interest that was never recorded leaves the table as it is" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK

*>   A block without collision that is no fluid, fire or portal (the first one of the set) can be replaced by a frame.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT OR WS-STATE > 0
         COMPUTE WS-K = WS-I - 1
         IF CB-SOLID(WS-I) = 0 AND WS-K NOT = PI-AIR AND WS-K NOT = PI-CAVE-AIR AND WS-K NOT = PI-VOID-AIR
                 AND WS-K NOT = PI-FIRE AND WS-K NOT = PI-SOUL-FIRE AND WS-K NOT = PI-WATER AND WS-K NOT = PI-LAVA
                 AND WS-K NOT = PI-PORTAL
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-STATE
         END-IF
     END-PERFORM
     MOVE 3400 TO WS-X
     MOVE 200 TO WS-Y
     MOVE 3400 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STATE
     CALL "PORTAL-REPLACEABLE" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-OUT
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AIR
     MOVE WS-OUT TO WS-A
     MOVE "acceptance US12-core 39§5.2 a block without collision that is neither fluid, fire nor portal is replaceable" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK

*>   The relative position clamps at both ends along the axis and along the height.
     MOVE 10 TO PR-X MOVE 64 TO PR-Y MOVE 20 TO PR-Z
     MOVE 2 TO PR-W MOVE 3 TO PR-H MOVE 0 TO PR-AXIS
     MOVE 1.0 TO WS-EW
     MOVE 1.0 TO WS-EH
     MOVE 5.0 TO WS-FX MOVE 60.0 TO WS-FY MOVE 20.5 TO WS-FZ
     CALL "PORTAL-RELATIVE" USING PORTAL-RECT WS-FX WS-FY WS-FZ WS-EW WS-EH WS-RX WS-RY WS-RZ
     COMPUTE WS-F ROUNDED = WS-RX
     COMPUTE WS-G ROUNDED = WS-RY
     MOVE 30.0 TO WS-FX MOVE 90.0 TO WS-FY
     CALL "PORTAL-RELATIVE" USING PORTAL-RECT WS-FX WS-FY WS-FZ WS-EW WS-EH WS-RX WS-RY WS-RZ
     COMPUTE WS-H ROUNDED = WS-RX
     COMPUTE WS-T ROUNDED = WS-RY
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) " " FUNCTION TRIM(WS-H) " " FUNCTION TRIM(WS-T) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12-core 39§4.4 the relative position is clamped to 0 and 1 along the axis and the height (west of the portal and below it, east of it and above it)" TO TL-CASE
     MOVE "0.000000 0.000000 1.000000 1.000000" TO TL-EXPECTED
     PERFORM CHECK

*>   A wall to the north of a body at z 3200.1: the body is moved south to z 3200.3 (the free box lies wholly beyond the centre).
     PERFORM VARYING WS-I FROM 3199 BY 1 UNTIL WS-I > 3202
         PERFORM VARYING WS-J FROM 249 BY 1 UNTIL WS-J > 253
             PERFORM VARYING WS-K FROM 3198 BY 1 UNTIL WS-K > 3202
                 CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-I WS-J WS-K WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 3200 TO WS-X
     MOVE 250 TO WS-Y
     MOVE 3199 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE
     MOVE 251 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-STONE
     MOVE 0.6 TO WS-EW
     MOVE 1.8 TO WS-EH
     MOVE 3200.5 TO WS-FX
     MOVE 250.0 TO WS-FY
     MOVE 3200.1 TO WS-FZ
     CALL "PORTAL-FREE-POS" USING DIM-STANDARD-OVERWORLD WS-FX WS-FY WS-FZ WS-EW WS-EH
     COMPUTE WS-F ROUNDED = WS-FX
     COMPUTE WS-G ROUNDED = WS-FY
     COMPUTE WS-H ROUNDED = WS-FZ
     MOVE "acceptance US12-core 39§6.8 a body overlapping a wall to the north is moved south, z 3200.3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-G) " " FUNCTION TRIM(WS-H) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "3200.500000 250.000000 3200.300000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 250 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AIR
     MOVE 251 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-X WS-Y WS-Z WS-AIR

*>   PORTAL-CREATE with a world border that leaves only a few columns: a floor of stone at y 60 in the Nether, a stone row at y 61 along
*>   z 3998, 4001 and 4003, so that no candidate has both neighbouring slabs and the nearest own slab (the fallback) is used.
     CALL "WORLDSIM-ENSURE2"
     MOVE W2-B-CX(DIM-STANDARD-NETHER) TO WS-SAVE-CX
     MOVE W2-B-CZ(DIM-STANDARD-NETHER) TO WS-SAVE-CZ
     MOVE W2-B-SIZE(DIM-STANDARD-NETHER) TO WS-SAVE-SIZE
     PERFORM VARYING WS-I FROM 3998 BY 1 UNTIL WS-I > 4003
         PERFORM VARYING WS-K FROM 3998 BY 1 UNTIL WS-K > 4003
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 126
                 EVALUATE TRUE
                     WHEN WS-J <= 60
                         MOVE WS-STONE TO WS-STATE
                     WHEN WS-J = 61 AND (WS-K = 3998 OR WS-K = 4001 OR WS-K = 4003)
                         MOVE WS-STONE TO WS-STATE
                     WHEN OTHER
                         MOVE WS-AIR TO WS-STATE
                 END-EVALUATE
                 CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-NETHER WS-I WS-J WS-K WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 4000.5 TO W2-B-CX(DIM-STANDARD-NETHER)
     MOVE 4000.5 TO W2-B-CZ(DIM-STANDARD-NETHER)
     MOVE 3.0 TO W2-B-SIZE(DIM-STANDARD-NETHER)
     MOVE 4000 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 4000 TO WS-Z
     CALL "PORTAL-CREATE" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT WS-OK
     MOVE WS-OK TO WS-A
     MOVE PR-X TO WS-B
     MOVE PR-Z TO WS-C
     MOVE "acceptance US12-core 39§5.2 with only a candidate whose neighbouring slabs are blocked the fallback column hosts the portal (ok 1, x 3999..4000, z 3999..4002)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF WS-OK = 1 AND PR-X >= 3999 AND PR-X <= 4001 AND PR-Z >= 3999 AND PR-Z <= 4002
         MOVE "built" TO TL-OBSERVED
     ELSE
         STRING "ok " FUNCTION TRIM(WS-A) " x " FUNCTION TRIM(WS-B) " z " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "built" TO TL-EXPECTED
     PERFORM CHECK

*>   A border without a column near the origin forces the platform (phase B); an origin above the creation range is clamped to top - 9.
     MOVE 9000.5 TO W2-B-CX(DIM-STANDARD-NETHER)
     MOVE 9000.5 TO W2-B-CZ(DIM-STANDARD-NETHER)
     MOVE 1.0 TO W2-B-SIZE(DIM-STANDARD-NETHER)
     MOVE 4000 TO WS-X
     MOVE 125 TO WS-Y
     MOVE 4000 TO WS-Z
     CALL "PORTAL-CREATE" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-AXIS PORTAL-RECT WS-OK
     MOVE WS-SAVE-CX TO W2-B-CX(DIM-STANDARD-NETHER)
     MOVE WS-SAVE-CZ TO W2-B-CZ(DIM-STANDARD-NETHER)
     MOVE WS-SAVE-SIZE TO W2-B-SIZE(DIM-STANDARD-NETHER)
     MOVE WS-OK TO WS-A
     MOVE PR-Y TO WS-B
     MOVE "acceptance US12-core 39§5.2 a platform for an origin at y 125 in the Nether is built at the top of the creation range (y 118)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING "ok " FUNCTION TRIM(WS-A) " y " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "ok 1 y 118" TO TL-EXPECTED
     PERFORM CHECK

*>   The point-of-interest scan of a chunk skips an unresolved block set and a dimension without portals.
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ROW-OUT
     MOVE 1 TO WS-I
     MOVE PQ-POI-COUNT TO WS-SAVE
     MOVE PI-PORTAL TO WS-SAVE-PI
     MOVE -1 TO PI-PORTAL
     CALL "PORTAL-POI-SCAN" USING WS-I
     MOVE WS-SAVE-PI TO PI-PORTAL
     MOVE CK-DIM(WS-I) TO WS-SAVE-DIM
     MOVE DIM-STANDARD-END TO CK-DIM(WS-I)
     CALL "PORTAL-POI-SCAN" USING WS-I
     MOVE WS-SAVE-DIM TO CK-DIM(WS-I)
     COMPUTE WS-A = PQ-POI-COUNT - WS-SAVE
     MOVE "acceptance US12-core 39§5.1 the point-of-interest scan records nothing when the portal block is unknown or the chunk is in the End" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-COV.

 COPY CORETEST.
 COPY PORTALTEST.
