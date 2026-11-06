*> Block state files (08 §4): BLOCKSTATE-SELECT picks the models of one block state from a parsed
*> file. The state is given as its variant key ("axis=x,punched=true", properties sorted by name;
*> empty for a block without properties). A variant key matches when each of its pairs is a pair
*> of the state (the empty key matches every state); the first matching variant is taken. Only
*> when no variant matches, every multipart case whose condition holds contributes its model.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKSTATE-SELECT.
*> USING JSON-DOC, state key (PIC X(62)), state key length, STATE-MODELS out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-SECTION             BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-WHEN                BINARY-LONG.
 01 WS-APPLY               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-KEY                 PIC X(256).
 01 WS-CAP                 BINARY-LONG VALUE 256.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-STATE               PIC X(66).
 01 WS-PAIR                PIC X(66).
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 COPY CLMODEL.
 01 L-STATE                PIC X(62).
 01 L-STATE-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-STATE L-STATE-LENGTH STATE-MODELS.
     MOVE 0 TO SX-COUNT
     IF JD-COUNT = 0
         GOBACK
     END-IF
*>   ",<state key>," so that ",<pair>," can be searched for.
     MOVE SPACES TO WS-STATE
     STRING "," L-STATE(1:L-STATE-LENGTH) "," DELIMITED BY SIZE INTO WS-STATE
     MOVE "variants" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-SECTION
     MOVE 0 TO WS-NODE
     IF WS-SECTION > 0
         MOVE JN-FIRST(WS-SECTION) TO WS-NODE
     END-IF
     PERFORM UNTIL WS-NODE = 0 OR SX-COUNT > 0
         MOVE SPACES TO WS-KEY
         CALL "JSON-KEY" USING JSON-DOC WS-NODE WS-KEY WS-CAP WS-KEY-LENGTH
         MOVE 1 TO WS-MATCH WS-START
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-LENGTH + 1
             IF WS-I > WS-KEY-LENGTH OR WS-KEY(WS-I:1) = ","
                 MOVE SPACES TO WS-PAIR
                 STRING "," WS-KEY(WS-START:WS-I - WS-START) "," DELIMITED BY SIZE INTO WS-PAIR
                 MOVE 0 TO WS-COUNT
                 INSPECT WS-STATE TALLYING WS-COUNT
                     FOR ALL WS-PAIR(1:WS-I - WS-START + 2)
                 IF WS-COUNT = 0 AND WS-KEY-LENGTH > 0
                     MOVE 0 TO WS-MATCH
                 END-IF
                 COMPUTE WS-START = WS-I + 1
             END-IF
         END-PERFORM
         IF WS-MATCH = 1
             CALL "BLOCKSTATE-ADD" USING JSON-DOC WS-NODE STATE-MODELS
         END-IF
         MOVE JN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     IF SX-COUNT = 0
         MOVE "multipart" TO WS-NAME
         MOVE 9 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NAME-LENGTH WS-SECTION
         IF WS-SECTION > 0
             MOVE JN-FIRST(WS-SECTION) TO WS-NODE
         END-IF
         PERFORM UNTIL WS-NODE = 0
             MOVE "when" TO WS-NAME
             MOVE 4 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-WHEN
             MOVE 1 TO WS-HOLDS
             IF WS-WHEN > 0
                 CALL "BLOCKSTATE-CONDITION" USING JSON-DOC WS-WHEN WS-STATE WS-HOLDS
             END-IF
             IF WS-HOLDS = 1
                 MOVE "apply" TO WS-NAME
                 MOVE 5 TO WS-NAME-LENGTH
                 CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-APPLY
                 CALL "BLOCKSTATE-ADD" USING JSON-DOC WS-APPLY STATE-MODELS
             END-IF
             MOVE JN-NEXT(WS-NODE) TO WS-NODE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BLOCKSTATE-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKSTATE-ADD.
*> USING JSON-DOC, ModelChoice node (a Variant object, or a weighted list whose first entry is
*> taken), STATE-MODELS: appends the variant (model, x, y, z modulo 360, uvlock).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 01 WS-FIELD               BINARY-LONG.
 01 WS-NAME                PIC X(8).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 80.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-AXES                PIC X(3) VALUE "xyz".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-CHOICE               BINARY-LONG.
 COPY CLMODEL.
 PROCEDURE DIVISION USING JSON-DOC L-CHOICE STATE-MODELS.
     MOVE L-CHOICE TO WS-NODE
     IF JN-TYPE(WS-NODE) = JT-ARRAY
         MOVE JN-FIRST(WS-NODE) TO WS-NODE
     END-IF
     IF SX-COUNT < 8
         ADD 1 TO SX-COUNT
         INITIALIZE SX-MODEL(SX-COUNT)
         MOVE "model" TO WS-NAME
         MOVE 5 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
         CALL "JSON-STRING" USING JSON-DOC WS-FIELD SX-ID(SX-COUNT) WS-CAP WS-LENGTH
         MOVE 1 TO WS-NAME-LENGTH
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             MOVE WS-AXES(WS-A:1) TO WS-NAME
             CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
             MOVE 0 TO WS-ANGLE
             IF WS-FIELD > 0
                 COMPUTE WS-ANGLE = FUNCTION MOD(JN-NUM(WS-FIELD), 360)
             END-IF
             EVALUATE WS-A
                 WHEN 1
                     MOVE WS-ANGLE TO SX-X(SX-COUNT)
                 WHEN 2
                     MOVE WS-ANGLE TO SX-Y(SX-COUNT)
                 WHEN 3
                     MOVE WS-ANGLE TO SX-Z(SX-COUNT)
             END-EVALUATE
         END-PERFORM
         MOVE "uvlock" TO WS-NAME
         MOVE 6 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
         IF WS-FIELD > 0
             IF JN-TYPE(WS-FIELD) = JT-TRUE
                 MOVE 1 TO SX-UVLOCK(SX-COUNT)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BLOCKSTATE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKSTATE-CONDITION RECURSIVE.
*> USING JSON-DOC, Condition node, state (",<state key>," PIC X(66)), holds out (1 or 0): a
*> Combined condition (one key AND or OR over an array of conditions, nesting) or a key-value one
*> (every listed property matches one of its "|"-separated terms; "!v" matches any other value).
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-NODE                BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-SUB-HOLDS           BINARY-LONG.
 01 LS-ANY                 BINARY-LONG.
 01 LS-KEY                 PIC X(32).
 01 LS-CAP                 BINARY-LONG VALUE 32.
 01 LS-KEY-LENGTH          BINARY-LONG.
 01 LS-TERMS               PIC X(80).
 01 LS-TERMS-CAP           BINARY-LONG VALUE 80.
 01 LS-TERMS-LENGTH        BINARY-LONG.
 01 LS-VALUE               PIC X(32).
 01 LS-NEEDLE              PIC X(40).
 01 LS-I                   BINARY-LONG.
 01 LS-START               BINARY-LONG.
 01 LS-TERM                PIC X(32).
 01 LS-NOT                 BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-EDIT                PIC -(9)9.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                PIC X(66).
 01 L-HOLDS                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-STATE L-HOLDS.
     MOVE JN-FIRST(L-NODE) TO LS-NODE
     MOVE SPACES TO LS-KEY
     CALL "JSON-KEY" USING JSON-DOC LS-NODE LS-KEY LS-CAP LS-KEY-LENGTH
     IF JN-COUNT(L-NODE) = 1 AND (LS-KEY = "AND" OR LS-KEY = "OR")
*>       AND: every sub-condition holds; OR: at least one does.
         MOVE 0 TO LS-ANY
         MOVE 1 TO L-HOLDS
         MOVE JN-FIRST(LS-NODE) TO LS-SUB
         PERFORM UNTIL LS-SUB = 0
             CALL "BLOCKSTATE-CONDITION" USING JSON-DOC LS-SUB L-STATE LS-SUB-HOLDS
             IF LS-SUB-HOLDS = 0
                 MOVE 0 TO L-HOLDS
             ELSE
                 MOVE 1 TO LS-ANY
             END-IF
             MOVE JN-NEXT(LS-SUB) TO LS-SUB
         END-PERFORM
         IF LS-KEY = "OR"
             MOVE LS-ANY TO L-HOLDS
         END-IF
         GOBACK
     END-IF
     MOVE 1 TO L-HOLDS
     PERFORM UNTIL LS-NODE = 0
         MOVE SPACES TO LS-KEY LS-TERMS LS-VALUE LS-NEEDLE
         CALL "JSON-KEY" USING JSON-DOC LS-NODE LS-KEY LS-CAP LS-KEY-LENGTH
         EVALUATE JN-TYPE(LS-NODE)
             WHEN JT-TRUE
                 MOVE "true" TO LS-TERMS
                 MOVE 4 TO LS-TERMS-LENGTH
             WHEN JT-FALSE
                 MOVE "false" TO LS-TERMS
                 MOVE 5 TO LS-TERMS-LENGTH
             WHEN JT-NUMBER
                 COMPUTE LS-EDIT = JN-NUM(LS-NODE)
                 MOVE FUNCTION TRIM(LS-EDIT) TO LS-TERMS
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-EDIT)) TO LS-TERMS-LENGTH
             WHEN OTHER
                 CALL "JSON-STRING" USING JSON-DOC LS-NODE LS-TERMS LS-TERMS-CAP LS-TERMS-LENGTH
         END-EVALUATE
*>       The state's value of the property: what follows ",<name>=" up to the next ",".
         STRING "," LS-KEY(1:LS-KEY-LENGTH) "=" DELIMITED BY SIZE INTO LS-NEEDLE
         MOVE 0 TO LS-COUNT
         INSPECT L-STATE TALLYING LS-COUNT FOR CHARACTERS
             BEFORE INITIAL LS-NEEDLE(1:LS-KEY-LENGTH + 2)
         IF LS-COUNT < 66
             UNSTRING L-STATE(LS-COUNT + LS-KEY-LENGTH + 3:) DELIMITED BY "," INTO LS-VALUE
         END-IF
         MOVE 0 TO LS-ANY
         MOVE 1 TO LS-START
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-TERMS-LENGTH + 1
             IF LS-I > LS-TERMS-LENGTH OR LS-TERMS(LS-I:1) = "|"
                 MOVE SPACES TO LS-TERM
                 MOVE LS-TERMS(LS-START:LS-I - LS-START) TO LS-TERM
                 MOVE 0 TO LS-NOT
                 IF LS-TERM(1:1) = "!"
                     MOVE 1 TO LS-NOT
                     MOVE LS-TERM(2:31) TO LS-NEEDLE
                     MOVE LS-NEEDLE TO LS-TERM
                 END-IF
                 IF (LS-TERM = LS-VALUE AND LS-NOT = 0) OR (LS-TERM NOT = LS-VALUE AND LS-NOT = 1)
                     MOVE 1 TO LS-ANY
                 END-IF
                 COMPUTE LS-START = LS-I + 1
             END-IF
         END-PERFORM
         IF LS-ANY = 0
             MOVE 0 TO L-HOLDS
         END-IF
         MOVE JN-NEXT(LS-NODE) TO LS-NODE
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKSTATE-CONDITION.
