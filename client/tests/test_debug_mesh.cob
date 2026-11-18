*> Real-input test of the debug world's mesh (plan "Operator addition: debug world"; docs/design/debug-world.md): with the generated vanilla pack on the
*> stack (CC_GENERATED_DIR, default /tmp/cc-test/generated) and the standard content set open, the baked quads of every block state of the debug grid
*> (state ids 1 to the last state, one cell each) use no missing-texture sprite (sprite 1), except the states of the blocks that have no block state file
*> or model on purpose (the air blocks) and heavy_core, whose model of the generated pack names its face texture `all` without the `#` of a slot reference, a sprite id `minecraft:all` that no pack holds (08 section 5.3: stripes). The test fails with the block names when a pack is absent or a state draws the stripes; it never skips.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-MESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-BATCH               BINARY-LONG VALUE 1500.
 01 WS-Q                   BINARY-LONG.
 01 WS-STRIPES             BINARY-LONG.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-BAD-STATES          BINARY-LONG VALUE 0.
 01 WS-CHECKED             BINARY-LONG VALUE 0.
 01 WS-LIST                PIC X(200) VALUE SPACES.
 01 WS-PTR                 BINARY-LONG VALUE 1.
 01 WS-HITS                BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-ATLAS               BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BSTATUS             BINARY-LONG.
 01 WS-N                   PIC Z(5)9.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
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
     MOVE "N" TO TL-MODE
     MOVE "debug mesh the generated vanilla pack is on the stack and holds the stone sprite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SPACES TO WS-ID
     MOVE "minecraft:block/stone" TO WS-ID
     MOVE 0 TO WS-ATLAS
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID 21 WS-ATLAS
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ATLAS > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-FIRST FROM 1 BY WS-BATCH UNTIL WS-FIRST >= CT-STATE-COUNT
         CALL "MODELS-BAKE" USING CLIENT-STATE
         PERFORM VARYING WS-STATE FROM WS-FIRST BY 1 UNTIL WS-STATE >= WS-FIRST + WS-BATCH OR WS-STATE >= CT-STATE-COUNT
             CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-ROW
             IF WS-ROW > 0
                 ADD 1 TO WS-CHECKED
                 MOVE 0 TO WS-STRIPES
                 PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(WS-ROW)
                     IF BM-SPRITE(WS-ROW, WS-Q) = 1
                         MOVE 1 TO WS-STRIPES
                     END-IF
                 END-PERFORM
                 IF WS-STRIPES = 1
                     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK-ID WS-INDEX WS-BLOCK-ROW WS-BSTATUS
                     MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
                     MOVE CT-BR-KEY TO WS-KEY
                     MOVE 0 TO WS-HITS
                     IF WS-KEY NOT = "air" AND WS-KEY NOT = "cave_air" AND WS-KEY NOT = "void_air" AND WS-KEY NOT = "heavy_core"
                         ADD 1 TO WS-BAD-STATES
                         IF WS-LIST NOT = SPACES
                             INSPECT WS-LIST TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-KEY)
                         END-IF
                         IF WS-HITS = 0 AND WS-PTR < 150
                             STRING FUNCTION TRIM(WS-KEY) " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
                             ADD 1 TO WS-BAD
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-CHECKED TO WS-N
     MOVE SPACES TO TL-CASE
     STRING "debug mesh states with a baked row checked: " FUNCTION TRIM(WS-N) " of the standard set" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CHECKED > 30000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "debug mesh no state draws the missing-texture stripes, blocks: " FUNCTION TRIM(WS-LIST) DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-STATES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-MESH.
