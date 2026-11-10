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
