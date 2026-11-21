*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 1.1.1, with doc 44 part 2 section 10): passenger attachments and riding offsets.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-1-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-KEY                PIC X(24).
 01 WS-RIDER              PIC X(24).
 01 WS-ROW                BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-SEAT               BINARY-LONG.
 COPY MOB181SEAT.
 PROCEDURE DIVISION.
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: 65 types are listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 65
     COMPUTE TL-OBSERVED-N ROUNDED = MR-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie seat 1 y 2.0125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2012500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "husk" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk seat 1 y 2.075" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2075000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: husk declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie_villager" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager seat 1 y 2.125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2125000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombie_villager declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombified_piglin" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin seat 1 y 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: zombified_piglin declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pillager" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager seat 1 y 2" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager riding offset -0.6" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -600000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pillager declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "skeleton" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton has 0 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wither_skeleton" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wither_skeleton is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wither_skeleton has 0 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wither_skeleton riding offset -0.875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -875000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wither_skeleton declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "giant" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: giant is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: giant has 0 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: giant riding offset -3.75" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -3750000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: giant declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "allay" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: allay is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: allay has 0 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: allay riding offset 0.04" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 40000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: allay declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ghast" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast seat 1 y 4.0625" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4062500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast riding offset 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 500000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ghast declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "happy_ghast" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast has 4 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 1 y 4.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 1 z 1.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 2 x -1.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -1700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 2 y 4.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 2 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 3 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 3 y 4.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 3 z -1.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -1700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 4 x 1.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 4 y 4.0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 4000000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast seat 4 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast riding offset 0.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 500000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: happy_ghast declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cat" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat seat 1 y 0.5125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 512500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cat declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "chicken" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken seat 1 y 0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 700000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken seat 1 z -0.1" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -100000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: chicken declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cow" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow seat 1 y 1.36875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1368750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: cow declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mooshroom" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom seat 1 y 1.36875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1368750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mooshroom declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "horse" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse seat 1 y 1.44375" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1443750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: horse declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "donkey" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey seat 1 y 1.1125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1112500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: donkey declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mule" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule seat 1 y 1.2125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1212500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: mule declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "skeleton_horse" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse seat 1 y 1.31875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1318750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: skeleton_horse declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "llama" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama seat 1 y 1.37" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1370000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama seat 1 z -0.3" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -300000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: llama declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pig" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig seat 1 y 0.86875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 868750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: pig declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ravager" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager seat 1 y 2.2625" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2262500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager seat 1 z -0.0625" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -62500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: ravager declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wolf" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf seat 1 y 0.81875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 818750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf seat 1 z -0.0625" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -62500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: wolf declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecart" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart seat 1 y 0.1875" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 187500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: minecart declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "phantom" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom seat 1 y 0.3375" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 337500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom riding offset -0.125" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = -125000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: phantom declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "vex" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex seat 1 y 0.7375" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 737500
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex riding offset 0.04" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 40000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: vex declares an offset True" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camel" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: camel is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: camel has 0 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: camel riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: camel declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "warden" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden seat 1 y 3.15" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 3150000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: warden declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sniffer" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer seat 1 y 2.09375" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2093750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: sniffer declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spider" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider seat 1 y 0.765" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 765000
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: spider declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "hoglin" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin is listed" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MIN(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin has 1 seat(s)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEATS(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin seat 1 x 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-X(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin seat 1 y 1.49375" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 1493750
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Y(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin seat 1 z 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-SEAT-Z(WS-ROW, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin riding offset None" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: hoglin declares an offset False" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = MR-RIDE-SET(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "creeper" TO WS-KEY
     CALL "M181-SEAT-FIND" USING WS-KEY WS-ROW
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a type that is not listed has no declared attachments" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-ROW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "horse" TO WS-KEY
     MOVE "zombie" TO WS-RIDER
     MOVE 1 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a zombie on a horse sits at the seat y 1.44375 plus its riding offset -0.7" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 743750
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "spider" TO WS-KEY
     MOVE "skeleton" TO WS-RIDER
     MOVE 1 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a skeleton on a spider (the jockey) sits at 0.065" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 65000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pig" TO WS-KEY
     MOVE "chicken" TO WS-RIDER
     MOVE 1 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a chicken has no riding offset: the seat y of the pig" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 868750
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "happy_ghast" TO WS-KEY
     MOVE "pillager" TO WS-RIDER
     MOVE 3 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a pillager on the third seat of a happy ghast" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 3400000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camel" TO WS-KEY
     MOVE "pig" TO WS-RIDER
     MOVE 1 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: a vehicle with no declared seat has it at the top of its box (camel 2.375)" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 2375000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nothing" TO WS-KEY
     MOVE "pig" TO WS-RIDER
     MOVE 1 TO WS-SEAT
     CALL "M181-RIDER-Y" USING WS-KEY WS-SEAT WS-RIDER WS-Y
     MOVE "acceptance US15 18§1.1.1 Passenger attachments and riding offsets: an unknown vehicle gives 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = 0
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-1-1-1.
