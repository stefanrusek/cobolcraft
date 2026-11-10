*> Acceptance test of docs/protocol/34-entity-models-2-humanoids-zombies-skeletons-piglins.md section 3 (Layer definitions): the layer table (mesh, texture size,
*> scaling), 3.1 baby zombie, 3.2 drowned, 3.3 zombie, 3.4 skeleton, 3.5 bogged, 3.6 parched, 3.7 adult piglin, 3.8 baby piglin, 3.9 armor stand and its armor,
*> and the validation items 1 to 4 and 7 of section 9 (feet line, model height, cuboid counts, small stand scale).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-2-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY CLEM1.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-LAYER               PIC X(32).
 01 WS-OK                  BINARY-LONG.
 01 WS-PARTS               BINARY-LONG.
 01 WS-CUBES               BINARY-LONG.
 01 WS-PN                  PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-INNER               FLOAT-LONG.
 01 WS-OUTER               FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
*> layer table: parts below the root, cuboids, texture size
     MOVE "ZOMBIE" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "ZOMBIE_BABY" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "HUSK" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "HUSK_BABY" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "GIANT" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "DROWNED" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "DROWNED_BABY" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "DROWNED_OUTER_LAYER" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "DROWNED_BABY_OUTER_LAYER" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "SKELETON" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-32
     MOVE "STRAY" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "WITHER_SKELETON" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "BOGGED" TO WS-LAYER
     MOVE 13 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-32
     MOVE "PARCHED" TO WS-LAYER
     MOVE 13 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "STRAY_OUTER_LAYER" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-32
     MOVE "BOGGED_OUTER_LAYER" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "PARCHED_OUTER_LAYER" TO WS-LAYER
     MOVE 7 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "PIGLIN" TO WS-LAYER
     MOVE 16 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "PIGLIN_BRUTE" TO WS-LAYER
     MOVE 16 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "ZOMBIFIED_PIGLIN" TO WS-LAYER
     MOVE 16 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "PIGLIN_BABY" TO WS-LAYER
     MOVE 9 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "ZOMBIFIED_PIGLIN_BABY" TO WS-LAYER
     MOVE 9 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "ARMOR_STAND" TO WS-LAYER
     MOVE 11 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     PERFORM CHECK-SIZE-64-64
     MOVE "ARMOR_STAND_SMALL" TO WS-LAYER
     MOVE 11 TO WS-E
     PERFORM CHECK-LAYER-CUBES
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "a layer outside the scope is not built" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
*> 3.1 baby zombie rows
     MOVE "ZOMBIE_BABY" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby zombie head pivot (0, 15.25, 0), two cuboids" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) * 10 + MM-NCUBES(WS-P)
     COMPUTE WS-E = 152.5 + 2
     PERFORM CHECK-NUM
     MOVE "baby head cuboid 1 tex (3, 3) size 6 x 6 x 6 grow 0; cuboid 2 tex (35, 3) grow 0.25 at y -6.15" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 100 + MC-V(WS-P, 1) + MC-GX(WS-P, 1) * 1000 + MC-U(WS-P, 2) * 0.01 + MC-GX(WS-P, 2) * 0.001 + MC-OY(WS-P, 2) * 0.0001
     COMPUTE WS-E = 303 + 0.35 + 0.00025 - 0.000615
     PERFORM CHECK-NUM
     MOVE "baby zombie head spans y 9 to 15, body 15 to 20, legs 20 to 24" TO WS-NAME
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     COMPUTE WS-O = MM-Y(WS-P) + MC-OY(WS-P, 1) + MC-H(WS-P, 1)
     MOVE 24 TO WS-E
     PERFORM CHECK-NUM
     MOVE "baby arms (28, 16) and (36, 16), size 2 x 5 x 2" TO WS-NAME
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     COMPUTE WS-O = MC-U(WS-P, 1) * 100 + MC-H(WS-P, 1)
     COMPUTE WS-E = 2805
     PERFORM CHECK-NUM
*> baby head top 9: head pivot 15.25 + origin -6.25 = 9
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby head top at y 9 (validation 2: 15 px high)" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) + MC-OY(WS-P, 1)
     MOVE 9 TO WS-E
     PERFORM CHECK-NUM
*> 3.2 drowned: player-style left limbs
     MOVE "DROWNED" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "drowned left arm tex (32, 48), not mirrored" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) + MC-MIRROR(WS-P, 1) * 10000
     COMPUTE WS-E = 32048
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "drowned left leg tex (16, 48), pivot (1.9, 12, 0), not mirrored" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) + MC-MIRROR(WS-P, 1) * 100000 + MM-X(WS-P) * 0.1
     COMPUTE WS-E = 16048 + 0.19
     PERFORM CHECK-NUM
     MOVE "DROWNED_OUTER_LAYER" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "drowned outer layer is grown 0.25" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
*> 3.4 skeleton: 2-wide limbs, leg pivots -2 and 2
     MOVE "SKELETON" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "skeleton right leg pivot -2, box (-1, 0, -1) 2 x 12 x 2" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 1000 + MC-OX(WS-P, 1) * 100 + MC-W(WS-P, 1) * 10 + MC-H(WS-P, 1) * 0.01
     COMPUTE WS-E = -2000 - 100 + 20 + 0.12
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "skeleton left leg pivot 2 mirrored tex (0, 16)" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 100 + MC-MIRROR(WS-P, 1) * 10 + MC-V(WS-P, 1) * 0.01
     COMPUTE WS-E = 200 + 10 + 0.16
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "skeleton right arm box (-1, -2, -1) 2 x 12 x 2 tex (40, 16)" TO WS-NAME
     COMPUTE WS-O = MC-OX(WS-P, 1) * 1000 + MC-OY(WS-P, 1) * 100 + MC-OZ(WS-P, 1) * 10 + MC-W(WS-P, 1) + MC-U(WS-P, 1) * 0.001
     COMPUTE WS-E = -1000 - 200 - 10 + 2 + 0.04
     PERFORM CHECK-NUM
*> 3.5 bogged mushrooms
     MOVE "BOGGED" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "red_mushroom_1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "red mushroom 1 pivot (3, -8, 3) rotation y pi/4, tex (50, 16), plane 6 x 4 x 0" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MM-Z(WS-P) + MM-YROT(WS-P) * 0.001 + MC-U(WS-P, 1) * 0.00001 + MC-D(WS-P, 1) * 0.1
     COMPUTE WS-E = 30000 - 800 + 3 + 0.7853982 * 0.001 + 50 * 0.00001
     PERFORM CHECK-NUM
     MOVE "brown_mushroom_4" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "brown mushroom 4 pivot (-2, -1, 4), rotation (-pi/2, 0, 3pi/4), tex (50, 28), box y -4" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 1000 + MM-Y(WS-P) * 100 + MM-Z(WS-P) * 10 + MM-XROT(WS-P) + MM-ZROT(WS-P) * 0.001 + MC-V(WS-P, 1) * 0.00001 + MC-OY(WS-P, 1) * 0.0001
     COMPUTE WS-E = -2000 - 100 + 40 - 1.5707964 + 2.3561945 * 0.001 + 28 * 0.00001 - 4 * 0.0001
     PERFORM CHECK-NUM
     MOVE "mushrooms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "mushrooms is a child of head with no cuboids" TO WS-NAME
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-I
     COMPUTE WS-O = MM-PARENT(WS-P) * 10 + MM-NCUBES(WS-P)
     COMPUTE WS-E = WS-I * 10
     PERFORM CHECK-NUM
*> 3.6 parched
     MOVE "PARCHED" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "parched body has three cuboids, the third grown 0.025 at tex (16, 48)" TO WS-NAME
     COMPUTE WS-O = MM-NCUBES(WS-P) * 1000 + MC-GX(WS-P, 3) * 10000 + MC-U(WS-P, 3) + MC-V(WS-P, 3) * 0.01
     COMPUTE WS-E = 3000 + 250 + 16 + 0.48
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "parched right arm pivot (-5.5, 2, 0), second cuboid (42, 33) box (-1.55, -2.025, -1.5)" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 1000 + MC-U(WS-P, 2) * 10 + MC-V(WS-P, 2) * 0.1 + MC-OX(WS-P, 2) * 0.001 + MC-OY(WS-P, 2) * 0.0001
     COMPUTE WS-E = -5500 + 420 + 3.3 - 0.00155 - 0.0002025
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "parched left leg second cuboid tex (4, 49), nothing mirrored" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 2) * 100 + MC-V(WS-P, 2) + MC-MIRROR(WS-P, 1) * 1000 + MC-MIRROR(WS-P, 2) * 10000
     COMPUTE WS-E = 449
     PERFORM CHECK-NUM
*> 3.7 adult piglin
     MOVE "PIGLIN" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "piglin head: four cuboids, the snout at tex (31, 1) box (-2, -4, -5) 4 x 4 x 1" TO WS-NAME
     COMPUTE WS-O = MM-NCUBES(WS-P) * 100000 + MC-U(WS-P, 2) * 1000 + MC-V(WS-P, 2) * 100 + MC-OX(WS-P, 2) * 10 + MC-OY(WS-P, 2)
     COMPUTE WS-E = 400000 + 31000 + 100 - 20 - 4
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "piglin hat is cleared: it exists and has no cuboids" TO WS-NAME
     COMPUTE WS-O = MM-NCUBES(WS-P) + WS-P
     COMPUTE WS-E = WS-P
     PERFORM CHECK-NUM
     MOVE "left_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left ear tex (51, 6) box (0, 0, -2) 1 x 5 x 4 at (4.5, -6, 0) z -pi/6" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) * 100 + MC-H(WS-P, 1) * 10 + MM-X(WS-P) * 0.1 + MM-ZROT(WS-P) * 0.001
     COMPUTE WS-E = 51000 + 600 + 50 + 0.45 - 0.0005235988
     PERFORM CHECK-NUM
     MOVE "left_sleeve" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left sleeve overlay tex (48, 48) grow 0.25 on the left arm box" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) + MC-GX(WS-P, 1) * 0.1 + MC-OX(WS-P, 1) * 0.01
     COMPUTE WS-E = 48048 + 0.025 - 0.01
     PERFORM CHECK-NUM
     MOVE "jacket" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "jacket tex (16, 32) box (-4, 0, -2) 8 x 12 x 4 on the body" TO WS-NAME
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-I
     COMPUTE WS-O = MM-PARENT(WS-P) * 1000 + MC-U(WS-P, 1) * 10 + MC-V(WS-P, 1) * 0.1
     COMPUTE WS-E = WS-I * 1000 + 160 + 3.2
     PERFORM CHECK-NUM
     MOVE "left_pants" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left pants tex (0, 48), right pants tex (0, 32)" TO WS-NAME
     MOVE "right_pants" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-I
     COMPUTE WS-O = MC-V(WS-P, 1) * 100 + MC-V(WS-I, 1)
     COMPUTE WS-E = 4800 + 32
     PERFORM CHECK-NUM
*> 3.8 baby piglin
     MOVE "PIGLIN_BABY" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "left_ear_r1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby left ear box: tex (0, 21) box (-0.5, -3, -2) 1 x 6 x 4 at (1, 1.75, 0) z -0.6109" TO WS-NAME
     COMPUTE WS-O = MC-V(WS-P, 1) * 10000 + MM-X(WS-P) * 1000 + MM-Y(WS-P) * 10 + MM-ZROT(WS-P) * 0.001
     COMPUTE WS-E = 210000 + 1000 + 17.5 - 0.0006109
     PERFORM CHECK-NUM
     MOVE "left_ear" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-I
     MOVE "baby ear parent has no cuboid and the box part is its child" TO WS-NAME
     COMPUTE WS-O = MM-PARENT(WS-P) * 10 + MM-NCUBES(WS-I)
     COMPUTE WS-E = WS-I * 10
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby piglin head cuboids: snout (21, 30) 3 x 3 x 1 and the 9 x 6 x 7 box" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 100 + MC-V(WS-P, 1) + MC-W(WS-P, 2) * 0.1 + MC-D(WS-P, 2) * 0.01
     COMPUTE WS-E = 2100 + 30 + 0.9 + 0.07
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "baby piglin leg ends at y 24 (20 + 4)" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) + MC-OY(WS-P, 1) + MC-H(WS-P, 1)
     MOVE 24 TO WS-E
     PERFORM CHECK-NUM
*> 3.9 armor stand
     MOVE "ARMOR_STAND" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "base_plate" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "base plate pivot (0, 12, 0), tex (0, 32), box (-6, 11, -6) 12 x 1 x 12 reaches y 24" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) + MC-OY(WS-P, 1) + MC-H(WS-P, 1)
     MOVE 24 TO WS-E
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "stand legs end at 23 (pivot 12, height 11)" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) + MC-OY(WS-P, 1) + MC-H(WS-P, 1)
     MOVE 23 TO WS-E
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "stand left arm tex (32, 16) box (0, -2, -1) mirrored" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) * 10 + MC-OX(WS-P, 1) + MC-MIRROR(WS-P, 1) * 100000
     COMPUTE WS-E = 32160 + 100000
     PERFORM CHECK-NUM
     MOVE "shoulder_stick" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "shoulder stick tex (0, 48) box (-4, 10, -1) 8 x 2 x 2" TO WS-NAME
     COMPUTE WS-O = MC-U(WS-P, 1) * 1000 + MC-V(WS-P, 1) * 10 + MC-OX(WS-P, 1) * 0.1 + MC-OY(WS-P, 1) * 0.001 + MC-W(WS-P, 1) * 0.00001
     COMPUTE WS-E = 480 - 0.4 + 0.01 + 0.00008
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "the stand model hides the hat (invisible, cuboid kept)" TO WS-NAME
     COMPUTE WS-O = MM-VISIBLE(WS-P) * 10 + MM-NCUBES(WS-P)
     MOVE 1 TO WS-E
     PERFORM CHECK-NUM
*>   small stand: the baby transform on the stand mesh (worked example 9)
     MOVE "ARMOR_STAND_SMALL" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "small stand head pivot (0, 12.75, 0) scale 0.75 spans 7.5 to 12.75" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) * 100 + MM-YSCALE(WS-P) + (MM-Y(WS-P) - 7 * MM-YSCALE(WS-P)) * 0.001
     COMPUTE WS-E = 1275 + 0.75 + 7.5 * 0.001
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "small stand arms (±2.5, 13, 0) scale 0.5" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 100 + MM-Y(WS-P) + MM-XSCALE(WS-P) * 0.1
     COMPUTE WS-E = 250 + 13 + 0.05
     PERFORM CHECK-NUM
     MOVE "base_plate" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "small stand plate pivot (0, 18, 0) spans 23.5 to 24" TO WS-NAME
     COMPUTE WS-O = MM-Y(WS-P) + (MC-OY(WS-P, 1)) * MM-YSCALE(WS-P) * 0.001 + (MC-OY(WS-P, 1) + MC-H(WS-P, 1)) * MM-YSCALE(WS-P) * 0.00001
     COMPUTE WS-E = 18 + 11 * 0.5 * 0.001 + 12 * 0.5 * 0.00001
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "small stand leg pivot (-0.95, 18, 0), bottom 23.5" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 10 + (MM-Y(WS-P) + 11 * MM-YSCALE(WS-P)) * 0.001
     COMPUTE WS-E = -9500 + 180 + 23.5 * 0.001
     PERFORM CHECK-NUM
*>   stand armor: the head at pivot y 1, the legs grown g - 0.1 at pivot y 11
     MOVE 0.5 TO WS-INNER
     MOVE 1.0 TO WS-OUTER
     MOVE 3 TO WS-SLOT
     CALL "EMD-STAND-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "stand armor leggings: leg pivot (-1.9, 11, 0), grow 0.4, ends at 23" TO WS-NAME
     COMPUTE WS-O = MM-X(WS-P) * 10000 + MM-Y(WS-P) * 100 + MC-GX(WS-P, 1) * 10 + (MM-Y(WS-P) + MC-OY(WS-P, 1) + MC-H(WS-P, 1)) * 0.001
     COMPUTE WS-E = -19000 + 1100 + 4 + 23 * 0.001
     PERFORM CHECK-NUM
     MOVE 1 TO WS-SLOT
     CALL "EMD-STAND-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "stand armor helmet: head at pivot y 1, grow 1.0, hat grow 1.5" TO WS-NAME
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-I
     COMPUTE WS-O = MM-Y(WS-P) * 100 + MC-GX(WS-P, 1) * 10 + MC-GX(WS-I, 1) * 0.1
     COMPUTE WS-E = 100 + 10 + 0.15
     PERFORM CHECK-NUM
     MOVE 2 TO WS-SLOT
     CALL "EMD-STAND-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "stand armor chestplate keeps body and arms" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-SLOT
     CALL "EMD-STAND-ARMOR" USING EMM-MODEL WS-SLOT WS-INNER WS-OUTER
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "stand armor boots keep the legs, grown 0.9" TO WS-NAME
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     COMPUTE WS-O = WS-CUBES * 10 + MC-GX(WS-P, 1)
     COMPUTE WS-E = 20.9
     PERFORM CHECK-NUM
*> validation 2: model height from head top to the feet line is 32 px for the zombie family and the skeletons
     MOVE "ZOMBIE" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM MODEL-EXTENT
     MOVE "zombie extent head top -8 to feet 24 = 32" TO WS-NAME
     COMPUTE WS-O = WS-HIGH - WS-LOW
     MOVE 32 TO WS-E
     PERFORM CHECK-NUM
     MOVE "SKELETON" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM MODEL-EXTENT
     MOVE "skeleton extent 32" TO WS-NAME
     COMPUTE WS-O = WS-HIGH - WS-LOW
     MOVE 32 TO WS-E
     PERFORM CHECK-NUM
     MOVE "PIGLIN" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM MODEL-EXTENT
     MOVE "adult piglin extent 32 (the head box starts at -8)" TO WS-NAME
     COMPUTE WS-O = WS-HIGH - WS-LOW
     MOVE 32 TO WS-E
     PERFORM CHECK-NUM
     MOVE "PARCHED" TO WS-LAYER
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM MODEL-EXTENT
     MOVE "parched extent 32 before grow" TO WS-NAME
     COMPUTE WS-O = WS-HIGH - WS-LOW
     MOVE 32 TO WS-E
     PERFORM CHECK-NUM
     STOP RUN.

*> model-space extent over the top-level parts (no rotation): lowest pivot + box top and highest pivot + box bottom (pivot scale 1)
 MODEL-EXTENT.
     MOVE 1000 TO WS-LOW
     MOVE -1000 TO WS-HIGH
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > MM-COUNT
         IF MM-PARENT(WS-I) = 1 AND MM-NCUBES(WS-I) > 0
             IF MM-Y(WS-I) + MC-OY(WS-I, 1) < WS-LOW
                 COMPUTE WS-LOW = MM-Y(WS-I) + MC-OY(WS-I, 1)
             END-IF
             IF MM-Y(WS-I) + MC-OY(WS-I, 1) + MC-H(WS-I, 1) > WS-HIGH
                 COMPUTE WS-HIGH = MM-Y(WS-I) + MC-OY(WS-I, 1) + MC-H(WS-I, 1)
             END-IF
         END-IF
     END-PERFORM.

 CHECK-LAYER-CUBES.
     CALL "EMD-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE SPACES TO WS-NAME
     STRING "layer " FUNCTION TRIM(WS-LAYER) " has this many cuboids" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM.

 CHECK-SIZE-64-64.
     MOVE SPACES TO WS-NAME
     STRING "layer " FUNCTION TRIM(WS-LAYER) " is 64 x 64" DELIMITED BY SIZE INTO WS-NAME
     COMPUTE WS-O = MM-TEXW * 100 + MM-TEXH
     MOVE 6464 TO WS-E
     PERFORM CHECK-NUM.

 CHECK-SIZE-64-32.
     MOVE SPACES TO WS-NAME
     STRING "layer " FUNCTION TRIM(WS-LAYER) " is 64 x 32" DELIMITED BY SIZE INTO WS-NAME
     COMPUTE WS-O = MM-TEXW * 100 + MM-TEXH
     MOVE 6432 TO WS-E
     PERFORM CHECK-NUM.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-2§3 Layer definitions: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 1000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-2-3.
