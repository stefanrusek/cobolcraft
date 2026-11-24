*> The climate of a biome entry (CBLOCKS.cpy CORE-BIOMES): BIOME-CLIMATE reads has_precipitation, temperature and temperature_modifier from the network NBT of a worldgen/biome registry entry
*> (the compound BIOME-NBT writes; docs/protocol/33 section 4.5 and 10 section 10 give the use). FR-TEMPERATURE of core/src/feat-freeze.cob turns it into the temperature at a position.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-CLIMATE.
*> USING PB-BUFFER (the payload, PB-POS anywhere: it is read from 0), has_precipitation out (BINARY-LONG), temperature out (FLOAT-LONG, a float widened to a double),
*> frozen out (BINARY-LONG, 1 when temperature_modifier is "frozen"). A member that is absent leaves its output as it was.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-TEXT                PIC X(16).
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 16.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PRECIPITATION        BINARY-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 01 L-FROZEN               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-PRECIPITATION L-TEMPERATURE L-FROZEN.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WS-NAME
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME WS-NAME-CAPACITY WS-NAME-LENGTH
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-NAME = "has_precipitation" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                 MOVE WS-BYTE TO L-PRECIPITATION
             WHEN WS-NAME = "temperature" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                 MOVE WS-FLOAT TO L-TEMPERATURE
                 CALL "FR-F32" USING L-TEMPERATURE
             WHEN WS-NAME = "temperature_modifier" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAPACITY WS-TEXT-LENGTH
                 IF WS-TEXT = "frozen"
                     MOVE 1 TO L-FROZEN
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BIOME-CLIMATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOME-CLIMATE-JSON.
*> USING text area (the entry's strict JSON, as the registry of a standard set holds it), length (BINARY-LONG), has_precipitation out (BINARY-LONG), temperature out (FLOAT-LONG, a float widened to a double),
*> frozen out (BINARY-LONG, 1 when temperature_modifier is "frozen"): the same three members as BIOME-CLIMATE reads from network NBT. A member that is absent leaves its output as it was.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-NODE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TEXT                PIC X(16).
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 16.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-KEY-PRECIPITATION   PIC X(17) VALUE "has_precipitation".
 01 WS-KEY-PRECIPITATION-N BINARY-LONG VALUE 17.
 01 WS-KEY-TEMPERATURE     PIC X(11) VALUE "temperature".
 01 WS-KEY-TEMPERATURE-N   BINARY-LONG VALUE 11.
 01 WS-KEY-MODIFIER        PIC X(20) VALUE "temperature_modifier".
 01 WS-KEY-MODIFIER-N      BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-PRECIPITATION        BINARY-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 01 L-FROZEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-PRECIPITATION L-TEMPERATURE L-FROZEN.
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
     IF JD-ERROR = 1
         GOBACK
     END-IF
     MOVE 1 TO WS-ROOT
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY-PRECIPITATION WS-KEY-PRECIPITATION-N WS-NODE
     IF WS-NODE > 0
         MOVE 0 TO L-PRECIPITATION
         IF JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO L-PRECIPITATION
         END-IF
     END-IF
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY-TEMPERATURE WS-KEY-TEMPERATURE-N WS-NODE
     IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-NUMBER
         MOVE JN-NUM(WS-NODE) TO L-TEMPERATURE
         CALL "FR-F32" USING L-TEMPERATURE
     END-IF
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY-MODIFIER WS-KEY-MODIFIER-N WS-NODE
     IF WS-NODE > 0
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-TEXT WS-TEXT-CAPACITY WS-TEXT-LENGTH
         IF WS-TEXT = "frozen"
             MOVE 1 TO L-FROZEN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BIOME-CLIMATE-JSON.
