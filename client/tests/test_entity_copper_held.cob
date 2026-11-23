 *> Copper golem held items and interaction states (T9905; docs/protocol 34-3 sections 9.2 and 9.3, 44-3 section 8, 19 section 21, 00 section 13 serializer 37 COPPER_GOLEM_STATE).
*> The replica keeps the golem state (Set Entity Data entry 17, serializer 37: 0 idle, 1 getting item, 2 getting no item, 3 dropping item, 4 dropping no item) and the tick the state
*> was entered at (a state sent again does not restart it). ENTITY-POSE-MORE takes the state, its start tick and the two item flags (state(5) start tick(6) right hand has an item(7)
*> left hand has an item(8)): a hand with an item raises both arms (poseHeldItemArmsIfStill, 9.2 step 2) and the state's animation runs from its start tick (the others stay stopped;
*> expected values are keys of Appendix A: the legs of every interaction animation are at 7.5 and -10 degrees from 0.2083 s, the right leg of the get-item animation stays there to 2.7083 s,
*> the other three animations have it back at 0 by 2.3333 s). The item a golem holds is posed in the arm's frame after translateToHand (9.3): the state IDLE rotates Y by -90 (right) or +90
*> (left) and translates (0, 0, 0.125), any other state scales by 0.55 and translates (-0.125, 0.3125, -0.1875); the vertices of a stick in each hand, expected from an independent script
*> (the identity frame at (0.5, 1, 0.25) of an entity at (10.5, 64, 10.5) seen from the eye (10, 64, 10); the stick's right entry (0, 3, 1) / 0.55 and its left entry (0, 4, 0.5), rotation (0, 90, -55), 0.85).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-COPPER-HELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY20               PIC X(20).
 01 WS-KEY24               PIC X(24).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-STATE               BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-LA                  BINARY-LONG.
 01 WS-RL                  BINARY-LONG.
 01 WS-LL                  BINARY-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-STOPPED             FLOAT-LONG VALUE -2147483648.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NAME                PIC X(100).
 01 WS-SUM-A               BINARY-DOUBLE.
 01 WS-SUM-B               BINARY-DOUBLE.
 01 WS-SUM-C               BINARY-DOUBLE.
 01 WS-QUADS               BINARY-LONG.
 01 WS-LEN-IDLE            FLOAT-LONG.
 01 WS-LEN-BUSY            FLOAT-LONG.
 01 WS-IN.
    05 WS-IV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EXPECT.
    05 WS-EX               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U PL-YAW
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "copper_golem" TO WS-KEY24
     CALL "ENTITY-MODEL-FIND" USING WS-KEY24 WS-MODEL
     CALL "ENTITY-MODEL-BUILD" USING EMM-MODEL WS-MODEL WS-STATUS
     MOVE "right_arm" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-RA
     MOVE "left_arm" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-LA
     MOVE "right_leg" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-RL
     MOVE "left_leg" TO WS-KEY24
     CALL "EMM-FIND" USING EMM-MODEL WS-KEY24 WS-LL
     MOVE "copper_golem" TO WS-KEY20

*>   ENTITY-POSE-MORE: an item in the right hand raises both arms to the held pose of 9.2 step 2 (xRot -0.87266463, yRot -+0.1134464, zRot -+0.064577185).
     PERFORM CLEAR-IN
     MOVE 1 TO WS-IV(7)
     MOVE 0 TO WS-AGE
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 an item in the right hand raises the right arm (x)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RA) + 0.87266463
     PERFORM CHECK-SMALL
     MOVE "T9905 an item in the right hand raises the left arm (x)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-LA) + 0.87266463
     PERFORM CHECK-SMALL
     MOVE "T9905 the held right arm turns in (y -0.1134464, z -0.064577185)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-RA) + 0.1134464 + MM-CZROT(WS-RA) + 0.064577185
     PERFORM CHECK-SMALL
     MOVE "T9905 the held left arm turns in (y 0.1134464, z 0.064577185)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CYROT(WS-LA) - 0.1134464 + MM-CZROT(WS-LA) - 0.064577185
     PERFORM CHECK-SMALL
*>   An item in the left hand only raises both arms the same way.
     PERFORM CLEAR-IN
     MOVE 1 TO WS-IV(8)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 an item in the left hand raises the right arm too" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RA) + 0.87266463
     PERFORM CHECK-SMALL
*>   Nothing held: the arms keep the rest pose.
     PERFORM CLEAR-IN
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 empty hands keep the arms at rest" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RA) + MM-CXROT(WS-LA)
     PERFORM CHECK-SMALL

*>   The state animations: state 1 (getting an item) started at tick 0, seen at tick 20 (1 s): the legs are at 7.5 and -10 degrees.
     PERFORM CLEAR-IN
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 20 TO WS-AGE
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 getting an item at 1 s: right leg 7.5 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.13089969
     PERFORM CHECK-SMALL
     MOVE "T9905 getting an item at 1 s: left leg -10 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-LL) + 0.17453293
     PERFORM CHECK-SMALL
*>   The idle state runs no state animation here (the start tick of idle is not told; 44-3 gives none), whatever start tick is in the input.
     MOVE 0 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 state idle leaves the legs at rest" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) + MM-CXROT(WS-LL)
     PERFORM CHECK-SMALL
*>   A stopped start tick plays nothing.
     MOVE 1 TO WS-IV(5)
     MOVE WS-STOPPED TO WS-IV(6)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 a stopped start tick leaves the legs at rest" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) + MM-CXROT(WS-LL)
     PERFORM CHECK-SMALL
*>   State 1 at 2.5 s (tick 50): the right leg is still at 7.5 degrees (the get-item animation, key 2.7083 s); state 2 has it back at 0 (key 2.3333 s).
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 50 TO WS-AGE
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 getting an item at 2.5 s: the right leg is still at 7.5 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.13089969
     PERFORM CHECK-SMALL
     MOVE 2 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 getting no item at 2.5 s: the right leg is back at 0" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL)
     PERFORM CHECK-SMALL
     MOVE 3 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 dropping an item at 2.5 s: the right leg is at 5 degrees (key 2.4583 s)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.08726646
     PERFORM CHECK-SMALL
     MOVE 4 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 dropping no item at 2.5 s: the right leg is back at 0" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL)
     PERFORM CHECK-SMALL
*>   At 2.2 s (tick 44) getting no item still has the right leg at 7.5 degrees (key 2.2917 s) and dropping no item is on its way back (between the keys 2.1667 s and 2.25 s: 4.5 degrees).
     MOVE 44 TO WS-AGE
     MOVE 2 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 getting no item at 2.2 s: the right leg is at 7.5 degrees" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.13089969
     PERFORM CHECK-SMALL
     MOVE 4 TO WS-IV(5)
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 dropping no item at 2.2 s: the right leg is on its way back (4.5 degrees)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.07857
     PERFORM CHECK-NEAR
*>   The start tick is the animation's zero: started at tick 40 and seen at tick 60 is the same pose as started at 0 and seen at 20.
     MOVE 1 TO WS-IV(5)
     MOVE 40 TO WS-IV(6)
     MOVE 60 TO WS-AGE
     CALL "ENTITY-POSE-MORE" USING EMM-MODEL WS-KEY20 WS-IN WS-AGE
     MOVE "T9905 the animation counts from its start tick (40 to 60 is 1 s)" TO TL-CASE
     COMPUTE WS-DIFF = MM-CXROT(WS-RL) - 0.13089969
     PERFORM CHECK-SMALL

*>   The replica: Set Entity Data entry 17 (COPPER_GOLEM_STATE) is kept with the tick it was entered at.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "copper_golem" TO WS-KEY
     CALL "CGH-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     MOVE "T9905 a new golem is idle" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-N
     PERFORM WS-N TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE 2 TO WS-STATE
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     MOVE "T9905 Set Entity Data 17 = 2 is kept" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9905 the state starts at the age it was entered at (5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-X3(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-N
     PERFORM WS-N TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     MOVE "T9905 the same state sent again keeps its start tick" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-X3(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-STATE
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     MOVE "T9905 another state starts at the age of the change (8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-X3(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9905 and is kept (3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     MOVE "T9905 back to idle (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Drawn: a state animation changes the mesh, and as the animation runs the mesh follows the age; idle is the rest mesh.
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-A WS-QUADS
     MOVE 1 TO WS-STATE
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     MOVE 20 TO WS-N
     PERFORM WS-N TIMES
         CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     END-PERFORM
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-B WS-QUADS
     MOVE "T9905 getting an item at 1 s draws another mesh than idle" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-B NOT = WS-SUM-A
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-C WS-QUADS
     MOVE "T9905 a tick later the animation has moved on" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-C NOT = WS-SUM-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "CGH-DATA" USING CLIENT-STATE WS-ID WS-STATE
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-C WS-QUADS
     MOVE "T9905 idle again draws the idle mesh" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-C = WS-SUM-A
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An item in a hand changes the mesh (the arms are raised).
     MOVE WS-STICK TO EN-EQ(1, 1)
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-B WS-QUADS
     MOVE "T9905 a golem that holds an item has its arms raised (another mesh)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-B NOT = WS-SUM-A
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-EQ(1, 1)
     MOVE WS-STICK TO EN-EQ(1, 2)
     CALL "CGH-SUM" USING CLIENT-STATE WS-EYE-TABLE WS-SUM-C WS-QUADS
     MOVE "T9905 an item in the other hand raises the arms the same" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM-C NOT = WS-SUM-A
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The held item through the whole path: a stick in the main hand is two quads at the right arm; idle and busy states place it differently and the busy one is 0.55 as large.
     MOVE 0 TO EN-EQ(1, 2)
     MOVE WS-STICK TO EN-EQ(1, 1)
     MOVE 0 TO EN-X1(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9905 a golem with a stick in its main hand draws the stick (12 vertices)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM DIAGONAL
     MOVE WS-DIFF TO WS-LEN-IDLE
     MOVE 2 TO EN-X1(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM DIAGONAL
     MOVE WS-DIFF TO WS-LEN-BUSY
     MOVE "T9905 the item of a golem at work is scaled by 0.55 (9.3)" TO TL-CASE
     COMPUTE WS-DIFF = WS-LEN-BUSY / WS-LEN-IDLE - 0.55
     PERFORM CHECK-SMALL

*>   The pose chain on a frame set by hand (identity axes at (0.5, 1, 0.25)): idle and busy, right and left hand.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "copper_golem" TO WS-KEY
     CALL "CGH-SPAWN" USING CLIENT-STATE WS-ID WS-KEY WS-X WS-Y WS-Z
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE 1 TO EN-HAND-FOK(1, WS-HAND)
         MOVE 0.5 TO EN-HAND-F(1, WS-HAND, 1)
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 2)
         MOVE 0.25 TO EN-HAND-F(1, WS-HAND, 3)
         PERFORM VARYING WS-J FROM 4 BY 1 UNTIL WS-J > 12
             MOVE 0 TO EN-HAND-F(1, WS-HAND, WS-J)
         END-PERFORM
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 4) EN-HAND-F(1, WS-HAND, 8) EN-HAND-F(1, WS-HAND, 12)
     END-PERFORM
     MOVE 0 TO EN-X1(1)
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-STICK WS-EYE-TABLE
     MOVE "T9905 an idle golem's stick in the right hand: rotate Y -90, translate (0, 0, 0.125)" TO WS-NAME
     MOVE 1.4625 TO WS-EX(1)
     MOVE 1.54531 TO WS-EX(2)
     MOVE 0.9625 TO WS-EX(3)
     MOVE 1.4625 TO WS-EX(4)
     MOVE 1.54531 TO WS-EX(5)
     MOVE 0.4125 TO WS-EX(6)
     MOVE 0.9125 TO WS-EX(7)
     MOVE 1.54531 TO WS-EX(8)
     MOVE 0.4125 TO WS-EX(9)
     MOVE 1.4625 TO WS-EX(10)
     MOVE 1.57969 TO WS-EX(11)
     MOVE 0.4125 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     MOVE 4 TO EN-X1(1)
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-STICK WS-EYE-TABLE
     MOVE "T9905 a golem at work: right-hand stick scaled 0.55, moved (-0.125, 0.3125, -0.1875)" TO WS-NAME
     MOVE 1.04812 TO WS-EX(1)
     MOVE 1.4718 TO WS-EX(2)
     MOVE 0.32375 TO WS-EX(3)
     MOVE 0.74562 TO WS-EX(4)
     MOVE 1.4718 TO WS-EX(5)
     MOVE 0.32375 TO WS-EX(6)
     MOVE 0.74562 TO WS-EX(7)
     MOVE 1.4718 TO WS-EX(8)
     MOVE 0.62625 TO WS-EX(9)
     MOVE 0.74562 TO WS-EX(10)
     MOVE 1.4907 TO WS-EX(11)
     MOVE 0.32375 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     MOVE 2 TO WS-HAND
     MOVE 0 TO EN-X1(1)
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-STICK WS-EYE-TABLE
     MOVE "T9905 an idle golem's stick in the left hand: rotate Y +90, translate (0, 0, 0.125)" TO WS-NAME
     MOVE 0.15809 TO WS-EX(1)
     MOVE 1.69812 TO WS-EX(2)
     MOVE 0.71406 TO WS-EX(3)
     MOVE 0.85437 TO WS-EX(4)
     MOVE 2.18566 TO WS-EX(5)
     MOVE 0.71406 TO WS-EX(6)
     MOVE 1.34191 TO WS-EX(7)
     MOVE 1.48938 TO WS-EX(8)
     MOVE 0.71406 TO WS-EX(9)
     MOVE 0.85437 TO WS-EX(10)
     MOVE 2.18566 TO WS-EX(11)
     MOVE 0.66094 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     MOVE 1 TO EN-X1(1)
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-STICK WS-EYE-TABLE
     MOVE "T9905 a golem at work: its stick in the left hand follows the same scale and translation" TO WS-NAME
     MOVE 0.95102 TO WS-EX(1)
     MOVE 1.55584 TO WS-EX(2)
     MOVE 0.11507 TO WS-EX(3)
     MOVE 0.95102 TO WS-EX(4)
     MOVE 1.82399 TO WS-EX(5)
     MOVE 0.49803 TO WS-EX(6)
     MOVE 0.95102 TO WS-EX(7)
     MOVE 1.44103 TO WS-EX(8)
     MOVE 0.76618 TO WS-EX(9)
     MOVE 0.98023 TO WS-EX(10)
     MOVE 1.82399 TO WS-EX(11)
     MOVE 0.49803 TO WS-EX(12)
     PERFORM CHECK-VERTICES
     STOP RUN.

 CLEAR-IN.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         MOVE 0 TO WS-IV(WS-J)
     END-PERFORM
     MOVE WS-STOPPED TO WS-IV(6).

 CHECK-NEAR.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.002 AND WS-DIFF > -0.002
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001 AND WS-DIFF > -0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The length of the first quad's diagonal (vertex 1 to vertex 3) of the ground item mesh, into WS-DIFF.
 DIAGONAL.
     COMPUTE WS-DIFF = FUNCTION SQRT((RL-GI-X(3) - RL-GI-X(1)) ** 2 + (RL-GI-Y(3) - RL-GI-Y(1)) ** 2 + (RL-GI-Z(3) - RL-GI-Z(1)) ** 2).

*> Vertices 1, 2, 3 and 7 of the mesh equal WS-EX (x y z each; within 0.001).
 CHECK-VERTICES.
     MOVE 0 TO WS-BAD
     IF FUNCTION ABS(RL-GI-X(1) - WS-EX(1)) > 0.001 OR FUNCTION ABS(RL-GI-Y(1) - WS-EX(2)) > 0.001 OR FUNCTION ABS(RL-GI-Z(1) - WS-EX(3)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(2) - WS-EX(4)) > 0.001 OR FUNCTION ABS(RL-GI-Y(2) - WS-EX(5)) > 0.001 OR FUNCTION ABS(RL-GI-Z(2) - WS-EX(6)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(3) - WS-EX(7)) > 0.001 OR FUNCTION ABS(RL-GI-Y(3) - WS-EX(8)) > 0.001 OR FUNCTION ABS(RL-GI-Z(3) - WS-EX(9)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(RL-GI-X(7) - WS-EX(10)) > 0.001 OR FUNCTION ABS(RL-GI-Y(7) - WS-EX(11)) > 0.001 OR FUNCTION ABS(RL-GI-Z(7) - WS-EX(12)) > 0.001
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-NAME TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-COPPER-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CGH-SPAWN.
*> USING CLIENT-STATE, entity id, type key (PIC X(112)), x y z: Add Entity at rest.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-KEY L-X L-Y L-Z.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM CGH-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CGH-DATA.
*> USING CLIENT-STATE, entity id, state: Set Entity Data with the one entry 17 of serializer 37 (COPPER_GOLEM_STATE, a VarInt).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE 17 TO MD-MX-INDEX
     MOVE 37 TO MD-MX-SERIALIZER
     MOVE L-STATE TO MD-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE MD-MD-END TO MD-MX-INDEX
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM CGH-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CGH-SUM.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG), sum out (BINARY-DOUBLE), vertex count out: the position-weighted sum of the frame's entity vertices (thousandths).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-SUM                  BINARY-DOUBLE.
 01 L-QUADS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-SUM L-QUADS.
     CALL "ENTITIES-MESH" USING CLIENT-STATE L-EYE-TABLE
     MOVE 0 TO L-SUM
     MOVE RL-EN-COUNT TO L-QUADS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RL-EN-COUNT
         COMPUTE L-SUM = L-SUM + FUNCTION INTEGER((RL-EN-X(WS-K) * 1.1 + RL-EN-Y(WS-K) * 2.3 + RL-EN-Z(WS-K) * 3.7) * 1000 + 0.5)
             * (1 + FUNCTION MOD(WS-K, 7))
     END-PERFORM
     GOBACK.
 END PROGRAM CGH-SUM.

 COPY CLTEST.
