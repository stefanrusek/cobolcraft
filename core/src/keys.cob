*> Namespace-tolerant block, item and entity keys. The rows of the standard content set keep their keys without the namespace ("water",
*> "sand", "diamond", "zombie"), the cobolcraft set and the rules and data files of docs/protocol write "minecraft:<name>". A rule that
*> compares a row's key with a literal must accept both forms; these programs are the one place that does it.
*>   KEY-BARE USING key (PIC X(48)), bare out (PIC X(48)): the key without a leading "minecraft:" (other namespaces stay).
*>   KEY-NAMESPACED USING key, full out: the key with "minecraft:" in front when it has no namespace.
*>   KEY-SAME USING key, other key, same out (BINARY-LONG): 1 when the two are the same key, whichever form each is in.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KEY-BARE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-BARE                 PIC X(48).
 PROCEDURE DIVISION USING L-KEY L-BARE.
     MOVE L-KEY TO L-BARE
     IF L-KEY(1:10) = "minecraft:"
         MOVE SPACES TO L-BARE
         MOVE L-KEY(11:38) TO L-BARE
     END-IF
     GOBACK.
 END PROGRAM KEY-BARE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KEY-NAMESPACED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLONS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FULL                 PIC X(48).
 PROCEDURE DIVISION USING L-KEY L-FULL.
     MOVE L-KEY TO L-FULL
     MOVE 0 TO WS-COLONS
     INSPECT L-KEY TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0 AND L-KEY NOT = SPACES
         MOVE SPACES TO L-FULL
         STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO L-FULL
     END-IF
     GOBACK.
 END PROGRAM KEY-NAMESPACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KEY-SAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   PIC X(48).
 01 WS-B                   PIC X(48).
 LINKAGE SECTION.
 01 L-A                    PIC X(48).
 01 L-B                    PIC X(48).
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SAME.
     MOVE 0 TO L-SAME
     CALL "KEY-BARE" USING L-A WS-A
     CALL "KEY-BARE" USING L-B WS-B
     IF WS-A = WS-B AND WS-A NOT = SPACES
         MOVE 1 TO L-SAME
     END-IF
     GOBACK.
 END PROGRAM KEY-SAME.
