*> Acceptance test of docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md section 6 (State values): extractHumanoidRenderState's speed value
*> (fall flying: the cube of |velocity|^2 / 0.2, at least 1), the item use arm rule, and the PiglinArmPose order of evaluation for piglins and brutes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-2-6.
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
 01 WS-DANCE               BINARY-LONG.
 01 WS-LOVED               BINARY-LONG.
 01 WS-AGGR                BINARY-LONG.
 01 WS-MELEE               BINARY-LONG.
 01 WS-CHARGING            BINARY-LONG.
 01 WS-CHARGED             BINARY-LONG.
 01 WS-BRUTE               BINARY-LONG.
 01 WS-POSE                BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-PNAME               PIC X(32).
 01 WS-ARM                 BINARY-LONG.
 01 WS-USING               BINARY-LONG.
 01 WS-HAND-ARM            BINARY-LONG.
 01 WS-TICKS               FLOAT-LONG.
 01 WS-RES                 FLOAT-LONG.
 PROCEDURE DIVISION.
*> speed value
     MOVE 0 TO WS-I(1)
     MOVE 5 TO WS-I(2)
     CALL "EM6-SPEED-VALUE" USING WS-IN WS-OUT
     MOVE "not fall flying: speed value 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-I(1)
     MOVE 0.1 TO WS-I(2)
     CALL "EM6-SPEED-VALUE" USING WS-IN WS-OUT
     MOVE "fall flying slowly: below 1 becomes 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.4 TO WS-I(2)
     CALL "EM6-SPEED-VALUE" USING WS-IN WS-OUT
     MOVE "fall flying at 0.4: v = 2, cubed 8" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
*> the use arm of a humanoid: ticksUsingItem(arm) is the ticks only when the entity uses an item with the hand mapping to that arm
     MOVE 1 TO WS-ARM
     MOVE 1 TO WS-USING
     MOVE 1 TO WS-HAND-ARM
     MOVE 12 TO WS-TICKS
     CALL "EMD-TICKS-USING" USING WS-ARM WS-USING WS-HAND-ARM WS-TICKS WS-RES
     MOVE "using with the right hand: the right arm has the ticks" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-ARM
     CALL "EMD-TICKS-USING" USING WS-ARM WS-USING WS-HAND-ARM WS-TICKS WS-RES
     MOVE "the left arm has none" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-ARM
     MOVE 0 TO WS-USING
     CALL "EMD-TICKS-USING" USING WS-ARM WS-USING WS-HAND-ARM WS-TICKS WS-RES
     MOVE "not using an item: zero" TO WS-NAME
     MOVE WS-RES TO WS-O
     PERFORM CHECK-NUM
*> PiglinArmPose: dancing, loved item in the off hand, melee, charging, charged crossbow, default
     MOVE 0 TO WS-DANCE WS-LOVED WS-AGGR WS-MELEE WS-CHARGING WS-CHARGED WS-BRUTE
     MOVE 5 TO WS-E
     MOVE "nothing set: DEFAULT" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 1 TO WS-DANCE WS-LOVED WS-AGGR WS-MELEE WS-CHARGING WS-CHARGED
     MOVE 4 TO WS-E
     MOVE "dancing wins over everything: DANCING" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 0 TO WS-DANCE
     MOVE 3 TO WS-E
     MOVE "a loved item in the off hand: ADMIRING_ITEM" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 0 TO WS-LOVED
     MOVE 0 TO WS-E
     MOVE "aggressive with a melee weapon: ATTACKING_WITH_MELEE_WEAPON" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 0 TO WS-MELEE
     MOVE 2 TO WS-E
     MOVE "charging flag: CROSSBOW_CHARGE" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 0 TO WS-CHARGING
     MOVE 1 TO WS-E
     MOVE "a charged crossbow: CROSSBOW_HOLD" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 0 TO WS-AGGR WS-CHARGED
     MOVE 1 TO WS-MELEE
     MOVE 5 TO WS-E
     MOVE "a melee weapon without aggression: DEFAULT" TO WS-NAME
     PERFORM CHECK-POSE
*>   the brute: aggressive and melee gives ATTACKING, else DEFAULT whatever the other flags
     MOVE 1 TO WS-BRUTE
     MOVE 1 TO WS-DANCE WS-LOVED WS-CHARGING WS-CHARGED
     MOVE 5 TO WS-E
     MOVE "brute ignores dancing, loved items and crossbows: DEFAULT" TO WS-NAME
     PERFORM CHECK-POSE
     MOVE 1 TO WS-AGGR
     MOVE 0 TO WS-E
     MOVE "aggressive brute with a melee weapon: ATTACKING_WITH_MELEE_WEAPON" TO WS-NAME
     PERFORM CHECK-POSE
*>   the enum order and names
     MOVE 0 TO WS-ORD
     PERFORM CHECK-ENUM-0
     MOVE 5 TO WS-ORD
     MOVE "DEFAULT" TO TL-EXPECTED
     MOVE "enum value 5 is DEFAULT" TO WS-NAME
     PERFORM CHECK-ENUM
     MOVE 4 TO WS-ORD
     MOVE "DANCING" TO TL-EXPECTED
     MOVE "enum value 4 is DANCING" TO WS-NAME
     PERFORM CHECK-ENUM
     MOVE 3 TO WS-ORD
     MOVE "ADMIRING_ITEM" TO TL-EXPECTED
     MOVE "enum value 3 is ADMIRING_ITEM" TO WS-NAME
     PERFORM CHECK-ENUM
     MOVE 2 TO WS-ORD
     MOVE "CROSSBOW_CHARGE" TO TL-EXPECTED
     MOVE "enum value 2 is CROSSBOW_CHARGE" TO WS-NAME
     PERFORM CHECK-ENUM
     MOVE 1 TO WS-ORD
     MOVE "CROSSBOW_HOLD" TO TL-EXPECTED
     MOVE "enum value 1 is CROSSBOW_HOLD" TO WS-NAME
     PERFORM CHECK-ENUM
     MOVE 6 TO WS-ORD
     MOVE SPACES TO TL-EXPECTED
     MOVE "there is no seventh value" TO WS-NAME
     PERFORM CHECK-ENUM
     STOP RUN.

 CHECK-ENUM-0.
     MOVE "ATTACKING_WITH_MELEE_WEAPON" TO TL-EXPECTED
     MOVE "enum value 0 is ATTACKING_WITH_MELEE_WEAPON" TO WS-NAME
     PERFORM CHECK-ENUM.

 CHECK-ENUM.
     CALL "EMD-PIGLIN-POSE-NAME" USING WS-ORD WS-PNAME
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§6 State values: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-PNAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-POSE.
     CALL "EMD-PIGLIN-POSE-OF" USING WS-DANCE WS-LOVED WS-AGGR WS-MELEE WS-CHARGING WS-CHARGED WS-BRUTE WS-POSE
     MOVE WS-POSE TO WS-O
     PERFORM CHECK-NUM.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§6 State values: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-2-6.
