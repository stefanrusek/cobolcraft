*> Implementation test of the environment atlas size (CC-0003; ENVIRONMENT-ATLAS-BUILD): rain and snow images of
*> co-prime heights give a bounded atlas. Heights 17 and 19: the least common multiple, 323 rows, each image
*> repeated down its columns (row 322 of the first is image row 322 mod 17 = 16). Heights 1000 and 999 (a least
*> common multiple of 999,000 rows, over the 4096 bound): both images are stretched to 1000 rows by nearest
*> neighbour and the atlas is 1000 rows.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WEATHER-ATLAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-weather-atlas".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-NAMES               PIC X(256) VALUE "weather weather2".
 01 WS-IDS                 PIC X(256) VALUE "file/weather".
 01 WS-IDS2                PIC X(256) VALUE "file/weather2".
 01 WS-E1                  PIC Z(5)9.
 01 WS-E2                  PIC Z(5)9.
 01 WS-E3                  PIC Z(5)9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE XA-W TO WS-E1
     MOVE XA-H TO WS-E2
     MOVE "weather atlas heights 17 and 19 give 323 rows (their least common multiple), 32 wide" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "32x323" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS2
     MOVE XA-W TO WS-E1
     MOVE XA-H TO WS-E2
     MOVE XA-IM-H(1) TO WS-E3
     MOVE "weather atlas heights 1000 and 999 (lcm over the bound) are both stretched to 1000 rows: the "
         & "atlas is 32 x 1000 and the first image keeps 1000" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "32x1000 1000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE XA-IM-H(2) TO WS-E3
     MOVE "weather atlas the second image's recorded height is the stretched 1000" TO TL-CASE
     MOVE FUNCTION TRIM(WS-E3) TO TL-OBSERVED
     MOVE "1000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WEATHER-ATLAS.
 COPY CLTEST.
 COPY PACKTEST.
