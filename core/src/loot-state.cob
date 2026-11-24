*> Block state property ranges of the loot predicates (T0436; docs/protocol/26-loot-and-predicates.md section 10.3, state properties): the
*> matcher {min?, max?} of a property compares the state's value with the bounds in the property's ordering (false < true for booleans, the
*> declaration order of an enum, the numeric order of an integer); a value the property does not hold (an unparsable bound) fails.
*> Entry points:
*>   LOOT-SPEC-ORDINAL USING value spec (PIC X(280), the block row's text of the property: "a/b/c", "lo..hi" or "bool"), value text (PIC X(32)),
*>     ordinal out (BINARY-LONG; -1 when the spec does not hold the value). A list of exactly the values true and false is a boolean.
*>   LOOT-STATE-RANGE USING slot, matcher node (an object {min, max}), state id, property name (PIC X(24)), result out (1 when the state has
*>     the property and its value lies within the bounds present)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-SPEC-ORDINAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POINTER             BINARY-LONG.
 01 WS-ITEM                PIC X(40).
 01 WS-LOW-TEXT            PIC X(12).
 01 WS-HIGH-TEXT           PIC X(12).
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-SLASHES             BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SPEC                 PIC X(280).
 01 L-VALUE                PIC X(32).
 01 L-ORDINAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEC L-VALUE L-ORDINAL.
     MOVE -1 TO L-ORDINAL
     MOVE 0 TO WS-SLASHES WS-DOTS
     INSPECT L-SPEC TALLYING WS-SLASHES FOR ALL "/"
     INSPECT L-SPEC TALLYING WS-DOTS FOR ALL ".."
     EVALUATE TRUE
         WHEN L-SPEC = "bool" OR L-SPEC = "true/false" OR L-SPEC = "false/true"
             EVALUATE L-VALUE
                 WHEN "false"
                     MOVE 0 TO L-ORDINAL
                 WHEN "true"
                     MOVE 1 TO L-ORDINAL
             END-EVALUATE
         WHEN WS-DOTS > 0
             MOVE SPACES TO WS-LOW-TEXT WS-HIGH-TEXT
             UNSTRING L-SPEC DELIMITED BY ".." INTO WS-LOW-TEXT WS-HIGH-TEXT
             COMPUTE WS-LOW = FUNCTION NUMVAL(WS-LOW-TEXT)
             COMPUTE WS-HIGH = FUNCTION NUMVAL(WS-HIGH-TEXT)
             IF FUNCTION TEST-NUMVAL(L-VALUE) = 0 AND L-VALUE NOT = SPACES
                 COMPUTE WS-NUMBER = FUNCTION NUMVAL(L-VALUE)
                 IF WS-NUMBER >= WS-LOW AND WS-NUMBER <= WS-HIGH
                     MOVE WS-NUMBER TO L-ORDINAL
                 END-IF
             END-IF
         WHEN OTHER
             MOVE 1 TO WS-POINTER
             MOVE 0 TO WS-INDEX
             PERFORM UNTIL WS-INDEX > WS-SLASHES OR L-ORDINAL >= 0
                 MOVE SPACES TO WS-ITEM
                 UNSTRING L-SPEC DELIMITED BY "/" OR SPACE INTO WS-ITEM WITH POINTER WS-POINTER
                 IF WS-ITEM = L-VALUE
                     MOVE WS-INDEX TO L-ORDINAL
                 END-IF
                 ADD 1 TO WS-INDEX
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM LOOT-SPEC-ORDINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-STATE-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY LOOTSTATE.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(71).
    05 WS-R-PROPS          PIC X(288).
    05 FILLER              PIC X(460).
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(300).
 01 WS-NAME                PIC X(24).
 01 WS-SPEC                PIC X(280).
 01 WS-OPEN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-HAVE-SPEC           BINARY-LONG.
 01 WS-CURRENT             PIC X(32).
 01 WS-BOUND               PIC X(112).
 01 WS-BOUND-LENGTH        BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-MEMBER              BINARY-LONG.
 01 WS-N-MIN               PIC X(32) VALUE "min".
 01 WS-N-MAX               PIC X(32) VALUE "max".
 01 WS-NOW                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 COPY CTPROPS.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-STATE L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "CONTENT-BLOCK-OF-STATE" USING L-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
*>   The spec of the property in the row's list "name[spec] name[spec]".
     MOVE 0 TO WS-HAVE-SPEC
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 288 OR WS-HAVE-SPEC = 1
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-R-PROPS DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES
             MOVE 0 TO WS-OPEN WS-CLOSE
             INSPECT WS-TOKEN TALLYING WS-OPEN FOR CHARACTERS BEFORE INITIAL "["
             INSPECT WS-TOKEN TALLYING WS-CLOSE FOR CHARACTERS BEFORE INITIAL "]"
             MOVE SPACES TO WS-NAME WS-SPEC
             MOVE WS-TOKEN(1:WS-OPEN) TO WS-NAME
             IF WS-NAME = L-NAME
                 COMPUTE WS-LENGTH = WS-CLOSE - WS-OPEN - 1
                 MOVE WS-TOKEN(WS-OPEN + 2:WS-LENGTH) TO WS-SPEC
                 MOVE 1 TO WS-HAVE-SPEC
             END-IF
         END-IF
     END-PERFORM
     IF WS-HAVE-SPEC = 0
         GOBACK
     END-IF
*>   The state's own value, then each bound present.
     CALL "CONTENT-STATE-PROPS" USING L-STATE CT-PROPS WS-STATUS
     MOVE SPACES TO WS-CURRENT
     PERFORM VARYING WS-NOW FROM 1 BY 1 UNTIL WS-NOW > CTP-COUNT
         IF CTP-NAME(WS-NOW) = L-NAME
             MOVE CTP-VALUE(WS-NOW) TO WS-CURRENT
         END-IF
     END-PERFORM
     CALL "LOOT-SPEC-ORDINAL" USING WS-SPEC WS-CURRENT WS-NOW
     MOVE 1 TO L-RESULT
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MIN WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-BOUND WS-BOUND-LENGTH
         MOVE WS-BOUND TO WS-TEXT
         CALL "LOOT-SPEC-ORDINAL" USING WS-SPEC WS-TEXT WS-LIMIT
         IF WS-LIMIT < 0 OR WS-NOW < WS-LIMIT
             MOVE 0 TO L-RESULT
         END-IF
     END-IF
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-N-MAX WS-MEMBER
     IF WS-MEMBER > 0
         CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-BOUND WS-BOUND-LENGTH
         MOVE WS-BOUND TO WS-TEXT
         CALL "LOOT-SPEC-ORDINAL" USING WS-SPEC WS-TEXT WS-LIMIT
         IF WS-LIMIT < 0 OR WS-NOW > WS-LIMIT
             MOVE 0 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOT-STATE-RANGE.
