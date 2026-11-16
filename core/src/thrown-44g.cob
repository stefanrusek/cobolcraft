*> The eye of ender item used in the air (docs/protocol/25 section 6.3 use, 21 section 8.12, 36-5 section 3.10; lane featsb7, T10000). THROWN-ITEM-USE hands an ender_eye to EYE-ITEM-USE:
*> the block ray of the look (reach 4.5, 5.0 in creative, fluids ignored) that ends on an end_portal_frame passes the item on (done 0: the use on the block handles it); otherwise
*> the stronghold locate (STRUCT-NEAREST-NAMED "stronghold" over the ring chunk list of the level seed, STRUCT-LOAD data and climate source as the world generation set them up) gives
*> the target (the locate position); none found leaves everything (CONSUME), else an eye_of_ender entity is made at (x, y + 0.9, z) of the player (EYE-SPAWN, signalTo, 4 in 5 survive) and a
*> survival stack loses one. Not done: the launch sound, the statistic and the used_ender_eye trigger.
*>
*>   EYE-ITEM-USE USING connection id, yaw, pitch (FLOAT-LONG), done out (0 = the item is passed on)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EYE-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-RYAW                FLOAT-LONG.
 01 WS-RPITCH              FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-IS                  BINARY-LONG.
 01 WS-HAS-EYE             BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-NAME                PIC X(40) VALUE "stronghold".
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CHX                 BINARY-LONG.
 01 WS-CHZ                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9101.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SURVIVES            BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-YAW L-PITCH L-DONE.
     MOVE 1 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
*>   the ray (fluid mode none: a cell with a fluid is passed through)
     MOVE 4.5 TO WS-REACH
     IF PL-MODE(WS-ROW) = 1
         MOVE 5.0 TO WS-REACH
     END-IF
     COMPUTE WS-EX = PL-X(WS-ROW)
     COMPUTE WS-EY = PL-Y(WS-ROW) + 1.62
     COMPUTE WS-EZ = PL-Z(WS-ROW)
     COMPUTE WS-RYAW = L-YAW * FUNCTION PI / 180
     COMPUTE WS-RPITCH = L-PITCH * FUNCTION PI / 180
     COMPUTE WS-DX = 0 - FUNCTION SIN(WS-RYAW) * FUNCTION COS(WS-RPITCH)
     COMPUTE WS-DY = 0 - FUNCTION SIN(WS-RPITCH)
     COMPUTE WS-DZ = FUNCTION COS(WS-RYAW) * FUNCTION COS(WS-RPITCH)
     MOVE 0 TO WS-HIT WS-T
     PERFORM UNTIL WS-T > WS-REACH OR WS-HIT = 1
         COMPUTE WS-CX = FUNCTION INTEGER(WS-EX + WS-DX * WS-T)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-EY + WS-DY * WS-T)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-EZ + WS-DZ * WS-T)
         CALL "FLUID-CELL" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
             WS-SOLID WS-HOLDS
         IF WS-STATE NOT = 0 AND WS-FLUID = 0
             MOVE 1 TO WS-HIT
         END-IF
         ADD 0.02 TO WS-T
     END-PERFORM
     IF WS-HIT = 1
         CALL "PORTAL-FRAME-INFO" USING WS-STATE WS-IS WS-HAS-EYE WS-FACING
         IF WS-IS = 1
             MOVE 0 TO L-DONE
             GOBACK
         END-IF
     END-IF
*>   the nearest stronghold of the level seed from the block position of the player
     COMPUTE WS-OX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-OY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-OZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME CW-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CHX WS-CHZ WS-LX WS-LY WS-LZ
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE PL-X(WS-ROW) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-ROW) + 0.9
     MOVE PL-Z(WS-ROW) TO WS-Z
     MOVE WS-LX TO WS-TX
     MOVE WS-LY TO WS-TY
     MOVE WS-LZ TO WS-TZ
     CALL "XP-RANDOM" USING WS-SALT WS-FIVE WS-DRAW
     MOVE 0 TO WS-SURVIVES
     IF WS-DRAW > 0
         MOVE 1 TO WS-SURVIVES
     END-IF
     CALL "EYE-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-TX WS-TY WS-TZ WS-SURVIVES PL-ENTITY-ID(WS-ROW) WS-NEW
     IF WS-NEW > 0
         CALL "MOB-TAKE" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM EYE-ITEM-USE.
