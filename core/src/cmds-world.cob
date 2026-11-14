*> Commands that edit the world (docs/protocol/16-commands-catalog.md §7): setblock and fill. A CX- program reads its parsed context
*> through the BX- helpers (core/src/cmd-args.cob), writes blocks through LEVEL-SET-BLOCK and LEVEL-DESTROY-BLOCK (core/src/blockupd-29.cob,
*> the changes are sent with the next world tick), tells through BR-FEEDBACK, sets BR-R-RESULT and, to fail, raises an exception (BR-RAISE).
*> Blocks with properties in a filter match by block only and the neighbour updates after a non-strict fill are BLOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-SETBLOCK.
*> setblock <pos> <block> [destroy | keep | replace | strict] (16 §7.1, level 2): the block state is placed (flags 2 + 256, strict: 2 + 816); destroy first
*> destroys the old block with its drops, keep places only over air; a position outside the world or not placed is commands.setblock.failed; a chunk
*> that is not loaded is argument.pos.unloaded; commands.setblock.success [x, y, z] is broadcast; the result is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-NAME-BLOCK          PIC X(32) VALUE "block".
 01 WS-NAME-DESTROY        PIC X(32) VALUE "destroy".
 01 WS-NAME-KEEP           PIC X(32) VALUE "keep".
 01 WS-NAME-STRICT         PIC X(32) VALUE "strict".
 01 WS-POS                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-DROP                BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
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
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-POS WS-POS
     CALL "BX-FIND" USING WS-NAME-BLOCK WS-BLOCK
     CALL "BX-LIT" USING WS-NAME-DESTROY WS-DESTROY
     CALL "BX-LIT" USING WS-NAME-KEEP WS-KEEP
     CALL "BX-LIT" USING WS-NAME-STRICT WS-STRICT
     CALL "BX-POSITION" USING WS-POS WS-X WS-Y WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
     CALL "WORLD-FIND" USING BS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         MOVE "argument.pos.unloaded" TO WS-KEY
         PERFORM FAIL-PLAIN
     ELSE
         MOVE BA-IVAL(WS-BLOCK) TO WS-STATE
         CALL "WORLD-GET-BLOCK" USING BS-DIM WS-BX WS-BY WS-BZ WS-OLD
         MOVE 0 TO WS-CHANGED
         IF WS-KEEP > 0 AND WS-OLD NOT = 0
             CONTINUE
         ELSE
             IF WS-DESTROY > 0
                 CALL "LEVEL-DESTROY-BLOCK" USING BS-DIM WS-BX WS-BY WS-BZ WS-DROP WS-BUDGET WS-RESULT
             END-IF
             MOVE 258 TO WS-FLAGS
             IF WS-STRICT > 0
                 MOVE 818 TO WS-FLAGS
             END-IF
             CALL "LEVEL-SET-BLOCK" USING BS-DIM WS-BX WS-BY WS-BZ WS-STATE WS-FLAGS WS-BUDGET WS-CHANGED
         END-IF
         IF WS-CHANGED = 0
             MOVE "commands.setblock.failed" TO WS-KEY
             PERFORM FAIL-PLAIN
         ELSE
             MOVE "commands.setblock.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-BX
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-BY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-BZ
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE 1 TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-SETBLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-SETBLOCK.
*> The forms of setblock (16 §7.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-SETBLOCK.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "setblock <pos:pos> <block:blockstate>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setblock <pos:pos> <block:blockstate> destroy" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setblock <pos:pos> <block:blockstate> keep" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setblock <pos:pos> <block:blockstate> replace" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "setblock <pos:pos> <block:blockstate> strict" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-SETBLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-FILL.
*> fill <from> <to> <block> [outline | hollow | destroy | strict], fill ... replace [<filter>] [mode], fill ... keep (16 §7.2, level 2): every position of the
*> box is visited; replace with a filter places over the blocks of the filter's block (properties of the filter are not compared), keep over air, outline only
*> on the faces of the box, hollow the block on the faces and air inside, destroy destroys the old block first, strict uses the flags 2 + 816; a chunk of
*> a corner that is not loaded is argument.pos.unloaded; a volume above the game rule max_block_modifications is commands.fill.toobig [max, volume];
*> nothing changed is commands.fill.failed; commands.fill.success [count] is broadcast; the result is the count.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-FROM           PIC X(32) VALUE "from".
 01 WS-NAME-TO             PIC X(32) VALUE "to".
 01 WS-NAME-BLOCK          PIC X(32) VALUE "block".
 01 WS-NAME-FILTER         PIC X(32) VALUE "filter".
 01 WS-NAME-OUTLINE        PIC X(32) VALUE "outline".
 01 WS-NAME-HOLLOW         PIC X(32) VALUE "hollow".
 01 WS-NAME-DESTROY        PIC X(32) VALUE "destroy".
 01 WS-NAME-KEEP           PIC X(32) VALUE "keep".
 01 WS-NAME-STRICT         PIC X(32) VALUE "strict".
 01 WS-RULE                PIC X(40) VALUE "max_block_modifications".
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-OUTLINE             BINARY-LONG.
 01 WS-HOLLOW              BINARY-LONG.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-DROP                BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
 01 WS-VOLUME              BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-ACCEPT              BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC -(18)9.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
     MOVE 1 TO BR-R-FAILED.

*> WS-ACCEPT 1 when the position (WS-PX, WS-PY, WS-PZ) takes the block (WS-NEW the state to place) in the mode of the command.
 DECIDE.
     MOVE 1 TO WS-ACCEPT
     MOVE WS-STATE TO WS-NEW
     CALL "WORLD-GET-BLOCK" USING BS-DIM WS-PX WS-PY WS-PZ WS-OLD
     MOVE 0 TO WS-FACE
     IF WS-PX = WS-X1 OR WS-PX = WS-X2 OR WS-PY = WS-Y1 OR WS-PY = WS-Y2 OR WS-PZ = WS-Z1 OR WS-PZ = WS-Z2
         MOVE 1 TO WS-FACE
     END-IF
     EVALUATE TRUE
         WHEN WS-KEEP > 0 AND WS-OLD NOT = 0
             MOVE 0 TO WS-ACCEPT
         WHEN WS-FILTER > 0 AND CB-S-BLOCK(WS-OLD + 1) NOT = CB-S-BLOCK(BA-IVAL(WS-FILTER) + 1)
             MOVE 0 TO WS-ACCEPT
         WHEN WS-OUTLINE > 0 AND WS-FACE = 0
             MOVE 0 TO WS-ACCEPT
         WHEN WS-HOLLOW > 0 AND WS-FACE = 0
             MOVE 0 TO WS-NEW
     END-EVALUATE.

*> One position: the destroy step, then the placement; WS-COUNT counts what changed.
 VISIT.
     PERFORM DECIDE
     IF WS-ACCEPT = 1
         MOVE 0 TO WS-RESULT
         IF WS-DESTROY > 0
             CALL "LEVEL-DESTROY-BLOCK" USING BS-DIM WS-PX WS-PY WS-PZ WS-DROP WS-BUDGET WS-RESULT
             IF WS-RESULT = 1
                 ADD 1 TO WS-COUNT
             END-IF
         END-IF
         MOVE 0 TO WS-RESULT
         CALL "LEVEL-SET-BLOCK" USING BS-DIM WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
         IF WS-RESULT = 1 AND WS-DESTROY = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-IF.

*> The corner WS-X/WS-Y/WS-Z must be in a loaded chunk.
 CHECK-LOADED.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "WORLD-FIND" USING BS-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         MOVE "argument.pos.unloaded" TO WS-KEY
         PERFORM FAIL-PLAIN
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-FROM WS-FROM
     CALL "BX-FIND" USING WS-NAME-TO WS-TO
     CALL "BX-FIND" USING WS-NAME-BLOCK WS-BLOCK
     CALL "BX-FIND" USING WS-NAME-FILTER WS-FILTER
     CALL "BX-LIT" USING WS-NAME-OUTLINE WS-OUTLINE
     CALL "BX-LIT" USING WS-NAME-HOLLOW WS-HOLLOW
     CALL "BX-LIT" USING WS-NAME-DESTROY WS-DESTROY
     CALL "BX-LIT" USING WS-NAME-KEEP WS-KEEP
     CALL "BX-LIT" USING WS-NAME-STRICT WS-STRICT
     MOVE BA-IVAL(WS-BLOCK) TO WS-STATE
     CALL "BX-POSITION" USING WS-FROM WS-X WS-Y WS-Z
     COMPUTE WS-X1 = FUNCTION INTEGER(WS-X)
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-Z1 = FUNCTION INTEGER(WS-Z)
     PERFORM CHECK-LOADED
     CALL "BX-POSITION" USING WS-TO WS-X WS-Y WS-Z
     COMPUTE WS-X2 = FUNCTION INTEGER(WS-X)
     COMPUTE WS-Y2 = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-Z2 = FUNCTION INTEGER(WS-Z)
     IF BR-R-FAILED = 0
         PERFORM CHECK-LOADED
     END-IF
     IF BR-R-FAILED = 0
         IF WS-X1 > WS-X2
             MOVE WS-X1 TO WS-INT
             MOVE WS-X2 TO WS-X1
             MOVE WS-INT TO WS-X2
         END-IF
         IF WS-Y1 > WS-Y2
             MOVE WS-Y1 TO WS-INT
             MOVE WS-Y2 TO WS-Y1
             MOVE WS-INT TO WS-Y2
         END-IF
         IF WS-Z1 > WS-Z2
             MOVE WS-Z1 TO WS-INT
             MOVE WS-Z2 TO WS-Z1
             MOVE WS-INT TO WS-Z2
         END-IF
         COMPUTE WS-VOLUME = (WS-X2 - WS-X1 + 1) * (WS-Y2 - WS-Y1 + 1) * (WS-Z2 - WS-Z1 + 1)
         CALL "BR-RULE-GET" USING WS-RULE WS-MAX
         IF WS-VOLUME > WS-MAX
             MOVE "commands.fill.toobig" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             MOVE WS-MAX TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A1
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L1
             MOVE WS-VOLUME TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-A2
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-L2
             CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC
             MOVE 1 TO BR-R-FAILED
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 258 TO WS-FLAGS
         IF WS-STRICT > 0
             MOVE 818 TO WS-FLAGS
         END-IF
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-PY FROM WS-Y1 BY 1 UNTIL WS-PY > WS-Y2
             PERFORM VARYING WS-PX FROM WS-X1 BY 1 UNTIL WS-PX > WS-X2
                 PERFORM VARYING WS-PZ FROM WS-Z1 BY 1 UNTIL WS-PZ > WS-Z2
                     PERFORM VISIT
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         IF WS-COUNT = 0
             MOVE "commands.fill.failed" TO WS-KEY
             PERFORM FAIL-PLAIN
         ELSE
             MOVE "commands.fill.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-FILL.
*> The forms of fill (16 §7.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-FILL.
 01 WS-PATH                PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                PIC X(120).
 01 WS-MODES.
    05 FILLER               PIC X(8) VALUE "outline".
    05 FILLER               PIC X(8) VALUE "hollow".
    05 FILLER               PIC X(8) VALUE "destroy".
    05 FILLER               PIC X(8) VALUE "strict".
 01 WS-MODE-TABLE REDEFINES WS-MODES.
    05 WS-MODE              PIC X(8) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     MOVE "fill <from:pos> <to:pos> <block:blockstate>" TO WS-BASE
     MOVE WS-BASE TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(WS-BASE) " " FUNCTION TRIM(WS-MODE(WS-I)) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-BASE) " keep" DELIMITED BY SIZE INTO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-BASE) " replace" DELIMITED BY SIZE INTO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(WS-BASE) " replace " FUNCTION TRIM(WS-MODE(WS-I)) DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-BASE) " replace <filter:blockpred>" DELIMITED BY SIZE INTO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(WS-BASE) " replace <filter:blockpred> " FUNCTION TRIM(WS-MODE(WS-I))
             DELIMITED BY SIZE INTO WS-PATH
         CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-FILL.
