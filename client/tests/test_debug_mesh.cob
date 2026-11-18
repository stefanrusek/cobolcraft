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
 01 WS-ZERO-STATES         BINARY-LONG VALUE 0.
 01 WS-ZERO-BAD            BINARY-LONG VALUE 0.
 01 WS-ZERO-LIST           PIC X(200) VALUE SPACES.
 01 WS-ZPTR                BINARY-LONG VALUE 1.
 01 WS-ZHITS               BINARY-LONG.
 01 WS-ZOK                 BINARY-LONG.
 01 WS-ZH                  BINARY-LONG.
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
                 IF BM-QUAD-COUNT(WS-ROW) = 0
                     PERFORM CHECK-ZERO-QUADS
                 END-IF
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
     MOVE SPACES TO TL-CASE
     STRING "debug mesh every state that bakes no quad is a fluid, an air or invisible block, a block-entity block or a wall's unreachable "
         "state, blocks: " FUNCTION TRIM(WS-ZERO-LIST) DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ZERO-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
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

*> A state that baked no quad (BM-QUAD-COUNT 0): fine for the blocks drawn by something else (fluids: MESH-FLUID; banners, shulker boxes, skulls and heads,
*> copper golem statues, decorated pots: block-entity models) and the blocks with no visible model (the air blocks, barrier, light, structure_void,
*> moving_piston, end_portal, end_gateway, bubble_column, conduit) and the states of a wall (or pitcher_crop) that no part holds for; a block model
*> state of any other block drawing nothing is a block that does not render (operator report, try14: logs, leaves, paths, crafting tables), named here.
 CHECK-ZERO-QUADS.
     ADD 1 TO WS-ZERO-STATES
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK-ID WS-INDEX WS-BLOCK-ROW WS-BSTATUS
     MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
     MOVE CT-BR-KEY TO WS-KEY
     MOVE 0 TO WS-ZOK
     EVALUATE WS-KEY
         WHEN "air" WHEN "cave_air" WHEN "void_air" WHEN "water" WHEN "lava" WHEN "moving_piston" WHEN "end_portal" WHEN "end_gateway"
         WHEN "barrier" WHEN "light" WHEN "structure_void" WHEN "conduit" WHEN "bubble_column" WHEN "pitcher_crop" WHEN "decorated_pot"
             MOVE 1 TO WS-ZOK
     END-EVALUATE
     MOVE 0 TO WS-ZH
     INSPECT WS-KEY TALLYING WS-ZH FOR ALL "banner" ALL "shulker_box" ALL "_skull" ALL "_head" ALL "golem_statue"
     IF WS-ZH > 0
         MOVE 1 TO WS-ZOK
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-ZH
     IF WS-ZH > 5 AND WS-KEY(WS-ZH - 4:5) = "_wall"
         MOVE 1 TO WS-ZOK
     END-IF
     IF WS-ZOK = 0
         ADD 1 TO WS-ZERO-BAD
         MOVE 0 TO WS-ZHITS
         IF WS-ZERO-LIST NOT = SPACES
             INSPECT WS-ZERO-LIST TALLYING WS-ZHITS FOR ALL FUNCTION TRIM(WS-KEY)
         END-IF
         IF WS-ZHITS = 0 AND WS-ZPTR < 150
             STRING FUNCTION TRIM(WS-KEY) " " DELIMITED BY SIZE INTO WS-ZERO-LIST WITH POINTER WS-ZPTR
         END-IF
     END-IF.
 END PROGRAM TEST-DEBUG-MESH.
