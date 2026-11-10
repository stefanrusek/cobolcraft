*> Acceptance test of docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md section 2 (Renderer pipeline of these mobs): 2.1 shadow radius and
*> the ghost draw, 2.2 setupRotations overrides (isShaking by family, the armor stand wiggle, the drowned swim), 2.3 body rotation riding a living mount and
*> the walk state while riding or dead.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-2-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-I                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-TYPE                PIC X(24).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Y                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 PROCEDURE DIVISION.
*> 2.1 shadow radius = renderer constant x scale, and for MobRenderer x ageScale; giant 0.5 x 6 = 3.0; armor stand 0
     MOVE "zombie" TO WS-TYPE
     MOVE 1 TO WS-I(1) WS-I(2)
     MOVE 0 TO WS-I(3)
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "adult zombie shadow 0.5" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-I(2)
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "baby zombie shadow 0.25" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-I(1)
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "scale 2 baby gives 0.5" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "giant" TO WS-TYPE
     MOVE 1 TO WS-I(1) WS-I(2)
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "giant shadow 0.5 x 6 = 3.0" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "armor_stand" TO WS-TYPE
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "armor stand has no shadow" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "piglin" TO WS-TYPE
     MOVE 1 TO WS-I(1)
     MOVE 0.5 TO WS-I(2)
     CALL "EMD-SHADOW" USING WS-TYPE WS-IN WS-OUT
     MOVE "piglin baby shadow 0.25" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
*>   ghost draw (worked example 11): tint 0x26FFFFFF times white; the render type is entityTranslucentCull
     MOVE 654311423 TO WS-X
     MOVE -1 TO WS-Y
     CALL "EM6-COLOUR-MULTIPLY" USING WS-X WS-Y WS-Z
     MOVE "ghost tint 0x26FFFFFF" TO WS-NAME
     MOVE 654311423 TO WS-E
     MOVE WS-Z TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "EM6-TRANSLUCENT" USING WS-A WS-B WS-R
     MOVE 0 TO WS-C
     CALL "EM6-RENDER-TYPE" USING WS-A WS-R WS-C WS-R2
     MOVE "invisible zombie draws as the ghost (1)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-R2 TO WS-O
     PERFORM CHECK-NUM
*> 2.2 isShaking by family
     MOVE "zombie" TO WS-TYPE
     MOVE 0 TO WS-A WS-B WS-C
     PERFORM CHECK-SHAKING-0
     MOVE 1 TO WS-A
     MOVE "frozen zombie shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE "converting zombie shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "husk" TO WS-TYPE
     MOVE "converting husk shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "drowned" TO WS-TYPE
     MOVE "converting drowned shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "piglin" TO WS-TYPE
     MOVE "converting piglin shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "piglin_brute" TO WS-TYPE
     MOVE "converting brute shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "zombified_piglin" TO WS-TYPE
     MOVE "converting flag does not shake a zombified piglin" TO WS-NAME
     PERFORM CHECK-SHAKING-0
     MOVE 1 TO WS-A
     MOVE "frozen zombified piglin shakes" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "giant" TO WS-TYPE
     MOVE 0 TO WS-A
     MOVE "converting flag does not shake a giant" TO WS-NAME
     PERFORM CHECK-SHAKING-0
     MOVE "armor_stand" TO WS-TYPE
     MOVE "converting flag does not shake an armor stand" TO WS-NAME
     PERFORM CHECK-SHAKING-0
     MOVE "skeleton" TO WS-TYPE
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B WS-C
     MOVE "frozen alone does not shake a skeleton" TO WS-NAME
     PERFORM CHECK-SHAKING-0
     MOVE 1 TO WS-C
     MOVE "the state's isShaking shakes a skeleton" TO WS-NAME
     PERFORM CHECK-SHAKING-1
     MOVE "stray" TO WS-TYPE
     MOVE "stray shakes by the state flag" TO WS-NAME
     PERFORM CHECK-SHAKING-1
*>   armor stand: Y rotation (180 - bodyRot) then the wiggle when wiggle < 5
     MOVE 40 TO WS-I(1)
     MOVE 0 TO WS-I(2)
     CALL "EMD-ARMORSTAND-ROT" USING WS-IN WS-OUT
     MOVE "armor stand wiggle 0: two Y rotations 140 and 0" TO WS-NAME
     COMPUTE WS-O = WS-OV(1) * 1000000 + WS-OV(3) * 1000 + WS-OV(7)
     COMPUTE WS-E = 2 * 1000000 + 140 * 1000
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-I(2)
     CALL "EMD-ARMORSTAND-ROT" USING WS-IN WS-OUT
     MOVE "armor stand wiggle 2.5: sin(2.5 / 1.5 pi) x 3 = -2.598076" TO WS-NAME
     MOVE -2.598076 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-I(2)
     CALL "EMD-ARMORSTAND-ROT" USING WS-IN WS-OUT
     MOVE "armor stand wiggle 5 or more adds nothing" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
*>   drowned swim: rotate X by lerp(swim, 0, -10 - xRot) about (0, height / 2 / scale, 0)
     MOVE 0 TO WS-I(1)
     MOVE 20 TO WS-I(2)
     MOVE 1.95 TO WS-I(3)
     MOVE 1 TO WS-I(4)
     CALL "EMD-DROWNED-ROT" USING WS-IN WS-OUT
     MOVE "drowned with no swim adds no operation" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-I(1)
     CALL "EMD-DROWNED-ROT" USING WS-IN WS-OUT
     MOVE "drowned swimming: three operations" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "translate up by 0.975, rotate X -15, translate back" TO WS-NAME
     COMPUTE WS-O = WS-OV(4) * 1000 + WS-OV(7) * 10 + WS-OV(12)
     COMPUTE WS-E = 975 + -150 + -0.975
     PERFORM CHECK-NUM
     MOVE "the rotation is about X (kind 5)" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
*> 2.3 body rotation riding a living mount: d = clamp(wrap(head - mount body), -85, 85), body = head - d, plus d x 0.2 when |d| > 50
     MOVE 1 TO WS-I(1)
     MOVE 0 TO WS-I(2)
     MOVE 30 TO WS-I(3) WS-I(4)
     MOVE 100 TO WS-I(5)
     CALL "EM6-SOLVE-BODY" USING WS-IN WS-OUT
     MOVE "riding: d = 70, body = 30 + 14 = 44" TO WS-NAME
     MOVE 44 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
*>   walk position and speed are zero while riding or dead
     MOVE 1 TO WS-I(1)
     MOVE 1 TO WS-I(2)
     MOVE 3.5 TO WS-I(3)
     MOVE 0.8 TO WS-I(4)
     CALL "EMD-WALK-STATE" USING WS-IN WS-OUT
     MOVE "riding: walk state zero" TO WS-NAME
     COMPUTE WS-O = WS-OV(1) + WS-OV(2)
     MOVE 0 TO WS-E
     PERFORM CHECK-NUM
     MOVE 0 TO WS-I(1)
     MOVE 0 TO WS-I(2)
     CALL "EMD-WALK-STATE" USING WS-IN WS-OUT
     MOVE "dead: walk state zero" TO WS-NAME
     COMPUTE WS-O = WS-OV(1) + WS-OV(2)
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I(2)
     CALL "EMD-WALK-STATE" USING WS-IN WS-OUT
     MOVE "alive and not riding: walk position and speed kept" TO WS-NAME
     COMPUTE WS-O = WS-OV(1) * 10 + WS-OV(2)
     COMPUTE WS-E = 35 + 0.8
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-SHAKING-0.
     MOVE 0 TO WS-E
     PERFORM CHECK-SHAKING.

 CHECK-SHAKING-1.
     MOVE 1 TO WS-E
     PERFORM CHECK-SHAKING.

 CHECK-SHAKING.
     CALL "EMD-SHAKING" USING WS-TYPE WS-A WS-B WS-C WS-R
     IF WS-NAME = SPACES
         STRING "shaking of " FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO WS-NAME
     END-IF
     MOVE WS-R TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-NAME.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§2 Renderer pipeline of these mobs: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-2-2.
