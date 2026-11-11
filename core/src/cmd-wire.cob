*> The wire side of the commands (docs/protocol/15-commands-framework.md §3.3, §13, §14; 05a Chat Command 0x07, Commands 0x10,
*> Command Suggestion 0x0F): the packets go through the command framework (core/src/cmd-*.cob); the commands are core/src/cmds-*.cob.
*>
*> Senders: a player row, or 0 for the console (operator permission, replies printed as console lines through their en_us text).
*>
*> Entry points:
*>   CMD-RUN-PACKET USING connection id, PLAY-SERVERBOUND       Chat Command 0x07: the player runs the line (CMD-RUN)
*>   CMD-RUN USING sender, line (PIC X(768), no leading /), byte length: BR-EXECUTE; the result of the command is dropped
*>   CMD-SUGGEST USING connection id, PLAY-SERVERBOUND          Command Suggestion 0x0F: BR-SUGGEST on the text, the answer
*>     is Command Suggestions with the range counted in the text (a leading / included)
*>   CMD-TREE-SEND USING player row: the Commands packet for the player's permission level (BR-TREE-BUILD), on joining and
*>     when the level changes
*>   CMD-TELL USING recipient (player row, 0 = the console), PB-TEXT: a message to a player (System Chat) or the console

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RUN-PACKET.
*> 15 §13.1: a text with a character that is not allowed in chat (U+00A7, below U+0020, U+007F) disconnects the player with
*> multiplayer.disconnect.illegal_characters and runs nothing; otherwise the player runs the line with their own source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-MESSAGE-LENGTH
         COMPUTE WS-BYTE = FUNCTION ORD(PSB-MESSAGE(WS-I:1)) - 1
         IF WS-BYTE < 32 OR WS-BYTE = 127
             MOVE 1 TO WS-BAD
         END-IF
         IF WS-BYTE = 194 AND WS-I < PSB-MESSAGE-LENGTH
             IF FUNCTION ORD(PSB-MESSAGE(WS-I + 1:1)) = 168
                 MOVE 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     IF WS-BAD = 1
         INITIALIZE PK-TEXT
         MOVE PK-TEXT-TRANSLATE TO PK-TX-KIND
         MOVE "multiplayer.disconnect.illegal_characters" TO PK-TX-VALUE
         MOVE 41 TO PK-TX-LENGTH
         CALL "CORE-SEND-DISCONNECT" USING L-ID PK-TEXT
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "CMD-RUN" USING WS-ROW PSB-MESSAGE PSB-MESSAGE-LENGTH
     GOBACK.
 END PROGRAM CMD-RUN-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 01 L-LINE                 PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-LINE L-LENGTH.
     CALL "BR-EXECUTE" USING L-SENDER L-LINE L-LENGTH WS-RESULT
     GOBACK.
 END PROGRAM CMD-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-TEXT.
     CALL "BR-TELL" USING L-ROW PB-TEXT
     GOBACK.
 END PROGRAM CMD-TELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TREE-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BR-TREE-ENSURE"
     CALL "BR-SOURCE-LEVEL" USING L-ROW WS-LEVEL
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BR-TREE-BUILD" USING WS-LEVEL PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-TREE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SUGGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRIGADIER.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CURSOR              BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     CALL "BR-TREE-ENSURE"
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "BR-SOURCE-LEVEL" USING WS-ROW WS-LEVEL
     MOVE 0 TO WS-SLASH
     IF PSB-MESSAGE-LENGTH > 0 AND PSB-MESSAGE(1:1) = "/"
         MOVE 1 TO WS-SLASH
     END-IF
     MOVE SPACES TO WS-LINE
     COMPUTE WS-LENGTH = PSB-MESSAGE-LENGTH - WS-SLASH
     IF WS-LENGTH > 0
         MOVE PSB-MESSAGE(WS-SLASH + 1:WS-LENGTH) TO WS-LINE
     END-IF
     MOVE WS-LENGTH TO WS-CURSOR
     CALL "BR-SUGGEST" USING WS-LEVEL WS-LINE WS-LENGTH WS-CURSOR
     IF BR-SG-COUNT > 0
         ADD WS-SLASH TO BR-SG-START
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BR-SUGGESTIONS-BUILD" USING PSB-TRANSACTION PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-SUGGEST.
