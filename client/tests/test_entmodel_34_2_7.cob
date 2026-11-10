*> Parents are asserted where the documents state them (34-2 section 7 and 34-1 6.3); the others are left blank.
*> Acceptance test of docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md section 7 (Render state fields): the field list of each state class
*> of the scope in the document's order, their defaults, and the inheritance chain.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-2-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-STATE               PIC X(32).
 01 WS-FIELDS              PIC X(400).
 01 WS-PARENT              PIC X(24).
 01 WS-PARENT-OUT          PIC X(24).
 01 WS-COUNT               BINARY-LONG.
 01 WS-FIELD               PIC X(32).
 01 WS-DEFAULT             PIC X(16).
 PROCEDURE DIVISION.
     MOVE "HumanoidRenderState" TO WS-STATE
     MOVE "swimAmount,speedValue,maxCrossbowChargeDuration,ticksUsingItem,useItemHand,isCrouching,isFallFlying,isVisuallySwimming,isPassenger,isUsingItem,elytraRotX,elytraRotY,elytraRotZ,headEquipment,chestEquipment,legsEquipment,feetEquipment" TO TL-EXPECTED
     MOVE "ArmedEntityRenderState" TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "ArmedEntityRenderState" TO WS-STATE
     MOVE "mainArm,rightArmPose,leftArmPose,rightHandItemState,rightHandItemStack,leftHandItemState,leftHandItemStack,currentSwing,swingAnimation" TO TL-EXPECTED
     MOVE "LivingEntityRenderState" TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "UndeadRenderState" TO WS-STATE
     MOVE SPACES TO TL-EXPECTED
     MOVE "HumanoidRenderState" TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "ZombieRenderState" TO WS-STATE
     MOVE "isAggressive,isConverting" TO TL-EXPECTED
     MOVE "UndeadRenderState" TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "SkeletonRenderState" TO WS-STATE
     MOVE "isAggressive,isShaking,isHoldingBow" TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "BoggedRenderState" TO WS-STATE
     MOVE "isSheared" TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "ZombifiedPiglinRenderState" TO WS-STATE
     MOVE "isAggressive" TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "PiglinRenderState" TO WS-STATE
     MOVE "isBrute,isConverting,maxCrossbowChageDuration,armPose" TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "ArmorStandRenderState" TO WS-STATE
     MOVE "yRot,wiggle,isMarker,isSmall,showArms,showBasePlate,headPose,bodyPose,leftArmPose,rightArmPose,leftLegPose,rightLegPose" TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     MOVE "NoSuchState" TO WS-STATE
     MOVE SPACES TO TL-EXPECTED
     MOVE SPACES TO WS-PARENT
     PERFORM CHECK-STATE
     CALL "EMD-STATE-COUNT" USING WS-COUNT
     MOVE "N" TO TL-MODE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§7 Render state fields: nine state classes are described" DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   defaults
     MOVE "speedValue" TO WS-FIELD
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "useItemHand" TO WS-FIELD
     MOVE "main hand" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "mainArm" TO WS-FIELD
     MOVE "right" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "rightArmPose" TO WS-FIELD
     MOVE "EMPTY" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "leftArmPose" TO WS-FIELD
     MOVE "EMPTY" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "armPose" TO WS-FIELD
     MOVE "DEFAULT" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "headEquipment" TO WS-FIELD
     MOVE "empty" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "isAggressive" TO WS-FIELD
     MOVE "false" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "isConverting" TO WS-FIELD
     MOVE "false" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "isBrute" TO WS-FIELD
     MOVE "false" TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     MOVE "wiggle" TO WS-FIELD
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK-DEFAULT
     STOP RUN.

 CHECK-STATE.
     CALL "EMD-STATE-FIELDS" USING WS-STATE WS-FIELDS WS-PARENT-OUT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§7 Render state fields: fields of " FUNCTION TRIM(WS-STATE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-FIELDS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§7 Render state fields: parent of " FUNCTION TRIM(WS-STATE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-PARENT TO TL-EXPECTED
     MOVE WS-PARENT-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-DEFAULT.
     CALL "EMD-STATE-DEFAULT" USING WS-FIELD WS-DEFAULT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§7 Render state fields: default of " FUNCTION TRIM(WS-FIELD) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-DEFAULT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-2-7.
