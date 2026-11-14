*> Particles part 4 (docs/protocol/42-particles-4-block-item-dust-ambient.md), sections 1 to 3: the conventions,
*> the table of the 33 types and the terrain particles. Draws are passed in as tables (a nextFloat as a
*> FLOAT-LONG in [0, 1), a nextInt(n) as floor(r * n)); see particles-42-2.cob.
*>
*> Entry points for the integrator (inputs):
*>   P4-QUAD-VEL-NEW     PCL x y z vx vy vz draws(7): the SingleQuadParticle velocity constructor.
*>   P4-TERRAIN-NEW      PCL P4X x y z vx vy vz tint-flag tint-argb draws(9): TerrainParticle.
*>   P4-TERRAIN-GUARD    air piston no-terrain-flag, create out: the creation guard of 3.3.
*>   P4-BREAK-COUNT / P4-BREAK-CELL: the break burst of 3.6 (box, i, j, k, block position).
*>   P4-CRACK-POS / P4-CRACK-APPLY: the hit crack of 3.7.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-QUAD-VEL-NEW.
*> Section 1 and 4.1/4.3: the SingleQuadParticle constructor with a velocity: USING PCL, x, y, z, vx, vy, vz,
*> draws (1-6 the normalised burst, 7 the quad size draw).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     GOBACK.
 END PROGRAM P4-QUAD-VEL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-CONV-FACTS.
*> Section 1: USING fact (1 burst draws 6, 2 quad size draws 1, 3 position-only draws 2, 4 velocity
*> constructor draws 7), value out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACT                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-FACT L-VALUE.
     EVALUATE L-FACT
         WHEN 1
             MOVE 6 TO L-VALUE
         WHEN 2
             MOVE 1 TO L-VALUE
         WHEN 3
             MOVE 2 TO L-VALUE
         WHEN 4
             MOVE 7 TO L-VALUE
         WHEN OTHER
             MOVE 0 TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-CONV-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TYPE-COUNT.
*> Section 2: USING count out (33 types of this part).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 33 TO L-COUNT
     GOBACK.
 END PROGRAM P4-TYPE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TYPE-LIST.
*> Section 2: USING row (1 to 33, the order of the table), registry id out (0 for a row out of range).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IDS                 PIC X(99) VALUE
     "001002021022036040041042043044045046057062063064127067116094102095096097104126110111112113114121125".
 01 WS-ID-TABLE REDEFINES WS-IDS.
    05 WS-ID               PIC 999 OCCURS 33 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ID.
     IF L-ROW < 1 OR L-ROW > 33
         MOVE 0 TO L-ID
     ELSE
         MOVE WS-ID(L-ROW) TO L-ID
     END-IF
     GOBACK.
 END PROGRAM P4-TYPE-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TYPE-INFO.
*> Section 2: USING registry id, layer out (0 OPAQUE, 1 TRANSLUCENT, 9 chosen by sprite, -1 none here), section out
*> (PIC X(5): the section of this document, spaces for an id that is not a type of this part).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(9) VALUE "001 9 3  ".
    05 FILLER PIC X(9) VALUE "002 9 4  ".
    05 FILLER PIC X(9) VALUE "021 0 6  ".
    05 FILLER PIC X(9) VALUE "022 0 6  ".
    05 FILLER PIC X(9) VALUE "036 0 5  ".
    05 FILLER PIC X(9) VALUE "040-1 -  ".
    05 FILLER PIC X(9) VALUE "041 0 8  ".
    05 FILLER PIC X(9) VALUE "042 0 8  ".
    05 FILLER PIC X(9) VALUE "043 0 8  ".
    05 FILLER PIC X(9) VALUE "044 0 8  ".
    05 FILLER PIC X(9) VALUE "045 0 8  ".
    05 FILLER PIC X(9) VALUE "046 0 8  ".
    05 FILLER PIC X(9) VALUE "057 9 7  ".
    05 FILLER PIC X(9) VALUE "062 9 7  ".
    05 FILLER PIC X(9) VALUE "063 9 7  ".
    05 FILLER PIC X(9) VALUE "064 9 7  ".
    05 FILLER PIC X(9) VALUE "127 9 7  ".
    05 FILLER PIC X(9) VALUE "067 010.1".
    05 FILLER PIC X(9) VALUE "116 010.1".
    05 FILLER PIC X(9) VALUE "094 0 9  ".
    05 FILLER PIC X(9) VALUE "102 0 9  ".
    05 FILLER PIC X(9) VALUE "095 010.2".
    05 FILLER PIC X(9) VALUE "096 010.2".
    05 FILLER PIC X(9) VALUE "097 010.2".
    05 FILLER PIC X(9) VALUE "104 011  ".
    05 FILLER PIC X(9) VALUE "126 112  ".
    05 FILLER PIC X(9) VALUE "110 013  ".
    05 FILLER PIC X(9) VALUE "111 013  ".
    05 FILLER PIC X(9) VALUE "112 013  ".
    05 FILLER PIC X(9) VALUE "113 013  ".
    05 FILLER PIC X(9) VALUE "114 013  ".
    05 FILLER PIC X(9) VALUE "121 9 3.5".
    05 FILLER PIC X(9) VALUE "125 9 3.4".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 33 TIMES.
       10 WS-RID           PIC 999.
       10 WS-RLAYER        PIC XX.
       10 WS-RSEC          PIC X(4).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 01 L-SECTION              PIC X(5).
 PROCEDURE DIVISION USING L-ID L-LAYER L-SECTION.
     MOVE -1 TO L-LAYER
     MOVE SPACES TO L-SECTION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 33
         IF WS-RID(WS-I) = L-ID
             MOVE FUNCTION NUMVAL(WS-RLAYER(WS-I)) TO L-LAYER
             MOVE FUNCTION TRIM(WS-RSEC(WS-I)) TO L-SECTION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM P4-TYPE-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-SCALE-CLAMP.
*> Section 2 (ScalableParticleOptionsBase): USING scale, clamped scale out: within 0.01 to 4.0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCALE                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SCALE L-OUT.
     MOVE L-SCALE TO L-OUT
     IF L-OUT < 0.01
         MOVE 0.01 TO L-OUT
     END-IF
     IF L-OUT > 4.0
         MOVE 4.0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM P4-SCALE-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TERRAIN-NEW.
*> Section 3.1 TerrainParticle: USING PCL, P4X, x, y, z, vx, vy, vz, tint flag (1 when the state has a tint source of
*> index 0), tint argb (BINARY-DOUBLE, the terrain particle colour; only the low 24 bits count), draws (1-6 the
*> burst, 7 the quad size, 8 uo, 9 vo). gravity 1, colours 0.6 times the tint channels, quadSize halved,
*> uo = r * 3, vo = r * 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLP4X.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-TINT                 BINARY-LONG.
 01 L-ARGB                 BINARY-DOUBLE.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL P4X L-X L-Y L-Z L-VX L-VY L-VZ L-TINT L-ARGB L-DRAWS.
     CALL "P4-QUAD-VEL-NEW" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     MOVE 1.0 TO PC-GRAVITY
     MOVE 0.6 TO PC-RCOL PC-GCOL PC-BCOL
     IF L-TINT NOT = 0
         CALL "PART-RGB24" USING L-ARGB WS-R WS-G WS-B
         COMPUTE PC-RCOL = PC-RCOL * WS-R
         COMPUTE PC-GCOL = PC-GCOL * WS-G
         COMPUTE PC-BCOL = PC-BCOL * WS-B
     END-IF
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE / 2
     COMPUTE X4-UO = L-DRAW(8) * 3.0
     COMPUTE X4-VO = L-DRAW(9) * 3.0
     GOBACK.
 END PROGRAM P4-TERRAIN-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-WINDOW.
*> Section 3.2 and 7.1: USING uo, vo, sprite corners (u0, u1, v0, v1), window out (U0, U1, V0, V1):
*> U0 = getU((uo + 1) / 4), U1 = getU(uo / 4), V0 = getV(vo / 4), V1 = getV((vo + 1) / 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UO                   FLOAT-LONG.
 01 L-VO                   FLOAT-LONG.
 01 L-SPRITE.
    05 L-S                 FLOAT-LONG OCCURS 4 TIMES.
 01 L-WINDOW.
    05 L-W                 FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-UO L-VO L-SPRITE L-WINDOW.
     COMPUTE L-W(1) = L-S(1) + (L-S(2) - L-S(1)) * ((L-UO + 1) / 4)
     COMPUTE L-W(2) = L-S(1) + (L-S(2) - L-S(1)) * (L-UO / 4)
     COMPUTE L-W(3) = L-S(3) + (L-S(4) - L-S(3)) * (L-VO / 4)
     COMPUTE L-W(4) = L-S(3) + (L-S(4) - L-S(3)) * ((L-VO + 1) / 4)
     GOBACK.
 END PROGRAM P4-WINDOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-TERRAIN-GUARD.
*> Section 3.3: USING air (0/1), moving piston (0/1), shouldSpawnTerrainParticles (0/1), create out (0/1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-PISTON               BINARY-LONG.
 01 L-SHOULD               BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-PISTON L-SHOULD L-CREATE.
     MOVE 1 TO L-CREATE
     IF L-AIR NOT = 0 OR L-PISTON NOT = 0 OR L-SHOULD = 0
         MOVE 0 TO L-CREATE
     END-IF
     GOBACK.
 END PROGRAM P4-TERRAIN-GUARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-NO-TERRAIN.
*> Section 3.3: USING block name (PIC X(32), no namespace), flag out: 1 for the two blocks built with
*> noTerrainParticles (barrier, structure_void).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-NAME = "barrier" OR L-NAME = "structure_void"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM P4-NO-TERRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-CRUMBLE-FIX.
*> Section 3.4 (after P4-TERRAIN-NEW): USING PCL, draw (nextInt(10) as r): velocity exactly zero, lifetime =
*> floor(r * 10) + 1.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-R.
     MOVE 0 TO PC-XD PC-YD PC-ZD
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-R * 10) + 1
     GOBACK.
 END PROGRAM P4-CRUMBLE-FIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-PILLAR-FIX.
*> Section 3.5 (after P4-TERRAIN-NEW): USING PCL, vy (the call's y velocity), g1, g2, g3 (the gaussians), draw
*> (nextInt(20) as r): speed (g1 / 30, vy + g2 / 2, g3 / 30), lifetime = 20 + floor(r * 20).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-VY                   FLOAT-LONG.
 01 L-G1                   FLOAT-LONG.
 01 L-G2                   FLOAT-LONG.
 01 L-G3                   FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-VY L-G1 L-G2 L-G3 L-R.
     COMPUTE PC-XD = L-G1 / 30.0
     COMPUTE PC-YD = L-VY + L-G2 / 2.0
     COMPUTE PC-ZD = L-G3 / 30.0
     COMPUTE PC-LIFETIME = 20 + FUNCTION INTEGER-PART(L-R * 20)
     GOBACK.
 END PROGRAM P4-PILLAR-FIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-BREAK-COUNT.
*> Section 3.6: USING box (x0, y0, z0, x1, y1, z1), count out, nx, ny, nz out: n = max(2, ceil(min(1, extent) /
*> 0.25)) per axis, count = nx * ny * nz.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-COUNT L-NX L-NY L-NZ.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-S = L-B(WS-A + 3) - L-B(WS-A)
         IF WS-S > 1
             MOVE 1 TO WS-S
         END-IF
         COMPUTE WS-N = FUNCTION INTEGER(WS-S / 0.25)
         IF WS-N * 0.25 < WS-S - 0.0000000001
             ADD 1 TO WS-N
         END-IF
         IF WS-N < 2
             MOVE 2 TO WS-N
         END-IF
         EVALUATE WS-A
             WHEN 1
                 MOVE WS-N TO L-NX
             WHEN 2
                 MOVE WS-N TO L-NY
             WHEN OTHER
                 MOVE WS-N TO L-NZ
         END-EVALUATE
     END-PERFORM
     COMPUTE L-COUNT = L-NX * L-NY * L-NZ
     GOBACK.
 END PROGRAM P4-BREAK-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-BREAK-CELL.
*> Section 3.6: USING box, block position P (x, y, z), i, j, k (0-based, i outer), position out, velocity bias out:
*> f = (i + 0.5) / n, position = P + f * s + box minimum, bias = f - 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-P.
    05 L-PP                FLOAT-LONG OCCURS 3 TIMES.
 01 L-I                    BINARY-LONG.
 01 L-J                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-BIAS.
    05 L-BI                FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-BOX L-P L-I L-J L-K L-POS L-BIAS.
     CALL "P4-BREAK-COUNT" USING L-BOX WS-COUNT WS-NX WS-NY WS-NZ
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-S = L-B(WS-A + 3) - L-B(WS-A)
         IF WS-S > 1
             MOVE 1 TO WS-S
         END-IF
         EVALUATE WS-A
             WHEN 1
                 MOVE WS-NX TO WS-N
                 MOVE L-I TO WS-IDX
             WHEN 2
                 MOVE WS-NY TO WS-N
                 MOVE L-J TO WS-IDX
             WHEN OTHER
                 MOVE WS-NZ TO WS-N
                 MOVE L-K TO WS-IDX
         END-EVALUATE
         COMPUTE WS-F = (WS-IDX + 0.5) / WS-N
         COMPUTE L-O(WS-A) = L-PP(WS-A) + WS-F * WS-S + L-B(WS-A)
         COMPUTE L-BI(WS-A) = WS-F - 0.5
     END-PERFORM
     GOBACK.
 END PROGRAM P4-BREAK-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-CRACK-POS.
*> Section 3.7: USING block position P, shape bounds B (x0, y0, z0, x1, y1, z1), face (0 DOWN, 1 UP, 2 NORTH, 3 SOUTH,
*> 4 WEST, 5 EAST), draws u (three nextDouble, x y z), position out. coord = P + u * (max - min - 0.2) + 0.1 + min with
*> the widened f32 constants 0.20000000298023224 and 0.10000000149011612; the hit face axis is replaced by
*> P + min - 0.1 or P + max + 0.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-P.
    05 L-PP                FLOAT-LONG OCCURS 3 TIMES.
 01 L-B.
    05 L-BB                FLOAT-LONG OCCURS 6 TIMES.
 01 L-FACE                 BINARY-LONG.
 01 L-U.
    05 L-UU                FLOAT-LONG OCCURS 3 TIMES.
 01 L-POS.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-P L-B L-FACE L-U L-POS.
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE L-O(WS-A) = L-PP(WS-A) + L-UU(WS-A)
             * (L-BB(WS-A + 3) - L-BB(WS-A) - 0.20000000298023224)
             + 0.10000000149011612 + L-BB(WS-A)
     END-PERFORM
     EVALUATE L-FACE
         WHEN 0
             COMPUTE L-O(2) = L-PP(2) + L-BB(2) - 0.10000000149011612
         WHEN 1
             COMPUTE L-O(2) = L-PP(2) + L-BB(5) + 0.10000000149011612
         WHEN 2
             COMPUTE L-O(3) = L-PP(3) + L-BB(3) - 0.10000000149011612
         WHEN 3
             COMPUTE L-O(3) = L-PP(3) + L-BB(6) + 0.10000000149011612
         WHEN 4
             COMPUTE L-O(1) = L-PP(1) + L-BB(1) - 0.10000000149011612
         WHEN OTHER
             COMPUTE L-O(1) = L-PP(1) + L-BB(4) + 0.10000000149011612
     END-EVALUATE
     GOBACK.
 END PROGRAM P4-CRACK-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-CRACK-APPLY.
*> Section 3.7 (after P4-TERRAIN-NEW with zero velocity): USING PCL: setPower(0.2) then scale(0.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POWER               FLOAT-LONG VALUE 0.20000000298023224.
 01 WS-SCALE               FLOAT-LONG VALUE 0.6000000238418579.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL.
     CALL "PCL-SET-POWER" USING PCL WS-POWER
     CALL "PCL-QUAD-SCALE" USING PCL WS-SCALE
     GOBACK.
 END PROGRAM P4-CRACK-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P4-HIT-SOUND.
*> Section 3.7 playBreakingSound: USING sound type volume, pitch, hit volume out = (volume + 1) / 8, hit pitch out =
*> pitch * 0.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VOLUME               FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-OUT-VOLUME           FLOAT-LONG.
 01 L-OUT-PITCH            FLOAT-LONG.
 PROCEDURE DIVISION USING L-VOLUME L-PITCH L-OUT-VOLUME L-OUT-PITCH.
     COMPUTE L-OUT-VOLUME = (L-VOLUME + 1.0) / 8.0
     COMPUTE L-OUT-PITCH = L-PITCH * 0.5
     GOBACK.
 END PROGRAM P4-HIT-SOUND.
