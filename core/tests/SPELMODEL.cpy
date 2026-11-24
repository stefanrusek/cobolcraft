*> Model paragraphs shared by the tests of speleothem, the cluster and the large dripstone (COPY inside the PROCEDURE DIVISION, after SPELPROC.cpy; SPELWS.cpy has the working storage).
*> MODEL-IN-SET: WS-D = 1 when the block WS-MB is in the replaceable set. MODEL-ISBASE: WS-D = 1 when the model cell (WS-MX, WS-MY, WS-MZ) is the base block or in the set.
*> MODEL-PLACE: placeBaseBlockIfPossible at the model cell. MODEL-GROW: growSpeleothem (5.3) at (WS-GX, WS-GY, WS-GZ) for WS-TIP (0 down, 1 up), WS-HT and WS-MERGE.
*> MODEL-IN-SET: WS-D = 1 when the block WS-MB is in the replaceable set
 MODEL-IN-SET.
     MOVE 0 TO WS-D
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-MB = WS-SETB(WS-I)
             MOVE 1 TO WS-D
         END-IF
     END-PERFORM
     .
*> MODEL-ISBASE: WS-D = 1 when the model cell (WS-MX, WS-MY, WS-MZ) is the base block or in the set
 MODEL-ISBASE.
     PERFORM MGET
     PERFORM MBLOCK
     PERFORM MODEL-IN-SET
     IF WS-MB = WS-B-BASE
         MOVE 1 TO WS-D
     END-IF
     .
*> MODEL-PLACE: placeBaseBlockIfPossible at (WS-MX, WS-MY, WS-MZ)
 MODEL-PLACE.
     PERFORM MGET
     PERFORM MBLOCK
     PERFORM MODEL-IN-SET
     IF WS-D = 1
         MOVE WS-S-BASE TO WS-MV
         PERFORM MSET
     END-IF
     .
*> MODEL-GROW: section 5.3 at (WS-GX, WS-GY, WS-GZ) for the tip WS-TIP, the height WS-HT and WS-MERGE: the list of pieces is built as the section lists them, then written
 MODEL-GROW.
     COMPUTE WS-KD = WS-TIP + 1
     COMPUTE WS-D = WS-KD
*>   the base cell behind the first piece: the opposite direction is the other one of the pair (DOWN 0 / UP 1)
     COMPUTE WS-MX = WS-GX
     IF WS-TIP = 0
         COMPUTE WS-MY = WS-GY + 1
     ELSE
         COMPUTE WS-MY = WS-GY - 1
     END-IF
     MOVE WS-GZ TO WS-MZ
     PERFORM MODEL-ISBASE
     IF WS-D = 0
         EXIT PARAGRAPH
     END-IF
     IF WS-HT < 1
         EXIT PARAGRAPH
     END-IF
     MOVE 0 TO WS-NP
     IF WS-HT >= 3
         ADD 1 TO WS-NP
         MOVE 4 TO WS-PC(WS-NP)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-HT - 3
             ADD 1 TO WS-NP
             MOVE 3 TO WS-PC(WS-NP)
         END-PERFORM
     END-IF
     IF WS-HT >= 2
         ADD 1 TO WS-NP
         MOVE 2 TO WS-PC(WS-NP)
     END-IF
     ADD 1 TO WS-NP
     IF WS-MERGE = 1
         MOVE 0 TO WS-PC(WS-NP)
     ELSE
         MOVE 1 TO WS-PC(WS-NP)
     END-IF
     MOVE WS-GX TO WS-MX
     MOVE WS-GY TO WS-MY
     MOVE WS-GZ TO WS-MZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NP
         PERFORM MGET
         PERFORM MBLOCK
         MOVE "false" TO WS-NAME
         IF WS-MB = WS-B-WATER
             MOVE "true" TO WS-NAME
         END-IF
         MOVE SPACES TO WS-PAIRS
         COMPUTE WS-KD = WS-PC(WS-I) + 1
         IF WS-TIP = 0
             STRING "thickness=" FUNCTION TRIM(WS-THICK(WS-KD)) ",vertical_direction=down,waterlogged=" FUNCTION TRIM(WS-NAME)
                 DELIMITED BY SIZE INTO WS-PAIRS
         ELSE
             STRING "thickness=" FUNCTION TRIM(WS-THICK(WS-KD)) ",vertical_direction=up,waterlogged=" FUNCTION TRIM(WS-NAME)
                 DELIMITED BY SIZE INTO WS-PAIRS
         END-IF
         MOVE "pointed_dripstone" TO WS-KEY
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-MV
         PERFORM MSET
         COMPUTE WS-KD = WS-TIP + 1
         COMPUTE WS-MX = WS-MX + WS-SX(WS-KD)
         COMPUTE WS-MY = WS-MY + WS-SY(WS-KD)
         COMPUTE WS-MZ = WS-MZ + WS-SZ(WS-KD)
     END-PERFORM
     .
