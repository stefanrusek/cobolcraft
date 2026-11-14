*> Finding the jar (22 §7.1). EX-JAR-FIND USING jar out (PIC X(1100)), status out (BINARY-LONG: 0 found, 10 CCX-010
*> after the message, 11 CCX-011 after the message). With --jar (EXO-JAR-GIVEN) the path is taken as given and must
*> be a readable file; otherwise the first regular file of <game>/minecraft-26.3-client.jar, <game>/client.jar and
*> ./minecraft-26.3-client.jar wins.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-JAR-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-NAME-1              PIC X(1100) VALUE "minecraft-26.3-client.jar".
 01 WS-NAME-2              PIC X(1100) VALUE "client.jar".
 01 WS-CANDIDATES.
    05 WS-CANDIDATE        PIC X(1100) OCCURS 3 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-LIST-POINTER        BINARY-LONG.
 LINKAGE SECTION.
 01 L-JAR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-JAR L-STATUS.
     MOVE SPACES TO L-JAR
     MOVE 0 TO L-STATUS
     IF EXO-JAR-GIVEN = 1
         CALL "FILE-EXISTS" USING EXO-JAR WS-FILE-STATUS
         MOVE EXO-JAR TO L-JAR
         IF WS-FILE-STATUS NOT = FM-OK
             MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
             MOVE EXO-JAR TO EXM-ARG(1)
             MOVE "no such file" TO EXM-ARG(2)
             IF WS-FILE-STATUS = FM-IS-DIR
                 MOVE "is a directory" TO EXM-ARG(2)
             END-IF
             MOVE 11 TO WS-CODE L-STATUS
             CALL "EX-SAY" USING WS-CODE
         END-IF
         GOBACK
     END-IF
     MOVE SPACES TO WS-CANDIDATES
     CALL "EX-JOIN" USING EXO-GAME WS-NAME-1 WS-CANDIDATE(1)
     CALL "EX-JOIN" USING EXO-GAME WS-NAME-2 WS-CANDIDATE(2)
     MOVE "./minecraft-26.3-client.jar" TO WS-CANDIDATE(3)
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 3
         CALL "FILE-EXISTS" USING WS-CANDIDATE(WS-INDEX) WS-FILE-STATUS
         IF WS-FILE-STATUS = FM-OK
             MOVE WS-CANDIDATE(WS-INDEX) TO L-JAR
             GOBACK
         END-IF
     END-PERFORM
     MOVE SPACES TO EXM-ARG(1)
     MOVE 1 TO WS-LIST-POINTER
     STRING FUNCTION TRIM(WS-CANDIDATE(1)) ", " FUNCTION TRIM(WS-CANDIDATE(2)) ", "
         FUNCTION TRIM(WS-CANDIDATE(3)) DELIMITED BY SIZE INTO EXM-ARG(1) POINTER WS-LIST-POINTER
     MOVE 10 TO WS-CODE L-STATUS
     CALL "EX-SAY" USING WS-CODE
     GOBACK.
 END PROGRAM EX-JAR-FIND.
