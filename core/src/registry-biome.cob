*> The network NBT of a standard world's worldgen/biome entry (docs/protocol/04 section 6, the biome codec; 43 section 5
*> for the colours). The entry the content set holds is the JSON of the vanilla-data pack, whose generation settings,
*> spawns and sounds the network codec leaves out; BIOME-NBT writes the compound the client reads:
*> has_precipitation (Byte), temperature and downfall (Float), temperature_modifier (String, only when "frozen"),
*> attributes (the minecraft:visual/ ones: a String colour as it stands, a Float as a Float, an object as the
*> Compound of its modifier String and argument Float), effects (water_color, foliage_color, dry_foliage_color and
*> grass_color as the pack gives them, a String or an Int, and grass_color_modifier String). The root is a network
*> root (no name, 07 section 3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-NBT.
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
 01 WS-MEMBER              BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-I                   BINARY-LONG.
 01 WS-COLOURS.
    05 FILLER              PIC X(17) VALUE "water_color      ".
    05 FILLER              PIC X(17) VALUE "foliage_color    ".
    05 FILLER              PIC X(17) VALUE "dry_foliage_color".
    05 FILLER              PIC X(17) VALUE "grass_color      ".
 01 WS-COLOUR-TABLE REDEFINES WS-COLOURS.
    05 WS-COLOUR-NAME      PIC X(17) OCCURS 4 TIMES.
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
*>   has_precipitation
     MOVE "has_precipitation" TO WS-KEY
     MOVE 17 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE 0 TO WS-VALUE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO WS-VALUE
         END-IF
     END-IF
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
*>   temperature, downfall
     MOVE "temperature" TO WS-KEY
     MOVE 11 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE 0 TO WS-FLOAT
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO WS-FLOAT
     END-IF
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-FLOAT
     MOVE "downfall" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     MOVE 0 TO WS-FLOAT
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO WS-FLOAT
     END-IF
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-FLOAT
*>   temperature_modifier, only "frozen" (the default is none)
     MOVE "temperature_modifier" TO WS-KEY
     MOVE 20 TO WS-KEY-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-KEY WS-KEY-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-TEXT WS-CAP WS-TEXT-LENGTH
         IF WS-TEXT = "frozen"
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
         END-IF
     END-IF
*>   attributes: the visual ones
     MOVE "attributes" TO WS-NAME
     MOVE 10 TO WS-NAME-LENGTH
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NAME WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-NAME WS-NAME-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-FIRST(WS-NODE) TO WS-MEMBER
         PERFORM UNTIL WS-MEMBER = 0
             MOVE SPACES TO WS-KEY
             CALL "JSON-KEY" USING JSON-DOC WS-MEMBER WS-KEY WS-CAP WS-KEY-LENGTH
             IF WS-KEY-LENGTH > 17 AND WS-KEY(1:17) = "minecraft:visual/"
                 EVALUATE JN-TYPE(WS-MEMBER)
                     WHEN JT-STRING
                         MOVE SPACES TO WS-TEXT
                         CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-TEXT WS-CAP WS-TEXT-LENGTH
                         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
                     WHEN JT-NUMBER
                         MOVE JN-NUM(WS-MEMBER) TO WS-FLOAT
                         CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-FLOAT
                     WHEN JT-OBJECT
                         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
                         MOVE "modifier" TO WS-NAME
                         MOVE 8 TO WS-NAME-LENGTH
                         CALL "JSON-MEMBER" USING JSON-DOC WS-MEMBER WS-NAME WS-NAME-LENGTH WS-SUB
                         IF WS-SUB > 0
                             MOVE SPACES TO WS-TEXT
                             CALL "JSON-STRING" USING JSON-DOC WS-SUB WS-TEXT WS-CAP WS-TEXT-LENGTH
                             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-TEXT WS-TEXT-LENGTH
                         END-IF
                         MOVE "argument" TO WS-NAME
                         CALL "JSON-MEMBER" USING JSON-DOC WS-MEMBER WS-NAME WS-NAME-LENGTH WS-SUB
                         IF WS-SUB > 0
                             MOVE JN-NUM(WS-SUB) TO WS-FLOAT
                             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-FLOAT
                         END-IF
                         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 END-EVALUATE
             END-IF
             MOVE JN-NEXT(WS-MEMBER) TO WS-MEMBER
         END-PERFORM
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>   effects: the colours and the grass colour modifier
     MOVE "effects" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NAME WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ONE WS-NAME WS-NAME-LENGTH WS-NODE
     IF WS-NODE > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE SPACES TO WS-KEY
             MOVE WS-COLOUR-NAME(WS-I) TO WS-KEY
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
             CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-MEMBER
             IF WS-MEMBER > 0
                 EVALUATE JN-TYPE(WS-MEMBER)
                     WHEN JT-STRING
                         MOVE SPACES TO WS-TEXT
                         CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-TEXT WS-CAP WS-TEXT-LENGTH
                         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
                     WHEN JT-NUMBER
                         MOVE JN-NUM(WS-MEMBER) TO WS-VALUE
                         CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-VALUE
                 END-EVALUATE
             END-IF
         END-PERFORM
         MOVE "grass_color_modifier" TO WS-KEY
         MOVE 20 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-MEMBER
         IF WS-MEMBER > 0
             MOVE SPACES TO WS-TEXT
             CALL "JSON-STRING" USING JSON-DOC WS-MEMBER WS-TEXT WS-CAP WS-TEXT-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-KEY WS-KEY-LENGTH WS-TEXT WS-TEXT-LENGTH
         END-IF
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM BIOME-NBT.
