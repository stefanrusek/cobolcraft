*> The title screen (data-model §13; 08 §10.8.6): the game's name, Single-player (the world list,
*> US16-1), Multiplayer, Resource Packs (the pack selection screen, US18) and Quit Game; under them,
*> when the generated packs are not ok (CL-PACKS-STATUS, PACKS-STATUS-CHECK), the banner of 22 §9.2
*> (cobolcraft.packs.absent, .incomplete, .stale or .damaged of the built-in language) in label lines
*> of at most 56 characters, broken at spaces.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TITLE-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-LINE                BINARY-LONG.
 01 WS-SPACE               BINARY-LONG.
 01 WS-LINE-TEXT           PIC X(512).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-X = L-GW / 2 - 40
     MOVE 40 TO WS-Y
     MOVE WK-LABEL TO WS-KIND
     MOVE "cobolcraft.screen.title.name" TO WS-KEY
     MOVE 28 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 90 TO WS-Y
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     MOVE "cobolcraft.screen.title.single_player" TO WS-KEY
     MOVE 37 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     MOVE 116 TO WS-Y
     MOVE ACT-MULTIPLAYER TO WS-ACTION
     MOVE "cobolcraft.screen.title.multiplayer" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     MOVE 142 TO WS-Y
     MOVE ACT-PACKS TO WS-ACTION
     MOVE "cobolcraft.screen.title.packs" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     MOVE 168 TO WS-Y
     MOVE ACT-QUIT TO WS-ACTION
     MOVE "cobolcraft.screen.title.quit" TO WS-KEY
     MOVE 28 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     IF CL-PACKS-STATUS NOT = CT-PACKS-OK
         MOVE SPACES TO WS-KEY
         EVALUATE CL-PACKS-STATUS
             WHEN CT-PACKS-ABSENT
                 MOVE "cobolcraft.packs.absent" TO WS-KEY
                 MOVE 23 TO WS-KEY-LENGTH
             WHEN CT-PACKS-INCOMPLETE
                 MOVE "cobolcraft.packs.incomplete" TO WS-KEY
                 MOVE 27 TO WS-KEY-LENGTH
             WHEN CT-PACKS-STALE
                 MOVE "cobolcraft.packs.stale" TO WS-KEY
                 MOVE 22 TO WS-KEY-LENGTH
             WHEN OTHER
                 MOVE "cobolcraft.packs.damaged" TO WS-KEY
                 MOVE 24 TO WS-KEY-LENGTH
         END-EVALUATE
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         MOVE WK-LABEL TO WS-KIND
         MOVE 0 TO WS-ACTION
         MOVE 1 TO WS-START
         MOVE 204 TO WS-Y
         PERFORM UNTIL WS-START > WS-LENGTH
             COMPUTE WS-END = FUNCTION MIN(WS-START + 55, WS-LENGTH)
    *>       Break at the last space within 56 characters, unless the rest fits.
             IF WS-END < WS-LENGTH
                 MOVE WS-END TO WS-SPACE
                 PERFORM UNTIL WS-SPACE <= WS-START OR WS-TEXT(WS-SPACE + 1:1) = SPACE
                     SUBTRACT 1 FROM WS-SPACE
                 END-PERFORM
                 IF WS-SPACE > WS-START
                     MOVE WS-SPACE TO WS-END
                 END-IF
             END-IF
             COMPUTE WS-LINE = WS-END - WS-START + 1
             MOVE SPACES TO WS-LINE-TEXT
             MOVE WS-TEXT(WS-START:WS-LINE) TO WS-LINE-TEXT
             COMPUTE WS-X = L-GW / 2 - WS-LINE * 3
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-Z2 WS-Z3
                 WS-LINE-TEXT WS-LINE WS-ZERO
             ADD 10 TO WS-Y
             COMPUTE WS-START = WS-END + 2
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM TITLE-BUILD.
