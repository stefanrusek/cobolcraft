*> The pack confirmation screen (US18-4; 08 §2.3 "an incompatible pack can still be enabled after a
*> confirmation prompt"; 08 §10.8.6 pack_confirm texts): enabling a too old, too new or unknown pack
*> asks first. Enable Anyway enables it (PACK-SELECT-ACTION) and Cancel (or Escape) returns to the
*> pack screen without it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-CONFIRM-BUILD.
*> USING CLIENT-STATE (LP-CONFIRM the pack), GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 150.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-KEYS.
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.pack_confirm.too_old".
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.pack_confirm.too_new".
    05 FILLER PIC X(40) VALUE "cobolcraft.screen.pack_confirm.unknown".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-MESSAGE-KEY      PIC X(40) OCCURS 3 TIMES.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
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
     COMPUTE WS-X = L-GW / 2 - 50
     MOVE 40 TO WS-Y
     MOVE "cobolcraft.screen.pack_confirm.title" TO WS-KEY
     MOVE 36 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 150
     MOVE 70 TO WS-Y
     MOVE WS-MESSAGE-KEY(LP-COMPAT(LP-CONFIRM)) TO WS-KEY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE LP-NAME(LP-CONFIRM) TO LA-TEXT(1)
     MOVE LP-NAME-LENGTH(LP-CONFIRM) TO LA-LENGTH(1)
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT
         WS-LENGTH WS-STATE
     MOVE WK-BUTTON TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 154
     MOVE 110 TO WS-Y
     MOVE ACT-PACK-CONFIRM TO WS-ACTION
     MOVE "cobolcraft.screen.pack_confirm.enable" TO WS-KEY
     MOVE 37 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 + 4
     MOVE ACT-PACKS TO WS-ACTION
     MOVE "cobolcraft.screen.common.cancel" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM PACK-CONFIRM-BUILD.
