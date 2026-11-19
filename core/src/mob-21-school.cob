*> Schooling fish (docs/protocol/21 section 4.1 and 4.1.1, AbstractSchoolingFish and FollowFlockLeaderGoal; lane p49t, T39100): cod, salmon and tropical fish. State per fish in its tracker row: EN-SCH-LEADER
*> (the entity id of its leader, 0 none), EN-SCH-FOLLOWERS (schoolSize is 1 + this), EN-SCH-NEXT (nextStartTick), EN-SCH-ROLLED (the constructor's roll of 200 + nextInt(200) mod 20, made at the first goal
*> tick) and EN-SCH-PATH (timeToRecalcPath). The random draws are the hash of xp.cob (XP-RANDOM), not the fish's own or the level's random.
*>
*>   FISH-SCHOOL-MAX USING species key (PIC X(24)), max school size out (0 a fish that does not school: cod and tropical fish 8, salmon 5)
*>   FISH-SCHOOL-SIZE USING row, size out                  1 + followers
*>   FISH-LEADER-ROW USING row, leader row out              the row of the living leader of a follower, 0 when it has none or it died (isFollower)
*>   FISH-FOLLOW USING follower row, leader row             startFollowing
*>   FISH-UNFOLLOW USING follower row                       stopFollowing
*>   FISH-PACK-JOIN USING first row of the group, new row   finalizeSpawn: the first fish leads, every later one follows it
*>   FISH-SCHOOL-STEP USING row, following out              one tick: the leader's housekeeping, then the goal; following 1 when the fish heads for its leader (EN-DEST-X, -Y, -Z, EN-COOLDOWN set)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-SCHOOL-MAX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MAX.
     MOVE 0 TO L-MAX
     EVALUATE L-KEY
         WHEN "cod" WHEN "tropical_fish"
             MOVE 8 TO L-MAX
         WHEN "salmon"
             MOVE 5 TO L-MAX
     END-EVALUATE
     GOBACK.
 END PROGRAM FISH-SCHOOL-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-SCHOOL-SIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SIZE.
     COMPUTE L-SIZE = 1 + EN-SCH-FOLLOWERS(L-ROW)
     GOBACK.
 END PROGRAM FISH-SCHOOL-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-FIND-ID.
*> USING entity id, row out (0 when no used row has it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW.
     MOVE 0 TO L-ROW
     IF L-ID > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ROW > 0
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = L-ID
                 MOVE WS-E TO L-ROW
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FISH-FIND-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-LEADER-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEADER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEADER.
     CALL "FISH-FIND-ID" USING EN-SCH-LEADER(L-ROW) L-LEADER
     IF L-LEADER > 0
         IF EN-HEALTH(L-LEADER) = 0
             MOVE 0 TO L-LEADER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FISH-LEADER-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-FOLLOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LEADER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LEADER.
     MOVE EN-ID(L-LEADER) TO EN-SCH-LEADER(L-ROW)
     ADD 1 TO EN-SCH-FOLLOWERS(L-LEADER)
     GOBACK.
 END PROGRAM FISH-FOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-UNFOLLOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEADER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "FISH-FIND-ID" USING EN-SCH-LEADER(L-ROW) WS-LEADER
     IF WS-LEADER > 0 AND EN-SCH-FOLLOWERS(WS-LEADER) > 0
         SUBTRACT 1 FROM EN-SCH-FOLLOWERS(WS-LEADER)
     END-IF
     MOVE 0 TO EN-SCH-LEADER(L-ROW)
     GOBACK.
 END PROGRAM FISH-UNFOLLOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-PACK-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24).
 01 WS-MAX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-NEW.
     CALL "MOB-SPECIES-KEY" USING L-NEW WS-KEY
     CALL "FISH-SCHOOL-MAX" USING WS-KEY WS-MAX
     IF WS-MAX > 0 AND L-NEW NOT = L-FIRST
         CALL "FISH-FOLLOW" USING L-NEW L-FIRST
     END-IF
     GOBACK.
 END PROGRAM FISH-PACK-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-NEAR.
*> USING row, other row, near out: 1 when the box of the other fish touches the box of the first inflated by 8 on every axis.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-HALF                FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HEIGHT-A            FLOAT-LONG.
 01 WS-HEIGHT-B            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-NEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OTHER L-NEAR.
     MOVE 0 TO L-NEAR
     COMPUTE WS-HALF = (ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) + ET-WIDTH-MILLI(EN-TYPE(L-OTHER) + 1)) / 2000
     COMPUTE WS-HEIGHT-A = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     COMPUTE WS-HEIGHT-B = ET-HEIGHT-MILLI(EN-TYPE(L-OTHER) + 1) / 1000
     COMPUTE WS-DX = FUNCTION ABS(EN-X(L-OTHER) - EN-X(L-ROW))
     COMPUTE WS-DZ = FUNCTION ABS(EN-Z(L-OTHER) - EN-Z(L-ROW))
     IF WS-DX <= 8 + WS-HALF AND WS-DZ <= 8 + WS-HALF AND EN-Y(L-OTHER) <= EN-Y(L-ROW) + WS-HEIGHT-A + 8
             AND EN-Y(L-OTHER) + WS-HEIGHT-B >= EN-Y(L-ROW) - 8
         MOVE 1 TO L-NEAR
     END-IF
     GOBACK.
 END PROGRAM FISH-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FISH-SCHOOL-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-KEY                 PIC X(24).
 01 WS-MAX                 BINARY-LONG.
 01 WS-SALT-OWN            BINARY-LONG VALUE 9661.
 01 WS-SALT-LEVEL          BINARY-LONG VALUE 9662.
 01 WS-200                 BINARY-LONG VALUE 200.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LEADER              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FOLLOWER            BINARY-LONG.
 01 WS-OWN-LEADER          BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOLLOW               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOLLOW.
     MOVE 0 TO L-FOLLOW
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     CALL "FISH-SCHOOL-MAX" USING WS-KEY WS-MAX
     IF WS-MAX = 0
         GOBACK
     END-IF
*>   Leader housekeeping (every tick): with followers and nextInt(200) = 1, a box with no other fish of the class dissolves the school.
     IF EN-SCH-FOLLOWERS(L-ROW) > 0
         CALL "XP-RANDOM" USING WS-SALT-LEVEL WS-200 WS-DRAW
         IF WS-DRAW = 1
             MOVE 0 TO WS-COUNT
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-TYPE(WS-E) = EN-TYPE(L-ROW) AND EN-HEALTH(WS-E) > 0
                     CALL "FISH-NEAR" USING L-ROW WS-E WS-NEAR
                     IF WS-NEAR = 1
                         ADD 1 TO WS-COUNT
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-COUNT <= 1
                 MOVE 0 TO EN-SCH-FOLLOWERS(L-ROW)
             END-IF
         END-IF
         GOBACK
     END-IF
     CALL "FISH-LEADER-ROW" USING L-ROW WS-LEADER
     IF WS-LEADER = 0
         IF EN-SCH-ROLLED(L-ROW) = 0
             CALL "XP-RANDOM" USING WS-SALT-OWN WS-200 WS-DRAW
             COMPUTE EN-SCH-NEXT(L-ROW) = 200 + FUNCTION MOD(WS-DRAW, 20)
             MOVE 1 TO EN-SCH-ROLLED(L-ROW)
         END-IF
         IF EN-SCH-NEXT(L-ROW) > 0
             SUBTRACT 1 FROM EN-SCH-NEXT(L-ROW)
             GOBACK
         END-IF
         CALL "XP-RANDOM" USING WS-SALT-OWN WS-200 WS-DRAW
         COMPUTE EN-SCH-NEXT(L-ROW) = 200 + FUNCTION MOD(WS-DRAW, 20)
*>       The search: every fish of the class in the inflated box that can be followed or is not a follower, in row order.
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-COUNT >= 64
             IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-TYPE(WS-E) = EN-TYPE(L-ROW) AND EN-HEALTH(WS-E) > 0
                 CALL "FISH-NEAR" USING L-ROW WS-E WS-NEAR
                 CALL "FISH-LEADER-ROW" USING WS-E WS-OWN-LEADER
                 IF WS-NEAR = 1 AND (WS-OWN-LEADER = 0 OR (EN-SCH-FOLLOWERS(WS-E) > 0 AND EN-SCH-FOLLOWERS(WS-E) + 1 < WS-MAX))
                     ADD 1 TO WS-COUNT
                     MOVE WS-E TO WS-L(WS-COUNT)
                 END-IF
             END-IF
         END-PERFORM
*>       The leader: the first that can be followed (hasFollowers and schoolSize below the maximum), else the fish itself.
         MOVE L-ROW TO WS-PICK
         PERFORM VARYING WS-I FROM WS-COUNT BY -1 UNTIL WS-I < 1
             IF EN-SCH-FOLLOWERS(WS-L(WS-I)) > 0 AND EN-SCH-FOLLOWERS(WS-L(WS-I)) + 1 < WS-MAX
                 MOVE WS-L(WS-I) TO WS-PICK
             END-IF
         END-PERFORM
*>       addFollowers: keep the non-followers, limit(N) with N = max - schoolSize, then skip the leader, then startFollowing.
         COMPUTE WS-LIMIT = WS-MAX - (1 + EN-SCH-FOLLOWERS(WS-PICK))
         MOVE 0 TO WS-TAKEN
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-TAKEN >= WS-LIMIT
             MOVE WS-L(WS-I) TO WS-FOLLOWER
             CALL "FISH-LEADER-ROW" USING WS-FOLLOWER WS-OWN-LEADER
             IF WS-OWN-LEADER = 0
                 ADD 1 TO WS-TAKEN
                 IF WS-FOLLOWER NOT = WS-PICK
                     CALL "FISH-FOLLOW" USING WS-FOLLOWER WS-PICK
                 END-IF
             END-IF
         END-PERFORM
         CALL "FISH-LEADER-ROW" USING L-ROW WS-LEADER
         IF WS-LEADER = 0
             GOBACK
         END-IF
         MOVE 0 TO EN-SCH-PATH(L-ROW)
     END-IF
*>   A follower: canContinueToUse needs the leader within squared distance 121, else stopFollowing.
     COMPUTE WS-DX = EN-X(WS-LEADER) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(WS-LEADER) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-LEADER) - EN-Z(L-ROW)
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ > 121
         CALL "FISH-UNFOLLOW" USING L-ROW
         GOBACK
     END-IF
     MOVE 1 TO L-FOLLOW
     SUBTRACT 1 FROM EN-SCH-PATH(L-ROW)
     IF EN-SCH-PATH(L-ROW) <= 0
         MOVE 5 TO EN-SCH-PATH(L-ROW)
         COMPUTE EN-DEST-X(L-ROW) = FUNCTION INTEGER(EN-X(WS-LEADER))
         COMPUTE EN-DEST-Y(L-ROW) = FUNCTION INTEGER(EN-Y(WS-LEADER))
         COMPUTE EN-DEST-Z(L-ROW) = FUNCTION INTEGER(EN-Z(WS-LEADER))
         MOVE SM-STROLL-TICKS TO EN-COOLDOWN(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM FISH-SCHOOL-STEP.
