*> Real-data test (vanfmt lane; docs/protocol/07 section 7.3, 46): the property text of a block state is not cut at 64
*> characters. When the full generated packs are present (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped,
*> as a pass, when they are not), every state of the standard set renders its properties with BLOCKS-STATE-PROPS and
*> BLOCKS-STATE-OF finds the same state again from that text (the longest text of the 26.3 set is 144 characters), and a palette entry with seven properties is read whole by CHUNK-NBT-PALETTE-ENTRY.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STATE-PROPS-WIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-S                   BINARY-LONG.
 01 WS-BACK                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LONGEST             BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FIRST-BAD           BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PROPS               PIC X(160).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ELEMENT             BINARY-LONG VALUE 10.
 01 WS-NAMES.
    05 FILLER              PIC X(10) VALUE "down      ".
    05 FILLER              PIC X(10) VALUE "east      ".
    05 FILLER              PIC X(10) VALUE "north     ".
    05 FILLER              PIC X(10) VALUE "south     ".
    05 FILLER              PIC X(10) VALUE "up        ".
    05 FILLER              PIC X(10) VALUE "waterlogge".
    05 FILLER              PIC X(10) VALUE "west      ".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-PNAME            PIC X(10) OCCURS 7 TIMES.
 01 WS-J                   BINARY-LONG.
 01 WS-K-KEY               PIC X(64).
 01 WS-K-LENGTH            BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-PAIR-COUNT          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE               PIC X(8) VALUE "false".
 01 WS-VALUE-LENGTH        BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
*>   A palette entry with seven properties: 83 characters of pairs.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN
     MOVE 2 TO WL
     MOVE "minecraft:glow_lichen" TO WS-K-KEY
     MOVE 21 TO WS-K-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-K-KEY WS-K-LENGTH
     MOVE "properties" TO WN
     MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
         MOVE SPACES TO WS-NAME
         MOVE WS-PNAME(WS-J) TO WS-NAME
         IF WS-J = 6
             MOVE "waterlogged" TO WS-NAME
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-VALUE WS-VALUE-LENGTH
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WS-K-KEY WS-PAIRS
     MOVE 0 TO WS-K-LENGTH WS-PAIR-COUNT
     CALL "CHUNK-NBT-PALETTE-ENTRY" USING PB-BUFFER WS-ELEMENT WS-K-KEY WS-K-LENGTH WS-PAIRS WS-PAIR-COUNT
     MOVE WS-PAIR-COUNT TO WS-E1
     MOVE PB-ERROR TO WS-E2
     MOVE "test state props wide: a palette entry with seven properties is read whole" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-PAIRS) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "7 0 down=false,east=false,north=false,south=false,up=false,waterlogged=false,west=false"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test state props wide no generated packs here, skipped" TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-BAD WS-LONGEST WS-FIRST-BAD
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= CB-STATE-COUNT
         CALL "BLOCKS-STATE-PROPS" USING WS-S WS-PROPS
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROPS TRAILING)) TO WS-LENGTH
         IF WS-PROPS = SPACES
             MOVE 0 TO WS-LENGTH
         END-IF
         IF WS-LENGTH > WS-LONGEST
             MOVE WS-LENGTH TO WS-LONGEST
         END-IF
         MOVE CB-S-BLOCK(WS-S + 1) TO WS-BLOCK
         MOVE SPACES TO WS-KEY
         MOVE CB-KEY(WS-BLOCK + 1)(1:CB-KEY-LENGTH(WS-BLOCK + 1)) TO WS-KEY
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PROPS WS-BACK
         IF WS-BACK NOT = WS-S
             ADD 1 TO WS-BAD
             IF WS-FIRST-BAD = 0
                 MOVE WS-S TO WS-FIRST-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "test state props wide every state of the standard set is found again from its property text" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test state props wide the longest property text of the standard set is over 64 and fits 160" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LONGEST > 64 AND WS-LONGEST <= 160
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STATE-PROPS-WIDE.

 COPY CORETEST.
