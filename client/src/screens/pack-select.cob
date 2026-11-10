*> The pack selection screen (US18-1, US18-2, US18-4, US18-5; 08 §2.3, §3.1; 08 §10.8.6 packs texts):
*> the local packs (LOCAL-PACKS-SCAN when the screen opens), the selected ones first, top first,
*> above the built-in pack, then the available ones. Each pack shows its name (a selectable entry),
*> its icon, its description and its compatibility, or what makes it unusable; at most 8 packs are
*> shown. Enable puts the selected usable pack on top (an incompatible one after the confirmation
*> screen, pack-confirm.cob), Disable takes it out, Move Up and Move Down move it; Done (or Escape)
*> saves options.dat, reloads the packs (PACKS-RELOAD) and returns to the title screen. The pack
*> errors of the last reload are listed at the bottom.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SELECT-BUILD.
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
 01 WS-E                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-BUTTONS.
    05 FILLER PIC X(48) VALUE "32cobolcraft.screen.packs.enable".
    05 FILLER PIC X(48) VALUE "33cobolcraft.screen.packs.disable".
    05 FILLER PIC X(48) VALUE "34cobolcraft.screen.packs.move_up".
    05 FILLER PIC X(48) VALUE "35cobolcraft.screen.packs.move_down".
    05 FILLER PIC X(48) VALUE "39cobolcraft.screen.common.done".
 01 WS-BUTTON-TABLE REDEFINES WS-BUTTONS.
    05 WS-BUTTON OCCURS 5 TIMES.
       10 WS-B-ACTION      PIC 99.
       10 WS-B-KEY         PIC X(46).
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 40
     MOVE 4 TO WS-Y
     MOVE "cobolcraft.screen.packs.title" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE 8 TO WS-X
     MOVE 16 TO WS-Y
     MOVE "cobolcraft.screen.packs.selected" TO WS-KEY
     MOVE 32 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE 26 TO WS-Y
     MOVE 0 TO WS-SHOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OP-COUNT
         CALL "LOCAL-PACK-FIND" USING CLIENT-STATE OP-ID(WS-I) OP-ID-LENGTH(WS-I) WS-E
         IF WS-E > 0 AND WS-SHOWN < 8
             CALL "PACK-SELECT-ROW" USING CLIENT-STATE WS-E WS-Y
             ADD 1 TO WS-SHOWN
             ADD 20 TO WS-Y
         END-IF
     END-PERFORM
     MOVE WK-LABEL TO WS-KIND
     MOVE 28 TO WS-X
     MOVE "cobolcraft.screen.packs.builtin" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     ADD 12 TO WS-Y
     MOVE 8 TO WS-X
     MOVE "cobolcraft.screen.packs.available" TO WS-KEY
     MOVE 33 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     ADD 10 TO WS-Y
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > LP-COUNT
         CALL "PACK-OP-INDEX" USING CLIENT-STATE WS-E WS-AT
         IF WS-AT = 0 AND WS-SHOWN < 8
             CALL "PACK-SELECT-ROW" USING CLIENT-STATE WS-E WS-Y
             ADD 1 TO WS-SHOWN
             ADD 20 TO WS-Y
         END-IF
     END-PERFORM
     MOVE WK-BUTTON TO WS-KIND
     MOVE 80 TO WS-W
     MOVE 20 TO WS-H
     COMPUTE WS-Y = L-GH - 24
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE WS-X = L-GW / 2 - 208 + (WS-I - 1) * 84
         MOVE WS-B-ACTION(WS-I) TO WS-ACTION
         MOVE WS-B-KEY(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
             WS-KEY-LENGTH
     END-PERFORM
*>   Open Pack Folder (US4) above the row of buttons; a line when its opener could not start.
     MOVE 120 TO WS-W
     COMPUTE WS-X = L-GW / 2 - 60
     COMPUTE WS-Y = L-GH - 46
     MOVE ACT-OPEN-PACK-FOLDER TO WS-ACTION
     MOVE "cobolcraft.screen.packs.open_folder" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     IF CL-OPEN-FAILED = 1
         MOVE WK-LABEL TO WS-KIND
         MOVE "cobolcraft.screen.packs.open_failed" TO WS-KEY
         MOVE 35 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         MOVE 1 TO LA-COUNT
         MOVE CL-OPENER TO LA-TEXT(1)
         MOVE CL-OPENER-LENGTH TO LA-LENGTH(1)
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         MOVE 8 TO WS-X
         COMPUTE WS-Y = L-GH - 56
         MOVE 0 TO WS-STATE
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT
             WS-LENGTH WS-STATE
     END-IF
     MOVE WK-LABEL TO WS-KIND
     MOVE 8 TO WS-X
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-ERROR-COUNT
         COMPUTE WS-Y = L-GH - 24 - WS-I * 10
         MOVE PK-ERROR-TEXT(WS-I) TO WS-TEXT
         MOVE PK-ERROR-LENGTH(WS-I) TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT
             WS-LENGTH WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-SELECT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SELECT-ROW.
*> USING CLIENT-STATE, local pack entry, GUI y: the pack's entry (its name), icon, and its
*> description and compatibility, or its problem.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG VALUE 16.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-COMPAT-KEYS.
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.packs.compatible".
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.packs.too_old".
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.packs.too_new".
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.packs.unknown".
 01 WS-COMPAT-TABLE REDEFINES WS-COMPAT-KEYS.
    05 WS-COMPAT-KEY       PIC X(40) OCCURS 4 TIMES.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTRY                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTRY L-Y.
     MOVE WK-ENTRY TO WS-KIND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 28 TO WS-X
     MOVE 120 TO WS-W
     MOVE 16 TO WS-H
     MOVE 0 TO WS-STATE
     IF L-ENTRY = SM-SELECTED
         MOVE 1 TO WS-STATE
     END-IF
     MOVE LP-NAME(L-ENTRY) TO WS-TEXT
     MOVE LP-NAME-LENGTH(L-ENTRY) TO WS-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION L-ENTRY WS-X L-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-STATE
     IF LP-ICON(L-ENTRY) > 0
         MOVE WK-ICON TO WS-KIND
         MOVE 8 TO WS-X
         MOVE 0 TO WS-LENGTH WS-STATE
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 LP-ICON(L-ENTRY) WS-X L-Y WS-H WS-H2
             WS-TEXT WS-LENGTH WS-STATE
     END-IF
     MOVE WK-LABEL TO WS-KIND
     MOVE 152 TO WS-X
     MOVE 0 TO WS-STATE
     IF LP-VALID(L-ENTRY) = 0
         MOVE LP-PROBLEM(L-ENTRY) TO WS-TEXT
         MOVE LP-PROBLEM-LENGTH(L-ENTRY) TO WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X L-Y WS-Z3 WS-Z4 WS-TEXT
             WS-LENGTH WS-STATE
         GOBACK
     END-IF
     MOVE LP-DESC(L-ENTRY) TO WS-TEXT
     MOVE LP-DESC-LENGTH(L-ENTRY) TO WS-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X L-Y WS-Z3 WS-Z4 WS-TEXT
         WS-LENGTH WS-STATE
     COMPUTE WS-Y = L-Y + 9
     MOVE WS-COMPAT-KEY(LP-COMPAT(L-ENTRY) + 1) TO WS-KEY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z5 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM PACK-SELECT-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-OP-INDEX.
*> USING CLIENT-STATE, local pack entry, position out: the entry's position in OP-ENABLED (1 =
*> top), 0 when it is not enabled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTRY                BINARY-LONG.
 01 L-AT                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTRY L-AT.
     MOVE 0 TO L-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OP-COUNT OR L-AT > 0
         IF OP-ID-LENGTH(WS-I) = LP-ID-LENGTH(L-ENTRY) AND OP-ID(WS-I) = LP-ID(L-ENTRY)
             MOVE WS-I TO L-AT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-OP-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SELECT-ACTION.
*> USING CLIENT-STATE, action (ACT-PACK-ENABLE, -DISABLE, -UP, -DOWN, -CONFIRM, ACT-PACKS-DONE):
*> what the pack screen's and the confirmation screen's buttons do (nothing without a selected
*> pack that can be enabled, disabled or moved).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-E                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-SWAP.
    05 WS-SWAP-ID          PIC X(80).
    05 WS-SWAP-LENGTH      BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION.
     MOVE SM-SELECTED TO WS-E
     IF L-ACTION = ACT-PACK-CONFIRM
         MOVE LP-CONFIRM TO WS-E
     END-IF
     MOVE 0 TO WS-AT WS-OTHER
     IF WS-E > 0
         CALL "PACK-OP-INDEX" USING CLIENT-STATE WS-E WS-AT
     END-IF
     EVALUATE TRUE
         WHEN L-ACTION = ACT-PACKS-DONE
             CALL "OPTIONS-SAVE" USING CLIENT-STATE
             CALL "PACKS-RELOAD" USING CLIENT-STATE
             MOVE SCR-TITLE TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         WHEN WS-E = 0
             CONTINUE
         WHEN L-ACTION = ACT-PACK-ENABLE AND WS-AT = 0 AND LP-VALID(WS-E) = 1
                 AND LP-COMPAT(WS-E) NOT = 0
             MOVE WS-E TO LP-CONFIRM
             MOVE SCR-PACK-CONFIRM TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         WHEN (L-ACTION = ACT-PACK-ENABLE OR L-ACTION = ACT-PACK-CONFIRM) AND WS-AT = 0
                 AND LP-VALID(WS-E) = 1 AND OP-COUNT < CL-MAX-LOCAL-PACKS
             PERFORM VARYING WS-I FROM OP-COUNT BY -1 UNTIL WS-I < 1
                 MOVE OP-ENABLED(WS-I) TO OP-ENABLED(WS-I + 1)
             END-PERFORM
             ADD 1 TO OP-COUNT
             MOVE LP-ID(WS-E) TO OP-ID(1)
             MOVE LP-ID-LENGTH(WS-E) TO OP-ID-LENGTH(1)
             IF L-ACTION = ACT-PACK-CONFIRM
                 MOVE SCR-PACKS TO WS-SCREEN
                 CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
             END-IF
         WHEN L-ACTION = ACT-PACK-DISABLE AND WS-AT > 0
             PERFORM VARYING WS-I FROM WS-AT BY 1 UNTIL WS-I >= OP-COUNT
                 MOVE OP-ENABLED(WS-I + 1) TO OP-ENABLED(WS-I)
             END-PERFORM
             SUBTRACT 1 FROM OP-COUNT
         WHEN L-ACTION = ACT-PACK-UP AND WS-AT > 1
             COMPUTE WS-OTHER = WS-AT - 1
         WHEN L-ACTION = ACT-PACK-DOWN AND WS-AT > 0 AND WS-AT < OP-COUNT
             COMPUTE WS-OTHER = WS-AT + 1
     END-EVALUATE
     IF WS-OTHER > 0
         MOVE OP-ENABLED(WS-AT) TO WS-SWAP
         MOVE OP-ENABLED(WS-OTHER) TO OP-ENABLED(WS-AT)
         MOVE WS-SWAP TO OP-ENABLED(WS-OTHER)
     END-IF
     GOBACK.
 END PROGRAM PACK-SELECT-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FOLDER-OPEN.
*> USING CLIENT-STATE: Open Pack Folder (US4): resourcepacks/ of the game directory is created when it is
*> missing, the opener of CL-OPENER is started with it as its only argument (cc_open_path; CC-NOTFOUND when
*> it cannot start sets CL-OPEN-FAILED, which the pack screen shows), a run line names the opener, and the
*> local packs are listed again so a pack copied in shows without a restart.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-COMMAND             PIC X(1200).
 01 WS-OPENER              PIC X(300).
 01 WS-FOLDER              PIC X(1100).
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE LOW-VALUES TO WS-FOLDER WS-OPENER WS-COMMAND
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks" DELIMITED BY SIZE INTO WS-FOLDER
     STRING "mkdir -p '" CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks'" X"00"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     STRING CL-OPENER(1:CL-OPENER-LENGTH) DELIMITED BY SIZE INTO WS-OPENER
     CALL STATIC "cc_open_path" USING BY REFERENCE WS-OPENER BY REFERENCE WS-FOLDER
         RETURNING WS-RC
     MOVE 0 TO CL-OPEN-FAILED
     IF WS-RC NOT = 0
         MOVE 1 TO CL-OPEN-FAILED
     END-IF
     DISPLAY "RUN " CL-OPENER(1:CL-OPENER-LENGTH) " " CL-GAME-DIR(1:CL-GAME-DIR-LENGTH)
         "/resourcepacks" UPON SYSERR
     CALL "LOCAL-PACKS-SCAN" USING CLIENT-STATE
     GOBACK.
 END PROGRAM PACK-FOLDER-OPEN.
