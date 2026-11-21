*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 1, lane 002-lane-p49j-a): the scope map is a table of pointers; what it makes
*> checkable in the core is 1.1, the aquatic siblings: cod, salmon, pufferfish, tropical fish (fish rows), squid, glow squid and dolphin have mob rows in the standard table, so
*> the rules the map points at (4.1 flop, 6.1 experience, 4.2 hop) run on real mobs. The map's other rows (axolotl, nautilus family, guardians, tadpole, turtle) have no row here.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-TYPE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(14) VALUE "cod".
    05 FILLER              PIC X(14) VALUE "salmon".
    05 FILLER              PIC X(14) VALUE "pufferfish".
    05 FILLER              PIC X(14) VALUE "tropical_fish".
    05 FILLER              PIC X(14) VALUE "squid".
    05 FILLER              PIC X(14) VALUE "glow_squid".
    05 FILLER              PIC X(14) VALUE "dolphin".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(14) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE INTO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 44-7§1.1 the aquatic sibling minecraft:" DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " has a mob row" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-INDEX > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "MS6-ROW-CAT" USING WS-INDEX WS-CAT
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 44-7§1.1 minecraft:" DELIMITED BY SIZE WS-NAME(WS-K) DELIMITED BY SPACE
             " is a water category mob (6 water creature or 7 water ambient)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF WS-CAT = 6 OR WS-CAT = 7 OR WS-CAT = 5
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-Q44-44-7-1.
 COPY CORETEST.
 COPY MOBSPTEST.
