*> Running a command line through the framework (docs/protocol/15-commands-framework.md §10; 15a §4; cmd-exec.cob): the source is
*> built (BR-SOURCE-OF), the line is parsed, flattened and run (BR-LINE with the framework's own runner, modifier and consumer),
*> and what went wrong is told to the source: a parse error as the two lines of 15 §4.6, an exception of the execution red (15 §10.4).
*>
*> Entry points:
*>   BR-EXECUTE USING sender (player row, 0 = the console), line (PIC X(768), no leading /), byte length, result out (BINARY-LONG:
*>     the result of 15a §4.3, 0 when the line failed)
*>   BR-CMD-CALL USING context index: the runner: runs the command BR-R-COMMAND (the CX- programs of core/src/cmds-*.cob; core/copy/BRCMD.cpy
*>     has the ids). It lives in this file so that the program pointer to it, which BR-EXECUTE takes with SET ... TO ENTRY, finds it linked
*>   BR-MODIFY-CALL USING context index: the modifier: the sources of the modifier BR-R-MODIFIER for the source BR-SRC into BR-MOD
*>     (a modifier id that the framework does not know leaves the source as it is)
*>   BR-CONSUME USING context index, success, result: the result consumer of a top-level line: it does nothing (15 §10.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-EXECUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-LINE                PIC X(1024).
 01 WS-LEVEL               BINARY-LONG.
 01 WS-FAILED              BINARY-LONG.
 01 WS-RUNNER              USAGE PROGRAM-POINTER.
 01 WS-MODIFIER            USAGE PROGRAM-POINTER.
 01 WS-CONSUMER            USAGE PROGRAM-POINTER.
 LINKAGE SECTION.
 01 L-SENDER               BINARY-LONG.
 01 L-LINE                 PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SENDER L-LINE L-LENGTH L-RESULT.
     CALL "BR-TREE-ENSURE"
     CALL "BR-SOURCE-OF" USING L-SENDER
     MOVE BS-LEVEL TO WS-LEVEL
     MOVE SPACES TO WS-LINE
     IF L-LENGTH > 0
         MOVE L-LINE(1:L-LENGTH) TO WS-LINE
     END-IF
     SET WS-RUNNER TO ENTRY "BR-CMD-CALL"
     SET WS-MODIFIER TO ENTRY "BR-MODIFY-CALL"
     SET WS-CONSUMER TO ENTRY "BR-CONSUME"
     CALL "BR-LINE" USING WS-LEVEL WS-LINE L-LENGTH WS-RUNNER WS-MODIFIER WS-CONSUMER L-RESULT WS-FAILED
     EVALUATE WS-FAILED
         WHEN 1
             MOVE 0 TO L-RESULT
             CALL "BR-PARSE-ERROR" USING L-SENDER
         WHEN 2
             MOVE 0 TO L-RESULT
             CALL "BR-FAIL-EXCEPTION"
     END-EVALUATE
     GOBACK.
 END PROGRAM BR-EXECUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-CONSUME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX L-SUCCESS L-RESULT.
     GOBACK.
 END PROGRAM BR-CONSUME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-MODIFY-CALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX.
     MOVE 1 TO BM-COUNT
     MOVE BR-SRC TO BM-ENTRY(1)
     GOBACK.
 END PROGRAM BR-MODIFY-CALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-CMD-CALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 COPY BRRUN.
 LINKAGE SECTION.
 01 L-CTX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CTX.
     EVALUATE BR-R-COMMAND
         WHEN BC-SAY
             CALL "CX-SAY"
         WHEN BC-ME
             CALL "CX-ME"
         WHEN BC-MSG
             CALL "CX-MSG"
         WHEN BC-LIST
             CALL "CX-LIST"
         WHEN BC-GAMEMODE
             CALL "CX-GAMEMODE"
         WHEN BC-TIME
             CALL "CX-TIME"
         WHEN BC-WEATHER
             CALL "CX-WEATHER"
         WHEN BC-SETWORLDSPAWN
             CALL "CX-SETWORLDSPAWN"
         WHEN BC-SPAWNPOINT
             CALL "CX-SPAWNPOINT"
         WHEN BC-SEED
             CALL "CX-SEED"
         WHEN BC-VERSION
             CALL "CX-VERSION"
         WHEN BC-DIFFICULTY
             CALL "CX-DIFFICULTY"
         WHEN BC-GAMERULE
             CALL "CX-GAMERULE"
         WHEN BC-DEFAULTGAMEMODE
             CALL "CX-DEFAULTGAMEMODE"
         WHEN BC-OP
             CALL "CX-OP"
         WHEN BC-DEOP
             CALL "CX-DEOP"
         WHEN BC-BAN
             CALL "CX-BAN"
         WHEN BC-PARDON
             CALL "CX-PARDON"
         WHEN BC-BANLIST
             CALL "CX-BANLIST"
         WHEN BC-KICK
             CALL "CX-KICK"
         WHEN BC-GIVE
             CALL "CX-GIVE"
         WHEN BC-TELEPORT
             CALL "CX-TELEPORT"
         WHEN BC-SUMMON
             CALL "CX-SUMMON"
         WHEN BC-KILL
             CALL "CX-KILL"
         WHEN BC-CLEAR
             CALL "CX-CLEAR"
         WHEN BC-WHITELIST
             CALL "CX-WHITELIST"
         WHEN BC-STOP
             CALL "CX-STOP"
         WHEN BC-SAVE-ALL
             CALL "CX-SAVE-ALL"
         WHEN BC-SAVE-ON
         WHEN BC-RANDOM
             CALL "CX-RANDOM"
         WHEN BC-RELOAD
             CALL "CX-RELOAD"
         WHEN BC-SETIDLETIMEOUT
             CALL "CX-SETIDLETIMEOUT"
         WHEN BC-SETBLOCK
             CALL "CX-SETBLOCK"
         WHEN BC-FILL
             CALL "CX-FILL"
         WHEN BC-EFFECT
             CALL "CX-EFFECT"
         WHEN BC-BAN-IP
             CALL "CX-BAN-IP"
         WHEN BC-PARDON-IP
             CALL "CX-PARDON-IP"
         WHEN BC-SAVE-OFF
             CALL "CX-SAVE-SWITCH"
         WHEN OTHER
             CALL "CX-HELP"
     END-EVALUATE
     GOBACK.
 END PROGRAM BR-CMD-CALL.
