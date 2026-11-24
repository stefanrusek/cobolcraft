*> Pack sources (08 §1.1 to §1.5, §3.3, §10): each pack of the stack (PK-PACK of CLSTATE.cpy) is
*> read through its source kind. Kind 0 is the built-in pack (builtin.cob); kind 1 a folder and
*> kind 2 a zip archive (zip.cob), local (US18-1) or downloaded from a server (US18-6).
*> PACK-SOURCE-OPEN opens a folder or zip pack and reads its pack.mcmeta (mcmeta.cob);
*> PACK-SOURCE-FILES lists the files it serves: every valid path under assets/ (§1.3, §1.4) of the
*> root and of its active overlays (§1.5: a later overlay replaces an earlier one, an overlay the
*> root), without the paths a pack above hides with its filter (§3.3; PACK-HIDDEN), which also
*> hides them in the built-in pack. PACK-SOURCE-PATH, -HAS, -READ and -IMAGE serve those files; a
*> listed file that cannot be read or decoded is reported (PACK-ERROR-ADD, bad_file) and found as
*> missing.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-OPEN.
*> USING CLIENT-STATE, pack (PK-KIND 1 or 2 and PK-ROOT set), problem out (BINARY-LONG: 0 open,
*> 1 the pack cannot be read, 2 pack.mcmeta is missing, 3 pack.mcmeta has no usable pack section).
*> Open: PK-ZIP (a zip) and PK-META (its PACK-META) are allocated, PK-FILES empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(256) VALUE "pack.mcmeta".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 11.
 01 WS-TEXT                PIC X(262144).
 01 WS-CAP                 BINARY-LONG VALUE 262144.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PROBLEM              BINARY-LONG.
 COPY CLMCMETA.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PROBLEM.
     MOVE 0 TO L-PROBLEM PK-FILE-COUNT(L-PACK)
     SET PK-ZIP(L-PACK) PK-META(L-PACK) PK-FILES(L-PACK) TO NULL
     IF PK-KIND(L-PACK) = 2
         CALL "ZIP-OPEN" USING PK-ROOT(L-PACK) PK-ROOT-LENGTH(L-PACK) PK-ZIP(L-PACK) WS-STATUS
         IF WS-STATUS NOT = 0
             MOVE 1 TO L-PROBLEM
             GOBACK
         END-IF
     END-IF
     CALL "PACK-ROOT-READ" USING CLIENT-STATE L-PACK WS-NAME WS-NAME-LENGTH WS-TEXT WS-CAP
         WS-LENGTH WS-FOUND
     IF WS-FOUND = 0
         MOVE 2 TO L-PROBLEM
         GOBACK
     END-IF
     MOVE LENGTH OF PACK-META TO WS-BYTES
     ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING PK-META(L-PACK)
     SET ADDRESS OF PACK-META TO PK-META(L-PACK)
     CALL "MCMETA-PARSE" USING CLIENT-STATE WS-TEXT WS-LENGTH PACK-META
     CALL "MCMETA-REPORT" USING PK-ID(L-PACK) PK-ID-LENGTH(L-PACK) PACK-META
     IF PM-VALID = 0
         MOVE 3 TO L-PROBLEM
     END-IF
     GOBACK.
 END PROGRAM PACK-SOURCE-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-CLOSE.
*> USING CLIENT-STATE, pack: frees what PACK-SOURCE-OPEN and PACK-SOURCE-FILES allocated.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK.
     CALL "ZIP-CLOSE" USING PK-ZIP(L-PACK)
     IF PK-META(L-PACK) NOT = NULL
         FREE PK-META(L-PACK)
     END-IF
     IF PK-FILES(L-PACK) NOT = NULL
         FREE PK-FILES(L-PACK)
     END-IF
     MOVE 0 TO PK-FILE-COUNT(L-PACK)
     GOBACK.
 END PROGRAM PACK-SOURCE-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-ROOT-READ.
*> USING CLIENT-STATE, pack (kind 1 or 2, open), name (PIC X(256), relative to the pack root),
*> name length, area, capacity, length out, found out: the bytes of a file at the pack root
*> (pack.mcmeta, pack.png: always the root, 08 §1.5); not found when absent, unreadable or larger
*> than the capacity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-NAME                 PIC X(256).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-NAME L-NAME-LENGTH L-AREA L-CAPACITY L-LENGTH
         L-FOUND.
     MOVE 0 TO L-FOUND
     IF PK-KIND(L-PACK) = 2
         CALL "ZIP-FIND" USING PK-ZIP(L-PACK) L-NAME L-NAME-LENGTH WS-INDEX
         MOVE 1 TO WS-STATUS
         IF WS-INDEX > 0
             CALL "ZIP-READ" USING PK-ZIP(L-PACK) WS-INDEX L-AREA L-CAPACITY L-LENGTH WS-STATUS
         END-IF
     ELSE
         MOVE SPACES TO WS-PATH
         STRING PK-ROOT(L-PACK)(1:PK-ROOT-LENGTH(L-PACK)) "/" L-NAME(1:L-NAME-LENGTH)
             DELIMITED BY SIZE INTO WS-PATH
         COMPUTE WS-PATH-LENGTH = PK-ROOT-LENGTH(L-PACK) + 1 + L-NAME-LENGTH
         CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH L-AREA L-CAPACITY L-LENGTH WS-STATUS
     END-IF
     IF WS-STATUS = 0
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM PACK-ROOT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-FILES.
*> USING CLIENT-STATE, pack (kind 1 or 2, open; the packs above it open with their PK-META): the
*> pack's file table PK-FILES (at most CL-MAX-PACK-FILES entries of 268 bytes: logical path
*> PIC X(256), its length, the zip entry index (zip) or 0, the overlay (0 the root, else its
*> PM-OVERLAY row)). The root's files come first, then each active overlay's in declaration
*> order, a later copy of a path replacing the earlier one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-TABLE.
    05 WS-COUNT            BINARY-LONG.
    05 WS-FILE OCCURS 16384 TIMES.
       10 WS-F-PATH        PIC X(256).
       10 WS-F-LENGTH      BINARY-LONG.
       10 WS-F-INDEX       BINARY-LONG.
       10 WS-F-OVERLAY     BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-PREFIX              PIC X(80).
 01 WS-PREFIX-LENGTH       BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 B-FILES                PIC X(4390912) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 COPY CLMCMETA.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK.
     MOVE 0 TO WS-COUNT
     SET ADDRESS OF PACK-META TO PK-META(L-PACK)
     PERFORM VARYING WS-OVERLAY FROM 0 BY 1 UNTIL WS-OVERLAY > PM-OVERLAY-COUNT
*>       The directory prefix of this layer: "" for the root, "<directory>/" for an overlay.
         MOVE 0 TO WS-PREFIX-LENGTH
         MOVE SPACES TO WS-PREFIX
         IF WS-OVERLAY > 0
             MOVE PM-OVERLAY-DIR-LENGTH(WS-OVERLAY) TO WS-PREFIX-LENGTH
             MOVE PM-OVERLAY-DIR(WS-OVERLAY) TO WS-PREFIX
             ADD 1 TO WS-PREFIX-LENGTH
             MOVE "/" TO WS-PREFIX(WS-PREFIX-LENGTH:1)
         END-IF
         IF WS-OVERLAY = 0 OR PM-OVERLAY-ACTIVE(WS-OVERLAY) = 1
             IF PK-KIND(L-PACK) = 2
                 CALL "ZIP-COUNT" USING PK-ZIP(L-PACK) WS-ENTRIES
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ENTRIES
                     CALL "ZIP-NAME" USING PK-ZIP(L-PACK) WS-I WS-NAME WS-NAME-LENGTH
                     IF WS-NAME-LENGTH > WS-PREFIX-LENGTH
                         IF WS-PREFIX-LENGTH = 0 OR WS-NAME(1:WS-PREFIX-LENGTH) =
                                 WS-PREFIX(1:WS-PREFIX-LENGTH)
                             MOVE WS-I TO WS-INDEX
                             CALL "PACK-FILE-ADD" USING CLIENT-STATE L-PACK WS-TABLE WS-NAME
                                 WS-NAME-LENGTH WS-PREFIX-LENGTH WS-INDEX WS-OVERLAY
                         END-IF
                     END-IF
                 END-PERFORM
             ELSE
                 CALL "PACK-FOLDER-SCAN" USING CLIENT-STATE L-PACK WS-TABLE WS-PREFIX
                     WS-PREFIX-LENGTH WS-OVERLAY
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO PK-FILE-COUNT(L-PACK)
     COMPUTE WS-BYTES = FUNCTION MAX(WS-COUNT, 1) * 268
     ALLOCATE WS-BYTES CHARACTERS RETURNING PK-FILES(L-PACK)
     SET ADDRESS OF B-FILES TO PK-FILES(L-PACK)
     MOVE WS-TABLE(5:WS-BYTES) TO B-FILES(1:WS-BYTES)
     GOBACK.
 END PROGRAM PACK-SOURCE-FILES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FOLDER-SCAN.
*> USING CLIENT-STATE, pack (a folder), file table (PACK-SOURCE-FILES layout), layer prefix
*> (PIC X(80): "" or "<overlay>/"), prefix length, overlay: every file under
*> <root>/<prefix>assets, depth first (cc_fs_list; at most 512 directories pending: the vanilla textures/entity directory alone has 79 sub-directories), offered to
*> PACK-FILE-ADD with its path relative to the root.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STACK.
    05 WS-DIR OCCURS 512 TIMES.
       10 WS-DIR-PATH      PIC X(256).
       10 WS-DIR-LENGTH    BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-CUR                 PIC X(256).
 01 WS-CUR-LENGTH          BINARY-LONG.
 01 WS-DIRZ                PIC X(1400).
*> A directory listing of the generated vanilla pack is about 80,000 bytes (models/block alone has
*> 2,900 names); a listing that does not fit is dropped whole by cc_fs_list, which hid every model.
 01 WS-LIST                PIC X(524288).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 524288.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-TABLE                PIC X(4390916).
 01 L-PREFIX               PIC X(80).
 01 L-PREFIX-LENGTH        BINARY-LONG.
 01 L-OVERLAY              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-TABLE L-PREFIX L-PREFIX-LENGTH L-OVERLAY.
     MOVE 1 TO WS-DEPTH
     MOVE SPACES TO WS-DIR-PATH(1)
     STRING L-PREFIX(1:L-PREFIX-LENGTH) "assets" DELIMITED BY SIZE INTO WS-DIR-PATH(1)
     COMPUTE WS-DIR-LENGTH(1) = L-PREFIX-LENGTH + 6
     PERFORM UNTIL WS-DEPTH = 0
         MOVE WS-DIR-PATH(WS-DEPTH) TO WS-CUR
         MOVE WS-DIR-LENGTH(WS-DEPTH) TO WS-CUR-LENGTH
         SUBTRACT 1 FROM WS-DEPTH
         MOVE LOW-VALUES TO WS-DIRZ
         STRING PK-ROOT(L-PACK)(1:PK-ROOT-LENGTH(L-PACK)) "/" WS-CUR(1:WS-CUR-LENGTH)
             DELIMITED BY SIZE INTO WS-DIRZ
         MOVE 0 TO WS-LIST-COUNT
         CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
             BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
         MOVE 1 TO WS-PTR
         PERFORM WS-LIST-COUNT TIMES
             MOVE SPACES TO WS-ENTRY
             UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-LENGTH
                 WITH POINTER WS-PTR
             MOVE SPACES TO WS-PATH
             STRING WS-CUR(1:WS-CUR-LENGTH) "/" WS-ENTRY(2:WS-LENGTH - 1) DELIMITED BY SIZE
                 INTO WS-PATH
             COMPUTE WS-PATH-LENGTH = FUNCTION MIN(WS-CUR-LENGTH + WS-LENGTH, 256)
             EVALUATE TRUE
                 WHEN WS-ENTRY(1:1) = "F"
                     CALL "PACK-FILE-ADD" USING CLIENT-STATE L-PACK L-TABLE WS-PATH
                         WS-PATH-LENGTH L-PREFIX-LENGTH WS-ZERO L-OVERLAY
                 WHEN WS-DEPTH < 512
                     ADD 1 TO WS-DEPTH
                     MOVE WS-PATH TO WS-DIR-PATH(WS-DEPTH)
                     MOVE WS-PATH-LENGTH TO WS-DIR-LENGTH(WS-DEPTH)
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-FOLDER-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FILE-ADD.
*> USING CLIENT-STATE, pack, file table, path (PIC X(256), relative to the pack root), path
*> length, prefix length (the overlay directory and "/" to drop), zip entry index, overlay: adds
*> (or replaces) the logical path when it is valid (PACK-PATH-VALID) and not hidden by a pack
*> above (PACK-HIDDEN); a full table takes no more.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-TABLE.
    05 L-COUNT             BINARY-LONG.
    05 L-FILE OCCURS 16384 TIMES.
       10 L-F-PATH         PIC X(256).
       10 L-F-LENGTH       BINARY-LONG.
       10 L-F-INDEX        BINARY-LONG.
       10 L-F-OVERLAY      BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-PREFIX-LENGTH        BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-OVERLAY              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-TABLE L-PATH L-PATH-LENGTH L-PREFIX-LENGTH
         L-INDEX L-OVERLAY.
     MOVE SPACES TO WS-PATH
     COMPUTE WS-LENGTH = L-PATH-LENGTH - L-PREFIX-LENGTH
     MOVE L-PATH(L-PREFIX-LENGTH + 1:WS-LENGTH) TO WS-PATH
     CALL "PACK-PATH-VALID" USING WS-PATH WS-LENGTH WS-VALID
     IF WS-VALID = 0
         GOBACK
     END-IF
     CALL "PACK-HIDDEN" USING CLIENT-STATE L-PACK WS-PATH WS-LENGTH WS-HIDDEN
     IF WS-HIDDEN = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR WS-AT > 0
         IF L-F-LENGTH(WS-I) = WS-LENGTH AND L-F-PATH(WS-I) = WS-PATH
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT = 0 AND L-COUNT < CL-MAX-PACK-FILES
         ADD 1 TO L-COUNT
         MOVE L-COUNT TO WS-AT
     END-IF
     IF WS-AT > 0
         MOVE WS-PATH TO L-F-PATH(WS-AT)
         MOVE WS-LENGTH TO L-F-LENGTH(WS-AT)
         MOVE L-INDEX TO L-F-INDEX(WS-AT)
         MOVE L-OVERLAY TO L-F-OVERLAY(WS-AT)
     END-IF
     GOBACK.
 END PROGRAM PACK-FILE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-PATH-VALID.
*> USING path (PIC X(256)), length, valid out (BINARY-LONG): 1 for assets/<namespace>/<path> with
*> a namespace of a-z 0-9 _ - . (08 §1.3) and path segments of a-z 0-9 _ - . that are not empty,
*> "." or ".." (§1.4), the last not ".ds_store".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-SEGMENT             BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-SLASHES             BINARY-LONG.
 01 WS-SEG                 PIC X(256).
 01 WS-SEG-LENGTH          BINARY-LONG.
 01 WS-C                   PIC X.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH L-VALID.
     MOVE 0 TO L-VALID WS-SLASHES
     IF L-LENGTH < 10 OR L-PATH(1:7) NOT = "assets/"
         GOBACK
     END-IF
     MOVE 8 TO WS-START
     PERFORM VARYING WS-I FROM 8 BY 1 UNTIL WS-I > L-LENGTH + 1
         IF WS-I > L-LENGTH
             MOVE "/" TO WS-C
         ELSE
             MOVE L-PATH(WS-I:1) TO WS-C
         END-IF
         EVALUATE TRUE
             WHEN WS-C = "/"
                 COMPUTE WS-SEG-LENGTH = WS-I - WS-START
                 IF WS-SEG-LENGTH = 0
                     GOBACK
                 END-IF
                 MOVE SPACES TO WS-SEG
                 MOVE L-PATH(WS-START:WS-SEG-LENGTH) TO WS-SEG
                 IF WS-SEG = "." OR WS-SEG = ".." OR WS-SEG = ".ds_store"
                     GOBACK
                 END-IF
                 ADD 1 TO WS-SLASHES
                 COMPUTE WS-START = WS-I + 1
             WHEN WS-C >= "a" AND WS-C <= "z"
             WHEN WS-C >= "0" AND WS-C <= "9"
             WHEN WS-C = "_" OR WS-C = "-" OR WS-C = "."
                 CONTINUE
             WHEN OTHER
                 GOBACK
         END-EVALUATE
     END-PERFORM
     IF WS-SLASHES >= 2
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM PACK-PATH-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-HIDDEN.
*> USING CLIENT-STATE, pack, path (PIC X(256), assets/<namespace>/<path>), length, hidden out
*> (BINARY-LONG): 1 when a pack above has a filter entry matching the namespace and the path (08
*> §3.3; MCMETA-FILTERS), a .mcmeta companion matching as its file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-NS                  PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-REST                PIC X(256).
 01 WS-REST-LENGTH         BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-HIDDEN               BINARY-LONG.
 COPY CLMCMETA.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-HIDDEN.
     MOVE 0 TO L-HIDDEN WS-SLASH
     IF L-LENGTH < 10 OR L-PATH(1:7) NOT = "assets/"
         GOBACK
     END-IF
     INSPECT L-PATH(8:L-LENGTH - 7) TALLYING WS-SLASH FOR CHARACTERS BEFORE INITIAL "/"
     MOVE SPACES TO WS-NS WS-REST
     MOVE FUNCTION MIN(WS-SLASH, 64) TO WS-NS-LENGTH
     MOVE L-PATH(8:WS-NS-LENGTH) TO WS-NS
     COMPUTE WS-REST-LENGTH = L-LENGTH - 8 - WS-SLASH
     MOVE L-PATH(9 + WS-SLASH:WS-REST-LENGTH) TO WS-REST
     IF WS-REST-LENGTH > 7
         IF WS-REST(WS-REST-LENGTH - 6:7) = ".mcmeta"
             MOVE SPACES TO WS-REST(WS-REST-LENGTH - 6:7)
             SUBTRACT 7 FROM WS-REST-LENGTH
         END-IF
     END-IF
     PERFORM VARYING WS-ABOVE FROM L-PACK BY 1 UNTIL WS-ABOVE >= PK-COUNT OR L-HIDDEN = 1
         IF PK-META(WS-ABOVE + 1) NOT = NULL
             SET ADDRESS OF PACK-META TO PK-META(WS-ABOVE + 1)
             CALL "MCMETA-FILTERS" USING PACK-META WS-NS WS-NS-LENGTH WS-REST WS-REST-LENGTH
                 WS-HIT
             MOVE WS-HIT TO L-HIDDEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-HIDDEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FILE-FIND.
*> USING CLIENT-STATE, pack (kind 1 or 2), path (PIC X(256)), length, file index out (0 = the pack
*> does not serve it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY.
    05 WS-F-PATH           PIC X(256).
    05 WS-F-LENGTH         BINARY-LONG.
    05 WS-F-INDEX          BINARY-LONG.
    05 WS-F-OVERLAY        BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 B-TABLE                PIC X(4390912) BASED.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-INDEX.
     MOVE 0 TO L-INDEX
     SET ADDRESS OF B-TABLE TO PK-FILES(L-PACK)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-FILE-COUNT(L-PACK) OR L-INDEX > 0
         MOVE B-TABLE((WS-I - 1) * 268 + 1:268) TO WS-ENTRY
         IF WS-F-LENGTH = L-LENGTH AND WS-F-PATH = L-PATH
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-FILE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FILE-BYTES.
*> USING CLIENT-STATE, pack (kind 1 or 2), file index, area, capacity, length out, status out (0
*> read, 1 unreadable, 5 larger than the capacity: length out is its size).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ENTRY.
    05 WS-F-PATH           PIC X(256).
    05 WS-F-LENGTH         BINARY-LONG.
    05 WS-F-INDEX          BINARY-LONG.
    05 WS-F-OVERLAY        BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 B-TABLE                PIC X(4390912) BASED.
 COPY CLMCMETA.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-INDEX L-AREA L-CAPACITY L-LENGTH L-STATUS.
     SET ADDRESS OF B-TABLE TO PK-FILES(L-PACK)
     MOVE B-TABLE((L-INDEX - 1) * 268 + 1:268) TO WS-ENTRY
     IF PK-KIND(L-PACK) = 2
         CALL "ZIP-SIZE" USING PK-ZIP(L-PACK) WS-F-INDEX WS-SIZE
         MOVE WS-SIZE TO L-LENGTH
         MOVE 5 TO L-STATUS
         IF WS-SIZE <= L-CAPACITY
             CALL "ZIP-READ" USING PK-ZIP(L-PACK) WS-F-INDEX L-AREA L-CAPACITY L-LENGTH
                 WS-STATUS
             MOVE FUNCTION MIN(WS-STATUS, 1) TO L-STATUS
         END-IF
         GOBACK
     END-IF
     MOVE SPACES TO WS-PATH
     MOVE 1 TO WS-PTR
     STRING PK-ROOT(L-PACK)(1:PK-ROOT-LENGTH(L-PACK)) "/" DELIMITED BY SIZE INTO WS-PATH
         WITH POINTER WS-PTR
     IF WS-F-OVERLAY > 0
         SET ADDRESS OF PACK-META TO PK-META(L-PACK)
         STRING PM-OVERLAY-DIR(WS-F-OVERLAY)(1:PM-OVERLAY-DIR-LENGTH(WS-F-OVERLAY)) "/"
             DELIMITED BY SIZE INTO WS-PATH WITH POINTER WS-PTR
     END-IF
     STRING WS-F-PATH(1:WS-F-LENGTH) DELIMITED BY SIZE INTO WS-PATH WITH POINTER WS-PTR
     COMPUTE WS-PATH-LENGTH = WS-PTR - 1
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH L-AREA L-CAPACITY L-LENGTH L-STATUS
     GOBACK.
 END PROGRAM PACK-FILE-BYTES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-PATH.
*> USING CLIENT-STATE, pack (stack index), file index (1-based), path out (PIC X(256)), path length
*> out, found out (0 past the pack's last file): enumerates the pack's files. A built-in file a pack
*> above hides, and the path past the last file of a folder or zip pack, is given as "filtered"
*> (matching no asset kind).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HIDDEN              BINARY-LONG.
 01 WS-ENTRY.
    05 WS-F-PATH           PIC X(256).
    05 WS-F-LENGTH         BINARY-LONG.
    05 WS-F-INDEX          BINARY-LONG.
    05 WS-F-OVERLAY        BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 B-TABLE                PIC X(4390912) BASED.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-INDEX L-PATH L-LENGTH L-FOUND.
     IF PK-KIND(L-PACK) = 3
         MOVE 0 TO L-FOUND
         MOVE "filtered" TO L-PATH
         MOVE 8 TO L-LENGTH
         GOBACK
     END-IF
     IF PK-KIND(L-PACK) = 0
         CALL "BUILTIN-PATH" USING L-INDEX L-PATH L-LENGTH L-FOUND
         IF L-FOUND = 1
             CALL "PACK-HIDDEN" USING CLIENT-STATE L-PACK L-PATH L-LENGTH WS-HIDDEN
             IF WS-HIDDEN = 1
                 MOVE "filtered" TO L-PATH
                 MOVE 8 TO L-LENGTH
             END-IF
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO L-FOUND
     MOVE "filtered" TO L-PATH
     MOVE 8 TO L-LENGTH
     IF L-INDEX <= PK-FILE-COUNT(L-PACK)
         SET ADDRESS OF B-TABLE TO PK-FILES(L-PACK)
         MOVE B-TABLE((L-INDEX - 1) * 268 + 1:268) TO WS-ENTRY
         MOVE WS-F-PATH TO L-PATH
         MOVE WS-F-LENGTH TO L-LENGTH
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM PACK-SOURCE-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-HAS.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, found out (1 = the pack has the file
*> and no pack above hides it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-HIDDEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-FOUND.
     IF PK-KIND(L-PACK) = 3
         CALL "SKIN-FIND" USING L-PATH L-LENGTH WS-INDEX
         MOVE FUNCTION MIN(WS-INDEX, 1) TO L-FOUND
         GOBACK
     END-IF
     IF PK-KIND(L-PACK) = 0
         CALL "BUILTIN-FIND" USING L-PATH L-LENGTH WS-INDEX
         MOVE FUNCTION MIN(WS-INDEX, 1) TO L-FOUND
         IF L-FOUND = 1
             CALL "PACK-HIDDEN" USING CLIENT-STATE L-PACK L-PATH L-LENGTH WS-HIDDEN
             COMPUTE L-FOUND = 1 - WS-HIDDEN
         END-IF
     ELSE
         CALL "PACK-FILE-FIND" USING CLIENT-STATE L-PACK L-PATH L-LENGTH WS-INDEX
         MOVE FUNCTION MIN(WS-INDEX, 1) TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM PACK-SOURCE-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-READ.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, area, capacity, length out, found out:
*> the file's bytes; a file larger than the capacity is not found; a listed file that cannot be
*> read is reported (bad_file) and not found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.packs.problem.bad_file".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-OUT-LENGTH           BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH
         L-FOUND.
     IF PK-KIND(L-PACK) = 3
         CALL "SKIN-READ" USING L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH L-FOUND
         GOBACK
     END-IF
     IF PK-KIND(L-PACK) = 0
         CALL "BUILTIN-READ" USING L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH L-FOUND
         GOBACK
     END-IF
     MOVE 0 TO L-OUT-LENGTH L-FOUND
     CALL "PACK-FILE-FIND" USING CLIENT-STATE L-PACK L-PATH L-LENGTH WS-INDEX
     IF WS-INDEX = 0
         GOBACK
     END-IF
     CALL "PACK-FILE-BYTES" USING CLIENT-STATE L-PACK WS-INDEX L-AREA L-CAPACITY L-OUT-LENGTH
         WS-STATUS
     EVALUATE WS-STATUS
         WHEN 0
             MOVE 1 TO L-FOUND
         WHEN 1
             CALL "PACK-ERROR-ADD" USING CLIENT-STATE L-PACK WS-KEY WS-KEY-LENGTH L-PATH L-LENGTH
             MOVE 0 TO L-OUT-LENGTH
         WHEN OTHER
             MOVE 0 TO L-OUT-LENGTH
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-SOURCE-IMAGE.
*> USING CLIENT-STATE, pack, path (PIC X(256)), path length, area, capacity, width out, height out,
*> found out: the texture file decoded to RGBA (rows top to bottom; png.cob). An image larger than
*> the capacity is not found; a file that cannot be read or decoded is reported (bad_file) and not
*> found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DUMMY               PIC X.
 01 WS-ADDR                USAGE POINTER.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.packs.problem.bad_file".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 40.
 01 B-FILE                 PIC X BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACK                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACK L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND.
     IF PK-KIND(L-PACK) = 3
         MOVE 0 TO L-W L-H L-FOUND
         GOBACK
     END-IF
     IF PK-KIND(L-PACK) = 0
         CALL "BUILTIN-IMAGE" USING L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND
         GOBACK
     END-IF
     MOVE 0 TO L-W L-H L-FOUND
     CALL "PACK-FILE-FIND" USING CLIENT-STATE L-PACK L-PATH L-LENGTH WS-INDEX
     IF WS-INDEX = 0
         GOBACK
     END-IF
     CALL "PACK-FILE-BYTES" USING CLIENT-STATE L-PACK WS-INDEX WS-DUMMY WS-ZERO WS-SIZE WS-STATUS
     IF WS-SIZE = 0
         MOVE 1 TO WS-STATUS
     END-IF
     IF WS-STATUS = 5
         ALLOCATE FUNCTION MAX(WS-SIZE, 1) CHARACTERS RETURNING WS-ADDR
         SET ADDRESS OF B-FILE TO WS-ADDR
         MOVE WS-SIZE TO WS-CAP
         CALL "PACK-FILE-BYTES" USING CLIENT-STATE L-PACK WS-INDEX B-FILE WS-CAP WS-SIZE
             WS-STATUS
         IF WS-STATUS = 0
             CALL "PNG-DECODE" USING B-FILE WS-SIZE L-AREA L-CAPACITY L-W L-H WS-STATUS
         END-IF
         FREE WS-ADDR
     END-IF
     EVALUATE WS-STATUS
         WHEN 0
             MOVE 1 TO L-FOUND
         WHEN 5
             MOVE 0 TO L-W L-H
         WHEN OTHER
             CALL "PACK-ERROR-ADD" USING CLIENT-STATE L-PACK WS-KEY WS-KEY-LENGTH L-PATH L-LENGTH
             MOVE 0 TO L-W L-H
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-SOURCE-IMAGE.
