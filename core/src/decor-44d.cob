*> The painting variants of the registry (docs/protocol/44 part 9 section 5.4; lane 002-lane-mobsb8, T9730): PAINTING-VARIANTS lists the entries of the painting_variant registry that are in the
*> placeable tag (minecraft:placeable of that registry) with their width and height (read from the entry's JSON), at most 64. An open set without the registry or the tag gives none (the caller keeps
*> its 1 x 1 stand-in).
*>
*>   PAINTING-JSON-INT USING text (first byte), length, key (PIC X(20), with its quotes and colon, e.g. '"width":'), value out (0 when the key is missing)
*>   PAINTING-VARIANTS USING count out, ids (table of 64), widths (table of 64), heights (table of 64)
*>   PAINTING-VARIANT-OF USING key (PIC X(48), with or without minecraft:), registry id out, width out, height out (lane p49t, T39060; 21 section 8.9.1): the variant of that key; an unknown or empty key gives
*>     the registry's first entry (id 0, VariantUtils.getAny); 1 x 1 when the registry is missing

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-VARIANTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REG                 PIC X(112) VALUE "painting_variant".
 01 WS-REG48               PIC X(48) VALUE "painting_variant".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:placeable".
 01 WS-TOTAL               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LEN             BINARY-LONG.
 01 WS-PAYLOAD             PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LEN                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-KEY-W               PIC X(20) VALUE '"width":'.
 01 WS-KEY-H               PIC X(20) VALUE '"height":'.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-IDS.
    05 L-ID                BINARY-LONG OCCURS 64 TIMES.
 01 L-WIDTHS.
    05 L-W                 BINARY-LONG OCCURS 64 TIMES.
 01 L-HEIGHTS.
    05 L-H                 BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-IDS L-WIDTHS L-HEIGHTS.
     MOVE 0 TO L-COUNT
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REG WS-TOTAL WS-STATUS
     IF WS-TOTAL <= 0
         GOBACK
     END-IF
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-TOTAL OR L-COUNT >= 64
         CALL "CONTENT-TAG-HAS" USING WS-REG48 WS-TAG WS-ID WS-HAS
         IF WS-HAS = 1
             CALL "CONTENT-REGISTRY-ENTRY" USING WS-REG WS-ID WS-KEY WS-KEY-LEN WS-PAYLOAD WS-CAPACITY WS-LEN WS-STATUS
             IF WS-LEN > 0
                 CALL "PAINTING-JSON-INT" USING WS-PAYLOAD WS-LEN WS-KEY-W WS-W
                 CALL "PAINTING-JSON-INT" USING WS-PAYLOAD WS-LEN WS-KEY-H WS-H
                 IF WS-W > 0 AND WS-H > 0
                     ADD 1 TO L-COUNT
                     MOVE WS-ID TO L-ID(L-COUNT)
                     MOVE WS-W TO L-W(L-COUNT)
                     MOVE WS-H TO L-H(L-COUNT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PAINTING-VARIANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-VARIANT-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REG                 PIC X(112) VALUE "painting_variant".
 01 WS-REG48               PIC X(48) VALUE "painting_variant".
 01 WS-BARE                PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LEN             BINARY-LONG.
 01 WS-PAYLOAD             PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY-W               PIC X(20) VALUE '"width":'.
 01 WS-KEY-H               PIC X(20) VALUE '"height":'.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID L-WIDTH L-HEIGHT.
     MOVE 0 TO L-ID
     MOVE 1 TO L-WIDTH L-HEIGHT
     CALL "KEY-BARE" USING L-KEY WS-BARE
     IF WS-BARE NOT = SPACES
         CALL "M44-VARIANT-ID" USING WS-REG48 WS-BARE L-ID
     END-IF
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REG L-ID WS-KEY WS-KEY-LEN WS-PAYLOAD WS-CAPACITY WS-LEN WS-STATUS
     IF WS-LEN > 0
         CALL "PAINTING-JSON-INT" USING WS-PAYLOAD WS-LEN WS-KEY-W L-WIDTH
         CALL "PAINTING-JSON-INT" USING WS-PAYLOAD WS-LEN WS-KEY-H L-HEIGHT
     END-IF
     COMPUTE L-WIDTH = FUNCTION MAX(L-WIDTH, 1)
     COMPUTE L-HEIGHT = FUNCTION MAX(L-HEIGHT, 1)
     GOBACK.
 END PROGRAM PAINTING-VARIANT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PAINTING-JSON-INT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 B-TEXT                 PIC X(8192) BASED.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LEN                  BINARY-LONG.
 01 L-KEY                  PIC X(20).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LEN L-KEY L-VALUE.
     MOVE 0 TO L-VALUE WS-FOUND
     SET ADDRESS OF B-TEXT TO ADDRESS OF L-TEXT
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I + WS-N - 1 > L-LEN OR WS-FOUND > 0
         IF B-TEXT(WS-I:WS-N) = L-KEY(1:WS-N)
             MOVE WS-I TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         COMPUTE WS-P = WS-FOUND + WS-N
         MOVE 0 TO WS-DIGIT
*>       The data files are pretty printed ("width": 4): blanks between the colon and the digits are skipped (lane p49t: the read gave 0 for every real variant, so each was 1 x 1).
         PERFORM UNTIL WS-P > L-LEN OR WS-DIGIT = -1
             MOVE B-TEXT(WS-P:1) TO WS-CH
             IF WS-CH >= "0" AND WS-CH <= "9"
                 COMPUTE L-VALUE = L-VALUE * 10 + FUNCTION NUMVAL(WS-CH)
                 MOVE 1 TO WS-DIGIT
                 ADD 1 TO WS-P
             ELSE
                 IF WS-CH = " " AND WS-DIGIT = 0
                     ADD 1 TO WS-P
                 ELSE
                     MOVE -1 TO WS-DIGIT
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PAINTING-JSON-INT.
