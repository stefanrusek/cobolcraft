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
*> commands.banlist.entry [name, banned by, reason] per ban ("Banned by an operator." when it has no reason), not broadcast; `ips`
*> lists no bans (BLOCKED with ban-ip: no IP list); the result is the number of bans listed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-IPS            PIC X(32) VALUE "ips".
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-DEFAULT             PIC X(24) VALUE "Banned by an operator.".
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BX-LIT" USING WS-NAME-IPS WS-INDEX
     MOVE AC-COUNT(2) TO WS-COUNT
     IF WS-INDEX > 0
         MOVE 0 TO WS-COUNT
     END-IF
     IF WS-COUNT = 0
         MOVE "commands.banlist.none" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     ELSE
         MOVE "commands.banlist.list" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE "commands.banlist.entry" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT AC-NAME(2, WS-I) AC-NAME-LENGTH(2, WS-I)
             CALL "CMD-TEXT-ARG" USING PB-TEXT AC-SOURCE(2, WS-I) AC-SOURCE-LENGTH(2, WS-I)
             IF AC-REASON-LENGTH(2, WS-I) > 0
                 CALL "CMD-TEXT-ARG" USING PB-TEXT AC-REASON(2, WS-I) AC-REASON-LENGTH(2, WS-I)
             ELSE
                 MOVE 22 TO WS-INDEX
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DEFAULT WS-INDEX
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
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
