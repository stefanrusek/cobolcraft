*> Implementation test of TINT-AVERAGE (client/src/tint-43.cob; docs/protocol/43-tint-sources.md section 4; operator report "lots of blocks aren't rendering",
*> try14: meshing took 5 to 15 ms a section, most of it the biome blend of every grass top, leaf and water surface: 25 calls of TINT-BIOME-AT and of
*> TINT-BIOME-COLOR each). The blend is read without a call per sample now. Cases: (1) over a replica of five chunks around the origin with every kind of
*> biome cell (the swamp's noise, the dark forest's modifier, overrides, an id the table does not know, plains), all four resolvers, the radii 0 to 7, x and z
*> across the chunk borders (negative coordinates, an unloaded chunk) and y inside and outside the world, TINT-AVERAGE returns exactly what the
*> definition gives (the box of TINT-BIOME-AT and TINT-BIOME-COLOR samples, summed per channel, integer division: TINT-AVERAGE-REF below); (2) a blend of
*> radius 2 costs at most a third of the definition's (the cost that made the sections of a view take minutes).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-AVERAGE-FAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLTINT.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-RESOLVER            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-CHECKED             BINARY-LONG VALUE 0.
 01 WS-WRONG               BINARY-LONG VALUE 0.
 01 WS-SHOWN               BINARY-LONG VALUE 0.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US-NEW              BINARY-DOUBLE.
 01 WS-US-REF              BINARY-DOUBLE.
 01 WS-REPEAT              BINARY-LONG.
 01 WS-HASH                BINARY-LONG.
 01 WS-N                   PIC Z(8)9.
 01 WS-N2                  PIC Z(8)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE -64 TO PL-MIN-Y
     MOVE 384 TO PL-HEIGHT
*>   The colour data: colormaps with a different colour per pixel, six biomes (0 to 5) with their kinds, the plains biome 1.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 65536
         COMPUTE TT-MAP-GRASS(WS-I) = 4278190080 + FUNCTION MOD(WS-I * 7, 256) * 65536 + FUNCTION MOD(WS-I * 13, 256) * 256 + FUNCTION MOD(WS-I, 251)
         COMPUTE TT-MAP-FOLIAGE(WS-I) = 4278190080 + FUNCTION MOD(WS-I * 3, 256) * 65536 + FUNCTION MOD(WS-I * 5, 256) * 256 + FUNCTION MOD(WS-I, 199)
         COMPUTE TT-MAP-DRY(WS-I) = 4278190080 + FUNCTION MOD(WS-I * 11, 256) * 65536 + FUNCTION MOD(WS-I * 17, 256) * 256 + FUNCTION MOD(WS-I, 241)
     END-PERFORM
     MOVE 6 TO TT-BIOMES
     MOVE 1 TO TT-PLAINS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE TB-TEMP(WS-I) = FUNCTION MOD(WS-I * 17, 11) / 10
         COMPUTE TB-DOWN(WS-I) = FUNCTION MOD(WS-I * 7, 13) / 12
         COMPUTE TB-WATER(WS-I) = 4278190080 + WS-I * 3000000
         MOVE -1 TO TB-GRASS(WS-I) TB-FOLIAGE(WS-I) TB-DRY(WS-I)
         MOVE 0 TO TB-MOD(WS-I)
     END-PERFORM
     MOVE 1 TO TB-MOD(3)
     MOVE 2 TO TB-MOD(4)
     MOVE 4279312947 TO TB-GRASS(5)
     MOVE 4282668390 TO TB-FOLIAGE(5)
     MOVE 4283201084 TO TB-DRY(6)
*>   Five chunks: (0,0), (-1,0), (1,0), (0,-1), (0,1); every biome cell holds one of the ids 0 to 5, or 9 (not in the table).
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
         EVALUATE WS-J
             WHEN 1 MOVE 0 TO WS-CX WS-CZ
             WHEN 2 MOVE -1 TO WS-CX
                    MOVE 0 TO WS-CZ
             WHEN 3 MOVE 1 TO WS-CX
                    MOVE 0 TO WS-CZ
             WHEN 4 MOVE 0 TO WS-CX
                    MOVE -1 TO WS-CZ
             WHEN OTHER MOVE 0 TO WS-CX
                    MOVE 1 TO WS-CZ
         END-EVALUATE
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
             COMPUTE WS-HASH = FUNCTION MOD(WS-I * 31 + WS-J * 17 + FUNCTION MOD(WS-I * WS-I, 7), 9)
             IF WS-HASH > 5
                 MOVE 9 TO CE-BIOME(WS-I)
             ELSE
                 MOVE WS-HASH TO CE-BIOME(WS-I)
             END-IF
         END-PERFORM
     END-PERFORM

*>   (1) The same colour as the definition, everywhere.
     PERFORM VARYING WS-RESOLVER FROM 1 BY 1 UNTIL WS-RESOLVER > 4
      PERFORM VARYING WS-RADIUS FROM 0 BY 1 UNTIL WS-RADIUS > 7
       PERFORM VARYING WS-Y FROM -70 BY 37 UNTIL WS-Y > 420
        PERFORM VARYING WS-X FROM -22 BY 7 UNTIL WS-X > 38
         PERFORM VARYING WS-Z FROM -21 BY 6 UNTIL WS-Z > 37
             CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-RADIUS WS-GOT
             CALL "TINT-AVERAGE-REF" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-RADIUS WS-WANT
             ADD 1 TO WS-CHECKED
             IF WS-GOT NOT = WS-WANT
                 ADD 1 TO WS-WRONG
                 IF WS-SHOWN < 10
                     ADD 1 TO WS-SHOWN
                     DISPLAY "DIFF resolver " WS-RESOLVER " radius " WS-RADIUS " at " WS-X " " WS-Y " " WS-Z " got " WS-GOT " want " WS-WANT
                 END-IF
             END-IF
         END-PERFORM
        END-PERFORM
       END-PERFORM
      END-PERFORM
     END-PERFORM
     MOVE WS-WRONG TO WS-N
     MOVE WS-CHECKED TO WS-N2
     MOVE "tint average the blend equals the definition for every resolver, radius, chunk border, unloaded chunk and y (no position differs)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "different 0 of " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-EXPECTED
     IF WS-WRONG = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         STRING "different " FUNCTION TRIM(WS-N) " of " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   (2) The cost: 400 blends of radius 2 (a grass top) each way, over one biome (the usual terrain: a blend looks at 25 columns of the same biome).
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 5
         EVALUATE WS-J
             WHEN 1 MOVE 0 TO WS-CX WS-CZ
             WHEN 2 MOVE -1 TO WS-CX
                    MOVE 0 TO WS-CZ
             WHEN 3 MOVE 1 TO WS-CX
                    MOVE 0 TO WS-CZ
             WHEN 4 MOVE 0 TO WS-CX
                    MOVE -1 TO WS-CZ
             WHEN OTHER MOVE 0 TO WS-CX
                    MOVE 1 TO WS-CZ
         END-EVALUATE
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
             MOVE 0 TO CE-BIOME(WS-I)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO WS-RESOLVER
     MOVE 2 TO WS-RADIUS
     MOVE 70 TO WS-Y
     CALL "TINT-CLOCK" USING WS-T0
     PERFORM VARYING WS-REPEAT FROM 1 BY 1 UNTIL WS-REPEAT > 400
         COMPUTE WS-X = FUNCTION MOD(WS-REPEAT, 20) - 2
         COMPUTE WS-Z = WS-REPEAT / 20
         CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-RADIUS WS-GOT
     END-PERFORM
     CALL "TINT-CLOCK" USING WS-T1
     COMPUTE WS-US-NEW = WS-T1 - WS-T0
     CALL "TINT-CLOCK" USING WS-T0
     PERFORM VARYING WS-REPEAT FROM 1 BY 1 UNTIL WS-REPEAT > 400
         COMPUTE WS-X = FUNCTION MOD(WS-REPEAT, 20) - 2
         COMPUTE WS-Z = WS-REPEAT / 20
         CALL "TINT-AVERAGE-REF" USING CLIENT-STATE WS-RESOLVER WS-X WS-Y WS-Z WS-RADIUS WS-WANT
     END-PERFORM
     CALL "TINT-CLOCK" USING WS-T1
     COMPUTE WS-US-REF = WS-T1 - WS-T0
     MOVE WS-US-NEW TO WS-N
     MOVE WS-US-REF TO WS-N2
     DISPLAY "PERF tint average 400 blends of radius 2: " FUNCTION TRIM(WS-N) " us, the definition: " FUNCTION TRIM(WS-N2) " us"
     MOVE "tint average 400 blends of radius 2 cost at most a third of the definition's time" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "at most a third" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-US-NEW * 3 <= WS-US-REF
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         STRING "new " FUNCTION TRIM(WS-N) " us, definition " FUNCTION TRIM(WS-N2) " us" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-TINT-AVERAGE-FAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-CLOCK.
*> USING microseconds out (BINARY-DOUBLE): the CPU time of the process (C clock()).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-US                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-US.
     CALL STATIC "clock" RETURNING L-US
     GOBACK.
 END PROGRAM TINT-CLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-AVERAGE-REF.
*> The definition of the blend (section 4): USING CLIENT-STATE, resolver, x, y, z, radius, colour out. Radius 0 is the resolver's colour of the
*> position's biome as it is; a larger radius averages the (2r + 1)^2 columns at the same y, each channel summed and divided with integer
*> division, alpha 255, every sample one TINT-BIOME-AT and one TINT-BIOME-COLOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIOME               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-CH                  BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-RESOLVER             BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-RESOLVER L-X L-Y L-Z L-RADIUS L-COLOUR.
     COMPUTE WS-RAD = FUNCTION MAX(0, FUNCTION MIN(7, L-RADIUS))
     IF WS-RAD = 0
         CALL "TINT-BIOME-AT" USING CLIENT-STATE L-X L-Y L-Z WS-BIOME
         CALL "TINT-BIOME-COLOR" USING L-RESOLVER WS-BIOME L-X L-Z L-COLOUR
         GOBACK
     END-IF
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2 * WS-RAD
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 2 * WS-RAD
             COMPUTE WS-PX = L-X - WS-RAD + WS-DX
             COMPUTE WS-PZ = L-Z - WS-RAD + WS-DZ
             CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-PX L-Y WS-PZ WS-BIOME
             CALL "TINT-BIOME-COLOR" USING L-RESOLVER WS-BIOME WS-PX WS-PZ WS-COLOUR
             COMPUTE WS-CH = WS-COLOUR / 65536
             COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
             ADD WS-CH TO WS-SUM(1)
             COMPUTE WS-CH = WS-COLOUR / 256
             COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
             ADD WS-CH TO WS-SUM(2)
             COMPUTE WS-CH = FUNCTION MOD(WS-COLOUR, 256)
             ADD WS-CH TO WS-SUM(3)
         END-PERFORM
     END-PERFORM
     COMPUTE WS-N = (2 * WS-RAD + 1) * (2 * WS-RAD + 1)
     DIVIDE WS-SUM(1) BY WS-N GIVING WS-SUM(1)
     DIVIDE WS-SUM(2) BY WS-N GIVING WS-SUM(2)
     DIVIDE WS-SUM(3) BY WS-N GIVING WS-SUM(3)
     COMPUTE L-COLOUR = 4278190080 + WS-SUM(1) * 65536 + WS-SUM(2) * 256 + WS-SUM(3)
     GOBACK.
 END PROGRAM TINT-AVERAGE-REF.
