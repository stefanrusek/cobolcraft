*> The single-player world list (US16-1; client-surface.md §2; 08 §10.8.6 world_list texts): the
*> worlds of saves/ (WORLDS-LIST, read when the screen opens), each entry "<LevelName>
*> (<folder>)  Type: <type>", selectable, at most 12 shown; Play, Create New World, Delete and Back.
*> Play on a standard or debug world with the packs not ok (CL-PACKS-STATUS) opens nothing and the
*> screen shows cobolcraft.world_type.standard.unavailable (world-types.md §8.2).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LIST-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 COPY CONTENT.
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
 01 WS-TYPE-KEY            PIC X(80).
 01 WS-TYPE-KEY-LENGTH     BINARY-LONG.
 01 WS-TYPE-TEXT           PIC X(512).
 01 WS-TYPE-LENGTH         BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(512).
 01 WS-ROW-LENGTH          BINARY-LONG.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WL-COUNT OR WS-I > 12
         MOVE 2 TO LA-COUNT
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
*>       The type: the name of the type's own text (a type the client does not know shows as read).
         MOVE "cobolcraft.world_type.cobolcraft" TO WS-TYPE-KEY
         MOVE 32 TO WS-TYPE-KEY-LENGTH
         IF WL-TYPE(WS-I) = "standard" OR WL-TYPE(WS-I) = "debug"
             MOVE "cobolcraft.world_type.standard" TO WS-TYPE-KEY
             MOVE 30 TO WS-TYPE-KEY-LENGTH
         END-IF
         CALL "LANG-GET" USING CLIENT-STATE WS-TYPE-KEY WS-TYPE-KEY-LENGTH WS-TYPE-TEXT
             WS-TYPE-LENGTH
         MOVE 1 TO LA-COUNT
         MOVE WS-TYPE-TEXT TO LA-TEXT(1)
         MOVE FUNCTION MIN(WS-TYPE-LENGTH, 256) TO LA-LENGTH(1)
         MOVE "cobolcraft.screen.world_list.type" TO WS-TYPE-KEY
         MOVE 33 TO WS-TYPE-KEY-LENGTH
         MOVE WS-TEXT TO WS-ROW-TEXT
         MOVE WS-LENGTH TO WS-ROW-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-TYPE-KEY WS-TYPE-KEY-LENGTH LANG-ARGS
             WS-TYPE-TEXT WS-TYPE-LENGTH
         MOVE SPACES TO WS-TEXT
         STRING WS-ROW-TEXT(1:WS-ROW-LENGTH) "  " WS-TYPE-TEXT(1:WS-TYPE-LENGTH)
             DELIMITED BY SIZE INTO WS-TEXT
         COMPUTE WS-LENGTH = WS-ROW-LENGTH + 2 + WS-TYPE-LENGTH
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
     IF SP-CREATE-REFUSED NOT = 0
         MOVE WK-LABEL TO WS-KIND
         COMPUTE WS-X = L-GW / 2 - 150
         COMPUTE WS-Y = L-GH - 66
         MOVE "cobolcraft.world_type.standard.unavailable" TO WS-KEY
         MOVE 42 TO WS-KEY-LENGTH
         IF SP-CREATE-REFUSED = 2
             MOVE "cobolcraft.world_type.refused" TO WS-KEY
             MOVE 29 TO WS-KEY-LENGTH
         END-IF
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
             WS-KEY-LENGTH
     END-IF
     GOBACK.
 END PROGRAM WORLD-LIST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-PLAY.
*> USING CLIENT-STATE: Play: opens the selected world (SP-OPEN; the mode and name of its
*> level.dat, which the core reads again). Nothing is selected: nothing happens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO SP-CREATE-REFUSED
     IF SM-SELECTED > 0 AND SM-SELECTED <= WL-COUNT
         MOVE SM-SELECTED TO WS-I
         IF (WL-TYPE(WS-I) = "standard" OR WL-TYPE(WS-I) = "debug")
                 AND CL-PACKS-STATUS NOT = CT-PACKS-OK
             MOVE 1 TO SP-CREATE-REFUSED
             GOBACK
         END-IF
         CALL "WORLD-TYPE-ID" USING WL-TYPE(WS-I) SP-CREATE-TYPE
         CALL "SP-OPEN" USING CLIENT-STATE WL-FOLDER(WS-I) WL-FOLDER-LENGTH(WS-I) WL-NAME(WS-I)
             WL-NAME-LENGTH(WS-I) WL-MODE(WS-I)
     END-IF
     GOBACK.
 END PROGRAM WORLD-PLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-OPEN-ARG.
*> USING CLIENT-STATE (CL-WORLD from --world or CC_WORLD): opens that save folder of saves/ the way
*> selecting it in the world list and pressing Play does (WORLD-PLAY: standard-or-cobolcraft detection, the
*> packs check, the core's refusals). CL-WORLD-LENGTH 0: nothing. When no such save exists or the
*> world is refused, the reason goes to standard error and the client stays on the title screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CL-WORLD-LENGTH = 0
         GOBACK
     END-IF
     MOVE CL-WORLD-LENGTH TO WS-LEN
     CALL "WORLDS-LIST" USING CLIENT-STATE
     MOVE 0 TO SM-SELECTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WL-COUNT OR SM-SELECTED > 0
         IF WL-FOLDER-LENGTH(WS-I) = WS-LEN AND WL-FOLDER(WS-I)(1:WS-LEN) = CL-WORLD(1:WS-LEN)
             MOVE WS-I TO SM-SELECTED
         END-IF
     END-PERFORM
     IF SM-SELECTED = 0
         DISPLAY "ERROR world: no save folder " CL-WORLD(1:WS-LEN) " in saves/" UPON STDERR
         GOBACK
     END-IF
     CALL "WORLD-PLAY" USING CLIENT-STATE
     MOVE 0 TO SM-SELECTED
     EVALUATE SP-CREATE-REFUSED
         WHEN 0
             CONTINUE
         WHEN 1
             DISPLAY "ERROR world: " CL-WORLD(1:WS-LEN) " needs the Minecraft content (generated packs not ok)"
                 UPON STDERR
         WHEN OTHER
             DISPLAY "ERROR world: " CL-WORLD(1:WS-LEN) " cannot be opened (refused by the core)" UPON STDERR
     END-EVALUATE
     MOVE 0 TO SP-CREATE-REFUSED
     GOBACK.
 END PROGRAM WORLD-OPEN-ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-TYPE-ID.
*> USING world type text (PIC X(16), level.dat WorldType), type out (BINARY-LONG, CT-TYPE-*): standard,
*> debug or, for any other text, cobolcraft.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(16).
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-TYPE.
     EVALUATE L-TEXT
         WHEN "standard"
             MOVE CT-TYPE-STANDARD TO L-TYPE
         WHEN "debug"
             MOVE CT-TYPE-DEBUG TO L-TYPE
         WHEN OTHER
             MOVE CT-TYPE-COBOLCRAFT TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM WORLD-TYPE-ID.
