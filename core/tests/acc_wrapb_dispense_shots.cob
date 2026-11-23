*> Acceptance test (wrap agent B round 6, T29574; docs/protocol/30-redstone-4 section 4.1, 44 part x2 continuation): a dispenser shoots the fire charge, the wind charge, the firework rocket and the splash and
*> lingering potions. Fire charge and wind charge leave from the centre of the front cell (centre + 1.0 along the facing) with power 1.0 and uncertainty 6.6666665 (the noise is 0.11485 per axis around the unit
*> direction), the firework rocket from centre + 0.5000099999997474 along the facing with power 0.5 and uncertainty 1.0 (shot at an angle), the potions from centre + 0.7 along the facing and 0.1 above it with
*> power 1.375 and uncertainty 3.0, carrying the contents of the slot. The dispense sound events are 1018, 1051, 1004 and the default launch 1002. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-SHOTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROJSTATE.
 COPY PROTO.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-shots-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-BE                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OBS-N               BINARY-DOUBLE SIGNED.
 01 WS-EXP-N               BINARY-DOUBLE SIGNED.
 01 WS-BARE                PIC X(48).
 01 WS-ENT-KEY             PIC X(48).
 01 WS-ECOUNT              BINARY-LONG.
 01 WS-EROW                BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-VAR                 BINARY-LONG VALUE 0.
 01 WS-FACING              BINARY-LONG VALUE 5.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(48).
 01 WS-TEXT                PIC X(1024).
 01 WS-PACKET-47           BINARY-LONG VALUE 47.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-EVX                 BINARY-LONG.
 01 WS-EVY                 BINARY-LONG.
 01 WS-EVZ                 BINARY-LONG.
 01 WS-EVDATA              BINARY-LONG.
 01 WS-EVGLOBAL            BINARY-LONG.
 01 WS-A-ED                PIC -(9)9.
 01 WS-B-ED                PIC -(9)9.
 01 WS-C-ED                PIC -(9)9.
 01 WS-GX-ED               PIC -(11)9.
 01 WS-GY-ED               PIC -(11)9.
 01 WS-GZ-ED               PIC -(11)9.
 01 WS-LIVE-KEY            PIC X(48).
 01 WS-SLOT                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-POTION              BINARY-LONG VALUE 19.
 01 WS-SCALE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FXS.
    05 WS-FX-E OCCURS 8 TIMES.
       10 WS-FX-ID         BINARY-LONG.
       10 WS-FX-AMP        BINARY-LONG.
       10 WS-FX-DUR        BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MAIN-TOL            FLOAT-LONG.
 01 WS-SIDE-TOL            FLOAT-LONG.
 01 WS-MAIN                FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-EX                  BINARY-DOUBLE SIGNED.
 01 WS-EY                  BINARY-DOUBLE SIGNED.
 01 WS-EZ                  BINARY-DOUBLE SIGNED.
 01 WS-GX                  BINARY-DOUBLE SIGNED.
 01 WS-GY                  BINARY-DOUBLE SIGNED.
 01 WS-GZ                  BINARY-DOUBLE SIGNED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense shots: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS

*>   A. the fire charge at the front cell (4, 101, 20) facing east: a small fireball at the centre of the front cell, shot east at about 1.0 within 0.11485 of noise, spent with event 1018 (consumed 4)
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 20 TO WS-FZ MOVE 5 TO WS-FACING
     MOVE "fire_charge" TO WS-K MOVE "small_fireball" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE 4 TO WS-CODE
     MOVE 450000 TO WS-EX MOVE 10150000 TO WS-EY MOVE 2050000 TO WS-EZ
     MOVE "acceptance wrapb dispense 30-4 4.1 a fire charge is a small fireball at the centre of the front cell, handled, consumed code 4" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 1 TO WS-AXIS MOVE 1 TO WS-SIGN MOVE 1.0 TO WS-SPEED MOVE 0.12 TO WS-MAIN-TOL MOVE 0.12 TO WS-SIDE-TOL
     MOVE "acceptance wrapb dispense 30-4 4.1 the fire charge is shot east at power 1.0 with the noise of 6.6666665" TO WS-CASE
     PERFORM CHECK-VELOCITY

*>   B. the wind charge, same position and shot
     MOVE "wind_charge" TO WS-K MOVE "wind_charge" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE 5 TO WS-CODE
     MOVE "acceptance wrapb dispense 30-4 4.1 a wind charge is a wind charge entity at the centre of the front cell, consumed code 5" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE "acceptance wrapb dispense 30-4 4.1 the wind charge is shot east at power 1.0 with the noise of 6.6666665" TO WS-CASE
     PERFORM CHECK-VELOCITY

*>   C. the firework rocket: 0.50001 in front of the dispenser's centre (3.5 + 0.5000099999997474), shot at an angle at power 0.5
     MOVE "firework_rocket" TO WS-K MOVE "firework_rocket" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE 6 TO WS-CODE
     MOVE 400001 TO WS-EX
     MOVE "acceptance wrapb dispense 30-4 4.1 a firework rocket leaves 0.50001 in front of the dispenser's centre, no y offset, consumed code 6" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 0.5 TO WS-SPEED MOVE 0.01 TO WS-MAIN-TOL MOVE 0.01 TO WS-SIDE-TOL
     MOVE "acceptance wrapb dispense 30-4 4.1 the firework rocket is shot east at power 0.5 with the noise of 1.0" TO WS-CASE
     PERFORM CHECK-VELOCITY
     CALL "PJ-FIND" USING EN-ID(WS-EROW) WS-SLOT
     MOVE PJ-I5(WS-SLOT) TO WS-OBS-N MOVE 1 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 the firework rocket is shot at an angle (no acceleration)" TO WS-CASE
     PERFORM ASSERT-N

*>   D. the firework rocket dispensed west from the front cell (3, 101, 20): 4.5 - 0.50001 = 3.99999, shot along -x
     MOVE 3 TO WS-FX MOVE 4 TO WS-FACING
     PERFORM SHOT
     MOVE 399999 TO WS-EX
     MOVE "acceptance wrapb dispense 30-4 4.1 a firework rocket dispensed west leaves 0.50001 west of the dispenser's centre" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 1 TO WS-AXIS MOVE -1 TO WS-SIGN
     MOVE "acceptance wrapb dispense 30-4 4.1 and flies west" TO WS-CASE
     PERFORM CHECK-VELOCITY

*>   E. the fire charge dispensed up from the front cell (4, 102, 20): centre of that cell, flying up
     MOVE 4 TO WS-FX MOVE 102 TO WS-FY MOVE 1 TO WS-FACING
     MOVE "fire_charge" TO WS-K MOVE "small_fireball" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE 4 TO WS-CODE
     MOVE 450000 TO WS-EX MOVE 10250000 TO WS-EY MOVE 2050000 TO WS-EZ
     MOVE "acceptance wrapb dispense 30-4 4.1 a fire charge dispensed up appears at the centre of the cell above the dispenser" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 2 TO WS-AXIS MOVE 1 TO WS-SIGN MOVE 1.0 TO WS-SPEED MOVE 0.12 TO WS-MAIN-TOL MOVE 0.12 TO WS-SIDE-TOL
     MOVE "acceptance wrapb dispense 30-4 4.1 and flies up" TO WS-CASE
     PERFORM CHECK-VELOCITY
     MOVE 4 TO WS-FX MOVE 101 TO WS-FY MOVE 5 TO WS-FACING

*>   F. a splash potion: 0.7 in front of the centre and 0.1 above it, power 1.375 with the noise of 3, and the effects of its contents
     MOVE 0 TO WS-HANDLE
     CALL "SC-POTION-SET" USING WS-HANDLE WS-POTION
     MOVE WS-HANDLE TO WS-VAR
     MOVE "splash_potion" TO WS-K MOVE "splash_potion" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE 3 TO WS-CODE
     MOVE 420000 TO WS-EX MOVE 10160000 TO WS-EY MOVE 2050000 TO WS-EZ
     MOVE "acceptance wrapb dispense 30-4 4.1 a splash potion leaves 0.7 in front of the centre and 0.1 above it, consumed code 3 (the default launch)" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 1 TO WS-AXIS MOVE 1 TO WS-SIGN MOVE 1.375 TO WS-SPEED MOVE 0.08 TO WS-MAIN-TOL MOVE 0.08 TO WS-SIDE-TOL
     MOVE "acceptance wrapb dispense 30-4 4.1 the splash potion is shot at power 1.375 with the noise of 3" TO WS-CASE
     PERFORM CHECK-VELOCITY
     MOVE 1000 TO WS-SCALE
     CALL "SC-POTION-RESOLVE" USING WS-HANDLE WS-SCALE WS-COUNT WS-FXS
     CALL "PJ-FIND" USING EN-ID(WS-EROW) WS-SLOT
     MOVE SPACES TO TL-OBSERVED
     MOVE PJ-FXN(WS-SLOT) TO WS-A-ED
     MOVE PJ-FX-ID(WS-SLOT, 1) TO WS-B-ED
     MOVE PJ-FX-DUR(WS-SLOT, 1) TO WS-C-ED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-COUNT TO WS-A-ED
     MOVE WS-FX-ID(1) TO WS-B-ED
     MOVE WS-FX-DUR(1) TO WS-C-ED
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance wrapb dispense 30-4 4.1 the splash potion carries the effects of the slot's contents at the full scale" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   G. a lingering potion carries the same contents at the cloud scale 250 (the effects are kept at full duration, as a thrown potion of a player)
     MOVE "lingering_potion" TO WS-K MOVE "lingering_potion" TO WS-ENT-KEY
     PERFORM SHOT
     MOVE "acceptance wrapb dispense 30-4 4.1 a lingering potion is a lingering potion entity, consumed code 3" TO WS-CASE
     PERFORM CHECK-SHOT
     MOVE 1000 TO WS-SCALE
     CALL "SC-POTION-RESOLVE" USING WS-HANDLE WS-SCALE WS-COUNT WS-FXS
     CALL "PJ-FIND" USING EN-ID(WS-EROW) WS-SLOT
     MOVE SPACES TO TL-OBSERVED
     MOVE PJ-FXN(WS-SLOT) TO WS-A-ED
     MOVE PJ-FX-DUR(WS-SLOT, 1) TO WS-B-ED
     MOVE PJ-SCALE(WS-SLOT) TO WS-C-ED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-COUNT TO WS-A-ED
     MOVE WS-FX-DUR(1) TO WS-B-ED
     MOVE 250 TO WS-C-ED
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance wrapb dispense 30-4 4.1 the lingering potion carries the contents with the cloud scale 250" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-VAR

*>   H. through a powered dispenser the launch events follow the item: 1018, 1051, 1004 (the potion keeps 1002); the item is spent
     MOVE 0 TO WS-Z
     MOVE "fire_charge" TO WS-K MOVE 1018 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a dispenser shooting a fire charge sends level event 1018 and spends it" TO WS-CASE
     PERFORM LIVE-CASE
     MOVE 3 TO WS-Z
     MOVE "wind_charge" TO WS-K MOVE 1051 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a dispenser shooting a wind charge sends level event 1051 and spends it" TO WS-CASE
     PERFORM LIVE-CASE
     MOVE 6 TO WS-Z
     MOVE "firework_rocket" TO WS-K MOVE 1004 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a dispenser shooting a firework rocket sends level event 1004 and spends it" TO WS-CASE
     PERFORM LIVE-CASE
     MOVE 9 TO WS-Z
     MOVE "splash_potion" TO WS-K MOVE 1002 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 a dispenser shooting a splash potion sends the default launch event 1002 and spends it" TO WS-CASE
     PERFORM LIVE-CASE
     STOP RUN.

 SHOT.
*>   RL-DISP-BEHAVE at the front cell (WS-FX, WS-FY, WS-FZ) facing WS-FACING with the item WS-K and the slot contents WS-VAR; the entities of key WS-ENT-KEY are cleared before: WS-ECOUNT and WS-EROW after
     PERFORM FIND-ITEM
     PERFORM CLEAR-ENTITIES
     CALL "RL-DISP-BEHAVE" USING WS-DIM WS-FX WS-FY WS-FZ WS-FACING WS-ITEM WS-VAR WS-HANDLED WS-CONSUMED WS-REMAINDER
     PERFORM FIND-ENTITY.

 CHECK-SHOT.
*>   handled, consumed, the entity count and the entity's position x 100000 in one text "handled consumed count x y z"
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HANDLED TO WS-A-ED
     MOVE WS-CONSUMED TO WS-B-ED
     MOVE WS-ECOUNT TO WS-C-ED
     MOVE -1 TO WS-GX WS-GY WS-GZ
     IF WS-EROW > 0
         COMPUTE WS-GX = FUNCTION INTEGER(EN-X(WS-EROW) * 100000 + 0.5)
         COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-EROW) * 100000 + 0.5)
         COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(WS-EROW) * 100000 + 0.5)
     END-IF
     MOVE WS-GX TO WS-GX-ED
     MOVE WS-GY TO WS-GY-ED
     MOVE WS-GZ TO WS-GZ-ED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) " " FUNCTION TRIM(WS-GX-ED) " "
         FUNCTION TRIM(WS-GY-ED) " " FUNCTION TRIM(WS-GZ-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE 1 TO WS-A-ED
     MOVE WS-CODE TO WS-B-ED
     MOVE 1 TO WS-C-ED
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-EX TO WS-GX-ED
     MOVE WS-EY TO WS-GY-ED
     MOVE WS-EZ TO WS-GZ-ED
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) " " FUNCTION TRIM(WS-GX-ED) " "
         FUNCTION TRIM(WS-GY-ED) " " FUNCTION TRIM(WS-GZ-ED) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-VELOCITY.
*>   the velocity of the entity WS-EROW along axis WS-AXIS (1 x, 2 y, 3 z) times WS-SIGN is WS-SPEED within WS-MAIN-TOL, the two others within WS-SIDE-TOL of 0 (1 when it is so)
     MOVE 0 TO WS-OBS-N
     IF WS-EROW > 0
         EVALUATE WS-AXIS
             WHEN 1
                 COMPUTE WS-MAIN = EN-VX(WS-EROW) * WS-SIGN
                 MOVE EN-VY(WS-EROW) TO WS-S1
                 MOVE EN-VZ(WS-EROW) TO WS-S2
             WHEN 2
                 COMPUTE WS-MAIN = EN-VY(WS-EROW) * WS-SIGN
                 MOVE EN-VX(WS-EROW) TO WS-S1
                 MOVE EN-VZ(WS-EROW) TO WS-S2
             WHEN OTHER
                 COMPUTE WS-MAIN = EN-VZ(WS-EROW) * WS-SIGN
                 MOVE EN-VX(WS-EROW) TO WS-S1
                 MOVE EN-VY(WS-EROW) TO WS-S2
         END-EVALUATE
         IF WS-MAIN > WS-SPEED - WS-MAIN-TOL AND WS-MAIN < WS-SPEED + WS-MAIN-TOL
                 AND WS-S1 > 0 - WS-SIDE-TOL AND WS-S1 < WS-SIDE-TOL AND WS-S2 > 0 - WS-SIDE-TOL AND WS-S2 < WS-SIDE-TOL
             MOVE 1 TO WS-OBS-N
         END-IF
     END-IF
     MOVE 1 TO WS-EXP-N
     PERFORM ASSERT-N.

 LIVE-CASE.
*>   a dispenser facing east at (3, 101, WS-Z) holding one WS-K (the potion with its contents): the first Level Event the player sees after it is powered is WS-EXP-N and the slot is empty
     PERFORM FIND-ITEM
     MOVE WS-K TO WS-LIVE-KEY
     PERFORM SETUP-DISPENSER
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 0 TO BE-SLOT-VAR(WS-BE, 1)
     IF WS-LIVE-KEY = "splash_potion"
         MOVE 0 TO WS-HANDLE
         CALL "SC-POTION-SET" USING WS-HANDLE WS-POTION
         MOVE WS-HANDLE TO BE-SLOT-VAR(WS-BE, 1)
     END-IF
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     CALL "TEST-DRAIN-PACKET" USING WS-ALICE WS-PACKET-47 PB-BUFFER WS-FOUND
     MOVE 0 TO WS-EVENT
     IF WS-FOUND = 1
         MOVE 0 TO PB-POS
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-GET-INT" USING PB-BUFFER WS-EVENT
         CALL "PB-GET-POSITION" USING PB-BUFFER WS-EVX WS-EVY WS-EVZ
         CALL "PB-GET-INT" USING PB-BUFFER WS-EVDATA
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-EVGLOBAL
     END-IF
     MOVE WS-EVENT TO WS-OBS-N
     PERFORM ASSERT-N
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-OBS-N MOVE 0 TO WS-EXP-N
     MOVE "acceptance wrapb dispense 30-4 4.1 and the shot item is spent from the slot" TO WS-CASE
     PERFORM ASSERT-N.

 CLEAR-ENTITIES.
*>   removes the entities of the standard type with the bare key WS-ENT-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = WS-DIM
             CALL "KEY-BARE" USING ET-KEY(EN-TYPE(WS-I) + 1) WS-BARE
             IF WS-BARE = WS-ENT-KEY
                 CALL "ENTITY-REMOVE" USING WS-I
             END-IF
         END-IF
     END-PERFORM.

 FIND-ENTITY.
*>   the entities of the standard type with the bare key WS-ENT-KEY in the dimension: their number in WS-ECOUNT and the last one's row in WS-EROW
     MOVE 0 TO WS-ECOUNT WS-EROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = WS-DIM
             CALL "KEY-BARE" USING ET-KEY(EN-TYPE(WS-I) + 1) WS-BARE
             IF WS-BARE = WS-ENT-KEY
                 ADD 1 TO WS-ECOUNT
                 MOVE WS-I TO WS-EROW
             END-IF
         END-IF
     END-PERFORM.

 SETUP-DISPENSER.
*>   a dispenser facing east at (3, 101, WS-Z), air in front at x 4 over stone (y 100), nothing at x 2
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 POWER-ON.
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 101 TO WS-Y.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP-N TO TL-EXPECTED-N
     MOVE WS-OBS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 MAKE-DEF.
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
*>   the item id of the bare key WS-K in WS-ITEM
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         CALL "KEY-BARE" USING IT-KEY(WS-I) WS-ITEM-KEY
         IF WS-ITEM-KEY = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-DISPENSE-SHOTS.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
