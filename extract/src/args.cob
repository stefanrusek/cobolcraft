*> The command line of the extraction tool (22 §7.1): cobolcraft-extract [--jar P] [--game-dir P] [--generated-dir P]
*> [--force] [--verify] [--dry-run] [--quiet].
*>
*> EX-ARGS USING arguments (PIC X(4000)), length (BINARY-LONG), status out (BINARY-LONG: 0, or 1 after CCX-001 has
*> been reported by EX-SAY). The arguments are one text, separated by LF (assumption A1 of messages.cob). It resets
*> EX-OPT first: the game directory is "." and the generated directory <game directory>/generated unless given.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-ARGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 WS-POSITION            BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-TOKEN-LENGTH        BINARY-LONG.
 01 WS-TOKEN               PIC X(1100).
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-GAME-GIVEN          BINARY-LONG.
 01 WS-GEN-GIVEN           BINARY-LONG.
 01 WS-SUFFIX              PIC X(1100) VALUE "generated".
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4000).
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-STATUS.
     MOVE SPACES TO EXO-JAR EXO-GAME EXO-GEN
     MOVE 0 TO EXO-JAR-GIVEN EXO-FORCE EXO-VERIFY EXO-DRY EXO-QUIET
     MOVE 0 TO WS-WANT WS-BAD WS-GAME-GIVEN WS-GEN-GIVEN
     MOVE 1 TO WS-POSITION
     PERFORM UNTIL WS-POSITION > L-LENGTH OR WS-BAD = 1
         COMPUTE WS-LEFT = L-LENGTH - WS-POSITION + 1
         MOVE 0 TO WS-TOKEN-LENGTH
         INSPECT L-TEXT(WS-POSITION:WS-LEFT) TALLYING WS-TOKEN-LENGTH FOR CHARACTERS BEFORE INITIAL X"0A"
         IF WS-TOKEN-LENGTH = 0 OR WS-TOKEN-LENGTH > 1000
             MOVE 1 TO WS-BAD
         ELSE
             MOVE SPACES TO WS-TOKEN
             MOVE L-TEXT(WS-POSITION:WS-TOKEN-LENGTH) TO WS-TOKEN
             COMPUTE WS-POSITION = WS-POSITION + WS-TOKEN-LENGTH + 1
             EVALUATE TRUE
                 WHEN WS-WANT = 1
                     MOVE WS-TOKEN TO EXO-JAR
                     MOVE 1 TO EXO-JAR-GIVEN
                     MOVE 0 TO WS-WANT
                 WHEN WS-WANT = 2
                     MOVE WS-TOKEN TO EXO-GAME
                     MOVE 1 TO WS-GAME-GIVEN
                     MOVE 0 TO WS-WANT
                 WHEN WS-WANT = 3
                     MOVE WS-TOKEN TO EXO-GEN
                     MOVE 1 TO WS-GEN-GIVEN
                     MOVE 0 TO WS-WANT
                 WHEN WS-TOKEN = "--jar"
                     MOVE 1 TO WS-WANT
                 WHEN WS-TOKEN = "--game-dir"
                     MOVE 2 TO WS-WANT
                 WHEN WS-TOKEN = "--generated-dir"
                     MOVE 3 TO WS-WANT
                 WHEN WS-TOKEN = "--force"
                     MOVE 1 TO EXO-FORCE
                 WHEN WS-TOKEN = "--verify"
                     MOVE 1 TO EXO-VERIFY
                 WHEN WS-TOKEN = "--dry-run"
                     MOVE 1 TO EXO-DRY
                 WHEN WS-TOKEN = "--quiet"
                     MOVE 1 TO EXO-QUIET
                 WHEN OTHER
                     MOVE 1 TO WS-BAD
             END-EVALUATE
         END-IF
     END-PERFORM
     IF WS-WANT > 0
         MOVE 1 TO WS-BAD
     END-IF
     IF WS-BAD = 1
         MOVE 1 TO WS-CODE
         CALL "EX-SAY" USING WS-CODE
         MOVE 1 TO L-STATUS
         GOBACK
     END-IF
     IF WS-GAME-GIVEN = 0
         MOVE "." TO EXO-GAME
     END-IF
     IF WS-GEN-GIVEN = 0
         CALL "EX-JOIN" USING EXO-GAME WS-SUFFIX EXO-GEN
     END-IF
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM EX-ARGS.
