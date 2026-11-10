*> Access lists of the world (FR-010, FR-016, US13-4, US14; CORESTATE.cpy CORE-ACCESS; saved in access.dat by
*> core/src/persistence.cob): the operator, ban and allow lists of offline identities (name and
*> offline UUID, 02 Offline mode), and whether the allow-list is enforced in this world (operator
*> decision A2). A list is chosen by ACCESS-OPERATORS, ACCESS-BANS or ACCESS-ALLOW; identities are
*> matched by UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-RESET.
*> No parameters: the access state of a new world (called by CORE-WORLD-OPEN after it stored the
*> settings): every list empty; the allow-list enforced as the allow-list setting says on a
*> dedicated server (CS-HOST-KIND 0), not enforced in a world hosted by the client (07 §9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     INITIALIZE CORE-ACCESS
     IF CS-HOST-KIND = 0
         MOVE CS-ALLOW-LIST-ENFORCED TO AC-ENFORCED
     END-IF
     GOBACK.
 END PROGRAM ACCESS-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-FIND.
*> USING list (BINARY-LONG), offline UUID (PIC X(16)), row out (BINARY-LONG; 0 = not listed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-UUID L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > AC-COUNT(L-LIST) OR L-ROW > 0
         IF AC-UUID(L-LIST, WS-ROW) = L-UUID
             MOVE WS-ROW TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ACCESS-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-ADD.
*> USING list, name (PIC X(16)), name length, offline UUID (PIC X(16)), outcome out (BINARY-LONG):
*> 0 added at the end of the list, 1 already listed, 2 the list is full (CORE-MAX-ACCESS). The entry is level 4 (an operator),
*> has no creation time, source or reason and expires forever (the caller sets what it knows).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-NAME L-NAME-LENGTH L-UUID L-OUTCOME.
     CALL "ACCESS-FIND" USING L-LIST L-UUID WS-ROW
     EVALUATE TRUE
         WHEN WS-ROW > 0
             MOVE 1 TO L-OUTCOME
         WHEN AC-COUNT(L-LIST) >= CORE-MAX-ACCESS
             MOVE 2 TO L-OUTCOME
         WHEN OTHER
             ADD 1 TO AC-COUNT(L-LIST)
             MOVE L-NAME TO AC-NAME(L-LIST, AC-COUNT(L-LIST))
             MOVE L-NAME-LENGTH TO AC-NAME-LENGTH(L-LIST, AC-COUNT(L-LIST))
             MOVE L-UUID TO AC-UUID(L-LIST, AC-COUNT(L-LIST))
             MOVE 0 TO AC-LEVEL(L-LIST, AC-COUNT(L-LIST))
             IF L-LIST = ACCESS-OPERATORS
                 MOVE 4 TO AC-LEVEL(L-LIST, AC-COUNT(L-LIST))
             END-IF
             MOVE SPACES TO AC-CREATED(L-LIST, AC-COUNT(L-LIST)) AC-SOURCE(L-LIST, AC-COUNT(L-LIST))
                 AC-REASON(L-LIST, AC-COUNT(L-LIST))
             MOVE 0 TO AC-CREATED-LENGTH(L-LIST, AC-COUNT(L-LIST)) AC-SOURCE-LENGTH(L-LIST, AC-COUNT(L-LIST))
                 AC-REASON-LENGTH(L-LIST, AC-COUNT(L-LIST))
             MOVE "forever" TO AC-EXPIRES(L-LIST, AC-COUNT(L-LIST))
             MOVE 7 TO AC-EXPIRES-LENGTH(L-LIST, AC-COUNT(L-LIST))
             MOVE 0 TO L-OUTCOME
     END-EVALUATE
     GOBACK.
 END PROGRAM ACCESS-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-REMOVE.
*> USING list, offline UUID (PIC X(16)), outcome out (BINARY-LONG): 0 removed (the later entries
*> move up one row), 1 not listed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-UUID L-OUTCOME.
     CALL "ACCESS-FIND" USING L-LIST L-UUID WS-ROW
     MOVE 1 TO L-OUTCOME
     IF WS-ROW > 0
         PERFORM VARYING WS-I FROM WS-ROW BY 1 UNTIL WS-I >= AC-COUNT(L-LIST)
             MOVE AC-ENTRY(L-LIST, WS-I + 1) TO AC-ENTRY(L-LIST, WS-I)
         END-PERFORM
         SUBTRACT 1 FROM AC-COUNT(L-LIST)
         MOVE 0 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM ACCESS-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-OPERATOR-STATUS.
*> USING player row (BINARY-LONG): whether the player holds operator status (PL-OPERATOR; FR-016,
*> FR-017, standin §16.1): a player on the operator list; the host of a single-player world or of a
*> world opened to others (host kinds 1 and 2, the host's name); a guest of an opened world when the
*> host allowed guests operator commands (CS-GUEST-OPERATOR 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LIST                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST PL-UUID(L-ROW) WS-ROW
     MOVE 0 TO PL-OPERATOR(L-ROW)
     IF WS-ROW > 0
         MOVE 1 TO PL-OPERATOR(L-ROW)
     END-IF
     IF CS-HOST-KIND > 0 AND PL-NAME(L-ROW) = CS-HOST-NAME
         MOVE 1 TO PL-OPERATOR(L-ROW)
     END-IF
     IF CS-HOST-KIND = 2 AND CS-GUEST-OPERATOR = 1
         MOVE 1 TO PL-OPERATOR(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ACCESS-OPERATOR-STATUS.
