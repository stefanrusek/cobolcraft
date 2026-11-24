*> Shared paragraphs of the water, surface and underground feature tests (test_feat_35_5_*, test_feat_35_6_*): COPY it inside the PROCEDURE DIVISION, after the program's own paragraphs. The
*> program declares WS-KEY (PIC X(112)), WS-PAIRS (PIC X(160)), WS-STATE, WS-WANT, WS-BLOCK, WS-X, WS-Y, WS-Z (BINARY-LONG), WS-FLAGS (2), WS-OK, WS-CASE (PIC X(200)), WS-OBS, WS-EXP,
*> WS-NAME (PIC X(48)) and WS-ZERO.
*> PUT-AT: writes the block WS-KEY (default state) at (WS-X, WS-Y, WS-Z). PUT-PAIRS: the same with the property pairs WS-PAIRS.
 PUT-AT.
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-PAIRS
     .
 PUT-PAIRS.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     .
*> FILL-BOX: the block WS-KEY over x WS-X0..WS-X1, y WS-Y0..WS-Y1, z WS-Z0..WS-Z1
 FILL-BOX.
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                 PERFORM PUT-AT
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> BLOCK-NOW: WS-BLOCK = the block index at (WS-X, WS-Y, WS-Z); WANT-BLOCK: WS-WANT = the block index of the key WS-KEY
 BLOCK-NOW.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     .
 WANT-BLOCK.
     MOVE WS-KEY TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     .
*> ASSERT-BLOCK: the block at (WS-X, WS-Y, WS-Z) is the block WS-KEY
 ASSERT-BLOCK.
     PERFORM BLOCK-NOW
     PERFORM WANT-BLOCK
     MOVE WS-BLOCK TO WS-OBS
     MOVE WS-WANT TO WS-EXP
     PERFORM ASSERT-N
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
