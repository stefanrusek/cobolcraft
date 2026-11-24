       IDENTIFICATION DIVISION.
       PROGRAM-ID. SPIKE-JAR-DIGEST.
      * spike (throwaway): the extraction tool's platform services from COBOL with no glue
      * (constitution Principle I, docs/protocol/22 section 7.2): incremental SHA-256 over a 41 MB
      * file read in blocks at byte offsets with CBL_READ_FILE, the zip end record read by offset,
      * rename and delete of files and directories (22 section 7.5).
      * Usage: spike_jar_digest <path-to-jar> <scratch-dir>
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ARGS         PIC X(1024).
       01 WS-JAR          PIC X(1024).
       01 WS-SCRATCH      PIC X(1024).
       01 WS-HANDLE       PIC X(4).
       01 WS-OFFSET       PIC X(8) COMP-X.
       01 WS-NBYTES       PIC X(4) COMP-X.
       01 WS-FLAGS        PIC X COMP-X VALUE 0.
       01 WS-ACCESS       PIC X COMP-X VALUE 1.
       01 WS-DENY         PIC X COMP-X VALUE 3.
       01 WS-DEVICE       PIC X COMP-X VALUE 0.
       01 WS-BLOCK        PIC X(65536).
       01 WS-FSIZE        PIC X(8) COMP-X.
       01 WS-FINFO.
          05 WS-FI-SIZE   PIC X(8) COMP-X.
          05 WS-FI-REST   PIC X(8).
       01 WS-CTX          USAGE POINTER.
       01 WS-ALG          USAGE POINTER.
       01 WS-NULL         USAGE POINTER VALUE NULL.
       01 WS-MD           PIC X(32).
       01 WS-MDLEN        BINARY-LONG UNSIGNED.
       01 WS-RC           BINARY-LONG.
       01 WS-LEN          BINARY-DOUBLE UNSIGNED.
       01 WS-TOTAL        BINARY-DOUBLE UNSIGNED VALUE 0.
       01 WS-ABC          PIC X(3) VALUE "abc".
       01 WS-A            PIC X(1100).
       01 WS-B            PIC X(1100).
       PROCEDURE DIVISION.
           ACCEPT WS-ARGS FROM COMMAND-LINE
           UNSTRING WS-ARGS DELIMITED BY SPACE INTO WS-JAR WS-SCRATCH
      *    SHA-256 of "abc" (FIPS 180-4 vector)
           CALL STATIC "EVP_MD_CTX_new" RETURNING WS-CTX
           CALL STATIC "EVP_sha256" RETURNING WS-ALG
           CALL STATIC "EVP_DigestInit_ex" USING BY VALUE WS-CTX
                BY VALUE WS-ALG BY VALUE WS-NULL RETURNING WS-RC
           MOVE 3 TO WS-LEN
           CALL STATIC "EVP_DigestUpdate" USING BY VALUE WS-CTX
                BY REFERENCE WS-ABC BY VALUE WS-LEN RETURNING WS-RC
           CALL STATIC "EVP_DigestFinal_ex" USING BY VALUE WS-CTX
                BY REFERENCE WS-MD BY REFERENCE WS-MDLEN
                RETURNING WS-RC
           DISPLAY "SHA256(abc) LEN=" WS-MDLEN
           DISPLAY "  " FUNCTION HEX-OF(WS-MD)
      *    the jar, in 64 KiB blocks at offsets
           CALL "CBL_CHECK_FILE_EXIST" USING WS-JAR WS-FINFO
                RETURNING WS-RC
           DISPLAY "CHECK RC=" WS-RC " SIZE=" WS-FI-SIZE
           CALL "CBL_OPEN_FILE" USING WS-JAR WS-ACCESS WS-DENY
                WS-DEVICE WS-HANDLE RETURNING WS-RC
           DISPLAY "OPEN RC=" WS-RC
           CALL STATIC "EVP_MD_CTX_reset" USING BY VALUE WS-CTX
           CALL STATIC "EVP_DigestInit_ex" USING BY VALUE WS-CTX
                BY VALUE WS-ALG BY VALUE WS-NULL RETURNING WS-RC
           MOVE 0 TO WS-OFFSET
           PERFORM UNTIL WS-OFFSET >= WS-FI-SIZE
              MOVE 65536 TO WS-NBYTES
              CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET
                   WS-NBYTES WS-FLAGS WS-BLOCK RETURNING WS-RC
              IF WS-OFFSET + 65536 > WS-FI-SIZE
                 COMPUTE WS-LEN = WS-FI-SIZE - WS-OFFSET
              ELSE
                 MOVE 65536 TO WS-LEN
              END-IF
              CALL STATIC "EVP_DigestUpdate" USING BY VALUE WS-CTX
                   BY REFERENCE WS-BLOCK BY VALUE WS-LEN
                   RETURNING WS-RC
              ADD WS-LEN TO WS-TOTAL
              ADD 65536 TO WS-OFFSET
           END-PERFORM
           CALL STATIC "EVP_DigestFinal_ex" USING BY VALUE WS-CTX
                BY REFERENCE WS-MD BY REFERENCE WS-MDLEN
                RETURNING WS-RC
           DISPLAY "JAR BYTES=" WS-TOTAL
           DISPLAY "JAR SHA256=" FUNCTION LOWER-CASE(
                FUNCTION HEX-OF(WS-MD))
      *    zip end record: last 22 bytes
           COMPUTE WS-OFFSET = WS-FI-SIZE - 22
           MOVE 22 TO WS-NBYTES
           CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET
                WS-NBYTES WS-FLAGS WS-BLOCK RETURNING WS-RC
           DISPLAY "END RECORD RC=" WS-RC " "
                FUNCTION HEX-OF(WS-BLOCK(1:22))
           CALL "CBL_CLOSE_FILE" USING WS-HANDLE
      *    rename a directory and delete a tree level by level
           STRING FUNCTION TRIM(WS-SCRATCH) "/a" X"00"
                DELIMITED BY SIZE INTO WS-A
           STRING FUNCTION TRIM(WS-SCRATCH) "/b" X"00"
                DELIMITED BY SIZE INTO WS-B
           CALL "CBL_CREATE_DIR" USING WS-A RETURNING WS-RC
           DISPLAY "CREATE a RC=" WS-RC
           CALL "CBL_RENAME_FILE" USING WS-A WS-B RETURNING WS-RC
           DISPLAY "RENAME dir RC=" WS-RC
           CALL "CBL_DELETE_DIR" USING WS-B RETURNING WS-RC
           DISPLAY "DELETE dir RC=" WS-RC
           STOP RUN.
