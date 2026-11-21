*> Performance measurement of the chunk mesher (operator playtest: unplayably choppy): the cost of
*> MESH-SECTION on a terrain section (half full with relief), on an all-air section and on a solid
*> underground section, and of the frame's MESH-DIRTY call with 64 dirty terrain sections. The
*> timings are printed as PERF lines (CPU microseconds of the C library clock()); the one case
*> asserts only that the meshes were built. The structural guarantees (budget per frame, empty
*> sections, daylight without remesh) are asserted in test_mesher_budget.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PERF-MESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BUDGET              BINARY-LONG VALUE 64.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-QUADS               BINARY-LONG.
 01 WS-MESHED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U
*>   Four rows: terrain (a solid floor of 6 to 10 blocks with relief) in section 1, solid in section 2
*>   of row 1 only, the sections above air under full sky light.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-CX = WS-I - 1
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-ZERO WS-ROW(WS-I)
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(WS-I))
         MOVE ALL X"FF" TO CE-SKYS
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-H = 6 + FUNCTION MOD(WS-X * 7 + WS-Z * 13 + WS-I, 5)
                 PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= WS-H
                     COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                     MOVE 2 TO CE-STATE(WS-CELL)
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW(1))
     PERFORM VARYING WS-Y FROM 16 BY 1 UNTIL WS-Y > 31
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
                 MOVE 2 TO CE-STATE(WS-CELL)
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>   Terrain section: 20 meshes.
     MOVE 1 TO WS-S
     CALL "PERF-CLOCK" USING WS-T0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(2) WS-S
     END-PERFORM
     CALL "PERF-CLOCK" USING WS-T1
     COMPUTE WS-US = (WS-T1 - WS-T0) / 20
     MOVE WS-US TO WS-EDIT
     DISPLAY "PERF mesh-section terrain section, microseconds per mesh: " WS-EDIT
     COMPUTE WS-QUADS = WR-OP-COUNT(WS-ROW(2), 1) / 6
     MOVE WS-QUADS TO WS-EDIT
     DISPLAY "PERF mesh-section terrain section quads: " WS-EDIT

*>   Air section (section 5 of row 2): 20 meshes.
     MOVE 5 TO WS-S
     CALL "PERF-CLOCK" USING WS-T0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(2) WS-S
     END-PERFORM
     CALL "PERF-CLOCK" USING WS-T1
     COMPUTE WS-US = (WS-T1 - WS-T0) / 20
     MOVE WS-US TO WS-EDIT
     DISPLAY "PERF mesh-section all-air section, microseconds per mesh: " WS-EDIT

*>   Solid underground section (section 2 of row 1, solid from y 16 to 31, air above): 20 meshes.
     MOVE 2 TO WS-S
     CALL "PERF-CLOCK" USING WS-T0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "MESH-SECTION" USING CLIENT-STATE WS-ROW(1) WS-S
     END-PERFORM
     CALL "PERF-CLOCK" USING WS-T1
     COMPUTE WS-US = (WS-T1 - WS-T0) / 20
     MOVE WS-US TO WS-EDIT
     DISPLAY "PERF mesh-section solid section, microseconds per mesh: " WS-EDIT

*>   One frame with 64 dirty sections (the sections 1 to 16 of the four rows).
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             MOVE 1 TO WR-DIRTY(WS-ROW(WS-R), WS-S)
         END-PERFORM
     END-PERFORM
     CALL "PERF-CLOCK" USING WS-T0
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "PERF-CLOCK" USING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     MOVE WS-US TO WS-EDIT
     DISPLAY "PERF mesh-dirty one frame with 64 dirty sections, microseconds: " WS-EDIT
     MOVE 0 TO WS-MESHED
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             IF WR-DIRTY(WS-ROW(WS-R), WS-S) = 0
                 ADD 1 TO WS-MESHED
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-MESHED TO WS-EDIT
     DISPLAY "PERF mesh-dirty sections meshed in that frame: " WS-EDIT

     MOVE "perf mesh the terrain section has quads" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-QUADS > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-PERF-MESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERF-CLOCK.
*> USING microseconds out (BINARY-DOUBLE): the process CPU time (C clock(); CLOCKS_PER_SEC is 1000000).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-US.
     CALL STATIC "clock" RETURNING L-US
     GOBACK.
 END PROGRAM PERF-CLOCK.
 COPY CLTEST.
