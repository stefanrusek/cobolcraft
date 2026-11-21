*> Coverage of core/src/stack-trim.cob: TRIM-MATERIAL-OF for every ingot and gem that provides a trim material, and SMITH-TRIM-RESULT with a pattern named without minecraft:, an unknown pattern and
*> a pattern the registry does not hold (refused). No fixture lacks a trim material, so that refusal shares the pattern line.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-C-TRIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/anvil-registry".
 01 WS-REG-STATUS          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-COPPER              BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-H3                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-MKEY                PIC X(24).
 01 WS-PATTERN             PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-LIST.
    05 FILLER              PIC X(32) VALUE "copper_ingot".
    05 FILLER              PIC X(32) VALUE "netherite_ingot".
    05 FILLER              PIC X(32) VALUE "diamond".
    05 FILLER              PIC X(32) VALUE "emerald".
    05 FILLER              PIC X(32) VALUE "lapis_lazuli".
    05 FILLER              PIC X(32) VALUE "quartz".
    05 FILLER              PIC X(32) VALUE "amethyst_shard".
    05 FILLER              PIC X(32) VALUE "resin_brick".
 01 WS-ITEMS REDEFINES WS-LIST.
    05 WS-ITEM-KEY         PIC X(32) OCCURS 8 TIMES.
 01 WS-WANT-LIST.
    05 FILLER              PIC X(24) VALUE "copper".
    05 FILLER              PIC X(24) VALUE "netherite".
    05 FILLER              PIC X(24) VALUE "diamond".
    05 FILLER              PIC X(24) VALUE "emerald".
    05 FILLER              PIC X(24) VALUE "lapis".
    05 FILLER              PIC X(24) VALUE "quartz".
    05 FILLER              PIC X(24) VALUE "amethyst".
    05 FILLER              PIC X(24) VALUE "resin".
 01 WS-WANTS REDEFINES WS-WANT-LIST.
    05 WS-WANT             PIC X(24) OCCURS 8 TIMES.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     CALL "REGISTRY-LOAD-ALL" USING WS-DIR WS-REG-STATUS
     CALL "TEST-STANDARD-TABLES"
     MOVE "T" TO TL-MODE

     MOVE "diamond_helmet" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-HELMET
     MOVE "gold_ingot" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-GOLD
     MOVE "copper_ingot" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-COPPER

     MOVE "cove-c trim material of an item: the eight remaining ingots and gems name their material" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-ITEM-KEY(WS-I) TO WS-KEY
         PERFORM LOOKUP-ID
         CALL "TRIM-MATERIAL-OF" USING WS-ID WS-MKEY
         IF WS-MKEY NOT = WS-WANT(WS-I)
             MOVE WS-I TO WS-E1
             MOVE SPACES TO TL-OBSERVED
             STRING "item " FUNCTION TRIM(WS-E1) " gave " WS-MKEY DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c smithing: a pattern without minecraft: trims like the full key" TO TL-CASE
     MOVE "coast" TO WS-PATTERN
     MOVE 0 TO WS-H2
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H2 WS-GOLD WS-H3 WS-OK
     CALL "SC-TRIM-GET" USING WS-H3 WS-FOUND WS-M WS-P
     MOVE WS-OK TO WS-E1
     MOVE WS-M TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "ok " FUNCTION TRIM(WS-E1) " material " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "ok 1 material 4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cove-c smithing: a pattern the registry lacks is refused (a copper addition alone trims)" TO TL-CASE
     MOVE "minecraft:coast" TO WS-PATTERN
     MOVE 0 TO WS-H2
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H2 WS-COPPER WS-H3 WS-OK
     MOVE WS-OK TO WS-E1
     MOVE "nowhere" TO WS-PATTERN
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H2 WS-GOLD WS-H3 WS-OK
     MOVE WS-OK TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "copper " FUNCTION TRIM(WS-E1) " pattern " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "copper 1 pattern 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.
 END PROGRAM TEST-COVE-C-TRIM.
 COPY CORETEST.
