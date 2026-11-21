*> T5301 (lane 002-lane-p70b): the first-person hand's view pose, off hand and use poses (12 section 6.1, 6.2, 6.3, 6.6; 53 section 15.2, 15.3; 17 section 4.1).
*> Expected matrices come from an independent script (4 x 4 matrices, right-handed rotations, each transform multiplied on the right) written from the formulas of the
*> docs: the translation, the image of the z axis and of the x axis of each pose. Cases: every use pose of 12 section 6.6 for both arms, the bob and sway of 53 section 15.2
*> and 15.3 (the worked example), the tick state (walk distance, bob amount, lagging angles, attack ticker), the attack-cooldown dip of the equip animation, an off hand
*> that is drawn mirrored on the left, the mainHand option, the eating pose of a mesh, and the cache of the mesh.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-POSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(200).
 01 WS-KIND                BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-EO                  FLOAT-LONG.
 01 WS-EL                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-EXPECTED.
    05 WS-EXP              FLOAT-LONG OCCURS 9 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-GOT.
    05 WS-G                FLOAT-LONG OCCURS 9 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-PART                FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-DELAY               FLOAT-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HID                 BINARY-LONG.
 01 WS-HYAW                FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
*>   The pose cases read every quad of the mesh: the back faces the hand pass drops (12 section 6.9) are kept here (test_hand_doc and test_hand_pickaxe test the culling).
     MOVE 1 TO CL-HAND-NOCULL
     MOVE "N" TO TL-MODE
*>   Every use pose, right and left: the arm transform of 12 section 6.3 step 1 or the pose of 6.6.
     MOVE "T5301 plain arm, right" TO WS-NAME
     MOVE 0 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.56000 TO WS-EXP(1)
     MOVE -0.67000 TO WS-EXP(2)
     MOVE -0.72000 TO WS-EXP(3)
     MOVE 0.00000 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 1.00000 TO WS-EXP(6)
     MOVE 1.00000 TO WS-EXP(7)
     MOVE 0.00000 TO WS-EXP(8)
     MOVE 0.00000 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 eating at 10 of 32 ticks, right" TO WS-NAME
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 10 TO WS-EL
     MOVE 32 TO WS-D
     MOVE -0.16111 TO WS-EXP(1)
     MOVE -0.59995 TO WS-EXP(2)
     MOVE -0.82011 TO WS-EXP(3)
     MOVE 0.98481 TO WS-EXP(4)
     MOVE -0.17363 TO WS-EXP(5)
     MOVE 0.00021 TO WS-EXP(6)
     MOVE 0.08698 TO WS-EXP(7)
     MOVE 0.49235 TO WS-EXP(8)
     MOVE -0.86604 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 eating just begun (t over 0.8 adds no bounce), right" TO WS-NAME
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.0 TO WS-E
     MOVE 1 TO WS-EL
     MOVE 32 TO WS-D
     MOVE 0.56000 TO WS-EXP(1)
     MOVE -0.52000 TO WS-EXP(2)
     MOVE -0.72000 TO WS-EXP(3)
     MOVE 0.00000 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 1.00000 TO WS-EXP(6)
     MOVE 1.00000 TO WS-EXP(7)
     MOVE 0.00000 TO WS-EXP(8)
     MOVE 0.00000 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 bow at 15 ticks, right" TO WS-NAME
     MOVE 2 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 15 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.29579 TO WS-EXP(1)
     MOVE -0.48299 TO WS-EXP(2)
     MOVE -0.54223 TO WS-EXP(3)
     MOVE -0.10861 TO WS-EXP(4)
     MOVE 0.37009 TO WS-EXP(5)
     MOVE 0.99256 TO WS-EXP(6)
     MOVE 1.02879 TO WS-EXP(7)
     MOVE -0.05712 TO WS-EXP(8)
     MOVE 0.26881 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 bow fully drawn, right" TO WS-NAME
     MOVE 2 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.0 TO WS-E
     MOVE 40 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.30470 TO WS-EXP(1)
     MOVE -0.32769 TO WS-EXP(2)
     MOVE -0.53136 TO WS-EXP(3)
     MOVE -0.07837 TO WS-EXP(4)
     MOVE 0.38038 TO WS-EXP(5)
     MOVE 1.03401 TO WS-EXP(6)
     MOVE 1.05903 TO WS-EXP(7)
     MOVE -0.04683 TO WS-EXP(8)
     MOVE 0.31026 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 crossbow charging, right" TO WS-NAME
     MOVE 3 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 8 TO WS-EL
     MOVE 25 TO WS-D
     MOVE 0.09163 TO WS-EXP(1)
     MOVE -0.76312 TO WS-EXP(2)
     MOVE -0.65822 TO WS-EXP(3)
     MOVE 0.38721 TO WS-EXP(4)
     MOVE 0.31302 TO WS-EXP(5)
     MOVE 0.89981 TO WS-EXP(6)
     MOVE 0.96957 TO WS-EXP(7)
     MOVE -0.18397 TO WS-EXP(8)
     MOVE -0.28925 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 trident charging, right" TO WS-NAME
     MOVE 4 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 6 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.11781 TO WS-EXP(1)
     MOVE 0.09692 TO WS-EXP(2)
     MOVE -0.57331 TO WS-EXP(3)
     MOVE -0.11923 TO WS-EXP(4)
     MOVE 0.91877 TO WS-EXP(5)
     MOVE 0.49663 TO WS-EXP(6)
     MOVE 1.01817 TO WS-EXP(7)
     MOVE 0.12123 TO WS-EXP(8)
     MOVE 0.23159 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 blocking with a sword, right" TO WS-NAME
     MOVE 5 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.41858 TO WS-EXP(1)
     MOVE -0.59000 TO WS-EXP(2)
     MOVE -0.57858 TO WS-EXP(3)
     MOVE 0.23115 TO WS-EXP(4)
     MOVE 0.95077 TO WS-EXP(5)
     MOVE -0.20643 TO WS-EXP(6)
     MOVE 0.20145 TO WS-EXP(7)
     MOVE -0.25435 TO WS-EXP(8)
     MOVE -0.94590 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 auto spin attack, right" TO WS-NAME
     MOVE 6 TO WS-KIND
     MOVE 1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE 0.16000 TO WS-EXP(1)
     MOVE 0.13000 TO WS-EXP(2)
     MOVE -0.42000 TO WS-EXP(3)
     MOVE 0.90631 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 0.42262 TO WS-EXP(6)
     MOVE 0.03683 TO WS-EXP(7)
     MOVE -0.99619 TO WS-EXP(8)
     MOVE -0.07899 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 plain arm, left" TO WS-NAME
     MOVE 0 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.56000 TO WS-EXP(1)
     MOVE -0.67000 TO WS-EXP(2)
     MOVE -0.72000 TO WS-EXP(3)
     MOVE 0.00000 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 1.00000 TO WS-EXP(6)
     MOVE 1.00000 TO WS-EXP(7)
     MOVE 0.00000 TO WS-EXP(8)
     MOVE 0.00000 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 eating at 10 of 32 ticks, left" TO WS-NAME
     MOVE 1 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 10 TO WS-EL
     MOVE 32 TO WS-D
     MOVE 0.16111 TO WS-EXP(1)
     MOVE -0.59995 TO WS-EXP(2)
     MOVE -0.82011 TO WS-EXP(3)
     MOVE -0.98481 TO WS-EXP(4)
     MOVE -0.17363 TO WS-EXP(5)
     MOVE 0.00021 TO WS-EXP(6)
     MOVE 0.08698 TO WS-EXP(7)
     MOVE -0.49235 TO WS-EXP(8)
     MOVE 0.86604 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 eating just begun (t over 0.8 adds no bounce), left" TO WS-NAME
     MOVE 1 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.0 TO WS-E
     MOVE 1 TO WS-EL
     MOVE 32 TO WS-D
     MOVE -0.56000 TO WS-EXP(1)
     MOVE -0.52000 TO WS-EXP(2)
     MOVE -0.72000 TO WS-EXP(3)
     MOVE 0.00000 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 1.00000 TO WS-EXP(6)
     MOVE 1.00000 TO WS-EXP(7)
     MOVE 0.00000 TO WS-EXP(8)
     MOVE 0.00000 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 bow at 15 ticks, left" TO WS-NAME
     MOVE 2 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 15 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.29579 TO WS-EXP(1)
     MOVE -0.48299 TO WS-EXP(2)
     MOVE -0.54223 TO WS-EXP(3)
     MOVE 0.10861 TO WS-EXP(4)
     MOVE 0.37009 TO WS-EXP(5)
     MOVE 0.99256 TO WS-EXP(6)
     MOVE 1.02879 TO WS-EXP(7)
     MOVE 0.05712 TO WS-EXP(8)
     MOVE -0.26881 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 bow fully drawn, left" TO WS-NAME
     MOVE 2 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.0 TO WS-E
     MOVE 40 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.30470 TO WS-EXP(1)
     MOVE -0.32769 TO WS-EXP(2)
     MOVE -0.53136 TO WS-EXP(3)
     MOVE 0.07837 TO WS-EXP(4)
     MOVE 0.38038 TO WS-EXP(5)
     MOVE 1.03401 TO WS-EXP(6)
     MOVE 1.05903 TO WS-EXP(7)
     MOVE 0.04683 TO WS-EXP(8)
     MOVE -0.31026 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 crossbow charging, left" TO WS-NAME
     MOVE 3 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 8 TO WS-EL
     MOVE 25 TO WS-D
     MOVE -0.09163 TO WS-EXP(1)
     MOVE -0.76312 TO WS-EXP(2)
     MOVE -0.65822 TO WS-EXP(3)
     MOVE -0.38721 TO WS-EXP(4)
     MOVE 0.31302 TO WS-EXP(5)
     MOVE 0.89981 TO WS-EXP(6)
     MOVE 0.96957 TO WS-EXP(7)
     MOVE 0.18397 TO WS-EXP(8)
     MOVE 0.28925 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 trident charging, left" TO WS-NAME
     MOVE 4 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 6 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.11781 TO WS-EXP(1)
     MOVE 0.09692 TO WS-EXP(2)
     MOVE -0.57331 TO WS-EXP(3)
     MOVE 0.11923 TO WS-EXP(4)
     MOVE 0.91877 TO WS-EXP(5)
     MOVE 0.49663 TO WS-EXP(6)
     MOVE 1.01817 TO WS-EXP(7)
     MOVE -0.12123 TO WS-EXP(8)
     MOVE -0.23159 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 blocking with a sword, left" TO WS-NAME
     MOVE 5 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.41858 TO WS-EXP(1)
     MOVE -0.59000 TO WS-EXP(2)
     MOVE -0.57858 TO WS-EXP(3)
     MOVE -0.23115 TO WS-EXP(4)
     MOVE 0.95077 TO WS-EXP(5)
     MOVE -0.20643 TO WS-EXP(6)
     MOVE 0.20145 TO WS-EXP(7)
     MOVE 0.25435 TO WS-EXP(8)
     MOVE 0.94590 TO WS-EXP(9)
     PERFORM CHECK-ARM
     MOVE "T5301 auto spin attack, left" TO WS-NAME
     MOVE 6 TO WS-KIND
     MOVE -1 TO WS-SIDE
     MOVE 0.25 TO WS-E
     MOVE 0 TO WS-EL
     MOVE 0 TO WS-D
     MOVE -0.16000 TO WS-EXP(1)
     MOVE 0.13000 TO WS-EXP(2)
     MOVE -0.42000 TO WS-EXP(3)
     MOVE -0.90631 TO WS-EXP(4)
     MOVE 0.00000 TO WS-EXP(5)
     MOVE 0.42262 TO WS-EXP(6)
     MOVE 0.03683 TO WS-EXP(7)
     MOVE 0.99619 TO WS-EXP(8)
     MOVE 0.07899 TO WS-EXP(9)
     PERFORM CHECK-ARM

*>   The view pose: 53 section 15.2 worked example (b 0.1, walkDist 10, walkDistO 9.8, partial 0.5: translate (-0.0155, -0.0951, 0), rotate Z -0.093, rotate X 0.435
*>   degrees), then the sway of 12 section 6.1 step 3 (pitch 30 against 20, yaw 90 against 70: 1 and 2 degrees).
     MOVE 1 TO CL-BOB-INIT
     MOVE 10 TO PL-WALK
     MOVE 9.8 TO PL-WALK-O
     MOVE 0.1 TO PL-BOB PL-BOB-O
     MOVE 20 TO CL-XBOB CL-XBOB-O
     MOVE 70 TO CL-YBOB CL-YBOB-O
     MOVE 30 TO PL-PITCH
     MOVE 90 TO PL-YAW
     MOVE 0.5 TO WS-PART
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 the view pose is the bob of the worked example and the sway" TO WS-NAME
     MOVE -0.01545 TO WS-EXP(1)
     MOVE -0.09511 TO WS-EXP(2)
     MOVE 0 TO WS-EXP(3)
     MOVE 0.03486 TO WS-EXP(4)
     MOVE -0.02509 TO WS-EXP(5)
     MOVE 0.99908 TO WS-EXP(6)
     MOVE 0.99939 TO WS-EXP(7)
     MOVE -0.00074 TO WS-EXP(8)
     MOVE -0.03489 TO WS-EXP(9)
     PERFORM CHECK-M
*>   The option bobView false takes the bob away (the sway stays).
     MOVE "bobView" TO WS-OPT-NAME
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 with the option bobView false only the sway remains" TO WS-NAME
     MOVE 0 TO WS-EXP(1) WS-EXP(2) WS-EXP(3)
     MOVE 0.03490 TO WS-EXP(4)
     MOVE -0.01744 TO WS-EXP(5)
     MOVE 0.99924 TO WS-EXP(6)
     MOVE 0.99939 TO WS-EXP(7)
     MOVE 0.00061 TO WS-EXP(8)
     MOVE -0.03489 TO WS-EXP(9)
     PERFORM CHECK-M
     MOVE "true" TO WS-OPT-VALUE
     MOVE 4 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   Before the first hand tick the lagging angles are unknown (no sway) and, at rest (bob amount 0), the pose is the identity.
     MOVE 0 TO CL-BOB-INIT
     MOVE 0 TO PL-WALK PL-WALK-O PL-BOB PL-BOB-O
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 before the first hand tick the view pose is the identity" TO WS-NAME
     MOVE 0 TO WS-EXP(1) WS-EXP(2) WS-EXP(3) WS-EXP(4) WS-EXP(5) WS-EXP(7) WS-EXP(8) WS-EXP(9)
     MOVE 1 TO WS-EXP(6) WS-EXP(7)
     PERFORM CHECK-M
*>   The hurt tilt: Hurt Animation (id 43) of the local player stores the yaw; half way through the 500 ms the pose is Y -dir, Z -k 14, Y +dir with
*>   k = sin(0.5^4 pi) (rotation about the horizontal axis across the view, 2.731 degrees), and a hit on another entity changes nothing.
     MOVE 3 TO WS-HID
     MOVE 0 TO WS-HYAW
     CALL "HP-HURT" USING CLIENT-STATE WS-HID WS-HYAW
     MOVE "T5301 a Hurt Animation of another entity leaves the hurt direction" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-HURT-DIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE PL-ENTITY-ID TO WS-HID
     MOVE 90 TO WS-HYAW
     CALL "HP-HURT" USING CLIENT-STATE WS-HID WS-HYAW
     MOVE "T5301 a Hurt Animation of the local player keeps its yaw" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     MOVE PL-HURT-DIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-BOB-INIT
     MOVE 30 TO PL-HEALTH
     MOVE 6000000 TO CL-NOW-MS
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 250
     MOVE 0 TO WS-PART
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 half way through the hurt time the view is tilted by the hurt direction" TO WS-NAME
     MOVE 0 TO WS-EXP(1) WS-EXP(2) WS-EXP(3) WS-EXP(4) WS-EXP(7) WS-EXP(8) WS-EXP(9)
     MOVE -0.04765 TO WS-EXP(5)
     MOVE 0.99886 TO WS-EXP(6)
     MOVE 1 TO WS-EXP(7)
     PERFORM CHECK-M
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 1000
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 a hurt time over its length is clamped to the start of the tilt (sin(pi) = 0: no tilt)" TO WS-NAME
     MOVE 0 TO WS-EXP(5)
     MOVE 1 TO WS-EXP(6)
     PERFORM CHECK-M
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 250
     MOVE "damageTiltStrength" TO WS-OPT-NAME
     MOVE "0.0" TO WS-OPT-VALUE
     MOVE 3 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T5301 damageTiltStrength 0 takes the tilt away" TO WS-NAME
     MOVE 0 TO WS-EXP(5)
     MOVE 1 TO WS-EXP(6)
     PERFORM CHECK-M
     MOVE "1.0" TO WS-OPT-VALUE
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     MOVE 0 TO PL-HURT-UNTIL
*>   The tick state. The first tick only records the position and the angles; then a player on the ground at 0.2 blocks a tick moved 0.25 blocks.
     MOVE 0 TO CL-BOB-INIT CL-ATK-TICKER CL-ATK-LAST
     MOVE 5 TO PL-X
     MOVE 5 TO PL-Z
     MOVE 40 TO PL-PITCH
     MOVE 1 TO PL-ON-GROUND
     MOVE 30 TO PL-HEALTH
     MOVE 0 TO PL-IN-WATER
     MOVE 0.2 TO PL-VX
     MOVE 0 TO PL-VZ
     MOVE 6 TO WS-HELD
     CALL "HAND-TICK" USING CLIENT-STATE WS-HELD
     MOVE "T5301 the first hand tick takes the lagging angles from the view (no sway)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE CL-XBOB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5.25 TO PL-X
     MOVE 60 TO PL-PITCH
     CALL "HAND-TICK" USING CLIENT-STATE WS-HELD
     MOVE "T5301 the lagging pitch moves half way to the view (40 to 60 gives 50)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(CL-XBOB - 50) < 0.0001 AND FUNCTION ABS(CL-XBOB-O - 40) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T5301 the attack ticker counts the ticks since the stack was taken (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-ATK-TICKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Another stack restarts the ticker.
     MOVE 7 TO WS-HELD
     CALL "HAND-TICK" USING CLIENT-STATE WS-HELD
     MOVE "T5301 another held stack restarts the attack ticker" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-ATK-TICKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO PL-HEALTH
     MOVE 0 TO CL-BOB-INIT PL-WALK PL-WALK-O PL-BOB PL-BOB-O
     MOVE 0 TO PL-PITCH PL-YAW PL-VX
     MOVE 0.5 TO PL-X PL-Z
*>   The attack-cooldown dip (12 section 6.2): after an attack (ticker 0) the held item, bare-hand delay D = 5 ticks, drops with the cube of (ticker + 1) / 5.
*>   Per tick h = 1, 0.6, 0.216, 0.512; at the third tick E = 1 - oh = 1 - 0.216 = 0.784.
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM CL-ATK-LAST
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 0 TO CL-ATK-TICKER
     MOVE 2000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     ADD 150 TO CL-NOW-MS
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     MOVE "T5301 three ticks after an attack (E uses the height one tick back) the held item has dropped (E = 0.784, in thousandths)" TO TL-CASE
     MOVE 784 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-E * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An attack on an entity (left press with an entity aimed at) restarts the ticker; a press with none does not.
     MOVE 50 TO CL-ATK-TICKER
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO TG-ENTITY-HIT
     MOVE 1 TO IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1)
     CALL "HAND-INPUT" USING CLIENT-STATE
     MOVE "T5301 a left press with no entity aimed at leaves the attack ticker" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE CL-ATK-TICKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TG-ENTITY-HIT
     CALL "HAND-INPUT" USING CLIENT-STATE
     MOVE 0 TO IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) TG-ENTITY-HIT
     MOVE "T5301 an attack on an entity restarts the attack ticker" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-ATK-TICKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The meshes. A flat icon with the identity display: its centre is the translation of the pose.
     MOVE 1 TO IS-FP-STATE(11)
     MOVE 0 TO IS-FP-VAL(91) IS-FP-VAL(92) IS-FP-VAL(93) IS-FP-VAL(94) IS-FP-VAL(95) IS-FP-VAL(96)
     MOVE 1 TO IS-FP-VAL(97) IS-FP-VAL(98) IS-FP-VAL(99)
     MOVE 100 TO CL-ATK-TICKER
     MOVE 11 TO CL-HAND-ITEM
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 0 TO CL-OHAND-ITEM CL-SWING-AT
     MOVE 0 TO PL-OFFHAND-COUNT
     MOVE 3000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE RL-HAND-COUNT TO WS-COUNT
     MOVE 1 TO PL-OFFHAND-COUNT
     MOVE 10 TO PL-OFFHAND-ITEM
     MOVE 11 TO CL-OHAND-ITEM
     MOVE 1 TO CL-OHAND-H CL-OHAND-OH
     MOVE 3000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 an off hand with an item doubles the mesh" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT * 2
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM(1)
     PERFORM VARYING WS-I FROM WS-COUNT BY 1 UNTIL WS-I >= WS-COUNT + 12
         ADD RL-HAND-X(WS-I + 1) TO WS-SUM(1)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 12
     MOVE "T5301 the off hand is drawn on the left (centre x -0.56)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X + 0.56) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The mesh is reused while nothing changes, built again when the view pose changes.
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a still hand with an off hand reuses the mesh" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-BOB-INIT
     MOVE 0.1 TO PL-BOB PL-BOB-O
     MOVE 10 TO PL-WALK PL-WALK-O
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a changed view pose builds the mesh again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-BOB-INIT PL-WALK PL-WALK-O PL-BOB PL-BOB-O
*>   The mainHand option left puts the main hand on the left arm and the off hand on the right.
     MOVE "mainHand" TO WS-OPT-NAME
     MOVE '"left"' TO WS-OPT-VALUE
     MOVE 6 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-SUM(1) WS-SUM(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-X(WS-COUNT + WS-I) TO WS-SUM(2)
     END-PERFORM
     MOVE "T5301 with mainHand left the main hand is on the left and the off hand on the right" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-SUM(1) / 12 + 0.56) < 0.003 AND FUNCTION ABS(WS-SUM(2) / 12 - 0.56) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '"right"' TO WS-OPT-VALUE
     MOVE 7 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   The glint of a foil item in the hand (54 section 19.3): a flat item's glint covers its opaque texels (12 vertices a texel, more than the hand's 12 + edges), carries the
*>   glint strength 0.75 as brightness and is kept while the mesh is reused; with no foil there is none; a block item's glint is its 36 vertices.
     MOVE 0 TO PL-OFFHAND-COUNT CL-OHAND-ITEM CL-SWING-AT PL-EATING
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM CL-ATK-LAST
     MOVE 100 TO CL-ATK-TICKER
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 0 TO PL-SLOT-FOIL(PL-HELD + 1)
     MOVE 7000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 an item without foil has no glint mesh" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-HAND-COUNT TO WS-COUNT
     MOVE 1 TO PL-SLOT-FOIL(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a flat foil item's glint mesh covers its texels and is whole quads" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HG-COUNT > WS-COUNT AND FUNCTION MOD(RL-HG-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T5301 the hand's own mesh is unchanged by the foil" TO TL-CASE
     MOVE WS-COUNT TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T5301 the glint's brightness is the glint strength 0.75" TO TL-CASE
     MOVE 750 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = RL-HG-B(1) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-HG-COUNT TO WS-COUNT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a still foil hand reuses its glint mesh with the hand mesh" TO TL-CASE
     MOVE WS-COUNT TO TL-EXPECTED-N
     MOVE RL-HG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO TL-EXPECTED-N
     MOVE "T5301 and the hand mesh is the reused one" TO TL-CASE
     MOVE RL-HAND-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block item (item 1) with foil: its 6 faces.
     MOVE 1 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 2 TO CL-HAND-ITEM CL-ATK-LAST
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a block item's glint mesh is its 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-FOIL(PL-HELD + 1)
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM CL-ATK-LAST
*>   An off hand with foil has its own glint (the main hand shows nothing).
     MOVE 0 TO CL-HAND-ITEM
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 1 TO PL-OFFHAND-COUNT PL-OFFHAND-FOIL
     MOVE 10 TO PL-OFFHAND-ITEM
     MOVE 11 TO CL-OHAND-ITEM
     MOVE 1 TO CL-OHAND-H CL-OHAND-OH
     MOVE 7100000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 an off hand with foil has a glint mesh" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HG-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-OFFHAND-COUNT PL-OFFHAND-FOIL CL-OHAND-ITEM
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM
*>   Eating: 10 of 30 ticks (the use lasts CL-EAT-MS = 1500 ms) puts the main hand's item at the eating pose, with no swing.
     MOVE 0 TO PL-OFFHAND-COUNT
     MOVE 0 TO CL-OHAND-ITEM
     MOVE 1 TO PL-EATING
     MOVE 2999500 TO PL-EAT-START
     MOVE 3000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 3000000 TO CL-SWING-AT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         ADD RL-HAND-X(WS-I) TO WS-SUM(1)
         ADD RL-HAND-Y(WS-I) TO WS-SUM(2)
         ADD RL-HAND-Z(WS-I) TO WS-SUM(3)
     END-PERFORM
     COMPUTE WS-X = WS-SUM(1) / 12
     COMPUTE WS-Y = WS-SUM(2) / 12
     COMPUTE WS-Z = WS-SUM(3) / 12
     MOVE "T5301 an eating hand is at the eating pose (-0.1386, -0.4720, -0.7450)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-X - -0.13861) < 0.003 AND FUNCTION ABS(WS-Y - -0.47201) < 0.003 AND FUNCTION ABS(WS-Z - -0.74504) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-EATING
     MOVE 0 TO CL-SWING-AT
*>   The off hand takes the new stack at the bottom of its dip (below 0.1), like the main hand's.
     MOVE 0 TO CL-OHAND-ITEM CL-OHAND-H CL-OHAND-OH
     MOVE 1 TO PL-OFFHAND-COUNT
     MOVE 10 TO PL-OFFHAND-ITEM
     MOVE 4000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     ADD 50 TO CL-NOW-MS
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     MOVE "T5301 the off hand shows the new stack once its height is under 0.1" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE CL-OHAND-ITEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block item in the off hand with no display entry of its model takes block/block's own left-hand entry (rotation y 225, scale 0.4; 12 section 8.2):
*>   the first vertex of the cube (model corner (0, 1, 1)) is at (-0.56, -0.32, -1.0028), not the mirrored right entry's (-0.8428, -0.32, -0.72).
     MOVE 0 TO CL-HAND-ITEM PL-OFFHAND-COUNT
     MOVE 1 TO PL-OFFHAND-COUNT
     MOVE 1 TO PL-OFFHAND-ITEM
     MOVE 2 TO CL-OHAND-ITEM
     MOVE 1 TO CL-OHAND-H CL-OHAND-OH
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 0 TO CL-ATK-LAST
     MOVE 5000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T5301 a block item in the off hand is a cube of 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T5301 the off hand's block takes the left-hand default (first vertex x -560, y -320, z -1003)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RL-HAND-X(1) + 0.56) < 0.003 AND FUNCTION ABS(RL-HAND-Y(1) + 0.32) < 0.003
             AND FUNCTION ABS(RL-HAND-Z(1) + 1.00284) < 0.003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The attack delay of a held item: the bare hand and an item with no attack modifier 5 ticks; the standard set's iron sword 20 / 1.6 = 12.5.
     MOVE 0 TO WS-HELD
     CALL "HAND-ATTACK-DELAY" USING CLIENT-STATE WS-HELD WS-DELAY
     MOVE "T5301 the bare hand's full-charge delay is 5 ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-DELAY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "iron_sword" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = WS-ID + 1
     CALL "HAND-ATTACK-DELAY" USING CLIENT-STATE WS-HELD WS-DELAY
     MOVE "T5301 an iron sword's delay is 12.5 ticks (attack speed 1.6)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-DELAY - 12.5) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "apple" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = WS-ID + 1
     CALL "HAND-ATTACK-DELAY" USING CLIENT-STATE WS-HELD WS-DELAY
     MOVE "T5301 an apple has no attack modifier: delay 5 ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-DELAY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     STOP RUN.

 CHECK-ARM.
     CALL "HAND-M-IDENT" USING WS-M
     CALL "HAND-ARM" USING WS-M WS-SIDE WS-E WS-KIND WS-EL WS-D
     PERFORM CHECK-M.

 CHECK-M.
     MOVE WS-MV(10) TO WS-G(1)
     MOVE WS-MV(11) TO WS-G(2)
     MOVE WS-MV(12) TO WS-G(3)
     MOVE WS-MV(3) TO WS-G(4)
     MOVE WS-MV(6) TO WS-G(5)
     MOVE WS-MV(9) TO WS-G(6)
     MOVE WS-MV(1) TO WS-G(7)
     MOVE WS-MV(4) TO WS-G(8)
     MOVE WS-MV(7) TO WS-G(9)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF FUNCTION ABS(WS-G(WS-I) - WS-EXP(WS-I)) > 0.0006
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HAND-POSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HP-HURT.
*> USING CLIENT-STATE, entity id, yaw (FLOAT-SHORT): hands PROTO-PACKET (connection 1) a Hurt Animation (0x2B).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 43.
 01 WS-CONN                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-YAW
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM HP-HURT.

 COPY CLTEST.
