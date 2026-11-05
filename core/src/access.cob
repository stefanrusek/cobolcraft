*> Access lists of the world (FR-010, FR-016, US13-4; CORESTATE.cpy CORE-ACCESS; saved in access.dat by
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
*> 0 added at the end of the list, 1 already listed, 2 the list is full (CORE-MAX-ACCESS).
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
