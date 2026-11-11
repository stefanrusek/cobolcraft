*> Commands of the server administration and utility groups (docs/protocol/16-commands-catalog.md §10.8, §10.12, §11.14): random, reload and
*> setidletimeout. A CX- program reads its parsed context through the BX- helpers (core/src/cmd-args.cob), tells through BR-FEEDBACK, sets
*> BR-R-RESULT and, to fail, raises an exception (BR-RAISE) and sets BR-R-FAILED; a CMDS-REG- program registers the forms.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RANDOM.
*> random value <range> [<sequence>] and random roll <range> [<sequence>] (16 §10.8, level 0): a number from min to max inclusive; the max must be above
*> the min (commands.random.error.range_too_small) and max - min below 2147483647 (range_too_large); `value` tells the source
*> commands.random.sample.success [value] (not broadcast), `roll` tells every player commands.random.roll [name, value, min, max]; the result is the number.
*> A sequence name is accepted and the one random source is used (the sequence store and `random reset` are BLOCKED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-RANGE          PIC X(32) VALUE "range".
 01 WS-NAME-ROLL           PIC X(32) VALUE "roll".
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-MIN                 BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE.
 01 WS-SPAN                BINARY-DOUBLE.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-QUIET               BINARY-LONG VALUE 0.
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
     CALL "BX-FIND" USING WS-NAME-RANGE WS-INDEX
     CALL "BX-LIT" USING WS-NAME-ROLL WS-ROLL
     MOVE -2147483648 TO WS-MIN
     MOVE 2147483647 TO WS-MAX
     IF BA-AUX(WS-INDEX) = 1 OR BA-AUX(WS-INDEX) = 3
         MOVE BA-IVAL(WS-INDEX) TO WS-MIN
     END-IF
     IF BA-AUX(WS-INDEX) = 2 OR BA-AUX(WS-INDEX) = 3
         MOVE BA-IVAL2(WS-INDEX) TO WS-MAX
     END-IF
     COMPUTE WS-SPAN = WS-MAX - WS-MIN
     EVALUATE TRUE
         WHEN WS-MAX <= WS-MIN
             MOVE "commands.random.error.range_too_small" TO WS-KEY
             PERFORM FAIL-PLAIN
         WHEN WS-SPAN >= 2147483647
             MOVE "commands.random.error.range_too_large" TO WS-KEY
             PERFORM FAIL-PLAIN
         WHEN OTHER
             COMPUTE WS-VALUE = WS-MIN + FUNCTION INTEGER(FUNCTION RANDOM * (WS-SPAN + 1))
             IF WS-VALUE > WS-MAX
                 MOVE WS-MAX TO WS-VALUE
             END-IF
             IF WS-ROLL > 0
                 MOVE "commands.random.roll" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 CALL "CMD-TEXT-ARG" USING PB-TEXT BS-NAME BS-NAME-LENGTH
                 MOVE WS-VALUE TO WS-INT
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
                 MOVE WS-MIN TO WS-INT
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
                 MOVE WS-MAX TO WS-INT
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
                 INITIALIZE PB-TEXT-STYLE
                 CALL "BR-BROADCAST" USING PB-TEXT PB-TEXT-STYLE
             ELSE
                 MOVE "commands.random.sample.success" TO WS-KEY
                 CALL "BX-KEY" USING PB-TEXT WS-KEY
                 MOVE WS-VALUE TO WS-INT
                 CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
                 CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             END-IF
             MOVE WS-VALUE TO BR-R-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RANDOM.
*> The forms of random value and random roll (16 §10.8; reset is BLOCKED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RANDOM.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "random value <range:intrange>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "random value <range:intrange> <sequence:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "random roll <range:intrange>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "random roll <range:intrange> <sequence:resloc>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-RELOAD.
*> reload (16 §10.12, level 2): commands.reload.success is broadcast; the content of the world is fixed (the data pack loader is BLOCKED), so the
*> reload never fails; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY PROTO.
 01 WS-KEY                 PIC X(72) VALUE "commands.reload.success".
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 1 TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-RELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-RELOAD.
*> The form of reload (16 §10.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-RELOAD.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "reload" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-RELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SETIDLETIMEOUT.
*> setidletimeout <minutes> (16 §11.14, level 3): the idle timeout in minutes (BW-IDLE-MINUTES; the kick of an idle player,
*> multiplayer.disconnect.idling, is BLOCKED: no idle clock) with commands.setidletimeout.success [minutes] or, for 0,
*> commands.setidletimeout.success.disabled, broadcast; the result is the minutes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 COPY BRWORLD.
 COPY PROTO.
 01 WS-NAME                PIC X(32) VALUE "minutes".
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-INT                 BINARY-LONG.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "BX-FIND" USING WS-NAME WS-INDEX
     CALL "BR-WORLD-READY"
     MOVE BA-IVAL(WS-INDEX) TO WS-INT
     MOVE WS-INT TO BW-IDLE-MINUTES
     IF WS-INT = 0
         MOVE "commands.setidletimeout.success.disabled" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
     ELSE
         MOVE "commands.setidletimeout.success" TO WS-KEY
         CALL "BX-KEY" USING PB-TEXT WS-KEY
         CALL "CMD-TEXT-INT" USING PB-TEXT WS-INT
     END-IF
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE WS-INT TO BR-R-RESULT
     GOBACK.
 END PROGRAM CX-SETIDLETIMEOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SETIDLETIMEOUT.
*> The form of setidletimeout (16 §11.14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SETIDLETIMEOUT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "setidletimeout <minutes:int:0>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SETIDLETIMEOUT.
