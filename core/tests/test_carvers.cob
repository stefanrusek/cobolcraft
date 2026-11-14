*> Implementation test of the classic carvers (core/src/carvers.cob, core/src/rng-java.cob; T0425; docs/protocol/11 sections 4, 5 and
*> 10.1): the Java LCG reference values of 11 section 4 (seed 0), setLargeFeatureSeed, the worked example of 10.1 (world seed 0, source
*> chunk (-2, -2): start draw, count, cave parameters, room, tunnel parameters), the ellipsoid and its carving mask (5.5, hand
*> computed points of a sphere with and without the cave floor, the canyon width factor), the mask application (5.6: bedrock kept, air
*> above sea level, sea water and lava below, regrassed dirt) and the whole stage on a stone chunk (the room of the worked example
*> is air at its centre, the result is the same twice). Block table of the test: air 0, stone 1, water 86, lava 102, bedrock 7,
*> grass_block 8, dirt 9.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CARVERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CARVER.
 COPY GENSTAGE.
 COPY GENSTEPS.
 01 WS-RND                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-U64                 BINARY-DOUBLE UNSIGNED.
 01 WS-S64                 BINARY-DOUBLE.
 01 WS-I32                 BINARY-LONG.
 01 WS-I64                 BINARY-DOUBLE.
 01 WS-F                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-HR                  FLOAT-LONG.
 01 WS-VR                  FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-MARKED              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-A                   PIC X(304640) BASED.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE "minecraft:bedrock" TO CB-KEY(5)
     MOVE 17 TO CB-KEY-LENGTH(5)
     MOVE 7 TO CB-DEFAULT-STATE(5)
     MOVE "minecraft:grass_block" TO CB-KEY(6)
     MOVE 21 TO CB-KEY-LENGTH(6)
     MOVE 8 TO CB-DEFAULT-STATE(6)
     MOVE "minecraft:dirt" TO CB-KEY(7)
     MOVE 14 TO CB-KEY-LENGTH(7)
     MOVE 9 TO CB-DEFAULT-STATE(7)
     MOVE "minecraft:mycelium" TO CB-KEY(8)
     MOVE 18 TO CB-KEY-LENGTH(8)
     MOVE 10 TO CB-DEFAULT-STATE(8)
     CALL "CARVER-SETUP" USING WS-SEED

*>   the Java LCG (11 section 4, section 11 items 9 and 10)
     MOVE 0 TO WS-U64
     CALL "JRAND-SET-SEED" USING WS-RND WS-U64
     MOVE 32 TO WS-I32
     CALL "JRAND-NEXT" USING WS-RND WS-I32 WS-I64
     MOVE "test carvers java random seed 0 nextInt" TO TL-CASE
     MOVE -1155484576 TO TL-EXPECTED-N
     MOVE WS-I64 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-SET-SEED" USING WS-RND WS-U64
     CALL "JRAND-NEXT-LONG" USING WS-RND WS-U64
     MOVE WS-U64 TO WS-S64
     IF WS-U64 > 9223372036854775807
         COMPUTE WS-S64 = WS-U64 - 18446744073709551616
     END-IF
     MOVE "test carvers java random seed 0 nextLong" TO TL-CASE
     MOVE -4962768465676381896 TO TL-EXPECTED-N
     MOVE WS-S64 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-U64
     CALL "JRAND-SET-SEED" USING WS-RND WS-U64
     CALL "JRAND-NEXT-FLOAT" USING WS-RND WS-F
     MOVE 7309678 TO WS-WANT
     PERFORM CHECK-SEVEN
     MOVE "test carvers java random seed 0 nextFloat 0.7309678" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-SET-SEED" USING WS-RND WS-U64
     MOVE 10 TO WS-I32
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-I32 WS-K
     MOVE "test carvers java random seed 0 nextInt(10) is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-SET-SEED" USING WS-RND WS-U64
     MOVE 16 TO WS-I32
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RND WS-I32 WS-K
     MOVE "test carvers java random nextInt of a power of two takes the high bits (seed 0, bound 16)" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   setLargeFeatureSeed
     MOVE 0 TO WS-U64
     MOVE 0 TO WS-SX
     MOVE 0 TO WS-SZ
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RND WS-U64 WS-SX WS-SZ
     MOVE 32 TO WS-I32
     CALL "JRAND-NEXT" USING WS-RND WS-I32 WS-I64
     MOVE "test carvers setLargeFeatureSeed(0, 0, 0) is the stream of seed 0" TO TL-CASE
     MOVE -1155484576 TO TL-EXPECTED-N
     MOVE WS-I64 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SX
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RND WS-U64 WS-SX WS-SZ
     CALL "JRAND-NEXT" USING WS-RND WS-I32 WS-I64
     MOVE "test carvers setLargeFeatureSeed(0, 1, 0) first next(32) is 1118589937" TO TL-CASE
     MOVE 1118589937 TO TL-EXPECTED-N
     MOVE WS-I64 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   worked example 10.2 comparison: chunk (1, 0): the cave does not start, the extra cave starts and has count 0
     MOVE 0 TO WS-K
     CALL "CARVER-START-DRAW" USING WS-U64 WS-K WS-SX WS-SZ WS-RND WS-F
     MOVE 260442 TO WS-WANT
     PERFORM CHECK-SIX
     MOVE "test carvers 10.1 chunk (1, 0) cave start draw 0.260442" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-K
     CALL "CARVER-START-DRAW" USING WS-U64 WS-K WS-SX WS-SZ WS-RND WS-F
     MOVE 17425 TO WS-WANT
     PERFORM CHECK-SIX
     MOVE "test carvers 10.1 chunk (1, 0) extra cave start draw 0.017425" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CARVER-COUNT" USING WS-RND WS-COUNT
     MOVE "test carvers 10.1 chunk (1, 0) extra cave count 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   worked example 10.1: seed 0, source chunk (-2, -2), cave carver
     MOVE 0 TO WS-K
     MOVE -2 TO WS-SX
     MOVE -2 TO WS-SZ
     CALL "CARVER-START-DRAW" USING WS-U64 WS-K WS-SX WS-SZ WS-RND WS-F
     MOVE 116262 TO WS-WANT
     PERFORM CHECK-SIX
     MOVE "test carvers 10.1 first draw 0.116262" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CARVER-COUNT" USING WS-RND WS-COUNT
     MOVE "test carvers 10.1 count 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -56 TO WS-X
     MOVE 180 TO WS-Y
     CALL "CARVER-CAVE-HEAD" USING WS-RND WS-X WS-Y
     MOVE "test carvers 10.1 cave position (-29, 96, -18)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (CV-CAVE-X + 100) * 1000000 + (CV-CAVE-Y + 100) * 1000 + CV-CAVE-Z + 100
     COMPUTE TL-EXPECTED-N = 71 * 1000000 + 196 * 1000 + 82
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-CAVE-HMUL TO WS-F
     MOVE 12275 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 hMul 1.2275" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-CAVE-VMUL TO WS-F
     MOVE 9986 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 vMul 0.9986" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-CAVE-FLOOR TO WS-F
     MOVE -5688 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 floor -0.5688" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-CAVE-ROOMV TO WS-F
     MOVE 6578 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 room vertical multiplier 0.6578" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-CAVE-ROOMR TO WS-F
     MOVE 46286 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 room radius draw 4.6286" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers 10.1 a room and three tunnels" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CV-CAVE-ROOM * 10 + CV-CAVE-TUNNELS
     MOVE 13 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CARVER-TUNNEL-HEAD" USING WS-RND
     MOVE CV-TUN-YAW TO WS-F
     MOVE 14454 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 tunnel 0 yaw 1.4454" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-TUN-PITCH TO WS-F
     MOVE -3018 TO WS-WANT
     PERFORM CHECK-FIVE-LOW
     MOVE "test carvers 10.1 tunnel 0 pitch -0.03018" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-TUN-THICK TO WS-F
     MOVE 10539 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 tunnel 0 thickness 1.0539" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers 10.1 tunnel 0 steps 91" TO TL-CASE
     MOVE 91 TO TL-EXPECTED-N
     MOVE CV-TUN-STEPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CV-TUN-SEED TO WS-S64
     IF CV-TUN-SEED > 9223372036854775807
         COMPUTE WS-S64 = CV-TUN-SEED - 18446744073709551616
     END-IF
     MOVE "test carvers 10.1 tunnel 0 walker seed -1474232536740074715" TO TL-CASE
     MOVE -1474232536740074715 TO TL-EXPECTED-N
     MOVE WS-S64 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CARVER-TUNNEL-HEAD" USING WS-RND
     MOVE CV-TUN-YAW TO WS-F
     MOVE 20769 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 tunnel 1 yaw 2.0769" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers 10.1 tunnel 1 steps 88" TO TL-CASE
     MOVE 88 TO TL-EXPECTED-N
     MOVE CV-TUN-STEPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CARVER-TUNNEL-HEAD" USING WS-RND
     MOVE CV-TUN-THICK TO WS-F
     MOVE 19627 TO WS-WANT
     PERFORM CHECK-FOUR
     MOVE "test carvers 10.1 tunnel 2 thickness 1.9627" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers 10.1 tunnel 2 steps 89" TO TL-CASE
     MOVE 89 TO TL-EXPECTED-N
     MOVE CV-TUN-STEPS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the ellipsoid (5.5): a sphere of radius 3 at (8, 100, 8) of chunk (0, 0); the cave floor is -1.0 (no cut) then -0.5
     PERFORM MAKE-JOB
     MOVE 8 TO WS-CX
     MOVE 100 TO WS-CY
     MOVE 8 TO WS-CZ
     MOVE 3 TO WS-HR
     MOVE 3 TO WS-VR
     MOVE 0 TO CV-MODE
     MOVE -1 TO CV-FLOOR
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 7 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 7 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid marks the block next to the centre" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-X
     MOVE 102 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid marks (9, 102, 8) (squares add to 0.53)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid does not mark (11, 100, 8) (outside the radius)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 8 TO WS-X
     MOVE 104 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid does not mark (8, 104, 8) (above the top)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 98 TO WS-Y
     MOVE 8 TO WS-X
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid marks (8, 98, 8) with no floor cut" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-MARKS
     MOVE "test carvers ellipsoid mark count of the sphere of radius 3" TO TL-CASE
     MOVE 136 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM MAKE-JOB
     MOVE -0.5 TO CV-FLOOR
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 8 TO WS-X
     MOVE 98 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers cave floor -0.5 cuts the bottom: (8, 98, 8) is not marked" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 99 TO WS-Y
     PERFORM MARK-AT
     MOVE "test carvers cave floor -0.5: yd = -0.5 exactly is cut at y 99" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-Y
     PERFORM MARK-AT
     MOVE "test carvers cave floor -0.5: (8, 100, 8) is marked" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a sphere too far from the chunk marks nothing; one at the chunk edge marks only the part inside
     PERFORM MAKE-JOB
     MOVE 60 TO WS-CX
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     PERFORM COUNT-MARKS
     MOVE "test carvers ellipsoid beyond 16 + 2 radii of the chunk centre marks nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-CX
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 15 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM MARK-AT
     MOVE "test carvers ellipsoid centred on the next chunk's first block marks the border column" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the canyon test: factors 1.0, the squares plus yd * yd / 6 must stay below 1: at (8, 105, 8) with radius (3, 9): yd = 0.5
     PERFORM MAKE-JOB
     MOVE 1 TO CV-MODE
     MOVE 9 TO WS-VR
     MOVE 8 TO WS-CX
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Z
     MOVE 108 TO WS-Y
     PERFORM MARK-AT
     MOVE "test carvers canyon marks (8, 108, 8): yd 0.944, yd squared over 6 is 0.149" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-X
     MOVE 100 TO WS-Y
     PERFORM MARK-AT
     MOVE "test carvers canyon does not mark (12, 100, 8): outside the horizontal radius" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM MAKE-JOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 384
         MOVE 1 TO CV-WIDTH(WS-I)
     END-PERFORM
     MOVE 1 TO CV-WIDTH(165)
     MOVE 100 TO CV-WIDTH(164)
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 7 TO WS-X
     MOVE 7 TO WS-Z
     MOVE 100 TO WS-Y
     PERFORM MARK-AT
     MOVE "test carvers canyon layer factor 1 marks (7, 100, 7) (y 100: index 164)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MARKED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the clamps at the borders of the chunk and of the mask, and a sphere beyond the chunk in z only
     PERFORM MAKE-JOB
     MOVE 0 TO CV-MODE
     MOVE -1 TO CV-FLOOR
     MOVE 2 TO WS-CX
     MOVE 310 TO WS-CY
     MOVE 2 TO WS-CZ
     MOVE 3 TO WS-HR
     MOVE 3 TO WS-VR
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 14 TO WS-CX
     MOVE -60 TO WS-CY
     MOVE 14 TO WS-CZ
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 8 TO WS-CX
     MOVE 60 TO WS-CZ
     MOVE 100 TO WS-CY
     CALL "CARVER-ELLIPSOID" USING WS-JOB WS-CX WS-CY WS-CZ WS-HR WS-VR
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-X
     MOVE 310 TO WS-Y
     MOVE 0 TO WS-Z
     PERFORM MARK-AT
     ADD WS-MARKED TO WS-BAD
     MOVE 15 TO WS-X
     MOVE -60 TO WS-Y
     MOVE 15 TO WS-Z
     PERFORM MARK-AT
     ADD WS-MARKED TO WS-BAD
     MOVE 8 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 15 TO WS-Z
     PERFORM MARK-AT
     ADD WS-MARKED TO WS-BAD
     MOVE "test carvers ellipsoids at the chunk and mask borders mark the border blocks and nothing beyond in z" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a source chunk whose canyon starts, carved into itself; canyons and caves from many seeds mark blocks
     MOVE 2 TO WS-K
     MOVE 0 TO WS-U64
     MOVE 0 TO WS-SZ
     MOVE 0 TO WS-SX
     MOVE 1 TO WS-I32
     PERFORM UNTIL WS-I32 = 0 OR WS-SX > 3000
         ADD 1 TO WS-SX
         CALL "CARVER-START-DRAW" USING WS-U64 WS-K WS-SX WS-SZ WS-RND WS-F
         IF WS-F <= CV-PROB-CANYON
             MOVE 0 TO WS-I32
         END-IF
     END-PERFORM
     PERFORM MAKE-JOB
     MOVE WS-SX TO T-CX
     MOVE WS-SZ TO T-CZ
     CALL "CARVER-SOURCE" USING WS-JOB WS-SX WS-SZ
     PERFORM COUNT-MARKS
     MOVE "test carvers the canyon of a source chunk carves its own chunk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-COUNT > 0 AND CV-MODE = 1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         PERFORM MAKE-JOB
         MOVE 0 TO T-CX
         MOVE 0 TO T-CZ
         MOVE 0 TO CV-SX
         MOVE 0 TO CV-SZ
         MOVE WS-K TO WS-U64
         CALL "JRAND-SET-SEED" USING WS-RND WS-U64
         CALL "CARVER-CANYON" USING WS-JOB WS-RND
         PERFORM COUNT-MARKS
         IF WS-COUNT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "test carvers a canyon started inside the chunk marks blocks (12 seeds)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-MARKED
     MOVE -56 TO WS-X
     MOVE 47 TO WS-Y
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 60
         PERFORM MAKE-JOB
         MOVE 0 TO T-CX
         MOVE 0 TO T-CZ
         MOVE 0 TO CV-SX
         MOVE 0 TO CV-SZ
         MOVE WS-K TO WS-U64
         CALL "JRAND-SET-SEED" USING WS-RND WS-U64
         CALL "CARVER-CAVE" USING WS-JOB WS-RND WS-X WS-Y
         PERFORM COUNT-MARKS
         ADD WS-COUNT TO WS-MARKED
     END-PERFORM
     MOVE "test carvers caves started inside the chunk mark blocks (60 seeds)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-MARKED > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   applying the mask (5.6), on a stone chunk with the aquifer absent (the global fluid decides)
     PERFORM MAKE-JOB
     PERFORM FILL-STONE
     MOVE -64 TO WS-Y
     PERFORM SET-BEDROCK-LAYER
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Z
     MOVE 120 TO WS-Y
     PERFORM MARK-SET
     MOVE 40 TO WS-Y
     PERFORM MARK-SET
     MOVE -60 TO WS-Y
     PERFORM MARK-SET
     MOVE -64 TO WS-Y
     PERFORM MARK-SET
     MOVE 3 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 62 TO WS-Y
     PERFORM MARK-SET
     MOVE 61 TO WS-Y
     PERFORM MARK-SET
     MOVE 60 TO WS-Y
     PERFORM MARK-SET
*>   column (3, 6): the run 60 to 62 under sea level, grass at its top (62), dirt below it at 59
     MOVE 8 TO WS-WANT
     COMPUTE WS-CELL = (62 + 64) * 256 + 6 * 16 + 3 + 1
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 8 TO CE-STATE(WS-CELL)
     COMPUTE WS-CELL = (59 + 64) * 256 + 6 * 16 + 3 + 1
     MOVE 9 TO CE-STATE(WS-CELL)
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         MOVE WS-X TO WS-K
         CALL "CARVER-APPLY-ROW" USING WS-JOB WS-K
     END-PERFORM
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Z
     MOVE 120 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: a carved block above sea level is air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: a carved block below sea level in the open is water" TO TL-CASE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -60 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: a carved block at y -60 is lava (the carver lava level is -54)" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: bedrock is never carved" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     MOVE 6 TO WS-Z
     MOVE 60 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: the run of three carved blocks under grass is water" TO TL-CASE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 59 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: dirt below a carved grassy run stays dirt when the run became water" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   regrassing: grass at y 70 carved with the air above 63... the run 70 to 71 over dirt at 69 gives grass at 69
     PERFORM MAKE-JOB
     PERFORM FILL-STONE
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     COMPUTE WS-CELL = (71 + 64) * 256 + 2 * 16 + 4 + 1
     MOVE 8 TO CE-STATE(WS-CELL)
     COMPUTE WS-CELL = (70 + 64) * 256 + 2 * 16 + 4 + 1
     MOVE 9 TO CE-STATE(WS-CELL)
     MOVE 4 TO WS-X
     MOVE 2 TO WS-Z
     MOVE 71 TO WS-Y
     PERFORM MARK-SET
     MOVE 4 TO WS-K
     CALL "CARVER-APPLY-ROW" USING WS-JOB WS-K
     MOVE 71 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: a carved grass block above sea level is air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-Y
     PERFORM STATE-AT
     MOVE "test carvers apply: the dirt under a carved grass block is regrassed" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB

*>   the whole stage for chunk (-2, -2) of seed 0: the room of 10.1 is air at its centre; two runs give the same bytes
     PERFORM MAKE-JOB
     PERFORM FILL-STONE
     MOVE -2 TO T-CX
     MOVE -2 TO T-CZ
     PERFORM RUN-STAGE
     MOVE WS-A TO WS-REF
     MOVE -28 TO WS-X
     MOVE 96 TO WS-Y
     MOVE -18 TO WS-Z
     COMPUTE WS-K = WS-X + 32
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     COMPUTE WS-CELL = (96 + 64) * 256 + (WS-Z + 32) * 16 + WS-K + 1
     MOVE "test carvers stage: the centre of the room of 10.1 (-28, 96, -18) is air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers stage: carving leaves stone at the bottom row y -64 (no carving at the lowest layer)" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF CE-STATE(WS-I) NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         IF CE-STATE(WS-I) NOT = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "test carvers stage: the chunk has carved blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-COUNT > 100
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     PERFORM MAKE-JOB
     PERFORM FILL-STONE
     MOVE -2 TO T-CX
     MOVE -2 TO T-CZ
     PERFORM RUN-STAGE
     MOVE "test carvers stage: the same seed and chunk give the same bytes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-A = WS-REF
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test carvers stage: GS-CARVER counted 2 x 305 steps" TO TL-CASE
     MOVE 610 TO TL-EXPECTED-N
     MOVE GS-CARVER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     MOVE "test carvers the stage has 305 steps (289 source chunks and 16 rows of the mask)" TO TL-CASE
     MOVE 305 TO TL-EXPECTED-N
     MOVE GJ-STEPS-CARVERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 MAKE-JOB.
     INITIALIZE WS-JOB
     MOVE 1 TO T-ACTIVE
     MOVE 3 TO T-DIM
     MOVE 0 TO T-CX
     MOVE 0 TO T-CZ
     MOVE 0 TO T-AQ-READY
     MOVE LOW-VALUES TO T-CV
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 384
         MOVE 1 TO CV-WIDTH(WS-I)
     END-PERFORM
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING T-ADDR
     SET ADDRESS OF WS-A TO T-ADDR.

 FILL-STONE.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE 1 TO CE-STATE(WS-I)
     END-PERFORM.

 SET-BEDROCK-LAYER.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
         MOVE 7 TO CE-STATE(WS-CELL)
     END-PERFORM.

 MARK-SET.
     COMPUTE WS-CELL = (WS-Y + 63) + (WS-Z + 16 * WS-X) * 376 + 1
     MOVE "1" TO T-CV-MASK(WS-CELL).

 MARK-AT.
     COMPUTE WS-CELL = (WS-Y + 63) + (WS-Z + 16 * WS-X) * 376 + 1
     MOVE 0 TO WS-MARKED
     IF T-CV-MASK(WS-CELL) = "1"
         MOVE 1 TO WS-MARKED
     END-IF.

 COUNT-MARKS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 96256
         IF T-CV-MASK(WS-I) = "1"
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 STATE-AT.
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-CELL) TO WS-WANT.

 RUN-STAGE.
     MOVE 0 TO T-SUB
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GJ-STEPS-CARVERS
         MOVE WS-I TO T-SUB
         CALL "GEN-STAGE-CARVERS" USING WS-JOB
     END-PERFORM.

*> CHECK-n: the float WS-F times 10 to the n against WS-WANT, to within one unit (the document gives about the last digit);
*> the observed is WS-WANT when they agree, else the value
 CHECK-FOUR.
     COMPUTE WS-DIFF ROUNDED = WS-F * 10000 - WS-WANT
     PERFORM CHECK-DIFF.
 CHECK-FIVE-LOW.
     COMPUTE WS-DIFF ROUNDED = WS-F * 100000 - WS-WANT
     PERFORM CHECK-DIFF.
 CHECK-SIX.
     COMPUTE WS-DIFF ROUNDED = WS-F * 1000000 - WS-WANT
     PERFORM CHECK-DIFF.
 CHECK-SEVEN.
     COMPUTE WS-DIFF ROUNDED = WS-F * 10000000 - WS-WANT
     PERFORM CHECK-DIFF.
 CHECK-DIFF.
     MOVE WS-WANT TO TL-EXPECTED-N
     IF WS-DIFF >= -1 AND WS-DIFF <= 1
         MOVE WS-WANT TO TL-OBSERVED-N
     ELSE
         COMPUTE TL-OBSERVED-N = WS-WANT + WS-DIFF
     END-IF.
 END PROGRAM TEST-CARVERS.
 COPY CORETEST.
