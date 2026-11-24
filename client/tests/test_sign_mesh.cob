*> Real-input test, lane signtext (client/src/sign-mesh.cob SGR-MESH, sign-layout.cob SGR-KIND cache): with the generated vanilla pack (CC_GENERATED_DIR, default /tmp/cc-test/generated; a pass
*> without it) and the standard content set open, a standing oak sign placed in a loaded chunk draws the glyph quads of the text the client holds for it (SN rows): none for a row whose cell
*> holds no sign or lies beyond 64 blocks, none for a side without text, 6 vertices a glyph quad; glowing coloured text adds its outline quads. The kind of one state read twice comes from the cache.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SIGN-MESH.
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
 01 WS-KEYSTR              PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND2               BINARY-LONG.
 01 WS-KEY2                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4000.
 01 WS-VERTICES.
    05 WS-V                OCCURS 4000 TIMES.
       10 WS-VF            FLOAT-SHORT OCCURS 11 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "sign mesh: no generated packs here, skipped" TO TL-CASE
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
     CALL "FONT-LOAD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE "oak_sign" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-ROW-TEXT WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-SIGN WS-STATUS
     MOVE SPACES TO WS-KEYSTR
     MOVE "stone" TO WS-KEYSTR
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEYSTR WS-ID WS-ROW-TEXT WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STONE WS-STATUS
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO-Z WS-ROW
     MOVE 70 TO WS-Y
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SIGN

*>   The kind of the sign state read twice: the second answer comes from the cache.
     CALL "SGR-KIND" USING CLIENT-STATE WS-SIGN WS-KIND WS-KEY
     CALL "SGR-KIND" USING CLIENT-STATE WS-SIGN WS-KIND2 WS-KEY2
     MOVE "sign mesh: the default oak sign state is a standing sign and a second read gives the same" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KIND = 1 AND WS-KIND2 = 1 AND WS-KEY = WS-KEY2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One row: the sign, front text Hello on line 1 (side 2), black, no glow; the back (side 1) has no text.
     MOVE 1 TO SN-USED(1)
     MOVE WS-X TO SN-X(1)
     MOVE WS-Y TO SN-Y(1)
     MOVE WS-Z TO SN-Z(1)
     MOVE 15 TO SN-COLOR(1, 2)
     MOVE 0 TO SN-GLOW(1, 2)
     MOVE 5 TO SN-LEN(1, 2, 1)
     MOVE "Hello" TO SN-TEXT(1, 2, 1)
     COMPUTE WS-EYE(1) = WS-X + 0.5
     COMPUTE WS-EYE(2) = WS-Y + 1.6
     COMPUTE WS-EYE(3) = WS-Z + 3.5
     PERFORM BUILD
     MOVE "sign mesh: Hello on the front of a sign near the eye is five glyph quads of 6 vertices" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Text on the back as well doubles it.
     MOVE 15 TO SN-COLOR(1, 1)
     MOVE 0 TO SN-GLOW(1, 1)
     MOVE 2 TO SN-LEN(1, 1, 2)
     MOVE "Hi" TO SN-TEXT(1, 1, 2)
     PERFORM BUILD
     MOVE "sign mesh: two more glyphs on the back (line 2) make seven glyph quads in all" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Glowing coloured text near the player adds the outline (more than the plain glyphs).
     MOVE 1 TO SN-GLOW(1, 2)
     MOVE 14 TO SN-COLOR(1, 2)
     MOVE WS-X TO PL-X
     MOVE WS-Y TO PL-Y
     MOVE WS-Z TO PL-Z
     PERFORM BUILD
     MOVE "sign mesh: glowing coloured text draws its outline quads too (more vertices than the plain text)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 42
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A row beyond 64 blocks from the eye draws nothing.
     COMPUTE WS-EYE(1) = WS-X + 0.5 + 70
     PERFORM BUILD
     MOVE "sign mesh: a sign 70 blocks from the eye draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The block under the row changed to stone: skipped.
     COMPUTE WS-EYE(1) = WS-X + 0.5
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STONE
     PERFORM BUILD
     MOVE "sign mesh: a row whose cell is no longer a sign draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-COUNT: SGR-MESH of the client state for the eye WS-EYE.
 BUILD.
     MOVE 0 TO WS-COUNT
     CALL "SGR-MESH" USING CLIENT-STATE WS-EYE-TABLE WS-VERTICES WS-CAPACITY WS-COUNT.
 END PROGRAM TEST-SIGN-MESH.
