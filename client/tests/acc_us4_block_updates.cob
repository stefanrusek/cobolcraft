*> Acceptance test of US4-7, client half (05a Block Update 0x08, Section Blocks Update 0x56 (05b),
*> Light Update 0x31; 06 §7, §8; client/src/world-replica.cob): block and light changes the server
*> sends change the replica, and the sections they affect (with a neighbouring section when a
*> changed cell lies on its edge) are meshed again and uploaded; sections they do not affect are
*> left alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-BLOCK-UPDATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC Z9.
 01 WS-E2                  PIC Z9.
 01 WS-E3                  PIC Z9.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   Every section of the flat world meshed and uploaded first.
     CALL "TEST-TICKS" USING CLIENT-STATE WS-THREE
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     MOVE 1 TO WS-CX
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-EAST

     MOVE "contract/fixtures/wire/play-s2c-08-block-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance US4-7 client half given the world shown when Block Update sets (8, 59, 8) to "
         & "14 then the replica holds 14 there and only section 4 of chunk (0, 0) (y 48 to 63) is to "
         & "be meshed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 8 TO WS-X WS-Z
     MOVE 59 TO WS-Y
     PERFORM CELL-TEXT
     PERFORM DIRTY-TEXT
     MOVE "14 0001000000000000 0000000000000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-STEP" USING CLIENT-STATE
     COMPUTE WS-SLOT = MESH-SLOT-BASE + ((WS-ROW - 1) * 16 + 3) * 2
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = WS-SLOT
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US4-7 client half the next frame meshes that section again and uploads its "
         & "mesh" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM DIRTY-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION CHAR(WS-FOUND + 49) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "0000000000000000 0000000000000000 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-56-section-blocks-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance US4-7 client half given the world shown when Section Blocks Update changes "
         & "(9, 55, 8) to 15 and (8, 60, 8) to 11 then the replica holds them and section 4 of chunk "
         & "(0, 0) is to be meshed" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 9 TO WS-X
     MOVE 55 TO WS-Y
     PERFORM CELL-TEXT
     MOVE 8 TO WS-X
     MOVE 60 TO WS-Y
     PERFORM CELL-TEXT
     PERFORM DIRTY-TEXT
     MOVE "15 11 0001000000000000 0000000000000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE

*>   Block light 9 in sections Y 3 and Y 4 of chunk (0, 0) first, then the Light Update clears it.
     PERFORM VARYING WS-Y FROM 48 BY 1 UNTIL WS-Y > 79
         CALL "TEST-SET-LIGHT" USING CLIENT-STATE WS-Y
     END-PERFORM
     MOVE "contract/fixtures/wire/play-s2c-31-light-update.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance US4-7 client half when Light Update clears the block light of sections Y 3 "
         & "and Y 4 of chunk (0, 0) then it is 0 there and those sections, the ones above and below "
         & "and the same in the neighbouring chunks are to be meshed" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-BLOCK TO WS-E1
     MOVE WS-SKY TO WS-E2
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM DIRTY-TEXT
     MOVE "0/15 0011110000000000 0011110000000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE

*>   A change on the edge of a section and of a chunk: (15, 16, 3) in chunk (0, 0), section 2.
     MOVE 15 TO WS-X
     MOVE 16 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 12 TO WS-STATE
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US4-7 client half given a changed cell on the edge of a section and a chunk "
         & "then the neighbouring section below and the neighbouring chunk's section are meshed too"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM CELL-TEXT
     PERFORM DIRTY-TEXT
     MOVE "12 1100000000000000 0100000000000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CELL-TEXT.
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE WS-STATE TO WS-E3
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 DIRTY-TEXT.
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     COMPUTE WS-PTR = FUNCTION LENGTH(FUNCTION TRIM(TL-OBSERVED)) + 1
     IF TL-OBSERVED = SPACES
         MOVE 1 TO WS-PTR
     END-IF
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         STRING WR-DIRTY(WS-ROW, WS-S) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         STRING WR-DIRTY(WS-EAST, WS-S) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED.
 END PROGRAM ACC-US4-BLOCK-UPDATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-LIGHT.
*> USING CLIENT-STATE, y: block light 9 in every cell of layer y of chunk (0, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCELLS.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-Y.
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     SET ADDRESS OF RC-CHUNK TO WR-ADDR(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE 9 TO RC-BLOCK(L-Y * 256 + WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-SET-LIGHT.
 COPY CLTEST.
