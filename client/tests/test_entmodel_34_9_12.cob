*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 12 (lead knot): the one part model (texture 32 x 32, cuboid (-3, -8, -3) size 6 x 8 x 6), the submit (scale (-1, -1, 1), no shadow) and the texture path.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-X60               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "LEASH_KNOT" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LEASH_KNOT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§12 Lead knot 12 LEASH_KNOT" TO CK-PREFIX
     MOVE "P knot root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C knot 0 0 -3 -8 -3 6 8 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "12 LEASH_KNOT: parts below the root" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 LEASH_KNOT: cuboids" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 LEASH_KNOT: texture width" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 LEASH_KNOT: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-KNOT-OPS" USING WS-IN WS-OUT
     MOVE "12 submit ops (count, scale code, -1, -1, 1) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 submit ops (count, scale code, -1, -1, 1) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 submit ops (count, scale code, -1, -1, 1) [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 submit ops (count, scale code, -1, -1, 1) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12 submit ops (count, scale code, -1, -1, 1) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X60
     CALL "EF9-KNOT-TEXTURE" USING WS-IN WS-X60
     MOVE "12 texture" TO WS-NAME
     MOVE "entity/lead_knot/lead_knot.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "NO_SUCH_LAYER" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "12 a layer that is not of this part is not known" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§12 Lead knot: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§12 Lead knot: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-12.
