*> Implementation test (wrap I2 round 3, T52093; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.6 "Skeleton horse trap", 45-4 section 6.4, 18 section 1.1.1): the thunder spawn sets the trap flag
*> (WC-TRAP, age 0); a trap horse with a living player within 10 blocks clears the flag, becomes tamed and adult, a visual-only bolt strikes it, a skeleton (a helmet at least) rides it and 3 more skeleton horses
*> with riding skeletons appear (tamed, adult, persistent, invulnerable for 60 ticks, a random horizontal push); out of reach nothing happens; a non-persistent trap horse despawns at 18000 ticks; the invulnerable
*> window blocks damage and counts down; SkeletonTrap and SkeletonTrapTime are saved; the skeleton horse has a passenger seat (y 1.31875 less the skeleton's 0.7).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-SKELETON-TRAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY WCSTATE.
 COPY PROJSTATE.
 COPY RULES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
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
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-HORSES              BINARY-LONG.
 01 WS-SKELS               BINARY-LONG.
 01 WS-RIDDEN              BINARY-LONG.
 01 WS-ADULT-TAMED         BINARY-LONG.
 01 WS-INVUL               BINARY-LONG.
 01 WS-PUSHED              BINARY-LONG.
 01 WS-PERSIST             BINARY-LONG.
 01 WS-HELMETS             BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-BOLTS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SEAT-Y              FLOAT-LONG.
 01 WS-SEAT-Z              FLOAT-LONG.
 01 WS-SEAT                BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:skeleton_horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS

*>   The seat: a skeleton on a skeleton horse sits at y 1.31875 - 0.7 = 0.61875 (18 section 1.1.1, 18 section 8.4).
     MOVE "skeleton_horse" TO WS-KEY24
     MOVE "skeleton" TO WS-KEY
     CALL "MOB-MOUNT-SEAT" USING WS-KEY24 WS-KEY WS-SEAT-Y WS-SEAT-Z WS-SEAT
     MOVE "implementation 19 3.6 a skeleton horse takes a skeleton rider at y 0.61875" TO WS-CASE
     MOVE 61875 TO WS-EXPECT
     COMPUTE WS-OBSERVE ROUNDED = WS-SEAT-Y * 100000
     PERFORM CHECK

*>   The thunder spawn: a trap roll of 0 on Normal puts a skeleton horse with the trap flag (and age 0) beside a visual-only bolt.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 8
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 0 TO WS-ROLL
     CALL "LIGHTNING-STRIKE-AT" USING WS-DIM WS-BX WS-BZ WS-ROLL WS-BOLT
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             MOVE WS-I TO WS-H
         END-IF
     END-PERFORM
     CALL "WC-ROW-OPEN" USING WS-H
     MOVE "implementation 19 3.6 the thunder spawn makes a skeleton horse with the trap flag, age 0, untamed" TO WS-CASE
     MOVE 100 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-TRAP(WS-H) * 100 + EN-MOBAGE(WS-H) * 10 + EN-TAMED(WS-H)
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-H

*>   Out of reach: a trap horse 12 blocks from the only player does nothing (10 blocks is the range).
     MOVE "skeleton_horse" TO WS-KEY24
     COMPUTE WS-X = PL-X(WS-PLAYER) + 12
     COMPUTE WS-Y = WS-FY + 1
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM SPAWN-TRAP
     CALL "SKELETON-HORSE-TICK" USING WS-H
     PERFORM COUNT-ALL
     MOVE "implementation 19 3.6 no player within 10 blocks: the flag stays and no skeleton comes" TO WS-CASE
     MOVE 1100 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-TRAP(WS-H) * 1000 + WS-HORSES * 100 + WS-SKELS
     PERFORM CHECK
     MOVE "implementation 19 3.6 the trap time counts the ticks the flag has stood" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WC-TRAP-TICKS(WS-H) TO WS-OBSERVE
     PERFORM CHECK

*>   18000 ticks: a non-persistent trap horse is discarded, a persistent one stays.
     MOVE 18000 TO WC-TRAP-TICKS(WS-H)
     CALL "SKELETON-HORSE-TICK" USING WS-H
     MOVE "implementation 19 3.6 a non-persistent trap horse despawns after 18000 ticks" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-USED(WS-H) TO WS-OBSERVE
     PERFORM CHECK
     PERFORM SPAWN-TRAP
     MOVE 1 TO EN-PERSISTENT(WS-H)
     MOVE 18000 TO WC-TRAP-TICKS(WS-H)
     CALL "SKELETON-HORSE-TICK" USING WS-H
     MOVE "implementation 19 3.6 a persistent trap horse stays" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-USED(WS-H) TO WS-OBSERVE
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-H

*>   The trap: a baby, untamed trap horse 3 blocks from the player.
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     PERFORM SPAWN-TRAP
     MOVE -100 TO EN-MOBAGE(WS-H)
     PERFORM COUNT-BOLTS
     MOVE WS-BOLTS TO WS-BOLT
     CALL "SKELETON-HORSE-TICK" USING WS-H
     PERFORM COUNT-ALL
     MOVE "implementation 19 3.6 the trap clears the flag, tames the horse and makes it an adult" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-TAMED(WS-H) * 10 + (1 - WC-TRAP(WS-H)) * 1
     IF EN-MOBAGE(WS-H) NOT = 0
         MOVE 99 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 19 3.6 four skeleton horses and four skeletons now" TO WS-CASE
     MOVE 44 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HORSES * 10 + WS-SKELS
     PERFORM CHECK
     MOVE "implementation 19 3.6 every skeleton sits on a skeleton horse" TO WS-CASE
     MOVE 4 TO WS-EXPECT
     MOVE WS-RIDDEN TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 19 3.6 every skeleton wears a helmet (an iron one when it rolled none)" TO WS-CASE
     MOVE 4 TO WS-EXPECT
     MOVE WS-HELMETS TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 19 3.6 the three added horses are tamed adults, persistent, invulnerable for 60 ticks" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-INVUL TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 19 3.6 the three added horses are pushed horizontally (triangle(0, 1.1485))" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-PUSHED TO WS-OBSERVE
     PERFORM CHECK
     PERFORM COUNT-BOLTS
     MOVE "implementation 19 3.6 one visual-only lightning bolt strikes the horse" TO WS-CASE
     COMPUTE WS-EXPECT = WS-BOLT + 1
     MOVE WS-BOLTS TO WS-OBSERVE
     PERFORM CHECK

*>   The invulnerable window: damage is ignored while WC-INVUL-TICKS is above 0, which counts down once a tick; then the hit lands.
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             CALL "WC-ROW-OPEN" USING WS-I
             IF WC-INVUL-TICKS(WS-I) > 0
                 MOVE WS-I TO WS-H
             END-IF
         END-IF
     END-PERFORM
     MOVE EN-HEALTH(WS-H) TO WS-HEALTH
     MOVE CAUSE-GENERIC TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-H WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     MOVE "implementation 19 3.6 an invulnerable trap horse takes no damage" TO WS-CASE
     MOVE WS-HEALTH TO WS-EXPECT
     MOVE EN-HEALTH(WS-H) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 2 TO WC-INVUL-TICKS(WS-H)
     CALL "SKELETON-HORSE-TICK" USING WS-H
     CALL "SKELETON-HORSE-TICK" USING WS-H
     MOVE "implementation 19 3.6 the window counts down once a tick" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-INVUL-TICKS(WS-H) TO WS-OBSERVE
     PERFORM CHECK
     MOVE EN-HEALTH(WS-H) TO WS-HEALTH
     CALL "HEALTH-MOB-DAMAGE" USING WS-H WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
     MOVE "implementation 19 3.6 after the window a hit lands" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-HEALTH(WS-H) < WS-HEALTH
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   The flag is saved (45-4 section 6.4: SkeletonTrap Byte, SkeletonTrapTime Int) and comes back.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 15
     PERFORM SPAWN-TRAP
     MOVE 1234 TO WC-TRAP-TICKS(WS-H)
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-H) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-H) / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     CALL "ENTITY-REMOVE" USING WS-H
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             MOVE WS-I TO WS-H
         END-IF
     END-PERFORM
     CALL "WC-ROW-OPEN" USING WS-H
     MOVE "implementation 45-4 6.4 SkeletonTrap and SkeletonTrapTime come back" TO WS-CASE
     MOVE 11234 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-TRAP(WS-H) * 10000 + WC-TRAP-TICKS(WS-H)
     PERFORM CHECK

*>   Through a real tick of the world: a trap horse in reach of the player springs the trap.
     CALL "ENTITY-REMOVE" USING WS-H
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     PERFORM SPAWN-TRAP
     CALL "TEST-TICKS" USING WS-AMOUNT
     MOVE "implementation 19 3.6 a world tick runs the trap: the flag is cleared" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WC-TRAP(WS-H) TO WS-OBSERVE
     PERFORM CHECK
*>   And the despawn through a world tick: a far, non-persistent trap horse at 18000 ticks is gone after one tick.
     COMPUTE WS-X = PL-X(WS-PLAYER) - 12
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     PERFORM SPAWN-TRAP
     MOVE 18000 TO WC-TRAP-TICKS(WS-H)
     MOVE 1 TO WS-AMOUNT
     CALL "TEST-TICKS" USING WS-AMOUNT
     MOVE "implementation 19 3.6 a world tick discards the expired trap horse" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-USED(WS-H) TO WS-OBSERVE
     PERFORM CHECK
     STOP RUN.
*> SPAWN-TRAP: a skeleton horse with the trap flag at WS-X WS-Y WS-Z (WS-Y: the floor top + 1 unless set), its row in WS-H
 SPAWN-TRAP.
     COMPUTE WS-Y = WS-FY + 1
     CALL "MOB-SPAWN" USING WS-DIM WS-HTYPE WS-X WS-Y WS-Z WS-YAW WS-H
     CALL "WC-ROW-OPEN" USING WS-H
     MOVE 1 TO WC-TRAP(WS-H)
     MOVE 0 TO WC-TRAP-TICKS(WS-H) EN-TAMED(WS-H) EN-PERSISTENT(WS-H).
*> COUNT-ALL: the skeleton horses and skeletons in the world in WS-HORSES and WS-SKELS; of the horses, WS-INVUL are tamed adult persistent horses with 60 ticks and WS-PUSHED have a horizontal push; of the
*> skeletons, WS-RIDDEN ride a skeleton horse and WS-HELMETS wear a helmet
 COUNT-ALL.
     MOVE 0 TO WS-HORSES WS-SKELS WS-RIDDEN WS-HELMETS WS-INVUL WS-PUSHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-HTYPE
             ADD 1 TO WS-HORSES
             CALL "WC-ROW-OPEN" USING WS-I
             IF WC-INVUL-TICKS(WS-I) = 60 AND EN-TAMED(WS-I) = 1 AND EN-MOBAGE(WS-I) = 0 AND EN-PERSISTENT(WS-I) = 1
                 ADD 1 TO WS-INVUL
             END-IF
             IF EN-VX(WS-I) NOT = 0 OR EN-VZ(WS-I) NOT = 0
                 ADD 1 TO WS-PUSHED
             END-IF
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-STYPE
             ADD 1 TO WS-SKELS
             MOVE EN-MOUNT(WS-I) TO WS-VEHICLE
             IF WS-VEHICLE > 0
                 IF EN-TYPE(WS-VEHICLE) = WS-HTYPE
                     ADD 1 TO WS-RIDDEN
                 END-IF
             END-IF
             IF FUNCTION MOD(EN-EQUIP(WS-I), 10) >= 1
                 ADD 1 TO WS-HELMETS
             END-IF
         END-IF
     END-PERFORM.
*> COUNT-BOLTS: the lightning bolts (PJ-KIND 9) in WS-BOLTS
 COUNT-BOLTS.
     MOVE 0 TO WS-BOLTS
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > PJ-MAX
         IF PJ-ENT(WS-SLOT) > 0 AND PJ-KIND(WS-SLOT) = 9
             ADD 1 TO WS-BOLTS
         END-IF
     END-PERFORM.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-SKELETON-TRAP.
 COPY CORETEST.
 COPY MOBSPTEST.
