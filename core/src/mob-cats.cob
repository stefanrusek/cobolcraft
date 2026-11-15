*> Cat and ocelot goals (docs/protocol/19-mobs-land-friendly-and-neutral.md sections 5.1 and 5.2; 18 section 4.2 TemptGoal, AvoidEntityGoal, FollowOwnerGoal;
*> lane 002-lane-mobsfull-h25). One tick of the movement goals of a cat or an ocelot, in the priority order of the goal lists: SitWhenOrdered, Tempt, the
*> avoid-player goal of an ocelot that does not trust, FollowOwner(1.0, 10.0, 5.0) of a tame cat.
*> Open items (T2351, T2353): the beg sound, the tempt goal's scare-off (needs the player's last position: no float field is added), the offhand slot as a tempt item,
*> CatRelaxOnOwner and the morning gift (no sleeping state for players), CatLieOnBlock and CatSitOnBlock, CatSpawner, the rabbit, chicken and turtle targets, the
*> despawn of an untamed cat or an untrusting ocelot after 2400 ticks, cat breeding and variants.
*>   CAT-FOLLOW USING squared distance to the owner, moving, action out      FollowOwnerGoal(1.0, 10.0, 5.0): 2 teleport, 1 walk, 3 stop, 0 nothing
*>   CAT-TEMPT USING row, player row out                                     the nearest player within 10 blocks holding raw cod or salmon (0 none)
*>   CAT-AVOID USING row, player row out, squared distance out               the nearest player within 16 blocks (3 vertically) other than a spectator (0 none)
*>   CAT-TICK USING row, hx out, hz out, walk out                            walk 1: hx, hz are the walk of this tick; 2: stand still; 0: the other goals

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-FOLLOW.
*> USING squared distance to the owner (FLOAT-LONG), moving (BINARY-LONG: 1 while it walks to the owner), action out (BINARY-LONG): as M188-FOLLOW with the
*> stop distance 5.0 of the cat: 2 teleport at 12 blocks or more, 1 walk (start farther than 10 blocks, or keep walking beyond 5), 3 stop, 0 nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-MOVING               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-MOVING L-ACTION.
     CALL "M188-OWNER-FAR" USING L-D2 WS-FAR
     EVALUATE TRUE
         WHEN WS-FAR = 1
             MOVE 2 TO L-ACTION
         WHEN L-MOVING = 0 AND L-D2 > 100
             MOVE 1 TO L-ACTION
         WHEN L-MOVING = 1 AND L-D2 > 25
             MOVE 1 TO L-ACTION
         WHEN L-MOVING = 1
             MOVE 3 TO L-ACTION
         WHEN OTHER
             MOVE 0 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM CAT-FOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-TEMPT.
*> USING row, player row out: TemptGoal(0.6, cat_food) range 10: the nearest alive player of the mob's dimension, not a spectator, within 10 blocks and holding raw cod or
*> raw salmon in the main hand (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     MOVE 0 TO L-PLAYER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-SLOT = PL-HELD(WS-P) + 1
             MOVE SPACES TO WS-BARE
             IF PL-SLOT-COUNT(WS-P, WS-SLOT) > 0
                 MOVE IT-KEY(PL-SLOT-ITEM(WS-P, WS-SLOT) + 1) TO WS-KEY
                 CALL "KEY-BARE" USING WS-KEY WS-BARE
             END-IF
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF (WS-BARE = "cod" OR "salmon") AND WS-D2 <= 100 AND (L-PLAYER = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE WS-P TO L-PLAYER
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CAT-TEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-AVOID.
*> USING row, player row out, squared distance out (FLOAT-LONG): AvoidEntityGoal(Player, 16.0): the nearest alive player of the mob's dimension, not a spectator, within 16
*> blocks and 3 vertically (0 when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-D2.
     MOVE 0 TO L-PLAYER L-D2
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-DY = FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW))
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2 + WS-DY ** 2
             IF WS-D2 <= 256 AND WS-DY <= 3 AND (L-PLAYER = 0 OR WS-D2 < L-D2)
                 MOVE WS-P TO L-PLAYER
                 MOVE WS-D2 TO L-D2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CAT-AVOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAT-TICK.
*> USING row, hx out, hz out, walk out: one tick of the goals above. SitWhenOrdered (a tame cat ordered to sit: walk 2); Tempt (walk to the player holding cod at speed 0.6
*> instead of the stroll's 0.8, standing within 2.5 blocks; when the goal stops EN-PET-CD counts a 100-tick cooldown, EN-PET-MOVING 2 marks a running tempt); the
*> ocelot that does not trust walks away from the nearest player (0.8, sprinting at 1.33 within 7 blocks); a tame cat follows its owner (CAT-FOLLOW).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     IF EN-TAMED(L-ROW) = 1 AND EN-SIT(L-ROW) = 1
         MOVE 0 TO EN-PET-MOVING(L-ROW)
         MOVE 2 TO L-WALK
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF EN-PET-CD(L-ROW) > 0 AND EN-PET-MOVING(L-ROW) NOT = 2
         SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     END-IF
     MOVE 0 TO WS-PLAYER
     IF EN-PET-CD(L-ROW) = 0
         CALL "CAT-TEMPT" USING L-ROW WS-PLAYER
     END-IF
     IF WS-PLAYER > 0
         MOVE 2 TO EN-PET-MOVING(L-ROW)
         COMPUTE WS-D2 = (PL-X(WS-PLAYER) - EN-X(L-ROW)) ** 2 + (PL-Z(WS-PLAYER) - EN-Z(L-ROW)) ** 2
         IF WS-D2 < 6.25
             MOVE 2 TO L-WALK
         ELSE
             MOVE 1 TO L-WALK
             COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-PLAYER))
             COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
             COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
             COMPUTE L-HX = L-HX * 0.5625
             COMPUTE L-HZ = L-HZ * 0.5625
         END-IF
         GOBACK
     END-IF
     IF EN-PET-MOVING(L-ROW) = 2
         MOVE 100 TO EN-PET-CD(L-ROW)
         MOVE 0 TO EN-PET-MOVING(L-ROW)
     END-IF
     IF SM-KEY(WS-M) = "ocelot" AND EN-TAMED(L-ROW) = 0
         CALL "CAT-AVOID" USING L-ROW WS-PLAYER WS-D2
         IF WS-PLAYER > 0
             COMPUTE WS-DX = EN-X(L-ROW) - PL-X(WS-PLAYER)
             COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(WS-PLAYER)
             CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
             COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
             IF WS-D2 <= 49
                 COMPUTE WS-SPEED = WS-SPEED * 2.7639
             END-IF
             COMPUTE WS-RADIANS = WS-YAW * FUNCTION PI / 180
             COMPUTE L-HX = - FUNCTION SIN(WS-RADIANS) * WS-SPEED
             COMPUTE L-HZ = FUNCTION COS(WS-RADIANS) * WS-SPEED
             MOVE 1 TO L-WALK
             GOBACK
         END-IF
     END-IF
     IF EN-TAMED(L-ROW) = 1 AND SM-KEY(WS-M) = "cat"
         CALL "PET-OWNER" USING L-ROW WS-OWNER
         IF WS-OWNER = 0
             MOVE 0 TO EN-PET-MOVING(L-ROW)
             GOBACK
         END-IF
         COMPUTE WS-D2 = (PL-X(WS-OWNER) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-OWNER) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-OWNER) - EN-Z(L-ROW)) ** 2
         CALL "CAT-FOLLOW" USING WS-D2 EN-PET-MOVING(L-ROW) WS-ACTION
         EVALUATE WS-ACTION
             WHEN 2
                 MOVE 0 TO EN-PET-MOVING(L-ROW)
                 MOVE EN-YAW(L-ROW) TO WS-YAW
                 MOVE EN-PITCH(L-ROW) TO WS-PITCH
                 CALL "ENTITY-MOVE" USING L-ROW PL-X(WS-OWNER) PL-Y(WS-OWNER) PL-Z(WS-OWNER) WS-YAW WS-PITCH WS-GROUND
             WHEN 1
                 MOVE 1 TO EN-PET-MOVING(L-ROW)
                 MOVE 1 TO L-WALK
                 COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-OWNER))
                 COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-OWNER))
                 COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-OWNER))
                 CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
             WHEN OTHER
                 MOVE 0 TO EN-PET-MOVING(L-ROW)
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM CAT-TICK.
