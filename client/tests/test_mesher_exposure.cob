*> Implementation test of the exposure of faces after a block change (T5500; operator play: "the bottom and
*> side surfaces of recently exposed surfaces were often not rendering, so I could see through the world").
*> A brute-force oracle over two neighbouring chunks of three sections: after blocks are broken (and some set
*> again) with WORLD-BLOCK-SET, on section borders (y 15 and 16, 31 and 32) and chunk borders (x 0, 15; z 0, 15) as
*> well as inside, and the dirty sections are meshed until none is left, every plane between an opaque cell and
*> a cell that is not opaque holds exactly one quad of the opaque mesh, in all six directions, and no plane
*> between two cells alike holds one. Run once with the stand-in states (the mesher's own table) and once with
*> the mesh credit on and a clock that makes each frame mesh a single section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-EXPOSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG OCCURS 2 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SOLID-STATE         BINARY-LONG VALUE 2.
 01 WS-AIR-STATE           BINARY-LONG VALUE 0.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-CHECKED             BINARY-LONG.
 01 WS-NSOLID              BINARY-LONG.
 01 WS-GLASS               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-NOT-OPAQUES.
    05 FILLER PIC X(32) VALUE "white_stained_glass".
    05 FILLER PIC X(32) VALUE "black_stained_glass".
    05 FILLER PIC X(32) VALUE "spawner".
    05 FILLER PIC X(32) VALUE "tall_seagrass".
    05 FILLER PIC X(32) VALUE "short_dry_grass".
    05 FILLER PIC X(32) VALUE "tall_dry_grass".
    05 FILLER PIC X(32) VALUE "moving_piston".
    05 FILLER PIC X(32) VALUE "copper_grate".
    05 FILLER PIC X(32) VALUE "waxed_oxidized_copper_grate".
    05 FILLER PIC X(32) VALUE "copper_golem_statue".
    05 FILLER PIC X(32) VALUE "big_dripleaf".
    05 FILLER PIC X(32) VALUE "glass".
 01 WS-NOT-OPAQUE-TABLE REDEFINES WS-NOT-OPAQUES.
    05 WS-NOT-OPAQUE       PIC X(32) OCCURS 12 TIMES.
 01 WS-WY                  BINARY-LONG.
 01 WS-LABEL               PIC X(10).
 01 WS-K                   BINARY-LONG.
 01 WS-KEY2                PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-PICKS.
    05 WS-PICK             BINARY-LONG OCCURS 8 TIMES.
 01 WS-NAMES.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC X(16) VALUE "gravel".
    05 FILLER PIC X(16) VALUE "deepslate".
    05 FILLER PIC X(16) VALUE "granite".
    05 FILLER PIC X(16) VALUE "coal_ore".
    05 FILLER PIC X(16) VALUE "iron_ore".
    05 FILLER PIC X(16) VALUE "cobblestone".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 8 TIMES.
 01 WS-KEYSTR              PIC X(112).
 01 WS-PHASE               PIC X(24).
 01 WS-SHOWN               BINARY-LONG.
 01 WS-N                   PIC Z(5)9.
 01 WS-XS                  PIC Z9.
 01 WS-YS                  PIC Z9.
 01 WS-ZS                  PIC Z9.
 01 WS-BREAKS.
    05 FILLER PIC X(8) VALUE "05 05 05".
    05 FILLER PIC X(8) VALUE "05 15 05".
    05 FILLER PIC X(8) VALUE "05 16 05".
    05 FILLER PIC X(8) VALUE "05 31 08".
    05 FILLER PIC X(8) VALUE "05 32 08".
    05 FILLER PIC X(8) VALUE "00 20 07".
    05 FILLER PIC X(8) VALUE "15 20 07".
    05 FILLER PIC X(8) VALUE "16 20 07".
    05 FILLER PIC X(8) VALUE "31 20 07".
    05 FILLER PIC X(8) VALUE "07 30 00".
    05 FILLER PIC X(8) VALUE "07 30 15".
    05 FILLER PIC X(8) VALUE "00 16 00".
    05 FILLER PIC X(8) VALUE "15 31 15".
    05 FILLER PIC X(8) VALUE "16 15 15".
    05 FILLER PIC X(8) VALUE "20 47 05".
    05 FILLER PIC X(8) VALUE "20 00 05".
    05 FILLER PIC X(8) VALUE "24 24 08".
    05 FILLER PIC X(8) VALUE "24 25 08".
    05 FILLER PIC X(8) VALUE "24 26 08".
    05 FILLER PIC X(8) VALUE "25 25 08".
 01 WS-BREAK-TABLE REDEFINES WS-BREAKS.
    05 WS-BRK OCCURS 20 TIMES.
       10 WS-BX               PIC 99.
       10 FILLER              PIC X.
       10 WS-BY               PIC 99.
       10 FILLER              PIC X.
       10 WS-BZ               PIC 99.
 01 WS-PLANES.
    05 WS-PLANE-COUNT       BINARY-CHAR UNSIGNED OCCURS 208065 TIMES.
 01 WS-SOLID.
    05 WS-IS-SOLID          PIC 9 OCCURS 24576 TIMES.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 150000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-ALPHA          FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 1000 TO SK-U
     MOVE 1 TO MB-FAKE
     MOVE 0 TO MB-FAKE-STEP MB-FAKE-NOW
     MOVE 1000000000 TO MB-BUDGET-US
*>   The stand-in states: greystone (2) and the cobolcraft stand-in set.
     MOVE "stand-in " TO WS-LABEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         MOVE 2 TO WS-PICK(WS-K)
     END-PERFORM
     PERFORM RUN-SCENARIO
*>   The standard set: eight different solid blocks, each baked on first use.
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY MB-CREDIT-ON
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE "standard " TO WS-LABEL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         MOVE SPACES TO WS-KEYSTR
         MOVE WS-NAME(WS-K) TO WS-KEYSTR
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
         CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-PICK(WS-K) WS-STATUS
     END-PERFORM
     PERFORM RUN-SCENARIO
     PERFORM CHECK-OPACITY
     PERFORM GLASS-CASE
     STOP RUN.

*> Opacity from the block data (T5501; 24 part 1 section 5.2: a state occludes when canOcclude and its occlusion shape is the full
*> cube; noOcclusion and noCollision clear canOcclude): blocks the registry rows of the generated table once left unflagged.
 CHECK-OPACITY.
     MOVE 0 TO WS-MISSING
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         MOVE SPACES TO WS-KEYSTR
         MOVE WS-NOT-OPAQUE(WS-K) TO WS-KEYSTR
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
         CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
         IF ST-OPAQUE(WS-STATE + 1) NOT = 0
             ADD 1 TO WS-MISSING
             DISPLAY "  opaque but not an occluder: " FUNCTION TRIM(WS-KEYSTR)
         END-IF
     END-PERFORM
     MOVE "mesher exposure (standard) glass, spawner, seagrass, dry grass, copper grates and statues, moving piston do not occlude"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Stone with a stained glass cell, a glass pair and a seagrass cell: the stone's face toward glass or seagrass is drawn.
 GLASS-CASE.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
             MOVE WS-PICK(1) TO CE-STATE(WS-CELL)
         END-PERFORM
     END-PERFORM
     MOVE "white_stained_glass" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-GLASS WS-STATUS
     MOVE "tall_seagrass" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-GRASS WS-STATUS
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     COMPUTE WS-WY = 5 + PL-MIN-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-GLASS
     MOVE 6 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-GLASS
     MOVE 9 TO WS-X
     MOVE 5 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-GRASS
     PERFORM MARK-ALL
     PERFORM MESH-IDLE
     MOVE "standard " TO WS-LABEL
     PERFORM CHECK-PLANES
*>   Planes (doubled coordinates, y 5 is cell row 5): the stone cell at x 6 beside the glass at x 5; the stone at x 8 beside the seagrass at x 9;
*>   the face between the two glass cells (z 5 and 6) is not drawn by either.
     COMPUTE WS-KEY = (11 * 33 + 11) * 65 + 12 + 1
     MOVE WS-PLANE-COUNT(WS-KEY) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "mesher exposure (standard) the stone face toward stained glass is drawn" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-KEY = (11 * 33 + 11) * 65 + 18 + 1
     MOVE WS-PLANE-COUNT(WS-KEY) TO TL-OBSERVED-N
     MOVE "mesher exposure (standard) the stone face toward seagrass is drawn" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-KEY = (11 * 33 + 12) * 65 + 11 + 1
     MOVE WS-PLANE-COUNT(WS-KEY) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     MOVE "mesher exposure (standard) the face between two stained glass cells is not drawn" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 RUN-SCENARIO.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
             COMPUTE WS-K = FUNCTION MOD(WS-CELL * 7 + WS-CELL / 5, 8) + 1
             MOVE WS-PICK(WS-K) TO CE-STATE(WS-CELL)
         END-PERFORM
     END-PERFORM
     PERFORM MARK-ALL
     PERFORM MESH-IDLE

*>   Phase 1: the twenty named cells and about 150 more are broken.
     MOVE 0 TO MB-CREDIT-ON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-BX(WS-I) TO WS-X
         MOVE WS-BY(WS-I) TO WS-Y
         MOVE WS-BZ(WS-I) TO WS-Z
         COMPUTE WS-WY = WS-Y + PL-MIN-Y
         CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-AIR-STATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         COMPUTE WS-X = FUNCTION MOD(WS-I * 13 + WS-I / 7, 32)
         COMPUTE WS-Y = FUNCTION MOD(WS-I * 29 + WS-I / 3, 48)
         COMPUTE WS-Z = FUNCTION MOD(WS-I * 5 + 3, 16)
         COMPUTE WS-WY = WS-Y + PL-MIN-Y
         CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-AIR-STATE
     END-PERFORM
     PERFORM MESH-IDLE
     MOVE "broken" TO WS-PHASE
     PERFORM CHECK-PLANES
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") every face of a solid cell beside a broken cell has its quad"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     DISPLAY "  solid cells " WS-NSOLID
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") no quad lies between two cells that are alike after breaking"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXTRA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Phase 2: part of them are filled again, the rest stay open; the clock lets one section a frame through.
     MOVE 1 TO MB-CREDIT-ON
     MOVE 7000 TO MB-CREDIT
     MOVE 6000 TO MB-FAKE-STEP
     MOVE 4000 TO MB-BUDGET-US
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         COMPUTE WS-X = FUNCTION MOD(WS-I * 13 + WS-I / 7, 32)
         COMPUTE WS-Y = FUNCTION MOD(WS-I * 29 + WS-I / 3, 48)
         COMPUTE WS-Z = FUNCTION MOD(WS-I * 5 + 3, 16)
         COMPUTE WS-K = FUNCTION MOD(WS-I, 8) + 1
         COMPUTE WS-WY = WS-Y + PL-MIN-Y
         CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-PICK(WS-K)
     END-PERFORM
     PERFORM MESH-IDLE
     MOVE "refilled" TO WS-PHASE
     PERFORM CHECK-PLANES
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") every face is drawn after cells are set again, credit on"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") no quad lies between two cells that are alike after setting again"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXTRA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Phase 3: the player breaks blocks right after an expensive mesh has put the credit far below zero (a dense
*>   section takes 100 ms, the frame earns 7 ms): the sections the edit changed are meshed in that very frame.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-X = WS-I * 5 + 5
         MOVE 20 TO WS-WY
         MOVE 8 TO WS-Z
         COMPUTE WS-WY = 20 + PL-MIN-Y
         CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-PICK(1)
     END-PERFORM
     MOVE 16 TO WS-X
     COMPUTE WS-WY = 31 + PL-MIN-Y
     MOVE 15 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-PICK(1)
     PERFORM MESH-IDLE
     MOVE -100000 TO MB-CREDIT
     MOVE 10 TO WS-X
     COMPUTE WS-WY = 20 + PL-MIN-Y
     MOVE 8 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-AIR-STATE
     MOVE 16 TO WS-X
     COMPUTE WS-WY = 31 + PL-MIN-Y
     MOVE 15 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-AIR-STATE
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE "after" TO WS-PHASE
     PERFORM CHECK-PLANES
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") a block broken while the mesh credit is overspent is meshed in the same frame"
         DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-MISSING + WS-EXTRA
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Phase 4: a fill that touches every section: a frame serves CL-MESH-URGENT of them, the rest wait for the next frames.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE 1 TO WR-DIRTY(WS-ROW(WS-I), WS-S) WR-URGENT(WS-ROW(WS-I), WS-S)
         END-PERFORM
     END-PERFORM
     MOVE -1000000000 TO MB-CREDIT
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") a frame meshes at most CL-MESH-URGENT urgent sections, the others wait"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE MB-MESHED TO TL-OBSERVED-N
     MOVE CL-MESH-URGENT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO TL-EXPECTED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
     END-PERFORM
     MOVE 0 TO WS-DIRTY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             ADD WR-URGENT(WS-ROW(WS-I), WS-S) TO WS-DIRTY
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "mesher exposure (" FUNCTION TRIM(WS-LABEL) ") six more frames serve the remaining 40 urgent sections"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-DIRTY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO MB-CREDIT-ON
     MOVE 0 TO MB-FAKE-STEP
     MOVE 1000000000 TO MB-BUDGET-US.

 MARK-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE 1 TO WR-DIRTY(WS-ROW(WS-I), WS-S)
         END-PERFORM
     END-PERFORM.

*> Frames until no section is dirty (at most 400).
 MESH-IDLE.
     MOVE 0 TO WS-FRAMES
     MOVE 1 TO WS-DIRTY
     PERFORM UNTIL WS-DIRTY = 0 OR WS-FRAMES > 400
         ADD 1 TO WS-FRAMES
         CALL "MESH-DIRTY" USING CLIENT-STATE WS-BIG
         MOVE 0 TO WS-DIRTY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
                 IF WR-DIRTY(WS-ROW(WS-I), WS-S) = 1
                     MOVE 1 TO WS-DIRTY
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 CHECK-PLANES.
*>   The planes: for every quad of the opaque meshes, the doubled coordinates of its centre.
     PERFORM VARYING WS-KEY FROM 1 BY 1 UNTIL WS-KEY > 208065
         MOVE 0 TO WS-PLANE-COUNT(WS-KEY)
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 3
             IF WR-OP-COUNT(WS-ROW(WS-R), WS-S) > 0
                 SET ADDRESS OF B-VERTICES TO WR-OP-ADDR(WS-ROW(WS-R), WS-S)
                 PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= WR-OP-COUNT(WS-ROW(WS-R), WS-S)
                     COMPUTE WS-A = WS-Q + 1
                     COMPUTE WS-B = WS-Q + 3
                     COMPUTE WS-X2 ROUNDED = B-X(WS-A) + B-X(WS-B) + (WS-R - 1) * 32
                     COMPUTE WS-Y2 ROUNDED = B-Y(WS-A) + B-Y(WS-B) + (WS-S - 1) * 32
                     COMPUTE WS-Z2 ROUNDED = B-Z(WS-A) + B-Z(WS-B)
                     COMPUTE WS-KEY = (WS-Y2 * 33 + WS-Z2) * 65 + WS-X2 + 1
                     ADD 1 TO WS-PLANE-COUNT(WS-KEY)
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
*>   The opaque cells of both chunks.
     MOVE 0 TO WS-NSOLID
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 47
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 31
                 COMPUTE WS-WY = WS-Y + PL-MIN-Y
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STATE WS-SKY WS-BLK
                 COMPUTE WS-CELL = (WS-Y * 16 + WS-Z) * 32 + WS-X + 1
                 MOVE ST-OPAQUE(WS-STATE + 1) TO WS-IS-SOLID(WS-CELL)
                 ADD WS-IS-SOLID(WS-CELL) TO WS-NSOLID
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-MISSING WS-EXTRA WS-CHECKED WS-SHOWN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 47
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 31
                 COMPUTE WS-CELL = (WS-Y * 16 + WS-Z) * 32 + WS-X + 1
                 MOVE WS-IS-SOLID(WS-CELL) TO WS-SA
                 PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
                     MOVE WS-X TO WS-NX
                     MOVE WS-Y TO WS-NY
                     MOVE WS-Z TO WS-NZ
                     COMPUTE WS-X2 = WS-X * 2 + 1
                     COMPUTE WS-Y2 = WS-Y * 2 + 1
                     COMPUTE WS-Z2 = WS-Z * 2 + 1
                     EVALUATE WS-AXIS
                         WHEN 1
                             ADD 1 TO WS-NX
                             ADD 1 TO WS-X2
                         WHEN 2
                             ADD 1 TO WS-NY
                             ADD 1 TO WS-Y2
                         WHEN 3
                             ADD 1 TO WS-NZ
                             ADD 1 TO WS-Z2
                     END-EVALUATE
                     IF WS-NX <= 31 AND WS-NY <= 47 AND WS-NZ <= 15
                         COMPUTE WS-CELL = (WS-NY * 16 + WS-NZ) * 32 + WS-NX + 1
                         MOVE WS-IS-SOLID(WS-CELL) TO WS-SB
                         MOVE 0 TO WS-EXPECT
                         IF WS-SA NOT = WS-SB
                             MOVE 1 TO WS-EXPECT
                         END-IF
                         COMPUTE WS-KEY = (WS-Y2 * 33 + WS-Z2) * 65 + WS-X2 + 1
                         MOVE WS-PLANE-COUNT(WS-KEY) TO WS-SEEN
                         ADD 1 TO WS-CHECKED
                         IF WS-SEEN NOT = WS-EXPECT
                             IF WS-EXPECT = 1
                                 ADD 1 TO WS-MISSING
                             ELSE
                                 ADD 1 TO WS-EXTRA
                             END-IF
                             IF WS-SHOWN < 12
                                 ADD 1 TO WS-SHOWN
                                 MOVE WS-X TO WS-XS
                                 MOVE WS-Y TO WS-YS
                                 MOVE WS-Z TO WS-ZS
                                 DISPLAY "  " FUNCTION TRIM(WS-PHASE) " plane after cell " WS-XS " " WS-YS " " WS-ZS
                                     " axis " WS-AXIS " solid " WS-SA WS-SB " quads " WS-SEEN
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-MESHER-EXPOSURE.
