*> The network NBT of a standard world's dimension_type entry (docs/protocol/04 section 6, the dimension_type codec). The entry the
*> content set holds is the JSON of the vanilla-data pack; DIMENSION-TYPE-NBT writes the compound the client reads: has_fixed_time,
*> has_skylight, has_ceiling and has_ender_dragon_fight (Byte), coordinate_scale (Double), min_y, height, logical_height and
*> monster_spawn_block_light_limit (Int), infiniburn (String: a tag with its #, or a key), ambient_light (Float), monster_spawn_light_level
*> (an Int, or the Compound of an int provider: type String, min_inclusive and max_inclusive Int), skybox and cardinal_light (String,
*> when the pack gives them). The environment attributes, the timelines and the default clock are left out (all optional in the codec). The root is a
*> network root (no name, 07 section 3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMENSION-TYPE-NBT.
*> USING JSON text (any area), its length (BINARY-LONG), PB-BUFFER (appended to), status out (0 done, 1 the text is
*> no JSON object: nothing is written).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-BOOLS.
    05 FILLER              PIC X(24) VALUE "has_skylight            ".
    05 FILLER              PIC X(24) VALUE "has_ceiling             ".
    05 FILLER              PIC X(24) VALUE "has_ender_dragon_fight  ".
 01 WS-BOOL-TABLE REDEFINES WS-BOOLS.
    05 WS-BOOL-NAME        PIC X(24) OCCURS 3 TIMES.
 01 WS-INTS.
    05 FILLER              PIC X(32) VALUE "min_y                          ".
    05 FILLER              PIC X(32) VALUE "height                         ".
    05 FILLER              PIC X(32) VALUE "logical_height                 ".
    05 FILLER              PIC X(32) VALUE "monster_spawn_block_light_limit".
 01 WS-INT-TABLE REDEFINES WS-INTS.
    05 WS-INT-NAME         PIC X(32) OCCURS 4 TIMES.
 01 WS-TEXTS.
    05 FILLER              PIC X(14) VALUE "infiniburn    ".
    05 FILLER              PIC X(14) VALUE "skybox        ".
    05 FILLER              PIC X(14) VALUE "cardinal_light".
 01 WS-TEXT-TABLE REDEFINES WS-TEXTS.
    05 WS-TEXT-NAME        PIC X(14) OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 COPY PROTO.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH PB-BUFFER L-STATUS.
     MOVE 0 TO L-STATUS
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
     IF JD-ERROR = 1 OR JD-COUNT = 0 OR JN-TYPE(1) NOT = JT-OBJECT
         MOVE 1 TO L-STATUS
         GOBACK
     END-IF
     MOVE SPACES TO WS-NAME
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NAME WS-ROOT
*>   has_fixed_time, written only when the pack gives it (the default is false)
     MOVE "has_fixed_time" TO WS-KEY
     MOVE 14 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE 0 TO WS-VALUE
         IF JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
     END-IF
*>   the required Bytes
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-KEY
         MOVE WS-BOOL-NAME(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
         MOVE 0 TO WS-VALUE
         IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
     END-PERFORM
*>   coordinate_scale
     MOVE "coordinate_scale" TO WS-KEY
     MOVE 16 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE 1 TO WS-DOUBLE
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO WS-DOUBLE
     END-IF
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-DOUBLE
*>   the required Ints
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-INT-NAME(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
         MOVE 0 TO WS-VALUE
         IF WS-NODE > 0
             MOVE JN-NUM(WS-NODE) TO WS-VALUE
         END-IF
         CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
     END-PERFORM
*>   ambient_light
     MOVE "ambient_light" TO WS-KEY
     MOVE 13 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE 0 TO WS-FLOAT
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO WS-FLOAT
     END-IF
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-FLOAT
*>   monster_spawn_light_level: an Int, or the compound of an int provider
     MOVE "monster_spawn_light_level" TO WS-KEY
     MOVE 25 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     EVALUATE TRUE
         WHEN WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-OBJECT
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
             MOVE "type" TO WS-NAME
             MOVE 4 TO WS-NAME-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-SUB
             MOVE SPACES TO WS-TEXT
             MOVE 0 TO WS-TEXT-LENGTH
             IF WS-SUB > 0
                 CALL "JSON-STRING" USING JSON-DOC WS-SUB WS-TEXT WS-CAP WS-TEXT-LENGTH
             END-IF
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-TEXT WS-TEXT-LENGTH
             MOVE 13 TO WS-NAME-LENGTH
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
                 MOVE "min_inclusive" TO WS-NAME
                 IF WS-I = 2
                     MOVE "max_inclusive" TO WS-NAME
                 END-IF
                 CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-NAME WS-NAME-LENGTH WS-SUB
                 MOVE 0 TO WS-VALUE
                 IF WS-SUB > 0
                     MOVE JN-NUM(WS-SUB) TO WS-VALUE
                 END-IF
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-VALUE
             END-PERFORM
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         WHEN WS-NODE > 0
             MOVE JN-NUM(WS-NODE) TO WS-VALUE
             CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
         WHEN OTHER
             MOVE 0 TO WS-VALUE
             CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
     END-EVALUATE
*>   infiniburn (required), skybox and cardinal_light (optional): the String as the pack gives it
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-KEY
         MOVE WS-TEXT-NAME(WS-I) TO WS-KEY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
         IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-STRING
             MOVE SPACES TO WS-TEXT
             CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-TEXT WS-CAP WS-TEXT-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM DIMENSION-TYPE-NBT.
