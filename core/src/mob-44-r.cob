*> Riding jump (002-lane-mobsa5; 05c 0x2A Player Command action 3 START_RIDING_JUMP, data = the strength 0 to 100; 19 section 3.1 jump, 54 sections 6.3 and 6.4).
*> - M44-HORSE-BORN USING row: a new horse's jump strength attribute, 0.4 + 0.2 (r1 + r2 + r3) (M19-GENE-JUMP; the health and speed genes of 3.2 are not drawn: gap). Not saved (gap).
*> - M44-RIDING-JUMP USING player row, strength, jumped out: the mount of the player (EN-VEHICLE of the player's entity): a camel dashes (M44-CAMEL-RIDER-JUMP); a saddled horse, donkey, mule,
*>   skeleton horse or zombie horse on the ground jumps: vertical speed jump strength x scale (0.4 + 0.4 p / 90 below 90, 1.0 from 90 up, M19-HORSE-JUMP-SCALE) and the forward impulse
*>   0.4 x scale along the mount's yaw added to its motion. A strength of 0 or less does nothing. A horse without a drawn strength (EN-HORSE-JUMP 0: a donkey, mule, undead horse or a loaded
*>   horse) jumps with 0.7, the middle of the gene range (gap: donkey, mule and the undead horses have their own formulas that are not stored).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-HORSE-BORN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 160.
 01 WS-BOUND               BINARY-LONG VALUE 10000.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-R3                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D1
     ADD 1 TO WS-SALT
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D2
     ADD 1 TO WS-SALT
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D3
     SUBTRACT 2 FROM WS-SALT
     COMPUTE WS-R1 = WS-D1 / 10000
     COMPUTE WS-R2 = WS-D2 / 10000
     COMPUTE WS-R3 = WS-D3 / 10000
     CALL "M19-GENE-JUMP" USING WS-R1 WS-R2 WS-R3 EN-HORSE-JUMP(L-ROW)
     GOBACK.
 END PROGRAM M44-HORSE-BORN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RIDING-JUMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-MOB                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-SCALE               BINARY-LONG.
 01 WS-JUMP                FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-JUMPED               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-STRENGTH L-JUMPED.
     MOVE 0 TO L-JUMPED
     MOVE EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) TO WS-MOB
     IF WS-MOB > 0 AND L-STRENGTH > 0
         CALL "MOB-SPECIES-KEY" USING WS-MOB WS-KEY
         EVALUATE WS-KEY
             WHEN "camel" WHEN "camel_husk"
                 CALL "M44-CAMEL-RIDER-JUMP" USING WS-MOB L-STRENGTH L-JUMPED
             WHEN "nautilus" WHEN "zombie_nautilus"
                 CALL "NAUTILUS-RIDER-JUMP" USING WS-MOB L-JUMPED
             WHEN "horse" WHEN "donkey" WHEN "mule" WHEN "skeleton_horse" WHEN "zombie_horse"
                 IF EN-SADDLE(WS-MOB) = 1 AND EN-ON-GROUND(WS-MOB) = 1
                     CALL "M19-HORSE-JUMP-SCALE" USING L-STRENGTH WS-SCALE
                     MOVE 0.7 TO WS-JUMP
                     IF EN-HORSE-JUMP(WS-MOB) > 0
                         MOVE EN-HORSE-JUMP(WS-MOB) TO WS-JUMP
                     END-IF
                     COMPUTE WS-S = WS-SCALE / 1000
                     COMPUTE WS-RADIANS = EN-YAW(WS-MOB) * FUNCTION PI / 180
                     COMPUTE EN-VY(WS-MOB) = WS-JUMP * WS-S
                     COMPUTE EN-VX(WS-MOB) = EN-VX(WS-MOB) - 0.4 * FUNCTION SIN(WS-RADIANS) * WS-S
                     COMPUTE EN-VZ(WS-MOB) = EN-VZ(WS-MOB) + 0.4 * FUNCTION COS(WS-RADIANS) * WS-S
                     MOVE 0 TO EN-ON-GROUND(WS-MOB)
                     MOVE 1 TO L-JUMPED
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM M44-RIDING-JUMP.
