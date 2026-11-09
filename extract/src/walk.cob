*> The walk (22 §7.3 step 7): EX-WALK USING zip handle, partial directory (PIC X(1100)), status out (BINARY-LONG: 0, or
*> the CCX number of the first failure after its message: 20, 21, 40, 41, 42, 45 or 50). Each planned entry (EX-PLAN)
*> is read and CRC-checked by EX-ENTRY-READ, written to every destination below the partial directory (pack.png to
*> both packs) and indexed (EX-INDEX-ADD); EXR-WRITTEN and EXR-BYTES count what was written. With --dry-run the
*> entries are read and checked and nothing else happens. Progress: "Wrote <n> files" per 1000 files unless --quiet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-WALK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-BUFFER              PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COPIES              BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-DEST                PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-PARENT-LENGTH       BINARY-LONG.
 01 WS-PARENT              PIC X(1100).
 01 WS-LAST-PARENT         PIC X(1100).
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-NUMBER-TEXT         PIC X(20).
 LINKAGE SECTION.
 01 L-ZIP                  USAGE POINTER.
 01 L-PARTIAL              PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ZIP L-PARTIAL L-STATUS.
     MOVE 0 TO L-STATUS
     MOVE SPACES TO WS-LAST-PARENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EXP-COUNT OR L-STATUS NOT = 0
         MOVE EXP-INDEX(WS-I) TO WS-ENTRY
         MOVE EXP-KIND(WS-I) TO WS-KIND
         CALL "ZIP-NAME" USING L-ZIP WS-ENTRY WS-NAME WS-NAME-LENGTH
         CALL "EX-ENTRY-READ" USING L-ZIP WS-ENTRY WS-BUFFER WS-CAPACITY WS-LENGTH WS-CRC L-STATUS
         MOVE 1 TO WS-COPIES
         IF WS-KIND = 4
             MOVE 2 TO WS-COPIES
         END-IF
         IF EXO-DRY = 1
             MOVE 0 TO WS-COPIES
         END-IF
         PERFORM VARYING WS-WHICH FROM 1 BY 1 UNTIL WS-WHICH > WS-COPIES OR L-STATUS NOT = 0
             CALL "EX-DEST" USING WS-NAME WS-NAME-LENGTH WS-KIND WS-WHICH WS-DEST
             CALL "EX-JOIN" USING L-PARTIAL WS-DEST WS-PATH
*>           The folder of the file: everything before its last "/", made once for a run of files in one folder.
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
             MOVE WS-PATH-LENGTH TO WS-SLASH
             PERFORM UNTIL WS-PATH(WS-SLASH:1) = "/"
                 SUBTRACT 1 FROM WS-SLASH
             END-PERFORM
             COMPUTE WS-PARENT-LENGTH = WS-SLASH - 1
             MOVE SPACES TO WS-PARENT
             MOVE WS-PATH(1:WS-PARENT-LENGTH) TO WS-PARENT
             IF WS-PARENT NOT = WS-LAST-PARENT
                 CALL "DIR-ENSURE" USING WS-PARENT WS-FILE-STATUS
                 IF WS-FILE-STATUS NOT = FM-OK
                     MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
                     MOVE WS-PARENT TO EXM-ARG(1)
                     MOVE "cannot be created or written" TO EXM-ARG(2)
                     MOVE 50 TO WS-CODE L-STATUS
                     CALL "EX-SAY" USING WS-CODE
                 END-IF
                 MOVE WS-PARENT TO WS-LAST-PARENT
             END-IF
             IF L-STATUS = 0
                 CALL "EX-PUT" USING WS-PATH WS-BUFFER WS-LENGTH L-STATUS
             END-IF
             IF L-STATUS = 0
                 CALL "EX-INDEX-ADD" USING WS-CRC WS-LENGTH WS-DEST L-STATUS
             END-IF
             IF L-STATUS = 0
                 ADD 1 TO EXR-WRITTEN
                 ADD WS-LENGTH TO EXR-BYTES
                 IF EXO-QUIET = 0 AND FUNCTION MOD(EXR-WRITTEN, 1000) = 0
                     MOVE EXR-WRITTEN TO WS-NUMBER
                     CALL "EX-NUM" USING WS-NUMBER WS-NUMBER-TEXT
                     DISPLAY "Wrote " FUNCTION TRIM(WS-NUMBER-TEXT) " files"
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM EX-WALK.
