*> Messages and small shared helpers of the extraction tool (docs/protocol/22-extraction-tool.md §7.4).
*>
*> DOCUMENTED ASSUMPTIONS of the extraction tool (22 says nothing about them; each is repeated in the report of
*> the phase that wrote it):
*>  A1. Command-line arguments reach EX-ARGS as one text separated by LF (EX-MAIN joins them), so a path may hold
*>      spaces; "--option=value" is not accepted; a repeated option keeps the last value; a path over 1000 bytes
*>      is a usage error (CCX-001).
*>  A2. The detail of CCX-020 for a file ZIP-OPEN refuses is "too short" (under 22 bytes) or "no end record or
*>      the central directory does not match the end record": ZIP-OPEN does not say which of its checks failed.
*>  A3. EX-CHECK also rejects, for every entry of the archive (mapped or not), an encrypted entry, a method other
*>      than 0 and 8 and a zip64 entry with CCX-021 before it decides on the jar (22 §7.3 step 7.5 names only the
*>      extracted entries).
*>  A4. The file counts of 22 §6.1 (11,605, 9,779, 106, 21,490) are constants of the tool for its one accepted
*>      row: the accepted-jar table carries no counts.
*>  A5. CCX-011 carries a fixed system message ("no such file", "is a directory", "cannot be opened or read").
*>  A6. The index is built in a 16 MiB buffer; one that does not fit is CCX-045.
*>  A7. A skipped entry is a file entry (not a directory entry) that maps to nothing; --dry-run reads and
*>      CRC-checks every planned entry (22 §7.1 "optionally 5 to 7") but creates nothing.
*>  A8. A run whose output directory holds the marker is replaced; one that is a plain file or a non-empty
*>      directory without the marker is CCX-051; a leftover <generated>.partial without the marker is CCX-051.
*>  A9. Progress lines are "Wrote <n> files" on standard output.
*>  A10. --verify counts every problem and reports the first; a file larger than the 1 MiB buffer counts as a
*>      size problem.
*>  A11. The detail of CCX-041 for an entry ZIP-READ-RANGE refuses as corrupt is "bad deflate data or a size that
*>      differs from the central record" (it does not say which); a central record whose sizes lie past the end of the
*>      file is CCX-020 "bad central record at entry <n>".
*>  A12. --dry-run ends with a line numbered CCX-103 (not in 22 §7.4): the counts of 22 §6.1 and the skipped count.
*>  A13. The walk accepts methods 0 and 8 (the contract fixture t-bad-crc.zip is a stored entry that must give CCX-040).

*> EX-NUM USING number (BINARY-DOUBLE), text out (PIC X(20), left-justified decimal, no leading zeros).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-NUM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC -(17)9.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-DOUBLE.
 01 L-TEXT                 PIC X(20).
 PROCEDURE DIVISION USING L-NUMBER L-TEXT.
     MOVE L-NUMBER TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO L-TEXT
     GOBACK.
 END PROGRAM EX-NUM.

*> EX-HEX8 USING value (BINARY-LONG UNSIGNED), text out (PIC X(8): eight lower-case hex digits).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-HEX8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX-DIGITS          PIC X(16) VALUE "0123456789abcdef".
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-QUOTIENT            BINARY-DOUBLE.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG UNSIGNED.
 01 L-TEXT                 PIC X(8).
 PROCEDURE DIVISION USING L-VALUE L-TEXT.
     MOVE L-VALUE TO WS-VALUE
     PERFORM VARYING WS-I FROM 8 BY -1 UNTIL WS-I < 1
         DIVIDE WS-VALUE BY 16 GIVING WS-QUOTIENT REMAINDER WS-DIGIT
         ADD 1 TO WS-DIGIT
         MOVE WS-HEX-DIGITS(WS-DIGIT:1) TO L-TEXT(WS-I:1)
         MOVE WS-QUOTIENT TO WS-VALUE
     END-PERFORM
     GOBACK.
 END PROGRAM EX-HEX8.

*> EX-JOIN USING base (PIC X(1100)), rest (PIC X(1100)), out (PIC X(1100)): base, "/", rest (a base of spaces
*> gives rest alone). All space padded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-JOIN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 PIC X(1100).
 01 L-REST                 PIC X(1100).
 01 L-OUT                  PIC X(1100).
 PROCEDURE DIVISION USING L-BASE L-REST L-OUT.
     MOVE SPACES TO L-OUT
     IF L-BASE = SPACES
         MOVE L-REST TO L-OUT
     ELSE
         STRING FUNCTION TRIM(L-BASE) "/" FUNCTION TRIM(L-REST) DELIMITED BY SIZE INTO L-OUT
     END-IF
     GOBACK.
 END PROGRAM EX-JOIN.

*> EX-SAY USING code (BINARY-LONG, the number of CCX-nnn): builds the line of 22 §7.4 from the arguments EXM-ARG(1..)
*> in the order of the placeholders, leaves code, exit status and text in EX-RES and prints the line: errors on
*> standard error, CCX-100 to CCX-102 on standard output (they are the final lines, also printed with --quiet).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-SAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-R                   PIC X(20).
 01 WS-D                   PIC X(20).
 01 WS-F                   PIC X(20).
 01 WS-N                   PIC X(20).
 01 WS-S                   PIC X(20).
 01 WS-CODE-TEXT           PIC 999.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE.
     MOVE SPACES TO EXR-LINE
     MOVE 1 TO WS-POINTER
     MOVE L-CODE TO EXR-CODE WS-CODE-TEXT
     STRING "CCX-" WS-CODE-TEXT " " DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
     EVALUATE L-CODE
         WHEN 1
             MOVE 1 TO EXR-EXIT
             STRING "usage: cobolcraft-extract [--jar <file>] [--game-dir <dir>] [--generated-dir <dir>] "
                 "[--force] [--verify] [--dry-run] [--quiet]" DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 10
             MOVE 2 TO EXR-EXIT
             STRING "Cannot find the Minecraft client jar. Looked for: " FUNCTION TRIM(EXM-ARG(1))
                 ". Pass --jar <file>." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 11
             MOVE 2 TO EXR-EXIT
             STRING "Cannot read " FUNCTION TRIM(EXM-ARG(1)) ": " FUNCTION TRIM(EXM-ARG(2)) "."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 20
             MOVE 4 TO EXR-EXIT
             STRING FUNCTION TRIM(EXM-ARG(1)) " is not a zip file this tool can read: " FUNCTION TRIM(EXM-ARG(2)) "."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 21
             MOVE 4 TO EXR-EXIT
             STRING FUNCTION TRIM(EXM-ARG(1)) " uses a zip feature this tool does not support: "
                 FUNCTION TRIM(EXM-ARG(2)) "." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 30
             MOVE 3 TO EXR-EXIT
             STRING "This jar is not supported (Minecraft " FUNCTION TRIM(EXM-ARG(1)) ", SHA-256 "
                 FUNCTION TRIM(EXM-ARG(2)) ", " FUNCTION TRIM(EXM-ARG(3)) " bytes). CobolCraft supports Minecraft "
                 FUNCTION TRIM(EXM-ARG(4)) ". Nothing was written." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 31
             MOVE 3 TO EXR-EXIT
             STRING "This jar says it is Minecraft " FUNCTION TRIM(EXM-ARG(1))
                 " but it is not the build CobolCraft was written for (SHA-256 " FUNCTION TRIM(EXM-ARG(2))
                 ", expected " FUNCTION TRIM(EXM-ARG(3)) "; size " FUNCTION TRIM(EXM-ARG(4)) ", expected "
                 FUNCTION TRIM(EXM-ARG(5)) "). The file may be damaged or from another build. Nothing was written."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 40
             MOVE 4 TO EXR-EXIT
             STRING "Entry " FUNCTION TRIM(EXM-ARG(1)) " is damaged: CRC-32 " FUNCTION TRIM(EXM-ARG(2))
                 ", expected " FUNCTION TRIM(EXM-ARG(3)) "." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 41
             MOVE 4 TO EXR-EXIT
             STRING "Entry " FUNCTION TRIM(EXM-ARG(1)) " cannot be unpacked: " FUNCTION TRIM(EXM-ARG(2)) "."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 42
             MOVE 4 TO EXR-EXIT
             STRING "Entry " FUNCTION TRIM(EXM-ARG(1)) " does not match its local header."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 43
             MOVE 4 TO EXR-EXIT
             STRING "Entry name " FUNCTION TRIM(EXM-ARG(1)) " cannot become a pack path."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 44
             MOVE 4 TO EXR-EXIT
             STRING "Two entries map to " FUNCTION TRIM(EXM-ARG(1)) "." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 45
             MOVE 4 TO EXR-EXIT
             STRING "version.json or the file counts do not match the table for this jar: "
                 FUNCTION TRIM(EXM-ARG(1)) "." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 50
             MOVE 5 TO EXR-EXIT
             STRING "Cannot write " FUNCTION TRIM(EXM-ARG(1)) ": " FUNCTION TRIM(EXM-ARG(2)) "."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 51
             MOVE 5 TO EXR-EXIT
             STRING "Refusing to replace " FUNCTION TRIM(EXM-ARG(1))
                 ": it was not made by this tool (no .cobolcraft-generated marker)."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 60
             MOVE 6 TO EXR-EXIT
             STRING "Verification failed: " FUNCTION TRIM(EXM-ARG(1)) " problems. First: " FUNCTION TRIM(EXM-ARG(2))
                 "." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 100
             MOVE 0 TO EXR-EXIT
             STRING "Generated packs are up to date (Minecraft " FUNCTION TRIM(EXM-ARG(1)) ", SHA-256 "
                 FUNCTION TRIM(EXM-ARG(2)) "). Nothing to do. Use --force to rebuild."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 101
             MOVE 0 TO EXR-EXIT
             MOVE EXR-RESOURCE TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-R
             MOVE EXR-DATA TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-D
             MOVE EXR-FEATURE TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-F
             MOVE EXR-BYTES TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-N
             MOVE EXR-SKIPPED TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-S
             STRING "Wrote " FUNCTION TRIM(WS-R) " resource files, " FUNCTION TRIM(WS-D) " data files and "
                 FUNCTION TRIM(WS-F) " feature-pack files (" FUNCTION TRIM(WS-N) " bytes) to "
                 FUNCTION TRIM(EXM-ARG(1)) ". Skipped " FUNCTION TRIM(WS-S)
                 " jar entries (code, signatures, markers)." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 103
             MOVE 0 TO EXR-EXIT
             MOVE EXR-RESOURCE TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-R
             MOVE EXR-DATA TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-D
             MOVE EXR-FEATURE TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-F
             MOVE EXR-SKIPPED TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-S
             STRING "Dry run: " FUNCTION TRIM(WS-R) " resource files, " FUNCTION TRIM(WS-D) " data files and "
                 FUNCTION TRIM(WS-F) " feature-pack files would be written; " FUNCTION TRIM(WS-S)
                 " jar entries skipped. Nothing was written." DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
         WHEN 102
             MOVE 0 TO EXR-EXIT
             STRING "Verified " FUNCTION TRIM(EXM-ARG(1)) " files in " FUNCTION TRIM(EXM-ARG(2)) "."
                 DELIMITED BY SIZE INTO EXR-LINE POINTER WS-POINTER
     END-EVALUATE
     IF L-CODE < 100
         DISPLAY FUNCTION TRIM(EXR-LINE) UPON SYSERR
     END-IF
     IF L-CODE >= 100
         DISPLAY FUNCTION TRIM(EXR-LINE)
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM EX-SAY.
