*> Acceptance test (lane p49r; docs/protocol/20 section 15, 15.1, 15.4 and 44-5 section 3): the warden's activities.
*> - a new warden has the dig cooldown (1200); DIG when it has run out with no roar target (100 ticks of Digging on the ground, then the warden is removed; invulnerable meanwhile);
*> - ROAR: an ANGRY warden (anger 80 or more at the top suspect, a player it can target) with no attack target and no roar target sets the roar target; the Roar behaviour starts the next tick, adds 20 anger,
*>   lasts 84 ticks and then makes the roar target the attack target (sonic boom cooldown 200); FIGHT follows; below ANGRY or against a creative player no roar;
*> - FIGHT: the attack target is erased when the target's anger is below 80 (and a target that cannot be targeted loses its anger too);
*> - INVESTIGATE: a disturbance location (set by a vibration or a sniff) lasts 100 ticks, the warden walks to it, and setting it does nothing when the warden is ANGRY at someone;
*> - SNIFF: TryToSniff needs the sniff cooldown absent, nearest_attackable present, no disturbance location: sniff cooldown 100 to 200, Sniffing runs 84 ticks and then adds 35 anger for a target within
*>   6 blocks (20 vertical) and sets a disturbance location at it;
*> - EMERGE: is_emerging 134 ticks, invulnerable; vibrations: heard within 16 blocks after floor(distance to the listener point 2.465 above the feet) ticks, cooldown 40, anger 35 and a disturbance
*>   location; ignored for creative sources, sneaking-filtered events, a vibration in flight, a cooldown, digging and emerging; a projectile owner gets 10 the first time (35 with a recent projectile).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-15-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY WARDENSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 5.
 01 WS-CAUSE               BINARY-LONG VALUE 3.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DIST0               FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-SNEAK               BINARY-LONG.
 01 WS-EVENT-X             FLOAT-LONG.
 01 WS-EVENT-Y             FLOAT-LONG.
 01 WS-EVENT-Z             FLOAT-LONG.
 01 WS-TICKS0              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE 12001 TO CW-TIME
*>   0. A new warden has the dig cooldown memory (finalizeSpawn, 1200).
     PERFORM NEW-WARDEN
     MOVE "a new warden has the dig cooldown 1200" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
*>   1. ROAR. Anger 100 (ANGRY), no target: the roar target is set on the first tick, the roar starts on the second (anger + 20) and ends at the 86th tick with the attack target.
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "an ANGRY warden sets the roar target on its first tick" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-ROAR-TARGET(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and the ROAR activity is chosen for the next tick" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the Roar behaviour starts on the second tick and adds 20 anger (no decay yet)" TO TL-CASE
     MOVE 120 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 2 TO WS-K
     PERFORM UNTIL EN-TARGET(WS-WARDEN) > 0 OR WS-K >= 120
         CALL "MOB-STEP" USING WS-WARDEN
         ADD 1 TO WS-K
     END-PERFORM
     MOVE "the roar ends 84 ticks after it started: the attack target is set on the 86th tick" TO TL-CASE
     MOVE 86 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the attack target is the roar target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the roar target memory is erased and the sonic boom cooldown is 200" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 200
     COMPUTE TL-OBSERVED-N = WD-SONIC-CD(WS-W) + WD-ROAR-TARGET(WS-W)
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "FIGHT is the activity after the roar" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   Below ANGRY (79) no roar; a creative player at 100 no roar.
     PERFORM NEW-WARDEN
     MOVE 79 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "anger 79 is not ANGRY: no roar target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ROAR-TARGET(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a creative player cannot be targeted: no roar target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ROAR-TARGET(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   2. FIGHT: the attack target is erased when its anger is below 80; a target that turns creative loses its anger too.
     PERFORM NEW-WARDEN
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-WARDEN)
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 5000 TO WD-SONIC-CD(WS-W)
     CALL "MOB-STEP" USING WS-WARDEN
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a fighting warden keeps a target at anger 100" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 50 TO WD-ANGER(WS-W, WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the attack target is erased when the target's anger falls below 80" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-WARDEN
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "a target that turns creative is dropped and its anger cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TARGET(WS-WARDEN) + WD-ANGER(WS-W, WS-PLAYER)
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   3. INVESTIGATE: a disturbance location lasts 100 ticks and the warden walks to it.
     PERFORM NEW-WARDEN
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 12
     MOVE EN-X(WS-WARDEN) TO WS-DIST0
     CALL "WARDEN-DISTURB" USING WS-WARDEN WS-BX WS-BY WS-BZ
     MOVE "a disturbance location lasts 100 ticks" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "it sets the sniff cooldown to 100" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE WD-SNIFF-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 20 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "INVESTIGATE is the activity while the location is present" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the warden walks towards the location (x decreases)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-WARDEN) < WS-DIST0 - 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     PERFORM 79 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "after 99 ticks the location still holds (1 tick left), INVESTIGATE" TO TL-CASE
     MOVE 501 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WD-ACT(WS-W) * 100 + WD-DISTURB(WS-W)
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "after 100 ticks the location has expired and the activity is IDLE" TO TL-CASE
     MOVE 700 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WD-ACT(WS-W) * 100 + WD-DISTURB(WS-W)
     PERFORM CASE-LINE
*>   Setting a location does nothing while the warden is ANGRY at someone.
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "WARDEN-DISTURB" USING WS-WARDEN WS-BX WS-BY WS-BZ
     MOVE "a warden ANGRY at someone ignores a disturbance location" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-DISTURB(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   4. SNIFF: a player within 24 blocks becomes nearest_attackable at the first scan; TryToSniff sets is_sniffing and the cooldown 100 to 200.
     PERFORM NEW-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WD-SENSOR(WS-W)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 4
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the sensor finds the player within 24 blocks (nearest_attackable)" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE WD-NEAR(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "TryToSniff sets is_sniffing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WD-SNIFFING(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and a sniff cooldown of 100 to 200 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-SNIFF-CD(WS-W) >= 100 AND WD-SNIFF-CD(WS-W) <= 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     MOVE "SNIFF is the activity of the next tick" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 84 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "Sniffing is still running on its 85th tick of life" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WD-SNIFFING(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "after 84 ticks of Sniffing is_sniffing is cleared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-SNIFFING(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and a target within 6 blocks gets anger 35 (less the manager's decay)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-ANGER(WS-W, WS-PLAYER) >= 30 AND WD-ANGER(WS-W, WS-PLAYER) <= 35
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     MOVE "and a disturbance location is set at its block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-DISTURB(WS-W) > 0 AND WD-DX(WS-W) = FUNCTION INTEGER(WS-X) AND WD-DZ(WS-W) = FUNCTION INTEGER(WS-Z)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   A target farther than 6 blocks horizontally gets no anger from the sniff.
     PERFORM NEW-WARDEN
     MOVE 1 TO WD-SENSOR(WS-W)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 9
     PERFORM 87 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "a target 9 blocks away gets no anger from the sniff" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   5. DIG: the cooldown runs out with no roar target: Digging starts the next tick, lasts 100 ticks and removes the warden; it is invulnerable meanwhile.
     PERFORM NEW-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE EN-X(WS-WARDEN) = WS-X + 15
     MOVE 2 TO WD-DIG-CD(WS-W)
     MOVE 5000 TO WD-SNIFF-CD(WS-W)
     PERFORM 3 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the DIG activity is chosen once the dig cooldown has run out" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE EN-HEALTH(WS-WARDEN) TO WS-HEALTH
     MOVE 0 TO EN-HURT(WS-WARDEN)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WARDEN WS-DAMAGE WS-CAUSE WS-ZERO
     MOVE "a digging warden is invulnerable" TO TL-CASE
     MOVE WS-HEALTH TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 99 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the warden is still there 99 ticks into the dig" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "the warden is removed after the 100 ticks of Digging" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
*>   A warden with an attack target does not dig (and a fighting warden keeps the cooldown fresh).
     PERFORM NEW-WARDEN
     MOVE 100 TO WD-ANGER(WS-W, WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-WARDEN)
     MOVE 5000 TO WD-SONIC-CD(WS-W)
     MOVE 5 TO WD-DIG-CD(WS-W)
     PERFORM 3 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the FIGHT activity refreshes the dig cooldown to 1200" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   6. EMERGE: a warden finalized for a shrieker emerges for 134 ticks, invulnerable.
     PERFORM NEW-WARDEN
     CALL "WARDEN-EMERGE" USING WS-WARDEN
     MOVE "emerging lasts 134 ticks" TO TL-CASE
     MOVE 134 TO TL-EXPECTED-N
     MOVE WD-EMERGE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 10 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the EMERGE activity is the first valid" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WD-ACT(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE EN-HEALTH(WS-WARDEN) TO WS-HEALTH
     MOVE 0 TO EN-HURT(WS-WARDEN)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WARDEN WS-DAMAGE WS-CAUSE WS-ZERO
     MOVE "an emerging warden is invulnerable" TO TL-CASE
     MOVE WS-HEALTH TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-WARDEN) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM 124 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "after 134 ticks the memory has expired and the warden is vulnerable and IDLE" TO TL-CASE
     MOVE 700 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WD-ACT(WS-W) * 100 + WD-EMERGE(WS-W)
     PERFORM CASE-LINE
     MOVE 0 TO EN-HURT(WS-WARDEN)
     CALL "HEALTH-MOB-DAMAGE" USING WS-WARDEN WS-DAMAGE WS-CAUSE WS-ZERO
     MOVE "and it takes damage again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-WARDEN) < WS-HEALTH
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   7. Vibrations. A survival player posts a step 10 blocks east of the warden at the same height; the listener point is 2.465 above its feet, so the distance is 10.3 and the travel time 10 ticks.
     PERFORM NEW-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1000 TO CW-TICKS
     COMPUTE EN-X(WS-WARDEN) = WS-X - 10
     MOVE WS-X TO WS-EVENT-X
     MOVE WS-Y TO WS-EVENT-Y
     MOVE WS-Z TO WS-EVENT-Z
     MOVE 0 TO WS-OWNER WS-SNEAK
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     PERFORM 9 TIMES
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the vibration has not arrived after 9 ticks (anger 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     ADD 1 TO CW-TICKS
     CALL "MOB-STEP" USING WS-WARDEN
     MOVE "it arrives on the 10th tick: anger 35" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "the vibration cooldown is 40 (39 after the next tick of the same step)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WD-VIB-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "a disturbance location is set at the source's block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-DISTURB(WS-W) > 0 AND WD-DX(WS-W) = FUNCTION INTEGER(WS-X) AND WD-DZ(WS-W) = FUNCTION INTEGER(WS-Z)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
*>   A second vibration inside the cooldown is not heard.
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     PERFORM 15 TIMES
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "a vibration posted inside the 40-tick cooldown is not heard (35, less the manager's one decay at tick 20)" TO TL-CASE
     MOVE 34 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WD-ANGER(WS-W, WS-PLAYER)
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   Not heard: a creative source, a sneaking-filtered event, 17 blocks away.
     PERFORM NEW-WARDEN
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE EN-X(WS-WARDEN) = WS-X - 5
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "a creative source is not heard (nothing in flight)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WS-SNEAK
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "a sneaking source's filtered event is not heard" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 0 TO WS-SNEAK
     COMPUTE EN-X(WS-WARDEN) = WS-X - 17
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "an event 17 blocks away is out of the listener radius 16" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     COMPUTE EN-X(WS-WARDEN) = WS-X - 15
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "an event 15 blocks away is heard (due after floor(15.2) = 15 ticks)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 15
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "a second event while one is in flight is dropped (due unchanged)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CW-TICKS + 15
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   A digging or emerging warden hears nothing.
     PERFORM NEW-WARDEN
     CALL "WARDEN-EMERGE" USING WS-WARDEN
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-OWNER WS-SNEAK
     MOVE "an emerging warden hears nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-V-DUE(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   Projectile: the owner of the projectile (here the player, 8 blocks from the warden) gets 10 the first time, 35 within the next 100 ticks; the location is the vibration's own the first time.
     PERFORM NEW-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1000 TO CW-TICKS
     COMPUTE EN-X(WS-WARDEN) = WS-X + 8
     COMPUTE WS-EVENT-X = WS-X + 3
     MOVE WS-PLAYER TO WS-OWNER
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-ZERO WS-OWNER WS-SNEAK
     PERFORM 6 TIMES
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "a projectile owner within 30 blocks gets 10 anger the first time" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WD-ANGER(WS-W, WS-PLAYER) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and recent_projectile is set for 100 ticks (94 after 6 more)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-PROJ-CD(WS-W) >= 90 AND WD-PROJ-CD(WS-W) <= 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     MOVE "the location is the vibration's own block (the projectile's)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-DISTURB(WS-W) > 0 AND WD-DX(WS-W) = FUNCTION INTEGER(WS-EVENT-X)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     MOVE 0 TO WD-VIB-CD(WS-W) WD-DISTURB(WS-W)
     CALL "WARDEN-HEAR" USING WS-DIM WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-ZERO WS-OWNER WS-SNEAK
     PERFORM 6 TIMES
         ADD 1 TO CW-TICKS
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "with a recent projectile the owner gets 35 more (10 + 35, less decay)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-ANGER(WS-W, WS-PLAYER) >= 40 AND WD-ANGER(WS-W, WS-PLAYER) <= 45
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     MOVE "and the location becomes the owner's block (the player's)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WD-DISTURB(WS-W) > 0 AND WD-DX(WS-W) = FUNCTION INTEGER(WS-X) AND WD-DZ(WS-W) = FUNCTION INTEGER(WS-Z)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   A disturbance while it has an attack target refreshes the present dig cooldown (and arriving at the walk target ends the walk).
     PERFORM NEW-WARDEN
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE WS-PLAYER TO EN-TARGET(WS-WARDEN)
     MOVE 5 TO WD-DIG-CD(WS-W)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-WARDEN)) - 4
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WARDEN-DISTURB" USING WS-WARDEN WS-BX WS-BY WS-BZ
     MOVE "a disturbance with an attack target refreshes the dig cooldown to 1200" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE WD-DIG-CD(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
     PERFORM NEW-WARDEN
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-WARDEN)) - 5
     CALL "WARDEN-DISTURB" USING WS-WARDEN WS-BX WS-BY WS-BZ
     PERFORM 60 TIMES
         CALL "MOB-STEP" USING WS-WARDEN
     END-PERFORM
     MOVE "the warden reaches a location 5 blocks away and stops walking (walk target cleared)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WD-WALK-ON(WS-W) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
*>   With every state slot taken a warden has no brain state: the helpers do nothing.
     PERFORM NEW-WARDEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         COMPUTE WD-ID(WS-I) = 900000 + WS-I
     END-PERFORM
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ZERO WS-W
     CALL "WARDEN-ACTIVE" USING WS-WARDEN WS-K WS-LAST
     CALL "WARDEN-DISTURB" USING WS-WARDEN WS-BX WS-BY WS-BZ
     CALL "WARDEN-HEAR-ONE" USING WS-WARDEN WS-EVENT-X WS-EVENT-Y WS-EVENT-Z WS-PLAYER WS-ZERO
     MOVE "a warden without a state slot: level and top suspect are 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-K + WS-LAST + WS-W
     PERFORM CASE-LINE
     CALL "ENTITY-REMOVE" USING WS-WARDEN
     STOP RUN.

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§15 Warden brain: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> A new warden 8 blocks east of the player (survival), on the floor, with its state slot (the dig cooldown memory 1200), no sonic boom cooldown trouble: the player stands 8 blocks away.
 NEW-WARDEN.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WD-MAX
         INITIALIZE WD-ENTRY(WS-I)
     END-PERFORM
     COMPUTE WS-X0 = WS-X + 8
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-WARDEN
     CALL "WD-FIND" USING EN-ID(WS-WARDEN) WS-ONE WS-W
     MOVE 5 TO WD-SENSOR(WS-W)
     MOVE 0 TO EN-WAKE(WS-WARDEN) EN-TARGET(WS-WARDEN)
     .
 END PROGRAM TEST-MOB-20-15-6.
 COPY CORETEST.
 COPY MOBSPTEST.
