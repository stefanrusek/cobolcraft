*> Test of the saved map data and the map components (core/src/maps.cob; docs/protocol/25-item-registry-5 sections 8.1, 8.2 and 10 example 7, 54 section 26.1; lane p70c, T23501): createFresh's centre and
*> counter, scaled() from the old centre (clamped at scale 4), locked(), a missing id, a full store, and the components map_id (48), map_post_processing (50) and dropping one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MAPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-ID                  BINARY-LONG.
 01 WS-ID2                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SCALE               BINARY-LONG.
 01 WS-LOCKED              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-T50                 BINARY-LONG VALUE 50.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "T" TO TL-MODE

     MOVE "test maps createFresh: (1000, -200) at scale 1 is map 0 centred on (1088, -192), unlocked, in dimension 1 (25-5 example 7)" TO TL-CASE
     MOVE 1000 TO WS-X
     MOVE -200 TO WS-Z
     MOVE 1 TO WS-SCALE
     CALL "MAP-NEW" USING WS-DIM WS-X WS-Z WS-SCALE WS-ID
     PERFORM SHOW

     MOVE "test maps scaled(): the map around the old centre at scale 2 is map 1 centred on (1216, -320), the source is unchanged" TO TL-CASE
     MOVE 1 TO WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     MOVE WS-ID2 TO WS-E6
     CALL "MAP-FIND" USING WS-ID2 WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-SCALE TO WS-E1
     MOVE WS-CX TO WS-E2
     MOVE WS-CZ TO WS-E3
     MOVE WS-LOCKED TO WS-E4
     CALL "MAP-FIND" USING WS-ID WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-SCALE TO WS-E5
     STRING "id " FUNCTION TRIM(WS-E6) " scale " FUNCTION TRIM(WS-E1) " centre " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         " locked " FUNCTION TRIM(WS-E4) " source-scale " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "id 1 scale 2 centre 1216 -320 locked 0 source-scale 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test maps locked(): a copy with the same scale and centre is map 2 and locked" TO TL-CASE
     MOVE 2 TO WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     PERFORM SHOW-ID2

     MOVE "test maps scaled() stops at scale 4: a map of scale 4 scaled again keeps scale 4" TO TL-CASE
     MOVE 0 TO WS-X WS-Z
     MOVE 4 TO WS-SCALE
     CALL "MAP-NEW" USING WS-DIM WS-X WS-Z WS-SCALE WS-ID
     MOVE 1 TO WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     CALL "MAP-FIND" USING WS-ID2 WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-SCALE TO WS-E1
     STRING "scale " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "scale 4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test maps a missing id: find says not found and deriving gives -1" TO TL-CASE
     MOVE 9999 TO WS-ID
     CALL "MAP-FIND" USING WS-ID WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-FOUND TO WS-E1
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     MOVE WS-ID2 TO WS-E2
     STRING "found " FUNCTION TRIM(WS-E1) " derived " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "found 0 derived -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test maps a full store of 256 maps gives id -1 for a new one and for a derived one" TO TL-CASE
     MOVE 0 TO WS-X WS-Z WS-SCALE
     MOVE 0 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         CALL "MAP-NEW" USING WS-DIM WS-X WS-Z WS-SCALE WS-LAST
     END-PERFORM
     MOVE WS-LAST TO WS-E1
     MOVE 1 TO WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     MOVE WS-ID2 TO WS-E2
     MOVE 2 TO WS-MODE
     CALL "MAP-DERIVE" USING WS-ID WS-MODE WS-ID2
     MOVE WS-ID2 TO WS-E3
     STRING "new " FUNCTION TRIM(WS-E1) " scaled " FUNCTION TRIM(WS-E2) " locked " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "new -1 scaled -1 locked -1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test maps components: map_id and map_post_processing are VarInts, absent on a plain stack, and a dropped component leaves the other" TO TL-CASE
     MOVE 0 TO WS-H
     CALL "SC-MAPID-GET" USING WS-H WS-ID WS-HAS
     MOVE WS-HAS TO WS-E1
     CALL "SC-MAPPOST-GET" USING WS-H WS-MODE
     MOVE WS-MODE TO WS-E2
     MOVE 300 TO WS-ID
     CALL "SC-MAPID-SET" USING WS-H WS-ID
     MOVE 1 TO WS-MODE
     CALL "SC-MAPPOST-SET" USING WS-H WS-MODE
     CALL "SC-MAPPOST-GET" USING WS-H WS-MODE
     MOVE WS-MODE TO WS-E3
     CALL "SC-COMP-DROP" USING WS-H WS-T50
     CALL "SC-MAPPOST-GET" USING WS-H WS-MODE
     MOVE WS-MODE TO WS-E4
     MOVE 0 TO WS-ID
     CALL "SC-MAPID-GET" USING WS-H WS-ID WS-HAS
     MOVE WS-ID TO WS-E5
     MOVE WS-HAS TO WS-E6
     STRING "plain " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " post " FUNCTION TRIM(WS-E3) " dropped " FUNCTION TRIM(WS-E4)
         " id " FUNCTION TRIM(WS-E5) " has " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "plain 0 -1 post 1 dropped -1 id 300 has 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SHOW.
     MOVE WS-ID TO WS-E6
     CALL "MAP-FIND" USING WS-ID WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-SCALE TO WS-E1
     MOVE WS-CX TO WS-E2
     MOVE WS-CZ TO WS-E3
     MOVE WS-LOCKED TO WS-E4
     MOVE WS-D TO WS-E5
     STRING "id " FUNCTION TRIM(WS-E6) " scale " FUNCTION TRIM(WS-E1) " centre " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         " locked " FUNCTION TRIM(WS-E4) " dim " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "id 0 scale 1 centre 1088 -192 locked 0 dim 1" TO TL-EXPECTED
     PERFORM CHECK.

 SHOW-ID2.
     MOVE WS-ID2 TO WS-E6
     CALL "MAP-FIND" USING WS-ID2 WS-SCALE WS-LOCKED WS-CX WS-CZ WS-D WS-FOUND
     MOVE WS-SCALE TO WS-E1
     MOVE WS-CX TO WS-E2
     MOVE WS-CZ TO WS-E3
     MOVE WS-LOCKED TO WS-E4
     STRING "id " FUNCTION TRIM(WS-E6) " scale " FUNCTION TRIM(WS-E1) " centre " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         " locked " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "id 2 scale 1 centre 1088 -192 locked 1" TO TL-EXPECTED
     PERFORM CHECK.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED.
 END PROGRAM TEST-MAPS.
 COPY CORETEST.
