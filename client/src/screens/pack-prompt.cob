*> The server pack prompt (US18-6, US18-7; 08 §9.1 steps 3 and 4; 08 §10.8.6 pack_prompt texts):
*> shown when a server pushes a pack and neither an answer for this connection nor the server's
*> PackPolicy decides it. It says whether a pushed pack is required, shows the server's prompt
*> text, and that the answer is kept for the server (a server-list entry); Accept and Decline go
*> to PACK-PROMPT-ANSWER (packs/download.cob). Pushes that arrive while it is open share it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-PROMPT-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
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
 01 WS-I                   BINARY-LONG.
 01 WS-REQUIRED            BINARY-LONG.
 01 WS-PROMPT              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
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
     MOVE 0 TO WS-REQUIRED WS-PROMPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         IF RP-STEP(WS-I) = RPS-PROMPT
             IF RP-REQUIRED(WS-I) = 1
                 MOVE 1 TO WS-REQUIRED
             END-IF
             IF RP-PROMPT-LENGTH(WS-I) > 0 AND WS-PROMPT = 0
                 MOVE WS-I TO WS-PROMPT
             END-IF
         END-IF
     END-PERFORM
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 150
     MOVE 30 TO WS-Y
     MOVE "cobolcraft.screen.pack_prompt.title" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE 50 TO WS-Y
     MOVE "cobolcraft.screen.pack_prompt.optional" TO WS-KEY
     MOVE 38 TO WS-KEY-LENGTH
     IF WS-REQUIRED = 1
         MOVE "cobolcraft.screen.pack_prompt.required" TO WS-KEY
     END-IF
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE 62 TO WS-Y
     IF WS-PROMPT > 0
         MOVE "cobolcraft.screen.pack_prompt.message" TO WS-KEY
         MOVE 37 TO WS-KEY-LENGTH
         MOVE 1 TO LA-COUNT
         MOVE RP-PROMPT(WS-PROMPT) TO LA-TEXT(1)
         MOVE RP-PROMPT-LENGTH(WS-PROMPT) TO LA-LENGTH(1)
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4 WS-TEXT
             WS-LENGTH WS-STATE
         MOVE 74 TO WS-Y
     END-IF
     IF RP-ENTRY-JOINED > 0
         MOVE "cobolcraft.screen.pack_prompt.remembered" TO WS-KEY
         MOVE 40 TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
             WS-KEY-LENGTH
     END-IF
     MOVE WK-BUTTON TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 154
     MOVE 110 TO WS-Y
     MOVE ACT-PACK-ACCEPT TO WS-ACTION
     MOVE "cobolcraft.screen.pack_prompt.accept" TO WS-KEY
     MOVE 36 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 + 4
     MOVE ACT-PACK-DECLINE TO WS-ACTION
     MOVE "cobolcraft.screen.pack_prompt.decline" TO WS-KEY
     MOVE 37 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM PACK-PROMPT-BUILD.
