*> GUI sprites of the UI atlas (12 §5.9; builtin-ui-art 3, 5): GUI-SPRITES-LOAD reads the sprites the screens
*> draw (GSP-* in CLCONST.cpy: widget/button, container/slot) through the pack stack, from
*> assets/minecraft/textures/gui/sprites/<id>.png and its .png.mcmeta (gui.scaling nine_slice: width, height,
*> border as a number or an object of left, top, right and bottom), into the rows GS-* of the client state.
*> Mode 0 measures (GS-W, GS-H, the scaling, GS-TOTAL-H, GS-MAX-W: FONT-LOAD sizes the atlas by them); mode 1
*> copies the pixels below the icon cells (UA-SPRITE-Y), one sprite under the other at x 0. A sprite no pack
*> has is GS-W 0 and its widget keeps the swatch.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUI-SPRITES-LOAD.
*> USING CLIENT-STATE, mode (0 measure, 1 copy into the UI atlas).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY JSONDOC.
 01 WS-PATHS.
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/widget/button.png".
    05 FILLER PIC X(64) VALUE "assets/minecraft/textures/gui/sprites/container/slot.png".
 01 WS-PATH-TABLE REDEFINES WS-PATHS.
    05 WS-SPRITE-PATH      PIC X(64) OCCURS 2 TIMES.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-META-PATH           PIC X(256).
 01 WS-META-LENGTH         BINARY-LONG.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 1048576.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 4096.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-IW                  BINARY-LONG.
 01 WS-IH                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SCALING             BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               PIC X(32).
 01 WS-VALUE-CAP           BINARY-LONG VALUE 32.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-BORDER              BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MODE.
     IF L-MODE = 0
         MOVE 0 TO GS-TOTAL-H GS-MAX-W
     END-IF
     MOVE 0 TO WS-Y
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE SPACES TO WS-PATH
         MOVE WS-SPRITE-PATH(WS-K) TO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-IMAGE-CAP WS-IW
             WS-IH WS-FOUND
         IF L-MODE = 0
             INITIALIZE GS-ROW(WS-K)
             IF WS-FOUND = 1
                 MOVE WS-IW TO GS-W(WS-K)
                 MOVE WS-IH TO GS-H(WS-K)
                 CALL "GUI-SPRITE-SCALING" USING CLIENT-STATE WS-K WS-PATH WS-PATH-LENGTH
                 ADD WS-IH TO GS-TOTAL-H
                 MOVE FUNCTION MAX(GS-MAX-W, WS-IW) TO GS-MAX-W
             END-IF
         ELSE
             IF GS-W(WS-K) > 0 AND WS-FOUND = 1 AND WS-IW = GS-W(WS-K) AND WS-IH = GS-H(WS-K)
                 SET ADDRESS OF B-ATLAS TO UA-ADDR
                 MOVE 0 TO GS-X(WS-K)
                 COMPUTE GS-Y(WS-K) = UA-SPRITE-Y + WS-Y
                 PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW >= WS-IH
                     COMPUTE WS-BYTES = (GS-Y(WS-K) + WS-ROW) * UA-W * 4 + 1
                     MOVE WS-IMAGE(WS-ROW * WS-IW * 4 + 1:WS-IW * 4) TO B-ATLAS(WS-BYTES:WS-IW * 4)
                 END-PERFORM
                 ADD WS-IH TO WS-Y
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUI-SPRITES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUI-SPRITE-SCALING.
*> USING CLIENT-STATE, sprite row, image path (PIC X(256)), its length: the .mcmeta beside the image sets the
*> row's nine-slice (GS-NINE, GS-LW, GS-LH and the borders); none, or one that is not a nine_slice, leaves it plain.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-META-PATH           PIC X(256).
 01 WS-META-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 4096.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SCALING             BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               PIC X(32).
 01 WS-VALUE-CAP           BINARY-LONG VALUE 32.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-BORDER              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 WS-K                   BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE WS-K L-PATH L-LENGTH.
*>   The .mcmeta beside the image (of the pack that gave the image: the stack's top-most file).
     MOVE 0 TO WS-SCALING
     MOVE SPACES TO WS-TEXT
     MOVE SPACES TO WS-META-PATH
     STRING L-PATH(1:L-LENGTH) ".mcmeta" DELIMITED BY SIZE INTO WS-META-PATH
     COMPUTE WS-META-LENGTH = L-LENGTH + 7
     CALL "PACK-READ" USING CLIENT-STATE WS-META-PATH WS-META-LENGTH WS-TEXT WS-TEXT-CAP WS-TEXT-LENGTH
         WS-FOUND
     IF WS-FOUND = 1
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-TEXT-LENGTH
         IF JD-COUNT > 0
             MOVE "gui" TO WS-KEY
             MOVE 3 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
             IF WS-NODE > 0
                 MOVE "scaling" TO WS-KEY
                 MOVE 7 TO WS-KEY-LENGTH
                 CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-SCALING
             ELSE
                 MOVE 0 TO WS-SCALING
             END-IF
         END-IF
     END-IF

     IF WS-SCALING > 0
         MOVE "type" TO WS-KEY
         MOVE 4 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-SCALING WS-KEY WS-KEY-LENGTH WS-MEMBER
         MOVE SPACES TO WS-VALUE
         MOVE 0 TO WS-VALUE-LENGTH
         IF WS-MEMBER > 0
             CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-VALUE WS-VALUE-CAP WS-VALUE-LENGTH
         END-IF
         IF WS-VALUE-LENGTH = 10 AND WS-VALUE(1:10) = "nine_slice"
             MOVE "width" TO WS-KEY
             MOVE 5 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-SCALING WS-KEY WS-KEY-LENGTH WS-MEMBER
             IF WS-MEMBER > 0
                 MOVE JN-NUM(WS-MEMBER) TO GS-LW(WS-K)
             END-IF
             MOVE "height" TO WS-KEY
             MOVE 6 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-SCALING WS-KEY WS-KEY-LENGTH WS-MEMBER
             IF WS-MEMBER > 0
                 MOVE JN-NUM(WS-MEMBER) TO GS-LH(WS-K)
             END-IF
             MOVE "border" TO WS-KEY
             MOVE 6 TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-SCALING WS-KEY WS-KEY-LENGTH WS-MEMBER
             IF WS-MEMBER > 0 AND GS-LW(WS-K) > 0 AND GS-LH(WS-K) > 0
                 MOVE 1 TO GS-NINE(WS-K)
                 IF JN-TYPE(WS-MEMBER) = JT-NUMBER
                     MOVE JN-NUM(WS-MEMBER) TO WS-BORDER
                     MOVE WS-BORDER TO GS-BL(WS-K) GS-BT(WS-K) GS-BR(WS-K) GS-BB(WS-K)
                 ELSE
                     MOVE WS-MEMBER TO WS-NODE
                     MOVE "left" TO WS-KEY
                     MOVE 4 TO WS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-SIDE
                     IF WS-SIDE > 0
                         MOVE JN-NUM(WS-SIDE) TO GS-BL(WS-K)
                     END-IF
                     MOVE "top" TO WS-KEY
                     MOVE 3 TO WS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-SIDE
                     IF WS-SIDE > 0
                         MOVE JN-NUM(WS-SIDE) TO GS-BT(WS-K)
                     END-IF
                     MOVE "right" TO WS-KEY
                     MOVE 5 TO WS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-SIDE
                     IF WS-SIDE > 0
                         MOVE JN-NUM(WS-SIDE) TO GS-BR(WS-K)
                     END-IF
                     MOVE "bottom" TO WS-KEY
                     MOVE 6 TO WS-KEY-LENGTH
                     CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-SIDE
                     IF WS-SIDE > 0
                         MOVE JN-NUM(WS-SIDE) TO GS-BB(WS-K)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GUI-SPRITE-SCALING.
