*> Implementation test of the crack overlay's draw (render-list.cob, 12 section 4.3): the frame's draw list holds
*> the overlay mesh with the crumbling pipeline (CC-PIPE-CRUMBLING: 2 x source x destination, so the
*> crack darkens the block instead of covering it), texture 0 (the block atlas), in the world screen only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OVERLAY-DRAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BREAKER             BINARY-LONG VALUE 99.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 9.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-STAGE               BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   The block atlas gets a sprite for stage 3 (a pack that has the images gives it; the built-in pack has none).
     ADD 1 TO AT-SPRITE-COUNT
     MOVE "minecraft:block/destroy_stage_3" TO AT-NAME(AT-SPRITE-COUNT)
     MOVE 31 TO AT-NAME-LENGTH(AT-SPRITE-COUNT)
     MOVE 0 TO AT-X(AT-SPRITE-COUNT) AT-Y(AT-SPRITE-COUNT)
     MOVE 16 TO AT-SW(AT-SPRITE-COUNT) AT-SH(AT-SPRITE-COUNT)
*>   The step clock starts near 1,000,000 ms: the entry is stamped with it.
     MOVE 1000010 TO CL-NOW-MS
     CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE WS-BREAKER WS-X WS-Y WS-Z WS-STAGE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 0 TO WS-DRAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-BREAK AND RL-D-PIPELINE(WS-I) = CC-PIPE-CRUMBLING
                 AND RL-D-TEX(WS-I) = CC-TEX-BLOCKS
             ADD 1 TO WS-DRAW
         END-IF
     END-PERFORM
     MOVE "overlay draw the break overlay is drawn once, with the crumbling pipeline and the block atlas" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DRAW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OVERLAY-DRAW.

 COPY CLTEST.
