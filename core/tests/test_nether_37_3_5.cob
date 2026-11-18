*> Implementation test of the zoomed block biome lookup (core/src/nether-37-3.cob NETHER-ZOOM; T1667, T1668; docs/protocol/37-nether-3 section 5.2 and
*> 10 section 7.7): the expected biomes were computed by an independent implementation of 10 section 7.7 (obfuscated world seed 0, the fiddled distances
*> of the eight cells) for two rings of 6 x 6 cells around the chunk (0, 0). The probes at one column with growing y show that y takes part in the
*> distance (the winning column changes with y) and the ends y 0 and y 127 need no clamping; a ring of one biome gives that biome anywhere (5.1: no y dependence).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY NETHER.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM NETHER-TABLES
     CALL "NETHER-SETUP" USING WS-SEED
     PERFORM SET-RING-1
     MOVE 8 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 0, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 4, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 6 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 6, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 7 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 7, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 8, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 12 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 12, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 14 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 14, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 16 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 16, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 100, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 127 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 127, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 97 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 97, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 98 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 98, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 99, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 101 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 101, 5) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (10, 64, 5) of the split ring (cells left of the cut 1, right 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (5, 64, 3) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 6 TO WS-X
     MOVE 3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (6, 3, 2) of the split ring (cells left of the cut 1, right 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     PERFORM SET-RING-2
     MOVE 8 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 0, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 4, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 6 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 6, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 7 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 7, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 8, 5) of the diagonal ring (1 + (row + column) mod 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 12 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 12, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 14 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 14, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 16 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 16, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 100, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 8 TO WS-X
     MOVE 127 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (8, 127, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 97 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 97, 5) of the diagonal ring (1 + (row + column) mod 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 98 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 98, 5) of the diagonal ring (1 + (row + column) mod 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 99, 5) of the diagonal ring (1 + (row + column) mod 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 9 TO WS-X
     MOVE 101 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (9, 101, 5) of the diagonal ring (1 + (row + column) mod 5): biome 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (10, 64, 5) of the diagonal ring (1 + (row + column) mod 5): biome 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (5, 64, 3) of the diagonal ring (1 + (row + column) mod 5): biome 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
     MOVE 6 TO WS-X
     MOVE 3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE "acceptance US12 37-3§5 5.2 zoom at (6, 3, 2) of the diagonal ring (1 + (row + column) mod 5): biome 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM ZOOM-AT
*>   a ring of one biome: every probe gives it, whatever the fuzz
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 3 TO NH-RING(WS-I)
     END-PERFORM
     MOVE 0 TO WS-BIOME
     PERFORM VARYING WS-Y FROM 0 BY 9 UNTIL WS-Y > 127
         CALL "NETHER-ZOOM" USING WS-X WS-Y WS-Z WS-R
         IF WS-R NOT = 3
             ADD 1 TO WS-BIOME
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-3§5 5.1 a ring of one biome gives that biome at every y: 0 other answers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BIOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 ZOOM-AT.
     CALL "NETHER-ZOOM" USING WS-X WS-Y WS-Z WS-R
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SET-RING-1.
     MOVE -1 TO NH-RING-QX NH-RING-QZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         COMPUTE WS-C = FUNCTION MOD(WS-I - 1, 6)
         IF WS-C <= 2
             MOVE 1 TO NH-RING(WS-I)
         ELSE
             MOVE 5 TO NH-RING(WS-I)
         END-IF
     END-PERFORM.

 SET-RING-2.
     MOVE -1 TO NH-RING-QX NH-RING-QZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         COMPUTE WS-C = (WS-I - 1) / 6 + FUNCTION MOD(WS-I - 1, 6)
         COMPUTE NH-RING(WS-I) = 1 + FUNCTION MOD(WS-C, 5)
     END-PERFORM.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-37-3-5.
