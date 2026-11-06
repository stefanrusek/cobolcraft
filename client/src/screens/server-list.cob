*> The server list screen (US2-1, US2-2; data-model §13 server list entry; 08 §10.8.6
*> server_list texts): the entries (selectable, at most 12 shown) with the description and online
*> count of their status, an incompatible-protocol mark or "no answer", the last disconnect message,
*> and Join, Add Server, Edit, Remove and Back. SERVER-LIST-PING asks the entries for their status
*> one at a time over the status connection while the list is shown.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVER-LIST-BUILD.
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-BUTTONS.
    05 FILLER PIC X(48) VALUE "03cobolcraft.screen.server_list.join".
    05 FILLER PIC X(48) VALUE "04cobolcraft.screen.server_list.add".
    05 FILLER PIC X(48) VALUE "05cobolcraft.screen.server_list.edit".
    05 FILLER PIC X(48) VALUE "06cobolcraft.screen.server_list.remove".
 01 WS-BUTTON-TABLE REDEFINES WS-BUTTONS.
    05 WS-BUTTON OCCURS 4 TIMES.
       10 WS-B-ACTION      PIC 99.
       10 WS-B-KEY         PIC X(46).
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 01 WS-Z4                   BINARY-LONG VALUE 0.
 01 WS-Z5                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 20
     MOVE 8 TO WS-Y
     MOVE "cobolcraft.screen.server_list.title" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 150
     IF SL-COUNT = 0
         MOVE 30 TO WS-Y
         MOVE "cobolcraft.screen.server_list.empty" TO WS-KEY
         MOVE 35 TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3
             WS-KEY WS-KEY-LENGTH
     END-IF
     MOVE 300 TO WS-W
     MOVE 10 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-COUNT OR WS-I > 12
         COMPUTE WS-Y = 24 + (WS-I - 1) * 30
         MOVE WK-ENTRY TO WS-KIND
         MOVE ACT-SELECT TO WS-ACTION
         MOVE 0 TO WS-STATE
         IF WS-I = SM-SELECTED
             MOVE 1 TO WS-STATE
         END-IF
         MOVE SL-NAME(WS-I) TO WS-TEXT
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-I WS-X WS-Y WS-W WS-H WS-TEXT
             SL-NAME-LENGTH(WS-I) WS-STATE
         MOVE WK-LABEL TO WS-KIND
         MOVE 0 TO LA-COUNT
         EVALUATE TRUE
             WHEN SL-STATUS(WS-I) = SLS-UNREACHABLE
                 MOVE "cobolcraft.screen.server_list.unreachable" TO WS-KEY
             WHEN SL-STATUS(WS-I) NOT = SLS-ANSWERED
                 MOVE "cobolcraft.screen.server_list.pinging" TO WS-KEY
             WHEN OTHER
                 ADD 10 TO WS-Y
                 MOVE SL-DESC(WS-I) TO WS-TEXT
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-W WS-H
                     WS-TEXT SL-DESC-LENGTH(WS-I) WS-Z3
                 SUBTRACT 10 FROM WS-Y
                 MOVE "cobolcraft.screen.server_list.online" TO WS-KEY
                 MOVE 2 TO LA-COUNT
                 MOVE SL-ONLINE(WS-I) TO WS-EDIT
                 MOVE FUNCTION TRIM(WS-EDIT) TO LA-TEXT(1)
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO LA-LENGTH(1)
                 MOVE SL-MAX(WS-I) TO WS-EDIT
                 MOVE FUNCTION TRIM(WS-EDIT) TO LA-TEXT(2)
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO LA-LENGTH(2)
                 IF SL-INCOMPATIBLE(WS-I) = 1
                     MOVE "cobolcraft.screen.server_list.incompatible" TO WS-KEY
                     MOVE 1 TO LA-COUNT
                     MOVE SL-VERSION(WS-I) TO LA-TEXT(1)
                     MOVE SL-VERSION-LENGTH(WS-I) TO LA-LENGTH(1)
                 END-IF
         END-EVALUATE
         ADD 20 TO WS-Y
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-W WS-H WS-TEXT
             WS-LENGTH WS-Z3
     END-PERFORM
     IF SM-MESSAGE-LENGTH > 0
         MOVE 1 TO LA-COUNT
         MOVE SM-MESSAGE TO LA-TEXT(1)
         MOVE FUNCTION MIN(SM-MESSAGE-LENGTH, 256) TO LA-LENGTH(1)
         MOVE "cobolcraft.screen.server_list.disconnected" TO WS-KEY
         MOVE 42 TO WS-KEY-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         COMPUTE WS-Y = L-GH - 64
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4
             WS-TEXT WS-LENGTH WS-Z5
     END-IF
     MOVE WK-BUTTON TO WS-KIND
     MOVE 74 TO WS-W
     MOVE 20 TO WS-H
     COMPUTE WS-Y = L-GH - 48
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-X = L-GW / 2 - 156 + (WS-I - 1) * 78
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
 END PROGRAM SERVER-LIST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVER-LIST-PING.
*> USING CLIENT-STATE: while the status connection is free, the next entry not yet asked is asked
*> (Intention status, Status Request; the answers fill the entry, protocol-client.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 2.
 01 WS-NEXT                BINARY-LONG VALUE 2.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 01 WS-Z4                   BINARY-LONG VALUE 0.
 01 WS-Z5                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CN-PHASE(CONN-PING) = PH-NONE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-COUNT
             IF SL-STATUS(WS-I) = SLS-NONE AND CN-PHASE(CONN-PING) = PH-NONE
                 MOVE SLS-PINGING TO SL-STATUS(WS-I)
                 MOVE WS-I TO CN-ENTRY(CONN-PING)
                 CALL "NET-OPEN" USING CLIENT-STATE WS-CONN SL-ADDR(WS-I) SL-ADDR-LENGTH(WS-I)
                     WS-NEXT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SERVER-LIST-PING.
