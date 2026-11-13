*> Implementation test of client/src/models-chest.cob (T5001; docs/protocol/52 section 3): CHEST-TEXTURE picks the texture of 3.3
*> (copper by stage whether waxed or not, ender, christmas over trapped, trapped, normal, left and right halves, none for the ender
*> chest); CHEST-BAKE bakes the closed chest of 3.4 to 3.6: 18 quads for a single chest, 15 for a half (the seam face of each cuboid
*> is not drawn), the body corners of worked example E1, the unwrap of E1 (the south rectangle (42, 33)-(56, 43) of the 64 x 64
*> texture) and the turn of the facing (E2: the south face of a chest facing west is its west face at x = 1/16).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHEST-BAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-FACING              PIC X(8).
 01 WS-TYPE                PIC X(8).
 01 WS-ID                  PIC X(80).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Q                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-K                   BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-E                   PIC -99.999.
 01 WS-LIST                PIC X(200).
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE

     MOVE "chest" TO WS-NAME MOVE "single" TO WS-TYPE
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-LENGTH
     MOVE "chest texture normal single" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "minecraft:entity/chest/normal" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "trapped_chest" TO WS-NAME MOVE "left" TO WS-TYPE
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-LENGTH
     MOVE "chest texture trapped left half" TO TL-CASE
     MOVE "minecraft:entity/chest/trapped_left" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ONE WS-ID WS-LENGTH
     MOVE "chest texture christmas overrides trapped" TO TL-CASE
     MOVE "minecraft:entity/chest/christmas_left" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "ender_chest" TO WS-NAME MOVE "right" TO WS-TYPE
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ONE WS-ID WS-LENGTH
     MOVE "chest texture ender has no halves and no christmas" TO TL-CASE
     MOVE "minecraft:entity/chest/ender" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "waxed_oxidized_copper_chest" TO WS-NAME MOVE "right" TO WS-TYPE
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ONE WS-ID WS-LENGTH
     MOVE "chest texture waxed oxidized copper right half" TO TL-CASE
     MOVE "minecraft:entity/chest/copper_oxidized_right" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "waxed_weathered_copper_chest" TO WS-NAME MOVE "single" TO WS-TYPE
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-LENGTH
     MOVE "chest texture weathered copper" TO TL-CASE
     MOVE "minecraft:entity/chest/copper_weathered" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "exposed_copper_chest" TO WS-NAME
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-LENGTH
     MOVE "chest texture exposed copper" TO TL-CASE
     MOVE "minecraft:entity/chest/copper_exposed" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "copper_chest" TO WS-NAME
     CALL "CHEST-TEXTURE" USING WS-NAME WS-TYPE WS-ZERO WS-ID WS-LENGTH
     MOVE "chest texture copper" TO TL-CASE
     MOVE "minecraft:entity/chest/copper" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "chest" TO WS-NAME MOVE "south" TO WS-FACING MOVE "single" TO WS-TYPE
     CALL "CHEST-BAKE" USING CLIENT-STATE WS-ONE WS-NAME WS-FACING WS-TYPE
     MOVE "chest bake a single chest has 18 quads" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 18 TO TL-EXPECTED-N
     MOVE BM-QUAD-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The first quad is the table's DOWN face, which is the top of the cuboid (the artwork is laid out for y down).
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE BM-Y(1, 1, WS-K) TO WS-E
         STRING WS-E " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE "chest bake the first face of the body is its top, at y 10/16 (the top rectangle of the strip)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " 00.625  00.625  00.625  00.625" TO TL-EXPECTED
     MOVE WS-LIST(1:WS-PTR - 2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The south face of the body (the quads are in the clockwise order of the mesher, from the corner of the vertex 0: (maxU, minV))
*>   (sixth quad of the six: down, up, west, north, east, south is quad 6): z 15/16, texture u from 10.5 to 14
*>   and v from 8.25 to 10.75 (the rectangle (42, 33)-(56, 43) of 64).
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE BM-Z(1, 6, WS-K) TO WS-E
         STRING WS-E " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE "chest bake body south face is at z 15/16" TO TL-CASE
     MOVE " 00.937  00.937  00.937  00.937" TO TL-EXPECTED
     MOVE WS-LIST(1:WS-PTR - 2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE BM-U(1, 6, WS-K) TO WS-E
         STRING WS-E " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
         MOVE BM-V(1, 6, WS-K) TO WS-E
         STRING WS-E " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE "chest bake body south face reads the rectangle (42, 33)-(56, 43)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING " 14.000  08.250 " " 10.500  08.250 " " 10.500  10.750 " " 14.000  10.750" DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE WS-LIST(1:WS-PTR - 2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Facing west: quad 6 (south face) is now the west face (shade west) at x 1/16.
     MOVE "west" TO WS-FACING
     CALL "CHEST-BAKE" USING CLIENT-STATE WS-ONE WS-NAME WS-FACING WS-TYPE
     MOVE "chest bake facing west turns the south face to the west face at x 1/16" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "5  00.062  00.062  00.062  00.062" TO TL-EXPECTED
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     MOVE BM-SHADE(1, 6) TO WS-DIGIT
     STRING WS-DIGIT " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE BM-X(1, 6, WS-K) TO WS-E
         STRING WS-E " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE WS-LIST(1:WS-PTR - 2) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "right" TO WS-TYPE MOVE "south" TO WS-FACING
     CALL "CHEST-BAKE" USING CLIENT-STATE WS-ONE WS-NAME WS-FACING WS-TYPE
     MOVE "chest bake a right half has 15 quads, none of them on its east seam" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 15 TO TL-EXPECTED-N
     MOVE BM-QUAD-COUNT(1) TO TL-OBSERVED-N
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(1)
         IF BM-SHADE(1, WS-Q) = DIR-EAST
             MOVE -1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "left" TO WS-TYPE
     CALL "CHEST-BAKE" USING CLIENT-STATE WS-ONE WS-NAME WS-FACING WS-TYPE
     MOVE "chest bake a left half has 15 quads, none of them on its west seam" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE BM-QUAD-COUNT(1) TO TL-OBSERVED-N
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > BM-QUAD-COUNT(1)
         IF BM-SHADE(1, WS-Q) = DIR-WEST
             MOVE -1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CHEST-BAKE.
