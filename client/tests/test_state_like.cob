*> T10401 (bug-sweep: ice drew its hidden faces): the blocks that fill the cube without occluding (ice, frosted ice, glass, stained glass, tinted glass,
*> slime, honey, leaves) hide their faces against the same block (ST-LIKE, mesher.cob), and do not occlude (ST-OPAQUE 0); a block of the same class
*> that is a full opaque cube (packed ice, blue ice, stone) occludes instead.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STATE-LIKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-KEYSTR              PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-N                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(24) VALUE "ice".
    05 FILLER              PIC X(24) VALUE "frosted_ice".
    05 FILLER              PIC X(24) VALUE "glass".
    05 FILLER              PIC X(24) VALUE "white_stained_glass".
    05 FILLER              PIC X(24) VALUE "tinted_glass".
    05 FILLER              PIC X(24) VALUE "slime_block".
    05 FILLER              PIC X(24) VALUE "honey_block".
    05 FILLER              PIC X(24) VALUE "oak_leaves".
    05 FILLER              PIC X(24) VALUE "packed_ice".
    05 FILLER              PIC X(24) VALUE "blue_ice".
    05 FILLER              PIC X(24) VALUE "stone".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(24) OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 11
         MOVE SPACES TO WS-KEYSTR
         MOVE WS-NAME(WS-N) TO WS-KEYSTR
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-BLOCK-ROW WS-STATUS
         CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "state like " FUNCTION TRIM(WS-NAME(WS-N)) " opaque and like" DELIMITED BY SIZE INTO TL-CASE
         IF WS-N <= 8
             MOVE "opaque 0 like 1" TO TL-EXPECTED
         ELSE
             MOVE "opaque 1 like 0" TO TL-EXPECTED
         END-IF
         STRING "opaque " ST-OPAQUE(WS-STATE + 1) " like " ST-LIKE(WS-STATE + 1) DELIMITED BY SIZE INTO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-STATE-LIKE.
