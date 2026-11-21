*> Implementation test of the whole Nether chunk (core/src/nether-gen-chunk.cob; T1687, T1688; docs/protocol/37-nether-4 section 8, 37-nether-2
*> sections 3 and 9, 37-nether-3 section 5.1): NETHER-GEN-CHUNK for the chunks (0, 0) and (-3, 5) of world seed 0 gives y 0 and y 127 of bedrock in
*> every column, air above y 127 (sections 8 to 15), only the blocks the generator places, a netherrack cap from y 122 (no basalt, gravel
*> or soul sand there), a biome cell of the five Nether biomes everywhere with the 64 rows of a column equal, and the same bytes twice.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-4-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-CHUNK               PIC X(304640).
 01 WS-COPY                PIC X(304640).
 01 WS-CELL                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-COUNT-BEDROCK       BINARY-LONG.
 01 WS-SURFACE-STATES      BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM NETHER-TABLES
     MOVE 0 TO WS-CX WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "NETHER-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     PERFORM CHECK-CHUNK
     MOVE WS-CHUNK TO WS-COPY
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "NETHER-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "acceptance US12 37-4§8 the chunk (0, 0) made twice has the same bytes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CHUNK(1:196608) = WS-COPY(1:196608) AND WS-CHUNK(1:1) = WS-COPY(1:1)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-4§8 the chunk (0, 0) biome cells are the same twice" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CE-BIOMES(1:1024) = WS-COPY(196608 + 53248 + 53248 + 1:1024)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -3 TO WS-CX
     MOVE 5 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "NETHER-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     PERFORM CHECK-CHUNK
     GOBACK.

 CHECK-CHUNK.
     MOVE WS-CX TO WS-ED
     MOVE "acceptance US12 37-4§8 chunk: marker -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MARKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   bedrock at y 0 and y 127 of every column
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 256
         COMPUTE WS-CELL = WS-COL
         IF CE-STATE(WS-CELL) NOT = 7
             ADD 1 TO WS-BAD
         END-IF
         COMPUTE WS-CELL = 127 * 256 + WS-COL
         IF CE-STATE(WS-CELL) NOT = 7
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-2§9 y 0 and y 127 are bedrock in all 256 columns" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   air from y 128, and only generator blocks below
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CELL FROM 32769 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-2§3 sections 8 to 15 (y 128 and up) stay air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD WS-COUNT-BEDROCK
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 32768
         EVALUATE CE-STATE(WS-CELL)
             WHEN 0
             WHEN 100 THRU 110
                 CONTINUE
             WHEN 7
                 ADD 1 TO WS-COUNT-BEDROCK
             WHEN OTHER
                 ADD 1 TO WS-BAD
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 37-4§5 every block is air or one of the generator's blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the roof band y 122 .. 126 holds only netherrack and bedrock
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 122 BY 1 UNTIL WS-Y > 126
         PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 256
             COMPUTE WS-CELL = WS-Y * 256 + WS-COL
             IF CE-STATE(WS-CELL) NOT = 7 AND CE-STATE(WS-CELL) NOT = 100 AND CE-STATE(WS-CELL) NOT = 0
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-4§5 5.1 rule 3: y 122 to 126 hold only netherrack, bedrock (and air)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   bedrock is rare below y 5 and absent from y 5 to 122
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 5 BY 1 UNTIL WS-Y > 122
         PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 256
             COMPUTE WS-CELL = WS-Y * 256 + WS-COL
             IF CE-STATE(WS-CELL) = 7
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-4§5 5.2 no bedrock between y 5 and y 122" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-4§5 5.2 bedrock: more than 256 + 256 blocks (the edges alone) and fewer than 2 x 256 x 4 (partial layers)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT-BEDROCK > 512 AND WS-COUNT-BEDROCK < 2048
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   biomes: ids 0 to 4 in all 1024 cells of the 16 sections, equal over the 64 rows of a column
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 15
         PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW > 3
             PERFORM VARYING WS-COL FROM 1 BY 1 UNTIL WS-COL > 16
                 COMPUTE WS-C = WS-S * 64 + WS-ROW * 16 + WS-COL
                 IF CE-BIOME(WS-C) > 4 OR CE-BIOME(WS-C) NOT = CE-BIOME(WS-COL)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-3§5 5.1 biome cells of 16 sections: ids 0 to 4, every row equal to the first" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-37-4-8.
