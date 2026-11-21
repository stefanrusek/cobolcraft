*> The generated-pack check of 22 §8.2 ("valid generated packs"): CONTENT-PACKS-CHECK USING generated
*> directory (z-string or space-padded, PIC X(1100)), status out (BINARY-LONG, CT-PACKS-* of CONTENT.cpy),
*> reason text out (PIC X(128): the English wording of 22 §9.2, spaces for ok). It reads the manifest (a few
*> hundred bytes) and probes nine sentinel files. It never opens the jar, hashes nothing and never looks at
*> <generated>.partial (22 §7.5): only the directory it is given. The accepted-jar row comes from
*> CONTENT-ACCEPTED-JAR. Steps and their results as 22 §8.2: no directory absent; no manifest absent without
*> the tool's marker and incomplete with it; an invalid manifest damaged; a manifest of another format or jar
*> stale; a missing sentinel damaged.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-PACKS-CHECK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 01 L-REASON               PIC X(128).
 PROCEDURE DIVISION USING L-DIR L-STATUS L-REASON.
     CALL "PACKS-STATUS-OF" USING L-DIR L-STATUS
     CALL "PACKS-REASON" USING L-STATUS L-REASON
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM CONTENT-PACKS-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-REASON.
*> USING status (BINARY-LONG, CT-PACKS-*), reason out (PIC X(128)): the wording of 22 §9.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-REASON               PIC X(128).
 PROCEDURE DIVISION USING L-STATUS L-REASON.
     MOVE SPACES TO L-REASON
     EVALUATE L-STATUS
         WHEN CT-PACKS-ABSENT
             MOVE "Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds."
                 TO L-REASON
         WHEN CT-PACKS-INCOMPLETE
             MOVE "The Minecraft content is incomplete. Run the extraction tool again." TO L-REASON
         WHEN CT-PACKS-STALE
             MOVE "The Minecraft content was made for another version. Run the extraction tool again." TO L-REASON
         WHEN CT-PACKS-DAMAGED
             MOVE "The Minecraft content is damaged. Run the extraction tool with --force." TO L-REASON
     END-EVALUATE
     GOBACK.
 END PROGRAM PACKS-REASON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-MANIFEST-PARSE.
*> USING manifest text (PIC X(4097)), length (BINARY-LONG), values out (13 x PIC X(80), the value of each
*> key in manifest order), status out (0 valid, 1 invalid). Valid: the 13 keys of 22 §6.4 in that order, one
*> key=value line each (LF ended; the last LF may be missing), every value non-empty, at most 80 bytes and
*> free of control characters; the numeric keys hold digits and the two pack formats digits, a dot and digits.
*> Keys after the 13th are ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEYS.
    05 FILLER PIC X(20) VALUE "format".
    05 FILLER PIC X(20) VALUE "tool".
    05 FILLER PIC X(20) VALUE "jar-version".
    05 FILLER PIC X(20) VALUE "jar-sha256".
    05 FILLER PIC X(20) VALUE "jar-size".
    05 FILLER PIC X(20) VALUE "world-version".
    05 FILLER PIC X(20) VALUE "protocol-version".
    05 FILLER PIC X(20) VALUE "resource-format".
    05 FILLER PIC X(20) VALUE "data-format".
    05 FILLER PIC X(20) VALUE "files-resource".
    05 FILLER PIC X(20) VALUE "files-data".
    05 FILLER PIC X(20) VALUE "files-feature".
    05 FILLER PIC X(20) VALUE "files-total".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(20) OCCURS 13 TIMES.
*> Value kinds per key: T text, N digits, F digits with an optional dot part.
 01 WS-KINDS               PIC X(13) VALUE "TTTTNNNFFNNNN".
 01 WS-INDEX               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-EQUALS              BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-LINE                PIC X(200).
 01 WS-NAME                PIC X(200).
 01 WS-EXPECTED            PIC X(200).
 01 WS-VALUE               PIC X(200).
 01 WS-KIND                PIC X.
 01 WS-CHAR-INDEX          BINARY-LONG.
 01 WS-CHAR                PIC X.
 01 WS-DOTS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(4097).
 01 L-LENGTH               BINARY-LONG.
 01 L-VALUES.
    05 L-VALUE             PIC X(80) OCCURS 13 TIMES.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-VALUES L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE SPACES TO L-VALUES
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 13
*>       The line: up to the next LF or the end of the text.
         IF WS-POS > L-LENGTH
             GOBACK
         END-IF
         MOVE 0 TO WS-LINE-LENGTH
         COMPUTE WS-END = L-LENGTH - WS-POS + 1
         INSPECT L-TEXT(WS-POS:WS-END) TALLYING WS-LINE-LENGTH FOR CHARACTERS BEFORE INITIAL X"0A"
         IF WS-LINE-LENGTH > 199
             GOBACK
         END-IF
         MOVE SPACES TO WS-LINE
         IF WS-LINE-LENGTH > 0
             MOVE L-TEXT(WS-POS:WS-LINE-LENGTH) TO WS-LINE
         END-IF
         COMPUTE WS-POS = WS-POS + WS-LINE-LENGTH + 1
*>       Split at the first "=": the key must be the expected one.
         MOVE 0 TO WS-EQUALS
         INSPECT WS-LINE TALLYING WS-EQUALS FOR CHARACTERS BEFORE INITIAL "="
         IF WS-EQUALS >= WS-LINE-LENGTH
             GOBACK
         END-IF
         MOVE SPACES TO WS-NAME WS-VALUE
         IF WS-EQUALS > 0
             MOVE WS-LINE(1:WS-EQUALS) TO WS-NAME
         END-IF
         MOVE WS-KEY(WS-INDEX) TO WS-EXPECTED
         IF WS-NAME NOT = WS-EXPECTED
             GOBACK
         END-IF
         COMPUTE WS-VALUE-LENGTH = WS-LINE-LENGTH - WS-EQUALS - 1
         IF WS-VALUE-LENGTH < 1 OR WS-VALUE-LENGTH > 80
             GOBACK
         END-IF
         COMPUTE WS-CHAR-INDEX = WS-EQUALS + 2
         MOVE WS-LINE(WS-CHAR-INDEX:WS-VALUE-LENGTH) TO WS-VALUE
         MOVE WS-KINDS(WS-INDEX:1) TO WS-KIND
*>       Characters: no control characters, and the digits of a numeric kind.
         MOVE 0 TO WS-BAD WS-DOTS
         PERFORM VARYING WS-CHAR-INDEX FROM 1 BY 1 UNTIL WS-CHAR-INDEX > WS-VALUE-LENGTH
             MOVE WS-VALUE(WS-CHAR-INDEX:1) TO WS-CHAR
             EVALUATE TRUE
                 WHEN WS-CHAR < SPACE
                     ADD 1 TO WS-BAD
                 WHEN WS-KIND = "T"
                     CONTINUE
                 WHEN WS-CHAR IS NUMERIC
                     CONTINUE
                 WHEN WS-KIND = "F" AND WS-CHAR = "." AND WS-CHAR-INDEX > 1
                         AND WS-CHAR-INDEX < WS-VALUE-LENGTH
                     ADD 1 TO WS-DOTS
                 WHEN OTHER
                     ADD 1 TO WS-BAD
             END-EVALUATE
         END-PERFORM
         IF WS-BAD > 0 OR WS-DOTS > 1
             GOBACK
         END-IF
         MOVE WS-VALUE(1:80) TO L-VALUE(WS-INDEX)
     END-PERFORM
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM PACKS-MANIFEST-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-STATUS-OF.
*> USING directory (PIC X(1100)), status out (BINARY-LONG, CT-PACKS-*): the steps of 22 §8.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY FORMATS.
 01 WS-Z                   PIC X(1101).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-CHILD               PIC X(1100).
 01 WS-MARKER              PIC X(21) VALUE ".cobolcraft-generated".
 01 WS-MANIFEST            PIC X(14) VALUE "/manifest.txt".
 01 WS-TEXT                PIC X(4097).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-VALUES.
    05 WS-VALUE            PIC X(80) OCCURS 13 TIMES.
 01 WS-PARSE-STATUS        BINARY-LONG.
 01 WS-ROW-NUMBER          BINARY-LONG VALUE 1.
 01 WS-ROW.
    05 WS-ROW-VERSION      PIC X(4).
    05 WS-ROW-SIZE         PIC X(8).
    05 WS-ROW-SHA          PIC X(64).
    05 WS-ROW-WORLD        PIC X(4).
    05 WS-ROW-PROTOCOL     PIC X(3).
    05 WS-ROW-RESOURCE     PIC X(4).
    05 WS-ROW-DATA         PIC X(5).
 01 WS-ROW-STATUS          BINARY-LONG.
 01 WS-CMP                 PIC X(80).
 01 WS-SENTINELS.
    05 FILLER PIC X(80) VALUE "/vanilla-resources/pack.mcmeta".
    05 FILLER PIC X(80) VALUE "/vanilla-resources/assets/minecraft/lang/en_us.json".
    05 FILLER PIC X(80) VALUE "/vanilla-resources/assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(80) VALUE "/vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png".
    05 FILLER PIC X(80) VALUE "/vanilla-data/pack.mcmeta".
    05 FILLER PIC X(80) VALUE "/vanilla-data/data/minecraft/worldgen/biome/plains.json".
    05 FILLER PIC X(80) VALUE "/vanilla-data/data/minecraft/dimension_type/overworld.json".
    05 FILLER PIC X(80) VALUE "/vanilla-data/data/minecraft/damage_type/generic.json".
    05 FILLER PIC X(80) VALUE "/vanilla-data/data/minecraft/recipe/stick.json".
 01 WS-SENTINEL-TABLE REDEFINES WS-SENTINELS.
    05 WS-SENTINEL         PIC X(80) OCCURS 9 TIMES.
 01 WS-SENTINEL-INDEX      BINARY-LONG.
 01 WS-ONE                 PIC X(80).
 01 WS-ONE-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
*>   1. Not a directory: absent. A path too long to take a child name is not one either.
     MOVE CT-PACKS-ABSENT TO L-STATUS
     CALL "FILE-EXISTS" USING L-DIR WS-PATH-STATUS
     IF WS-PATH-STATUS NOT = FM-IS-DIR
         GOBACK
     END-IF
     CALL "FILE-PATH-Z" USING L-DIR WS-Z WS-LENGTH WS-PATH-STATUS
     IF WS-LENGTH > 1000
         GOBACK
     END-IF
*>   2. The manifest. Missing: absent without the marker, incomplete with it.
     MOVE SPACES TO WS-CHILD
     STRING WS-Z(1:WS-LENGTH) WS-MANIFEST DELIMITED BY SIZE INTO WS-CHILD
     MOVE 4097 TO WS-TEXT-LENGTH
     CALL "FILE-READ-AT" USING WS-CHILD WS-OFFSET WS-TEXT WS-TEXT-LENGTH WS-PATH-STATUS
     EVALUATE TRUE
         WHEN WS-PATH-STATUS = FM-NOT-FOUND
             MOVE SPACES TO WS-CHILD
             STRING WS-Z(1:WS-LENGTH) "/" WS-MARKER DELIMITED BY SIZE INTO WS-CHILD
             CALL "FILE-EXISTS" USING WS-CHILD WS-PATH-STATUS
             IF WS-PATH-STATUS = FM-OK
                 MOVE CT-PACKS-INCOMPLETE TO L-STATUS
             END-IF
             GOBACK
         WHEN WS-PATH-STATUS NOT = FM-OK OR WS-TEXT-LENGTH > 4096
             MOVE CT-PACKS-DAMAGED TO L-STATUS
             GOBACK
     END-EVALUATE
     CALL "PACKS-MANIFEST-PARSE" USING WS-TEXT WS-TEXT-LENGTH WS-VALUES WS-PARSE-STATUS
     IF WS-PARSE-STATUS NOT = 0
         MOVE CT-PACKS-DAMAGED TO L-STATUS
         GOBACK
     END-IF
*>   3. Format 1 and the facts of the accepted-jar row (columns of the generated table, 92 bytes); no match: stale.
     MOVE CT-PACKS-STALE TO L-STATUS
     IF WS-VALUE(1) NOT = "1"
         GOBACK
     END-IF
     CALL "CONTENT-ACCEPTED-JAR" USING WS-ROW-NUMBER WS-ROW WS-ROW-STATUS
     MOVE WS-ROW-SHA TO WS-CMP
     IF WS-VALUE(4) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-VERSION TO WS-CMP
     IF WS-VALUE(3) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-SIZE TO WS-CMP
     IF WS-VALUE(5) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-WORLD TO WS-CMP
     IF WS-VALUE(6) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-PROTOCOL TO WS-CMP
     IF WS-VALUE(7) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-RESOURCE TO WS-CMP
     IF WS-VALUE(8) NOT = WS-CMP
         GOBACK
     END-IF
     MOVE WS-ROW-DATA TO WS-CMP
     IF WS-VALUE(9) NOT = WS-CMP
         GOBACK
     END-IF
*>   4 and 5. The sentinel files of both packs: one missing is damaged.
     MOVE CT-PACKS-DAMAGED TO L-STATUS
     PERFORM VARYING WS-SENTINEL-INDEX FROM 1 BY 1 UNTIL WS-SENTINEL-INDEX > 9
         MOVE WS-SENTINEL(WS-SENTINEL-INDEX) TO WS-ONE
         MOVE 0 TO WS-ONE-LENGTH
         INSPECT WS-ONE TALLYING WS-ONE-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
         MOVE SPACES TO WS-CHILD
         STRING WS-Z(1:WS-LENGTH) WS-ONE(1:WS-ONE-LENGTH) DELIMITED BY SIZE INTO WS-CHILD
         CALL "FILE-EXISTS" USING WS-CHILD WS-PATH-STATUS
         IF WS-PATH-STATUS NOT = FM-OK
             GOBACK
         END-IF
     END-PERFORM
     MOVE CT-PACKS-OK TO L-STATUS
     GOBACK.
 END PROGRAM PACKS-STATUS-OF.
