*> Convergence acceptance test of the operator report "stairs render dark, the first real render issue I have seen this run" (try19 play; bug lane bugstairlight; docs/protocol/12
*> sections 1.3, 1.4 and 1.6: a quad inside its cell takes the light of its own cell, a quad on the border of the cell the light of the neighbour it looks into; docs/protocol/32 sections
*> 5.1 and 7: block light enters the cell of a stair, a slab, a chest or a fence, whose dampening is below 15). A standard superflat world made through the client's single-player host
*> from the generated packs (CC_GENERATED_DIR; a pass without them): the core builds a sealed stone room in the Player's chunk (no sky light inside: night as far as the room is concerned)
*> with a torch in its middle and, three cells from it, an oak stair, a bottom oak slab, a chest and an oak fence; the light the core stored for the chunk goes into the client's replica
*> row (both use the one CE-CHUNK layout), the sections are meshed by the client, and the vertices of each block that are not on a whole-number plane (its inner quads: treads, risers,
*> posts) draw at 0.3 or more at full daylight (the larger of the block term and the sky term; the 0.1 floor is the black of the report). The stand-in engine gave such cells block light 0
*> (it treated every block with a collision shape as opaque), so those quads were drawn at the floor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSTAIRLIGHT-STAIRS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugstairlight-stairs".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "StairFlat".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 9.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BASE-Y              BINARY-LONG.
 01 WS-DIRTY               BINARY-LONG.
 01 WS-WRONG               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-LIST                PIC X(200).
 01 WS-LIST-POINTER        BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugstairlight: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z / 16)
     COMPUTE WS-BASE-Y = FUNCTION INTEGER(PL-Y) + 8
     CALL "STAIRLIGHT-BUILD" USING WS-CX WS-CZ WS-BASE-Y
     CALL "STAIRLIGHT-COPY" USING CLIENT-STATE WS-CX WS-CZ WS-DIRTY
     MOVE "acceptance bugstairlight given a sealed room built by the core in the Player's chunk when its light goes to the replica then the client holds that chunk" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DIRTY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO WS-WRONG WS-SEEN
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-LIST-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "STAIRLIGHT-MEASURE" USING CLIENT-STATE WS-CX WS-CZ WS-BASE-Y WS-I WS-SEEN WS-WRONG WS-LIST WS-LIST-POINTER
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance bugstairlight given a stair, a slab, a chest and a fence in a torch-lit sealed room when meshed then every inner vertex of each draws at 0.3 or more" TO TL-CASE
     MOVE "no dark vertex" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-WRONG = 0 AND WS-SEEN > 60
         MOVE "no dark vertex" TO TL-OBSERVED
     ELSE
         MOVE WS-WRONG TO WS-E1
         MOVE WS-SEEN TO WS-E2
         STRING "dark vertices " FUNCTION TRIM(WS-E1) " of " FUNCTION TRIM(WS-E2) " in: " FUNCTION TRIM(WS-LIST) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGSTAIRLIGHT-STAIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STAIRLIGHT-BUILD.
*> USING chunk x, chunk z, floor y (world y of the room's floor; BINARY-LONG): the core builds the sealed room in that chunk (shell x, z 1 to 13, two cells of air high, a stone ceiling), a torch at 7, 7
*> and the four blocks three cells from it along x and z: oak stair at +3, 0; bottom oak slab at -3, 0; chest at 0, +3; oak fence at 0, -3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-DIM                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-PUT                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-Y.
     MOVE CW-DIM(1) TO WS-DIM
     CALL "WORLD-CHUNK" USING WS-DIM L-CX L-CZ WS-ROW
     COMPUTE WS-X0 = L-CX * 16
     COMPUTE WS-Z0 = L-CZ * 16
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "minecraft:torch" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-TORCH
     CALL "LIGHT-BATCH-BEGIN"
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 13
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 13
             COMPUTE WS-WX = WS-X0 + WS-A
             COMPUTE WS-WZ = WS-Z0 + WS-B
             MOVE L-Y TO WS-WY
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             COMPUTE WS-WY = L-Y + 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             IF WS-A = 1 OR WS-A = 13 OR WS-B = 1 OR WS-B = 13
                 COMPUTE WS-WY = L-Y + 1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
                 ADD 1 TO WS-WY
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-STONE
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-WY = L-Y + 1
     COMPUTE WS-WX = WS-X0 + 7
     COMPUTE WS-WZ = WS-Z0 + 7
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-TORCH
     MOVE "minecraft:oak_stairs" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-PUT
     COMPUTE WS-WX = WS-X0 + 10
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT
     MOVE "minecraft:oak_slab" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-PUT
     COMPUTE WS-WX = WS-X0 + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT
     MOVE "minecraft:chest" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-PUT
     COMPUTE WS-WX = WS-X0 + 7
     COMPUTE WS-WZ = WS-Z0 + 10
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT
     MOVE "minecraft:oak_fence" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-PUT
     COMPUTE WS-WZ = WS-Z0 + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-PUT
     CALL "LIGHT-BATCH-END"
     GOBACK.
 END PROGRAM STAIRLIGHT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STAIRLIGHT-COPY.
*> USING CLIENT-STATE, chunk x, chunk z, loaded out (BINARY-LONG, 1 when the client holds the chunk): the core's cells and light of the chunk are copied into the replica row of the
*> same chunk (one CE-CHUNK layout) and every section of it is marked to be meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CORE-ROW            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 B-SRC                  PIC X(CE-CHUNK-BYTES) BASED.
 01 B-DST                  PIC X(CE-CHUNK-BYTES) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-LOADED.
     MOVE 0 TO L-LOADED
     MOVE CW-DIM(1) TO WS-DIM
     CALL "WORLD-CHUNK" USING WS-DIM L-CX L-CZ WS-CORE-ROW
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0 AND WS-CORE-ROW > 0
         SET ADDRESS OF B-SRC TO CK-ADDR(WS-CORE-ROW)
         SET ADDRESS OF B-DST TO WR-ADDR(WS-ROW)
         MOVE B-SRC TO B-DST
*>       The surfaces the client's sky stopgap cached for the row were those of the flat world (no ceiling).
         MOVE 0 TO WR-SURF-OK(WS-ROW)
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 24
             MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
         END-PERFORM
         MOVE 1 TO L-LOADED
     END-IF
     GOBACK.
 END PROGRAM STAIRLIGHT-COPY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STAIRLIGHT-MEASURE.
*> USING CLIENT-STATE, chunk x, chunk z, floor y, block number 1 to 4 (stair, slab, chest, fence, the cells of STAIRLIGHT-BUILD), vertices seen (added to), dark ones (added to), names text, its
*> pointer: the vertices of the section that holds the block's cell that lie inside the cell and off the whole-number planes (an inner quad's corners) are counted, and counted dark when the
*> larger of their block term and sky term is below 0.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-BR                  FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-ANY-DARK            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-VROW.
    05 WS-VF               FLOAT-SHORT OCCURS 11 TIMES.
 01 B-VERT                 PIC X(6488064) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-SEEN                 BINARY-LONG.
 01 L-WRONG                BINARY-LONG.
 01 L-LIST                 PIC X(200).
 01 L-POINTER              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-Y L-WHICH L-SEEN L-WRONG L-LIST L-POINTER.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     COMPUTE WS-LY = L-Y + 1 - PL-MIN-Y
     COMPUTE WS-SECTION = WS-LY / 16 + 1
     COMPUTE WS-LY = WS-LY - (WS-SECTION - 1) * 16
     EVALUATE L-WHICH
         WHEN 1
             MOVE 10 TO WS-LX
             MOVE 7 TO WS-LZ
         WHEN 2
             MOVE 4 TO WS-LX
             MOVE 7 TO WS-LZ
         WHEN 3
             MOVE 7 TO WS-LX
             MOVE 10 TO WS-LZ
         WHEN OTHER
             MOVE 7 TO WS-LX
             MOVE 4 TO WS-LZ
     END-EVALUATE
     MOVE 0 TO WS-ANY-DARK
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 2
         MOVE 0 TO WS-COUNT
         IF WS-ROW > 0
             IF WS-T = 1
                 MOVE WR-OP-COUNT(WS-ROW, WS-SECTION) TO WS-COUNT
                 IF WS-COUNT > 0
                     SET ADDRESS OF B-VERT TO WR-OP-ADDR(WS-ROW, WS-SECTION)
                 END-IF
             ELSE
                 MOVE WR-TR-COUNT(WS-ROW, WS-SECTION) TO WS-COUNT
                 IF WS-COUNT > 0
                     SET ADDRESS OF B-VERT TO WR-TR-ADDR(WS-ROW, WS-SECTION)
                 END-IF
             END-IF
         END-IF
         PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= WS-COUNT
             COMPUTE WS-OFF = WS-Q * 44 + 1
             MOVE B-VERT(WS-OFF:44) TO WS-VROW
             COMPUTE WS-FX = WS-VF(1) - WS-LX
             COMPUTE WS-FY = WS-VF(2) - WS-LY
             COMPUTE WS-FZ = WS-VF(3) - WS-LZ
             IF WS-FX >= -0.001 AND WS-FX <= 1.001 AND WS-FY >= -0.001 AND WS-FY <= 1.001 AND WS-FZ >= -0.001 AND WS-FZ <= 1.001
                 MOVE 0 TO WS-ODD
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     EVALUATE WS-K
                         WHEN 1
                             MOVE WS-FX TO WS-R
                         WHEN 2
                             MOVE WS-FY TO WS-R
                         WHEN OTHER
                             MOVE WS-FZ TO WS-R
                     END-EVALUATE
                     IF WS-R > 0.01 AND WS-R < 0.99
                         MOVE 1 TO WS-ODD
                     END-IF
                 END-PERFORM
                 IF WS-ODD = 1
                     ADD 1 TO L-SEEN
                     MOVE WS-VF(6) TO WS-BR
                     IF WS-VF(8) > WS-BR
                         MOVE WS-VF(8) TO WS-BR
                     END-IF
                     IF WS-BR < 0.3
                         ADD 1 TO L-WRONG
                         MOVE 1 TO WS-ANY-DARK
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-ANY-DARK = 1 AND L-POINTER < 190
         MOVE L-WHICH TO WS-DIGIT
         STRING "block " WS-DIGIT " " DELIMITED BY SIZE INTO L-LIST WITH POINTER L-POINTER
     END-IF
     GOBACK.
 END PROGRAM STAIRLIGHT-MEASURE.
