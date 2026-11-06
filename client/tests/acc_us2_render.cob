*> Acceptance test of US2-4 on the client (FR-003; standin-content §1.1, §1.4, §5.2; data-model §13
*> per-face brightness; 08 §10): given the replica holds the spawn chunk (play-s2c-2e-level-chunk-
*> with-light-spawn.hex) and the player stands at the spawn, the meshes built for the render list
*> draw every visible block face with its built-in sprite and per-face shading, the lucite in the
*> translucent draw with the blocks behind it drawn, and faces near the lit glowtube brighter than
*> the same faces far from it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PATH                PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex".
 01 WS-ID                  BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 1000.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-S                   BINARY-LONG.
 01 WS-OUT                 PIC X(1024).
 01 WS-SPEC                PIC X(40).
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1 TO PL-HAS-SKY
     MOVE 3 TO RG-BIOMES
     MOVE 4.5 TO PL-X
     MOVE 54 TO PL-Y
     MOVE 8.5 TO PL-Z
     MOVE -90 TO PL-YAW
     MOVE 6000 TO PL-TIME
     CALL "SKY-UPDATE" USING CLIENT-STATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "WORLD-CHUNK-LOAD" USING CLIENT-STATE PB-BUFFER
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "WORLD-ROW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW

     MOVE SPACES TO WS-OUT
     MOVE "04.5 54.0 08.5 0turf_top" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "08.0 55.5 08.5 0cardstack_side" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "08.5 60.0 08.5 0glowtube_lit" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "01.0 10.5 00.5 0greystone" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "acceptance US2-4 given the spawn chunk when the Player looks around then every "
         & "visible face is drawn with its built-in sprite and per-face shading (turf top 1.00, the "
         & "pillar's west side 0.60, the glowtube top 1.00) and hidden faces are not" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "turf_top 1.00 cardstack_side 0.60 glowtube_lit 1.00 none" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-OUT
     MOVE "08.0 58.5 08.5 1lucite" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "08.0 58.5 08.5 0lucite" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "08.5 58.0 08.5 0cardstack_end" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "08.5 59.0 08.5 0glowtube_lit" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "acceptance US2-4 given the marker pillar when the Player looks at the lucite then its "
         & "faces are in the translucent draw only and the faces of the blocks behind it (the "
         & "punched cardstack's top, the glowtube's bottom) are drawn" TO TL-CASE
     MOVE "lucite 0.60 none cardstack_end 0.93 glowtube_lit 0.47" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   By night (Time 18000, daylight 0.2): the glowtube's light shows.
     MOVE 18000 TO PL-TIME
     CALL "SKY-UPDATE" USING CLIENT-STATE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
         MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
     END-PERFORM
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     MOVE SPACES TO WS-OUT
     MOVE "09.5 55.0 07.5 0turf_top" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "01.5 53.0 01.5 0turf_top" TO WS-SPEC
     CALL "TEST-RENDER-FACE" USING CLIENT-STATE WS-ROW WS-SPEC WS-OUT
     MOVE "acceptance US2-4 given night when the Player looks at the turf then faces near the lit "
         & "glowtube are brighter (block light 9: 0.60) than the same faces far from it (sky light "
         & "only: 0.20)" TO TL-CASE
     MOVE "turf_top 0.60 turf_top 0.20" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US2-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RENDER-FACE.
*> USING CLIENT-STATE, row, spec ("xx.x yy.y zz.z t<sprite stem>": a face centre in world
*> coordinates of chunk (0, 0), 0 opaque or 1 translucent mesh), text (appended): "<stem of the
*> face's sprite> <brightness>" or "none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-SECTION             BINARY-LONG.
 01 WS-LY                  FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-E                   PIC 9.99.
 01 WS-S                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-STEM                PIC X(40).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SPEC.
    05 L-X                 PIC X(4).
    05 FILLER              PIC X.
    05 L-Y                 PIC X(4).
    05 FILLER              PIC X.
    05 L-Z                 PIC X(4).
    05 FILLER              PIC X.
    05 L-TRANSLUCENT       PIC 9.
    05 L-STEM              PIC X(24).
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SPEC L-TEXT.
     COMPUTE WS-X = FUNCTION NUMVAL(L-X)
     COMPUTE WS-Z = FUNCTION NUMVAL(L-Z)
     COMPUTE WS-LY = FUNCTION NUMVAL(L-Y)
*>   The face's section: that of the cell just below the centre (no centre here lies on a
*>   section's bottom plane).
     COMPUTE WS-SECTION = FUNCTION INTEGER((WS-LY - 0.01) / 16) + 1
     COMPUTE WS-Y = WS-LY - (WS-SECTION - 1) * 16
     IF L-TRANSLUCENT = 0
         CALL "TEST-MESH-FACE" USING WR-OP-ADDR(L-ROW, WS-SECTION) WR-OP-COUNT(L-ROW, WS-SECTION)
             WS-X WS-Y WS-Z WS-FOUND WS-B WS-U WS-V
     ELSE
         CALL "TEST-MESH-FACE" USING WR-TR-ADDR(L-ROW, WS-SECTION) WR-TR-COUNT(L-ROW, WS-SECTION)
             WS-X WS-Y WS-Z WS-FOUND WS-B WS-U WS-V
     END-IF
     IF WS-FOUND = 0
         STRING FUNCTION TRIM(L-TEXT) " none" DELIMITED BY SIZE INTO L-TEXT
     ELSE
*>       The sprite whose atlas rectangle holds the top-left texture coordinate.
         MOVE "?" TO WS-STEM
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > AT-SPRITE-COUNT
             IF WS-U * AT-W >= AT-X(WS-S) - 0.01 AND WS-U * AT-W < AT-X(WS-S) + AT-SW(WS-S) - 0.01
                     AND WS-V * AT-H >= AT-Y(WS-S) - 0.01
                     AND WS-V * AT-H < AT-Y(WS-S) + AT-SH(WS-S) - 0.01
                 MOVE AT-NAME(WS-S) TO WS-NAME
                 UNSTRING WS-NAME DELIMITED BY "/" INTO WS-STEM WS-STEM
             END-IF
         END-PERFORM
         COMPUTE WS-E ROUNDED = WS-B
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-STEM) " " WS-E DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-RENDER-FACE.
 COPY CLTEST.
