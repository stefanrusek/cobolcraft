*> Mobs riding mobs (docs/protocol/18-mob-framework.md sections 1.1.1, 2.2 and 8.4; 20 sections 4.1, 7.1 and 14.3; 21 section 5.7): the jockeys.
*> The rider is a mob row with EN-MOUNT (the vehicle's row) and EN-MOUNT-ID (its entity id); the vehicle has EN-PASS (the rider's row). A player riding a mob is EN-RIDER
*> (mob-18-ride.cob) and a mob with a player on it takes no mob rider. The rider is put on the seat of the vehicle by the vehicle's table (MOB-MOUNT-SEAT) less the rider's
*> riding offset; its position is never sent (18 section 9.2: a passenger sends no movement), only Set Passengers when the passengers change (MOB-RIDE-SEND).
*> The vehicle's MOVE and LOOK goals are off while a mob rides it (18 section 2.2), so the rider's goals steer it: it walks to the rider's target at its own walk speed (a strider is not driven: only a player holding the stick steers it, 21 section 5.7).
*> Open: the strider's seat (not in the 1.1.1 table: 21 section 5.7 and 44-6 section 8 give no passenger attachment, the rider is put at the strider's position), the pairing
*> bundle's Set Passengers for a viewer who comes into range later, a rider dismounting into water (dismounts_underwater), a chicken jockey's 10 experience.
*>   MOB-MOUNT-SEAT USING vehicle key, rider key, y out, z out, seat out (1 when the vehicle takes a mob rider)
*>   MOB-MOUNT USING rider row, vehicle row, mounted out
*>   MOB-MOUNT-PLACE, MOB-MOUNT-DROP, MOB-MOUNT-GONE, MOB-MOUNT-STEP, MOB-MOUNT-DRIVE, MOB-JOCKEY-SPIDER, MOB-JOCKEY-ZOMBIE

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-SEAT.
*> USING vehicle key, rider key (PIC X(24)), y out, z out (FLOAT-LONG), seat out (BINARY-LONG): the rider's feet relative to the vehicle's feet. The vehicle's passenger
*> attachment (18 section 1.1.1: spider y 0.765, ravager (0, 2.2625, -0.0625), chicken (0, 0.7, -0.1); the strider has none documented: 0) plus the rider's riding offset
*> (-0.7 for the skeleton, zombie and piglin families, -0.6 for the illagers, else 0). seat is 0 for a species that takes no mob rider.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ATTACH.
    05 FILLER              PIC X(24) VALUE "spider".
    05 FILLER              FLOAT-LONG VALUE 0.765.
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              PIC X(24) VALUE "ravager".
    05 FILLER              FLOAT-LONG VALUE 2.2625.
    05 FILLER              FLOAT-LONG VALUE -0.0625.
    05 FILLER              PIC X(24) VALUE "chicken".
    05 FILLER              FLOAT-LONG VALUE 0.7.
    05 FILLER              FLOAT-LONG VALUE -0.1.
    05 FILLER              PIC X(24) VALUE "strider".
    05 FILLER              FLOAT-LONG VALUE 0.
    05 FILLER              FLOAT-LONG VALUE 0.
 01 WS-TABLE REDEFINES WS-ATTACH.
    05 WS-A OCCURS 4 TIMES.
       10 WS-A-KEY         PIC X(24).
       10 WS-A-Y           FLOAT-LONG.
       10 WS-A-Z           FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-VEHICLE              PIC X(24).
 01 L-RIDER                PIC X(24).
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SEAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VEHICLE L-RIDER L-Y L-Z L-SEAT.
     MOVE 0 TO L-Y L-Z L-SEAT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-A-KEY(WS-I) = L-VEHICLE
             MOVE 1 TO L-SEAT
             MOVE WS-A-Y(WS-I) TO L-Y
             MOVE WS-A-Z(WS-I) TO L-Z
         END-IF
     END-PERFORM
     EVALUATE L-RIDER
         WHEN "skeleton" WHEN "stray" WHEN "bogged" WHEN "parched" WHEN "zombie" WHEN "husk" WHEN "drowned"
         WHEN "zombie_villager" WHEN "piglin" WHEN "piglin_brute" WHEN "zombified_piglin"
             COMPUTE L-Y = L-Y - 0.7
         WHEN "evoker" WHEN "illusioner" WHEN "pillager" WHEN "vindicator"
             COMPUTE L-Y = L-Y - 0.6
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-MOUNT-SEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-PLACE.
*> USING rider row (EN-MOUNT > 0): the rider is put at its seat on the vehicle (no packet), facing the vehicle's yaw; the z offset of the seat turns with the vehicle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VKEY                PIC X(24).
 01 WS-RKEY                PIC X(24).
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SEAT                BINARY-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-EV-DISMOUNT         PIC X(32) VALUE "entity_dismount".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-MOUNT(L-ROW) TO WS-V
     CALL "MOB-SPECIES-KEY" USING WS-V WS-VKEY
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-RKEY
     CALL "MOB-MOUNT-SEAT" USING WS-VKEY WS-RKEY WS-Y WS-Z WS-SEAT
     COMPUTE WS-RADIANS = EN-YAW(WS-V) * FUNCTION PI / 180
     COMPUTE EN-X(L-ROW) = EN-X(WS-V) - WS-Z * FUNCTION SIN(WS-RADIANS)
     COMPUTE EN-Y(L-ROW) = EN-Y(WS-V) + WS-Y
     COMPUTE EN-Z(L-ROW) = EN-Z(WS-V) + WS-Z * FUNCTION COS(WS-RADIANS)
     MOVE EN-YAW(WS-V) TO EN-YAW(L-ROW)
     MOVE EN-ON-GROUND(WS-V) TO EN-ON-GROUND(L-ROW)
     MOVE 0 TO EN-VY(L-ROW)
     GOBACK.
 END PROGRAM MOB-MOUNT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT.
*> USING rider row, vehicle row, mounted out (BINARY-LONG): startRiding for two mobs (18 section 8.4). It fails when a row is free, the rider already rides, the vehicle
*> already has a mob rider or a player on it, or the vehicle's species takes none (MOB-MOUNT-SEAT). The rider is placed on the seat and the vehicle's viewers get Set Passengers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VKEY                PIC X(24).
 01 WS-RKEY                PIC X(24).
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SEAT                BINARY-LONG.
 01 WS-EV-MOUNT            PIC X(32) VALUE "entity_mount".
 LINKAGE SECTION.
 01 L-RIDER                BINARY-LONG.
 01 L-VEHICLE              BINARY-LONG.
 01 L-MOUNTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-RIDER L-VEHICLE L-MOUNTED.
     MOVE 0 TO L-MOUNTED
     IF L-RIDER = L-VEHICLE OR EN-USED(L-RIDER) = 0 OR EN-USED(L-VEHICLE) = 0
         GOBACK
     END-IF
     IF EN-MOUNT(L-RIDER) > 0 OR EN-PASS(L-VEHICLE) > 0 OR EN-RIDER(L-VEHICLE) > 0 OR EN-MOUNT(L-VEHICLE) = L-RIDER
         GOBACK
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-VEHICLE WS-VKEY
     CALL "MOB-SPECIES-KEY" USING L-RIDER WS-RKEY
     CALL "MOB-MOUNT-SEAT" USING WS-VKEY WS-RKEY WS-Y WS-Z WS-SEAT
     IF WS-SEAT = 0 OR WS-RKEY = SPACES
         GOBACK
     END-IF
     MOVE L-VEHICLE TO EN-MOUNT(L-RIDER)
     MOVE EN-ID(L-VEHICLE) TO EN-MOUNT-ID(L-RIDER)
     MOVE L-RIDER TO EN-PASS(L-VEHICLE)
     CALL "MOB-MOUNT-PLACE" USING L-RIDER
     CALL "MOB-RIDE-SEND" USING L-VEHICLE
*>   entity_mount at the vehicle's position, the rider as the source (30-8 14.1.9)
     CALL "GAME-EVENT-BY" USING WS-EV-MOUNT L-VEHICLE L-RIDER
     MOVE 1 TO L-MOUNTED
     GOBACK.
 END PROGRAM MOB-MOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-DROP.
*> USING rider row: the rider gets off where it is (stopRiding) and the vehicle's viewers get Set Passengers (the vehicle row is read before it is cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-V                   BINARY-LONG.
 01 WS-EV-DISMOUNT         PIC X(32) VALUE "entity_dismount".
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-MOUNT(L-ROW) TO WS-V
     MOVE 0 TO EN-MOUNT(L-ROW) EN-MOUNT-ID(L-ROW)
     IF WS-V > 0
         IF EN-PASS(WS-V) = L-ROW
             MOVE 0 TO EN-PASS(WS-V)
             CALL "MOB-RIDE-SEND" USING WS-V
             CALL "GAME-EVENT-BY" USING WS-EV-DISMOUNT WS-V L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-MOUNT-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-GONE.
*> USING row (called by ENTITY-REMOVE before the row is cleared): a vehicle's rider is left standing (EN-MOUNT cleared) and a rider's vehicle has no rider. Entity.removeVehicle posts
*> entity_dismount at the vehicle's position with the rider as the source (30-8 14.1.9) when the rider has no removal reason or one that destroys it: every removal of this core destroys
*> (death, despawn, pickup), except a player row, which leaves with its connection (unloaded: nothing is posted for it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EV-DISMOUNT         PIC X(32) VALUE "entity_dismount".
 01 WS-RIDER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-PASS(L-ROW) > 0
         MOVE EN-PASS(L-ROW) TO WS-RIDER
         MOVE 0 TO EN-MOUNT(WS-RIDER) EN-MOUNT-ID(WS-RIDER)
         CALL "GAME-EVENT-BY" USING WS-EV-DISMOUNT L-ROW WS-RIDER
     END-IF
*>   Players riding the vehicle (EN-RIDER, a camel's EN-RIDER2): they get off the vehicle that goes.
     IF EN-RIDER(L-ROW) > 0
         MOVE PL-ENTITY-ROW(EN-RIDER(L-ROW)) TO WS-RIDER
         MOVE 0 TO EN-VEHICLE(WS-RIDER)
         CALL "GAME-EVENT-BY" USING WS-EV-DISMOUNT L-ROW WS-RIDER
     END-IF
     IF EN-RIDER2(L-ROW) > 0
         MOVE PL-ENTITY-ROW(EN-RIDER2(L-ROW)) TO WS-RIDER
         MOVE 0 TO EN-VEHICLE(WS-RIDER)
         CALL "GAME-EVENT-BY" USING WS-EV-DISMOUNT L-ROW WS-RIDER
     END-IF
     IF EN-MOUNT(L-ROW) > 0
         IF EN-PASS(EN-MOUNT(L-ROW)) = L-ROW
             MOVE 0 TO EN-PASS(EN-MOUNT(L-ROW))
             IF EN-PLAYER(L-ROW) = 0
                 CALL "GAME-EVENT-BY" USING WS-EV-DISMOUNT EN-MOUNT(L-ROW) L-ROW
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-MOUNT-GONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-STEP.
*> USING rider row (EN-MOUNT > 0), done out: one tick of a mob that rides a mob. The ride ends when the vehicle is gone (the row is free or holds another entity) or is dying;
*> done is then 0 and the rider carries on by itself. Otherwise the rider is put on the seat and done is 1: it burns in daylight, takes a target (STDMOB-AGGRO), shoots a bow
*> (STDMOB-SHOOT) or hits a target within the melee reach of the seat (the vehicle does the walking: MOB-MOUNT-DRIVE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DONE.
     MOVE 1 TO L-DONE
     MOVE EN-MOUNT(L-ROW) TO WS-V
     IF EN-USED(WS-V) = 0 OR EN-ID(WS-V) NOT = EN-MOUNT-ID(L-ROW) OR EN-HEALTH(WS-V) = 0
         CALL "MOB-MOUNT-DROP" USING L-ROW
         MOVE 0 TO L-DONE
         GOBACK
     END-IF
     CALL "MOB-MOUNT-PLACE" USING L-ROW
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF SM-KIND(WS-M) = 1
         IF SM-BURNS(WS-M) = 1
             CALL "STDMOB-BURN" USING L-ROW WS-M
         END-IF
         CALL "STDMOB-AGGRO" USING L-ROW WS-M
         IF EN-COOLDOWN(L-ROW) > 0
             SUBTRACT 1 FROM EN-COOLDOWN(L-ROW)
         END-IF
         MOVE EN-TARGET(L-ROW) TO WS-P
         IF SM-RANGED(WS-M) = 1 OR SM-RANGED(WS-M) = 2
             CALL "STDMOB-SHOOT" USING L-ROW WS-M WS-STOP
         END-IF
         IF WS-P > 0 AND SM-RANGED(WS-M) = 0 AND EN-COOLDOWN(L-ROW) = 0
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             COMPUTE WS-REACH = SM-REACH-MILLI / 1000
             IF FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH
                     AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
                 MOVE SM-ATTACK-TICKS TO EN-COOLDOWN(L-ROW)
                 CALL "STDMOB-ATTACK-DAMAGE" USING L-ROW WS-M WS-DAMAGE
                 IF WS-DAMAGE > 0
                     CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-MOUNT-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-MOUNT-DRIVE.
*> USING vehicle row (EN-PASS > 0), driven out: the vehicle of a mob rider (18 section 2.2: its own MOVE and LOOK goals are disabled). With the rider's target it walks to it at
*> its walk speed (STDMOB-HEAD); with none it stands. MOB-PHYSICS moves it. driven is 0 when the rider is gone or dying (the vehicle then acts by itself).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-VKEY                PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DRIVEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DRIVEN.
     MOVE 0 TO L-DRIVEN
     MOVE EN-PASS(L-ROW) TO WS-R
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-VKEY
     IF WS-VKEY = "strider"
         GOBACK
     END-IF
     IF EN-USED(WS-R) = 0 OR EN-MOUNT(WS-R) NOT = L-ROW OR EN-HEALTH(WS-R) = 0
         MOVE 0 TO EN-PASS(L-ROW)
         GOBACK
     END-IF
     MOVE 1 TO L-DRIVEN
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE 0 TO WS-HX WS-HZ
     MOVE EN-TARGET(WS-R) TO WS-P
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
         COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-P))
         COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-P))
         COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-P))
         CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ WS-HX WS-HZ WS-ARRIVED
     END-IF
     CALL "MOB-PHYSICS" USING L-ROW WS-HX WS-HZ WS-YAW
     GOBACK.
 END PROGRAM MOB-MOUNT-DRIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-JOCKEY-SPIDER.
*> USING xoro state, spider row (called by STDMOB-FINALIZE, the finalizeSpawn of a spider, 20 section 7.1): with probability 1/100 (nextInt(100) = 0) a skeleton is created at the
*> spider's position, finalized and made to ride it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-BOUND               BINARY-LONG VALUE 100.
 01 WS-DRAW                BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:skeleton".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     CALL "XORO-NEXT-INT" USING L-STATE WS-BOUND WS-DRAW
     IF WS-DRAW = 0
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE EN-YAW(L-ROW) TO WS-YAW
         CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-SKELETON
         CALL "STDMOB-FINALIZE" USING L-STATE WS-SKELETON
         CALL "MOB-MOUNT" USING WS-SKELETON L-ROW WS-MOUNTED
     END-IF
     GOBACK.
 END PROGRAM MOB-JOCKEY-SPIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-JOCKEY-ZOMBIE.
*> USING xoro state, baby zombie row (called by STDMOB-FINALIZE right after the baby roll, 20 section 4.1 step 2 and 44-x1 part 1): a first draw below 0.05 looks for an un-ridden
*> chicken within the box inflated by (5, 3, 5) around the zombie and rides the first one (a chicken jockey from then on: EN-JOCKEY); with none there nothing further happens (no second
*> draw). Only a first draw of 0.05 or more takes the second draw: below 0.05 a chicken is created at the zombie (yaw, pitch 0), finalized, marked as jockey and ridden.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-D                   FLOAT-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:chicken".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CHICKEN             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ZOMBIE              BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     MOVE L-ROW TO WS-ZOMBIE
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     IF WS-D < 0.05
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR WS-FOUND > 0
             IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND EN-DIM(WS-I) = EN-DIM(WS-ZOMBIE) AND EN-PASS(WS-I) = 0
                     AND EN-RIDER(WS-I) = 0 AND EN-MOUNT(WS-I) = 0 AND EN-HEALTH(WS-I) > 0
                 IF FUNCTION ABS(EN-X(WS-I) - EN-X(WS-ZOMBIE)) <= 5.5 AND FUNCTION ABS(EN-Z(WS-I) - EN-Z(WS-ZOMBIE)) <= 5.5
                         AND EN-Y(WS-I) >= EN-Y(WS-ZOMBIE) - 3.7 AND EN-Y(WS-I) <= EN-Y(WS-ZOMBIE) + 4.95
                     MOVE WS-I TO WS-FOUND
                 END-IF
             END-IF
         END-PERFORM
         IF WS-FOUND > 0
             MOVE 1 TO EN-JOCKEY(WS-FOUND)
             CALL "MOB-MOUNT" USING WS-ZOMBIE WS-FOUND WS-MOUNTED
         END-IF
     ELSE
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         IF WS-D < 0.05
             MOVE EN-X(WS-ZOMBIE) TO WS-X
             MOVE EN-Y(WS-ZOMBIE) TO WS-Y
             MOVE EN-Z(WS-ZOMBIE) TO WS-Z
             MOVE EN-YAW(WS-ZOMBIE) TO WS-YAW
             CALL "MOB-SPAWN" USING EN-DIM(WS-ZOMBIE) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-CHICKEN
             CALL "STDMOB-FINALIZE" USING L-STATE WS-CHICKEN
             MOVE 1 TO EN-JOCKEY(WS-CHICKEN)
             CALL "MOB-MOUNT" USING WS-ZOMBIE WS-CHICKEN WS-MOUNTED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-JOCKEY-ZOMBIE.
