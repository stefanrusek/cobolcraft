*> Implementation test of client/src/submit.cob and CL-RUN of client/src/loop.cob against the real
*> window and MoltenVK (no test double, research R9; shim-abi.md §8, §9): the atlases are uploaded
*> through cc_vk_texture and the changed meshes through cc_vk_mesh (the upload marks are then
*> cleared), the draws are recorded in render-list order inside a presented frame; a run of CL-RUN
*> ends through the window's close-requested event.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SUBMIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-TITLE               PIC X(16) VALUE Z"test_submit".
 01 WS-W                   BINARY-LONG VALUE 320.
 01 WS-H                   BINARY-LONG VALUE 240.
 01 WS-HIDDEN              BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-PRESENTED           BINARY-LONG.
 01 WS-PATH                PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex".
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ID                  BINARY-LONG.
 01 WS-UPLOADS             BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-MARK1               PIC 9.
 01 WS-MARK2               PIC 9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-submit"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-submit" TO CL-GAME-DIR
     MOVE 24 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL STATIC "cc_win_open" USING BY VALUE WS-W BY VALUE WS-H BY REFERENCE WS-TITLE
         BY VALUE WS-HIDDEN RETURNING WS-RC
     CALL STATIC "cc_vk_init" RETURNING WS-RC
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 256 TO PL-HEIGHT
     MOVE 3 TO RG-BIOMES
     MOVE 4.5 TO PL-X
     MOVE 54 TO PL-Y
     MOVE 8.5 TO PL-Z
     MOVE -90 TO PL-YAW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE RL-UPLOAD-COUNT TO WS-UPLOADS
     MOVE RL-DRAW-COUNT TO WS-DRAWS
     CALL "SUBMIT-FRAME" USING CLIENT-STATE WS-PRESENTED
     MOVE "submit atlases and meshes are uploaded (marks cleared) and the frame's draws are "
         & "recorded and presented" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 uploads draws 0000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-PRESENTED = 1
         MOVE "1" TO TL-OBSERVED
     END-IF
     IF WS-UPLOADS > 1
         STRING FUNCTION TRIM(TL-OBSERVED) " uploads" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     IF WS-DRAWS > 1
         STRING FUNCTION TRIM(TL-OBSERVED) " draws" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " " AT-UPLOAD(1) AT-UPLOAD(2) AT-UPLOAD(3) AT-UPLOAD(4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An animated cell whose frame changed goes up alone (cc_vk_texture_update) and its mark clears; a
*>   whole atlas upload clears the marks too.
     MOVE 1 TO AN-COUNT
     MOVE 1 TO AN-SPRITE(1) AN-DIRTY(1)
     MOVE 16 TO AN-FRAME-W(1) AN-FRAME-H(1)
     ALLOCATE 1024 CHARACTERS INITIALIZED RETURNING AN-OUT(1)
     MOVE 0 TO AT-UPLOAD(1)
     CALL "SUBMIT-FRAME" USING CLIENT-STATE WS-PRESENTED
     MOVE AN-DIRTY(1) TO WS-MARK1
     MOVE 1 TO AN-DIRTY(1) AT-UPLOAD(1)
     CALL "SUBMIT-FRAME" USING CLIENT-STATE WS-PRESENTED
     MOVE AN-DIRTY(1) TO WS-MARK2
     FREE AN-OUT(1)
     MOVE 0 TO AN-COUNT
     MOVE "submit an animated cell is updated alone and its mark cleared; a whole atlas upload clears "
         & "the marks too" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-MARK1 " " WS-MARK2 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-CLOSE-REQUEST"
     CALL "CL-RUN" USING CLIENT-STATE
     MOVE "submit CL-RUN runs frames until the window's close-requested event ends the run"
         TO TL-CASE
     MOVE "quit" TO TL-EXPECTED
     MOVE "running" TO TL-OBSERVED
     IF CL-QUIT = 1 AND CL-FRAMES > 0
         MOVE "quit" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL STATIC "cc_vk_shutdown"
     CALL STATIC "cc_win_close"
     MOVE 0 TO RETURN-CODE
     STOP RUN.
 END PROGRAM TEST-SUBMIT.
 COPY CLTEST.
