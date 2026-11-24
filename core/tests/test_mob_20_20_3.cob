*> Acceptance test (002-lane-p49b; docs/protocol/20 section 20.3, validation item 13): raid wave composition, from the document's table of Normal waves 1 to 5 and its
*> Easy, Hard and bonus-wave remarks. Per wave and raider type (1 vindicator, 2 evoker, 3 pillager, 4 witch, 5 ravager) RAID-WAVE-COUNT gives the table's default plus the
*> bonus draw: over many draws the smallest count is the default and the largest the default plus the bonus maximum (vindicator and pillager 1 on Normal, 2 on Hard,
*> 0 or 1 on Easy; witch 1 from wave 3 on except wave 4, none on Easy; evoker none; ravager 1 only in the bonus wave on Normal and Hard, whose row is that of the last
*> regular wave). The number of waves is 3, 5 and 7 by difficulty, 0 in Peaceful.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-20-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-DEF                 BINARY-LONG.
 01 WS-BON                 BINARY-LONG.
 01 WS-WAVE                BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-WN                  PIC 9.
 01 WS-TN                  PIC 9.
 01 WS-DN                  PIC 9.
*> Each line: difficulty, wave, bonus-wave flag, then (default, bonus maximum) of vindicator, evoker, pillager, witch, ravager.
 01 WS-DATA.
    05 FILLER              PIC X(20) VALUE "2 1 0 01 00 41 00 00".
    05 FILLER              PIC X(20) VALUE "2 2 0 21 00 31 00 00".
    05 FILLER              PIC X(20) VALUE "2 3 0 01 00 31 01 10".
    05 FILLER              PIC X(20) VALUE "2 4 0 11 00 41 30 00".
    05 FILLER              PIC X(20) VALUE "2 5 0 41 10 41 01 10".
    05 FILLER              PIC X(20) VALUE "1 3 0 01 00 31 00 10".
    05 FILLER              PIC X(20) VALUE "3 7 0 52 20 22 11 20".
    05 FILLER              PIC X(20) VALUE "2 6 1 41 10 41 01 11".
    05 FILLER              PIC X(20) VALUE "3 8 1 52 20 22 11 21".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-LINE OCCURS 9 TIMES.
       10 WS-L-DIFF        PIC 9.
       10 FILLER           PIC X.
       10 WS-L-WAVE        PIC 9.
       10 FILLER           PIC X.
       10 WS-L-FLAG        PIC 9.
       10 WS-L-TYPE OCCURS 5 TIMES.
          15 FILLER        PIC X.
          15 WS-L-DEF      PIC 9.
          15 WS-L-BON      PIC 9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
             MOVE WS-L-DIFF(WS-I) TO WS-DIFF
             MOVE WS-L-WAVE(WS-I) TO WS-WAVE
             MOVE WS-L-FLAG(WS-I) TO WS-FLAG
             MOVE WS-L-DEF(WS-I, WS-T) TO WS-DEF
             MOVE WS-L-BON(WS-I, WS-T) TO WS-BON
             MOVE 99 TO WS-MIN
             MOVE 0 TO WS-MAX
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 120
                 CALL "RAID-WAVE-COUNT" USING WS-T WS-WAVE WS-DIFF WS-FLAG WS-COUNT
                 IF WS-COUNT < WS-MIN
                     MOVE WS-COUNT TO WS-MIN
                 END-IF
                 IF WS-COUNT > WS-MAX
                     MOVE WS-COUNT TO WS-MAX
                 END-IF
             END-PERFORM
             MOVE WS-DIFF TO WS-DN
             MOVE WS-WAVE TO WS-WN
             MOVE WS-T TO WS-TN
             MOVE SPACES TO TL-CASE
             STRING "acceptance US15 20§20.3 difficulty " WS-DN " wave " WS-WN " bonus " WS-L-FLAG(WS-I) " type " WS-TN
                 " smallest and largest count" DELIMITED BY SIZE INTO TL-CASE
             COMPUTE TL-EXPECTED-N = WS-DEF * 100 + WS-DEF + WS-BON
             COMPUTE TL-OBSERVED-N = WS-MIN * 100 + WS-MAX
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         CALL "RAID-NUM-GROUPS" USING WS-D WS-COUNT
         MOVE WS-D TO WS-DN
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 20§20.3 number of waves at difficulty " WS-DN DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         IF WS-D > 0
             COMPUTE TL-EXPECTED-N = 2 * WS-D + 1
         END-IF
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-20-3.
 COPY CORETEST.
