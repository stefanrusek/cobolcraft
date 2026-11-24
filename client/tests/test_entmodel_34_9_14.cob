*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 14 (experience orb): getIcon from the value (the tiers read from the document), the uv rectangle of an icon in the 4 x 4 sheet, the colour of the quad
*> (integers r, g = 255, b, alpha 128, with the table sine of 34-9 section 2), the block light clamp(block + 7, 0, 15), the worked examples and Validation 6.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-PFX                 PIC X(100).
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
 PROCEDURE DIVISION.
     MOVE "acceptance US15 34-9§14 experience orb" TO WS-PFX
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 3" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 7" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 16" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 17 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 17" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 20 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 20" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 36 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 36" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 37 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 37" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 72 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 72" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 73 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 73" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 148 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 148" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 149 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 149" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 306 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 306" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 307 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 307" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 616 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 616" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 617 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 617" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1236 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 1236" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1237 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 1237" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2476 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 2476" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2477 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 2477" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100000 TO WS-IV(1)
     CALL "EF9-ORB-ICON" USING WS-IN WS-OUT
     MOVE "14 icon of value 100000" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 0 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 0 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 0 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 0 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 1 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 1 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 1 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 1 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 2 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 2 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 2 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 2 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 3 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 3 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 3 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 3 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 4 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 4 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 4 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 4 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 5 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 5 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 5 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 5 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 6 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 6 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 6 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 6 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 7 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 7 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 7 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 7 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 8 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 8 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 8 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 8 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 9 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 9 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 9 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 9 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-ORB-UV" USING WS-IN WS-OUT
     MOVE "14 uv of icon 10 (u0, u1, v0, v1) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 10 (u0, u1, v0, v1) [2]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 10 (u0, u1, v0, v1) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 uv of icon 10 (u0, u1, v0, v1) [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 0 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 0 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 0 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 0 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 1 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 188 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 2.5 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 248 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 2.5 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 2.5 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 2.5 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6.2831854 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 6.2831854 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 6.2831854 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 6.2831854 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 47 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 6.2831854 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 10 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 10 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 10 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 31 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 10 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 57.3 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 57.3 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 57.3 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 57.3 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 50 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 57.3 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 123.4 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 123.4 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 123.4 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 123.4 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 27 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 123.4 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1000 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 colour at ageInTicks 1000 (r, g, b, alpha) [1]" TO WS-NAME
     MOVE 67 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1000 (r, g, b, alpha) [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1000 (r, g, b, alpha) [3]" TO WS-NAME
     MOVE 50 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 colour at ageInTicks 1000 (r, g, b, alpha) [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 worked example: age 0 gives r 127, b 3 [1]" TO WS-NAME
     MOVE 127 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: age 0 gives r 127, b 3 [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: age 0 gives r 127, b 3 [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: age 0 gives r 127, b 3 [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.1415927 TO WS-IV(1)
     CALL "EF9-ORB-COLOR" USING WS-IN WS-OUT
     MOVE "14 worked example: t = pi / 2 gives r 255, b 12 [1]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: t = pi / 2 gives r 255, b 12 [2]" TO WS-NAME
     MOVE 255 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: t = pi / 2 gives r 255, b 12 [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "14 worked example: t = pi / 2 gives r 255, b 12 [4]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-IN WS-OUT
     MOVE "14 block light 0" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-IN WS-OUT
     MOVE "14 block light 3" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-IN WS-OUT
     MOVE "14 block light 8" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-IN WS-OUT
     MOVE "14 block light 9" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF9-ORB-LIGHT" USING WS-IN WS-OUT
     MOVE "14 block light 15" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-14.
