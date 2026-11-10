*> The coordinate argument types of docs/protocol/15-commands-framework.md §8: block_pos (8), column_pos (9), vec3 (10),
*> vec2 (11), rotation (29), angle (28) and swizzle (32). Each coordinate component is absolute (a number), relative
*> (~ or ~N) or local (^ or ^N); world and local forms cannot be mixed (argument.pos.mixed). Components are separated by one
*> space; a missing or malformed separator after a component other than the last resets the cursor to the start of the
*> argument and raises the type's incomplete exception. Parsing is purely syntactic: the value is the kind and number of each
*> component (resolving it against the executing source and the loaded-chunk and world-border checks of §8.2 belong to the
*> command).
*>
*> The value left in BR-VAL (core/copy/BRIGADIER.cpy): BR-V-KIND(k) 0 absolute, 1 relative, 2 local and BR-V-NUM(k) the number of
*> component k, in the text order (rotation: yaw then pitch). A vec3 absolute x and z without a decimal point carry the
*> centre correction + 0.5 (§8.2); block and column positions read absolute components as integers. angle: kind 0 or 1 and the
*> degrees in component 1. swizzle: the integer value is the axis set, x 1, y 2, z 4.
*>
*> Entry point: BR-ARG-COORD USING node, integer out, double out, infinity flag out (as BR-ARG-EXT)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ARG-COORD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRIGADIER.
 01 WS-START               BINARY-LONG.
 01 WS-COMP-START          BINARY-LONG.
 01 WS-NCOMP               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-INT-MODE            BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-CENTER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HAS-DOT             BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-A1                  PIC X(64).
 01 WS-A2                  PIC X(64).
 01 WS-N-ARGS              BINARY-LONG VALUE 0.
 01 WS-L1                  BINARY-LONG VALUE 0.
 01 WS-L2                  BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-KIND-INT            BINARY-LONG VALUE 3.
 01 WS-KIND-FLOAT          BINARY-LONG VALUE 1.
 01 WS-KIND-DOUBLE         BINARY-LONG VALUE 2.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-INF                 BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-MASK                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-INT                  BINARY-DOUBLE.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-INF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-INT L-DOUBLE L-INF.
     GO TO MAIN-LINE.

 RAISE-NOW.
     CALL "BR-RAISE" USING WS-KEY WS-N-ARGS WS-A1 WS-L1 WS-A2 WS-L2 WS-RC.

*> One component of the world form from the cursor into component WS-K.
 WORLD-COMPONENT.
     MOVE BR-IN-CURSOR TO WS-COMP-START
     EVALUATE TRUE
         WHEN BR-IN-CURSOR >= BR-IN-LENGTH
             IF WS-INT-MODE = 1
                 MOVE "argument.pos.missing.int" TO WS-KEY
             ELSE
                 MOVE "argument.pos.missing.double" TO WS-KEY
             END-IF
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-NOW
         WHEN BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "^"
             MOVE "argument.pos.mixed" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-NOW
         WHEN OTHER
             PERFORM WORLD-NUMBER
     END-EVALUATE.

 WORLD-NUMBER.
     MOVE 0 TO WS-REL WS-DOUBLE
     IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "~"
         MOVE 1 TO WS-REL
         ADD 1 TO BR-IN-CURSOR
     END-IF
     IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
         IF WS-INT-MODE = 1 AND WS-REL = 0
             CALL "BR-READ-PLAIN" USING WS-KIND-INT WS-INT WS-DOUBLE WS-INF
             IF BR-E-KEY = SPACES
                 MOVE WS-INT TO WS-DOUBLE
             END-IF
         ELSE
             CALL "BR-READ-PLAIN" USING WS-KIND-DOUBLE WS-INT WS-DOUBLE WS-INF
         END-IF
     END-IF
     IF BR-E-KEY = SPACES
         MOVE 0 TO WS-HAS-DOT
         PERFORM VARYING WS-I FROM WS-COMP-START BY 1 UNTIL WS-I >= BR-IN-CURSOR
             IF BR-IN-TEXT(WS-I + 1:1) = "."
                 MOVE 1 TO WS-HAS-DOT
             END-IF
         END-PERFORM
         IF WS-CENTER = 1 AND WS-REL = 0 AND WS-HAS-DOT = 0
             COMPUTE WS-DOUBLE = WS-DOUBLE + 0.5
         END-IF
         MOVE WS-REL TO BR-V-KIND(WS-K)
         MOVE WS-DOUBLE TO BR-V-NUM(WS-K)
     END-IF.

*> One component of the local form: ^ then an optional number.
 LOCAL-COMPONENT.
     IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = "^"
         MOVE "argument.pos.mixed" TO WS-KEY
         MOVE BR-IN-CURSOR TO WS-RC
         PERFORM RAISE-NOW
     ELSE
         ADD 1 TO BR-IN-CURSOR
         MOVE 0 TO WS-DOUBLE
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
             CALL "BR-READ-PLAIN" USING WS-KIND-DOUBLE WS-INT WS-DOUBLE WS-INF
         END-IF
         IF BR-E-KEY = SPACES
             MOVE 2 TO BR-V-KIND(WS-K)
             MOVE WS-DOUBLE TO BR-V-NUM(WS-K)
         END-IF
     END-IF.

*> After a component that is not the last: exactly one space, else the type's incomplete exception at the start.
 SEPARATOR.
     IF BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
         EVALUATE BR-N-TYPE(L-NODE)
             WHEN BR-P-ROTATION
                 MOVE "argument.rotation.incomplete" TO WS-KEY
             WHEN BR-P-VEC2
             WHEN BR-P-COLUMN-POS
                 MOVE "argument.pos2d.incomplete" TO WS-KEY
             WHEN OTHER
                 MOVE "argument.pos3d.incomplete" TO WS-KEY
         END-EVALUATE
         MOVE WS-START TO WS-RC
         PERFORM RAISE-NOW
     ELSE
         ADD 1 TO BR-IN-CURSOR
     END-IF.

 DO-POSITION.
     MOVE 2 TO WS-NCOMP
     MOVE 0 TO WS-INT-MODE WS-LOCAL
     IF BR-N-TYPE(L-NODE) = BR-P-BLOCK-POS OR BR-N-TYPE(L-NODE) = BR-P-VEC3
         MOVE 3 TO WS-NCOMP
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "^"
             MOVE 1 TO WS-LOCAL
         END-IF
     END-IF
     IF BR-N-TYPE(L-NODE) = BR-P-BLOCK-POS OR BR-N-TYPE(L-NODE) = BR-P-COLUMN-POS
         MOVE 1 TO WS-INT-MODE
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NCOMP OR BR-E-KEY NOT = SPACES
         MOVE 0 TO WS-CENTER
         IF BR-N-TYPE(L-NODE) = BR-P-VEC3 AND WS-K NOT = 2
             MOVE 1 TO WS-CENTER
         END-IF
         IF WS-LOCAL = 1
             PERFORM LOCAL-COMPONENT
         ELSE
             PERFORM WORLD-COMPONENT
         END-IF
         IF BR-E-KEY = SPACES AND WS-K < WS-NCOMP
             PERFORM SEPARATOR
         END-IF
     END-PERFORM.

*> angle: an optional ~ and a float; a value that is not finite is argument.angle.invalid.
 DO-ANGLE.
     IF BR-IN-CURSOR >= BR-IN-LENGTH
         MOVE "argument.angle.incomplete" TO WS-KEY
         MOVE BR-IN-CURSOR TO WS-RC
         PERFORM RAISE-NOW
     ELSE
         MOVE 0 TO WS-REL WS-DOUBLE
         MOVE BR-IN-CURSOR TO WS-COMP-START
         IF BR-IN-TEXT(BR-IN-CURSOR + 1:1) = "~"
             MOVE 1 TO WS-REL
             ADD 1 TO BR-IN-CURSOR
         END-IF
         IF BR-IN-CURSOR < BR-IN-LENGTH AND BR-IN-TEXT(BR-IN-CURSOR + 1:1) NOT = SPACE
             CALL "BR-READ-PLAIN" USING WS-KIND-FLOAT WS-INT WS-DOUBLE WS-INF
             IF BR-E-KEY = "argument.float.big" OR BR-E-KEY = "argument.float.low"
                 PERFORM NOT-FINITE
             END-IF
         END-IF
         IF BR-E-KEY = SPACES
             MOVE WS-REL TO BR-V-KIND(1)
             MOVE WS-DOUBLE TO BR-V-NUM(1)
         END-IF
     END-IF.

*> The float run is past the largest finite float: the cursor goes after the run.
 NOT-FINITE.
     MOVE BR-E-CURSOR TO WS-RC
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-RC >= BR-IN-LENGTH OR WS-DONE = 1
         MOVE BR-IN-TEXT(WS-RC + 1:1) TO WS-CH
         IF (WS-CH >= "0" AND WS-CH <= "9") OR WS-CH = "." OR WS-CH = "-"
             ADD 1 TO WS-RC
         ELSE
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     MOVE "argument.angle.invalid" TO WS-KEY
     MOVE 0 TO WS-N-ARGS
     PERFORM RAISE-NOW.

*> swizzle: the letters x y z each at most once up to the next space.
 DO-SWIZZLE.
     MOVE 0 TO WS-MASK WS-DONE
     PERFORM UNTIL BR-IN-CURSOR >= BR-IN-LENGTH OR BR-IN-TEXT(BR-IN-CURSOR + 1:1) = SPACE OR WS-DONE = 1
         MOVE BR-IN-TEXT(BR-IN-CURSOR + 1:1) TO WS-CH
         ADD 1 TO BR-IN-CURSOR
         MOVE 0 TO WS-BIT
         EVALUATE WS-CH
             WHEN "x"
                 MOVE 1 TO WS-BIT
             WHEN "y"
                 MOVE 2 TO WS-BIT
             WHEN "z"
                 MOVE 4 TO WS-BIT
         END-EVALUATE
         MOVE 0 TO WS-SEEN
         IF WS-BIT > 0
             DIVIDE WS-MASK BY WS-BIT GIVING WS-QUOTIENT
             COMPUTE WS-SEEN = FUNCTION MOD(WS-QUOTIENT, 2)
         END-IF
         IF WS-BIT = 0 OR WS-SEEN = 1
             MOVE "arguments.swizzle.invalid" TO WS-KEY
             MOVE BR-IN-CURSOR TO WS-RC
             PERFORM RAISE-NOW
             MOVE 1 TO WS-DONE
         ELSE
             ADD WS-BIT TO WS-MASK
         END-IF
     END-PERFORM
     IF BR-E-KEY = SPACES
         MOVE WS-MASK TO L-INT
     END-IF.

 MAIN-LINE.
     MOVE BR-IN-CURSOR TO WS-START
     EVALUATE BR-N-TYPE(L-NODE)
         WHEN BR-P-ANGLE
             PERFORM DO-ANGLE
         WHEN BR-P-SWIZZLE
             PERFORM DO-SWIZZLE
         WHEN OTHER
             PERFORM DO-POSITION
     END-EVALUATE.
 END PROGRAM BR-ARG-COORD.
