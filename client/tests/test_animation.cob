*> Implementation test of texture animation (08 section 7; FR-010; ANIM-PARSE in packs/mcmeta.cob, ANIM-TICK in
*> atlas.cob): the animation section of a .png.mcmeta (frame size, frametime, the frames list with index and time,
*> interpolate; a malformed one is refused) and the schedule: frame order and time per cell, one frame per
*> entry for its ticks of 50 ms, the cycle repeating, interpolation blending between frames, the cell marked
*> to be updated only when it changed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ANIMATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLMCMETA.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-animation".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAMES               PIC X(256) VALUE "animbase anim".
 01 WS-IDS                 PIC X(256) VALUE "file/anim file/animbase".
 01 WS-JSON                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 16.
 01 WS-H                   BINARY-LONG VALUE 48.
 01 WS-RESULT              BINARY-LONG.
 01 WS-NAME                PIC X(80).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-PIXEL               PIC X(32).
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC Z(3)9.
 01 WS-E2                  PIC Z(3)9.
 01 WS-E3                  PIC Z(3)9.
 01 WS-E4                  PIC Z(3)9.
 01 WS-E5                  PIC 9.
 01 WS-E6                  PIC 9.
 01 WS-E5X                 PIC Z(3)9.
 PROCEDURE DIVISION.
*>   ---- ANIM-PARSE ----
     MOVE '{"animation":{}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation an empty animation section is valid: square frames, 3 frames of a 16 x 48 strip "
         & "in order, 1 tick each" TO TL-CASE
     MOVE "1 16x16 pictures 3 entries 3 ticks 3 blend 0" TO TL-EXPECTED
     PERFORM SHOW
     MOVE '{"animation":{"width":16,"height":16,"frametime":5}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation width, height and frametime are taken: 3 entries of 5 ticks" TO TL-CASE
     MOVE "1 16x16 pictures 3 entries 3 ticks 15 blend 0" TO TL-EXPECTED
     PERFORM SHOW
     MOVE '{"animation":{"height":24}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation only a height: the width is the image's, 2 frames of 16 x 24" TO TL-CASE
     MOVE "1 16x24 pictures 2 entries 2 ticks 2 blend 0" TO TL-EXPECTED
     PERFORM SHOW
     MOVE '{"animation":{"frametime":2,"frames":[0,{"index":2,"time":4},{"index":9},{"index":1,"time":0},'
         & 'true,-1,1.5,1]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation frames as indexes and {index,time}: an index outside the image, a zero time and "
         & "other values are skipped; entries 0 (2 ticks), 2 (4 ticks), 1 (2 ticks)" TO TL-CASE
     MOVE "1 16x16 pictures 3 entries 3 ticks 8 blend 0" TO TL-EXPECTED
     PERFORM SHOW
     MOVE '{"animation":{"interpolate":true}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation interpolate true is kept" TO TL-CASE
     MOVE "1 16x16 pictures 3 entries 3 ticks 3 blend 1" TO TL-EXPECTED
     PERFORM SHOW
     MOVE '{"other":1}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a file with no animation section is not an animation (2)" TO TL-CASE
     MOVE "2" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"frames":[5]}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a frames list with no usable frame is malformed (0)" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"frametime":0}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a frametime of 0 is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"frametime":"x"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a frametime that is no number is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":5}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation an animation section that is no object is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{not json' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation text that is no JSON is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"width":8}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a frame narrower than the image (frames side by side) is not supported: malformed"
         TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"width":"x"}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a width that is no positive integer is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"height":0}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation a height that is no positive integer is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"height":20}}' TO WS-JSON
     PERFORM DO-PARSE
     MOVE "animation an image height that is no multiple of the frame height is malformed" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-RESULT
     MOVE '{"animation":{"frames":[' TO WS-JSON
     MOVE 25 TO WS-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         STRING "1," DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-LENGTH
     END-PERFORM
     STRING "1]}}" DELIMITED BY SIZE INTO WS-JSON WITH POINTER WS-LENGTH
     SUBTRACT 1 FROM WS-LENGTH
     CALL "ANIM-PARSE" USING WS-JSON WS-LENGTH WS-W WS-H ANIM-META WS-RESULT
     MOVE "animation a frames list longer than 32 keeps its first 32 entries" TO TL-CASE
     MOVE "1 16x16 pictures 3 entries 32 ticks 32 blend 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     PERFORM SHOW

*>   ---- the schedule over the atlas ----
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE "anim:block/flow" TO WS-NAME
     MOVE 15 TO WS-NAME-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E2
     MOVE AT-SH(WS-SPRITE) TO WS-E4
     MOVE AN-COUNT TO WS-E1
     MOVE "animation the animated textures (flow, mix) are two animations; flow is one frame of its "
         & "strip, 16 x 16, not the whole image" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 16x16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "flow starts as its first sequence picture: red" TO TL-CASE
     CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
     MOVE "255,0,0,255" TO TL-EXPECTED
     MOVE WS-PIXEL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1000000 TO WS-NOW
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 0
                 MOVE 1000000 TO WS-NOW
             WHEN 1
                 MOVE 1000100 TO WS-NOW
             WHEN 2
                 MOVE 1000250 TO WS-NOW
             WHEN 3
                 MOVE 1000300 TO WS-NOW
             WHEN 4
                 MOVE 1000400 TO WS-NOW
         END-EVALUATE
         CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
         CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-PIXEL) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     MOVE "animation flow at ticks 0, 2, 5, 6, 8: red, blue (entry 2, 4 ticks), blue, green, red again"
         TO TL-CASE
     MOVE "255,0,0,255 0,0,255,255 0,0,255,255 0,255,0,255 255,0,0,255" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Interpolation: black to grey over 4 ticks, then grey to black (the cycle wraps).
     MOVE "anim:block/mix" TO WS-NAME
     MOVE 14 TO WS-NAME-LENGTH
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         COMPUTE WS-NOW = 1000000 + (WS-I * 2) * 50
         CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
         CALL "TEST-PIXEL" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-PIXEL
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-PIXEL) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     MOVE "animation mix (interpolate, 4 ticks a frame) at ticks 0, 2, 4, 6: 0, half way 100, 200, 100"
         TO TL-CASE
     MOVE "0,0,0,255 100,100,100,255 200,200,200,255 100,100,100,255" TO TL-EXPECTED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cell is marked only when it changed.
     MOVE 1000100 TO WS-NOW
     MOVE 0 TO AN-DIRTY(1) AN-DIRTY(2)
     CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
     MOVE AN-DIRTY(1) TO WS-E6
     MOVE 0 TO AN-DIRTY(1)
     CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
     MOVE AN-DIRTY(1) TO WS-E5
     MOVE "animation flow (not interpolated) is marked to be updated when its picture changes and not "
         & "again while the same picture shows" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E6 " " WS-E5 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT


*>   A second build of the atlas frees the animation buffers and builds them again.
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE AN-COUNT TO WS-E1
     MOVE "animation building the atlas again keeps the two animations" TO TL-CASE
     MOVE "2" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DO-PARSE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JSON TRAILING)) TO WS-LENGTH
     MOVE 16 TO WS-W
     MOVE 48 TO WS-H
     CALL "ANIM-PARSE" USING WS-JSON WS-LENGTH WS-W WS-H ANIM-META WS-RESULT
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED.

 SHOW.
     MOVE AM-FRAME-W TO WS-E1
     MOVE AM-FRAME-H TO WS-E3
     MOVE AM-PICTURES TO WS-E5X
     MOVE AM-COUNT TO WS-E2
     MOVE AM-TOTAL TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION CHAR(WS-RESULT + 49) " " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E3)
         " pictures " FUNCTION TRIM(WS-E5X) " entries " FUNCTION TRIM(WS-E2) " ticks "
         FUNCTION TRIM(WS-E4) " blend " AM-INTERPOLATE DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SHOW-RESULT.
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION CHAR(WS-RESULT + 49) TO TL-OBSERVED(1:1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ANIMATION.
 COPY CLTEST.
 COPY PACKTEST.
