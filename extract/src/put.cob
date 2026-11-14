*> EX-PUT USING path (PIC X(1100)), area (PIC X, any size), length (BINARY-LONG), status out (BINARY-LONG: 0, or 50 after
*> CCX-050 has been reported): writes one file with FILE-WRITE (create or truncate). Its own file: a caller in the same
*> source file would be size-checked against the one-byte area.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-PUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-AREA L-LENGTH L-STATUS.
     MOVE 0 TO L-STATUS
     CALL "FILE-WRITE" USING L-PATH L-AREA L-LENGTH WS-FILE-STATUS
     IF WS-FILE-STATUS NOT = FM-OK
         MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
         MOVE L-PATH TO EXM-ARG(1)
         MOVE "cannot be created or written" TO EXM-ARG(2)
         MOVE 50 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
     END-IF
     GOBACK.
 END PROGRAM EX-PUT.
