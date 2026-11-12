*> The text and NBT argument types of docs/protocol/15-commands-framework.md §9.3 to §9.5: component (18) and style (19), which parse an
*> SNBT value (the text-component codec is applied at execution), nbt_compound_tag (21), nbt_tag (22) and nbt_path (23).
*> Entry points: BR-ARG-NBT USING node; BR-ARG-NBT-PATH. Failures set BR-E-KEY; the cursor is left after the value.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-KIND                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N                   BINARY-LONG VALUE 0.
 01 WS-L                   BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE.
     MOVE BR-IN-CURSOR TO WS-START
     CALL "BR-SNBT-VALUE" USING WS-KIND
     IF BR-E-KEY = SPACES AND BR-N-TYPE(L-NODE) = BR-P-NBT-COMPOUND AND WS-KIND NOT = 1
         MOVE "argument.nbt.expected.compound" TO WS-KEY
         CALL "BR-RAISE" USING WS-KEY WS-N WS-A1 WS-L WS-A2 WS-L2 WS-START
     END-IF
     GOBACK.
 END PROGRAM BR-ARG-NBT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-NBT-PATH.
*> path := node { [.] node }, ended by a space or the end; a node is { (first only), [ {compound} | ] | int ], a quoted
*> string or an unquoted name, each optionally followed by a compound filter.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-KIND                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-STR                 PIC X(1024).
 01 WS-STR-LENGTH          BINARY-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-KIND-INT            BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N                   BINARY-LONG.
 01 WS-L1                  BINARY-LONG.
 01 WS-L2                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 PROCEDURE DIVISION.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

 RAISE-INVALID.
     MOVE "arguments.nbtpath.node.invalid" TO WS-KEY
     MOVE 0 TO WS-N WS-L1 WS-L2
     MOVE BR-IN-CURSOR TO WS-RC
     PERFORM RAISE-NOW.

 RAISE-EXPECTED.
     MOVE "parsing.expected" TO WS-KEY
     MOVE 1 TO WS-N
     MOVE WS-CH TO WS-A1(1:1)
     MOVE 1 TO WS-L1
     MOVE 0 TO WS-L2
     MOVE BR-IN-CURSOR TO WS-RC
     PERFORM RAISE-NOW.

 ONE-NODE.
     MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
     EVALUATE TRUE
         WHEN WS-CH = "{"
             IF WS-FIRST = 1
                 CALL "BR-SNBT-VALUE" USING WS-KIND
             ELSE
                 PERFORM RAISE-INVALID
             END-IF
         WHEN WS-CH = "["
             PERFORM INDEX-NODE
         WHEN OTHER
             PERFORM NAME-NODE
     END-EVALUATE.

 INDEX-NODE.
     ADD 1 TO BR-IN-CURSOR
     EVALUATE TRUE
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
             CALL "BR-SNBT-VALUE" USING WS-KIND
         WHEN BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             CONTINUE
         WHEN OTHER
             CALL "BR-READ-PLAIN" USING WS-KIND-INT WS-INT WS-DOUBLE WS-INF
     END-EVALUATE
     IF BR-E-KEY = SPACES
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "]"
             ADD 1 TO BR-IN-CURSOR
         ELSE
             MOVE "]" TO WS-CH
             PERFORM RAISE-EXPECTED
         END-IF
     END-IF.

*> A quoted string or an unquoted name (not space " ' [ ] . { }), then an optional compound filter.
 NAME-NODE.
     IF WS-CH = '"' OR WS-CH = "'"
         MOVE BR-IN-CURSOR TO WS-C
         CALL "BR-READ-STRING" USING WS-ONE WS-C WS-STR WS-STR-LENGTH
         IF BR-E-KEY = SPACES
             MOVE WS-C TO BR-IN-CURSOR
         END-IF
     ELSE
         MOVE BR-IN-CURSOR TO WS-C
         PERFORM UNTIL WS-C >= BR-IN-LENGTH
             MOVE BR-IN-TEXT(WS-C + 1:1) TO WS-CH
             IF WS-CH = SPACE OR WS-CH = '"' OR WS-CH = "'" OR WS-CH = "[" OR WS-CH = "]"
                     OR WS-CH = "." OR WS-CH = "{" OR WS-CH = "}"
                 EXIT PERFORM
             END-IF
             ADD 1 TO WS-C
         END-PERFORM
         IF WS-C = BR-IN-CURSOR
             PERFORM RAISE-INVALID
         ELSE
             MOVE WS-C TO BR-IN-CURSOR
         END-IF
     END-IF
     IF BR-E-KEY = SPACES AND BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "{"
         CALL "BR-SNBT-VALUE" USING WS-KIND
     END-IF.

 MAIN-LINE.
     MOVE 1 TO WS-FIRST
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1 OR BR-E-KEY NOT = SPACES
         PERFORM ONE-NODE
         MOVE 0 TO WS-FIRST
         IF BR-E-KEY = SPACES
             IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = SPACE
                 MOVE 1 TO WS-DONE
             ELSE
                 MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
                 EVALUATE TRUE
                     WHEN WS-CH = "."
                         ADD 1 TO BR-IN-CURSOR
                     WHEN WS-CH = "[" OR WS-CH = "{"
                         CONTINUE
                     WHEN OTHER
                         MOVE "." TO WS-CH
                         PERFORM RAISE-EXPECTED
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BR-ARG-NBT-PATH.
