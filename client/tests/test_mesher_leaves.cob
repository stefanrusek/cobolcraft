*> T62100 (bug lane bugleaves; operator report, try19 play: trees looked sparse, only the outermost leaves were drawn). With the cutoutLeaves option on
*> (13 section 7.5, the default: Fancy graphics) a leaf block draws all six faces, also the ones between two leaf blocks (24 part 1 section 9.1,
*> LeavesBlock.skipRendering: only with the option off is a face against any leaves block skipped; leaves have an empty occlusion shape, so they hide
*> nothing of a neighbour and are hidden by none either, except by a neighbour whose face covers theirs). Against the generated vanilla pack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; never skipped) and the standard content set: a 3 x 3 x 3 block of oak leaves across a chunk and a
*> section border draws 27 x 6 faces with the option on and its 54 outside faces with it off; oak leaves beside birch leaves 12 faces on and 10 off;
*> leaves beside stone: the stone draws its six faces and the leaves five in both modes; the option read from the options (the CL-LEAVES-CULL flag of
*> OPTIONS-APPLY) and a change of it meshes every loaded section again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESHER-LEAVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-ROW                 BINARY-LONG OCCURS 2 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 64.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-KEYSTR              PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-OAK                 BINARY-LONG.
 01 WS-BIRCH               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TR                  BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-FACES               BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MARKED              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY MB-CREDIT-ON
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 1000 TO SK-U
     MOVE 1 TO MB-FAKE
     MOVE 0 TO MB-FAKE-STEP MB-FAKE-NOW
     MOVE 1000000000 TO MB-BUDGET-US
     MOVE "oak_leaves" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-OAK WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "birch_leaves" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-BIRCH WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "stone" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS

*>   The option's default is on (cutoutLeaves true): the client keeps interior leaf faces culled only when it is off.
     MOVE "mesher leaves the default options draw every leaf face (CL-LEAVES-CULL 0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-LEAVES-CULL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A 3 x 3 x 3 block of oak leaves across the chunk border (x 15..17) and the section border (rows 15..17), the option on.
     PERFORM CLEAR-WORLD
     MOVE WS-OAK TO WS-CELL
     PERFORM PLACE-CUBE
     PERFORM MESH-ALL
     MOVE "mesher leaves fancy: a 3 x 3 x 3 block of oak leaves draws all 27 x 6 faces, the inner ones too (162 quads)" TO TL-CASE
     MOVE 162 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same with the option off: only the 54 faces of the outside.
     MOVE 1 TO CL-LEAVES-CULL
     PERFORM MESH-ALL
     MOVE "mesher leaves fast: the same block draws only its 54 outside faces" TO TL-CASE
     MOVE 54 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-LEAVES-CULL

*>   Oak leaves beside birch leaves.
     PERFORM CLEAR-WORLD
     COMPUTE WS-WY = 5 + PL-MIN-Y
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-OAK
     MOVE 6 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-BIRCH
     PERFORM MESH-ALL
     MOVE "mesher leaves fancy: oak leaves beside birch leaves draw 12 faces (the one between them twice)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-LEAVES-CULL
     PERFORM MESH-ALL
     MOVE "mesher leaves fast: oak leaves beside birch leaves draw 10 faces (any leaves block hides the face)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-LEAVES-CULL

*>   A leaf cell beside a stone cell: the stone's face is not hidden by the leaves (they occlude nothing), the leaf's face toward the stone is.
     PERFORM CLEAR-WORLD
     MOVE 5 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-OAK
     MOVE 6 TO WS-X
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-STONE
     PERFORM MESH-ALL
     MOVE "mesher leaves fancy: a leaf cell beside a stone cell and the stone together draw 5 + 6 faces" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mesher leaves fancy: the stone beside the leaves draws all six faces" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FACES - 5
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-LEAVES-CULL
     PERFORM MESH-ALL
     MOVE "mesher leaves fast: a leaf cell beside a stone cell and the stone still draw 5 + 6 faces" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-LEAVES-CULL

*>   The leaf quads are in the opaque list (cut out in the shader), none in the translucent one.
     MOVE "mesher leaves the leaf quads are drawn in the opaque layer (cut-out texels are discarded by the shader)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The option as the options hold it: false turns the culling on, true off; a change meshes every loaded section again.
     PERFORM CLEAR-WORLD
     PERFORM MESH-ALL
     MOVE "cutoutLeaves" TO WS-NAME
     MOVE "false" TO WS-VALUE
     MOVE 5 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
     CALL "OPTIONS-APPLY" USING CLIENT-STATE
     MOVE "mesher leaves the option cutoutLeaves false sets CL-LEAVES-CULL" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-LEAVES-CULL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-MARKED
     MOVE "mesher leaves a change of the option marks every section of both loaded chunks to be meshed again (48)" TO TL-CASE
     MOVE 48 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM MESH-ALL
     CALL "OPTIONS-APPLY" USING CLIENT-STATE
     PERFORM COUNT-MARKED
     MOVE "mesher leaves applying the same option again marks nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "true" TO WS-VALUE
     MOVE 4 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
     CALL "OPTIONS-APPLY" USING CLIENT-STATE
     MOVE "mesher leaves the option cutoutLeaves true clears CL-LEAVES-CULL" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-LEAVES-CULL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> 3 x 3 x 3 cells of state WS-CELL at x 15..17, rows 15..17, z 4..6.
 PLACE-CUBE.
     PERFORM VARYING WS-Y FROM 15 BY 1 UNTIL WS-Y > 17
         PERFORM VARYING WS-Z FROM 4 BY 1 UNTIL WS-Z > 6
             PERFORM VARYING WS-X FROM 15 BY 1 UNTIL WS-X > 17
                 COMPUTE WS-WY = WS-Y + PL-MIN-Y
                 CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-WY WS-Z WS-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM.

 COUNT-MARKED.
     MOVE 0 TO WS-MARKED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             IF WR-DIRTY(WS-ROW(WS-I), WS-S) = 1
                 ADD 1 TO WS-MARKED
             END-IF
         END-PERFORM
     END-PERFORM.

 CLEAR-WORLD.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 12288
             MOVE 0 TO CE-STATE(WS-CELL)
         END-PERFORM
     END-PERFORM.

 MESH-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE 1 TO WR-DIRTY(WS-ROW(WS-I), WS-S)
         END-PERFORM
     END-PERFORM
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
     END-PERFORM
     MOVE 0 TO WS-TR WS-OP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             ADD WR-TR-COUNT(WS-ROW(WS-I), WS-S) TO WS-TR
             ADD WR-OP-COUNT(WS-ROW(WS-I), WS-S) TO WS-OP
         END-PERFORM
     END-PERFORM
     COMPUTE WS-FACES = (WS-TR + WS-OP) / 6.
 END PROGRAM TEST-MESHER-LEAVES.
