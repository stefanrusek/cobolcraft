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

*> ---- The commands of the lane cmds-c: clone, fillbiome, forceload, locate, particle, place, playsound and stopsound (16 §7.3 to §7.10). The CXC- programs are
*> their shared helpers; CX-DISPATCH-C runs the commands (CX-DISPATCH-A hands over to it). ----

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-FAIL.
*> USING key (PIC X(72)), argument count, argument 1 (PIC X(64)), its length, argument 2, its length: the command fails with that exception
*> (BR-RAISE) and BR-R-FAILED is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-RC                  BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(72).
 01 L-N                    BINARY-LONG.
 01 L-A1                   PIC X(64).
 01 L-L1                   BINARY-LONG.
 01 L-A2                   PIC X(64).
 01 L-L2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-N L-A1 L-L1 L-A2 L-L2.
     CALL "BR-RAISE" USING L-KEY L-N L-A1 L-L1 L-A2 L-L2 WS-RC
     MOVE 1 TO BR-R-FAILED
     GOBACK.
 END PROGRAM CXC-FAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-INT-TEXT.
*> USING value (BINARY-DOUBLE), text out (PIC X(64)), length out: the decimal text of the value, `-` first when negative.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(18)9.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-DOUBLE.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TEXT L-LENGTH.
     MOVE L-VALUE TO WS-EDIT
     MOVE SPACES TO L-TEXT
     MOVE FUNCTION TRIM(WS-EDIT) TO L-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO L-LENGTH
     GOBACK.
 END PROGRAM CXC-INT-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-CHUNK-TEXT.
*> USING chunk x, chunk z (BINARY-LONG), text out (PIC X(64)), length out: the text [x, z] of a chunk position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-TEXT L-LENGTH.
     MOVE L-CX TO WS-EDIT-X
     MOVE L-CZ TO WS-EDIT-Z
     MOVE SPACES TO L-TEXT
     STRING "[" FUNCTION TRIM(WS-EDIT-X) ", " FUNCTION TRIM(WS-EDIT-Z) "]" DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-TEXT)) TO L-LENGTH
     GOBACK.
 END PROGRAM CXC-CHUNK-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-DIM-OF.
*> USING argument index of a dimension argument, dimension row out: the dimension the identifier names; a dimension the world does not have is
*> argument.dimension.invalid [identifier] (row 0, BR-R-FAILED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRRUN.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM-KEY             PIC X(32).
 01 WS-DIM-LENGTH          BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N                   BINARY-LONG VALUE 1.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DIM.
     MOVE 0 TO L-DIM
     COMPUTE WS-LENGTH = BA-END(L-INDEX) - BA-START(L-INDEX)
     MOVE BA-START(L-INDEX) TO WS-START
     ADD 1 TO WS-START
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE DM-KEY(WS-I) TO WS-DIM-KEY
         MOVE DM-KEY-LENGTH(WS-I) TO WS-DIM-LENGTH
         IF (WS-I = 1 OR CW-DIM-COUNT > 1) AND WS-DIM-LENGTH = WS-LENGTH
                 AND WS-DIM-KEY(1:WS-LENGTH) = BR-R-LINE(WS-START:WS-LENGTH)
             MOVE WS-I TO L-DIM
         END-IF
     END-PERFORM
     IF L-DIM = 0
         MOVE "argument.dimension.invalid" TO WS-KEY
         MOVE SPACES TO WS-A1 WS-A2
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO WS-L1
         MOVE BR-R-LINE(WS-START:WS-L1) TO WS-A1
         CALL "CXC-FAIL" USING WS-KEY WS-N WS-A1 WS-L1 WS-A2 WS-L2
     END-IF
     GOBACK.
 END PROGRAM CXC-DIM-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-POS-INT.
*> USING argument index of a coordinate argument, x, y, z out (BINARY-LONG), ok out (0 when a component lies beyond 30000000 blocks: no chunk of
*> that position is loaded): the block position of the argument (BX-POSITION, floored).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z L-OK.
     CALL "BX-POSITION" USING L-INDEX WS-X WS-Y WS-Z
     IF WS-X > 30000000 OR WS-X < -30000000 OR WS-Y > 30000000 OR WS-Y < -30000000 OR WS-Z > 30000000 OR WS-Z < -30000000
         MOVE 0 TO L-OK L-X L-Y L-Z
     ELSE
         MOVE 1 TO L-OK
         COMPUTE L-X = FUNCTION INTEGER(WS-X)
         COMPUTE L-Y = FUNCTION INTEGER(WS-Y)
         COMPUTE L-Z = FUNCTION INTEGER(WS-Z)
     END-IF
     GOBACK.
 END PROGRAM CXC-POS-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-REG-ID.
*> USING registry (PIC X(112)), identifier text (PIC X(112)), its length (1 to 100), id out (-1 when the registry holds no such entry): an
*> identifier without a namespace is looked up as cobolcraft: and as minecraft: (as BR-ARG-EXT checks a resource argument).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ENTRY               PIC X(112).
 01 WS-ENTRY-LENGTH        BINARY-LONG.
 01 WS-PAYLOAD             PIC X.
 01 WS-CAPACITY            BINARY-LONG VALUE 0.
 01 WS-PAYLOAD-LENGTH      BINARY-LONG.
 01 WS-WANT                PIC X(112).
 01 WS-WANT-LENGTH         BINARY-LONG.
 01 WS-ALT                 PIC X(112).
 01 WS-ALT-LENGTH          BINARY-LONG.
 01 WS-COLONS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(112).
 01 L-TEXT                 PIC X(112).
 01 L-LENGTH               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-TEXT L-LENGTH L-ID.
     MOVE -1 TO L-ID
     MOVE 0 TO WS-COLONS
     INSPECT L-TEXT(1:L-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     MOVE SPACES TO WS-WANT WS-ALT
     MOVE 0 TO WS-ALT-LENGTH
     IF WS-COLONS > 0
         MOVE L-TEXT(1:L-LENGTH) TO WS-WANT
         MOVE L-LENGTH TO WS-WANT-LENGTH
     ELSE
         STRING "cobolcraft:" L-TEXT(1:L-LENGTH) DELIMITED BY SIZE INTO WS-WANT
         COMPUTE WS-WANT-LENGTH = L-LENGTH + 11
         STRING "minecraft:" L-TEXT(1:L-LENGTH) DELIMITED BY SIZE INTO WS-ALT
         COMPUTE WS-ALT-LENGTH = L-LENGTH + 10
     END-IF
     CALL "CONTENT-REGISTRY-COUNT" USING L-REGISTRY WS-COUNT WS-STATUS
     IF WS-STATUS = CT-OK
         PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT OR L-ID >= 0
             CALL "CONTENT-REGISTRY-ENTRY" USING L-REGISTRY WS-ID WS-ENTRY WS-ENTRY-LENGTH WS-PAYLOAD WS-CAPACITY
                 WS-PAYLOAD-LENGTH WS-STATUS
             IF WS-ENTRY-LENGTH = WS-WANT-LENGTH AND WS-ENTRY(1:WS-ENTRY-LENGTH) = WS-WANT(1:WS-WANT-LENGTH)
                 MOVE WS-ID TO L-ID
             END-IF
             IF L-ID < 0 AND WS-ALT-LENGTH > 0 AND WS-ENTRY-LENGTH = WS-ALT-LENGTH
                     AND WS-ENTRY(1:WS-ENTRY-LENGTH) = WS-ALT(1:WS-ALT-LENGTH)
                 MOVE WS-ID TO L-ID
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CXC-REG-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-ARG-REF.
*> USING argument index of a resource-or-tag argument, registry (PIC X(112)), kind out (1 an entry, 2 a tag with the leading #), id out (the entry of
*> the registry, -1 when it has none), tag out (PIC X(112), the tag's identifier with its namespace, minecraft: when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 01 WS-START               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-COLONS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-REGISTRY             PIC X(112).
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TAG                  PIC X(112).
 PROCEDURE DIVISION USING L-INDEX L-REGISTRY L-KIND L-ID L-TAG.
     MOVE BA-START(L-INDEX) TO WS-START
     COMPUTE WS-LENGTH = BA-END(L-INDEX) - WS-START
     ADD 1 TO WS-START
     MOVE SPACES TO WS-TEXT L-TAG
     MOVE -1 TO L-ID
     MOVE 1 TO L-KIND
     IF BR-R-LINE(WS-START:1) = "#"
         MOVE 2 TO L-KIND
         ADD 1 TO WS-START
         SUBTRACT 1 FROM WS-LENGTH
     END-IF
     COMPUTE WS-LENGTH = FUNCTION MAX(FUNCTION MIN(WS-LENGTH, 100), 1)
     MOVE BR-R-LINE(WS-START:WS-LENGTH) TO WS-TEXT
     IF L-KIND = 1
         CALL "CXC-REG-ID" USING L-REGISTRY WS-TEXT WS-LENGTH L-ID
     ELSE
         MOVE 0 TO WS-COLONS
         INSPECT WS-TEXT(1:WS-LENGTH) TALLYING WS-COLONS FOR ALL ":"
         IF WS-COLONS > 0
             MOVE WS-TEXT TO L-TAG
         ELSE
             STRING "minecraft:" WS-TEXT(1:WS-LENGTH) DELIMITED BY SIZE INTO L-TAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CXC-ARG-REF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-BIOME-MATCH.
*> USING spec kind (0 any biome, 1 the entry spec id, 2 a member of the tag spec tag), spec id, spec tag (PIC X(112)), biome id, result out (1 when the
*> biome matches): the filter of fillbiome and the target of locate biome over the registry minecraft:worldgen/biome.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:worldgen/biome".
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TAG                  PIC X(112).
 01 L-BIOME                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID L-TAG L-BIOME L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE L-KIND
         WHEN 0
             MOVE 1 TO L-RESULT
         WHEN 1
             IF L-BIOME = L-ID
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN OTHER
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY L-TAG L-BIOME L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM CXC-BIOME-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-BIOMES-SEND.
*> USING dimension row, chunk x, chunk z (BINARY-LONG): Chunks Biomes 0x0D (05a) for that one chunk: its ChunkPos and the biome containers of every
*> section from the bottom (the cells of CELLS.cpy), sent to the players whose view holds the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 13.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-TWO-32              BINARY-DOUBLE VALUE 4294967296.
 01 WS-POS                 BINARY-DOUBLE.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG VALUE 64.
 01 WS-STRATEGY            BINARY-LONG VALUE 1.
 01 WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 64 TIMES.
 01 B-MEM                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 64
             COMPUTE WS-CELL = WS-S * 64 + WS-K
             MOVE CE-BIOME(WS-CELL) TO WS-VALUE(WS-K)
         END-PERFORM
         CALL "CHUNK-CONTAINER-ENCODE" USING WK-BUFFER WS-VALUES WS-ENTRIES WS-STRATEGY DM-BIOME-BITS(L-DIM)
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     COMPUTE WS-POS = L-CZ * WS-TWO-32 + FUNCTION MOD(L-CX, WS-TWO-32)
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-POS
     CALL "PB-PUT-VARINT" USING PB-BUFFER WK-LENGTH
     SET ADDRESS OF B-MEM TO WK-ADDR
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-MEM WK-LENGTH
     CALL "VIEWERS-SEND" USING L-DIM L-CX L-CZ WS-NONE PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING WK-BUFFER
     GOBACK.
 END PROGRAM CXC-BIOMES-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-CLONE.
*> clone [from <dim>] <begin> <end> [to <dim>] <destination> [strict] [replace | masked | filtered <predicate>] [force | move | normal] (16 §7.4, level 2). The
*> checks run in the order of the catalog: the boxes may not intersect in one dimension unless the mode is force or move (commands.clone.overlap), the volume
*> may not exceed max_block_modifications (and 65536, the size of the recording table: commands.clone.toobig [max, volume]), every chunk the two boxes touch
*> must be loaded (argument.pos.unloaded; so is a position beyond 30000000 blocks). The accepted source blocks are recorded (replace: all; masked: not air;
*> filtered: the block of the predicate, its properties are not compared), move clears them (air, flags 3, strict 818), then the destination is written in the
*> order of the box (flags 2, strict 818) and the neighbours of every changed position are updated (LEVEL-NEIGHBOURS-ON-SET); inside one dimension the source's
*> scheduled block ticks are copied (BT-COPY-AREA). The result is the number of blocks that changed (commands.clone.success [count], broadcast); none is
*> commands.clone.failed. Not done: the barrier passes, block entities (the world has none), the debug-world refusal and the group order of the writes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-BEGIN          PIC X(32) VALUE "begin".
 01 WS-NAME-END            PIC X(32) VALUE "end".
 01 WS-NAME-DEST           PIC X(32) VALUE "destination".
 01 WS-NAME-SOURCE-DIM     PIC X(32) VALUE "sourceDimension".
 01 WS-NAME-TARGET-DIM     PIC X(32) VALUE "targetDimension".
 01 WS-NAME-FILTER         PIC X(32) VALUE "filter".
 01 WS-NAME-STRICT         PIC X(32) VALUE "strict".
 01 WS-NAME-MASKED         PIC X(32) VALUE "masked".
 01 WS-NAME-FILTERED       PIC X(32) VALUE "filtered".
 01 WS-NAME-FORCE          PIC X(32) VALUE "force".
 01 WS-NAME-MOVE           PIC X(32) VALUE "move".
 01 WS-RULE                PIC X(40) VALUE "max_block_modifications".
 01 WS-BEGIN               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-SOURCE-DIM-ARG      BINARY-LONG.
 01 WS-TARGET-DIM-ARG      BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-MASKED              BINARY-LONG.
 01 WS-FILTERED            BINARY-LONG.
 01 WS-FORCE               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG.
 01 WS-SDIM                BINARY-LONG.
 01 WS-TDIM                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK-ALL              BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-VOLUME              BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BOX-DIM             BINARY-LONG.
 01 WS-BOX-X1              BINARY-LONG.
 01 WS-BOX-Z1              BINARY-LONG.
 01 WS-BOX-X2              BINARY-LONG.
 01 WS-BOX-Z2              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-CLEAR-FLAGS         BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OFF-X               BINARY-LONG.
 01 WS-OFF-Y               BINARY-LONG.
 01 WS-OFF-Z               BINARY-LONG.
 01 WS-RECORDS.
    05 WS-REC              BINARY-LONG OCCURS 65536 TIMES.
 01 WS-OLDS.
    05 WS-OLD-OF           BINARY-LONG OCCURS 65536 TIMES.
 01 WS-KEY                 PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2.

*> The position of WS-IDX in the box (WS-LX, WS-LY, WS-LZ from the box's minimum corner; x runs fastest, then z, then y).
 LOCATE.
     COMPUTE WS-T = WS-IDX - 1
     COMPUTE WS-LX = FUNCTION MOD(WS-T, WS-SX)
     COMPUTE WS-T = (WS-T - WS-LX) / WS-SX
     COMPUTE WS-LZ = FUNCTION MOD(WS-T, WS-SZ)
     COMPUTE WS-LY = (WS-T - WS-LZ) / WS-SZ.

*> Every chunk column of the box (WS-BOX-X1, WS-BOX-Z1) to (WS-BOX-X2, WS-BOX-Z2) of dimension WS-BOX-DIM must be loaded.
 CHECK-BOX.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BOX-X1 / 16)
     COMPUTE WS-CX2 = FUNCTION INTEGER(WS-BOX-X2 / 16)
     COMPUTE WS-CZ2 = FUNCTION INTEGER(WS-BOX-Z2 / 16)
     PERFORM UNTIL WS-CX > WS-CX2
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-BOX-Z1 / 16)
         PERFORM UNTIL WS-CZ > WS-CZ2
             CALL "WORLD-FIND" USING WS-BOX-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW = 0
                 MOVE "argument.pos.unloaded" TO WS-KEY
                 PERFORM FAIL-PLAIN
                 COMPUTE WS-CZ = WS-CZ2 + 1
                 COMPUTE WS-CX = WS-CX2 + 1
             ELSE
                 ADD 1 TO WS-CZ
             END-IF
         END-PERFORM
         ADD 1 TO WS-CX
     END-PERFORM.

*> Record the source position: the state + 1 when the filter accepts it, else 0; the destination's old state is cleared.
 REC-ONE.
     PERFORM LOCATE
     COMPUTE WS-PX = WS-X1 + WS-LX
     COMPUTE WS-PY = WS-Y1 + WS-LY
     COMPUTE WS-PZ = WS-Z1 + WS-LZ
     CALL "WORLD-GET-BLOCK" USING WS-SDIM WS-PX WS-PY WS-PZ WS-OLD
     MOVE 0 TO WS-REC(WS-IDX) WS-OLD-OF(WS-IDX)
     EVALUATE TRUE
         WHEN WS-MASKED > 0 AND WS-OLD = 0
             CONTINUE
         WHEN WS-FILTERED > 0 AND CB-S-BLOCK(WS-OLD + 1) NOT = CB-S-BLOCK(BA-IVAL(WS-FILTER) + 1)
             CONTINUE
         WHEN OTHER
             COMPUTE WS-REC(WS-IDX) = WS-OLD + 1
     END-EVALUATE.

*> Move mode: a recorded source position becomes air.
 CLEAR-ONE.
     PERFORM LOCATE
     IF WS-REC(WS-IDX) > 0
         COMPUTE WS-PX = WS-X1 + WS-LX
         COMPUTE WS-PY = WS-Y1 + WS-LY
         COMPUTE WS-PZ = WS-Z1 + WS-LZ
         CALL "LEVEL-SET-BLOCK" USING WS-SDIM WS-PX WS-PY WS-PZ WS-AIR WS-CLEAR-FLAGS WS-BUDGET WS-CHANGED
     END-IF.

*> The recorded state is written at the destination; a changed position remembers the state it replaced (+ 1).
 WRITE-ONE.
     PERFORM LOCATE
     IF WS-REC(WS-IDX) > 0
         COMPUTE WS-PX = WS-DX + WS-LX
         COMPUTE WS-PY = WS-DY + WS-LY
         COMPUTE WS-PZ = WS-DZ + WS-LZ
         CALL "WORLD-GET-BLOCK" USING WS-TDIM WS-PX WS-PY WS-PZ WS-OLD
         COMPUTE WS-STATE = WS-REC(WS-IDX) - 1
         MOVE 0 TO WS-CHANGED
         CALL "LEVEL-SET-BLOCK" USING WS-TDIM WS-PX WS-PY WS-PZ WS-STATE WS-FLAGS WS-BUDGET WS-CHANGED
         IF WS-CHANGED = 1
             ADD 1 TO WS-COUNT
             COMPUTE WS-OLD-OF(WS-IDX) = WS-OLD + 1
         END-IF
     END-IF.

*> The neighbours of a written position are updated.
 UPDATE-ONE.
     PERFORM LOCATE
     IF WS-OLD-OF(WS-IDX) > 0
         COMPUTE WS-PX = WS-DX + WS-LX
         COMPUTE WS-PY = WS-DY + WS-LY
         COMPUTE WS-PZ = WS-DZ + WS-LZ
         COMPUTE WS-OLD = WS-OLD-OF(WS-IDX) - 1
         CALL "LEVEL-NEIGHBOURS-ON-SET" USING WS-TDIM WS-PX WS-PY WS-PZ WS-OLD
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-BEGIN WS-BEGIN
     CALL "BX-FIND" USING WS-NAME-END WS-END
     CALL "BX-FIND" USING WS-NAME-DEST WS-DEST
     CALL "BX-FIND" USING WS-NAME-SOURCE-DIM WS-SOURCE-DIM-ARG
     CALL "BX-FIND" USING WS-NAME-TARGET-DIM WS-TARGET-DIM-ARG
     CALL "BX-FIND" USING WS-NAME-FILTER WS-FILTER
     CALL "BX-LIT" USING WS-NAME-STRICT WS-STRICT
     CALL "BX-LIT" USING WS-NAME-MASKED WS-MASKED
     CALL "BX-LIT" USING WS-NAME-FILTERED WS-FILTERED
     CALL "BX-LIT" USING WS-NAME-FORCE WS-FORCE
     CALL "BX-LIT" USING WS-NAME-MOVE WS-MOVE
     MOVE BS-DIM TO WS-SDIM WS-TDIM
     IF WS-SOURCE-DIM-ARG > 0
         CALL "CXC-DIM-OF" USING WS-SOURCE-DIM-ARG WS-SDIM
     END-IF
     IF WS-TARGET-DIM-ARG > 0 AND BR-R-FAILED = 0
         CALL "CXC-DIM-OF" USING WS-TARGET-DIM-ARG WS-TDIM
     END-IF
     IF BR-R-FAILED = 0
         CALL "CXC-POS-INT" USING WS-BEGIN WS-X1 WS-Y1 WS-Z1 WS-OK-ALL
         CALL "CXC-POS-INT" USING WS-END WS-X2 WS-Y2 WS-Z2 WS-OK
         COMPUTE WS-OK-ALL = FUNCTION MIN(WS-OK-ALL, WS-OK)
         CALL "CXC-POS-INT" USING WS-DEST WS-DX WS-DY WS-DZ WS-OK
         COMPUTE WS-OK-ALL = FUNCTION MIN(WS-OK-ALL, WS-OK)
         IF WS-OK-ALL = 0
             MOVE "argument.pos.unloaded" TO WS-KEY
             PERFORM FAIL-PLAIN
         END-IF
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
         COMPUTE WS-SX = WS-X2 - WS-X1 + 1
         COMPUTE WS-SY = WS-Y2 - WS-Y1 + 1
         COMPUTE WS-SZ = WS-Z2 - WS-Z1 + 1
         IF WS-FORCE = 0 AND WS-MOVE = 0 AND WS-SDIM = WS-TDIM
                 AND WS-X1 < WS-DX + WS-SX AND WS-DX <= WS-X2
                 AND WS-Y1 < WS-DY + WS-SY AND WS-DY <= WS-Y2
                 AND WS-Z1 < WS-DZ + WS-SZ AND WS-DZ <= WS-Z2
             MOVE "commands.clone.overlap" TO WS-KEY
             PERFORM FAIL-PLAIN
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         COMPUTE WS-VOLUME = WS-SX * WS-SY * WS-SZ
         CALL "BR-RULE-GET" USING WS-RULE WS-MAX
         COMPUTE WS-MAX = FUNCTION MIN(WS-MAX, 65536)
         IF WS-VOLUME > WS-MAX
             MOVE "commands.clone.toobig" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             CALL "CXC-INT-TEXT" USING WS-MAX WS-A1 WS-L1
             CALL "CXC-INT-TEXT" USING WS-VOLUME WS-A2 WS-L2
             CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE WS-SDIM TO WS-BOX-DIM
         MOVE WS-X1 TO WS-BOX-X1
         MOVE WS-Z1 TO WS-BOX-Z1
         MOVE WS-X2 TO WS-BOX-X2
         MOVE WS-Z2 TO WS-BOX-Z2
         PERFORM CHECK-BOX
     END-IF
     IF BR-R-FAILED = 0
         MOVE WS-TDIM TO WS-BOX-DIM
         MOVE WS-DX TO WS-BOX-X1
         MOVE WS-DZ TO WS-BOX-Z1
         COMPUTE WS-BOX-X2 = WS-DX + WS-SX - 1
         COMPUTE WS-BOX-Z2 = WS-DZ + WS-SZ - 1
         PERFORM CHECK-BOX
     END-IF
     IF BR-R-FAILED = 0
         MOVE 2 TO WS-FLAGS
         MOVE 3 TO WS-CLEAR-FLAGS
         IF WS-STRICT > 0
             MOVE 818 TO WS-FLAGS WS-CLEAR-FLAGS
         END-IF
         COMPUTE WS-TOTAL = WS-SX * WS-SY * WS-SZ
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-TOTAL
             PERFORM REC-ONE
         END-PERFORM
         IF WS-MOVE > 0
             PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-TOTAL
                 PERFORM CLEAR-ONE
             END-PERFORM
         END-IF
         PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-TOTAL
             PERFORM WRITE-ONE
         END-PERFORM
         PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > WS-TOTAL
             PERFORM UPDATE-ONE
         END-PERFORM
         IF WS-SDIM = WS-TDIM
             COMPUTE WS-OFF-X = WS-DX - WS-X1
             COMPUTE WS-OFF-Y = WS-DY - WS-Y1
             COMPUTE WS-OFF-Z = WS-DZ - WS-Z1
             CALL "BT-COPY-AREA" USING WS-TDIM WS-X1 WS-Y1 WS-Z1 WS-X2 WS-Y2 WS-Z2 WS-OFF-X WS-OFF-Y WS-OFF-Z
         END-IF
         IF WS-COUNT = 0
             MOVE "commands.clone.failed" TO WS-KEY
             PERFORM FAIL-PLAIN
         ELSE
             MOVE "commands.clone.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-CLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-CLONE.
*> The forms of clone (16 §7.4): the four prefixes (with or without from and to dimensions), strict or not, the filter modes and the move modes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-CLONE.
 01 WS-PATH                PIC X(256).
 01 WS-PTR                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-PREFIXES.
    05 FILLER               PIC X(120) VALUE "clone <begin:pos> <end:pos> <destination:pos>".
    05 FILLER               PIC X(120) VALUE "clone from <sourceDimension:dimension> <begin:pos> <end:pos> <destination:pos>".
    05 FILLER               PIC X(120) VALUE "clone <begin:pos> <end:pos> to <targetDimension:dimension> <destination:pos>".
    05 FILLER               PIC X(120) VALUE "clone from <sourceDimension:dimension> <begin:pos> <end:pos> to <targetDimension:dimension>"
         & " <destination:pos>".
 01 WS-PREFIX-TABLE REDEFINES WS-PREFIXES.
    05 WS-PREFIX            PIC X(120) OCCURS 4 TIMES.
 01 WS-TAILS.
    05 FILLER               PIC X(40) VALUE SPACES.
    05 FILLER               PIC X(40) VALUE " force".
    05 FILLER               PIC X(40) VALUE " move".
    05 FILLER               PIC X(40) VALUE " normal".
    05 FILLER               PIC X(40) VALUE " replace".
    05 FILLER               PIC X(40) VALUE " replace force".
    05 FILLER               PIC X(40) VALUE " replace move".
    05 FILLER               PIC X(40) VALUE " replace normal".
    05 FILLER               PIC X(40) VALUE " masked".
    05 FILLER               PIC X(40) VALUE " masked force".
    05 FILLER               PIC X(40) VALUE " masked move".
    05 FILLER               PIC X(40) VALUE " masked normal".
    05 FILLER               PIC X(40) VALUE " filtered <filter:blockpred>".
    05 FILLER               PIC X(40) VALUE " filtered <filter:blockpred> force".
    05 FILLER               PIC X(40) VALUE " filtered <filter:blockpred> move".
    05 FILLER               PIC X(40) VALUE " filtered <filter:blockpred> normal".
 01 WS-TAIL-TABLE REDEFINES WS-TAILS.
    05 WS-TAIL              PIC X(40) OCCURS 16 TIMES.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 4
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 2
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 16
                 MOVE SPACES TO WS-PATH
                 MOVE 1 TO WS-PTR
                 STRING FUNCTION TRIM(WS-PREFIX(WS-P)) DELIMITED BY SIZE INTO WS-PATH POINTER WS-PTR
                 IF WS-B = 2
                     STRING " strict" DELIMITED BY SIZE INTO WS-PATH POINTER WS-PTR
                 END-IF
                 IF WS-T > 1
                     STRING FUNCTION TRIM(WS-TAIL(WS-T), TRAILING) DELIMITED BY SIZE INTO WS-PATH POINTER WS-PTR
                 END-IF
                 CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CMDS-REG-CLONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-FILLBIOME.
*> fillbiome <from> <to> <biome> [replace <filter>] (16 §7.3, level 2): both corners go down to a multiple of 4 on every axis; the box between them may not
*> exceed max_block_modifications in volume (commands.fillbiome.toobig [max, requested]) and every chunk column of it must be loaded (argument.pos.unloaded; so is a
*> position beyond 30000000 blocks). Each biome cell (4 x 4 x 4 blocks of CELLS.cpy) whose block position, its minimum corner, lies in the box and whose current biome
*> passes the filter (a biome, a #tag of the biome registry, absent: every cell) takes the biome; a cell already of that biome is not counted. A changed chunk is marked
*> unsaved (CK-CHANGED) and its biomes are sent again (CXC-BIOMES-SEND). The result is the number of cells (commands.fillbiome.success.count [count, x1, y1, z1, x2, y2, z2]
*> with the quantised corners as given, broadcast); none is commands.fillbiome.no_changes. Not done: the biomes of a saved chunk (this core writes no biome data;
*> the generator gives them again when the chunk is read back).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY BRRUN.
 COPY PROTO.
 01 WS-NAME-FROM           PIC X(32) VALUE "from".
 01 WS-NAME-TO             PIC X(32) VALUE "to".
 01 WS-NAME-BIOME          PIC X(32) VALUE "biome".
 01 WS-NAME-FILTER         PIC X(32) VALUE "filter".
 01 WS-NAME-REPLACE        PIC X(32) VALUE "replace".
 01 WS-RULE                PIC X(40) VALUE "max_block_modifications".
 01 WS-REGISTRY            PIC X(112) VALUE "minecraft:worldgen/biome".
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-BIOME-ARG           BINARY-LONG.
 01 WS-FILTER-ARG          BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 01 WS-TKIND               BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-TTAG                PIC X(112).
 01 WS-FKIND               BINARY-LONG VALUE 0.
 01 WS-FID                 BINARY-LONG.
 01 WS-FTAG                PIC X(112).
 01 WS-OK                  BINARY-LONG.
 01 WS-OK-ALL              BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-VOLUME              BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CX2                 BINARY-LONG.
 01 WS-CZ2                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CHG-COUNT           BINARY-LONG VALUE 0.
 01 WS-CHG-TABLE.
    05 WS-CHG               OCCURS 1024 TIMES.
       10 WS-CHG-X           BINARY-LONG.
       10 WS-CHG-Z           BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2.

*> The cell at the block position (WS-PX, WS-PY, WS-PZ), when it is inside the dimension: it takes the target biome when its biome passes the filter.
 VISIT-CELL.
     IF WS-PY >= WS-MIN-Y AND WS-PY < WS-MIN-Y + WS-HEIGHT
         COMPUTE WS-CX = FUNCTION INTEGER(WS-PX / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-PZ / 16)
         CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
         SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
         COMPUTE WS-LOCAL = WS-PY - WS-MIN-Y
         COMPUTE WS-CELL = FUNCTION INTEGER(WS-LOCAL / 16) * 64 + 1
         COMPUTE WS-LOCAL = FUNCTION MOD(WS-LOCAL, 16)
         COMPUTE WS-CELL = WS-CELL + FUNCTION INTEGER(WS-LOCAL / 4) * 16
         COMPUTE WS-LOCAL = FUNCTION MOD(WS-PZ, 16)
         COMPUTE WS-CELL = WS-CELL + FUNCTION INTEGER(WS-LOCAL / 4) * 4
         COMPUTE WS-LOCAL = FUNCTION MOD(WS-PX, 16)
         COMPUTE WS-CELL = WS-CELL + FUNCTION INTEGER(WS-LOCAL / 4)
         MOVE CE-BIOME(WS-CELL) TO WS-CURRENT
         IF WS-CURRENT NOT = WS-TARGET
             CALL "CXC-BIOME-MATCH" USING WS-FKIND WS-FID WS-FTAG WS-CURRENT WS-PASS
             IF WS-PASS = 1
                 MOVE WS-TARGET TO CE-BIOME(WS-CELL)
                 ADD 1 TO WS-COUNT
                 MOVE 1 TO CK-CHANGED(WS-ROW)
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-CHG-COUNT
                     IF WS-CHG-X(WS-J) = WS-CX AND WS-CHG-Z(WS-J) = WS-CZ
                         MOVE 1 TO WS-FOUND
                     END-IF
                 END-PERFORM
                 IF WS-FOUND = 0 AND WS-CHG-COUNT < 1024
                     ADD 1 TO WS-CHG-COUNT
                     MOVE WS-CX TO WS-CHG-X(WS-CHG-COUNT)
                     MOVE WS-CZ TO WS-CHG-Z(WS-CHG-COUNT)
                 END-IF
             END-IF
         END-IF
     END-IF.

 MAIN-LINE.
     CALL "BX-FIND" USING WS-NAME-FROM WS-FROM
     CALL "BX-FIND" USING WS-NAME-TO WS-TO
     CALL "BX-FIND" USING WS-NAME-BIOME WS-BIOME-ARG
     CALL "BX-FIND" USING WS-NAME-FILTER WS-FILTER-ARG
     CALL "BX-LIT" USING WS-NAME-REPLACE WS-REPLACE
     CALL "CXC-ARG-REF" USING WS-BIOME-ARG WS-REGISTRY WS-TKIND WS-TARGET WS-TTAG
     MOVE 0 TO WS-FKIND WS-CHG-COUNT
     IF WS-REPLACE > 0
         CALL "CXC-ARG-REF" USING WS-FILTER-ARG WS-REGISTRY WS-FKIND WS-FID WS-FTAG
     END-IF
     MOVE BS-DIM TO WS-DIM
     MOVE DM-MIN-Y(WS-DIM) TO WS-MIN-Y
     MOVE DM-HEIGHT(WS-DIM) TO WS-HEIGHT
     CALL "CXC-POS-INT" USING WS-FROM WS-FX WS-FY WS-FZ WS-OK-ALL
     CALL "CXC-POS-INT" USING WS-TO WS-TX WS-TY WS-TZ WS-OK
     COMPUTE WS-OK-ALL = FUNCTION MIN(WS-OK-ALL, WS-OK)
     IF WS-OK-ALL = 0
         MOVE "argument.pos.unloaded" TO WS-KEY
         PERFORM FAIL-PLAIN
     ELSE
         COMPUTE WS-FX = FUNCTION INTEGER(WS-FX / 4) * 4
         COMPUTE WS-FY = FUNCTION INTEGER(WS-FY / 4) * 4
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-FZ / 4) * 4
         COMPUTE WS-TX = FUNCTION INTEGER(WS-TX / 4) * 4
         COMPUTE WS-TY = FUNCTION INTEGER(WS-TY / 4) * 4
         COMPUTE WS-TZ = FUNCTION INTEGER(WS-TZ / 4) * 4
         COMPUTE WS-X1 = FUNCTION MIN(WS-FX, WS-TX)
         COMPUTE WS-Y1 = FUNCTION MIN(WS-FY, WS-TY)
         COMPUTE WS-Z1 = FUNCTION MIN(WS-FZ, WS-TZ)
         COMPUTE WS-X2 = FUNCTION MAX(WS-FX, WS-TX)
         COMPUTE WS-Y2 = FUNCTION MAX(WS-FY, WS-TY)
         COMPUTE WS-Z2 = FUNCTION MAX(WS-FZ, WS-TZ)
         COMPUTE WS-VOLUME = (WS-X2 - WS-X1 + 1) * (WS-Y2 - WS-Y1 + 1) * (WS-Z2 - WS-Z1 + 1)
         CALL "BR-RULE-GET" USING WS-RULE WS-MAX
         IF WS-VOLUME > WS-MAX
             MOVE "commands.fillbiome.toobig" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             CALL "CXC-INT-TEXT" USING WS-MAX WS-A1 WS-L1
             CALL "CXC-INT-TEXT" USING WS-VOLUME WS-A2 WS-L2
             CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         COMPUTE WS-CX = FUNCTION INTEGER(WS-X1 / 16)
         COMPUTE WS-CX2 = FUNCTION INTEGER(WS-X2 / 16)
         COMPUTE WS-CZ2 = FUNCTION INTEGER(WS-Z2 / 16)
         PERFORM UNTIL WS-CX > WS-CX2
             COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z1 / 16)
             PERFORM UNTIL WS-CZ > WS-CZ2
                 CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
                 IF WS-ROW = 0
                     MOVE "argument.pos.unloaded" TO WS-KEY
                     PERFORM FAIL-PLAIN
                     COMPUTE WS-CZ = WS-CZ2 + 1
                     COMPUTE WS-CX = WS-CX2 + 1
                 ELSE
                     ADD 1 TO WS-CZ
                 END-IF
             END-PERFORM
             ADD 1 TO WS-CX
         END-PERFORM
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-PY FROM WS-Y1 BY 4 UNTIL WS-PY > WS-Y2
             PERFORM VARYING WS-PX FROM WS-X1 BY 4 UNTIL WS-PX > WS-X2
                 PERFORM VARYING WS-PZ FROM WS-Z1 BY 4 UNTIL WS-PZ > WS-Z2
                     PERFORM VISIT-CELL
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         IF WS-COUNT = 0
             MOVE "commands.fillbiome.no_changes" TO WS-KEY
             PERFORM FAIL-PLAIN
         ELSE
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-CHG-COUNT
                 CALL "CXC-BIOMES-SEND" USING WS-DIM WS-CHG-X(WS-J) WS-CHG-Z(WS-J)
             END-PERFORM
             MOVE "commands.fillbiome.success.count" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-COUNT
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-FX
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-FY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-FZ
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TX
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-TZ
             CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
             MOVE WS-COUNT TO BR-R-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CX-FILLBIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-FILLBIOME.
*> The forms of fillbiome (16 §7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-FILLBIOME.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "fillbiome <from:pos> <to:pos> <biome:biome>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "fillbiome <from:pos> <to:pos> <biome:biome> replace <filter:biomeortag>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-FILLBIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-COLPOS.
*> USING argument index of a column position (colpos) argument, x out, z out (BINARY-DOUBLE): the block x and z of it (a relative component is the
*> source's block coordinate plus the offset).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRRUN.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-DOUBLE.
 01 L-Z                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-INDEX L-X L-Z.
     COMPUTE L-X = FUNCTION INTEGER(BA-NUM(L-INDEX, 1))
     COMPUTE L-Z = FUNCTION INTEGER(BA-NUM(L-INDEX, 2))
     IF BA-KIND(L-INDEX, 1) = 1
         COMPUTE L-X = L-X + FUNCTION INTEGER(BS-X)
     END-IF
     IF BA-KIND(L-INDEX, 2) = 1
         COMPUTE L-Z = L-Z + FUNCTION INTEGER(BS-Z)
     END-IF
     GOBACK.
 END PROGRAM CXC-COLPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-FORCELOAD.
*> forceload add <from> [<to>] | remove <from> [<to>] | remove all | query [<pos>] (16 §7.6, level 2). The chunks of the box of the two column positions (at
*> most 256: commands.forceload.toobig [256, count]; x and z in [-30000000, 30000000), else argument.pos.outofworld) are marked or unmarked in BR-FORCE (BRFORCE.cpy; a
*> marked chunk is loaded at once, WORLD-CHUNK); the result is the number of chunks that changed and none changed is commands.forceload.added.failure or .removed.failure.
*> The success messages (broadcast) show chunk positions as [x, z] and the dimension's key; one chunk changed is the .single form (the chunk of the first column), else the
*> .multiple form with the count and the corner chunks of the box. remove all unmarks the chunks of the dimension (result 0). query <pos> is quiet: marked is
*> commands.forceload.query.success (result 1), else commands.forceload.query.failure [chunk, dimension]; query alone lists the marked chunks of the dimension
*> (list.single or list.multiple, quiet, the result is their number), none is the failure message commands.forceload.added.none (result 0). Not done: a marked chunk
*> is not kept in the cache by the chunk unloader (chunk feed is not edited by this lane) and the marks are not saved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BRRUN.
 COPY BRFORCE.
 COPY PROTO.
 01 WS-NAME-ADD            PIC X(32) VALUE "add".
 01 WS-NAME-REMOVE         PIC X(32) VALUE "remove".
 01 WS-NAME-QUERY          PIC X(32) VALUE "query".
 01 WS-NAME-ALL            PIC X(32) VALUE "all".
 01 WS-NAME-FROM           PIC X(32) VALUE "from".
 01 WS-NAME-TO             PIC X(32) VALUE "to".
 01 WS-NAME-POS            PIC X(32) VALUE "pos".
 01 WS-ADD                 BINARY-LONG.
 01 WS-REMOVE              BINARY-LONG.
 01 WS-QUERY               BINARY-LONG.
 01 WS-ALL                 BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-DIM-TEXT            PIC X(64).
 01 WS-DIM-LENGTH          BINARY-LONG.
 01 WS-X1                  BINARY-DOUBLE.
 01 WS-Z1                  BINARY-DOUBLE.
 01 WS-X2                  BINARY-DOUBLE.
 01 WS-Z2                  BINARY-DOUBLE.
 01 WS-VOLUME              BINARY-DOUBLE.
 01 WS-MAX                 BINARY-DOUBLE VALUE 256.
 01 WS-FCX                 BINARY-LONG.
 01 WS-FCZ                 BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-LIST                PIC X(1024).
 01 WS-LIST-PTR            BINARY-LONG.
 01 WS-LIST-LENGTH         BINARY-LONG.
 01 WS-CHUNK-TEXT          PIC X(64).
 01 WS-CHUNK-LENGTH        BINARY-LONG.
 01 WS-CHUNK-TEXT-2        PIC X(64).
 01 WS-CHUNK-LENGTH-2      BINARY-LONG.
 01 WS-KEY                 PIC X(72).
 01 WS-BASE                PIC X(72).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-BROADCAST           BINARY-LONG VALUE 1.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

*> The failure WS-KEY with no arguments.
 FAIL-PLAIN.
     MOVE 0 TO WS-N-ARGS
     MOVE SPACES TO WS-A1 WS-A2
     CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2.

*> WS-AT: the entry of BR-FORCE of the chunk (BS-DIM, WS-CX, WS-CZ), 0 when it is not marked.
 FIND-ENTRY.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BF-COUNT OR WS-AT > 0
         IF BF-DIM(WS-J) = BS-DIM AND BF-X(WS-J) = WS-CX AND BF-Z(WS-J) = WS-CZ
             MOVE WS-J TO WS-AT
         END-IF
     END-PERFORM.

*> The entry WS-AT is removed; the later entries keep their order.
 DELETE-ENTRY.
     PERFORM VARYING WS-J FROM WS-AT BY 1 UNTIL WS-J >= BF-COUNT
         MOVE BF-ENTRY(WS-J + 1) TO BF-ENTRY(WS-J)
     END-PERFORM
     SUBTRACT 1 FROM BF-COUNT.

*> WS-X1 .. WS-Z2 must lie inside the world.
 CHECK-WORLD.
     IF WS-X1 < -30000000 OR WS-X1 >= 30000000 OR WS-Z1 < -30000000 OR WS-Z1 >= 30000000
             OR WS-X2 < -30000000 OR WS-X2 >= 30000000 OR WS-Z2 < -30000000 OR WS-Z2 >= 30000000
         MOVE "argument.pos.outofworld" TO WS-KEY
         PERFORM FAIL-PLAIN
     END-IF.

*> The chunk (WS-CX, WS-CZ) as text in WS-CHUNK-TEXT.
 CHUNK-AS-TEXT.
     CALL "CXC-CHUNK-TEXT" USING WS-CX WS-CZ WS-CHUNK-TEXT WS-CHUNK-LENGTH.

*> add and remove: the box of the two columns.
 CHANGE.
     CALL "CXC-COLPOS" USING WS-FROM WS-X1 WS-Z1
     MOVE WS-X1 TO WS-X2
     MOVE WS-Z1 TO WS-Z2
     IF WS-TO > 0
         CALL "CXC-COLPOS" USING WS-TO WS-X2 WS-Z2
     END-IF
     PERFORM CHECK-WORLD
     IF BR-R-FAILED = 0
         COMPUTE WS-FCX = FUNCTION INTEGER(WS-X1 / 16)
         COMPUTE WS-FCZ = FUNCTION INTEGER(WS-Z1 / 16)
         COMPUTE WS-MINX = FUNCTION INTEGER(FUNCTION MIN(WS-X1, WS-X2) / 16)
         COMPUTE WS-MAXX = FUNCTION INTEGER(FUNCTION MAX(WS-X1, WS-X2) / 16)
         COMPUTE WS-MINZ = FUNCTION INTEGER(FUNCTION MIN(WS-Z1, WS-Z2) / 16)
         COMPUTE WS-MAXZ = FUNCTION INTEGER(FUNCTION MAX(WS-Z1, WS-Z2) / 16)
         COMPUTE WS-VOLUME = (WS-MAXX - WS-MINX + 1) * (WS-MAXZ - WS-MINZ + 1)
         IF WS-VOLUME > WS-MAX
             MOVE "commands.forceload.toobig" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE SPACES TO WS-A1 WS-A2
             CALL "CXC-INT-TEXT" USING WS-MAX WS-A1 WS-L1
             CALL "CXC-INT-TEXT" USING WS-VOLUME WS-A2 WS-L2
             CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE 0 TO WS-CHANGED
         PERFORM VARYING WS-CX FROM WS-MINX BY 1 UNTIL WS-CX > WS-MAXX
             PERFORM VARYING WS-CZ FROM WS-MINZ BY 1 UNTIL WS-CZ > WS-MAXZ
                 PERFORM FIND-ENTRY
                 IF WS-ADD > 0
                     IF WS-AT = 0 AND BF-COUNT < BF-MAX
                         ADD 1 TO BF-COUNT
                         MOVE BS-DIM TO BF-DIM(BF-COUNT)
                         MOVE WS-CX TO BF-X(BF-COUNT)
                         MOVE WS-CZ TO BF-Z(BF-COUNT)
                         CALL "WORLD-CHUNK" USING BS-DIM WS-CX WS-CZ WS-ROW
                         ADD 1 TO WS-CHANGED
                     END-IF
                 ELSE
                     IF WS-AT > 0
                         PERFORM DELETE-ENTRY
                         ADD 1 TO WS-CHANGED
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
         IF WS-CHANGED = 0 AND WS-ADD > 0
             MOVE "commands.forceload.added.failure" TO WS-KEY
             PERFORM FAIL-PLAIN
         END-IF
         IF WS-CHANGED = 0 AND WS-ADD = 0
             MOVE "commands.forceload.removed.failure" TO WS-KEY
             PERFORM FAIL-PLAIN
         END-IF
     END-IF
     IF BR-R-FAILED = 0
         MOVE "commands.forceload.removed" TO WS-BASE
         IF WS-ADD > 0
             MOVE "commands.forceload.added" TO WS-BASE
         END-IF
         MOVE SPACES TO WS-KEY
         IF WS-CHANGED = 1
             STRING FUNCTION TRIM(WS-BASE) ".single" DELIMITED BY SIZE INTO WS-KEY
             MOVE WS-FCX TO WS-CX
             MOVE WS-FCZ TO WS-CZ
             PERFORM CHUNK-AS-TEXT
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CHUNK-TEXT WS-CHUNK-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
         ELSE
             STRING FUNCTION TRIM(WS-BASE) ".multiple" DELIMITED BY SIZE INTO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-CHANGED
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
             MOVE WS-MINX TO WS-CX
             MOVE WS-MINZ TO WS-CZ
             PERFORM CHUNK-AS-TEXT
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CHUNK-TEXT WS-CHUNK-LENGTH
             MOVE WS-MAXX TO WS-CX
             MOVE WS-MAXZ TO WS-CZ
             PERFORM CHUNK-AS-TEXT
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CHUNK-TEXT WS-CHUNK-LENGTH
         END-IF
         CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
         MOVE WS-CHANGED TO BR-R-RESULT
     END-IF.

*> remove all: every chunk of the dimension is unmarked.
 REMOVE-ALL.
     MOVE 0 TO WS-K
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BF-COUNT
         IF BF-DIM(WS-J) NOT = BS-DIM
             ADD 1 TO WS-K
             MOVE BF-ENTRY(WS-J) TO BF-ENTRY(WS-K)
         END-IF
     END-PERFORM
     MOVE WS-K TO BF-COUNT
     MOVE "commands.forceload.removed.all" TO WS-KEY
     CALL "BX-KEY" USING PB-TEXT WS-KEY
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
     CALL "BR-FEEDBACK" USING PB-TEXT WS-BROADCAST
     MOVE 0 TO BR-R-RESULT.

*> query <pos>: is the chunk marked.
 QUERY-ONE.
     CALL "CXC-COLPOS" USING WS-POS WS-X1 WS-Z1
     MOVE WS-X1 TO WS-X2
     MOVE WS-Z1 TO WS-Z2
     PERFORM CHECK-WORLD
     IF BR-R-FAILED = 0
         COMPUTE WS-CX = FUNCTION INTEGER(WS-X1 / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z1 / 16)
         PERFORM FIND-ENTRY
         PERFORM CHUNK-AS-TEXT
         IF WS-AT > 0
             MOVE "commands.forceload.query.success" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CHUNK-TEXT WS-CHUNK-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
             MOVE 1 TO BR-R-RESULT
         ELSE
             MOVE "commands.forceload.query.failure" TO WS-KEY
             MOVE 2 TO WS-N-ARGS
             MOVE WS-CHUNK-TEXT TO WS-A1
             MOVE WS-CHUNK-LENGTH TO WS-L1
             MOVE WS-DIM-TEXT TO WS-A2
             MOVE WS-DIM-LENGTH TO WS-L2
             CALL "CXC-FAIL" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2
         END-IF
     END-IF.

*> query alone: the marked chunks of the dimension.
 QUERY-LIST.
     MOVE 0 TO WS-K
     MOVE 1 TO WS-LIST-PTR
     MOVE SPACES TO WS-LIST
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BF-COUNT
         IF BF-DIM(WS-J) = BS-DIM
             ADD 1 TO WS-K
             MOVE BF-X(WS-J) TO WS-CX
             MOVE BF-Z(WS-J) TO WS-CZ
             PERFORM CHUNK-AS-TEXT
             IF WS-K = 1
                 MOVE WS-CHUNK-TEXT TO WS-CHUNK-TEXT-2
                 MOVE WS-CHUNK-LENGTH TO WS-CHUNK-LENGTH-2
             END-IF
             IF WS-LIST-PTR < 960
                 IF WS-K > 1
                     STRING ", " DELIMITED BY SIZE INTO WS-LIST POINTER WS-LIST-PTR
                 END-IF
                 STRING WS-CHUNK-TEXT(1:WS-CHUNK-LENGTH) DELIMITED BY SIZE INTO WS-LIST POINTER WS-LIST-PTR
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-LIST-LENGTH = WS-LIST-PTR - 1
     EVALUATE WS-K
         WHEN 0
             MOVE "commands.forceload.added.none" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
             CALL "BR-FAILURE" USING PB-TEXT
         WHEN 1
             MOVE "commands.forceload.list.single" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-CHUNK-TEXT-2 WS-CHUNK-LENGTH-2
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
         WHEN OTHER
             MOVE "commands.forceload.list.multiple" TO WS-KEY
             CALL "BX-KEY" USING PB-TEXT WS-KEY
             CALL "CMD-TEXT-INT" USING PB-TEXT WS-K
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-DIM-TEXT WS-DIM-LENGTH
             CALL "CMD-TEXT-ARG" USING PB-TEXT WS-LIST WS-LIST-LENGTH
             CALL "BR-FEEDBACK" USING PB-TEXT WS-QUIET
     END-EVALUATE
     MOVE WS-K TO BR-R-RESULT.

 MAIN-LINE.
     CALL "BX-LIT" USING WS-NAME-ADD WS-ADD
     CALL "BX-LIT" USING WS-NAME-REMOVE WS-REMOVE
     CALL "BX-LIT" USING WS-NAME-QUERY WS-QUERY
     CALL "BX-LIT" USING WS-NAME-ALL WS-ALL
     CALL "BX-FIND" USING WS-NAME-FROM WS-FROM
     CALL "BX-FIND" USING WS-NAME-TO WS-TO
     CALL "BX-FIND" USING WS-NAME-POS WS-POS
     MOVE SPACES TO WS-DIM-TEXT
     MOVE DM-KEY(BS-DIM) TO WS-DIM-TEXT
     MOVE DM-KEY-LENGTH(BS-DIM) TO WS-DIM-LENGTH
     EVALUATE TRUE
         WHEN WS-ALL > 0
             PERFORM REMOVE-ALL
         WHEN WS-QUERY > 0 AND WS-POS > 0
             PERFORM QUERY-ONE
         WHEN WS-QUERY > 0
             PERFORM QUERY-LIST
         WHEN OTHER
             PERFORM CHANGE
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-FORCELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMDS-REG-FORCELOAD.
*> The forms of forceload (16 §7.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 01 WS-LEVEL               BINARY-LONG VALUE 2.
 01 WS-COMMAND             BINARY-LONG VALUE BC-FORCELOAD.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     MOVE "forceload add <from:colpos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload add <from:colpos> <to:colpos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload remove <from:colpos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload remove <from:colpos> <to:colpos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload remove all" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload query" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     MOVE "forceload query <pos:colpos>" TO WS-PATH
     CALL "BR-REG" USING WS-LEVEL WS-COMMAND WS-PATH
     GOBACK.
 END PROGRAM CMDS-REG-FORCELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CX-DISPATCH-C.
*> The commands of the lane cmds-c that BR-CMD-CALL and CX-DISPATCH-A do not name: any other command id is help.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCMD.
 COPY BRRUN.
 PROCEDURE DIVISION.
     EVALUATE BR-R-COMMAND
         WHEN BC-CLONE
             CALL "CX-CLONE"
         WHEN BC-FILLBIOME
             CALL "CX-FILLBIOME"
         WHEN BC-FORCELOAD
             CALL "CX-FORCELOAD"
         WHEN OTHER
             CALL "CX-HELP"
     END-EVALUATE
     GOBACK.
 END PROGRAM CX-DISPATCH-C.
