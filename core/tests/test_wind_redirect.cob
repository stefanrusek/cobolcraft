*> Implementation test (wrap C round 6, T24214; docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md sections 6.3, 6.4 and 8, 21 section 8.18): a wind charge is redirected by a
*> player's attack (AIM_DEFLECT: the velocity becomes the attacker's look direction, the attacker is the new owner, the acceleration power becomes 0.1 so the speed grows by 0.1 a tick);
*> the charge of a player takes no deflection during its first 5 ticks (noDeflectTicks, decremented every tick), the breeze's charge has no such window; the attack never damages the charge.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WIND-REDIRECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 777.
 01 WS-BREEZE              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-DUMMY               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 1.0
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 1.5

*>   A fresh charge of a player is in its no-deflect window: the attack changes nothing and does not damage the charge.
     MOVE 0 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "PJ-FIND" USING WS-ID WS-SLOT
     MOVE "implementation 44-8 8 a new charge of a player has a no-deflect window of 5 ticks" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PJ-I2(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 44-8 8 an attack inside the window does not redirect: owner and velocity stay, the charge is not hurt" TO TL-CASE
     MOVE 7771 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TARGET-ID(WS-ROW) * 10 + EN-USED(WS-ROW) + EN-VZ(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The window counts down one a tick: after 4 ticks the charge still refuses, after 5 the attack redirects it.
     PERFORM 4 TIMES
         CALL "THROWN-TICK"
     END-PERFORM
     MOVE "implementation 44-8 8 the window is 1 tick after 4 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I2(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 44-8 8 an attack with 1 tick of the window left still redirects nothing" TO TL-CASE
     MOVE WS-OWNER TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "THROWN-TICK"
     MOVE "implementation 44-8 8 the window is over after 5 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-I2(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Redirect by attack: the velocity is the player's look direction (yaw 0, pitch 0: +z, speed 1), the player owns the charge, the power is 0.1.
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-DUMMY
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 6.3 AIM_DEFLECT the attack aims the charge along the player's look: velocity (0, 0, 1)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000 + EN-VX(WS-ROW) * 1000000 + EN-VY(WS-ROW) * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 6.3 the attacker is the new owner" TO TL-CASE
     MOVE WS-DUMMY TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 6.4 onDeflection by an attack: the acceleration power is 0.1" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-ROU(WS-SLOT) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 8 the charge is not damaged or removed by the attack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Acceleration: one tick of flight adds 0.1 along the velocity (inertia 1.0), so the speed is 1.1.
     CALL "THROWN-TICK"
     MOVE "implementation 6.4 applyInertia with power 0.1: the speed after one tick is 1.1" TO TL-CASE
     MOVE 1100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The breeze's charge has no window: the attack redirects it at once. Remove the player charge first.
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 1 TO WS-BREEZE
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 8 the breeze's charge has no no-deflect window: the attack redirects it at once" TO TL-CASE
     MOVE WS-DUMMY TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The pick radius (44-8 section 6.1: getPickRadius is 1.0 for a redirectable projectile): the charge's box is inflated by 1.0 for the reach of an attack (4.0). A charge whose box is 4.84 blocks from
*>   the eye (z + 5.0 less its half width 0.156) is within reach through the radius (3.84), one at z + 5.3 (4.14) is not.
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 5.3
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 44-8 6.1 a charge 4.14 blocks from the eye (box inflated by the pick radius 1.0) is out of reach: not redirected" TO TL-CASE
     MOVE WS-OWNER TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ROW
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 5.0
     CALL "WIND-SPAWN" USING WS-BREEZE WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "implementation 44-8 6.1 a charge 3.84 blocks from the eye through the pick radius is within the reach 4.0: redirected" TO TL-CASE
     MOVE WS-DUMMY TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WIND-REDIRECT.
 COPY CORETEST.
 COPY MOBSPTEST.
