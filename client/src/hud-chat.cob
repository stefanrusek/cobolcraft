*> The chat of the HUD as the vanilla client keeps and draws it (docs/protocol/57-client-closures-5 section 2, task T47400): the history of 100 lines with the GUI tick each
*> arrived and its tag (HX-CM, beside CH-MESSAGE of hud.cob), the delay queue, word wrapping, the fade and the window of the closed chat. The receive side is hud-chat-packets.cob.
*>   CHAT-TR: a translated text with up to three arguments (the language file, else the English text of the documents);
*>   CHAT-OPT, CHAT-OPT-FLAG: a float and a boolean option; CHAT-WRAP: the lines of a text at a width in pixels (a continuation line starts with a space);
*>   CHAT-TYPE-DEFAULT, CHAT-TYPE-ENTRY, CHAT-DECORATE: the chat types (section 2.3) and the decoration of a line;
*>   CHAT-LINE-ADD (the delay queue and the visibility of the options), CHAT-RECORD-ADD (the history), CHAT-TICK (the GUI tick and the queue), CHAT-HUD-ADD (the window).
*> Not built: a chat scale other than 1 (text cannot be scaled by a fraction), the pending-line marker of 2.7 (the document gives no position), the rewriting of a partly
*> filtered message (it does not say which bit of the mask marks a masked character), the open chat window (57-5 open question 8: only the HUD window is specified).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-TR.
*> USING CLIENT-STATE, key (PIC X(80)), key length, argument 1 (PIC X(256)), its length, argument 2, its length, argument 3, its length, text out (PIC X(512)), length out:
*> the text of the key of the language files with %s taken by the arguments in order; a key no pack knows gives the English text of the documents (57-5 sections 2 and 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLARGS.
 01 WS-TEMPLATE            PIC X(512).
 01 WS-TEMPLATE-LENGTH     BINARY-LONG.
 01 WS-FALLBACK-DATA.
    05 FILLER PIC X(80) VALUE "chat.type.text".
    05 FILLER PIC X(64) VALUE "<%s> %s".
    05 FILLER PIC X(80) VALUE "chat.type.emote".
    05 FILLER PIC X(64) VALUE "* %s %s".
    05 FILLER PIC X(80) VALUE "chat.type.announcement".
    05 FILLER PIC X(64) VALUE "[%s] %s".
    05 FILLER PIC X(80) VALUE "commands.message.display.incoming".
    05 FILLER PIC X(64) VALUE "%s whispers to you: %s".
    05 FILLER PIC X(80) VALUE "commands.message.display.outgoing".
    05 FILLER PIC X(64) VALUE "You whisper to %s: %s".
    05 FILLER PIC X(80) VALUE "chat.type.team.text".
    05 FILLER PIC X(64) VALUE "%s <%s> %s".
    05 FILLER PIC X(80) VALUE "chat.type.team.sent".
    05 FILLER PIC X(64) VALUE "-> %s <%s> %s".
    05 FILLER PIC X(80) VALUE "chat.validation_error".
    05 FILLER PIC X(64) VALUE "Chat validation error".
    05 FILLER PIC X(80) VALUE "chat.deleted_marker".
    05 FILLER PIC X(64) VALUE "This chat message has been deleted by the server.".
    05 FILLER PIC X(80) VALUE "chat.queue".
    05 FILLER PIC X(64) VALUE "[+%s pending line(s)]".
    05 FILLER PIC X(80) VALUE "record.nowPlaying".
    05 FILLER PIC X(64) VALUE "Now Playing: %s".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.bad_chat_index".
    05 FILLER PIC X(64) VALUE "Detected a missed or reordered chat message from the server".
    05 FILLER PIC X(80) VALUE "disconnect.packetError".
    05 FILLER PIC X(64) VALUE "Network Protocol Error".
 01 WS-FALLBACK REDEFINES WS-FALLBACK-DATA.
    05 WS-FB OCCURS 13 TIMES.
       10 WS-FB-KEY        PIC X(80).
       10 WS-FB-TEXT       PIC X(64).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-A1                   PIC X(256).
 01 L-N1                   BINARY-LONG.
 01 L-A2                   PIC X(256).
 01 L-N2                   BINARY-LONG.
 01 L-A3                   PIC X(256).
 01 L-N3                   BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH L-A1 L-N1 L-A2 L-N2 L-A3 L-N3 L-TEXT L-LENGTH.
     MOVE 3 TO LA-COUNT
     MOVE L-A1 TO LA-TEXT(1)
     MOVE L-N1 TO LA-LENGTH(1)
     MOVE L-A2 TO LA-TEXT(2)
     MOVE L-N2 TO LA-LENGTH(2)
     MOVE L-A3 TO LA-TEXT(3)
     MOVE L-N3 TO LA-LENGTH(3)
     CALL "LANG-GET" USING CLIENT-STATE L-KEY L-KEY-LENGTH WS-TEMPLATE WS-TEMPLATE-LENGTH
     IF L-KEY-LENGTH > 0 AND WS-TEMPLATE-LENGTH = L-KEY-LENGTH AND WS-TEMPLATE(1:WS-TEMPLATE-LENGTH) = L-KEY(1:L-KEY-LENGTH)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
             IF WS-FB-KEY(WS-I) = L-KEY
                 MOVE SPACES TO WS-TEMPLATE
                 MOVE WS-FB-TEXT(WS-I) TO WS-TEMPLATE
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FB-TEXT(WS-I) TRAILING)) TO WS-TEMPLATE-LENGTH
             END-IF
         END-PERFORM
     END-IF
     CALL "LANG-FORMAT-TEXT" USING WS-TEMPLATE WS-TEMPLATE-LENGTH LANG-ARGS L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM CHAT-TR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-OPT.
*> USING CLIENT-STATE, option name (PIC X(40)), default (FLOAT-LONG), value out (FLOAT-LONG): the numeric option as stored, else the default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(40).
 01 L-DEFAULT              FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-DEFAULT L-VALUE.
     MOVE L-DEFAULT TO L-VALUE
     CALL "OPTIONS-GET" USING CLIENT-STATE L-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-LENGTH > 0
         COMPUTE L-VALUE = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH))
     END-IF
     GOBACK.
 END PROGRAM CHAT-OPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-OPT-FLAG.
*> USING CLIENT-STATE, option name (PIC X(40)), default (0 or 1), value out (BINARY-LONG 1 for true): a boolean option as stored, else the default.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(40).
 01 L-DEFAULT              BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-DEFAULT L-VALUE.
     MOVE L-DEFAULT TO L-VALUE
     CALL "OPTIONS-GET" USING CLIENT-STATE L-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-LENGTH = 4 AND WS-VALUE(1:4) = "true"
         MOVE 1 TO L-VALUE
     END-IF
     IF WS-FOUND = 1 AND WS-LENGTH = 5 AND WS-VALUE(1:5) = "false"
         MOVE 0 TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM CHAT-OPT-FLAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-WRAP.
*> USING CLIENT-STATE, text (PIC X(256), UTF-8), length, width in pixels, LINES out, count out: the lines of the text (57-5 section 2.7). A line is cut at the last space
*> of the line (a space that itself passes the width is the cut) when the next glyph would pass the width (the space is dropped), else before that glyph; every line after the first begins with one space (its width
*> counts), so L-LN-PREFIX is 1 for it and the line's bytes are text(start : length). An empty text is one empty line. At most 32 lines.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-P0                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LAST-SPACE          BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADVANCE             BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-SPACE-W             BINARY-LONG.
 01 WS-PREFIX              BINARY-LONG.
 01 WS-CUT                 BINARY-LONG.
 01 WS-SPACE-CP            BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-LINES.
    05 L-LN OCCURS 32 TIMES.
       10 L-LN-START       BINARY-LONG.
       10 L-LN-LENGTH      BINARY-LONG.
       10 L-LN-PREFIX      BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-WIDTH L-LINES L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "FONT-GLYPH" USING CLIENT-STATE WS-SPACE-CP WS-GX WS-GY WS-GW WS-GH WS-SPACE-W
     MOVE 1 TO WS-POS WS-START
     MOVE 0 TO WS-W WS-PREFIX WS-LAST-SPACE
     PERFORM UNTIL WS-POS > L-LENGTH OR L-COUNT >= 31
         MOVE WS-POS TO WS-P0
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADVANCE
         IF WS-CP = 32
             MOVE WS-P0 TO WS-LAST-SPACE
         END-IF
         IF WS-W + WS-ADVANCE > L-WIDTH AND WS-P0 > WS-START
*>           The line is full: break at the last space of the line (dropped), else before this glyph.
             ADD 1 TO L-COUNT
             MOVE WS-START TO L-LN-START(L-COUNT)
             MOVE WS-PREFIX TO L-LN-PREFIX(L-COUNT)
             IF WS-LAST-SPACE > 0
                 COMPUTE L-LN-LENGTH(L-COUNT) = WS-LAST-SPACE - WS-START
                 COMPUTE WS-START = WS-LAST-SPACE + 1
             ELSE
                 COMPUTE L-LN-LENGTH(L-COUNT) = WS-P0 - WS-START
                 MOVE WS-P0 TO WS-START
             END-IF
             MOVE WS-START TO WS-POS
             MOVE WS-SPACE-W TO WS-W
             MOVE 1 TO WS-PREFIX
             MOVE 0 TO WS-LAST-SPACE
         ELSE
             ADD WS-ADVANCE TO WS-W
         END-IF
     END-PERFORM
     ADD 1 TO L-COUNT
     MOVE WS-START TO L-LN-START(L-COUNT)
     MOVE WS-PREFIX TO L-LN-PREFIX(L-COUNT)
     COMPUTE WS-CUT = L-LENGTH - WS-START + 1
     MOVE WS-CUT TO L-LN-LENGTH(L-COUNT)
     GOBACK.
 END PROGRAM CHAT-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-TYPE-DEFAULT.
*> USING chat type name (PIC X(40), with namespace), key out (PIC X(64)), key length out, parameter count out, parameters 1 to 3 out (0 sender, 1 target, 2 content), found out:
*> the `chat` decoration of the seven vanilla chat types (57-5 section 2.3); the entry of a registry that came without data takes it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPES-DATA.
    05 FILLER PIC X(40) VALUE "minecraft:chat".
    05 FILLER PIC X(40) VALUE "chat.type.text".
    05 FILLER PIC X(40) VALUE "minecraft:emote_command".
    05 FILLER PIC X(40) VALUE "chat.type.emote".
    05 FILLER PIC X(40) VALUE "minecraft:say_command".
    05 FILLER PIC X(40) VALUE "chat.type.announcement".
    05 FILLER PIC X(40) VALUE "minecraft:msg_command_incoming".
    05 FILLER PIC X(40) VALUE "commands.message.display.incoming".
    05 FILLER PIC X(40) VALUE "minecraft:msg_command_outgoing".
    05 FILLER PIC X(40) VALUE "commands.message.display.outgoing".
    05 FILLER PIC X(40) VALUE "minecraft:team_msg_command_incoming".
    05 FILLER PIC X(40) VALUE "chat.type.team.text".
    05 FILLER PIC X(40) VALUE "minecraft:team_msg_command_outgoing".
    05 FILLER PIC X(40) VALUE "chat.type.team.sent".
 01 WS-TYPES REDEFINES WS-TYPES-DATA.
    05 WS-T OCCURS 7 TIMES.
       10 WS-T-NAME        PIC X(40).
       10 WS-T-KEY         PIC X(40).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-KEY                  PIC X(64).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-PCOUNT               BINARY-LONG.
 01 L-P1                   BINARY-LONG.
 01 L-P2                   BINARY-LONG.
 01 L-P3                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-KEY L-KEY-LENGTH L-PCOUNT L-P1 L-P2 L-P3 L-FOUND.
     MOVE 0 TO L-FOUND L-KEY-LENGTH L-PCOUNT L-P1 L-P2 L-P3
     MOVE SPACES TO L-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF WS-T-NAME(WS-I) = L-NAME
*>           The parameter lists of the table of 2.3: sender and content; target and content for the outgoing whisper; target, sender and content for the team types.
             MOVE 1 TO L-FOUND
             MOVE WS-T-KEY(WS-I) TO L-KEY
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-T-KEY(WS-I) TRAILING)) TO L-KEY-LENGTH
             EVALUATE WS-T-NAME(WS-I)
                 WHEN "minecraft:msg_command_outgoing"
                     MOVE 2 TO L-PCOUNT
                     MOVE 1 TO L-P1
                     MOVE 2 TO L-P2
                 WHEN "minecraft:team_msg_command_incoming"
                 WHEN "minecraft:team_msg_command_outgoing"
                     MOVE 3 TO L-PCOUNT
                     MOVE 1 TO L-P1
                     MOVE 0 TO L-P2
                     MOVE 2 TO L-P3
                 WHEN OTHER
                     MOVE 2 TO L-PCOUNT
                     MOVE 0 TO L-P1
                     MOVE 2 TO L-P2
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CHAT-TYPE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-TYPE-ENTRY.
*> USING CLIENT-STATE, index (1 to 15, the entry's position in the registry + 1; row 16 of HX-CT is the inline decoration of the last packet), name (PIC X(64)), present (the entry came with data), PB-BUFFER (at the data when present): keeps
*> the entry in HX-CT: the decoration of the vanilla type of that name, then the `chat` member of the data when present (translation_key and the list parameters of
*> strings); the rest of the data (style, narration) is skipped. A present entry's NBT is consumed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WN2                    PIC X(64).
 01 WL2                    BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PCOUNT              BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NAME40              PIC X(40).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-PRESENT              BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE L-INDEX L-NAME L-PRESENT PB-BUFFER.
     IF L-INDEX >= 1 AND L-INDEX <= 15
         IF L-INDEX > HX-CT-COUNT
             MOVE L-INDEX TO HX-CT-COUNT
         END-IF
         MOVE L-NAME(1:40) TO WS-NAME40
         MOVE WS-NAME40 TO HX-CT-NAME(L-INDEX)
         CALL "CHAT-TYPE-DEFAULT" USING WS-NAME40 WS-KEY WS-KEY-LENGTH WS-PCOUNT WS-P1 WS-P2 WS-P3 WS-FOUND
         MOVE WS-KEY TO HX-CT-KEY(L-INDEX)
         MOVE WS-KEY-LENGTH TO HX-CT-KEY-LEN(L-INDEX)
         MOVE WS-PCOUNT TO HX-CT-PCOUNT(L-INDEX)
         MOVE WS-P1 TO HX-CT-PARAM(L-INDEX, 1)
         MOVE WS-P2 TO HX-CT-PARAM(L-INDEX, 2)
         MOVE WS-P3 TO HX-CT-PARAM(L-INDEX, 3)
     END-IF
     IF L-PRESENT = 1
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
         IF WS-TYPE = 10
             PERFORM UNTIL WS-TYPE = 0 OR PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAP WL
                 EVALUATE TRUE
                     WHEN WS-TYPE = 0
                         CONTINUE
                     WHEN WN = "chat" AND WS-TYPE = 10 AND L-INDEX >= 1 AND L-INDEX <= 15
                         MOVE 1 TO WS-TYPE2
                         PERFORM UNTIL WS-TYPE2 = 0 OR PB-ERROR = 1
                             MOVE SPACES TO WN2
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                             EVALUATE TRUE
                                 WHEN WS-TYPE2 = 0
                                     CONTINUE
                                 WHEN WN2 = "translation_key" AND WS-TYPE2 = 8
                                     MOVE SPACES TO WS-TEXT
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                                     MOVE WS-TEXT TO HX-CT-KEY(L-INDEX)
                                     MOVE WS-TEXT-LENGTH TO HX-CT-KEY-LEN(L-INDEX)
                                 WHEN WN2 = "parameters" AND WS-TYPE2 = 9
                                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT WS-COUNT
                                     MOVE 0 TO HX-CT-PCOUNT(L-INDEX)
                                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                                         MOVE SPACES TO WS-TEXT
                                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-TEXT-LENGTH
                                         IF WS-I <= 3
                                             ADD 1 TO HX-CT-PCOUNT(L-INDEX)
                                             EVALUATE WS-TEXT
                                                 WHEN "target" MOVE 1 TO HX-CT-PARAM(L-INDEX, WS-I)
                                                 WHEN "content" MOVE 2 TO HX-CT-PARAM(L-INDEX, WS-I)
                                                 WHEN OTHER MOVE 0 TO HX-CT-PARAM(L-INDEX, WS-I)
                                             END-EVALUATE
                                         END-IF
                                     END-PERFORM
                                 WHEN OTHER
                                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                             END-EVALUATE
                         END-PERFORM
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-EVALUATE
             END-PERFORM
         ELSE
             IF WS-TYPE NOT = 0
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CHAT-TYPE-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-DECORATE.
*> USING CLIENT-STATE, chat type index (the registry id, from 0), sender (PIC X(256)), its length, target, its length, content, its length, text out (PIC X(512)), length out:
*> ChatTypeDecoration.decorate (57-5 section 2.3): the translation of the type's key with the entries of its parameter list in order (sender, target or content; a target that
*> is absent is empty). An index the registry does not have gives the content alone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   PIC X(80).
 01 WS-T1                  PIC X(256).
 01 WS-N1                  BINARY-LONG.
 01 WS-T2                  PIC X(256).
 01 WS-N2                  BINARY-LONG.
 01 WS-T3                  PIC X(256).
 01 WS-N3                  BINARY-LONG.
 01 WS-PIECE               PIC X(256).
 01 WS-PIECE-LEN           BINARY-LONG.
 01 WS-Z                   PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-SENDER               PIC X(256).
 01 L-SENDER-LENGTH        BINARY-LONG.
 01 L-TARGET               PIC X(256).
 01 L-TARGET-LENGTH        BINARY-LONG.
 01 L-CONTENT              PIC X(256).
 01 L-CONTENT-LENGTH       BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INDEX L-SENDER L-SENDER-LENGTH L-TARGET L-TARGET-LENGTH L-CONTENT L-CONTENT-LENGTH
         L-TEXT L-LENGTH.
     COMPUTE WS-ROW = L-INDEX + 1
     IF L-INDEX < 0 OR WS-ROW > 16 OR HX-CT-KEY-LEN(WS-ROW) = 0
         MOVE SPACES TO L-TEXT
         MOVE L-CONTENT TO L-TEXT(1:256)
         MOVE L-CONTENT-LENGTH TO L-LENGTH
         GOBACK
     END-IF
     MOVE SPACES TO WS-T1 WS-T2 WS-T3
     MOVE 0 TO WS-N1 WS-N2 WS-N3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-PIECE
         MOVE 0 TO WS-PIECE-LEN
         IF WS-I <= HX-CT-PCOUNT(WS-ROW)
             EVALUATE HX-CT-PARAM(WS-ROW, WS-I)
                 WHEN 0
                     MOVE L-SENDER TO WS-PIECE
                     MOVE L-SENDER-LENGTH TO WS-PIECE-LEN
                 WHEN 1
                     MOVE L-TARGET TO WS-PIECE
                     MOVE L-TARGET-LENGTH TO WS-PIECE-LEN
                 WHEN OTHER
                     MOVE L-CONTENT TO WS-PIECE
                     MOVE L-CONTENT-LENGTH TO WS-PIECE-LEN
             END-EVALUATE
         END-IF
         EVALUATE WS-I
             WHEN 1
                 MOVE WS-PIECE TO WS-T1
                 MOVE WS-PIECE-LEN TO WS-N1
             WHEN 2
                 MOVE WS-PIECE TO WS-T2
                 MOVE WS-PIECE-LEN TO WS-N2
             WHEN OTHER
                 MOVE WS-PIECE TO WS-T3
                 MOVE WS-PIECE-LEN TO WS-N3
         END-EVALUATE
     END-PERFORM
     MOVE SPACES TO WS-K
     MOVE HX-CT-KEY(WS-ROW) TO WS-K
     CALL "CHAT-TR" USING CLIENT-STATE WS-K HX-CT-KEY-LEN(WS-ROW) WS-T1 WS-N1 WS-T2 WS-N2
         WS-T3 WS-N3 L-TEXT L-LENGTH
     GOBACK.
 END PROGRAM CHAT-DECORATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-RECORD-ADD.
*> USING CLIENT-STATE, text (PIC X(512)), length, tag, source: the line is in the history at once (the newest last; the oldest is dropped past 100), stamped with the GUI tick
*> of now. Tags: 0 none, 1 not secure, 2 modified, 3 error, 4 system, 5 server message; sources 1 system client, 2 player, 3 system server.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-TAG L-SOURCE.
     IF CH-COUNT = CL-MAX-CHAT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= CL-MAX-CHAT
             MOVE CH-MESSAGE(WS-I + 1) TO CH-MESSAGE(WS-I)
             MOVE HX-CM(WS-I + 1) TO HX-CM(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM CH-COUNT
     END-IF
     ADD 1 TO CH-COUNT
     MOVE CL-NOW-MS TO CH-TIME(CH-COUNT)
     MOVE L-TEXT(1:256) TO CH-TEXT(CH-COUNT)
     MOVE FUNCTION MIN(L-LENGTH, 256) TO CH-LENGTH(CH-COUNT)
     MOVE HX-GUI-TICKS TO HX-CM-TICK(CH-COUNT)
     MOVE L-TAG TO HX-CM-TAG(CH-COUNT)
     MOVE L-SOURCE TO HX-CM-SRC(CH-COUNT)
     GOBACK.
 END PROGRAM CHAT-RECORD-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-VISIBLE.
*> USING CLIENT-STATE, source, flag out: 1 when the visible-message filter of the chat visibility option (57-5 section 2.8) lets the source in: a system client line always, a
*> player line when the option is Shown (0), a system server line unless it is Hidden (2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40) VALUE "chatVisibility".
 01 WS-DEFAULT             FLOAT-LONG VALUE 0.
 01 WS-LEVEL               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SOURCE               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SOURCE L-FLAG.
     CALL "CHAT-OPT" USING CLIENT-STATE WS-NAME WS-DEFAULT WS-LEVEL
     MOVE 1 TO L-FLAG
     IF L-SOURCE = 2 AND WS-LEVEL NOT = 0
         MOVE 0 TO L-FLAG
     END-IF
     IF L-SOURCE = 3 AND WS-LEVEL >= 2
         MOVE 0 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM CHAT-VISIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-LINE-ADD.
*> USING CLIENT-STATE, text (PIC X(512)), length, tag, source: a line for the chat (57-5 section 2.9). A player line (source 2) goes through the delay queue: with the Chat
*> Delay option at 0 and an empty queue it is added at once, else it is queued (32 at most; a full queue drops the new line) and CHAT-TICK adds it when the delay has passed.
*> A line the visibility option keeps out is dropped. Every shown line sets previousMessageTime to now (HX-CHAT-PREV-MS, the GUI tick clock of 50 ms).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40) VALUE "chatDelay".
 01 WS-DEFAULT             FLOAT-LONG VALUE 0.
 01 WS-DELAY               FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-TAG L-SOURCE.
     CALL "CHAT-OPT" USING CLIENT-STATE WS-NAME WS-DEFAULT WS-DELAY
     IF L-SOURCE = 2 AND (WS-DELAY > 0 OR HX-DQ-COUNT > 0)
         IF HX-DQ-COUNT < 32
             ADD 1 TO HX-DQ-COUNT
             MOVE L-TAG TO HX-DQ-TAG(HX-DQ-COUNT)
             MOVE L-SOURCE TO HX-DQ-SRC(HX-DQ-COUNT)
             MOVE FUNCTION MIN(L-LENGTH, 256) TO HX-DQ-LENGTH(HX-DQ-COUNT)
             MOVE L-TEXT(1:256) TO HX-DQ-TEXT(HX-DQ-COUNT)
         END-IF
         GOBACK
     END-IF
     CALL "CHAT-VISIBLE" USING CLIENT-STATE L-SOURCE WS-FLAG
     IF WS-FLAG = 1
         CALL "CHAT-RECORD-ADD" USING CLIENT-STATE L-TEXT L-LENGTH L-TAG L-SOURCE
         COMPUTE HX-CHAT-PREV-MS = HX-GUI-TICKS * 50
     END-IF
     GOBACK.
 END PROGRAM CHAT-LINE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-TICK.
*> USING CLIENT-STATE: one unpaused client tick (57-5 sections 1.3 and 2.9): the GUI tick counter counts up, and the delay queue runs: with a delay above 0 the next
*> queued line is added once the delay has passed since the last shown line (a dropped line does not use the delay, the next is tried), with the delay at 0 the whole
*> queue is added at once and previousMessageTime is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40) VALUE "chatDelay".
 01 WS-DEFAULT             FLOAT-LONG VALUE 0.
 01 WS-DELAY               FLOAT-LONG.
 01 WS-DELAY-MS            BINARY-DOUBLE.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     ADD 1 TO HX-GUI-TICKS
     COMPUTE WS-NOW = HX-GUI-TICKS * 50
     CALL "CHAT-OPT" USING CLIENT-STATE WS-NAME WS-DEFAULT WS-DELAY
     COMPUTE WS-DELAY-MS = WS-DELAY * 1000
     IF WS-DELAY-MS = 0 AND HX-DQ-COUNT > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HX-DQ-COUNT
             MOVE SPACES TO WS-TEXT
             MOVE HX-DQ-TEXT(WS-I) TO WS-TEXT
             MOVE HX-DQ-LENGTH(WS-I) TO WS-LENGTH
             CALL "CHAT-VISIBLE" USING CLIENT-STATE HX-DQ-SRC(WS-I) WS-FLAG
             IF WS-FLAG = 1
                 CALL "CHAT-RECORD-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH HX-DQ-TAG(WS-I) HX-DQ-SRC(WS-I)
             END-IF
         END-PERFORM
         MOVE 0 TO HX-DQ-COUNT HX-CHAT-PREV-MS
     END-IF
     MOVE 0 TO WS-SHOWN
     PERFORM UNTIL HX-DQ-COUNT = 0 OR WS-SHOWN = 1 OR WS-NOW < HX-CHAT-PREV-MS + WS-DELAY-MS
         MOVE SPACES TO WS-TEXT
         MOVE HX-DQ-TEXT(1) TO WS-TEXT
         MOVE HX-DQ-LENGTH(1) TO WS-LENGTH
         CALL "CHAT-VISIBLE" USING CLIENT-STATE HX-DQ-SRC(1) WS-FLAG
         IF WS-FLAG = 1
             CALL "CHAT-RECORD-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH HX-DQ-TAG(1) HX-DQ-SRC(1)
             MOVE 1 TO WS-SHOWN
             MOVE WS-NOW TO HX-CHAT-PREV-MS
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= HX-DQ-COUNT
             MOVE HX-DQ(WS-I + 1) TO HX-DQ(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM HX-DQ-COUNT
     END-PERFORM
     GOBACK.
 END PROGRAM CHAT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-HUD-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: the widgets of the closed chat window (57-5 section 2.7). The lines of the history are wrapped at the chat width
*> floor(width option x 280 + 40) (320), newest first, at most 100 lines; the window shows the newest floor(floor(unfocused height x 160 + 20) / entryHeight) of them (10),
*> the bottom line ending at GUI height - 40. Per line, in order: the black background from x 0 to 332 (alpha floor(lineAlpha x background opacity x 255)), the 2 pixel wide
*> indicator of the tag at the left edge (alpha floor(lineAlpha x text opacity x 255)) and the text at x 4, y bottom - 8 with the shadow, alpha floor(lineAlpha x text opacity
*> x 255) where text opacity = chat opacity x 0.9 + 0.1 and lineAlpha = (clamp(10 x (1 - age / 200), 0, 1)) ^ 2 of the age in GUI ticks; a line of alpha 1.0E-5 or less is
*> skipped. The tag icon of a modified message is only drawn in the open window.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N-OPACITY           PIC X(40) VALUE "chatOpacity".
 01 WS-N-BACK              PIC X(40) VALUE "textBackgroundOpacity".
 01 WS-N-SPACING           PIC X(40) VALUE "chatLineSpacing".
 01 WS-N-HEIGHT            PIC X(40) VALUE "chatHeightUnfocused".
 01 WS-N-WIDTH             PIC X(40) VALUE "chatWidth".
 01 WS-D-ONE               FLOAT-LONG VALUE 1.
 01 WS-D-HALF              FLOAT-LONG VALUE 0.5.
 01 WS-D-ZERO              FLOAT-LONG VALUE 0.
 01 WS-D-HEIGHT            FLOAT-LONG VALUE 0.4375.
 01 WS-OPACITY             FLOAT-LONG.
 01 WS-BACK                FLOAT-LONG.
 01 WS-SPACING             FLOAT-LONG.
 01 WS-HEIGHT-OPT          FLOAT-LONG.
 01 WS-WIDTH-OPT           FLOAT-LONG.
 01 WS-TEXT-OPACITY        FLOAT-LONG.
 01 WS-WIDTH-PX            BINARY-LONG.
 01 WS-ENTRY-H             BINARY-LONG.
 01 WS-TEXT-OFFSET         BINARY-LONG.
 01 WS-PER-PAGE            BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-LINES-OUT.
    05 WS-LO OCCURS 100 TIMES.
       10 WS-LO-MSG        BINARY-LONG.
       10 WS-LO-START      BINARY-LONG.
       10 WS-LO-LENGTH     BINARY-LONG.
       10 WS-LO-PREFIX     BINARY-LONG.
 01 WS-LO-COUNT            BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-WRAP.
    05 WS-LN OCCURS 32 TIMES.
       10 WS-LN-START      BINARY-LONG.
       10 WS-LN-LENGTH     BINARY-LONG.
       10 WS-LN-PREFIX     BINARY-LONG.
 01 WS-WRAP-COUNT          BINARY-LONG.
 01 WS-MSG-TEXT            PIC X(256).
 01 WS-M                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-T32                 FLOAT-SHORT.
 01 WS-ALPHA               FLOAT-LONG.
 01 WS-A-BACK              BINARY-LONG.
 01 WS-A-TEXT              BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-BLACK               BINARY-LONG VALUE SW-BLACK.
 01 WS-WHITE               BINARY-LONG VALUE SW-WHITE.
 01 WS-OVERLAY             BINARY-LONG VALUE WK-OVERLAY.
 01 WS-LABEL               BINARY-LONG VALUE WK-LABEL.
 01 WS-LINE                PIC X(512).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG-RGB             BINARY-LONG.
 01 WS-EMPTY               PIC X(512) VALUE SPACES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     CALL "CHAT-OPT" USING CLIENT-STATE WS-N-OPACITY WS-D-ONE WS-OPACITY
     CALL "CHAT-OPT" USING CLIENT-STATE WS-N-BACK WS-D-HALF WS-BACK
     CALL "CHAT-OPT" USING CLIENT-STATE WS-N-SPACING WS-D-ZERO WS-SPACING
     CALL "CHAT-OPT" USING CLIENT-STATE WS-N-HEIGHT WS-D-HEIGHT WS-HEIGHT-OPT
     CALL "CHAT-OPT" USING CLIENT-STATE WS-N-WIDTH WS-D-ONE WS-WIDTH-OPT
     COMPUTE WS-TEXT-OPACITY = WS-OPACITY * 0.9 + 0.1
     COMPUTE WS-WIDTH-PX = FUNCTION INTEGER(WS-WIDTH-OPT * 280 + 40)
     COMPUTE WS-ENTRY-H = FUNCTION INTEGER(9 * (WS-SPACING + 1))
     COMPUTE WS-TEXT-OFFSET = FUNCTION INTEGER(8 * (WS-SPACING + 1) - 4 * WS-SPACING + 0.5)
     COMPUTE WS-PER-PAGE = FUNCTION INTEGER(FUNCTION INTEGER(WS-HEIGHT-OPT * 160 + 20) / WS-ENTRY-H)
     COMPUTE WS-BOTTOM = L-GH - 40
*>   The display lines, newest first, up to 100.
     MOVE 0 TO WS-LO-COUNT
     PERFORM VARYING WS-M FROM CH-COUNT BY -1 UNTIL WS-M < 1 OR WS-LO-COUNT >= 100
         MOVE CH-TEXT(WS-M) TO WS-MSG-TEXT
         MOVE CH-LENGTH(WS-M) TO WS-LENGTH
         CALL "CHAT-WRAP" USING CLIENT-STATE WS-MSG-TEXT WS-LENGTH WS-WIDTH-PX WS-WRAP WS-WRAP-COUNT
         PERFORM VARYING WS-J FROM WS-WRAP-COUNT BY -1 UNTIL WS-J < 1 OR WS-LO-COUNT >= 100
             ADD 1 TO WS-LO-COUNT
             MOVE WS-M TO WS-LO-MSG(WS-LO-COUNT)
             MOVE WS-LN-START(WS-J) TO WS-LO-START(WS-LO-COUNT)
             MOVE WS-LN-LENGTH(WS-J) TO WS-LO-LENGTH(WS-LO-COUNT)
             MOVE WS-LN-PREFIX(WS-J) TO WS-LO-PREFIX(WS-LO-COUNT)
         END-PERFORM
     END-PERFORM
*>   The widgets go oldest first (the order the chat was read in); the lines are placed from the bottom, i = 0 the newest.
     COMPUTE WS-LIMIT = FUNCTION MIN(WS-PER-PAGE, WS-LO-COUNT) - 1
     PERFORM VARYING WS-I FROM WS-LIMIT BY -1 UNTIL WS-I < 0
         MOVE WS-LO-MSG(WS-I + 1) TO WS-M
         COMPUTE WS-AGE = HX-GUI-TICKS - HX-CM-TICK(WS-M)
         COMPUTE WS-T = 10 * (1 - WS-AGE / 200)
         IF WS-T < 0
             MOVE 0 TO WS-T
         END-IF
         IF WS-T > 1
             MOVE 1 TO WS-T
         END-IF
*>       The age arithmetic is in double and narrowed to float (57-5 section 2.7): 10 x (1 - 180 / 200) must come out as exactly 1.0.
         MOVE WS-T TO WS-T32
         COMPUTE WS-ALPHA = WS-T32 * WS-T32
         IF WS-ALPHA > 0.00001
             COMPUTE WS-A-BACK = FUNCTION INTEGER(WS-ALPHA * WS-BACK * 255)
             COMPUTE WS-A-TEXT = FUNCTION INTEGER(WS-ALPHA * WS-TEXT-OPACITY * 255)
             COMPUTE WS-B = WS-BOTTOM - WS-I * WS-ENTRY-H
             MOVE 0 TO WS-X
             COMPUTE WS-Y = WS-B - WS-ENTRY-H
             MOVE 332 TO WS-W
             MOVE WS-ENTRY-H TO WS-H
*>           The background of the line (an alpha of 0 draws nothing: the widget keeps its alpha byte 0 and an overlay without it would be opaque, so it is left out).
             IF WS-A-BACK > 0
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-OVERLAY WS-ACTION WS-BLACK WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z3 WS-STATE
                 CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A-BACK
             END-IF
             IF HX-CM-TAG(WS-M) > 0 AND WS-A-TEXT > 0
                 EVALUATE HX-CM-TAG(WS-M)
                     WHEN 2 MOVE 6316128 TO WS-TAG-RGB
                     WHEN 3 MOVE 16733525 TO WS-TAG-RGB
                     WHEN OTHER MOVE 13684944 TO WS-TAG-RGB
                 END-EVALUATE
                 MOVE 2 TO WS-W
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-OVERLAY WS-ACTION WS-WHITE WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z3 WS-STATE
                 CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-TAG-RGB
                 CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A-TEXT
             END-IF
             IF WS-A-TEXT > 0
                 MOVE SPACES TO WS-LINE
                 MOVE 0 TO WS-LINE-LENGTH
                 IF WS-LO-PREFIX(WS-I + 1) = 1
                     MOVE " " TO WS-LINE(1:1)
                     MOVE 1 TO WS-LINE-LENGTH
                 END-IF
                 MOVE CH-TEXT(WS-M) TO WS-MSG-TEXT
                 MOVE WS-LO-START(WS-I + 1) TO WS-J
                 MOVE WS-LO-LENGTH(WS-I + 1) TO WS-LENGTH
                 IF WS-LENGTH > 0
                     MOVE WS-MSG-TEXT(WS-J:WS-LENGTH) TO WS-LINE(WS-LINE-LENGTH + 1:WS-LENGTH)
                     ADD WS-LENGTH TO WS-LINE-LENGTH
                 END-IF
                 MOVE 4 TO WS-X
                 COMPUTE WS-Y = WS-B - WS-TEXT-OFFSET
                 COMPUTE WS-W = L-GW - 4
                 MOVE 9 TO WS-H
                 CALL "WIDGET-ADD" USING CLIENT-STATE WS-LABEL WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-H WS-LINE WS-LINE-LENGTH WS-STATE
                 CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A-TEXT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CHAT-HUD-ADD.
