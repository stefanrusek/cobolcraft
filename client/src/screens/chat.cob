*> The chat screen (US6; client-surface §3 T, §4 chat area; 08 §10.8.6 cobolcraft.screen.chat.hint;
*> docs/protocol/09-cobolcraft-profile.md §1 chat is unsigned, §3.2 Chat 0x09). T on the world screen
*> opens it with an empty line (common.cob); the chat area (hud.cob) shows the 10 most recent messages
*> regardless of age above the input line, which shows the line being typed (its end, when it is
*> longer than 255 bytes) or the hint while it is empty. Typed characters (any keyboard layout)
*> are appended as UTF-8 while the line stays within 256 UTF-16 code units (05c Chat Message);
*> Backspace deletes the last character; the scroll wheel moves back (up) and forward (down) through
*> the history, at most to its oldest message; Enter sends a non-empty line as Chat and closes chat;
*> Escape closes it without sending.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-OPEN                BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG VALUE WK-FIELD.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 2.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG VALUE 12.
 01 WS-STATE               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.chat.hint".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 27.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     CALL "CHAT-AREA-ADD" USING CLIENT-STATE L-GW L-GH WS-OPEN
     COMPUTE WS-Y = L-GH - 14
     COMPUTE WS-W = L-GW - 4
     MOVE 0 TO WS-STATE
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     IF CH-LINE-LENGTH > 0
*>       The end of the line: at most 255 bytes (a widget text holds 256, the caret takes one),
*>       starting on a character.
         MOVE 1 TO WS-STATE
         COMPUTE WS-START = FUNCTION MAX(1, CH-LINE-LENGTH - 254)
         COMPUTE WS-B = FUNCTION ORD(CH-LINE(WS-START:1)) - 1
         PERFORM UNTIL WS-B < 128 OR WS-B >= 192
             ADD 1 TO WS-START
             COMPUTE WS-B = FUNCTION ORD(CH-LINE(WS-START:1)) - 1
         END-PERFORM
         COMPUTE WS-LENGTH = CH-LINE-LENGTH - WS-START + 1
         MOVE SPACES TO WS-TEXT
         MOVE CH-LINE(WS-START:WS-LENGTH) TO WS-TEXT(1:WS-LENGTH)
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-STATE
     GOBACK.
 END PROGRAM CHAT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-INPUT.
*> USING CLIENT-STATE: the frame's typed characters, Backspace, the scroll wheel and Enter.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-UNITS               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-COUNT               BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
*>   The line's length in UTF-16 code units: one per character, two for a 4-byte one.
     MOVE 0 TO WS-UNITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CH-LINE-LENGTH
         COMPUTE WS-B = FUNCTION ORD(CH-LINE(WS-I:1)) - 1
         EVALUATE TRUE
             WHEN WS-B >= 240
                 ADD 2 TO WS-UNITS
             WHEN WS-B < 128 OR WS-B >= 192
                 ADD 1 TO WS-UNITS
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
         CALL "UTF8-ENCODE" USING IN-TEXT(WS-I) WS-BYTES WS-COUNT
         MOVE 1 TO WS-ADD
         IF WS-COUNT = 4
             MOVE 2 TO WS-ADD
         END-IF
         IF WS-UNITS + WS-ADD <= CL-CHAT-UNITS
             MOVE WS-BYTES(1:WS-COUNT) TO CH-LINE(CH-LINE-LENGTH + 1:WS-COUNT)
             ADD WS-COUNT TO CH-LINE-LENGTH
             ADD WS-ADD TO WS-UNITS
         END-IF
     END-PERFORM
     IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1
         CALL "TEXT-DROP-LAST" USING CH-LINE CH-LINE-LENGTH
     END-IF
*>   The wheel: up (positive) goes back to earlier messages, at most to the oldest.
     COMPUTE WS-STEPS ROUNDED = IN-SCROLL-Y
     COMPUTE CH-SCROLL = FUNCTION MIN(FUNCTION MAX(CH-SCROLL + WS-STEPS, 0),
         FUNCTION MAX(CH-COUNT - CL-CHAT-SHOWN, 0))
     IF IN-KEY-PRESSED(CC-KEY-ENTER + 1) = 1
         IF CH-LINE-LENGTH > 0
             CALL "CHAT-SEND" USING CLIENT-STATE
         END-IF
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM CHAT-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-SEND.
*> USING CLIENT-STATE: Chat with the line, stamped with the frame's clock as milliseconds since the
*> Unix epoch (CL-CLOCK counts from day 1 of INTEGER-OF-DATE; 1970-01-01 is day 134775, so the
*> offset is 134775 x 86400000 ms; local time, which the server does not use, 09 §3.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1100.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-EPOCH               BINARY-DOUBLE VALUE 11644560000000.
 01 WS-TIME                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-TIME = CL-NOW-MS - WS-EPOCH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-CHAT" USING PB-BUFFER CH-LINE CH-LINE-LENGTH WS-TIME
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CHAT-SEND.
