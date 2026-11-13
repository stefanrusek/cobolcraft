*> The server administration commands (docs/protocol/16-commands-catalog.md §11): op, deop, and (added with their tests) ban, ban-ip,
*> pardon, pardon-ip, banlist, kick, save-all, save-on, save-off, stop, whitelist. A CX- program reads its parsed context through
*> the BX- helpers, tells through BR-FEEDBACK, sets BR-R-RESULT and, to fail, raises an exception (BR-RAISE) and sets BR-R-FAILED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-OP.
*> op <targets> (16 §11.1, level 3): each profile that is not an operator is put on the operator list (level 4) and, when online,
*> holds operator status and is sent the Commands packet of its level; commands.op.success [name] is broadcast per profile; no
*> profile changed is commands.op.failed; the result is the number of profiles changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-PROFILES" USING WS-INDEX WS-PROFILES
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-PCOUNT OR BR-R-FAILED = 1
         CALL "ACCESS-FIND" USING WS-LIST BX-P-UUID(WS-I) WS-ROW
         IF WS-ROW = 0
             CALL "ACCESS-ADD" USING WS-LIST BX-P-NAME(WS-I) BX-P-LENGTH(WS-I) BX-P-UUID(WS-I) WS-OUTCOME
             IF WS-OUTCOME = 0
                 ADD 1 TO WS-CHANGED
                 CALL "BX-ROW-OF-UUID" USING BX-P-UUID(WS-I) WS-PLAYER
                 IF WS-PLAYER > 0
                     CALL "ACCESS-OPERATOR-STATUS" USING WS-PLAYER
                     CALL "CMD-PERMISSION-SEND" USING WS-PLAYER
                 END-IF
                 MOVE "commands.op.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT BX-P-NAME(WS-I) BX-P-LENGTH(WS-I)
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             END-IF
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         IF WS-CHANGED = 0
             MOVE "commands.op.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-CHANGED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-OP.
*> The form of op (16 §11.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-OP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "op <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEOP.
*> deop <targets> (16 §11.2, level 3): each profile that is an operator leaves the operator list and, when online, its operator
*> status is recomputed (the host of a single-player world stays an operator) and it is sent the Commands packet of its level;
*> commands.deop.success [name] is broadcast per profile; none changed is commands.deop.failed; the result is the number changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-PROFILES" USING WS-INDEX WS-PROFILES
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-PCOUNT OR BR-R-FAILED = 1
         CALL "ACCESS-FIND" USING WS-LIST BX-P-UUID(WS-I) WS-ROW
         IF WS-ROW > 0
             CALL "ACCESS-REMOVE" USING WS-LIST BX-P-UUID(WS-I) WS-OUTCOME
             ADD 1 TO WS-CHANGED
             CALL "BX-ROW-OF-UUID" USING BX-P-UUID(WS-I) WS-PLAYER
             IF WS-PLAYER > 0
                 CALL "ACCESS-OPERATOR-STATUS" USING WS-PLAYER
                 CALL "CMD-PERMISSION-SEND" USING WS-PLAYER
             END-IF
             MOVE "commands.deop.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT BX-P-NAME(WS-I) BX-P-LENGTH(WS-I)
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         IF WS-CHANGED = 0
             MOVE "commands.deop.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-CHANGED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-DEOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEOP.
*> The form of deop (16 §11.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEOP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "deop <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DEOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-NOW-TEXT.
*> USING text out (PIC X(32)), length out: the current time as "yyyy-MM-dd HH:mm:ss +zzzz" (the creation time of a ban, 07 §9.2)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 PIC X(21).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH.
     MOVE FUNCTION CURRENT-DATE TO WS-NOW
     MOVE SPACES TO L-TEXT
     STRING WS-NOW(1:4) "-" WS-NOW(5:2) "-" WS-NOW(7:2) " " WS-NOW(9:2) ":" WS-NOW(11:2) ":" WS-NOW(13:2) " "
         WS-NOW(17:5) DELIMITED BY SIZE INTO L-TEXT
     MOVE 25 TO L-LENGTH
     GOBACK.
 END PROGRAM BR-NOW-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-BAN.
*> ban <targets> [<reason>] (16 §11.3, level 3): each profile that is not banned gets a ban entry (the creation time, the source's
*> name, forever, the reason when given) and, when online, is disconnected with multiplayer.disconnect.banned.reason [reason];
*> commands.ban.success [name, reason] is broadcast per profile (the reason is "Banned by an operator." when none was given);
*> none banned is commands.ban.failed; the result is the number banned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-REASON         PIC X(32) VALUE "reason".
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-REASON        BINARY-LONG.
 01 WS-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-REASON              PIC X(1024).
 01 WS-REASON-LENGTH       BINARY-LONG VALUE 0.
 01 WS-SHOWN               PIC X(1024).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-DEFAULT             PIC X(24) VALUE "Banned by an operator.".
 01 WS-KEY                 PIC X(72).
 01 WS-NOW                 PIC X(32).
 01 WS-NOW-LENGTH          BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-REASON-LENGTH
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-PROFILES" USING WS-INDEX WS-PROFILES
     CALL "BX-FIND" USING WS-NAME-REASON WS-INDEX-REASON
     IF BR-R-FAILED = 0 AND WS-INDEX-REASON > 0
         CALL "BX-MESSAGE" USING WS-INDEX-REASON WS-REASON WS-REASON-LENGTH
     END-IF
     IF WS-REASON-LENGTH > 0
         MOVE WS-REASON TO WS-SHOWN
         MOVE WS-REASON-LENGTH TO WS-SHOWN-LENGTH
     ELSE
         MOVE WS-DEFAULT TO WS-SHOWN
         MOVE 22 TO WS-SHOWN-LENGTH
     END-IF
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-PCOUNT OR BR-R-FAILED = 1
         CALL "ACCESS-FIND" USING WS-LIST BX-P-UUID(WS-I) WS-ROW
         IF WS-ROW = 0
             CALL "ACCESS-ADD" USING WS-LIST BX-P-NAME(WS-I) BX-P-LENGTH(WS-I) BX-P-UUID(WS-I) WS-OUTCOME
             IF WS-OUTCOME = 0
                 ADD 1 TO WS-CHANGED
                 MOVE AC-COUNT(WS-LIST) TO WS-ROW
                 CALL "BR-NOW-TEXT" USING WS-NOW WS-NOW-LENGTH
                 MOVE WS-NOW TO AC-CREATED(WS-LIST, WS-ROW)
                 MOVE WS-NOW-LENGTH TO AC-CREATED-LENGTH(WS-LIST, WS-ROW)
                 MOVE BS-NAME TO AC-SOURCE(WS-LIST, WS-ROW)
                 MOVE BS-NAME-LENGTH TO AC-SOURCE-LENGTH(WS-LIST, WS-ROW)
                 IF WS-REASON-LENGTH > 0
                     MOVE WS-REASON(1:WS-REASON-LENGTH) TO AC-REASON(WS-LIST, WS-ROW)
                     MOVE WS-REASON-LENGTH TO AC-REASON-LENGTH(WS-LIST, WS-ROW)
                 END-IF
                 MOVE "commands.ban.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT BX-P-NAME(WS-I) BX-P-LENGTH(WS-I)
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
                 CALL "BX-ROW-OF-UUID" USING BX-P-UUID(WS-I) WS-PLAYER
                 IF WS-PLAYER > 0
                     MOVE "multiplayer.disconnect.banned.reason" TO WS-KEY
                     CALL "BX-KEY" USING PB-TEXT WS-KEY
                     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
                     CALL "CORE-SEND-DISCONNECT" USING PL-CONN(WS-PLAYER) PB-TEXT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         IF WS-CHANGED = 0
             MOVE "commands.ban.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-CHANGED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-BAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-BAN.
*> The forms of ban (16 §11.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-BAN.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "ban <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ban <targets:profiles> <reason:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-BAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-PARDON.
*> pardon <targets> (16 §11.5, level 3): each banned profile leaves the ban list; commands.pardon.success [name] is broadcast per
*> profile; none removed is commands.pardon.failed; the result is the number removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG VALUE 2.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-PROFILES" USING WS-INDEX WS-PROFILES
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-PCOUNT OR BR-R-FAILED = 1
         CALL "ACCESS-REMOVE" USING WS-LIST BX-P-UUID(WS-I) WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-CHANGED
             MOVE "commands.pardon.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT BX-P-NAME(WS-I) BX-P-LENGTH(WS-I)
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         IF WS-CHANGED = 0
             MOVE "commands.pardon.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-CHANGED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-PARDON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-PARDON.
*> The form of pardon (16 §11.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-PARDON.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "pardon <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-PARDON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-BANLIST.
*> banlist [ips | players] (16 §11.7, level 3): without bans commands.banlist.none; else commands.banlist.list [count] and one
*> commands.banlist.entry [name or IP, banned by, reason] per ban ("Banned by an operator." when it has no reason), players first, then the
*> IP addresses (both for the plain form), not broadcast; the result is the number of bans listed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-IPS            PIC X(32) VALUE "ips".
 01 WS-NAME-PLAYERS        PIC X(32) VALUE "players".
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-PLAYERS       BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-DEFAULT             PIC X(24) VALUE "Banned by an operator.".
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-LIT" USING WS-NAME-IPS WS-INDEX
     CALL "BX-LIT" USING WS-NAME-PLAYERS WS-INDEX-PLAYERS
     MOVE ACCESS-BANS TO WS-FIRST
     MOVE ACCESS-IPBANS TO WS-LAST
     IF WS-INDEX > 0
         MOVE ACCESS-IPBANS TO WS-FIRST
     END-IF
     IF WS-INDEX-PLAYERS > 0
         MOVE ACCESS-BANS TO WS-LAST
     END-IF
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LIST FROM WS-FIRST BY 1 UNTIL WS-LIST > WS-LAST
         IF WS-LIST = ACCESS-BANS OR WS-LIST = ACCESS-IPBANS
             ADD AC-COUNT(WS-LIST) TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT = 0
         MOVE "commands.banlist.none" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     ELSE
         MOVE "commands.banlist.list" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         PERFORM VARYING WS-LIST FROM WS-FIRST BY 1 UNTIL WS-LIST > WS-LAST
             IF WS-LIST = ACCESS-BANS OR WS-LIST = ACCESS-IPBANS
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AC-COUNT(WS-LIST)
                     MOVE "commands.banlist.entry" TO WS-KEY
                     CALL "BX-KEY" USING PB-TEXT WS-KEY
                     CALL "CMD-TEXT-ARG" USING PB-TEXT AC-NAME(WS-LIST, WS-I) AC-NAME-LENGTH(WS-LIST, WS-I)
                     CALL "CMD-TEXT-ARG" USING PB-TEXT AC-SOURCE(WS-LIST, WS-I) AC-SOURCE-LENGTH(WS-LIST, WS-I)
                     IF AC-REASON-LENGTH(WS-LIST, WS-I) > 0
                         CALL "CMD-TEXT-ARG" USING PB-TEXT AC-REASON(WS-LIST, WS-I) AC-REASON-LENGTH(WS-LIST, WS-I)
                     ELSE
                         MOVE 22 TO WS-INDEX
                         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DEFAULT WS-INDEX
                     END-IF
                     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-COUNT TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-BANLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-BANLIST.
*> The forms of banlist (16 §11.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-BANLIST.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "banlist" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "banlist ips" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "banlist players" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-BANLIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-KICK.
*> kick <targets> [<reason>] (16 §11.8, level 3): in a single-player world (host kind 1) commands.kick.singleplayer.failed; else each
*> target except the host of a world opened to others is disconnected (with the reason as a text, or multiplayer.disconnect.kicked)
*> and commands.kick.success [player, reason] is broadcast; nobody kicked is commands.kick.owner.failed; the result is the number kicked.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-REASON         PIC X(32) VALUE "reason".
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-REASON        BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KICKED              BINARY-LONG.
 01 WS-REASON              PIC X(1024).
 01 WS-REASON-LENGTH       BINARY-LONG.
 01 WS-SHOWN               PIC X(1024).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-DEFAULT             PIC X(24) VALUE "Kicked by an operator".
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO WS-REASON-LENGTH WS-KICKED
     IF CS-HOST-KIND = 1
         MOVE "commands.kick.singleplayer.failed" TO WS-KEY
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
         CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-REASON WS-INDEX-REASON
         IF WS-INDEX-REASON > 0
             CALL "BX-MESSAGE" USING WS-INDEX-REASON WS-REASON WS-REASON-LENGTH
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         IF WS-REASON-LENGTH > 0
             MOVE WS-REASON TO WS-SHOWN
             MOVE WS-REASON-LENGTH TO WS-SHOWN-LENGTH
         ELSE
             MOVE WS-DEFAULT TO WS-SHOWN
             MOVE 21 TO WS-SHOWN-LENGTH
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             IF NOT (CS-HOST-KIND = 2 AND PL-NAME(WS-ROW) = CS-HOST-NAME)
                 ADD 1 TO WS-KICKED
                 INITIALIZE PB-TEXT
                 IF WS-REASON-LENGTH > 0
                     MOVE PB-TEXT-LITERAL TO PB-TX-KIND
                     MOVE WS-REASON-LENGTH TO PB-TX-LENGTH
                     MOVE WS-REASON(1:WS-REASON-LENGTH) TO PB-TX-VALUE
                 ELSE
                     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
                     MOVE "multiplayer.disconnect.kicked" TO PB-TX-VALUE
                     MOVE 29 TO PB-TX-LENGTH
                 END-IF
                 CALL "CORE-SEND-DISCONNECT" USING PL-CONN(WS-ROW) PB-TEXT
                 MOVE "commands.kick.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             END-IF
         END-PERFORM
         IF WS-KICKED = 0
             MOVE "commands.kick.owner.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-KICKED TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-KICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-KICK.
*> The forms of kick (16 §11.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-KICK.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "kick <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "kick <targets:players> <reason:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-KICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-STOP.
*> stop (16 §11.12, level 4): commands.stop.stopping (broadcast) and the run state becomes 1 (stop requested); the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72) VALUE "commands.stop.stopping".
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 1 TO CW-RUN-STATE
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-STOP.
*> The form of stop (16 §11.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE BC-STOP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "stop" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SAVE-ALL.
*> save-all [flush] (16 §11.9, level 4): commands.save.saving (not broadcast), the world is saved (WORLD-SAVE) and commands.save.success is
*> broadcast; the result is 1 (a save that fails, commands.save.failed, is BLOCKED: WORLD-SAVE reports no failure).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72).
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "commands.save.saving" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     CALL "WORLD-SAVE"
     MOVE "commands.save.success" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-SAVE-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SAVE-ALL.
*> The forms of save-all (16 §11.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SAVE-ALL.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "save-all" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "save-all flush" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SAVE-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SAVE-SWITCH.
*> save-on and save-off (16 §11.10, §11.11, level 4): the automatic saving is switched (BW-SAVE-OFF) with commands.save.enabled or
*> disabled (broadcast); already in the state asked for is commands.save.alreadyOn or alreadyOff; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-WANT-OFF            BINARY-LONG.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-WANT-OFF
     IF BA-NAME(1) = "save-off"
         MOVE 1 TO WS-WANT-OFF
     END-IF
     IF BW-SAVE-OFF = WS-WANT-OFF
         IF WS-WANT-OFF = 1
             MOVE "commands.save.alreadyOff" TO WS-KEY
         ELSE
             MOVE "commands.save.alreadyOn" TO WS-KEY
         END-IF
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     ELSE
         MOVE WS-WANT-OFF TO BW-SAVE-OFF
         IF WS-WANT-OFF = 1
             MOVE "commands.save.disabled" TO WS-KEY
         ELSE
             MOVE "commands.save.enabled" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SAVE-SWITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SAVE-SWITCH.
*> The forms of save-on and save-off (16 §11.10, §11.11).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND-ON          BINARY-LONG VALUE BC-SAVE-ON.
 01 WS-COMMAND-OFF         BINARY-LONG VALUE BC-SAVE-OFF.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "save-off" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND-OFF WS-PATH
     MOVE "save-on" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND-ON WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SAVE-SWITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-WHITELIST.
*> whitelist on | off | list | reload | add <targets> | remove <targets> (16 §11.22, level 3): on and off switch AC-ENFORCED (already
*> in the state asked is commands.whitelist.alreadyOn or alreadyOff); list is commands.whitelist.list [count, names joined by ", "] or
*> commands.whitelist.none (not broadcast; the result is the count); add and remove edit the allow list (commands.whitelist.add.success,
*> remove.success per profile, broadcast; none changed is add.failed or remove.failed; the result is the number changed) and remove
*> with enforcement disconnects the online players who are not listed with multiplayer.disconnect.not_whitelisted; reload reads the
*> allow list of access.dat again (the operators, the bans and the enforcement flag of memory stay; a missing file is an empty list).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-PROFILES.
    05 BX-PCOUNT            BINARY-LONG.
    05 BX-PROFILE           OCCURS 64 TIMES.
       10 BX-P-NAME          PIC X(16).
       10 BX-P-LENGTH        BINARY-LONG.
       10 BX-P-UUID          PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-NAMES               PIC X(4800).
 01 WS-POS                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-LAST                PIC X(32).
 01 WS-SAVED-OPS.
    05 WS-OPS-COUNT         BINARY-LONG.
    05 WS-OPS-ENTRY         PIC X(300) OCCURS 256 TIMES.
 01 WS-SAVED-BANS.
    05 WS-BANS-COUNT        BINARY-LONG.
    05 WS-BANS-ENTRY        PIC X(300) OCCURS 256 TIMES.
 01 WS-SAVED-FLAG          PIC 9.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-SUFFIX              PIC X(128) VALUE "/access.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-FILE-OUTCOME        BINARY-LONG.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

 FAIL-PLAIN.
     MOVE SPACES TO WS-A1 WS-A2
     MOVE 0 TO WS-N-ARGS WS-L1 WS-L2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

 SWITCH-ENFORCEMENT.
     IF AC-ENFORCED = 1 AND WS-LAST = "on"
         MOVE "commands.whitelist.alreadyOn" TO WS-KEY
         PERFORM FAIL-PLAIN
     END-IF
     IF AC-ENFORCED = 0 AND WS-LAST = "off" AND BR-R-FAILED = 0
         MOVE "commands.whitelist.alreadyOff" TO WS-KEY
         PERFORM FAIL-PLAIN
     END-IF
     IF BR-R-FAILED = 0
         IF WS-LAST = "on"
             MOVE 1 TO AC-ENFORCED
             MOVE "commands.whitelist.enabled" TO WS-KEY
         ELSE
             MOVE 0 TO AC-ENFORCED
             MOVE "commands.whitelist.disabled" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF.

 LIST-NAMES.
     IF AC-COUNT(WS-LIST) = 0
         MOVE "commands.whitelist.none" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
     ELSE
         MOVE SPACES TO WS-NAMES
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AC-COUNT(WS-LIST)
             IF WS-I > 1
                 STRING ", " DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POS
             END-IF
             STRING AC-NAME(WS-LIST, WS-I)(1:AC-NAME-LENGTH(WS-LIST, WS-I)) DELIMITED BY SIZE
                 INTO WS-NAMES WITH POINTER WS-POS
         END-PERFORM
         COMPUTE WS-LENGTH = WS-POS - 1
         MOVE "commands.whitelist.list" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT AC-COUNT(WS-LIST)
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE AC-COUNT(WS-LIST) TO BR-R-RESULT.

 RELOAD-LIST.
     MOVE AC-LIST(1) TO WS-SAVED-OPS
     MOVE AC-LIST(2) TO WS-SAVED-BANS
     MOVE AC-ENFORCED TO WS-SAVED-FLAG
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PK-BUFFER WS-FILE-OUTCOME
     CALL "PB-FREE" USING PK-BUFFER
     MOVE 0 TO AC-COUNT(3)
     IF WS-FILE-OUTCOME = 0
         CALL "ACCESS-DAT-READ"
     END-IF
     MOVE WS-SAVED-OPS TO AC-LIST(1)
     MOVE WS-SAVED-BANS TO AC-LIST(2)
     MOVE WS-SAVED-FLAG TO AC-ENFORCED
     MOVE "commands.whitelist.reloaded" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 1 TO BR-R-RESULT.

*> Every online player who is not on the allow list is disconnected (the enforcement is on).
 KICK-UNLISTED.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1
             CALL "ACCESS-FIND" USING WS-LIST PL-UUID(WS-PLAYER) WS-ROW
             IF WS-ROW = 0
                 INITIALIZE PB-TEXT
                 MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
                 MOVE "multiplayer.disconnect.not_whitelisted" TO PB-TX-VALUE
                 MOVE 38 TO PB-TX-LENGTH
                 CALL "CORE-SEND-DISCONNECT" USING PL-CONN(WS-PLAYER) PB-TEXT
             END-IF
         END-IF
     END-PERFORM.

 EDIT-LIST.
     CALL "BX-FIND" USING WS-NAME-TARGETS WS-INDEX
     CALL "BX-PROFILES" USING WS-INDEX WS-PROFILES
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-PCOUNT OR BR-R-FAILED = 1
         PERFORM EDIT-ONE
     END-PERFORM
     IF BR-R-FAILED = 0
         IF WS-CHANGED = 0
             IF WS-LAST = "add"
                 MOVE "commands.whitelist.add.failed" TO WS-KEY
             ELSE
                 MOVE "commands.whitelist.remove.failed" TO WS-KEY
             END-IF
             PERFORM FAIL-PLAIN
         ELSE
             MOVE WS-CHANGED TO BR-R-RESULT
             IF WS-LAST = "remove" AND AC-ENFORCED = 1
                 PERFORM KICK-UNLISTED
             END-IF
         END-IF
     END-IF.

 EDIT-ONE.
     CALL "ACCESS-FIND" USING WS-LIST BX-P-UUID(WS-I) WS-ROW
     IF WS-LAST = "add" AND WS-ROW = 0
         CALL "ACCESS-ADD" USING WS-LIST BX-P-NAME(WS-I) BX-P-LENGTH(WS-I) BX-P-UUID(WS-I) WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-CHANGED
             MOVE "commands.whitelist.add.success" TO WS-KEY
             PERFORM TELL-NAME
         END-IF
     END-IF
     IF WS-LAST = "remove" AND WS-ROW > 0
         CALL "ACCESS-REMOVE" USING WS-LIST BX-P-UUID(WS-I) WS-OUTCOME
         ADD 1 TO WS-CHANGED
         MOVE "commands.whitelist.remove.success" TO WS-KEY
         PERFORM TELL-NAME
     END-IF.

 TELL-NAME.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT BX-P-NAME(WS-I) BX-P-LENGTH(WS-I)
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 MAIN-LINE.
     MOVE SPACES TO WS-LAST
     IF BA-ARG(BR-R-COUNT) = 1
         MOVE BA-NAME(BR-R-COUNT - 1) TO WS-LAST
     ELSE
         MOVE BA-NAME(BR-R-COUNT) TO WS-LAST
     END-IF
     EVALUATE WS-LAST
         WHEN "on"
         WHEN "off"
             PERFORM SWITCH-ENFORCEMENT
         WHEN "list"
             PERFORM LIST-NAMES
         WHEN "reload"
             PERFORM RELOAD-LIST
         WHEN OTHER
             PERFORM EDIT-LIST
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-WHITELIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-WHITELIST.
*> The forms of whitelist (16 §11.22).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-WHITELIST.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "whitelist on" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "whitelist off" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "whitelist list" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "whitelist reload" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "whitelist add <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "whitelist remove <targets:profiles>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-WHITELIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-IPV4.
*> USING text (PIC X(64)), length, ok out, address out (PIC X(16), the text space padded: the identity of the entry): 1 when the text is a dotted IPv4 address
*> (four numbers of 1 to 3 digits, each at most 255); IPv6 addresses are BLOCKED (an entry holds at most 16 characters).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-GROUPS              BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-ADDRESS              PIC X(16).
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-OK L-ADDRESS.
     MOVE 1 TO L-OK
     MOVE SPACES TO L-ADDRESS
     IF L-LENGTH < 7 OR L-LENGTH > 15
         MOVE 0 TO L-OK
     ELSE
         MOVE L-TEXT(1:L-LENGTH) TO L-ADDRESS
         MOVE 1 TO WS-GROUPS
         MOVE 0 TO WS-DIGITS WS-VALUE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
             MOVE L-TEXT(WS-I:1) TO WS-CH
             EVALUATE TRUE
                 WHEN WS-CH >= "0" AND WS-CH <= "9"
                     ADD 1 TO WS-DIGITS
                     COMPUTE WS-VALUE = WS-VALUE * 10 + FUNCTION ORD(WS-CH) - 49
                     IF WS-DIGITS > 3 OR WS-VALUE > 255
                         MOVE 0 TO L-OK
                     END-IF
                 WHEN WS-CH = "."
                     IF WS-DIGITS = 0
                         MOVE 0 TO L-OK
                     END-IF
                     ADD 1 TO WS-GROUPS
                     MOVE 0 TO WS-DIGITS WS-VALUE
                 WHEN OTHER
                     MOVE 0 TO L-OK
             END-EVALUATE
         END-PERFORM
         IF WS-GROUPS NOT = 4 OR WS-DIGITS = 0
             MOVE 0 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BX-IPV4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-BAN-IP.
*> ban-ip <target> [<reason>] (16 §11.4, level 3): the target is an IPv4 address (a player's name would give that player's address: BLOCKED, the core
*> keeps no peer address, so a name is commands.banip.invalid); an address already banned is commands.banip.failed; else it is added to the IP list
*> (creation time, the source's name, forever, the reason when given) and commands.banip.success [address, reason] is broadcast ("Banned by an operator."
*> when none was given); the result is the number of players disconnected (0: no player address is known).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-REASON         PIC X(32) VALUE "reason".
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-REASON        BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ADDRESS             PIC X(16).
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG VALUE 4.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-REASON              PIC X(1024).
 01 WS-REASON-LENGTH       BINARY-LONG VALUE 0.
 01 WS-SHOWN               PIC X(1024).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-DEFAULT             PIC X(24) VALUE "Banned by an operator.".
 01 WS-KEY                 PIC X(72).
 01 WS-NOW                 PIC X(32).
 01 WS-NOW-LENGTH          BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

 MAIN-LINE.
     MOVE 0 TO WS-REASON-LENGTH
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
     MOVE SPACES TO WS-TEXT
     IF WS-LENGTH > 0 AND WS-LENGTH <= 64
         MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-LENGTH) TO WS-TEXT
     END-IF
     CALL "BX-IPV4" USING WS-TEXT WS-LENGTH WS-OK WS-ADDRESS
     CALL "BX-FIND" USING WS-NAME-REASON WS-INDEX-REASON
     IF WS-INDEX-REASON > 0
         CALL "BX-MESSAGE" USING WS-INDEX-REASON WS-REASON WS-REASON-LENGTH
     END-IF
     EVALUATE TRUE
         WHEN WS-OK = 0
             MOVE "commands.banip.invalid" TO WS-KEY
             PERFORM FAIL-PLAIN
         WHEN OTHER
             CALL "ACCESS-FIND" USING WS-LIST WS-ADDRESS WS-ROW
             IF WS-ROW > 0
                 MOVE "commands.banip.failed" TO WS-KEY
                 PERFORM FAIL-PLAIN
             END-IF
     END-EVALUATE
     IF BR-R-FAILED = 0
         MOVE WS-ADDRESS TO WS-UUID
         CALL "ACCESS-ADD" USING WS-LIST WS-ADDRESS WS-LENGTH WS-UUID WS-OUTCOME
         MOVE AC-COUNT(WS-LIST) TO WS-ROW
         CALL "BR-NOW-TEXT" USING WS-NOW WS-NOW-LENGTH
         MOVE WS-NOW TO AC-CREATED(WS-LIST, WS-ROW)
         MOVE WS-NOW-LENGTH TO AC-CREATED-LENGTH(WS-LIST, WS-ROW)
         MOVE BS-NAME TO AC-SOURCE(WS-LIST, WS-ROW)
         MOVE BS-NAME-LENGTH TO AC-SOURCE-LENGTH(WS-LIST, WS-ROW)
         IF WS-REASON-LENGTH > 0
             MOVE WS-REASON(1:WS-REASON-LENGTH) TO AC-REASON(WS-LIST, WS-ROW)
             MOVE WS-REASON-LENGTH TO AC-REASON-LENGTH(WS-LIST, WS-ROW)
             MOVE WS-REASON TO WS-SHOWN
             MOVE WS-REASON-LENGTH TO WS-SHOWN-LENGTH
         ELSE
             MOVE WS-DEFAULT TO WS-SHOWN
             MOVE 22 TO WS-SHOWN-LENGTH
         END-IF
         MOVE "commands.banip.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ADDRESS WS-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 0 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-BAN-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-BAN-IP.
*> The forms of ban-ip (16 §11.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-BAN-IP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "ban-ip <target:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "ban-ip <target:word> <reason:message>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-BAN-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-PARDON-IP.
*> pardon-ip <target> (16 §11.6, level 3): the target must be an IPv4 address (else commands.pardonip.invalid) that is banned (else
*> commands.pardonip.failed); it leaves the IP list; commands.pardonip.success [address] is broadcast; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-INDEX               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ADDRESS             PIC X(16).
 01 WS-LIST                BINARY-LONG VALUE 4.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-TARGET WS-INDEX
     COMPUTE WS-LENGTH = BA-END(WS-INDEX) - BA-START(WS-INDEX)
     MOVE SPACES TO WS-TEXT
     IF WS-LENGTH > 0 AND WS-LENGTH <= 64
         MOVE BR-R-LINE(BA-START(WS-INDEX) + 1:WS-LENGTH) TO WS-TEXT
     END-IF
     CALL "BX-IPV4" USING WS-TEXT WS-LENGTH WS-OK WS-ADDRESS
     MOVE 1 TO WS-OUTCOME
     IF WS-OK = 1
         CALL "ACCESS-REMOVE" USING WS-LIST WS-ADDRESS WS-OUTCOME
     END-IF
     EVALUATE TRUE
         WHEN WS-OK = 0
             MOVE "commands.pardonip.invalid" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         WHEN WS-OUTCOME NOT = 0
             MOVE "commands.pardonip.failed" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         WHEN OTHER
             MOVE "commands.pardonip.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ADDRESS WS-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 1 TO BR-R-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-PARDON-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-PARDON-IP.
*> The form of pardon-ip (16 §11.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-PARDON-IP.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "pardon-ip <target:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-PARDON-IP.

*> ---- Lane cmds-a: the dev and debug commands (16 §12), the profilers, transfer, serverpack, fetchprofile, publish, unpublish ----

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-RAISE.
*> USING key (PIC X(72)), argument count, argument 1 (PIC X(64)), its length, argument 2 (PIC X(64)), its length: the command fails
*> with that exception (BR-RAISE; BR-R-FAILED 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-N-ARGS               BINARY-LONG.
 01 L-A1                   PIC X(64).
 01 L-L1                   BINARY-LONG.
 01 L-A2                   PIC X(64).
 01 L-L2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-N-ARGS L-A1 L-L1 L-A2 L-L2.
     CALL "BR-RAISE" USING L-KEY L-N-ARGS L-A1 L-L1 L-A2 L-L2 WS-RC
     MOVE 1 TO BR-R-FAILED
     GOBACK.
 END PROGRAM BA-RAISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-RAISE-PLAIN.
*> USING key (PIC X(72)): the command fails with that exception, which has no arguments.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 PROCEDURE DIVISION USING L-KEY.
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BA-RAISE" USING L-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
     GOBACK.
 END PROGRAM BA-RAISE-PLAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-SAY.
*> USING key (PIC X(72)), broadcast flag (1 = B): the source is told the text of that key with no arguments (BR-FEEDBACK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-BROADCAST            BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-BROADCAST.
     CALL "BX-KEY" USING PB-TEXT L-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT L-BROADCAST
     GOBACK.
 END PROGRAM BA-SAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-SEND.
*> USING packet (PB-BUFFER), dimension row (0 = every dimension, else a row of the DIMENSIONS.cpy table: PL-DIM, BS-DIM): the packet is sent to every player in play (join
*> sent) of that dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND (L-DIM = 0 OR PL-DIM(WS-ROW) = L-DIM)
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-FIXED.
*> USING scaled value (BINARY-DOUBLE, not negative: the number times 10 to the decimals), decimals (1 or 2), text out (PIC X(32)),
*> length out: the number with that many decimals (the %.1f and %.2f of 16 §4.11, §11.17).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIVISOR             BINARY-DOUBLE.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-FRAC                BINARY-DOUBLE.
 01 WS-EDIT                PIC -(18)9.
 01 WS-FRAC-DIGITS         PIC 99.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 01 L-DECIMALS             BINARY-LONG.
 01 L-TEXT                 PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-DECIMALS L-TEXT L-LENGTH.
     COMPUTE WS-DIVISOR = 10 ** L-DECIMALS
     DIVIDE L-VALUE BY WS-DIVISOR GIVING WS-INT REMAINDER WS-FRAC
     MOVE WS-INT TO WS-EDIT
     MOVE WS-FRAC TO WS-FRAC-DIGITS
     MOVE SPACES TO L-TEXT
     STRING FUNCTION TRIM(WS-EDIT) "." WS-FRAC-DIGITS(3 - L-DECIMALS:L-DECIMALS) DELIMITED BY SIZE INTO L-TEXT
     COMPUTE L-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-TEXT))
     GOBACK.
 END PROGRAM BA-FIXED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-HOST-KIND.
*> USING kind out (BINARY-LONG): CS-HOST-KIND of the settings of the open world (0 dedicated server, 1 single-player, 2 opened to others;
*> 0 while no world is open: the settings are still all zero bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF CS-HOST-KIND IS NUMERIC
         MOVE CS-HOST-KIND TO L-KIND
     ELSE
         MOVE 0 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM BA-HOST-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-CHASE.
*> chase follow [<host> <port>] | lead [<bind_address> <port>] | stop (16 §12, §14a, level 0, DEBUG_CHASE_COMMAND): the chase (a test-time follower
*> of another server's player positions) has no subsystem here and the catalog names no message; the result is 0. BLOCKED docs: the
*> already-running failure of 14a has no key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-CHASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-CHASE.
*> The forms of chase (16 §12, §14a): the hostless forms use the defaults localhost:10000 and 0.0.0.0:10000.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-CHASE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "chase follow" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "chase follow <host:word> <port:int:1:65535>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "chase lead" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "chase lead <bind_address:word> <port:int:1024:65535>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "chase stop" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-CHASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEBUGPATH.
*> debugpath <to> (16 §12, level 2, dev): no pathfinding debug view exists here and the catalog names no message or result; the result is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-DEBUGPATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEBUGPATH.
*> The form of debugpath (16 §12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEBUGPATH.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "debugpath <to:pos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DEBUGPATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEBUGMOBSPAWNING.
*> debugmobspawning <mob_category> <at> (16 §12, level 2, dev): no spawn debug view exists here and the catalog names no message or result;
*> the result is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-DEBUGMOBSPAWNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEBUGMOBSPAWNING.
*> The forms of debugmobspawning (16 §12): each spawn category (18 §1.2, serialized names) followed by a block position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEBUGMOBSPAWNING.
 01 WS-PATH                PIC X(256).
 01 WS-CATEGORIES.
    05 FILLER PIC X(28) VALUE "monster".
    05 FILLER PIC X(28) VALUE "creature".
    05 FILLER PIC X(28) VALUE "ambient".
    05 FILLER PIC X(28) VALUE "axolotls".
    05 FILLER PIC X(28) VALUE "underground_water_creature".
    05 FILLER PIC X(28) VALUE "water_creature".
    05 FILLER PIC X(28) VALUE "water_ambient".
    05 FILLER PIC X(28) VALUE "misc".
 01 WS-TABLE REDEFINES WS-CATEGORIES.
    05 WS-CATEGORY          PIC X(28) OCCURS 8 TIMES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-PATH
         STRING "debugmobspawning " FUNCTION TRIM(WS-CATEGORY(WS-I)) " <at:pos>" DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-DEBUGMOBSPAWNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEBUGCONFIG.
*> debugconfig config <target> | unconfig <target> | dialog <target> <dialog> (16 §12, level 3, dev, dedicated): moving a player into and out of the
*> configuration phase is not part of the play loop here and the catalog names no message or result; the result is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-DEBUGCONFIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEBUGCONFIG.
*> The forms of debugconfig (16 §12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEBUGCONFIG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "debugconfig config <target:player>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "debugconfig unconfig <target:uuid>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "debugconfig dialog <target:uuid> <dialog:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DEBUGCONFIG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RAID.
*> raid start <omenlvl> | stop | check | sound <type> | spawnleader | setomen <level> | glow (16 §12, §14a, level 3, dev): raids do not exist here; the
*> catalog names no message ("none referenced") and gives the result 1 (start: -1 on a failure that cannot happen without raids).
*> BLOCKED docs: the failures "no raid" and "not in a raid" have no keys.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-RAID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RAID.
*> The forms of raid (16 §12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RAID.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "raid start <omenlvl:int:0:>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid stop" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid check" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid sound <type:component>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid spawnleader" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid setomen <level:int:0:>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "raid glow" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-RAID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SPAWN-ARMOR-TRIMS.
*> spawn_armor_trims *_lag_my_game | <pattern> (16 §12, §14a, level 2, dev): the armor stand display of every trim is not built here; the catalog
*> names no message and gives the result 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 PROCEDURE DIVISION.
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-SPAWN-ARMOR-TRIMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SPAWN-ARMOR-TRIMS.
*> The forms of spawn_armor_trims (16 §12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SPAWN-ARMOR-TRIMS.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "spawn_armor_trims *_lag_my_game" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spawn_armor_trims <pattern:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SPAWN-ARMOR-TRIMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SERVERPACK.
*> serverpack push <url> <uuid> <hash> | pop <uuid> (16 §11.21, level 2, dev): every player in play is sent Resource Pack Push (0x52: pack id, URL, hash,
*> required false, no prompt) or Resource Pack Pop (0x51, the pack id present); no message; the result is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-PUSH           PIC X(32) VALUE "push".
 01 WS-NAME-URL            PIC X(32) VALUE "url".
 01 WS-NAME-UUID           PIC X(32) VALUE "uuid".
 01 WS-NAME-HASH           PIC X(32) VALUE "hash".
 01 WS-LIT                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-URL                 PIC X(1024).
 01 WS-HASH                PIC X(40).
 01 WS-HASH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(36).
 01 WS-UUID                PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-ID-PUSH             BINARY-LONG VALUE 82.
 01 WS-ID-POP              BINARY-LONG VALUE 81.
 01 WS-MAX-URL             BINARY-LONG VALUE 32767.
 01 WS-MAX-HASH            BINARY-LONG VALUE 40.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 01 WS-TRUE                BINARY-LONG VALUE 1.
 01 WS-EVERY               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-UUID WS-INDEX
     MOVE BA-START(WS-INDEX) TO WS-START
     COMPUTE WS-LENGTH = FUNCTION MIN(BA-END(WS-INDEX) - WS-START, 36)
     MOVE SPACES TO WS-TEXT
     MOVE BR-R-LINE(WS-START + 1:WS-LENGTH) TO WS-TEXT
     CALL "CONFIG-PACK-UUID" USING WS-TEXT WS-UUID
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BX-LIT" USING WS-NAME-PUSH WS-LIT
     IF WS-LIT > 0
         CALL "BX-FIND" USING WS-NAME-URL WS-INDEX
         MOVE BA-START(WS-INDEX) TO WS-START
         COMPUTE WS-LENGTH = BA-END(WS-INDEX) - WS-START
         IF WS-LENGTH > 1 AND BR-R-LINE(WS-START + 1:1) = '"'
             ADD 1 TO WS-START
             SUBTRACT 2 FROM WS-LENGTH
         END-IF
         MOVE SPACES TO WS-URL
         MOVE BR-R-LINE(WS-START + 1:WS-LENGTH) TO WS-URL
         CALL "BX-FIND" USING WS-NAME-HASH WS-INDEX
         MOVE BA-START(WS-INDEX) TO WS-START
         COMPUTE WS-HASH-LENGTH = FUNCTION MIN(BA-END(WS-INDEX) - WS-START, 40)
         MOVE SPACES TO WS-HASH
         MOVE BR-R-LINE(WS-START + 1:WS-HASH-LENGTH) TO WS-HASH
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID-PUSH
         CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
         CALL "PB-PUT-STRING" USING PB-BUFFER WS-URL WS-LENGTH WS-MAX-URL
         CALL "PB-PUT-STRING" USING PB-BUFFER WS-HASH WS-HASH-LENGTH WS-MAX-HASH
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID-POP
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TRUE
         CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     END-IF
     CALL "BA-SEND" USING PB-BUFFER WS-EVERY
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-SERVERPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SERVERPACK.
*> The forms of serverpack (16 §11.21).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SERVERPACK.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "serverpack push <url:phrase> <uuid:uuid> <hash:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "serverpack pop <uuid:uuid>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SERVERPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TRANSFER.
*> transfer <hostname> [<port> [<players>]] (16 §11.13, level 3): each target (the source player when none is given; the console must name
*> players) is sent Transfer (0x84: host, port, default 25565); commands.transfer.success.single [player, host, port] or .multiple [count, host,
*> port] is broadcast; the result is the number of players. (commands.transfer.error.no_players cannot occur: a selector that finds no player fails
*> in the framework.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-HOST           PIC X(32) VALUE "hostname".
 01 WS-NAME-PORT           PIC X(32) VALUE "port".
 01 WS-NAME-PLAYERS        PIC X(32) VALUE "players".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-START               BINARY-LONG.
 01 WS-HOST                PIC X(256).
 01 WS-HOST-LENGTH         BINARY-LONG.
 01 WS-PORT                BINARY-LONG VALUE 25565.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ID                  BINARY-LONG VALUE 132.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-HOST WS-INDEX
     MOVE BA-START(WS-INDEX) TO WS-START
     COMPUTE WS-HOST-LENGTH = FUNCTION MIN(BA-END(WS-INDEX) - WS-START, 256)
     MOVE SPACES TO WS-HOST
     MOVE BR-R-LINE(WS-START + 1:WS-HOST-LENGTH) TO WS-HOST
     MOVE 25565 TO WS-PORT
     CALL "BX-FIND" USING WS-NAME-PORT WS-INDEX
     IF WS-INDEX > 0
         MOVE BA-IVAL(WS-INDEX) TO WS-PORT
     END-IF
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-PLAYERS WS-ROWS
     IF BR-R-FAILED = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
         CALL "PB-PUT-STRING" USING PB-BUFFER WS-HOST WS-HOST-LENGTH WS-MAX
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PORT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             CALL "CORE-SEND" USING PL-CONN(BX-ROW(WS-I)) PB-BUFFER
         END-PERFORM
         CALL "PB-FREE" USING PB-BUFFER
         IF BX-COUNT = 1
             MOVE "commands.transfer.success.single" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(1)) PL-NAME-LENGTH(BX-ROW(1))
         ELSE
             MOVE "commands.transfer.success.multiple" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-HOST WS-HOST-LENGTH
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-PORT
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-TRANSFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TRANSFER.
*> The forms of transfer (16 §11.13): the port defaults to 25565.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TRANSFER.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "transfer <hostname:word>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "transfer <hostname:word> <port:int:1:65535>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "transfer <hostname:word> <port:int:1:65535> <players:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TRANSFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-WARDEN-SPAWN-TRACKER.
*> warden_spawn_tracker clear | set <warning_level> (16 §12, §14a, level 2, dev): the player running it is the target (the console fails with
*> permissions.requires.player); wardens do not exist here, so no warning level is kept; commands.warden_spawn_tracker.clear.success.single or
*> .set.success.single [player] is broadcast; the result is the tracker total, 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGET         PIC X(32) VALUE "target".
 01 WS-NAME-CLEAR          PIC X(32) VALUE "clear".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-LIT                 BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-TARGET WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-LIT" USING WS-NAME-CLEAR WS-LIT
         IF WS-LIT > 0
             MOVE "commands.warden_spawn_tracker.clear.success.single" TO WS-KEY
         ELSE
             MOVE "commands.warden_spawn_tracker.set.success.single" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(1)) PL-NAME-LENGTH(BX-ROW(1))
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-WARDEN-SPAWN-TRACKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-WARDEN-SPAWN-TRACKER.
*> The forms of warden_spawn_tracker (16 §12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-WARDEN-SPAWN-TRACKER.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "warden_spawn_tracker clear" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "warden_spawn_tracker set <warning_level:int:0:4>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-WARDEN-SPAWN-TRACKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-FETCHPROFILE.
*> fetchprofile name <name> | id <id> | entity <entity> (16 §11.20, level 2): the profile service is online-only and a server without it cannot
*> resolve: name and id fail with commands.fetchprofile.name.failure [name] and .id.failure [id] (the failure line of the lookup); entity of a player
*> is commands.fetchprofile.entity.success [name, "name (uuid)": the serialized profile is not in the docs] and of any other entity
*> commands.fetchprofile.no_profile [entity type key] (both failures red, the success not broadcast: the B/Q mark is not in the docs); the result is
*> 1 (the lookup runs asynchronously).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-NAME           PIC X(32) VALUE "name".
 01 WS-NAME-ID             PIC X(32) VALUE "id".
 01 WS-NAME-ENTITY         PIC X(32) VALUE "entity".
 01 WS-LIT                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-KEY                 PIC X(72).
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PROFILE             PIC X(64).
 01 WS-PROFILE-LENGTH      BINARY-LONG.
 01 WS-HEX                 PIC X(32).
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-PLAYER-NAME         PIC X(16).
 01 WS-PLAYER-LENGTH       BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with the text of the argument WS-INDEX.
 FAIL-TEXT.
     MOVE BA-START(WS-INDEX) TO WS-START
     COMPUTE WS-LENGTH = FUNCTION MIN(BA-END(WS-INDEX) - WS-START, 256)
     MOVE SPACES TO WS-TEXT
     MOVE BR-R-LINE(WS-START + 1:WS-LENGTH) TO WS-TEXT
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     CALL "BR-FAILURE" USING PB-TEXT.

*> The entity of the row WS-ROW: a player has its name and offline uuid as profile, any other entity has no profile.
 ENTITY-RESULT.
     IF WS-ROW > 0
         MOVE "commands.fetchprofile.entity.success" TO WS-KEY
         MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(PL-UUID(WS-ROW))) TO WS-HEX
         STRING WS-HEX(1:8) "-" WS-HEX(9:4) "-" WS-HEX(13:4) "-" WS-HEX(17:4) "-" WS-HEX(21:12) DELIMITED BY SIZE
             INTO WS-UUID-TEXT
         MOVE PL-NAME(WS-ROW) TO WS-PLAYER-NAME
         MOVE PL-NAME-LENGTH(WS-ROW) TO WS-PLAYER-LENGTH
         MOVE SPACES TO WS-PROFILE
         STRING WS-PLAYER-NAME(1:WS-PLAYER-LENGTH) " (" WS-UUID-TEXT ")" DELIMITED BY SIZE INTO WS-PROFILE
         COMPUTE WS-PROFILE-LENGTH = WS-PLAYER-LENGTH + 39
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-PLAYER-NAME WS-PLAYER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-PROFILE WS-PROFILE-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     ELSE
         MOVE "commands.fetchprofile.no_profile" TO WS-KEY
         COMPUTE WS-ENTITY = 0 - WS-ROW
         COMPUTE WS-ROW = EN-TYPE(WS-ENTITY) + 1
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT ET-KEY(WS-ROW) ET-KEY-LENGTH(WS-ROW)
         CALL "BR-FAILURE" USING PB-TEXT
     END-IF.

 MAIN-LINE.
     MOVE 1 TO BR-R-RESULT
     CALL "BX-LIT" USING WS-NAME-NAME WS-LIT
     IF WS-LIT > 0
         MOVE "commands.fetchprofile.name.failure" TO WS-KEY
         CALL "BX-FIND" USING WS-NAME-NAME WS-INDEX
         PERFORM FAIL-TEXT
     ELSE
         CALL "BX-LIT" USING WS-NAME-ID WS-LIT
         IF WS-LIT > 0
             MOVE "commands.fetchprofile.id.failure" TO WS-KEY
             CALL "BX-FIND" USING WS-NAME-ID WS-INDEX
             PERFORM FAIL-TEXT
         ELSE
             CALL "BX-FIND" USING WS-NAME-ENTITY WS-INDEX
             CALL "BX-RESOLVE" USING WS-INDEX WS-ROWS
             IF BR-R-FAILED = 0
                 MOVE BX-ROW(1) TO WS-ROW
                 PERFORM ENTITY-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-FETCHPROFILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-FETCHPROFILE.
*> The forms of fetchprofile (16 §11.20).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-FETCHPROFILE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "fetchprofile name <name:greedy>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "fetchprofile id <id:uuid>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "fetchprofile entity <entity:entity>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-FETCHPROFILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-PUBLISH.
*> publish [<allowCommands> [<port>]] (16 §11.15, level 4, a hosted world; world-types 11.1): a world already published is
*> commands.publish.alreadyPublished.lan [port]; else the port is the one given (0 is kept: the artifact announces the number it was given) or, when
*> omitted, a free port (a listener on port 0 that is closed again), the world becomes a world opened to others (CORE-OPEN-TO-OTHERS: guests in
*> survival, operators when allowCommands is true), commands.publish.started.lan [port] is broadcast and the result is the port. The core binds
*> nothing: the host listens on BP-PORT while BP-PUBLISHED is 1. BLOCKED docs: commands.publish.failed (a bind failure is the host's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY BRCMDA.
 COPY PROTO.
 01 WS-NAME-ALLOW          PIC X(32) VALUE "allowCommands".
 01 WS-NAME-PORT           PIC X(32) VALUE "port".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ALLOW               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HANDLE              BINARY-LONG VALUE 0.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PORT                BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-NUMBER              PIC X(16).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     IF BP-PUBLISHED = 1
         MOVE BP-PORT TO WS-EDIT
         MOVE "commands.publish.alreadyPublished.lan" TO WS-KEY
         MOVE SPACES TO WS-A1 WS-A2
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
         COMPUTE WS-NUMBER-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
         CALL "BA-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-NUMBER-LENGTH WS-A2 WS-L2
     ELSE
         MOVE 0 TO WS-ALLOW
         CALL "BX-FIND" USING WS-NAME-ALLOW WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-ALLOW
         END-IF
         CALL "BX-FIND" USING WS-NAME-PORT WS-INDEX
         IF WS-INDEX > 0
             MOVE BA-IVAL(WS-INDEX) TO WS-PORT
         ELSE
             MOVE 0 TO WS-PORT
             CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-HANDLE WS-PORT RETURNING WS-STATUS
             CALL STATIC "cc_net_close" USING BY VALUE WS-HANDLE
         END-IF
         MOVE WS-PORT TO BP-PORT
         MOVE 1 TO BP-PUBLISHED
         CALL "CORE-OPEN-TO-OTHERS" USING WS-MODE WS-ALLOW
         MOVE "commands.publish.started.lan" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-PORT
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-PORT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-PUBLISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-PUBLISH.
*> The forms of publish (16 §11.15).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE BC-PUBLISH.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "publish" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "publish <allowCommands:bool>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "publish <allowCommands:bool> <port:int:0:65535>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-PUBLISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-UNPUBLISH.
*> unpublish (16 §11.16, level 4, a hosted world): a published world is closed (BP-PUBLISHED 0, the host stops listening; the world stays a world opened to
*> others for the session, CORE-OPEN-TO-OTHERS), commands.unpublish.success is broadcast and the result is 1; else commands.unpublish.notPublished.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY BRCMDA.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     IF BP-PUBLISHED = 0
         MOVE "commands.unpublish.notPublished" TO WS-KEY
         CALL "BA-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE 0 TO BP-PUBLISHED BP-PORT
         MOVE "commands.unpublish.success" TO WS-KEY
         CALL "BA-SAY" USING WS-KEY WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-UNPUBLISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-UNPUBLISH.
*> The form of unpublish (16 §11.16).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE BC-UNPUBLISH.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "unpublish" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-UNPUBLISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-PROFILE.
*> USING which (1 debug, 2 perf): the profiler runs of `debug start|stop` (16 §11.19, level 3, broadcast) and `perf start|stop` (§11.17, level 4, not broadcast):
*> start while running is commands.<name>.alreadyRunning, stop while stopped .notRunning; start remembers the tick (BF-START) and tells .started; stop
*> tells .stopped [seconds (ticks / 20, two decimals), ticks, ticks per second] and ends the run. The result is 0, and of debug stop the ticks per second
*> as an integer. BLOCKED docs: the debug report file of perf stop (commands.perf.reportSaved) has no format; the 10 second run of perf is not timed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY BRCMDA.
 COPY PROTO.
 01 WS-NAME-START          PIC X(32) VALUE "start".
 01 WS-LIT                 BINARY-LONG.
 01 WS-NAME                PIC X(8).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-TICKS-LONG          BINARY-LONG.
 01 WS-SCALED              BINARY-DOUBLE.
 01 WS-DECIMALS            BINARY-LONG VALUE 2.
 01 WS-SECONDS             PIC X(32).
 01 WS-SECONDS-LENGTH      BINARY-LONG.
 01 WS-RATE                PIC X(32).
 01 WS-RATE-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH.
     IF L-WHICH = 1
         MOVE "debug" TO WS-NAME
         MOVE 5 TO WS-NAME-LENGTH
         MOVE 1 TO WS-BROADCAST
     ELSE
         MOVE "perf" TO WS-NAME
         MOVE 4 TO WS-NAME-LENGTH
         MOVE 0 TO WS-BROADCAST
     END-IF
     CALL "BX-LIT" USING WS-NAME-START WS-LIT
     EVALUATE TRUE
         WHEN WS-LIT > 0 AND BF-START(L-WHICH) > 0
             MOVE SPACES TO WS-KEY
             STRING "commands." WS-NAME(1:WS-NAME-LENGTH) ".alreadyRunning" DELIMITED BY SIZE INTO WS-KEY
             CALL "BA-RAISE-PLAIN" USING WS-KEY
         WHEN WS-LIT > 0
             COMPUTE BF-START(L-WHICH) = CW-TICKS + 1
             MOVE SPACES TO WS-KEY
             STRING "commands." WS-NAME(1:WS-NAME-LENGTH) ".started" DELIMITED BY SIZE INTO WS-KEY
             CALL "BA-SAY" USING WS-KEY WS-BROADCAST
             MOVE 0 TO BR-R-RESULT
         WHEN BF-START(L-WHICH) = 0
             MOVE SPACES TO WS-KEY
             STRING "commands." WS-NAME(1:WS-NAME-LENGTH) ".notRunning" DELIMITED BY SIZE INTO WS-KEY
             CALL "BA-RAISE-PLAIN" USING WS-KEY
         WHEN OTHER
             COMPUTE WS-TICKS = CW-TICKS + 1 - BF-START(L-WHICH)
             MOVE WS-TICKS TO WS-TICKS-LONG
             MOVE 0 TO BF-START(L-WHICH)
             COMPUTE WS-SCALED = WS-TICKS * 5
             CALL "BA-FIXED" USING WS-SCALED WS-DECIMALS WS-SECONDS WS-SECONDS-LENGTH
             MOVE 0 TO WS-SCALED
             IF WS-TICKS > 0
                 MOVE 2000 TO WS-SCALED
             END-IF
             CALL "BA-FIXED" USING WS-SCALED WS-DECIMALS WS-RATE WS-RATE-LENGTH
             MOVE SPACES TO WS-KEY
             STRING "commands." WS-NAME(1:WS-NAME-LENGTH) ".stopped" DELIMITED BY SIZE INTO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SECONDS WS-SECONDS-LENGTH
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TICKS-LONG
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-RATE WS-RATE-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 0 TO BR-R-RESULT
             IF L-WHICH = 1
                 COMPUTE BR-R-RESULT = WS-SCALED / 100
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BA-PROFILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEBUG.
*> debug start | stop (16 §11.19, level 3): the tick profiler run (BA-PROFILE 1). BLOCKED docs: `debug function <name>` needs the function engine.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHICH               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BA-PROFILE" USING WS-WHICH
     GOBACK.
 END PROGRAM CX-DEBUG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-PERF.
*> perf start | stop (16 §11.17, level 4): the performance profiler run (BA-PROFILE 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHICH               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "BA-PROFILE" USING WS-WHICH
     GOBACK.
 END PROGRAM CX-PERF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEBUG.
*> The forms of debug (16 §11.19).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEBUG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "debug start" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "debug stop" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DEBUG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-PERF.
*> The forms of perf (16 §11.17).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-COMMAND             BINARY-LONG VALUE BC-PERF.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "perf start" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "perf stop" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-PERF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEV.
*> The dev and debug commands of 16 §2, §12 in registration order, each only when its condition holds (BRCMDA.cpy): chase with BA-CHASE-COMMAND; raid,
*> debugpath, debugmobspawning, warden_spawn_tracker, spawn_armor_trims and serverpack with BA-DEV-COMMANDS; debugconfig with BA-DEV-COMMANDS and a
*> dedicated host (CS-HOST-KIND 0). jfr (BA-PROFILER) is BLOCKED docs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMDA.
 01 WS-KIND                BINARY-LONG.
 PROCEDURE DIVISION.
     IF BA-CHASE-COMMAND = 1
         CALL "CMDS-REG-CHASE"
     END-IF
     IF BA-DEV-COMMANDS = 1
         CALL "CMDS-REG-RAID"
         CALL "CMDS-REG-DEBUGPATH"
         CALL "CMDS-REG-DEBUGMOBSPAWNING"
         CALL "CMDS-REG-WARDEN-SPAWN-TRACKER"
         CALL "CMDS-REG-SPAWN-ARMOR-TRIMS"
         CALL "CMDS-REG-SERVERPACK"
         CALL "BA-HOST-KIND" USING WS-KIND
         IF WS-KIND = 0
             CALL "CMDS-REG-DEBUGCONFIG"
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CMDS-REG-DEV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-LAN.
*> publish and unpublish (16 §2): registered when the world is hosted (CS-HOST-KIND not 0: a single-player world or one opened to others).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BA-HOST-KIND" USING WS-KIND
     IF WS-KIND NOT = 0
         CALL "CMDS-REG-PUBLISH"
         CALL "CMDS-REG-UNPUBLISH"
     END-IF
     GOBACK.
 END PROGRAM CMDS-REG-LAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DISPATCH-A.
*> The commands of the lane cmds-a that BR-CMD-CALL does not name: any other command id is help (a command of the lane cmds-items/entities/... is
*> added to BR-CMD-CALL itself).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 COPY BRRUN.
 PROCEDURE DIVISION.
     EVALUATE BR-R-COMMAND
         WHEN BC-CHASE
             CALL "CX-CHASE"
         WHEN BC-DEBUG
             CALL "CX-DEBUG"
         WHEN BC-DEBUGCONFIG
             CALL "CX-DEBUGCONFIG"
         WHEN BC-DEBUGMOBSPAWNING
             CALL "CX-DEBUGMOBSPAWNING"
         WHEN BC-DEBUGPATH
             CALL "CX-DEBUGPATH"
         WHEN BC-FETCHPROFILE
             CALL "CX-FETCHPROFILE"
         WHEN BC-PERF
             CALL "CX-PERF"
         WHEN BC-PUBLISH
             CALL "CX-PUBLISH"
         WHEN BC-UNPUBLISH
             CALL "CX-UNPUBLISH"
         WHEN BC-RAID
             CALL "CX-RAID"
         WHEN BC-SERVERPACK
             CALL "CX-SERVERPACK"
         WHEN BC-SPAWN-ARMOR-TRIMS
             CALL "CX-SPAWN-ARMOR-TRIMS"
         WHEN BC-TRANSFER
             CALL "CX-TRANSFER"
         WHEN BC-TICK
             CALL "CX-TICK"
         WHEN BC-WORLDBORDER
             CALL "CX-WORLDBORDER"
         WHEN BC-WARDEN-SPAWN-TRACKER
             CALL "CX-WARDEN-SPAWN-TRACKER"
         WHEN OTHER
             CALL "CX-HELP"
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-DISPATCH-A.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BA-ENSURE.
*> No arguments: the state of BRCMDA.cpy gets its defaults the first time (the tick rate 20.0, 16 §4.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMDA.
 PROCEDURE DIVISION.
     IF BA-INIT = 0
         MOVE 1 TO BA-INIT
         MOVE 20 TO BT-RATE
     END-IF
     GOBACK.
 END PROGRAM BA-ENSURE.
