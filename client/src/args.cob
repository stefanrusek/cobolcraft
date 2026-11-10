*> Command line of the client (contracts/client-surface.md §1; research R14; wire-profile.md §1):
*> ARGS-PARSE takes --name <name> (required: 1 to 16 characters of A-Z a-z 0-9 _) and
*> --gamedir <path> (default $HOME/.cobolcraft) and --generated-dir <path> (the generated packs of the
*> extraction tool, 22 section 5.1; default <game directory>/generated). Other words are ignored. A missing or invalid name
*> is fatal: "FATAL arguments: ...", exit status 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARGS-PARSE.
*> USING CLIENT-STATE, CL-ARGS (the words of the command line): sets CL-NAME, CL-GAME-DIR and
*> CL-GENERATED-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-HOME                PIC X(1024).
 01 WS-WHAT                PIC X(128).
 01 WS-CHAR                PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 PROCEDURE DIVISION USING CLIENT-STATE CL-ARGS.
     MOVE 0 TO CL-NAME-LENGTH
     MOVE SPACES TO CL-NAME
     ACCEPT WS-HOME FROM ENVIRONMENT "HOME"
     MOVE SPACES TO CL-GAME-DIR
     STRING FUNCTION TRIM(WS-HOME) "/.cobolcraft" DELIMITED BY SIZE INTO CL-GAME-DIR
     COMPUTE CL-GAME-DIR-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-HOME)) + 12
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE 0 TO CL-GENERATED-DIR-LENGTH
     MOVE -1 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= AR-COUNT
         EVALUATE TRUE
             WHEN AR-TEXT(WS-I) = "--name"
                 ADD 1 TO WS-I
                 MOVE 0 TO WS-BAD
                 IF AR-LENGTH(WS-I) < 1 OR AR-LENGTH(WS-I) > 16
                     MOVE 1 TO WS-BAD
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > AR-LENGTH(WS-I) OR WS-K > 16
                     MOVE AR-TEXT(WS-I)(WS-K:1) TO WS-CHAR
                     IF NOT (WS-CHAR IS ALPHABETIC-UPPER OR WS-CHAR IS ALPHABETIC-LOWER
                             OR WS-CHAR IS NUMERIC OR WS-CHAR = "_") OR WS-CHAR = SPACE
                         MOVE 1 TO WS-BAD
                     END-IF
                 END-PERFORM
                 MOVE AR-TEXT(WS-I)(1:16) TO CL-NAME
                 MOVE FUNCTION MIN(AR-LENGTH(WS-I), 16) TO CL-NAME-LENGTH
             WHEN AR-TEXT(WS-I) = "--gamedir"
                 ADD 1 TO WS-I
                 MOVE AR-TEXT(WS-I) TO CL-GAME-DIR
                 MOVE AR-LENGTH(WS-I) TO CL-GAME-DIR-LENGTH
             WHEN AR-TEXT(WS-I) = "--generated-dir"
                 ADD 1 TO WS-I
                 MOVE AR-TEXT(WS-I) TO CL-GENERATED-DIR
                 MOVE AR-LENGTH(WS-I) TO CL-GENERATED-DIR-LENGTH
         END-EVALUATE
     END-PERFORM
     IF CL-GENERATED-DIR-LENGTH = 0
         STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/generated" DELIMITED BY SIZE
             INTO CL-GENERATED-DIR
         COMPUTE CL-GENERATED-DIR-LENGTH = CL-GAME-DIR-LENGTH + 10
     END-IF
     EVALUATE WS-BAD
         WHEN -1
             MOVE LOW-VALUES TO WS-WHAT
             STRING "arguments: --name <name> is required" DELIMITED BY SIZE INTO WS-WHAT
             CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
         WHEN 1
             MOVE LOW-VALUES TO WS-WHAT
             STRING "arguments: --name must be 1 to 16 characters of A-Z a-z 0-9 _"
                 DELIMITED BY SIZE INTO WS-WHAT
             CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
     END-EVALUATE
     GOBACK.
 END PROGRAM ARGS-PARSE.
