*> The item entity of docs/protocol/41-item-entity-physics.md (T0342 and following; core/copy/CITEMPHYS.cpy for the state).
*> Sections 1 to 8 of the document are implemented here; core/src/ground-items.cob keeps the tracker side (packets, the
*> per-tick loop) and calls these programs.
*>
*> Section 1, the entity and its random sources:
*>   IP-RNG-SEED USING state (BINARY-DOUBLE), seed (BINARY-DOUBLE)   state = seed mod 2^48
*>   IP-RNG-NEXT USING state, bits (BINARY-LONG), value out (BINARY-LONG)   the next(bits) of java.util.Random
*>   IP-RNG-FLOAT USING state, value out (FLOAT-LONG)    nextFloat: next(24) / 2^24
*>   IP-RNG-DOUBLE USING state, value out (FLOAT-LONG)   nextDouble: (next(26) * 2^27 + next(27)) / 2^53
*>   IP-ITEM-SEED USING entity id, state out    the starting state of an item entity's own source
*>   IP-LEVEL-DOUBLE USING value out; IP-PLAYER-FLOAT USING player row, value out   the level and player sources
*>   IP-INIT, IP-ENSURE USING tracker row      the record of CITEMPHYS.cpy of a row (defaults of 41 section 1)
*>   IP-SETUP USING tracker row, kind (IP-SET-*); IP-HAS-DELAY USING tracker row, result (1 or 0)
*>   IP-NEW USING dim, x, y, z, item, count, delay, patch handle, row out   a new item entity, not yet in the tracker
*>   IP-RANDOM-MOTION USING row                 the motion of the five-argument constructor
*>   IP-ANNOUNCE USING row                      the entity enters the tracker (Add Entity, Set Entity Data, Set Entity Motion)
*>   GI-SPAWN-X USING dim, x, y, z, vx, vy, vz, item, count, delay, row out, patch handle   explicit motion
*>   GI-SPAWN-RANDOM USING dim, x, y, z, item, count, patch handle, delay, row out   random motion

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RNG-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MOD                 BINARY-DOUBLE VALUE 281474976710656.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-STATE L-SEED.
     COMPUTE L-STATE = FUNCTION MOD(L-SEED, WS-MOD)
     GOBACK.
 END PROGRAM IP-RNG-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RNG-NEXT.
*> state <- (state * 0x5DEECE66D + 11) mod 2^48, value = state div 2^(48 - bits). The product exceeds 64 bits, so the state is
*> split into a high and a low part of 24 bits.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MUL                 BINARY-DOUBLE VALUE 25214903917.
 01 WS-M24                 BINARY-DOUBLE VALUE 16777216.
 01 WS-HIGH                BINARY-DOUBLE.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-LOW-PRODUCT         BINARY-DOUBLE.
 01 WS-DIVISOR             BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE.
 01 L-BITS                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BITS L-VALUE.
     COMPUTE WS-HIGH = FUNCTION INTEGER(L-STATE / WS-M24)
     COMPUTE WS-LOW = FUNCTION MOD(L-STATE, WS-M24)
     COMPUTE WS-LOW-PRODUCT = WS-LOW * WS-MUL + 11
     COMPUTE L-STATE = FUNCTION MOD(FUNCTION MOD(WS-HIGH * WS-MUL + FUNCTION INTEGER(WS-LOW-PRODUCT / WS-M24), WS-M24)
         * WS-M24 + FUNCTION MOD(WS-LOW-PRODUCT, WS-M24), 281474976710656)
     COMPUTE WS-DIVISOR = 2 ** (48 - L-BITS)
     COMPUTE L-VALUE = FUNCTION INTEGER(L-STATE / WS-DIVISOR)
     GOBACK.
 END PROGRAM IP-RNG-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RNG-FLOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 24.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-VALUE.
     CALL "IP-RNG-NEXT" USING L-STATE WS-BITS WS-NEXT
     COMPUTE L-VALUE = WS-NEXT / 16777216
     GOBACK.
 END PROGRAM IP-RNG-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RNG-DOUBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS-HIGH           BINARY-LONG VALUE 26.
 01 WS-BITS-LOW            BINARY-LONG VALUE 27.
 01 WS-HIGH                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-VALUE.
     CALL "IP-RNG-NEXT" USING L-STATE WS-BITS-HIGH WS-HIGH
     CALL "IP-RNG-NEXT" USING L-STATE WS-BITS-LOW WS-LOW
     COMPUTE L-VALUE = (WS-HIGH * 134217728 + WS-LOW) / 9007199254740992
     GOBACK.
 END PROGRAM IP-RNG-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-ITEM-SEED.
*> USING entity id (BINARY-LONG), state out (BINARY-DOUBLE): the mixed id (RNG-MIX) in the high 32 bits of the 48-bit state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-DOUBLE.
 01 WS-MIXED               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ID L-STATE.
     MOVE L-ID TO WS-ID
     CALL "RNG-MIX" USING WS-ID WS-MIXED
     COMPUTE L-STATE = WS-MIXED * 65536 + FUNCTION MOD(L-ID, 65536)
     GOBACK.
 END PROGRAM IP-ITEM-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-LEVEL-DOUBLE.
*> USING value out (FLOAT-LONG): nextDouble of the level's random source (seeded on first use).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-SEED                BINARY-DOUBLE VALUE 20260311.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     IF IP-LEVEL-SEEDED = 0
         CALL "IP-RNG-SEED" USING IP-LEVEL-RNG WS-SEED
         MOVE 1 TO IP-LEVEL-SEEDED
     END-IF
     CALL "IP-RNG-DOUBLE" USING IP-LEVEL-RNG L-VALUE
     GOBACK.
 END PROGRAM IP-LEVEL-DOUBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-PLAYER-FLOAT.
*> USING player row, value out (FLOAT-LONG): nextFloat of the player's random source (seeded on first use from its entity id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALUE.
     IF IP-P-SEEDED(L-ROW) = 0
         COMPUTE WS-ID = PL-ENTITY-ID(L-ROW) + 1000
         CALL "IP-ITEM-SEED" USING WS-ID IP-P-RNG(L-ROW)
         MOVE 1 TO IP-P-SEEDED(L-ROW)
     END-IF
     CALL "IP-RNG-FLOAT" USING IP-P-RNG(L-ROW) L-VALUE
     GOBACK.
 END PROGRAM IP-PLAYER-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-INIT.
*> USING tracker row: the record of the row with the defaults of 41 section 1 and the random source seeded from the entity id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     INITIALIZE IP-ITEM(L-ROW)
     MOVE EN-ID(L-ROW) TO IP-I-ID(L-ROW)
     MOVE IP-DEFAULT-HEALTH TO IP-I-HEALTH(L-ROW)
     CALL "IP-ITEM-SEED" USING EN-ID(L-ROW) IP-I-RNG(L-ROW)
     MOVE EN-X(L-ROW) TO IP-I-SENT-X(L-ROW)
     MOVE EN-Y(L-ROW) TO IP-I-SENT-Y(L-ROW)
     MOVE EN-Z(L-ROW) TO IP-I-SENT-Z(L-ROW)
     GOBACK.
 END PROGRAM IP-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-ENSURE.
*> USING tracker row: IP-INIT unless the record already belongs to the entity of the row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF IP-I-ID(L-ROW) NOT = EN-ID(L-ROW)
         CALL "IP-INIT" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM IP-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-SETUP.
*> USING tracker row, kind (IP-SET-*): setDefaultPickUpDelay, setNoPickUpDelay, setNeverPickUp, setUnlimitedLifetime,
*> setExtendedLifetime, makeFakeItem (never pick up plus age 5999).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND.
     EVALUATE L-KIND
         WHEN IP-SET-DEFAULT-DELAY
             MOVE IP-DELAY-DEFAULT TO EN-DELAY(L-ROW)
         WHEN IP-SET-NO-DELAY
             MOVE 0 TO EN-DELAY(L-ROW)
         WHEN IP-SET-NEVER-PICKUP
             MOVE IP-NEVER-PICKUP TO EN-DELAY(L-ROW)
         WHEN IP-SET-UNLIMITED-LIFE
             MOVE IP-INFINITE-LIFETIME TO EN-AGE(L-ROW)
         WHEN IP-SET-EXTENDED-LIFE
             COMPUTE EN-AGE(L-ROW) = 0 - IP-LIFETIME
         WHEN IP-SET-FAKE-ITEM
             MOVE IP-NEVER-PICKUP TO EN-DELAY(L-ROW)
             COMPUTE EN-AGE(L-ROW) = IP-LIFETIME - 1
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-HAS-DELAY.
*> USING tracker row, result (BINARY-LONG): 1 when pickupDelay is above 0 (32767 counts as delayed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     MOVE 0 TO L-RESULT
     IF EN-DELAY(L-ROW) > 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM IP-HAS-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-NEW.
*> USING dimension row, x, y, z (FLOAT-LONG), item, count, pickup delay, patch handle (BINARY-LONG), row out: a tracker row of
*> a new item entity of age 0 with motion 0; the base entity draws bobOffs and then the yaw (nextFloat * 360) from the item's
*> own source. The caller sets the motion and calls IP-ANNOUNCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-DELAY L-VAR L-ROW.
     CALL "ENTITY-ALLOC" USING L-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
     MOVE CR-LOOSE-ITEM TO EN-TYPE(L-ROW)
     CALL "ENTITY-SET-UUID" USING L-ROW
     MOVE L-DIM TO EN-DIM(L-ROW)
     MOVE L-X TO EN-X(L-ROW)
     MOVE L-Y TO EN-Y(L-ROW)
     MOVE L-Z TO EN-Z(L-ROW)
     MOVE L-ITEM TO EN-ITEM(L-ROW)
     MOVE L-COUNT TO EN-ITEM-COUNT(L-ROW)
     MOVE L-DELAY TO EN-DELAY(L-ROW)
     CALL "IP-INIT" USING L-ROW
     MOVE L-VAR TO IP-I-VAR(L-ROW)
     CALL "IP-RNG-FLOAT" USING IP-I-RNG(L-ROW) IP-I-BOB(L-ROW)
     CALL "IP-RNG-FLOAT" USING IP-I-RNG(L-ROW) WS-DRAW
     COMPUTE EN-YAW(L-ROW) = WS-DRAW * 360
     GOBACK.
 END PROGRAM IP-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RANDOM-MOTION.
*> USING tracker row: the motion of the five-argument constructor: (nextDouble * 0.2 - 0.1, 0.2, nextDouble * 0.2 - 0.1), x
*> drawn before z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "IP-RNG-DOUBLE" USING IP-I-RNG(L-ROW) WS-DRAW
     COMPUTE EN-VX(L-ROW) = WS-DRAW * 0.2 - 0.1
     MOVE 0.2 TO EN-VY(L-ROW)
     CALL "IP-RNG-DOUBLE" USING IP-I-RNG(L-ROW) WS-DRAW
     COMPUTE EN-VZ(L-ROW) = WS-DRAW * 0.2 - 0.1
     GOBACK.
 END PROGRAM IP-RANDOM-MOTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-ANNOUNCE.
*> USING tracker row: the entity enters the tracker; every player who sees it gets Add Entity (movement = its motion) and Set
*> Entity Data with its stack, then Set Entity Motion when its motion is not (0, 0, 0) (09 section 3.4 rule 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "ENTITY-TRACK" USING L-ROW
     IF EN-VX(L-ROW) NOT = 0 OR EN-VY(L-ROW) NOT = 0 OR EN-VZ(L-ROW) NOT = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "SET-ENTITY-MOTION-BUILD" USING EN-ID(L-ROW) EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW) PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM IP-ANNOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SPAWN-X.
*> USING dimension row, x, y, z, vx, vy, vz (FLOAT-LONG), item, count, pickup delay, row out, patch handle (BINARY-LONG): the
*> eight-argument constructor: explicit motion, no motion draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-ITEM L-COUNT L-DELAY L-ROW L-VAR.
     CALL "IP-NEW" USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-DELAY L-VAR L-ROW
     MOVE L-VX TO EN-VX(L-ROW)
     MOVE L-VY TO EN-VY(L-ROW)
     MOVE L-VZ TO EN-VZ(L-ROW)
     CALL "IP-ANNOUNCE" USING L-ROW
     GOBACK.
 END PROGRAM GI-SPAWN-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SPAWN-RANDOM.
*> USING dimension row, x, y, z (FLOAT-LONG), item, count, patch handle, pickup delay, row out (BINARY-LONG): the five-argument
*> constructor: the random motion of IP-RANDOM-MOTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-VAR L-DELAY L-ROW.
     CALL "IP-NEW" USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-DELAY L-VAR L-ROW
     CALL "IP-RANDOM-MOTION" USING L-ROW
     CALL "IP-ANNOUNCE" USING L-ROW
     GOBACK.
 END PROGRAM GI-SPAWN-RANDOM.

*> Section 2, spawning:
*>   IP-MTH-SIN, IP-MTH-COS USING x (FLOAT-LONG), result out   the table-driven Mth.sin and Mth.cos of docs/protocol/11
*>   IP-THROW-MOTION USING yaw, pitch (degrees), r1, r2, r3, r4 (the four nextFloat draws), vx, vy, vz out   2.3 step 4
*>   IP-DEATH-MOTION USING r1, r2, vx, vy, vz out   2.4
*>   GI-POP-RESOURCE USING dim, x, y, z (block), item, count, patch handle, row out (0 when nothing was spawned)   2.1
*>   GI-POP-FACE USING dim, x, y, z (block), face (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), item, count, patch handle,
*>     row out   2.2
*>   IP-AT-LOCATION USING dim, x, y, z, y offset (FLOAT-LONG), item, count, patch handle, row out   Entity.spawnAtLocation
*>   GI-THROW-STACK-X USING player row, item, count, patch handle   a thrown drop of the player (delay 40, thrower, stats)
*>   GI-DROP-EXTRA USING player row, item, count, patch handle   the same for an item that did not fit (no thrower, no stats)
*>   GI-DEATH-DROP USING player row, item, count, patch handle   one stack of the inventory death drop
*>   GI-CREATIVE-DROP USING player row, item, count, patch handle   a creative inventory drop through the throttle
*>   GI-DISPENSE USING dim, x, y, z (dispenser block), facing, item, row out   DefaultDispenseItemBehavior, one item
*>   IP-STAT-ADD USING player row, kind (IP-STAT-*), item, amount; IP-STAT-GET USING player row, kind, item, value out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-MTH-SIN.
*> USING x (FLOAT-LONG, radians), result out: TABLE[(long)(x * 10430.378350470453) & 65535] of a 65536-entry sine table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-RESULT.
     COMPUTE WS-INDEX = FUNCTION MOD(FUNCTION INTEGER-PART(L-X * 10430.378350470453), 65536)
     COMPUTE L-RESULT = FUNCTION SIN(WS-INDEX * FUNCTION PI * 2 / 65536)
     GOBACK.
 END PROGRAM IP-MTH-SIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-MTH-COS.
*> USING x (FLOAT-LONG, radians), result out: the same table at the index (long)(x * 10430.378350470453 + 16384.0) & 65535.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-RESULT.
     COMPUTE WS-INDEX = FUNCTION MOD(FUNCTION INTEGER-PART(L-X * 10430.378350470453 + 16384), 65536)
     COMPUTE L-RESULT = FUNCTION SIN(WS-INDEX * FUNCTION PI * 2 / 65536)
     GOBACK.
 END PROGRAM IP-MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-THROW-MOTION.
*> USING yaw, pitch (FLOAT-LONG degrees), r1, r2, r3, r4 (the nextFloat draws in order), vx, vy, vz out (FLOAT-LONG): 41 section
*> 2.3 step 4. P and Y are the f32 products of the degrees and 0.017453292; a = r1 * 6.2831855, b = 0.02 * r2; vx = -sinY * cosP *
*> 0.3 + cos(a) * b, vy = -sinP * 0.3 + 0.1 + (r3 - r4) * 0.1, vz = cosY * cosP * 0.3 + sin(a) * b (the table functions for P and Y,
*> the ordinary ones for a).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TO-RADIANS          FLOAT-SHORT VALUE 0.017453292.
 01 WS-TURN                FLOAT-SHORT VALUE 6.2831855.
 01 WS-P                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-PL                  FLOAT-LONG.
 01 WS-YL                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-SIN-P               FLOAT-LONG.
 01 WS-COS-P               FLOAT-LONG.
 01 WS-SIN-Y               FLOAT-LONG.
 01 WS-COS-Y               FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 0.30000001192092896.
 01 WS-LIFT                FLOAT-LONG VALUE 0.10000000149011612.
 01 WS-SPREAD              FLOAT-LONG VALUE 0.019999999552965164.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-R4                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-R1 L-R2 L-R3 L-R4 L-VX L-VY L-VZ.
     COMPUTE WS-P = L-PITCH * WS-TO-RADIANS
     COMPUTE WS-Y = L-YAW * WS-TO-RADIANS
     MOVE WS-P TO WS-PL
     MOVE WS-Y TO WS-YL
     CALL "IP-MTH-SIN" USING WS-PL WS-SIN-P
     CALL "IP-MTH-COS" USING WS-PL WS-COS-P
     CALL "IP-MTH-SIN" USING WS-YL WS-SIN-Y
     CALL "IP-MTH-COS" USING WS-YL WS-COS-Y
     COMPUTE WS-A = L-R1 * WS-TURN
     COMPUTE WS-B = WS-SPREAD * L-R2
     COMPUTE L-VX = 0 - WS-SIN-Y * WS-COS-P * WS-POWER + FUNCTION COS(WS-A) * WS-B
     COMPUTE L-VY = 0 - WS-SIN-P * WS-POWER + WS-LIFT + (L-R3 - L-R4) * WS-LIFT
     COMPUTE L-VZ = WS-COS-Y * WS-COS-P * WS-POWER + FUNCTION SIN(WS-A) * WS-B
     GOBACK.
 END PROGRAM IP-THROW-MOTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-DEATH-MOTION.
*> USING r1, r2 (the nextFloat draws), vx, vy, vz out (FLOAT-LONG): f = r1 * 0.5, g = r2 * 6.2831855; (-sin(g) * f, the f32 value
*> of 0.2, cos(g) * f) with the table functions.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TURN                FLOAT-SHORT VALUE 6.2831855.
 01 WS-G                   FLOAT-SHORT.
 01 WS-GL                  FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-VX L-VY L-VZ.
     COMPUTE WS-F = L-R1 * 0.5
     COMPUTE WS-G = L-R2 * WS-TURN
     MOVE WS-G TO WS-GL
     CALL "IP-MTH-SIN" USING WS-GL WS-SIN
     CALL "IP-MTH-COS" USING WS-GL WS-COS
     COMPUTE L-VX = 0 - WS-SIN * WS-F
     MOVE 0.20000000298023224 TO L-VY
     COMPUTE L-VZ = WS-COS * WS-F
     GOBACK.
 END PROGRAM IP-DEATH-MOTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-LEVEL-RANGE.
*> USING low, high (FLOAT-LONG), value out: Mth.nextDouble(random, low, high) = low + nextDouble * (high - low) from the level source
*> (low when low >= high; no draw is made then? the draw is made first, as in the artifact: low + draw * (high - low) with the
*> draw taken in every case).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LOW                  FLOAT-LONG.
 01 L-HIGH                 FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-LOW L-HIGH L-VALUE.
     CALL "IP-LEVEL-DOUBLE" USING WS-DRAW
     COMPUTE L-VALUE = L-LOW + WS-DRAW * (L-HIGH - L-LOW)
     GOBACK.
 END PROGRAM IP-LEVEL-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-POP-RESOURCE.
*> USING dimension row, block x, y, z, item, count, patch handle, row out (BINARY-LONG): 41 section 2.1. The three level draws
*> come first and always; only then the gate (a non-empty stack, game rule block_drops) decides whether an entity is built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-LOW                 FLOAT-LONG VALUE -0.25.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-ITEM L-COUNT L-VAR L-ROW.
     CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-DX
     CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-DY
     CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-DZ
     MOVE 0 TO L-ROW
     IF L-COUNT > 0 AND IP-NO-BLOCK-DROPS = 0
         COMPUTE WS-X = L-BX + 0.5 + WS-DX
         COMPUTE WS-Y = L-BY + 0.5 + WS-DY - 0.125
         COMPUTE WS-Z = L-BZ + 0.5 + WS-DZ
         CALL "GI-SPAWN-RANDOM" USING L-DIM WS-X WS-Y WS-Z L-ITEM L-COUNT L-VAR WS-DELAY L-ROW
     END-IF
     GOBACK.
 END PROGRAM GI-POP-RESOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-POP-FACE.
*> USING dimension row, block x, y, z, face, item, count, patch handle, row out (BINARY-LONG): 41 section 2.2. Per axis: a step of
*> 0 draws the position r(-0.25, 0.25) and the motion r(-0.1, 0.1) (y: r(0, 0.1)); a step of +-1 gives the position offset
*> step * 0.625 and the motion step * 0.1 (y: step * 0.1 + 0.1). All draws precede the gate.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 COPY CFACE.
 01 WS-LOW                 FLOAT-LONG VALUE -0.25.
 01 WS-HIGH                FLOAT-LONG VALUE 0.25.
 01 WS-MLOW                FLOAT-LONG VALUE -0.1.
 01 WS-MHIGH               FLOAT-LONG VALUE 0.1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-FACE L-ITEM L-COUNT L-VAR L-ROW.
     IF FC-SX(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-OX
     ELSE
         COMPUTE WS-OX = FC-SX(L-FACE + 1) * 0.625
     END-IF
     IF FC-SY(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-OY
     ELSE
         COMPUTE WS-OY = FC-SY(L-FACE + 1) * 0.625
     END-IF
     IF FC-SZ(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-LOW WS-HIGH WS-OZ
     ELSE
         COMPUTE WS-OZ = FC-SZ(L-FACE + 1) * 0.625
     END-IF
     IF FC-SX(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-MLOW WS-MHIGH WS-VX
     ELSE
         COMPUTE WS-VX = FC-SX(L-FACE + 1) * 0.1
     END-IF
     IF FC-SY(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-ZERO WS-MHIGH WS-VY
     ELSE
         COMPUTE WS-VY = FC-SY(L-FACE + 1) * 0.1 + 0.1
     END-IF
     IF FC-SZ(L-FACE + 1) = 0
         CALL "IP-LEVEL-RANGE" USING WS-MLOW WS-MHIGH WS-VZ
     ELSE
         COMPUTE WS-VZ = FC-SZ(L-FACE + 1) * 0.1
     END-IF
     MOVE 0 TO L-ROW
     IF L-COUNT > 0 AND IP-NO-BLOCK-DROPS = 0
         COMPUTE WS-X = L-BX + 0.5 + WS-OX
         COMPUTE WS-Y = L-BY + 0.5 + WS-OY - 0.125
         COMPUTE WS-Z = L-BZ + 0.5 + WS-OZ
         CALL "GI-SPAWN-X" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ L-ITEM L-COUNT WS-DELAY L-ROW L-VAR
     END-IF
     GOBACK.
 END PROGRAM GI-POP-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-AT-LOCATION.
*> USING dimension row, x, y, z, y offset (FLOAT-LONG), item, count, patch handle, row out: Entity.spawnAtLocation: the position
*> plus (0, offset, 0), the random motion of the constructor, delay 10; an empty stack spawns nothing (row 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OFFSET L-ITEM L-COUNT L-VAR L-ROW.
     MOVE 0 TO L-ROW
     IF L-COUNT > 0
         COMPUTE WS-Y = L-Y + L-OFFSET
         CALL "GI-SPAWN-RANDOM" USING L-DIM L-X WS-Y L-Z L-ITEM L-COUNT L-VAR WS-DELAY L-ROW
     END-IF
     GOBACK.
 END PROGRAM IP-AT-LOCATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-STAT-ADD.
*> USING player row, kind (IP-STAT-PICKED, IP-STAT-DROPPED, IP-STAT-DROP), item, amount (BINARY-LONG): adds to the statistic
*> (IP-STAT-DROP counts per player only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-ITEM L-AMOUNT.
     EVALUATE L-KIND
         WHEN IP-STAT-PICKED
             ADD L-AMOUNT TO IP-S-PICKED(L-ROW, L-ITEM + 1)
         WHEN IP-STAT-DROPPED
             ADD L-AMOUNT TO IP-S-DROPPED(L-ROW, L-ITEM + 1)
         WHEN OTHER
             ADD L-AMOUNT TO IP-S-DROP-ACTIONS(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-STAT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-STAT-GET.
*> USING player row, kind, item, value out (BINARY-LONG): the statistic of IP-STAT-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-ITEM L-VALUE.
     EVALUATE L-KIND
         WHEN IP-STAT-PICKED
             MOVE IP-S-PICKED(L-ROW, L-ITEM + 1) TO L-VALUE
         WHEN IP-STAT-DROPPED
             MOVE IP-S-DROPPED(L-ROW, L-ITEM + 1) TO L-VALUE
         WHEN OTHER
             MOVE IP-S-DROP-ACTIONS(L-ROW) TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-STAT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-DROP-CORE.
*> USING player row, item, count, patch handle, mode (BINARY-LONG; 0 thrown by the player, 1 extra items, 2 death drop), row out:
*> LivingEntity.createItemStackToDrop: at (x, eye y - 0.30000001192092896, z), delay 40, the constructor's draws, then the motion of
*> the mode from the player's own source. Mode 0 names the thrower and awards item_dropped (the count passed in) and the custom stat
*> drop. An empty stack drops nothing (row 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-DELAY               BINARY-LONG VALUE 40.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-Y                   FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 01 WS-R4                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-ZERO-ITEM           BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR L-MODE L-ROW.
     MOVE 0 TO L-ROW
     IF L-COUNT > 0
         COMPUTE WS-Y = PL-Y(L-PLAYER) + 1.62 - 0.30000001192092896
         CALL "GI-SPAWN-RANDOM-HELD" USING PL-DIM(L-PLAYER) PL-X(L-PLAYER) WS-Y PL-Z(L-PLAYER) L-ITEM L-COUNT L-VAR
             WS-DELAY L-ROW
         IF L-MODE = 2
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R1
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R2
             CALL "IP-DEATH-MOTION" USING WS-R1 WS-R2 EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
         ELSE
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R1
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R2
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R3
             CALL "IP-PLAYER-FLOAT" USING L-PLAYER WS-R4
             MOVE PL-YAW(L-PLAYER) TO WS-YAW
             MOVE PL-PITCH(L-PLAYER) TO WS-PITCH
             CALL "IP-THROW-MOTION" USING WS-YAW WS-PITCH WS-R1 WS-R2 WS-R3 WS-R4 EN-VX(L-ROW) EN-VY(L-ROW)
                 EN-VZ(L-ROW)
         END-IF
         IF L-MODE = 0
             MOVE PL-ENTITY-ID(L-PLAYER) TO IP-I-THROWER(L-ROW)
             CALL "IP-STAT-ADD" USING L-PLAYER IP-STAT-DROPPED L-ITEM L-COUNT
             CALL "IP-STAT-ADD" USING L-PLAYER IP-STAT-DROP WS-ZERO-ITEM WS-ONE
         END-IF
         CALL "IP-ANNOUNCE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM GI-DROP-CORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-SPAWN-RANDOM-HELD.
*> USING dimension row, x, y, z, item, count, patch handle, pickup delay, row out: GI-SPAWN-RANDOM without the announcement, so the
*> caller can replace the motion before the viewers are told.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-VAR L-DELAY L-ROW.
     CALL "IP-NEW" USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-DELAY L-VAR L-ROW
     CALL "IP-RANDOM-MOTION" USING L-ROW
     GOBACK.
 END PROGRAM GI-SPAWN-RANDOM-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-THROW-STACK-X.
*> USING player row, item, count, patch handle (BINARY-LONG): GI-DROP-CORE mode 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR.
     CALL "GI-DROP-CORE" USING L-PLAYER L-ITEM L-COUNT L-VAR WS-MODE WS-ROW
     GOBACK.
 END PROGRAM GI-THROW-STACK-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-DROP-EXTRA.
*> USING player row, item, count, patch handle: GI-DROP-CORE mode 1 (an item that did not fit: no thrower, no statistics).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR.
     CALL "GI-DROP-CORE" USING L-PLAYER L-ITEM L-COUNT L-VAR WS-MODE WS-ROW
     GOBACK.
 END PROGRAM GI-DROP-EXTRA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-DEATH-DROP.
*> USING player row, item, count, patch handle: GI-DROP-CORE mode 2 (Inventory.dropAll: random circle motion, no thrower).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR.
     CALL "GI-DROP-CORE" USING L-PLAYER L-ITEM L-COUNT L-VAR WS-MODE WS-ROW
     GOBACK.
 END PROGRAM GI-DEATH-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-CREATIVE-DROP.
*> USING player row, item, count, patch handle: 41 section 2.3.1. The TickThrottler (step 20, threshold 1480) allows the drop while
*> its count is below 1480 and then adds 20; a refused drop is lost. GROUND-ITEMS-TICK lowers the count by 1 per tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR.
     IF IP-P-THROTTLE(L-PLAYER) < IP-THROTTLE-LIMIT
         ADD IP-THROTTLE-STEP TO IP-P-THROTTLE(L-PLAYER)
         CALL "GI-THROW-STACK-X" USING L-PLAYER L-ITEM L-COUNT L-VAR
     END-IF
     GOBACK.
 END PROGRAM GI-CREATIVE-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GI-DISPENSE.
*> USING dimension row, block x, y, z, facing (0 to 5 as GI-POP-FACE), item, row out: DefaultDispenseItemBehavior.spawnItem with
*> one item: position = block centre + step * 0.7, y lowered by 0.125 (vertical facing) or 0.15625; no pickup delay; speed =
*> nextDouble * 0.1 + 0.2, spread 0.0172275 * 6; motion x = triangle(stepX * speed), y = triangle(0.2), z = triangle(stepZ * speed)
*> with triangle(c, d) = c + d * (nextDouble - nextDouble), all from the level source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CFACE.
 01 WS-ZERO-DELAY          BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-LIFT                FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-FACING L-ITEM L-ROW.
     COMPUTE WS-X = L-BX + 0.5 + FC-SX(L-FACING + 1) * 0.7
     COMPUTE WS-Y = L-BY + 0.5 + FC-SY(L-FACING + 1) * 0.7
     COMPUTE WS-Z = L-BZ + 0.5 + FC-SZ(L-FACING + 1) * 0.7
     IF FC-SY(L-FACING + 1) = 0
         SUBTRACT 0.15625 FROM WS-Y
     ELSE
         SUBTRACT 0.125 FROM WS-Y
     END-IF
     CALL "IP-LEVEL-DOUBLE" USING WS-D1
     COMPUTE WS-SPEED = WS-D1 * 0.1 + 0.2
     COMPUTE WS-LIFT = FC-SX(L-FACING + 1) * WS-SPEED
     CALL "IP-TRIANGLE" USING WS-LIFT WS-VX
     MOVE 0.2 TO WS-LIFT
     CALL "IP-TRIANGLE" USING WS-LIFT WS-VY
     COMPUTE WS-LIFT = FC-SZ(L-FACING + 1) * WS-SPEED
     CALL "IP-TRIANGLE" USING WS-LIFT WS-VZ
     CALL "GI-SPAWN-RANDOM-HELD" USING L-DIM WS-X WS-Y WS-Z L-ITEM WS-ONE WS-NONE WS-ZERO-DELAY L-ROW
     MOVE WS-VX TO EN-VX(L-ROW)
     MOVE WS-VY TO EN-VY(L-ROW)
     MOVE WS-VZ TO EN-VZ(L-ROW)
     CALL "IP-ANNOUNCE" USING L-ROW
     GOBACK.
 END PROGRAM GI-DISPENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-TRIANGLE.
*> USING centre (FLOAT-LONG), value out: centre + 0.103365 * (nextDouble - nextDouble) of the level source (the dispenser's spread
*> 0.0172275 * accuracy 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CENTRE               FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-CENTRE L-VALUE.
     CALL "IP-LEVEL-DOUBLE" USING WS-D1
     CALL "IP-LEVEL-DOUBLE" USING WS-D2
     COMPUTE L-VALUE = L-CENTRE + 0.103365 * (WS-D1 - WS-D2)
     GOBACK.
 END PROGRAM IP-TRIANGLE.

*> Section 3, the tick (GI-STEP of core/src/ground-items.cob calls these in the order of 41 section 3 steps 1 to 12):
*>   IP-RESTITUTE USING vy (after gravity), moved y (the collided distance), block restitution (FLOAT-LONG), vy out   3.3, a
*>     downward collision of an item: 0 when -vy <= 0.04, else (ratio * 0.04 - vy) * (1 + ratio * (0.98 - 1)) * block * 0.8
*>   IP-FRICTION USING dim, x, y, z (FLOAT-LONG), friction out        the block below (getOnPos 0.999999) and its friction
*>   IP-BOUNCINESS USING dim, x, y, z, restitution out                the block at the legacy on-position (0.2 below)
*>   IP-FLUID-CELL USING dim, x, y, z (BINARY-LONG), kind out (0 none, 1 water, 2 lava), height out (FLOAT-LONG)
*>   IP-FLUID-SCAN USING tracker row      water and lava height of the item box, the water flag (3.2)
*>   IP-PUSH-OUT USING tracker row, x, y, z (the box centre column), vx, vy, vz   3.4
*>   IP-AXIS-MOVE USING dim, x, y, z, axis (1 x, 2 y, 3 z), delta, hit out   a swept move of one axis against solid cells
*>   IP-ITEM-MOVE USING tracker row, changed cell out (1 or 0)   steps 4 to 8 (forces, push out, the move, friction)
*>   IP-FIRE-TICK, IP-LAVA-EFFECTS USING tracker row, alive out; IP-HURT, IP-FIRE-IMMUNE and the rest of 5 are below.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RESTITUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VY                   FLOAT-LONG.
 01 L-MOVED                FLOAT-LONG.
 01 L-BLOCK                FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-VY L-MOVED L-BLOCK L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE 0 TO WS-B
     IF 0 - L-VY > 0.04
         COMPUTE WS-B = L-BLOCK * 0.8
     END-IF
     IF WS-B > 0
         COMPUTE WS-RATIO = L-MOVED / L-VY
         COMPUTE L-RESULT = (WS-RATIO * 0.04 - L-VY) * (1 + WS-RATIO * (0.98 - 1)) * WS-B
     END-IF
     GOBACK.
 END PROGRAM IP-RESTITUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-BLOCK-KEY.
*> USING dimension row, cell x, y, z (BINARY-LONG), key out (PIC X(48)), length out (BINARY-LONG): the key of the block in the cell
*> (a cell of an unloaded chunk has the length 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-LENGTH
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK > 0
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         MOVE CB-KEY(WS-BLOCK + 1) TO L-KEY
         MOVE CB-KEY-LENGTH(WS-BLOCK + 1) TO L-LENGTH
*>       The rows of the standard set have no namespace: every rule of 41 names its blocks as minecraft:<name>.
         IF L-LENGTH > 0 AND L-KEY(1:10) NOT = "minecraft:" AND L-KEY(1:11) NOT = "cobolcraft:"
             MOVE SPACES TO L-KEY
             STRING "minecraft:" FUNCTION TRIM(CB-KEY(WS-BLOCK + 1)) DELIMITED BY SIZE INTO L-KEY
             COMPUTE L-LENGTH = CB-KEY-LENGTH(WS-BLOCK + 1) + 10
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-BLOCK-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FRICTION.
*> USING dimension row, x, y, z (FLOAT-LONG), friction out (FLOAT-LONG): the block at (floor x, floor(y - 0.999999), floor z):
*> ice, packed_ice and frosted_ice 0.98, slime_block 0.8, blue_ice 0.989, every other block 0.6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FRICTION             FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FRICTION.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y - 0.999999)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     CALL "IP-BLOCK-KEY" USING L-DIM WS-CX WS-CY WS-CZ WS-KEY WS-LENGTH
     EVALUATE WS-KEY(1:WS-LENGTH)
         WHEN "minecraft:ice"
         WHEN "minecraft:packed_ice"
         WHEN "minecraft:frosted_ice"
             MOVE 0.98 TO L-FRICTION
         WHEN "minecraft:slime_block"
             MOVE 0.8 TO L-FRICTION
         WHEN "minecraft:blue_ice"
             MOVE 0.989 TO L-FRICTION
         WHEN OTHER
             MOVE 0.6 TO L-FRICTION
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-FRICTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-BOUNCINESS.
*> USING dimension row, x, y, z (FLOAT-LONG), restitution out (FLOAT-LONG): bounceRestitution of the block at (floor x, floor(y -
*> 0.2), floor z): slime_block 1.0, a bed (key ending in _bed) and shelf_mushroom 0.75, every other block 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RESTITUTION          FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RESTITUTION.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y - 0.2)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     CALL "IP-BLOCK-KEY" USING L-DIM WS-CX WS-CY WS-CZ WS-KEY WS-LENGTH
     MOVE 0 TO L-RESTITUTION
     EVALUATE TRUE
         WHEN WS-KEY(1:WS-LENGTH) = "minecraft:slime_block"
             MOVE 1 TO L-RESTITUTION
         WHEN WS-KEY(1:WS-LENGTH) = "minecraft:shelf_mushroom"
             MOVE 0.75 TO L-RESTITUTION
         WHEN WS-LENGTH > 4 AND WS-KEY(WS-LENGTH - 3:4) = "_bed"
             MOVE 0.75 TO L-RESTITUTION
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-BOUNCINESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FLUID-CELL.
*> USING dimension row, cell x, y, z (BINARY-LONG), kind out (0 none, 1 water, 2 lava), height out (FLOAT-LONG): the fluid of the
*> block in the cell (the keys minecraft:water and minecraft:lava; the property level is the state number within the block): the
*> height is 1 when the cell above holds the same fluid, else 8/9 for a source or a falling fluid (level 0 or 8 and above) and
*> (8 - level) / 9 for a flowing one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-HEIGHT.
     MOVE 0 TO L-KIND
     MOVE 0 TO L-HEIGHT
     CALL "IP-BLOCK-KEY" USING L-DIM L-X L-Y L-Z WS-KEY WS-LENGTH
     EVALUATE WS-KEY(1:WS-LENGTH)
         WHEN "minecraft:water"
             MOVE 1 TO L-KIND
         WHEN "minecraft:lava"
             MOVE 2 TO L-KIND
     END-EVALUATE
     IF L-KIND > 0
         COMPUTE WS-ABOVE = L-Y + 1
         CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-ABOVE L-Z WS-KEY WS-LENGTH
         MOVE 0 TO WS-KIND
         EVALUATE WS-KEY(1:WS-LENGTH)
             WHEN "minecraft:water"
                 MOVE 1 TO WS-KIND
             WHEN "minecraft:lava"
                 MOVE 2 TO WS-KIND
         END-EVALUATE
         COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
         COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
         CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         COMPUTE WS-LEVEL = WS-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
         EVALUATE TRUE
             WHEN WS-KIND = L-KIND
                 MOVE 1 TO L-HEIGHT
             WHEN WS-LEVEL >= 1 AND WS-LEVEL <= 7
                 COMPUTE L-HEIGHT = (8 - WS-LEVEL) / 9
             WHEN OTHER
                 COMPUTE L-HEIGHT = 8 / 9
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM IP-FLUID-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FLUID-SCAN.
*> USING tracker row: the box of the item deflated by 0.001 on every side; every cell from floor(min) to ceil(max) - 1 that holds a
*> fluid whose surface (cell y + height) is not below the deflated box bottom raises the height of its fluid to max(previous, cell
*> y + height - the undeflated box bottom). The water flag is set when the water height is above 0. The current (3.2): every counted
*> cell adds its flow (FLUID-FLOW-AT, 29a 1.4) scaled by the accumulator height while that is below 0.4 (EF-ACCUM); then each fluid's sum
*> is normalised, times 0.014 (water) or 0.0023333 (lava; 0.007 with the dimension's fast_lava), lifted to 0.0045 for a slow item (EF-CURRENT), and
*> added to the item's velocity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CELL-H              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-TRACKER             FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SUMS.
    05 WS-SUM OCCURS 2 TIMES.
       10 WS-ACC           FLOAT-LONG.
       10 WS-SX            FLOAT-LONG.
       10 WS-SY            FLOAT-LONG.
       10 WS-SZ            FLOAT-LONG.
       10 WS-SC            BINARY-LONG.
 01 WS-FAST                BINARY-LONG.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     INITIALIZE WS-SUMS
     COMPUTE WS-HALF = ET-WIDTH-MILLI(CR-LOOSE-ITEM + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-LOOSE-ITEM + 1) / 1000
     COMPUTE WS-MIN-Y = EN-Y(L-ROW) + 0.001
     MOVE 0 TO IP-I-WATER-H(L-ROW) IP-I-LAVA-H(L-ROW)
     COMPUTE WS-X0 = FUNCTION INTEGER(EN-X(L-ROW) - WS-HALF + 0.001)
     COMPUTE WS-X1 = 0 - FUNCTION INTEGER(0 - (EN-X(L-ROW) + WS-HALF - 0.001)) - 1
     COMPUTE WS-Y0 = FUNCTION INTEGER(WS-MIN-Y)
     COMPUTE WS-Y1 = 0 - FUNCTION INTEGER(0 - (EN-Y(L-ROW) + WS-HEIGHT - 0.001)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(EN-Z(L-ROW) - WS-HALF + 0.001)
     COMPUTE WS-Z1 = 0 - FUNCTION INTEGER(0 - (EN-Z(L-ROW) + WS-HALF - 0.001)) - 1
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1
                 CALL "IP-FLUID-CELL" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KIND WS-CELL-H
                 IF WS-KIND > 0
                     COMPUTE WS-TOP = WS-BY + WS-CELL-H
                     IF WS-TOP >= WS-MIN-Y
                         COMPUTE WS-TOP = WS-TOP - EN-Y(L-ROW)
                         IF WS-KIND = 1 AND WS-TOP > IP-I-WATER-H(L-ROW)
                             MOVE WS-TOP TO IP-I-WATER-H(L-ROW)
                         END-IF
                         IF WS-KIND = 2 AND WS-TOP > IP-I-LAVA-H(L-ROW)
                             MOVE WS-TOP TO IP-I-LAVA-H(L-ROW)
                         END-IF
                         MOVE IP-I-WATER-H(L-ROW) TO WS-TRACKER
                         IF WS-KIND = 2
                             MOVE IP-I-LAVA-H(L-ROW) TO WS-TRACKER
                         END-IF
                         CALL "FLUID-FLOW-AT" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-FX WS-FY WS-FZ
                         CALL "EF-ACCUM" USING WS-TRACKER WS-ACC(WS-KIND) WS-FX WS-FY WS-FZ WS-SX(WS-KIND) WS-SY(WS-KIND)
                             WS-SZ(WS-KIND) WS-SC(WS-KIND)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO IP-I-WET(L-ROW)
     IF IP-I-WATER-H(L-ROW) > 0
         MOVE 1 TO IP-I-WET(L-ROW)
     END-IF
*>   The current of each fluid (3.2); lava's strength depends on the dimension's fast_lava.
     CALL "FLUID-FAST" USING EN-DIM(L-ROW) WS-FAST
     PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 2
         CALL "EF-STRENGTH" USING WS-KIND WS-FAST WS-STRENGTH
         CALL "EF-CURRENT" USING WS-SX(WS-KIND) WS-SY(WS-KIND) WS-SZ(WS-KIND) WS-SC(WS-KIND) WS-NO-PLAYER WS-STRENGTH
             EN-VX(L-ROW) EN-VZ(L-ROW) WS-PX WS-PY WS-PZ
         ADD WS-PX TO EN-VX(L-ROW)
         ADD WS-PY TO EN-VY(L-ROW)
         ADD WS-PZ TO EN-VZ(L-ROW)
     END-PERFORM
     GOBACK.
 END PROGRAM IP-FLUID-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-PUSH-OUT.
*> USING tracker row, x, y, z (FLOAT-LONG, the point: the item's x, the middle of its box, its z), vx, vy, vz (FLOAT-LONG, in and
*> out): 41 section 3.4. The candidates north, south, west, east, up in this order, a neighbour cell that is solid is skipped, the
*> nearest face wins (an earlier candidate wins a tie, up when all are skipped); then s = nextFloat * 0.2 + 0.1 from the item's
*> source, the velocity * 0.75 and the component of the axis replaced by +-s.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG VALUE 1000000.
 01 WS-DIST                FLOAT-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-DIM-ROW             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-VX L-VY L-VZ.
     CALL "IP-DIMENSION-OF" USING L-ROW WS-DIM-ROW
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     COMPUTE WS-OX = L-X - WS-CX
     COMPUTE WS-OY = L-Y - WS-CY
     COMPUTE WS-OZ = L-Z - WS-CZ
     MOVE 1000000 TO WS-BEST
     MOVE 5 TO WS-DIR
     PERFORM VARYING WS-CAND FROM 1 BY 1 UNTIL WS-CAND > 5
         MOVE WS-CX TO WS-NX
         MOVE WS-CY TO WS-NY
         MOVE WS-CZ TO WS-NZ
         EVALUATE WS-CAND
             WHEN 1
                 SUBTRACT 1 FROM WS-NZ
                 MOVE WS-OZ TO WS-DIST
             WHEN 2
                 ADD 1 TO WS-NZ
                 COMPUTE WS-DIST = 1 - WS-OZ
             WHEN 3
                 SUBTRACT 1 FROM WS-NX
                 MOVE WS-OX TO WS-DIST
             WHEN 4
                 ADD 1 TO WS-NX
                 COMPUTE WS-DIST = 1 - WS-OX
             WHEN 5
                 ADD 1 TO WS-NY
                 COMPUTE WS-DIST = 1 - WS-OY
         END-EVALUATE
         CALL "GI-SOLID-CELL" USING WS-DIM-ROW WS-NX WS-NY WS-NZ WS-SOLID
         IF WS-SOLID = 0 AND WS-DIST < WS-BEST
             MOVE WS-DIST TO WS-BEST
             MOVE WS-CAND TO WS-DIR
         END-IF
     END-PERFORM
     CALL "IP-RNG-FLOAT" USING IP-I-RNG(L-ROW) WS-S
     COMPUTE WS-S = WS-S * 0.2 + 0.1
     COMPUTE L-VX = L-VX * 0.75
     COMPUTE L-VY = L-VY * 0.75
     COMPUTE L-VZ = L-VZ * 0.75
     EVALUATE WS-DIR
         WHEN 1
             COMPUTE L-VZ = 0 - WS-S
         WHEN 2
             MOVE WS-S TO L-VZ
         WHEN 3
             COMPUTE L-VX = 0 - WS-S
         WHEN 4
             MOVE WS-S TO L-VX
         WHEN 5
             MOVE WS-S TO L-VY
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-PUSH-OUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-DIMENSION-OF.
*> USING tracker row, dimension row out: the dimension the entity is in.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM.
     MOVE EN-DIM(L-ROW) TO L-DIM
     GOBACK.
 END PROGRAM IP-DIMENSION-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-AXIS-MOVE.
*> USING dimension row, x, y, z (FLOAT-LONG, in and out), axis (1 x, 2 y, 3 z), delta (FLOAT-LONG), hit out (BINARY-LONG 1 or 0):
*> moves the item box along one axis in steps of at most 0.5 block; a step into solid cells (ENTITY-BOX-HITS) ends the move flush
*> against the cells: the box face touches the cell face.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-DELTA                FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS L-DELTA L-HIT.
     MOVE CR-LOOSE-ITEM TO WS-TYPE
     COMPUTE WS-HALF = ET-WIDTH-MILLI(WS-TYPE + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(WS-TYPE + 1) / 1000
     MOVE 0 TO L-HIT
     COMPUTE WS-STEPS = 1 - FUNCTION INTEGER(0 - FUNCTION ABS(L-DELTA) / 0.5)
     COMPUTE WS-STEP = L-DELTA / WS-STEPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-STEPS OR L-HIT = 1
         MOVE L-X TO WS-NX
         MOVE L-Y TO WS-NY
         MOVE L-Z TO WS-NZ
         EVALUATE L-AXIS
             WHEN 1
                 ADD WS-STEP TO WS-NX
             WHEN 2
                 ADD WS-STEP TO WS-NY
             WHEN 3
                 ADD WS-STEP TO WS-NZ
         END-EVALUATE
         CALL "ENTITY-BOX-HITS" USING L-DIM WS-TYPE WS-NX WS-NY WS-NZ WS-HIT WS-TOP
         IF WS-HIT = 0
             MOVE WS-NX TO L-X
             MOVE WS-NY TO L-Y
             MOVE WS-NZ TO L-Z
         ELSE
             MOVE 1 TO L-HIT
             EVALUATE TRUE
                 WHEN L-AXIS = 1 AND WS-STEP > 0
                     COMPUTE WS-CELL = - FUNCTION INTEGER(0.0000001 - (WS-NX + WS-HALF)) - 1
                     COMPUTE L-X = WS-CELL - WS-HALF
                 WHEN L-AXIS = 1
                     COMPUTE WS-CELL = FUNCTION INTEGER(WS-NX - WS-HALF + 0.0000001)
                     COMPUTE L-X = WS-CELL + 1 + WS-HALF
                 WHEN L-AXIS = 2 AND WS-STEP > 0
                     COMPUTE WS-CELL = - FUNCTION INTEGER(0.0000001 - (WS-NY + WS-HEIGHT)) - 1
                     COMPUTE L-Y = WS-CELL - WS-HEIGHT
                 WHEN L-AXIS = 2
                     COMPUTE L-Y = WS-TOP + 1
                 WHEN L-AXIS = 3 AND WS-STEP > 0
                     COMPUTE WS-CELL = - FUNCTION INTEGER(0.0000001 - (WS-NZ + WS-HALF)) - 1
                     COMPUTE L-Z = WS-CELL - WS-HALF
                 WHEN OTHER
                     COMPUTE WS-CELL = FUNCTION INTEGER(WS-NZ - WS-HALF + 0.0000001)
                     COMPUTE L-Z = WS-CELL + 1 + WS-HALF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM IP-AXIS-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-ITEM-MOVE.
*> USING tracker row, changed out (BINARY-LONG 1 or 0), new x, y, z out (FLOAT-LONG): steps 4 to 8 of 41 section 3. EN-X to EN-Z keep
*> the values last sent (the caller sends Teleport Entity when the new position differs); the motion and the on-ground flag are
*> updated here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-MID                 FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-NO-PHYSICS          BINARY-LONG.
 01 WS-AXIS-X              BINARY-LONG VALUE 1.
 01 WS-AXIS-Y              BINARY-LONG VALUE 2.
 01 WS-AXIS-Z              BINARY-LONG VALUE 3.
 01 WS-GROUND              BINARY-LONG.
 01 WS-HIT-X               BINARY-LONG.
 01 WS-HIT-Y               BINARY-LONG.
 01 WS-HIT-Z               BINARY-LONG.
 01 WS-FRICTION            FLOAT-LONG.
 01 WS-DRAG                FLOAT-LONG VALUE 0.98.
 01 WS-RESTITUTION         FLOAT-LONG.
 01 WS-NEW-VY              FLOAT-LONG.
 01 WS-MOVED-Y             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-NX                   FLOAT-LONG.
 01 L-NY                   FLOAT-LONG.
 01 L-NZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHANGED L-NX L-NY L-NZ.
     MOVE EN-X(L-ROW) TO WS-X WS-OX
     MOVE EN-Y(L-ROW) TO WS-Y WS-OY
     MOVE EN-Z(L-ROW) TO WS-Z WS-OZ
     MOVE EN-VX(L-ROW) TO WS-VX
     MOVE EN-VY(L-ROW) TO WS-VY
     MOVE EN-VZ(L-ROW) TO WS-VZ
     MOVE EN-ON-GROUND(L-ROW) TO WS-GROUND
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-LOOSE-ITEM + 1) / 1000
*>   5. The movement force: water, lava, else gravity.
     EVALUATE TRUE
         WHEN IP-I-WET(L-ROW) = 1 AND IP-I-WATER-H(L-ROW) > 0.1
             COMPUTE WS-VX = WS-VX * 0.99
             COMPUTE WS-VZ = WS-VZ * 0.99
             IF WS-VY < 0.06
                 ADD 0.0005 TO WS-VY
             END-IF
         WHEN IP-I-LAVA-H(L-ROW) > 0.1 AND IP-I-TICKS(L-ROW) > 1
             COMPUTE WS-VX = WS-VX * 0.95
             COMPUTE WS-VZ = WS-VZ * 0.95
             IF WS-VY < 0.06
                 ADD 0.0005 TO WS-VY
             END-IF
         WHEN OTHER
             SUBTRACT 0.04 FROM WS-VY
     END-EVALUATE
*>   6. Inside blocks: the push out of 3.4 and no collisions for the move.
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) CR-LOOSE-ITEM WS-X WS-Y WS-Z WS-HIT WS-TOP
     MOVE WS-HIT TO WS-NO-PHYSICS
     IF WS-NO-PHYSICS = 1
         COMPUTE WS-MID = WS-Y + WS-HEIGHT / 2
         CALL "IP-PUSH-OUT" USING L-ROW WS-X WS-MID WS-Z WS-VX WS-VY WS-VZ
     END-IF
*>   7. The move: not on the ground, or moving, or on the cadence tick.
     IF WS-GROUND = 0 OR WS-VX * WS-VX + WS-VZ * WS-VZ > 0.00001
             OR FUNCTION MOD(IP-I-TICKS(L-ROW) + EN-ID(L-ROW), 4) = 0
         MOVE 0 TO WS-HIT-X WS-HIT-Y WS-HIT-Z
         IF WS-NO-PHYSICS = 1
             ADD WS-VX TO WS-X
             ADD WS-VY TO WS-Y
             ADD WS-VZ TO WS-Z
             MOVE 0 TO WS-GROUND
         ELSE
             MOVE WS-Y TO WS-MOVED-Y
             CALL "IP-AXIS-MOVE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AXIS-Y WS-VY WS-HIT-Y
             COMPUTE WS-MOVED-Y = WS-Y - WS-MOVED-Y
             CALL "IP-AXIS-MOVE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AXIS-X WS-VX WS-HIT-X
             CALL "IP-AXIS-MOVE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AXIS-Z WS-VZ WS-HIT-Z
             MOVE 0 TO WS-GROUND
             IF WS-HIT-Y = 1 AND WS-VY < 0
                 MOVE 1 TO WS-GROUND
             END-IF
*>           3.3 Restitution: a wall removes that horizontal component; a landing gives the block's rebound, a head hit zero.
             IF WS-HIT-X = 1
                 MOVE 0 TO WS-VX
             END-IF
             IF WS-HIT-Z = 1
                 MOVE 0 TO WS-VZ
             END-IF
             IF WS-HIT-Y = 1
                 MOVE 0 TO WS-NEW-VY
                 IF WS-GROUND = 1
                     CALL "IP-BOUNCINESS" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-RESTITUTION
                     CALL "IP-RESTITUTE" USING WS-VY WS-MOVED-Y WS-RESTITUTION WS-NEW-VY
                 END-IF
                 MOVE WS-NEW-VY TO WS-VY
             END-IF
         END-IF
*>       The friction step: 0.98, on the ground 0.98 * the block's friction (x and z only).
         MOVE WS-DRAG TO WS-FRICTION
         IF WS-GROUND = 1
             CALL "IP-FRICTION" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-FRICTION
             COMPUTE WS-FRICTION = WS-DRAG * WS-FRICTION
         END-IF
         COMPUTE WS-VX = WS-VX * WS-FRICTION
         COMPUTE WS-VY = WS-VY * WS-DRAG
         COMPUTE WS-VZ = WS-VZ * WS-FRICTION
*>       (The -0.5 rebound rule for an item on the ground with vy below 0 after this step cannot fire here: a landing sets vy by the
*>       restitution of 3.3, which is never below 0.)
     END-IF
     MOVE WS-VX TO EN-VX(L-ROW)
     MOVE WS-VY TO EN-VY(L-ROW)
     MOVE WS-VZ TO EN-VZ(L-ROW)
     MOVE WS-GROUND TO EN-ON-GROUND(L-ROW)
*>   8. Did the item change block cell?
     MOVE 0 TO L-CHANGED
     IF FUNCTION INTEGER(WS-OX) NOT = FUNCTION INTEGER(WS-X) OR FUNCTION INTEGER(WS-OY) NOT = FUNCTION INTEGER(WS-Y)
             OR FUNCTION INTEGER(WS-OZ) NOT = FUNCTION INTEGER(WS-Z)
         MOVE 1 TO L-CHANGED
     END-IF
     MOVE WS-X TO L-NX
     MOVE WS-Y TO L-NY
     MOVE WS-Z TO L-NZ
     GOBACK.
 END PROGRAM IP-ITEM-MOVE.

*> Section 5, damage, fire and explosions; section 4.4, merging:
*>   IP-RESISTANT USING item, damage type (IP-DT-*), result: 1 when the item's damage_resistant covers the type (the 16 netherite
*>     family items cover is_fire; the nether star is_explosion)
*>   IP-FIRE-IMMUNE USING tracker row, result      the item is not hurt by in_fire damage
*>   IP-HURT USING tracker row, damage type, amount (FLOAT-LONG), source (IP-SRC-*), result (1 accepted, 0 ignored)   hurtServer
*>   IP-IGNITE USING tracker row, seconds          igniteForSeconds unless fire immune
*>   IP-EXPLODE USING tracker row, interaction (0 keep, 1 trigger block, 2 destroy, 3 destroy with decay), amount, result
*>   IP-FIRE-TICK USING tracker row, alive out     the fire rules of the base entity tick (step 2)
*>   IP-LAVA-EFFECTS USING tracker row, alive out  LAVA_IGNITE and the lava hurt (step 11)
*>   IP-MERGEABLE USING tracker row, result; IP-MERGE USING tracker row   isMergable and mergeWithNeighbours (4.4)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RESISTANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:ancient_debris".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_block".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_ingot".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_scrap".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_sword".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_shovel".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_pickaxe".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_axe".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_hoe".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_spear".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_helmet".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_chestplate".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_leggings".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_boots".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_horse_armor".
    05 FILLER              PIC X(40) VALUE "minecraft:netherite_nautilus_armor".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-FIRE-ITEM        PIC X(40) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FULL                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-TYPE L-RESULT.
     MOVE 0 TO L-RESULT
*>   The standard set keeps its item keys without the namespace ("netherite_ingot").
     CALL "KEY-NAMESPACED" USING IT-KEY(L-ITEM + 1) WS-FULL
     IF L-TYPE >= 1 AND L-TYPE <= 8
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             IF FUNCTION TRIM(WS-FULL) = FUNCTION TRIM(WS-FIRE-ITEM(WS-I))
                 MOVE 1 TO L-RESULT
             END-IF
         END-PERFORM
     END-IF
     IF L-TYPE >= 9 AND L-TYPE <= 12
         IF WS-FULL = "minecraft:nether_star"
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-RESISTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FIRE-IMMUNE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-IN-FIRE             BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     CALL "IP-RESISTANT" USING EN-ITEM(L-ROW) WS-IN-FIRE L-RESULT
     GOBACK.
 END PROGRAM IP-FIRE-IMMUNE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-HURT.
*> The checks of hurtServer in order: an invulnerable item (invulnerableTime above 0) ignores every type but out_of_world and
*> generic_kill and the hits of a creative player; a fire immune item ignores is_fire; a mob's hit is ignored when mob_griefing is
*> false; a stack whose damage_resistant covers the type ignores it. Otherwise health = (int)(health - amount) and at 0 or below
*> the entity is discarded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMPHYS.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-RESISTANT           BINARY-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-AMOUNT               FLOAT-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TYPE L-AMOUNT L-SOURCE L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "IP-FIRE-IMMUNE" USING L-ROW WS-IMMUNE
     CALL "IP-RESISTANT" USING EN-ITEM(L-ROW) L-TYPE WS-RESISTANT
     EVALUATE TRUE
         WHEN IP-I-INVULN(L-ROW) > 0 AND L-TYPE < IP-DT-OUT-OF-WORLD AND L-SOURCE NOT = IP-SRC-CREATIVE
             CONTINUE
         WHEN WS-IMMUNE = 1 AND L-TYPE >= IP-DT-IN-FIRE AND L-TYPE <= IP-DT-FIREBALL
             CONTINUE
         WHEN IP-NO-MOB-GRIEFING = 1 AND L-SOURCE = IP-SRC-MOB
             CONTINUE
         WHEN WS-RESISTANT = 1
             CONTINUE
         WHEN OTHER
             MOVE 1 TO L-RESULT
             COMPUTE WS-HEALTH = IP-I-HEALTH(L-ROW) - L-AMOUNT
             COMPUTE IP-I-HEALTH(L-ROW) = FUNCTION INTEGER-PART(WS-HEALTH)
             IF IP-I-HEALTH(L-ROW) <= 0
                 CALL "ENTITY-REMOVE" USING L-ROW
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-IGNITE.
*> USING tracker row, seconds: remainingFireTicks = max(it, seconds * 20) unless the item is fire immune.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-IMMUNE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SECONDS.
     CALL "IP-FIRE-IMMUNE" USING L-ROW WS-IMMUNE
     IF WS-IMMUNE = 0
         COMPUTE IP-I-FIRE(L-ROW) = FUNCTION MAX(IP-I-FIRE(L-ROW), L-SECONDS * 20)
     END-IF
     GOBACK.
 END PROGRAM IP-IGNITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-EXPLODE.
*> USING tracker row, interaction (0 keep, 1 trigger block, 2 destroy, 3 destroy with decay), amount (FLOAT-LONG), result: an item
*> ignores an explosion that does not affect blocklike entities (keep, trigger block); otherwise IP-HURT with the explosion type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-INTERACTION          BINARY-LONG.
 01 L-AMOUNT               FLOAT-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-INTERACTION L-AMOUNT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-INTERACTION >= 2
         CALL "IP-HURT" USING L-ROW IP-DT-EXPLOSION L-AMOUNT IP-SRC-OTHER L-RESULT
     END-IF
     GOBACK.
 END PROGRAM IP-EXPLODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FIRE-TICK.
*> USING tracker row, alive out: while remainingFireTicks is above 0: a fire immune item puts the fire out; any other takes 1.0
*> on_fire damage on every tick whose count is a multiple of 20 and that is not in lava; then the count falls by 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ALIVE.
     MOVE 1 TO L-ALIVE
     IF IP-I-FIRE(L-ROW) > 0
         CALL "IP-FIRE-IMMUNE" USING L-ROW WS-IMMUNE
         IF WS-IMMUNE = 1
             MOVE 0 TO IP-I-FIRE(L-ROW)
         ELSE
             IF FUNCTION MOD(IP-I-FIRE(L-ROW), 20) = 0 AND IP-I-LAVA-H(L-ROW) = 0
                 CALL "IP-HURT" USING L-ROW IP-DT-ON-FIRE WS-ONE IP-SRC-OTHER WS-HIT
                 IF IP-I-HEALTH(L-ROW) <= 0
                     MOVE 0 TO L-ALIVE
                 END-IF
             END-IF
             SUBTRACT 1 FROM IP-I-FIRE(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-FIRE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-LAVA-EFFECTS.
*> USING tracker row, alive out: an item that overlaps lava (the lava height of the last scan above 0) is set alight for 15 seconds
*> unless fire immune and takes 4.0 lava damage (also not when fire immune).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMPHYS.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG VALUE 15.
 01 WS-DAMAGE              FLOAT-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ALIVE.
     MOVE 1 TO L-ALIVE
     IF IP-I-LAVA-H(L-ROW) > 0
         CALL "IP-IGNITE" USING L-ROW WS-SECONDS
         CALL "IP-FIRE-IMMUNE" USING L-ROW WS-IMMUNE
         IF WS-IMMUNE = 0
             CALL "IP-HURT" USING L-ROW IP-DT-LAVA WS-DAMAGE IP-SRC-OTHER WS-HIT
             IF IP-I-HEALTH(L-ROW) <= 0
                 MOVE 0 TO L-ALIVE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-LAVA-EFFECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-MERGEABLE.
*> USING tracker row, result: the item is alive, its pickup delay is not 32767, its age is neither -32768 nor 6000 or more, and its
*> stack is below the item's maximum.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RESULT.
     MOVE 0 TO L-RESULT
     IF EN-DELAY(L-ROW) NOT = IP-NEVER-PICKUP AND EN-AGE(L-ROW) NOT = IP-INFINITE-LIFETIME
             AND EN-AGE(L-ROW) < IP-LIFETIME AND EN-ITEM-COUNT(L-ROW) < IT-MAX-STACK(EN-ITEM(L-ROW) + 1)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM IP-MERGEABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-MERGE.
*> USING tracker row: mergeWithNeighbours: every other mergeable item entity of the dimension whose box meets this one's box
*> inflated by (0.5, 0, 0.5) (strict comparisons), in tracker row order; tryToMerge needs equal owners, the same item and patch
*> handle and a total within the item's maximum; the entity with the larger count (this one on a tie goes to the other) receives:
*> moved = min(min(maximum, 64) - receiver count, donor count), the delay becomes the larger and the age the smaller of the two,
*> an emptied donor is removed, the receiver's viewers get Set Entity Data. The loop ends when this entity is gone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 01 WS-OTHER               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-REACH = ET-WIDTH-MILLI(CR-LOOSE-ITEM + 1) / 1000 + 0.5
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-LOOSE-ITEM + 1) / 1000
     MOVE EN-ID(L-ROW) TO WS-ID
     PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > EN-COUNT OR EN-USED(L-ROW) = 0 OR EN-ID(L-ROW) NOT = WS-ID
         IF WS-OTHER NOT = L-ROW AND EN-USED(WS-OTHER) = 1 AND EN-TYPE(WS-OTHER) = CR-LOOSE-ITEM
                 AND EN-DIM(WS-OTHER) = EN-DIM(L-ROW)
             CALL "IP-MERGEABLE" USING WS-OTHER WS-OK
             IF WS-OK = 1 AND FUNCTION ABS(EN-X(WS-OTHER) - EN-X(L-ROW)) < WS-REACH
                     AND FUNCTION ABS(EN-Z(WS-OTHER) - EN-Z(L-ROW)) < WS-REACH
                     AND FUNCTION ABS(EN-Y(WS-OTHER) - EN-Y(L-ROW)) < WS-HEIGHT
                 CALL "IP-TRY-MERGE" USING L-ROW WS-OTHER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM IP-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-TRY-MERGE.
*> USING tracker row (this), tracker row (other): ItemEntity.tryToMerge (41 section 4.4): equal owners, the same item and patch
*> handle and a total within the item's maximum; the entity with the larger count (this one on a tie goes to the other) receives.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-RECEIVER            BINARY-LONG.
 01 WS-DONOR               BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OTHER.
     CALL "IP-ENSURE" USING L-OTHER
     MOVE IT-MAX-STACK(EN-ITEM(L-OTHER) + 1) TO WS-MAX
     IF IP-I-HAS-OWNER(L-ROW) = IP-I-HAS-OWNER(L-OTHER) AND IP-I-OWNER(L-ROW) = IP-I-OWNER(L-OTHER)
             AND EN-ITEM(L-ROW) = EN-ITEM(L-OTHER) AND IP-I-VAR(L-ROW) = IP-I-VAR(L-OTHER)
             AND EN-ITEM-COUNT(L-ROW) + EN-ITEM-COUNT(L-OTHER) <= WS-MAX
         IF EN-ITEM-COUNT(L-OTHER) < EN-ITEM-COUNT(L-ROW)
             MOVE L-ROW TO WS-RECEIVER
             MOVE L-OTHER TO WS-DONOR
         ELSE
             MOVE L-OTHER TO WS-RECEIVER
             MOVE L-ROW TO WS-DONOR
         END-IF
         COMPUTE WS-MOVED = FUNCTION MIN(FUNCTION MIN(WS-MAX, 64) - EN-ITEM-COUNT(WS-RECEIVER), EN-ITEM-COUNT(WS-DONOR))
         ADD WS-MOVED TO EN-ITEM-COUNT(WS-RECEIVER)
         SUBTRACT WS-MOVED FROM EN-ITEM-COUNT(WS-DONOR)
         COMPUTE EN-DELAY(WS-RECEIVER) = FUNCTION MAX(EN-DELAY(WS-RECEIVER), EN-DELAY(WS-DONOR))
         COMPUTE EN-AGE(WS-RECEIVER) = FUNCTION MIN(EN-AGE(WS-RECEIVER), EN-AGE(WS-DONOR))
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "SET-ENTITY-DATA-ITEM-BUILD" USING EN-ID(WS-RECEIVER) EN-ITEM(WS-RECEIVER) EN-ITEM-COUNT(WS-RECEIVER)
             PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-RECEIVER PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         IF EN-ITEM-COUNT(WS-DONOR) = 0
             CALL "ENTITY-REMOVE" USING WS-DONOR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-TRY-MERGE.

*> Section 4.3, Inventory.add:
*>   IP-INV-ADD USING player row, item, count (in and out: what is left), patch handle, result (1 = add returned true, 0 = false)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-INV-ADD.
*> Inventory.add(stack): an empty stack returns false. A damaged stack (damage above 0) never stacks: it takes the first free slot,
*> else a creative player consumes it (true), else false. Otherwise addResource repeats while the stack is non-empty and its count
*> fell: the selected slot when it has room (same item, same patch, below the maximum min(99, item maximum)), else the first slot
*> by index with room, else the first free slot; a stalled iteration ends the loop. A creative player consumes what is left and
*> gets true; otherwise the result is true only when the last iteration moved something and emptied the stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-COUNT0              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-COUNT <= 0
         GOBACK
     END-IF
     MOVE 0 TO WS-DAMAGE
     IF L-VAR > 0
         CALL "SP-GET-DAMAGE" USING L-ITEM L-VAR WS-DAMAGE
     END-IF
     MOVE FUNCTION MIN(99, IT-MAX-STACK(L-ITEM + 1)) TO WS-MAX
     IF WS-DAMAGE > 0
         CALL "IP-FIND-FREE" USING L-PLAYER WS-FREE
         EVALUATE TRUE
             WHEN WS-FREE > 0
                 MOVE L-ITEM TO PL-SLOT-ITEM(L-PLAYER, WS-FREE)
                 MOVE L-COUNT TO PL-SLOT-COUNT(L-PLAYER, WS-FREE)
                 MOVE L-VAR TO PL-SLOT-VAR(L-PLAYER, WS-FREE)
                 MOVE 0 TO L-COUNT
                 MOVE 1 TO L-RESULT
             WHEN PL-MODE(L-PLAYER) = 1
                 MOVE 0 TO L-COUNT
                 MOVE 1 TO L-RESULT
         END-EVALUATE
         GOBACK
     END-IF
     PERFORM UNTIL L-COUNT = 0
         MOVE L-COUNT TO WS-COUNT0
         CALL "IP-ADD-RESOURCE" USING L-PLAYER L-ITEM L-COUNT L-VAR WS-MAX
         IF L-COUNT = WS-COUNT0
             EXIT PERFORM
         END-IF
     END-PERFORM
     IF L-COUNT > 0 AND PL-MODE(L-PLAYER) = 1
         MOVE 0 TO L-COUNT
         MOVE 1 TO L-RESULT
     ELSE
         IF L-COUNT < WS-COUNT0
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM IP-INV-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-FIND-FREE.
*> USING player row, slot out: the lowest empty slot of the 36 main slots (1 to 36), 0 when none (Inventory.getFreeSlot).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-FREE.
     MOVE 0 TO L-FREE
     PERFORM VARYING WS-S FROM 36 BY -1 UNTIL WS-S < 1
         IF PL-SLOT-COUNT(L-PLAYER, WS-S) = 0
             MOVE WS-S TO L-FREE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM IP-FIND-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-ADD-RESOURCE.
*> USING player row, item, count (in and out), patch handle, maximum stack: Inventory.addResource: the selected slot, else the first
*> slot with room, else the first free slot take what they can of the count.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ITEM L-COUNT L-VAR L-MAX.
     COMPUTE WS-SLOT = PL-HELD(L-PLAYER) + 1
     IF NOT (PL-SLOT-COUNT(L-PLAYER, WS-SLOT) > 0 AND PL-SLOT-ITEM(L-PLAYER, WS-SLOT) = L-ITEM
             AND PL-SLOT-VAR(L-PLAYER, WS-SLOT) = L-VAR AND PL-SLOT-COUNT(L-PLAYER, WS-SLOT) < L-MAX)
         MOVE 0 TO WS-SLOT
         PERFORM VARYING WS-S FROM 36 BY -1 UNTIL WS-S < 1
             IF PL-SLOT-COUNT(L-PLAYER, WS-S) > 0 AND PL-SLOT-ITEM(L-PLAYER, WS-S) = L-ITEM
                     AND PL-SLOT-VAR(L-PLAYER, WS-S) = L-VAR AND PL-SLOT-COUNT(L-PLAYER, WS-S) < L-MAX
                 MOVE WS-S TO WS-SLOT
             END-IF
         END-PERFORM
     END-IF
     IF WS-SLOT = 0
         CALL "IP-FIND-FREE" USING L-PLAYER WS-SLOT
         IF WS-SLOT > 0
             MOVE L-ITEM TO PL-SLOT-ITEM(L-PLAYER, WS-SLOT)
             MOVE L-VAR TO PL-SLOT-VAR(L-PLAYER, WS-SLOT)
             MOVE 0 TO PL-SLOT-COUNT(L-PLAYER, WS-SLOT)
         END-IF
     END-IF
     IF WS-SLOT > 0
         COMPUTE WS-MOVED = FUNCTION MIN(L-COUNT, L-MAX - PL-SLOT-COUNT(L-PLAYER, WS-SLOT))
         ADD WS-MOVED TO PL-SLOT-COUNT(L-PLAYER, WS-SLOT)
         SUBTRACT WS-MOVED FROM L-COUNT
     END-IF
     GOBACK.
 END PROGRAM IP-ADD-RESOURCE.

*> Section 7, the facts the client's renderer needs:
*>   IP-RENDER-AMOUNT USING count, copies out         1 up to 1 item, 2 up to 16, 3 up to 32, 4 up to 48, else 5
*>   IP-BOB-Y USING age (FLOAT-LONG: tickCount + partial tick), bobOffs, model min y, height out
*>   IP-SPIN USING age, bobOffs, radians out; IP-VISUAL-YAW USING age (BINARY-LONG), bobOffs, degrees out
*>   IP-RENDER-OFFSETS USING item, damage, depth (FLOAT-LONG), copies, offsets out (5 times x, y, z FLOAT-LONG)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RENDER-AMOUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-AMOUNT.
     EVALUATE TRUE
         WHEN L-COUNT <= 1
             MOVE 1 TO L-AMOUNT
         WHEN L-COUNT <= 16
             MOVE 2 TO L-AMOUNT
         WHEN L-COUNT <= 32
             MOVE 3 TO L-AMOUNT
         WHEN L-COUNT <= 48
             MOVE 4 TO L-AMOUNT
         WHEN OTHER
             MOVE 5 TO L-AMOUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM IP-RENDER-AMOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-BOB-Y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-AGE                  FLOAT-LONG.
 01 L-BOB                  FLOAT-LONG.
 01 L-MIN-Y                FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-BOB L-MIN-Y L-Y.
     COMPUTE WS-ANGLE = L-AGE / 10 + L-BOB
     CALL "IP-MTH-SIN" USING WS-ANGLE WS-SIN
     COMPUTE L-Y = WS-SIN * 0.1 + 0.1 + (0 - L-MIN-Y + 0.0625)
     GOBACK.
 END PROGRAM IP-BOB-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-SPIN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  FLOAT-LONG.
 01 L-BOB                  FLOAT-LONG.
 01 L-RADIANS              FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-BOB L-RADIANS.
     COMPUTE L-RADIANS = L-AGE / 20 + L-BOB
     GOBACK.
 END PROGRAM IP-SPIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-VISUAL-YAW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-BOB                  FLOAT-LONG.
 01 L-DEGREES              FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-BOB L-DEGREES.
     COMPUTE L-DEGREES = 180 - ((L-AGE + 0.5) / 20 + L-BOB) / (2 * FUNCTION PI) * 360
     GOBACK.
 END PROGRAM IP-VISUAL-YAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IP-RENDER-OFFSETS.
*> USING item, damage (BINARY-LONG), depth (FLOAT-LONG, the Z size of the model box), copies, offsets out: the random source is
*> seeded with item + damage (187 for an empty stack, item 0). A model thicker than 0.0625 draws the first copy unmoved and every
*> other one offset by (nextFloat * 2 - 1) * 0.15 on x, y and z; a flat one spaces the copies 1.5 * depth along z, centred on the
*> group, and offsets the others on x and y by (nextFloat * 2 - 1) * 0.15 * 0.5 (x drawn first).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-SPACING             FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-DEPTH                FLOAT-LONG.
 01 L-COPIES               BINARY-LONG.
 01 L-OFFSETS.
    05 L-COPY OCCURS 5 TIMES.
       10 L-X              FLOAT-LONG.
       10 L-Y              FLOAT-LONG.
       10 L-Z              FLOAT-LONG.
 PROCEDURE DIVISION USING L-ITEM L-DAMAGE L-DEPTH L-COPIES L-OFFSETS.
     INITIALIZE L-OFFSETS
     IF L-ITEM = 0
         MOVE 187 TO WS-SEED
     ELSE
         COMPUTE WS-SEED = L-ITEM + L-DAMAGE
     END-IF
     CALL "IP-RNG-SEED" USING WS-STATE WS-SEED
     IF L-DEPTH > 0.0625
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COPIES
             CALL "IP-RNG-FLOAT" USING WS-STATE WS-R
             COMPUTE L-X(WS-I) = (WS-R * 2 - 1) * 0.15
             CALL "IP-RNG-FLOAT" USING WS-STATE WS-R
             COMPUTE L-Y(WS-I) = (WS-R * 2 - 1) * 0.15
             CALL "IP-RNG-FLOAT" USING WS-STATE WS-R
             COMPUTE L-Z(WS-I) = (WS-R * 2 - 1) * 0.15
         END-PERFORM
     ELSE
         COMPUTE WS-SPACING = L-DEPTH * 1.5
         COMPUTE WS-Z = 0 - WS-SPACING * (L-COPIES - 1) / 2
         MOVE WS-Z TO L-Z(1)
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COPIES
             ADD WS-SPACING TO WS-Z
             MOVE WS-Z TO L-Z(WS-I)
             CALL "IP-RNG-FLOAT" USING WS-STATE WS-R
             COMPUTE L-X(WS-I) = (WS-R * 2 - 1) * 0.15 * 0.5
             CALL "IP-RNG-FLOAT" USING WS-STATE WS-R
             COMPUTE L-Y(WS-I) = (WS-R * 2 - 1) * 0.15 * 0.5
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM IP-RENDER-OFFSETS.
