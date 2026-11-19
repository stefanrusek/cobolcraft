*> The breeze's numbers (lane 002-lane-p49r; docs/protocol/20 section 16.2, 16.4, 16.5), as programs of plain numbers: the caller draws the random values and the program applies the
*> document's arithmetic, so tests can pass the draws.
*>   BREEZE-AIM-VECTOR USING dx, dy, dz (FLOAT-LONG, the aim), uncertainty (BINARY-LONG, 5 - 4 x difficulty), draws (six FLOAT-LONG nextDouble results, in the order x1 x2 y1 y2 z1 z2), vx, vy, vz out:
*>     Projectile.shoot with power 0.7f: (normalize(d) + error) x 0.699999988079071, error component = 0.0172275 x uncertainty x (first draw - second draw) (16.2).
*>   BREEZE-JUMP-VECTOR USING px, py, pz (the breeze), qx, qy, qz (the bottom centre of the jump cell), follow range, gravity (FLOAT-LONG), angle (BINARY-LONG degrees), ok out, vx, vy, vz out:
*>     the jump vector of one angle (16.4 steps 1 to 5; no Jump Boost): ok 0 when v2 < 0 or v exceeds follow range x 0.058333334f.
*>   BREEZE-JUMP-PICK USING px, py, pz, qx, qy, qz, follow range, gravity, draws (four BINARY-LONG: nextInt(5), nextInt(4), nextInt(3), nextInt(2) of the shuffle), angle out, ok out, vx, vy, vz out:
*>     the five angles 40, 55, 60, 75, 80 shuffled (for i from 5 down to 2 swap the element i - 1 with the one at the draw) and the first that gives a vector.
*>   BREEZE-POINT-BEHIND USING tx, ty, tz (the target's feet), head yaw (FLOAT-LONG degrees), gaussian, unit (FLOAT-LONG, nextGaussian then nextFloat), px, py, pz out:
*>     randomPointBehindTarget: yaw = head yaw + 180 + gaussian x 45, distance 4 + 4 x unit along Vec3.directionFromRotation(0, yaw).
*>   WIND-BURST USING dim, x, y, z (FLOAT-LONG), source entity id: the explosion of a breeze wind charge (16.3): radius 3, push only.
*>   BREEZE-POINT-MIDDLE USING bx, by, bz (the breeze), tx, ty, tz (the target), unit (FLOAT-LONG nextDouble), px, py, pz out: the point on the line to the target (8 - 4 x unit) blocks short of it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-AIM-VECTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-U                    BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 6 TIMES.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-U L-DRAWS L-VX L-VY L-VZ.
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     COMPUTE WS-S = 0.0172275 * L-U
     COMPUTE L-VX = (L-DX / WS-LEN + WS-S * (L-DRAW(1) - L-DRAW(2))) * 0.699999988079071
     COMPUTE L-VY = (L-DY / WS-LEN + WS-S * (L-DRAW(3) - L-DRAW(4))) * 0.699999988079071
     COMPUTE L-VZ = (L-DZ / WS-LEN + WS-S * (L-DRAW(5) - L-DRAW(6))) * 0.699999988079071
     GOBACK.
 END PROGRAM BREEZE-AIM-VECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-JUMP-VECTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-HL                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-THETA               FLOAT-SHORT.
 01 WS-TWO-THETA           FLOAT-SHORT.
 01 WS-V2                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-VMAX                FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-VH                  FLOAT-LONG.
 01 WS-A                   FLOAT-SHORT.
 01 WS-PI                  FLOAT-SHORT VALUE 3.1415927410125732.
 01 WS-F                   FLOAT-SHORT VALUE 0.058333333581686.
 LINKAGE SECTION.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-QX                   FLOAT-LONG.
 01 L-QY                   FLOAT-LONG.
 01 L-QZ                   FLOAT-LONG.
 01 L-FOLLOW               FLOAT-LONG.
 01 L-GRAVITY              FLOAT-LONG.
 01 L-ANGLE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-PX L-PY L-PZ L-QX L-QY L-QZ L-FOLLOW L-GRAVITY L-ANGLE L-OK L-VX L-VY L-VZ.
     MOVE 0 TO L-OK L-VX L-VY L-VZ
*>   The aim point is 0.5 block short of the target horizontally.
     COMPUTE WS-HX = L-QX - L-PX
     COMPUTE WS-HZ = L-QZ - L-PZ
     COMPUTE WS-HL = FUNCTION SQRT(WS-HX * WS-HX + WS-HZ * WS-HZ)
     IF WS-HL > 0
         COMPUTE WS-DX = L-QX - WS-HX / WS-HL * 0.5 - L-PX
         COMPUTE WS-DZ = L-QZ - WS-HZ / WS-HL * 0.5 - L-PZ
     ELSE
         MOVE 0 TO WS-DX WS-DZ
     END-IF
     COMPUTE WS-DY = L-QY - L-PY
     COMPUTE WS-L = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF WS-L = 0
         GOBACK
     END-IF
     COMPUTE WS-A = L-ANGLE
     COMPUTE WS-THETA = WS-A * WS-PI / 180
     COMPUTE WS-TWO-THETA = 2 * WS-THETA
     COMPUTE WS-COS = FUNCTION COS(WS-THETA)
     COMPUTE WS-DEN = WS-L * FUNCTION SIN(WS-TWO-THETA) - 2 * WS-DY * WS-COS * WS-COS
     IF WS-DEN = 0
         GOBACK
     END-IF
     COMPUTE WS-V2 = (WS-L * WS-L * L-GRAVITY) / WS-DEN
     IF WS-V2 < 0
         GOBACK
     END-IF
     COMPUTE WS-V = FUNCTION SQRT(WS-V2)
     COMPUTE WS-VMAX = L-FOLLOW * WS-F
     IF WS-V > WS-VMAX
         GOBACK
     END-IF
     COMPUTE WS-VH = WS-V * WS-COS
*>   cos(phi) and sin(phi) of phi = atan2(d.z, d.x) are d.x / L and d.z / L.
     COMPUTE L-VX = 0.949999988079071 * WS-VH * WS-DX / WS-L
     COMPUTE L-VY = 0.949999988079071 * WS-V * FUNCTION SIN(WS-THETA)
     COMPUTE L-VZ = 0.949999988079071 * WS-VH * WS-DZ / WS-L
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM BREEZE-JUMP-VECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-JUMP-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLES.
    05 WS-ANGLE            BINARY-LONG OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-QX                   FLOAT-LONG.
 01 L-QY                   FLOAT-LONG.
 01 L-QZ                   FLOAT-LONG.
 01 L-FOLLOW               FLOAT-LONG.
 01 L-GRAVITY              FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              BINARY-LONG OCCURS 4 TIMES.
 01 L-PICKED               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-PX L-PY L-PZ L-QX L-QY L-QZ L-FOLLOW L-GRAVITY L-DRAWS L-PICKED L-OK L-VX L-VY L-VZ.
     MOVE 40 TO WS-ANGLE(1)
     MOVE 55 TO WS-ANGLE(2)
     MOVE 60 TO WS-ANGLE(3)
     MOVE 75 TO WS-ANGLE(4)
     MOVE 80 TO WS-ANGLE(5)
*>   Util.shuffle: for i from 5 down to 2, j = nextInt(i), swap the element at i - 1 with the one at j.
     PERFORM VARYING WS-I FROM 5 BY -1 UNTIL WS-I < 2
         COMPUTE WS-K = 6 - WS-I
         MOVE L-DRAW(WS-K) TO WS-J
         ADD 1 TO WS-J
         MOVE WS-ANGLE(WS-I) TO WS-SWAP
         MOVE WS-ANGLE(WS-J) TO WS-ANGLE(WS-I)
         MOVE WS-SWAP TO WS-ANGLE(WS-J)
     END-PERFORM
     MOVE 0 TO L-OK L-PICKED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR L-OK = 1
         CALL "BREEZE-JUMP-VECTOR" USING L-PX L-PY L-PZ L-QX L-QY L-QZ L-FOLLOW L-GRAVITY WS-ANGLE(WS-I) L-OK L-VX L-VY L-VZ
         IF L-OK = 1
             MOVE WS-ANGLE(WS-I) TO L-PICKED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREEZE-JUMP-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-POINT-BEHIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-DIST                FLOAT-SHORT.
 01 WS-A                   FLOAT-SHORT.
 01 WS-R                   FLOAT-SHORT VALUE 0.01745329238474369.
 01 WS-PI                  FLOAT-SHORT VALUE 3.1415927410125732.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-G                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-HEAD                 FLOAT-LONG.
 01 L-GAUSS                FLOAT-LONG.
 01 L-UNIT                 FLOAT-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-TX L-TY L-TZ L-HEAD L-GAUSS L-UNIT L-PX L-PY L-PZ.
     MOVE L-GAUSS TO WS-G
     COMPUTE WS-YAW = L-HEAD + 180 + WS-G * 90 / 2
     COMPUTE WS-DIST = 4 + L-UNIT * 4
*>   Vec3.directionFromRotation(0, yaw): a = -yaw x r - pi, the pitch factors are cp = -1 and sp = 0 for pitch 0.
     COMPUTE WS-A = - WS-YAW * WS-R - WS-PI
     MOVE WS-A TO WS-ARG
     CALL "IP-MTH-SIN" USING WS-ARG WS-SIN
     CALL "IP-MTH-COS" USING WS-ARG WS-COS
     COMPUTE L-PX = L-TX + (- WS-SIN) * WS-DIST
     MOVE L-TY TO L-PY
     COMPUTE L-PZ = L-TZ + (- WS-COS) * WS-DIST
     GOBACK.
 END PROGRAM BREEZE-POINT-BEHIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-POINT-MIDDLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BX                   FLOAT-LONG.
 01 L-BY                   FLOAT-LONG.
 01 L-BZ                   FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-UNIT                 FLOAT-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-BX L-BY L-BZ L-TX L-TY L-TZ L-UNIT L-PX L-PY L-PZ.
     COMPUTE WS-DX = L-TX - L-BX
     COMPUTE WS-DY = L-TY - L-BY
     COMPUTE WS-DZ = L-TZ - L-BZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     MOVE L-BX TO L-PX
     MOVE L-BY TO L-PY
     MOVE L-BZ TO L-PZ
     IF WS-LEN > 0
         COMPUTE WS-M = WS-LEN - (8 - 4 * L-UNIT)
         COMPUTE L-PX = L-BX + WS-DX / WS-LEN * WS-M
         COMPUTE L-PY = L-BY + WS-DY / WS-LEN * WS-M
         COMPUTE L-PZ = L-BZ + WS-DZ / WS-LEN * WS-M
     END-IF
     GOBACK.
 END PROGRAM BREEZE-POINT-MIDDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-BURST.
*> USING dim, x, y, z (FLOAT-LONG, the burst centre), source entity id (the charge; 0 none): the explosion of a breeze wind charge (16.3): radius 3.0, TRIGGER, no damage to entities, no block destroyed,
*> knockback multiplier 1.0. Every player (not a spectator, not a creative flying one) and standard mob within 2R = 6 blocks of the centre (feet distance) is pushed by (1 - distance / 6) x seen along
*> the direction from the centre to its eyes (a mob's through EN-VX, EN-VY, EN-VZ like EXPLODE-RUN, a player's in the Explode packet to the players within 64 blocks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-REACH               FLOAT-LONG VALUE 6.
 01 WS-POWER               FLOAT-LONG VALUE 3.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-SEEN                FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-BLOCKS              BINARY-LONG VALUE 0.
 01 WS-KNOCK.
    05 WS-KN OCCURS 64 TIMES.
       10 WS-KN-SET        BINARY-LONG.
       10 WS-KN-X          FLOAT-LONG.
       10 WS-KN-Y          FLOAT-LONG.
       10 WS-KN-Z          FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOURCE.
     INITIALIZE WS-KNOCK
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = L-DIM
                 AND PL-MODE(WS-P) < 3 AND NOT (PL-MODE(WS-P) = 1 AND PL-FLYING(WS-P) = 1)
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
             IF WS-DIST < 1
                 COMPUTE WS-MINX = PL-X(WS-P) - 0.3
                 COMPUTE WS-MAXX = PL-X(WS-P) + 0.3
                 MOVE PL-Y(WS-P) TO WS-MINY
                 COMPUTE WS-MAXY = PL-Y(WS-P) + 1.8
                 COMPUTE WS-MINZ = PL-Z(WS-P) - 0.3
                 COMPUTE WS-MAXZ = PL-Z(WS-P) + 0.3
                 CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                 COMPUTE WS-S = (1 - WS-DIST) * WS-SEEN
                 COMPUTE WS-DY = PL-Y(WS-P) + 1.62 - L-Y
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                 IF WS-LEN > 0
                     MOVE 1 TO WS-KN-SET(WS-P)
                     COMPUTE WS-KN-X(WS-P) = WS-DX / WS-LEN * WS-S
                     COMPUTE WS-KN-Y(WS-P) = WS-DY / WS-LEN * WS-S
                     COMPUTE WS-KN-Z(WS-P) = WS-DZ / WS-LEN * WS-S
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND EN-HEALTH(WS-E) > 0 AND EN-ID(WS-E) NOT = L-SOURCE
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-DX = EN-X(WS-E) - L-X
                 COMPUTE WS-DY = EN-Y(WS-E) - L-Y
                 COMPUTE WS-DZ = EN-Z(WS-E) - L-Z
                 COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
                 IF WS-DIST < 1
                     COMPUTE WS-WIDTH = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-MINX = EN-X(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXX = EN-X(WS-E) + WS-WIDTH / 2
                     MOVE EN-Y(WS-E) TO WS-MINY
                     COMPUTE WS-MAXY = EN-Y(WS-E) + WS-HEIGHT
                     COMPUTE WS-MINZ = EN-Z(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXZ = EN-Z(WS-E) + WS-WIDTH / 2
                     CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                     COMPUTE WS-S = (1 - WS-DIST) * WS-SEEN
                     COMPUTE WS-DY = EN-Y(WS-E) + WS-HEIGHT * 0.85 - L-Y
                     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                     IF WS-LEN > 0
                         COMPUTE EN-VX(WS-E) = EN-VX(WS-E) + WS-DX / WS-LEN * WS-S
                         COMPUTE EN-VY(WS-E) = EN-VY(WS-E) + WS-DY / WS-LEN * WS-S
                         COMPUTE EN-VZ(WS-E) = EN-VZ(WS-E) + WS-DZ / WS-LEN * WS-S
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*>   The Explode packet (no block, the knockback of the player) to every player within 64 blocks.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4096
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "EXPLODE-BUILD" USING L-X L-Y L-Z WS-POWER WS-BLOCKS WS-KN-SET(WS-P) WS-KN-X(WS-P) WS-KN-Y(WS-P)
                     WS-KN-Z(WS-P) PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIND-BURST.
