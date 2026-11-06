*> Acceptance test of US11-1, the client half (standin-content §14.1, §14.5, §4.3, §4.8, §15.3;
*> 08 §10.3, §10.11; client/src/weather-render.cob, sky.cob, packs/builtin.cob): the weather
*> Game Events received set the kind, and each kind is drawn as §14.5 describes. The world is
*> chunk (0, 0) of cobolcraft:main from its fixture (surface heights 52 to 56, the marker pillar
*> up to 59 at (8, 8); biomes lowland and upland, both with has_precipitation 1 in the biome
*> registry fixture), the camera at (8.5, 56.6, 8.5): block column (8, 8), block y 56, so the
*> columns x and z 0 to 16 count and the 16 x 16 of them in the loaded chunk get quads from
*> top + 1 to 72. Time 6001 (day, u 1000): the drizzle scroll is (6001 x 0.25) mod 1 = 0.25, the
*> hail scroll (6001 x 0.5) mod 1 = 0.5. The environment atlas (texture 3, repeat wrapping, shim-abi
*> §9) holds drizzle.png at columns 0 to 15 and hailstorm.png at columns 16 to 31 (32 x 16), so a
*> quad's v is scroll + block y - y0 images: at its top-left corner (y = 72) scroll + n, at its
*> bottom-right corner (y = y0) the scroll; u runs across the kind's half (0 to 0.5 drizzle, 0.5
*> to 1 hail).
*> Sky (day colour #8FB8E6): drizzle (c x 60 + t x 40) div 100 with t #7A7F88 gives
*> (134, 161, 192) and daylight u' = 850; hailstorm (c x 45 + t x 55) div 100 with t #5A5E68 gives
*> (113, 134, 160) and u' = 700.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-WEATHER-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-SPEC                PIC X(40).
 01 WS-EVENT               BINARY-LONG.
 01 WS-LEVEL               FLOAT-SHORT.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-IMAGES.
    05 WS-IMAGE            PIC X(1024) OCCURS 2 TIMES.
 01 WS-REFERENCE           PIC X(1024).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 1024.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-EDIT                PIC ZZ9.
 01 WS-EDIT2               PIC ZZ9.
 01 B-ATLAS                PIC X(51200) BASED.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ENVIRONMENT-ATLAS-BUILD" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-CONFIG TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-s2c-07-registry-data-dimension-type.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE "contract/fixtures/wire/play-s2c-32-login-main.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 8.5 TO PL-X PL-Z
     MOVE 55 TO PL-Y
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 6001 TO PL-TIME

*>   Drizzle: Game Events 1, 7 (1.0), 8 (0.0).
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 8 TO WS-EVENT
     MOVE 0 TO WS-LEVEL
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY" USING CLIENT-STATE WS-TEXT
*>   Column (3, 5): top 53, quads from 54 to 72 (n 18); the top-left corners 15.4 above the eye,
*>   at x 3 in the plane z 5.5 and at z 5 in the plane x 3.5.
     MOVE "z-quad -5.5 15.4 -3.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "x-quad -5.0 15.4 -3.5" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-WEATHER-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US11-1 client half: given drizzle at day then the sky is (134, 161, 192), "
         & "daylight 850, and each loaded column gets two crossed quads on texture 3 with "
         & "drizzle.png scrolled by 0.25: column (3, 5) from y 54 to 72" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "sky 134/161/192 u 850 z-quad 0.0000/18.2500 0.5000/0.2500 1.00/1.00 x-quad "
         & "0.0000/18.2500 0.5000/0.2500 1.00/1.00 3072 1 0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A biome without precipitation (ash_flats, id 2) in the cell holding (3, 54, 5): columns x 0
*>   to 3, z 4 to 7 (tops 52 and 53, so top + 1 lies in that cell) get no quads.
     MOVE 3 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 2 TO WS-BIOME
     CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "z-quad -5.5 15.4 -3.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "near -7.5 15.4 -3.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "beside -1.5 15.4 -3.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-WEATHER-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US11-1 client half: given drizzle when the biome at a column's top + 1 has "
         & "no precipitation (ash_flats) then that column gets no quads: the 16 columns of the "
         & "cell x 0 to 3, z 4 to 7 are left out, column (7, 5) beside it is drawn" TO TL-CASE
     MOVE "z-quad none near none beside 0.0000/17.2500 0.5000/0.2500 1.00/1.00 2880 1 0"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hailstorm: Game Events 1, 7 (1.0), 8 (1.0). Column (10, 2): top 55, quads from 56 to 72.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-08-thunder-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY" USING CLIENT-STATE WS-TEXT
     MOVE "z-quad 1.5 15.4 -6.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     CALL "TEST-WEATHER-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US11-1 client half: given a hailstorm at day then the sky is (113, 134, "
         & "160), daylight 700, and the quads use hailstorm.png (atlas columns 16 on) scrolled by "
         & "0.5: column (10, 2) from y 56 to 72" TO TL-CASE
     MOVE "sky 113/134/160 u 700 z-quad 0.5000/16.5000 1.0000/0.5000 1.00/1.00 2880 1 0"
         TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One client tick later (Time 6002) the hail has fallen half a block: scroll 0.
     MOVE 6002 TO PL-TIME
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     MOVE "z-quad 1.5 15.4 -6.0" TO WS-SPEC
     CALL "TEST-WEATHER-QUAD" USING CLIENT-STATE WS-SPEC WS-TEXT
     MOVE "acceptance US11-1 client half: given a hailstorm when Time advances by one tick then "
         & "the texture scrolls down by 0.5 block (v at the top 16.0 instead of 16.5 images)"
         TO TL-CASE
     MOVE "z-quad 0.5000/16.0000 1.0000/0.0000 1.00/1.00" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clear: Game Events 2, 7 (0.0), 8 (0.0).
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-02-stop-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 7 TO WS-EVENT
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     MOVE 8 TO WS-EVENT
     CALL "TEST-GAME-EVENT" USING CLIENT-STATE WS-CONN WS-EVENT WS-LEVEL
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY" USING CLIENT-STATE WS-TEXT
     CALL "TEST-WEATHER-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US11-1 client half: given clear weather (Game Events 2, 7 0.0, 8 0.0) then "
         & "the sky is the day colour (143, 184, 230) with daylight 1000 and no weather quads are "
         & "drawn (the slot is freed once)" TO TL-CASE
     MOVE "sky 143/184/230 u 1000 0 0 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dimension without weather: travel to cobolcraft:subroutine (sunless: no sky light), a floor
*>   of greystone at y 30 in ash_flats, the weather still a hailstorm.
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-08-thunder-level.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-54-respawn-subroutine.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 30 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 31 TO WS-Y
     PERFORM VARYING WS-X FROM 0 BY 4 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 4 UNTIL WS-Z > 15
             CALL "TEST-SET-BIOME" USING CLIENT-STATE WS-X WS-Y WS-Z WS-BIOME
         END-PERFORM
     END-PERFORM
     MOVE 31 TO PL-Y
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-SKY" USING CLIENT-STATE WS-TEXT
     CALL "TEST-WEATHER-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "US11 edge: given cobolcraft:subroutine (no weather: no sky light, ash_flats) then "
         & "nothing of the weather is drawn: the fixed sky #100C12 (16, 12, 18) and no quads"
         TO TL-CASE
     MOVE "sky 16/12/18 u 1000 0 0 0" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The built-in environment textures (SC-004) and the environment atlas.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE "assets/cobolcraft/textures/environment/drizzle.png" TO WS-PATH
         MOVE 50 TO WS-PATH-LENGTH
         MOVE "SC-004 given only the built-in pack when "
             & "assets/cobolcraft/textures/environment/drizzle.png is read then it is 16 x 16 and "
             & "equals the reference drizzle.rgba pixel for pixel" TO TL-CASE
         IF WS-K = 2
             MOVE "assets/cobolcraft/textures/environment/hailstorm.png" TO WS-PATH
             MOVE 52 TO WS-PATH-LENGTH
             MOVE "SC-004 given only the built-in pack when "
                 & "assets/cobolcraft/textures/environment/hailstorm.png is read then it is "
                 & "16 x 16 and equals the reference hailstorm.rgba pixel for pixel" TO TL-CASE
         END-IF
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE(WS-K)
             WS-IMAGE-CAP WS-W WS-H WS-FOUND
         MOVE "client/tests/fixtures/textures/drizzle.rgba" TO WS-PATH
         IF WS-K = 2
             MOVE "client/tests/fixtures/textures/hailstorm.rgba" TO WS-PATH
         END-IF
         CALL "TEST-READ-FILE" USING WS-PATH WS-REFERENCE WS-IMAGE-CAP WS-LENGTH
         MOVE "T" TO TL-MODE
         MOVE "found 16 x 16 equal" TO TL-EXPECTED
         MOVE "not found or another size" TO TL-OBSERVED
         IF WS-FOUND = 1 AND WS-W = 16 AND WS-H = 16 AND WS-LENGTH = 1024
             MOVE "found 16 x 16 different" TO TL-OBSERVED
             IF WS-IMAGE(WS-K) = WS-REFERENCE
                 MOVE "found 16 x 16 equal" TO TL-OBSERVED
             END-IF
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE 0 TO WS-ROWS
     IF XA-W = 32 AND XA-H = 16
         SET ADDRESS OF B-ATLAS TO XA-ADDR
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 15
             COMPUTE WS-K = WS-R * 64 + 1
             IF B-ATLAS(WS-R * 128 + 1:64) = WS-IMAGE(1)(WS-K:64)
                 ADD 1 TO WS-ROWS
             END-IF
             IF B-ATLAS(WS-R * 128 + 65:64) = WS-IMAGE(2)(WS-K:64)
                 ADD 1 TO WS-ROWS
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-ROWS TO WS-EDIT
     MOVE AT-UPLOAD(4) TO WS-EDIT2
     MOVE "acceptance US11-1 client half: the environment atlas (texture 3) is 32 x 16 and holds "
         & "the active pack's drizzle.png at columns 0 to 15 and hailstorm.png at columns 16 to "
         & "31, once each (repeat wrapping), marked for upload" TO TL-CASE
     MOVE "rows 32 upload 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "rows " FUNCTION TRIM(WS-EDIT) " upload " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US11-WEATHER-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SKY.
*> USING CLIENT-STATE, text (appended): " sky <r>/<g>/<b> u <daylight>" (0 to 255 each).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-E1                  PIC ZZ9.
 01 WS-E2                  PIC ZZ9.
 01 WS-E3                  PIC ZZ9.
 01 WS-E4                  PIC ZZZ9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     COMPUTE WS-E1 ROUNDED = SK-R * 255
     COMPUTE WS-E2 ROUNDED = SK-G * 255
     COMPUTE WS-E3 ROUNDED = SK-B * 255
     MOVE SK-U TO WS-E4
     STRING FUNCTION TRIM(L-TEXT) " sky " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) "/"
         FUNCTION TRIM(WS-E3) " u " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WEATHER-QUAD.
*> USING CLIENT-STATE, spec (PIC X(40): label, then the eye-relative top-left corner x y z), text
*> (appended): " <label> <u>/<v> <u>/<v> <brightness>/<alpha>" of the weather-mesh quad with that
*> top-left corner (its top-left and bottom-right corners), or " <label> none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LABEL               PIC X(10).
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-WORD                PIC X(12).
 01 WS-EU1                 PIC 9.9999.
 01 WS-EV1                 PIC Z9.9999.
 01 WS-EU2                 PIC 9.9999.
 01 WS-EV2                 PIC Z9.9999.
 01 WS-EB                  PIC 9.99.
 01 WS-EA                  PIC 9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SPEC                 PIC X(40).
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-SPEC L-TEXT.
     MOVE 1 TO WS-POS
     UNSTRING L-SPEC DELIMITED BY ALL SPACE INTO WS-LABEL WS-WORD WITH POINTER WS-POS
     COMPUTE WS-CX = FUNCTION NUMVAL(WS-WORD)
     UNSTRING L-SPEC DELIMITED BY ALL SPACE INTO WS-WORD WITH POINTER WS-POS
     COMPUTE WS-CY = FUNCTION NUMVAL(WS-WORD)
     UNSTRING L-SPEC DELIMITED BY ALL SPACE INTO WS-WORD WITH POINTER WS-POS
     COMPUTE WS-CZ = FUNCTION NUMVAL(WS-WORD)
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= RL-WX-COUNT OR WS-FOUND = 1
         COMPUTE WS-A = WS-Q + 1
         COMPUTE WS-B = WS-Q + 3
         IF FUNCTION ABS(RL-WX-X(WS-A) - WS-CX) < 0.001
                 AND FUNCTION ABS(RL-WX-Y(WS-A) - WS-CY) < 0.001
                 AND FUNCTION ABS(RL-WX-Z(WS-A) - WS-CZ) < 0.001
             MOVE 1 TO WS-FOUND
             COMPUTE WS-EU1 ROUNDED = RL-WX-U(WS-A)
             COMPUTE WS-EV1 ROUNDED = RL-WX-V(WS-A)
             COMPUTE WS-EU2 ROUNDED = RL-WX-U(WS-B)
             COMPUTE WS-EV2 ROUNDED = RL-WX-V(WS-B)
             COMPUTE WS-EB ROUNDED = RL-WX-B(WS-A)
             COMPUTE WS-EA ROUNDED = RL-WX-A(WS-A)
         END-IF
     END-PERFORM
     IF WS-FOUND = 1
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " " WS-EU1 "/"
             FUNCTION TRIM(WS-EV1) " " WS-EU2 "/" FUNCTION TRIM(WS-EV2) " " WS-EB "/" WS-EA
             DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " none" DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-WEATHER-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WEATHER-DRAWS.
*> USING CLIENT-STATE, text (appended): " <weather vertices> <translucent draws of the weather slot
*> on texture 3> <empty uploads of the weather slot>" of the last render list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-FREES               BINARY-LONG.
 01 WS-E1                  PIC ZZZ9.
 01 WS-E2                  PIC Z9.
 01 WS-E3                  PIC Z9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE 0 TO WS-DRAWS WS-FREES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-WEATHER AND RL-D-TEX(WS-I) = CC-TEX-ENVIRONMENT
                 AND RL-D-PIPELINE(WS-I) = CC-PIPE-TRANSLUCENT
             ADD 1 TO WS-DRAWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-WEATHER AND RL-U-COUNT(WS-I) = 0
             ADD 1 TO WS-FREES
         END-IF
     END-PERFORM
     MOVE RL-WX-COUNT TO WS-E1
     MOVE WS-DRAWS TO WS-E2
     MOVE WS-FREES TO WS-E3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-WEATHER-DRAWS.
 COPY CLTEST.
