*> Acceptance test of US2-4 / SC-004 on the client (docs/protocol/08-resource-packs.md §10.3, §10.10;
*> standin-content §1.4, §18): every built-in block texture and the font atlas, read from the pack
*> stack holding only the built-in pack, equal the reference RGBA of
*> client/tests/fixtures/textures/<name>.rgba (written by the independent Python generator)
*> pixel for pixel, with the stand-in size.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-TEXTURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-NAMES.
    05 FILLER PIC X(32) VALUE "block/baseplate".
    05 FILLER PIC X(32) VALUE "block/greystone".
    05 FILLER PIC X(32) VALUE "block/loam".
    05 FILLER PIC X(32) VALUE "block/turf_top".
    05 FILLER PIC X(32) VALUE "block/turf_side".
    05 FILLER PIC X(32) VALUE "block/grit".
    05 FILLER PIC X(32) VALUE "block/cardstack_end".
    05 FILLER PIC X(32) VALUE "block/cardstack_side".
    05 FILLER PIC X(32) VALUE "block/cardstack_side_punched".
    05 FILLER PIC X(32) VALUE "block/lucite".
    05 FILLER PIC X(32) VALUE "block/glowtube_lit".
    05 FILLER PIC X(32) VALUE "block/glowtube_unlit".
    05 FILLER PIC X(32) VALUE "block/ledger_tile".
    05 FILLER PIC X(32) VALUE "block/goto_pad".
    05 FILLER PIC X(32) VALUE "block/slag".
    05 FILLER PIC X(32) VALUE "font/ascii".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-FIXTURE             PIC X(256).
 01 WS-IMAGE               PIC X(65536).
 01 WS-REFERENCE           PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-STEM                PIC X(32).
 01 WS-EDIT                PIC Z(5)9.
 01 WS-EDIT2               PIC Z(5)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE SPACES TO WS-PATH WS-FIXTURE WS-STEM
         STRING "assets/cobolcraft/textures/" FUNCTION TRIM(WS-NAME(WS-I)) ".png"
             DELIMITED BY SIZE INTO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         UNSTRING WS-NAME(WS-I) DELIMITED BY "/" INTO WS-STEM WS-STEM
         STRING "client/tests/fixtures/textures/" FUNCTION TRIM(WS-STEM) ".rgba"
             DELIMITED BY SIZE INTO WS-FIXTURE
         MOVE LOW-VALUES TO WS-IMAGE
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-CAPACITY
             WS-W WS-H WS-FOUND
         CALL "TEST-READ-FILE" USING WS-FIXTURE WS-REFERENCE WS-CAPACITY WS-LENGTH
         MOVE 0 TO WS-DIFF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-LENGTH OR WS-DIFF > 0
             IF WS-IMAGE(WS-K:1) NOT = WS-REFERENCE(WS-K:1)
                 MOVE WS-K TO WS-DIFF
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "acceptance US2-4 SC-004 given only the built-in pack when "
             FUNCTION TRIM(WS-PATH) " is read then it equals the reference "
             FUNCTION TRIM(WS-STEM) ".rgba pixel for pixel" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         COMPUTE WS-EDIT = WS-LENGTH / 4
         STRING "found, " FUNCTION TRIM(WS-EDIT) " pixels equal" DELIMITED BY SIZE
             INTO TL-EXPECTED
         COMPUTE WS-EDIT2 = WS-W * WS-H
         EVALUATE TRUE
             WHEN WS-FOUND NOT = 1
                 MOVE "not found" TO TL-OBSERVED
             WHEN WS-W * WS-H * 4 NOT = WS-LENGTH
                 STRING "size " FUNCTION TRIM(WS-EDIT2) " pixels" DELIMITED BY SIZE
                     INTO TL-OBSERVED
             WHEN WS-DIFF > 0
                 COMPUTE WS-EDIT2 = (WS-DIFF - 1) / 4
                 STRING "pixel " FUNCTION TRIM(WS-EDIT2) " differs" DELIMITED BY SIZE
                     INTO TL-OBSERVED
             WHEN OTHER
                 MOVE TL-EXPECTED TO TL-OBSERVED
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-US2-TEXTURES.
 COPY CLTEST.
