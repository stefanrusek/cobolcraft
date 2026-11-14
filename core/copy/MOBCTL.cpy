*> Mob controls (docs/protocol/18-mob-framework.md section 4.4): the state and the inputs the caller reads from the mob for
*> MoveControl / FlyingMoveControl (MC-RECORD), LookControl (LC-RECORD) and SmoothSwimmingMoveControl (SW-RECORD).
*> Angles are in degrees; flags are 1 (yes) or 0. MC-OPERATION: 1 WAIT, 2 MOVE_TO, 3 STRAFE, 4 JUMPING.
 01 MC-RECORD.
    05 MC-OPERATION         BINARY-LONG.
    05 MC-DX                FLOAT-LONG.
    05 MC-DY                FLOAT-LONG.
    05 MC-DZ                FLOAT-LONG.
    05 MC-SPEED-MOD         FLOAT-LONG.
    05 MC-FORWARD           FLOAT-LONG.
    05 MC-RIGHT             FLOAT-LONG.
    05 MC-MOVEMENT-SPEED    FLOAT-LONG.
    05 MC-FLYING-SPEED      FLOAT-LONG.
    05 MC-YAW               FLOAT-LONG.
    05 MC-PITCH             FLOAT-LONG.
    05 MC-STEP-HEIGHT       FLOAT-LONG.
    05 MC-BB-WIDTH          FLOAT-LONG.
    05 MC-MAX-TURN          FLOAT-LONG.
    05 MC-ON-GROUND         BINARY-LONG.
    05 MC-IN-LIQUID         BINARY-LONG.
    05 MC-BLOCKING          BINARY-LONG.
    05 MC-WALKABLE          BINARY-LONG.
    05 MC-AIRBORNE          BINARY-LONG.
    05 MC-HOVERS            BINARY-LONG.
    05 MC-OUT-SPEED         FLOAT-LONG.
    05 MC-OUT-ZZA           FLOAT-LONG.
    05 MC-OUT-XXA           FLOAT-LONG.
    05 MC-OUT-YYA           FLOAT-LONG.
    05 MC-OUT-JUMP          BINARY-LONG.
    05 MC-NO-GRAVITY        BINARY-LONG.
 01 LC-RECORD.
    05 LC-COOLDOWN          BINARY-LONG.
    05 LC-DX                FLOAT-LONG.
    05 LC-DY                FLOAT-LONG.
    05 LC-DZ                FLOAT-LONG.
    05 LC-Y-HEAD            FLOAT-LONG.
    05 LC-X-ROT             FLOAT-LONG.
    05 LC-Y-BODY            FLOAT-LONG.
    05 LC-Y-MAX-SPEED       FLOAT-LONG.
    05 LC-X-MAX-ANGLE       FLOAT-LONG.
    05 LC-MAX-HEAD-Y        FLOAT-LONG.
    05 LC-NAV-DONE          BINARY-LONG.
 01 SW-RECORD.
    05 SW-APPLY-GRAVITY     BINARY-LONG.
    05 SW-IN-WATER          BINARY-LONG.
    05 SW-OPERATION         BINARY-LONG.
    05 SW-NAV-DONE          BINARY-LONG.
    05 SW-DX                FLOAT-LONG.
    05 SW-DY                FLOAT-LONG.
    05 SW-DZ                FLOAT-LONG.
    05 SW-MAX-TURN-X        FLOAT-LONG.
    05 SW-MAX-TURN-Y        FLOAT-LONG.
    05 SW-IN-MOD            FLOAT-LONG.
    05 SW-OUT-MOD           FLOAT-LONG.
    05 SW-SPEED-MOD         FLOAT-LONG.
    05 SW-MOVEMENT-SPEED    FLOAT-LONG.
    05 SW-Y-ROT             FLOAT-LONG.
    05 SW-X-ROT             FLOAT-LONG.
    05 SW-Y-HEAD            FLOAT-LONG.
    05 SW-Y-BODY            FLOAT-LONG.
    05 SW-OUT-SPEED         FLOAT-LONG.
    05 SW-OUT-XXA           FLOAT-LONG.
    05 SW-OUT-YYA           FLOAT-LONG.
    05 SW-OUT-ZZA           FLOAT-LONG.
    05 SW-VY-ADD            FLOAT-LONG.
