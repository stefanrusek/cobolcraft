*> Acceptance test of docs/protocol/35-worldgen-features-4 section 2 (random patches): TrapezoidInt (the three cases of 2.2 and the worked examples) and the patch idiom
*> count, offset, block_predicate_filter placed end to end from core/tests/fixtures/feat (the offsets with trapezoid providers, the filter, the single block feature) and compared
*> with the placements written out by hand from the draws.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-PTR1                USAGE POINTER.
 01 WS-PTR2                USAGE POINTER.
 01 WS-A                   PIC X(196608) BASED.
 01 WS-B                   PIC X(196608) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-MN                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-PL                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 7 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 1 TO CB-SOLID(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE "minecraft:dandelion" TO CB-KEY(4)
     MOVE "minecraft:poppy" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     MOVE 1 TO CB-SOLID(8)
     MOVE "minecraft:lava" TO CB-KEY(9)
     MOVE "minecraft:tall_grass" TO CB-KEY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR1
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR2
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -7 TO WS-MN
     MOVE 7 TO WS-MX
     MOVE 0 TO WS-PL
     CALL "F354-TRAPEZOID" USING XR-STATE WS-MN WS-MX WS-PL WS-R
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 8 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     COMPUTE WS-T = WS-V - WS-W
     MOVE "acceptance US12 35-4§2 Random patches: `count`, `offset`, `block_predicate_filter`: trapezoid -7..7 plateau 0 is nextInt(8) - nextInt(8)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-R - WS-T
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE -4 TO WS-MN
     MOVE 1 TO WS-MX
     MOVE 3 TO WS-PL
     CALL "F354-TRAPEZOID" USING XR-STATE WS-MN WS-MX WS-PL WS-R
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 5 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 2 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     COMPUTE WS-T = -4 + WS-V + WS-W
     MOVE "acceptance US12 35-4§2 Random patches: `count`, `offset`, `block_predicate_filter`: trapezoid -4..1 plateau 3: span 5, lo 1, hi 4: -4 + nextInt(5) + nextInt(2) (the weeping-vine offset)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-R - WS-T
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-MN
     MOVE 4 TO WS-MX
     MOVE 4 TO WS-PL
     CALL "F354-TRAPEZOID" USING XR-STATE WS-MN WS-MX WS-PL WS-R
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 5 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE WS-V TO WS-T
     MOVE "acceptance US12 35-4§2 Random patches: `count`, `offset`, `block_predicate_filter`: trapezoid with plateau equal to the span is one draw nextInt(span + 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-R - WS-T
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM NEW-WORLD
     CALL "FL-OPEN" USING WS-PTR2 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     PERFORM 6 TIMES
         MOVE 8 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
         COMPUTE WS-X = 21 + WS-V - WS-W
         MOVE 4 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
         COMPUTE WS-Y = 63 + WS-V - WS-W
         MOVE 8 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
         COMPUTE WS-Z = 37 + WS-V - WS-W
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = 0
             MOVE 4 TO WS-STATE
             COMPUTE WS-YB = WS-Y - 1
             CALL "FL-GET-STATE" USING WS-X WS-YB WS-Z WS-T
             CALL "FL-CLASS" USING WS-T WS-CLASS
             IF WS-CLASS NOT = 1
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     MOVE "patch_idiom" TO WS-KEY
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:patch_idiom" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FL-OPEN" USING WS-PTR1 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-ZERO WS-X WS-Y WS-Z WS-RESULT
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "acceptance US12 35-4§2 Random patches: `count`, `offset`, `block_predicate_filter`: the patch idiom (count 6, offsets trapezoid -7..7, -3..3, -7..7, air filter, single block) places what the draws say" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     FREE WS-PTR1
     FREE WS-PTR2
     GOBACK.

 NEW-WORLD.
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-K = (WS-Y + 64) * 256 + WS-I
             MOVE 0 TO CE-STATE(WS-K)
             IF WS-Y <= 62
                 MOVE 1 TO CE-STATE(WS-K)
             END-IF
         END-PERFORM
     END-PERFORM
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE WS-A TO WS-B
     CALL "FD-RESET"
     CALL "FL-OPEN" USING WS-PTR1 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA.
