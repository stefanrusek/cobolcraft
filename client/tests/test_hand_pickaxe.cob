*> T32301 (lane 002-lane-bugitems, operator try14 13.33.34: "tool in hand rendered wrong"): the first-person wooden pickaxe of the real generated vanilla pack
*> (CC_GENERATED_DIR; model chain wooden_pickaxe, handheld, generated) at rest: HAND-MESH holds the extruded sprite (08 section 5.7: front and back quad and
*> one quad for each side of an opaque texel next to a clear one, 74 quads, 444 vertices) posed by the arm transform and the model's firstperson_righthand
*> display (rotation 0 -90 25, translation 1.13 3.2 1.13, scale 0.68). The expected corners of the front quad and the quad count come from the independent script
*> client/tests/fixtures/gen_hand_flat.py (from the texture and the formulas of 12 section 6.3 and 8.2). The front quad (towards the camera at the origin)
*> is clockwise seen from the camera, the back quad is not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-PICKAXE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-B                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-EXPV.
    05 WS-EXPECT           FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE SPACES TO WS-KEY
     MOVE "wooden_pickaxe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
     COMPUTE CL-HAND-ITEM = WS-ITEM + 1
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE WS-ITEM TO PL-SLOT-ITEM(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "T32301 the wooden pickaxe in hand is 74 quads: front, back and 72 edges (444 vertices)" TO TL-CASE
     MOVE 444 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The front quad's top-left, top-right and bottom-right corners (independent script), in view space.
     MOVE 0.6094 TO WS-EXPECT(1) WS-EXPECT(4) WS-EXPECT(7)
     MOVE -0.1555 TO WS-EXPECT(2)
     MOVE -1.1012 TO WS-EXPECT(3)
     MOVE 0.1318 TO WS-EXPECT(5)
     MOVE -0.4849 TO WS-EXPECT(6)
     MOVE -0.4845 TO WS-EXPECT(8)
     MOVE -0.1975 TO WS-EXPECT(9)
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF FUNCTION ABS(RL-HAND-X(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 1)) > 0.002 OR FUNCTION ABS(RL-HAND-Y(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 2)) > 0.002
                 OR FUNCTION ABS(RL-HAND-Z(WS-I) - WS-EXPECT((WS-I - 1) * 3 + 3)) > 0.002
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE "T32301 the front quad's corners are where the arm transform and the handheld display put them (+-2 mm)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The front quad is clockwise seen from the camera at the origin: cross(v2 - v1, v3 - v2) . v1 > 0; the back quad (vertices 7 to 9) is not.
     PERFORM VARYING WS-I FROM 1 BY 6 UNTIL WS-I > 7
         COMPUTE WS-A(1) = RL-HAND-X(WS-I + 1) - RL-HAND-X(WS-I)
         COMPUTE WS-A(2) = RL-HAND-Y(WS-I + 1) - RL-HAND-Y(WS-I)
         COMPUTE WS-A(3) = RL-HAND-Z(WS-I + 1) - RL-HAND-Z(WS-I)
         COMPUTE WS-B(1) = RL-HAND-X(WS-I + 2) - RL-HAND-X(WS-I + 1)
         COMPUTE WS-B(2) = RL-HAND-Y(WS-I + 2) - RL-HAND-Y(WS-I + 1)
         COMPUTE WS-B(3) = RL-HAND-Z(WS-I + 2) - RL-HAND-Z(WS-I + 1)
         COMPUTE WS-DOT = (WS-A(2) * WS-B(3) - WS-A(3) * WS-B(2)) * RL-HAND-X(WS-I)
             + (WS-A(3) * WS-B(1) - WS-A(1) * WS-B(3)) * RL-HAND-Y(WS-I)
             + (WS-A(1) * WS-B(2) - WS-A(2) * WS-B(1)) * RL-HAND-Z(WS-I)
         MOVE 0 TO TL-OBSERVED-N
         IF WS-DOT > 0
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         MOVE "T32301 the front quad faces the camera (clockwise seen from it)" TO TL-CASE
         IF WS-I > 1
             MOVE "T32301 the back quad faces away from the camera" TO TL-CASE
             MOVE 0 TO TL-EXPECTED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-HAND-PICKAXE.

 COPY CLTEST.
