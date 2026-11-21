*> Entity models part 2 sections 6 and 7 (docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md): state values and render state fields.
*> Entry points for the integrator (inputs):
*>   EMD-TICKS-USING arm(1 right, 2 left) using-item hand-arm(1 right, 2 left) ticks result: HumanoidRenderState.ticksUsingItem(arm) (the ticks only when using an item with
*>     the hand that maps to that arm, else 0). The humanoid speed value is EM6-SPEED-VALUE of client/src/entmodel-34-1-render.cob.
*>   EMD-PIGLIN-POSE-OF dancing loved-item-off-hand aggressive melee-weapon charging crossbow-charged brute pose(out 0 to 5, the PiglinArmPose ordinal): the order of 6
*>     (a brute only knows melee and default); EMD-PIGLIN-POSE-NAME ordinal name(X(32)).
*>   EMD-STATE-FIELDS state(X(32)) fields(X(400), comma separated, in the document's order) parent(X(24), where the documents state it); EMD-STATE-COUNT n;
*>     EMD-STATE-DEFAULT field(X(32)) default(X(16), spaces when the document gives none).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-TICKS-USING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ARM                  BINARY-LONG.
 01 L-USING                BINARY-LONG.
 01 L-HAND-ARM             BINARY-LONG.
 01 L-TICKS                FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-ARM L-USING L-HAND-ARM L-TICKS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-USING NOT = 0 AND L-HAND-ARM = L-ARM
         MOVE L-TICKS TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM EMD-TICKS-USING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-PIGLIN-POSE-OF.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DANCE                BINARY-LONG.
 01 L-LOVED                BINARY-LONG.
 01 L-AGGR                 BINARY-LONG.
 01 L-MELEE                BINARY-LONG.
 01 L-CHARGING             BINARY-LONG.
 01 L-CHARGED              BINARY-LONG.
 01 L-BRUTE                BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DANCE L-LOVED L-AGGR L-MELEE L-CHARGING L-CHARGED L-BRUTE L-POSE.
     MOVE 5 TO L-POSE
     EVALUATE TRUE
         WHEN L-BRUTE NOT = 0 AND L-AGGR NOT = 0 AND L-MELEE NOT = 0
             MOVE 0 TO L-POSE
         WHEN L-BRUTE NOT = 0
             CONTINUE
         WHEN L-DANCE NOT = 0
             MOVE 4 TO L-POSE
         WHEN L-LOVED NOT = 0
             MOVE 3 TO L-POSE
         WHEN L-AGGR NOT = 0 AND L-MELEE NOT = 0
             MOVE 0 TO L-POSE
         WHEN L-CHARGING NOT = 0
             MOVE 2 TO L-POSE
         WHEN L-CHARGED NOT = 0
             MOVE 1 TO L-POSE
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-PIGLIN-POSE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-PIGLIN-POSE-NAME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-ORD L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-ORD
         WHEN 0 MOVE "ATTACKING_WITH_MELEE_WEAPON" TO L-NAME
         WHEN 1 MOVE "CROSSBOW_HOLD" TO L-NAME
         WHEN 2 MOVE "CROSSBOW_CHARGE" TO L-NAME
         WHEN 3 MOVE "ADMIRING_ITEM" TO L-NAME
         WHEN 4 MOVE "DANCING" TO L-NAME
         WHEN 5 MOVE "DEFAULT" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-PIGLIN-POSE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-STATE-FIELDS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                PIC X(32).
 01 L-FIELDS               PIC X(400).
 01 L-PARENT               PIC X(24).
 PROCEDURE DIVISION USING L-STATE L-FIELDS L-PARENT.
     MOVE SPACES TO L-FIELDS L-PARENT
     EVALUATE L-STATE
         WHEN "HumanoidRenderState"
             MOVE "swimAmount,speedValue,maxCrossbowChargeDuration,ticksUsingItem,useItemHand,isCrouching,isFallFlying,"
                 & "isVisuallySwimming,isPassenger,isUsingItem,elytraRotX,elytraRotY,elytraRotZ,headEquipment,chestEquipment,"
                 & "legsEquipment,feetEquipment" TO L-FIELDS
             MOVE "ArmedEntityRenderState" TO L-PARENT
         WHEN "ArmedEntityRenderState"
             MOVE "mainArm,rightArmPose,leftArmPose,rightHandItemState,rightHandItemStack,leftHandItemState,leftHandItemStack,"
                 & "currentSwing,swingAnimation" TO L-FIELDS
             MOVE "LivingEntityRenderState" TO L-PARENT
         WHEN "UndeadRenderState"
             MOVE "HumanoidRenderState" TO L-PARENT
         WHEN "ZombieRenderState"
             MOVE "isAggressive,isConverting" TO L-FIELDS
             MOVE "UndeadRenderState" TO L-PARENT
         WHEN "SkeletonRenderState"
             MOVE "isAggressive,isShaking,isHoldingBow" TO L-FIELDS
         WHEN "BoggedRenderState"
             MOVE "isSheared" TO L-FIELDS
         WHEN "ZombifiedPiglinRenderState"
             MOVE "isAggressive" TO L-FIELDS
         WHEN "PiglinRenderState"
             MOVE "isBrute,isConverting,maxCrossbowChageDuration,armPose" TO L-FIELDS
         WHEN "ArmorStandRenderState"
             MOVE "yRot,wiggle,isMarker,isSmall,showArms,showBasePlate,headPose,bodyPose,leftArmPose,rightArmPose,leftLegPose,"
                 & "rightLegPose" TO L-FIELDS
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-STATE-FIELDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-STATE-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N.
     MOVE 9 TO L-N
     GOBACK.
 END PROGRAM EMD-STATE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EMD-STATE-DEFAULT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIELD                PIC X(32).
 01 L-DEFAULT              PIC X(16).
 PROCEDURE DIVISION USING L-FIELD L-DEFAULT.
     MOVE SPACES TO L-DEFAULT
     EVALUATE L-FIELD
         WHEN "speedValue" MOVE "1" TO L-DEFAULT
         WHEN "useItemHand" MOVE "main hand" TO L-DEFAULT
         WHEN "mainArm" MOVE "right" TO L-DEFAULT
         WHEN "rightArmPose" WHEN "leftArmPose" MOVE "EMPTY" TO L-DEFAULT
         WHEN "armPose" MOVE "DEFAULT" TO L-DEFAULT
         WHEN "headEquipment" WHEN "chestEquipment" WHEN "legsEquipment" WHEN "feetEquipment" MOVE "empty" TO L-DEFAULT
         WHEN "isAggressive" WHEN "isConverting" WHEN "isShaking" WHEN "isHoldingBow" WHEN "isSheared" WHEN "isBrute"
             MOVE "false" TO L-DEFAULT
     END-EVALUATE
     GOBACK.
 END PROGRAM EMD-STATE-DEFAULT.
