*> The chat commands (docs/protocol/16-commands-catalog.md §8): say, me, msg (tell, w), list, help. A command program reads its
*> parsed context (core/copy/BRRUN.cpy) through BX-FIND and the BX- helpers, sends its messages through BR-FEEDBACK and the BR-
*> senders (core/src/cmd-feedback.cob), sets BR-R-RESULT and, to fail, raises an exception (BR-RAISE) and sets BR-R-FAILED.
*>
*> Entry points: CX-SAY, CX-ME, CX-MSG, CX-LIST, CX-HELP (no arguments)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SAY.
*> say <message> (16 §8.1, level 2): the message (selectors resolved) is chat.type.announcement [sender, content] to every
*> player and the console; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME                PIC X(32) VALUE "message".
 01 WS-INDEX               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "chat.type.announcement".
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     CALL "BX-MESSAGE" USING WS-INDEX WS-TEXT WS-LENGTH
     IF BR-R-FAILED = 0
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT BS-NAME BS-NAME-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
         INITIALIZE PB-TEXT-STYLE
         CALL "BR-BROADCAST" USING PB-TEXT PB-TEXT-STYLE
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-ME.
*> me <action> (16 §8.2, level 0): the action is chat.type.emote [sender, content] to every player and the console; result 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME                PIC X(32) VALUE "action".
 01 WS-INDEX               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "chat.type.emote".
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     CALL "BX-MESSAGE" USING WS-INDEX WS-TEXT WS-LENGTH
     IF BR-R-FAILED = 0
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT BS-NAME BS-NAME-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
         INITIALIZE PB-TEXT-STYLE
         CALL "BR-BROADCAST" USING PB-TEXT PB-TEXT-STYLE
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-ME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-MSG.
*> msg <targets> <message> (16 §8.3, level 0; tell and w are aliases): each target is sent commands.message.display.incoming
*> [sender, content] and the sender commands.message.display.outgoing [target, content], both gray and italic; the result is the
*> number of targets.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-MESSAGE        PIC X(32) VALUE "message".
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-MESSAGE       BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY-IN              PIC X(72) VALUE "commands.message.display.incoming".
 01 WS-KEY-OUT             PIC X(72) VALUE "commands.message.display.outgoing".
 01 WS-I                   BINARY-LONG.
 COPY CORESTATE.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-MESSAGE WS-INDEX-MESSAGE
         CALL "BX-MESSAGE" USING WS-INDEX-MESSAGE WS-TEXT WS-LENGTH
     END-IF
     IF BR-R-FAILED = 0
         INITIALIZE PB-TEXT-STYLE
         MOVE "gray" TO PB-TS-COLOR
         MOVE 1 TO PB-TS-ITALIC
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             CALL "BX-KEY" USING PB-TEXT WS-KEY-IN
             CALL "CMD-TEXT-ARG" USING PB-TEXT BS-NAME BS-NAME-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
             CALL "BR-TELL-STYLED" USING BX-ROW(WS-I) PB-TEXT PB-TEXT-STYLE
             CALL "BX-KEY" USING PB-TEXT WS-KEY-OUT
             CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(WS-I)) PL-NAME-LENGTH(BX-ROW(WS-I))
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
             CALL "BR-TELL-STYLED" USING BS-ROW PB-TEXT PB-TEXT-STYLE
         END-PERFORM
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-MSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-LIST.
*> list, list uuids (16 §8.5, level 0): commands.list.players [online count, max players, names joined by ", "], each name
*> "name (uuid)" for uuids; not broadcast; the result is the number of players online.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-NAME-UUIDS          PIC X(32) VALUE "uuids".
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROWS.
    05 WS-ONLINE            BINARY-LONG OCCURS 64 TIMES.
 01 WS-NAMES               PIC X(2400).
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-KEY                 PIC X(72) VALUE "commands.list.players".
 01 WS-MAX                 BINARY-LONG VALUE 64.
 01 WS-BROADCAST           BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-LIT" USING WS-NAME-UUIDS WS-INDEX
     CALL "CMD-ONLINE" USING WS-COUNT WS-ROWS
     MOVE SPACES TO WS-NAMES
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-ONLINE(WS-I) TO WS-ROW
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POS
         END-IF
         STRING PL-NAME(WS-ROW)(1:PL-NAME-LENGTH(WS-ROW)) DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POS
         IF WS-INDEX > 0
             CALL "PERSIST-UUID-TEXT" USING PL-UUID(WS-ROW) WS-UUID-TEXT
             STRING " (" WS-UUID-TEXT ")" DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POS
         END-IF
     END-PERFORM
     COMPUTE WS-LENGTH = WS-POS - 1
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-MAX
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE WS-COUNT TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-HELP.
*> help, help <command> (16 §8.6, level 0): one line "/" + usage for each command the source may use (the smart usage of the
*> root), or for the children of the last node the command text parses to; no node parsed is commands.help.failed. A line is a
*> literal text with the click action that suggests it; not broadcast; the result is the number of lines.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 COPY PROTO.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==HT-==.
 01 WS-NAME                PIC X(32) VALUE "command".
 01 WS-INDEX               BINARY-LONG.
 01 WS-NODE                BINARY-LONG VALUE 1.
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-PREFIX              PIC X(1024).
 01 WS-PREFIX-LENGTH       BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(1100).
 01 WS-KEY                 PIC X(48).
 01 WS-A                   PIC X(64).
 01 WS-B                   PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-BROADCAST           BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE BS-LEVEL TO WS-LEVEL
     MOVE 0 TO WS-PREFIX-LENGTH
     MOVE SPACES TO WS-PREFIX
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     IF WS-INDEX > 0
         MOVE SPACES TO WS-LINE
         COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
         MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-LENGTH) TO WS-LINE
         CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH HT-TRAIL
         IF HT-COUNT = 0
             MOVE "commands.help.failed" TO WS-KEY
             MOVE SPACES TO WS-A WS-B
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A WS-L1 WS-B WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE HT-NODE(HT-COUNT) TO WS-NODE
             MOVE WS-LINE TO WS-PREFIX
             MOVE WS-LENGTH TO WS-PREFIX-LENGTH
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         CALL "BR-SMART-USAGE" USING WS-NODE WS-LEVEL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-U-COUNT
             MOVE SPACES TO WS-TEXT
             IF WS-PREFIX-LENGTH > 0
                 STRING "/" WS-PREFIX(1:WS-PREFIX-LENGTH) " " BR-U-TEXT(WS-I)(1:BR-U-LENGTH(WS-I))
                     DELIMITED BY SIZE INTO WS-TEXT
             ELSE
                 STRING "/" BR-U-TEXT(WS-I)(1:BR-U-LENGTH(WS-I)) DELIMITED BY SIZE INTO WS-TEXT
             END-IF
             INITIALIZE PB-TEXT PB-TEXT-STYLE
             MOVE PB-TEXT-LITERAL TO PB-TX-KIND
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING)) TO PB-TX-LENGTH
             MOVE WS-TEXT TO PB-TX-VALUE
             MOVE PB-TX-LENGTH TO PB-TS-CLICK-LENGTH
             MOVE WS-TEXT TO PB-TS-CLICK
             CALL "BR-FEEDBACK-STYLED" USING PB-TEXT PB-TEXT-STYLE WS-BROADCAST
         END-PERFORM
         MOVE BR-U-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-HELP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SAY.
*> The forms of say (16 §8.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SAY.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "say <message:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-ME.
*> The forms of me (16 §8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-ME.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "me <action:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-ME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-MSG.
*> The forms of msg and its aliases tell and w (16 §8.3, §14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-MSG.
 01 WS-PATH                PIC X(256).
 01 WS-ALIAS               PIC X(32).
 01 WS-ALIAS-LENGTH        BINARY-LONG.
 01 WS-TARGET              PIC X(32) VALUE "msg".
 01 WS-TARGET-LENGTH       BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     MOVE "msg <targets:players> <message:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "tell" TO WS-ALIAS
     MOVE 4 TO WS-ALIAS-LENGTH
     CALL "BR-REG-ALIAS" USING WS-ALIAS WS-ALIAS-LENGTH WS-TARGET WS-TARGET-LENGTH
     MOVE "w" TO WS-ALIAS
     MOVE 1 TO WS-ALIAS-LENGTH
     CALL "BR-REG-ALIAS" USING WS-ALIAS WS-ALIAS-LENGTH WS-TARGET WS-TARGET-LENGTH
     GOBACK.
 END PROGRAM CMDS-REG-MSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-LIST.
*> The forms of list (16 §8.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-LIST.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "list" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "list uuids" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-HELP.
*> The forms of help (16 §8.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-HELP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "help" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "help <command:greedy>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-HELP.

*> ---- Lane cmds-a: tellraw, title, dialog, teammsg, posteffect, bossbar (16 §8) ----

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-COMPONENT.
*> USING index, text out (PIC X(1024)), length out: the text of a component argument (15 §9.3): the inside of a quoted SNBT string, the value of the text
*> member of a compound ({text:"x"} or {"text":"x"}, a quoted value), anything else as it was typed (the selectors, scores and NBT inside a component
*> are not resolved and the other members are dropped here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RAW                 PIC X(1024).
 01 WS-FIRST               PIC X.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-QUOTE               PIC X.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH.
     MOVE BA-START(L-INDEX) TO WS-START
     COMPUTE WS-LENGTH = FUNCTION MIN(BA-END(L-INDEX) - WS-START, 1024)
     MOVE SPACES TO WS-RAW
     MOVE BR-R-LINE(WS-START + 1:WS-LENGTH) TO WS-RAW
     MOVE WS-RAW TO L-TEXT
     MOVE WS-LENGTH TO L-LENGTH
     MOVE WS-RAW(1:1) TO WS-FIRST
     EVALUATE TRUE
         WHEN WS-LENGTH >= 2 AND (WS-FIRST = '"' OR WS-FIRST = "'")
             MOVE SPACES TO L-TEXT
             MOVE WS-RAW(2:1023) TO L-TEXT
             COMPUTE L-LENGTH = WS-LENGTH - 2
         WHEN WS-FIRST = "{"
             MOVE 0 TO WS-A WS-B WS-I
             INSPECT WS-RAW(1:WS-LENGTH) TALLYING WS-A FOR CHARACTERS BEFORE INITIAL "text:"
             INSPECT WS-RAW(1:WS-LENGTH) TALLYING WS-B FOR CHARACTERS BEFORE INITIAL 'text":'
             EVALUATE TRUE
                 WHEN WS-A < WS-LENGTH
                     COMPUTE WS-I = WS-A + 6
                 WHEN WS-B < WS-LENGTH
                     COMPUTE WS-I = WS-B + 7
             END-EVALUATE
             IF WS-I > 0 AND WS-I < WS-LENGTH
                 MOVE WS-RAW(WS-I:1) TO WS-QUOTE
                 IF WS-QUOTE = '"' OR WS-QUOTE = "'"
                     COMPUTE WS-J = WS-I + 1
                     PERFORM UNTIL WS-J > WS-LENGTH OR WS-RAW(WS-J:1) = WS-QUOTE
                         ADD 1 TO WS-J
                     END-PERFORM
                     COMPUTE L-LENGTH = WS-J - WS-I - 1
                     MOVE SPACES TO L-TEXT
                     MOVE WS-RAW(WS-I + 1:1023 - WS-I) TO L-TEXT
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BX-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-LITERAL.
*> USING text (PIC X(1024)), length, PB-TEXT out: a literal text component of that text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH PB-TEXT.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-LITERAL TO PB-TX-KIND
     MOVE L-LENGTH TO PB-TX-LENGTH
     MOVE L-TEXT TO PB-TX-VALUE
     GOBACK.
 END PROGRAM BX-LITERAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TELLRAW.
*> tellraw <targets> <message> (16 §8.8, level 2): each player target is sent the component as a System Chat message (not an overlay); no message to
*> the source; the result is the number of players.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-MESSAGE        PIC X(32) VALUE "message".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-MESSAGE WS-INDEX
         CALL "BX-COMPONENT" USING WS-INDEX WS-TEXT WS-LENGTH
         CALL "BX-LITERAL" USING WS-TEXT WS-LENGTH PB-TEXT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             CALL "BR-TELL" USING BX-ROW(WS-I) PB-TEXT
         END-PERFORM
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-TELLRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TELLRAW.
*> The form of tellraw (16 §8.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TELLRAW.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "tellraw <targets:players> <message:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TELLRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-COUNT-MESSAGE.
*> USING key prefix (PIC X(48), without the .single and .multiple), rows (BX-ROWS group), broadcast, lead text (PIC X(64)), its length (0 = none): the
*> message of a command over several players (16 §1 tracker): <prefix>.single [lead, player name] for one, else <prefix>.multiple [lead, count];
*> told through BR-FEEDBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-KEY                 PIC X(72).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PREFIX               PIC X(48).
 01 L-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 L-BROADCAST            BINARY-LONG.
 01 L-LEAD                 PIC X(64).
 01 L-LEAD-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-PREFIX L-ROWS L-BROADCAST L-LEAD L-LEAD-LENGTH.
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-PREFIX TRAILING))
     MOVE SPACES TO WS-KEY
     IF BX-COUNT = 1
         STRING L-PREFIX(1:WS-LENGTH) ".single" DELIMITED BY SIZE INTO WS-KEY
     ELSE
         STRING L-PREFIX(1:WS-LENGTH) ".multiple" DELIMITED BY SIZE INTO WS-KEY
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     IF L-LEAD-LENGTH > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT L-LEAD L-LEAD-LENGTH
     END-IF
     IF BX-COUNT = 1
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(1)) PL-NAME-LENGTH(BX-ROW(1))
     ELSE
         CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT L-BROADCAST
     GOBACK.
 END PROGRAM BX-COUNT-MESSAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TITLE.
*> title <targets> clear | reset | title <c> | subtitle <c> | actionbar <c> | times <fadeIn> <stay> <fadeOut> (16 §8.9, level 2): each player target is sent
*> Clear Titles 0x0E (reset flag), Set Title Text 0x74, Set Subtitle Text 0x72, Set Action Bar Text 0x59 or Set Titles Animation 0x75 (three Ints, ticks);
*> commands.title.<kind>.single [player] or .multiple [count] is broadcast; the result is the number of players.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-TITLE          PIC X(32) VALUE "title".
 01 WS-NAME-FADE-IN        PIC X(32) VALUE "fadeIn".
 01 WS-NAME-STAY           PIC X(32) VALUE "stay".
 01 WS-NAME-FADE-OUT       PIC X(32) VALUE "fadeOut".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SUB                 PIC X(64).
 01 WS-PREFIX              PIC X(48).
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-ID                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FADE-IN             BINARY-LONG.
 01 WS-STAY                BINARY-LONG.
 01 WS-FADE-OUT            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-NO-LEAD             PIC X(64).
 01 WS-NO-LEAD-LENGTH      BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         MOVE BA-NAME(3) TO WS-SUB
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         EVALUATE WS-SUB
             WHEN "clear"
                 MOVE "commands.title.cleared" TO WS-PREFIX
                 MOVE 14 TO WS-ID
                 MOVE 0 TO WS-FLAG
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
                 CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
             WHEN "reset"
                 MOVE "commands.title.reset" TO WS-PREFIX
                 MOVE 14 TO WS-ID
                 MOVE 1 TO WS-FLAG
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
                 CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
             WHEN "times"
                 MOVE "commands.title.times" TO WS-PREFIX
                 CALL "BX-FIND" USING WS-NAME-FADE-IN WS-INDEX
                 MOVE BA-IVAL(WS-INDEX) TO WS-FADE-IN
                 CALL "BX-FIND" USING WS-NAME-STAY WS-INDEX
                 MOVE BA-IVAL(WS-INDEX) TO WS-STAY
                 CALL "BX-FIND" USING WS-NAME-FADE-OUT WS-INDEX
                 MOVE BA-IVAL(WS-INDEX) TO WS-FADE-OUT
                 MOVE 117 TO WS-ID
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
                 CALL "PB-PUT-INT" USING PB-BUFFER WS-FADE-IN
                 CALL "PB-PUT-INT" USING PB-BUFFER WS-STAY
                 CALL "PB-PUT-INT" USING PB-BUFFER WS-FADE-OUT
             WHEN OTHER
                 CALL "BX-FIND" USING WS-NAME-TITLE WS-INDEX
                 CALL "BX-COMPONENT" USING WS-INDEX WS-TEXT WS-LENGTH
                 CALL "BX-LITERAL" USING WS-TEXT WS-LENGTH PB-TEXT
                 EVALUATE WS-SUB
                     WHEN "title"
                         MOVE "commands.title.show.title" TO WS-PREFIX
                         MOVE 116 TO WS-ID
                     WHEN "subtitle"
                         MOVE "commands.title.show.subtitle" TO WS-PREFIX
                         MOVE 114 TO WS-ID
                     WHEN OTHER
                         MOVE "commands.title.show.actionbar" TO WS-PREFIX
                         MOVE 89 TO WS-ID
                 END-EVALUATE
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
                 CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
         END-EVALUATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             CALL "CORE-SEND" USING PL-CONN(BX-ROW(WS-I)) PB-BUFFER
         END-PERFORM
         CALL "PB-FREE" USING PB-BUFFER
         CALL "BX-COUNT-MESSAGE" USING WS-PREFIX WS-ROWS WS-BROADCAST WS-NO-LEAD WS-NO-LEAD-LENGTH
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-TITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TITLE.
*> The forms of title (16 §8.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TITLE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "title <targets:players> clear" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "title <targets:players> reset" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "title <targets:players> title <title:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "title <targets:players> subtitle <title:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "title <targets:players> actionbar <title:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "title <targets:players> times <fadeIn:time:0> <stay:time:0> <fadeOut:time:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TITLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DIALOG.
*> dialog clear <targets> (16 §8.10, level 2): each player target is sent Clear Dialog (0x8E); commands.dialog.clear.single [player] or .multiple [count] is
*> broadcast; the result is the number of players. BLOCKED docs: dialog show (the dialog registry is empty in the stand-in content and the inline
*> dialog has no NBT encoding of the SNBT argument in the docs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-PREFIX              PIC X(48) VALUE "commands.dialog.clear".
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-ID                  BINARY-LONG VALUE 142.
 01 WS-I                   BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-NO-LEAD             PIC X(64).
 01 WS-NO-LEAD-LENGTH      BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     IF BR-R-FAILED = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             CALL "CORE-SEND" USING PL-CONN(BX-ROW(WS-I)) PB-BUFFER
         END-PERFORM
         CALL "PB-FREE" USING PB-BUFFER
         CALL "BX-COUNT-MESSAGE" USING WS-PREFIX WS-ROWS WS-BROADCAST WS-NO-LEAD WS-NO-LEAD-LENGTH
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-DIALOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DIALOG.
*> The form of dialog (16 §8.10): clear.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DIALOG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "dialog clear <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DIALOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TEAMMSG.
*> teammsg <message> (16 §8.4, level 0; tm is an alias): the sender must be on a team, else commands.teammsg.failed.noteam; no team exists yet (the
*> scoreboard lane owns teams), so every sender fails and the delivery to a team is not done (BLOCKED outside this file: team state); result 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-KEY                 PIC X(72) VALUE "commands.teammsg.failed.noteam".
 PROCEDURE DIVISION.
     CALL "BA-RAISE-PLAIN" USING WS-KEY
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-TEAMMSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TEAMMSG.
*> The form of teammsg and its alias tm (16 §8.4, §14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TEAMMSG.
 01 WS-PATH                PIC X(256).
 01 WS-ALIAS               PIC X(32).
 01 WS-ALIAS-LENGTH        BINARY-LONG.
 01 WS-TARGET              PIC X(32) VALUE "teammsg".
 01 WS-TARGET-LENGTH       BINARY-LONG VALUE 7.
 PROCEDURE DIVISION.
     MOVE "teammsg <message:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "tm" TO WS-ALIAS
     MOVE 2 TO WS-ALIAS-LENGTH
     CALL "BR-REG-ALIAS" USING WS-ALIAS WS-ALIAS-LENGTH WS-TARGET WS-TARGET-LENGTH
     GOBACK.
 END PROGRAM CMDS-REG-TEAMMSG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-NAMESPACED.
*> USING index, id out (PIC X(64)), length out: the text of an identifier argument with the namespace (minecraft: is added when none was typed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-RAW                 PIC X(64).
 01 WS-COLONS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ID L-LENGTH.
     MOVE BA-START(L-INDEX) TO WS-START
     COMPUTE WS-LENGTH = FUNCTION MIN(BA-END(L-INDEX) - WS-START, 53)
     MOVE SPACES TO WS-RAW L-ID
     MOVE BR-R-LINE(WS-START + 1:WS-LENGTH) TO WS-RAW
     MOVE 0 TO WS-COLONS
     INSPECT WS-RAW(1:WS-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0
         STRING "minecraft:" WS-RAW(1:WS-LENGTH) DELIMITED BY SIZE INTO L-ID
         COMPUTE L-LENGTH = WS-LENGTH + 10
     ELSE
         MOVE WS-RAW TO L-ID
         MOVE WS-LENGTH TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BX-NAMESPACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFX-SEND.
*> USING player row: Post Effects 0x53 (the VarInt count, each identifier) with the effects of the player, sent to it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRPOSTFX.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ID                  BINARY-LONG VALUE 83.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER PFX-COUNT(L-ROW)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PFX-COUNT(L-ROW)
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER PFX-FX-ID(L-ROW, WS-K) PFX-FX-LENGTH(L-ROW, WS-K)
     END-PERFORM
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM PFX-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-POSTEFFECT.
*> posteffect add <targets> <id> | remove <targets> <id> | clear <targets> | list <target> (16 §8.11, level 2): each player keeps up to 8 post effects (BRPOSTFX.cpy,
*> per row and uuid); a player whose list changed is sent Post Effects (0x53, the whole list); add of an effect the player has (or a full list), remove of one it
*> has not and clear of an empty list change nothing; the players changed are counted: none is .add.failed / .remove.failed / .clear.failed, else
*> .add.success / .remove.success [effect, player or count] or .clear.success [player or count] is broadcast; the result is the number changed. list tells
*> .list.success [player, count, the effects joined by ", "] or .list.empty [player], not broadcast; its result is the number of effects.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY BRPOSTFX.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-ID             PIC X(32) VALUE "posteffect".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-CHANGED-ROWS.
    05 CH-COUNT             BINARY-LONG.
    05 CH-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SUB                 PIC X(64).
 01 WS-SUB-LENGTH          BINARY-LONG.
 01 WS-FX                  PIC X(64).
 01 WS-FX-LENGTH           BINARY-LONG.
 01 WS-NO-LEAD             PIC X(64).
 01 WS-LEAD-LENGTH         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-PREFIX              PIC X(48).
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-LIST                PIC X(600).
 01 WS-LIST-LENGTH         BINARY-LONG.
 01 WS-NAME-COPY           PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The entry of the player row WS-ROW belongs to that player: another uuid makes it empty.
 ENSURE-ENTRY.
     IF PFX-UUID(WS-ROW) NOT = PL-UUID(WS-ROW)
         MOVE PL-UUID(WS-ROW) TO PFX-UUID(WS-ROW)
         MOVE 0 TO PFX-COUNT(WS-ROW)
     END-IF.

*> WS-POS: the place of the effect WS-FX in the list of the player row WS-ROW, 0 when it has none.
 FIND-EFFECT.
     MOVE 0 TO WS-POS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PFX-COUNT(WS-ROW) OR WS-POS > 0
         IF PFX-FX-ID(WS-ROW, WS-K) = WS-FX
             MOVE WS-K TO WS-POS
         END-IF
     END-PERFORM.

*> The change of the player row WS-ROW by WS-SUB: WS-CHANGED 1 when its list changed.
 CHANGE-ONE.
     PERFORM ENSURE-ENTRY
     MOVE 0 TO WS-CHANGED
     EVALUATE WS-SUB
         WHEN "add"
             PERFORM FIND-EFFECT
             IF WS-POS = 0 AND PFX-COUNT(WS-ROW) < 8
                 ADD 1 TO PFX-COUNT(WS-ROW)
                 MOVE WS-FX TO PFX-FX-ID(WS-ROW, PFX-COUNT(WS-ROW))
                 MOVE WS-FX-LENGTH TO PFX-FX-LENGTH(WS-ROW, PFX-COUNT(WS-ROW))
                 MOVE 1 TO WS-CHANGED
             END-IF
         WHEN "remove"
             PERFORM FIND-EFFECT
             IF WS-POS > 0
                 PERFORM VARYING WS-K FROM WS-POS BY 1 UNTIL WS-K >= PFX-COUNT(WS-ROW)
                     MOVE PFX-FX(WS-ROW, WS-K + 1) TO PFX-FX(WS-ROW, WS-K)
                 END-PERFORM
                 SUBTRACT 1 FROM PFX-COUNT(WS-ROW)
                 MOVE 1 TO WS-CHANGED
             END-IF
         WHEN OTHER
             IF PFX-COUNT(WS-ROW) > 0
                 MOVE 0 TO PFX-COUNT(WS-ROW)
                 MOVE 1 TO WS-CHANGED
             END-IF
     END-EVALUATE
     IF WS-CHANGED = 1
         CALL "PFX-SEND" USING WS-ROW
         ADD 1 TO CH-COUNT
         MOVE WS-ROW TO CH-ROW(CH-COUNT)
     END-IF.

 LIST-EFFECTS.
     MOVE BX-ROW(1) TO WS-ROW
     PERFORM ENSURE-ENTRY
     MOVE PL-NAME(WS-ROW) TO WS-NAME-COPY
     MOVE PL-NAME-LENGTH(WS-ROW) TO WS-NAME-LENGTH
     IF PFX-COUNT(WS-ROW) = 0
         MOVE "commands.posteffect.list.empty" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME-COPY WS-NAME-LENGTH
     ELSE
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PFX-COUNT(WS-ROW)
             IF WS-K > 1
                 STRING ", " DELIMITED BY SIZE INTO WS-LIST POINTER WS-POS
             END-IF
             STRING PFX-FX-ID(WS-ROW, WS-K) DELIMITED BY SPACE INTO WS-LIST POINTER WS-POS
         END-PERFORM
         COMPUTE WS-LIST-LENGTH = WS-POS - 1
         MOVE "commands.posteffect.list.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME-COPY WS-NAME-LENGTH
         CALL "CMD-TEXT-INT" USING PB-TEXT PFX-COUNT(WS-ROW)
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-LIST WS-LIST-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE PFX-COUNT(WS-ROW) TO BR-R-RESULT.

 MAIN-LINE.
     MOVE BA-NAME(2) TO WS-SUB
     COMPUTE WS-SUB-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-SUB TRAILING))
     IF WS-SUB = "list"
         CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
         IF BR-R-FAILED = 0
             PERFORM LIST-EFFECTS
         END-IF
     ELSE
         CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
         IF BR-R-FAILED = 0
             MOVE 0 TO CH-COUNT WS-LEAD-LENGTH
             MOVE SPACES TO WS-FX WS-NO-LEAD
             IF WS-SUB NOT = "clear"
                 CALL "BX-FIND" USING WS-NAME-ID WS-INDEX
                 CALL "BX-NAMESPACED" USING WS-INDEX WS-FX WS-FX-LENGTH
                 MOVE WS-FX TO WS-NO-LEAD
                 MOVE WS-FX-LENGTH TO WS-LEAD-LENGTH
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
                 MOVE BX-ROW(WS-I) TO WS-ROW
                 PERFORM CHANGE-ONE
             END-PERFORM
             MOVE SPACES TO WS-PREFIX WS-KEY
             IF CH-COUNT = 0
                 STRING "commands.posteffect." WS-SUB(1:WS-SUB-LENGTH) ".failed" DELIMITED BY SIZE INTO WS-KEY
                 CALL "BA-RAISE-PLAIN" USING WS-KEY
             ELSE
                 STRING "commands.posteffect." WS-SUB(1:WS-SUB-LENGTH) ".success" DELIMITED BY SIZE INTO WS-PREFIX
                 CALL "BX-COUNT-MESSAGE" USING WS-PREFIX WS-CHANGED-ROWS WS-BROADCAST WS-NO-LEAD WS-LEAD-LENGTH
                 MOVE CH-COUNT TO BR-R-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-POSTEFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-POSTEFFECT.
*> The forms of posteffect (16 §8.11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-POSTEFFECT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "posteffect add <targets:players> <posteffect:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "posteffect remove <targets:players> <posteffect:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "posteffect clear <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "posteffect list <target:player>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-POSTEFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BO-FIND.
*> USING id (PIC X(64), with the namespace), bar out (BINARY-LONG): the table index of the custom bar with that id, 0 when none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRBOSS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   PIC X(64).
 01 L-BAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-BAR.
     MOVE 0 TO L-BAR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16 OR L-BAR > 0
         IF BO-USED(WS-I) = 1 AND BO-ID(WS-I) = L-ID
             MOVE WS-I TO L-BAR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BO-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BO-PACKET.
*> USING bar, operation (0 ADD, 1 REMOVE, 2 UPDATE_PROGRESS, 3 UPDATE_NAME, 4 UPDATE_STYLE), player row (0 = every player in play whose uuid is on the bar):
*> Boss Event 0x09 (05a): the bar's uuid (15 zero bytes and the index), the operation and its data (ADD: title, progress, color, overlay, flags 0; progress
*> is value / maximum, at most 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRBOSS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ID                  BINARY-LONG VALUE 9.
 01 WS-UUID                PIC X(16).
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-TEXT                PIC X(1024).
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-BAR                  BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BAR L-OP L-ROW.
     MOVE LOW-VALUES TO WS-UUID
     MOVE FUNCTION CHAR(L-BAR + 1) TO WS-UUID(16:1)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-OP
     COMPUTE WS-PROGRESS = FUNCTION MIN(1, BO-VALUE(L-BAR) / BO-MAX(L-BAR))
     MOVE SPACES TO WS-TEXT
     MOVE BO-NAME(L-BAR) TO WS-TEXT
     CALL "BX-LITERAL" USING WS-TEXT BO-NAME-LENGTH(L-BAR) PB-TEXT
     EVALUATE L-OP
         WHEN 0
             CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
             CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
             CALL "PB-PUT-VARINT" USING PB-BUFFER BO-COLOR(L-BAR)
             CALL "PB-PUT-VARINT" USING PB-BUFFER BO-STYLE(L-BAR)
             CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-FLAGS
         WHEN 2
             CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
         WHEN 3
             CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
         WHEN 4
             CALL "PB-PUT-VARINT" USING PB-BUFFER BO-COLOR(L-BAR)
             CALL "PB-PUT-VARINT" USING PB-BUFFER BO-STYLE(L-BAR)
     END-EVALUATE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
             MOVE 0 TO WS-ON
             IF L-ROW = 0
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BO-PLAYER-COUNT(L-BAR)
                     IF BO-PLAYER(L-BAR, WS-J) = PL-UUID(WS-ROW)
                         MOVE 1 TO WS-ON
                     END-IF
                 END-PERFORM
             ELSE
                 IF WS-ROW = L-ROW
                     MOVE 1 TO WS-ON
                 END-IF
             END-IF
             IF WS-ON = 1
                 CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BO-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-BOSSBAR.
*> bossbar add <id> <name> | remove <id> | list | set <id> name|color|style|value|max|visible|players ... | get <id> value|max|visible|players (16 §8.7, level 2),
*> on the custom bars of BRBOSS.cpy (at most 16; a full table is commands.bossbar.create.failed: the docs give no key for it). The messages and results are
*> those of the section (the bar in a message is its identifier; add and remove result in the number of bars, list the number, set value and max the
*> argument, set players the number of players on the bar, get the value asked, 1 or 0 for visible, the number of players online on the bar; the set
*> forms of name, color, style and visible 0; a value the bar already has is .unchanged; the sets and removes are broadcast, list is not, every get is).
*> Boss Event goes to the players of the bar (BO-PACKET): ADD when a player joins a visible bar or it is shown, REMOVE when a player leaves, it is hidden
*> or removed, UPDATE_PROGRESS for value and max, UPDATE_NAME, UPDATE_STYLE for color and style (inferred, 16 §8.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY BRBOSS.
 COPY PROTO.
 01 WS-NAME-ID             PIC X(32) VALUE "id".
 01 WS-NAME-NAME           PIC X(32) VALUE "name".
 01 WS-NAME-VALUE          PIC X(32) VALUE "value".
 01 WS-NAME-MAX            PIC X(32) VALUE "max".
 01 WS-NAME-VISIBLE        PIC X(32) VALUE "visible".
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SUB                 PIC X(64).
 01 WS-SUB4                PIC X(64).
 01 WS-LITERAL             PIC X(64).
 01 WS-BAR                 BINARY-LONG.
 01 WS-ID-TEXT             PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CHANGES             BINARY-LONG.
 01 WS-LIST                PIC X(1024).
 01 WS-LIST-LENGTH         BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NAME-COPY           PIC X(16).
 01 WS-NEW-COUNT           BINARY-LONG.
 01 WS-NEW-UUID            PIC X(16) OCCURS 16 TIMES.
 01 WS-OP                  BINARY-LONG.
 01 WS-WAS                BINARY-LONG.
 01 WS-IS                 BINARY-LONG.
 01 WS-OP-ADD              BINARY-LONG VALUE 0.
 01 WS-OP-REMOVE           BINARY-LONG VALUE 1.
 01 WS-OP-PROGRESS         BINARY-LONG VALUE 2.
 01 WS-OP-NAME             BINARY-LONG VALUE 3.
 01 WS-OP-STYLE            BINARY-LONG VALUE 4.
 01 WS-ALL                 BINARY-LONG VALUE 0.
 01 WS-COLORS.
    05 FILLER PIC X(8) VALUE "pink".
    05 FILLER PIC X(8) VALUE "blue".
    05 FILLER PIC X(8) VALUE "red".
    05 FILLER PIC X(8) VALUE "green".
    05 FILLER PIC X(8) VALUE "yellow".
    05 FILLER PIC X(8) VALUE "purple".
    05 FILLER PIC X(8) VALUE "white".
 01 WS-COLOR-TABLE REDEFINES WS-COLORS.
    05 WS-COLOR-NAME        PIC X(8) OCCURS 7 TIMES.
 01 WS-STYLES.
    05 FILLER PIC X(12) VALUE "progress".
    05 FILLER PIC X(12) VALUE "notched_6".
    05 FILLER PIC X(12) VALUE "notched_10".
    05 FILLER PIC X(12) VALUE "notched_12".
    05 FILLER PIC X(12) VALUE "notched_20".
 01 WS-STYLE-TABLE REDEFINES WS-STYLES.
    05 WS-STYLE-NAME        PIC X(12) OCCURS 5 TIMES.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with the identifier WS-ID-TEXT as its argument.
 FAIL-ID.
     MOVE SPACES TO WS-A1 WS-A2
     MOVE WS-ID-TEXT TO WS-A1
     CALL "BA-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-ID-LENGTH WS-A2 WS-L2.

*> The broadcast text WS-KEY with the identifier of the bar as its argument.
 SAY-ID.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID-TEXT WS-ID-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> The same with the number WS-NUMBER as a second argument.
 SAY-ID-NUMBER.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID-TEXT WS-ID-LENGTH
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-NUMBER
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> The same with the number of players and the names of WS-LIST (WS-LIST-LENGTH 0: no players, the .none key WS-KEY is used alone).
 SAY-ID-PLAYERS.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID-TEXT WS-ID-LENGTH
     IF WS-NUMBER > 0
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-NUMBER
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-LIST WS-LIST-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> WS-BAR: the bar of the id argument (WS-ID-TEXT, WS-ID-LENGTH); an unknown id fails with commands.bossbar.unknown.
 FIND-BAR.
     CALL "BX-FIND" USING WS-NAME-ID WS-INDEX
     CALL "BX-NAMESPACED" USING WS-INDEX WS-ID-TEXT WS-ID-LENGTH
     CALL "BO-FIND" USING WS-ID-TEXT WS-BAR
     IF WS-BAR = 0
         MOVE "commands.bossbar.unknown" TO WS-KEY
         PERFORM FAIL-ID
     END-IF.

 ADD-BAR.
     CALL "BX-FIND" USING WS-NAME-ID WS-INDEX
     CALL "BX-NAMESPACED" USING WS-INDEX WS-ID-TEXT WS-ID-LENGTH
     CALL "BO-FIND" USING WS-ID-TEXT WS-BAR
     IF WS-BAR > 0 OR BO-COUNT = 16
         MOVE "commands.bossbar.create.failed" TO WS-KEY
         PERFORM FAIL-ID
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL BO-USED(WS-I) = 0
             CONTINUE
         END-PERFORM
         ADD 1 TO BO-COUNT
         INITIALIZE BO-BAR(WS-I)
         MOVE 1 TO BO-USED(WS-I)
         MOVE WS-ID-TEXT TO BO-ID(WS-I)
         MOVE WS-ID-LENGTH TO BO-ID-LENGTH(WS-I)
         CALL "BX-FIND" USING WS-NAME-NAME WS-INDEX
         CALL "BX-COMPONENT" USING WS-INDEX WS-TEXT WS-LENGTH
         MOVE WS-TEXT TO BO-NAME(WS-I)
         MOVE WS-LENGTH TO BO-NAME-LENGTH(WS-I)
         MOVE 6 TO BO-COLOR(WS-I)
         MOVE 100 TO BO-MAX(WS-I)
         MOVE 1 TO BO-VISIBLE(WS-I)
         MOVE "commands.bossbar.create.success" TO WS-KEY
         PERFORM SAY-ID
         MOVE BO-COUNT TO BR-R-RESULT
     END-IF.

 REMOVE-BAR.
     PERFORM FIND-BAR
     IF BR-R-FAILED = 0
         CALL "BO-PACKET" USING WS-BAR WS-OP-REMOVE WS-ALL
         MOVE 0 TO BO-USED(WS-BAR)
         SUBTRACT 1 FROM BO-COUNT
         MOVE "commands.bossbar.remove.success" TO WS-KEY
         PERFORM SAY-ID
         MOVE BO-COUNT TO BR-R-RESULT
     END-IF.

 LIST-BARS.
     MOVE BO-COUNT TO WS-NUMBER
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-POINTER
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF BO-USED(WS-I) = 1
             ADD 1 TO WS-K
             IF WS-K > 1
                 STRING ", " DELIMITED BY SIZE INTO WS-LIST POINTER WS-POINTER
             END-IF
             STRING BO-ID(WS-I) DELIMITED BY SPACE INTO WS-LIST POINTER WS-POINTER
         END-IF
     END-PERFORM
     COMPUTE WS-LIST-LENGTH = WS-POINTER - 1
     IF BO-COUNT = 0
         MOVE "commands.bossbar.list.bars.none" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
     ELSE
         MOVE "commands.bossbar.list.bars.some" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-NUMBER
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-LIST WS-LIST-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE BO-COUNT TO BR-R-RESULT.

*> WS-LIST, WS-NUMBER: the names and the number of the online players whose uuid is in WS-NEW-UUID (WS-NEW-COUNT of them).
 NAME-PLAYERS.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-POINTER
     MOVE 0 TO WS-NUMBER
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NEW-COUNT
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
             IF PL-USED(WS-ROW) = 1 AND PL-UUID(WS-ROW) = WS-NEW-UUID(WS-J)
                 ADD 1 TO WS-NUMBER
                 IF WS-NUMBER > 1
                     STRING ", " DELIMITED BY SIZE INTO WS-LIST POINTER WS-POINTER
                 END-IF
                 MOVE PL-NAME(WS-ROW) TO WS-NAME-COPY
                 STRING WS-NAME-COPY DELIMITED BY SPACE INTO WS-LIST POINTER WS-POINTER
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-LIST-LENGTH = WS-POINTER - 1.

 SET-BAR.
     PERFORM FIND-BAR
     IF BR-R-FAILED = 0
         MOVE BA-NAME(4) TO WS-SUB4
         EVALUATE WS-SUB4
             WHEN "value"
                 PERFORM SET-VALUE
             WHEN "max"
                 PERFORM SET-MAX
             WHEN "name"
                 PERFORM SET-NAME
             WHEN "color"
                 PERFORM SET-COLOR
             WHEN "style"
                 PERFORM SET-STYLE
             WHEN "visible"
                 PERFORM SET-VISIBLE
             WHEN OTHER
                 PERFORM SET-PLAYERS
         END-EVALUATE
     END-IF.

 SET-VALUE.
     CALL "BX-FIND" USING WS-NAME-VALUE WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-NUMBER
     IF WS-NUMBER = BO-VALUE(WS-BAR)
         MOVE "commands.bossbar.set.value.unchanged" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-NUMBER TO BO-VALUE(WS-BAR)
         CALL "BO-PACKET" USING WS-BAR WS-OP-PROGRESS WS-ALL
         MOVE "commands.bossbar.set.value.success" TO WS-KEY
         PERFORM SAY-ID-NUMBER
         MOVE WS-NUMBER TO BR-R-RESULT
     END-IF.

 SET-MAX.
     CALL "BX-FIND" USING WS-NAME-MAX WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-NUMBER
     IF WS-NUMBER = BO-MAX(WS-BAR)
         MOVE "commands.bossbar.set.max.unchanged" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-NUMBER TO BO-MAX(WS-BAR)
         CALL "BO-PACKET" USING WS-BAR WS-OP-PROGRESS WS-ALL
         MOVE "commands.bossbar.set.max.success" TO WS-KEY
         PERFORM SAY-ID-NUMBER
         MOVE WS-NUMBER TO BR-R-RESULT
     END-IF.

 SET-NAME.
     CALL "BX-FIND" USING WS-NAME-NAME WS-INDEX
     CALL "BX-COMPONENT" USING WS-INDEX WS-TEXT WS-LENGTH
     IF WS-LENGTH = BO-NAME-LENGTH(WS-BAR) AND WS-TEXT(1:256) = BO-NAME(WS-BAR)
         MOVE "commands.bossbar.set.name.unchanged" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-TEXT TO BO-NAME(WS-BAR)
         MOVE WS-LENGTH TO BO-NAME-LENGTH(WS-BAR)
         CALL "BO-PACKET" USING WS-BAR WS-OP-NAME WS-ALL
         MOVE "commands.bossbar.set.name.success" TO WS-KEY
         PERFORM SAY-ID
         MOVE 0 TO BR-R-RESULT
     END-IF.

 SET-COLOR.
     MOVE BA-NAME(5) TO WS-LITERAL
     MOVE 0 TO WS-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF WS-COLOR-NAME(WS-I) = WS-LITERAL
             COMPUTE WS-NUMBER = WS-I - 1
         END-IF
     END-PERFORM
     IF WS-NUMBER = BO-COLOR(WS-BAR)
         MOVE "commands.bossbar.set.color.unchanged" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-NUMBER TO BO-COLOR(WS-BAR)
         CALL "BO-PACKET" USING WS-BAR WS-OP-STYLE WS-ALL
         MOVE "commands.bossbar.set.color.success" TO WS-KEY
         PERFORM SAY-ID
         MOVE 0 TO BR-R-RESULT
     END-IF.

 SET-STYLE.
     MOVE BA-NAME(5) TO WS-LITERAL
     MOVE 0 TO WS-NUMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF WS-STYLE-NAME(WS-I) = WS-LITERAL
             COMPUTE WS-NUMBER = WS-I - 1
         END-IF
     END-PERFORM
     IF WS-NUMBER = BO-STYLE(WS-BAR)
         MOVE "commands.bossbar.set.style.unchanged" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-NUMBER TO BO-STYLE(WS-BAR)
         CALL "BO-PACKET" USING WS-BAR WS-OP-STYLE WS-ALL
         MOVE "commands.bossbar.set.style.success" TO WS-KEY
         PERFORM SAY-ID
         MOVE 0 TO BR-R-RESULT
     END-IF.

 SET-VISIBLE.
     CALL "BX-FIND" USING WS-NAME-VISIBLE WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-NUMBER
     IF WS-NUMBER = BO-VISIBLE(WS-BAR)
         IF WS-NUMBER = 1
             MOVE "commands.bossbar.set.visibility.unchanged.visible" TO WS-KEY
         ELSE
             MOVE "commands.bossbar.set.visibility.unchanged.hidden" TO WS-KEY
         END-IF
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-NUMBER TO BO-VISIBLE(WS-BAR)
         IF WS-NUMBER = 1
             CALL "BO-PACKET" USING WS-BAR WS-OP-ADD WS-ALL
             MOVE "commands.bossbar.set.visible.success.visible" TO WS-KEY
         ELSE
             CALL "BO-PACKET" USING WS-BAR WS-OP-REMOVE WS-ALL
             MOVE "commands.bossbar.set.visible.success.hidden" TO WS-KEY
         END-IF
         PERFORM SAY-ID
         MOVE 0 TO BR-R-RESULT
     END-IF.

*> set players [<targets>]: the new list of uuids; players added are sent ADD (a visible bar), players left REMOVE.
 SET-PLAYERS.
     MOVE 0 TO WS-NEW-COUNT BX-COUNT
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     IF WS-INDEX > 0
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
         COMPUTE WS-NEW-COUNT = FUNCTION MIN(BX-COUNT, 16)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NEW-COUNT
             MOVE PL-UUID(BX-ROW(WS-I)) TO WS-NEW-UUID(WS-I)
         END-PERFORM
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-CHANGES
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BO-PLAYER-COUNT(WS-BAR)
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NEW-COUNT
                 IF WS-NEW-UUID(WS-J) = BO-PLAYER(WS-BAR, WS-I)
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 ADD 1 TO WS-CHANGES
             END-IF
         END-PERFORM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NEW-COUNT
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BO-PLAYER-COUNT(WS-BAR)
                 IF WS-NEW-UUID(WS-J) = BO-PLAYER(WS-BAR, WS-I)
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 ADD 1 TO WS-CHANGES
             END-IF
         END-PERFORM
         IF WS-CHANGES = 0
             MOVE "commands.bossbar.set.players.unchanged" TO WS-KEY
             CALL "BA-RAISE-PLAIN" USING WS-KEY
         ELSE
             PERFORM APPLY-PLAYERS
         END-IF
     END-IF.

 APPLY-PLAYERS.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
             MOVE 0 TO WS-WAS WS-IS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BO-PLAYER-COUNT(WS-BAR)
                 IF BO-PLAYER(WS-BAR, WS-I) = PL-UUID(WS-ROW)
                     MOVE 1 TO WS-WAS
                 END-IF
             END-PERFORM
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NEW-COUNT
                 IF WS-NEW-UUID(WS-J) = PL-UUID(WS-ROW)
                     MOVE 1 TO WS-IS
                 END-IF
             END-PERFORM
             IF WS-WAS = 1 AND WS-IS = 0
                 CALL "BO-PACKET" USING WS-BAR WS-OP-REMOVE WS-ROW
             END-IF
             IF WS-WAS = 0 AND WS-IS = 1 AND BO-VISIBLE(WS-BAR) = 1
                 CALL "BO-PACKET" USING WS-BAR WS-OP-ADD WS-ROW
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-NEW-COUNT TO BO-PLAYER-COUNT(WS-BAR)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NEW-COUNT
         MOVE WS-NEW-UUID(WS-I) TO BO-PLAYER(WS-BAR, WS-I)
     END-PERFORM
     PERFORM NAME-PLAYERS
     IF WS-NUMBER = 0
         MOVE "commands.bossbar.set.players.success.none" TO WS-KEY
     ELSE
         MOVE "commands.bossbar.set.players.success.some" TO WS-KEY
     END-IF
     PERFORM SAY-ID-PLAYERS
     MOVE WS-NUMBER TO BR-R-RESULT.

 GET-BAR.
     PERFORM FIND-BAR
     IF BR-R-FAILED = 0
         MOVE BA-NAME(4) TO WS-SUB4
         EVALUATE WS-SUB4
             WHEN "value"
                 MOVE BO-VALUE(WS-BAR) TO WS-NUMBER
                 MOVE "commands.bossbar.get.value" TO WS-KEY
                 PERFORM SAY-ID-NUMBER
             WHEN "max"
                 MOVE BO-MAX(WS-BAR) TO WS-NUMBER
                 MOVE "commands.bossbar.get.max" TO WS-KEY
                 PERFORM SAY-ID-NUMBER
             WHEN "visible"
                 MOVE BO-VISIBLE(WS-BAR) TO WS-NUMBER
                 IF WS-NUMBER = 1
                     MOVE "commands.bossbar.get.visible.visible" TO WS-KEY
                 ELSE
                     MOVE "commands.bossbar.get.visible.hidden" TO WS-KEY
                 END-IF
                 PERFORM SAY-ID
             WHEN OTHER
                 MOVE BO-PLAYER-COUNT(WS-BAR) TO WS-NEW-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NEW-COUNT
                     MOVE BO-PLAYER(WS-BAR, WS-I) TO WS-NEW-UUID(WS-I)
                 END-PERFORM
                 PERFORM NAME-PLAYERS
                 IF WS-NUMBER = 0
                     MOVE "commands.bossbar.get.players.none" TO WS-KEY
                 ELSE
                     MOVE "commands.bossbar.get.players.some" TO WS-KEY
                 END-IF
                 PERFORM SAY-ID-PLAYERS
         END-EVALUATE
         MOVE WS-NUMBER TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     MOVE BA-NAME(2) TO WS-SUB
     EVALUATE WS-SUB
         WHEN "add"
             PERFORM ADD-BAR
         WHEN "remove"
             PERFORM REMOVE-BAR
         WHEN "list"
             PERFORM LIST-BARS
         WHEN "set"
             PERFORM SET-BAR
         WHEN OTHER
             PERFORM GET-BAR
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-BOSSBAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-BOSSBAR.
*> The forms of bossbar (16 §8.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-BOSSBAR.
 01 WS-PATH                PIC X(256).
 01 WS-COLORS.
    05 FILLER PIC X(8) VALUE "pink".
    05 FILLER PIC X(8) VALUE "blue".
    05 FILLER PIC X(8) VALUE "red".
    05 FILLER PIC X(8) VALUE "green".
    05 FILLER PIC X(8) VALUE "yellow".
    05 FILLER PIC X(8) VALUE "purple".
    05 FILLER PIC X(8) VALUE "white".
 01 WS-COLOR-TABLE REDEFINES WS-COLORS.
    05 WS-COLOR-NAME        PIC X(8) OCCURS 7 TIMES.
 01 WS-STYLES.
    05 FILLER PIC X(12) VALUE "progress".
    05 FILLER PIC X(12) VALUE "notched_6".
    05 FILLER PIC X(12) VALUE "notched_10".
    05 FILLER PIC X(12) VALUE "notched_12".
    05 FILLER PIC X(12) VALUE "notched_20".
 01 WS-STYLE-TABLE REDEFINES WS-STYLES.
    05 WS-STYLE-NAME        PIC X(12) OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "bossbar add <id:resloc> <name:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar remove <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar list" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar set <id:resloc> name <name:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-PATH
         STRING "bossbar set <id:resloc> color " FUNCTION TRIM(WS-COLOR-NAME(WS-I)) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE SPACES TO WS-PATH
         STRING "bossbar set <id:resloc> style " FUNCTION TRIM(WS-STYLE-NAME(WS-I)) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     MOVE "bossbar set <id:resloc> value <value:int:0:>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar set <id:resloc> max <max:int:1:>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar set <id:resloc> visible <visible:bool>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar set <id:resloc> players" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar set <id:resloc> players <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar get <id:resloc> value" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar get <id:resloc> max" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar get <id:resloc> visible" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "bossbar get <id:resloc> players" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-BOSSBAR.
