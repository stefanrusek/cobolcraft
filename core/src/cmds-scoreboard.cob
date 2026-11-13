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
