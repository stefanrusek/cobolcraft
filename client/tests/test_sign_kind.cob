*> Real-input test, lane signtext (client/src/sign-layout.cob SGR-KIND; docs/protocol/52-block-entity-models-2-signs.md sections 2.1, 3, 4.3): with the generated vanilla pack on the stack
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass without it) and the standard content set open, the block states of the 13 woods' four sign blocks (oak, spruce, birch, acacia, cherry,
*> jungle, dark oak, pale oak, mangrove, poplar, bamboo, crimson, warped) are told apart: SGR-KIND gives the family (1 standing, 2 wall, 3 ceiling hanging, 4 wall hanging) and the rotation (0 to 15)
*> or facing (0 south, 1 west, 2 north, 3 east) of every state of the registry, 1456 sign states in all; no other block is a sign. The board of each wood is an ordinary block model that bakes
*> (standing 11 quads: board 6 and post 5; wall 6; hanging 14: board 6 and four chains of two; attached hanging 8; wall hanging 20: board 6, bracket 6 and four chains), none with the missing texture.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SIGN-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-FILE                PIC X(300).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-COUNTS.
    05 WS-KIND-ENTRY       OCCURS 4 TIMES.
       10 WS-KEY-COUNT     BINARY-LONG OCCURS 16 TIMES.
 01 WS-OTHER               BINARY-LONG VALUE 0.
 01 WS-TOTAL               BINARY-LONG VALUE 0.
 01 WS-OBS                 PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-N1                  PIC -(8)9.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-WOODS               PIC X(120) VALUE
     "oak,spruce,birch,acacia,cherry,jungle,dark_oak,pale_oak,mangrove,poplar,bamboo,crimson,warped,".
 01 WS-WOOD                PIC X(12).
 01 WS-WP                  BINARY-LONG.
 01 WS-NAME                PIC X(112).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-BM-ROW              BINARY-LONG.
 01 WS-STRIPES             BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-SPEC.
    05 FILLER              PIC X(32) VALUE "_sign                          ".
    05 FILLER              PIC X(32) VALUE "_wall_sign                     ".
    05 FILLER              PIC X(32) VALUE "_hanging_sign                  ".
    05 FILLER              PIC X(32) VALUE "_wall_hanging_sign             ".
 01 WS-SPEC-TABLE REDEFINES WS-SPEC.
    05 WS-SUFFIX           PIC X(32) OCCURS 4 TIMES.
 01 WS-QUAD-TABLE.
    05 WS-QUADS            PIC 99 OCCURS 4 TIMES.
 01 WS-BAD-KIND            BINARY-LONG.
 01 WS-BAD-QUADS           BINARY-LONG.
 01 WS-BAD-STRIPES         BINARY-LONG.
 01 WS-LIST                PIC X(200).
 01 WS-LIST-PTR            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "sign kind: no generated packs here, skipped" TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN

*>   Every state of the registry.
     INITIALIZE WS-COUNTS
     PERFORM VARYING WS-STATE FROM 1 BY 1 UNTIL WS-STATE >= CT-STATE-COUNT
         CALL "SGR-KIND" USING CLIENT-STATE WS-STATE WS-KIND WS-KEY
         IF WS-KIND = 0
             ADD 1 TO WS-OTHER
         ELSE
             ADD 1 TO WS-KEY-COUNT(WS-KIND, WS-KEY + 1)
             ADD 1 TO WS-TOTAL
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
             MOVE WS-KEY-COUNT(WS-I, WS-K) TO WS-N1
             STRING FUNCTION TRIM(WS-N1) " " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
         END-PERFORM
         STRING "| " DELIMITED BY SIZE INTO WS-OBS WITH POINTER WS-PTR
     END-PERFORM
     MOVE "sign kind states per family and rotation or facing: 26 for each rotation of a standing sign, 26 per facing of a wall sign, 52 per rotation of a hanging sign, 26 per facing of a wall hanging sign" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 | 26 26 26 26 0 0 0 0 0 0 0 0 0 0 0 0 | "
         "52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 | 26 26 26 26 0 0 0 0 0 0 0 0 0 0 0 0 | " DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sign kind 1456 states are signs (13 woods x 112 states); every other state is none" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1456 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The default state of each of the 52 blocks: its kind, and its board bakes with the quads of the doc and no stripes.
     MOVE 11 TO WS-QUADS(1)
     MOVE 6 TO WS-QUADS(2)
     MOVE 14 TO WS-QUADS(3)
     MOVE 20 TO WS-QUADS(4)
     MOVE 0 TO WS-BAD-KIND WS-BAD-QUADS WS-BAD-STRIPES
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-LIST-PTR
     MOVE 1 TO WS-WP
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > 13
         MOVE SPACES TO WS-WOOD
         UNSTRING WS-WOODS DELIMITED BY "," INTO WS-WOOD WITH POINTER WS-WP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE SPACES TO WS-NAME
             STRING "minecraft:" FUNCTION TRIM(WS-WOOD) FUNCTION TRIM(WS-SUFFIX(WS-I)) DELIMITED BY SIZE INTO WS-NAME
             CALL "CONTENT-BLOCK-BY-KEY" USING WS-NAME WS-BLOCK-ID WS-ROW-TEXT WS-STATUS
             MOVE 0 TO WS-DEFAULT
             IF WS-STATUS = CT-OK
                 CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK-ID WS-DEFAULT WS-STATUS
             END-IF
             CALL "SGR-KIND" USING CLIENT-STATE WS-DEFAULT WS-KIND WS-KEY
             IF WS-KIND NOT = WS-I OR WS-DEFAULT = 0
                 ADD 1 TO WS-BAD-KIND
                 STRING FUNCTION TRIM(WS-WOOD) FUNCTION TRIM(WS-SUFFIX(WS-I)) " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-LIST-PTR
             ELSE
                 CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-DEFAULT WS-BM-ROW
                 MOVE 0 TO WS-STRIPES
                 IF WS-BM-ROW > 0
                     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-BM-ROW)
                         IF BM-SPRITE(WS-BM-ROW, WS-Q) = 1
                             MOVE 1 TO WS-STRIPES
                         END-IF
                     END-PERFORM
                 END-IF
                 IF WS-STRIPES = 1
                     ADD 1 TO WS-BAD-STRIPES
                 END-IF
                 IF WS-BM-ROW = 0 OR BM-QUAD-COUNT(WS-BM-ROW) NOT = WS-QUADS(WS-I)
                     ADD 1 TO WS-BAD-QUADS
                     MOVE 0 TO WS-STATE
                     IF WS-BM-ROW > 0
                         MOVE BM-QUAD-COUNT(WS-BM-ROW) TO WS-STATE
                     END-IF
                     MOVE WS-STATE TO WS-N1
                     STRING FUNCTION TRIM(WS-WOOD) FUNCTION TRIM(WS-SUFFIX(WS-I)) "=" FUNCTION TRIM(WS-N1) " "
                         DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-LIST-PTR
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "sign kind each of the 13 woods has the four sign blocks, told apart by SGR-KIND, bad: " FUNCTION TRIM(WS-LIST) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-KIND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "sign board the default state of each of the 52 sign blocks bakes its board model quads (11, 6, 14, 20), bad: " FUNCTION TRIM(WS-LIST) DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-QUADS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sign board no board quad of any wood draws the missing-texture stripes (sprite 1)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-STRIPES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SIGN-KIND.
