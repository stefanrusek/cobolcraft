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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-HOLDERS.
*> USING target kind, target argument index, source kind, source argument index (BINARY-LONG each): the holders of the /data line in the order the line has them. A holder is
*> the literal entity (kind 1), block (kind 2) or storage (kind 3) and the argument after it; the first is the target, a second one is the source of a modify (0 when none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TK                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 01 L-SK                   BINARY-LONG.
 01 L-SA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TK L-TA L-SK L-SA.
     MOVE 0 TO L-TK L-TA L-SK L-SA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-R-COUNT
         MOVE 0 TO WS-KIND
         IF BA-ARG(WS-I) = 0
             EVALUATE BA-NAME(WS-I)
                 WHEN "entity"
                     MOVE 1 TO WS-KIND
                 WHEN "block"
                     MOVE 2 TO WS-KIND
                 WHEN "storage"
                     MOVE 3 TO WS-KIND
             END-EVALUATE
         END-IF
         IF WS-KIND > 0
             IF L-TK = 0
                 MOVE WS-KIND TO L-TK
                 COMPUTE L-TA = WS-I + 1
             ELSE
                 MOVE WS-KIND TO L-SK
                 COMPUTE L-SA = WS-I + 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DTX-HOLDERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-STORAGE-LOAD.
*> USING kind, holder argument index, root out: the data of a holder as a tree of its own (the caller frees it, or hands it to DTX-STORE). A storage that does not exist is an empty
*> compound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-ID                  PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-ROOT.
     CALL "SDX-ID" USING L-ARG WS-ID WS-LENGTH WS-TAG
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NX-STORAGE-MAX
         IF NX-ST-USED(WS-I) = 1 AND NX-ST-KLEN(WS-I) = WS-LENGTH AND NX-ST-KEY(WS-I) = WS-ID
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         CALL "NBX-CLONE" USING NX-ST-ROOT(WS-FOUND) L-ROOT
     ELSE
         CALL "NBX-NEW" USING WS-T-COMPOUND L-ROOT
     END-IF
     GOBACK.
 END PROGRAM DTX-STORAGE-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-STORAGE-STORE.
*> USING kind, holder argument index, root, stored out (1: the tree is now the holder's data and the caller must not free it; 0: no room for another storage, the caller frees it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-ID                  PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-ROOT L-STORED.
     CALL "SDX-ID" USING L-ARG WS-ID WS-LENGTH WS-TAG
     MOVE 0 TO WS-SLOT WS-FREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NX-STORAGE-MAX
         IF NX-ST-USED(WS-I) = 0 AND WS-FREE = 0
             MOVE WS-I TO WS-FREE
         END-IF
         IF NX-ST-USED(WS-I) = 1 AND NX-ST-KLEN(WS-I) = WS-LENGTH AND NX-ST-KEY(WS-I) = WS-ID
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE 1 TO L-STORED
     EVALUATE TRUE
         WHEN WS-SLOT > 0
             CALL "NBX-FREE" USING NX-ST-ROOT(WS-SLOT)
             MOVE L-ROOT TO NX-ST-ROOT(WS-SLOT)
         WHEN WS-FREE > 0
             MOVE 1 TO NX-ST-USED(WS-FREE)
             MOVE WS-LENGTH TO NX-ST-KLEN(WS-FREE)
             MOVE WS-ID TO NX-ST-KEY(WS-FREE)
             MOVE L-ROOT TO NX-ST-ROOT(WS-FREE)
         WHEN OTHER
             MOVE 0 TO L-STORED
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-STORAGE-STORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-KEY.
*> USING kind, what (PIC X(16): modified, query, get), key out (PIC X(72)): commands.data.<holder>.<what>.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(8).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-WHAT                 PIC X(16).
 01 L-KEY                  PIC X(72).
 PROCEDURE DIVISION USING L-KIND L-WHAT L-KEY.
     EVALUATE L-KIND
         WHEN 1
             MOVE "entity" TO WS-NAME
         WHEN 2
             MOVE "block" TO WS-NAME
         WHEN OTHER
             MOVE "storage" TO WS-NAME
     END-EVALUATE
     MOVE SPACES TO L-KEY
     STRING "commands.data." DELIMITED BY SIZE FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE "." DELIMITED BY SIZE
         FUNCTION TRIM(L-WHAT) DELIMITED BY SIZE INTO L-KEY
     GOBACK.
 END PROGRAM DTX-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-STORAGE-ARGS.
*> USING PB-TEXT, kind, holder argument index: the message arguments that name the holder (storage: its id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-KIND L-ARG.
     CALL "SDX-ID" USING L-ARG WS-ID WS-LENGTH WS-TAG
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-ID WS-LENGTH
     GOBACK.
 END PROGRAM DTX-STORAGE-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-SHOW.
*> USING node, text out (PIC X(1024)), length out: the SNBT of a node (cut to 1024 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRINT               PIC X(4096).
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-TEXT L-LENGTH.
     MOVE SPACES TO WS-PRINT
     MOVE 1 TO WS-POS
     CALL "NBX-PRINT" USING L-NODE WS-PRINT WS-POS
     MOVE WS-PRINT TO L-TEXT
     COMPUTE L-LENGTH = FUNCTION MIN(WS-POS - 1, 1024)
     GOBACK.
 END PROGRAM DTX-SHOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-RAISE-NODE.
*> USING key (PIC X(72)), node: the command fails with that key and the SNBT of the node as its argument.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-A1                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NODE.
     CALL "DTX-SHOW" USING L-NODE WS-TEXT WS-LENGTH
     MOVE WS-TEXT TO WS-A1
     COMPUTE WS-L1 = FUNCTION MIN(WS-LENGTH, 64)
     MOVE SPACES TO WS-A2
     CALL "SBX-RAISE" USING L-KEY WS-N WS-A1 WS-L1 WS-A2 WS-L2
     GOBACK.
 END PROGRAM DTX-RAISE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-RAISE-PATH.
*> USING key (PIC X(72)), argument index of a path: the command fails with that key and the path text as its argument.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A1                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-A2                  PIC X(64).
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG VALUE 1.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     CALL "SBX-ARG-TEXT" USING L-INDEX WS-A1 WS-L1 WS-NO-QUOTES
     MOVE SPACES TO WS-A2
     CALL "SBX-RAISE" USING L-KEY WS-N WS-A1 WS-L1 WS-A2 WS-L2
     GOBACK.
 END PROGRAM DTX-RAISE-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-FINISH.
*> USING kind, holder argument index, root (the edited tree of the target): the tree is stored as the holder's data and the broadcast `modified` message is sent; when the node pool was
*> full on the way, or the storage table is, the command fails with cobolcraft.data.too_large and the tree is freed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72).
 01 WS-WHAT                PIC X(16) VALUE "modified".
 01 WS-STORED              BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-ROOT.
     MOVE 0 TO WS-STORED
     IF NX-FULL = 0
         CALL "DTX-STORE" USING L-KIND L-ARG L-ROOT WS-STORED
     END-IF
     IF WS-STORED > 0
         CALL "DTX-KEY" USING L-KIND WS-WHAT WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "DTX-HOLDER-ARGS" USING PB-TEXT L-KIND L-ARG
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     ELSE
         MOVE "cobolcraft.data.too_large" TO WS-KEY
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
     END-IF
     IF WS-STORED NOT = 1
         CALL "NBX-FREE" USING L-ROOT
     END-IF
     GOBACK.
 END PROGRAM DTX-FINISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-GET.
*> data get <holder> [<path> [<scale>]] (16 §10.1): the data (result 1), or the one value at the path with floor(value x scale) as the result (the size of a list, array or compound, the length of a string).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXPATH.
 COPY NBXRES.
 COPY BRRUN.
 COPY PROTO.
 01 WS-N-PATH              PIC X(32) VALUE "path".
 01 WS-N-SCALE             PIC X(32) VALUE "scale".
 01 WS-ROOT                BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-SI                  BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-WHAT                PIC X(16).
 01 WS-DATA                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH-TEXT           PIC X(64).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NO-QUOTES           BINARY-LONG VALUE 0.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-EDIT                PIC -(9)9.99.
 01 WS-SCALE-TEXT          PIC X(16).
 01 WS-SCALE-LENGTH        BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 0.
 01 WS-KEY-GET             PIC X(72) VALUE "commands.data.get.unknown".
 01 WS-KEY-MULTIPLE        PIC X(72) VALUE "commands.data.get.multiple".
 LINKAGE SECTION.
 01 L-TK                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TK L-TA.
     CALL "DTX-LOAD" USING L-TK L-TA WS-ROOT
     CALL "BX-FIND" USING WS-N-PATH WS-PI
     IF WS-PI = 0
         MOVE "query" TO WS-WHAT
         CALL "DTX-KEY" USING L-TK WS-WHAT WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "DTX-HOLDER-ARGS" USING PB-TEXT L-TK L-TA
         CALL "DTX-SHOW" USING WS-ROOT WS-DATA WS-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DATA WS-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     ELSE
         CALL "NBX-PATH-PARSE" USING BR-R-LINE BA-START(WS-PI) BA-END(WS-PI) NBX-PATH
         CALL "NBX-PATH-GET" USING WS-ROOT NBX-PATH NR-RES
         EVALUATE TRUE
             WHEN NR-COUNT = 0
                 CALL "DTX-RAISE-PATH" USING WS-KEY-GET WS-PI
             WHEN NR-COUNT > 1
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY-MULTIPLE
             WHEN OTHER
                 MOVE NR-NODE(1) TO WS-NODE
                 MOVE 1.0 TO WS-SCALE
                 CALL "BX-FIND" USING WS-N-SCALE WS-SI
                 IF WS-SI > 0
                     MOVE BA-DVAL(WS-SI) TO WS-SCALE
                 END-IF
                 EVALUATE TRUE
                     WHEN NX-TYPE(WS-NODE) <= 4
                         COMPUTE WS-D = NX-INT(WS-NODE) * WS-SCALE
                     WHEN NX-TYPE(WS-NODE) <= 6
                         COMPUTE WS-D = NX-DBL(WS-NODE) * WS-SCALE
                     WHEN NX-TYPE(WS-NODE) = 8
                         MOVE NX-SLEN(WS-NODE) TO WS-D
                     WHEN OTHER
                         MOVE NX-COUNT(WS-NODE) TO WS-D
                 END-EVALUATE
                 COMPUTE BR-R-RESULT = FUNCTION INTEGER(WS-D)
                 COMPUTE WS-EDIT ROUNDED = WS-SCALE
                 MOVE FUNCTION TRIM(WS-EDIT) TO WS-SCALE-TEXT
                 COMPUTE WS-SCALE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
                 MOVE "get" TO WS-WHAT
                 CALL "DTX-KEY" USING L-TK WS-WHAT WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "SBX-ARG-TEXT" USING WS-PI WS-PATH-TEXT WS-PATH-LENGTH WS-NO-QUOTES
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-PATH-TEXT WS-PATH-LENGTH
                 CALL "DTX-HOLDER-ARGS" USING PB-TEXT L-TK L-TA
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-SCALE-TEXT WS-SCALE-LENGTH
                 CALL "CMD-TEXT-INT" USING PB-TEXT BR-R-RESULT
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         END-EVALUATE
         CALL "NBX-PATH-FREE" USING NBX-PATH
     END-IF
     CALL "NBX-FREE" USING WS-ROOT
     GOBACK.
 END PROGRAM DTX-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-MERGE.
*> data merge <holder> <nbt> (16 §10.1): the compound is merged into the holder's data (result 1); no difference is commands.data.merge.failed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY BRRUN.
 01 WS-N-NBT               PIC X(32) VALUE "nbt".
 01 WS-ROOT                BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-NI                  BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "commands.data.merge.failed".
 LINKAGE SECTION.
 01 L-TK                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TK L-TA.
     CALL "DTX-LOAD" USING L-TK L-TA WS-ROOT
     CALL "BX-FIND" USING WS-N-NBT WS-NI
     CALL "NBX-PARSE" USING BR-R-LINE BA-START(WS-NI) BA-END(WS-NI) WS-SOURCE
     CALL "NBX-MERGE" USING WS-ROOT WS-SOURCE WS-CHANGED
     CALL "NBX-FREE" USING WS-SOURCE
     IF WS-CHANGED = 0
         CALL "SBX-RAISE-PLAIN" USING WS-KEY
         CALL "NBX-FREE" USING WS-ROOT
     ELSE
         MOVE 1 TO BR-R-RESULT
         CALL "DTX-FINISH" USING L-TK L-TA WS-ROOT
     END-IF
     GOBACK.
 END PROGRAM DTX-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-REMOVE.
*> data remove <holder> <path> (16 §10.1): the matches are removed (result: how many); none is arguments.nbtpath.nothing_found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXPATH.
 COPY BRRUN.
 01 WS-N-PATH              PIC X(32) VALUE "path".
 01 WS-ROOT                BINARY-LONG.
 01 WS-PI                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "arguments.nbtpath.nothing_found".
 LINKAGE SECTION.
 01 L-TK                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TK L-TA.
     CALL "DTX-LOAD" USING L-TK L-TA WS-ROOT
     CALL "BX-FIND" USING WS-N-PATH WS-PI
     CALL "NBX-PATH-PARSE" USING BR-R-LINE BA-START(WS-PI) BA-END(WS-PI) NBX-PATH
     CALL "NBX-PATH-REMOVE" USING WS-ROOT NBX-PATH WS-COUNT
     CALL "NBX-PATH-FREE" USING NBX-PATH
     IF WS-COUNT = 0
         CALL "DTX-RAISE-PATH" USING WS-KEY WS-PI
         CALL "NBX-FREE" USING WS-ROOT
     ELSE
         MOVE WS-COUNT TO BR-R-RESULT
         CALL "DTX-FINISH" USING L-TK L-TA WS-ROOT
     END-IF
     GOBACK.
 END PROGRAM DTX-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-ENSURE.
*> USING root, NBX-PATH, type (9 list, 10 compound), NR-RES out: the nodes the path matches; when there are none, an empty node of that type is set at the path first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 COPY NBXPATH.
 01 L-TYPE                 BINARY-LONG.
 COPY NBXRES.
 PROCEDURE DIVISION USING L-ROOT NBX-PATH L-TYPE NR-RES.
     CALL "NBX-PATH-GET" USING L-ROOT NBX-PATH NR-RES
     IF NR-COUNT = 0
         CALL "NBX-NEW" USING L-TYPE WS-NODE
         CALL "NBX-PATH-SET" USING L-ROOT NBX-PATH WS-NODE WS-CHANGED
         CALL "NBX-FREE" USING WS-NODE
         CALL "NBX-PATH-GET" USING L-ROOT NBX-PATH NR-RES
     END-IF
     GOBACK.
 END PROGRAM DTX-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-SOURCE.
*> USING source kind, source argument index, vals (a list node): the source of a modify (16 §10.1) as values added to the list: `value` the parsed tag; `from` the matches of the source
*> path (the whole data without a path), each copied; `string` the one string at the path cut by start and end (Java substring rules). A failure raises its exception.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXPATH.
 COPY NBXRES.
 COPY BRRUN.
 01 WS-N-VALUE             PIC X(32) VALUE "value".
 01 WS-N-FROM              PIC X(32) VALUE "from".
 01 WS-N-SPATH             PIC X(32) VALUE "sourcePath".
 01 WS-N-START             PIC X(32) VALUE "start".
 01 WS-N-END               PIC X(32) VALUE "end".
 01 WS-LIT                 BINARY-LONG.
 01 WS-VI                  BINARY-LONG.
 01 WS-SPI                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SROOT               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-KEY-NOTHING         PIC X(72) VALUE "arguments.nbtpath.nothing_found".
 01 WS-KEY-MULTIPLE        PIC X(72) VALUE "commands.data.get.multiple".
 01 WS-KEY-VALUE           PIC X(72) VALUE "commands.data.modify.expected_value".
 01 WS-KEY-SUBSTRING       PIC X(72) VALUE "commands.data.modify.invalid_substring".
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-EDIT                PIC -(9)9.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-SK                   BINARY-LONG.
 01 L-SA                   BINARY-LONG.
 01 L-VALS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SK L-SA L-VALS.
     CALL "BX-LIT" USING WS-N-FROM WS-LIT
     IF WS-LIT = 0 AND L-SK = 0
         CALL "BX-FIND" USING WS-N-VALUE WS-VI
         CALL "NBX-PARSE" USING BR-R-LINE BA-START(WS-VI) BA-END(WS-VI) WS-NODE
         CALL "NBX-ADD" USING L-VALS WS-NODE
     ELSE
         CALL "DTX-LOAD" USING L-SK L-SA WS-SROOT
         CALL "BX-FIND" USING WS-N-SPATH WS-SPI
         IF WS-SPI = 0
             MOVE 1 TO NR-COUNT
             MOVE WS-SROOT TO NR-NODE(1)
         ELSE
             CALL "NBX-PATH-PARSE" USING BR-R-LINE BA-START(WS-SPI) BA-END(WS-SPI) NBX-PATH
             CALL "NBX-PATH-GET" USING WS-SROOT NBX-PATH NR-RES
             CALL "NBX-PATH-FREE" USING NBX-PATH
         END-IF
         MOVE NR-NODE(1) TO WS-NODE
         EVALUATE TRUE
             WHEN NR-COUNT = 0
                 CALL "DTX-RAISE-PATH" USING WS-KEY-NOTHING WS-SPI
             WHEN WS-LIT > 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > NR-COUNT
                     MOVE NR-NODE(WS-I) TO WS-NODE
                     CALL "NBX-CLONE" USING WS-NODE WS-COPY
                     CALL "NBX-ADD" USING L-VALS WS-COPY
                 END-PERFORM
             WHEN NR-COUNT > 1
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY-MULTIPLE
             WHEN NX-TYPE(WS-NODE) NOT = 8
                 CALL "DTX-RAISE-NODE" USING WS-KEY-VALUE WS-NODE
             WHEN OTHER
                 MOVE NX-SLEN(WS-NODE) TO WS-LEN
                 MOVE 0 TO WS-START
                 MOVE WS-LEN TO WS-END
                 CALL "BX-FIND" USING WS-N-START WS-I
                 IF WS-I > 0
                     MOVE BA-IVAL(WS-I) TO WS-START
                 END-IF
                 CALL "BX-FIND" USING WS-N-END WS-I
                 IF WS-I > 0
                     MOVE BA-IVAL(WS-I) TO WS-END
                 END-IF
                 IF WS-START < 0 OR WS-START > WS-LEN OR WS-END < WS-START OR WS-END > WS-LEN
                     MOVE WS-START TO WS-EDIT
                     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
                     COMPUTE WS-L1 = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
                     MOVE WS-END TO WS-EDIT
                     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
                     COMPUTE WS-L2 = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
                     CALL "SBX-RAISE" USING WS-KEY-SUBSTRING WS-N2 WS-A1 WS-L1 WS-A2 WS-L2
                 ELSE
                     CALL "NBX-NEW" USING WS-T-STRING WS-COPY
                     COMPUTE WS-LEN = WS-END - WS-START
                     MOVE NX-STR(WS-NODE) TO WS-TEXT
                     IF WS-LEN > 0
                         MOVE WS-TEXT(WS-START + 1:WS-LEN) TO NX-STR(WS-COPY)
                     END-IF
                     MOVE WS-LEN TO NX-SLEN(WS-COPY)
                     CALL "NBX-ADD" USING L-VALS WS-COPY
                 END-IF
         END-EVALUATE
         CALL "NBX-FREE" USING WS-SROOT
     END-IF
     GOBACK.
 END PROGRAM DTX-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-MODIFY.
*> data modify <holder> <targetPath> (set | merge | append | prepend | insert <index>) <source> (16 §10.1). set replaces the matches (and creates what is missing), merge merges a
*> compound into each match (a missing path becomes an empty compound), append, prepend and insert put each value into each list match (a missing path becomes an empty
*> list). The result is the number of changes; none is commands.data.merge.failed (recalled, not in the docs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY NBXPATH.
 COPY NBXRES.
 COPY BRRUN.
 01 WS-N-TPATH             PIC X(32) VALUE "targetPath".
 01 WS-N-INDEX             PIC X(32) VALUE "index".
 01 WS-N-SET               PIC X(32) VALUE "set".
 01 WS-N-MERGE             PIC X(32) VALUE "merge".
 01 WS-N-APPEND            PIC X(32) VALUE "append".
 01 WS-N-PREPEND           PIC X(32) VALUE "prepend".
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-ROOT                BINARY-LONG.
 01 WS-VALS                BINARY-LONG.
 01 WS-TPI                 BINARY-LONG.
 01 WS-II                  BINARY-LONG.
 01 WS-LIT                 BINARY-LONG.
 01 WS-LIT-2               BINARY-LONG.
 01 WS-LIT-3               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-TN                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-N1                  BINARY-LONG VALUE 1.
 01 WS-KEY-OBJECT          PIC X(72) VALUE "commands.data.modify.expected_object".
 01 WS-KEY-LIST            PIC X(72) VALUE "commands.data.modify.expected_list".
 01 WS-KEY-INDEX           PIC X(72) VALUE "commands.data.modify.invalid_index".
 01 WS-KEY-FAILED          PIC X(72) VALUE "commands.data.merge.failed".
 LINKAGE SECTION.
 01 L-TK                   BINARY-LONG.
 01 L-TA                   BINARY-LONG.
 01 L-SK                   BINARY-LONG.
 01 L-SA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TK L-TA L-SK L-SA.
     CALL "DTX-LOAD" USING L-TK L-TA WS-ROOT
     CALL "NBX-NEW" USING WS-T-LIST WS-VALS
     CALL "DTX-SOURCE" USING L-SK L-SA WS-VALS
     MOVE 0 TO WS-CHANGED
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-N-TPATH WS-TPI
         CALL "NBX-PATH-PARSE" USING BR-R-LINE BA-START(WS-TPI) BA-END(WS-TPI) NBX-PATH
         CALL "BX-LIT" USING WS-N-SET WS-LIT
         CALL "BX-LIT" USING WS-N-MERGE WS-LIT-2
         CALL "BX-LIT" USING WS-N-APPEND WS-LIT-3
         EVALUATE TRUE
             WHEN WS-LIT > 0
                 MOVE NX-FIRST(WS-VALS) TO WS-V
                 PERFORM UNTIL WS-V = 0
                     CALL "NBX-PATH-SET" USING WS-ROOT NBX-PATH WS-V WS-C
                     ADD WS-C TO WS-CHANGED
                     MOVE NX-NEXT(WS-V) TO WS-V
                 END-PERFORM
             WHEN WS-LIT-2 > 0
                 CALL "DTX-ENSURE" USING WS-ROOT NBX-PATH WS-T-COMPOUND NR-RES
                 PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > NR-COUNT OR BR-R-FAILED = 1
                     MOVE NR-NODE(WS-T) TO WS-TN
                     MOVE NX-FIRST(WS-VALS) TO WS-V
                     PERFORM UNTIL WS-V = 0 OR BR-R-FAILED = 1
                         EVALUATE TRUE
                             WHEN NX-TYPE(WS-V) NOT = 10
                                 CALL "DTX-RAISE-NODE" USING WS-KEY-OBJECT WS-V
                             WHEN NX-TYPE(WS-TN) NOT = 10
                                 CALL "DTX-RAISE-NODE" USING WS-KEY-OBJECT WS-TN
                             WHEN OTHER
                                 CALL "NBX-MERGE" USING WS-TN WS-V WS-C
                                 ADD WS-C TO WS-CHANGED
                         END-EVALUATE
                         MOVE NX-NEXT(WS-V) TO WS-V
                     END-PERFORM
                 END-PERFORM
             WHEN OTHER
                 CALL "BX-FIND" USING WS-N-INDEX WS-II
                 CALL "DTX-ENSURE" USING WS-ROOT NBX-PATH WS-T-LIST NR-RES
                 PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > NR-COUNT OR BR-R-FAILED = 1
                     MOVE NR-NODE(WS-T) TO WS-TN
                     IF NX-TYPE(WS-TN) NOT = 9 AND NX-TYPE(WS-TN) NOT = 7 AND NX-TYPE(WS-TN) < 11
                         CALL "DTX-RAISE-NODE" USING WS-KEY-LIST WS-TN
                     END-IF
                     MOVE NX-FIRST(WS-VALS) TO WS-V
                     PERFORM UNTIL WS-V = 0 OR BR-R-FAILED = 1
                         EVALUATE TRUE
                             WHEN WS-LIT-3 > 0
                                 MOVE NX-COUNT(WS-TN) TO WS-POS
                             WHEN WS-II = 0
                                 MOVE 0 TO WS-POS
                             WHEN OTHER
                                 MOVE BA-IVAL(WS-II) TO WS-INDEX
                                 MOVE WS-INDEX TO WS-POS
                                 IF WS-POS < 0
                                     ADD NX-COUNT(WS-TN) TO WS-POS
                                 END-IF
                                 IF WS-POS < 0 OR WS-POS > NX-COUNT(WS-TN)
                                     MOVE WS-INDEX TO WS-EDIT
                                     MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
                                     COMPUTE WS-L1 = FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
                                     MOVE SPACES TO WS-A2
                                     CALL "SBX-RAISE" USING WS-KEY-INDEX WS-N1 WS-A1 WS-L1 WS-A2 WS-L2
                                 END-IF
                         END-EVALUATE
                         IF BR-R-FAILED = 0
                             CALL "NBX-CLONE" USING WS-V WS-COPY
                             CALL "NBX-INSERT" USING WS-TN WS-COPY WS-POS
                             ADD 1 TO WS-CHANGED
                         END-IF
                         MOVE NX-NEXT(WS-V) TO WS-V
                     END-PERFORM
                 END-PERFORM
         END-EVALUATE
         CALL "NBX-PATH-FREE" USING NBX-PATH
     END-IF
     CALL "NBX-FREE" USING WS-VALS
     EVALUATE TRUE
         WHEN BR-R-FAILED = 1
             CALL "NBX-FREE" USING WS-ROOT
         WHEN WS-CHANGED = 0
             CALL "SBX-RAISE-PLAIN" USING WS-KEY-FAILED
             CALL "NBX-FREE" USING WS-ROOT
         WHEN OTHER
             MOVE WS-CHANGED TO BR-R-RESULT
             CALL "DTX-FINISH" USING L-TK L-TA WS-ROOT
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-MODIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DATA.
*> data (16 §10.1, level 2): get, merge, remove and modify over the holders entity, block and storage; the node pool is reset-checked per command (cobolcraft.data.too_large when full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 COPY BRRUN.
 01 WS-N-GET               PIC X(32) VALUE "get".
 01 WS-N-MODIFY            PIC X(32) VALUE "modify".
 01 WS-N-REMOVE            PIC X(32) VALUE "remove".
 01 WS-GET                 BINARY-LONG.
 01 WS-MODIFY              BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-TK                  BINARY-LONG.
 01 WS-TA                  BINARY-LONG.
 01 WS-SK                  BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-WRITE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO NX-FULL
     CALL "DTX-HOLDERS" USING WS-TK WS-TA WS-SK WS-SA
     CALL "BX-LIT" USING WS-N-GET WS-GET
     CALL "BX-LIT" USING WS-N-MODIFY WS-MODIFY
     CALL "BX-LIT" USING WS-N-REMOVE WS-REMOVE
     MOVE 1 TO WS-WRITE
     IF WS-GET > 0
         MOVE 0 TO WS-WRITE
     END-IF
     CALL "DTX-CHECK-ONE" USING WS-TK WS-TA WS-WRITE
     IF WS-SK > 0 AND BR-R-FAILED = 0
         MOVE 0 TO WS-WRITE
         CALL "DTX-CHECK-ONE" USING WS-SK WS-SA WS-WRITE
     END-IF
     EVALUATE TRUE
         WHEN BR-R-FAILED = 1
             MOVE 0 TO WS-WRITE
         WHEN WS-GET > 0
             CALL "DTX-GET" USING WS-TK WS-TA
         WHEN WS-MODIFY > 0
             CALL "DTX-MODIFY" USING WS-TK WS-TA WS-SK WS-SA
         WHEN WS-REMOVE > 0
             CALL "DTX-REMOVE" USING WS-TK WS-TA
         WHEN OTHER
             CALL "DTX-MERGE" USING WS-TK WS-TA
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DATA.
*> The forms of data (16 §10.1): get (path, scale), merge, remove, and modify with set, merge, append, prepend and insert from a value, from a holder (with a path) or a string of a
*> holder (with a path, start and end). The compute source needs the providers of 10.9 and is not registered (BLOCKED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DATA.
 01 WS-PATH                PIC X(256).
 01 WS-POINTER             BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TARGETS.
    05 FILLER PIC X(40) VALUE "entity <target:entity>".
    05 FILLER PIC X(40) VALUE "block <targetPos:pos>".
    05 FILLER PIC X(40) VALUE "storage <target:resloc>".
 01 WS-TARGET-TABLE REDEFINES WS-TARGETS.
    05 WS-TARGET            PIC X(40) OCCURS 3 TIMES.
 01 WS-SOURCES.
    05 FILLER PIC X(40) VALUE "entity <source:entity>".
    05 FILLER PIC X(40) VALUE "block <sourcePos:pos>".
    05 FILLER PIC X(40) VALUE "storage <source:resloc>".
 01 WS-SOURCE-TABLE REDEFINES WS-SOURCES.
    05 WS-SOURCE            PIC X(40) OCCURS 3 TIMES.
 01 WS-OPS.
    05 FILLER PIC X(32) VALUE "set".
    05 FILLER PIC X(32) VALUE "merge".
    05 FILLER PIC X(32) VALUE "append".
    05 FILLER PIC X(32) VALUE "prepend".
    05 FILLER PIC X(32) VALUE "insert <index:int>".
 01 WS-OP-TABLE REDEFINES WS-OPS.
    05 WS-OP                PIC X(32) OCCURS 5 TIMES.
*> source forms: the word, a flag (1: a source holder follows) and the words after the holder
 01 WS-FORMS.
    05 FILLER PIC X(48) VALUE "value <value:nbttag>".
    05 FILLER PIC X(48) VALUE "from".
    05 FILLER PIC X(48) VALUE "from".
    05 FILLER PIC X(48) VALUE "string".
    05 FILLER PIC X(48) VALUE "string".
    05 FILLER PIC X(48) VALUE "string".
    05 FILLER PIC X(48) VALUE "string".
 01 WS-FORM-TABLE REDEFINES WS-FORMS.
    05 WS-FORM              PIC X(48) OCCURS 7 TIMES.
 01 WS-TAILS.
    05 FILLER PIC X(64) VALUE " ".
    05 FILLER PIC X(64) VALUE " ".
    05 FILLER PIC X(64) VALUE "<sourcePath:nbtpath>".
    05 FILLER PIC X(64) VALUE " ".
    05 FILLER PIC X(64) VALUE "<sourcePath:nbtpath>".
    05 FILLER PIC X(64) VALUE "<sourcePath:nbtpath> <start:int>".
    05 FILLER PIC X(64) VALUE "<sourcePath:nbtpath> <start:int> <end:int>".
 01 WS-TAIL-TABLE REDEFINES WS-TAILS.
    05 WS-TAIL              PIC X(64) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 3
         MOVE SPACES TO WS-PATH
         STRING "data get " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  " INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "data get " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  " " <path:nbtpath>" DELIMITED BY SIZE
             INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "data get " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  " " <path:nbtpath> <scale:double>"
             DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "data merge " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  " " <nbt:nbt>" DELIMITED BY SIZE
             INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         MOVE SPACES TO WS-PATH
         STRING "data remove " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  " " <path:nbtpath>" DELIMITED BY SIZE
             INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         PERFORM VARYING WS-O FROM 1 BY 1 UNTIL WS-O > 5
             PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 7
                 IF WS-F = 1
                     MOVE 1 TO WS-LAST
                 ELSE
                     MOVE 3 TO WS-LAST
                 END-IF
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-LAST
                     MOVE SPACES TO WS-PATH
                     MOVE 1 TO WS-POINTER
                     STRING "data modify " DELIMITED BY SIZE WS-TARGET(WS-H) DELIMITED BY "  "
                         " <targetPath:nbtpath> " DELIMITED BY SIZE WS-OP(WS-O) DELIMITED BY "  " " " DELIMITED BY SIZE
                         WS-FORM(WS-F) DELIMITED BY "  " INTO WS-PATH WITH POINTER WS-POINTER
                     IF WS-F > 1
                         STRING " " DELIMITED BY SIZE WS-SOURCE(WS-S) DELIMITED BY "  " INTO WS-PATH WITH POINTER WS-POINTER
                         IF WS-TAIL(WS-F) NOT = SPACES
                             STRING " " DELIMITED BY SIZE WS-TAIL(WS-F) DELIMITED BY "  " INTO WS-PATH
                                 WITH POINTER WS-POINTER
                         END-IF
                     END-IF
                     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-BLOCK-POS.
*> USING block position argument index, x, y, z (BINARY-LONG): the block the argument names in the world of the source (the floor of the coordinates).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ARG                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ARG L-X L-Y L-Z.
     CALL "BX-POSITION" USING L-ARG WS-X WS-Y WS-Z
     COMPUTE L-X = FUNCTION INTEGER(WS-X)
     COMPUTE L-Y = FUNCTION INTEGER(WS-Y)
     COMPUTE L-Z = FUNCTION INTEGER(WS-Z)
     GOBACK.
 END PROGRAM DTX-BLOCK-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-BLOCK-INDEX.
*> USING block position argument index, block entity index out (0 when the block has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY BRRUN.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ARG                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ARG L-INDEX.
     CALL "DTX-BLOCK-POS" USING L-ARG WS-X WS-Y WS-Z
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = BS-DIM AND BE-X(WS-I) = WS-X AND BE-Y(WS-I) = WS-Y AND BE-Z(WS-I) = WS-Z
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DTX-BLOCK-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-BLOCK-TREE.
*> USING block entity index, root out: the save form of the block entity (31-1 2.2, with its id and position) read into a tree.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-FORM                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROOT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING L-INDEX WS-FORM PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBX-FROM-BUFFER" USING PB-BUFFER L-ROOT
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM DTX-BLOCK-TREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-BLOCK-WRITE.
*> USING block entity index, root: the tree is written as NBT and loaded into the block entity (BE-LOAD skips the id and position keys), which is marked changed (BE-SET-CHANGED
*> sends nothing to the clients).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-NEIGHBOURS          BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ROOT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBX-TO-BUFFER" USING PB-BUFFER L-ROOT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING L-INDEX PB-BUFFER
     CALL "BE-SET-CHANGED" USING L-INDEX WS-AIR WS-NEIGHBOURS
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM DTX-BLOCK-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-ENTITY-TREE.
*> USING code (a player row, or the negated row of CORE-ENTITIES), root out: the data of an entity built from its live state, after the saved form of 07 §9.3 and 45 §3.5: id, UUID,
*> Pos, Motion, Rotation, OnGround; a mob adds Health, a ground item Item {id, count}, Age and PickupDelay, a player Health, foodLevel, playerGameType, SelectedItemSlot and
*> Inventory ({Slot, id, count} of each stack). The id of a player is the type key of its entity row (not minecraft:player: gap).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY MOBS.
 COPY NBXTREE.
 01 WS-K-ID                PIC X(16) VALUE "id".
 01 WS-K-UUID              PIC X(16) VALUE "UUID".
 01 WS-K-POS               PIC X(16) VALUE "Pos".
 01 WS-K-MOTION            PIC X(16) VALUE "Motion".
 01 WS-K-ROTATION          PIC X(16) VALUE "Rotation".
 01 WS-K-ON-GROUND         PIC X(16) VALUE "OnGround".
 01 WS-K-HEALTH            PIC X(16) VALUE "Health".
 01 WS-K-ITEM              PIC X(16) VALUE "Item".
 01 WS-K-COUNT             PIC X(16) VALUE "count".
 01 WS-K-AGE               PIC X(16) VALUE "Age".
 01 WS-K-DELAY             PIC X(16) VALUE "PickupDelay".
 01 WS-K-FOOD              PIC X(16) VALUE "foodLevel".
 01 WS-K-MODE              PIC X(16) VALUE "playerGameType".
 01 WS-K-SELECTED          PIC X(16) VALUE "SelectedItemSlot".
 01 WS-K-INVENTORY         PIC X(16) VALUE "Inventory".
 01 WS-K-SLOT              PIC X(16) VALUE "Slot".
 01 WS-T-BYTE              BINARY-LONG VALUE 1.
 01 WS-T-SHORT             BINARY-LONG VALUE 2.
 01 WS-T-INT               BINARY-LONG VALUE 3.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-N2                  BINARY-LONG VALUE 2.
 01 WS-N3                  BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-GROUND              BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-IT                  BINARY-LONG.
 01 WS-ZERO-D              FLOAT-LONG VALUE 0.
 01 WS-UUID                PIC X(16).
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-ROOT.
     MOVE 0 TO WS-PLAYER
     MOVE 0 TO WS-VX WS-VY WS-VZ
     EVALUATE TRUE
         WHEN L-CODE > 0
             MOVE L-CODE TO WS-PLAYER
             MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-ROW
             MOVE PL-X(WS-PLAYER) TO WS-X
             MOVE PL-Y(WS-PLAYER) TO WS-Y
             MOVE PL-Z(WS-PLAYER) TO WS-Z
             MOVE PL-YAW(WS-PLAYER) TO WS-YAW
             MOVE PL-PITCH(WS-PLAYER) TO WS-PITCH
             MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
             MOVE PL-ON-GROUND(WS-PLAYER) TO WS-GROUND
             MOVE PL-UUID(WS-PLAYER) TO WS-UUID
         WHEN OTHER
             COMPUTE WS-ROW = 0 - L-CODE
             MOVE EN-X(WS-ROW) TO WS-X
             MOVE EN-Y(WS-ROW) TO WS-Y
             MOVE EN-Z(WS-ROW) TO WS-Z
             MOVE EN-YAW(WS-ROW) TO WS-YAW
             MOVE EN-PITCH(WS-ROW) TO WS-PITCH
             MOVE EN-VX(WS-ROW) TO WS-VX
             MOVE EN-VY(WS-ROW) TO WS-VY
             MOVE EN-VZ(WS-ROW) TO WS-VZ
             MOVE EN-HEALTH(WS-ROW) TO WS-HEALTH
             MOVE EN-ON-GROUND(WS-ROW) TO WS-GROUND
             MOVE EN-UUID(WS-ROW) TO WS-UUID
     END-EVALUATE
     CALL "NBX-NEW" USING WS-T-COMPOUND L-ROOT
     COMPUTE WS-I = EN-TYPE(WS-ROW) + 1
     MOVE SPACES TO WS-TEXT
     MOVE ET-KEY(WS-I) TO WS-TEXT
     MOVE ET-KEY-LENGTH(WS-I) TO WS-LENGTH
     CALL "NBX-PUT-STR-N" USING L-ROOT WS-K-ID WS-TEXT WS-LENGTH
     CALL "NBX-UUID-BYTES" USING WS-UUID WS-NODE
     CALL "NBX-SET-N" USING L-ROOT WS-K-UUID WS-NODE
     CALL "NBX-PUT-NUMS" USING L-ROOT WS-K-POS WS-T-DOUBLE WS-N3 WS-X WS-Y WS-Z
     CALL "NBX-PUT-NUMS" USING L-ROOT WS-K-MOTION WS-T-DOUBLE WS-N3 WS-VX WS-VY WS-VZ
     CALL "NBX-PUT-NUMS" USING L-ROOT WS-K-ROTATION WS-T-FLOAT WS-N2 WS-YAW WS-PITCH WS-ZERO-D
     CALL "NBX-PUT-N" USING L-ROOT WS-K-ON-GROUND WS-T-BYTE WS-GROUND WS-ZERO-D WS-NODE
     IF WS-PLAYER > 0
         CALL "NBX-PUT-N" USING L-ROOT WS-K-HEALTH WS-T-FLOAT WS-INT WS-HEALTH WS-NODE
         MOVE PL-FOOD(WS-PLAYER) TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-FOOD WS-T-INT WS-INT WS-ZERO-D WS-NODE
         MOVE PL-MODE(WS-PLAYER) TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-MODE WS-T-INT WS-INT WS-ZERO-D WS-NODE
         MOVE PL-HELD(WS-PLAYER) TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-SELECTED WS-T-INT WS-INT WS-ZERO-D WS-NODE
         MOVE 0 TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-INVENTORY WS-T-LIST WS-INT WS-ZERO-D WS-LIST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
             IF PL-SLOT-COUNT(WS-PLAYER, WS-I) > 0
                 CALL "NBX-NEW" USING WS-T-COMPOUND WS-STACK
                 CALL "NBX-ADD" USING WS-LIST WS-STACK
                 COMPUTE WS-INT = WS-I - 1
                 CALL "NBX-PUT-N" USING WS-STACK WS-K-SLOT WS-T-BYTE WS-INT WS-ZERO-D WS-NODE
                 COMPUTE WS-IT = PL-SLOT-ITEM(WS-PLAYER, WS-I) + 1
                 MOVE SPACES TO WS-TEXT
                 MOVE IT-KEY(WS-IT) TO WS-TEXT
                 MOVE IT-KEY-LENGTH(WS-IT) TO WS-LENGTH
                 CALL "NBX-PUT-STR-N" USING WS-STACK WS-K-ID WS-TEXT WS-LENGTH
                 MOVE PL-SLOT-COUNT(WS-PLAYER, WS-I) TO WS-INT
                 CALL "NBX-PUT-N" USING WS-STACK WS-K-COUNT WS-T-INT WS-INT WS-ZERO-D WS-NODE
             END-IF
         END-PERFORM
     END-IF
     IF WS-PLAYER = 0 AND EN-TYPE(WS-ROW) >= MOB-FIRST-TYPE
         CALL "NBX-PUT-N" USING L-ROOT WS-K-HEALTH WS-T-FLOAT WS-INT WS-HEALTH WS-NODE
     END-IF
     IF WS-PLAYER = 0 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
         MOVE 0 TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-ITEM WS-T-COMPOUND WS-INT WS-ZERO-D WS-STACK
         COMPUTE WS-IT = EN-ITEM(WS-ROW) + 1
         MOVE SPACES TO WS-TEXT
         MOVE IT-KEY(WS-IT) TO WS-TEXT
         MOVE IT-KEY-LENGTH(WS-IT) TO WS-LENGTH
         CALL "NBX-PUT-STR-N" USING WS-STACK WS-K-ID WS-TEXT WS-LENGTH
         MOVE EN-ITEM-COUNT(WS-ROW) TO WS-INT
         CALL "NBX-PUT-N" USING WS-STACK WS-K-COUNT WS-T-INT WS-INT WS-ZERO-D WS-NODE
         MOVE EN-AGE(WS-ROW) TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-AGE WS-T-INT WS-INT WS-ZERO-D WS-NODE
         MOVE EN-DELAY(WS-ROW) TO WS-INT
         CALL "NBX-PUT-N" USING L-ROOT WS-K-DELAY WS-T-SHORT WS-INT WS-ZERO-D WS-NODE
     END-IF
     GOBACK.
 END PROGRAM DTX-ENTITY-TREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-ENTITY-WRITE.
*> USING entity row (CORE-ENTITIES), root: the values of an edited tree go back to a mob or ground item: Health, Age, PickupDelay, Item.count, Motion, and Pos and Rotation
*> (the entity is moved: ENTITY-MOVE sends the change to its viewers). Other keys, among them id and UUID, are ignored (gap: no entity can change its type).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY NBXTREE.
 01 WS-K-POS               PIC X(16) VALUE "Pos".
 01 WS-K-MOTION            PIC X(16) VALUE "Motion".
 01 WS-K-ROTATION          PIC X(16) VALUE "Rotation".
 01 WS-K-HEALTH            PIC X(16) VALUE "Health".
 01 WS-K-ITEM              PIC X(16) VALUE "Item".
 01 WS-K-COUNT             PIC X(16) VALUE "count".
 01 WS-K-AGE               PIC X(16) VALUE "Age".
 01 WS-K-DELAY             PIC X(16) VALUE "PickupDelay".
 01 WS-LIST                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-YAW-S               FLOAT-SHORT.
 01 WS-PITCH-S             FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ROOT.
     CALL "NBX-GET-NUM-N" USING L-ROOT WS-K-HEALTH WS-VALUE WS-FOUND
     IF WS-FOUND = 1
         COMPUTE EN-HEALTH(L-ROW) ROUNDED = WS-VALUE
     END-IF
     CALL "NBX-GET-NUM-N" USING L-ROOT WS-K-AGE WS-VALUE WS-FOUND
     IF WS-FOUND = 1
         COMPUTE EN-AGE(L-ROW) ROUNDED = WS-VALUE
     END-IF
     CALL "NBX-GET-NUM-N" USING L-ROOT WS-K-DELAY WS-VALUE WS-FOUND
     IF WS-FOUND = 1
         COMPUTE EN-DELAY(L-ROW) ROUNDED = WS-VALUE
     END-IF
     CALL "NBX-FIND-N" USING L-ROOT WS-K-ITEM WS-ITEM
     IF WS-ITEM > 0
         CALL "NBX-GET-NUM-N" USING WS-ITEM WS-K-COUNT WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             COMPUTE EN-ITEM-COUNT(L-ROW) ROUNDED = WS-VALUE
         END-IF
     END-IF
     CALL "NBX-FIND-N" USING L-ROOT WS-K-MOTION WS-LIST
     IF WS-LIST > 0
         CALL "NBX-GET-ELEM" USING WS-LIST WS-ONE WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-VALUE TO EN-VX(L-ROW)
         END-IF
         CALL "NBX-GET-ELEM" USING WS-LIST WS-TWO WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-VALUE TO EN-VY(L-ROW)
         END-IF
         CALL "NBX-GET-ELEM" USING WS-LIST WS-THREE WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-VALUE TO EN-VZ(L-ROW)
         END-IF
     END-IF
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     CALL "NBX-FIND-N" USING L-ROOT WS-K-POS WS-LIST
     IF WS-LIST > 0
         CALL "NBX-GET-ELEM" USING WS-LIST WS-ONE WS-X WS-FOUND
         CALL "NBX-GET-ELEM" USING WS-LIST WS-TWO WS-Y WS-FOUND
         CALL "NBX-GET-ELEM" USING WS-LIST WS-THREE WS-Z WS-FOUND
     END-IF
     CALL "NBX-FIND-N" USING L-ROOT WS-K-ROTATION WS-LIST
     IF WS-LIST > 0
         CALL "NBX-GET-ELEM" USING WS-LIST WS-ONE WS-YAW WS-FOUND
         CALL "NBX-GET-ELEM" USING WS-LIST WS-TWO WS-PITCH WS-FOUND
     END-IF
     MOVE WS-YAW TO WS-YAW-S
     MOVE WS-PITCH TO WS-PITCH-S
     IF WS-X NOT = EN-X(L-ROW) OR WS-Y NOT = EN-Y(L-ROW) OR WS-Z NOT = EN-Z(L-ROW)
             OR WS-YAW-S NOT = EN-YAW(L-ROW) OR WS-PITCH-S NOT = EN-PITCH(L-ROW)
         CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW-S WS-PITCH-S EN-ON-GROUND(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM DTX-ENTITY-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-ENTITY-ARGS.
*> USING PB-TEXT, entity argument index: the message argument that names the entity: a player's name, else the type key of the entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-ARG.
     CALL "BX-RESOLVE" USING L-ARG WS-ROWS
     MOVE WS-ROW(1) TO WS-CODE
     MOVE SPACES TO WS-TEXT
     IF WS-CODE > 0
         MOVE PL-NAME(WS-CODE) TO WS-TEXT
         MOVE PL-NAME-LENGTH(WS-CODE) TO WS-LENGTH
     ELSE
         COMPUTE WS-I = EN-TYPE(0 - WS-CODE) + 1
         MOVE ET-KEY(WS-I) TO WS-TEXT
         MOVE ET-KEY-LENGTH(WS-I) TO WS-LENGTH
     END-IF
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     GOBACK.
 END PROGRAM DTX-ENTITY-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-HOLDER-ARGS.
*> USING PB-TEXT, kind, holder argument index: the message arguments that name the holder (entity: its name, block: x, y, z, storage: its id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-KIND L-ARG.
     EVALUATE L-KIND
         WHEN 1
             CALL "DTX-ENTITY-ARGS" USING PB-TEXT L-ARG
         WHEN 2
             CALL "DTX-BLOCK-POS" USING L-ARG WS-X WS-Y WS-Z
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-X
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-Y
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-Z
         WHEN OTHER
             CALL "DTX-STORAGE-ARGS" USING PB-TEXT L-KIND L-ARG
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-HOLDER-ARGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-LOAD.
*> USING kind, holder argument index, root out: the data of a holder as a tree of its own (the caller frees it, or hands it to DTX-STORE). DTX-CHECK has made sure the holder exists.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-ROOT.
     EVALUATE L-KIND
         WHEN 1
             CALL "BX-RESOLVE" USING L-ARG WS-ROWS
             CALL "DTX-ENTITY-TREE" USING WS-ROW(1) L-ROOT
         WHEN 2
             CALL "DTX-BLOCK-INDEX" USING L-ARG WS-INDEX
             CALL "DTX-BLOCK-TREE" USING WS-INDEX L-ROOT
         WHEN OTHER
             CALL "DTX-STORAGE-LOAD" USING L-KIND L-ARG L-ROOT
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-STORE.
*> USING kind, holder argument index, root, stored out (1: the tree is now a storage and the caller must not free it; 2: it went into the entity or block entity and the caller
*> frees it; 0: no room for another storage).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-ROOT L-STORED.
     EVALUATE L-KIND
         WHEN 1
             CALL "BX-RESOLVE" USING L-ARG WS-ROWS
             COMPUTE WS-ENTITY = 0 - WS-ROW(1)
             CALL "DTX-ENTITY-WRITE" USING WS-ENTITY L-ROOT
             MOVE 2 TO L-STORED
         WHEN 2
             CALL "DTX-BLOCK-INDEX" USING L-ARG WS-INDEX
             CALL "DTX-BLOCK-WRITE" USING WS-INDEX L-ROOT
             MOVE 2 TO L-STORED
         WHEN OTHER
             CALL "DTX-STORAGE-STORE" USING L-KIND L-ARG L-ROOT L-STORED
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-STORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DTX-CHECK-ONE.
*> USING kind, holder argument index, write (1 when the command changes the holder): an entity selector must select one entity (the selector raises its own failure), a changed entity must not
*> be a player (commands.data.entity.invalid) and a block must have a block entity (commands.data.block.invalid).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-ROWS.
    05 WS-COUNT             BINARY-LONG.
    05 WS-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY-PLAYER          PIC X(72) VALUE "commands.data.entity.invalid".
 01 WS-KEY-BLOCK           PIC X(72) VALUE "commands.data.block.invalid".
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ARG L-WRITE.
     EVALUATE L-KIND
         WHEN 1
             CALL "BX-RESOLVE" USING L-ARG WS-ROWS
             IF BR-R-FAILED = 0 AND L-WRITE = 1 AND WS-ROW(1) > 0
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY-PLAYER
             END-IF
         WHEN 2
             CALL "DTX-BLOCK-INDEX" USING L-ARG WS-INDEX
             IF WS-INDEX = 0
                 CALL "SBX-RAISE-PLAIN" USING WS-KEY-BLOCK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM DTX-CHECK-ONE.
