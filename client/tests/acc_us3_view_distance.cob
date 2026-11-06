*> Acceptance test of US3-4, the client half (09 §3.2 Level Chunk With Light and Forget Level
*> Chunk; client/src/world-replica.cob, render-list.cob): a chunk received is meshed and drawn; a
*> chunk forgotten is no longer drawn and its mesh slots are released (uploaded with no vertices,
*> which frees a cc_vk_mesh slot, shim-abi §9) once, not again in later frames.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-VIEW-DISTANCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-BUDGET              BINARY-LONG VALUE 1000.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG VALUE 38.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 256 TO PL-HEIGHT
     MOVE 1 TO PL-HAS-SKY
     MOVE 3 TO RG-BIOMES
     MOVE 4.5 TO PL-X
     MOVE 54 TO PL-Y
     MOVE 8.5 TO PL-Z
     MOVE 6000 TO PL-TIME
     CALL "SKY-UPDATE" USING CLIENT-STATE
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-ROW-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US3-4 client half: given a chunk received then its sections are meshed, "
         & "uploaded and drawn (opaque and translucent draws of row 1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "draws yes uploads yes released no" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Forget Level Chunk (0, 0): Long with Z in the high Int and X in the low Int.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ID
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-ROW-DRAWS" USING CLIENT-STATE WS-TEXT
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     CALL "TEST-ROW-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US3-4 client half: given the chunk forgotten then it is no longer drawn and "
         & "its 32 mesh slots are released once (empty uploads), not again in the next frame"
         TO TL-CASE
     MOVE "draws no uploads yes released 32 draws no uploads no released no" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US3-VIEW-DISTANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ROW-DRAWS.
*> USING CLIENT-STATE, text (appended): "draws yes|no uploads yes|no released <n>|no" for the mesh
*> slots of replica row 1 in the render list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-UPLOADS             BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-LAST                BINARY-LONG VALUE 33.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE 0 TO WS-DRAWS WS-UPLOADS WS-EMPTY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-D-SLOT(WS-I) <= WS-LAST
             ADD 1 TO WS-DRAWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) >= MESH-SLOT-BASE AND RL-U-SLOT(WS-I) <= WS-LAST
             ADD 1 TO WS-UPLOADS
             IF RL-U-COUNT(WS-I) = 0
                 ADD 1 TO WS-EMPTY
             END-IF
         END-IF
     END-PERFORM
     STRING FUNCTION TRIM(L-TEXT) " draws " DELIMITED BY SIZE INTO L-TEXT
     IF WS-DRAWS > 0
         STRING FUNCTION TRIM(L-TEXT) " yes" DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " no" DELIMITED BY SIZE INTO L-TEXT
     END-IF
     IF WS-UPLOADS > 0
         STRING FUNCTION TRIM(L-TEXT) " uploads yes" DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " uploads no" DELIMITED BY SIZE INTO L-TEXT
     END-IF
     IF WS-EMPTY = WS-UPLOADS AND WS-EMPTY > 0
         MOVE WS-EMPTY TO WS-EDIT
         STRING FUNCTION TRIM(L-TEXT) " released " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
             INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " released no" DELIMITED BY SIZE INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-ROW-DRAWS.
 COPY CLTEST.
