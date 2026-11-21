*> The plan of a run (22 §6.1 path mapping, §6.3 regeneration rules, §7.3 steps 5 and 7.1 to 7.4, §7.5 step 0).
*>   EX-PATH-OK        USING name (PIC X(256)), length, status out (0 a valid pack path, 1 not): lower case a-z 0-9
*>                     _ - . and /, no empty segment, no "." or ".." segment (08 §1.3, §1.4); a byte above 127 is not valid.
*>   EX-DEST           USING name, length, kind (1 resource, 2 data, 3 feature pack, 4 pack.png), which (1, or 2 for the
*>                     second copy of pack.png), destination out (PIC X(1100): the path below the generated directory).
*>   EX-PLAN           USING zip handle, status out (0, 43 or 44 after the message): selects the payload entries of the
*>                     jar in central directory order into EX-PLAN and counts them into EX-RES (resource, data and feature
*>                     files including the two generated pack.mcmeta, skipped file entries).
*>   EX-ACTION         USING action out (0 build, 1 up to date: a valid generated directory and no --force).
*>   EX-TARGET-CHECK   USING directory (PIC X(1100)), status out (0, or 51 after the message): the directory is absent,
*>                     empty or holds the marker.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-PATH-OK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-SEGMENT             BINARY-LONG.
 01 WS-C                   PIC X.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-STATUS.
     MOVE 0 TO L-STATUS
     MOVE 1 TO WS-START
     COMPUTE WS-END = L-LENGTH + 1
*>   Position length + 1 stands for the "/" that ends the last segment.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-END
         MOVE "/" TO WS-C
         IF WS-I <= L-LENGTH
             MOVE L-NAME(WS-I:1) TO WS-C
         END-IF
         IF WS-C = "/"
             COMPUTE WS-SEGMENT = WS-I - WS-START
             IF WS-SEGMENT = 0
                 MOVE 1 TO L-STATUS
             END-IF
             IF WS-SEGMENT = 1
                 IF L-NAME(WS-START:1) = "."
                     MOVE 1 TO L-STATUS
                 END-IF
             END-IF
             IF WS-SEGMENT = 2
                 IF L-NAME(WS-START:2) = ".."
                     MOVE 1 TO L-STATUS
                 END-IF
             END-IF
             COMPUTE WS-START = WS-I + 1
         ELSE
             IF NOT ((WS-C >= "a" AND WS-C <= "z") OR (WS-C >= "0" AND WS-C <= "9")
                     OR WS-C = "_" OR WS-C = "-" OR WS-C = ".")
                 MOVE 1 TO L-STATUS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EX-PATH-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-DEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-DEST                 PIC X(1100).
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-KIND L-WHICH L-DEST.
     MOVE SPACES TO L-DEST
     COMPUTE WS-REST-LENGTH = L-LENGTH - 25
     EVALUATE L-KIND
         WHEN 1
             STRING "vanilla-resources/" L-NAME(1:L-LENGTH) DELIMITED BY SIZE INTO L-DEST
         WHEN 2
             STRING "vanilla-data/" L-NAME(1:L-LENGTH) DELIMITED BY SIZE INTO L-DEST
         WHEN 3
             STRING "featurepacks/" L-NAME(26:WS-REST-LENGTH) DELIMITED BY SIZE INTO L-DEST
         WHEN 4
             IF L-WHICH = 1
                 MOVE "vanilla-resources/pack.png" TO L-DEST
             ELSE
                 MOVE "vanilla-data/pack.png" TO L-DEST
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EX-DEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-PLAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-WHICH               BINARY-LONG VALUE 1.
 01 WS-DEST                PIC X(1100).
 01 WS-REST-LENGTH         BINARY-LONG.
 01 WS-SLASH               BINARY-LONG.
 01 WS-TAIL-START          BINARY-LONG.
 01 WS-TAIL-LENGTH         BINARY-LONG.
 01 WS-PNG                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ZIP                  USAGE POINTER.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ZIP L-STATUS.
     MOVE 0 TO L-STATUS EXP-COUNT EXR-RESOURCE EXR-DATA EXR-FEATURE EXR-SKIPPED EXR-TOTAL WS-PNG
     CALL "ZIP-COUNT" USING L-ZIP WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL OR L-STATUS NOT = 0
         MOVE WS-I TO WS-ENTRY
         CALL "ZIP-NAME" USING L-ZIP WS-ENTRY WS-NAME WS-LENGTH
*>       Directory entries are ignored; every other entry is mapped by 6.1.
         IF WS-NAME(WS-LENGTH:1) NOT = "/"
             MOVE 0 TO WS-KIND
             EVALUATE TRUE
                 WHEN WS-NAME(1:WS-LENGTH) = "assets/.mcassetsroot" OR WS-NAME(1:WS-LENGTH) = "data/.mcassetsroot"
                         OR WS-NAME(1:WS-LENGTH) = "version.json"
                     CONTINUE
                 WHEN WS-NAME(1:WS-LENGTH) = "pack.png"
                     MOVE 4 TO WS-KIND
                 WHEN WS-NAME(1:7) = "assets/"
                     MOVE 1 TO WS-KIND
                 WHEN WS-NAME(1:25) = "data/minecraft/datapacks/"
                     MOVE 3 TO WS-KIND
                 WHEN WS-NAME(1:5) = "data/"
                     MOVE 2 TO WS-KIND
             END-EVALUATE
             IF WS-KIND = 0
                 ADD 1 TO EXR-SKIPPED
             END-IF
*>           The path must be valid (CCX-043); a feature pack file is <name>/pack.mcmeta or <name>/data/<rest>.
             IF WS-KIND > 0
                 CALL "EX-PATH-OK" USING WS-NAME WS-LENGTH WS-BAD
                 IF WS-KIND = 3
                     COMPUTE WS-REST-LENGTH = WS-LENGTH - 25
                     MOVE 0 TO WS-SLASH
                     INSPECT WS-NAME(26:WS-REST-LENGTH) TALLYING WS-SLASH FOR CHARACTERS BEFORE INITIAL "/"
                     COMPUTE WS-TAIL-START = 26 + WS-SLASH + 1
                     COMPUTE WS-TAIL-LENGTH = WS-REST-LENGTH - WS-SLASH - 1
                     IF WS-SLASH >= WS-REST-LENGTH
                         MOVE 1 TO WS-BAD
                     ELSE
                         IF WS-NAME(WS-TAIL-START:WS-TAIL-LENGTH) NOT = "pack.mcmeta"
                             IF WS-TAIL-LENGTH <= 5 OR WS-NAME(WS-TAIL-START:5) NOT = "data/"
                                 MOVE 1 TO WS-BAD
                             END-IF
                         END-IF
                     END-IF
                 END-IF
                 IF WS-BAD = 1
                     MOVE SPACES TO EXM-ARG(1)
                     MOVE WS-NAME(1:WS-LENGTH) TO EXM-ARG(1)
                     MOVE 43 TO WS-CODE L-STATUS
                     CALL "EX-SAY" USING WS-CODE
                 END-IF
             END-IF
*>           A name that the archive's index finds at another entry is a name twice: the same output path (CCX-044).
             IF WS-KIND > 0 AND L-STATUS = 0
                 CALL "ZIP-FIND" USING L-ZIP WS-NAME WS-LENGTH WS-FOUND
                 IF WS-FOUND NOT = WS-ENTRY
                     CALL "EX-DEST" USING WS-NAME WS-LENGTH WS-KIND WS-WHICH WS-DEST
                     MOVE WS-DEST TO EXM-ARG(1)
                     MOVE 44 TO WS-CODE L-STATUS
                     CALL "EX-SAY" USING WS-CODE
                 END-IF
             END-IF
             IF WS-KIND > 0 AND L-STATUS = 0
                 ADD 1 TO EXP-COUNT
                 MOVE WS-ENTRY TO EXP-INDEX(EXP-COUNT)
                 MOVE WS-KIND TO EXP-KIND(EXP-COUNT)
                 EVALUATE WS-KIND
                     WHEN 1
                         ADD 1 TO EXR-RESOURCE
                     WHEN 2
                         ADD 1 TO EXR-DATA
                     WHEN 3
                         ADD 1 TO EXR-FEATURE
                     WHEN 4
                         ADD 1 TO WS-PNG
                 END-EVALUATE
             END-IF
         END-IF
     END-PERFORM
     IF L-STATUS = 0
*>       pack.png goes to both packs; each pack gets its generated pack.mcmeta.
         COMPUTE EXR-RESOURCE = EXR-RESOURCE + WS-PNG + 1
         COMPUTE EXR-DATA = EXR-DATA + WS-PNG + 1
         COMPUTE EXR-TOTAL = EXR-RESOURCE + EXR-DATA + EXR-FEATURE
     END-IF
     GOBACK.
 END PROGRAM EX-PLAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-ACTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY CONTENT.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 LINKAGE SECTION.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTION.
     CALL "CONTENT-PACKS-CHECK" USING EXO-GEN WS-STATUS WS-REASON
     MOVE 0 TO L-ACTION
     IF WS-STATUS = CT-PACKS-OK AND EXO-FORCE = 0
         MOVE 1 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM EX-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-TARGET-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-MARKER              PIC X(1100) VALUE ".cobolcraft-generated".
 01 WS-CHILD               PIC X(1100).
 01 WS-KIND-STATUS         BINARY-LONG.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-LIST                PIC X.
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 1.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-LIST-RC             BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     MOVE 51 TO L-STATUS
     CALL "FILE-EXISTS" USING L-DIR WS-KIND-STATUS
     EVALUATE TRUE
         WHEN WS-KIND-STATUS = FM-NOT-FOUND
             MOVE 0 TO L-STATUS
         WHEN WS-KIND-STATUS = FM-IS-DIR
             CALL "EX-JOIN" USING L-DIR WS-MARKER WS-CHILD
             CALL "FILE-EXISTS" USING WS-CHILD WS-KIND-STATUS
             IF WS-KIND-STATUS = FM-OK
                 MOVE 0 TO L-STATUS
             END-IF
             IF L-STATUS NOT = 0
                 CALL "FILE-PATH-Z" USING L-DIR WS-Z WS-LENGTH WS-PATH-STATUS
                 MOVE 0 TO WS-LIST-COUNT
                 CALL STATIC "cc_fs_list" USING BY REFERENCE WS-Z BY REFERENCE WS-LIST
                     BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-LIST-RC
                 IF WS-LIST-RC = 0
                     MOVE 0 TO L-STATUS
                 END-IF
             END-IF
     END-EVALUATE
     IF L-STATUS NOT = 0
         MOVE SPACES TO EXM-ARG(1)
         MOVE L-DIR TO EXM-ARG(1)
         MOVE 51 TO WS-CODE
         CALL "EX-SAY" USING WS-CODE
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM EX-TARGET-CHECK.
