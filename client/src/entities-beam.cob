*> The guardian's beam (docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md 11.4 and 11.6): ENTITY-BEAM-EMIT appends the beam of a guardian that has an active attack target
*> (EN-TGT, an entity of the replica or the local player) to RL-EN-VERTEX in the eye-relative world, BEAM-QUAD writes one quad from both sides. The image is the model row guardian_beam of
*> CLMODELS.cpy (an atlas slot of the entity atlas, code 0): the atlas cannot repeat an image, so the two crossing planes are cut into strips where the scrolling texture coordinate v crosses an
*> integer (v runs from -1 + ph over 2.5 a block), each strip drawn with v inside its image.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BEAM-QUAD.
*> USING CLIENT-STATE, corners (4 x (x y z u v) FLOAT-LONG, beam-local, u v inside the image), frame (12 FLOAT-LONG: sin a, cos a, sin b, cos b of the rotation about X by a then Y by b, the eye-relative
*> origin x y z, the atlas slot, the tint r g b, the brightness), tints (4 FLOAT-LONG, a factor of the tint at each corner): the quad's two triangles from each side (1 2 3, 1 3 4, then 1 3 2, 1 4 3), alpha 1, no sky term.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CORNERS.
    05 WS-C OCCURS 4 TIMES.
       10 WS-C-X           FLOAT-SHORT.
       10 WS-C-Y           FLOAT-SHORT.
       10 WS-C-Z           FLOAT-SHORT.
       10 WS-C-U           FLOAT-SHORT.
       10 WS-C-V           FLOAT-SHORT.
       10 WS-C-T           FLOAT-SHORT.
 01 WS-ORDER-DATA          PIC X(12) VALUE "123134132143".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 12 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-QUAD.
    05 L-Q                 FLOAT-LONG OCCURS 20 TIMES.
 01 L-FRAME.
    05 L-F                 FLOAT-LONG OCCURS 12 TIMES.
 01 L-TINTS.
    05 L-T4                FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-QUAD L-FRAME L-TINTS.
     IF RL-EN-COUNT + 12 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     COMPUTE WS-SLOT = L-F(8)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-N = WS-K * 5 - 4
         COMPUTE WS-T = L-Q(WS-N + 1) * L-F(2) - L-Q(WS-N + 2) * L-F(1)
         COMPUTE WS-Z = L-Q(WS-N + 1) * L-F(1) + L-Q(WS-N + 2) * L-F(2)
         MOVE WS-T TO WS-Y
         MOVE L-Q(WS-N) TO WS-X
         COMPUTE WS-T = WS-X * L-F(4) + WS-Z * L-F(3)
         COMPUTE WS-Z = WS-Z * L-F(4) - WS-X * L-F(3)
         COMPUTE WS-C-X(WS-K) = WS-T + L-F(5)
         COMPUTE WS-C-Y(WS-K) = WS-Y + L-F(6)
         COMPUTE WS-C-Z(WS-K) = WS-Z + L-F(7)
         COMPUTE WS-C-U(WS-K) = (EA-MT-X(WS-SLOT) + L-Q(WS-N + 3) * EA-MT-W(WS-SLOT)) / EA-W
         COMPUTE WS-C-V(WS-K) = (EA-MT-Y(WS-SLOT) + L-Q(WS-N + 4) * EA-MT-H(WS-SLOT)) / EA-H
         MOVE L-T4(WS-K) TO WS-C-T(WS-K)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         MOVE WS-ORD(WS-K) TO WS-N
         ADD 1 TO RL-EN-COUNT
         MOVE WS-C-X(WS-N) TO RL-EN-X(RL-EN-COUNT)
         MOVE WS-C-Y(WS-N) TO RL-EN-Y(RL-EN-COUNT)
         MOVE WS-C-Z(WS-N) TO RL-EN-Z(RL-EN-COUNT)
         MOVE WS-C-U(WS-N) TO RL-EN-U(RL-EN-COUNT)
         MOVE WS-C-V(WS-N) TO RL-EN-V(RL-EN-COUNT)
         MOVE L-F(12) TO RL-EN-B(RL-EN-COUNT)
         MOVE 1 TO RL-EN-A(RL-EN-COUNT)
         MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
         COMPUTE RL-EN-R(RL-EN-COUNT) = L-F(9) * WS-C-T(WS-N)
         COMPUTE RL-EN-G(RL-EN-COUNT) = L-F(10) * WS-C-T(WS-N)
         COMPUTE RL-EN-BLUE(RL-EN-COUNT) = L-F(11) * WS-C-T(WS-N)
     END-PERFORM
     GOBACK.
 END PROGRAM BEAM-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BEAM-EMIT.
*> USING CLIENT-STATE, replica row of a guardian or elder guardian with EN-TGT not 0, eye (3 FLOAT-LONG): the eye is the guardian's position plus its eye height (0.425, elder 0.99875, 21 section 2),
*> the end the middle of the target's box (the replica row's position plus half EN-BOX-HEIGHT; the local player: PL-X, PL-Y, PL-Z and 1.8). With the attack time t = EN-RS + 1 (the client side
*> attack time at the partial tick 1) and the attack scale t / duration (80, elder 60): the length L = |delta| + 1, the beam turned by b = pi / 2 - atan2(dz, dx) about Y after a = acos(dy / |delta|)
*> about X, the planes A-B and C-D of inner radius 0.2 and the cap P1..P4 of radius 0.282 at the angle th = -0.075 t, v from -1 + (t / 2 mod 1), tint (64 + trunc(191 s^2), 32 + trunc(191 s^2),
*> 128 - trunc(64 s^2)) / 255. Plane 1 strips first, then plane 2, then the cap (its v is 0.5 when floor(t) is even, else 0, up to +0.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-KEY                 PIC X(24) VALUE "guardian_beam".
 01 WS-BM                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-T-ROW               BINARY-LONG.
 01 WS-PI                  FLOAT-LONG.
 01 WS-EYE-H               FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-AT                  FLOAT-LONG.
 01 WS-ATK                 FLOAT-LONG.
 01 WS-DUR                 FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-TH                  FLOAT-LONG.
 01 WS-PH                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-YA                  FLOAT-LONG.
 01 WS-YB                  FLOAT-LONG.
 01 WS-VM                  FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PLANE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-RED                 BINARY-LONG.
 01 WS-GREEN               BINARY-LONG.
 01 WS-BLUE                BINARY-LONG.
 01 WS-QUAD.
    05 WS-Q                FLOAT-LONG OCCURS 20 TIMES.
 01 WS-FRAME.
    05 WS-F                FLOAT-LONG OCCURS 12 TIMES.
 01 WS-PT.
    05 WS-PX               FLOAT-LONG OCCURS 8 TIMES.
    05 WS-PZ               FLOAT-LONG OCCURS 8 TIMES.
 01 WS-ONES.
    05 WS-ONE              FLOAT-LONG OCCURS 4 TIMES VALUE 1.
 01 WS-RADIUS-DATA.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.2.
    05 FILLER              FLOAT-LONG VALUE 0.282.
    05 FILLER              FLOAT-LONG VALUE 0.282.
    05 FILLER              FLOAT-LONG VALUE 0.282.
    05 FILLER              FLOAT-LONG VALUE 0.282.
 01 WS-RADIUS REDEFINES WS-RADIUS-DATA.
    05 WS-R                FLOAT-LONG OCCURS 8 TIMES.
*> The angle of each point as a multiple of pi / 4 added to th: A pi (4), B 0, C pi / 2 (2), D 3 pi / 2 (6), P1 3 pi / 4 (3), P2 pi / 4 (1), P3 7 pi / 4 (7), P4 5 pi / 4 (5).
 01 WS-STEP-DATA           PIC X(8) VALUE "40263175".
 01 WS-STEP-TABLE REDEFINES WS-STEP-DATA.
    05 WS-STEP             PIC 9 OCCURS 8 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-BM
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = WS-BM AND EA-MT-TEX(WS-S) = 0
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     CALL "ENTITY-FIND" USING CLIENT-STATE EN-TGT(L-ROW) WS-T-ROW
     IF WS-SLOT = 0 OR (WS-T-ROW = 0 AND EN-TGT(L-ROW) NOT = PL-ENTITY-ID)
         GOBACK
     END-IF
     IF WS-T-ROW > 0
         MOVE EN-X(WS-T-ROW) TO WS-TX
         COMPUTE WS-TY = EN-Y(WS-T-ROW) + EN-BOX-HEIGHT(WS-T-ROW) * 0.5
         MOVE EN-Z(WS-T-ROW) TO WS-TZ
     ELSE
         MOVE PL-X TO WS-TX
         COMPUTE WS-TY = PL-Y + 0.9
         MOVE PL-Z TO WS-TZ
     END-IF
     MOVE FUNCTION PI TO WS-PI
     MOVE 0.425 TO WS-EYE-H
     MOVE 80 TO WS-DUR
     IF EN-KEY(L-ROW) = "elder_guardian"
         MOVE 0.99875 TO WS-EYE-H
         MOVE 60 TO WS-DUR
     END-IF
     COMPUTE WS-DX = WS-TX - EN-X(L-ROW)
     COMPUTE WS-DY = WS-TY - (EN-Y(L-ROW) + WS-EYE-H)
     COMPUTE WS-DZ = WS-TZ - EN-Z(L-ROW)
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     IF WS-LEN = 0
         GOBACK
     END-IF
     COMPUTE WS-L = WS-LEN + 1
     COMPUTE WS-A = FUNCTION ACOS(WS-DY / WS-LEN)
     CALL "EM8-ATAN2" USING WS-DZ WS-DX WS-AT
     COMPUTE WS-B = WS-PI / 2 - WS-AT
     COMPUTE WS-ATK = EN-RS(L-ROW) + 1
     COMPUTE WS-SC = WS-ATK / WS-DUR
     COMPUTE WS-C2 = WS-SC * WS-SC
     COMPUTE WS-TH = WS-ATK * 0.05 * -1.5
     COMPUTE WS-PH = FUNCTION MOD(WS-ATK * 0.5, 1)
     COMPUTE WS-RED = 64 + FUNCTION INTEGER-PART(WS-C2 * 191)
     COMPUTE WS-GREEN = 32 + FUNCTION INTEGER-PART(WS-C2 * 191)
     COMPUTE WS-BLUE = 128 - FUNCTION INTEGER-PART(WS-C2 * 64)
     COMPUTE WS-F(1) = FUNCTION SIN(WS-A)
     COMPUTE WS-F(2) = FUNCTION COS(WS-A)
     COMPUTE WS-F(3) = FUNCTION SIN(WS-B)
     COMPUTE WS-F(4) = FUNCTION COS(WS-B)
     COMPUTE WS-F(5) = EN-X(L-ROW) - L-EYE(1)
     COMPUTE WS-F(6) = EN-Y(L-ROW) + WS-EYE-H - L-EYE(2)
     COMPUTE WS-F(7) = EN-Z(L-ROW) - L-EYE(3)
     MOVE WS-SLOT TO WS-F(8)
     COMPUTE WS-F(9) = WS-RED / 255
     COMPUTE WS-F(10) = WS-GREEN / 255
     COMPUTE WS-F(11) = WS-BLUE / 255
     MOVE 1 TO WS-F(12)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-PX(WS-I) = WS-R(WS-I) * FUNCTION COS(WS-TH + WS-STEP(WS-I) * WS-PI / 4)
         COMPUTE WS-PZ(WS-I) = WS-R(WS-I) * FUNCTION SIN(WS-TH + WS-STEP(WS-I) * WS-PI / 4)
     END-PERFORM
     COMPUTE WS-V0 = -1 + WS-PH
     COMPUTE WS-V1 = WS-V0 + WS-L * 2.5
*>   The planes: points 1 and 2 (A, B) for the first, 3 and 4 (C, D) for the second.
     PERFORM VARYING WS-PLANE FROM 1 BY 1 UNTIL WS-PLANE > 2
         MOVE 0 TO WS-YA
         COMPUTE WS-N = FUNCTION INTEGER(WS-V0) + 1
         PERFORM UNTIL WS-YA >= WS-L
             IF WS-N < WS-V1
                 COMPUTE WS-YB = (WS-N - WS-V0) / 2.5
             ELSE
                 MOVE WS-L TO WS-YB
             END-IF
             COMPUTE WS-VM = WS-V0 + 2.5 * (WS-YA + WS-YB) / 2
             COMPUTE WS-K = FUNCTION INTEGER(WS-VM)
             COMPUTE WS-I = WS-PLANE * 2 - 1
             MOVE WS-PX(WS-I) TO WS-Q(1)
             MOVE WS-YB TO WS-Q(2)
             MOVE WS-PZ(WS-I) TO WS-Q(3)
             MOVE 0.4999 TO WS-Q(4)
             COMPUTE WS-Q(5) = WS-V0 + 2.5 * WS-YB - WS-K
             MOVE WS-PX(WS-I) TO WS-Q(6)
             MOVE WS-YA TO WS-Q(7)
             MOVE WS-PZ(WS-I) TO WS-Q(8)
             MOVE 0.4999 TO WS-Q(9)
             COMPUTE WS-Q(10) = WS-V0 + 2.5 * WS-YA - WS-K
             COMPUTE WS-I = WS-PLANE * 2
             MOVE WS-PX(WS-I) TO WS-Q(11)
             MOVE WS-YA TO WS-Q(12)
             MOVE WS-PZ(WS-I) TO WS-Q(13)
             MOVE 0 TO WS-Q(14)
             MOVE WS-Q(10) TO WS-Q(15)
             MOVE WS-PX(WS-I) TO WS-Q(16)
             MOVE WS-YB TO WS-Q(17)
             MOVE WS-PZ(WS-I) TO WS-Q(18)
             MOVE 0 TO WS-Q(19)
             MOVE WS-Q(5) TO WS-Q(20)
             CALL "BEAM-QUAD" USING CLIENT-STATE WS-QUAD WS-FRAME WS-ONES
             MOVE WS-YB TO WS-YA
             ADD 1 TO WS-N
         END-PERFORM
     END-PERFORM
*>   The sparkle cap at y = L: P1 to P4 (the points 5 to 8), v from f to f + 0.5 with f = 0.5 when floor(t) is even.
     COMPUTE WS-K = 0.5 * (1 - FUNCTION MOD(FUNCTION INTEGER(WS-ATK), 2))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-N = WS-I * 5 - 4
         COMPUTE WS-Q(WS-N) = WS-PX(WS-I + 4)
         MOVE WS-L TO WS-Q(WS-N + 1)
         COMPUTE WS-Q(WS-N + 2) = WS-PZ(WS-I + 4)
         MOVE 0.5 TO WS-Q(WS-N + 3)
         COMPUTE WS-Q(WS-N + 4) = WS-K + 0.5
         IF WS-I = 2 OR WS-I = 3
             MOVE 1 TO WS-Q(WS-N + 3)
         END-IF
         IF WS-I >= 3
             MOVE WS-K TO WS-Q(WS-N + 4)
         END-IF
     END-PERFORM
     CALL "BEAM-QUAD" USING CLIENT-STATE WS-QUAD WS-FRAME WS-ONES
     GOBACK.
 END PROGRAM ENTITY-BEAM-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-DRAGON-SET.
*> USING CLIENT-STATE, entity id, entry index, serializer, float value, block x y z, present (PIC 9): the Set Entity Data entries of the ender dragon and the end crystal that the
*> passes read (34-7 7.3, 8.2): the dragon's health (entry 9, FLOAT, EN-HP) and the crystal's beam target (entry 8, OPTIONAL_BLOCK_POS 11: present and the block, EN-BP, EN-BX, EN-BY, EN-BZ).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-SERIAL               BINARY-LONG.
 01 L-FLOAT                FLOAT-SHORT.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PRESENT              PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-INDEX L-SERIAL L-FLOAT L-X L-Y L-Z L-PRESENT.
     CALL "ENTITY-FIND" USING CLIENT-STATE L-ID WS-ROW
     IF WS-ROW > 0 AND EN-KEY(WS-ROW) = "ender_dragon" AND L-INDEX = 9 AND L-SERIAL = 3
         MOVE L-FLOAT TO EN-HP(WS-ROW)
     END-IF
     IF WS-ROW > 0 AND EN-KEY(WS-ROW) = "end_crystal" AND L-INDEX = 8 AND L-SERIAL = 11
         MOVE L-PRESENT TO EN-BP(WS-ROW)
         MOVE 0 TO EN-BX(WS-ROW) EN-BY(WS-ROW) EN-BZ(WS-ROW)
         IF L-PRESENT = 1
             MOVE L-X TO EN-BX(WS-ROW)
             MOVE L-Y TO EN-BY(WS-ROW)
             MOVE L-Z TO EN-BZ(WS-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-DRAGON-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-DRAGON-CRYSTAL.
*> USING CLIENT-STATE, replica row of an ender dragon: the nearest healing crystal (21 section 6.4, checkCrystals): the end_crystal whose box (2 x 2) meets the dragon's box (EN-BOX-HALF, EN-BOX-HEIGHT; 8 and 8
*> where the row has none) inflated by 32 and whose position is the nearest by squared distance (EN-NCI its entity id, 0 none). The server rescans with probability 1 / 10 a tick and forgets a
*> removed crystal at once; the client has no such draw to match and rescans every tick (the same choice a tick later at most).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     MOVE 8 TO WS-HALF WS-HEIGHT
     IF EN-BOX-HALF(L-ROW) > 0
         MOVE EN-BOX-HALF(L-ROW) TO WS-HALF
     END-IF
     IF EN-BOX-HEIGHT(L-ROW) > 0
         MOVE EN-BOX-HEIGHT(L-ROW) TO WS-HEIGHT
     END-IF
     MOVE 0 TO EN-NCI(L-ROW)
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-KEY(WS-I) = "end_crystal"
             COMPUTE WS-DX = EN-X(WS-I) - EN-X(L-ROW)
             COMPUTE WS-DY = EN-Y(WS-I) - EN-Y(L-ROW)
             COMPUTE WS-DZ = EN-Z(WS-I) - EN-Z(L-ROW)
             IF FUNCTION ABS(WS-DX) <= WS-HALF + 33 AND FUNCTION ABS(WS-DZ) <= WS-HALF + 33
                     AND WS-DY >= -34 AND WS-DY <= WS-HEIGHT + 32
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF EN-NCI(L-ROW) = 0 OR WS-D2 < WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE EN-ID(WS-I) TO EN-NCI(L-ROW)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-DRAGON-CRYSTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRYSTAL-BEAM.
*> USING CLIENT-STATE, origin (3 FLOAT-LONG: the pose origin relative to the eye), vector (3 FLOAT-LONG: the beam from its origin to its end), age (FLOAT-LONG), light (FLOAT-LONG, 0 to 1):
*> EnderDragonRenderer.submitCrystalBeams (34-7 8.7): the pose translates (0, 2, 0) and rotates about Y by -atan2(z, x) - pi / 2 and about X by -atan2(h, y) - pi / 2 (h = sqrt(x^2 + z^2));
*> eight quads (k = 1 to 8, angle k pi / 4, (sin, cos) x 0.75) between the previous and this corner, from radius 0.2 black at the origin to 0.75 white at the far end (len = |vector|), u = k / 8,
*> v from -age x 0.01 to len / 32 - age x 0.01 (the image does not repeat in the atlas, so the quads are cut where v crosses an integer). The image is the row end_crystal_beam.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLMODELS.
 01 WS-KEY                 PIC X(24) VALUE "end_crystal_beam".
 01 WS-BM                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PI                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AT                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-FB                  FLOAT-LONG OCCURS 64 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KM                  FLOAT-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-RA                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG OCCURS 2 TIMES.
 01 WS-PY                  FLOAT-LONG OCCURS 2 TIMES.
 01 WS-PU                  FLOAT-LONG OCCURS 2 TIMES.
 01 WS-QUAD.
    05 WS-Q                FLOAT-LONG OCCURS 20 TIMES.
 01 WS-TINTS.
    05 WS-T4               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-FRAME.
    05 WS-F                FLOAT-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ORIGIN.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-VEC.
    05 L-V                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-AGE                  FLOAT-LONG.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ORIGIN L-VEC L-AGE L-LIGHT.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-BM
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = WS-BM AND EA-MT-TEX(WS-S) = 0
             MOVE WS-S TO WS-SLOT
         END-IF
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(L-V(1) * L-V(1) + L-V(2) * L-V(2) + L-V(3) * L-V(3))
     IF WS-SLOT = 0 OR WS-LEN < 0.00001
         GOBACK
     END-IF
     MOVE FUNCTION PI TO WS-PI
     COMPUTE WS-H = FUNCTION SQRT(L-V(1) * L-V(1) + L-V(3) * L-V(3))
     MOVE L-V(1) TO WS-VX
     MOVE L-V(2) TO WS-VY
     MOVE L-V(3) TO WS-VZ
     CALL "EM8-ATAN2" USING WS-VZ WS-VX WS-AT
     COMPUTE WS-AY = 0 - WS-AT - WS-PI / 2
     CALL "EM8-ATAN2" USING WS-H WS-VY WS-AT
     COMPUTE WS-AX = 0 - WS-AT - WS-PI / 2
     COMPUTE WS-F(1) = FUNCTION SIN(WS-AX)
     COMPUTE WS-F(2) = FUNCTION COS(WS-AX)
     COMPUTE WS-F(3) = FUNCTION SIN(WS-AY)
     COMPUTE WS-F(4) = FUNCTION COS(WS-AY)
     MOVE L-O(1) TO WS-F(5)
     COMPUTE WS-F(6) = L-O(2) + 2
     MOVE L-O(3) TO WS-F(7)
     MOVE WS-SLOT TO WS-F(8)
     MOVE 1 TO WS-F(9) WS-F(10) WS-F(11)
     MOVE L-LIGHT TO WS-F(12)
*>   The quad edges as fractions of the length where v crosses an integer.
     COMPUTE WS-V0 = 0 - L-AGE * 0.01
     COMPUTE WS-V1 = WS-LEN / 32 - L-AGE * 0.01
     MOVE 0 TO WS-FB(1)
     MOVE 1 TO WS-NB
     COMPUTE WS-N = FUNCTION INTEGER(WS-V0) + 1
     PERFORM UNTIL WS-N >= WS-V1 OR WS-NB >= 62
         ADD 1 TO WS-NB
         COMPUTE WS-FB(WS-NB) = (WS-N - WS-V0) / (WS-V1 - WS-V0)
         ADD 1 TO WS-N
     END-PERFORM
     ADD 1 TO WS-NB
     MOVE 1 TO WS-FB(WS-NB)
     MOVE 0 TO WS-PX(1)
     MOVE 0.75 TO WS-PY(1)
     MOVE 0 TO WS-PU(1)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 8
         COMPUTE WS-A = WS-K * 2 * WS-PI / 8
         COMPUTE WS-PX(2) = FUNCTION SIN(WS-A) * 0.75
         COMPUTE WS-PY(2) = FUNCTION COS(WS-A) * 0.75
         COMPUTE WS-PU(2) = WS-K / 8
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-NB
             MOVE WS-FB(WS-I) TO WS-FA
             MOVE WS-FB(WS-I + 1) TO WS-FZ
             COMPUTE WS-KM = FUNCTION INTEGER(WS-V0 + (WS-V1 - WS-V0) * (WS-FA + WS-FZ) / 2)
             COMPUTE WS-RA = 0.2 + 0.8 * WS-FA
             COMPUTE WS-RZ = 0.2 + 0.8 * WS-FZ
*>           Corner 1: the previous edge at the near end of the strip, 2 the previous edge at the far end, 3 this edge far, 4 this edge near.
             COMPUTE WS-Q(1) = WS-PX(1) * WS-RA
             COMPUTE WS-Q(2) = WS-PY(1) * WS-RA
             COMPUTE WS-Q(3) = WS-FA * WS-LEN
             MOVE WS-PU(1) TO WS-Q(4)
             COMPUTE WS-Q(5) = WS-V0 + (WS-V1 - WS-V0) * WS-FA - WS-KM
             COMPUTE WS-Q(6) = WS-PX(1) * WS-RZ
             COMPUTE WS-Q(7) = WS-PY(1) * WS-RZ
             COMPUTE WS-Q(8) = WS-FZ * WS-LEN
             MOVE WS-PU(1) TO WS-Q(9)
             COMPUTE WS-Q(10) = WS-V0 + (WS-V1 - WS-V0) * WS-FZ - WS-KM
             COMPUTE WS-Q(11) = WS-PX(2) * WS-RZ
             COMPUTE WS-Q(12) = WS-PY(2) * WS-RZ
             COMPUTE WS-Q(13) = WS-FZ * WS-LEN
             MOVE WS-PU(2) TO WS-Q(14)
             MOVE WS-Q(10) TO WS-Q(15)
             COMPUTE WS-Q(16) = WS-PX(2) * WS-RA
             COMPUTE WS-Q(17) = WS-PY(2) * WS-RA
             COMPUTE WS-Q(18) = WS-FA * WS-LEN
             MOVE WS-PU(2) TO WS-Q(19)
             MOVE WS-Q(5) TO WS-Q(20)
             MOVE WS-FA TO WS-T4(1) WS-T4(4)
             MOVE WS-FZ TO WS-T4(2) WS-T4(3)
             CALL "BEAM-QUAD" USING CLIENT-STATE WS-QUAD WS-FRAME WS-TINTS
         END-PERFORM
         MOVE WS-PX(2) TO WS-PX(1)
         MOVE WS-PY(2) TO WS-PY(1)
         MOVE WS-PU(2) TO WS-PU(1)
     END-PERFORM
     GOBACK.
 END PROGRAM CRYSTAL-BEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-CRYSTAL-BEAM-EMIT.
*> USING CLIENT-STATE, replica row of an end_crystal with a beam target or an ender_dragon with a nearest crystal, eye (3 FLOAT-LONG): the crystal's beam starts at the centre of its beam target block and
*> runs to its bobbing centre (34-7 7.3: the vector (-bx, -by + y, -bz) with (bx, by, bz) the target centre minus the crystal's position and y = getY(age), f = sin(0.2 a) / 2 + 0.5, (f f + f) 0.4 - 1.4);
*> the dragon's starts at the dragon and runs to its nearest crystal plus (0, getY(crystal age), 0) (8.5 pass 4, beamOffset of 8.2). The age is the replica's tick count (EN-AGE) of the entity the pass is in.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ORIGIN.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VEC.
    05 WS-V                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-T-ROW               BINARY-LONG.
 01 WS-AGE                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-GY                  FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-EYE-TABLE.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLOCK) / 15, 0.1)
     IF EN-KEY(L-ROW) = "end_crystal"
         MOVE EN-AGE(L-ROW) TO WS-AGE
         COMPUTE WS-F = FUNCTION SIN(0.2 * WS-AGE) / 2 + 0.5
         COMPUTE WS-GY = (WS-F * WS-F + WS-F) * 0.4 - 1.4
         COMPUTE WS-BX = EN-BX(L-ROW) + 0.5 - EN-X(L-ROW)
         COMPUTE WS-BY = EN-BY(L-ROW) + 0.5 - EN-Y(L-ROW)
         COMPUTE WS-BZ = EN-BZ(L-ROW) + 0.5 - EN-Z(L-ROW)
         COMPUTE WS-O(1) = EN-X(L-ROW) + WS-BX - L-EYE(1)
         COMPUTE WS-O(2) = EN-Y(L-ROW) + WS-BY - L-EYE(2)
         COMPUTE WS-O(3) = EN-Z(L-ROW) + WS-BZ - L-EYE(3)
         COMPUTE WS-V(1) = 0 - WS-BX
         COMPUTE WS-V(2) = 0 - WS-BY + WS-GY
         COMPUTE WS-V(3) = 0 - WS-BZ
     ELSE
         CALL "ENTITY-FIND" USING CLIENT-STATE EN-NCI(L-ROW) WS-T-ROW
         IF WS-T-ROW = 0
             GOBACK
         END-IF
         MOVE EN-AGE(L-ROW) TO WS-AGE
         COMPUTE WS-F = FUNCTION SIN(0.2 * EN-AGE(WS-T-ROW)) / 2 + 0.5
         COMPUTE WS-GY = (WS-F * WS-F + WS-F) * 0.4 - 1.4
         COMPUTE WS-O(1) = EN-X(L-ROW) - L-EYE(1)
         COMPUTE WS-O(2) = EN-Y(L-ROW) - L-EYE(2)
         COMPUTE WS-O(3) = EN-Z(L-ROW) - L-EYE(3)
         COMPUTE WS-V(1) = EN-X(WS-T-ROW) - EN-X(L-ROW)
         COMPUTE WS-V(2) = EN-Y(WS-T-ROW) + WS-GY - EN-Y(L-ROW)
         COMPUTE WS-V(3) = EN-Z(WS-T-ROW) - EN-Z(L-ROW)
     END-IF
     CALL "CRYSTAL-BEAM" USING CLIENT-STATE WS-ORIGIN WS-VEC WS-AGE WS-LIGHT
     GOBACK.
 END PROGRAM ENTITY-CRYSTAL-BEAM-EMIT.
