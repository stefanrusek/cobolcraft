*> Acceptance test of US5-1, the client half (standin-content §3 loose_item, §3.3 ground item
*> appearance, §9; docs/protocol/09-cobolcraft-profile.md §3.3 ground items; client/src/
*> entities-replica.cob, entities-render.cob): a loose_item added by the server, with its stack from
*> Set Entity Data, is drawn as its item's icon on a 0.3 x 0.3 quad (texture 0, the block and item
*> atlas), bottom edge at the entity's y, centred on it horizontally and turned about the vertical
*> axis to face the camera; it follows the server's Teleport Entity updates until it rests; Take
*> Item Entity removes it once every item is taken (a partial take leaves it), Remove Entities
*> removes it, and its mesh slot is released when no ground item is left.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-GROUND-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-ID                  BINARY-LONG VALUE 10.
 01 WS-ID2                 BINARY-LONG VALUE 12.
 01 WS-PLAYER              BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ITEM                BINARY-LONG VALUE 4.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 2.5.
 01 WS-Y                   FLOAT-LONG VALUE 12.0.
 01 WS-Z                   FLOAT-LONG VALUE 4.5.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-ZERO                FLOAT-SHORT VALUE 0.
 01 WS-ZERO2               FLOAT-SHORT VALUE 0.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-EU                  PIC 9.9(4).
 01 WS-EV                  PIC 9.9(4).
 01 WS-UV                  PIC X(20).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   The icon of turf (item 4): the top-left of its sprite in the block and item atlas.
     MOVE IT-SPRITE(WS-ITEM + 1) TO WS-SPRITE
     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-ZERO WS-ZERO2 WS-U WS-V
     COMPUTE WS-EU ROUNDED = WS-U
     COMPUTE WS-EV ROUNDED = WS-V
     MOVE SPACES TO WS-UV
     STRING WS-EU "/" WS-EV DELIMITED BY SIZE INTO WS-UV

*>   The eye is at (0.5, 11.6, 0.5), facing +Z (yaw 0): the camera's right is -X.
     CALL "TEST-ADD-ITEM" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-COUNT WS-ITEM
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-GI-QUAD" USING CLIENT-STATE WS-TEXT
     CALL "TEST-GI-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US5-1 client half: given 3 turf on the ground at (2.5, 12, 4.5) and the "
         & "camera facing +Z then the turf icon is drawn on texture 0 on a 0.3 x 0.3 quad facing "
         & "the camera, corners at eye-relative (2.15, 0.70, 4) and (1.85, 0.40, 4)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     STRING "2.15/0.70/4.00 1.85/0.40/4.00 " FUNCTION TRIM(WS-UV) " 1.00 6 1 0"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 90 TO PL-YAW
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-GI-QUAD" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US5-1 client half: when the camera turns to face -X (yaw 90) then the quad "
         & "turns with it: top-left (+Z side) at (2, 0.70, 4.15), bottom-right at (2, 0.40, 3.85)"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "2.00/0.70/4.15 2.00/0.40/3.85 " FUNCTION TRIM(WS-UV) " 1.00" DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO PL-YAW
     MOVE 11.0 TO WS-Y
     MOVE 0 TO WS-GROUND
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-GI-QUAD" USING CLIENT-STATE WS-TEXT
     MOVE 10.0 TO WS-Y
     MOVE 1 TO WS-GROUND
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     CALL "TEST-GI-QUAD" USING CLIENT-STATE WS-TEXT
     CALL "TEST-ENTITY" USING CLIENT-STATE WS-ID WS-TEXT
     MOVE "acceptance US5-1 client half: when the server moves the falling item to y 11 and then "
         & "to rest on the floor at y 10 then the quad follows it and the item is on the ground"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "2.15/-0.30/4.00 1.85/-0.60/4.00 " FUNCTION TRIM(WS-UV)
         " 1.00 2.15/-1.30/4.00 1.85/-1.60/4.00 " FUNCTION TRIM(WS-UV)
         " 1.00 10 1 2.5000/10.0000/4.5000 0.0/0.0/0.0 1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 1 TO WS-AMOUNT
     CALL "TEST-TAKE-ITEM" USING CLIENT-STATE WS-CONN WS-ID WS-PLAYER WS-AMOUNT
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-ID WS-TEXT
     CALL "TEST-GI-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE 2 TO WS-AMOUNT
     CALL "TEST-TAKE-ITEM" USING CLIENT-STATE WS-CONN WS-ID WS-PLAYER WS-AMOUNT
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-ID WS-TEXT
     CALL "TEST-GI-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US5-1 client half: when Take Item Entity takes 1 of the 3 items then the "
         & "item stays with 2; when it takes the other 2 then it is removed, nothing is drawn and "
         & "the ground-item mesh slot is released" TO TL-CASE
     MOVE "10 2x4 0.0000/0.0000/0.0000 6 1 0 10 none 0 0 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-ADD-ITEM" USING CLIENT-STATE WS-CONN WS-ID2 WS-X WS-Y WS-Z WS-COUNT WS-ITEM
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE SPACES TO WS-TEXT
     CALL "TEST-GI-DRAWS" USING CLIENT-STATE WS-TEXT
     CALL "TEST-REMOVE-ENTITY" USING CLIENT-STATE WS-CONN WS-ID2
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     CALL "TEST-GROUND-ITEM" USING CLIENT-STATE WS-ID2 WS-TEXT
     CALL "TEST-GI-DRAWS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US5-1 client half: given another ground item drawn when Remove Entities "
         & "names it then it is removed and nothing is drawn" TO TL-CASE
     MOVE "6 1 0 12 none 0 0 1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US5-GROUND-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GI-QUAD.
*> USING CLIENT-STATE, text (appended): " <x>/<y>/<z> <x>/<y>/<z> <u>/<v> <brightness>" of the
*> first ground-item quad: its top-left and bottom-right corners (vertices 1 and 3, eye-relative,
*> 2 decimals), the top-left's texture coordinates (4 decimals) and its brightness; " none" when
*> no ground item is drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EX                  PIC -9.99.
 01 WS-EY                  PIC -9.99.
 01 WS-EZ                  PIC -9.99.
 01 WS-EU                  PIC 9.9(4).
 01 WS-EV                  PIC 9.9(4).
 01 WS-EB                  PIC 9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     IF RL-GI-COUNT < 6
         STRING FUNCTION TRIM(L-TEXT) " none" DELIMITED BY SIZE INTO L-TEXT
     ELSE
         PERFORM VARYING WS-K FROM 1 BY 2 UNTIL WS-K > 3
             COMPUTE WS-EX ROUNDED = RL-GI-X(WS-K)
             COMPUTE WS-EY ROUNDED = RL-GI-Y(WS-K)
             COMPUTE WS-EZ ROUNDED = RL-GI-Z(WS-K)
             STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-EX) "/" FUNCTION TRIM(WS-EY) "/"
                 FUNCTION TRIM(WS-EZ) DELIMITED BY SIZE INTO L-TEXT
         END-PERFORM
         MOVE 1 TO WS-I
         COMPUTE WS-EU ROUNDED = RL-GI-U(WS-I)
         COMPUTE WS-EV ROUNDED = RL-GI-V(WS-I)
         COMPUTE WS-EB ROUNDED = RL-GI-B(WS-I)
         STRING FUNCTION TRIM(L-TEXT) " " WS-EU "/" WS-EV " " WS-EB DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-GI-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GI-DRAWS.
*> USING CLIENT-STATE, text (appended): " <ground-item vertices> <translucent draws of the
*> ground-item slot on texture 0> <empty uploads of that slot>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-RELEASED            BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-EDIT2               PIC Z(4)9.
 01 WS-EDIT3               PIC Z(4)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE 0 TO WS-DRAWS WS-RELEASED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-GROUND-ITEMS AND RL-D-TEX(WS-I) = CC-TEX-BLOCKS
                 AND RL-D-PIPELINE(WS-I) = CC-PIPE-TRANSLUCENT
             ADD 1 TO WS-DRAWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-GROUND-ITEMS AND RL-U-COUNT(WS-I) = 0
             ADD 1 TO WS-RELEASED
         END-IF
     END-PERFORM
     MOVE RL-GI-COUNT TO WS-EDIT
     MOVE WS-DRAWS TO WS-EDIT2
     MOVE WS-RELEASED TO WS-EDIT3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-GI-DRAWS.
 COPY CLTEST.
