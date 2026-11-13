*> The data group (docs/protocol/16-commands-catalog.md §10): stopwatch, schedule, return, function and datapack, and the state they own (core/copy/SDSTATE.cpy, in memory only: not saved
*> with the world). There is no function engine and no data-pack loader, so scheduled functions are kept but never run and every function is missing; /data and /compute are not in
*> this file (see the notes of their tasks). The shape of a command follows core/src/cmds-scoreboard.cob; CX-DISPATCH-D there runs these.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SDX-ID.
*> USING argument index, id out (PIC X(64)), length out, tag out (BINARY-LONG, 1 when the text started with #): the identifier a resource location or function-or-tag argument typed,
*> with minecraft: added when it has no namespace.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAW                 PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-COLONS              BINARY-LONG.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ID L-LENGTH L-TAG.
     CALL "SBX-ARG-TEXT" USING L-INDEX WS-RAW WS-LENGTH WS-NO-QUOTES
     MOVE 0 TO L-TAG
     MOVE 1 TO WS-FROM
     IF WS-RAW(1:1) = "#"
         MOVE 1 TO L-TAG
         MOVE 2 TO WS-FROM
         SUBTRACT 1 FROM WS-LENGTH
     END-IF
     MOVE 0 TO WS-COLONS
     INSPECT WS-RAW(WS-FROM:WS-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     MOVE SPACES TO L-ID
     IF WS-COLONS = 0
         STRING "minecraft:" DELIMITED BY SIZE WS-RAW(WS-FROM:WS-LENGTH) DELIMITED BY SIZE INTO L-ID
         COMPUTE L-LENGTH = FUNCTION MIN(WS-LENGTH + 10, 64)
     ELSE
         MOVE WS-RAW(WS-FROM:WS-LENGTH) TO L-ID
         MOVE WS-LENGTH TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM SDX-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-STOPWATCH.
*> stopwatch create|query|restart|remove <id> (16 §10.10, level 2): a stopwatch counts game ticks from its start (CW-TICKS). create makes it (.create.success [id], or the failure .already_exists
*> [id]); restart sets its start to now and remove drops it (.restart.success, .remove.success [id]); an unknown one is .does_not_exist [id]; all return 1. query [<scale>] tells .query
*> [id, seconds] with seconds the elapsed ticks over 20 times the scale (as Java prints a double), broadcast, and returns them truncated. The id has minecraft: when no namespace was typed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY SDSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-CREATE            PIC X(32) VALUE "create".
 01 WS-N-QUERY             PIC X(32) VALUE "query".
 01 WS-N-RESTART           PIC X(32) VALUE "restart".
 01 WS-N-ID                PIC X(32) VALUE "id".
 01 WS-N-SCALE             PIC X(32) VALUE "scale".
 01 WS-CREATE              BINARY-LONG.
 01 WS-QUERY               BINARY-LONG.
 01 WS-RESTART             BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ELAPSED             BINARY-DOUBLE.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-SECONDS             FLOAT-LONG.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-INT-ZERO            BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The message WS-KEY with the id as its only argument, broadcast; the result is 1.
 TELL-ID.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 1 TO BR-R-RESULT.

*> The failure WS-KEY with the id.
 FAIL-ID.
     MOVE SPACES TO WS-A2
     CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-ID WS-ID-LENGTH WS-A2 WS-L2.

 DO-CREATE.
     IF WS-ROW > 0
         MOVE "commands.stopwatch.already_exists" TO WS-KEY
         PERFORM FAIL-ID
     ELSE
         MOVE 0 TO WS-FREE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-MAX-WATCHES OR WS-FREE > 0
             IF SD-W-USED(WS-I) = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         END-PERFORM
         IF WS-FREE > 0
             MOVE 1 TO SD-W-USED(WS-FREE)
             MOVE WS-ID TO SD-W-ID(WS-FREE)
             MOVE WS-ID-LENGTH TO SD-W-LENGTH(WS-FREE)
             MOVE CW-TICKS TO SD-W-START(WS-FREE)
         END-IF
         MOVE "commands.stopwatch.create.success" TO WS-KEY
         PERFORM TELL-ID
     END-IF.

 DO-QUERY.
     COMPUTE WS-ELAPSED = CW-TICKS - SD-W-START(WS-ROW)
     MOVE 1.0 TO WS-SCALE
     CALL "BX-FIND" USING WS-N-SCALE WS-INDEX
     IF WS-INDEX > 0
         MOVE BA-DVAL(WS-INDEX) TO WS-SCALE
     END-IF
     COMPUTE WS-SECONDS = WS-ELAPSED / 20 * WS-SCALE
     CALL "BR-NUMBER-TEXT" USING WS-KIND-DOUBLE WS-INT-ZERO WS-SECONDS WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
     MOVE "commands.stopwatch.query" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     COMPUTE BR-R-RESULT = FUNCTION INTEGER-PART(WS-SECONDS).

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-CREATE WS-CREATE
     CALL "BX-LIT" USING WS-N-QUERY WS-QUERY
     CALL "BX-LIT" USING WS-N-RESTART WS-RESTART
     CALL "BX-FIND" USING WS-N-ID WS-INDEX
     CALL "SDX-ID" USING WS-INDEX WS-ID WS-ID-LENGTH WS-TAG
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-MAX-WATCHES OR WS-ROW > 0
         IF SD-W-USED(WS-I) = 1 AND SD-W-LENGTH(WS-I) = WS-ID-LENGTH AND SD-W-ID(WS-I) = WS-ID
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-CREATE > 0
             PERFORM DO-CREATE
         WHEN WS-ROW = 0
             MOVE "commands.stopwatch.does_not_exist" TO WS-KEY
             PERFORM FAIL-ID
         WHEN WS-QUERY > 0
             PERFORM DO-QUERY
         WHEN WS-RESTART > 0
             MOVE CW-TICKS TO SD-W-START(WS-ROW)
             MOVE "commands.stopwatch.restart.success" TO WS-KEY
             PERFORM TELL-ID
         WHEN OTHER
             MOVE 0 TO SD-W-USED(WS-ROW)
             MOVE "commands.stopwatch.remove.success" TO WS-KEY
             PERFORM TELL-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-STOPWATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-STOPWATCH.
*> The forms of stopwatch (16 §10.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-STOPWATCH.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "stopwatch create <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "stopwatch query <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "stopwatch query <id:resloc> <scale:double>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "stopwatch restart <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "stopwatch remove <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-STOPWATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SCHEDULE.
*> schedule function <function|#tag> <time> [append|replace] and schedule clear <id> (16 §10.4, level 2): a time of 0 is the failure commands.schedule.same_tick; otherwise the schedule is kept for
*> game tick CW-TICKS + time (replace, the default, first drops the schedules of the same id and kind) and commands.schedule.created.function or .created.tag [id, ticks, game time] is broadcast;
*> the result is the game time modulo 2147483647. clear removes the schedules of the id (.cleared.success [count, id], or the failure .cleared.failure [id]); the result is the count. The functions
*> never run (no function engine) and a macro cannot be recognised, so commands.schedule.macro is not raised.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY SDSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-CLEAR             PIC X(32) VALUE "clear".
 01 WS-N-APPEND            PIC X(32) VALUE "append".
 01 WS-N-FUNCTION          PIC X(32) VALUE "function".
 01 WS-N-TIME              PIC X(32) VALUE "time".
 01 WS-N-ID                PIC X(32) VALUE "id".
 01 WS-CLEAR               BINARY-LONG.
 01 WS-APPEND              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DUE                 BINARY-DOUBLE.
 01 WS-EDIT                PIC -(17)9.
 01 WS-TEXT                PIC X(24).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

 DO-CLEAR.
     CALL "BX-FIND" USING WS-N-ID WS-INDEX
     CALL "SDX-ID" USING WS-INDEX WS-ID WS-ID-LENGTH WS-TAG
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-MAX-SCHEDULES
         IF SD-S-USED(WS-I) = 1 AND SD-S-TAG(WS-I) = 0 AND SD-S-LENGTH(WS-I) = WS-ID-LENGTH AND SD-S-ID(WS-I) = WS-ID
             MOVE 0 TO SD-S-USED(WS-I)
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT = 0
         MOVE "commands.schedule.cleared.failure" TO WS-KEY
         MOVE SPACES TO WS-A2
         CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-ID WS-ID-LENGTH WS-A2 WS-L2
     ELSE
         MOVE "commands.schedule.cleared.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-COUNT TO BR-R-RESULT
     END-IF.

 DO-FUNCTION.
     CALL "BX-FIND" USING WS-N-FUNCTION WS-INDEX
     CALL "SDX-ID" USING WS-INDEX WS-ID WS-ID-LENGTH WS-TAG
     CALL "BX-FIND" USING WS-N-TIME WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-TICKS
     IF WS-TICKS = 0
         MOVE "commands.schedule.same_tick" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     ELSE
         COMPUTE WS-DUE = CW-TICKS + WS-TICKS
         CALL "BX-LIT" USING WS-N-APPEND WS-APPEND
         MOVE 0 TO WS-FREE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-MAX-SCHEDULES
             IF SD-S-USED(WS-I) = 1 AND WS-APPEND = 0 AND SD-S-TAG(WS-I) = WS-TAG
                     AND SD-S-LENGTH(WS-I) = WS-ID-LENGTH AND SD-S-ID(WS-I) = WS-ID
                 MOVE 0 TO SD-S-USED(WS-I)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-MAX-SCHEDULES OR WS-FREE > 0
             IF SD-S-USED(WS-I) = 0
                 MOVE WS-I TO WS-FREE
             END-IF
         END-PERFORM
         IF WS-FREE > 0
             MOVE 1 TO SD-S-USED(WS-FREE)
             MOVE WS-ID TO SD-S-ID(WS-FREE)
             MOVE WS-ID-LENGTH TO SD-S-LENGTH(WS-FREE)
             MOVE WS-TAG TO SD-S-TAG(WS-FREE)
             MOVE WS-DUE TO SD-S-TIME(WS-FREE)
         END-IF
         MOVE "commands.schedule.created.function" TO WS-KEY
         IF WS-TAG = 1
             MOVE "commands.schedule.created.tag" TO WS-KEY
         END-IF
         MOVE WS-DUE TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
         COMPUTE WS-TEXT-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-ID-LENGTH
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-TICKS
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         COMPUTE BR-R-RESULT = FUNCTION MOD(WS-DUE, 2147483647)
     END-IF.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-CLEAR WS-CLEAR
     IF WS-CLEAR > 0
         PERFORM DO-CLEAR
     ELSE
         PERFORM DO-FUNCTION
     END-IF
     GOBACK.
 END PROGRAM CX-SCHEDULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SCHEDULE.
*> The forms of schedule (16 §10.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SCHEDULE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "schedule function <function:function> <time:time>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "schedule function <function:function> <time:time> append" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "schedule function <function:function> <time:time> replace" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "schedule clear <id:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SCHEDULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RETURN.
*> return <value> and return fail (16 §10.6, level 2); return run <command> redirects to the command tree, so the command runs as itself and its result is the result. No feedback. The value
*> is the result; fail has result 0 (marking the frame of a function as failed needs the function engine, which does not exist).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-INDEX               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO BR-R-RESULT
     CALL "BX-FIND" USING WS-N-VALUE WS-INDEX
     IF WS-INDEX > 0
         MOVE BA-IVAL(WS-INDEX) TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-RETURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RETURN.
*> The forms of return (16 §10.6): run redirects to the root of the tree like the run of execute.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 COPY BRCMD.
 COPY BRREGLAST.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RETURN.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PATH                PIC X(256).
 01 WS-NODE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "return <value:int>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "return fail" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "return run" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-ZERO WS-PATH
     MOVE BR-REG-LAST-NODE TO WS-NODE
     MOVE 1 TO BR-N-REDIRECT(WS-NODE)
     GOBACK.
 END PROGRAM CMDS-REG-RETURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-FUNCTION.
*> function <name|#tag> [<arguments> | with block|entity|storage ...] (16 §10.3, level 2): the function engine and the data-pack functions do not exist, so every function is missing:
*> commands.function.scheduled.no_functions [name] (the name has minecraft: when no namespace was typed, and # for a tag); the result is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-N-NAME              PIC X(32) VALUE "name".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SHOWN               PIC X(64).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "commands.function.scheduled.no_functions".
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-N-NAME WS-INDEX
     CALL "SDX-ID" USING WS-INDEX WS-ID WS-ID-LENGTH WS-TAG
     MOVE SPACES TO WS-SHOWN WS-A2
     MOVE WS-ID TO WS-SHOWN
     MOVE WS-ID-LENGTH TO WS-SHOWN-LENGTH
     IF WS-TAG = 1
         STRING "#" DELIMITED BY SIZE WS-ID(1:WS-ID-LENGTH) DELIMITED BY SIZE INTO WS-SHOWN
         ADD 1 TO WS-SHOWN-LENGTH
     END-IF
     CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-SHOWN WS-SHOWN-LENGTH WS-A2 WS-L2
     MOVE 0 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-FUNCTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-FUNCTION.
*> The forms of function (16 §10.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-FUNCTION.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-FORMS.
    05 FILLER PIC X(80) VALUE "function <name:function>".
    05 FILLER PIC X(80) VALUE "function <name:function> <arguments:nbt>".
    05 FILLER PIC X(80) VALUE "function <name:function> with block <pos:pos>".
    05 FILLER PIC X(80) VALUE "function <name:function> with block <pos:pos> <path:nbtpath>".
    05 FILLER PIC X(80) VALUE "function <name:function> with entity <target:entities>".
    05 FILLER PIC X(80) VALUE "function <name:function> with entity <target:entities> <path:nbtpath>".
    05 FILLER PIC X(80) VALUE "function <name:function> with storage <storage:resloc>".
    05 FILLER PIC X(80) VALUE "function <name:function> with storage <storage:resloc> <path:nbtpath>".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM              PIC X(80) OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-FORM(WS-I) TO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-FUNCTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SDX-PACK-FIND.
*> USING name (PIC X(64)), length, pack row out (0 none), enabled position out (0 when the pack is not enabled): the data pack of that name. The built-in vanilla pack is made, enabled, the
*> first time this is called.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SDSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-POSITION             BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-ROW L-POSITION.
     IF SD-PACK-COUNT = 0
         MOVE 1 TO SD-PACK-COUNT SD-ENABLED-COUNT
         MOVE "vanilla" TO SD-P-NAME(1)
         MOVE 7 TO SD-P-LENGTH(1)
         MOVE 1 TO SD-ENABLED(1)
     END-IF
     MOVE 0 TO L-ROW L-POSITION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-PACK-COUNT OR L-ROW > 0
         IF SD-P-LENGTH(WS-I) = L-LENGTH AND SD-P-NAME(WS-I) = L-NAME
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ENABLED-COUNT
         IF SD-ENABLED(WS-I) = L-ROW
             MOVE WS-I TO L-POSITION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SDX-PACK-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DATAPACK.
*> datapack list [available|enabled], enable <pack> [first|last|before <pack>|after <pack>], disable <pack> and create <id> <description> (16 §10.11, level 2; create 4): the packs are the
*> built-in vanilla pack (enabled) and the packs create makes ("file/<id>", not enabled; an id has only a-z 0-9 _ - . else .create.invalid_name [id]; one that exists is .create.already_exists [id]; no
*> files are written). list tells .list.enabled.success [count, names] or .none and .list.available.success or .none, not broadcast (no argument: both; the result is the count of what was listed).
*> enable puts the pack in the enabled order (.modify.enable [pack]; a pack that is enabled is .enable.failed [pack]; an unknown pack, or an anchor that is not enabled, is .unknown [name]); disable
*> removes it (.modify.disable, .disable.failed); both return the number enabled. create returns 1. The checks of required flags are not made (no feature flags exist here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SDSTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-LIST              PIC X(32) VALUE "list".
 01 WS-N-AVAILABLE         PIC X(32) VALUE "available".
 01 WS-N-ENABLED           PIC X(32) VALUE "enabled".
 01 WS-N-ENABLE            PIC X(32) VALUE "enable".
 01 WS-N-DISABLE           PIC X(32) VALUE "disable".
 01 WS-N-FIRST             PIC X(32) VALUE "first".
 01 WS-N-BEFORE            PIC X(32) VALUE "before".
 01 WS-N-AFTER             PIC X(32) VALUE "after".
 01 WS-N-NAME              PIC X(32) VALUE "name".
 01 WS-N-EXISTING          PIC X(32) VALUE "existing".
 01 WS-N-ID                PIC X(32) VALUE "id".
 01 WS-LIST                BINARY-LONG.
 01 WS-AVAILABLE           BINARY-LONG.
 01 WS-ENABLED             BINARY-LONG.
 01 WS-ENABLE              BINARY-LONG.
 01 WS-DISABLE             BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-OTHER               PIC X(64).
 01 WS-OTHER-LENGTH        BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POSITION            BINARY-LONG.
 01 WS-ROW-2               BINARY-LONG.
 01 WS-POSITION-2          BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LISTED              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NAMES               PIC X(1024).
 01 WS-NAMES-LENGTH        BINARY-LONG.
 01 WS-QUOTES              BINARY-LONG VALUE 1.
 01 WS-VALID               BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-FULL                PIC X(64).
 01 WS-FULL-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N-ARGS              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with WS-NAME.
 FAIL-NAME.
     MOVE SPACES TO WS-A2
     CALL "SBX-RAISE" USING WS-KEY WS-N-ARGS WS-NAME WS-NAME-LENGTH WS-A2 WS-L2.

*> The message WS-KEY with WS-NAME, broadcast.
 TELL-NAME.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

*> The names of the enabled packs (WS-TARGET 1) or of the others (2) in WS-NAMES, their number in WS-COUNT.
 COLLECT-NAMES.
     MOVE SPACES TO WS-NAMES
     MOVE 1 TO WS-POINTER
     MOVE 0 TO WS-COUNT
     IF WS-TARGET = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ENABLED-COUNT
             IF WS-COUNT > 0
                 STRING ", " DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
             END-IF
             MOVE SD-ENABLED(WS-I) TO WS-ROW
             STRING SD-P-NAME(WS-ROW)(1:SD-P-LENGTH(WS-ROW)) DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
             ADD 1 TO WS-COUNT
         END-PERFORM
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-PACK-COUNT
             MOVE 0 TO WS-POSITION
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SD-ENABLED-COUNT
                 IF SD-ENABLED(WS-J) = WS-I
                     MOVE WS-J TO WS-POSITION
                 END-IF
             END-PERFORM
             IF WS-POSITION = 0
                 IF WS-COUNT > 0
                     STRING ", " DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
                 END-IF
                 STRING SD-P-NAME(WS-I)(1:SD-P-LENGTH(WS-I)) DELIMITED BY SIZE INTO WS-NAMES WITH POINTER WS-POINTER
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-IF
     COMPUTE WS-NAMES-LENGTH = WS-POINTER - 1.

*> The list message of the enabled (WS-TARGET 1) or available (2) packs; the number listed is added to WS-LISTED.
 TELL-LIST.
     PERFORM COLLECT-NAMES
     ADD WS-COUNT TO WS-LISTED
     IF WS-TARGET = 1
         MOVE "commands.datapack.list.enabled.none" TO WS-KEY
         IF WS-COUNT > 0
             MOVE "commands.datapack.list.enabled.success" TO WS-KEY
         END-IF
     ELSE
         MOVE "commands.datapack.list.available.none" TO WS-KEY
         IF WS-COUNT > 0
             MOVE "commands.datapack.list.available.success" TO WS-KEY
         END-IF
     END-IF
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     IF WS-COUNT > 0
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAMES WS-NAMES-LENGTH
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET.

 DO-LIST.
     MOVE 0 TO WS-LISTED
     IF WS-AVAILABLE = 0
         MOVE 1 TO WS-TARGET
         PERFORM TELL-LIST
     END-IF
     IF WS-ENABLED = 0
         MOVE 2 TO WS-TARGET
         PERFORM TELL-LIST
     END-IF
     MOVE WS-LISTED TO BR-R-RESULT.

 DO-ENABLE.
     CALL "BX-FIND" USING WS-N-NAME WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-NAME WS-NAME-LENGTH WS-QUOTES
     CALL "SDX-PACK-FIND" USING WS-NAME WS-NAME-LENGTH WS-ROW WS-POSITION
     COMPUTE WS-TARGET = SD-ENABLED-COUNT + 1
     IF WS-ROW > 0 AND WS-POSITION = 0
         CALL "BX-FIND" USING WS-N-EXISTING WS-INDEX
         IF WS-INDEX > 0
             MOVE WS-NAME TO WS-FULL
             MOVE WS-NAME-LENGTH TO WS-FULL-LENGTH
             CALL "SBX-ARG-TEXT" USING WS-INDEX WS-OTHER WS-OTHER-LENGTH WS-QUOTES
             CALL "SDX-PACK-FIND" USING WS-OTHER WS-OTHER-LENGTH WS-ROW-2 WS-POSITION-2
             MOVE WS-FULL TO WS-NAME
             MOVE WS-FULL-LENGTH TO WS-NAME-LENGTH
             MOVE WS-POSITION-2 TO WS-TARGET
             IF WS-AFTER > 0
                 ADD 1 TO WS-TARGET
             END-IF
         END-IF
         IF WS-FIRST > 0
             MOVE 1 TO WS-TARGET
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-ROW = 0
             MOVE "commands.datapack.unknown" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN WS-POSITION > 0
             MOVE "commands.datapack.enable.failed" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN WS-TARGET = 0 OR (WS-BEFORE + WS-AFTER > 0 AND WS-POSITION-2 = 0)
             MOVE "commands.datapack.unknown" TO WS-KEY
             MOVE WS-OTHER TO WS-NAME
             MOVE WS-OTHER-LENGTH TO WS-NAME-LENGTH
             PERFORM FAIL-NAME
         WHEN OTHER
             PERFORM VARYING WS-I FROM SD-ENABLED-COUNT BY -1 UNTIL WS-I < WS-TARGET
                 MOVE SD-ENABLED(WS-I) TO SD-ENABLED(WS-I + 1)
             END-PERFORM
             MOVE WS-ROW TO SD-ENABLED(WS-TARGET)
             ADD 1 TO SD-ENABLED-COUNT
             MOVE "commands.datapack.modify.enable" TO WS-KEY
             PERFORM TELL-NAME
             MOVE SD-ENABLED-COUNT TO BR-R-RESULT
     END-EVALUATE.

 DO-DISABLE.
     CALL "BX-FIND" USING WS-N-NAME WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-NAME WS-NAME-LENGTH WS-QUOTES
     CALL "SDX-PACK-FIND" USING WS-NAME WS-NAME-LENGTH WS-ROW WS-POSITION
     EVALUATE TRUE
         WHEN WS-ROW = 0
             MOVE "commands.datapack.unknown" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN WS-POSITION = 0
             MOVE "commands.datapack.disable.failed" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN OTHER
             PERFORM VARYING WS-I FROM WS-POSITION BY 1 UNTIL WS-I >= SD-ENABLED-COUNT
                 MOVE SD-ENABLED(WS-I + 1) TO SD-ENABLED(WS-I)
             END-PERFORM
             SUBTRACT 1 FROM SD-ENABLED-COUNT
             MOVE "commands.datapack.modify.disable" TO WS-KEY
             PERFORM TELL-NAME
             MOVE SD-ENABLED-COUNT TO BR-R-RESULT
     END-EVALUATE.

 DO-CREATE.
     CALL "BX-FIND" USING WS-N-ID WS-INDEX
     CALL "SBX-ARG-TEXT" USING WS-INDEX WS-NAME WS-NAME-LENGTH WS-QUOTES
     MOVE 1 TO WS-VALID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NAME-LENGTH
         MOVE WS-NAME(WS-I:1) TO WS-CH
         IF NOT ((WS-CH >= "a" AND WS-CH <= "z") OR (WS-CH >= "0" AND WS-CH <= "9") OR WS-CH = "_" OR WS-CH = "-" OR WS-CH = ".")
             MOVE 0 TO WS-VALID
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-FULL
     STRING "file/" DELIMITED BY SIZE WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-FULL
     COMPUTE WS-FULL-LENGTH = FUNCTION MIN(WS-NAME-LENGTH + 5, 64)
     CALL "SDX-PACK-FIND" USING WS-FULL WS-FULL-LENGTH WS-ROW WS-POSITION
     EVALUATE TRUE
         WHEN WS-VALID = 0
             MOVE "commands.datapack.create.invalid_name" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN WS-ROW > 0 OR SD-PACK-COUNT >= SD-MAX-PACKS
             MOVE "commands.datapack.create.already_exists" TO WS-KEY
             PERFORM FAIL-NAME
         WHEN OTHER
             ADD 1 TO SD-PACK-COUNT
             MOVE WS-FULL TO SD-P-NAME(SD-PACK-COUNT)
             MOVE WS-FULL-LENGTH TO SD-P-LENGTH(SD-PACK-COUNT)
             MOVE "commands.datapack.create.success" TO WS-KEY
             PERFORM TELL-NAME
             MOVE 1 TO BR-R-RESULT
     END-EVALUATE.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-N-LIST WS-LIST
     CALL "BX-LIT" USING WS-N-AVAILABLE WS-AVAILABLE
     CALL "BX-LIT" USING WS-N-ENABLED WS-ENABLED
     CALL "BX-LIT" USING WS-N-ENABLE WS-ENABLE
     CALL "BX-LIT" USING WS-N-DISABLE WS-DISABLE
     CALL "BX-LIT" USING WS-N-FIRST WS-FIRST
     CALL "BX-LIT" USING WS-N-BEFORE WS-BEFORE
     CALL "BX-LIT" USING WS-N-AFTER WS-AFTER
     MOVE SPACES TO WS-OTHER
     MOVE 0 TO WS-OTHER-LENGTH WS-POSITION-2
     CALL "SDX-PACK-FIND" USING WS-OTHER WS-OTHER-LENGTH WS-ROW WS-POSITION
     EVALUATE TRUE
         WHEN WS-LIST > 0
             PERFORM DO-LIST
         WHEN WS-ENABLE > 0
             PERFORM DO-ENABLE
         WHEN WS-DISABLE > 0
             PERFORM DO-DISABLE
         WHEN OTHER
             PERFORM DO-CREATE
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-DATAPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DATAPACK.
*> The forms of datapack (16 §10.11); create needs level 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DATAPACK.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-FORMS.
    05 FILLER PIC X(80) VALUE "datapack list".
    05 FILLER PIC X(80) VALUE "datapack list available".
    05 FILLER PIC X(80) VALUE "datapack list enabled".
    05 FILLER PIC X(80) VALUE "datapack enable <name:phrase>".
    05 FILLER PIC X(80) VALUE "datapack enable <name:phrase> first".
    05 FILLER PIC X(80) VALUE "datapack enable <name:phrase> last".
    05 FILLER PIC X(80) VALUE "datapack enable <name:phrase> before <existing:phrase>".
    05 FILLER PIC X(80) VALUE "datapack enable <name:phrase> after <existing:phrase>".
    05 FILLER PIC X(80) VALUE "datapack disable <name:phrase>".
    05 FILLER PIC X(80) VALUE "datapack create@4 <id:phrase> <description:component>".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM              PIC X(80) OCCURS 10 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-FORM(WS-I) TO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-DATAPACK.
