*> The scoreboard group (docs/protocol/16-commands-catalog.md §9): scoreboard, team and trigger, and the state they own (core/copy/SBSTATE.cpy,
*> in memory only: it is not saved with the world, and the packets that follow score changes (Set Objective 0x6C, Set Score 0x70, Reset Score 0x50,
*> Set Display Objective 0x64: the catalog does not give the link from command to packet) are not sent). A CX- program reads its parsed context
*> through the BX- helpers (core/src/cmd-args.cob), tells through BR-FEEDBACK, sets BR-R-RESULT and, to fail, raises an exception (SBX-RAISE, which
*> keeps keys longer than the 48 bytes of the older raisers) and sets BR-R-FAILED; a CMDS-REG- program registers the forms. CX-DISPATCH-D runs the
*> commands of this file and of core/src/cmds-data.cob and ends the chain of dispatchers in help.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-RAISE.
*> USING key (PIC X(72)), argument count, argument 1 (PIC X(64)), its length, argument 2, its length: the command fails with that exception (any key
*> of up to 72 bytes; BR-R-FAILED 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRRUN.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-N-ARGS               BINARY-LONG.
 01 L-A1                   PIC X(64).
 01 L-L1                   BINARY-LONG.
 01 L-A2                   PIC X(64).
 01 L-L2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-N-ARGS L-A1 L-L1 L-A2 L-L2.
     MOVE L-KEY TO BR-E-KEY
     MOVE L-N-ARGS TO BR-E-ARG-COUNT
     MOVE L-L1 TO BR-E-ARG-LENGTH(1)
     MOVE L-A1 TO BR-E-ARG(1)
     MOVE L-L2 TO BR-E-ARG-LENGTH(2)
     MOVE L-A2 TO BR-E-ARG(2)
     MOVE -1 TO BR-E-CURSOR
     MOVE 1 TO BR-R-FAILED
     GOBACK.
 END PROGRAM SBX-RAISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-RAISE-PLAIN.
*> USING key (PIC X(72)): SBX-RAISE with no arguments.
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
     CALL "SBX-RAISE" USING L-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
     GOBACK.
 END PROGRAM SBX-RAISE-PLAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-ARG-TEXT.
*> USING argument index, text out (PIC X(64)), length out, quotes (BINARY-LONG, 1 strips one pair of double quotes around the text): the
*> text of an argument as typed (at most 64 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-QUOTES               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TEXT L-LENGTH L-QUOTES.
     MOVE SPACES TO L-TEXT
     MOVE BA-START(L-INDEX) TO WS-START
     COMPUTE WS-LENGTH = BA-END(L-INDEX) - WS-START
     IF L-QUOTES = 1 AND WS-LENGTH >= 2 AND BR-R-LINE(WS-START + 1:1) = '"' AND BR-R-LINE(WS-START + WS-LENGTH:1) = '"'
         ADD 1 TO WS-START
         SUBTRACT 2 FROM WS-LENGTH
     END-IF
     COMPUTE L-LENGTH = FUNCTION MIN(WS-LENGTH, 64)
     MOVE BR-R-LINE(WS-START + 1:L-LENGTH) TO L-TEXT(1:L-LENGTH)
     GOBACK.
 END PROGRAM SBX-ARG-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-WRAP.
*> USING value (BINARY-DOUBLE): the value wrapped to the range of a signed 32-bit integer (Java int arithmetic).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-VALUE.
     COMPUTE L-VALUE = FUNCTION MOD(L-VALUE + 2147483648, 4294967296) - 2147483648
     GOBACK.
 END PROGRAM SBX-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-OBJECTIVE.
*> USING argument index, objective row out: the objective the argument names; an unknown one raises arguments.objective.notFound [name] and sets
*> BR-R-FAILED (row 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-NAME                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "arguments.objective.notFound".
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROW.
     CALL "SBX-ARG-TEXT" USING L-INDEX WS-NAME WS-LENGTH WS-QUOTES
     CALL "SBX-OBJECTIVE-BY-NAME" USING WS-NAME WS-LENGTH L-ROW
     IF L-ROW = 0
         MOVE SPACES TO WS-A2
         CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-NAME WS-LENGTH WS-A2 WS-L2
     END-IF
     GOBACK.
 END PROGRAM SBX-OBJECTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-OBJECTIVE-BY-NAME.
*> USING name (PIC X(64)), length, row out (0 when there is no such objective).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-OBJECTIVES OR L-ROW > 0
         IF SB-O-USED(WS-I) = 1 AND SB-O-NAME-LENGTH(WS-I) = L-LENGTH AND SB-O-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SBX-OBJECTIVE-BY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-TEAM.
*> USING argument index, team row out: the team the argument names; an unknown one raises team.notFound [name] and sets BR-R-FAILED (row 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-NAME                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72) VALUE "team.notFound".
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROW.
     CALL "SBX-ARG-TEXT" USING L-INDEX WS-NAME WS-LENGTH WS-QUOTES
     CALL "SBX-TEAM-BY-NAME" USING WS-NAME WS-LENGTH L-ROW
     IF L-ROW = 0
         MOVE SPACES TO WS-A2
         CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-NAME WS-LENGTH WS-A2 WS-L2
     END-IF
     GOBACK.
 END PROGRAM SBX-TEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-TEAM-BY-NAME.
*> USING name (PIC X(64)), length, row out (0 when there is no such team).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-TEAMS OR L-ROW > 0
         IF SB-T-USED(WS-I) = 1 AND SB-T-NAME-LENGTH(WS-I) = L-LENGTH AND SB-T-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SBX-TEAM-BY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-MEMBER-OF.
*> USING holder name (PIC X(64)), length, member row out (0: on no team): the entry of SB-MEMBER of the holder.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-MEMBERS OR L-ROW > 0
         IF SB-M-USED(WS-I) = 1 AND SB-M-NAME-LENGTH(WS-I) = L-LENGTH AND SB-M-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SBX-MEMBER-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-SCORE-FIND.
*> USING objective row, holder (PIC X(64)), length, create (BINARY-LONG, 1 adds a score of 0 when there is none), score row out (0: none, or the
*> table is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-OBJECTIVE            BINARY-LONG.
 01 L-HOLDER               PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OBJECTIVE L-HOLDER L-LENGTH L-CREATE L-ROW.
     MOVE 0 TO L-ROW WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES OR L-ROW > 0
         IF SB-S-USED(WS-I) = 1
             IF SB-S-OBJECTIVE(WS-I) = L-OBJECTIVE AND SB-S-HOLDER-LENGTH(WS-I) = L-LENGTH AND SB-S-HOLDER(WS-I) = L-HOLDER
                 MOVE WS-I TO L-ROW
             END-IF
         ELSE
             IF WS-FREE = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         END-IF
     END-PERFORM
     IF L-ROW = 0 AND L-CREATE = 1 AND WS-FREE > 0
         MOVE WS-FREE TO L-ROW
         INITIALIZE SB-SCORE(L-ROW)
         MOVE 1 TO SB-S-USED(L-ROW)
         MOVE L-OBJECTIVE TO SB-S-OBJECTIVE(L-ROW)
         MOVE L-HOLDER TO SB-S-HOLDER(L-ROW)
         MOVE L-LENGTH TO SB-S-HOLDER-LENGTH(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM SBX-SCORE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-HOLDERS.
*> USING argument index, holders out (SBHOLD.cpy): the score holders a holder argument names: a selector's players by name and other entities by
*> UUID text (BX-RESOLVE), * every holder with a score (none: argument.scoreHolder.empty), anything else the typed text as a name. A failure
*> sets BR-R-FAILED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY SBSTATE.
 COPY BRRUN.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-KEY                 PIC X(72) VALUE "argument.scoreHolder.empty".
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 COPY SBHOLD.
 PROCEDURE DIVISION USING L-INDEX SBH-TABLE.
     MOVE 0 TO SBH-COUNT
     CALL "SBX-ARG-TEXT" USING L-INDEX WS-TEXT WS-LENGTH WS-QUOTES
     EVALUATE TRUE
         WHEN WS-TEXT(1:1) = "@"
             CALL "BX-RESOLVE" USING L-INDEX WS-ROWS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT OR BR-R-FAILED = 1
                 ADD 1 TO SBH-COUNT
                 MOVE SPACES TO SBH-NAME(SBH-COUNT)
                 IF BX-ROW(WS-I) > 0
                     MOVE PL-NAME(BX-ROW(WS-I)) TO SBH-NAME(SBH-COUNT)
                     MOVE PL-NAME-LENGTH(BX-ROW(WS-I)) TO SBH-LENGTH(SBH-COUNT)
                 ELSE
                     COMPUTE WS-ENTITY = 0 - BX-ROW(WS-I)
                     CALL "PERSIST-UUID-TEXT" USING EN-UUID(WS-ENTITY) WS-UUID-TEXT
                     MOVE WS-UUID-TEXT TO SBH-NAME(SBH-COUNT)
                     MOVE 36 TO SBH-LENGTH(SBH-COUNT)
                 END-IF
             END-PERFORM
         WHEN WS-TEXT(1:1) = "*" AND WS-LENGTH = 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES
                 IF SB-S-USED(WS-I) = 1
                     MOVE 0 TO WS-SEEN
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SBH-COUNT
                         IF SBH-LENGTH(WS-J) = SB-S-HOLDER-LENGTH(WS-I) AND SBH-NAME(WS-J) = SB-S-HOLDER(WS-I)
                             MOVE 1 TO WS-SEEN
                         END-IF
                     END-PERFORM
                     IF WS-SEEN = 0 AND SBH-COUNT < 64
                         ADD 1 TO SBH-COUNT
                         MOVE SB-S-HOLDER(WS-I) TO SBH-NAME(SBH-COUNT)
                         MOVE SB-S-HOLDER-LENGTH(WS-I) TO SBH-LENGTH(SBH-COUNT)
                     END-IF
                 END-IF
             END-PERFORM
             IF SBH-COUNT = 0
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY
             END-IF
         WHEN OTHER
             MOVE 1 TO SBH-COUNT
             MOVE WS-TEXT TO SBH-NAME(1)
             MOVE WS-LENGTH TO SBH-LENGTH(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM SBX-HOLDERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-TRACKED.
*> USING holders out (SBHOLD.cpy): every holder with a score, in the order its first score was made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 COPY SBHOLD.
 PROCEDURE DIVISION USING SBH-TABLE.
     MOVE 0 TO SBH-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES
         IF SB-S-USED(WS-I) = 1
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SBH-COUNT
                 IF SBH-LENGTH(WS-J) = SB-S-HOLDER-LENGTH(WS-I) AND SBH-NAME(WS-J) = SB-S-HOLDER(WS-I)
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0 AND SBH-COUNT < 64
                 ADD 1 TO SBH-COUNT
                 MOVE SB-S-HOLDER(WS-I) TO SBH-NAME(SBH-COUNT)
                 MOVE SB-S-HOLDER-LENGTH(WS-I) TO SBH-LENGTH(SBH-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SBX-TRACKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-JOIN.
*> USING kind (2 objectives, else teams), text out (PIC X(1024)), length out, count out: the names of every objective or team joined by ", ".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TEXT L-LENGTH L-COUNT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POINTER
     MOVE 0 TO L-COUNT
     IF L-KIND = 2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-OBJECTIVES
             IF SB-O-USED(WS-I) = 1
                 IF L-COUNT > 0
                     STRING ", " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
                 END-IF
                 STRING SB-O-NAME(WS-I)(1:SB-O-NAME-LENGTH(WS-I)) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
                 ADD 1 TO L-COUNT
             END-IF
         END-PERFORM
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-TEAMS
             IF SB-T-USED(WS-I) = 1
                 IF L-COUNT > 0
                     STRING ", " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
                 END-IF
                 STRING SB-T-NAME(WS-I)(1:SB-T-NAME-LENGTH(WS-I)) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
                 ADD 1 TO L-COUNT
             END-IF
         END-PERFORM
     END-IF
     COMPUTE L-LENGTH = WS-POINTER - 1
     GOBACK.
 END PROGRAM SBX-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-JOIN-HOLDERS.
*> USING holders (SBHOLD.cpy), text out (PIC X(1024)), length out: the holder names joined by ", ".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 LINKAGE SECTION.
 COPY SBHOLD.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING SBH-TABLE L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
         IF WS-I > 1
             STRING ", " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
         END-IF
         STRING SBH-NAME(WS-I)(1:SBH-LENGTH(WS-I)) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
     END-PERFORM
     COMPUTE L-LENGTH = WS-POINTER - 1
     GOBACK.
 END PROGRAM SBX-JOIN-HOLDERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXS-OBJECTIVES.
*> scoreboard objectives list|add|remove|setdisplay|modify (16 §9.1, level 2): list tells commands.scoreboard.objectives.list.empty or .success [count,
*> names] (not broadcast; the result is the count). add <name> <criteria> [<displayName>] makes the objective (a duplicate, or a full table, is
*> .add.duplicate) with .add.success [name]; remove drops it with its scores and display slots (.remove.success [name]); both return the number of
*> objectives afterwards. setdisplay <slot> [<objective>] shows or clears a slot (.display.set [slot, objective], .display.cleared [slot]; the slot already
*> showing it is .display.alreadySet, an empty one .display.alreadyEmpty); modify changes the display name, the render type, the auto-update flag
*> or the number format with the .modify.* messages; setdisplay and modify return 0. An unknown objective is arguments.objective.notFound [name].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-LIST              PIC X(32) VALUE "list".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-N-REMOVE            PIC X(32) VALUE "remove".
 01 WS-N-SETDISPLAY        PIC X(32) VALUE "setdisplay".
 01 WS-N-DISPLAYNAME       PIC X(32) VALUE "displayname".
 01 WS-N-RENDERTYPE        PIC X(32) VALUE "rendertype".
 01 WS-N-HEARTS            PIC X(32) VALUE "hearts".
 01 WS-N-AUTOUPDATE        PIC X(32) VALUE "displayautoupdate".
 01 WS-N-NUMBERFORMAT      PIC X(32) VALUE "numberformat".
 01 WS-N-BLANK             PIC X(32) VALUE "blank".
 01 WS-N-FIXED             PIC X(32) VALUE "fixed".
 01 WS-N-STYLED            PIC X(32) VALUE "styled".
 01 WS-N-OBJECTIVE         PIC X(32) VALUE "objective".
 01 WS-N-CRITERIA          PIC X(32) VALUE "criteria".
 01 WS-N-DISPLAY           PIC X(32) VALUE "displayName".
 01 WS-N-SLOT              PIC X(32) VALUE "slot".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-LIST                BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-SETDISPLAY          BINARY-LONG.
 01 WS-DISPLAYNAME         BINARY-LONG.
 01 WS-RENDERTYPE          BINARY-LONG.
 01 WS-HEARTS              BINARY-LONG.
 01 WS-AUTOUPDATE          BINARY-LONG.
 01 WS-BLANK               BINARY-LONG.
 01 WS-FIXED               BINARY-LONG.
 01 WS-STYLED              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-2             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT-NO             BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAMES               PIC X(1024).
 01 WS-NAMES-LENGTH        BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CRITERIA            PIC X(64).
 01 WS-CRITERIA-LENGTH     BINARY-LONG.
 01 WS-SLOT-TEXT           PIC X(64).
 01 WS-SLOT-LENGTH         BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 1.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The count of objectives into BR-R-RESULT.
 COUNT-RESULT.
     CALL "SBX-JOIN" USING WS-KIND WS-NAMES WS-NAMES-LENGTH WS-COUNT
     MOVE WS-COUNT TO BR-R-RESULT.

*> The message WS-KEY with the objective name as its only argument, broadcast.
 TELL-NAME.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 DO-LIST.
     CALL "SBX-JOIN" USING WS-KIND WS-NAMES WS-NAMES-LENGTH WS-COUNT
     IF WS-COUNT = 0
         MOVE "commands.scoreboard.objectives.list.empty" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
     ELSE
         MOVE "commands.scoreboard.objectives.list.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-NAMES-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE WS-COUNT TO BR-R-RESULT.

 DO-ADD.
     CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-NAME WS-NAME-LENGTH WS-NO-QUOTES
     CALL "BX-FIND" USING WS-N-CRITERIA WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-CRITERIA WS-CRITERIA-LENGTH WS-NO-QUOTES
     CALL "SBX-OBJECTIVE-BY-NAME" USING WS-NAME WS-NAME-LENGTH WS-ROW
     MOVE 0 TO WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-OBJECTIVES OR WS-FREE > 0
         IF SB-O-USED(WS-I) = 0
             MOVE WS-I TO WS-FREE
         END-IF
     END-PERFORM
     IF WS-ROW > 0 OR WS-FREE = 0
         MOVE "commands.scoreboard.objectives.add.duplicate" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         INITIALIZE SB-OBJECTIVE(WS-FREE)
         MOVE 1 TO SB-O-USED(WS-FREE)
         MOVE WS-NAME TO SB-O-NAME(WS-FREE)
         MOVE WS-NAME-LENGTH TO SB-O-NAME-LENGTH(WS-FREE)
         MOVE WS-CRITERIA TO SB-O-CRITERIA(WS-FREE)
         MOVE WS-CRITERIA-LENGTH TO SB-O-CRIT-LENGTH(WS-FREE)
         MOVE WS-NAME TO SB-O-DISPLAY(WS-FREE)
         MOVE WS-NAME-LENGTH TO SB-O-DISPLAY-LENGTH(WS-FREE)
         CALL "BX-FIND" USING WS-N-DISPLAY WS-INDEX
         IF WS-INDEX > 0
             CALL "SBX-ARG-TEXT" USING WS-INDEX SB-O-DISPLAY(WS-FREE) SB-O-DISPLAY-LENGTH(WS-FREE) WS-QUOTES
         END-IF
         MOVE "commands.scoreboard.objectives.add.success" TO WS-KEY
         PERFORM TELL-NAME
         PERFORM COUNT-RESULT
     END-IF.

 DO-REMOVE.
     CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
     CALL "SBX-OBJECTIVE" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         MOVE SB-O-NAME(WS-ROW) TO WS-NAME
         MOVE SB-O-NAME-LENGTH(WS-ROW) TO WS-NAME-LENGTH
         MOVE 0 TO SB-O-USED(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES
             IF SB-S-USED(WS-I) = 1 AND SB-S-OBJECTIVE(WS-I) = WS-ROW
                 MOVE 0 TO SB-S-USED(WS-I)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
             IF SB-SLOT(WS-I) = WS-ROW
                 MOVE 0 TO SB-SLOT(WS-I)
             END-IF
         END-PERFORM
         MOVE "commands.scoreboard.objectives.remove.success" TO WS-KEY
         PERFORM TELL-NAME
         PERFORM COUNT-RESULT
     END-IF.

 DO-SETDISPLAY.
     CALL "BX-FIND" USING WS-N-SLOT WS-INDEX
     COMPUTE WS-SLOT-NO = BA-IVAL(WS-INDEX) + 1
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-SLOT-TEXT WS-SLOT-LENGTH WS-NO-QUOTES
     CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX-2
     MOVE 0 TO WS-ROW
     IF WS-INDEX-2 > 0
         CALL "SBX-OBJECTIVE" USING WS-INDEX-2 WS-ROW
     END-IF
     EVALUATE TRUE
         WHEN BR-R-FAILED = 1
             MOVE 0 TO BR-R-RESULT
         WHEN WS-ROW > 0 AND SB-SLOT(WS-SLOT-NO) = WS-ROW
             MOVE "commands.scoreboard.objectives.display.alreadySet" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         WHEN WS-ROW > 0
             MOVE WS-ROW TO SB-SLOT(WS-SLOT-NO)
             MOVE "commands.scoreboard.objectives.display.set" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SLOT-TEXT WS-SLOT-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-ROW) SB-O-NAME-LENGTH(WS-ROW)
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         WHEN SB-SLOT(WS-SLOT-NO) = 0
             MOVE "commands.scoreboard.objectives.display.alreadyEmpty" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         WHEN OTHER
             MOVE 0 TO SB-SLOT(WS-SLOT-NO)
             MOVE "commands.scoreboard.objectives.display.cleared" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SLOT-TEXT WS-SLOT-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     END-EVALUATE.

 DO-MODIFY.
     CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
     CALL "SBX-OBJECTIVE" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         MOVE SB-O-NAME(WS-ROW) TO WS-NAME
         MOVE SB-O-NAME-LENGTH(WS-ROW) TO WS-NAME-LENGTH
         EVALUATE TRUE
             WHEN WS-DISPLAYNAME > 0
                 CALL "BX-FIND" USING WS-N-DISPLAY WS-INDEX
                 CALL "SBX-ARG-TEXT" USING WS-INDEX SB-O-DISPLAY(WS-ROW) SB-O-DISPLAY-LENGTH(WS-ROW) WS-QUOTES
                 MOVE "commands.scoreboard.objectives.modify.displayname" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-DISPLAY(WS-ROW) SB-O-DISPLAY-LENGTH(WS-ROW)
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             WHEN WS-RENDERTYPE > 0
                 MOVE 0 TO SB-O-RENDER(WS-ROW)
                 IF WS-HEARTS > 0
                     MOVE 1 TO SB-O-RENDER(WS-ROW)
                 END-IF
                 MOVE "commands.scoreboard.objectives.modify.rendertype" TO WS-KEY
                 PERFORM TELL-NAME
             WHEN WS-AUTOUPDATE > 0
                 CALL "BX-FIND" USING WS-N-VALUE WS-INDEX
                 MOVE BA-IVAL(WS-INDEX) TO SB-O-AUTO(WS-ROW)
                 MOVE "commands.scoreboard.objectives.modify.displayAutoUpdate.disable" TO WS-KEY
                 IF SB-O-AUTO(WS-ROW) = 1
                     MOVE "commands.scoreboard.objectives.modify.displayAutoUpdate.enable" TO WS-KEY
                 END-IF
                 PERFORM TELL-NAME
             WHEN OTHER
                 MOVE 0 TO SB-O-FORMAT(WS-ROW)
                 MOVE "commands.scoreboard.objectives.modify.objectiveFormat.clear" TO WS-KEY
                 EVALUATE TRUE
                     WHEN WS-BLANK > 0
                         MOVE 1 TO SB-O-FORMAT(WS-ROW)
                     WHEN WS-FIXED > 0
                         MOVE 2 TO SB-O-FORMAT(WS-ROW)
                     WHEN WS-STYLED > 0
                         MOVE 3 TO SB-O-FORMAT(WS-ROW)
                 END-EVALUATE
                 IF SB-O-FORMAT(WS-ROW) > 0
                     MOVE "commands.scoreboard.objectives.modify.objectiveFormat.set" TO WS-KEY
                 END-IF
                 PERFORM TELL-NAME
         END-EVALUATE
         MOVE 0 TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-LIST WS-LIST
     CALL "BX-LIT" USING WS-N-ADD WS-ADD
     CALL "BX-LIT" USING WS-N-REMOVE WS-REMOVE
     CALL "BX-LIT" USING WS-N-SETDISPLAY WS-SETDISPLAY
     CALL "BX-LIT" USING WS-N-DISPLAYNAME WS-DISPLAYNAME
     CALL "BX-LIT" USING WS-N-RENDERTYPE WS-RENDERTYPE
     CALL "BX-LIT" USING WS-N-HEARTS WS-HEARTS
     CALL "BX-LIT" USING WS-N-AUTOUPDATE WS-AUTOUPDATE
     CALL "BX-LIT" USING WS-N-BLANK WS-BLANK
     CALL "BX-LIT" USING WS-N-FIXED WS-FIXED
     CALL "BX-LIT" USING WS-N-STYLED WS-STYLED
     EVALUATE TRUE
         WHEN WS-LIST > 0
             PERFORM DO-LIST
         WHEN WS-ADD > 0
             PERFORM DO-ADD
         WHEN WS-REMOVE > 0
             PERFORM DO-REMOVE
         WHEN WS-SETDISPLAY > 0
             PERFORM DO-SETDISPLAY
         WHEN OTHER
             PERFORM DO-MODIFY
     END-EVALUATE
     GOBACK.
 END PROGRAM CXS-OBJECTIVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXS-PLAYERS.
*> scoreboard players list|get|set|add|remove|reset|enable|operation|display (16 §9.1, level 2) over the holders of a score_holder argument (SBX-HOLDERS).
*> list tells the tracked holders (.list.empty or .list.success [count, names]; the result is the count) or the scores of one holder (.list.entity.empty
*> [holder], else .list.entity.success [holder, count] and one .list.entity.entry [objective, score] each; the result is the count); get tells
*> .get.success [holder, score, objective] or fails .get.null [objective, holder]; the result is the score. set, add and remove change the scores (a
*> missing score is 0; add and remove wrap like a Java int) with the .single or .multiple messages, broadcast; the result is the sum of the new scores. reset
*> drops the scores (.reset.all.* or .reset.specific.*; the result is the number of holders). enable makes a trigger score 0 or unlocks it (.enable.invalid
*> for another criterion, .enable.failed when nothing changed; the result is the number changed). operation applies = += -= *= /= %= < > >< of the source
*> scores to the target scores (/= and %= by zero fail arguments.operation.div0; /= floors, %= has the sign of the divisor), .operation.success.single or
*> .multiple; the result is the sum of the new target scores. display name and display numberformat store the text or format of a score
*> (.display.name.* and .display.numberFormat.* messages; the result is the number of holders).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 COPY BRRUN.
 COPY PROTO.
 COPY SBHOLD.
 COPY SBHOLD REPLACING LEADING ==SBH-== BY ==SBS-==.
 01 WS-N-LIST              PIC X(32) VALUE "list".
 01 WS-N-GET               PIC X(32) VALUE "get".
 01 WS-N-SET               PIC X(32) VALUE "set".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-N-REMOVE            PIC X(32) VALUE "remove".
 01 WS-N-RESET             PIC X(32) VALUE "reset".
 01 WS-N-ENABLE            PIC X(32) VALUE "enable".
 01 WS-N-OPERATION         PIC X(32) VALUE "operation".
 01 WS-N-DISPLAY           PIC X(32) VALUE "display".
 01 WS-N-NAME              PIC X(32) VALUE "name".
 01 WS-N-BLANK             PIC X(32) VALUE "blank".
 01 WS-N-FIXED             PIC X(32) VALUE "fixed".
 01 WS-N-STYLED            PIC X(32) VALUE "styled".
 01 WS-N-TARGETS           PIC X(32) VALUE "targets".
 01 WS-N-TARGET            PIC X(32) VALUE "target".
 01 WS-N-OBJECTIVE         PIC X(32) VALUE "objective".
 01 WS-N-SCORE             PIC X(32) VALUE "score".
 01 WS-N-TARGET-OBJ        PIC X(32) VALUE "targetObjective".
 01 WS-N-SOURCE            PIC X(32) VALUE "source".
 01 WS-N-SOURCE-OBJ        PIC X(32) VALUE "sourceObjective".
 01 WS-N-OPERATION-ARG     PIC X(32) VALUE "operation".
 01 WS-N-NAME-ARG          PIC X(32) VALUE "name".
 01 WS-LIST                BINARY-LONG.
 01 WS-GET                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 01 WS-ENABLE              BINARY-LONG.
 01 WS-OPERATION           BINARY-LONG.
 01 WS-DISPLAY             BINARY-LONG.
 01 WS-NAME-LIT            BINARY-LONG.
 01 WS-BLANK               BINARY-LONG.
 01 WS-FIXED               BINARY-LONG.
 01 WS-STYLED              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-2             BINARY-LONG.
 01 WS-OBJ                 BINARY-LONG.
 01 WS-OBJ-2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW-2               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-QUOTES              BINARY-LONG VALUE 1.
 01 WS-AMOUNT              BINARY-DOUBLE.
 01 WS-NEW                 BINARY-DOUBLE.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-OP                  BINARY-LONG.
 01 WS-VERB                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT-2               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAMES               PIC X(1024).
 01 WS-NAMES-LENGTH        BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-FORMAT              BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The holders of the argument named WS-N-TARGETS or WS-N-TARGET (WS-INDEX-2 > 0 for the singular).
 GET-HOLDERS.
     CALL "BX-FIND" USING WS-N-TARGETS WS-INDEX
     IF WS-INDEX = 0
         CALL "BX-FIND" USING WS-N-TARGET WS-INDEX
     END-IF
     CALL "SBX-HOLDERS" USING WS-INDEX SBH-TABLE.

*> The objective of the argument named "objective".
 GET-OBJECTIVE.
     CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
     CALL "SBX-OBJECTIVE" USING WS-INDEX WS-OBJ.

 DO-LIST.
     CALL "BX-FIND" USING WS-N-TARGET WS-INDEX
     IF WS-INDEX = 0
         CALL "SBX-TRACKED" USING SBH-TABLE
         CALL "SBX-JOIN-HOLDERS" USING SBH-TABLE WS-NAMES WS-NAMES-LENGTH
         IF SBH-COUNT = 0
             MOVE "commands.scoreboard.players.list.empty" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
         ELSE
             MOVE "commands.scoreboard.players.list.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-NAMES-LENGTH
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE SBH-COUNT TO BR-R-RESULT
     ELSE
         CALL "SBX-HOLDERS" USING WS-INDEX SBH-TABLE
         IF BR-R-FAILED = 0
             MOVE 0 TO WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES
                 IF SB-S-USED(WS-I) = 1 AND SB-S-HOLDER-LENGTH(WS-I) = SBH-LENGTH(1) AND SB-S-HOLDER(WS-I) = SBH-NAME(1)
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
             IF WS-COUNT = 0
                 MOVE "commands.scoreboard.players.list.entity.empty" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             ELSE
                 MOVE "commands.scoreboard.players.list.entity.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-SCORES
                     IF SB-S-USED(WS-I) = 1 AND SB-S-HOLDER-LENGTH(WS-I) = SBH-LENGTH(1) AND SB-S-HOLDER(WS-I) = SBH-NAME(1)
                         MOVE "commands.scoreboard.players.list.entity.entry" TO WS-KEY
                         MOVE SB-S-OBJECTIVE(WS-I) TO WS-OBJ
                         CALL "BX-KEY" USING PB-TEXT WS-KEY
                         CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
                         CALL "CMD-TEXT-INT" USING PB-TEXT SB-S-VALUE(WS-I)
                         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
                     END-IF
                 END-PERFORM
             END-IF
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF.

 DO-GET.
     PERFORM GET-HOLDERS
     IF BR-R-FAILED = 0
         PERFORM GET-OBJECTIVE
     END-IF
     IF BR-R-FAILED = 0
         CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(1) SBH-LENGTH(1) WS-ZERO WS-ROW
         IF WS-ROW = 0
             MOVE "commands.scoreboard.players.get.null" TO WS-KEY
             CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ) SBH-NAME(1) SBH-LENGTH(1)
         ELSE
             MOVE "commands.scoreboard.players.get.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
             CALL "CMD-TEXT-INT" USING PB-TEXT SB-S-VALUE(WS-ROW)
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             MOVE SB-S-VALUE(WS-ROW) TO BR-R-RESULT
         END-IF
     END-IF.

*> set (WS-VERB 1), add (2) and remove (3).
 DO-CHANGE.
     PERFORM GET-HOLDERS
     IF BR-R-FAILED = 0
         PERFORM GET-OBJECTIVE
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-SCORE WS-INDEX
         MOVE BA-IVAL(WS-INDEX) TO WS-AMOUNT
         MOVE 0 TO WS-TOTAL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(WS-I) SBH-LENGTH(WS-I) WS-ONE WS-ROW
             MOVE 0 TO WS-NEW
             IF WS-ROW > 0
                 EVALUATE WS-VERB
                     WHEN 1
                         MOVE WS-AMOUNT TO WS-NEW
                     WHEN 2
                         COMPUTE WS-NEW = SB-S-VALUE(WS-ROW) + WS-AMOUNT
                     WHEN OTHER
                         COMPUTE WS-NEW = SB-S-VALUE(WS-ROW) - WS-AMOUNT
                 END-EVALUATE
                 CALL "SBX-WRAP" USING WS-NEW
                 MOVE WS-NEW TO SB-S-VALUE(WS-ROW)
             END-IF
             ADD WS-NEW TO WS-TOTAL
         END-PERFORM
         MOVE WS-AMOUNT TO WS-INT-2
         MOVE WS-NEW TO WS-INT
         EVALUATE WS-VERB
             WHEN 1
                 IF SBH-COUNT = 1
                     MOVE "commands.scoreboard.players.set.success.single" TO WS-KEY
                 ELSE
                     MOVE "commands.scoreboard.players.set.success.multiple" TO WS-KEY
                 END-IF
             WHEN 2
                 IF SBH-COUNT = 1
                     MOVE "commands.scoreboard.players.add.success.single" TO WS-KEY
                 ELSE
                     MOVE "commands.scoreboard.players.add.success.multiple" TO WS-KEY
                 END-IF
             WHEN OTHER
                 IF SBH-COUNT = 1
                     MOVE "commands.scoreboard.players.remove.success.single" TO WS-KEY
                 ELSE
                     MOVE "commands.scoreboard.players.remove.success.multiple" TO WS-KEY
                 END-IF
         END-EVALUATE
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF WS-VERB > 1
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT-2
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
         IF SBH-COUNT = 1
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
             IF WS-VERB > 1
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
             ELSE
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT-2
             END-IF
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
             IF WS-VERB = 1
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT-2
             END-IF
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         CALL "SBX-WRAP" USING WS-TOTAL
         MOVE WS-TOTAL TO BR-R-RESULT
     END-IF.

 DO-RESET.
     PERFORM GET-HOLDERS
     MOVE 0 TO WS-OBJ
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
         IF WS-INDEX > 0
             CALL "SBX-OBJECTIVE" USING WS-INDEX WS-OBJ
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SB-MAX-SCORES
                 IF SB-S-USED(WS-J) = 1 AND SB-S-HOLDER-LENGTH(WS-J) = SBH-LENGTH(WS-I) AND SB-S-HOLDER(WS-J) = SBH-NAME(WS-I)
                         AND (WS-OBJ = 0 OR SB-S-OBJECTIVE(WS-J) = WS-OBJ)
                     MOVE 0 TO SB-S-USED(WS-J)
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-OBJ = 0 AND SBH-COUNT = 1
             MOVE "commands.scoreboard.players.reset.all.single" TO WS-KEY
         END-IF
         IF WS-OBJ = 0 AND SBH-COUNT > 1
             MOVE "commands.scoreboard.players.reset.all.multiple" TO WS-KEY
         END-IF
         IF WS-OBJ > 0 AND SBH-COUNT = 1
             MOVE "commands.scoreboard.players.reset.specific.single" TO WS-KEY
         END-IF
         IF WS-OBJ > 0 AND SBH-COUNT > 1
             MOVE "commands.scoreboard.players.reset.specific.multiple" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF WS-OBJ > 0
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
         END-IF
         IF SBH-COUNT = 1
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE SBH-COUNT TO BR-R-RESULT
     END-IF.

 DO-ENABLE.
     PERFORM GET-HOLDERS
     IF BR-R-FAILED = 0
         PERFORM GET-OBJECTIVE
     END-IF
     IF BR-R-FAILED = 0 AND (SB-O-CRIT-LENGTH(WS-OBJ) NOT = 7 OR SB-O-CRITERIA(WS-OBJ)(1:7) NOT = "trigger")
         MOVE "commands.scoreboard.players.enable.invalid" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-CHANGED WS-LAST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(WS-I) SBH-LENGTH(WS-I) WS-ZERO WS-ROW
             IF WS-ROW = 0
                 CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(WS-I) SBH-LENGTH(WS-I) WS-ONE WS-ROW
                 IF WS-ROW > 0
                     ADD 1 TO WS-CHANGED
                     MOVE WS-I TO WS-LAST
                 END-IF
             ELSE
                 IF SB-S-LOCKED(WS-ROW) = 1
                     MOVE 0 TO SB-S-LOCKED(WS-ROW)
                     ADD 1 TO WS-CHANGED
                     MOVE WS-I TO WS-LAST
                 END-IF
             END-IF
         END-PERFORM
         IF WS-CHANGED = 0
             MOVE "commands.scoreboard.players.enable.failed" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         ELSE
             IF WS-CHANGED = 1
                 MOVE "commands.scoreboard.players.enable.success.single" TO WS-KEY
             ELSE
                 MOVE "commands.scoreboard.players.enable.success.multiple" TO WS-KEY
             END-IF
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
             IF WS-CHANGED = 1
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(WS-LAST) SBH-LENGTH(WS-LAST)
             ELSE
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-CHANGED
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-CHANGED TO BR-R-RESULT
         END-IF
     END-IF.

 DO-OPERATION.
     CALL "BX-FIND" USING WS-N-TARGETS WS-INDEX
     CALL "SBX-HOLDERS" USING WS-INDEX SBH-TABLE
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-TARGET-OBJ WS-INDEX
         CALL "SBX-OBJECTIVE" USING WS-INDEX WS-OBJ
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-SOURCE WS-INDEX
         CALL "SBX-HOLDERS" USING WS-INDEX SBS-TABLE
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-SOURCE-OBJ WS-INDEX
         CALL "SBX-OBJECTIVE" USING WS-INDEX WS-OBJ-2
     END-IF
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-OPERATION-ARG WS-INDEX
         MOVE BA-IVAL(WS-INDEX) TO WS-OP
         MOVE 0 TO WS-TOTAL WS-NEW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT OR BR-R-FAILED = 1
             CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(WS-I) SBH-LENGTH(WS-I) WS-ONE WS-ROW
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SBS-COUNT OR BR-R-FAILED = 1
                 CALL "SBX-SCORE-FIND" USING WS-OBJ-2 SBS-NAME(WS-J) SBS-LENGTH(WS-J) WS-ONE WS-ROW-2
                 IF WS-ROW > 0 AND WS-ROW-2 > 0
                     MOVE SB-S-VALUE(WS-ROW) TO WS-T
                     MOVE SB-S-VALUE(WS-ROW-2) TO WS-S
                     EVALUATE WS-OP
                         WHEN 0
                             MOVE WS-S TO WS-NEW
                         WHEN 1
                             COMPUTE WS-NEW = WS-T + WS-S
                         WHEN 2
                             COMPUTE WS-NEW = WS-T - WS-S
                         WHEN 3
                             COMPUTE WS-NEW = WS-T * WS-S
                         WHEN 4
                             IF WS-S = 0
                                 MOVE "arguments.operation.div0" TO WS-KEY
                                 CALL "SBX-RAISE-PLAIN" USING WS-KEY
                             ELSE
                                 COMPUTE WS-NEW = FUNCTION INTEGER(WS-T / WS-S)
                             END-IF
                         WHEN 5
                             IF WS-S = 0
                                 MOVE "arguments.operation.div0" TO WS-KEY
                                 CALL "SBX-RAISE-PLAIN" USING WS-KEY
                             ELSE
                                 COMPUTE WS-NEW = FUNCTION MOD(WS-T, WS-S)
                             END-IF
                         WHEN 6
                             MOVE FUNCTION MIN(WS-T, WS-S) TO WS-NEW
                         WHEN 7
                             MOVE FUNCTION MAX(WS-T, WS-S) TO WS-NEW
                         WHEN OTHER
                             MOVE WS-T TO SB-S-VALUE(WS-ROW-2)
                             MOVE WS-S TO WS-NEW
                     END-EVALUATE
                     IF BR-R-FAILED = 0
                         CALL "SBX-WRAP" USING WS-NEW
                         MOVE WS-NEW TO SB-S-VALUE(WS-ROW)
                     END-IF
                 END-IF
             END-PERFORM
             ADD WS-NEW TO WS-TOTAL
         END-PERFORM
         IF BR-R-FAILED = 0
             MOVE WS-NEW TO WS-INT
             IF SBH-COUNT = 1
                 MOVE "commands.scoreboard.players.operation.success.single" TO WS-KEY
             ELSE
                 MOVE "commands.scoreboard.players.operation.success.multiple" TO WS-KEY
             END-IF
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
             IF SBH-COUNT = 1
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
             ELSE
                 CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             CALL "SBX-WRAP" USING WS-TOTAL
             MOVE WS-TOTAL TO BR-R-RESULT
         END-IF
     END-IF.

*> display name (WS-NAME-LIT > 0) and display numberformat.
 DO-DISPLAY.
     PERFORM GET-HOLDERS
     IF BR-R-FAILED = 0
         PERFORM GET-OBJECTIVE
     END-IF
     IF BR-R-FAILED = 0
         MOVE SPACES TO WS-TEXT
         MOVE 0 TO WS-TEXT-LENGTH WS-FORMAT
         IF WS-NAME-LIT > 0
             CALL "BX-FIND" USING WS-N-NAME-ARG WS-INDEX
             IF WS-INDEX > 0
                 CALL "SBX-ARG-TEXT" USING WS-INDEX WS-TEXT WS-TEXT-LENGTH WS-QUOTES
             END-IF
         ELSE
             EVALUATE TRUE
                 WHEN WS-BLANK > 0
                     MOVE 1 TO WS-FORMAT
                 WHEN WS-FIXED > 0
                     MOVE 2 TO WS-FORMAT
                 WHEN WS-STYLED > 0
                     MOVE 3 TO WS-FORMAT
             END-EVALUATE
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             CALL "SBX-SCORE-FIND" USING WS-OBJ SBH-NAME(WS-I) SBH-LENGTH(WS-I) WS-ONE WS-ROW
             IF WS-ROW > 0
                 IF WS-NAME-LIT > 0
                     MOVE WS-TEXT TO SB-S-DISPLAY(WS-ROW)
                     MOVE WS-TEXT-LENGTH TO SB-S-DISPLAY-LENGTH(WS-ROW)
                 ELSE
                     MOVE WS-FORMAT TO SB-S-FORMAT(WS-ROW)
                 END-IF
             END-IF
         END-PERFORM
         EVALUATE TRUE
             WHEN WS-NAME-LIT > 0 AND WS-TEXT-LENGTH > 0 AND SBH-COUNT = 1
                 MOVE "commands.scoreboard.players.display.name.set.success.single" TO WS-KEY
             WHEN WS-NAME-LIT > 0 AND WS-TEXT-LENGTH > 0
                 MOVE "commands.scoreboard.players.display.name.set.success.multiple" TO WS-KEY
             WHEN WS-NAME-LIT > 0 AND SBH-COUNT = 1
                 MOVE "commands.scoreboard.players.display.name.clear.success.single" TO WS-KEY
             WHEN WS-NAME-LIT > 0
                 MOVE "commands.scoreboard.players.display.name.clear.success.multiple" TO WS-KEY
             WHEN WS-FORMAT > 0 AND SBH-COUNT = 1
                 MOVE "commands.scoreboard.players.display.numberFormat.set.success.single" TO WS-KEY
             WHEN WS-FORMAT > 0
                 MOVE "commands.scoreboard.players.display.numberFormat.set.success.multiple" TO WS-KEY
             WHEN SBH-COUNT = 1
                 MOVE "commands.scoreboard.players.display.numberFormat.clear.success.single" TO WS-KEY
             WHEN OTHER
                 MOVE "commands.scoreboard.players.display.numberFormat.clear.success.multiple" TO WS-KEY
         END-EVALUATE
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF WS-TEXT-LENGTH > 0
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
         END-IF
         IF SBH-COUNT = 1
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE SBH-COUNT TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-LIST WS-LIST
     CALL "BX-LIT" USING WS-N-GET WS-GET
     CALL "BX-LIT" USING WS-N-SET WS-SET
     CALL "BX-LIT" USING WS-N-ADD WS-ADD
     CALL "BX-LIT" USING WS-N-REMOVE WS-REMOVE
     CALL "BX-LIT" USING WS-N-RESET WS-RESET
     CALL "BX-LIT" USING WS-N-ENABLE WS-ENABLE
     CALL "BX-LIT" USING WS-N-OPERATION WS-OPERATION
     CALL "BX-LIT" USING WS-N-NAME WS-NAME-LIT
     CALL "BX-LIT" USING WS-N-BLANK WS-BLANK
     CALL "BX-LIT" USING WS-N-FIXED WS-FIXED
     CALL "BX-LIT" USING WS-N-STYLED WS-STYLED
     EVALUATE TRUE
         WHEN WS-LIST > 0
             PERFORM DO-LIST
         WHEN WS-GET > 0
             PERFORM DO-GET
         WHEN WS-SET > 0
             MOVE 1 TO WS-VERB
             PERFORM DO-CHANGE
         WHEN WS-ADD > 0
             MOVE 2 TO WS-VERB
             PERFORM DO-CHANGE
         WHEN WS-REMOVE > 0
             MOVE 3 TO WS-VERB
             PERFORM DO-CHANGE
         WHEN WS-RESET > 0
             PERFORM DO-RESET
         WHEN WS-ENABLE > 0
             PERFORM DO-ENABLE
         WHEN WS-OPERATION > 0
             PERFORM DO-OPERATION
         WHEN OTHER
             PERFORM DO-DISPLAY
     END-EVALUATE
     GOBACK.
 END PROGRAM CXS-PLAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SCOREBOARD.
*> scoreboard (16 §9.1, level 2): objectives ... is CXS-OBJECTIVES, players ... is CXS-PLAYERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N-OBJECTIVES        PIC X(32) VALUE "objectives".
 01 WS-OBJECTIVES          BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BX-LIT" USING WS-N-OBJECTIVES WS-OBJECTIVES
     IF WS-OBJECTIVES > 0
         CALL "CXS-OBJECTIVES"
     ELSE
         CALL "CXS-PLAYERS"
     END-IF
     GOBACK.
 END PROGRAM CX-SCOREBOARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SCOREBOARD.
*> The forms of scoreboard (16 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SCOREBOARD.
 01 WS-PATH                PIC X(256).
 01 WS-HEAD                PIC X(64).
 01 WS-TAIL                PIC X(192).
 01 WS-I                   BINARY-LONG.
 01 WS-FORMS.
    05 FILLER PIC X(140) VALUE "objectives list".
    05 FILLER PIC X(140) VALUE "objectives add <objective:word> <criteria:criteria>".
    05 FILLER PIC X(140) VALUE "objectives add <objective:word> <criteria:criteria> <displayName:component>".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> displayname <displayName:component>".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> rendertype integer".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> rendertype hearts".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> displayautoupdate <value:bool>".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> numberformat".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> numberformat blank".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> numberformat fixed <contents:component>".
    05 FILLER PIC X(140) VALUE "objectives modify <objective:objective> numberformat styled <style:style>".
    05 FILLER PIC X(140) VALUE "objectives remove <objective:objective>".
    05 FILLER PIC X(140) VALUE "objectives setdisplay <slot:dslot>".
    05 FILLER PIC X(140) VALUE "objectives setdisplay <slot:dslot> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players list".
    05 FILLER PIC X(140) VALUE "players list <target:holder>".
    05 FILLER PIC X(140) VALUE "players set <targets:holders> <objective:objective> <score:int>".
    05 FILLER PIC X(140) VALUE "players get <target:holder> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players add <targets:holders> <objective:objective> <score:int:0>".
    05 FILLER PIC X(140) VALUE "players remove <targets:holders> <objective:objective> <score:int:0>".
    05 FILLER PIC X(140) VALUE "players reset <targets:holders>".
    05 FILLER PIC X(140) VALUE "players reset <targets:holders> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players enable <targets:holders> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players display name <targets:holders> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players display name <targets:holders> <objective:objective> <name:component>".
    05 FILLER PIC X(140) VALUE "players display numberformat <targets:holders> <objective:objective>".
    05 FILLER PIC X(140) VALUE "players display numberformat <targets:holders> <objective:objective> blank".
    05 FILLER PIC X(140) VALUE "players display numberformat <targets:holders> <objective:objective> fixed <contents:component>".
    05 FILLER PIC X(140) VALUE "players display numberformat <targets:holders> <objective:objective> styled <style:style>".
    05 FILLER PIC X(140) VALUE "players operation <targets:holders> <targetObjective:objective> <operation:operation> <source:holders> <sourceObjective:objective>".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM              PIC X(140) OCCURS 30 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE SPACES TO WS-PATH
         STRING "scoreboard " DELIMITED BY SIZE WS-FORM(WS-I) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-SCOREBOARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-TEAM-LEAVE.
*> USING holder name (PIC X(64)), length: the holder is on no team afterwards.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH.
     CALL "SBX-MEMBER-OF" USING L-NAME L-LENGTH WS-ROW
     IF WS-ROW > 0
         MOVE 0 TO SB-M-USED(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM SBX-TEAM-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SBX-TEAM-JOIN.
*> USING team row, holder name (PIC X(64)), length: the holder is on that team (and off any other); a holder already on it stays where it is, and a full
*> member table drops the join.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEAM                 BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEAM L-NAME L-LENGTH.
     CALL "SBX-MEMBER-OF" USING L-NAME L-LENGTH WS-ROW
     IF WS-ROW > 0 AND SB-M-TEAM(WS-ROW) NOT = L-TEAM
         MOVE 0 TO SB-M-USED(WS-ROW)
         MOVE 0 TO WS-ROW
     END-IF
     IF WS-ROW = 0
         MOVE 0 TO WS-FREE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-MEMBERS OR WS-FREE > 0
             IF SB-M-USED(WS-I) = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         END-PERFORM
         IF WS-FREE > 0
             MOVE 1 TO SB-M-USED(WS-FREE)
             MOVE L-TEAM TO SB-M-TEAM(WS-FREE)
             MOVE L-NAME TO SB-M-NAME(WS-FREE)
             MOVE L-LENGTH TO SB-M-NAME-LENGTH(WS-FREE)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SBX-TEAM-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXT-MODIFY.
*> team modify <team> <option> ... (16 §9.2): displayName, color (reset or a colour), friendlyFire and seeFriendlyInvisibles (a bool), nametagVisibility and
*> deathMessageVisibility (always, never, hideForOtherTeams, hideForOwnTeam), collisionRule (always, never, pushOtherTeams, pushOwnTeam), prefix and suffix.
*> A value the team already has fails with the option's unchanged or already... exception; otherwise the .option.* message is broadcast (prefix and suffix are
*> quiet) and the result is 0 (prefix and suffix 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-OPTION-NAMES.
    05 FILLER               PIC X(32) VALUE "displayName".
    05 FILLER               PIC X(32) VALUE "color".
    05 FILLER               PIC X(32) VALUE "friendlyFire".
    05 FILLER               PIC X(32) VALUE "seeFriendlyInvisibles".
    05 FILLER               PIC X(32) VALUE "nametagVisibility".
    05 FILLER               PIC X(32) VALUE "deathMessageVisibility".
    05 FILLER               PIC X(32) VALUE "collisionRule".
    05 FILLER               PIC X(32) VALUE "prefix".
    05 FILLER               PIC X(32) VALUE "suffix".
 01 WS-OPTION-TABLE REDEFINES WS-OPTION-NAMES.
    05 WS-OPTION-NAME       PIC X(32) OCCURS 9 TIMES.
 01 WS-VALUE-NAMES.
    05 FILLER               PIC X(32) VALUE "always".
    05 FILLER               PIC X(32) VALUE "never".
    05 FILLER               PIC X(32) VALUE "hideForOtherTeams".
    05 FILLER               PIC X(32) VALUE "hideForOwnTeam".
    05 FILLER               PIC X(32) VALUE "pushOtherTeams".
    05 FILLER               PIC X(32) VALUE "pushOwnTeam".
 01 WS-VALUE-TABLE REDEFINES WS-VALUE-NAMES.
    05 WS-VALUE-NAME        PIC X(32) OCCURS 6 TIMES.
 01 WS-VALUE-CODES.
    05 FILLER               BINARY-LONG VALUE 0.
    05 FILLER               BINARY-LONG VALUE 1.
    05 FILLER               BINARY-LONG VALUE 2.
    05 FILLER               BINARY-LONG VALUE 3.
    05 FILLER               BINARY-LONG VALUE 2.
    05 FILLER               BINARY-LONG VALUE 3.
 01 WS-CODE-TABLE REDEFINES WS-VALUE-CODES.
    05 WS-VALUE-CODE        BINARY-LONG OCCURS 6 TIMES.
 01 WS-N-TEAM              PIC X(32) VALUE "team".
 01 WS-N-RESET             PIC X(32) VALUE "reset".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-ALLOWED           PIC X(32) VALUE "allowed".
 01 WS-N-DISPLAY           PIC X(32) VALUE "displayName".
 01 WS-N-PREFIX            PIC X(32) VALUE "prefix".
 01 WS-N-SUFFIX            PIC X(32) VALUE "suffix".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OPT                 BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-VALUE-TEXT          PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 1.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-KEY-UNCHANGED       PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The message WS-KEY with the team name, then the value text when WS-VALUE-LENGTH > 0, broadcast.
 TELL-TEAM.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT SB-T-NAME(WS-ROW) SB-T-NAME-LENGTH(WS-ROW)
     IF WS-VALUE-LENGTH > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-VALUE-TEXT WS-VALUE-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> The visibility or collision options: WS-CURRENT is the team's value, WS-KEY-UNCHANGED the failure.
 DO-LEVELS.
     MOVE 0 TO WS-VALUE-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "BX-LIT" USING WS-VALUE-NAME(WS-I) WS-INDEX
         IF WS-INDEX > 0
             MOVE WS-VALUE-CODE(WS-I) TO WS-CODE
             MOVE WS-VALUE-NAME(WS-I) TO WS-VALUE-TEXT
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-VALUE-NAME(WS-I))) TO WS-VALUE-LENGTH
         END-IF
     END-PERFORM
     IF WS-CODE = WS-CURRENT
         CALL "SBX-RAISE-PLAIN" USING WS-KEY-UNCHANGED
     ELSE
         EVALUATE WS-OPT
             WHEN 5
                 MOVE WS-CODE TO SB-T-NAMETAG(WS-ROW)
             WHEN 6
                 MOVE WS-CODE TO SB-T-DEATH(WS-ROW)
             WHEN OTHER
                 MOVE WS-CODE TO SB-T-COLLISION(WS-ROW)
         END-EVALUATE
         PERFORM TELL-TEAM
     END-IF.

*> friendlyFire (WS-OPT 3) and seeFriendlyInvisibles (4): the bool of "allowed".
 DO-FLAG.
     CALL "BX-FIND" USING WS-N-ALLOWED WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-CODE
     MOVE 0 TO WS-VALUE-LENGTH
     IF WS-OPT = 3
         MOVE SB-T-FRIENDLY(WS-ROW) TO WS-CURRENT
         MOVE "commands.team.option.friendlyfire.alreadyDisabled" TO WS-KEY-UNCHANGED
         MOVE "commands.team.option.friendlyfire.disabled" TO WS-KEY
         IF WS-CODE = 1
             MOVE "commands.team.option.friendlyfire.alreadyEnabled" TO WS-KEY-UNCHANGED
             MOVE "commands.team.option.friendlyfire.enabled" TO WS-KEY
         END-IF
     ELSE
         MOVE SB-T-SEE-INVISIBLE(WS-ROW) TO WS-CURRENT
         MOVE "commands.team.option.seeFriendlyInvisibles.alreadyDisabled" TO WS-KEY-UNCHANGED
         MOVE "commands.team.option.seeFriendlyInvisibles.disabled" TO WS-KEY
         IF WS-CODE = 1
             MOVE "commands.team.option.seeFriendlyInvisibles.alreadyEnabled" TO WS-KEY-UNCHANGED
             MOVE "commands.team.option.seeFriendlyInvisibles.enabled" TO WS-KEY
         END-IF
     END-IF
     IF WS-CODE = WS-CURRENT
         CALL "SBX-RAISE-PLAIN" USING WS-KEY-UNCHANGED
     ELSE
         IF WS-OPT = 3
             MOVE WS-CODE TO SB-T-FRIENDLY(WS-ROW)
         ELSE
             MOVE WS-CODE TO SB-T-SEE-INVISIBLE(WS-ROW)
         END-IF
         PERFORM TELL-TEAM
     END-IF.

 DO-COLOR.
     CALL "BX-LIT" USING WS-N-RESET WS-RESET
     MOVE 0 TO WS-VALUE-LENGTH
     IF WS-RESET > 0
         MOVE -1 TO WS-CODE
     ELSE
         CALL "BX-FIND" USING WS-N-VALUE WS-INDEX
         MOVE BA-IVAL(WS-INDEX) TO WS-CODE
         CALL "SBX-ARG-TEXT" USING WS-INDEX WS-VALUE-TEXT WS-VALUE-LENGTH WS-NO-QUOTES
     END-IF
     IF WS-CODE = SB-T-COLOR(WS-ROW)
         MOVE "commands.team.option.color.unchanged" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-CODE TO SB-T-COLOR(WS-ROW)
         MOVE "commands.team.option.color.success" TO WS-KEY
         IF WS-RESET > 0
             MOVE "commands.team.option.color.clear.success" TO WS-KEY
         END-IF
         PERFORM TELL-TEAM
     END-IF.

 DO-NAME.
     CALL "BX-FIND" USING WS-N-DISPLAY WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-TEXT WS-TEXT-LENGTH WS-QUOTES
     MOVE 0 TO WS-VALUE-LENGTH
     IF WS-TEXT-LENGTH = SB-T-DISPLAY-LENGTH(WS-ROW) AND WS-TEXT = SB-T-DISPLAY(WS-ROW)
         MOVE "commands.team.option.name.unchanged" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         MOVE WS-TEXT TO SB-T-DISPLAY(WS-ROW)
         MOVE WS-TEXT-LENGTH TO SB-T-DISPLAY-LENGTH(WS-ROW)
         MOVE "commands.team.option.name.success" TO WS-KEY
         PERFORM TELL-TEAM
     END-IF.

*> prefix (WS-OPT 8) and suffix (9): the component text, told quietly; the result is 1.
 DO-AFFIX.
     IF WS-OPT = 8
         CALL "BX-FIND" USING WS-N-PREFIX WS-INDEX
         CALL "SBX-ARG-TEXT" USING WS-INDEX SB-T-PREFIX(WS-ROW) SB-T-PREFIX-LENGTH(WS-ROW) WS-QUOTES
         MOVE SB-T-PREFIX(WS-ROW) TO WS-TEXT
         MOVE SB-T-PREFIX-LENGTH(WS-ROW) TO WS-TEXT-LENGTH
         MOVE "commands.team.option.prefix.success" TO WS-KEY
     ELSE
         CALL "BX-FIND" USING WS-N-SUFFIX WS-INDEX
         CALL "SBX-ARG-TEXT" USING WS-INDEX SB-T-SUFFIX(WS-ROW) SB-T-SUFFIX-LENGTH(WS-ROW) WS-QUOTES
         MOVE SB-T-SUFFIX(WS-ROW) TO WS-TEXT
         MOVE SB-T-SUFFIX-LENGTH(WS-ROW) TO WS-TEXT-LENGTH
         MOVE "commands.team.option.suffix.success" TO WS-KEY
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE 1 TO BR-R-RESULT.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     CALL "SBX-TEAM" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-OPT BR-R-RESULT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
             CALL "BX-LIT" USING WS-OPTION-NAME(WS-I) WS-INDEX
             IF WS-INDEX > 0
                 MOVE WS-I TO WS-OPT
             END-IF
         END-PERFORM
         EVALUATE WS-OPT
             WHEN 1
                 PERFORM DO-NAME
             WHEN 2
                 PERFORM DO-COLOR
             WHEN 3 THRU 4
                 PERFORM DO-FLAG
             WHEN 5
                 MOVE SB-T-NAMETAG(WS-ROW) TO WS-CURRENT
                 MOVE "commands.team.option.nametagVisibility.unchanged" TO WS-KEY-UNCHANGED
                 MOVE "commands.team.option.nametagVisibility.success" TO WS-KEY
                 PERFORM DO-LEVELS
             WHEN 6
                 MOVE SB-T-DEATH(WS-ROW) TO WS-CURRENT
                 MOVE "commands.team.option.deathMessageVisibility.unchanged" TO WS-KEY-UNCHANGED
                 MOVE "commands.team.option.deathMessageVisibility.success" TO WS-KEY
                 PERFORM DO-LEVELS
             WHEN 7
                 MOVE SB-T-COLLISION(WS-ROW) TO WS-CURRENT
                 MOVE "commands.team.option.collisionRule.unchanged" TO WS-KEY-UNCHANGED
                 MOVE "commands.team.option.collisionRule.success" TO WS-KEY
                 PERFORM DO-LEVELS
             WHEN OTHER
                 PERFORM DO-AFFIX
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM CXT-MODIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TEAM.
*> team list|add|remove|empty|join|leave|modify (16 §9.2, level 2). list tells the teams (.list.teams.empty or .list.teams.success [count, names]) or the
*> members of one (.list.members.empty [team], .list.members.success [team, count, names]), not broadcast; the result is the count. add <team> [<displayName>]
*> makes a team (a duplicate, or a full table, is .add.duplicate; .add.success [team]); remove drops it and its members (.remove.success [team]); both return
*> the number of teams afterwards. empty removes the members (.empty.success [count, team], .empty.unchanged when there were none; the result is the count).
*> join <team> [<members>] puts the holders (the source when none is typed; the console is permissions.requires.entity) on the team, off any other
*> (.join.success.single [member, team] or .multiple [count, team]); leave takes them off any team (.leave.success.single [member] or .multiple [count]); both
*> return the number of holders. modify is CXT-MODIFY. An unknown team is team.notFound [name].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 COPY BRRUN.
 COPY PROTO.
 COPY SBHOLD.
 01 WS-N-LIST              PIC X(32) VALUE "list".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-N-REMOVE            PIC X(32) VALUE "remove".
 01 WS-N-EMPTY             PIC X(32) VALUE "empty".
 01 WS-N-JOIN              PIC X(32) VALUE "join".
 01 WS-N-LEAVE             PIC X(32) VALUE "leave".
 01 WS-N-TEAM              PIC X(32) VALUE "team".
 01 WS-N-DISPLAY           PIC X(32) VALUE "displayName".
 01 WS-N-MEMBERS           PIC X(32) VALUE "members".
 01 WS-LIST                BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-EMPTY               BINARY-LONG.
 01 WS-JOIN                BINARY-LONG.
 01 WS-LEAVE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NAMES               PIC X(1024).
 01 WS-NAMES-LENGTH        BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 1.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The number of teams into BR-R-RESULT.
 COUNT-RESULT.
     CALL "SBX-JOIN" USING WS-KIND WS-NAMES WS-NAMES-LENGTH WS-COUNT
     MOVE WS-COUNT TO BR-R-RESULT.

*> The message WS-KEY with the team name (WS-NAME) as its only argument, broadcast.
 TELL-NAME.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> The names of the members of team WS-ROW in WS-NAMES and their number in WS-COUNT.
 COLLECT-MEMBERS.
     MOVE SPACES TO WS-NAMES
     MOVE 1 TO WS-POINTER
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-MEMBERS
         IF SB-M-USED(WS-I) = 1 AND SB-M-TEAM(WS-I) = WS-ROW
             IF WS-COUNT > 0
                 STRING ", " DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
             END-IF
             STRING SB-M-NAME(WS-I)(1:SB-M-NAME-LENGTH(WS-I)) DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     COMPUTE WS-NAMES-LENGTH = WS-POINTER - 1.

 DO-LIST.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     IF WS-INDEX = 0
         CALL "SBX-JOIN" USING WS-KIND WS-NAMES WS-NAMES-LENGTH WS-COUNT
         IF WS-COUNT = 0
             MOVE "commands.team.list.teams.empty" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
         ELSE
             MOVE "commands.team.list.teams.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-NAMES-LENGTH
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE WS-COUNT TO BR-R-RESULT
     ELSE
         CALL "SBX-TEAM" USING WS-INDEX WS-ROW
         IF BR-R-FAILED = 0
             PERFORM COLLECT-MEMBERS
             IF WS-COUNT = 0
                 MOVE "commands.team.list.members.empty" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SB-T-NAME(WS-ROW) SB-T-NAME-LENGTH(WS-ROW)
             ELSE
                 MOVE "commands.team.list.members.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT SB-T-NAME(WS-ROW) SB-T-NAME-LENGTH(WS-ROW)
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-NAMES-LENGTH
             END-IF
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF.

 DO-ADD.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-NAME WS-NAME-LENGTH WS-NO-QUOTES
     CALL "SBX-TEAM-BY-NAME" USING WS-NAME WS-NAME-LENGTH WS-ROW
     MOVE 0 TO WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-TEAMS OR WS-FREE > 0
         IF SB-T-USED(WS-I) = 0
             MOVE WS-I TO WS-FREE
         END-IF
     END-PERFORM
     IF WS-ROW > 0 OR WS-FREE = 0
         MOVE "commands.team.add.duplicate" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         INITIALIZE SB-TEAM(WS-FREE)
         MOVE 1 TO SB-T-USED(WS-FREE)
         MOVE WS-NAME TO SB-T-NAME(WS-FREE)
         MOVE WS-NAME-LENGTH TO SB-T-NAME-LENGTH(WS-FREE)
         MOVE WS-NAME TO SB-T-DISPLAY(WS-FREE)
         MOVE WS-NAME-LENGTH TO SB-T-DISPLAY-LENGTH(WS-FREE)
         MOVE -1 TO SB-T-COLOR(WS-FREE)
         MOVE 1 TO SB-T-FRIENDLY(WS-FREE) SB-T-SEE-INVISIBLE(WS-FREE)
         CALL "BX-FIND" USING WS-N-DISPLAY WS-INDEX
         IF WS-INDEX > 0
             CALL "SBX-ARG-TEXT" USING WS-INDEX SB-T-DISPLAY(WS-FREE) SB-T-DISPLAY-LENGTH(WS-FREE) WS-QUOTES
         END-IF
         MOVE "commands.team.add.success" TO WS-KEY
         PERFORM TELL-NAME
         PERFORM COUNT-RESULT
     END-IF.

 DO-REMOVE.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     CALL "SBX-TEAM" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         MOVE SB-T-NAME(WS-ROW) TO WS-NAME
         MOVE SB-T-NAME-LENGTH(WS-ROW) TO WS-NAME-LENGTH
         MOVE 0 TO SB-T-USED(WS-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-MEMBERS
             IF SB-M-USED(WS-I) = 1 AND SB-M-TEAM(WS-I) = WS-ROW
                 MOVE 0 TO SB-M-USED(WS-I)
             END-IF
         END-PERFORM
         MOVE "commands.team.remove.success" TO WS-KEY
         PERFORM TELL-NAME
         PERFORM COUNT-RESULT
     END-IF.

 DO-EMPTY.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     CALL "SBX-TEAM" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SB-MAX-MEMBERS
             IF SB-M-USED(WS-I) = 1 AND SB-M-TEAM(WS-I) = WS-ROW
                 MOVE 0 TO SB-M-USED(WS-I)
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
         IF WS-COUNT = 0
             MOVE "commands.team.empty.unchanged" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         ELSE
             MOVE "commands.team.empty.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "CMD-TEXT-ARG" USING PB-TEXT SB-T-NAME(WS-ROW) SB-T-NAME-LENGTH(WS-ROW)
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF.

*> The holders of the "members" argument, or the source when there is none (the console is not an entity).
 GET-MEMBERS.
     CALL "BX-FIND" USING WS-N-MEMBERS WS-INDEX
     EVALUATE TRUE
         WHEN WS-INDEX > 0
             CALL "SBX-HOLDERS" USING WS-INDEX SBH-TABLE
         WHEN BS-ROW = 0
             MOVE "permissions.requires.entity" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         WHEN OTHER
             MOVE 1 TO SBH-COUNT
             MOVE SPACES TO SBH-NAME(1)
             MOVE BS-NAME TO SBH-NAME(1)
             MOVE BS-NAME-LENGTH TO SBH-LENGTH(1)
     END-EVALUATE.

 DO-JOIN.
     CALL "BX-FIND" USING WS-N-TEAM WS-INDEX
     CALL "SBX-TEAM" USING WS-INDEX WS-ROW
     IF BR-R-FAILED = 0
         PERFORM GET-MEMBERS
     END-IF
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             CALL "SBX-TEAM-JOIN" USING WS-ROW SBH-NAME(WS-I) SBH-LENGTH(WS-I)
         END-PERFORM
         IF SBH-COUNT = 1
             MOVE "commands.team.join.success.single" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
         ELSE
             MOVE "commands.team.join.success.multiple" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
         END-IF
         CALL "CMD-TEXT-ARG" USING PB-TEXT SB-T-NAME(WS-ROW) SB-T-NAME-LENGTH(WS-ROW)
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE SBH-COUNT TO BR-R-RESULT
     END-IF.

 DO-LEAVE.
     PERFORM GET-MEMBERS
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBH-COUNT
             CALL "SBX-TEAM-LEAVE" USING SBH-NAME(WS-I) SBH-LENGTH(WS-I)
         END-PERFORM
         IF SBH-COUNT = 1
             MOVE "commands.team.leave.success.single" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT SBH-NAME(1) SBH-LENGTH(1)
         ELSE
             MOVE "commands.team.leave.success.multiple" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT SBH-COUNT
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE SBH-COUNT TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-LIST WS-LIST
     CALL "BX-LIT" USING WS-N-ADD WS-ADD
     CALL "BX-LIT" USING WS-N-REMOVE WS-REMOVE
     CALL "BX-LIT" USING WS-N-EMPTY WS-EMPTY
     CALL "BX-LIT" USING WS-N-JOIN WS-JOIN
     CALL "BX-LIT" USING WS-N-LEAVE WS-LEAVE
     EVALUATE TRUE
         WHEN WS-LIST > 0
             PERFORM DO-LIST
         WHEN WS-ADD > 0
             PERFORM DO-ADD
         WHEN WS-REMOVE > 0
             PERFORM DO-REMOVE
         WHEN WS-EMPTY > 0
             PERFORM DO-EMPTY
         WHEN WS-JOIN > 0
             PERFORM DO-JOIN
         WHEN WS-LEAVE > 0
             PERFORM DO-LEAVE
         WHEN OTHER
             CALL "CXT-MODIFY"
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-TEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TEAM.
*> The forms of team (16 §9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TEAM.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-FORMS.
    05 FILLER PIC X(100) VALUE "list".
    05 FILLER PIC X(100) VALUE "list <team:team>".
    05 FILLER PIC X(100) VALUE "add <team:word>".
    05 FILLER PIC X(100) VALUE "add <team:word> <displayName:component>".
    05 FILLER PIC X(100) VALUE "remove <team:team>".
    05 FILLER PIC X(100) VALUE "empty <team:team>".
    05 FILLER PIC X(100) VALUE "join <team:team>".
    05 FILLER PIC X(100) VALUE "join <team:team> <members:holders>".
    05 FILLER PIC X(100) VALUE "leave <members:holders>".
    05 FILLER PIC X(100) VALUE "modify <team:team> displayName <displayName:component>".
    05 FILLER PIC X(100) VALUE "modify <team:team> color reset".
    05 FILLER PIC X(100) VALUE "modify <team:team> color <value:teamcolor>".
    05 FILLER PIC X(100) VALUE "modify <team:team> friendlyFire <allowed:bool>".
    05 FILLER PIC X(100) VALUE "modify <team:team> seeFriendlyInvisibles <allowed:bool>".
    05 FILLER PIC X(100) VALUE "modify <team:team> nametagVisibility never".
    05 FILLER PIC X(100) VALUE "modify <team:team> nametagVisibility hideForOtherTeams".
    05 FILLER PIC X(100) VALUE "modify <team:team> nametagVisibility hideForOwnTeam".
    05 FILLER PIC X(100) VALUE "modify <team:team> nametagVisibility always".
    05 FILLER PIC X(100) VALUE "modify <team:team> deathMessageVisibility never".
    05 FILLER PIC X(100) VALUE "modify <team:team> deathMessageVisibility hideForOtherTeams".
    05 FILLER PIC X(100) VALUE "modify <team:team> deathMessageVisibility hideForOwnTeam".
    05 FILLER PIC X(100) VALUE "modify <team:team> deathMessageVisibility always".
    05 FILLER PIC X(100) VALUE "modify <team:team> collisionRule never".
    05 FILLER PIC X(100) VALUE "modify <team:team> collisionRule pushOwnTeam".
    05 FILLER PIC X(100) VALUE "modify <team:team> collisionRule pushOtherTeams".
    05 FILLER PIC X(100) VALUE "modify <team:team> collisionRule always".
    05 FILLER PIC X(100) VALUE "modify <team:team> prefix <prefix:component>".
    05 FILLER PIC X(100) VALUE "modify <team:team> suffix <suffix:component>".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM              PIC X(100) OCCURS 28 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         MOVE SPACES TO WS-PATH
         STRING "team " DELIMITED BY SIZE WS-FORM(WS-I) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-TEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TRIGGER.
*> trigger <objective> [add <value> | set <value>] (16 §9.3, level 0): the source must be a player (permissions.requires.player); the objective must have
*> the criterion trigger (commands.trigger.failed.invalid) and the player a score of it that is not locked (commands.trigger.failed.unprimed; scoreboard players
*> enable makes or unlocks it). The score is locked, then raised by 1 (.simple.success [objective]), raised by the value (.add.success [objective, value]) or set
*> to it (.set.success [objective, value]), broadcast; the result is the new score.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SBSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-OBJECTIVE         PIC X(32) VALUE "objective".
 01 WS-N-ADD               PIC X(32) VALUE "add".
 01 WS-N-SET               PIC X(32) VALUE "set".
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-ADD                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OBJ                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HOLDER              PIC X(64).
 01 WS-HOLDER-LENGTH       BINARY-LONG.
 01 WS-NEW                 BINARY-DOUBLE.
 01 WS-VALUE               BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     IF BS-ROW = 0
         MOVE "permissions.requires.player" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         CALL "BX-FIND" USING WS-N-OBJECTIVE WS-INDEX
         CALL "SBX-OBJECTIVE" USING WS-INDEX WS-OBJ
     END-IF
     IF BR-R-FAILED = 0 AND (SB-O-CRIT-LENGTH(WS-OBJ) NOT = 7 OR SB-O-CRITERIA(WS-OBJ)(1:7) NOT = "trigger")
         MOVE "commands.trigger.failed.invalid" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     END-IF
     IF BR-R-FAILED = 0
         MOVE SPACES TO WS-HOLDER
         MOVE BS-NAME TO WS-HOLDER
         MOVE BS-NAME-LENGTH TO WS-HOLDER-LENGTH
         CALL "SBX-SCORE-FIND" USING WS-OBJ WS-HOLDER WS-HOLDER-LENGTH WS-ZERO WS-ROW
         IF WS-ROW = 0
             MOVE "commands.trigger.failed.unprimed" TO WS-KEY
             CALL "SBX-RAISE-PLAIN" USING WS-KEY
         ELSE
             IF SB-S-LOCKED(WS-ROW) = 1
                 MOVE "commands.trigger.failed.unprimed" TO WS-KEY
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY
             END-IF
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 1 TO SB-S-LOCKED(WS-ROW)
         CALL "BX-LIT" USING WS-N-ADD WS-ADD
         CALL "BX-LIT" USING WS-N-SET WS-SET
         MOVE 1 TO WS-VALUE
         IF WS-ADD + WS-SET > 0
             CALL "BX-FIND" USING WS-N-VALUE WS-INDEX
             MOVE BA-IVAL(WS-INDEX) TO WS-VALUE
         END-IF
         EVALUATE TRUE
             WHEN WS-SET > 0
                 MOVE WS-VALUE TO WS-NEW
                 MOVE "commands.trigger.set.success" TO WS-KEY
             WHEN WS-ADD > 0
                 COMPUTE WS-NEW = SB-S-VALUE(WS-ROW) + WS-VALUE
                 MOVE "commands.trigger.add.success" TO WS-KEY
             WHEN OTHER
                 COMPUTE WS-NEW = SB-S-VALUE(WS-ROW) + 1
                 MOVE "commands.trigger.simple.success" TO WS-KEY
         END-EVALUATE
         CALL "SBX-WRAP" USING WS-NEW
         MOVE WS-NEW TO SB-S-VALUE(WS-ROW)
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT SB-O-NAME(WS-OBJ) SB-O-NAME-LENGTH(WS-OBJ)
         IF WS-ADD + WS-SET > 0
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-VALUE
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-NEW TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TRIGGER.
*> The forms of trigger (16 §9.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TRIGGER.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "trigger <objective:objective>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "trigger <objective:objective> add <value:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "trigger <objective:objective> set <value:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DISPATCH-D.
*> The commands of the lane cmds-d (the scoreboard group of this file and the data group of core/src/cmds-data.cob; CX-DISPATCH-C hands over to it):
*> any other command id is help.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 COPY BRRUN.
 PROCEDURE DIVISION.
     EVALUATE BR-R-COMMAND
         WHEN BC-SCOREBOARD
             CALL "CX-SCOREBOARD"
         WHEN BC-TEAM
             CALL "CX-TEAM"
         WHEN BC-TRIGGER
             CALL "CX-TRIGGER"
         WHEN BC-STOPWATCH
             CALL "CX-STOPWATCH"
         WHEN BC-SCHEDULE
             CALL "CX-SCHEDULE"
         WHEN BC-RETURN
             CALL "CX-RETURN"
         WHEN BC-FUNCTION
             CALL "CX-FUNCTION"
         WHEN BC-DATAPACK
             CALL "CX-DATAPACK"
         WHEN BC-DATA
             CALL "CX-DATA"
         WHEN BC-COMPUTE
             CALL "CX-COMPUTE"
         WHEN OTHER
             CALL "CX-HELP"
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-DISPATCH-D.
