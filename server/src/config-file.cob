*> The server's configuration file (contracts/operator-surface.md §2, FR-009, US13-2):
*> ./cobolcraft-server.conf, one key=value per line, "#" starts a comment line (spaces may come
*> before it), blank lines are ignored, keys in any order, a later line of a key wins. A missing key
*> takes its default; an unknown key or an invalid value is fatal ("FATAL configuration: <key>:
*> <problem>", exit 1; research R14). When the file is absent it is written with the defaults, each
*> key preceded by a one-line comment. Keys are trimmed of spaces; a value is the text after the
*> first "=" up to the end of the line (trailing spaces and a carriage return dropped).
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
         WHEN "player-combat"
         WHEN "hostile-mobs"
         WHEN "weather-changes"
         WHEN "extra-dimensions"
         WHEN "allow-list"
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
 01 WS-DEFAULT-TABLE REDEFINES WS-DEFAULTS.
    05 WS-DEFAULT          PIC X(128) OCCURS 18 TIMES.
 PROCEDURE DIVISION.
     OPEN OUTPUT CONF-FILE
     IF WS-STATUS NOT = "00"
         SET WS-PTR TO ADDRESS OF WS-ERROR
         CALL "SV-PRINT" USING WS-PTR WS-ERROR-LENGTH
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
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
     GOBACK.
 END PROGRAM SV-CONFIG-LOAD.
