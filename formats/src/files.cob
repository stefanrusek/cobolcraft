*> File services of the formats library (contracts/formats-api.md; 22 §7.2): thin COBOL wrappers over the
*> GnuCOBOL byte-stream routines CBL_OPEN_FILE, CBL_READ_FILE, CBL_WRITE_FILE, CBL_CHECK_FILE_EXIST, with
*> cc_fs_list to tell a directory from a file. FILE-READ-ALL (moved from the client's pack source, with
*> its own path-and-length convention and the status words 0, 1 and 5 it has always had) reads a whole
*> file; FILE-READ-AT, FILE-WRITE and FILE-EXISTS take a z-string path (PIC X(1100): a NUL ends it, a
*> space-padded field works too, FM-PATH-LONG when neither ends inside the 1100 bytes) and answer with a
*> status word of FORMATS.cpy. FILE-PATH-Z and FILE-KIND are their shared helpers (and dirs.cob's).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-READ-ALL.
*> USING path (PIC X(1100)), path length, area, capacity, length out, status out (0 read; 1 the
*> file cannot be opened or read; 5 larger than the capacity: length out is its size, nothing read).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(1101).
 01 WS-INFO.
    05 WS-SIZE             PIC X(8) COMP-X.
    05 FILLER              PIC X(8).
 01 WS-ACCESS              PIC X COMP-X VALUE 1.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X VALUE 0.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               PIC X COMP-X VALUE 0.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-PATH-LENGTH L-AREA L-CAPACITY L-LENGTH L-STATUS.
     MOVE 0 TO L-LENGTH
     MOVE 1 TO L-STATUS
     MOVE SPACES TO WS-PATH
     MOVE L-PATH(1:L-PATH-LENGTH) TO WS-PATH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     MOVE WS-SIZE TO L-LENGTH
     IF WS-SIZE > L-CAPACITY
         MOVE 5 TO L-STATUS
         GOBACK
     END-IF
     CALL "CBL_OPEN_FILE" USING WS-PATH WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE L-LENGTH
         GOBACK
     END-IF
     MOVE WS-SIZE TO WS-COUNT
     CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS L-AREA
     CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     MOVE 0 TO L-STATUS RETURN-CODE
     GOBACK.
 END PROGRAM FILE-READ-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-PATH-Z.
*> USING path (PIC X(1100)), z-string out (PIC X(1101), NUL terminated), length out (BINARY-LONG: the bytes
*> of the path), status out (FM-OK, or FM-PATH-LONG when the path has no end inside the 1100 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-Z                    PIC X(1101).
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-Z L-LENGTH L-STATUS.
     MOVE LOW-VALUES TO L-Z
     MOVE FM-OK TO L-STATUS
     MOVE 0 TO WS-LENGTH
     INSPECT L-PATH TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
     IF WS-LENGTH = FM-PATH-MAX
*>       No NUL: the path ends where its space padding starts.
         IF L-PATH(FM-PATH-MAX:1) NOT = SPACE
             MOVE FM-PATH-LONG TO L-STATUS
         END-IF
         PERFORM UNTIL WS-LENGTH < 1 OR L-PATH(WS-LENGTH:1) NOT = SPACE
             SUBTRACT 1 FROM WS-LENGTH
         END-PERFORM
     END-IF
     MOVE WS-LENGTH TO L-LENGTH
     IF WS-LENGTH > 0 AND L-STATUS = FM-OK
         MOVE L-PATH(1:WS-LENGTH) TO L-Z(1:WS-LENGTH)
     END-IF
     GOBACK.
 END PROGRAM FILE-PATH-Z.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-KIND.
*> USING z-string path (PIC X(1101)), size out (BINARY-DOUBLE: the size of a file), kind out (BINARY-LONG:
*> 0 nothing there, 1 a file, 2 a directory; a directory is what cc_fs_list can open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INFO.
    05 WS-SIZE             PIC X(8) COMP-X.
    05 FILLER              PIC X(8).
 01 WS-LIST                PIC X.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-Z                    PIC X(1101).
 01 L-SIZE                 BINARY-DOUBLE.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-Z L-SIZE L-KIND.
     MOVE 0 TO L-SIZE L-KIND
     CALL "CBL_CHECK_FILE_EXIST" USING L-Z WS-INFO
     IF RETURN-CODE = 0
         MOVE WS-SIZE TO L-SIZE
         MOVE 1 TO L-KIND
         CALL STATIC "cc_fs_list" USING BY REFERENCE L-Z BY REFERENCE WS-LIST
             BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
         IF WS-RC = 0 OR WS-RC = 5
             MOVE 2 TO L-KIND
             MOVE 0 TO L-SIZE
         END-IF
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM FILE-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-EXISTS.
*> USING path (z-string, PIC X(1100)), status out: FM-OK a file exists, FM-NOT-FOUND nothing is there,
*> FM-IS-DIR a directory exists, FM-PATH-LONG the path has no end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-STATUS.
     CALL "FILE-PATH-Z" USING L-PATH WS-Z WS-LENGTH L-STATUS
     IF L-STATUS = FM-OK
         CALL "FILE-KIND" USING WS-Z WS-SIZE WS-KIND
         EVALUATE WS-KIND
             WHEN 0
                 MOVE FM-NOT-FOUND TO L-STATUS
             WHEN 2
                 MOVE FM-IS-DIR TO L-STATUS
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM FILE-EXISTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-READ-AT.
*> USING path (z-string, PIC X(1100)), offset (BINARY-DOUBLE, 0-based byte offset), area (any size), length
*> (BINARY-LONG: the bytes asked in, the bytes read out: fewer at the end of the file, 0 at or past it),
*> status out: FM-OK; FM-NOT-FOUND (no such file); FM-UNREADABLE (a directory, or a file that cannot be
*> opened or read); FM-PATH-LONG. The length is 0 unless the status is FM-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-ASKED               BINARY-LONG.
 01 WS-ACCESS              PIC X COMP-X VALUE 1.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               PIC X COMP-X VALUE 0.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-OFFSET               BINARY-DOUBLE.
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-OFFSET L-AREA L-LENGTH L-STATUS.
     MOVE L-LENGTH TO WS-ASKED
     MOVE 0 TO L-LENGTH
     CALL "FILE-PATH-Z" USING L-PATH WS-Z WS-LENGTH L-STATUS
     IF L-STATUS NOT = FM-OK
         GOBACK
     END-IF
     CALL "FILE-KIND" USING WS-Z WS-SIZE WS-KIND
     EVALUATE TRUE
         WHEN WS-KIND = 0
             MOVE FM-NOT-FOUND TO L-STATUS
         WHEN WS-KIND = 2
             MOVE FM-UNREADABLE TO L-STATUS
         WHEN WS-ASKED > 0 AND L-OFFSET < WS-SIZE
*>           Bytes before the end of the file only.
             COMPUTE WS-ASKED = FUNCTION MIN(WS-ASKED, WS-SIZE - L-OFFSET)
*>           Unreadable until the bytes are read: a failed open or read leaves it so.
             MOVE FM-UNREADABLE TO L-STATUS
             CALL "CBL_OPEN_FILE" USING WS-Z WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
             IF RETURN-CODE = 0
                 MOVE L-OFFSET TO WS-OFFSET
                 MOVE WS-ASKED TO WS-COUNT
                 CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS L-AREA
                 IF RETURN-CODE = 0
                     MOVE WS-ASKED TO L-LENGTH
                     MOVE FM-OK TO L-STATUS
                 END-IF
                 CALL "CBL_CLOSE_FILE" USING WS-HANDLE
             END-IF
     END-EVALUATE
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM FILE-READ-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-WRITE.
*> USING path (z-string, PIC X(1100)), area (any size), length (BINARY-LONG), status out: creates the file
*> or truncates it and writes the bytes. FM-OK; FM-UNREADABLE (the file cannot be created: a folder that
*> is absent or not writable); FM-SHORT-WRITE (the disk took fewer bytes); FM-PATH-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ACCESS              PIC X COMP-X VALUE 2.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X VALUE 0.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               PIC X COMP-X VALUE 0.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-AREA                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-AREA L-LENGTH L-STATUS.
     CALL "FILE-PATH-Z" USING L-PATH WS-Z WS-LENGTH L-STATUS
     IF L-STATUS = FM-OK
         CALL "CBL_CREATE_FILE" USING WS-Z WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
         IF RETURN-CODE NOT = 0
             MOVE FM-UNREADABLE TO L-STATUS
         ELSE
             IF L-LENGTH > 0
                 MOVE L-LENGTH TO WS-COUNT
                 CALL "CBL_WRITE_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS L-AREA
                 IF RETURN-CODE NOT = 0
                     MOVE FM-SHORT-WRITE TO L-STATUS
                 END-IF
             END-IF
             CALL "CBL_CLOSE_FILE" USING WS-HANDLE
         END-IF
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM FILE-WRITE.
