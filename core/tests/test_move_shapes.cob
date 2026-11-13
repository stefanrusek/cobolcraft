*> Implementation test of the server's collision by shape (T4504; docs/protocol/51-block-shapes.md; core/src/movement.cob MOVE-COLLIDES,
*> MOVE-SUPPORTED): the player box (0.7 x 1.75) against the collision shape of the block state, not a full cube. The standard set's tables
*> are opened over the test world; the blocks are placed in the air above the spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOVE-SHAPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(64).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SUPPORTED           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
*>   A bottom slab at (6, 54, 8): a body standing on it has its feet at 54.5.
     MOVE 6 TO WS-BX
     MOVE 54 TO WS-BY
     MOVE 8 TO WS-BZ
     MOVE "oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 6.5 TO WS-X
     MOVE 54.5 TO WS-Y
     MOVE 8.5 TO WS-Z
     MOVE "test move shapes: a body standing on a bottom slab does not collide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE "test move shapes: a body standing on a bottom slab is supported" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "MOVE-SUPPORTED" USING WS-DIM WS-X WS-Y WS-Z WS-SUPPORTED
     MOVE WS-SUPPORTED TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 54.4 TO WS-Y
     MOVE "test move shapes: a body inside the lower half of the slab collides" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A top slab fills the upper half: a body at its cell floor stands under it.
     MOVE "type=top,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.0 TO WS-Y
     MOVE "test move shapes: a body at the floor of a top slab cell collides with the slab above its knees only from 54.5" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A closed door, facing north: a 3 pixel panel at the south edge of the cell.
     MOVE "oak_door" TO WS-KEY
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 6.5 TO WS-X
     MOVE 54.0 TO WS-Y
     MOVE 8.0 TO WS-Z
     MOVE "test move shapes: a body in the open part of a closed door cell does not collide" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 8.6 TO WS-Z
     MOVE "test move shapes: a body in the panel of a closed door collides" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   The same door open with its hinge on the left: the panel swings to the west edge, so a body in the middle of the cell passes.
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 6.6 TO WS-X
     MOVE 8.5 TO WS-Z
     MOVE "test move shapes: a body walks through an open door" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 6.4 TO WS-X
     MOVE "test move shapes: the open door panel at the west edge still blocks a body there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A torch has no collision.
     MOVE "torch" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE 6.5 TO WS-X
     MOVE 54.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     MOVE "test move shapes: a body stands inside a torch cell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
     MOVE 54.8 TO WS-Y
     MOVE 1 TO WS-SUPPORTED
     CALL "MOVE-SUPPORTED" USING WS-DIM WS-X WS-Y WS-Z WS-SUPPORTED
     MOVE "test move shapes: a torch does not support a body" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SUPPORTED TO TL-OBSERVED-N
     PERFORM ASSERT-N
*>   A ladder is a thin panel: a body in the open part of its cell passes.
     MOVE "ladder" TO WS-KEY
     MOVE "facing=north,waterlogged=false" TO WS-PAIRS
     PERFORM PLACE
     MOVE 54.0 TO WS-Y
     MOVE 8.3 TO WS-Z
     MOVE "test move shapes: a body walks into a ladder cell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM HIT-OF
*>   A full block still blocks.
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PLACE
     MOVE "test move shapes: a body inside stone collides" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM HIT-OF
     GOBACK.

 PLACE.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE.

 HIT-OF.
     CALL "MOVE-COLLIDES" USING WS-DIM WS-X WS-Y WS-Z WS-HIT
     MOVE WS-HIT TO TL-OBSERVED-N
     PERFORM ASSERT-N.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-MOVE-SHAPES.

 COPY CORETEST.
