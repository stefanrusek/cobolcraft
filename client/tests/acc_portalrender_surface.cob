*> Acceptance test of the operator report "an opened end portal (and an end gateway) is a see-through hole" (lane portalrender, T54020 to T54031; docs/protocol/52 section 8,
*> the validation list 8.13): the client creates the block entities of type 14 and 22 only from the chunk packet's list or a block change (E1) and draws them: the
*> portal's slab faces at y 0.375 and 0.75 (E2) with no side face and the top invisible from below (E3), the distances 64 and 256 (E4), the gateway's faces except
*> those against a full block (E5), the gateway's Age read from the entry's tag. The standard content set (compiled in) names the blocks; the colour of a vertex is the
*> shader's sum for its screen position (here the textures are one texel each, so every vertex has the same colour).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PORTALRENDER-SURFACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PORTAL              BINARY-LONG.
 01 WS-GATEWAY             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-AGE                 BINARY-DOUBLE.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HEADS.
    05 WS-HEAD             BINARY-LONG OCCURS 2560 TIMES.
 01 WS-DATA                PIC X(262144).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV-TABLE.
    05 WS-PV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-EXP                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-MILLI-A             PIC -(6)9.
 01 WS-MILLI-B             PIC -(6)9.
 01 WS-EDIT                PIC -(4)9.9(7).
 01 WS-CORNERS.
    05 WS-CORNER           FLOAT-LONG OCCURS 12 TIMES.
 01 WS-REL.
    05 WS-RX               FLOAT-LONG.
    05 WS-RY               FLOAT-LONG.
    05 WS-RZ               FLOAT-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LAYERS              BINARY-LONG.
 01 WS-GT                  FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-TAG                 PIC X(40).
 01 WS-TAG-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 256 TO PL-HEIGHT
     MOVE 128 TO UA-W UA-H
     MOVE "end_portal" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-PORTAL WS-STATUS
     MOVE "end_gateway" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-GATEWAY WS-STATUS
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
*>   The textures: one texel each (sky (100, 50, 200), portal 0): every vertex is the sky's texel times the first tint.
     MOVE 1 TO EP-TEX EP-SKY-W EP-SKY-H EP-PTX-W EP-PTX-H
     MOVE FUNCTION CHAR(101) TO EP-SKY(1:1)
     MOVE FUNCTION CHAR(51) TO EP-SKY(2:1)
     MOVE FUNCTION CHAR(201) TO EP-SKY(3:1)
     MOVE FUNCTION CHAR(256) TO EP-SKY(4:1)
     MOVE FUNCTION CHAR(1) TO EP-PTX(1:1) EP-PTX(2:1) EP-PTX(3:1)
     MOVE FUNCTION CHAR(256) TO EP-PTX(4:1)
*>   A projection x view for the test: clip x = x / 100, clip y = z / 100, w = 10 (everything within 1000 blocks is in view).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO WS-PV(WS-I)
     END-PERFORM
     MOVE 0.01 TO WS-PV(1)
     MOVE 0.01 TO WS-PV(10)
     MOVE 0.5 TO WS-PV(15)
     MOVE 10 TO WS-PV(16)
     MOVE "T" TO TL-MODE

*>   The block kinds of the standard set.
     CALL "PORTAL-BLOCK-KIND" USING CLIENT-STATE WS-PORTAL WS-KIND
     MOVE "portal surface the state of end_portal is kind 14" TO TL-CASE
     PERFORM CHECK-KIND-14
     CALL "PORTAL-BLOCK-KIND" USING CLIENT-STATE WS-GATEWAY WS-KIND
     MOVE "portal surface the state of end_gateway is kind 22" TO TL-CASE
     MOVE 22 TO WS-VAL
     PERFORM CHECK-KIND
     CALL "PORTAL-BLOCK-KIND" USING CLIENT-STATE WS-STONE WS-KIND
     MOVE "portal surface the state of stone is kind 0" TO TL-CASE
     MOVE 0 TO WS-VAL
     PERFORM CHECK-KIND
     MOVE 99999999 TO WS-ID
     CALL "PORTAL-BLOCK-KIND" USING CLIENT-STATE WS-ID WS-KIND
     MOVE "portal surface a state beyond the table is kind 0" TO TL-CASE
     MOVE 0 TO WS-VAL
     PERFORM CHECK-KIND

*>   A loaded chunk (0, 0) with an end_portal at (3, 64, 3) written into its cells, as a chunk packet that lists no entity for it leaves it.
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-CHUNK)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE WS-PORTAL TO CE-STATE(1 + (64 * 256 + 3 * 16 + 3))
     MOVE 0 TO WS-COUNT
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE 3 TO WS-EYE(1) MOVE 70 TO WS-EYE(2) MOVE 3 TO WS-EYE(3)
     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "N" TO TL-MODE
     MOVE "portal surface E1: a chunk packet that lists no block entity for the end_portal block draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The same chunk sent with the entry (type 14, empty tag): the slab's top face at y 64.75.
     MOVE 1 TO WS-COUNT
     MOVE 3 TO WS-HEAD(1)
     MOVE 64 TO WS-HEAD(2)
     MOVE 3 TO WS-HEAD(3)
     MOVE 14 TO WS-HEAD(4)
     MOVE 0 TO WS-HEAD(5)
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE "portal surface E1: with the entry (type 14, empty tag) one entity exists" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E1: seen from above it draws the top face only, an 8 x 8 grid at 7 blocks (384 vertices)" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     PERFORM RANGE-OF-Y
     MOVE "portal surface E2: the top face lies at y 64.75 (5.25 below the eye at 70)" TO TL-CASE
     MOVE "-5250 -5250" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM RANGE-OF-X
     MOVE "portal surface E2: its x runs from 3 to 4 blocks (2.5 to 3.5 from the eye)" TO TL-CASE
     MOVE "2500 3500" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "portal surface the vertex colour is the sky texel (100, 50, 200) times the first tint, alpha and brightness 1" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-I
     COMPUTE WS-VAL = RL-EP-R(1) * 1000000
     COMPUTE WS-MILLI-A ROUNDED = WS-VAL
     COMPUTE WS-VAL = RL-EP-BLUE(RL-EP-COUNT) * 1000000
     COMPUTE WS-MILLI-B ROUNDED = WS-VAL
     STRING FUNCTION TRIM(WS-MILLI-A) " " FUNCTION TRIM(WS-MILLI-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "8662 86916" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "portal surface the quads are opaque on the swatch: alpha and brightness 1, no sky term" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-EP-A(7) * RL-EP-B(7) + RL-EP-SKY(7)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   E3: from below the bottom face only (y 64.375), from inside the slab nothing.
     MOVE 60 TO WS-EYE(2)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E3: from below it draws the bottom face only (8 x 8 grid, 384 vertices)" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     PERFORM RANGE-OF-Y
     MOVE "portal surface E2: the bottom face lies at y 64.375 (4.375 above the eye at 60)" TO TL-CASE
     MOVE "4375 4375" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64.5 TO WS-EYE(2)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "N" TO TL-MODE
     MOVE "portal surface E3: from inside the slab (y 64.5) no face is drawn, and no side face ever" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Grid sizes by distance: 8 x 8 within 12 blocks (384 vertices), 4 x 4 from 12 to 40 (96), 2 x 2 beyond 40 (24).
     MOVE 66 TO WS-EYE(2)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface within 12 blocks the face is an 8 x 8 grid (384 vertices)" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 80 TO WS-EYE(2)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface from 12 to 40 blocks the face is a 4 x 4 grid (96 vertices)" TO TL-CASE
     MOVE 96 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 110 TO WS-EYE(2)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface beyond 40 blocks (and within 64) the face is a 2 x 2 grid (24 vertices)" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   E4: closer than 64 blocks from the block's centre.
     MOVE 3.5 TO WS-EYE(1) WS-EYE(3)
     COMPUTE WS-EYE(2) = 64.5 + 63.9
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E4: drawn at 63.9 blocks" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-EYE(2) = 64.5 + 64.1
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E4: not drawn at 64.1 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
*>   The frame's clock: the fraction of the tick enters GameTime (no effect on a one-texel image, the calls run).
     MOVE 70 TO WS-EYE(2)
     MOVE 1000 TO CL-NOW-MS
     MOVE 1010 TO CL-NEXT-TICK
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE 1100 TO CL-NEXT-TICK
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface a frame early in the tick and one more than a tick before the next draw the same face" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block change makes or drops the entity (8.1 point 2): the second portal cell at (4, 64, 3) by Block Update, then stone over the first.
     MOVE 4 TO WS-X MOVE 64 TO WS-Y MOVE 3 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-PORTAL
     MOVE "portal surface E1: a block change to end_portal creates the entity (2 now)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-PORTAL
     MOVE "portal surface a second change to the same state keeps the one entity (2)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE "portal surface a block change of the cell to stone drops its entity (1 left)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-ZERO WS-Z WS-STONE
     MOVE "portal surface a change to stone of a cell that had none leaves the table alone (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     CALL "PORTAL-BE-REMOVE" USING CLIENT-STATE WS-X WS-Y WS-Z
     MOVE "portal surface removing an entity that is not there changes nothing (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Forgetting the chunk drops its entities; a chunk sent again replaces them.
     CALL "WORLD-FORGET" USING CLIENT-STATE WS-ZERO WS-ZERO
     MOVE "portal surface Forget Level Chunk drops the chunk's entities (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-COUNT
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE 1 TO WS-X
     MOVE 5 TO WS-HEAD(1)
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE "portal surface a chunk sent again replaces its entities (still 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-I
     MOVE 21 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 14 TO WS-TYPE
     MOVE 0 TO WS-AGE
     CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     MOVE ZERO TO WS-X
     CALL "PORTAL-BE-FORGET" USING CLIENT-STATE WS-ZERO WS-ZERO
     MOVE "portal surface forgetting chunk (0, 0) leaves the entity of chunk (1, 0) (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     MOVE "portal surface a cleared world (a dimension change) holds none (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entries of other types are not entities of this lane; a type 22 entry with no tag has age 0; the table is bounded.
     MOVE 2 TO WS-COUNT
     MOVE 1 TO WS-HEAD(1) MOVE 64 TO WS-HEAD(2) MOVE 1 TO WS-HEAD(3) MOVE 1 TO WS-HEAD(4) MOVE 0 TO WS-HEAD(5)
     MOVE 2 TO WS-HEAD(6) MOVE 64 TO WS-HEAD(7) MOVE 2 TO WS-HEAD(8) MOVE 22 TO WS-HEAD(9) MOVE 0 TO WS-HEAD(10)
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE "portal surface a chest entry is not kept, a gateway entry without a tag is (1, age 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EP-COUNT + EP-AGE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The gateway's tag: ExactTeleport (a byte), exit_portal (an int array of 3), Age (a long 60), End: the walker finds the Age.
     MOVE 1 TO WS-COUNT
     MOVE 5 TO WS-HEAD(1) MOVE 64 TO WS-HEAD(2) MOVE 5 TO WS-HEAD(3) MOVE 22 TO WS-HEAD(4)
     MOVE SPACES TO WS-DATA
     MOVE 1 TO WS-I
     STRING X"0A" X"01000D" "ExactTeleport" X"01" X"0B000B" "exit_portal" X"00000003" X"000000010000000200000003"
         X"040003" "Age" X"000000000000003C" X"00" DELIMITED BY SIZE INTO WS-DATA WITH POINTER WS-I
     COMPUTE WS-HEAD(5) = WS-I - 1
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE 5 TO WS-X MOVE 64 TO WS-Y MOVE 5 TO WS-Z
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ROW
     MOVE "portal surface the gateway entry's tag with ExactTeleport, exit_portal and Age 60 gives Age 60" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE EP-AGE(WS-ROW) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A tag with another long first (Age is not it), a tag with an unknown tag type, and an empty compound.
     MOVE 6 TO WS-HEAD(1)
     MOVE SPACES TO WS-DATA
     MOVE 1 TO WS-I
     STRING X"0A" X"040003" "Bge" X"0000000000000009" X"040003" "Age" X"0000000000000007" X"00" DELIMITED BY SIZE INTO WS-DATA WITH POINTER WS-I
     COMPUTE WS-HEAD(5) = WS-I - 1
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE 6 TO WS-X
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ROW
     MOVE "portal surface a long named Bge before Age is skipped: Age 7" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE EP-AGE(WS-ROW) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-HEAD(1)
     MOVE SPACES TO WS-DATA
     MOVE 1 TO WS-I
     STRING X"0A" X"080003" "Age" X"0000" X"00" DELIMITED BY SIZE INTO WS-DATA WITH POINTER WS-I
     COMPUTE WS-HEAD(5) = WS-I - 1
     CALL "PORTAL-BE-CHUNK" USING CLIENT-STATE WS-ZERO WS-ZERO WS-COUNT WS-HEADS WS-DATA
     MOVE 7 TO WS-X
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ROW
     MOVE "portal surface a tag of a type the walker does not know stops it: Age 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE -1 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE EP-AGE(WS-ROW) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One client tick: a gateway's age counts up and its cooldown down, a portal's does not.
     MOVE 8 TO WS-X
     MOVE 14 TO WS-TYPE
     MOVE 5 TO WS-AGE
     CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     MOVE 22 TO WS-TYPE
     MOVE 9 TO WS-X
     CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ROW
     MOVE 2 TO EP-COOLDOWN(WS-ROW)
     CALL "PORTAL-BE-TICK" USING CLIENT-STATE
     CALL "PORTAL-BE-TICK" USING CLIENT-STATE
     CALL "PORTAL-BE-TICK" USING CLIENT-STATE
     MOVE "portal surface three client ticks: the gateway's age 5 becomes 8 and its cooldown 2 stops at 0" TO TL-CASE
     MOVE 800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EP-AGE(WS-ROW) * 100 + EP-COOLDOWN(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-X
     CALL "PORTAL-BE-FIND" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ROW
     MOVE "portal surface the portal's age does not change" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EP-AGE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The table is bounded (CL-MAX-PORTALS): the 1025th entity is not made.
     MOVE 0 TO EP-COUNT
     MOVE 14 TO WS-TYPE
     MOVE 0 TO WS-AGE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MAX-PORTALS + 5
         MOVE WS-I TO WS-X
         CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     END-PERFORM
     MOVE "portal surface the table holds CL-MAX-PORTALS entities and no more" TO TL-CASE
     MOVE CL-MAX-PORTALS TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second entity at a position keeps the first and takes the new type.
     MOVE 0 TO EP-COUNT
     MOVE 4 TO WS-X MOVE 64 TO WS-Y MOVE 3 TO WS-Z
     MOVE 14 TO WS-TYPE
     CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     MOVE 22 TO WS-TYPE
     CALL "PORTAL-BE-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-TYPE WS-AGE
     MOVE "portal surface an entity set again at its position stays one and takes the new type (1, 22)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 22
     COMPUTE TL-OBSERVED-N = EP-COUNT * 100 + EP-TYPE(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EP-COUNT

*>   E5: a gateway with a stone block on all six sides draws no face; with air above it, the up face (seen from above).
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ONE WS-ZERO WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-CHUNK)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE 20 TO WS-X MOVE 64 TO WS-Y MOVE 3 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-GATEWAY
     MOVE 19 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE 21 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE 20 TO WS-X
     MOVE 63 TO WS-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE 65 TO WS-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE 64 TO WS-Y
     MOVE 2 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE 4 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     MOVE "portal surface E5 set-up: the gateway entity was made by its block change" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20.5 TO WS-EYE(1)
     MOVE 110 TO WS-EYE(2)
     MOVE 3.5 TO WS-EYE(3)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E5: a gateway with a stone block on all six sides draws no face" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 65 TO WS-Y
     MOVE 0 TO WS-STATE
     MOVE 20 TO WS-X MOVE 3 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E5: with air above it the up face is drawn (a 2 x 2 grid at 25 blocks: 24 vertices)" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Seen from the north-west above, with air all round: the up, north and west faces (the gateway's six faces are eligible, 72 vertices at that distance).
     MOVE 64 TO WS-Y
     MOVE 19 TO WS-X
     MOVE 3 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 20 TO WS-X
     MOVE 2 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE -20 TO WS-EYE(1)
     MOVE 90 TO WS-EYE(2)
     MOVE -20 TO WS-EYE(3)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface the gateway seen from the north-west above draws up, north and west (72 vertices)" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   E4: the gateway's distance is 256.
     MOVE 20.5 TO WS-EYE(1)
     COMPUTE WS-EYE(2) = 64.5 + 255.9
     MOVE 3.5 TO WS-EYE(3)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E4: the gateway is drawn at 255.9 blocks (up face, 24 vertices)" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-EYE(2) = 64.5 + 256.1
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface E4: and not at 256.1 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The view test of a face: wholly behind the eye, wholly outside one side, partly in view.
     MOVE 1 TO WS-CORNER(1) MOVE 64 TO WS-CORNER(2) MOVE 1 TO WS-CORNER(3)
     MOVE 1 TO WS-CORNER(4) MOVE 64 TO WS-CORNER(5) MOVE 2 TO WS-CORNER(6)
     MOVE 2 TO WS-CORNER(7) MOVE 64 TO WS-CORNER(8) MOVE 2 TO WS-CORNER(9)
     MOVE 2 TO WS-CORNER(10) MOVE 64 TO WS-CORNER(11) MOVE 1 TO WS-CORNER(12)
     MOVE 0 TO WS-RX WS-RY WS-RZ
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face in front of the eye is in view" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5000 TO WS-RX
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face wholly right of the view is out" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5000 TO WS-RX
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face wholly left of the view is out" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-RX
     MOVE 5000 TO WS-RZ
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face wholly below the view is out" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5000 TO WS-RZ
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face wholly above the view is out" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-RZ
     MOVE -10 TO WS-PV(16)
     CALL "PORTAL-IN-VIEW" USING WS-PV-TABLE WS-CORNERS WS-REL WS-RESULT
     MOVE "portal surface a face wholly behind the eye (w below 0) is out" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A vertex behind the eye still gets a colour (nearest depth): w = x + 0.01 here, so the face's x of -1 and 0 gives w of -0.99 and 0.01.
     MOVE 0.01 TO WS-PV(16)
     MOVE 1 TO WS-PV(4)
     MOVE 2 TO WS-N
     MOVE 16 TO WS-LAYERS
     MOVE 0 TO WS-GT
     MOVE 0 TO RL-EP-COUNT
     MOVE 1 TO WS-D
     MOVE 1 TO EP-COUNT
     MOVE 22 TO EP-TYPE(1)
     MOVE 20 TO EP-X(1) MOVE 64 TO EP-Y(1) MOVE 3 TO EP-Z(1)
     MOVE -1 TO WS-RX
     MOVE -40 TO WS-RY
     MOVE -1 TO WS-RZ
     MOVE 1 TO WS-ROW
     CALL "PORTAL-FACE-MESH" USING CLIENT-STATE WS-ROW WS-D WS-N WS-LAYERS WS-GT WS-REL WS-PV-TABLE
     MOVE "portal surface a face with a vertex at the eye's depth is made (24 vertices)" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32760 TO RL-EP-COUNT
     CALL "PORTAL-FACE-MESH" USING CLIENT-STATE WS-ROW WS-D WS-N WS-LAYERS WS-GT WS-REL WS-PV-TABLE
     MOVE "portal surface a frame whose vertex list is full takes no more (32760)" TO TL-CASE
     MOVE 32760 TO TL-EXPECTED-N
     MOVE RL-EP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Textures not read yet: PORTAL-MESH reads them (no pack here: missing, the flat colour).
     MOVE 0 TO EP-TEX
     MOVE 0.01 TO WS-PV(16)
     MOVE 10 TO WS-PV(16)
     MOVE 0 TO WS-PV(4)
     MOVE 20.5 TO WS-EYE(1)
     MOVE 110 TO WS-EYE(2)
     MOVE 3.5 TO WS-EYE(3)
     CALL "PORTAL-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-PV-TABLE
     MOVE "portal surface a first frame reads the textures (none in this stack: EP-TEX 2) and draws the flat colour" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EP-TEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-KIND-14.
     MOVE 14 TO WS-VAL
     PERFORM CHECK-KIND.

 CHECK-KIND.
     MOVE "N" TO TL-MODE
     MOVE WS-VAL TO TL-EXPECTED-N
     MOVE WS-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.

*> RANGE-OF-Y: TL-OBSERVED = the lowest and highest y of the frame's vertices in thousandths.
 RANGE-OF-Y.
     MOVE RL-EP-Y(1) TO WS-MIN WS-MAX
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > RL-EP-COUNT
         MOVE FUNCTION MIN(WS-MIN, RL-EP-Y(WS-I)) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, RL-EP-Y(WS-I)) TO WS-MAX
     END-PERFORM
     COMPUTE WS-MILLI-A ROUNDED = WS-MIN * 1000
     COMPUTE WS-MILLI-B ROUNDED = WS-MAX * 1000
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-MILLI-A) " " FUNCTION TRIM(WS-MILLI-B) DELIMITED BY SIZE INTO TL-OBSERVED.

 RANGE-OF-X.
     MOVE RL-EP-X(1) TO WS-MIN WS-MAX
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > RL-EP-COUNT
         MOVE FUNCTION MIN(WS-MIN, RL-EP-X(WS-I)) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, RL-EP-X(WS-I)) TO WS-MAX
     END-PERFORM
     COMPUTE WS-MILLI-A ROUNDED = WS-MIN * 1000
     COMPUTE WS-MILLI-B ROUNDED = WS-MAX * 1000
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-MILLI-A) " " FUNCTION TRIM(WS-MILLI-B) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM ACC-PORTALRENDER-SURFACE.
 COPY CLTEST.
