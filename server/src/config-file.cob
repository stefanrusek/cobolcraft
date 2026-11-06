*> The server's configuration file (contracts/operator-surface.md §2, FR-009, US13-2):
*> ./cobolcraft-server.conf, one key=value per line, "#" starts a comment line (spaces may come
*> before it), blank lines are ignored, keys in any order, a later line of a key wins. A missing key
*> takes its default; an unknown key or an invalid value is fatal ("FATAL configuration: <key>:
*> <problem>", exit 1; research R14). When the file is absent it is written with the defaults, each
*> key preceded by a one-line comment. Keys are trimmed of spaces; a value is the text after the
*> first "=" up to the end of the line (trailing spaces and a carriage return dropped).
*> The pack keys (US18-6): pack-url empty or http:// or https:// with an address (up to 1024
*> characters, CS-PACK-URL); pack-sha1 empty or 40 hex digits (either case); pack-id empty or UUID
*> text 8-4-4-4-12 hex digits; pack-required a boolean; pack-prompt up to 256 characters. A
*> non-empty pack-url sets CS-PACK-OFFERED; the Resource Pack Push carries a pack UUID, so with an
*> empty pack-id it is derived from pack-url and pack-sha1 (SV-PACK-ID-DERIVE: a new pack version
*> gets a new id).
*> The description limit of 256 is counted in bytes: CS-DESCRIPTION holds 256 bytes of UTF-8.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONFIG-FATAL.
*> USING key (PIC X(256)), problem (PIC X(64)): ends the server with
*> "FATAL configuration: <key>: <problem>" (cc_fatal, exit status 1). Does not return.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHAT                PIC X(400).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(256).
 01 L-PROBLEM              PIC X(64).
 PROCEDURE DIVISION USING L-KEY L-PROBLEM.
     MOVE LOW-VALUES TO WS-WHAT
     STRING "configuration: " FUNCTION TRIM(L-KEY) ": " FUNCTION TRIM(L-PROBLEM)
         DELIMITED BY SIZE INTO WS-WHAT
     CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
     GOBACK.
 END PROGRAM SV-CONFIG-FATAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONFIG-NUMBER.
*> USING value (PIC X(4096)), value length, number out (BINARY-LONG), valid out (PIC 9): valid = 1
*> when the value is 1 to 9 decimal digits and nothing else.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                PIC X(4096).
 01 L-LENGTH               BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 01 L-VALID                PIC 9.
 PROCEDURE DIVISION USING L-VALUE L-LENGTH L-NUMBER L-VALID.
     MOVE 0 TO L-NUMBER L-VALID
     IF L-LENGTH >= 1 AND L-LENGTH <= 9
         MOVE 1 TO L-VALID
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH OR L-VALID = 0
         IF L-VALUE(WS-I:1) IS NOT NUMERIC
             MOVE 0 TO L-VALID
         END-IF
     END-PERFORM
     IF L-VALID = 1
         COMPUTE L-NUMBER = FUNCTION NUMVAL(L-VALUE(1:L-LENGTH))
     END-IF
     GOBACK.
 END PROGRAM SV-CONFIG-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONFIG-LINE.
*> USING line (PIC X(4096)), CORE-SETTINGS, port (BINARY-LONG): applies one line of the file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-EQUALS              BINARY-LONG.
 01 WS-KEY                 PIC X(256).
 01 WS-LINE-KEY            PIC X(4097).
 01 WS-VALUE               PIC X(4096).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-VALID               PIC 9.
 01 WS-FLAG                PIC 9.
 01 WS-PORT-PROBLEM        PIC X(64) VALUE "must be a number from 1 to 65535".
 01 WS-VIEW-PROBLEM        PIC X(64) VALUE "must be a number from 2 to 32".
 01 WS-MODE-PROBLEM        PIC X(64) VALUE "must be creative or survival".
 01 WS-TEXT-PROBLEM        PIC X(64) VALUE "longer than 256 characters".
 01 WS-BOOLEAN-PROBLEM     PIC X(64) VALUE "must be true or false".
 01 WS-UNKNOWN-PROBLEM     PIC X(64) VALUE "unknown key".
 01 WS-URL-LENGTH-PROBLEM  PIC X(64) VALUE "longer than 1024 characters".
 01 WS-URL-PROBLEM         PIC X(64) VALUE "must be empty or an http:// or https:// URL".
 01 WS-SHA1-PROBLEM        PIC X(64) VALUE "must be empty or 40 hex digits".
 01 WS-ID-PROBLEM          PIC X(64) VALUE "must be empty or a UUID (8-4-4-4-12 hex digits)".
 01 WS-I                   BINARY-LONG.
 01 WS-HEX                 BINARY-LONG.
 01 WS-DASHES              BINARY-LONG.
 01 WS-CHAR                PIC X.
    88 WS-HEX-DIGIT        VALUES "0" THRU "9" "a" THRU "f" "A" THRU "F".
 LINKAGE SECTION.
 01 L-LINE                 PIC X(4096).
 COPY COREAPI.
 01 L-PORT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LINE CORE-SETTINGS L-PORT.
     MOVE 4096 TO WS-LENGTH
     PERFORM UNTIL WS-LENGTH = 0
             OR (L-LINE(WS-LENGTH:1) NOT = SPACE AND L-LINE(WS-LENGTH:1) NOT = X"0D")
         SUBTRACT 1 FROM WS-LENGTH
     END-PERFORM
     MOVE 1 TO WS-FIRST
     PERFORM UNTIL WS-FIRST >= WS-LENGTH OR L-LINE(WS-FIRST:1) NOT = SPACE
         ADD 1 TO WS-FIRST
     END-PERFORM
*>   A blank line or a comment line.
     IF WS-LENGTH = 0 OR L-LINE(WS-FIRST:1) = "#"
         GOBACK
     END-IF
     MOVE 0 TO WS-EQUALS
     INSPECT L-LINE(1:WS-LENGTH) TALLYING WS-EQUALS FOR CHARACTERS BEFORE INITIAL "="
     MOVE SPACES TO WS-VALUE
*>   The key: the text before the "=" (the whole line without one), trimmed.
     MOVE L-LINE(1:WS-LENGTH) TO WS-LINE-KEY
     MOVE SPACES TO WS-LINE-KEY(WS-EQUALS + 1:)
     MOVE FUNCTION TRIM(WS-LINE-KEY) TO WS-KEY
     COMPUTE WS-VALUE-LENGTH = WS-LENGTH - WS-EQUALS - 1
     IF WS-VALUE-LENGTH > 0
         MOVE L-LINE(WS-EQUALS + 2:WS-VALUE-LENGTH) TO WS-VALUE
     END-IF
     MOVE FUNCTION MAX(WS-VALUE-LENGTH, 0) TO WS-VALUE-LENGTH
*>   The booleans: 1 for true, 0 for false, 2 for anything else.
     EVALUATE WS-VALUE
         WHEN "true"
             MOVE 1 TO WS-FLAG
         WHEN "false"
             MOVE 0 TO WS-FLAG
         WHEN OTHER
             MOVE 2 TO WS-FLAG
     END-EVALUATE
     CALL "SV-CONFIG-NUMBER" USING WS-VALUE WS-VALUE-LENGTH WS-NUMBER WS-VALID
*>   Hex digits among the first 40 characters, and hyphens where UUID text has them (8-4-4-4-12).
     MOVE 0 TO WS-HEX WS-DASHES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-VALUE-LENGTH OR WS-I > 40
         MOVE WS-VALUE(WS-I:1) TO WS-CHAR
         EVALUATE TRUE
             WHEN WS-HEX-DIGIT
                 ADD 1 TO WS-HEX
             WHEN WS-CHAR = "-" AND (WS-I = 9 OR WS-I = 14 OR WS-I = 19 OR WS-I = 24)
                 ADD 1 TO WS-DASHES
         END-EVALUATE
     END-PERFORM
     EVALUATE WS-KEY
         WHEN "port"
             IF WS-VALID = 0 OR WS-NUMBER < 1 OR WS-NUMBER > 65535
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-PORT-PROBLEM
             END-IF
             MOVE WS-NUMBER TO L-PORT
         WHEN "default-game-mode"
             EVALUATE WS-VALUE
                 WHEN "creative"
                     MOVE 1 TO CS-DEFAULT-MODE
                 WHEN "survival"
                     MOVE 0 TO CS-DEFAULT-MODE
                 WHEN OTHER
                     CALL "SV-CONFIG-FATAL" USING WS-KEY WS-MODE-PROBLEM
             END-EVALUATE
         WHEN "description"
             IF WS-VALUE-LENGTH > 256
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-TEXT-PROBLEM
             END-IF
             MOVE WS-VALUE TO CS-DESCRIPTION
         WHEN "view-distance"
             IF WS-VALID = 0 OR WS-NUMBER < 2 OR WS-NUMBER > 32
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-VIEW-PROBLEM
             END-IF
             MOVE WS-NUMBER TO CS-VIEW-DISTANCE
         WHEN "pack-url"
             IF WS-VALUE-LENGTH > 1024
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-URL-LENGTH-PROBLEM
             END-IF
             IF WS-VALUE-LENGTH > 0
                     AND NOT (WS-VALUE(1:7) = "http://" AND WS-VALUE-LENGTH > 7)
                     AND NOT (WS-VALUE(1:8) = "https://" AND WS-VALUE-LENGTH > 8)
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-URL-PROBLEM
             END-IF
             MOVE WS-VALUE TO CS-PACK-URL
         WHEN "pack-sha1"
             IF WS-VALUE-LENGTH > 0 AND (WS-VALUE-LENGTH NOT = 40 OR WS-HEX NOT = 40)
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-SHA1-PROBLEM
             END-IF
             MOVE WS-VALUE TO CS-PACK-SHA1
         WHEN "pack-id"
             IF WS-VALUE-LENGTH > 0
                     AND (WS-VALUE-LENGTH NOT = 36 OR WS-HEX NOT = 32 OR WS-DASHES NOT = 4)
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-ID-PROBLEM
             END-IF
             MOVE WS-VALUE TO CS-PACK-ID
         WHEN "pack-prompt"
             IF WS-VALUE-LENGTH > 256
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-TEXT-PROBLEM
             END-IF
             MOVE WS-VALUE TO CS-PACK-PROMPT
         WHEN "player-combat"
         WHEN "hostile-mobs"
         WHEN "weather-changes"
         WHEN "extra-dimensions"
         WHEN "allow-list"
         WHEN "pack-required"
             IF WS-FLAG = 2
                 CALL "SV-CONFIG-FATAL" USING WS-KEY WS-BOOLEAN-PROBLEM
             END-IF
             EVALUATE WS-KEY
                 WHEN "player-combat"
                     MOVE WS-FLAG TO CS-PLAYER-COMBAT
                 WHEN "hostile-mobs"
                     MOVE WS-FLAG TO CS-HOSTILE-MOBS
                 WHEN "weather-changes"
                     MOVE WS-FLAG TO CS-WEATHER-CHANGES
                 WHEN "extra-dimensions"
                     MOVE WS-FLAG TO CS-EXTRA-DIMENSIONS
                 WHEN "pack-required"
                     MOVE WS-FLAG TO CS-PACK-REQUIRED
                 WHEN OTHER
                     MOVE WS-FLAG TO CS-ALLOW-LIST-ENFORCED
             END-EVALUATE
         WHEN OTHER
             CALL "SV-CONFIG-FATAL" USING WS-KEY WS-UNKNOWN-PROBLEM
     END-EVALUATE
     GOBACK.
 END PROGRAM SV-CONFIG-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONFIG-WRITE.
*> No parameters: writes ./cobolcraft-server.conf with every key's default, each preceded by a
*> one-line comment (operator-surface §2). A file that cannot be written is a non-fatal failure
*> ("ERROR configuration: cannot write cobolcraft-server.conf"): the server goes on with the
*> defaults.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT CONF-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD CONF-FILE.
 01 CONF-LINE              PIC X(128).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(32) VALUE "cobolcraft-server.conf".
 01 WS-STATUS              PIC XX.
 01 WS-I                   BINARY-LONG.
 01 WS-ERROR               PIC X(64) VALUE "ERROR configuration: cannot write cobolcraft-server.conf".
 01 WS-ERROR-LENGTH        BINARY-LONG VALUE 56.
 01 WS-PTR                 USAGE POINTER.
 01 WS-DEFAULTS.
    05 FILLER PIC X(128) VALUE "# Listening port, 1 to 65535".
    05 FILLER PIC X(128) VALUE "port=25565".
    05 FILLER PIC X(128) VALUE "# Game mode of new players: creative or survival".
    05 FILLER PIC X(128) VALUE "default-game-mode=creative".
    05 FILLER PIC X(128) VALUE "# Description in the server list, up to 256 characters".
    05 FILLER PIC X(128) VALUE "description=A CobolCraft server".
    05 FILLER PIC X(128) VALUE "# View distance in chunks, 2 to 32".
    05 FILLER PIC X(128) VALUE "view-distance=8".
    05 FILLER PIC X(128) VALUE "# Players can hurt each other: true or false".
    05 FILLER PIC X(128) VALUE "player-combat=true".
    05 FILLER PIC X(128) VALUE "# Hostile mobs appear: true or false".
    05 FILLER PIC X(128) VALUE "hostile-mobs=true".
    05 FILLER PIC X(128) VALUE "# The weather changes on its own: true or false".
    05 FILLER PIC X(128) VALUE "weather-changes=true".
    05 FILLER PIC X(128) VALUE "# Players can travel to extra dimensions: true or false".
    05 FILLER PIC X(128) VALUE "extra-dimensions=true".
    05 FILLER PIC X(128) VALUE "# Allow-list enforced in a newly created world (an existing world keeps it"
        & "s own): true or false".
    05 FILLER PIC X(128) VALUE "allow-list=false".
    05 FILLER PIC X(128) VALUE "# Resource pack offered to players: its http:// or https:// address, empty"
        & " for no offer".
    05 FILLER PIC X(128) VALUE "pack-url=".
    05 FILLER PIC X(128) VALUE "# SHA-1 hash of the pack zip, 40 hex digits, or empty".
    05 FILLER PIC X(128) VALUE "pack-sha1=".
    05 FILLER PIC X(128) VALUE "# Stable identifier of the pack, a UUID, or empty to derive one from pack-url"
        & " and pack-sha1".
    05 FILLER PIC X(128) VALUE "pack-id=".
    05 FILLER PIC X(128) VALUE "# Players who decline the pack are disconnected: true or false".
    05 FILLER PIC X(128) VALUE "pack-required=false".
    05 FILLER PIC X(128) VALUE "# Message shown when the pack is offered, up to 256 characters, or empty".
    05 FILLER PIC X(128) VALUE "pack-prompt=".
 01 WS-DEFAULT-TABLE REDEFINES WS-DEFAULTS.
    05 WS-DEFAULT          PIC X(128) OCCURS 28 TIMES.
 PROCEDURE DIVISION.
     OPEN OUTPUT CONF-FILE
     IF WS-STATUS NOT = "00"
         SET WS-PTR TO ADDRESS OF WS-ERROR
         CALL "SV-PRINT" USING WS-PTR WS-ERROR-LENGTH
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         WRITE CONF-LINE FROM WS-DEFAULT(WS-I)
     END-PERFORM
     CLOSE CONF-FILE
     GOBACK.
 END PROGRAM SV-CONFIG-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-CONFIG-LOAD.
*> USING CORE-SETTINGS out, port out (BINARY-LONG): the operator-surface §2 defaults (creative,
*> "A CobolCraft server", view distance 8, player combat, hostile mobs, weather changes and extra
*> dimensions on, allow-list off, no pack offer, port 25565; a dedicated server, host kind 0, whose
*> new world is named "world"), then every line of ./cobolcraft-server.conf applied in order; the
*> file is written with the defaults when absent. A file that exists but cannot be read is fatal.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT CONF-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD CONF-FILE.
 01 CONF-LINE              PIC X(4096).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(32) VALUE "cobolcraft-server.conf".
 01 WS-STATUS              PIC XX.
 01 WS-KEY                 PIC X(256) VALUE "cobolcraft-server.conf".
 01 WS-PROBLEM             PIC X(64).
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-PORT                 BINARY-LONG.
 PROCEDURE DIVISION USING CORE-SETTINGS L-PORT.
     INITIALIZE CORE-SETTINGS
     MOVE 25565 TO L-PORT
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED CS-HOST-KIND
     MOVE "world" TO CS-NEW-WORLD-NAME
     OPEN INPUT CONF-FILE
     EVALUATE WS-STATUS
         WHEN "00"
             CONTINUE
         WHEN "35"
             CALL "SV-CONFIG-WRITE"
             GOBACK
         WHEN OTHER
             STRING "cannot be read (file status " WS-STATUS ")" DELIMITED BY SIZE
                 INTO WS-PROBLEM
             CALL "SV-CONFIG-FATAL" USING WS-KEY WS-PROBLEM
     END-EVALUATE
*>   Status 0x is a line (04: longer than 4096 bytes, cut there); 10 is the end of the file.
     PERFORM UNTIL WS-STATUS(1:1) NOT = "0"
         MOVE SPACES TO CONF-LINE
         READ CONF-FILE
         IF WS-STATUS(1:1) = "0"
             CALL "SV-CONFIG-LINE" USING CONF-LINE CORE-SETTINGS L-PORT
         END-IF
     END-PERFORM
     CLOSE CONF-FILE
*>   A non-empty pack-url is the offer; Resource Pack Push needs its pack UUID (09 §3.1).
     IF CS-PACK-URL NOT = SPACES
         MOVE 1 TO CS-PACK-OFFERED
         IF CS-PACK-ID = SPACES
             CALL "SV-PACK-ID-DERIVE" USING CS-PACK-URL CS-PACK-SHA1 CS-PACK-ID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SV-CONFIG-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-PACK-ID-DERIVE.
*> USING pack-url (PIC X(1024)), pack-sha1 (PIC X(40)), pack id out (PIC X(36), UUID text): the
*> name-based version 3 UUID of RFC 4122 §4.3 (operator-surface §2) in the URL namespace
*> 6ba7b811-9dad-11d1-80b4-00c04fd430c8 over the name "<pack-url> <pack-sha1 in lower case>": the
*> MD5 of namespace bytes and name by a direct OpenSSL call, then byte 7 gets version 3 (high nibble
*> 0011) and byte 9 the IETF variant (high bits 10); written as lower-case 8-4-4-4-12 hex digits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA                PIC X(1088).
 01 WS-DATA-LENGTH         BINARY-DOUBLE UNSIGNED.
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-SHA1-LENGTH         BINARY-LONG.
 01 WS-DIGEST              PIC X(64).
 01 WS-DIGEST-LENGTH       BINARY-LONG UNSIGNED.
 01 WS-ALGORITHM           USAGE POINTER.
 01 WS-ENGINE              USAGE POINTER VALUE NULL.
 01 WS-RC                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HEX                 PIC X(32).
 LINKAGE SECTION.
 01 L-URL                  PIC X(1024).
 01 L-SHA1                 PIC X(40).
 01 L-ID                   PIC X(36).
 PROCEDURE DIVISION USING L-URL L-SHA1 L-ID.
     MOVE FUNCTION HEX-TO-CHAR("6ba7b8119dad11d180b400c04fd430c8") TO WS-DATA(1:16)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-URL TRAILING)) TO WS-URL-LENGTH
     MOVE L-URL(1:WS-URL-LENGTH) TO WS-DATA(17:WS-URL-LENGTH)
     MOVE " " TO WS-DATA(17 + WS-URL-LENGTH:1)
     COMPUTE WS-DATA-LENGTH = 17 + WS-URL-LENGTH
     IF L-SHA1 NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-SHA1 TRAILING)) TO WS-SHA1-LENGTH
         MOVE FUNCTION LOWER-CASE(L-SHA1(1:WS-SHA1-LENGTH))
             TO WS-DATA(18 + WS-URL-LENGTH:WS-SHA1-LENGTH)
         ADD WS-SHA1-LENGTH TO WS-DATA-LENGTH
     END-IF
     CALL STATIC "EVP_md5" RETURNING WS-ALGORITHM
     CALL STATIC "EVP_Digest" USING BY REFERENCE WS-DATA BY VALUE WS-DATA-LENGTH
         BY REFERENCE WS-DIGEST BY REFERENCE WS-DIGEST-LENGTH BY VALUE WS-ALGORITHM
         BY VALUE WS-ENGINE RETURNING WS-RC
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION ORD(WS-DIGEST(7:1)) - 1, 16) + 48
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-DIGEST(7:1)
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION ORD(WS-DIGEST(9:1)) - 1, 64) + 128
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-DIGEST(9:1)
     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-DIGEST(1:16))) TO WS-HEX
     STRING WS-HEX(1:8) "-" WS-HEX(9:4) "-" WS-HEX(13:4) "-" WS-HEX(17:4) "-" WS-HEX(21:12)
         DELIMITED BY SIZE INTO L-ID
     GOBACK.
 END PROGRAM SV-PACK-ID-DERIVE.
