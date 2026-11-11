*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 0 (how this document relates to part 1 and part 3): 0.1 the scaling arithmetic (root offset and scale
*> of one and of several MeshTransformer.scaling steps, the pivot of a part, the fixed line y = 24.016) and the baby-model choice of the renderers (AgeableMobRenderer or the three that are not).
*> Values are worked by an independent script from the formulas of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-0.
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

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1.1 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 1.1 (horse)" TO WS-NAME
     MOVE -2.4016 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 1.1 (horse)" TO WS-NAME
     MOVE 1.1 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0.87 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 0.87 (donkey)" TO WS-NAME
     MOVE 3.12208 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 0.87 (donkey)" TO WS-NAME
     MOVE 0.87 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 4 (happy ghast)" TO WS-NAME
     MOVE -72.048 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 4 (happy ghast)" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE 0.2375 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 4 then 0.2375 (baby ghast)" TO WS-NAME
     MOVE 1.2008 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 4 then 0.2375 (baby ghast)" TO WS-NAME
     MOVE 0.95 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE 0.2375 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE 0.2375 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 4, 0.2375, 0.2375 (baby harness)" TO WS-NAME
     MOVE 18.59739 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 4, 0.2375, 0.2375 (baby harness)" TO WS-NAME
     MOVE 0.225625 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0.92 TO WS-IV(3)
     CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT
     MOVE WS-OV(1) TO WS-IV(1)
     MOVE WS-OV(2) TO WS-IV(2)
     MOVE "0.1 root offset after scaling 0.92 (mule)" TO WS-NAME
     MOVE 1.92128 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 root scale after scaling 0.92 (mule)" TO WS-NAME
     MOVE 0.92 TO WS-E
     MOVE WS-IV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 11 TO WS-IV(1)
     MOVE 1.1 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=11 scaled by 1.1" TO WS-NAME
     MOVE 9.6984 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1.1 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=4 scaled by 1.1" TO WS-NAME
     MOVE 1.9984 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24.016 TO WS-IV(1)
     MOVE 1.1 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=24.016 scaled by 1.1" TO WS-NAME
     MOVE 24.016 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24.016 TO WS-IV(1)
     MOVE 0.87 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=24.016 scaled by 0.87" TO WS-NAME
     MOVE 24.016 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=0 scaled by 4" TO WS-NAME
     MOVE -72.048 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 pivot y=16 scaled by 4" TO WS-NAME
     MOVE -8.048 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24.016 TO WS-IV(1)
     MOVE 0.37 TO WS-IV(2)
     CALL "EF4-SCALE-PIVOT" USING WS-IN WS-OUT
     MOVE "0.1 the line y = 24.016 is a fixed point (any scale)" TO WS-NAME
     MOVE 24.016 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cow" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 cow extends AgeableMobRenderer" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 pig extends AgeableMobRenderer" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "chicken" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 chicken extends AgeableMobRenderer" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "mooshroom" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 mooshroom extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "sheep" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 sheep extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "goat" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 goat extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 horse extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 donkey extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "mule" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 mule extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 skeleton_horse extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_horse" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 zombie_horse extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "llama" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 llama extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "trader_llama" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 trader_llama extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 camel extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "camel_husk" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 camel_husk extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "happy_ghast" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 happy_ghast extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     MOVE "rabbit" TO WS-X24
     CALL "EF4-AGEABLE" USING WS-X24 WS-FL
     MOVE "0.2 rabbit extends AgeableMobRenderer" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FL TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§0 How this document relates to part 1 and part 3: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§0 How this document relates to part 1 and part 3: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-0.
