*> Test of the armour trim helpers (core/src/stack-trim.cob; docs/protocol/54 section 18, 27 section 3.3; lane itemcomp3, T10605): SC-TRIM-SET and SC-TRIM-GET (component 58: the material
*> then the pattern, each a registry position plus 1), TRIM-MATERIAL-OF (the material of an ingot or gem item), REG-KEY-ID over the trim registries of the fixture and SMITH-TRIM-RESULT (the
*> trimmed copy of the base, refused when the same trim is already there or the addition has no material).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TRIM.
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
 01 WS-IRON                BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-REDSTONE            BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-H3                  BINARY-LONG.
 01 WS-MAT                 BINARY-LONG.
 01 WS-PAT                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MKEY                PIC X(24).
 01 WS-REG                 PIC X(112).
 01 WS-PATTERN             PIC X(112).
 01 WS-VALUE               PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-T58                 BINARY-LONG VALUE 58.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
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
     MOVE "iron_ingot" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-IRON
     MOVE "dirt" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-DIRT
     MOVE "redstone" TO WS-KEY
     PERFORM LOOKUP-ID
     MOVE WS-ID TO WS-REDSTONE

     MOVE "test trim registry ids: coast is position 1 of the patterns bolt, coast, wild; gold is position 4 of the materials; an unknown key is -1" TO TL-CASE
     MOVE "trim_pattern" TO WS-REG
     MOVE "minecraft:coast" TO WS-KEY
     CALL "REG-KEY-ID" USING WS-REG WS-KEY WS-P
     MOVE "trim_material" TO WS-REG
     MOVE "minecraft:gold" TO WS-KEY
     CALL "REG-KEY-ID" USING WS-REG WS-KEY WS-M
     MOVE "minecraft:nothing" TO WS-KEY
     CALL "REG-KEY-ID" USING WS-REG WS-KEY WS-ID
     MOVE WS-P TO WS-E1
     MOVE WS-M TO WS-E2
     MOVE WS-ID TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 4 -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test trim material of an item: iron_ingot iron, redstone redstone, dirt none" TO TL-CASE
     CALL "TRIM-MATERIAL-OF" USING WS-IRON WS-MKEY
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-MKEY) "," DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TRIM-MATERIAL-OF" USING WS-REDSTONE WS-MKEY
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-MKEY) "," DELIMITED BY SIZE INTO WS-VALUE
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TRIM-MATERIAL-OF" USING WS-DIRT WS-MKEY
     MOVE SPACES TO WS-VALUE
     IF WS-MKEY = SPACES
         STRING FUNCTION TRIM(TL-OBSERVED) "none" DELIMITED BY SIZE INTO WS-VALUE
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) "BAD" DELIMITED BY SIZE INTO WS-VALUE
     END-IF
     MOVE WS-VALUE TO TL-OBSERVED
     MOVE "iron,redstone,none" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test trim component: set material 4 and pattern 1 gives the bytes 05 02 and reads back as 4 and 1; absent reads not found" TO TL-CASE
     MOVE 0 TO WS-HANDLE
     CALL "SC-TRIM-GET" USING WS-HANDLE WS-FOUND WS-M WS-P
     MOVE WS-FOUND TO WS-E4
     MOVE 4 TO WS-MAT
     MOVE 1 TO WS-PAT
     CALL "SC-TRIM-SET" USING WS-HANDLE WS-MAT WS-PAT
     CALL "SC-TRIM-GET" USING WS-HANDLE WS-FOUND WS-M WS-P
     CALL "SP-GET-COMPONENT" USING WS-HANDLE WS-T58 WS-VALUE WS-LEN WS-FOUND
     MOVE WS-M TO WS-E1
     MOVE WS-P TO WS-E2
     COMPUTE WS-E3 = FUNCTION ORD(WS-VALUE(1:1)) - 1
     MOVE WS-LEN TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "absent " FUNCTION TRIM(WS-E4) " read " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " first-byte " FUNCTION TRIM(WS-E3) " len " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "absent 0 read 4/1 first-byte 5 len 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test trim smithing result: coast with a gold ingot trims a helmet (material 4 pattern 1); the same pair again is refused; iron on the trimmed helmet replaces the trim; dirt as the addition is refused" TO TL-CASE
     MOVE "minecraft:coast" TO WS-PATTERN
     MOVE 0 TO WS-H2
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H2 WS-GOLD WS-H3 WS-OK
     MOVE WS-OK TO WS-E1
     CALL "SC-TRIM-GET" USING WS-H3 WS-FOUND WS-M WS-P
     MOVE WS-M TO WS-E2
     MOVE WS-P TO WS-E3
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H3 WS-GOLD WS-H2 WS-OK
     MOVE WS-OK TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "first " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) "/" FUNCTION TRIM(WS-E3) " again " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H3 WS-IRON WS-H2 WS-OK
     CALL "SC-TRIM-GET" USING WS-H2 WS-FOUND WS-M WS-P
     MOVE WS-OK TO WS-E1
     MOVE WS-M TO WS-E2
     CALL "SMITH-TRIM-RESULT" USING WS-PATTERN WS-HELMET WS-H3 WS-DIRT WS-H2 WS-OK
     MOVE WS-OK TO WS-E3
     MOVE SPACES TO WS-VALUE
     STRING " iron " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) " dirt " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-VALUE
     MOVE SPACES TO WS-ITEM-ROW
     STRING FUNCTION TRIM(TL-OBSERVED) FUNCTION TRIM(WS-VALUE, TRAILING) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO TL-OBSERVED
     MOVE "first 1 4/1 again 0 iron 1/5 dirt 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 LOOKUP-ID.
     MOVE SPACES TO WS-ITEM-ROW
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-ITEM-ROW
     MOVE WS-ITEM-ROW TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TRIM.
 COPY CORETEST.
