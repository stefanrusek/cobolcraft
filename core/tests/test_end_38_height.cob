*> Test of the End's height (docs/protocol/38-end.md section 2, round R2): the dimension type of the_end has min_y 0, height 256 and logical_height 256, so the generated chunk of the End is 256 blocks high although the
*> terrain volume is 128 high (noise_settings end: min_y 0, height 128). On the generated vanilla data (CC_GENERATED_DIR; passes as skipped without it): the End row of the open world has min y 0 and height 256, a
*> block written at y 200 and at y 255 of a generated End chunk (0, 0) is read back (the chunk memory holds 256 rows), y 256 is outside, and the terrain fills nothing above y 127 (no end stone at y 128 to 255 of
*> the chunk's far corner column) while the central island's stone is below it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "38 2 End height: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 0 TO ND-PLACEHOLDER
     MOVE 12345 TO CW-SEED
     MOVE "38 2 End height: the End row has min y 0 and height 256" TO TL-CASE
     COMPUTE TL-OBSERVED-N = DM-MIN-Y(DIM-STANDARD-END) * 1000 + DM-HEIGHT(DIM-STANDARD-END)
     MOVE 256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "obsidian" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-OBSIDIAN
     MOVE "end_stone" TO WS-KEY
     CALL "PT-STATE" USING WS-KEY WS-PAIRS WS-STONE
     CALL "WORLD-CHUNK" USING DIM-STANDARD-END WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-X WS-Z
     MOVE 200 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-OBSIDIAN
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-GOT
     MOVE "38 2 End height: a block set at y 200 of a generated End chunk is read back" TO TL-CASE
     MOVE WS-OBSIDIAN TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 255 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-OBSIDIAN
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-GOT
     MOVE "38 2 End height: the top row y 255 holds a block too" TO TL-CASE
     MOVE WS-OBSIDIAN TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 256 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-OBSIDIAN
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-GOT
     MOVE "38 2 End height: y 256 is outside the dimension (reads as air)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the terrain stops at y 127: no end stone at y 128 to 255 anywhere in the chunk, some below
     MOVE 0 TO WS-ABOVE WS-BELOW
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
                 CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-END WS-X WS-Y WS-Z WS-GOT
                 IF WS-GOT = WS-STONE
                     IF WS-Y > 127
                         ADD 1 TO WS-ABOVE
                     ELSE
                         ADD 1 TO WS-BELOW
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "38 2 End height: the terrain volume is 128 high: end stone only below y 128" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ABOVE = 0 AND WS-BELOW > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-END-38-HEIGHT.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
