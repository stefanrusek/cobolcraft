*> The single-player world list (US16-1; client-surface.md §2; 08 §10.8.6 world_list texts): the
*> worlds of saves/ (WORLDS-LIST, read when the screen opens), each entry "<LevelName>
*> (<folder>)", selectable, at most 12 shown; Play, Create New World, Delete and Back.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LIST-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BUTTONS.
    05 FILLER PIC X(48) VALUE "19cobolcraft.screen.world_list.play".
    05 FILLER PIC X(48) VALUE "20cobolcraft.screen.world_list.create".
    05 FILLER PIC X(48) VALUE "21cobolcraft.screen.world_list.delete".
 01 WS-BUTTON-TABLE REDEFINES WS-BUTTONS.
    05 WS-BUTTON OCCURS 3 TIMES.
       10 WS-B-ACTION      PIC 99.
       10 WS-B-KEY         PIC X(46).
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 50
     MOVE 8 TO WS-Y
     MOVE "cobolcraft.screen.world_list.title" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 150
     IF WL-COUNT = 0
         MOVE 30 TO WS-Y
         MOVE "cobolcraft.screen.world_list.empty" TO WS-KEY
         MOVE 34 TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3
             WS-KEY WS-KEY-LENGTH
     END-IF
     MOVE WK-ENTRY TO WS-KIND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 300 TO WS-W
     MOVE 16 TO WS-H
     MOVE "cobolcraft.screen.world_list.entry" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     MOVE 2 TO LA-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WL-COUNT OR WS-I > 12
         COMPUTE WS-Y = 24 + (WS-I - 1) * 20
         MOVE 0 TO WS-STATE
         IF WS-I = SM-SELECTED
             MOVE 1 TO WS-STATE
         END-IF
         MOVE WL-NAME(WS-I) TO LA-TEXT(1)
         MOVE WL-NAME-LENGTH(WS-I) TO LA-LENGTH(1)
         MOVE WL-FOLDER(WS-I) TO LA-TEXT(2)
         MOVE WL-FOLDER-LENGTH(WS-I) TO LA-LENGTH(2)
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-I WS-X WS-Y WS-W WS-H WS-TEXT
             WS-LENGTH WS-STATE
     END-PERFORM
     MOVE WK-BUTTON TO WS-KIND
     MOVE 98 TO WS-W
     MOVE 20 TO WS-H
     COMPUTE WS-Y = L-GH - 48
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = L-GW / 2 - 151 + (WS-I - 1) * 102
         MOVE WS-B-ACTION(WS-I) TO WS-ACTION
         MOVE WS-B-KEY(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
             WS-KEY-LENGTH
     END-PERFORM
     COMPUTE WS-X = L-GW / 2 - 100
     COMPUTE WS-Y = L-GH - 24
     MOVE 200 TO WS-W
     MOVE ACT-BACK TO WS-ACTION
     MOVE "cobolcraft.screen.common.back" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM WORLD-LIST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-PLAY.
*> USING CLIENT-STATE: Play: opens the selected world (SP-OPEN; the mode and name of its
*> level.dat, which the core reads again). Nothing is selected: nothing happens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SM-SELECTED > 0 AND SM-SELECTED <= WL-COUNT
         MOVE SM-SELECTED TO WS-I
         CALL "SP-OPEN" USING CLIENT-STATE WL-FOLDER(WS-I) WL-FOLDER-LENGTH(WS-I) WL-NAME(WS-I)
             WL-NAME-LENGTH(WS-I) WL-MODE(WS-I)
     END-IF
     GOBACK.
 END PROGRAM WORLD-PLAY.
