*> Test of the column query STRUCT-BASE-HEIGHT (core/src/struct-height.cob; docs/design/world-types.md structures part 5; the getBaseHeight of
*> docs/protocol/37-nether-2 section 6.5 applied to the overworld's final density): the height of a world column from the final density alone, at a
*> column inside or outside the chunk being generated. Expected values come from the generator itself: the heightmaps WORLD_SURFACE_WG and
*> OCEAN_FLOOR_WG that the terrain fill of a chunk job records (the job is stepped to the end of the fill, 10 section 8.1). The fixture terrain data
*> have no aquifer, so the fill uses the global fluid picker like the query and every column must agree. Fixture terrain data core/tests/fixtures/height (the gen fixture with the continentalness term scaled to 2.5 at xz_scale 8, so that the surface runs up and down within a chunk and crosses the sea level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CLIMATE.
 COPY GENSTEPS.
 01 WS-GEN-DIR             PIC X(1100) VALUE "core/tests/fixtures/height".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==W-==.
 01 WS-CHUNKS.
    05 WS-CHUNK-X          BINARY-LONG OCCURS 4 TIMES.
    05 WS-CHUNK-Z          BINARY-LONG OCCURS 4 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-BAD-SURFACE         BINARY-LONG.
 01 WS-BAD-FLOOR           BINARY-LONG.
 01 WS-BAD-ORDER           BINARY-LONG.
 01 WS-BAD-AGAIN           BINARY-LONG.
 01 WS-LAND                BINARY-LONG VALUE 0.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-ZERO-KIND           BINARY-LONG VALUE 0.
 01 WS-ONE-KIND            BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-GEN-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-GEN-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "GEN-DATA-READY" USING WS-STATUS
     CALL "GEN-QUEUE-RESET"
     MOVE 0 TO WS-CHUNK-X(1) MOVE 0 TO WS-CHUNK-Z(1)
     MOVE 1 TO WS-CHUNK-X(2) MOVE 0 TO WS-CHUNK-Z(2)
     MOVE -3 TO WS-CHUNK-X(3) MOVE 5 TO WS-CHUNK-Z(3)
     MOVE 7 TO WS-CHUNK-X(4) MOVE -6 TO WS-CHUNK-Z(4)
     MOVE 0 TO WS-BAD-SURFACE WS-BAD-FLOOR WS-BAD-ORDER WS-BAD-AGAIN
     MOVE 999 TO WS-LOW
     MOVE -999 TO WS-HIGH
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 4
         CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CHUNK-X(WS-N) WS-CHUNK-Z(WS-N)
         PERFORM UNTIL W-STAGE > GJ-STAGE-FILL
             CALL "GEN-JOB-STEP" USING WS-JOB
         END-PERFORM
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                 COMPUTE WS-X = WS-CHUNK-X(WS-N) * 16 + WS-LX
                 COMPUTE WS-Z = WS-CHUNK-Z(WS-N) * 16 + WS-LZ
                 COMPUTE WS-COL = WS-LZ * 16 + WS-LX + 1
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-ZERO-KIND WS-H
                 COMPUTE WS-WANT = W-HM-SURFACE(WS-COL) + 1
                 IF WS-H NOT = WS-WANT
                     ADD 1 TO WS-BAD-SURFACE
                 END-IF
                 IF WS-H > WS-LAND
                     MOVE WS-H TO WS-LAND
                 END-IF
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-ONE-KIND WS-H2
                 IF WS-H2 < WS-LOW
                     MOVE WS-H2 TO WS-LOW
                 END-IF
                 IF WS-H2 > WS-HIGH
                     MOVE WS-H2 TO WS-HIGH
                 END-IF
                 COMPUTE WS-WANT = W-HM-OCEAN(WS-COL) + 1
                 IF WS-H2 NOT = WS-WANT
                     ADD 1 TO WS-BAD-FLOOR
                 END-IF
                 IF WS-H2 > WS-H
                     ADD 1 TO WS-BAD-ORDER
                 END-IF
             END-PERFORM
         END-PERFORM
         CALL "GEN-JOB-FREE" USING WS-JOB
     END-PERFORM
     MOVE "test struct height given 1024 columns of 4 chunks when WORLD_SURFACE_WG is asked then it equals the fill's heightmap + 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-SURFACE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct height given 1024 columns of 4 chunks when OCEAN_FLOOR_WG is asked then it equals the fill's heightmap + 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FLOOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct height given every column when both kinds are asked then the ocean floor is never above the surface" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ORDER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct height given the fixture terrain when the ocean floor heights are read then they are not all equal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HIGH > WS-LOW
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test struct height given the fixture terrain when the surface heights are read then some column is above the sea level of 63" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LAND > 63
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   asked again in another order (the corner cache is warm, a chunk away first): the same value
     PERFORM VARYING WS-N FROM 4 BY -1 UNTIL WS-N < 1
         PERFORM VARYING WS-LZ FROM 15 BY -5 UNTIL WS-LZ < 0
             PERFORM VARYING WS-LX FROM 0 BY 3 UNTIL WS-LX > 15
                 COMPUTE WS-X = WS-CHUNK-X(WS-N) * 16 + WS-LX
                 COMPUTE WS-Z = WS-CHUNK-Z(WS-N) * 16 + WS-LZ
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-ZERO-KIND WS-H
                 CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-ZERO-KIND WS-H2
                 IF WS-H NOT = WS-H2
                     ADD 1 TO WS-BAD-AGAIN
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test struct height given columns asked twice in the reverse chunk order when compared then they agree" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-AGAIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-HEIGHT.

 COPY NOSPAWN.
 COPY CORETEST.
