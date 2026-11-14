*> The run (22 §7.3, §7.5): EX-RUN and its steps, and EX-MAIN, the whole program of cobolcraft-extract.
*>   EX-TOTALS   USING status out (0, or 45 after the message): the counts of the plan equal those of the table row
*>               (22 §6.1, assumption A4).
*>   EX-PREPARE  USING partial directory (PIC X(1100)), status out (0, or 51 or 50): removes a leftover partial directory
*>               (only one that holds the marker, or is empty), then makes it with the marker and the two pack.mcmeta.
*>   EX-SWAP     USING partial directory, generated directory, status out (0, or 51 or 50): the target check again, then
*>               remove the generated directory and rename the partial one to its name (22 §7.5 steps 2 to 4); on a
*>               failure the partial directory is removed.
*>   EX-RUN      USING arguments (PIC X(4000), LF separated), length, exit status out (BINARY-LONG, the exit code of 22 §7.4).
*>   EX-MAIN     the program: joins its arguments, runs EX-RUN and ends with the exit status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-TOTALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-R                   PIC X(20).
 01 WS-D                   PIC X(20).
 01 WS-F                   PIC X(20).
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS.
     MOVE 0 TO L-STATUS
     IF EXR-RESOURCE NOT = 11605 OR EXR-DATA NOT = 9779 OR EXR-FEATURE NOT = 106 OR EXR-TOTAL NOT = 21490
         MOVE EXR-RESOURCE TO WS-NUMBER
         CALL "EX-NUM" USING WS-NUMBER WS-R
         MOVE EXR-DATA TO WS-NUMBER
         CALL "EX-NUM" USING WS-NUMBER WS-D
         MOVE EXR-FEATURE TO WS-NUMBER
         CALL "EX-NUM" USING WS-NUMBER WS-F
         MOVE SPACES TO EXM-ARG(1)
         STRING "file counts " FUNCTION TRIM(WS-R) " resource, " FUNCTION TRIM(WS-D) " data and "
             FUNCTION TRIM(WS-F) " feature-pack files, expected 11605, 9779 and 106" DELIMITED BY SIZE
             INTO EXM-ARG(1)
         MOVE 45 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
     END-IF
     GOBACK.
 END PROGRAM EX-TOTALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-PREPARE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PARTIAL              PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PARTIAL L-STATUS.
     CALL "EX-TARGET-CHECK" USING L-PARTIAL L-STATUS
     IF L-STATUS NOT = 0
         GOBACK
     END-IF
     CALL "DIR-REMOVE-TREE" USING L-PARTIAL WS-FILE-STATUS
     IF WS-FILE-STATUS NOT = FM-OK AND WS-FILE-STATUS NOT = FM-NOT-FOUND
         MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
         MOVE L-PARTIAL TO EXM-ARG(1)
         MOVE "cannot be removed" TO EXM-ARG(2)
         MOVE 50 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
         GOBACK
     END-IF
     CALL "EX-WRITE-MARKER" USING L-PARTIAL L-STATUS
     IF L-STATUS = 0
         CALL "EX-WRITE-MCMETA" USING L-PARTIAL L-STATUS
     END-IF
     GOBACK.
 END PROGRAM EX-PREPARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-SWAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-REMOVE-STATUS       BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PARTIAL              PIC X(1100).
 01 L-GEN                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PARTIAL L-GEN L-STATUS.
     CALL "EX-TARGET-CHECK" USING L-GEN L-STATUS
     IF L-STATUS = 0
         CALL "DIR-REMOVE-TREE" USING L-GEN WS-FILE-STATUS
         MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
         MOVE L-GEN TO EXM-ARG(1)
         IF WS-FILE-STATUS NOT = FM-OK AND WS-FILE-STATUS NOT = FM-NOT-FOUND
             MOVE "cannot be removed" TO EXM-ARG(2)
             MOVE 50 TO WS-CODE L-STATUS
             CALL "EX-SAY" USING WS-CODE
         END-IF
     END-IF
     IF L-STATUS = 0
         CALL "DIR-RENAME" USING L-PARTIAL L-GEN WS-FILE-STATUS
         IF WS-FILE-STATUS NOT = FM-OK
             MOVE "cannot be replaced by the new directory" TO EXM-ARG(2)
             MOVE 50 TO WS-CODE L-STATUS
             CALL "EX-SAY" USING WS-CODE
         END-IF
     END-IF
     IF L-STATUS NOT = 0
         CALL "DIR-REMOVE-TREE" USING L-PARTIAL WS-REMOVE-STATUS
     END-IF
     GOBACK.
 END PROGRAM EX-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-STEP.
*> USING status (BINARY-LONG: 0 or a CCX number), go (BINARY-LONG: 1 while the run goes on): go becomes 0 when the status is not 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAILED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-GO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS L-GO.
     COMPUTE WS-FAILED = FUNCTION MIN(L-STATUS, 1)
     COMPUTE L-GO = L-GO - L-GO * WS-FAILED
     GOBACK.
 END PROGRAM EX-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-STATUS              BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-JAR                 PIC X(1100).
 01 WS-PARTIAL             PIC X(1100).
 01 WS-ACTION              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-REMOVE-STATUS       BINARY-LONG.
 01 WS-GEN-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4000).
 01 L-LENGTH               BINARY-LONG.
 01 L-EXIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-EXIT.
     MOVE 0 TO L-EXIT EXR-CODE EXR-EXIT EXR-RESOURCE EXR-DATA EXR-FEATURE EXR-SKIPPED EXR-TOTAL EXR-WRITTEN
         EXR-BYTES EXP-COUNT
     MOVE SPACES TO EXR-LINE
     MOVE 1 TO WS-GO
     MOVE 0 TO WS-CREATED
     SET EXC-ZIP TO NULL
     CALL "EX-INDEX-RESET"
*>   Every step runs only while WS-GO is 1 and clears it when its status is not 0: the failing step has printed its
*>   message, whose exit status is left in EXR-EXIT (0 until a message with a non-zero exit is printed).
     CALL "EX-ARGS" USING L-TEXT L-LENGTH WS-STATUS
     CALL "EX-STEP" USING WS-STATUS WS-GO
*>   --verify never needs the jar (22 §7.1).
     IF WS-GO = 1 AND EXO-VERIFY = 1
         CALL "EX-VERIFY" USING EXO-GEN WS-STATUS
         MOVE 0 TO WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-JAR-FIND" USING WS-JAR WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-CHECK" USING WS-JAR WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
*>   Step 5: the action (22 §6.3) and the target check (22 §7.5 step 0).
     IF WS-GO = 1
         CALL "EX-ACTION" USING WS-ACTION
         IF WS-ACTION = 1
             MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
             MOVE EXC-ID TO EXM-ARG(1)
             MOVE EXC-SHA TO EXM-ARG(2)
             MOVE 100 TO WS-CODE
             CALL "EX-SAY" USING WS-CODE
             MOVE 0 TO WS-GO
         END-IF
     END-IF
     IF WS-GO = 1
         CALL "EX-TARGET-CHECK" USING EXO-GEN WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-PLAN" USING EXC-ZIP WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     MOVE SPACES TO WS-PARTIAL
     IF WS-GO = 1
         MOVE FUNCTION LENGTH(FUNCTION TRIM(EXO-GEN)) TO WS-GEN-LENGTH
         STRING EXO-GEN(1:WS-GEN-LENGTH) ".partial" DELIMITED BY SIZE INTO WS-PARTIAL
     END-IF
*>   --dry-run: the walk reads and checks every entry and writes nothing.
     IF WS-GO = 1 AND EXO-DRY = 1
         CALL "EX-WALK" USING EXC-ZIP WS-PARTIAL WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
         IF WS-GO = 1
             MOVE 103 TO WS-CODE
             CALL "EX-SAY" USING WS-CODE
         END-IF
         MOVE 0 TO WS-GO
     END-IF
*>   Steps 6 to 10. The partial directory counts as made once EX-PREPARE has succeeded: a refused one is not ours.
     IF WS-GO = 1
         CALL "EX-PREPARE" USING WS-PARTIAL WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
         MOVE WS-GO TO WS-CREATED
     END-IF
     IF WS-GO = 1
         CALL "EX-WALK" USING EXC-ZIP WS-PARTIAL WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-TOTALS" USING WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-WRITE-INDEX" USING WS-PARTIAL WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-WRITE-MANIFEST" USING WS-PARTIAL WS-STATUS
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         CALL "EX-SWAP" USING WS-PARTIAL EXO-GEN WS-STATUS
         MOVE 0 TO WS-CREATED
         CALL "EX-STEP" USING WS-STATUS WS-GO
     END-IF
     IF WS-GO = 1
         MOVE SPACES TO EXM-ARG(1)
         MOVE EXO-GEN TO EXM-ARG(1)
         MOVE 101 TO WS-CODE
         CALL "EX-SAY" USING WS-CODE
     END-IF
*>   A run that stops after the partial directory was made removes it; the generated directory is never touched.
     IF WS-CREATED = 1
         CALL "DIR-REMOVE-TREE" USING WS-PARTIAL WS-REMOVE-STATUS
     END-IF
     IF EXC-ZIP NOT = NULL
         CALL "ZIP-CLOSE" USING EXC-ZIP
         SET EXC-ZIP TO NULL
     END-IF
     MOVE EXR-EXIT TO L-EXIT
     CALL "EX-INDEX-RESET"
     GOBACK.

 END PROGRAM EX-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-MAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ARGUMENT            PIC X(1100).
 01 WS-ARGUMENT-LENGTH     BINARY-LONG.
 01 WS-TEXT                PIC X(4000).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 PROCEDURE DIVISION.
     ACCEPT WS-COUNT FROM ARGUMENT-NUMBER
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE SPACES TO WS-ARGUMENT
         ACCEPT WS-ARGUMENT FROM ARGUMENT-VALUE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ARGUMENT TRAILING)) TO WS-ARGUMENT-LENGTH
         STRING WS-ARGUMENT(1:WS-ARGUMENT-LENGTH) X"0A" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
             ON OVERFLOW
                 MOVE "--arguments-too-long" TO WS-TEXT
                 MOVE 21 TO WS-POINTER
         END-PERFORM
     COMPUTE WS-LENGTH = WS-POINTER - 1
     CALL "EX-RUN" USING WS-TEXT WS-LENGTH WS-EXIT
     MOVE WS-EXIT TO RETURN-CODE
     STOP RUN.
 END PROGRAM EX-MAIN.
