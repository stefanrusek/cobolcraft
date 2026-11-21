*> Rule functions of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md (lane 002-lane-p49j-b, tasks T24200 to T24299), the rules of sections 3 to 10 that have no entity engine in the core
*> yet (a second boat passenger, the boat bubble column, the camel pose animation, container carts, the projectile ownership checks, the wind charge, the wither skull, the ender pearl, the trident return,
*> the lingering cloud). Each program is one deterministic rule with its random draws and world facts passed in; they are proven by tests, not called by a tick (lane task list).

*> 44-8 3.2 boat push rule: another boat pushes only when its minY < the boat's maxY; any other entity only when its minY <= the boat's minY.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-PUSH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OTHER-BOAT           BINARY-LONG.
 01 L-OTHER-MINY           FLOAT-LONG.
 01 L-MINY                 FLOAT-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OTHER-BOAT L-OTHER-MINY L-MINY L-MAXY L-OUT.
     MOVE 0 TO L-OUT
     IF L-OTHER-BOAT = 1
         IF L-OTHER-MINY < L-MAXY
             MOVE 1 TO L-OUT
         END-IF
     ELSE
         IF L-OTHER-MINY <= L-MINY
             MOVE 1 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-BOAT-PUSH.

*> 44-8 3.1 canAddPassenger: fewer passengers than the maximum (2, or 1 for a chest boat) and the boat's own eye not in water.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-CAN-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PASSENGERS           BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-EYE-IN-WATER         BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PASSENGERS L-CHEST L-EYE-IN-WATER L-OUT.
     MOVE 2 TO WS-MAX
     IF L-CHEST = 1
         MOVE 1 TO WS-MAX
     END-IF
     MOVE 0 TO L-OUT
     IF L-PASSENGERS < WS-MAX AND L-EYE-IN-WATER = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-BOAT-CAN-ADD.

*> 44-8 3.6 seat z offset: 0.0 (0.15 for chest boats); with more than one passenger +0.2 for the first, -0.6 for the other, and +0.2 more for an Animal (only then).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-SEAT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASSENGERS           BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ANIMAL               BINARY-LONG.
 01 L-CHEST                BINARY-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-PASSENGERS L-INDEX L-ANIMAL L-CHEST L-Z.
     MOVE 0 TO L-Z
     IF L-CHEST = 1
         MOVE 0.15 TO L-Z
     END-IF
     IF L-PASSENGERS > 1
         IF L-INDEX = 0
             COMPUTE L-Z = L-Z + 0.2
         ELSE
             COMPUTE L-Z = L-Z - 0.6
         END-IF
         IF L-ANIMAL = 1
             COMPUTE L-Z = L-Z + 0.2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-BOAT-SEAT.

*> 44-8 3.6 rideHeight: wooden boats height / 3 = 0.1875, rafts height x 0.8888889 = 0.5.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-RIDE-HEIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAFT                 BINARY-LONG.
 01 L-H                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-RAFT L-H.
     MOVE 0.1875 TO L-H
     IF L-RAFT = 1
         COMPUTE L-H = 0.5625 * 0.8888889
     END-IF
     GOBACK.
 END PROGRAM Q8-BOAT-RIDE-HEIGHT.

*> 44-8 3.6 clampRotation for a player: delta = wrapDegrees(yaw - bodyYaw) clamped to -105..105; the yaw changes by clamped - delta (OUT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-CLAMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D  FLOAT-LONG.
 01 WS-C  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-BOAT-YAW             FLOAT-LONG.
 01 L-PASSENGER-YAW        FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-BOAT-YAW L-PASSENGER-YAW L-OUT.
     COMPUTE WS-D = FUNCTION MOD(L-PASSENGER-YAW - L-BOAT-YAW + 540, 360) - 180
     COMPUTE WS-C = FUNCTION MAX(-105, FUNCTION MIN(105, WS-D))
     COMPUTE L-OUT = WS-C - WS-D
     GOBACK.
 END PROGRAM Q8-BOAT-CLAMP.

*> 44-8 3.7 tickBubbleColumn (server): no column resets bubbleTime; with one the time counts down and at 0 the column acts: a drag column ejects the passengers (event 71), a push column sends event 72, then handleBubbleColumnEffect (LAUNCH).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BOAT-BUBBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ABOVE                BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-DOWN                 BINARY-LONG.
 01 L-EJECT                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-LAUNCH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE L-TIME L-DOWN L-EJECT L-EVENT L-LAUNCH.
     MOVE 0 TO L-EJECT L-EVENT L-LAUNCH
     IF L-ABOVE = 0
         MOVE 0 TO L-TIME
     ELSE
         IF L-TIME > 0
             SUBTRACT 1 FROM L-TIME
             COMPUTE WS-K = 60 - L-TIME - 1
             IF WS-K > 0 AND L-TIME = 0
                 IF L-DOWN = 1
                     MOVE 1 TO L-EJECT
                     MOVE 71 TO L-EVENT
                 ELSE
                     MOVE 72 TO L-EVENT
                 END-IF
                 MOVE 1 TO L-LAUNCH
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-BOAT-BUBBLE.

*> 44-8 3.7 handleBubbleColumnEffect: vy - 0.7 for a drag column, vy = 0.6 for a push column.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BUBBLE-EFFECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DOWN L-VY.
     IF L-DOWN = 1
         COMPUTE L-VY = L-VY - 0.7
     ELSE
         MOVE 0.6 TO L-VY
     END-IF
     GOBACK.
 END PROGRAM Q8-BUBBLE-EFFECT.

*> 44-8 4.6 DismountHelper.offsetsForDirection(d): a = d turned clockwise ((dx, dz) -> (-dz, dx)), b = -a, c = -d; offset I (1 to 8) in the order a, b, c + a, c + b, d + a, d + b, c, d.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-DISMOUNT-OFFSET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AX  BINARY-LONG.
 01 WS-AZ  BINARY-LONG.
 01 WS-CX  BINARY-LONG.
 01 WS-CZ  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DZ L-I L-OX L-OZ.
     COMPUTE WS-AX = 0 - L-DZ
     COMPUTE WS-AZ = L-DX
     COMPUTE WS-CX = 0 - L-DX
     COMPUTE WS-CZ = 0 - L-DZ
     EVALUATE L-I
         WHEN 1
             COMPUTE L-OX = WS-AX
             COMPUTE L-OZ = WS-AZ
         WHEN 2
             COMPUTE L-OX = 0 - WS-AX
             COMPUTE L-OZ = 0 - WS-AZ
         WHEN 3
             COMPUTE L-OX = WS-CX + WS-AX
             COMPUTE L-OZ = WS-CZ + WS-AZ
         WHEN 4
             COMPUTE L-OX = WS-CX - WS-AX
             COMPUTE L-OZ = WS-CZ - WS-AZ
         WHEN 5
             COMPUTE L-OX = L-DX + WS-AX
             COMPUTE L-OZ = L-DZ + WS-AZ
         WHEN 6
             COMPUTE L-OX = L-DX - WS-AX
             COMPUTE L-OZ = L-DZ - WS-AZ
         WHEN 7
             MOVE WS-CX TO L-OX
             MOVE WS-CZ TO L-OZ
         WHEN OTHER
             MOVE L-DX TO L-OX
             MOVE L-DZ TO L-OZ
     END-EVALUATE
     GOBACK.
 END PROGRAM Q8-DISMOUNT-OFFSET.

*> 44-8 4.6 getRedstoneSignalFromContainer: 0 for an empty container, else floor(14 x fill) + 1 (fill = the sum of count / max stack size over the slots, divided by the container size).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-CART-SIGNAL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FILL                 FLOAT-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-FILL L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-FILL > 0
         COMPUTE L-SIGNAL = FUNCTION INTEGER(L-FILL * 14) + 1
     END-IF
     GOBACK.
 END PROGRAM Q8-CART-SIGNAL.

*> 44-8 4.6 container cart slowdown f = 0.98 (+ (15 - signal) x 0.001 without a loot table) x 0.95 in water; the velocity is multiplied by (f, 0, f).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-CART-FACTOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-LOOT                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-F                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-LOOT L-WATER L-F.
     MOVE 0.98 TO L-F
     IF L-LOOT = 0
         COMPUTE L-F = L-F + (15 - L-SIGNAL) * 0.001
     END-IF
     IF L-WATER = 1
         COMPUTE L-F = L-F * 0.95
     END-IF
     GOBACK.
 END PROGRAM Q8-CART-FACTOR.

*> 44-8 5 camel seat z: 0.5; with more than one passenger the rear seats -0.7; an Animal adds 0.2 in that case only; times the age scale.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-CAMEL-SEAT-Z.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASSENGERS           BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ANIMAL               BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-PASSENGERS L-INDEX L-ANIMAL L-SCALE L-Z.
     MOVE 0.5 TO L-Z
     IF L-PASSENGERS > 1
         IF L-INDEX > 0
             MOVE -0.7 TO L-Z
         END-IF
         IF L-ANIMAL = 1
             COMPUTE L-Z = L-Z + 0.2
         END-IF
     END-IF
     COMPUTE L-Z = L-Z * L-SCALE
     GOBACK.
 END PROGRAM Q8-CAMEL-SEAT-Z.

*> 44-8 5 Camel.bodyAnchorY(first, 0, dimensions, scale): h = height - 0.375 (baby 0.09375), s = 1.43 x scale, d1 = s - 0.2 x scale, d2 = s - d1; outside a pose transition y = h (+ d2 while sitting); in one the piecewise lerps of the document (sitting down T 40, P 28, k 0.5 / 0.1; standing up T 52, P 24 / 32, k 0.6 / 0.35); T is the clamped pose time.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-CAMEL-ANCHOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H  FLOAT-LONG.
 01 WS-S  FLOAT-LONG.
 01 WS-D1  FLOAT-LONG.
 01 WS-D2  FLOAT-LONG.
 01 WS-TOT  FLOAT-LONG.
 01 WS-P  FLOAT-LONG.
 01 WS-K  FLOAT-LONG.
 01 WS-T  FLOAT-LONG.
 01 WS-MID  FLOAT-LONG.
 01 WS-U  FLOAT-LONG.
 01 WS-FP  BINARY-LONG.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-SITTING              BINARY-LONG.
 01 L-TRANSITION           BINARY-LONG.
 01 L-T                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-FIRST L-BABY L-HEIGHT L-SITTING L-TRANSITION L-T L-SCALE L-Y.
     IF L-BABY = 1
         COMPUTE WS-H = L-HEIGHT - 0.09375
     ELSE
         COMPUTE WS-H = L-HEIGHT - 0.375
     END-IF
     COMPUTE WS-S = 1.43 * L-SCALE
     COMPUTE WS-D1 = WS-S - 0.2 * L-SCALE
     COMPUTE WS-D2 = WS-S - WS-D1
     IF L-TRANSITION = 0
         MOVE WS-H TO L-Y
         IF L-SITTING = 1
             COMPUTE L-Y = L-Y + WS-D2
         END-IF
     ELSE
         IF L-SITTING = 1
             MOVE 40 TO WS-TOT
             MOVE 28 TO WS-P
             MOVE 0.5 TO WS-K
             IF L-FIRST = 0
                 MOVE 0.1 TO WS-K
             END-IF
         ELSE
             MOVE 52 TO WS-TOT
             MOVE 24 TO WS-P
             MOVE 0.6 TO WS-K
             IF L-FIRST = 0
                 MOVE 32 TO WS-P
                 MOVE 0.35 TO WS-K
             END-IF
         END-IF
         COMPUTE WS-T = FUNCTION MAX(0, FUNCTION MIN(WS-TOT, L-T))
         COMPUTE WS-MID = WS-S - WS-K * WS-D1
         IF WS-T < WS-P
             COMPUTE WS-U = WS-T / WS-P
             MOVE 1 TO WS-FP
         ELSE
             COMPUTE WS-U = (WS-T - WS-P) / (WS-TOT - WS-P)
             MOVE 0 TO WS-FP
         END-IF
         IF L-SITTING = 1
             IF WS-FP = 1
                 COMPUTE L-Y = WS-H + WS-S + WS-U * (WS-MID - WS-S)
             ELSE
                 COMPUTE L-Y = WS-H + WS-MID + WS-U * (WS-D2 - WS-MID)
             END-IF
         ELSE
             IF WS-FP = 1
                 COMPUTE L-Y = WS-H + (WS-D2 - WS-S) + WS-U * ((WS-D2 - WS-MID) - (WS-D2 - WS-S))
             ELSE
                 COMPUTE L-Y = WS-H + (WS-D2 - WS-MID) + WS-U * (0 - (WS-D2 - WS-MID))
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-CAMEL-ANCHOR.

*> 44-8 6.2 computeMargin: max(0, min(0.3, (tickCount - 2) / 20)).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-MARGIN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-TICK L-OUT.
     COMPUTE L-OUT = FUNCTION MAX(0, FUNCTION MIN(0.3, (L-TICK - 2) / 20))
     GOBACK.
 END PROGRAM Q8-MARGIN.

*> 44-8 6.1 checkLeftOwner: while leftOwner is false and not yet checked this tick it becomes isOutsideOwnerCollisionRange (no owner, or none of the owner's vehicle tree boxes meets the projectile box inflated by 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-LEFT-OWNER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-CHECKED              BINARY-LONG.
 01 L-NO-OWNER             BINARY-LONG.
 01 L-NONE-INTERSECTS      BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-CHECKED L-NO-OWNER L-NONE-INTERSECTS.
     IF L-LEFT = 0 AND L-CHECKED = 0
         MOVE 0 TO L-LEFT
         IF L-NO-OWNER = 1 OR L-NONE-INTERSECTS = 1
             MOVE 1 TO L-LEFT
         END-IF
         MOVE 1 TO L-CHECKED
     END-IF
     GOBACK.
 END PROGRAM Q8-LEFT-OWNER.

*> 44-8 6.1 canHitEntity: the entity must be hittable; while the owner has not been left, a passenger of the owner's vehicle is not hit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-CAN-HIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-BE-HIT           BINARY-LONG.
 01 L-HAS-OWNER            BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-SAME-VEHICLE         BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-BE-HIT L-HAS-OWNER L-LEFT L-SAME-VEHICLE L-OUT.
     MOVE 0 TO L-OUT
     IF L-CAN-BE-HIT = 1
         MOVE 1 TO L-OUT
         IF L-HAS-OWNER = 1 AND L-LEFT = 0 AND L-SAME-VEHICLE = 1
             MOVE 0 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-CAN-HIT.

*> 44-8 6.3 REVERSE: v x (-0.5 s) per axis, yRot + 170 + nextFloat x 20.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-REVERSE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-DRAW                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ L-SX L-SY L-SZ L-YAW L-DRAW.
     COMPUTE L-VX = L-VX * (-0.5 * L-SX)
     COMPUTE L-VY = L-VY * (-0.5 * L-SY)
     COMPUTE L-VZ = L-VZ * (-0.5 * L-SZ)
     COMPUTE L-YAW = L-YAW + 170 + L-DRAW * 20
     GOBACK.
 END PROGRAM Q8-REVERSE.

*> 44-8 6.3 AIM_DEFLECT: velocity = the deflector's look vector x s, per axis.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-AIM-DEFLECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LX                   FLOAT-LONG.
 01 L-LY                   FLOAT-LONG.
 01 L-LZ                   FLOAT-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-LX L-LY L-LZ L-SX L-SY L-SZ L-VX L-VY L-VZ.
     COMPUTE L-VX = L-LX * L-SX
     COMPUTE L-VY = L-LY * L-SY
     COMPUTE L-VZ = L-LZ * L-SZ
     GOBACK.
 END PROGRAM Q8-AIM-DEFLECT.

*> 44-8 6.3 MOMENTUM_DEFLECT: velocity = normalize(the deflector's known speed) x s (scalar s here).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-MOMENTUM-DEFLECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-L  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KX                   FLOAT-LONG.
 01 L-KY                   FLOAT-LONG.
 01 L-KZ                   FLOAT-LONG.
 01 L-S                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-KX L-KY L-KZ L-S L-VX L-VY L-VZ.
     COMPUTE WS-L = FUNCTION SQRT(L-KX * L-KX + L-KY * L-KY + L-KZ * L-KZ)
     COMPUTE L-VX = L-KX / WS-L * L-S
     COMPUTE L-VY = L-KY / WS-L * L-S
     COMPUTE L-VZ = L-KZ / WS-L * L-S
     GOBACK.
 END PROGRAM Q8-MOMENTUM-DEFLECT.

*> 44-8 6.3 hitTargetOrDeflectSelf for an entity: a deflection other than NONE (0) means the hit is not processed and the projectile deflects unless the entity is lastDeflectedBy.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-HIT-DEFLECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEFLECTION           BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-DEFLECT              BINARY-LONG.
 01 L-PROCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-DEFLECTION L-LAST L-DEFLECT L-PROCESS.
     MOVE 0 TO L-DEFLECT
     MOVE 1 TO L-PROCESS
     IF L-DEFLECTION NOT = 0
         MOVE 0 TO L-PROCESS
         IF L-LAST = 0
             MOVE 1 TO L-DEFLECT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-HIT-DEFLECT.

*> 44-8 6.3 block hits: a world border hit of an arrow gives REVERSE with s = 0.2 (OUT 0.2); a block hit on air is no hit (OUT -1); else 0 (onHit runs).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-BORDER-HIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BORDER               BINARY-LONG.
 01 L-BOUNCES              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-BORDER L-BOUNCES L-AIR L-OUT.
     MOVE 0 TO L-OUT
     IF L-BORDER = 1 AND L-BOUNCES = 1
         MOVE 0.2 TO L-OUT
     END-IF
     IF L-BORDER = 0 AND L-AIR = 1
         MOVE -1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-BORDER-HIT.

*> 44-8 6.4 onDeflection: accelerationPower 0.1 after an attack, else halved.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-ON-DEFLECTION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                FLOAT-LONG.
 01 L-BY-ATTACK            BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-POWER L-BY-ATTACK L-OUT.
     IF L-BY-ATTACK = 1
         MOVE 0.1 TO L-OUT
     ELSE
         COMPUTE L-OUT = L-POWER * 0.5
     END-IF
     GOBACK.
 END PROGRAM Q8-ON-DEFLECTION.

*> 44-8 8 WindCharge noDeflectTicks: deflect is refused while it is above 0; the counter decrements each tick (here per call).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-NO-DEFLECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKS L-ALLOWED.
     MOVE 0 TO L-ALLOWED
     IF L-TICKS <= 0
         MOVE 1 TO L-ALLOWED
     ELSE
         SUBTRACT 1 FROM L-TICKS
     END-IF
     GOBACK.
 END PROGRAM Q8-NO-DEFLECT.

*> 44-8 6.6 bubble columns on a projectile: above a column vy - 0.03 (drag) or + 0.1; inside vy - 0.03 or + 0.06; an arrow in the ground does nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-PROJ-BUBBLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-IN-GROUND            BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DOWN L-INSIDE L-IN-GROUND L-VY.
     IF L-IN-GROUND = 0
         IF L-INSIDE = 1
             IF L-DOWN = 1
                 COMPUTE L-VY = L-VY - 0.03
             ELSE
                 COMPUTE L-VY = L-VY + 0.06
             END-IF
         ELSE
             IF L-DOWN = 1
                 COMPUTE L-VY = L-VY - 0.03
             ELSE
                 COMPUTE L-VY = L-VY + 0.1
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-PROJ-BUBBLE.

*> 44-8 7.3 step 9 after a blocked hit: a nearly stopped arrow (squared speed below 1e-7) is discarded, and drops its pickup item first when the mode is ALLOWED.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-ARROW-BLOCKED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED2               FLOAT-LONG.
 01 L-PICKUP               BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-DISCARD              BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED2 L-PICKUP L-DROP L-DISCARD.
     MOVE 0 TO L-DROP L-DISCARD
     IF L-SPEED2 < 0.0000001
         MOVE 1 TO L-DISCARD
         IF L-PICKUP = 1
             MOVE 1 TO L-DROP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-ARROW-BLOCKED.

*> 44-8 7.7 a tipped arrow with contents loses its potion after 600 ticks in the ground (Entity Event 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-TIPPED-DECAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-CONTENTS             BINARY-LONG.
 01 L-DECAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-CONTENTS L-DECAY.
     MOVE 0 TO L-DECAY
     IF L-TIME >= 600 AND L-CONTENTS = 1
         MOVE 1 TO L-DECAY
     END-IF
     GOBACK.
 END PROGRAM Q8-TIPPED-DECAY.

*> 44-8 8 wind charge parameters: radius 1.2 and knockback multiplier 1.22 (player charge), radius 3.0 and no multiplier (0 here) for the breeze charge.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-PARAMS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BREEZE               BINARY-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-KNOCKBACK            FLOAT-LONG.
 PROCEDURE DIVISION USING L-BREEZE L-RADIUS L-KNOCKBACK.
     MOVE 1.2 TO L-RADIUS
     MOVE 1.22 TO L-KNOCKBACK
     IF L-BREEZE = 1
         MOVE 3.0 TO L-RADIUS
         MOVE 0 TO L-KNOCKBACK
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-PARAMS.

*> 44-8 8 makeBoundingBox: 0.3125 x 0.3125, half width 0.15625, bottom 0.15 below the position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-BOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-MINY                 FLOAT-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-MINY L-MAXY L-HALF.
     COMPUTE L-MINY = L-Y - 0.15
     COMPUTE L-MAXY = L-MINY + 0.3125
     MOVE 0.15625 TO L-HALF
     GOBACK.
 END PROGRAM Q8-WIND-BOX.

*> 44-8 8 canHitEntity: never another wind charge or an end crystal; else the hurting projectile rule (pickable and with physics).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-CAN-HIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OTHER-WIND           BINARY-LONG.
 01 L-OTHER-CRYSTAL        BINARY-LONG.
 01 L-OTHER-HITTABLE       BINARY-LONG.
 01 L-OTHER-PHYSICS        BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OTHER-WIND L-OTHER-CRYSTAL L-OTHER-HITTABLE L-OTHER-PHYSICS L-OUT.
     MOVE 0 TO L-OUT
     IF L-OTHER-WIND = 0 AND L-OTHER-CRYSTAL = 0 AND L-OTHER-HITTABLE = 1 AND L-OTHER-PHYSICS = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-CAN-HIT.

*> 44-8 8 tick: a charge whose block y is above level.maxY + 30 explodes and is discarded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK-Y              BINARY-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-EXPLODE              BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK-Y L-MAX-Y L-EXPLODE.
     MOVE 0 TO L-EXPLODE
     IF L-BLOCK-Y > L-MAX-Y + 30
         MOVE 1 TO L-EXPLODE
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-TICK.

*> 44-8 8 block hit: explode(hitLocation + faceNormal x 0.25).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-CENTRE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HX                   FLOAT-LONG.
 01 L-HY                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-NX                   BINARY-LONG.
 01 L-NY                   BINARY-LONG.
 01 L-NZ                   BINARY-LONG.
 01 L-CX                   FLOAT-LONG.
 01 L-CY                   FLOAT-LONG.
 01 L-CZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-HX L-HY L-HZ L-NX L-NY L-NZ L-CX L-CY L-CZ.
     COMPUTE L-CX = L-HX + L-NX * 0.25
     COMPUTE L-CY = L-HY + L-NY * 0.25
     COMPUTE L-CZ = L-HZ + L-NZ * 0.25
     GOBACK.
 END PROGRAM Q8-WIND-CENTRE.

*> 44-8 8 getKnockbackMultiplier: 0 for a player whose abilities have flying, else the configured multiplier.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-KB-MULT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLYING-PLAYER        BINARY-LONG.
 01 L-CONFIGURED           FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-FLYING-PLAYER L-CONFIGURED L-OUT.
     MOVE L-CONFIGURED TO L-OUT
     IF L-FLYING-PLAYER = 1
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-KB-MULT.

*> 44-8 8 getBlockExplosionResistance with an immune set: 3600000.0 for a member block, an empty result (-1) for any other block.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-RESIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IMMUNE-SET           BINARY-LONG.
 01 L-MEMBER               BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-IMMUNE-SET L-MEMBER L-OUT.
     MOVE -1 TO L-OUT
     IF L-IMMUNE-SET = 1 AND L-MEMBER = 1
         MOVE 3600000.0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-RESIST.

*> 44-8 8 entity hit: damage 1.0, the post-attack effects when the hurt landed on a living target, and in every case the explosion.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-WIND-HIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIVING-OWNER         BINARY-LONG.
 01 L-HURT-LANDED          BINARY-LONG.
 01 L-TARGET-LIVING        BINARY-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 01 L-POST-EFFECTS         BINARY-LONG.
 01 L-EXPLODE              BINARY-LONG.
 PROCEDURE DIVISION USING L-LIVING-OWNER L-HURT-LANDED L-TARGET-LIVING L-DAMAGE L-POST-EFFECTS L-EXPLODE.
     MOVE 1.0 TO L-DAMAGE
     MOVE 0 TO L-POST-EFFECTS
     MOVE 1 TO L-EXPLODE
     IF L-HURT-LANDED = 1 AND L-TARGET-LIVING = 1
         MOVE 1 TO L-POST-EFFECTS
     END-IF
     GOBACK.
 END PROGRAM Q8-WIND-HIT.

*> 44-8 9 wither skull inertia: 0.73 when dangerous, 0.95 otherwise.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-SKULL-INERTIA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DANGEROUS            BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DANGEROUS L-OUT.
     MOVE 0.95 TO L-OUT
     IF L-DANGEROUS = 1
         MOVE 0.73 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-SKULL-INERTIA.

*> 44-8 9 skull getBlockExplosionResistance: min(0.8, base) when dangerous and WitherBoss.canDestroy, else the base resistance.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-SKULL-RESIST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DANGEROUS            BINARY-LONG.
 01 L-CAN-DESTROY          BINARY-LONG.
 01 L-BASE                 FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DANGEROUS L-CAN-DESTROY L-BASE L-OUT.
     MOVE L-BASE TO L-OUT
     IF L-DANGEROUS = 1 AND L-CAN-DESTROY = 1
         COMPUTE L-OUT = FUNCTION MIN(0.8, L-BASE)
     END-IF
     GOBACK.
 END PROGRAM Q8-SKULL-RESIST.

*> 44-8 9 wither skull entity hit: a living owner: 8.0 wither_skull damage, post-attack effects if the target survives, else the owner heals 5.0; no living owner: 5.0 magic.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-SKULL-HIT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIVING-OWNER         BINARY-LONG.
 01 L-TARGET-SURVIVES      BINARY-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 01 L-HEAL                 FLOAT-LONG.
 01 L-POST-EFFECTS         BINARY-LONG.
 PROCEDURE DIVISION USING L-LIVING-OWNER L-TARGET-SURVIVES L-DAMAGE L-HEAL L-POST-EFFECTS.
     MOVE 0 TO L-HEAL L-POST-EFFECTS
     IF L-LIVING-OWNER = 1
         MOVE 8.0 TO L-DAMAGE
         IF L-TARGET-SURVIVES = 1
             MOVE 1 TO L-POST-EFFECTS
         ELSE
             MOVE 5.0 TO L-HEAL
         END-IF
     ELSE
         MOVE 5.0 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM Q8-SKULL-HIT.

*> 44-8 9 Wither effect of a skull hit: 20 x seconds ticks, 10 s on Normal (2) and 40 s on Hard (3), none on Peaceful (0) and Easy (1); amplifier 1 (Wither II).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-SKULL-WITHER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-AMPLIFIER            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-TICKS L-AMPLIFIER.
     MOVE 0 TO L-TICKS
     MOVE 1 TO L-AMPLIFIER
     IF L-DIFFICULTY = 2
         MOVE 200 TO L-TICKS
     END-IF
     IF L-DIFFICULTY = 3
         MOVE 800 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM Q8-SKULL-WITHER.

*> 44-8 9 large fireball: the rule mob_griefing gives both the fire flag and block destruction; the explosion radius is explosionPower (default 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-FIREBALL-FIRE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOB-GRIEFING         BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-MOB-GRIEFING L-FIRE L-DESTROY L-POWER L-RADIUS.
     MOVE L-MOB-GRIEFING TO L-FIRE L-DESTROY
     IF L-POWER = 0
         MOVE 1 TO L-RADIUS
     ELSE
         MOVE L-POWER TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM Q8-FIREBALL-FIRE.

*> 44-8 10 ender pearl: discarded instead of ticking when its owner is a dead ServerPlayer who has not won the game and ender_pearls_vanish_on_death is true.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-PEARL-VANISH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWNER-DEAD-PLAYER    BINARY-LONG.
 01 L-WON-GAME             BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-DISCARD              BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER-DEAD-PLAYER L-WON-GAME L-RULE L-DISCARD.
     MOVE 0 TO L-DISCARD
     IF L-OWNER-DEAD-PLAYER = 1 AND L-WON-GAME = 0 AND L-RULE = 1
         MOVE 1 TO L-DISCARD
     END-IF
     GOBACK.
 END PROGRAM Q8-PEARL-VANISH.

*> 44-8 10 canTeleport: not from the End to the Overworld through the End portal unless the owner has seen the credits.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-PEARL-CAN-TELEPORT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FROM-END             BINARY-LONG.
 01 L-TO-OVERWORLD         BINARY-LONG.
 01 L-SEEN-CREDITS         BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM-END L-TO-OVERWORLD L-SEEN-CREDITS L-OUT.
     MOVE 1 TO L-OUT
     IF L-FROM-END = 1 AND L-TO-OVERWORLD = 1 AND L-SEEN-CREDITS = 0
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q8-PEARL-CAN-TELEPORT.

*> 44-8 10 lingering potion cloud: radius 3.0, radiusOnUse -0.5, duration 600, wait 10, radiusPerTick -radius / duration = -0.005.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-LINGER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RADIUS               FLOAT-LONG.
 01 L-ON-USE               FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-WAIT                 BINARY-LONG.
 01 L-PER-TICK             FLOAT-LONG.
 PROCEDURE DIVISION USING L-RADIUS L-ON-USE L-DURATION L-WAIT L-PER-TICK.
     MOVE 3.0 TO L-RADIUS
     MOVE -0.5 TO L-ON-USE
     MOVE 600 TO L-DURATION
     MOVE 10 TO L-WAIT
     COMPUTE L-PER-TICK = 0 - L-RADIUS / L-DURATION
     GOBACK.
 END PROGRAM Q8-LINGER.

*> 44-8 10 trident tick with loyalty: an unacceptable owner (1: drop the pickup item when ALLOWED, discard); a non-player owner within width + 1 of the eye (2: discard); else the trident returns (3: no physics, pull).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-TRIDENT-RETURN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOYALTY              BINARY-LONG.
 01 L-DEALT                BINARY-LONG.
 01 L-NO-PHYSICS           BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-OWNER-OK             BINARY-LONG.
 01 L-OWNER-PLAYER         BINARY-LONG.
 01 L-D                    FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-LOYALTY L-DEALT L-NO-PHYSICS L-OWNER L-OWNER-OK L-OWNER-PLAYER L-D L-WIDTH L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-LOYALTY > 0 AND (L-DEALT = 1 OR L-NO-PHYSICS = 1) AND L-OWNER = 1
         IF L-OWNER-OK = 0
             MOVE 1 TO L-ACTION
         ELSE
             IF L-OWNER-PLAYER = 0 AND L-D < L-WIDTH + 1
                 MOVE 2 TO L-ACTION
             ELSE
                 MOVE 3 TO L-ACTION
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM Q8-TRIDENT-RETURN.

*> 44-8 10 returning trident: d = owner eye - trident; y + d.y x 0.015 x loyalty (x and z unchanged); velocity = 0.95 v + normalize(d) x 0.05 x loyalty.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-TRIDENT-PULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-L  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DY                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-LOYALTY              BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-DY L-DX L-DZ L-LOYALTY L-VX L-VY L-VZ L-Y.
     COMPUTE WS-L = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     COMPUTE L-Y = L-Y + L-DY * 0.015 * L-LOYALTY
     COMPUTE L-VX = 0.95 * L-VX + L-DX / WS-L * 0.05 * L-LOYALTY
     COMPUTE L-VY = 0.95 * L-VY + L-DY / WS-L * 0.05 * L-LOYALTY
     COMPUTE L-VZ = 0.95 * L-VZ + L-DZ / WS-L * 0.05 * L-LOYALTY
     GOBACK.
 END PROGRAM Q8-TRIDENT-PULL.

*> 44-8 10 findHitEntity returns nothing once dealtDamage is true (the trident hits one target, base damage 8.0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-TRIDENT-DAMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEALT                BINARY-LONG.
 01 L-FIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DEALT L-FIND.
     MOVE 1 TO L-FIND
     IF L-DEALT = 1
         MOVE 0 TO L-FIND
     END-IF
     GOBACK.
 END PROGRAM Q8-TRIDENT-DAMAGE.

*> 44-8 10.4 experience bottle award: 3 + nextInt(5) + nextInt(5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-XP-BOTTLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N1                   BINARY-LONG.
 01 L-N2                   BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N1 L-N2 L-XP.
     COMPUTE L-XP = 3 + L-N1 + L-N2
     GOBACK.
 END PROGRAM Q8-XP-BOTTLE.

*> 44-8 10.1 shouldStopFishing: the hook is discarded unless the owner can interact, holds a rod in either hand and the squared distance is at most 1024.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-HOOK-STOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN-INTERACT         BINARY-LONG.
 01 L-ROD-MAIN             BINARY-LONG.
 01 L-ROD-OFF              BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN-INTERACT L-ROD-MAIN L-ROD-OFF L-D2 L-STOP.
     MOVE 1 TO L-STOP
     IF L-CAN-INTERACT = 1 AND (L-ROD-MAIN = 1 OR L-ROD-OFF = 1) AND L-D2 <= 1024.0
         MOVE 0 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM Q8-HOOK-STOP.

*> 44-8 10.1 pullEntity: velocity + (owner position - hook position) x 0.1 per axis (shown for x).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q8-HOOK-PULL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OX                   FLOAT-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-OX L-HX L-VX.
     COMPUTE L-VX = L-VX + (L-OX - L-HX) * 0.1
     GOBACK.
 END PROGRAM Q8-HOOK-PULL.

