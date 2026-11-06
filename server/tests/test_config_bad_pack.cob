*> Fatal-path test of the pack-* configuration values (server/src/config-file.cob; operator-surface
*> §2, research R14): an invalid value ends the server with "FATAL configuration: <key>: <problem>"
*> and exit status 1. Sub-cases: a URL that is not http(s) or is longer than CS-PACK-URL, a hash
*> that is not 40 hex digits, a pack id that is not UUID text, a non-boolean pack-required, a
*> prompt longer than CS-PACK-PROMPT, and a pack-url without a pack-id (the Resource Pack Push needs
*> a pack UUID, 09 §3.1). Each runs in a forked child (SVT-FORK) whose exit status and standard
*> error are checked; the last sub-case (an invalid UUID) runs in the program itself, for the
*> runner's .expect mechanism (test_config_bad_pack.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIG-BAD-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-SCRATCH             PIC X(256) VALUE "build/server-test-config-bad-pack".
 01 WS-CONF                PIC X(4096).
 01 WS-PORT                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-STDERR              PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-URL-PROBLEM         PIC X(64) VALUE "must be empty or an http:// or https:// URL".
 01 WS-SHA1-PROBLEM        PIC X(64) VALUE "must be empty or 40 hex digits".
 01 WS-ID-PROBLEM          PIC X(64) VALUE "must be empty or a UUID (8-4-4-4-12 hex digits)".
 01 WS-CASES.
    05 FILLER PIC X(64) VALUE "pack-url=ftp://packs.example.test/p.zip".
    05 FILLER PIC X(64) VALUE "pack-url".
    05 FILLER PIC X(64) VALUE "U".
    05 FILLER PIC X(64) VALUE "pack-url=packs.example.test/p.zip".
    05 FILLER PIC X(64) VALUE "pack-url".
    05 FILLER PIC X(64) VALUE "U".
    05 FILLER PIC X(64) VALUE "pack-url=HTTPS://packs.example.test/p.zip".
    05 FILLER PIC X(64) VALUE "pack-url".
    05 FILLER PIC X(64) VALUE "U".
    05 FILLER PIC X(64) VALUE "pack-url=https:/".
    05 FILLER PIC X(64) VALUE "pack-url".
    05 FILLER PIC X(64) VALUE "U".
    05 FILLER PIC X(64) VALUE "pack-url=".
    05 FILLER PIC X(64) VALUE "pack-url".
    05 FILLER PIC X(64) VALUE "longer than 1024 characters".
    05 FILLER PIC X(64) VALUE "pack-sha1=0123456789abcdef0123456789abcdef0123456".
    05 FILLER PIC X(64) VALUE "pack-sha1".
    05 FILLER PIC X(64) VALUE "S".
    05 FILLER PIC X(64) VALUE "pack-sha1=0123456789abcdef0123456789abcdef012345678".
    05 FILLER PIC X(64) VALUE "pack-sha1".
    05 FILLER PIC X(64) VALUE "S".
    05 FILLER PIC X(64) VALUE "pack-sha1=0123456789abcdef0123456789abcdef0123456g".
    05 FILLER PIC X(64) VALUE "pack-sha1".
    05 FILLER PIC X(64) VALUE "S".
    05 FILLER PIC X(64) VALUE "pack-id=6f1c2a3b4d5e4f608a7b9c0d1e2f3a4b".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "I".
    05 FILLER PIC X(64) VALUE "pack-id=6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "I".
    05 FILLER PIC X(64) VALUE "pack-id=6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4bc".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "I".
    05 FILLER PIC X(64) VALUE "pack-id=6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3z4b".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "I".
    05 FILLER PIC X(64) VALUE "pack-id=6f1c2a3b-4d5e+4f60-8a7b-9c0d1e2f3a4b".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "I".
    05 FILLER PIC X(64) VALUE "pack-required=yes".
    05 FILLER PIC X(64) VALUE "pack-required".
    05 FILLER PIC X(64) VALUE "must be true or false".
    05 FILLER PIC X(64) VALUE "pack-prompt=".
    05 FILLER PIC X(64) VALUE "pack-prompt".
    05 FILLER PIC X(64) VALUE "longer than 256 characters".
    05 FILLER PIC X(64) VALUE "pack-url=http://packs.example.test/p.zip".
    05 FILLER PIC X(64) VALUE "pack-id".
    05 FILLER PIC X(64) VALUE "required when pack-url is set".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 16 TIMES.
       10 WS-LINE          PIC X(64).
       10 WS-KEY           PIC X(64).
       10 WS-PROBLEM       PIC X(64).
 PROCEDURE DIVISION.
     CALL "SVT-SCRATCH" USING WS-SCRATCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         EVALUATE WS-PROBLEM(WS-I)
             WHEN "U"
                 MOVE WS-URL-PROBLEM TO WS-PROBLEM(WS-I)
             WHEN "S"
                 MOVE WS-SHA1-PROBLEM TO WS-PROBLEM(WS-I)
             WHEN "I"
                 MOVE WS-ID-PROBLEM TO WS-PROBLEM(WS-I)
         END-EVALUATE
         MOVE SPACES TO WS-CONF
         MOVE 1 TO WS-AT
         STRING "# sub-case||port=25565|" DELIMITED BY SIZE WS-LINE(WS-I) DELIMITED BY SPACE
             INTO WS-CONF WITH POINTER WS-AT
*>       The length sub-cases: a URL of 1025 characters, a prompt of 257.
         EVALUATE WS-LINE(WS-I)
             WHEN "pack-url="
                 MOVE "https://" TO WS-CONF(WS-AT:8)
                 MOVE ALL "u" TO WS-CONF(WS-AT + 8:1017)
             WHEN "pack-prompt="
                 MOVE ALL "p" TO WS-CONF(WS-AT:257)
         END-EVALUATE
         CALL "SVT-WRITE-CONF" USING WS-CONF
         CALL "SVT-FORK" USING WS-PID
         IF WS-PID = 0
             CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
             STOP RUN
         END-IF
         CALL "SVT-WAIT" USING WS-PID WS-EXIT WS-STDERR
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "test config bad pack " WS-LINE(WS-I) DELIMITED BY "  " " is fatal"
             DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-LINE(WS-I)
             WHEN "pack-url="
                 MOVE "test config bad pack a pack-url of 1025 characters is fatal" TO TL-CASE
             WHEN "pack-prompt="
                 MOVE "test config bad pack a pack-prompt of 257 characters is fatal" TO TL-CASE
             WHEN "pack-url=http://packs.example.test/p.zip"
                 MOVE "test config bad pack a pack-url without a pack-id is fatal" TO TL-CASE
         END-EVALUATE
         MOVE "T" TO TL-MODE
         STRING "exit 1 FATAL configuration: " FUNCTION TRIM(WS-KEY(WS-I)) ": "
             FUNCTION TRIM(WS-PROBLEM(WS-I)) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-EXIT TO WS-EDIT
         STRING "exit " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-STDERR) DELIMITED BY SIZE
             INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The last pack-id sub-case, checked by the runner (exit 1 and its standard error).
     MOVE "port=25565|pack-id=not-a-uuid" TO WS-CONF
     CALL "SVT-WRITE-CONF" USING WS-CONF
     CALL "SV-CONFIG-LOAD" USING CORE-SETTINGS WS-PORT
     STOP RUN.
 END PROGRAM TEST-CONFIG-BAD-PACK.
 COPY SVTEST.
