*> Implementation test of client/src/weather-render.cob (ENVIRONMENT-ATLAS-BUILD, WEATHER-MESH):
*> with no pack supplying the environment textures the environment atlas holds the missing-texture
*> stripes at the stand-in size 16 x 16, once for each kind side by side (32 x 16; the shim
*> repeats it, shim-abi §9), built again without leaking the old image. Drizzle over chunk (0, 0) holding one block at (0, 10, 0) and a pillar top
*> at (1, 70, 0), the camera at (0.5, 50.6, 0.5) (column (0, 0), block y 50): a column whose top
*> lies below cy - 8 gets quads from 42 to 66, an all-void column too, the pillar column (top 70 at
*> or above cy + 16) none, and the columns of the unloaded chunks around none; a biome id past the
*> registry gets none; clear weather builds no quads.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WEATHER-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-W                   BINARY-LONG VALUE 16.
 01 WS-H                   BINARY-LONG VALUE 16.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-STRIPES             PIC X(1024).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-BIOME               BINARY-LONG VALUE 200.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EDIT                PIC ZZZ9.
 01 WS-EV                  PIC 99.9999.
 01 B-ATLAS                PIC X(51200) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENVIRONMENT-ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENVIRONMENT-ATLAS-BUILD" USING CLIENT-STATE
     CALL "MISSING-TEXTURE" USING WS-W WS-H WS-STRIPES
     MOVE 0 TO WS-ROWS
     IF XA-W = 32 AND XA-H = 16
         SET ADDRESS OF B-ATLAS TO XA-ADDR
*>       Half row r (64 bytes) of the 128-byte atlas rows is row r / 2 of the stripes.
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 31
             DIVIDE WS-R BY 2 GIVING WS-K
             COMPUTE WS-K = WS-K * 64 + 1
             IF B-ATLAS(WS-R * 64 + 1:64) = WS-STRIPES(WS-K:64)
                 ADD 1 TO WS-ROWS
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-ROWS TO WS-EDIT
     MOVE "weather render with no pack supplying the environment textures the 32 x 16 "
         & "environment atlas holds the 16 x 16 missing texture twice side by side (32 half "
         & "rows), marked for upload" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "rows 32 upload 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "rows " FUNCTION TRIM(WS-EDIT) " upload " AT-UPLOAD(4) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drizzle over chunk (0, 0); biome 0 has precipitation.
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO PL-MIN-Y PL-TIME
     MOVE 1 TO RG-BIOME-PRECIP(1)
     MOVE WX-DRIZZLE TO PL-WEATHER
     MOVE 0 TO WS-X WS-Z
     MOVE 10 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 1 TO WS-X
     MOVE 70 TO WS-Y
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
     MOVE 50.6 TO WS-EYE(2)
     CALL "WEATHER-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE SPACES TO TL-OBSERVED
     MOVE RL-WX-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
*>   Column (0, 0): top-left corner (0, 66, 0.5); column (2, 2), all void: (2, 66, 2.5).
     MOVE -0.5 TO WS-EYE(1)
     MOVE 0 TO WS-EYE(3)
     PERFORM FIND-CORNER
     MOVE 1.5 TO WS-EYE(1)
     MOVE 2 TO WS-EYE(3)
     PERFORM FIND-CORNER
*>   The pillar column (1, 0): none.
     MOVE 0.5 TO WS-EYE(1)
     MOVE 0 TO WS-EYE(3)
     PERFORM FIND-CORNER
     MOVE "weather render drizzle with the camera at block y 50: 80 of the 81 loaded columns get "
         & "quads from y 42 (cy - 8: below their tops' + 1) to 66, 24 images tall; the pillar "
         & "column (top 70, at or above cy + 16) gets none" TO TL-CASE
     MOVE "960 24.0000 24.0000 none" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO WS-X WS-Z
     MOVE 1 TO WS-Y
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
     MOVE 50.6 TO WS-EYE(2)
     CALL "WEATHER-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "weather render a column whose biome id lies past the biome registry (200) gets no "
         & "quads: the 14 all-void columns of biome cell x and z 0 to 3, y 0 to 3 are left out "
         & "(column (0, 0) takes its biome at y 11)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 792 TO TL-EXPECTED-N
     MOVE RL-WX-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE WX-CLEAR TO PL-WEATHER
     CALL "WEATHER-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "weather render clear weather builds no quads" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-WX-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Appends " <v>" of the quad whose top-left corner is (WS-EYE(1), 15.4, WS-EYE(3)) eye-relative,
*> or " none".
 FIND-CORNER.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 6 UNTIL WS-I > RL-WX-COUNT OR WS-FOUND = 1
         IF FUNCTION ABS(RL-WX-X(WS-I) - WS-EYE(1)) < 0.001
                 AND FUNCTION ABS(RL-WX-Y(WS-I) - 15.4) < 0.001
                 AND FUNCTION ABS(RL-WX-Z(WS-I) - WS-EYE(3)) < 0.001
             MOVE 1 TO WS-FOUND
             COMPUTE WS-EV ROUNDED = RL-WX-V(WS-I)
             STRING FUNCTION TRIM(TL-OBSERVED) " " WS-EV DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " none" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     .
 END PROGRAM TEST-WEATHER-RENDER.
 COPY CLTEST.
