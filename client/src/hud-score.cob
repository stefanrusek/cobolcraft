*> The scoreboard of the client (docs/protocol/57-client-closures-5 section 5, task T47430): the state HX-SO (objectives), HX-SS (scores), HX-SLOT (the objective of each display
*> slot), HX-TM and HX-TP (teams and their members), the five packets and the sidebar. SCORE-OBJECTIVE-READ is Set Objective (05b 0x6C = 108), SCORE-DISPLAY-READ Set Display
*> Objective (0x64 = 100), SCORE-SET-READ Set Score (0x70 = 112), SCORE-RESET-READ Reset Score (0x50 = 80), SCORE-TEAM-READ Set Player Team (0x6F = 111); a packet the vanilla
*> handler throws on ends the connection ("Network Protocol Error"): an objective added twice, a player left from a team he is not in. SCORE-SIDEBAR-ADD builds the sidebar
*> (5.4). Not built: the name tags (the client draws none, so the below-name text and the name tag rules of 5.3 have no consumer) and the tab list (the client has none, so
*> the score columns and hearts of 5.6 have no consumer).
*> Two readings of the wire forms the documents leave open: the Color of TeamParameters (05b "Optional IdEnum", a Boolean and a VarInt) and the Style of a styled number
*> format (a compound of which only `color` is read).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-COLOUR-RGB.
*> USING team colour ordinal (0 to 15), RGB out (BINARY-LONG): TeamColor.rgb of 43 section 7 (the chat text colours): black 000000, dark_blue 0000AA, dark_green 00AA00, dark_aqua
*> 00AAAA, dark_red AA0000, dark_purple AA00AA, gold FFAA00, gray AAAAAA, dark_gray 555555, blue 5555FF, green 55FF55, aqua 55FFFF, red FF5555, light_purple FF55FF, yellow FFFF55,
*> white FFFFFF; -1 outside 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER PIC 9(8) VALUE 00000000.
    05 FILLER PIC 9(8) VALUE 00000170.
    05 FILLER PIC 9(8) VALUE 00043520.
    05 FILLER PIC 9(8) VALUE 00043690.
    05 FILLER PIC 9(8) VALUE 11141120.
    05 FILLER PIC 9(8) VALUE 11141290.
    05 FILLER PIC 9(8) VALUE 16755200.
    05 FILLER PIC 9(8) VALUE 11184810.
    05 FILLER PIC 9(8) VALUE 05592405.
    05 FILLER PIC 9(8) VALUE 05592575.
    05 FILLER PIC 9(8) VALUE 05635925.
    05 FILLER PIC 9(8) VALUE 05636095.
    05 FILLER PIC 9(8) VALUE 16733525.
    05 FILLER PIC 9(8) VALUE 16733695.
    05 FILLER PIC 9(8) VALUE 16777045.
    05 FILLER PIC 9(8) VALUE 16777215.
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-RGB              PIC 9(8) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-COLOUR               BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COLOUR L-RGB.
     MOVE -1 TO L-RGB
     IF L-COLOUR >= 0 AND L-COLOUR <= 15
         MOVE WS-RGB(L-COLOUR + 1) TO L-RGB
     END-IF
     GOBACK.
 END PROGRAM SCORE-COLOUR-RGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-STYLE-COLOUR.
*> USING PB-BUFFER, RGB out (-1 none): a Style (a network NBT compound) read; only `color` is kept: a String that is a team colour name or "#RRGGBB".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(14) VALUE "black".
    05 FILLER PIC X(14) VALUE "dark_blue".
    05 FILLER PIC X(14) VALUE "dark_green".
    05 FILLER PIC X(14) VALUE "dark_aqua".
    05 FILLER PIC X(14) VALUE "dark_red".
    05 FILLER PIC X(14) VALUE "dark_purple".
    05 FILLER PIC X(14) VALUE "gold".
    05 FILLER PIC X(14) VALUE "gray".
    05 FILLER PIC X(14) VALUE "dark_gray".
    05 FILLER PIC X(14) VALUE "blue".
    05 FILLER PIC X(14) VALUE "green".
    05 FILLER PIC X(14) VALUE "aqua".
    05 FILLER PIC X(14) VALUE "red".
    05 FILLER PIC X(14) VALUE "light_purple".
    05 FILLER PIC X(14) VALUE "yellow".
    05 FILLER PIC X(14) VALUE "white".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(14) OCCURS 16 TIMES.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-RGB.
     MOVE -1 TO L-RGB
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     IF WS-TYPE NOT = 10
         IF WS-TYPE NOT = 0
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
         GOBACK
     END-IF
     PERFORM UNTIL WS-TYPE = 0 OR PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAP WL
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 CONTINUE
             WHEN WN = "color" AND WS-TYPE = 8
                 MOVE SPACES TO WS-TEXT
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP WS-LENGTH
                 IF WS-TEXT(1:1) = "#" AND WS-LENGTH = 7
                     MOVE 0 TO WS-VALUE
                     MOVE 1 TO WS-OK
                     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 7
                         MOVE 99 TO WS-DIGIT
                         IF WS-TEXT(WS-K:1) >= "0" AND WS-TEXT(WS-K:1) <= "9"
                             COMPUTE WS-DIGIT = FUNCTION ORD(WS-TEXT(WS-K:1)) - FUNCTION ORD("0")
                         END-IF
                         IF WS-TEXT(WS-K:1) >= "a" AND WS-TEXT(WS-K:1) <= "f"
                             COMPUTE WS-DIGIT = FUNCTION ORD(WS-TEXT(WS-K:1)) - FUNCTION ORD("a") + 10
                         END-IF
                         IF WS-TEXT(WS-K:1) >= "A" AND WS-TEXT(WS-K:1) <= "F"
                             COMPUTE WS-DIGIT = FUNCTION ORD(WS-TEXT(WS-K:1)) - FUNCTION ORD("A") + 10
                         END-IF
                         IF WS-DIGIT = 99
                             MOVE 0 TO WS-OK
                         ELSE
                             COMPUTE WS-VALUE = WS-VALUE * 16 + WS-DIGIT
                         END-IF
                     END-PERFORM
                     IF WS-OK = 1
                         MOVE WS-VALUE TO L-RGB
                     END-IF
                 ELSE
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                         IF WS-TEXT = WS-NAME(WS-I)
                             COMPUTE WS-K = WS-I - 1
                             CALL "SCORE-COLOUR-RGB" USING WS-K L-RGB
                         END-IF
                     END-PERFORM
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-STYLE-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-FORMAT-READ.
*> USING CLIENT-STATE, PB-BUFFER, kind out (-1 none, 0 blank, 1 styled, 2 fixed), colour out (the styled colour, -1 none), text out (PIC X(64), the fixed text), its length: an Optional
*> NumberFormat (05b): a Boolean, then the type VarInt and its body: blank nothing, styled a Style, fixed a text component.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-KIND L-COLOUR L-TEXT L-LENGTH.
     MOVE -1 TO L-KIND L-COLOUR
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-TYPE
         EVALUATE WS-TYPE
             WHEN 0
                 MOVE 0 TO L-KIND
             WHEN 1
                 MOVE 1 TO L-KIND
                 CALL "SCORE-STYLE-COLOUR" USING PB-BUFFER L-COLOUR
             WHEN 2
                 MOVE 2 TO L-KIND
                 CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
                 IF PB-ERROR = 0
                     CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
                     MOVE WS-TEXT(1:64) TO L-TEXT
                     MOVE FUNCTION MIN(WS-LENGTH, 64) TO L-LENGTH
                 END-IF
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM SCORE-FORMAT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-FAIL.
*> USING CLIENT-STATE: the connection ends with "Network Protocol Error" (disconnect.packetError), as a handler that throws does (57-5 section 1.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(80) VALUE "disconnect.packetError".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 22.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-EMPTY2              PIC X(256) VALUE SPACES.
 01 WS-EMPTY3              PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-MSG                 PIC X(512).
 01 WS-MSG-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "CHAT-TR" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO WS-EMPTY2 WS-ZERO2 WS-EMPTY3 WS-ZERO3 WS-MSG WS-MSG-LENGTH
     CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-MSG WS-MSG-LENGTH
     GOBACK.
 END PROGRAM SCORE-FAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-OBJECTIVE-FIND.
*> USING CLIENT-STATE, name (PIC X(64)), name length, row out (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR L-ROW > 0
         IF HX-SO-USED(WS-I) = 1 AND HX-SO-NAME-LEN(WS-I) = L-LENGTH AND HX-SO-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-OBJECTIVE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-OBJECTIVE-READ.
*> USING CLIENT-STATE, PB-BUFFER: Set Objective (57-5 section 5.2): the name, the method Byte (0 add, 1 remove, 2 change), and for 0 and 2 the display name, the render type VarInt and
*> the optional number format. Add of a name that exists ends the connection; remove clears every display slot that showed the objective and deletes its scores; an unknown
*> name is ignored by remove and change; change replaces the render type, the display name and the number format (an absent one clears it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-BIG                 PIC X(512).
 01 WS-METHOD              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RENDER              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-FTEXT               PIC X(64).
 01 WS-FLENGTH             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     MOVE SPACES TO WS-NAME
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-NAME WS-CAP WS-NAME-LENGTH
     CALL "PB-GET-BYTE" USING PB-BUFFER WS-METHOD
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "SCORE-OBJECTIVE-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-ROW
     IF WS-METHOD = 0 OR WS-METHOD = 2
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-RENDER
         CALL "SCORE-FORMAT-READ" USING CLIENT-STATE PB-BUFFER WS-KIND WS-COLOUR WS-FTEXT WS-FLENGTH
         IF PB-ERROR = 1
             GOBACK
         END-IF
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
     END-IF
     EVALUATE WS-METHOD
         WHEN 0
             IF WS-ROW > 0
                 CALL "SCORE-FAIL" USING CLIENT-STATE
                 GOBACK
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR WS-ROW > 0
                 IF HX-SO-USED(WS-I) = 0
                     MOVE WS-I TO WS-ROW
                 END-IF
             END-PERFORM
             IF WS-ROW > 0
                 INITIALIZE HX-SO(WS-ROW)
                 MOVE 1 TO HX-SO-USED(WS-ROW)
                 MOVE WS-NAME TO HX-SO-NAME(WS-ROW)
                 MOVE WS-NAME-LENGTH TO HX-SO-NAME-LEN(WS-ROW)
                 MOVE WS-TEXT(1:128) TO HX-SO-DISPLAY(WS-ROW)
                 MOVE FUNCTION MIN(WS-LENGTH, 128) TO HX-SO-DISPLAY-LEN(WS-ROW)
                 MOVE WS-RENDER TO HX-SO-RENDER(WS-ROW)
                 MOVE WS-KIND TO HX-SO-FMT(WS-ROW)
                 MOVE WS-COLOUR TO HX-SO-FMT-RGB(WS-ROW)
                 MOVE WS-FTEXT TO HX-SO-FMT-TEXT(WS-ROW)
                 MOVE WS-FLENGTH TO HX-SO-FMT-LEN(WS-ROW)
             END-IF
         WHEN 1
             IF WS-ROW > 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
                     IF HX-SLOT(WS-I) = WS-ROW
                         MOVE 0 TO HX-SLOT(WS-I)
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
                     IF HX-SS-USED(WS-I) = 1 AND HX-SS-OBJ(WS-I) = WS-ROW
                         MOVE 0 TO HX-SS-USED(WS-I)
                     END-IF
                 END-PERFORM
                 MOVE 0 TO HX-SO-USED(WS-ROW)
             END-IF
         WHEN 2
             IF WS-ROW > 0
                 MOVE WS-TEXT(1:128) TO HX-SO-DISPLAY(WS-ROW)
                 MOVE FUNCTION MIN(WS-LENGTH, 128) TO HX-SO-DISPLAY-LEN(WS-ROW)
                 MOVE WS-RENDER TO HX-SO-RENDER(WS-ROW)
                 MOVE WS-KIND TO HX-SO-FMT(WS-ROW)
                 MOVE WS-COLOUR TO HX-SO-FMT-RGB(WS-ROW)
                 MOVE WS-FTEXT TO HX-SO-FMT-TEXT(WS-ROW)
                 MOVE WS-FLENGTH TO HX-SO-FMT-LEN(WS-ROW)
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM SCORE-OBJECTIVE-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-DISPLAY-READ.
*> USING CLIENT-STATE, PB-BUFFER: Set Display Objective (57-5 section 5.2): the slot VarInt (an id outside 0 to 18 reads as 0) and the objective name; an empty or an unknown name
*> clears the slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SLOT
     MOVE SPACES TO WS-NAME
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-NAME WS-CAP WS-NAME-LENGTH
     IF PB-ERROR = 1
         GOBACK
     END-IF
     IF WS-SLOT < 0 OR WS-SLOT > 18
         MOVE 0 TO WS-SLOT
     END-IF
     MOVE 0 TO WS-ROW
     IF WS-NAME-LENGTH > 0
         CALL "SCORE-OBJECTIVE-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-ROW
     END-IF
     MOVE WS-ROW TO HX-SLOT(WS-SLOT + 1)
     GOBACK.
 END PROGRAM SCORE-DISPLAY-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-SET-READ.
*> USING CLIENT-STATE, PB-BUFFER: Set Score (57-5 section 5.2): owner, objective name, the value VarInt, an optional display text, an optional number format. An unknown objective is
*> ignored; else the score is made when missing and value, display and number format are all assigned (an absent one clears it). At most 256 scores are kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-OWNER               PIC X(40).
 01 WS-OWNER-LENGTH        BINARY-LONG.
 01 WS-OWNER-CAP           BINARY-LONG VALUE 40.
 01 WS-OBJ                 PIC X(64).
 01 WS-OBJ-LENGTH          BINARY-LONG.
 01 WS-OBJ-CAP             BINARY-LONG VALUE 64.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-VALUE               BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-FTEXT               PIC X(64).
 01 WS-FLENGTH             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SCORE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     MOVE SPACES TO WS-OWNER WS-OBJ
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-OWNER WS-OWNER-CAP WS-OWNER-LENGTH
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-OBJ WS-OBJ-CAP WS-OBJ-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     MOVE 0 TO WS-LENGTH
     IF WS-PRESENT = 1
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
     END-IF
     CALL "SCORE-FORMAT-READ" USING CLIENT-STATE PB-BUFFER WS-KIND WS-COLOUR WS-FTEXT WS-FLENGTH
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "SCORE-OBJECTIVE-FIND" USING CLIENT-STATE WS-OBJ WS-OBJ-LENGTH WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SCORE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 OR WS-SCORE > 0
         IF HX-SS-USED(WS-I) = 1 AND HX-SS-OBJ(WS-I) = WS-ROW AND HX-SS-OWNER-LEN(WS-I) = WS-OWNER-LENGTH
                 AND HX-SS-OWNER(WS-I) = WS-OWNER
             MOVE WS-I TO WS-SCORE
         END-IF
     END-PERFORM
     IF WS-SCORE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 OR WS-SCORE > 0
             IF HX-SS-USED(WS-I) = 0
                 MOVE WS-I TO WS-SCORE
             END-IF
         END-PERFORM
     END-IF
     IF WS-SCORE > 0
         MOVE 1 TO HX-SS-USED(WS-SCORE)
         MOVE WS-ROW TO HX-SS-OBJ(WS-SCORE)
         MOVE WS-OWNER TO HX-SS-OWNER(WS-SCORE)
         MOVE WS-OWNER-LENGTH TO HX-SS-OWNER-LEN(WS-SCORE)
         MOVE WS-VALUE TO HX-SS-VALUE(WS-SCORE)
         MOVE WS-TEXT(1:64) TO HX-SS-DISPLAY(WS-SCORE)
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO HX-SS-DISPLAY-LEN(WS-SCORE)
         MOVE WS-KIND TO HX-SS-FMT(WS-SCORE)
         MOVE WS-COLOUR TO HX-SS-FMT-RGB(WS-SCORE)
         MOVE WS-FTEXT TO HX-SS-FMT-TEXT(WS-SCORE)
         MOVE WS-FLENGTH TO HX-SS-FMT-LEN(WS-SCORE)
     END-IF
     GOBACK.
 END PROGRAM SCORE-SET-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-RESET-READ.
*> USING CLIENT-STATE, PB-BUFFER: Reset Score (57-5 section 5.2): the owner and an optional objective name. Without a name every score of the owner goes; with the name of a known
*> objective only that one; an unknown name is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OWNER               PIC X(40).
 01 WS-OWNER-LENGTH        BINARY-LONG.
 01 WS-OWNER-CAP           BINARY-LONG VALUE 40.
 01 WS-OBJ                 PIC X(64).
 01 WS-OBJ-LENGTH          BINARY-LONG.
 01 WS-OBJ-CAP             BINARY-LONG VALUE 64.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     MOVE SPACES TO WS-OWNER WS-OBJ
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-OWNER WS-OWNER-CAP WS-OWNER-LENGTH
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-OBJ WS-OBJ-CAP WS-OBJ-LENGTH
     END-IF
     IF PB-ERROR = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-ROW
     IF WS-PRESENT = 1
         CALL "SCORE-OBJECTIVE-FIND" USING CLIENT-STATE WS-OBJ WS-OBJ-LENGTH WS-ROW
         IF WS-ROW = 0
             GOBACK
         END-IF
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF HX-SS-USED(WS-I) = 1 AND HX-SS-OWNER-LEN(WS-I) = WS-OWNER-LENGTH AND HX-SS-OWNER(WS-I) = WS-OWNER
                 AND (WS-PRESENT = 0 OR HX-SS-OBJ(WS-I) = WS-ROW)
             MOVE 0 TO HX-SS-USED(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-RESET-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-TEAM-FIND.
*> USING CLIENT-STATE, team name (PIC X(40)), its length, row out (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(40).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32 OR L-ROW > 0
         IF HX-TM-USED(WS-I) = 1 AND HX-TM-NAME-LEN(WS-I) = L-LENGTH AND HX-TM-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-TEAM-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-TEAM-READ.
*> USING CLIENT-STATE, PB-BUFFER: Set Player Team (57-5 section 5.2): the team name, the method Byte (0 add, 1 remove, 2 change, 3 join, 4 leave), TeamParameters for 0 and 2 (display
*> name, prefix and suffix texts, name tag visibility and collision rule VarInts, an optional colour, the options Byte) and the player names for 0, 3 and 4. Add creates the team
*> (an existing one is used); every other method needs the team (else the packet is ignored). Join moves each name into the team from its previous team; leave takes each name
*> out of that team and ends the connection for a name that is not in it; remove drops the team and its memberships.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-NAME                PIC X(40).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME-CAP            BINARY-LONG VALUE 40.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-METHOD              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DISPLAY             PIC X(64).
 01 WS-DISPLAY-LENGTH      BINARY-LONG.
 01 WS-PREFIX              PIC X(64).
 01 WS-PREFIX-LENGTH       BINARY-LONG.
 01 WS-SUFFIX              PIC X(64).
 01 WS-SUFFIX-LENGTH       BINARY-LONG.
 01 WS-VIS                 BINARY-LONG.
 01 WS-COLL                BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-OPTIONS             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PLAYER              PIC X(40).
 01 WS-PLAYER-LENGTH       BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-HAS-PARAMS          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     MOVE SPACES TO WS-NAME
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-NAME WS-NAME-CAP WS-NAME-LENGTH
     CALL "PB-GET-BYTE" USING PB-BUFFER WS-METHOD
     IF PB-ERROR = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-HAS-PARAMS
     IF WS-METHOD = 0 OR WS-METHOD = 2
         MOVE 1 TO WS-HAS-PARAMS
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
         MOVE SPACES TO WS-DISPLAY
         MOVE WS-TEXT(1:64) TO WS-DISPLAY
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO WS-DISPLAY-LENGTH
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
         MOVE SPACES TO WS-PREFIX
         MOVE WS-TEXT(1:64) TO WS-PREFIX
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO WS-PREFIX-LENGTH
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
         MOVE SPACES TO WS-SUFFIX
         MOVE WS-TEXT(1:64) TO WS-SUFFIX
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO WS-SUFFIX-LENGTH
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-VIS
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLL
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
         MOVE -1 TO WS-COLOUR
         IF WS-PRESENT = 1
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COLOUR
         END-IF
         CALL "PB-GET-BYTE" USING PB-BUFFER WS-OPTIONS
     END-IF
     MOVE 0 TO WS-COUNT
     IF WS-METHOD = 0 OR WS-METHOD = 3 OR WS-METHOD = 4
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
         IF WS-COUNT < 0 OR WS-COUNT > 4096
             MOVE 1 TO PB-ERROR
         END-IF
     END-IF
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "SCORE-TEAM-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-ROW
     IF WS-METHOD = 0 AND WS-ROW = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32 OR WS-ROW > 0
             IF HX-TM-USED(WS-I) = 0
                 MOVE WS-I TO WS-ROW
             END-IF
         END-PERFORM
         IF WS-ROW > 0
             INITIALIZE HX-TM(WS-ROW)
             MOVE 1 TO HX-TM-USED(WS-ROW)
             MOVE WS-NAME TO HX-TM-NAME(WS-ROW)
             MOVE WS-NAME-LENGTH TO HX-TM-NAME-LEN(WS-ROW)
             MOVE -1 TO HX-TM-COLOUR(WS-ROW)
         END-IF
     END-IF
     IF WS-ROW > 0 AND WS-HAS-PARAMS = 1
         MOVE WS-DISPLAY TO HX-TM-DISPLAY(WS-ROW)
         MOVE WS-DISPLAY-LENGTH TO HX-TM-DISPLAY-LEN(WS-ROW)
         MOVE WS-PREFIX TO HX-TM-PREFIX(WS-ROW)
         MOVE WS-PREFIX-LENGTH TO HX-TM-PREFIX-LEN(WS-ROW)
         MOVE WS-SUFFIX TO HX-TM-SUFFIX(WS-ROW)
         MOVE WS-SUFFIX-LENGTH TO HX-TM-SUFFIX-LEN(WS-ROW)
         MOVE WS-COLOUR TO HX-TM-COLOUR(WS-ROW)
         MOVE WS-OPTIONS TO HX-TM-OPTIONS(WS-ROW)
         MOVE WS-VIS TO HX-TM-VIS(WS-ROW)
         MOVE WS-COLL TO HX-TM-COLL(WS-ROW)
     END-IF
*>   The players. The bytes of a member name are read whether or not the team exists.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT OR PB-ERROR = 1
         MOVE SPACES TO WS-PLAYER
         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-PLAYER WS-NAME-CAP WS-PLAYER-LENGTH
         IF PB-ERROR = 0 AND WS-ROW > 0
             MOVE 0 TO WS-MEMBER WS-FREE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
                 IF HX-TP-TEAM(WS-I) > 0 AND HX-TP-NAME-LEN(WS-I) = WS-PLAYER-LENGTH AND HX-TP-NAME(WS-I) = WS-PLAYER
                     MOVE WS-I TO WS-MEMBER
                 END-IF
                 IF HX-TP-TEAM(WS-I) = 0 AND WS-FREE = 0
                     MOVE WS-I TO WS-FREE
                 END-IF
             END-PERFORM
             EVALUATE TRUE
                 WHEN WS-METHOD = 4
                     IF WS-MEMBER > 0 AND HX-TP-TEAM(WS-MEMBER) = WS-ROW
                         MOVE 0 TO HX-TP-TEAM(WS-MEMBER)
                     ELSE
                         CALL "SCORE-FAIL" USING CLIENT-STATE
                         GOBACK
                     END-IF
                 WHEN WS-MEMBER > 0
                     MOVE WS-ROW TO HX-TP-TEAM(WS-MEMBER)
                 WHEN WS-FREE > 0
                     MOVE WS-ROW TO HX-TP-TEAM(WS-FREE)
                     MOVE WS-PLAYER TO HX-TP-NAME(WS-FREE)
                     MOVE WS-PLAYER-LENGTH TO HX-TP-NAME-LEN(WS-FREE)
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
         END-IF
     END-PERFORM
     IF WS-METHOD = 1 AND WS-ROW > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
             IF HX-TP-TEAM(WS-I) = WS-ROW
                 MOVE 0 TO HX-TP-TEAM(WS-I)
             END-IF
         END-PERFORM
         MOVE 0 TO HX-TM-USED(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM SCORE-TEAM-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-OWNER-TEAM.
*> USING CLIENT-STATE, owner name (PIC X(40)), its length, team row out (0 when the owner is in no team).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-OWNER                PIC X(40).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-OWNER L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128 OR L-ROW > 0
         IF HX-TP-TEAM(WS-I) > 0 AND HX-TP-NAME-LEN(WS-I) = L-LENGTH AND HX-TP-NAME(WS-I) = L-OWNER
             MOVE HX-TP-TEAM(WS-I) TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-OWNER-TEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCORE-SIDEBAR-ADD.
*> USING CLIENT-STATE, GUI width, GUI height: Hud.extractScoreboardSidebar (57-5 section 5.4). The objective is the one of the slot sidebar.team.<colour> of the local player's team
*> when the team has a colour and the slot shows one, else of the slot sidebar. Its entries: the scores except those whose owner starts with #, sorted by value descending and
*> by owner name ascending ignoring case, at most 15. The name is the score's display text or the owner, as prefix + name + suffix of the owner's team, in the team colour when it
*> has one; the score text is the number format of the score, else of the objective, else the sidebar default (the number in red FF5555): blank is empty, styled the number in
*> its colour, fixed its text. maxW = the width of the objective's display name, widened by name + colon + score of each entry (the colon is only a gap). With n entries: totalH =
*> n x 9, bottom = H / 2 + totalH / 3, top = bottom - totalH, left = W - maxW - 3, right = W - 3 + 2. The title strip is filled from (left - 2, top - 10) to (right, top - 1) and the
*> body from (left - 2, top - 1) to (right, bottom): black of alpha 102 and 76 (the opacities 0.4 and 0.3), or the textBackgroundOpacity alpha for both when the text background
*> option is Everywhere. Text without the shadow: the title at left + maxW / 2 - titleWidth / 2, y = top - 9, white; entry i from the top at y = bottom - (n - i) x 9, the name at
*> left, the score at right - scoreWidth.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-N-CHAT              PIC X(40) VALUE "backgroundForChatOnly".
 01 WS-N-OPACITY           PIC X(40) VALUE "textBackgroundOpacity".
 01 WS-D-HALF              FLOAT-LONG VALUE 0.5.
 01 WS-DEFAULT-ONE         BINARY-LONG VALUE 1.
 01 WS-CHAT-ONLY           BINARY-LONG.
 01 WS-OPACITY             FLOAT-LONG.
 01 WS-A-STRIP             BINARY-LONG.
 01 WS-A-BODY              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OBJ                 BINARY-LONG.
 01 WS-TEAM                BINARY-LONG.
 01 WS-LOCAL-OWNER         PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ORDER.
    05 WS-O                BINARY-LONG OCCURS 15 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-A-LOW               PIC X(40).
 01 WS-B-LOW               PIC X(40).
 01 WS-ENTRY.
    05 WS-E OCCURS 15 TIMES.
       10 WS-E-NAME        PIC X(256).
       10 WS-E-NAME-LEN    BINARY-LONG.
       10 WS-E-NAME-RGB    BINARY-LONG.
       10 WS-E-SCORE       PIC X(64).
       10 WS-E-SCORE-LEN   BINARY-LONG.
       10 WS-E-SCORE-RGB   BINARY-LONG.
       10 WS-E-NAME-W      BINARY-LONG.
       10 WS-E-SCORE-W     BINARY-LONG.
 01 WS-NUMBER              PIC -(9)9.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT256             PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TITLE-W             BINARY-LONG.
 01 WS-COLON               PIC X(256) VALUE ":".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-COLON-W             BINARY-LONG.
 01 WS-MAX-W               BINARY-LONG.
 01 WS-TOTAL-H             BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-BLACK               BINARY-LONG VALUE SW-BLACK.
 01 WS-EMPTY               PIC X(512) VALUE SPACES.
 01 WS-WHITE               BINARY-LONG VALUE 16777215.
 01 WS-ALPHA               BINARY-LONG VALUE 255.
 01 WS-NOSHADOW            BINARY-LONG VALUE 9.
 01 WS-RGB                 BINARY-LONG.
 01 WS-FMT                 BINARY-LONG.
 01 WS-FMT-RGB             BINARY-LONG.
 01 WS-FMT-TEXT            PIC X(64).
 01 WS-FMT-LEN             BINARY-LONG.
 01 WS-OWNER40             PIC X(40).
 01 WS-HALF-A              BINARY-LONG.
 01 WS-HALF-B              BINARY-LONG.
 01 WS-NAMEBUF             PIC X(256).
 01 WS-NAMELEN             BINARY-LONG.
 01 WS-PIECE               PIC X(256).
 01 WS-PLEN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
*>   The objective: the team's colour slot (3 + colour) first.
     MOVE 0 TO WS-OBJ
     MOVE SPACES TO WS-LOCAL-OWNER
     MOVE CL-NAME TO WS-LOCAL-OWNER
     CALL "SCORE-OWNER-TEAM" USING CLIENT-STATE WS-LOCAL-OWNER CL-NAME-LENGTH WS-TEAM
     IF WS-TEAM > 0
         IF HX-TM-COLOUR(WS-TEAM) >= 0 AND HX-TM-COLOUR(WS-TEAM) <= 15
             COMPUTE WS-SLOT = 3 + HX-TM-COLOUR(WS-TEAM) + 1
             MOVE HX-SLOT(WS-SLOT) TO WS-OBJ
         END-IF
     END-IF
     IF WS-OBJ = 0
         MOVE HX-SLOT(2) TO WS-OBJ
     END-IF
     IF WS-OBJ = 0
         GOBACK
     END-IF
*>   The entries: not hidden (owner starting with #), sorted, at most 15.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF HX-SS-USED(WS-I) = 1 AND HX-SS-OBJ(WS-I) = WS-OBJ AND HX-SS-OWNER(WS-I)(1:1) NOT = "#"
             MOVE 0 TO WS-BEFORE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR WS-BEFORE > 0
                 MOVE WS-O(WS-K) TO WS-N
                 EVALUATE TRUE
                     WHEN HX-SS-VALUE(WS-I) > HX-SS-VALUE(WS-N)
                         MOVE WS-K TO WS-BEFORE
                     WHEN HX-SS-VALUE(WS-I) = HX-SS-VALUE(WS-N)
                         MOVE FUNCTION LOWER-CASE(HX-SS-OWNER(WS-I)) TO WS-A-LOW
                         MOVE FUNCTION LOWER-CASE(HX-SS-OWNER(WS-N)) TO WS-B-LOW
                         IF WS-A-LOW < WS-B-LOW
                             MOVE WS-K TO WS-BEFORE
                         END-IF
                     WHEN OTHER
                         CONTINUE
                 END-EVALUATE
             END-PERFORM
             IF WS-BEFORE = 0
                 MOVE WS-COUNT TO WS-BEFORE
                 ADD 1 TO WS-BEFORE
             END-IF
             IF WS-BEFORE <= 15
                 IF WS-COUNT < 15
                     ADD 1 TO WS-COUNT
                 END-IF
                 PERFORM VARYING WS-K FROM WS-COUNT BY -1 UNTIL WS-K <= WS-BEFORE
                     COMPUTE WS-N = WS-K - 1
                     MOVE WS-O(WS-N) TO WS-O(WS-K)
                 END-PERFORM
                 MOVE WS-I TO WS-O(WS-BEFORE)
             END-IF
         END-IF
     END-PERFORM
     MOVE ":" TO WS-COLON
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-COLON WS-ONE WS-COLON-W
     MOVE SPACES TO WS-TEXT256
     MOVE HX-SO-DISPLAY(WS-OBJ) TO WS-TEXT256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 HX-SO-DISPLAY-LEN(WS-OBJ) WS-TITLE-W
     MOVE WS-TITLE-W TO WS-MAX-W
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         MOVE WS-O(WS-K) TO WS-I
*>       The name: the display text or the owner, as prefix + name + suffix of the owner's team (plain fields for every reference modification).
         MOVE SPACES TO WS-NAMEBUF
         MOVE 0 TO WS-NAMELEN
         MOVE 16777215 TO WS-E-NAME-RGB(WS-K)
         MOVE HX-SS-OWNER(WS-I) TO WS-OWNER40
         CALL "SCORE-OWNER-TEAM" USING CLIENT-STATE WS-OWNER40 HX-SS-OWNER-LEN(WS-I) WS-TEAM
         IF WS-TEAM > 0
             MOVE HX-TM-PREFIX-LEN(WS-TEAM) TO WS-PLEN
             IF WS-PLEN > 0
                 MOVE HX-TM-PREFIX(WS-TEAM) TO WS-PIECE
                 MOVE WS-PIECE(1:WS-PLEN) TO WS-NAMEBUF(WS-NAMELEN + 1:WS-PLEN)
                 ADD WS-PLEN TO WS-NAMELEN
             END-IF
         END-IF
         IF HX-SS-DISPLAY-LEN(WS-I) > 0
             MOVE HX-SS-DISPLAY-LEN(WS-I) TO WS-PLEN
             MOVE HX-SS-DISPLAY(WS-I) TO WS-PIECE
         ELSE
             MOVE HX-SS-OWNER-LEN(WS-I) TO WS-PLEN
             MOVE HX-SS-OWNER(WS-I) TO WS-PIECE
         END-IF
         IF WS-PLEN > 0
             MOVE WS-PIECE(1:WS-PLEN) TO WS-NAMEBUF(WS-NAMELEN + 1:WS-PLEN)
             ADD WS-PLEN TO WS-NAMELEN
         END-IF
         IF WS-TEAM > 0
             MOVE HX-TM-SUFFIX-LEN(WS-TEAM) TO WS-PLEN
             IF WS-PLEN > 0
                 MOVE HX-TM-SUFFIX(WS-TEAM) TO WS-PIECE
                 MOVE WS-PIECE(1:WS-PLEN) TO WS-NAMEBUF(WS-NAMELEN + 1:WS-PLEN)
                 ADD WS-PLEN TO WS-NAMELEN
             END-IF
             IF HX-TM-COLOUR(WS-TEAM) >= 0
                 CALL "SCORE-COLOUR-RGB" USING HX-TM-COLOUR(WS-TEAM) WS-E-NAME-RGB(WS-K)
             END-IF
         END-IF
         MOVE WS-NAMEBUF TO WS-E-NAME(WS-K)
         MOVE WS-NAMELEN TO WS-E-NAME-LEN(WS-K)
*>       The score text: the number format of the score, else of the objective, else red.
         MOVE HX-SS-FMT(WS-I) TO WS-FMT
         MOVE HX-SS-FMT-RGB(WS-I) TO WS-FMT-RGB
         MOVE HX-SS-FMT-TEXT(WS-I) TO WS-FMT-TEXT
         MOVE HX-SS-FMT-LEN(WS-I) TO WS-FMT-LEN
         IF WS-FMT < 0
             MOVE HX-SO-FMT(WS-OBJ) TO WS-FMT
             MOVE HX-SO-FMT-RGB(WS-OBJ) TO WS-FMT-RGB
             MOVE HX-SO-FMT-TEXT(WS-OBJ) TO WS-FMT-TEXT
             MOVE HX-SO-FMT-LEN(WS-OBJ) TO WS-FMT-LEN
         END-IF
         MOVE SPACES TO WS-E-SCORE(WS-K)
         MOVE 0 TO WS-E-SCORE-LEN(WS-K)
         MOVE 16733525 TO WS-E-SCORE-RGB(WS-K)
         EVALUATE WS-FMT
             WHEN 0
                 CONTINUE
             WHEN 2
                 MOVE WS-FMT-TEXT TO WS-E-SCORE(WS-K)
                 MOVE WS-FMT-LEN TO WS-E-SCORE-LEN(WS-K)
                 MOVE 16777215 TO WS-E-SCORE-RGB(WS-K)
             WHEN OTHER
                 MOVE HX-SS-VALUE(WS-I) TO WS-NUMBER
                 MOVE FUNCTION TRIM(WS-NUMBER) TO WS-E-SCORE(WS-K)
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NUMBER)) TO WS-E-SCORE-LEN(WS-K)
                 IF WS-FMT = 1 AND WS-FMT-RGB >= 0
                     MOVE WS-FMT-RGB TO WS-E-SCORE-RGB(WS-K)
                 END-IF
                 IF WS-FMT = 1 AND WS-FMT-RGB < 0
                     MOVE 16777215 TO WS-E-SCORE-RGB(WS-K)
                 END-IF
         END-EVALUATE
         MOVE WS-E-NAME(WS-K) TO WS-TEXT256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-E-NAME-LEN(WS-K) WS-E-NAME-W(WS-K)
         MOVE SPACES TO WS-TEXT256
         MOVE WS-E-SCORE(WS-K) TO WS-TEXT256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT256 WS-E-SCORE-LEN(WS-K) WS-E-SCORE-W(WS-K)
         IF WS-E-SCORE-W(WS-K) > 0
             COMPUTE WS-W = WS-E-NAME-W(WS-K) + WS-COLON-W + WS-E-SCORE-W(WS-K)
         ELSE
             MOVE WS-E-NAME-W(WS-K) TO WS-W
         END-IF
         MOVE FUNCTION MAX(WS-MAX-W, WS-W) TO WS-MAX-W
     END-PERFORM
     COMPUTE WS-TOTAL-H = WS-COUNT * 9
     COMPUTE WS-HALF-A = L-GH / 2
     COMPUTE WS-HALF-B = WS-TOTAL-H / 3
     COMPUTE WS-BOTTOM = WS-HALF-A + WS-HALF-B
     COMPUTE WS-TOP = WS-BOTTOM - WS-TOTAL-H
     COMPUTE WS-LEFT = L-GW - WS-MAX-W - 3
     COMPUTE WS-RIGHT = L-GW - 3 + 2
*>   The backgrounds: alpha 102 for the title strip and 76 for the body, the text background opacity for both when Everywhere.
     CALL "CHAT-OPT-FLAG" USING CLIENT-STATE WS-N-CHAT WS-DEFAULT-ONE WS-CHAT-ONLY
     MOVE 102 TO WS-A-STRIP
     MOVE 76 TO WS-A-BODY
     IF WS-CHAT-ONLY = 0
         CALL "CHAT-OPT" USING CLIENT-STATE WS-N-OPACITY WS-D-HALF WS-OPACITY
         COMPUTE WS-A-STRIP = FUNCTION INTEGER(255 * WS-OPACITY)
         MOVE WS-A-STRIP TO WS-A-BODY
     END-IF
     MOVE WK-OVERLAY TO WS-KIND
     COMPUTE WS-X = WS-LEFT - 2
     COMPUTE WS-Y = WS-TOP - 10
     COMPUTE WS-W = WS-RIGHT - WS-X
     MOVE 9 TO WS-H
     IF WS-A-STRIP > 0
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-BLACK WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
         CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A-STRIP
     END-IF
     COMPUTE WS-Y = WS-TOP - 1
     COMPUTE WS-H = WS-BOTTOM - WS-Y
     IF WS-A-BODY > 0
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-BLACK WS-X WS-Y WS-W WS-H WS-EMPTY WS-Z WS-Z2
         CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-A-BODY
     END-IF
*>   The text.
     MOVE WK-LABEL TO WS-KIND
     MOVE SPACES TO WS-TEXT
     MOVE HX-SO-DISPLAY(WS-OBJ) TO WS-TEXT
     MOVE HX-SO-DISPLAY-LEN(WS-OBJ) TO WS-LENGTH
     COMPUTE WS-HALF-A = WS-MAX-W / 2
     COMPUTE WS-HALF-B = WS-TITLE-W / 2
     COMPUTE WS-X = WS-LEFT + WS-HALF-A - WS-HALF-B
     COMPUTE WS-Y = WS-TOP - 9
     MOVE WS-TITLE-W TO WS-W
     MOVE 9 TO WS-H
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-NOSHADOW
     CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-WHITE
     CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         COMPUTE WS-Y = WS-BOTTOM - (WS-COUNT - WS-K + 1) * 9
         MOVE SPACES TO WS-TEXT
         MOVE WS-E-NAME(WS-K) TO WS-TEXT
         MOVE WS-E-NAME-LEN(WS-K) TO WS-LENGTH
         MOVE WS-LEFT TO WS-X
         MOVE WS-E-NAME-W(WS-K) TO WS-W
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-NOSHADOW
         MOVE FUNCTION MAX(1, WS-E-NAME-RGB(WS-K)) TO WS-RGB
         CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
         CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
         IF WS-E-SCORE-LEN(WS-K) > 0
             MOVE SPACES TO WS-TEXT
             MOVE WS-E-SCORE(WS-K) TO WS-TEXT
             MOVE WS-E-SCORE-LEN(WS-K) TO WS-LENGTH
             COMPUTE WS-X = WS-RIGHT - WS-E-SCORE-W(WS-K)
             MOVE WS-E-SCORE-W(WS-K) TO WS-W
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z WS-X WS-Y WS-W WS-H WS-TEXT WS-LENGTH WS-NOSHADOW
             MOVE FUNCTION MAX(1, WS-E-SCORE-RGB(WS-K)) TO WS-RGB
             CALL "WIDGET-COLOUR" USING CLIENT-STATE WS-RGB
             CALL "WIDGET-ALPHA" USING CLIENT-STATE WS-ALPHA
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCORE-SIDEBAR-ADD.
