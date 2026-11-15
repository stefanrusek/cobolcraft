*> Paragraphs shared by the tests of the underground features of 35-6 (COPY it inside the PROCEDURE DIVISION, before FWTEST.cpy; the working storage is SPELWS.cpy).
*> COMPILE-FT: compiles the data feature WS-FTKEY into WS-FT. NEW-WORLD: opens the level on chunk (1, 2) with stone y 40 to 62 and y 70 to 80 over the column of the chunk (x 16..31, z 32..47) and
*> snapshots it. SNAPSHOT: copies the cells to the model. MGET: WS-MV = the model cell (WS-MX, WS-MY, WS-MZ) (air outside the chunk's column). MSET: writes WS-MV there (outside the column: nothing).
*> MBLOCK: WS-MB = the block index of the state WS-MV. COMPARE: adds the number of cells (y 38 to 82 of the column) where the level differs from the model to WS-BAD.
*> COUNT-BLOCK: WS-N = the number of cells of the level, over the same region, whose block is WS-WANT.
 COMPILE-FT.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     .
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 70 TO WS-Y0
     MOVE 80 TO WS-Y1
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
 SNAPSHOT.
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     PERFORM VARYING WS-MIDX FROM 1 BY 1 UNTIL WS-MIDX > 98304
         MOVE CE-STATE(WS-MIDX) TO WS-MS(WS-MIDX)
     END-PERFORM
     .
 MGET.
     MOVE WS-S-AIR TO WS-MV
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= -64 AND WS-MY <= 319
         COMPUTE WS-MIDX = (WS-MY + 64) * 256 + (WS-MZ - 32) * 16 + (WS-MX - 16) + 1
         MOVE WS-MS(WS-MIDX) TO WS-MV
     END-IF
     .
 MSET.
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= -64 AND WS-MY <= 319
         COMPUTE WS-MIDX = (WS-MY + 64) * 256 + (WS-MZ - 32) * 16 + (WS-MX - 16) + 1
         MOVE WS-MV TO WS-MS(WS-MIDX)
     END-IF
     .
 MBLOCK.
     COMPUTE WS-MB = CB-S-BLOCK(WS-MV + 1) + 1
     .
*> COMPARE: WS-BAD += the cells (y 38 to 82 of the column) where the level differs from the model
 COMPARE.
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 38 BY 1 UNTIL WS-Y > 82
                 COMPUTE WS-MIDX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .

 COUNT-BLOCK.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 38 BY 1 UNTIL WS-Y > 82
                 PERFORM BLOCK-NOW
                 IF WS-BLOCK = WS-WANT
                     ADD 1 TO WS-N
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
