*> Test of the per-column cache of FL-HEIGHT-OF (core/src/feat-level.cob; docs/protocol/35-worldgen-features-1 section 4.2; docs/design/world-types.md performance): the cache answers
*> a repeated query of an unchanged column without a scan (FL-SCANS counts the scans), a write into a column empties only that column, FL-OPEN empties all, a write outside the
*> column or the build height changes nothing, and over a long random sequence of writes and queries every answer equals an independent scan of the chunk by this test (a model
*> of the five heightmap rules of section 4.2 that reads the cells directly).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-LEVEL-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 01 WS-PTR                 USAGE POINTER.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-S0                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20250611.
 01 WS-R                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-QUERIES             BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-MPASS               BINARY-LONG.
 01 WS-MLEAF               BINARY-LONG.
 01 WS-MLX                 BINARY-LONG.
 01 WS-MLZ                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE 8 TO CB-STATE-COUNT
     MOVE 5 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 1 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 0 TO CB-SOLID(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 0 TO CB-SOLID(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 0 TO CB-SOLID(4)
     MOVE "minecraft:oak_leaves" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE 0 TO CB-SOLID(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE 0 TO CB-SOLID(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     CALL "FL-OPEN" USING WS-PTR BY CONTENT 2 BY CONTENT -1 BY CONTENT -64 BY CONTENT 384 BY CONTENT 63

*>   a column of stone (state 1) up to y = 60 at x = 33, z = -10
     MOVE 33 TO WS-X
     MOVE -10 TO WS-Z
     MOVE 1 TO WS-STATE
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 60
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     MOVE 1 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: the first query of a column is a scan" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FL-SCANS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H2
     MOVE "test feat level cache: the same query again is answered without a scan, with the same height" TO TL-CASE
     MOVE 61 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (FL-SCANS - 1) * 1000 + WS-H2
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N + (WS-H - WS-H2) * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H2
     MOVE "test feat level cache: another heightmap kind of the column is a scan of its own" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE FL-SCANS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a write into another column keeps this column's answers; a write into this column drops them
     MOVE 34 TO WS-X
     MOVE 10 TO WS-Y
     MOVE 5 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 33 TO WS-X
     MOVE 1 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: a write into another column leaves the cached answer" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE FL-SCANS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-Y
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: a write into the column drops its answers (the new top is seen)" TO TL-CASE
     MOVE 3071 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FL-SCANS * 1000 + WS-H
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: a write drops every heightmap kind of the column" TO TL-CASE
     MOVE 4071 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FL-SCANS * 1000 + WS-H
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a write outside the column or above the build height changes no answer and costs no scan
     MOVE 33 TO WS-X
     MOVE 400 TO WS-Y
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: a write above the build height leaves the cached answer" TO TL-CASE
     MOVE 4071 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FL-SCANS * 1000 + WS-H
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a column outside the chunk answers min y and is not cached
     MOVE 48 TO WS-X
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE "test feat level cache: a column outside the chunk answers min y without a scan" TO TL-CASE
     MOVE -64 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (FL-SCANS - 4) * 1000 + WS-H
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an ordinal outside 0 to 5 acts as 5 and shares its cache entry
     MOVE 5 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     MOVE FL-SCANS TO WS-S0
     MOVE 9 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H2
     MOVE -1 TO WS-ORD
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H2
     MOVE "test feat level cache: an ordinal outside 0 to 5 is answered as 5 from the same entry" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (FL-SCANS - WS-S0) * 1000 + WS-H - WS-H2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ORD

*>   FL-OPEN empties the cache
     MOVE 33 TO WS-X
     MOVE FL-SCANS TO WS-S0
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
     CALL "FL-OPEN" USING WS-PTR BY CONTENT 2 BY CONTENT -1 BY CONTENT -64 BY CONTENT 384 BY CONTENT 63
     CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H2
     MOVE "test feat level cache: FL-OPEN empties the cache (FL-SCANS restarts; the query after it scans again, to the same height)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FL-SCANS * (1 - (WS-H - WS-H2) * (WS-H - WS-H2))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a long random sequence of writes and queries over a few columns: every answer equals the model
     MOVE 0 TO WS-BAD WS-QUERIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000
         PERFORM NEXT-RANDOM
         COMPUTE WS-X = 32 + FUNCTION MOD(WS-R, 3)
         PERFORM NEXT-RANDOM
         COMPUTE WS-Z = -16 + FUNCTION MOD(WS-R, 2)
         PERFORM NEXT-RANDOM
         IF FUNCTION MOD(WS-R, 3) = 0
             PERFORM NEXT-RANDOM
             COMPUTE WS-Y = -64 + FUNCTION MOD(WS-R, 400) - 8
             PERFORM NEXT-RANDOM
             COMPUTE WS-STATE = FUNCTION MOD(WS-R, 8)
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
         ELSE
             PERFORM NEXT-RANDOM
             COMPUTE WS-ORD = FUNCTION MOD(WS-R, 6)
             CALL "FL-HEIGHT-OF" USING WS-ORD WS-X WS-Z WS-H
             PERFORM MODEL-HEIGHT
             ADD 1 TO WS-QUERIES
             IF WS-H NOT = WS-MODEL
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "test feat level cache: over 6000 random writes and queries every answer equals the independent scan" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test feat level cache: the random sequence made many queries, most of them answered by the cache" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-QUERIES > 3000 AND FL-SCANS > 0 AND FL-SCANS < 3000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 NEXT-RANDOM.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-Q = WS-SEED / 65536
     MOVE WS-Q TO WS-R
     .
*> MODEL-HEIGHT: the answer of section 4.2 for kind WS-ORD at column (WS-X, WS-Z), by a direct scan of the chunk (states: 0 air, 1 stone, 2 water, 3 lava, 4 leaves, 5 cave air, 6 void air,
*> 7 bedrock; solid: 1, 4, 7).
 MODEL-HEIGHT.
     MOVE -64 TO WS-MODEL
     COMPUTE WS-MLX = WS-X - 32
     COMPUTE WS-MLZ = WS-Z + 16
     MOVE 0 TO WS-MPASS
     PERFORM VARYING WS-MY FROM 319 BY -1 UNTIL WS-MY < -64 OR WS-MPASS = 1
         COMPUTE WS-MIDX = (WS-MY + 64) * 256 + WS-MLZ * 16 + WS-MLX + 1
         MOVE CE-STATE(WS-MIDX) TO WS-MS
         EVALUATE WS-ORD
             WHEN 0
             WHEN 1
                 IF WS-MS NOT = 0 AND WS-MS NOT = 5 AND WS-MS NOT = 6
                     MOVE 1 TO WS-MPASS
                 END-IF
             WHEN 2
             WHEN 3
                 IF WS-MS = 1 OR WS-MS = 4 OR WS-MS = 7
                     MOVE 1 TO WS-MPASS
                 END-IF
             WHEN 4
                 IF WS-MS = 1 OR WS-MS = 4 OR WS-MS = 7 OR WS-MS = 2 OR WS-MS = 3
                     MOVE 1 TO WS-MPASS
                 END-IF
             WHEN OTHER
                 IF WS-MS = 1 OR WS-MS = 7 OR WS-MS = 2 OR WS-MS = 3
                     MOVE 1 TO WS-MPASS
                 END-IF
         END-EVALUATE
         IF WS-MPASS = 1
             COMPUTE WS-MODEL = WS-MY + 1
         END-IF
     END-PERFORM
     .
 END PROGRAM TEST-FEAT-LEVEL-CACHE.
