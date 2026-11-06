*> The chat screen (US6; client-surface §3 T, §4 chat area; 08 §10.8.6 cobolcraft.screen.chat.hint;
*> docs/protocol/09-cobolcraft-profile.md §1 chat is unsigned, §3.2 Chat 0x09). T on the world screen
*> opens it with an empty line (common.cob); the chat area (hud.cob) shows the 10 most recent messages
*> regardless of age above the input line, which shows the line being typed (its end, when it is
*> longer than 255 bytes) or the hint while it is empty. Typed characters (any keyboard layout)
*> are appended as UTF-8 while the line stays within 256 UTF-16 code units (05c Chat Message);
*> Backspace deletes the last character; the scroll wheel moves back (up) and forward (down) through
*> the history, at most to its oldest message; Enter sends a non-empty line as Chat and closes chat;
*> Escape closes it without sending.
*> Commands (US14; client-surface §3 "/ opens chat with / typed"; 09 §3.3, §5 rule 5): a line that
*> starts with / is a command. CHAT-SUGGEST follows its words through the command tree (Commands):
*> the names of the commands and fixed words that start with the word being typed are suggested;
*> where that word is an argument with ask_server suggestions the line is sent as Command
*> Suggestion (once per line text) and the answers that come back are suggested after the names.
*> The suggestions (at most CL-MAX-SUGGEST) are labels stacked just above the input line, the
*> messages above them. Enter on a command line sends Chat Command with the line without its /.

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
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LABEL               BINARY-LONG VALUE WK-LABEL.
 01 WS-SH                  BINARY-LONG VALUE 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE CS-SHOWN = FUNCTION MIN(CS-COUNT + CS-ANSWERS, CL-MAX-SUGGEST)
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
*>   The suggestions, top down, the last one just above the input line.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CS-SHOWN
         COMPUTE WS-Y = L-GH - 14 - (CS-SHOWN - WS-I + 1) * 9
         MOVE SPACES TO WS-TEXT
         IF WS-I <= CS-COUNT
             MOVE CS-TEXT(WS-I) TO WS-TEXT
             MOVE CS-LENGTH(WS-I) TO WS-LENGTH
         ELSE
             COMPUTE WS-J = WS-I - CS-COUNT
             MOVE CS-A-TEXT(WS-J) TO WS-TEXT
             MOVE CS-A-LENGTH(WS-J) TO WS-LENGTH
         END-IF
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-ACTION WS-ARG WS-X WS-Y WS-W WS-SH
             WS-TEXT WS-LENGTH WS-STATE
     END-PERFORM
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
     ELSE
         CALL "CHAT-SUGGEST" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM CHAT-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-SEND.
*> USING CLIENT-STATE: Chat Command with a line starting with / (without the /), else Chat with
*> the line, stamped with the frame's clock as milliseconds since the
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
 01 WS-COMMAND             PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-TIME = CL-NOW-MS - WS-EPOCH
     CALL "PB-RESET" USING PB-BUFFER
     IF CH-LINE(1:1) = "/"
         MOVE SPACES TO WS-COMMAND
         MOVE CH-LINE(2:) TO WS-COMMAND
         COMPUTE WS-LENGTH = CH-LINE-LENGTH - 1
         CALL "CLP-CHAT-COMMAND" USING PB-BUFFER WS-COMMAND WS-LENGTH
     ELSE
         CALL "CLP-CHAT" USING PB-BUFFER CH-LINE CH-LINE-LENGTH WS-TIME
     END-IF
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CHAT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-SUGGEST.
*> USING CLIENT-STATE: the suggestions for the line. Its words after the / are followed from the
*> tree's root: a word followed by a space goes to the child literal of that name, else to the
*> first argument child (a greedy argument takes the rest of the line: no suggestions); the last
*> word is the one being typed: every literal child whose name starts with it is suggested, and an
*> argument child with ask_server suggestions (flag 0x10) asks the server. A line asked about
*> already is not asked again; a line that needs no answer forgets the last question and answers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1100.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-NODE                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LITERAL             BINARY-LONG.
 01 WS-ARGUMENT            BINARY-LONG.
 01 WS-ASK                 BINARY-LONG.
 01 WS-WORD                PIC X(1024).
 01 WS-WORD-LENGTH         BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO CS-COUNT WS-ASK WS-NODE
     IF CH-LINE-LENGTH > 0 AND CH-LINE(1:1) = "/" AND CM-COUNT > 0
         COMPUTE WS-NODE = CM-ROOT + 1
         MOVE 2 TO WS-START
     END-IF
     PERFORM UNTIL WS-NODE < 1 OR WS-NODE > CM-COUNT
*>       The next word: from WS-START to the next space (WS-END), or to the end of the line.
         MOVE 0 TO WS-END
         PERFORM VARYING WS-I FROM WS-START BY 1 UNTIL WS-I > CH-LINE-LENGTH OR WS-END > 0
             IF CH-LINE(WS-I:1) = SPACE
                 MOVE WS-I TO WS-END
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-WORD
         MOVE 0 TO WS-WORD-LENGTH WS-LITERAL WS-ARGUMENT
         COMPUTE WS-I = CH-LINE-LENGTH + 1
         IF WS-END > 0
             MOVE WS-END TO WS-I
         END-IF
         COMPUTE WS-WORD-LENGTH = WS-I - WS-START
         IF WS-WORD-LENGTH > 0
             MOVE CH-LINE(WS-START:WS-WORD-LENGTH) TO WS-WORD(1:WS-WORD-LENGTH)
         END-IF
*>       The node's children: literals named by (or, for the last word, starting with) the word;
*>       the first argument child.
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > CM-CHILDREN(WS-NODE)
             COMPUTE WS-I = CM-FIRST(WS-NODE) + WS-K - 1
             COMPUTE WS-CHILD = CM-LINK(WS-I) + 1
             MOVE 0 TO WS-TYPE
             IF WS-CHILD >= 1 AND WS-CHILD <= CM-COUNT
                 COMPUTE WS-TYPE = FUNCTION MOD(CM-FLAGS(WS-CHILD), 4)
                 MOVE CM-NAME(WS-CHILD) TO WS-NAME
                 MOVE CM-NAME-LENGTH(WS-CHILD) TO WS-NAME-LENGTH
             END-IF
             MOVE 0 TO WS-MATCH
             EVALUATE TRUE
                 WHEN WS-TYPE = 2 AND WS-ARGUMENT = 0
                     MOVE WS-CHILD TO WS-ARGUMENT
                 WHEN WS-TYPE NOT = 1 OR WS-NAME-LENGTH < WS-WORD-LENGTH OR WS-NAME-LENGTH = 0
                     CONTINUE
                 WHEN WS-END > 0 AND WS-NAME-LENGTH = WS-WORD-LENGTH
                         AND WS-NAME(1:WS-NAME-LENGTH) = WS-WORD(1:WS-NAME-LENGTH)
                     MOVE WS-CHILD TO WS-LITERAL
                 WHEN WS-END > 0
                     CONTINUE
                 WHEN WS-WORD-LENGTH = 0
                     MOVE 1 TO WS-MATCH
                 WHEN WS-NAME(1:WS-WORD-LENGTH) = WS-WORD(1:WS-WORD-LENGTH)
                     MOVE 1 TO WS-MATCH
             END-EVALUATE
             IF WS-MATCH = 1 AND CS-COUNT < CL-MAX-SUGGEST
                 ADD 1 TO CS-COUNT
                 MOVE WS-NAME TO CS-TEXT(CS-COUNT)
                 MOVE WS-NAME-LENGTH TO CS-LENGTH(CS-COUNT)
             END-IF
         END-PERFORM
         EVALUATE TRUE
             WHEN WS-END = 0
*>               The word being typed: an ask_server argument asks the server; done.
                 IF WS-ARGUMENT > 0
                     COMPUTE WS-BIT = CM-FLAGS(WS-ARGUMENT) / 16
                     COMPUTE WS-ASK = FUNCTION MOD(WS-BIT, 2)
                 END-IF
                 MOVE 0 TO WS-NODE
             WHEN WS-LITERAL > 0
                 MOVE WS-LITERAL TO WS-NODE
             WHEN WS-ARGUMENT > 0 AND CM-GREEDY(WS-ARGUMENT) = 0
                 MOVE WS-ARGUMENT TO WS-NODE
             WHEN OTHER
                 MOVE 0 TO WS-NODE
         END-EVALUATE
         COMPUTE WS-START = WS-END + 1
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-ASK = 0
             MOVE 0 TO CS-ASKED-LENGTH CS-ANSWERS
         WHEN CS-ASKED-LENGTH = CH-LINE-LENGTH
                 AND CS-ASKED(1:CH-LINE-LENGTH) = CH-LINE(1:CH-LINE-LENGTH)
             CONTINUE
         WHEN OTHER
             ADD 1 TO CS-TRANSACTION
             MOVE CH-LINE TO CS-ASKED
             MOVE CH-LINE-LENGTH TO CS-ASKED-LENGTH
             MOVE 0 TO CS-ANSWERS
             CALL "PB-RESET" USING PB-BUFFER
             CALL "CLP-COMMAND-SUGGESTION" USING PB-BUFFER CS-TRANSACTION CH-LINE CH-LINE-LENGTH
             CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM CHAT-SUGGEST.
