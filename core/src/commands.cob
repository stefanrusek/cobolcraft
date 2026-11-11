*> Commands (US14; FR-016; standin-content §16; docs/protocol/09-cobolcraft-profile.md §3.3 Commands
*> rows and "Command tree"; contracts/wire-profile.md §3.3). The command set, its tree and usage
*> strings are core/copy/COMMANDS.cpy; the reply keys core/copy/MESSAGES.cpy (MK-*); the parsed line
*> core/copy/CMDPARSE.cpy.
*>
*> Senders: a player row, or 0 for the console (operator permission, replies printed as console
*> lines through their en_us text, operator-surface §3).
*>
*> Parsing (CMD-PARSE, §16.1 order of checks): the line is split into words at single spaces; an
*> unknown first word is `unknown` [word]; a command the sender may not use (CMD-PERMITTED) is
*> `not_permitted` [name]; then the words are matched down the command tree: a literal child whose
*> name equals the word, else the argument child when the word parses (integer and double: an
*> optional `-`, digits and for a double at most one `.`, within the node's range; single word: any
*> non-empty word; game_profile: any non-empty word, its validity being the command's own check;
*> greedy phrase: the rest of the line as written). Words running out at a node that is not
*> executable is `missing_argument` [usage]; a word no child takes (also extra words after the last
*> argument) is `invalid_argument` [word, usage]. A y argument must also lie from the dimension's
*> min_y to min_y + height - 2 (§16.2 ranges), the dimension being the one the line names when it
*> names an enabled one, else the sender's (the console's: main; homestead: always main). The usage
*> is that of the first usage form of the command whose fixed words equal the words typed so far
*> (before the offending word) (§16.4).
*>
*> Running (CMD-RUN): a parsed line runs its command, CMD-<NAME> (CMD-HOWTO ... CMD-SHUTDOWN, one
*> program per §16.2 command), which makes the command's own checks in the order of its row (the
*> first failing one replies and nothing changes), acts, and confirms to the sender with the row's
*> confirmation key. Shared checks: CMD-IDENTITY (a valid name and its offline UUID), CMD-TARGET (a
*> player online in this world, §16.1 target rule), CMD-DIMENSION (an enabled dimension),
*> CMD-IS-HOST (the host of a client-hosted world).
*>
*> The command tree (CMD-TREE-BUILD, CMD-TREE-SEND) is sent on joining and when operator status
*> changes; Command Suggestion is answered by CMD-SUGGEST (§16.3, 09 §3.4 rule 5).
*>
*> Entry points:
*>   CMD-RUN USING sender, line (PIC X(768)), byte length
*>   CMD-RUN-PACKET USING connection id, PLAY-SERVERBOUND        Chat Command 0x07
*>   CMD-SUGGEST USING connection id, PLAY-SERVERBOUND           Command Suggestion 0x0F
*>   CMD-TREE-SEND USING player row
*>   CMD-PARSE USING sender, line (PIC X(768)), byte length, PB-TEXT out (the refusal reply;
*>     PB-TX-LENGTH 0 when the line parsed)
*>   CMD-PERMITTED USING sender, permission (CMD-EVERYONE or CMD-OPERATOR), ok out (BINARY-LONG)
*>   CMD-TELL USING player row (0 = the console), PB-TEXT           a message to a player
*> Builders (append id + body to the caller's PB-BUFFER):
*>   CMD-TREE-BUILD USING operator (1 or 0), PB-BUFFER             Commands 0x10
*>   CMD-SUGGESTIONS-BUILD USING transaction id, PB-BUFFER          Command Suggestions 0x0F
*> Reply text helpers (PB-TEXT): CMD-TEXT-KEY USING PB-TEXT, MK-* index (a translate text with no
*> arguments yet); then each adds one literal argument: CMD-TEXT-WORD USING PB-TEXT, word index;
*> CMD-TEXT-INT USING PB-TEXT, integer; CMD-TEXT-DOUBLE USING PB-TEXT, double (two decimals, half
*> away from zero); CMD-TEXT-USAGE USING PB-TEXT (CQ-USAGE); CMD-TEXT-ARG USING PB-TEXT, area,
*> byte length.
*> Internal: CMD-CHILD, CMD-NUMBER, CMD-USAGE-FIND, CMD-FIND-DIM, CMD-ONLINE, CMD-FIND-ONLINE,
*> CMD-FIND-ITEM, CMD-FIND-MOB, CMD-SUGGEST-ADD, CMD-REPLY, CMD-SAY, CMD-SAY-WORD, CMD-SAY-NAME,
*> CMD-NOTICE, CMD-ACCESS-ADD, CMD-LIST-EDIT, CMD-NAMES-ARG, CMD-MOVE-PLAYER, CMD-SEND-INVENTORY,
*> CMD-SURVIVOR, CMD-AMOUNT, CMD-TO-PLAYERS, CMD-TEXT-DIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RUN-PACKET.
*> USING connection id, PLAY-SERVERBOUND (a decoded Chat Command 0x07): the player runs the command
*> line (CMD-RUN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "CMD-RUN" USING WS-ROW PSB-MESSAGE PSB-MESSAGE-LENGTH
     GOBACK.
 END PROGRAM CMD-RUN-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RUN.
*> USING sender (player row, 0 = the console), line (PIC X(768), without a leading `/`), byte
*> length: parses the line (CMD-PARSE); a refused line sends its reply to the sender and changes
*> nothing; a parsed one runs its command (CMD-<name>, which makes the command's own checks in the
*> order of its §16.2 row, then acts and confirms).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 01 L-LINE                 PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-LINE L-LENGTH.
     CALL "CMD-PARSE" USING L-SENDER L-LINE L-LENGTH PB-TEXT
     IF PB-TX-LENGTH > 0
         CALL "CMD-REPLY" USING PB-TEXT
         GOBACK
     END-IF
     EVALUATE CD-NAME(CQ-COMMAND)
         WHEN "howto"
             CALL "CMD-HOWTO"
         WHEN "roster"
             CALL "CMD-ROSTER"
         WHEN "murmur"
             CALL "CMD-MURMUR"
         WHEN "promote"
             CALL "CMD-PROMOTE"
         WHEN "demote"
             CALL "CMD-DEMOTE"
         WHEN "eject"
             CALL "CMD-EJECT"
         WHEN "bar"
             CALL "CMD-BAR"
         WHEN "unbar"
             CALL "CMD-UNBAR"
         WHEN "barlist"
             CALL "CMD-BARLIST"
         WHEN "guestlist"
             CALL "CMD-GUESTLIST"
         WHEN "mode"
             CALL "CMD-MODE"
         WHEN "relocate"
             CALL "CMD-RELOCATE"
         WHEN "supply"
             CALL "CMD-SUPPLY"
         WHEN "empty"
             CALL "CMD-EMPTY"
         WHEN "vitality"
             CALL "CMD-VITALITY"
         WHEN "ration"
             CALL "CMD-RATION"
         WHEN "conjure"
             CALL "CMD-CONJURE"
         WHEN "sweep"
             CALL "CMD-SWEEP"
         WHEN "clock"
             CALL "CMD-CLOCK"
         WHEN "skies"
             CALL "CMD-SKIES"
         WHEN "homestead"
             CALL "CMD-HOMESTEAD"
         WHEN "announce"
             CALL "CMD-ANNOUNCE"
         WHEN "persist"
             CALL "CMD-PERSIST"
         WHEN OTHER
             CALL "CMD-SHUTDOWN"
     END-EVALUATE
     GOBACK.
 END PROGRAM CMD-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-REPLY.
*> USING PB-TEXT: the text to the sender of the command being run (CQ-SENDER): System Chat to a
*> player, a console line for the console (§16.1 feedback).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT.
     CALL "CMD-TELL" USING CQ-SENDER PB-TEXT
     GOBACK.
 END PROGRAM CMD-REPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TELL.
*> USING recipient (player row, 0 = the console), PB-TEXT: System Chat (overlay false) to the
*> player, or the text as a console line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-TEXT.
     IF L-ROW = 0
         CALL "CONSOLE-TEXT" USING PB-TEXT
         GOBACK
     END-IF
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "SYSTEM-CHAT-BUILD" USING PB-TEXT PK-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PK-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM CMD-TELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SAY.
*> USING message (MK-* index): replies with that key and no arguments.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-MESSAGE              BINARY-LONG.
 PROCEDURE DIVISION USING L-MESSAGE.
     CALL "CMD-TEXT-KEY" USING PB-TEXT L-MESSAGE
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SAY-WORD.
*> USING message (MK-* index), word index: replies with that key and the word as typed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-MESSAGE              BINARY-LONG.
 01 L-WORD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-MESSAGE L-WORD.
     CALL "CMD-TEXT-KEY" USING PB-TEXT L-MESSAGE
     CALL "CMD-TEXT-WORD" USING PB-TEXT L-WORD
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SAY-WORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-IDENTITY.
*> USING word index, name out (PIC X(16)), length out, offline UUID out (PIC X(16)), ok out
*> (BINARY-LONG): a name argument that is valid as a login name (§16.1; LOGIN-NAME-VALID) and the
*> identity it stands for, online or not (02 Offline mode); otherwise the reply invalid_name [word]
*> and ok 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 COPY MESSAGES.
 01 WS-MSG                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-NAME L-LENGTH L-UUID L-OK.
     MOVE CQ-WORD-LENGTH(L-WORD) TO L-LENGTH
     MOVE CQ-WORD-START(L-WORD) TO WS-START
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-OK
     IF L-LENGTH >= 1 AND L-LENGTH <= 16
         MOVE CQ-LINE(WS-START:L-LENGTH) TO L-NAME
         CALL "LOGIN-NAME-VALID" USING L-NAME L-LENGTH L-OK
     END-IF
     IF L-OK = 0
         MOVE MK-INVALID-NAME TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG L-WORD
         GOBACK
     END-IF
     CALL "LOGIN-OFFLINE-UUID" USING L-NAME L-LENGTH L-UUID
     GOBACK.
 END PROGRAM CMD-IDENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TARGET.
*> USING word index, player row out (BINARY-LONG; 0 when refused): a player in the world named by
*> the word (§16.1 target rule): the name must be valid (else invalid_name) and a player with exactly
*> that name must be online in this world (else player_not_found [name]).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-ROW.
     MOVE 0 TO L-ROW
     CALL "CMD-IDENTITY" USING L-WORD WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "PLAYER-FIND-NAME" USING WS-NAME WS-LENGTH L-ROW
     IF L-ROW > 0
         IF CN-PHASE(PL-CONN(L-ROW)) NOT = PH-PLAY
             MOVE 0 TO L-ROW
         END-IF
     END-IF
     IF L-ROW = 0
         MOVE MK-PLAYER-NOT-FOUND TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG L-WORD
     END-IF
     GOBACK.
 END PROGRAM CMD-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-DIMENSION.
*> USING word index (0 = the argument was left out), dimension row out (BINARY-LONG; 0 when
*> refused): the enabled dimension the word names (else dimension_not_found [word]); left out, the
*> sender's dimension for a player and cobolcraft:main for the console (§16.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY DIMENSIONS.
 01 WS-MSG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-ROW.
     IF L-WORD = 0
         MOVE DIM-MAIN TO L-ROW
         IF CQ-SENDER > 0
             MOVE PL-DIM(CQ-SENDER) TO L-ROW
         END-IF
         GOBACK
     END-IF
     CALL "CMD-FIND-DIM" USING L-WORD L-ROW
     IF L-ROW = 0
         MOVE MK-DIMENSION-NOT-FOUND TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG L-WORD
     END-IF
     GOBACK.
 END PROGRAM CMD-DIMENSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-IS-HOST.
*> USING name (PIC X(16)), byte length, host out (BINARY-LONG): 1, after the reply is_host [name],
*> when the name is the host's in a world hosted by the client (host kinds 1 and 2; §16.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-MSG                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-HOST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-HOST.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO L-HOST
     IF CS-HOST-KIND > 0 AND L-NAME = CS-HOST-NAME
         MOVE 1 TO L-HOST
         MOVE MK-IS-HOST TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         CALL "CMD-TEXT-ARG" USING PB-TEXT L-NAME L-LENGTH
         CALL "CMD-REPLY" USING PB-TEXT
     END-IF
     GOBACK.
 END PROGRAM CMD-IS-HOST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-PARSE.
*> USING sender, line, byte length, PB-TEXT out: the parsing above; the result is in CMD-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY DIMENSIONS.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SENDER               BINARY-LONG.
 01 L-LINE                 PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-LINE L-LENGTH PB-TEXT.
     INITIALIZE PB-TEXT
     MOVE L-SENDER TO CQ-SENDER
     MOVE L-LINE TO CQ-LINE
     MOVE L-LENGTH TO CQ-LINE-LENGTH
     MOVE 0 TO CQ-COMMAND CQ-USAGE CQ-STEP-COUNT
*>   The words.
     MOVE 1 TO CQ-WORD-COUNT
     MOVE 1 TO CQ-WORD-START(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         IF L-LINE(WS-I:1) = SPACE
             COMPUTE CQ-WORD-LENGTH(CQ-WORD-COUNT) = WS-I - CQ-WORD-START(CQ-WORD-COUNT)
             ADD 1 TO CQ-WORD-COUNT
             COMPUTE CQ-WORD-START(CQ-WORD-COUNT) = WS-I + 1
         END-IF
     END-PERFORM
     COMPUTE CQ-WORD-LENGTH(CQ-WORD-COUNT) = L-LENGTH + 1 - CQ-WORD-START(CQ-WORD-COUNT)
*>   (1) The command name, (2) the permission.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CMD-COUNT OR CQ-COMMAND > 0
         MOVE CD-NAME-LENGTH(WS-I) TO WS-COUNT
         IF WS-COUNT = CQ-WORD-LENGTH(1)
             IF CD-NAME(WS-I)(1:WS-COUNT) = L-LINE(1:WS-COUNT)
                 MOVE WS-I TO CQ-COMMAND
             END-IF
         END-IF
     END-PERFORM
     IF CQ-COMMAND = 0
         MOVE MK-UNKNOWN TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         MOVE 1 TO WS-W
         CALL "CMD-TEXT-WORD" USING PB-TEXT WS-W
         GOBACK
     END-IF
     CALL "CMD-PERMITTED" USING L-SENDER CD-PERMISSION(CQ-COMMAND) WS-OK
     IF WS-OK = 0
         MOVE MK-NOT-PERMITTED TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         CALL "CMD-TEXT-ARG" USING PB-TEXT CD-NAME(CQ-COMMAND) CD-NAME-LENGTH(CQ-COMMAND)
         GOBACK
     END-IF
*>   (3) The arguments, down the tree.
     MOVE CD-NODE(CQ-COMMAND) TO WS-NODE
     MOVE 2 TO WS-W
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         EVALUATE TRUE
             WHEN WS-W > CQ-WORD-COUNT AND CT-EXEC(WS-NODE) = 1
                 MOVE 1 TO WS-DONE
             WHEN WS-W > CQ-WORD-COUNT
                 MOVE WS-NODE TO CQ-NODE
                 MOVE CQ-WORD-COUNT TO WS-COUNT
                 CALL "CMD-USAGE-FIND" USING WS-COUNT
                 MOVE MK-MISSING-ARGUMENT TO WS-MSG
                 CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
                 CALL "CMD-TEXT-USAGE" USING PB-TEXT
                 GOBACK
             WHEN OTHER
                 CALL "CMD-CHILD" USING WS-NODE WS-W WS-CHILD
                 IF WS-CHILD = 0
                     COMPUTE WS-COUNT = WS-W - 1
                     CALL "CMD-USAGE-FIND" USING WS-COUNT
                     MOVE MK-INVALID-ARGUMENT TO WS-MSG
                     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
                     CALL "CMD-TEXT-WORD" USING PB-TEXT WS-W
                     CALL "CMD-TEXT-USAGE" USING PB-TEXT
                     GOBACK
                 END-IF
                 ADD 1 TO CQ-STEP-COUNT
                 MOVE WS-CHILD TO WS-NODE
                 ADD 1 TO WS-W
                 IF CT-PARSER(WS-NODE) = 5 AND CT-STRING-KIND(WS-NODE) = 2
                     COMPUTE WS-W = CQ-WORD-COUNT + 1
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE WS-NODE TO CQ-NODE
*>   The y arguments against the dimension's height.
     MOVE DIM-MAIN TO WS-DIM
     IF L-SENDER > 0 AND CD-NAME(CQ-COMMAND) NOT = "homestead"
         MOVE PL-DIM(L-SENDER) TO WS-DIM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CQ-STEP-COUNT
         IF CT-NAME(CQ-STEP-NODE(WS-I)) = "dimension"
             COMPUTE WS-W = WS-I + 1
             CALL "CMD-FIND-DIM" USING WS-W WS-FOUND
             IF WS-FOUND > 0
                 MOVE WS-FOUND TO WS-DIM
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-LOW = DM-MIN-Y(WS-DIM)
     COMPUTE WS-HIGH = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CQ-STEP-COUNT
         MOVE CQ-STEP-NODE(WS-I) TO WS-NODE
         IF CT-PARSER(WS-NODE) = 2 AND CT-NAME(WS-NODE)(1:1) = "y"
             IF CQ-STEP-DOUBLE(WS-I) < WS-LOW OR CQ-STEP-DOUBLE(WS-I) > WS-HIGH
                 MOVE WS-I TO WS-COUNT
                 CALL "CMD-USAGE-FIND" USING WS-COUNT
                 MOVE MK-INVALID-ARGUMENT TO WS-MSG
                 CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
                 COMPUTE WS-W = WS-I + 1
                 CALL "CMD-TEXT-WORD" USING PB-TEXT WS-W
                 CALL "CMD-TEXT-USAGE" USING PB-TEXT
                 GOBACK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-CHILD.
*> USING tree node, word index, child out (BINARY-LONG; 0 = no child takes the word): the literal
*> child whose name is the word, else the argument child when the word parses (see above). The
*> child and its value are stored as the next step, CQ-STEP(CQ-STEP-COUNT + 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 01 WS-N                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-WORD                 BINARY-LONG.
 01 L-CHILD                BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-WORD L-CHILD.
     MOVE 0 TO L-CHILD WS-ARG
     MOVE CQ-WORD-START(L-WORD) TO WS-START
     MOVE CQ-WORD-LENGTH(L-WORD) TO WS-LENGTH
     COMPUTE WS-STEP = CQ-STEP-COUNT + 1
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > CMD-NODE-COUNT OR L-CHILD > 0
         IF CT-PARENT(WS-N) = L-NODE
             IF CT-TYPE(WS-N) = CMD-NODE-ARGUMENT
                 MOVE WS-N TO WS-ARG
             ELSE
                 IF CT-NAME-LENGTH(WS-N) = WS-LENGTH
                     IF CT-NAME(WS-N)(1:WS-LENGTH) = CQ-LINE(WS-START:WS-LENGTH)
                         MOVE WS-N TO L-CHILD
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-START TO CQ-STEP-START(WS-STEP)
     MOVE WS-LENGTH TO CQ-STEP-LENGTH(WS-STEP)
     MOVE 0 TO CQ-STEP-INT(WS-STEP) CQ-STEP-DOUBLE(WS-STEP)
     IF L-CHILD = 0 AND WS-ARG > 0
         EVALUATE TRUE
             WHEN CT-PARSER(WS-ARG) = 5 AND CT-STRING-KIND(WS-ARG) = 2
                 COMPUTE CQ-STEP-LENGTH(WS-STEP) = CQ-LINE-LENGTH + 1 - WS-START
                 MOVE WS-ARG TO L-CHILD
             WHEN WS-LENGTH = 0
                 CONTINUE
             WHEN CT-PARSER(WS-ARG) = 2 OR CT-PARSER(WS-ARG) = 3
                 CALL "CMD-NUMBER" USING WS-START WS-LENGTH CT-PARSER(WS-ARG)
                     CQ-STEP-INT(WS-STEP) CQ-STEP-DOUBLE(WS-STEP) WS-OK
                 IF WS-OK = 1 AND CQ-STEP-DOUBLE(WS-STEP) >= CT-MIN(WS-ARG)
                         AND CQ-STEP-DOUBLE(WS-STEP) <= CT-MAX(WS-ARG)
                     MOVE WS-ARG TO L-CHILD
                 END-IF
             WHEN OTHER
                 MOVE WS-ARG TO L-CHILD
         END-EVALUATE
     END-IF
     MOVE L-CHILD TO CQ-STEP-NODE(WS-STEP)
     GOBACK.
 END PROGRAM CMD-CHILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-NUMBER.
*> USING start, byte length (of a non-empty word of CQ-LINE), parser (2 double, 3 integer), integer
*> out, double out (both set for either parser), ok out (BINARY-LONG): an optional `-`, then at
*> least one digit, and for a double at most one `.` anywhere among them. The integer stops growing
*> past 2^31 (it is then out of every range); a double's fraction keeps its first 15 digits and is
*> added as one quotient, so that values such as 6.5 or 12.25 are exact.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 01 WS-I                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-INT-CAP             BINARY-DOUBLE VALUE 2147483648.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-FRACTION            BINARY-DOUBLE.
 01 WS-PLACES              BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-PARSER               BINARY-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-LENGTH L-PARSER L-INT L-DOUBLE L-OK.
     MOVE L-START TO WS-I
     COMPUTE WS-END = L-START + L-LENGTH - 1
     MOVE 1 TO WS-SIGN
     IF CQ-LINE(WS-I:1) = "-"
         MOVE -1 TO WS-SIGN
         ADD 1 TO WS-I
     END-IF
     MOVE 0 TO WS-DIGITS WS-POINTS WS-BAD WS-INT WS-VALUE WS-FRACTION WS-PLACES
     PERFORM UNTIL WS-I > WS-END
         EVALUATE TRUE
             WHEN CQ-LINE(WS-I:1) >= "0" AND CQ-LINE(WS-I:1) <= "9"
                 COMPUTE WS-D = FUNCTION ORD(CQ-LINE(WS-I:1)) - FUNCTION ORD("0")
                 ADD 1 TO WS-DIGITS
                 IF WS-POINTS = 0
                     COMPUTE WS-VALUE = WS-VALUE * 10 + WS-D
                     IF WS-INT <= WS-INT-CAP
                         COMPUTE WS-INT = WS-INT * 10 + WS-D
                     END-IF
                 END-IF
                 IF WS-POINTS > 0 AND WS-PLACES < 15
                     COMPUTE WS-FRACTION = WS-FRACTION * 10 + WS-D
                     ADD 1 TO WS-PLACES
                 END-IF
             WHEN CQ-LINE(WS-I:1) = "." AND L-PARSER = 2
                 ADD 1 TO WS-POINTS
             WHEN OTHER
                 MOVE 1 TO WS-BAD
         END-EVALUATE
         ADD 1 TO WS-I
     END-PERFORM
     MOVE 0 TO L-OK
     IF WS-DIGITS > 0 AND WS-POINTS <= 1 AND WS-BAD = 0
         MOVE 1 TO L-OK
     END-IF
     IF WS-INT > WS-INT-CAP
         MOVE WS-INT-CAP TO WS-INT
     END-IF
     COMPUTE WS-VALUE = WS-VALUE + WS-FRACTION / 10 ** WS-PLACES
     COMPUTE L-DOUBLE = WS-VALUE * WS-SIGN
     IF L-PARSER = 3
         COMPUTE L-DOUBLE = WS-INT * WS-SIGN
     END-IF
     COMPUTE L-INT = FUNCTION MIN(WS-INT, 2147483647) * WS-SIGN
     GOBACK.
 END PROGRAM CMD-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-USAGE-FIND.
*> USING count of words typed so far (BINARY-LONG): CQ-USAGE = the first usage form of CQ-COMMAND
*> whose fixed words (those not in <> or []) at positions 2 to count equal those words (§16.4).
*> The words counted are ones the command tree took, so some form always matches.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 01 WS-U                   BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-TEXT                PIC X(65).
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 0 TO CQ-USAGE
     PERFORM VARYING WS-U FROM 1 BY 1 UNTIL WS-U > CMD-USAGE-COUNT OR CQ-USAGE > 0
         IF CU-COMMAND(WS-U) = CQ-COMMAND
             MOVE CU-TEXT(WS-U) TO WS-TEXT
             MOVE 1 TO WS-MATCH WS-T WS-P
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CU-LENGTH(WS-U) + 1
                 IF WS-TEXT(WS-I:1) = SPACE
                     COMPUTE WS-LENGTH = WS-I - WS-P
                     IF WS-T > 1 AND WS-T <= L-COUNT AND WS-TEXT(WS-P:1) NOT = "<"
                             AND WS-TEXT(WS-P:1) NOT = "["
                         MOVE CQ-WORD-START(WS-T) TO WS-START
                         IF CQ-WORD-LENGTH(WS-T) NOT = WS-LENGTH
                             MOVE 0 TO WS-MATCH
                         ELSE
                             IF WS-TEXT(WS-P:WS-LENGTH) NOT = CQ-LINE(WS-START:WS-LENGTH)
                                 MOVE 0 TO WS-MATCH
                             END-IF
                         END-IF
                     END-IF
                     ADD 1 TO WS-T
                     COMPUTE WS-P = WS-I + 1
                 END-IF
             END-PERFORM
             IF WS-MATCH = 1
                 MOVE WS-U TO CQ-USAGE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-USAGE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-FIND-DIM.
*> USING word index, dimension row out (BINARY-LONG; 0 = no enabled dimension has that path): the
*> enabled dimension whose key path (after `cobolcraft:`) is the word (§16.1 names of things).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CMDPARSE.
 01 WS-D                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-ROW
         COMPUTE WS-LENGTH = DM-KEY-LENGTH(WS-ROW) - 11
         MOVE CQ-WORD-START(L-WORD) TO WS-START
         MOVE DM-KEY(WS-ROW) TO WS-KEY
         IF CQ-WORD-LENGTH(L-WORD) = WS-LENGTH
             IF WS-KEY(12:WS-LENGTH) = CQ-LINE(WS-START:WS-LENGTH)
                 MOVE WS-ROW TO L-ROW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-FIND-DIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-PERMITTED.
*> USING sender, permission (CMD-EVERYONE or CMD-OPERATOR), ok out (BINARY-LONG): 1 when the sender
*> may use a command of that permission: the console always; a player for everyone-commands, and
*> for operator commands iff they hold operator status (PL-OPERATOR, set by ACCESS-OPERATOR-STATUS
*> and the promote and demote commands).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 01 L-PERMISSION           BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-PERMISSION L-OK.
     MOVE 1 TO L-OK
     IF L-SENDER > 0 AND L-PERMISSION = CMD-OPERATOR AND PL-OPERATOR(L-SENDER) NOT = 1
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM CMD-PERMITTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TREE-BUILD.
*> USING operator (BINARY-LONG: 1 when the receiving player holds operator status), PB-BUFFER:
*> Commands 0x10 (05a; 09 §3.3 "Command tree"): the nodes the player may use in depth-first
*> pre-order, the root first (index 0, also the root index); a player without operator status gets
*> only the everyone-commands (§16.3). Flags: the node type, 0x04 where executable, 0x10 with the
*> suggestions type minecraft:ask_server; number ranges carry both bounds (flags 0x03).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 16.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SUGGEST             PIC X(20) VALUE "minecraft:ask_server".
 01 WS-INDEXES.
    05 WS-INDEX            BINARY-LONG OCCURS 89 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-OPERATOR             BINARY-LONG.
 PROCEDURE DIVISION USING L-OPERATOR PB-BUFFER.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > CMD-NODE-COUNT
         MOVE 0 TO WS-INDEX(WS-N)
         IF L-OPERATOR = 1 OR CD-PERMISSION(CT-COMMAND(WS-N)) = CMD-EVERYONE
             ADD 1 TO WS-COUNT
             MOVE WS-COUNT TO WS-INDEX(WS-N)
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     ADD 1 TO WS-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > CMD-NODE-COUNT
         MOVE 1 TO WS-IN
         IF WS-N > 0
             IF WS-INDEX(WS-N) = 0
                 MOVE 0 TO WS-IN
             END-IF
         END-IF
         IF WS-IN = 1
             INITIALIZE WK-COMMAND-NODE
             MOVE 0 TO WK-CN-CHILD-COUNT
             PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > CMD-NODE-COUNT
                 IF CT-PARENT(WS-M) = WS-N AND WS-INDEX(WS-M) > 0
                     ADD 1 TO WK-CN-CHILD-COUNT
                     MOVE WS-INDEX(WS-M) TO WK-CN-CHILD(WK-CN-CHILD-COUNT)
                 END-IF
             END-PERFORM
             IF WS-N > 0
                 COMPUTE WK-CN-FLAGS = CT-TYPE(WS-N) + CT-EXEC(WS-N) * WK-NODE-EXECUTABLE
                     + CT-SUGGEST(WS-N) * WK-NODE-HAS-SUGGEST
                 MOVE CT-NAME(WS-N) TO WK-CN-NAME
                 MOVE CT-NAME-LENGTH(WS-N) TO WK-CN-NAME-LENGTH
                 MOVE CT-PARSER(WS-N) TO WK-CN-PARSER
                 MOVE CT-STRING-KIND(WS-N) TO WK-CN-STRING-KIND
                 COMPUTE WK-CN-RANGE-FLAGS = WK-RANGE-HAS-MIN + WK-RANGE-HAS-MAX
                 MOVE CT-MIN(WS-N) TO WK-CN-MIN-INT WK-CN-MIN-DOUBLE
                 MOVE CT-MAX(WS-N) TO WK-CN-MAX-INT WK-CN-MAX-DOUBLE
                 MOVE WS-SUGGEST TO WK-CN-SUGGEST
                 MOVE 20 TO WK-CN-SUGGEST-LENGTH
             END-IF
             CALL "PB-PUT-COMMAND-NODE" USING PB-BUFFER WK-COMMAND-NODE
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     GOBACK.
 END PROGRAM CMD-TREE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TREE-SEND.
*> USING player row: the Commands packet for the player's operator status, to the player (on
*> joining, and at once when that status changes, US14-5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-OPERATOR            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE PL-OPERATOR(L-ROW) TO WS-OPERATOR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CMD-TREE-BUILD" USING WS-OPERATOR PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-TREE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-ONLINE.
*> USING count out (BINARY-LONG), table of 64 player rows out (BINARY-LONG): the players online in
*> this world (in play), in the order they entered it (PL-ENTERED; standin §16.2 roster).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-ROWS.
    05 L-ROW               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-ROWS.
     MOVE 0 TO L-COUNT WS-LAST
     MOVE 1 TO WS-NEXT
     PERFORM UNTIL WS-NEXT = 0
         MOVE 0 TO WS-NEXT
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
             IF PL-USED(WS-ROW) = 1 AND PL-ENTERED(WS-ROW) > WS-LAST
                 IF CN-PHASE(PL-CONN(WS-ROW)) = PH-PLAY
                     IF WS-NEXT = 0 OR PL-ENTERED(WS-ROW) < WS-BEST
                         MOVE WS-ROW TO WS-NEXT
                         MOVE PL-ENTERED(WS-ROW) TO WS-BEST
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-NEXT > 0
             ADD 1 TO L-COUNT
             MOVE WS-NEXT TO L-ROW(L-COUNT)
             MOVE WS-BEST TO WS-LAST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-ONLINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SUGGEST.
*> USING connection id, PLAY-SERVERBOUND (a decoded Command Suggestion 0x0F): answers with Command
*> Suggestions (09 §3.4 rule 5): the word being completed is the text after the last space (start
*> counted in characters of the text, its leading `/` included). When the words before it parse
*> (CMD-PARSE: they form a command line that is complete or only missing arguments) and lead to a
*> node whose argument child has ask_server suggestions, the suggestions are those of §16.3 that
*> start with the word, ignoring case: online player names (entering order) for <player> and
*> <target>; item key paths (ids 1 to 17) for <item>; mob type paths for <mob>; `mobs`, `items`, the
*> mob type paths and the item key paths for <what>; enabled dimension paths for <dimension>.
*> Otherwise (the command name itself, an unknown or forbidden command, a literal position) the
*> answer holds no suggestions.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY CITEMS.
 COPY MOBS.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-SPACE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KIND                PIC X(16).
 01 WS-CAND                PIC X(32).
 01 WS-CAND-LENGTH         BINARY-LONG.
 01 WS-MISSING             PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROWS.
    05 WS-ONLINE           BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE 0 TO WS-SLASH WS-SPACE CG-COUNT
     IF PSB-MESSAGE-LENGTH > 0 AND PSB-MESSAGE(1:1) = "/"
         MOVE 1 TO WS-SLASH
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PSB-MESSAGE-LENGTH
         IF PSB-MESSAGE(WS-I:1) = SPACE
             MOVE WS-I TO WS-SPACE
         END-IF
     END-PERFORM
     COMPUTE CG-START = FUNCTION MAX(WS-SPACE, WS-SLASH)
     COMPUTE CG-LENGTH = PSB-MESSAGE-LENGTH - CG-START
     MOVE SPACES TO CG-WORD
     MOVE CG-LENGTH TO CG-WORD-LENGTH
     IF CG-LENGTH > 0
         MOVE PSB-MESSAGE(CG-START + 1:CG-LENGTH) TO CG-WORD
     END-IF
     MOVE SPACES TO WS-KIND
     IF WS-SPACE > 0
         MOVE SPACES TO WS-LINE
         COMPUTE WS-LENGTH = WS-SPACE - 1 - WS-SLASH
         MOVE PSB-MESSAGE(WS-SLASH + 1:WS-LENGTH) TO WS-LINE
         CALL "CMD-PARSE" USING WS-ROW WS-LINE WS-LENGTH PB-TEXT
         MOVE MKEY-KEY(MK-MISSING-ARGUMENT) TO WS-MISSING
         IF PB-TX-LENGTH = 0 OR PB-TX-VALUE(1:48) = WS-MISSING
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > CMD-NODE-COUNT
                 IF CT-PARENT(WS-N) = CQ-NODE AND CT-SUGGEST(WS-N) = 1
                     MOVE CT-NAME(WS-N) TO WS-KIND
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     IF WS-KIND = "player" OR WS-KIND = "target"
         CALL "CMD-ONLINE" USING WS-COUNT WS-ROWS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE WS-ONLINE(WS-I) TO WS-N
             MOVE PL-NAME(WS-N) TO WS-CAND
             MOVE PL-NAME-LENGTH(WS-N) TO WS-CAND-LENGTH
             CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
         END-PERFORM
     END-IF
     IF WS-KIND = "what"
         MOVE "mobs" TO WS-CAND
         MOVE 4 TO WS-CAND-LENGTH
         CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
         MOVE "items" TO WS-CAND
         MOVE 5 TO WS-CAND-LENGTH
         CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
     END-IF
     IF WS-KIND = "mob" OR WS-KIND = "what"
         CALL "MOB-TABLE-COUNT" USING WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             COMPUTE WS-N = MB-ENTITY-TYPE(WS-I) + 1
             COMPUTE WS-CAND-LENGTH = ET-KEY-LENGTH(WS-N) - 11
             MOVE ET-KEY(WS-N)(12:) TO WS-CAND
             CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
         END-PERFORM
     END-IF
     IF WS-KIND = "item" OR WS-KIND = "what"
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > IT-COUNT
             COMPUTE WS-CAND-LENGTH = IT-KEY-LENGTH(WS-I) - 11
             MOVE IT-KEY(WS-I)(12:) TO WS-CAND
             CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
         END-PERFORM
     END-IF
     IF WS-KIND = "dimension"
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
             MOVE CW-DIM(WS-I) TO WS-N
             COMPUTE WS-CAND-LENGTH = DM-KEY-LENGTH(WS-N) - 11
             MOVE DM-KEY(WS-N)(12:) TO WS-CAND
             CALL "CMD-SUGGEST-ADD" USING WS-CAND WS-CAND-LENGTH
         END-PERFORM
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CMD-SUGGESTIONS-BUILD" USING PSB-TRANSACTION PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-SUGGEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SUGGEST-ADD.
*> USING candidate (PIC X(32)), byte length: added to the suggestions when it starts with the word
*> being completed (CG-WORD), ignoring case.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-CAND                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-CAND L-LENGTH.
     MOVE CG-WORD-LENGTH TO WS-LENGTH
     IF WS-LENGTH > L-LENGTH
         GOBACK
     END-IF
     IF WS-LENGTH > 0
         IF FUNCTION LOWER-CASE(L-CAND(1:WS-LENGTH))
                 NOT = FUNCTION LOWER-CASE(CG-WORD(1:WS-LENGTH))
             GOBACK
         END-IF
     END-IF
     ADD 1 TO CG-COUNT
     MOVE L-CAND TO CG-TEXT(CG-COUNT)
     MOVE L-LENGTH TO CG-TEXT-LENGTH(CG-COUNT)
     GOBACK.
 END PROGRAM CMD-SUGGEST-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SUGGESTIONS-BUILD.
*> USING transaction id, PB-BUFFER: Command Suggestions 0x0F (05a): the transaction id, CG-START,
*> CG-LENGTH, then each suggestion of CMD-SUGGESTIONS as a String with no tooltip.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 01 WS-PACKET-ID           BINARY-LONG VALUE 15.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TRANSACTION          BINARY-LONG.
 PROCEDURE DIVISION USING L-TRANSACTION PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TRANSACTION
     CALL "PB-PUT-VARINT" USING PB-BUFFER CG-START
     CALL "PB-PUT-VARINT" USING PB-BUFFER CG-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER CG-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CG-COUNT
         CALL "PB-PUT-STRING" USING PB-BUFFER CG-TEXT(WS-I) CG-TEXT-LENGTH(WS-I) WS-MAX
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-SUGGESTIONS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-HOWTO.
*> howto (§16.2 row 1): howto.header [number of usage forms the sender may use], then one
*> howto.entry [usage string] per such form, in table order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-U                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-PERMISSION          BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         IF WS-PASS = 2
             MOVE MK-HOWTO-HEADER TO WS-MSG
             CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "CMD-REPLY" USING PB-TEXT
         END-IF
         PERFORM VARYING WS-U FROM 1 BY 1 UNTIL WS-U > CMD-USAGE-COUNT
             MOVE CU-COMMAND(WS-U) TO WS-C
             MOVE CD-PERMISSION(WS-C) TO WS-PERMISSION
             CALL "CMD-PERMITTED" USING CQ-SENDER WS-PERMISSION WS-OK
             IF WS-OK = 1 AND WS-PASS = 1
                 ADD 1 TO WS-COUNT
             END-IF
             IF WS-OK = 1 AND WS-PASS = 2
                 MOVE MK-HOWTO-ENTRY TO WS-MSG
                 CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
                 CALL "CMD-TEXT-ARG" USING PB-TEXT CU-TEXT(WS-U) CU-LENGTH(WS-U)
                 CALL "CMD-REPLY" USING PB-TEXT
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-HOWTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-ROSTER.
*> roster (§16.2 row 2): roster [count, names of the online players in entering order].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-NAMES               PIC X(1200).
 01 WS-N                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ROWS.
    05 WS-ONLINE           BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "CMD-ONLINE" USING WS-COUNT WS-ROWS
     MOVE SPACES TO WS-NAMES
     MOVE 1 TO WS-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-ONLINE(WS-I) TO WS-ROW
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO WS-NAMES POINTER WS-LENGTH
         END-IF
         MOVE PL-NAME-LENGTH(WS-ROW) TO WS-N
         STRING PL-NAME(WS-ROW)(1:WS-N) DELIMITED BY SIZE INTO WS-NAMES POINTER WS-LENGTH
     END-PERFORM
     SUBTRACT 1 FROM WS-LENGTH
     MOVE MK-ROSTER TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-LENGTH
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-ROSTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-MURMUR.
*> murmur <player> <message...> (§16.2 row 3): the target (online) receives murmur.incoming [sender
*> name, message] from a player or murmur.incoming_console [message] from the console; the sender
*> murmur.sent [target name, message].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-TEXT                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-SENDER              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE CQ-STEP-START(2) TO WS-START
     MOVE CQ-STEP-LENGTH(2) TO WS-LENGTH
     MOVE SPACES TO WS-TEXT
     IF WS-LENGTH > 0
         MOVE CQ-LINE(WS-START:WS-LENGTH) TO WS-TEXT
     END-IF
     MOVE CQ-SENDER TO WS-SENDER
     MOVE MK-MURMUR-INCOMING-CONSOLE TO WS-MSG
     IF WS-SENDER > 0
         MOVE MK-MURMUR-INCOMING TO WS-MSG
     END-IF
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     IF WS-SENDER > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-SENDER) PL-NAME-LENGTH(WS-SENDER)
     END-IF
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     CALL "CMD-TELL" USING WS-ROW PB-TEXT
     MOVE MK-MURMUR-SENT TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-MURMUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-FIND-ONLINE.
*> USING name (PIC X(16)), byte length, player row out (BINARY-LONG; 0 = nobody online in this
*> world has exactly that name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-ROW.
     CALL "PLAYER-FIND-NAME" USING L-NAME L-LENGTH L-ROW
     IF L-ROW > 0
         IF CN-PHASE(PL-CONN(L-ROW)) NOT = PH-PLAY
             MOVE 0 TO L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CMD-FIND-ONLINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-NOTICE.
*> USING player row (0 = nobody), message (MK-*): the player, when online, is sent the message with no
*> arguments and the command tree for their operator status (US14-5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MESSAGE              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MESSAGE.
     IF L-ROW > 0
         CALL "CMD-TEXT-KEY" USING PB-TEXT L-MESSAGE
         CALL "CMD-TELL" USING L-ROW PB-TEXT
         CALL "CMD-TREE-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM CMD-NOTICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SAY-NAME.
*> USING message (MK-*), name (PIC X(16)), byte length: replies with that key and the name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-MESSAGE              BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-MESSAGE L-NAME L-LENGTH.
     CALL "CMD-TEXT-KEY" USING PB-TEXT L-MESSAGE
     CALL "CMD-TEXT-ARG" USING PB-TEXT L-NAME L-LENGTH
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SAY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-ACCESS-ADD.
*> USING list (ACCESS-*), name (PIC X(16)), byte length, offline UUID, added out (BINARY-LONG): adds
*> the identity at the end of the list (ACCESS-ADD); a full list (CORE-MAX-ACCESS) is a non-fatal
*> failure: the console line "ERROR access: the list is full", added 0 and no reply.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FULL                PIC X(32) VALUE "ERROR access: the list is full".
 01 WS-FULL-LENGTH         BINARY-LONG VALUE 30.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-ADDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-NAME L-LENGTH L-UUID L-ADDED.
     CALL "ACCESS-ADD" USING L-LIST L-NAME L-LENGTH L-UUID WS-OUTCOME
     MOVE 1 TO L-ADDED
     IF WS-OUTCOME = 2
         MOVE 0 TO L-ADDED
         CALL "CORE-LOG" USING WS-FULL WS-FULL-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CMD-ACCESS-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-PROMOTE.
*> promote <player> (§16.2 row 4): any valid name; promote.already when the identity holds operator
*> status; else it is added to the operator list (saved in access.dat), the sender gets
*> promote.done [name] and an online player promote.notice and a new command tree.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-IDENTITY" USING WS-WORD WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "CMD-FIND-ONLINE" USING WS-NAME WS-LENGTH WS-ROW
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-LISTED
     IF WS-ROW > 0
         IF PL-OPERATOR(WS-ROW) = 1
             MOVE 1 TO WS-LISTED
         END-IF
     END-IF
     IF WS-LISTED > 0
         MOVE MK-PROMOTE-ALREADY TO WS-MSG
         CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
         GOBACK
     END-IF
     CALL "CMD-ACCESS-ADD" USING WS-LIST WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     MOVE MK-PROMOTE-DONE TO WS-MSG
     CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
     IF WS-ROW > 0
         MOVE 1 TO PL-OPERATOR(WS-ROW)
     END-IF
     MOVE MK-PROMOTE-NOTICE TO WS-MSG
     CALL "CMD-NOTICE" USING WS-ROW WS-MSG
     GOBACK.
 END PROGRAM CMD-PROMOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-DEMOTE.
*> demote <player> (§16.2 row 5): any valid name; the host of a client-hosted world is refused
*> (is_host); demote.not_operator when the identity does not hold operator status; else it is
*> removed from the operator list, the sender gets demote.done [name] and an online player
*> demote.notice and a new command tree. The sender may demote themself, also the last operator;
*> the console keeps operator permission.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-IDENTITY" USING WS-WORD WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "CMD-IS-HOST" USING WS-NAME WS-LENGTH WS-HOST
     IF WS-HOST = 1
         GOBACK
     END-IF
     CALL "CMD-FIND-ONLINE" USING WS-NAME WS-LENGTH WS-ROW
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-LISTED
     IF WS-ROW > 0
         IF PL-OPERATOR(WS-ROW) = 1
             MOVE 1 TO WS-LISTED
         END-IF
     END-IF
     IF WS-LISTED = 0
         MOVE MK-DEMOTE-NOT-OPERATOR TO WS-MSG
         CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
         GOBACK
     END-IF
     CALL "ACCESS-REMOVE" USING WS-LIST WS-UUID WS-OUTCOME
     MOVE MK-DEMOTE-DONE TO WS-MSG
     CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
     IF WS-ROW > 0
         MOVE 0 TO PL-OPERATOR(WS-ROW)
     END-IF
     MOVE MK-DEMOTE-NOTICE TO WS-MSG
     CALL "CMD-NOTICE" USING WS-ROW WS-MSG
     GOBACK.
 END PROGRAM CMD-DEMOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-EJECT.
*> eject <player> [<reason...>] (§16.2 row 6): the target (online, not the host of a client-hosted
*> world); the sender gets eject.done [name], then the player is disconnected with
*> cobolcraft.disconnect.ejected [reason] or, without a reason, .ejected_plain (§17).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-TEXT                PIC X(768).
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     CALL "CMD-IS-HOST" USING PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW) WS-HOST
     IF WS-HOST = 1
         GOBACK
     END-IF
     MOVE MK-EJECT-DONE TO WS-MSG
     CALL "CMD-SAY-NAME" USING WS-MSG PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     MOVE MK-DC-EJECTED-PLAIN TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     IF CQ-STEP-COUNT >= 2
         MOVE MK-DC-EJECTED TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         MOVE CQ-STEP-START(2) TO WS-START
         MOVE CQ-STEP-LENGTH(2) TO WS-LENGTH
         MOVE SPACES TO WS-TEXT
         IF WS-LENGTH > 0
             MOVE CQ-LINE(WS-START:WS-LENGTH) TO WS-TEXT
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     END-IF
     CALL "CORE-SEND-DISCONNECT" USING PL-CONN(WS-ROW) PB-TEXT
     GOBACK.
 END PROGRAM CMD-EJECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-BAR.
*> bar <player> (§16.2 row 7): any valid name, not the host of a client-hosted world; bar.already
*> when the identity is on the ban list; else it is added (saved in access.dat), the sender gets
*> bar.done [name] and an online player is disconnected with cobolcraft.disconnect.barred (§17).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-HOST                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-IDENTITY" USING WS-WORD WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "CMD-IS-HOST" USING WS-NAME WS-LENGTH WS-HOST
     IF WS-HOST = 1
         GOBACK
     END-IF
     MOVE ACCESS-BANS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-LISTED
     IF WS-LISTED > 0
         MOVE MK-BAR-ALREADY TO WS-MSG
         CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
         GOBACK
     END-IF
     CALL "CMD-ACCESS-ADD" USING WS-LIST WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     MOVE MK-BAR-DONE TO WS-MSG
     CALL "CMD-SAY-NAME" USING WS-MSG WS-NAME WS-LENGTH
     CALL "CMD-FIND-ONLINE" USING WS-NAME WS-LENGTH WS-ROW
     IF WS-ROW > 0
         MOVE MK-DC-BARRED TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         CALL "CORE-SEND-DISCONNECT" USING PL-CONN(WS-ROW) PB-TEXT
     END-IF
     GOBACK.
 END PROGRAM CMD-BAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-LIST-EDIT.
*> USING list (ACCESS-*), word index of the name, add (1) or remove (0), done message, refusal
*> message (MK-*): unbar and guestlist add / remove (§16.2 rows 8, 12, 13): any valid name; the
*> identity is added (refused when listed) or removed (refused when not listed); the sender gets
*> the done or the refusal message with the name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-WORD                 BINARY-LONG.
 01 L-ADD                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 01 L-REFUSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-WORD L-ADD L-DONE L-REFUSED.
     CALL "CMD-IDENTITY" USING L-WORD WS-NAME WS-LENGTH WS-UUID WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "ACCESS-FIND" USING L-LIST WS-UUID WS-LISTED
     IF (L-ADD = 1 AND WS-LISTED > 0) OR (L-ADD = 0 AND WS-LISTED = 0)
         CALL "CMD-SAY-NAME" USING L-REFUSED WS-NAME WS-LENGTH
         GOBACK
     END-IF
     IF L-ADD = 1
         CALL "CMD-ACCESS-ADD" USING L-LIST WS-NAME WS-LENGTH WS-UUID WS-OK
     ELSE
         CALL "ACCESS-REMOVE" USING L-LIST WS-UUID WS-OUTCOME
     END-IF
     IF WS-OK = 1
         CALL "CMD-SAY-NAME" USING L-DONE WS-NAME WS-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CMD-LIST-EDIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-UNBAR.
*> unbar <player> (§16.2 row 8): the identity leaves the ban list: unbar.done [name], or
*> unbar.not_barred [name].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-LIST                BINARY-LONG.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-ADD                 BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-REFUSED             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE ACCESS-BANS TO WS-LIST
     MOVE MK-UNBAR-DONE TO WS-DONE
     MOVE MK-UNBAR-NOT-BARRED TO WS-REFUSED
     CALL "CMD-LIST-EDIT" USING WS-LIST WS-WORD WS-ADD WS-DONE WS-REFUSED
     GOBACK.
 END PROGRAM CMD-UNBAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-NAMES-ARG.
*> USING PB-TEXT, list (ACCESS-*): adds the count of the list and its names, in the order they were
*> added, joined by ", " (two arguments).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES               PIC X(4800).
 01 WS-NAME                PIC X(16).
 01 WS-N                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-LIST.
     MOVE SPACES TO WS-NAMES
     MOVE 1 TO WS-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AC-COUNT(L-LIST)
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO WS-NAMES POINTER WS-LENGTH
         END-IF
         MOVE AC-NAME-LENGTH(L-LIST, WS-I) TO WS-N
         MOVE AC-NAME(L-LIST, WS-I) TO WS-NAME
         STRING WS-NAME(1:WS-N) DELIMITED BY SIZE INTO WS-NAMES POINTER WS-LENGTH
     END-PERFORM
     SUBTRACT 1 FROM WS-LENGTH
     CALL "CMD-TEXT-INT" USING PB-TEXT AC-COUNT(L-LIST)
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-LENGTH
     GOBACK.
 END PROGRAM CMD-NAMES-ARG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-BARLIST.
*> barlist (§16.2 row 9): barlist [count, banned names in the order added].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-LIST                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE ACCESS-BANS TO WS-LIST
     MOVE MK-BARLIST TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-NAMES-ARG" USING PB-TEXT WS-LIST
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-BARLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-GUESTLIST.
*> guestlist on | off | add <player> | remove <player> | show (§16.2 rows 10 to 14): on and off set
*> the world's enforcement flag (saved in access.dat; players online stay); add and remove edit the
*> allow-list (CMD-LIST-EDIT); show replies guestlist.show [`on` or `off`, count, names].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-NAME-WORD           BINARY-LONG VALUE 3.
 01 WS-ADD                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-REFUSED             BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-STATE               PIC X(3).
 01 WS-STATE-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE CT-NAME(CQ-STEP-NODE(1)) TO WS-WORD
     MOVE ACCESS-ALLOW TO WS-LIST
     MOVE 3 TO WS-NAME-WORD
     EVALUATE WS-WORD
         WHEN "on"
             MOVE 1 TO AC-ENFORCED
             MOVE MK-GUESTLIST-ON TO WS-MSG
             CALL "CMD-SAY" USING WS-MSG
         WHEN "off"
             MOVE 0 TO AC-ENFORCED
             MOVE MK-GUESTLIST-OFF TO WS-MSG
             CALL "CMD-SAY" USING WS-MSG
         WHEN "add"
             MOVE 1 TO WS-ADD
             MOVE MK-GUESTLIST-ADDED TO WS-DONE
             MOVE MK-GUESTLIST-ALREADY TO WS-REFUSED
             CALL "CMD-LIST-EDIT" USING WS-LIST WS-NAME-WORD WS-ADD WS-DONE WS-REFUSED
         WHEN "remove"
             MOVE 0 TO WS-ADD
             MOVE MK-GUESTLIST-REMOVED TO WS-DONE
             MOVE MK-GUESTLIST-NOT-LISTED TO WS-REFUSED
             CALL "CMD-LIST-EDIT" USING WS-LIST WS-NAME-WORD WS-ADD WS-DONE WS-REFUSED
         WHEN OTHER
             MOVE MK-GUESTLIST-SHOW TO WS-MSG
             CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
             MOVE "off" TO WS-STATE
             MOVE 3 TO WS-STATE-LENGTH
             IF AC-ENFORCED = 1
                 MOVE "on" TO WS-STATE
                 MOVE 2 TO WS-STATE-LENGTH
             END-IF
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-STATE WS-STATE-LENGTH
             CALL "CMD-NAMES-ARG" USING PB-TEXT WS-LIST
             CALL "CMD-REPLY" USING PB-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM CMD-GUESTLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-MODE.
*> mode <player> survival | creative (§16.2 row 15; FR-007): the player's game mode is set: Game
*> Event 3 CHANGE_GAME_MODE (0.0 survival, 1.0 creative), Player Abilities and, in survival, Set
*> Health (a survival player stops flying); the sender gets mode.done [name, mode word].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-WORD                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-VALUE               FLOAT-SHORT.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE CQ-STEP-NODE(2) TO WS-NODE
     MOVE 0 TO PL-MODE(WS-ROW) PL-FLYING(WS-ROW)
     IF CT-NAME(WS-NODE) = "creative"
         MOVE 1 TO PL-MODE(WS-ROW)
     END-IF
     MOVE PL-MODE(WS-ROW) TO WS-VALUE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING PL-MODE(WS-ROW) PL-FLYING(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     IF PL-MODE(WS-ROW) = 0
         CALL "HEALTH-SEND" USING WS-ROW
     END-IF
     MOVE MK-MODE-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-ARG" USING PB-TEXT CT-NAME(WS-NODE) CT-NAME-LENGTH(WS-NODE)
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-MODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-MOVE-PLAYER.
*> USING player row, dimension row (BINARY-LONG), feet x, y, z (FLOAT-LONG): the player's feet go to
*> that position (§16.2 rows 16 and 17). In another dimension it is the travel switch without a
*> goto_pad (DIM-SWITCH: Respawn and the join sequence there, §15.5); in the same dimension the
*> player is sent Player Position (a new teleport id to accept), the chunks follow and the others
*> see the entity move. Facing is kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ON-GROUND           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z.
     MOVE L-ROW TO WS-ROW
     IF L-DIM NOT = PL-DIM(WS-ROW)
         CALL "DIM-SWITCH" USING WS-ROW L-DIM L-X L-Y L-Z
         GOBACK
     END-IF
     MOVE PL-CONN(WS-ROW) TO WS-CONN
     MOVE L-X TO PL-X(WS-ROW)
     MOVE L-Y TO PL-Y(WS-ROW) PL-FALL-START(WS-ROW)
     MOVE L-Z TO PL-Z(WS-ROW)
     ADD 1 TO CN-TELEPORT-ID(WS-CONN)
     MOVE 0 TO CN-TELEPORT-ACKED(WS-CONN)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-POSITION-BUILD" USING CN-TELEPORT-ID(WS-CONN) PL-X(WS-ROW) PL-Y(WS-ROW)
         PL-Z(WS-ROW) PL-YAW(WS-ROW) PL-PITCH(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     MOVE PL-ON-GROUND(WS-ROW) TO WS-ON-GROUND
     CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
         PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ON-GROUND
     GOBACK.
 END PROGRAM CMD-MOVE-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-DIM.
*> USING PB-TEXT, dimension row: adds the dimension's key path (after `cobolcraft:`).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-PATH                PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-DIM.
     MOVE DM-KEY(L-DIM)(12:) TO WS-PATH
     COMPUTE WS-LENGTH = DM-KEY-LENGTH(L-DIM) - 11
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-PATH WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-DIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RELOCATE.
*> relocate <player> at <x> <y> <z> [<dimension>] | relocate <player> to <target> (§16.2 rows 16 and
*> 17): the player (online) moves to the position in that dimension (left out: the sender's, main
*> for the console), or to the target player's dimension and position (CMD-MOVE-PLAYER); the
*> sender gets relocate.position [name, x, y, z, dimension path] or relocate.player [name, target].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE CQ-STEP-NODE(2) TO WS-NODE
     IF CT-NAME(WS-NODE) = "to"
         MOVE 4 TO WS-WORD
         CALL "CMD-TARGET" USING WS-WORD WS-TARGET
         IF WS-TARGET = 0
             GOBACK
         END-IF
         CALL "CMD-MOVE-PLAYER" USING WS-ROW PL-DIM(WS-TARGET) PL-X(WS-TARGET)
             PL-Y(WS-TARGET) PL-Z(WS-TARGET)
         MOVE MK-RELOCATE-PLAYER TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-TARGET) PL-NAME-LENGTH(WS-TARGET)
         CALL "CMD-REPLY" USING PB-TEXT
         GOBACK
     END-IF
     MOVE 0 TO WS-WORD
     IF CQ-STEP-COUNT >= 6
         MOVE 7 TO WS-WORD
     END-IF
     CALL "CMD-DIMENSION" USING WS-WORD WS-DIM
     IF WS-DIM = 0
         GOBACK
     END-IF
     MOVE CQ-STEP-DOUBLE(3) TO WS-X
     MOVE CQ-STEP-DOUBLE(4) TO WS-Y
     MOVE CQ-STEP-DOUBLE(5) TO WS-Z
     CALL "CMD-MOVE-PLAYER" USING WS-ROW WS-DIM WS-X WS-Y WS-Z
     MOVE MK-RELOCATE-POSITION TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-X
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-Y
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-Z
     CALL "CMD-TEXT-DIM" USING PB-TEXT WS-DIM
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-RELOCATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SEND-INVENTORY.
*> USING player row: the player's inventory (Container Set Content of container 0, the state id
*> raised by one first).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE PL-STATE-ID(L-ROW) = FUNCTION MOD(PL-STATE-ID(L-ROW) + 1, 32768)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-CONTENT-BUILD" USING L-ROW PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-SEND-INVENTORY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-FIND-ITEM.
*> USING word index, item id out (BINARY-LONG; 0 = no item other than `nothing` has that key path).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CMDPARSE.
 01 WS-I                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-ITEM.
     MOVE 0 TO L-ITEM
     MOVE CQ-WORD-START(L-WORD) TO WS-START
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > IT-COUNT
         COMPUTE WS-LENGTH = IT-KEY-LENGTH(WS-I) - 11
         MOVE IT-KEY(WS-I) TO WS-KEY
         IF CQ-WORD-LENGTH(L-WORD) = WS-LENGTH
             IF WS-KEY(12:WS-LENGTH) = CQ-LINE(WS-START:WS-LENGTH)
                 COMPUTE L-ITEM = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-FIND-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-FIND-MOB.
*> USING word index, mob row out (BINARY-LONG; MOBS.cpy row, 0 = no mob type has that key path).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MOBS.
 COPY CITEMS.
 COPY CMDPARSE.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 LINKAGE SECTION.
 01 L-WORD                 BINARY-LONG.
 01 L-MOB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-WORD L-MOB.
     MOVE 0 TO L-MOB
     MOVE CQ-WORD-START(L-WORD) TO WS-START
     CALL "MOB-TABLE-COUNT" USING WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-T = MB-ENTITY-TYPE(WS-I) + 1
         COMPUTE WS-LENGTH = ET-KEY-LENGTH(WS-T) - 11
         MOVE ET-KEY(WS-T) TO WS-KEY
         IF CQ-WORD-LENGTH(L-WORD) = WS-LENGTH
             IF WS-KEY(12:WS-LENGTH) = CQ-LINE(WS-START:WS-LENGTH)
                 MOVE WS-I TO L-MOB
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-FIND-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SUPPLY.
*> supply <player> <item> [<count>] (§16.2 row 18): count (default 1) of the item is added to the
*> player's inventory with the inventory add rule (INV-ADD; what does not fit is not added) and the
*> player is sent the inventory; the sender gets supply.done [number added, item path, name], or
*> supply.no_room [name] when nothing fits; item_not_found [word] for an unknown path or `nothing`.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY CITEMS.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-PATH                PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE 3 TO WS-WORD
     CALL "CMD-FIND-ITEM" USING WS-WORD WS-ITEM
     IF WS-ITEM = 0
         MOVE MK-ITEM-NOT-FOUND TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG WS-WORD
         GOBACK
     END-IF
     MOVE 1 TO WS-COUNT
     IF CQ-STEP-COUNT >= 3
         MOVE CQ-STEP-INT(3) TO WS-COUNT
     END-IF
     CALL "INV-ADD" USING WS-ROW WS-ITEM WS-COUNT WS-LEFT
     COMPUTE WS-ADDED = WS-COUNT - WS-LEFT
     IF WS-ADDED = 0
         MOVE MK-SUPPLY-NO-ROOM TO WS-MSG
         CALL "CMD-SAY-NAME" USING WS-MSG PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
         GOBACK
     END-IF
     CALL "CMD-SEND-INVENTORY" USING WS-ROW
     MOVE IT-KEY(WS-ITEM + 1)(12:) TO WS-PATH
     COMPUTE WS-LENGTH = IT-KEY-LENGTH(WS-ITEM + 1) - 11
     MOVE MK-SUPPLY-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-ADDED
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-PATH WS-LENGTH
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SUPPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-EMPTY.
*> empty <player> (§16.2 row 19): all 36 slots are emptied (nothing is dropped) and the player is
*> sent the inventory; the sender gets empty.done [name, total number of items removed].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         ADD PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-TOTAL
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-S) PL-SLOT-COUNT(WS-ROW, WS-S)
     END-PERFORM
     CALL "CMD-SEND-INVENTORY" USING WS-ROW
     MOVE MK-EMPTY-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-TOTAL
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SURVIVOR.
*> USING row out (BINARY-LONG; 0 when refused): the target of vitality and ration (§16.2 rows 20
*> and 21): online (CMD-TARGET), in survival mode (else not_survival [name]) and alive (else
*> not_alive [name]).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-WORD                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 2 TO WS-WORD
     CALL "CMD-TARGET" USING WS-WORD L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-MSG
     IF PL-STATE(L-ROW) = PS-DEAD
         MOVE MK-NOT-ALIVE TO WS-MSG
     END-IF
     IF PL-MODE(L-ROW) = 1
         MOVE MK-NOT-SURVIVAL TO WS-MSG
     END-IF
     IF WS-MSG > 0
         CALL "CMD-SAY-NAME" USING WS-MSG PL-NAME(L-ROW) PL-NAME-LENGTH(L-ROW)
         MOVE 0 TO L-ROW
     END-IF
     GOBACK.
 END PROGRAM CMD-SURVIVOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-AMOUNT.
*> USING full value, amount out (BINARY-LONG): the third word of vitality or ration: full, zero or
*> the amount.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FULL                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FULL L-AMOUNT.
     MOVE CQ-STEP-NODE(2) TO WS-NODE
     EVALUATE CT-NAME(WS-NODE)
         WHEN "full"
             MOVE L-FULL TO L-AMOUNT
         WHEN "zero"
             MOVE 0 TO L-AMOUNT
         WHEN OTHER
             MOVE CQ-STEP-INT(2) TO L-AMOUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM CMD-AMOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-VITALITY.
*> vitality <player> <amount> | full | zero (§16.2 row 20): a survival, alive player's health is
*> set (Set Health); the sender gets vitality.done [name, new health]; at 0 the player then dies
*> (cause cobolcraft.death.command, §10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY RULES.
 COPY PROTO.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "CMD-SURVIVOR" USING WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE RULE-MAX-HEALTH TO WS-FULL
     CALL "CMD-AMOUNT" USING WS-FULL WS-AMOUNT
     MOVE WS-AMOUNT TO PL-HEALTH(WS-ROW)
     CALL "HEALTH-SEND" USING WS-ROW
     MOVE MK-VITALITY-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-AMOUNT
     CALL "CMD-REPLY" USING PB-TEXT
     IF WS-AMOUNT = 0
         MOVE CAUSE-COMMAND TO WS-CAUSE
         CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-NOBODY
     END-IF
     GOBACK.
 END PROGRAM CMD-VITALITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-RATION.
*> ration <player> <amount> | full | zero (§16.2 row 21): a survival, alive player's food level is
*> set (Set Health); the sender gets ration.done [name, new food].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY RULES.
 COPY PROTO.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CMD-SURVIVOR" USING WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE RULE-MAX-FOOD TO WS-FULL
     CALL "CMD-AMOUNT" USING WS-FULL WS-AMOUNT
     MOVE WS-AMOUNT TO PL-FOOD(WS-ROW)
     COMPUTE PL-SATURATION(WS-ROW) = FUNCTION MIN(PL-SATURATION(WS-ROW), WS-AMOUNT)
     CALL "HEALTH-SEND" USING WS-ROW
     MOVE MK-RATION-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-AMOUNT
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-RATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-CONJURE.
*> conjure <mob> <x> <y> <z> [<dimension>] (§16.2 row 22): one mob of that type at the position with
*> yaw 0 and full health (MOB-SPAWN), ignoring §12.4's conditions and caps; mob_not_found [word];
*> dimension not found; conjure.hostile_disabled [mob path] for a hostile type while hostile-mobs
*> is off; the sender gets conjure.done [mob path, x, y, z, dimension path].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY MOBS.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 2 TO WS-WORD
     CALL "CMD-FIND-MOB" USING WS-WORD WS-MOB
     IF WS-MOB = 0
         MOVE MK-MOB-NOT-FOUND TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG WS-WORD
         GOBACK
     END-IF
     MOVE 0 TO WS-WORD
     IF CQ-STEP-COUNT >= 5
         MOVE 6 TO WS-WORD
     END-IF
     CALL "CMD-DIMENSION" USING WS-WORD WS-DIM
     IF WS-DIM = 0
         GOBACK
     END-IF
     IF MB-KIND(WS-MOB) = MOB-HOSTILE AND CS-HOSTILE-MOBS NOT = 1
         MOVE MK-CONJURE-HOSTILE-DISABLED TO WS-MSG
         MOVE 2 TO WS-WORD
         CALL "CMD-SAY-WORD" USING WS-MSG WS-WORD
         GOBACK
     END-IF
     MOVE CQ-STEP-DOUBLE(2) TO WS-X
     MOVE CQ-STEP-DOUBLE(3) TO WS-Y
     MOVE CQ-STEP-DOUBLE(4) TO WS-Z
     MOVE MB-ENTITY-TYPE(WS-MOB) TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE MK-CONJURE-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     MOVE 2 TO WS-WORD
     CALL "CMD-TEXT-WORD" USING PB-TEXT WS-WORD
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-X
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-Y
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT WS-Z
     CALL "CMD-TEXT-DIM" USING PB-TEXT WS-DIM
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-CONJURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SWEEP.
*> sweep <what> everywhere | sweep <what> area <dimension> <x1> <y1> <z1> <x2> <y2> <z2> (§16.2 row
*> 23): <what> is `mobs` (every mob), `items` (every ground item), a mob type path or an item path
*> (else sweep.unknown_target [word]); the matching mobs and ground items in every enabled
*> dimension, or those in the dimension whose position lies in the box of the two corners (bounds
*> included), are removed (ENTITY-REMOVE); the sender gets sweep.done [number removed].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY MOBS.
 COPY CITEMS.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-WHAT                PIC X(16).
 01 WS-MOB                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LOW-X               FLOAT-LONG.
 01 WS-LOW-Y               FLOAT-LONG.
 01 WS-LOW-Z               FLOAT-LONG.
 01 WS-HIGH-X              FLOAT-LONG.
 01 WS-HIGH-Y              FLOAT-LONG.
 01 WS-HIGH-Z              FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     MOVE SPACES TO WS-WHAT
     MOVE CQ-WORD-START(2) TO WS-START
     MOVE CQ-WORD-LENGTH(2) TO WS-LENGTH
     IF WS-LENGTH <= 16
         MOVE CQ-LINE(WS-START:WS-LENGTH) TO WS-WHAT
     END-IF
     CALL "CMD-FIND-MOB" USING WS-WORD WS-MOB
     CALL "CMD-FIND-ITEM" USING WS-WORD WS-ITEM
     IF WS-MOB = 0 AND WS-ITEM = 0 AND WS-WHAT NOT = "mobs" AND WS-WHAT NOT = "items"
         MOVE MK-SWEEP-UNKNOWN-TARGET TO WS-MSG
         CALL "CMD-SAY-WORD" USING WS-MSG WS-WORD
         GOBACK
     END-IF
     MOVE 0 TO WS-DIM
     IF CQ-STEP-COUNT > 2
         MOVE 4 TO WS-WORD
         CALL "CMD-DIMENSION" USING WS-WORD WS-DIM
         IF WS-DIM = 0
             GOBACK
         END-IF
         COMPUTE WS-LOW-X = FUNCTION MIN(CQ-STEP-DOUBLE(4), CQ-STEP-DOUBLE(7))
         COMPUTE WS-LOW-Y = FUNCTION MIN(CQ-STEP-DOUBLE(5), CQ-STEP-DOUBLE(8))
         COMPUTE WS-LOW-Z = FUNCTION MIN(CQ-STEP-DOUBLE(6), CQ-STEP-DOUBLE(9))
         COMPUTE WS-HIGH-X = FUNCTION MAX(CQ-STEP-DOUBLE(4), CQ-STEP-DOUBLE(7))
         COMPUTE WS-HIGH-Y = FUNCTION MAX(CQ-STEP-DOUBLE(5), CQ-STEP-DOUBLE(8))
         COMPUTE WS-HIGH-Z = FUNCTION MAX(CQ-STEP-DOUBLE(6), CQ-STEP-DOUBLE(9))
     END-IF
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         MOVE 0 TO WS-MATCH
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0
             EVALUATE TRUE
                 WHEN WS-WHAT = "mobs" AND EN-TYPE(WS-ROW) NOT = CR-LOOSE-ITEM
                 WHEN WS-WHAT = "items" AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
                     MOVE 1 TO WS-MATCH
                 WHEN WS-MOB > 0
                     IF EN-TYPE(WS-ROW) = MB-ENTITY-TYPE(WS-MOB)
                         MOVE 1 TO WS-MATCH
                     END-IF
                 WHEN WS-ITEM > 0
                     IF EN-TYPE(WS-ROW) = CR-LOOSE-ITEM AND EN-ITEM(WS-ROW) = WS-ITEM
                         MOVE 1 TO WS-MATCH
                     END-IF
             END-EVALUATE
         END-IF
         IF WS-MATCH = 1 AND WS-DIM > 0
             IF EN-DIM(WS-ROW) NOT = WS-DIM
                     OR EN-X(WS-ROW) < WS-LOW-X OR EN-X(WS-ROW) > WS-HIGH-X
                     OR EN-Y(WS-ROW) < WS-LOW-Y OR EN-Y(WS-ROW) > WS-HIGH-Y
                     OR EN-Z(WS-ROW) < WS-LOW-Z OR EN-Z(WS-ROW) > WS-HIGH-Z
                 MOVE 0 TO WS-MATCH
             END-IF
         END-IF
         IF WS-MATCH = 1
             CALL "ENTITY-REMOVE" USING WS-ROW
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE MK-SWEEP-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SWEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TO-PLAYERS.
*> USING PB-BUFFER (a packet), dimension row (0 = any): the packet to every player in play whose
*> join has been sent, in that dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
                 AND (L-DIM = 0 OR PL-DIM(WS-ROW) = L-DIM)
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-TO-PLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-CLOCK.
*> clock <ticks> (§16.2 row 24): Time is set; every player is sent Set Time; the sender gets
*> clock.done [ticks].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE CQ-STEP-INT(1) TO CW-TIME
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PLAY-TIME-BUILD" USING CW-TIME PK-BUFFER
     CALL "CMD-TO-PLAYERS" USING PK-BUFFER WS-ANY
     CALL "PB-FREE" USING PK-BUFFER
     MOVE MK-CLOCK-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-INT" USING PB-TEXT CQ-STEP-INT(1)
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-CLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SKIES.
*> skies <dimension> clear | drizzle | hailstorm [<seconds>] (§16.2 row 25, §14.3): the shared
*> weather state takes that kind (a skin of the standard levels) for seconds x 20 ticks, or for the longest time
*> without seconds; the players are told by the levels' fade (33 section 4.2); skies.no_weather [dimension path] for a dimension without
*> weather; the sender gets skies.timed [path, kind, seconds] or skies.held [path, kind].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COMMANDS.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY PROTO.
 01 WS-WORD                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-TIME                BINARY-LONG.
 01 WS-HELD                BINARY-LONG VALUE 2147483647.
 PROCEDURE DIVISION.
     MOVE 2 TO WS-WORD
     CALL "CMD-DIMENSION" USING WS-WORD WS-DIM
     IF WS-DIM = 0
         GOBACK
     END-IF
     IF DM-WEATHER(WS-DIM) = 0
         MOVE MK-SKIES-NO-WEATHER TO WS-MSG
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         CALL "CMD-TEXT-DIM" USING PB-TEXT WS-DIM
         CALL "CMD-REPLY" USING PB-TEXT
         GOBACK
     END-IF
     MOVE CQ-STEP-NODE(2) TO WS-NODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WEATHER-KIND-COUNT
         IF WK-KEY(WS-K)(12:16) = CT-NAME(WS-NODE)
             MOVE WS-K TO WS-KIND
         END-IF
     END-PERFORM
     MOVE WS-HELD TO WS-TIME
     MOVE MK-SKIES-HELD TO WS-MSG
     IF CQ-STEP-COUNT >= 3
         COMPUTE WS-TIME = CQ-STEP-INT(3) * 20
         MOVE MK-SKIES-TIMED TO WS-MSG
     END-IF
*>   The kind is a skin of the shared state (33 section 4.3): clear is clear time, drizzle rain, hailstorm rain and thunder.
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-DIM" USING PB-TEXT WS-DIM
     CALL "CMD-TEXT-ARG" USING PB-TEXT CT-NAME(WS-NODE) CT-NAME-LENGTH(WS-NODE)
     IF CQ-STEP-COUNT >= 3
         CALL "CMD-TEXT-INT" USING PB-TEXT CQ-STEP-INT(3)
     END-IF
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-SKIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-HOMESTEAD.
*> homestead <x> <y> <z> (§16.2 row 26): the world spawn point moves there (always in
*> cobolcraft:main, its yaw unchanged); every player in main is sent Set Default Spawn Position;
*> the sender gets homestead.done [x, y, z].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY DIMENSIONS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-MAIN                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE CQ-STEP-DOUBLE(1) TO CW-SPAWN-X
     MOVE CQ-STEP-DOUBLE(2) TO CW-SPAWN-Y
     MOVE CQ-STEP-DOUBLE(3) TO CW-SPAWN-Z
     MOVE DIM-MAIN TO WS-MAIN
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PLAY-SPAWN-POSITION-BUILD" USING PK-BUFFER
     CALL "CMD-TO-PLAYERS" USING PK-BUFFER WS-MAIN
     CALL "PB-FREE" USING PK-BUFFER
     MOVE MK-HOMESTEAD-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT CW-SPAWN-X
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT CW-SPAWN-Y
     CALL "CMD-TEXT-DOUBLE" USING PB-TEXT CW-SPAWN-Z
     CALL "CMD-REPLY" USING PB-TEXT
     GOBACK.
 END PROGRAM CMD-HOMESTEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-ANNOUNCE.
*> announce <message...> (§16.2 row 27): every connected player receives announce.message [message]
*> and the console prints it; the sender gets announce.done.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMDPARSE.
 COPY MESSAGES.
 COPY PROTO.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-TEXT                PIC X(768).
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE CQ-STEP-START(1) TO WS-START
     MOVE CQ-STEP-LENGTH(1) TO WS-LENGTH
     MOVE SPACES TO WS-TEXT
     IF WS-LENGTH > 0
         MOVE CQ-LINE(WS-START:WS-LENGTH) TO WS-TEXT
     END-IF
     MOVE MK-ANNOUNCE-MESSAGE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
             CALL "CMD-TELL" USING WS-ROW PB-TEXT
         END-IF
     END-PERFORM
     CALL "CONSOLE-TEXT" USING PB-TEXT
     MOVE MK-ANNOUNCE-DONE TO WS-MSG
     CALL "CMD-SAY" USING WS-MSG
     GOBACK.
 END PROGRAM CMD-ANNOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-PERSIST.
*> persist (§16.2 row 28): the world is saved now (WORLD-SAVE, 07 §9), then the sender gets
*> persist.done.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MESSAGES.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WORLD-SAVE"
     MOVE MK-PERSIST-DONE TO WS-MSG
     CALL "CMD-SAY" USING WS-MSG
     GOBACK.
 END PROGRAM CMD-PERSIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SHUTDOWN.
*> shutdown (§16.2 row 29): the sender gets shutdown.done, then the run state becomes 1 (stop
*> requested, CORE-STATUS-GET); the host stops (CORE-STOP: US15, US17-4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 01 WS-MSG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE MK-SHUTDOWN-DONE TO WS-MSG
     CALL "CMD-SAY" USING WS-MSG
     MOVE 1 TO CW-RUN-STATE
     GOBACK.
 END PROGRAM CMD-SHUTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-KEY.
*> USING PB-TEXT, message (MESSAGES.cpy MK-* index): the text becomes that translate key with no
*> arguments yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MESSAGES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-MESSAGE              BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-MESSAGE.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE MKEY-KEY(L-MESSAGE) TO PB-TX-VALUE
     MOVE MKEY-KEY-LENGTH(L-MESSAGE) TO PB-TX-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-WORD.
*> USING PB-TEXT, word index: adds the word as typed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMDPARSE.
 01 WS-WORD                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-WORD                 BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-WORD.
     MOVE CQ-WORD-LENGTH(L-WORD) TO WS-LENGTH
     MOVE CQ-WORD-START(L-WORD) TO WS-START
     MOVE SPACES TO WS-WORD
     IF WS-LENGTH > 0
         MOVE CQ-LINE(WS-START:WS-LENGTH) TO WS-WORD
     END-IF
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-WORD WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-WORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-USAGE.
*> USING PB-TEXT: adds the usage string CQ-USAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COMMANDS.
 COPY CMDPARSE.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT.
     CALL "CMD-TEXT-ARG" USING PB-TEXT CU-TEXT(CQ-USAGE) CU-LENGTH(CQ-USAGE)
     GOBACK.
 END PROGRAM CMD-TEXT-USAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-INT.
*> USING PB-TEXT, integer (BINARY-LONG): adds it in decimal, without leading zeros, `-` when
*> negative.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(10)9.
 01 WS-TEXT                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-VALUE.
     MOVE L-VALUE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-DOUBLE.
*> USING PB-TEXT, double (FLOAT-LONG): adds it with exactly two digits after the point, rounded half
*> away from zero, `-` when negative (§16.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(10)9.99.
 01 WS-TEXT                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-VALUE.
     COMPUTE WS-EDIT ROUNDED = L-VALUE
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM CMD-TEXT-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-TEXT-ARG.
*> USING PB-TEXT, area (UTF-8), byte length: adds a literal argument with the bytes (at most 1024,
*> PB-TX-ARG-VALUE's size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 B-AREA                 PIC X(1024) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-AREA L-LENGTH.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     COMPUTE WS-LENGTH = FUNCTION MIN(L-LENGTH, 1024)
     ADD 1 TO PB-TX-ARG-COUNT
     MOVE SPACES TO PB-TX-ARG-VALUE(PB-TX-ARG-COUNT)
     MOVE WS-LENGTH TO PB-TX-ARG-LENGTH(PB-TX-ARG-COUNT)
     IF WS-LENGTH > 0
         MOVE B-AREA(1:WS-LENGTH) TO PB-TX-ARG-VALUE(PB-TX-ARG-COUNT)(1:WS-LENGTH)
     END-IF
     GOBACK.
 END PROGRAM CMD-TEXT-ARG.
