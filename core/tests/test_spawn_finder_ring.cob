*> Test of the ring geometry and the fitness of the noise spawn finder (docs/protocol/36-structures-1 section 4.9, 33 section 6.3): the probe of a ring
*> (SPAWN-RING-POINT: x = cx + (int)(sin(angle) * radius), z = cz + (int)(cos(angle) * radius), the angle and the radius 32-bit floats), the advance of
*> the angle and the radius (SPAWN-RING-NEXT: angle += step / radius in float, a new ring after 2 pi), the probe count and the sums of the offsets of every
*> ring of both passes (the doc's checksum tables), the first probes of the rings, and the fitness of a probe (SPAWN-FITNESS-OF: the spawn target points
*> of the overworld noise settings, the distance of a quantised value to its interval, the minimum over the points times 2048 squared plus x^2 + z^2) with
*> the worked examples.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPAWN-FINDER-RING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:overworld".
 01 WS-ROOT                BINARY-LONG.
 01 WS-BOXES               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RING-R              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TEXT                PIC X(1000).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 WS-VALUES.
    05 WS-V                BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-FIT                 BINARY-DOUBLE.
 01 WS-ED                  PIC -(17)9.
 01 WS-QX                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE

*>   Pass 1 around (0, 0): 4 rings, 65 probes.
     MOVE 0 TO WS-CX WS-CZ
     MOVE 2048 TO WS-MAX
     MOVE 512 TO WS-STEP
     PERFORM RUN-PASS
     MOVE "spawn ring pass 1: probes and offset sums of the rings 512, 1024, 1536, 2048 (36-1 4.9 table)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "512:7:-53:371,1024:13:-63:444,1536:19:-34:229,2048:26:-27:1777,total 65" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Pass 2: 16 rings, 862 probes.
     MOVE 512 TO WS-MAX
     MOVE 32 TO WS-STEP
     PERFORM RUN-PASS
     MOVE "spawn ring pass 2: probes and offset sums of the 16 rings of radius 32 to 512 (36-1 4.9 table)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "32:7:-3:24,64:13:-4:29,96:19:-3:14,128:26:-1:111,160:32:-4:94,192:38:-5:61,224:44:-1:4,256:51:-4:190,"
         & "288:57:-6:129,320:63:-1:52,352:70:-2:310,384:76:-3:231,416:82:-2:136,448:88:-3:17,480:95:-6:361,"
         & "512:101:-10:244,total 862" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Pass 2 around a centre: the offsets are added to it (the ring sums move by count x centre).
     MOVE 1000 TO WS-CX
     MOVE -2000 TO WS-CZ
     MOVE 32 TO WS-STEP
     MOVE 96 TO WS-MAX
     PERFORM RUN-PASS
     MOVE "spawn ring around the centre (1000, -2000): the sums are the offsets plus count x centre" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "32:7:6997:-13976,64:13:12996:-25971,96:19:18997:-37986,total 39" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   First probes of the rings (offsets from the centre, 36-1 4.9).
     MOVE 0 TO WS-CX WS-CZ
     MOVE 512 TO WS-STEP
     MOVE 512 TO WS-RADIUS
     PERFORM FIRST-PROBES
     MOVE "spawn ring: the first seven probes of the ring of radius 512" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "(0,512) (430,276) (465,-213) (72,-506) (-387,-334) (-490,145) (-143,491)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 32 TO WS-STEP
     MOVE 32 TO WS-RADIUS
     PERFORM FIRST-PROBES
     MOVE "spawn ring: the first seven probes of the ring of radius 32" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "(0,32) (26,17) (29,-13) (4,-31) (-24,-20) (-30,9) (-8,30)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 512 TO WS-STEP
     MOVE 1024 TO WS-RADIUS
     MOVE 3 TO WS-TOTAL
     PERFORM FIRST-PROBES-3
     MOVE "spawn ring: the first three probes of the ring of radius 1024 (angle step 0.5)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "(0,1024) (490,898) (861,553)" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Fitness of a probe from the five quantised values: the overworld settings of the content fixture hold the two spawn target points.
     MOVE "content/tests/fixtures/worldgen" TO WS-DIR
     CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
     MOVE WGN-CHILD(WS-ROOT, 16) TO WS-BOXES

*>   Worked example 1: probe (30, -17), the values -2500, 5000, 1250, -7500, -5000 (continents, erosion, temperature, vegetation, ridges).
     MOVE -2500 TO WS-V(1)
     MOVE 5000 TO WS-V(2)
     MOVE 1250 TO WS-V(3)
     MOVE -7500 TO WS-V(4)
     MOVE -5000 TO WS-V(5)
     MOVE 30 TO WS-X
     MOVE -17 TO WS-Z
     CALL "SPAWN-FITNESS-OF" USING WS-BOXES WS-X WS-Z WS-VALUES WS-FIT
     MOVE "spawn fitness worked example 1: probe (30, -17) is 8220835841189" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 8220835841189 TO TL-EXPECTED-N
     MOVE WS-FIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Example 2: continents 1.5 (v = 15000) is 5000 above the interval: d^2 = 25 000 000 in both points; at (0, 0) the fitness is 25000000 x 4194304.
     MOVE 15000 TO WS-V(1)
     MOVE 0 TO WS-V(2) WS-V(3) WS-V(4)
     MOVE -5000 TO WS-V(5)
     MOVE 0 TO WS-X WS-Z
     CALL "SPAWN-FITNESS-OF" USING WS-BOXES WS-X WS-Z WS-VALUES WS-FIT
     MOVE "spawn fitness: a value above its interval (continents 15000) gives d = 5000, so 25000000 x 2048^2 at (0, 0)" TO TL-CASE
     MOVE 104857600000000 TO TL-EXPECTED-N
     MOVE WS-FIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Inside every interval of point 2 (ridges 2000 in [1600, 10000]): the fitness is only x^2 + z^2.
     MOVE 0 TO WS-V(1) WS-V(2) WS-V(3) WS-V(4)
     MOVE 2000 TO WS-V(5)
     MOVE -3 TO WS-X
     MOVE 4 TO WS-Z
     CALL "SPAWN-FITNESS-OF" USING WS-BOXES WS-X WS-Z WS-VALUES WS-FIT
     MOVE "spawn fitness: a value inside the intervals of one point has m = 0, so the fitness is x^2 + z^2 (25)" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE WS-FIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The minimum over the points: ridges 0 is 1600 above the first point's maximum (-1600) and 1600 below the second's minimum (1600).
     MOVE 0 TO WS-V(5)
     MOVE 0 TO WS-X WS-Z
     CALL "SPAWN-FITNESS-OF" USING WS-BOXES WS-X WS-Z WS-VALUES WS-FIT
     MOVE "spawn fitness: ridges 0 is 1600 from both points: 1600^2 x 2048^2" TO TL-CASE
     MOVE 10737418240000 TO TL-EXPECTED-N
     MOVE WS-FIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The grid: x = -1 samples at -4, x = 3 at 0, x = 4 at 4 (SPAWN-ALIGN).
     MOVE "T" TO TL-MODE
     MOVE "spawn align: -1 gives -4, 3 gives 0, 4 gives 4, -4 gives -4, -5 gives -8" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         EVALUATE WS-K
             WHEN 1 MOVE -1 TO WS-X
             WHEN 2 MOVE 3 TO WS-X
             WHEN 3 MOVE 4 TO WS-X
             WHEN 4 MOVE -4 TO WS-X
             WHEN OTHER MOVE -5 TO WS-X
         END-EVALUATE
         CALL "SPAWN-ALIGN" USING WS-X WS-QX
         MOVE WS-QX TO WS-E1
         STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "-4 0 4 -4 -8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> One pass around (WS-CX, WS-CZ): WS-TEXT lists "radius:probes:sum x:sum z," per ring and the total.
 RUN-PASS.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-ANGLE WS-TOTAL WS-COUNT WS-SX WS-SZ
     MOVE WS-STEP TO WS-RADIUS
     MOVE WS-STEP TO WS-RING-R
     PERFORM UNTIL WS-RADIUS > WS-MAX
         CALL "SPAWN-RING-POINT" USING WS-CX WS-CZ WS-ANGLE WS-RADIUS WS-X WS-Z
         ADD 1 TO WS-COUNT WS-TOTAL
         COMPUTE WS-SX = WS-SX + WS-X
         COMPUTE WS-SZ = WS-SZ + WS-Z
         CALL "SPAWN-RING-NEXT" USING WS-ANGLE WS-RADIUS WS-STEP
         IF WS-RADIUS NOT = WS-RING-R
             PERFORM ADD-RING
             MOVE WS-RADIUS TO WS-RING-R
             MOVE 0 TO WS-COUNT WS-SX WS-SZ
         END-IF
     END-PERFORM
     MOVE WS-TOTAL TO WS-E1
     STRING "total " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR.

 ADD-RING.
     MOVE WS-RING-R TO WS-E1
     MOVE WS-COUNT TO WS-E2
     MOVE WS-SX TO WS-E3
     MOVE WS-SZ TO WS-E4
     STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) ":" FUNCTION TRIM(WS-E4) ","
         DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR.

*> The first seven probes of the ring of WS-RADIUS (WS-STEP its step) around (0, 0).
 FIRST-PROBES.
     MOVE 7 TO WS-TOTAL
     PERFORM FIRST-PROBES-3.

 FIRST-PROBES-3.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-ANGLE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-TOTAL
         CALL "SPAWN-RING-POINT" USING WS-CX WS-CZ WS-ANGLE WS-RADIUS WS-X WS-Z
         MOVE WS-X TO WS-E1
         MOVE WS-Z TO WS-E2
         IF WS-K > 1
             STRING " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
         STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) ")" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         CALL "SPAWN-RING-NEXT" USING WS-ANGLE WS-RADIUS WS-STEP
     END-PERFORM.
