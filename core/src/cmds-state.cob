*> The commands of the player and game state (docs/protocol/16-commands-catalog.md §4): gamemode, and (added with their tests)
*> time, weather, difficulty, gamerule, seed, version, setworldspawn, spawnpoint, defaultgamemode. A CX- program reads its parsed
*> context through the BX- helpers, tells through BR-FEEDBACK, sets BR-R-RESULT and, to fail, raises an exception (BR-RAISE) and
*> sets BR-R-FAILED (core/src/cmds-chat.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-GAMEMODE.
*> gamemode <gamemode> [<targets>] (16 §4.1, level 2): each target that is not in the mode already changes to it: Game Event 3
*> with the mode, Player Abilities and, in survival and adventure, Set Health; the source is told success.self or success.other
*> (broadcast) and a target that is not the source gameMode.changed (when send_command_feedback is true); the result is the
*> number of players that changed. The mode name argument is the English text of gameMode.<name>.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-MODE           PIC X(32) VALUE "gamemode".
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-MODE-PIC            PIC 9.
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-MODE-NAME           PIC X(16).
 01 WS-MODE-NAME-LENGTH    BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-FEEDBACK-RULE       PIC X(40) VALUE "send_command_feedback".
 01 WS-FEEDBACK            BINARY-DOUBLE.
 01 WS-CHANGED             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-MODE WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO WS-MODE
     MOVE WS-MODE TO WS-MODE-PIC
     EVALUATE WS-MODE
         WHEN 0
             MOVE "Survival Mode" TO WS-MODE-NAME
         WHEN 1
             MOVE "Creative Mode" TO WS-MODE-NAME
         WHEN 2
             MOVE "Adventure Mode" TO WS-MODE-NAME
         WHEN OTHER
             MOVE "Spectator Mode" TO WS-MODE-NAME
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-MODE-NAME TRAILING)) TO WS-MODE-NAME-LENGTH
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-TARGETS WS-ROWS
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT OR BR-R-FAILED = 1
         MOVE BX-ROW(WS-I) TO WS-ROW
         IF PL-MODE(WS-ROW) NOT = WS-MODE
             ADD 1 TO WS-CHANGED
             MOVE WS-MODE TO PL-MODE(WS-ROW)
             MOVE 0 TO PL-FLYING(WS-ROW)
             IF WS-MODE = 3
                 MOVE 1 TO PL-FLYING(WS-ROW)
             END-IF
             MOVE WS-MODE TO WS-VALUE
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PLAY-ABILITIES-BUILD" USING WS-MODE-PIC PL-FLYING(WS-ROW) PB-BUFFER
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             IF WS-MODE = 0 OR WS-MODE = 2
                 CALL "HEALTH-SEND" USING WS-ROW
             END-IF
             IF WS-ROW = BS-ROW
                 MOVE "commands.gamemode.success.self" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-MODE-NAME WS-MODE-NAME-LENGTH
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             ELSE
                 MOVE "commands.gamemode.success.other" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW)
                 CALL "CMD-TEXT-ARG" USING PB-TEXT WS-MODE-NAME WS-MODE-NAME-LENGTH
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
                 CALL "BR-RULE-GET" USING WS-FEEDBACK-RULE WS-FEEDBACK
                 IF WS-FEEDBACK = 1
                     MOVE "gameMode.changed" TO WS-KEY
                     CALL "BX-KEY" USING PB-TEXT WS-KEY
                     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-MODE-NAME WS-MODE-NAME-LENGTH
                     CALL "BR-TELL" USING WS-ROW PB-TEXT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF BR-R-FAILED = 0
         MOVE WS-CHANGED TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-GAMEMODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-GAMEMODE.
*> The forms of gamemode (16 §4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-GAMEMODE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "gamemode <gamemode:gamemode>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "gamemode <gamemode:gamemode> <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-GAMEMODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-TIME.
*> time (16 §4.5, level 2) on the one clock of the world, cobolcraft:daylight (minecraft:overworld in a world of the standard
*> set): query gametime | time | timeline <day or villager_schedule>, set <time>, set <marker> (day 1000, noon 6000, night 13000,
*> midnight 18000: the next time after now), add <time>, pause, resume, rate <rate>. The clock is the time of day: a set or add
*> wraps to the day and the ticks the messages show are those of the day (total ticks, `time of <clock>`, the timelines moon and
*> early_game and `repetition` are BLOCKED). A change sends Set Time to every player; the changes are broadcast, the queries not.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-CLOCK               PIC X(24).
 01 WS-CLOCK-LENGTH        BINARY-LONG.
 01 WS-LAST                PIC X(32).
 01 WS-ARG                 PIC X(32).
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-EDIT                PIC -(18)9.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-STRIP               PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-MARKER              PIC X(48).
 01 WS-MARKER-LENGTH       BINARY-LONG.
 01 WS-MARKER-TICKS        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PAUSED              BINARY-LONG.
 01 WS-RATE                FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-INT-ZERO            BINARY-DOUBLE VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-DAY                 BINARY-LONG VALUE 24000.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The clock id and the last literal and argument names of the form.
 DESCRIBE.
     MOVE "cobolcraft:daylight" TO WS-CLOCK
     MOVE 19 TO WS-CLOCK-LENGTH
     IF CW-WORLD-TYPE = "standard" OR CW-WORLD-TYPE = "debug"
         MOVE "minecraft:overworld" TO WS-CLOCK
     END-IF
     MOVE SPACES TO WS-ARG
     MOVE BA-NAME(BR-R-COUNT) TO WS-LAST
     IF BA-ARG(BR-R-COUNT) = 1
         MOVE BA-NAME(BR-R-COUNT) TO WS-ARG
         MOVE BA-NAME(BR-R-COUNT - 1) TO WS-LAST
     END-IF.

*> WS-VALUE as decimal text in WS-NUMBER.
 NUM-TEXT.
     MOVE WS-VALUE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-NUMBER
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-NUMBER-LENGTH.

*> The failure WS-KEY with the clock as its first argument and, when WS-L2 > 0, WS-A2 as its second.
 FAIL-CLOCK.
     MOVE 1 TO WS-N-ARGS
     MOVE SPACES TO WS-A1
     MOVE WS-CLOCK TO WS-A1
     MOVE WS-CLOCK-LENGTH TO WS-L1
     IF WS-L2 > 0
         MOVE 2 TO WS-N-ARGS
     END-IF
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The text WS-KEY with the clock and, when WS-L2 > 0, WS-A2 as its arguments.
 TELL-CLOCK.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CLOCK WS-CLOCK-LENGTH
     IF WS-L2 > 0
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-A2 WS-L2
     END-IF.

*> WS-NAME: the text of the last argument without a leading minecraft:.
 FIND-NAME.
     COMPUTE WS-NAME-LENGTH = BA-END(BR-R-COUNT) - BA-START(BR-R-COUNT)
     MOVE SPACES TO WS-NAME
     MOVE BR-R-LINE(BA-START(BR-R-COUNT) + 1:WS-NAME-LENGTH) TO WS-NAME
     IF WS-NAME-LENGTH > 10 AND WS-NAME(1:10) = "minecraft:"
         COMPUTE WS-NAME-LENGTH = WS-NAME-LENGTH - 10
         MOVE WS-NAME(11:WS-NAME-LENGTH) TO WS-STRIP
         MOVE WS-STRIP TO WS-NAME
     END-IF
     MOVE SPACES TO WS-MARKER
     STRING "minecraft:" WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-MARKER
     COMPUTE WS-MARKER-LENGTH = WS-NAME-LENGTH + 10.

*> The marker WS-NAME: its tick of the day in WS-MARKER-TICKS (WS-FOUND 0 for an unknown marker).
 FIND-MARKER.
     PERFORM FIND-NAME
     MOVE 0 TO WS-FOUND
     EVALUATE WS-NAME(1:WS-NAME-LENGTH)
         WHEN "day"
             MOVE 1000 TO WS-MARKER-TICKS
             MOVE 1 TO WS-FOUND
         WHEN "noon"
             MOVE 6000 TO WS-MARKER-TICKS
             MOVE 1 TO WS-FOUND
         WHEN "night"
             MOVE 13000 TO WS-MARKER-TICKS
             MOVE 1 TO WS-FOUND
         WHEN "midnight"
             MOVE 18000 TO WS-MARKER-TICKS
             MOVE 1 TO WS-FOUND
     END-EVALUATE.

*> A failure with the two arguments WS-MARKER and the clock (no marker found, wrong timeline).
 FAIL-MARKER.
     MOVE SPACES TO WS-A1 WS-A2
     MOVE WS-MARKER TO WS-A1
     MOVE WS-MARKER-LENGTH TO WS-L1
     MOVE WS-CLOCK TO WS-A2
     MOVE WS-CLOCK-LENGTH TO WS-L2
     MOVE 2 TO WS-N-ARGS
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> The time of day has changed: Set Time to every player and set.absolute with the ticks WS-VALUE.
 SET-DONE.
     CALL "BR-SEND-TIME"
     PERFORM NUM-TEXT
     MOVE "commands.time.set.absolute" TO WS-KEY
     MOVE WS-NUMBER-LENGTH TO WS-L2
     MOVE WS-NUMBER TO WS-A2
     PERFORM TELL-CLOCK
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST.

 QUERY-GAMETIME.
     COMPUTE WS-VALUE = FUNCTION MOD(CW-TICKS, 2147483647)
     PERFORM NUM-TEXT
     MOVE "commands.time.query.gametime" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE WS-VALUE TO BR-R-RESULT.

 QUERY-TIME.
     MOVE CW-TIME TO WS-VALUE
     PERFORM NUM-TEXT
     MOVE "commands.time.query.absolute" TO WS-KEY
     MOVE WS-NUMBER-LENGTH TO WS-L2
     MOVE WS-NUMBER TO WS-A2
     PERFORM TELL-CLOCK
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     MOVE WS-VALUE TO BR-R-RESULT.

 QUERY-TIMELINE.
     PERFORM FIND-NAME
     IF WS-NAME(1:WS-NAME-LENGTH) = "day" OR WS-NAME(1:WS-NAME-LENGTH) = "villager_schedule"
         MOVE CW-TIME TO WS-VALUE
         PERFORM NUM-TEXT
         MOVE "commands.time.query.timeline" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-MARKER WS-MARKER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE WS-VALUE TO BR-R-RESULT
     ELSE
         MOVE "commands.time.wrong_timeline_for_clock" TO WS-KEY
         PERFORM FAIL-MARKER
     END-IF.

 SET-TICKS.
     MOVE BA-IVAL(BR-R-COUNT) TO WS-VALUE
     PERFORM NUM-TEXT
     IF FUNCTION MOD(WS-VALUE, WS-DAY) = CW-TIME
         MOVE "commands.time.set.already_at_time" TO WS-KEY
         MOVE WS-NUMBER-LENGTH TO WS-L2
         MOVE WS-NUMBER TO WS-A2
         PERFORM FAIL-CLOCK
     ELSE
         COMPUTE CW-TIME = FUNCTION MOD(WS-VALUE, WS-DAY)
         PERFORM SET-DONE
         MOVE WS-VALUE TO BR-R-RESULT
     END-IF.

 SET-MARKER.
     PERFORM FIND-MARKER
     EVALUATE TRUE
         WHEN WS-FOUND = 0
             MOVE "commands.time.no_time_marker_found" TO WS-KEY
             PERFORM FAIL-MARKER
         WHEN WS-MARKER-TICKS = CW-TIME
             MOVE "commands.time.set.already_at_time_marker" TO WS-KEY
             MOVE WS-MARKER TO WS-A2
             MOVE WS-MARKER-LENGTH TO WS-L2
             PERFORM FAIL-CLOCK
         WHEN OTHER
             MOVE WS-MARKER-TICKS TO CW-TIME
             CALL "BR-SEND-TIME"
             MOVE "commands.time.set.time_marker" TO WS-KEY
             MOVE WS-MARKER TO WS-A2
             MOVE WS-MARKER-LENGTH TO WS-L2
             PERFORM TELL-CLOCK
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE CW-TIME TO BR-R-RESULT
     END-EVALUATE.

 ADD-TICKS.
     COMPUTE CW-TIME = FUNCTION MOD(CW-TIME + BA-IVAL(BR-R-COUNT), WS-DAY)
     MOVE CW-TIME TO WS-VALUE
     PERFORM SET-DONE
     MOVE CW-TIME TO BR-R-RESULT.

 PAUSE-CLOCK.
     IF WS-PAUSED = 1
         MOVE "commands.time.pause.already_paused" TO WS-KEY
         PERFORM FAIL-CLOCK
     ELSE
         CALL "BR-CLOCK-SET" USING WS-ONE WS-RATE
         MOVE "commands.time.pause" TO WS-KEY
         PERFORM TELL-CLOCK
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF.

 RESUME-CLOCK.
     IF WS-PAUSED = 0
         MOVE "commands.time.pause.already_running" TO WS-KEY
         PERFORM FAIL-CLOCK
     ELSE
         CALL "BR-CLOCK-SET" USING WS-ZERO WS-RATE
         MOVE "commands.time.resume" TO WS-KEY
         PERFORM TELL-CLOCK
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF.

 RATE-CLOCK.
     CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO BA-DVAL(BR-R-COUNT) WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
     MOVE WS-NUMBER-LENGTH TO WS-L2
     MOVE WS-NUMBER TO WS-A2
     IF BA-DVAL(BR-R-COUNT) = WS-RATE
         MOVE "commands.time.rate.already_same" TO WS-KEY
         PERFORM FAIL-CLOCK
     ELSE
         CALL "BR-CLOCK-SET" USING WS-PAUSED BA-DVAL(BR-R-COUNT)
         MOVE "commands.time.rate" TO WS-KEY
         PERFORM TELL-CLOCK
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF.

 MAIN-LINE.
     PERFORM DESCRIBE
     MOVE 0 TO WS-L2
     MOVE SPACES TO WS-A2
     CALL "BR-CLOCK-STATE" USING WS-PAUSED WS-RATE
     EVALUATE TRUE
         WHEN WS-LAST = "gametime"
             PERFORM QUERY-GAMETIME
         WHEN WS-LAST = "time" AND WS-ARG = SPACES
             PERFORM QUERY-TIME
         WHEN WS-LAST = "timeline"
             PERFORM QUERY-TIMELINE
         WHEN WS-LAST = "set" AND WS-ARG = "time"
             PERFORM SET-TICKS
         WHEN WS-LAST = "set"
             PERFORM SET-MARKER
         WHEN WS-LAST = "add"
             PERFORM ADD-TICKS
         WHEN WS-LAST = "pause"
             PERFORM PAUSE-CLOCK
         WHEN WS-LAST = "resume"
             PERFORM RESUME-CLOCK
         WHEN OTHER
             PERFORM RATE-CLOCK
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-TIME.
*> The forms of time (16 §4.5): `time of <clock>` and `repetition` are BLOCKED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-TIME.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "time query gametime" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time query time" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time query timeline <timeline:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time set <time:time:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time set <marker:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time add <time:time:-2147483648>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time pause" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time resume" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "time rate <rate:float:0.00001:1000>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-WEATHER.
*> weather clear | rain | thunder [<duration>] (16 §4.10, level 2): the shared weather (WEATHER-SET-KIND) for the duration, or for
*> a duration drawn from the range of the kind (clear 12000..180000, rain 12000..24000, thunder 3600..15600); the message is
*> broadcast; the result is the duration as given, -1 when it was drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY WEATHER.
 COPY PROTO.
 01 WS-NAME                PIC X(32) VALUE "duration".
 01 WS-INDEX               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     EVALUATE BA-NAME(2)
         WHEN "clear"
             MOVE WK-CLEAR TO WS-KIND
             MOVE 12000 TO WS-LOW
             MOVE 180000 TO WS-HIGH
             MOVE "commands.weather.set.clear" TO WS-KEY
         WHEN "rain"
             MOVE WK-DRIZZLE TO WS-KIND
             MOVE 12000 TO WS-LOW
             MOVE 24000 TO WS-HIGH
             MOVE "commands.weather.set.rain" TO WS-KEY
         WHEN OTHER
             MOVE WK-HAILSTORM TO WS-KIND
             MOVE 3600 TO WS-LOW
             MOVE 15600 TO WS-HIGH
             MOVE "commands.weather.set.thunder" TO WS-KEY
     END-EVALUATE
     IF WS-INDEX > 0
         MOVE BA-IVAL(WS-INDEX) TO WS-DURATION
         MOVE WS-DURATION TO BR-R-RESULT
     ELSE
         COMPUTE WS-DURATION = WS-LOW + FUNCTION INTEGER(FUNCTION RANDOM * (WS-HIGH - WS-LOW + 1))
         MOVE -1 TO BR-R-RESULT
     END-IF
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-DURATION
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     GOBACK.
 END PROGRAM CX-WEATHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-WEATHER.
*> The forms of weather (16 §4.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-WEATHER.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "weather clear" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "weather clear <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "weather rain" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "weather rain <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "weather thunder" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "weather thunder <duration:time:1>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-WEATHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-SEND-SPAWN.
*> No arguments: Set Default Spawn Position (the world spawn) to every player in cobolcraft:main whose join has been sent
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-SPAWN-POSITION-BUILD" USING PB-BUFFER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND PL-DIM(WS-ROW) = DIM-MAIN
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BR-SEND-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BX-PLACE.
*> USING position index (0 = the source's position), rotation index (0 = none), block x, y, z out (BINARY-LONG), yaw out,
*> pitch out (FLOAT-SHORT: the yaw wrapped to degrees, the pitch limited to -90..90; 0 and 0 without a rotation): the place
*> of setworldspawn and spawnpoint; a block outside the spawnable bounds raises argument.pos.outofbounds (BR-R-FAILED)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-KEY                 PIC X(48) VALUE "argument.pos.outofbounds".
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-POS                  BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-POS L-ROT L-BX L-BY L-BZ L-YAW L-PITCH.
     MOVE BS-X TO WS-X
     MOVE BS-Y TO WS-Y
     MOVE BS-Z TO WS-Z
     IF L-POS > 0
         CALL "BX-POSITION" USING L-POS WS-X WS-Y WS-Z
     END-IF
     COMPUTE L-BX = FUNCTION INTEGER(WS-X)
     COMPUTE L-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE L-BZ = FUNCTION INTEGER(WS-Z)
     MOVE 0 TO L-YAW L-PITCH
     IF L-ROT > 0
         MOVE BA-NUM(L-ROT, 1) TO WS-W
         IF BA-KIND(L-ROT, 1) = 1
             ADD BS-YAW TO WS-W
         END-IF
         COMPUTE L-YAW = FUNCTION MOD(WS-W + 180, 360) - 180
         MOVE BA-NUM(L-ROT, 2) TO WS-W
         IF BA-KIND(L-ROT, 2) = 1
             ADD BS-PITCH TO WS-W
         END-IF
         IF WS-W < -90
             MOVE -90 TO WS-W
         END-IF
         IF WS-W > 90
             MOVE 90 TO WS-W
         END-IF
         MOVE WS-W TO L-PITCH
     END-IF
     IF L-BX < -30000000 OR L-BX >= 30000000 OR L-BZ < -30000000 OR L-BZ >= 30000000
             OR L-BY < -20000000 OR L-BY >= 20000000
         MOVE SPACES TO WS-A1 WS-A2
         CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
         MOVE 1 TO BR-R-FAILED
     END-IF
     GOBACK.
 END PROGRAM BX-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SETWORLDSPAWN.
*> setworldspawn [<pos> [<rotation>]] (16 §4.7, level 2): the world spawn point is the block (the source's, or the argument), its
*> rotation (0, 0 without one); every player in cobolcraft:main is sent Set Default Spawn Position; the message has six
*> arguments (x, y, z, yaw, pitch, dimension id); broadcast; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-ROT            PIC X(32) VALUE "rotation".
 01 WS-POS                 BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-KEY                 PIC X(72) VALUE "commands.setworldspawn.success".
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-INT-ZERO            BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-DVAL                FLOAT-LONG.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME-POS WS-POS
     CALL "BX-FIND" USING WS-NAME-ROT WS-ROT
     CALL "BX-PLACE" USING WS-POS WS-ROT WS-BX WS-BY WS-BZ WS-YAW WS-PITCH
     IF BR-R-FAILED = 0
         COMPUTE CW-SPAWN-X = WS-BX + 0.5
         MOVE WS-BY TO CW-SPAWN-Y
         COMPUTE CW-SPAWN-Z = WS-BZ + 0.5
         MOVE WS-YAW TO CW-SPAWN-YAW
         CALL "BR-SEND-SPAWN"
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BX
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BZ
         MOVE WS-YAW TO WS-DVAL
         CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO WS-DVAL WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
         MOVE WS-PITCH TO WS-DVAL
         CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO WS-DVAL WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT DM-KEY(BS-DIM) DM-KEY-LENGTH(BS-DIM)
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE 1 TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SETWORLDSPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SETWORLDSPAWN.
*> The forms of setworldspawn (16 §4.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SETWORLDSPAWN.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "setworldspawn" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setworldspawn <pos:pos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setworldspawn <pos:pos> <rotation:rotation>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SETWORLDSPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SPAWNPOINT.
*> spawnpoint [<targets> [<pos> [<rotation>]]] (16 §4.8, level 2): each target's personal respawn point (BW-SPAWN, core/copy/
*> BRWORLD.cpy) is the dimension of the source, the block (x and z at its centre) and the rotation; the message has seven arguments
*> (x, y, z, yaw, pitch, dimension id, the player or the count); broadcast; the result is the number of players.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRWORLD.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-TARGETS        PIC X(32) VALUE "targets".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-ROT            PIC X(32) VALUE "rotation".
 01 WS-ROWS.
    05 BX-COUNT             BINARY-LONG.
    05 BX-ROW               BINARY-LONG OCCURS 64 TIMES.
 01 WS-POS                 BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-INT-ZERO            BINARY-DOUBLE VALUE 0.
 01 WS-ZERO-INF            BINARY-LONG VALUE 0.
 01 WS-DVAL                FLOAT-LONG.
 01 WS-NUMBER              PIC X(32).
 01 WS-NUMBER-LENGTH       BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-TARGETS-OR-SELF" USING WS-NAME-TARGETS WS-ROWS
     IF BR-R-FAILED = 0
         CALL "BX-FIND" USING WS-NAME-POS WS-POS
         CALL "BX-FIND" USING WS-NAME-ROT WS-ROT
         CALL "BX-PLACE" USING WS-POS WS-ROT WS-BX WS-BY WS-BZ WS-YAW WS-PITCH
     END-IF
     IF BR-R-FAILED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BX-COUNT
             MOVE BX-ROW(WS-I) TO WS-ROW
             MOVE 1 TO BW-SPAWN-SET(WS-ROW)
             MOVE BS-DIM TO BW-SPAWN-DIM(WS-ROW)
             COMPUTE BW-SPAWN-X(WS-ROW) = WS-BX + 0.5
             MOVE WS-BY TO BW-SPAWN-Y(WS-ROW)
             COMPUTE BW-SPAWN-Z(WS-ROW) = WS-BZ + 0.5
             MOVE WS-YAW TO BW-SPAWN-YAW(WS-ROW)
             MOVE WS-PITCH TO BW-SPAWN-PITCH(WS-ROW)
         END-PERFORM
         IF BX-COUNT = 1
             MOVE "commands.spawnpoint.success.single" TO WS-KEY
         ELSE
             MOVE "commands.spawnpoint.success.multiple" TO WS-KEY
         END-IF
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BX
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-BZ
         MOVE WS-YAW TO WS-DVAL
         CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO WS-DVAL WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
         MOVE WS-PITCH TO WS-DVAL
         CALL "BR-NUMBER-TEXT" USING WS-KIND-FLOAT WS-INT-ZERO WS-DVAL WS-ZERO-INF WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NUMBER WS-NUMBER-LENGTH
         CALL "CMD-TEXT-ARG" USING PB-TEXT DM-KEY(BS-DIM) DM-KEY-LENGTH(BS-DIM)
         IF BX-COUNT = 1
             CALL "CMD-TEXT-ARG" USING PB-TEXT PL-NAME(BX-ROW(1)) PL-NAME-LENGTH(BX-ROW(1))
         ELSE
             CALL "CMD-TEXT-INT" USING PB-TEXT BX-COUNT
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE BX-COUNT TO BR-R-RESULT
     END-IF
     GOBACK.
 END PROGRAM CX-SPAWNPOINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SPAWNPOINT.
*> The forms of spawnpoint (16 §4.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SPAWNPOINT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "spawnpoint" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spawnpoint <targets:players>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spawnpoint <targets:players> <pos:pos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "spawnpoint <targets:players> <pos:pos> <rotation:rotation>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SPAWNPOINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SEED.
*> seed (16 §4.6, level 2; 0 in a single-player host): commands.seed.success [seed], not broadcast; the result is the low 32 bits
*> of the seed as a signed int. (The click-to-copy component of the seed is a literal here: BLOCKED.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72) VALUE "commands.seed.success".
 01 WS-EDIT                PIC -(18)9.
 01 WS-TEXT                PIC X(24).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-LOW                 BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE CW-SEED TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-LENGTH
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     COMPUTE WS-LOW = FUNCTION MOD(CW-SEED, 4294967296)
     IF WS-LOW >= 2147483648
         SUBTRACT 4294967296 FROM WS-LOW
     END-IF
     MOVE WS-LOW TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SEED.
*> The form of seed (16 §4.6): level 0 in a single-player host (host kind 1 or 2), else 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SEED.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     IF CS-HOST-KIND > 0
         MOVE 0 TO WS-LEVEL
     END-IF
     MOVE "seed" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-VERSION.
*> version (16 §4.6, level 2; 0 in a single-player host): the lines commands.version.header, id, name, data (5023), series,
*> protocol (777 and its hexadecimal), build_time, pack.resource (97.1), pack.data (121.0) and stable.yes, each to the source
*> only (a system message, not feedback); the result is 1. The id and name are 26.3, the series main and the build time
*> unknown (the artifact records none: BLOCKED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-I                   BINARY-LONG.
 01 WS-LINES.
    05 FILLER PIC X(40) VALUE "commands.version.header".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.id".
    05 FILLER PIC X(16) VALUE "26.3".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.name".
    05 FILLER PIC X(16) VALUE "26.3".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.data".
    05 FILLER PIC X(16) VALUE "5023".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.series".
    05 FILLER PIC X(16) VALUE "main".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.protocol".
    05 FILLER PIC X(16) VALUE "777".
    05 FILLER PIC X(16) VALUE "309".
    05 FILLER PIC X(40) VALUE "commands.version.build_time".
    05 FILLER PIC X(16) VALUE "unknown".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.pack.resource".
    05 FILLER PIC X(16) VALUE "97.1".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.pack.data".
    05 FILLER PIC X(16) VALUE "121.0".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(40) VALUE "commands.version.stable.yes".
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC X(16) VALUE SPACES.
 01 WS-TABLE REDEFINES WS-LINES.
    05 WS-LINE OCCURS 10 TIMES.
       10 WS-L-KEY          PIC X(40).
       10 WS-L-ARG1         PIC X(16).
       10 WS-L-ARG2         PIC X(16).
 01 WS-KEY                 PIC X(72).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-L-KEY(WS-I) TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         IF WS-L-ARG1(WS-I) NOT = SPACES
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-L-ARG1(WS-I) TRAILING)) TO WS-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-L-ARG1(WS-I) WS-LENGTH
         END-IF
         IF WS-L-ARG2(WS-I) NOT = SPACES
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-L-ARG2(WS-I) TRAILING)) TO WS-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-L-ARG2(WS-I) WS-LENGTH
         END-IF
         CALL "BR-TELL" USING BS-ROW PB-TEXT
     END-PERFORM
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-VERSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-VERSION.
*> The form of version (16 §4.6): level 0 in a single-player host, else 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-VERSION.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     IF CS-HOST-KIND > 0
         MOVE 0 TO WS-LEVEL
     END-IF
     MOVE "version" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-VERSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DIFFICULTY.
*> difficulty [peaceful | easy | normal | hard] (16 §4.3, level 2): without an argument commands.difficulty.query [name] (not
*> broadcast; the result is the id); with one the difficulty is set (result 0), every player is sent Change Difficulty (10) and
*> commands.difficulty.success is broadcast; the difficulty it already is gives commands.difficulty.failure.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY BRRUN.
 COPY PROTO.
 01 WS-WANTED              BINARY-LONG.
 01 WS-NAME                PIC X(8).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 10.
 01 WS-LOCKED              BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> WS-NAME of the difficulty WS-WANTED.
 NAME-IT.
     EVALUATE WS-WANTED
         WHEN 0
             MOVE "Peaceful" TO WS-NAME
         WHEN 1
             MOVE "Easy" TO WS-NAME
         WHEN 2
             MOVE "Normal" TO WS-NAME
         WHEN OTHER
             MOVE "Hard" TO WS-NAME
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME TRAILING)) TO WS-NAME-LENGTH.

 SEND-IT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER BW-DIFFICULTY
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-LOCKED
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER.

 MAIN-LINE.
     CALL "BR-WORLD-READY"
     IF BR-R-COUNT = 1
         MOVE BW-DIFFICULTY TO WS-WANTED
         PERFORM NAME-IT
         MOVE "commands.difficulty.query" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE BW-DIFFICULTY TO BR-R-RESULT
     ELSE
         EVALUATE BA-NAME(2)
             WHEN "peaceful"
                 MOVE 0 TO WS-WANTED
             WHEN "easy"
                 MOVE 1 TO WS-WANTED
             WHEN "normal"
                 MOVE 2 TO WS-WANTED
             WHEN OTHER
                 MOVE 3 TO WS-WANTED
         END-EVALUATE
         PERFORM NAME-IT
         IF WS-WANTED = BW-DIFFICULTY
             MOVE "commands.difficulty.failure" TO WS-KEY
             MOVE 1 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-NAME TO WS-A1
             MOVE WS-NAME-LENGTH TO WS-L1
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             MOVE WS-WANTED TO BW-DIFFICULTY
             PERFORM SEND-IT
             MOVE "commands.difficulty.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 0 TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.

 END PROGRAM CX-DIFFICULTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DIFFICULTY.
*> The forms of difficulty (16 §4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DIFFICULTY.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "difficulty" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "difficulty peaceful" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "difficulty easy" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "difficulty normal" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "difficulty hard" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DIFFICULTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DEFAULTGAMEMODE.
*> defaultgamemode <gamemode> (16 §4.2, level 2): the game mode new players start in (CW-GAME-MODE) is set; with force-gamemode
*> (BW-FORCE-GAMEMODE) every online player whose mode differs is moved to it (mode event and abilities sent; survival and creative only
*> are modes of the core, so another mode moves no one); commands.defaultgamemode.success is broadcast; the result is the number of
*> players moved (0 without force-gamemode).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-MODE-PIC            PIC 9.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NAME                PIC X(32) VALUE "gamemode".
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODE-NAME           PIC X(16).
 01 WS-MODE-NAME-LENGTH    BINARY-LONG.
 01 WS-KEY                 PIC X(72) VALUE "commands.defaultgamemode.success".
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     MOVE BA-IVAL(WS-INDEX) TO CW-GAME-MODE
     EVALUATE CW-GAME-MODE
         WHEN 0
             MOVE "Survival Mode" TO WS-MODE-NAME
         WHEN 1
             MOVE "Creative Mode" TO WS-MODE-NAME
         WHEN 2
             MOVE "Adventure Mode" TO WS-MODE-NAME
         WHEN OTHER
             MOVE "Spectator Mode" TO WS-MODE-NAME
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-MODE-NAME TRAILING)) TO WS-MODE-NAME-LENGTH
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-MODE-NAME WS-MODE-NAME-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 0 TO WS-MOVED
     CALL "BR-WORLD-READY"
     IF BW-FORCE-GAMEMODE = 1 AND CW-GAME-MODE < 2
         MOVE CW-GAME-MODE TO WS-MODE-PIC
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 64
             IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) NOT = PS-JOINING AND PL-MODE(WS-ROW) NOT = CW-GAME-MODE
                 ADD 1 TO WS-MOVED
                 MOVE CW-GAME-MODE TO PL-MODE(WS-ROW)
                 MOVE 0 TO PL-FLYING(WS-ROW)
                 MOVE CW-GAME-MODE TO WS-VALUE
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "PLAY-ABILITIES-BUILD" USING WS-MODE-PIC PL-FLYING(WS-ROW) PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-MOVED TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-DEFAULTGAMEMODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-DEFAULTGAMEMODE.
*> The form of defaultgamemode (16 §4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-DEFAULTGAMEMODE.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "defaultgamemode <gamemode:gamemode>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-DEFAULTGAMEMODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-GAMERULE.
*> gamerule <rule> [<value>] (16 §4.4, §13, level 2): the rule is the second node (its name with or without minecraft:); without a
*> value commands.gamerule.query [rule, value] (not broadcast); with one the rule is set (commands.gamerule.set, broadcast) unless
*> it already has that value (commands.gamerule.not_set, an error); the result is 1 or 0 for a boolean rule and the integer for
*> an integer rule.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-VALUE          PIC X(32) VALUE "value".
 01 WS-INDEX               BINARY-LONG.
 01 WS-RULE                PIC X(40).
 01 WS-STRIP               PIC X(64).
 01 WS-RULE-LENGTH         BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-CURRENT             BINARY-DOUBLE.
 01 WS-TEXT                PIC X(24).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-EDIT                PIC -(18)9.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> WS-TEXT of WS-VALUE for the rule WS-ENTRY: true or false for a boolean rule, else the integer.
 VALUE-TEXT.
     IF GR-D-TYPE(WS-ENTRY) = "B"
         IF WS-VALUE = 1
             MOVE "true" TO WS-TEXT
             MOVE 4 TO WS-TEXT-LENGTH
         ELSE
             MOVE "false" TO WS-TEXT
             MOVE 5 TO WS-TEXT-LENGTH
         END-IF
     ELSE
         MOVE WS-VALUE TO WS-EDIT
         MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-TEXT-LENGTH
     END-IF.

*> The text WS-KEY with the rule and the value WS-TEXT.
 TELL-RULE.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-RULE WS-RULE-LENGTH
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-TEXT WS-TEXT-LENGTH.

 MAIN-LINE.
     MOVE SPACES TO WS-RULE
     MOVE BA-NAME(2) TO WS-RULE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-RULE TRAILING)) TO WS-RULE-LENGTH
     IF WS-RULE-LENGTH > 10 AND WS-RULE(1:10) = "minecraft:"
         COMPUTE WS-RULE-LENGTH = WS-RULE-LENGTH - 10
         MOVE WS-RULE(11:WS-RULE-LENGTH) TO WS-STRIP
         MOVE WS-STRIP TO WS-RULE
     END-IF
     CALL "BR-RULE-FIND" USING WS-RULE WS-ENTRY
     MOVE GR-VALUE(WS-ENTRY) TO WS-CURRENT
     CALL "BX-FIND" USING WS-NAME-VALUE WS-INDEX
     IF WS-INDEX = 0
         MOVE WS-CURRENT TO WS-VALUE
         PERFORM VALUE-TEXT
         MOVE "commands.gamerule.query" TO WS-KEY
         PERFORM TELL-RULE
         CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         MOVE WS-CURRENT TO BR-R-RESULT
     ELSE
         MOVE BA-IVAL(WS-INDEX) TO WS-VALUE
         PERFORM VALUE-TEXT
         IF WS-VALUE = WS-CURRENT
             MOVE "commands.gamerule.not_set" TO WS-KEY
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-RULE TO WS-A1
             MOVE WS-RULE-LENGTH TO WS-L1
             MOVE WS-TEXT TO WS-A2
             MOVE WS-TEXT-LENGTH TO WS-L2
             MOVE 2 TO WS-N-ARGS
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         ELSE
             CALL "BR-RULE-SET" USING WS-ENTRY WS-VALUE
             MOVE "commands.gamerule.set" TO WS-KEY
             PERFORM TELL-RULE
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-VALUE TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-GAMERULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-GAMERULE.
*> The forms of gamerule (16 §4.4, §13): for each of the rules of BRRULES.cpy the name and the minecraft: name, each with a query and
*> a set (a bool, or an integer within the range of the rule).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRULES.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-GAMERULE.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-NAME                PIC X(60).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-MIN                 PIC -(10)9.
 01 WS-MAX                 PIC -(10)9.
 01 WS-LIMITS              PIC X(40).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GR-COUNT
         PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
             MOVE SPACES TO WS-NAME
             MOVE FUNCTION LENGTH(FUNCTION TRIM(GR-D-NAME(WS-I) TRAILING)) TO WS-NAME-LENGTH
             IF WS-PASS = 1
                 MOVE GR-D-NAME(WS-I)(1:WS-NAME-LENGTH) TO WS-NAME
             ELSE
                 STRING "minecraft:" GR-D-NAME(WS-I)(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-NAME
                 ADD 10 TO WS-NAME-LENGTH
             END-IF
             MOVE SPACES TO WS-PATH
             STRING "gamerule " WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO WS-PATH
             CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
             MOVE SPACES TO WS-PATH
             IF GR-D-TYPE(WS-I) = "B"
                 STRING "gamerule " WS-NAME(1:WS-NAME-LENGTH) " <value:bool>" DELIMITED BY SIZE INTO WS-PATH
             ELSE
                 MOVE GR-D-MIN(WS-I) TO WS-MIN
                 MOVE GR-D-MAX(WS-I) TO WS-MAX
                 MOVE SPACES TO WS-LIMITS
                 STRING FUNCTION TRIM(WS-MIN) ":" FUNCTION TRIM(WS-MAX) DELIMITED BY SIZE INTO WS-LIMITS
                 STRING "gamerule " WS-NAME(1:WS-NAME-LENGTH) " <value:int:" FUNCTION TRIM(WS-LIMITS TRAILING) ">"
                     DELIMITED BY SIZE INTO WS-PATH
             END-IF
             CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-GAMERULE.
