*> Directory services of the formats library (contracts/formats-api.md; 22 §7.2, §7.5): DIR-ENSURE (mkdir -p),
*> DIR-RENAME (the swap of the partial directory) and DIR-REMOVE-TREE (a tree walk through cc_fs_list), over
*> CBL_CREATE_DIR, CBL_RENAME_FILE, CBL_DELETE_FILE, CBL_DELETE_DIR. Paths are z-strings as in files.cob
*> (PIC X(1100)); every status word is one of FORMATS.cpy. cc_fs_list and CBL_CHECK_FILE_EXIST follow
*> symbolic links, so DIR-REMOVE-TREE asks the C library's readlink (a direct call, no glue) about every
*> path it is about to descend into: a link is unlinked as a link and never followed, so the target of
*> a link (a folder of the user's game directory, say) is never emptied.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIR-ENSURE.
*> USING path (z-string, PIC X(1100)), status out: the directory and every directory above it exist
*> afterwards. FM-OK (made or already there); FM-EXISTS (a file is where a directory is wanted);
*> FM-UNREADABLE (a directory cannot be created); FM-PATH-LONG. "/" separates, "//" and "./" are
*> harmless, a leading "/" is the root.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-PREFIX              PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PREFIX-LENGTH       BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-STATUS.
     CALL "FILE-PATH-Z" USING L-PATH WS-Z WS-LENGTH L-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH OR L-STATUS NOT = FM-OK
*>       Each directory of the path, from the top, ends at a "/" or at the end of the path.
         IF WS-Z(WS-I:1) = "/" OR WS-I = WS-LENGTH
             MOVE WS-I TO WS-PREFIX-LENGTH
             IF WS-Z(WS-I:1) = "/"
                 SUBTRACT 1 FROM WS-PREFIX-LENGTH
             END-IF
             IF WS-PREFIX-LENGTH > 0
                 MOVE LOW-VALUES TO WS-PREFIX
                 MOVE WS-Z(1:WS-PREFIX-LENGTH) TO WS-PREFIX(1:WS-PREFIX-LENGTH)
                 CALL "FILE-KIND" USING WS-PREFIX WS-SIZE WS-KIND
                 EVALUATE WS-KIND
                     WHEN 1
                         MOVE FM-EXISTS TO L-STATUS
                     WHEN 0
                         CALL "CBL_CREATE_DIR" USING WS-PREFIX
                         IF RETURN-CODE NOT = 0
                             MOVE FM-UNREADABLE TO L-STATUS
                         END-IF
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM DIR-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIR-RENAME.
*> USING from (z-string, PIC X(1100)), to (z-string), status out: one rename within a volume (atomic).
*> FM-OK; FM-NOT-FOUND (nothing at from); FM-EXISTS (something at to: nothing is changed);
*> FM-UNREADABLE (the system refused, for example a folder of to that is absent); FM-PATH-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-FROM                PIC X(1101).
 01 WS-TO                  PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-TO-KIND             BINARY-LONG.
 LINKAGE SECTION.
 01 L-FROM                 PIC X(1100).
 01 L-TO                   PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-STATUS.
     CALL "FILE-PATH-Z" USING L-FROM WS-FROM WS-LENGTH L-STATUS
     IF L-STATUS = FM-OK
         CALL "FILE-PATH-Z" USING L-TO WS-TO WS-LENGTH L-STATUS
     END-IF
     IF L-STATUS = FM-OK
         CALL "FILE-KIND" USING WS-FROM WS-SIZE WS-KIND
         CALL "FILE-KIND" USING WS-TO WS-SIZE WS-TO-KIND
         EVALUATE TRUE
             WHEN WS-KIND = 0
                 MOVE FM-NOT-FOUND TO L-STATUS
             WHEN WS-TO-KIND NOT = 0
                 MOVE FM-EXISTS TO L-STATUS
             WHEN OTHER
                 CALL "CBL_RENAME_FILE" USING WS-FROM WS-TO
                 IF RETURN-CODE NOT = 0
                     MOVE FM-UNREADABLE TO L-STATUS
                 END-IF
         END-EVALUATE
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM DIR-RENAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIR-REMOVE-TREE.
*> USING path (z-string, PIC X(1100)), status out: removes the directory and everything below it.
*> FM-OK; FM-NOT-FOUND (nothing there); FM-EXISTS (a file: left alone); FM-UNREADABLE (a directory cannot
*> be listed, or something in it cannot be removed: what was removed before stays removed); FM-PATH-LONG.
*> A symbolic link (also a dangling one), at the path or anywhere in the tree, is removed itself and not
*> followed; a link at the path is FM-OK once it is gone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-TARGET              PIC X(8).
 01 WS-TARGET-SIZE         BINARY-DOUBLE VALUE 8.
 01 WS-LINK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-STATUS.
     CALL "FILE-PATH-Z" USING L-PATH WS-Z WS-LENGTH L-STATUS
     IF L-STATUS = FM-OK
         CALL STATIC "readlink" USING BY REFERENCE WS-Z BY REFERENCE WS-TARGET
             BY VALUE WS-TARGET-SIZE RETURNING WS-LINK
         CALL "FILE-KIND" USING WS-Z WS-SIZE WS-KIND
         IF WS-LINK >= 0
             MOVE 3 TO WS-KIND
         END-IF
         EVALUATE WS-KIND
             WHEN 3
*>               A link: unlink it, unreadable until that has worked.
                 MOVE FM-UNREADABLE TO L-STATUS
                 CALL "CBL_DELETE_FILE" USING WS-Z
                 IF RETURN-CODE = 0
                     MOVE FM-OK TO L-STATUS
                 END-IF
             WHEN 0
                 MOVE FM-NOT-FOUND TO L-STATUS
             WHEN 1
                 MOVE FM-EXISTS TO L-STATUS
             WHEN OTHER
                 CALL "DIR-REMOVE-LEVEL" USING WS-Z L-STATUS
         END-EVALUATE
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM DIR-REMOVE-TREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIR-REMOVE-LEVEL IS RECURSIVE.
*> USING z-string path of an existing directory (PIC X(1101)), status out (FM-OK or FM-UNREADABLE): lists the
*> directory with cc_fs_list into a buffer that doubles until it holds the listing (a CC_SMALL answer writes
*> nothing), removes each file, removes each subdirectory by calling itself, then removes the directory.
*> Paths stay below the operating system's limit of 1024 bytes, so a child path fits PIC X(1101).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FORMATS.
 01 B-LIST                 PIC X(16777216) BASED.
 LOCAL-STORAGE SECTION.
 01 LS-CAPACITY            BINARY-LONG.
 01 LS-LIST-ADDR           USAGE POINTER.
 01 LS-COUNT               BINARY-LONG.
 01 LS-RC                  BINARY-LONG.
 01 LS-POS                 BINARY-LONG.
 01 LS-END                 BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-PATH-LENGTH         BINARY-LONG.
 01 LS-NAME-LENGTH         BINARY-LONG.
 01 LS-CHILD               PIC X(1101).
 01 LS-TARGET              PIC X(8).
 01 LS-TARGET-SIZE         BINARY-DOUBLE VALUE 8.
 01 LS-LINK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-Z                    PIC X(1101).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-Z L-STATUS.
     MOVE FM-OK TO L-STATUS
     MOVE 4096 TO LS-CAPACITY
     MOVE 5 TO LS-RC
     PERFORM UNTIL LS-RC NOT = 5
         ALLOCATE LS-CAPACITY CHARACTERS RETURNING LS-LIST-ADDR
         SET ADDRESS OF B-LIST TO LS-LIST-ADDR
         MOVE 0 TO LS-COUNT
         CALL STATIC "cc_fs_list" USING BY REFERENCE L-Z BY REFERENCE B-LIST
             BY VALUE LS-CAPACITY BY REFERENCE LS-COUNT RETURNING LS-RC
         IF LS-RC = 5
             FREE LS-LIST-ADDR
             COMPUTE LS-CAPACITY = LS-CAPACITY * 2
         END-IF
     END-PERFORM
     IF LS-RC NOT = 0
         MOVE FM-UNREADABLE TO L-STATUS
         FREE LS-LIST-ADDR
     END-IF
     IF LS-RC = 0
         MOVE 0 TO LS-PATH-LENGTH
         INSPECT L-Z TALLYING LS-PATH-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
         MOVE 1 TO LS-POS
*>       Entries are "<type><name>" lines: F a file, D a directory.
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT OR L-STATUS NOT = FM-OK
*>           B-LIST is shared by every level of the recursion: point it at this level's listing again.
             SET ADDRESS OF B-LIST TO LS-LIST-ADDR
             MOVE LS-POS TO LS-END
             PERFORM UNTIL B-LIST(LS-END:1) = X"0A"
                 ADD 1 TO LS-END
             END-PERFORM
             COMPUTE LS-NAME-LENGTH = LS-END - LS-POS - 1
             MOVE LOW-VALUES TO LS-CHILD
             MOVE L-Z(1:LS-PATH-LENGTH) TO LS-CHILD(1:LS-PATH-LENGTH)
             MOVE "/" TO LS-CHILD(LS-PATH-LENGTH + 1:1)
             MOVE B-LIST(LS-POS + 1:LS-NAME-LENGTH) TO LS-CHILD(LS-PATH-LENGTH + 2:LS-NAME-LENGTH)
*>           A link (to a directory too) is unlinked, never entered.
             CALL STATIC "readlink" USING BY REFERENCE LS-CHILD BY REFERENCE LS-TARGET
                 BY VALUE LS-TARGET-SIZE RETURNING LS-LINK
             IF B-LIST(LS-POS:1) = "D" AND LS-LINK < 0
                 CALL "DIR-REMOVE-LEVEL" USING LS-CHILD L-STATUS
             ELSE
                 CALL "CBL_DELETE_FILE" USING LS-CHILD
                 IF RETURN-CODE NOT = 0
                     MOVE FM-UNREADABLE TO L-STATUS
                 END-IF
             END-IF
             COMPUTE LS-POS = LS-END + 1
         END-PERFORM
         FREE LS-LIST-ADDR
         IF L-STATUS = FM-OK
             CALL "CBL_DELETE_DIR" USING L-Z
             IF RETURN-CODE NOT = 0
                 MOVE FM-UNREADABLE TO L-STATUS
             END-IF
         END-IF
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM DIR-REMOVE-LEVEL.
