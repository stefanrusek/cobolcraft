*> Implementation test (002-lane-mobsfull-h2, T2242; docs/protocol/18 section 5.4 Navigation classes): per class evaluator, update, destination and direct movement rules, sun trimming, surface search and createPath guards.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-5-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBPATH.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-A
     CALL "NAV-CLASS-INFO" USING WS-A WS-O1 WS-O2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes GroundPathNavigation uses evaluator 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes GroundPathNavigation canNavigateGround is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes GroundPathNavigation max vertical distance to a waypoint is 1.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "NAV-CLASS-INFO" USING WS-A WS-O1 WS-O2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes WaterBoundPathNavigation uses evaluator 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes WaterBoundPathNavigation canNavigateGround is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes WaterBoundPathNavigation max vertical distance to a waypoint is 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "NAV-CLASS-INFO" USING WS-A WS-O1 WS-O2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes FlyingPathNavigation uses evaluator 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes FlyingPathNavigation canNavigateGround is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes FlyingPathNavigation max vertical distance to a waypoint is 1.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "NAV-CLASS-INFO" USING WS-A WS-O1 WS-O2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes AmphibiousPathNavigation uses evaluator 4" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes AmphibiousPathNavigation canNavigateGround is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes AmphibiousPathNavigation max vertical distance to a waypoint is 1.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "NAV-CLASS-INFO" USING WS-A WS-O1 WS-O2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes WallClimberNavigation uses evaluator 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes WallClimberNavigation canNavigateGround is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.4 Navigation classes WallClimberNavigation max vertical distance to a waypoint is 1.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of GroundPathNavigation: ground 1 liquid 0 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of GroundPathNavigation: ground 0 liquid 1 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of GroundPathNavigation: ground 0 liquid 0 passenger 1 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of GroundPathNavigation: ground 0 liquid 0 passenger 0 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of WaterBoundPathNavigation: ground 0 liquid 1 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of WaterBoundPathNavigation: ground 1 liquid 0 passenger 0 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of FlyingPathNavigation: ground 0 liquid 0 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of FlyingPathNavigation: ground 0 liquid 1 passenger 0 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of FlyingPathNavigation: ground 0 liquid 0 passenger 1 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of AmphibiousPathNavigation: ground 0 liquid 0 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of WallClimberNavigation: ground 1 liquid 0 passenger 0 is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-UPDATE-PATH" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canUpdatePath of WallClimberNavigation: ground 0 liquid 0 passenger 0 is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of GroundPathNavigation (here solid 0, below solid 1, below air 0, stand-on 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of GroundPathNavigation (here solid 0, below solid 0, below air 0, stand-on 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of WallClimberNavigation (here solid 0, below solid 1, below air 0, stand-on 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of WaterBoundPathNavigation (here solid 0, below solid 0, below air 0, stand-on 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of WaterBoundPathNavigation (here solid 1, below solid 0, below air 0, stand-on 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of FlyingPathNavigation (here solid 0, below solid 0, below air 0, stand-on 1) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of FlyingPathNavigation (here solid 0, below solid 1, below air 0, stand-on 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of AmphibiousPathNavigation (here solid 0, below solid 0, below air 0, stand-on 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     CALL "NAV-STABLE-DESTINATION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes isStableDestination of AmphibiousPathNavigation (here solid 0, below solid 0, below air 1, stand-on 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of GroundPathNavigation (liquid 0, ray 1, ray with fluids 1) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of WallClimberNavigation (liquid 0, ray 1, ray with fluids 1) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of WaterBoundPathNavigation (liquid 1, ray 1, ray with fluids 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of WaterBoundPathNavigation (liquid 1, ray 0, ray with fluids 1) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of FlyingPathNavigation (liquid 0, ray 0, ray with fluids 1) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of FlyingPathNavigation (liquid 0, ray 1, ray with fluids 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of AmphibiousPathNavigation (liquid 1, ray 1, ray with fluids 0) is 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     CALL "NAV-CAN-MOVE-DIRECTLY" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes canMoveDirectly of AmphibiousPathNavigation (liquid 0, ray 1, ray with fluids 0) is 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PS-PATH-COUNT
     MOVE 0 TO PS-SKY(1)
     MOVE 0 TO PS-SKY(2)
     MOVE 1 TO PS-SKY(3)
     MOVE 0 TO PS-SKY(4)
     MOVE 0 TO PS-SKY(5)
     MOVE 1 TO WS-A
     CALL "PATH-TRIM-SUN" USING PF-SEARCH WS-A
     MOVE "acceptance US15 18§5.4 Navigation classes trimPath cuts the path at the first node under open sky when avoiding the sun" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO PS-PATH-COUNT
     MOVE 0 TO WS-A
     CALL "PATH-TRIM-SUN" USING PF-SEARCH WS-A
     MOVE "acceptance US15 18§5.4 Navigation classes trimPath leaves the path alone when not avoiding the sun" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PS-SKY(3)
     MOVE 1 TO WS-A
     CALL "PATH-TRIM-SUN" USING PF-SEARCH WS-A
     MOVE "acceptance US15 18§5.4 Navigation classes trimPath leaves a path without open sky nodes alone" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     MOVE 5 TO WS-A
     MOVE 5 TO WS-B
     MOVE 5 TO WS-C
     CALL "FIND-SURFACE" USING PF-WORLD WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes a target in the air is moved down to the surface" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     CALL "FIND-SURFACE" USING PF-WORLD WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes a target inside a block is moved up to the first air" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     CALL "FIND-SURFACE" USING PF-WORLD WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes a target already on the surface stays" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 0 TO WS-B
     MOVE 5 TO WS-C
     MOVE 1 TO WS-D
     PERFORM SET-CELL
     MOVE 3 TO WS-B
     CALL "FIND-SURFACE" USING PF-WORLD WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes a target above a hole without a floor goes down to the world bottom" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "PATH-REGION-OFFSET" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes the region offset of a block or set target is 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "PATH-REGION-OFFSET" USING WS-A WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes the region offset of an entity target is 16" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-F1
     MOVE 16 TO WS-F2
     CALL "PATH-MAX-LENGTH" USING WS-F1 WS-F2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes the maximum path length is the follow range" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 32 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 48 TO WS-F2
     CALL "PATH-MAX-LENGTH" USING WS-F1 WS-F2 WS-G1
     MOVE "acceptance US15 18§5.4 Navigation classes setRequiredPathLength can raise it" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 48 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath computes a new path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath returns null for an empty target set" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath returns null below the world minimum" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath keeps a current unfinished path to a target of the set" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath replaces a finished current path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "CREATE-PATH-GUARD" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes createPath replaces a current path to another target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 1 TO WS-B
     CALL "PATH-TARGET-Y" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes an entity target is shifted up by 1 when offsetUpward" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     CALL "PATH-TARGET-Y" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§5.4 Navigation classes without offsetUpward the target block is the entity block" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BUILD-FLAT.
     INITIALIZE PF-WORLD
     INITIALIZE PF-NODES
     MOVE 16 TO PW-DX
     MOVE 8 TO PW-DY
     MOVE 16 TO PW-DZ
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 2048
         MOVE 1 TO PW-CELL(WS-P)
     END-PERFORM
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 256
         MOVE 0 TO PW-CELL(WS-P)
     END-PERFORM.
 INIT-SEARCH.
     INITIALIZE PF-SEARCH
     INITIALIZE PF-MALUS-TABLE
     MOVE 1 TO PS-KIND
     MOVE 1 TO PS-TARGET-COUNT
     MOVE 1 TO PS-WIDTH
     MOVE 2 TO PS-HEIGHT
     MOVE 3 TO PS-MAX-FALL
     MOVE 1 TO PS-STEP
     MOVE 100 TO PS-MAX-DIST
     MOVE 1000 TO PS-BUDGET
     MOVE 2 TO PS-SX
     MOVE 1 TO PS-SY
     MOVE 2 TO PS-SZ
     MOVE 6 TO PS-TX(1)
     MOVE 1 TO PS-TY(1)
     MOVE 2 TO PS-TZ(1).
 SET-CELL.
     COMPUTE WS-P = (WS-B * PW-DZ + WS-C) * PW-DX + WS-A + 1
     MOVE WS-D TO PW-CELL(WS-P).
 FIND-NODE.
     COMPUTE WS-P = (WS-B * PW-DZ + WS-C) * PW-DX + WS-A + 1
     MOVE PN-INDEX(WS-P) TO WS-O1.
 BUILD-WALL.
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 6
         MOVE 4 TO WS-A
         MOVE 1 TO WS-B
         MOVE 0 TO WS-D
         PERFORM SET-CELL
         MOVE 2 TO WS-B
         PERFORM SET-CELL
     END-PERFORM.
 COUNT-NODE-AT.
     MOVE 0 TO WS-O3
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > PS-PATH-COUNT
         IF PS-PX(WS-P) = WS-A AND PS-PY(WS-P) = WS-B AND PS-PZ(WS-P) = WS-C
             ADD 1 TO WS-O3
         END-IF
     END-PERFORM.
 CHECK-WALL.
     MOVE 0 TO WS-O3
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > PS-PATH-COUNT
         IF PS-PX(WS-P) = 4 AND PS-PZ(WS-P) < 7
             ADD 1 TO WS-O3
         END-IF
     END-PERFORM.
 CHECK-COUNT.
     MOVE 0 TO WS-O2
     IF PS-PATH-COUNT NOT < WS-E
         MOVE 1 TO WS-O2
     END-IF.
 END PROGRAM TEST-MOB-18-5-4.
