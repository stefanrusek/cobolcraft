*> Experience (002-lane-mobs2, T4100; docs/protocol/17 section 4.10, 18 section 7.5, 21 section 8.2, 41 section 4, 05b 0x69).
*> A player holds a level, the points into that level and the total (PL-XP-*). An orb is a tracker row of the standard entity type
*> experience_orb (found by key, once): EN-ITEM its value, EN-ITEM-COUNT its count (how many orbs of that value it stands for),
*> EN-AGE its age, EN-COOLDOWN its tick count, EN-VX to EN-VZ its velocity; EN-WAY-X, EN-FLEE-X and EN-WAY-Z hold the position the viewers
*> were last told. Water and lava effects, Mending and slippery blocks are not done yet (open, see tasks T4100).
*>
*> Entry points:
*>   XP-NEEDED USING level, points out                  points to go from the level to the next (17 section 4.10)
*>   XP-GIVE USING player row, points                   adds points (levels, Set Experience to the player)
*>   XP-ORB-VALUE USING total, value out                the largest orb tier not above the total (21 section 8.2)
*>   XP-ORB-TYPE USING type id out                      the entity type id of experience_orb, 0 outside a standard world
*>   XP-ORB-SPAWN USING dim, x, y, z, value, row out    a new orb with the random spawn velocity
*>   XP-AWARD USING dim, x, y, z, total                 ExperienceOrb.award: split into orbs, merging into a near orb of the same value
*>   XP-ORBS-TICK                                       the pickup of the players, then every orb's tick

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-EXPERIENCE-BUILD.
*> USING progress (FLOAT-SHORT), level, total (BINARY-LONG), PB-BUFFER: Set Experience 0x69 (05b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 105.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PROGRESS             FLOAT-SHORT.
 01 L-LEVEL                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-PROGRESS L-LEVEL L-TOTAL PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PROGRESS
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-LEVEL
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TOTAL
     GOBACK.
 END PROGRAM SET-EXPERIENCE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-ENTITY-DATA-ORB-BUILD.
*> USING entity id, value (BINARY-LONG), PB-BUFFER: Set Entity Data 0x65 of an orb: entry 8 (the value), serializer INT (21 section 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-VALUE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 8 TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE L-VALUE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM SET-ENTITY-DATA-ORB-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-NEEDED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-NEEDED.
     EVALUATE TRUE
         WHEN L-LEVEL < 15
             COMPUTE L-NEEDED = 7 + 2 * L-LEVEL
         WHEN L-LEVEL < 30
             COMPUTE L-NEEDED = 37 + 5 * (L-LEVEL - 15)
         WHEN OTHER
             COMPUTE L-NEEDED = 112 + 9 * (L-LEVEL - 30)
     END-EVALUATE
     GOBACK.
 END PROGRAM XP-NEEDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-GIVE.
*> USING player row, points (BINARY-LONG, 0 or more): the total grows (capped at the int range), the points fill the level and overflow
*> into the next ones; the player is sent Set Experience (progress = points / needed, level, total).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-LEFT                BINARY-DOUBLE.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-PROGRESS            FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-POINTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-POINTS.
     COMPUTE WS-TOTAL = PL-XP-TOTAL(L-PLAYER) + L-POINTS
     IF WS-TOTAL > 2147483647
         MOVE 2147483647 TO WS-TOTAL
     END-IF
     MOVE WS-TOTAL TO PL-XP-TOTAL(L-PLAYER)
     COMPUTE WS-LEFT = PL-XP-POINTS(L-PLAYER) + L-POINTS
     CALL "XP-NEEDED" USING PL-XP-LEVEL(L-PLAYER) WS-NEEDED
     PERFORM UNTIL WS-LEFT < WS-NEEDED
         SUBTRACT WS-NEEDED FROM WS-LEFT
         ADD 1 TO PL-XP-LEVEL(L-PLAYER)
         CALL "XP-NEEDED" USING PL-XP-LEVEL(L-PLAYER) WS-NEEDED
     END-PERFORM
     MOVE WS-LEFT TO PL-XP-POINTS(L-PLAYER)
     COMPUTE WS-PROGRESS = PL-XP-POINTS(L-PLAYER) / WS-NEEDED
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "SET-EXPERIENCE-BUILD" USING WS-PROGRESS PL-XP-LEVEL(L-PLAYER) PL-XP-TOTAL(L-PLAYER) PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM XP-GIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORB-VALUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 XP-TIER-DATA.
    05 FILLER BINARY-LONG VALUE 2477.
    05 FILLER BINARY-LONG VALUE 1237.
    05 FILLER BINARY-LONG VALUE 617.
    05 FILLER BINARY-LONG VALUE 307.
    05 FILLER BINARY-LONG VALUE 149.
    05 FILLER BINARY-LONG VALUE 73.
    05 FILLER BINARY-LONG VALUE 37.
    05 FILLER BINARY-LONG VALUE 17.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 3.
 01 XP-TIER-TABLE REDEFINES XP-TIER-DATA.
    05 XP-TIER             BINARY-LONG OCCURS 10 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-VALUE.
     MOVE 1 TO L-VALUE
     PERFORM VARYING WS-I FROM 10 BY -1 UNTIL WS-I < 1
         IF L-TOTAL >= XP-TIER(WS-I)
             MOVE XP-TIER(WS-I) TO L-VALUE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM XP-ORB-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORB-TYPE.
*> USING type id out: the id of minecraft:experience_orb in the open standard set (found once), 0 in any other world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:experience_orb".
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-LOADED              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE.
     MOVE 0 TO L-TYPE
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     IF WS-LOADED = 0
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         MOVE 1 TO WS-LOADED
     END-IF
     MOVE WS-ID TO L-TYPE
     GOBACK.
 END PROGRAM XP-ORB-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-RANDOM.
*> USING salt, bound, result out (all BINARY-LONG): a deterministic draw 0 to bound - 1 from the hash of the tick, a running count and the salt.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-SEQ                 BINARY-DOUBLE VALUE 0.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SALT                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SALT L-BOUND L-RESULT.
     ADD 1 TO WS-SEQ
     MOVE CW-TICKS TO WS-ARG(1)
     MOVE WS-SEQ TO WS-ARG(2)
     MOVE L-SALT TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-H
     COMPUTE L-RESULT = FUNCTION MOD(WS-H, L-BOUND)
     GOBACK.
 END PROGRAM XP-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORB-SPAWN.
*> USING dim, x, y, z (FLOAT-LONG), value (BINARY-LONG), row out: a new orb (21 section 8.2): count 1, age 0, a random yaw and the spawn
*> velocity ((r x 0.2 - 0.1) x 2, r x 0.2 x 2, (r x 0.2 - 0.1) x 2); it enters the tracker.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 1.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VALUE L-ROW.
     CALL "XP-ORB-TYPE" USING WS-TYPE
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW) EN-WAY-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW) EN-FLEE-X(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW) EN-WAY-Z(WS-ROW)
     MOVE L-VALUE TO EN-ITEM(WS-ROW)
     MOVE 1 TO EN-ITEM-COUNT(WS-ROW)
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE EN-YAW(WS-ROW) = WS-R * 360 / 1000
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE EN-VX(WS-ROW) = (WS-R / 1000 * 0.2 - 0.1) * 2
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE EN-VY(WS-ROW) = WS-R / 1000 * 0.2 * 2
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE EN-VZ(WS-ROW) = (WS-R / 1000 * 0.2 - 0.1) * 2
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM XP-ORB-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-AWARD.
*> USING dim, x, y, z (FLOAT-LONG), total (BINARY-LONG): ExperienceOrb.award (18 section 7.5): while points remain, v is the largest tier not above
*> them; a draw r of 0 to 39 is made and an orb of value v within 0.5 of the position on every axis whose id minus r is a multiple of 40 takes
*> the piece (count + 1, age 0); otherwise a new orb of value v is spawned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEFT                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 40.
 01 WS-SALT                BINARY-LONG VALUE 2.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TOTAL.
     CALL "XP-ORB-TYPE" USING WS-TYPE
     MOVE L-TOTAL TO WS-LEFT
     PERFORM UNTIL WS-LEFT <= 0
         CALL "XP-ORB-VALUE" USING WS-LEFT WS-V
         SUBTRACT WS-V FROM WS-LEFT
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
             IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = L-DIM AND EN-ITEM(WS-E) = WS-V
                     AND FUNCTION MOD(EN-ID(WS-E) - WS-R, 40) = 0
                     AND FUNCTION ABS(EN-X(WS-E) - L-X) < 0.5 AND FUNCTION ABS(EN-Y(WS-E) - L-Y) < 0.5
                     AND FUNCTION ABS(EN-Z(WS-E) - L-Z) < 0.5
                 ADD 1 TO EN-ITEM-COUNT(WS-E)
                 MOVE 0 TO EN-AGE(WS-E)
                 MOVE 1 TO WS-DONE
             END-IF
         END-PERFORM
         IF WS-DONE = 0
             CALL "XP-ORB-SPAWN" USING L-DIM L-X L-Y L-Z WS-V WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM XP-AWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORB-MOVE.
*> USING tracker row of an orb: gravity 0.03, the pull toward the nearest player within 8 blocks, the move against solid cells (the floor
*> stops it, a wall cancels that horizontal part), drag 0.98 (times 0.6 on the ground) and the bounce (21 section 8.2). The viewers are
*> sent Teleport Entity when the position moved by the wire resolution.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.03.
 01 WS-STEP                FLOAT-LONG VALUE 0.000122.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D              FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-OLD-VY              FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-LANDED              BINARY-LONG.
 01 WS-DRAG                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - WS-GRAVITY
*>   The pull: the nearest living, non-spectator player within 8 blocks, aimed at the player's middle (feet + 0.81).
     MOVE 0 TO WS-BEST
     MOVE 64 TO WS-BEST-D
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 AND PL-MODE(WS-P) < 3
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) + 0.81 - EN-Y(L-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
             COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D < WS-BEST-D
                 MOVE WS-D TO WS-BEST-D
                 MOVE WS-P TO WS-BEST
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         COMPUTE WS-DX = PL-X(WS-BEST) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-BEST) + 0.81 - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-BEST) - EN-Z(L-ROW)
         COMPUTE WS-D = FUNCTION SQRT(WS-BEST-D)
         IF WS-D > 0
             COMPUTE WS-F = 1 - WS-D / 8
             COMPUTE WS-F = WS-F * WS-F * 0.1 / WS-D
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-DX * WS-F
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-DY * WS-F
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-DZ * WS-F
         END-IF
     END-IF
*>   The move. Horizontal first: a solid cell at the new place at the orb's middle height cancels that axis.
     MOVE EN-VY(L-ROW) TO WS-OLD-VY
     COMPUTE WS-NX = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-NZ = EN-Z(L-ROW) + EN-VZ(L-ROW)
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW) + 0.25)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-NX)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
     IF WS-SOLID = 1
         MOVE EN-X(L-ROW) TO WS-NX
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(WS-NX)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-NZ)
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
     IF WS-SOLID = 1
         MOVE EN-Z(L-ROW) TO WS-NZ
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
*>   Vertical: the floor below the feet stops a fall (and rests the orb on it), a ceiling above the head stops a rise.
     COMPUTE WS-NY = EN-Y(L-ROW) + EN-VY(L-ROW)
     MOVE 0 TO WS-LANDED
     COMPUTE WS-CX = FUNCTION INTEGER(WS-NX)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-NZ)
     IF EN-VY(L-ROW) < 0
         COMPUTE WS-CY = FUNCTION INTEGER(WS-NY)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             COMPUTE WS-NY = WS-CY + 1
             MOVE 1 TO WS-LANDED
             MOVE 0 TO EN-VY(L-ROW)
         END-IF
     ELSE
         COMPUTE WS-CY = FUNCTION INTEGER(WS-NY + 0.5)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE EN-Y(L-ROW) TO WS-NY
             MOVE 0 TO EN-VY(L-ROW)
         END-IF
     END-IF
     MOVE WS-LANDED TO EN-ON-GROUND(L-ROW)
*>   Drag: 0.98 in the air, 0.98 x 0.6 along the ground; a landing faster than gravity rebounds at 0.4 of its speed.
     MOVE 0.98 TO WS-DRAG
     IF WS-LANDED = 1
         COMPUTE WS-DRAG = 0.98 * 0.6
         IF WS-OLD-VY < -0.03
             COMPUTE EN-VY(L-ROW) = 0 - WS-OLD-VY * 0.4
         END-IF
     END-IF
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * WS-DRAG
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * WS-DRAG
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.98
     MOVE WS-NX TO EN-X(L-ROW)
     MOVE WS-NY TO EN-Y(L-ROW)
     MOVE WS-NZ TO EN-Z(L-ROW)
     IF FUNCTION ABS(WS-NX - EN-WAY-X(L-ROW)) >= WS-STEP OR FUNCTION ABS(WS-NY - EN-FLEE-X(L-ROW)) >= WS-STEP
             OR FUNCTION ABS(WS-NZ - EN-WAY-Z(L-ROW)) >= WS-STEP
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(L-ROW) WS-NX WS-NY WS-NZ EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
             EN-YAW(L-ROW) EN-PITCH(L-ROW) EN-ON-GROUND(L-ROW) PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
         MOVE WS-NX TO EN-WAY-X(L-ROW)
         MOVE WS-NY TO EN-FLEE-X(L-ROW)
         MOVE WS-NZ TO EN-WAY-Z(L-ROW)
         CALL "ENTITY-TRACK" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM XP-ORB-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORB-STEP.
*> USING tracker row of an orb in a loaded chunk: one tick (21 section 8.2): the tick count, the merge scan on tick count mod 20 = 1 (orbs of the
*> same value whose ids differ by a multiple of 40 within 1.0 on each axis join this one: counts add, the smaller age stays), the move
*> (XP-ORB-MOVE), the age, and the end of life at age 6000.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     ADD 1 TO EN-COOLDOWN(L-ROW)
     IF FUNCTION MOD(EN-COOLDOWN(L-ROW), 20) = 1
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = EN-TYPE(L-ROW) AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                     AND EN-ITEM(WS-E) = EN-ITEM(L-ROW) AND FUNCTION MOD(EN-ID(WS-E) - EN-ID(L-ROW), 40) = 0
                     AND FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < 1.0 AND FUNCTION ABS(EN-Y(WS-E) - EN-Y(L-ROW)) < 1.0
                     AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < 1.0
                 ADD EN-ITEM-COUNT(WS-E) TO EN-ITEM-COUNT(L-ROW)
                 IF EN-AGE(WS-E) < EN-AGE(L-ROW)
                     MOVE EN-AGE(WS-E) TO EN-AGE(L-ROW)
                 END-IF
                 CALL "ENTITY-REMOVE" USING WS-E
             END-IF
         END-PERFORM
     END-IF
     CALL "XP-ORB-MOVE" USING L-ROW
     ADD 1 TO EN-AGE(L-ROW)
     IF EN-AGE(L-ROW) >= 6000
         CALL "ENTITY-REMOVE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM XP-ORB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-PICKUP.
*> USING player row: Player.aiStep's pickup for experience (41 section 4.1, 21 section 8.2): takeXpDelay falls by 1; the orbs in reach (the player's
*> box inflated by 1.0 on x and z and 0.5 on y) are listed and one of them, drawn at random, is touched when the delay is 0: the delay becomes
*> 2, the viewers get Take Item Entity, the player gets the value (XP-GIVE) and the orb's count falls by 1 (removed at 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 3.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-LIST.
    05 WS-LISTED           BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     IF PL-XP-DELAY(L-PLAYER) > 0
         SUBTRACT 1 FROM PL-XP-DELAY(L-PLAYER)
     END-IF
     IF PL-USED(L-PLAYER) = 0 OR PL-ENTITY-ROW(L-PLAYER) = 0 OR PL-STATE(L-PLAYER) NOT = PS-ALIVE OR PL-MODE(L-PLAYER) >= 3
         GOBACK
     END-IF
     CALL "XP-ORB-TYPE" USING WS-TYPE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = PL-DIM(L-PLAYER) AND WS-N < 64
                 AND FUNCTION ABS(EN-X(WS-E) - PL-X(L-PLAYER)) < 1.55 AND FUNCTION ABS(EN-Z(WS-E) - PL-Z(L-PLAYER)) < 1.55
                 AND EN-Y(WS-E) + 0.5 > PL-Y(L-PLAYER) - 0.5 AND EN-Y(WS-E) < PL-Y(L-PLAYER) + 2.3
             ADD 1 TO WS-N
             MOVE WS-E TO WS-LISTED(WS-N)
         END-IF
     END-PERFORM
     IF WS-N > 0 AND PL-XP-DELAY(L-PLAYER) = 0
         CALL "XP-RANDOM" USING WS-SALT WS-N WS-PICK
         ADD 1 TO WS-PICK
         MOVE WS-LISTED(WS-PICK) TO WS-E
         MOVE 2 TO PL-XP-DELAY(L-PLAYER)
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(WS-E) PL-ENTITY-ID(L-PLAYER) WS-AMOUNT PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING WS-E PB-BUFFER
         CALL "XP-GIVE" USING L-PLAYER EN-ITEM(WS-E)
         SUBTRACT 1 FROM EN-ITEM-COUNT(WS-E)
         IF EN-ITEM-COUNT(WS-E) <= 0
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-IF
     GOBACK.
 END PROGRAM XP-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XP-ORBS-TICK.
*> No parameters (CORE-TICK, after the ground items): the pickup of every player, then XP-ORB-STEP for every orb whose chunk is loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "XP-ORB-TYPE" USING WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1
             CALL "XP-PICKUP" USING WS-P
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
             CALL "WORLD-FIND" USING EN-DIM(WS-E) WS-CX WS-CZ WS-CHUNK
             IF WS-CHUNK > 0
                 CALL "XP-ORB-STEP" USING WS-E
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM XP-ORBS-TICK.
