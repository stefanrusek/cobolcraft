*> Implementation test of VIL-PROF-ID (docs/protocol/46 section 6.2; lane 002-lane-villagers, T12100): the villager_profession registry id of each profession key; none and an unknown key are 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VIL-PROF-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAMES.
    05 FILLER              PIC X(16) VALUE "none".
    05 FILLER              PIC X(16) VALUE "armorer".
    05 FILLER              PIC X(16) VALUE "butcher".
    05 FILLER              PIC X(16) VALUE "cartographer".
    05 FILLER              PIC X(16) VALUE "cleric".
    05 FILLER              PIC X(16) VALUE "farmer".
    05 FILLER              PIC X(16) VALUE "fisherman".
    05 FILLER              PIC X(16) VALUE "fletcher".
    05 FILLER              PIC X(16) VALUE "leatherworker".
    05 FILLER              PIC X(16) VALUE "librarian".
    05 FILLER              PIC X(16) VALUE "mason".
    05 FILLER              PIC X(16) VALUE "nitwit".
    05 FILLER              PIC X(16) VALUE "shepherd".
    05 FILLER              PIC X(16) VALUE "toolsmith".
    05 FILLER              PIC X(16) VALUE "weaponsmith".
    05 FILLER              PIC X(16) VALUE "wandering_trader".
 01 WS-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         CALL "VIL-PROF-ID" USING WS-NAME(WS-I) WS-ID
         MOVE SPACES TO TL-CASE
         STRING "46 6.2 registry id of " WS-NAME(WS-I) DELIMITED BY SIZE INTO TL-CASE
         IF WS-I = 16
             MOVE 0 TO TL-EXPECTED-N
         ELSE
             COMPUTE TL-EXPECTED-N = WS-I - 1
         END-IF
         MOVE WS-ID TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-VIL-PROF-ID.
