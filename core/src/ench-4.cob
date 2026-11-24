*> Level-based values (docs/protocol/28 section 4; US14; T2167). The value types are written in prefix form, tokens separated by spaces, each type of a
*> fixed arity (so no brackets are needed): a bare number; "linear base per_level"; "squared added" (levels_squared); "lookup n v1 .. vn fallback"
*> (the fallback is itself an expression); "fraction numerator denominator"; "clamped min max value"; "exponent base power".
*>   TOOL-LBV-TOKENS USING expression (PIC X(200)), tokens out (60 of PIC X(16)), count out
*>   TOOL-LBV-NODE USING tokens, count, position (in and out), level, value out (FLOAT-LONG), status out (0 ok, 1 clamped with max not above min,
*>     2 syntax error): evaluates one expression from the position (RECURSIVE)
*>   TOOL-LBV-EVAL USING expression, level, value out (ten-thousandths, rounded), status out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LBV-TOKENS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 LINKAGE SECTION.
 01 L-EXPRESSION           PIC X(200).
 01 L-TOKENS.
    05 L-TOKEN             PIC X(16) OCCURS 60 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-EXPRESSION L-TOKENS L-COUNT.
     MOVE 0 TO L-COUNT
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 200 OR L-COUNT >= 60
         MOVE SPACES TO WS-TEXT
         UNSTRING L-EXPRESSION DELIMITED BY ALL SPACE INTO WS-TEXT WITH POINTER WS-POINTER
         IF WS-TEXT NOT = SPACES
             ADD 1 TO L-COUNT
             MOVE WS-TEXT TO L-TOKEN(L-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-LBV-TOKENS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LBV-NUMBER.
*> USING tokens, count, position (in and out), number out, status out (2 when there is no number at the position).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOKENS.
    05 L-TOKEN             PIC X(16) OCCURS 60 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-NUMBER               FLOAT-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TOKENS L-COUNT L-POS L-NUMBER L-STATUS.
     MOVE 0 TO L-NUMBER
     IF L-POS > L-COUNT
         MOVE 2 TO L-STATUS
     ELSE
         IF FUNCTION TEST-NUMVAL(L-TOKEN(L-POS)) = 0
             COMPUTE L-NUMBER = FUNCTION NUMVAL(L-TOKEN(L-POS))
         ELSE
             MOVE 2 TO L-STATUS
         END-IF
         ADD 1 TO L-POS
     END-IF
     GOBACK.
 END PROGRAM TOOL-LBV-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LBV-NODE RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-C                   FLOAT-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-PICK                FLOAT-LONG.
 01 LS-NAME                PIC X(16).
 LINKAGE SECTION.
 01 L-TOKENS.
    05 L-TOKEN             PIC X(16) OCCURS 60 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TOKENS L-COUNT L-POS L-LEVEL L-VALUE L-STATUS.
     MOVE 0 TO L-VALUE
     IF L-POS > L-COUNT
         MOVE 2 TO L-STATUS
         GOBACK
     END-IF
     MOVE L-TOKEN(L-POS) TO LS-NAME
     IF FUNCTION TEST-NUMVAL(LS-NAME) = 0
         COMPUTE L-VALUE = FUNCTION NUMVAL(LS-NAME)
         ADD 1 TO L-POS
         GOBACK
     END-IF
     ADD 1 TO L-POS
     EVALUATE LS-NAME
         WHEN "linear"
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-A L-STATUS
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-B L-STATUS
             COMPUTE L-VALUE = LS-A + LS-B * (L-LEVEL - 1)
         WHEN "squared"
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-A L-STATUS
             COMPUTE L-VALUE = L-LEVEL * L-LEVEL + LS-A
         WHEN "lookup"
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-A L-STATUS
             COMPUTE LS-N = LS-A
             MOVE 0 TO LS-PICK
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
                 CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-B L-STATUS
                 IF LS-I = L-LEVEL
                     MOVE LS-B TO LS-PICK
                 END-IF
             END-PERFORM
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-C L-STATUS
             IF L-LEVEL <= LS-N
                 MOVE LS-PICK TO L-VALUE
             ELSE
                 MOVE LS-C TO L-VALUE
             END-IF
         WHEN "fraction"
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-A L-STATUS
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-B L-STATUS
             IF LS-B NOT = 0
                 COMPUTE L-VALUE = LS-A / LS-B
             END-IF
         WHEN "clamped"
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-A L-STATUS
             CALL "TOOL-LBV-NUMBER" USING L-TOKENS L-COUNT L-POS LS-B L-STATUS
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-C L-STATUS
             IF LS-B <= LS-A
                 IF L-STATUS = 0
                     MOVE 1 TO L-STATUS
                 END-IF
             ELSE
                 MOVE LS-C TO L-VALUE
                 IF L-VALUE < LS-A
                     MOVE LS-A TO L-VALUE
                 END-IF
                 IF L-VALUE > LS-B
                     MOVE LS-B TO L-VALUE
                 END-IF
             END-IF
         WHEN "exponent"
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-A L-STATUS
             CALL "TOOL-LBV-NODE" USING L-TOKENS L-COUNT L-POS L-LEVEL LS-B L-STATUS
             COMPUTE L-VALUE = LS-A ** LS-B
         WHEN OTHER
             MOVE 2 TO L-STATUS
     END-EVALUATE
     GOBACK.
 END PROGRAM TOOL-LBV-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-LBV-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(16) OCCURS 60 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-EXPRESSION           PIC X(200).
 01 L-LEVEL                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-EXPRESSION L-LEVEL L-VALUE L-STATUS.
     MOVE 0 TO L-STATUS L-VALUE
     CALL "TOOL-LBV-TOKENS" USING L-EXPRESSION WS-TOKENS WS-COUNT
     MOVE 1 TO WS-POS
     CALL "TOOL-LBV-NODE" USING WS-TOKENS WS-COUNT WS-POS L-LEVEL WS-VALUE L-STATUS
     IF L-STATUS = 0
         COMPUTE L-VALUE ROUNDED = WS-VALUE * 10000
     END-IF
     GOBACK.
 END PROGRAM TOOL-LBV-EVAL.
