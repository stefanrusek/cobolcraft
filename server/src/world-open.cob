*> The server's world opening (docs/design/world-types.md section 3, 22 section 9.2): which type a created
*> world gets, what is printed about the generated packs, and the refusals that end the server with exit code 10.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-NOTE.
*> USING text (PIC X(512), space padded): prints it as one console line (SV-PRINT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LINE                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(512).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE L-TEXT TO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING)) TO WS-LENGTH
     SET WS-PTR TO ADDRESS OF WS-LINE
     CALL "SV-PRINT" USING WS-PTR WS-LENGTH
     GOBACK.
 END PROGRAM SV-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-WORLD-OPEN.
*> USING world folder (z-string), CORE-SETTINGS (CS-WORLD-TYPE auto, standard or cobolcraft as configured; the
*> record is not changed: a copy gets the type the packs check chooses for auto), created out (BINARY-LONG, 1 created, 0
*> opened). Checks the generated packs (CORE-PACKS-STATUS of CS-GENERATED-DIR) and opens the world
*> (CORE-WORLD-OPEN). auto creates a standard world when the check is ok, else a cobolcraft world and prints the
*> auto_fallback line; a world of a type that differs from an explicit setting is opened as it is, and the
*> setting is reported ignored; a cobolcraft world with a check that is not ok prints "Standard worlds are
*> unavailable: <text>". A world the core refuses (standard with packs not ok, data without level.dat, no
*> usable WorldType) prints its reason and ends the run with exit code 10 (WT-3, WT-24); nothing is created.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY COREAPI.
 01 WS-DIR                 PIC X(1100).
 01 WS-PACKS               BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-WORD                PIC X(10).
 01 WS-TEXT                PIC X(512).
 01 WS-CONFIGURED          PIC X(10).
 01 WS-ACTUAL              PIC X(10).
 LINKAGE SECTION.
 01 L-WORLD                PIC X.
 01 L-SETTINGS             PIC X(3829).
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-WORLD L-SETTINGS L-CREATED.
     MOVE L-SETTINGS TO CORE-SETTINGS
     MOVE CS-WORLD-TYPE TO WS-CONFIGURED
     MOVE SPACES TO WS-DIR
     MOVE CS-GENERATED-DIR TO WS-DIR
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-PACKS WS-REASON
     EVALUATE WS-PACKS
         WHEN CT-PACKS-ABSENT
             MOVE "absent" TO WS-WORD
         WHEN CT-PACKS-INCOMPLETE
             MOVE "incomplete" TO WS-WORD
         WHEN CT-PACKS-STALE
             MOVE "stale" TO WS-WORD
         WHEN CT-PACKS-DAMAGED
             MOVE "damaged" TO WS-WORD
         WHEN OTHER
             MOVE "ok" TO WS-WORD
     END-EVALUATE
     IF WS-CONFIGURED = "auto"
         IF WS-PACKS = CT-PACKS-OK
             MOVE "standard" TO CS-WORLD-TYPE
         ELSE
             MOVE "cobolcraft" TO CS-WORLD-TYPE
         END-IF
     END-IF
     CALL "CORE-WORLD-OPEN" USING L-WORLD CORE-SETTINGS L-CREATED
     EVALUATE L-CREATED
         WHEN -1
*>           A check that says ok but a set that does not load is damaged data (22 section 9.2).
             IF WS-REASON = SPACES
                 MOVE "The Minecraft content is damaged. Run the extraction tool with --force." TO WS-REASON
             END-IF
             MOVE SPACES TO WS-TEXT
             STRING FUNCTION TRIM(WS-REASON) " cobolcraft-extract --jar <file>" DELIMITED BY SIZE
                 INTO WS-TEXT
             CALL "SV-NOTE" USING WS-TEXT
             STOP RUN RETURNING 10
         WHEN -2
             MOVE "This folder holds world data but no level.dat." TO WS-TEXT
             CALL "SV-NOTE" USING WS-TEXT
             STOP RUN RETURNING 10
         WHEN -3
             MOVE "This world has no world type and cannot be opened." TO WS-TEXT
             CALL "SV-NOTE" USING WS-TEXT
             STOP RUN RETURNING 10
     END-EVALUATE
     MOVE "cobolcraft" TO WS-ACTUAL
     IF CT-SET-TYPE = CT-TYPE-STANDARD
         MOVE "standard" TO WS-ACTUAL
     END-IF
     IF CT-SET-TYPE = CT-TYPE-DEBUG
         MOVE "debug" TO WS-ACTUAL
     END-IF
     IF WS-ACTUAL = "cobolcraft" AND WS-PACKS NOT = CT-PACKS-OK
         MOVE SPACES TO WS-TEXT
         IF WS-CONFIGURED = "auto" AND L-CREATED = 1
             STRING "world-type=auto: Minecraft content is not usable (" FUNCTION TRIM(WS-WORD)
                 "), created a cobolcraft world" DELIMITED BY SIZE INTO WS-TEXT
         ELSE
             STRING "Standard worlds are unavailable: " FUNCTION TRIM(WS-REASON)
                 DELIMITED BY SIZE INTO WS-TEXT
         END-IF
         CALL "SV-NOTE" USING WS-TEXT
     END-IF
     IF WS-CONFIGURED NOT = "auto" AND WS-CONFIGURED NOT = WS-ACTUAL
             AND (WS-ACTUAL = "standard" OR WS-ACTUAL = "cobolcraft")
         MOVE SPACES TO WS-TEXT
         STRING "world-type=" FUNCTION TRIM(WS-CONFIGURED) " is ignored: this world is "
             FUNCTION TRIM(WS-ACTUAL) DELIMITED BY SIZE INTO WS-TEXT
         CALL "SV-NOTE" USING WS-TEXT
     END-IF
     GOBACK.
 END PROGRAM SV-WORLD-OPEN.
