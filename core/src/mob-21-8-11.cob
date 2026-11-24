*> The happy ghast (docs/protocol/21 section 8.11; 44-9 section 9), lane p49f. Row `happy_ghast` of MOBROWS11.cpy. Its own state is a PROJSTATE.cpy entry of PJ-KIND 43 (HG-STATE, made on the first use): PJ-I1 leashHolderTime,
*> PJ-I2 serverStillTimeout, PJ-I3 the body slot (0 empty, else the item id of the harness), PJ-I4 the home radius (0 no home), PJ-I5 the ticks lived, PJ-I6 the age lock, PJ-I7 what the viewers were last told of metadata 18 and 19
*> (1 + leash holder + 2 x stays still; 0 nothing yet), PJ-R1, PJ-R2 and PJ-R3 the home cell. STDMOB-STEP gives every happy ghast to HG-TICK after the environment; it does not move (no flight AI yet).
*> Each tick (server): the counters, checkRestriction (home radius 64 for an adult with an empty body slot, else 32; a new home at the block when there is none, it is farther than radius + 16 or the radius differs; not while leashed
*> or carrying a passenger), continuousHeal (1 point when the ticks lived are a multiple of 20 in rain, else of 600), the still timeout (10 while a player stands above it, counting down once the ghast has lived 60 ticks) and metadata 18
*> (leash holder) and 19 (stays still) to the viewers when they changed. HG-INTERACT: a baby fed a snowball grows (E8 of 44-9), an adult takes a harness in its body slot.
*> Formulas: HG-FEED-SECONDS, HG-AGE-UP, HG-RADIUS, HG-TEMPTED, HG-RIDDEN-INPUT, HG-RIDDEN-ROTATE, HG-QUAD-OFFSETS.
*> Not done (all in the documents): the flight AI (goals, the baby brain, the move and look controls, travel), the dried ghast block and the hatching (44-9 9.1), riding (seats, up to 4 passengers, the controller, the dismount),
*> collision, the position sync when the still timeout starts, isInClouds and the precipitation at the position (any rain in the dimension counts), the force-synced position, the goggles sounds, the quad leash pull.
*>
*>   HG-STATE USING row, slot out                          the PROJSTATE entry of a happy ghast (made when missing; 0 when the table is full)
*>   HG-RADIUS USING baby, harness, radius out             getHappyGhastRestrictionRadius
*>   HG-FEED-SECONDS USING age (negative), seconds out     getSpeedUpSecondsWhenFeeding
*>   HG-AGE-UP USING row, seconds                          AgeableMob.ageUp(seconds, forced = true)
*>   HG-TEMPTED USING item key (PIC X(48)), armored, baby, tempted out
*>   HG-RIDDEN-INPUT USING xxa, zza, pitch (degrees), jumping, x, y, z out (FLOAT-LONG)
*>   HG-RIDDEN-ROTATE USING yaw, rider yaw, rider pitch (degrees, FLOAT-LONG), yaw out, pitch out
*>   HG-QUAD-OFFSETS USING width, height, offsets out (12 FLOAT-LONG: four points x, y, z)
*>   HG-NOTIFY-LEASH USING row                             notifyLeashHolder: leashHolderTime 5
*>   HG-DATA-BUILD USING row, PB-BUFFER                    Set Entity Data: 18 BOOLEAN leash holder, 19 BOOLEAN stays still
*>   HG-INTERACT USING player row, entity row, used out
*>   HG-TICK USING row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KIND                BINARY-LONG VALUE 43.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     CALL "PJ-FIND" USING EN-ID(L-ROW) L-SLOT
     IF L-SLOT = 0
         CALL "PJ-ALLOC" USING EN-ID(L-ROW) WS-KIND L-SLOT
     END-IF
     GOBACK.
 END PROGRAM HG-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-RADIUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-HARNESS              BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-HARNESS L-RADIUS.
     MOVE 32 TO L-RADIUS
     IF L-BABY = 0 AND L-HARNESS = 0
         MOVE 64 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM HG-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-FEED-SECONDS.
*> (int)((float)(a / 20) x 0.1f): the integer division first, then the float product with 0.1f = 0.10000000149011612.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A20                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-SECONDS.
     COMPUTE WS-A20 = FUNCTION INTEGER-PART((0 - L-AGE) / 20)
     COMPUTE L-SECONDS = FUNCTION INTEGER-PART(WS-A20 * 0.10000000149011612)
     GOBACK.
 END PROGRAM HG-FEED-SECONDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-DATA-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LEASH               BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "HG-STATE" USING L-ROW WS-SLOT
     MOVE 0 TO WS-LEASH WS-STILL
     IF PJ-I1(WS-SLOT) > 0
         MOVE 1 TO WS-LEASH
     END-IF
     IF PJ-I2(WS-SLOT) > 0
         MOVE 1 TO WS-STILL
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 18 TO MD-MD-INDEX
     MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
     MOVE WS-LEASH TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     INITIALIZE MD-METADATA-ENTRY
     MOVE 19 TO MD-MD-INDEX
     MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
     MOVE WS-STILL TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     COMPUTE PJ-I7(WS-SLOT) = 1 + WS-LEASH + 2 * WS-STILL
     GOBACK.
 END PROGRAM HG-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-DATA-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "HG-DATA-BUILD" USING L-ROW PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HG-DATA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-AGE-UP.
*> newAge = min(age + seconds x 20, 0); the age 0 makes an adult (the baby flag falls, the viewers are told).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SECONDS.
     COMPUTE WS-NEW = EN-MOBAGE(L-ROW) + L-SECONDS * 20
     IF WS-NEW > 0
         MOVE 0 TO WS-NEW
     END-IF
     MOVE WS-NEW TO EN-MOBAGE(L-ROW)
     IF WS-NEW = 0 AND EN-VARIANT(L-ROW) = 1
         MOVE 0 TO EN-VARIANT(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM HG-AGE-UP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-TEMPTED.
*> The adult predicate: wearing body armor or a baby, only snowballs (happy_ghast_food); otherwise snowballs and the sixteen harnesses (happy_ghast_tempt_items).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HARNESS             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-ARMORED              BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-TEMPTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ARMORED L-BABY L-TEMPTED.
     MOVE 0 TO L-TEMPTED WS-HARNESS
     IF L-KEY = "snowball"
         MOVE 1 TO L-TEMPTED
         GOBACK
     END-IF
     INSPECT L-KEY TALLYING WS-HARNESS FOR ALL "_harness"
     IF WS-HARNESS = 1 AND L-ARMORED = 0 AND L-BABY = 0
         MOVE 1 TO L-TEMPTED
     END-IF
     GOBACK.
 END PROGRAM HG-TEMPTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-RIDDEN-INPUT.
*> strafe s = xxa; forward f and vertical v are 0 unless zza is not 0: f = cos(pitch), v = -sin(pitch), both x -0.5 when zza < 0; jumping adds 0.5 to v; (s, v, f) x (3.9000000953674316 x 0.05).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-XXA                  FLOAT-LONG.
 01 L-ZZA                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-JUMPING              BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-XXA L-ZZA L-PITCH L-JUMPING L-X L-Y L-Z.
     MOVE 0 TO WS-F WS-V
     IF L-ZZA NOT = 0
         COMPUTE WS-RAD = L-PITCH * 0.017453292
         COMPUTE WS-F = FUNCTION COS(WS-RAD)
         COMPUTE WS-V = 0 - FUNCTION SIN(WS-RAD)
         IF L-ZZA < 0
             COMPUTE WS-F = WS-F * -0.5
             COMPUTE WS-V = WS-V * -0.5
         END-IF
     END-IF
     IF L-JUMPING = 1
         COMPUTE WS-V = WS-V + 0.5
     END-IF
     COMPUTE WS-SCALE = 3.9000000953674316 * 0.05
     COMPUTE L-X = L-XXA * WS-SCALE
     COMPUTE L-Y = WS-V * WS-SCALE
     COMPUTE L-Z = WS-F * WS-SCALE
     GOBACK.
 END PROGRAM HG-RIDDEN-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-RIDDEN-ROTATE.
*> yaw += wrapDegrees(riderYaw - yaw) x 0.08; pitch = riderPitch x 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WRAP                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-RIDER-YAW            FLOAT-LONG.
 01 L-RIDER-PITCH          FLOAT-LONG.
 01 L-NEW-YAW              FLOAT-LONG.
 01 L-NEW-PITCH            FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-RIDER-YAW L-RIDER-PITCH L-NEW-YAW L-NEW-PITCH.
     COMPUTE WS-WRAP = L-RIDER-YAW - L-YAW
     PERFORM UNTIL WS-WRAP < 180
         COMPUTE WS-WRAP = WS-WRAP - 360
     END-PERFORM
     PERFORM UNTIL WS-WRAP >= -180
         COMPUTE WS-WRAP = WS-WRAP + 360
     END-PERFORM
     COMPUTE L-NEW-YAW = L-YAW + WS-WRAP * 0.08
     COMPUTE L-NEW-PITCH = L-RIDER-PITCH * 0.5
     GOBACK.
 END PROGRAM HG-RIDDEN-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-QUAD-OFFSETS.
*> createQuadLeashOffsets(ghast, -0.03125, 0.4375, 0.46875, 0.03125): A = -0.03125 w, B = 0.4375 w, C = 0.46875 w, D = 0.03125 h; the points (-C, D, B + A), (-C, D, -B + A), (C, D, -B + A), (C, D, B + A).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-WIDTH                FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-OFFSETS.
    05 L-O                 FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-WIDTH L-HEIGHT L-OFFSETS.
     COMPUTE WS-A = -0.03125 * L-WIDTH
     COMPUTE WS-B = 0.4375 * L-WIDTH
     COMPUTE WS-C = 0.46875 * L-WIDTH
     COMPUTE WS-D = 0.03125 * L-HEIGHT
     COMPUTE L-O(1) = 0 - WS-C
     MOVE WS-D TO L-O(2)
     COMPUTE L-O(3) = WS-B + WS-A
     COMPUTE L-O(4) = 0 - WS-C
     MOVE WS-D TO L-O(5)
     COMPUTE L-O(6) = 0 - WS-B + WS-A
     MOVE WS-C TO L-O(7)
     MOVE WS-D TO L-O(8)
     COMPUTE L-O(9) = 0 - WS-B + WS-A
     MOVE WS-C TO L-O(10)
     MOVE WS-D TO L-O(11)
     COMPUTE L-O(12) = WS-B + WS-A
     GOBACK.
 END PROGRAM HG-QUAD-OFFSETS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-NOTIFY-LEASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "HG-STATE" USING L-ROW WS-SLOT
     IF WS-SLOT > 0
         MOVE 5 TO PJ-I1(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM HG-NOTIFY-LEASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-HELD                PIC X(48).
 01 WS-SLOT                BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-HARNESS             BINARY-LONG.
 01 WS-HELD-ITEM           BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-USED.
     MOVE 0 TO L-USED
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-KEY
     IF WS-KEY NOT = "happy_ghast"
         GOBACK
     END-IF
     IF PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) = 0
         GOBACK
     END-IF
     CALL "HG-STATE" USING L-ENTITY WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WS-HELD-ITEM
     CALL "TOOLUSE-KEY" USING WS-HELD-ITEM WS-HELD
     IF EN-VARIANT(L-ENTITY) = 1
*>       A baby: food while not age-locked; Animal.mobInteract uses the item and ages it up by getSpeedUpSecondsWhenFeeding(-age).
         IF WS-HELD = "snowball" AND PJ-I6(WS-SLOT) = 0
             CALL "MOB-TAKE" USING L-PLAYER
             CALL "HG-FEED-SECONDS" USING EN-MOBAGE(L-ENTITY) WS-SECONDS
             CALL "HG-AGE-UP" USING L-ENTITY WS-SECONDS
             MOVE 1 TO L-USED
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO WS-HARNESS
     INSPECT WS-HELD TALLYING WS-HARNESS FOR ALL "_harness"
     IF WS-HARNESS = 1 AND PJ-I3(WS-SLOT) = 0
*>       An adult with an empty body slot takes the harness (equip_on_interact).
         MOVE WS-HELD-ITEM TO PJ-I3(WS-SLOT)
         CALL "MOB-TAKE" USING L-PLAYER
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM HG-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-ABOVE.
*> USING row, found out: scanPlayerAboveGhast: a non-spectator player of the dimension, not riding it, whose position is in the box from (minX - 1, maxY - 0.00001, minZ - 1) to (maxX + 1, maxY + height / 2, maxZ + 1)
*> of the 4 x 4 ghast (the box test is minimum inclusive, maximum exclusive).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND.
     MOVE 0 TO L-FOUND
     COMPUTE WS-X0 = EN-X(L-ROW) - 3
     COMPUTE WS-X1 = EN-X(L-ROW) + 3
     COMPUTE WS-Y0 = EN-Y(L-ROW) + 4 - 0.00001
     COMPUTE WS-Y1 = EN-Y(L-ROW) + 6
     COMPUTE WS-Z0 = EN-Z(L-ROW) - 3
     COMPUTE WS-Z1 = EN-Z(L-ROW) + 3
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-FOUND = 1
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3
                 AND PL-ENTITY-ROW(WS-P) > 0
             IF EN-MOUNT(PL-ENTITY-ROW(WS-P)) NOT = L-ROW
                 IF PL-X(WS-P) >= WS-X0 AND PL-X(WS-P) < WS-X1 AND PL-Y(WS-P) >= WS-Y0 AND PL-Y(WS-P) < WS-Y1
                         AND PL-Z(WS-P) >= WS-Z0 AND PL-Z(WS-P) < WS-Z1
                     MOVE 1 TO L-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HG-ABOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HG-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-PERIOD              BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "HG-STATE" USING L-ROW WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     ADD 1 TO PJ-I5(WS-SLOT)
     IF PJ-I1(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-I1(WS-SLOT)
     END-IF
*>   The still timeout: the scan keeps it at 10, else it counts down once the ghast has lived 60 ticks.
     CALL "HG-ABOVE" USING L-ROW WS-ABOVE
     IF PJ-I5(WS-SLOT) > 60 AND PJ-I2(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-I2(WS-SLOT)
     END-IF
     IF WS-ABOVE = 1
         MOVE 10 TO PJ-I2(WS-SLOT)
     END-IF
*>   checkRestriction (21 section 8.11, 44-9 section 9.6).
     MOVE EN-VARIANT(L-ROW) TO WS-BABY
     CALL "HG-RADIUS" USING WS-BABY PJ-I3(WS-SLOT) WS-RADIUS
     IF EN-LEASH(L-ROW) = 0 AND EN-LEASH-KNOT(L-ROW) = 0 AND EN-PASS(L-ROW) = 0
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         COMPUTE WS-LIMIT = WS-RADIUS + 16
         COMPUTE WS-DX = WS-BX - PJ-R1(WS-SLOT)
         COMPUTE WS-DY = WS-BY - PJ-R2(WS-SLOT)
         COMPUTE WS-DZ = WS-BZ - PJ-R3(WS-SLOT)
         IF PJ-I4(WS-SLOT) = 0 OR WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ >= WS-LIMIT * WS-LIMIT
                 OR PJ-I4(WS-SLOT) NOT = WS-RADIUS
             MOVE WS-BX TO PJ-R1(WS-SLOT)
             MOVE WS-BY TO PJ-R2(WS-SLOT)
             MOVE WS-BZ TO PJ-R3(WS-SLOT)
             MOVE WS-RADIUS TO PJ-I4(WS-SLOT)
         END-IF
     END-IF
*>   continuousHeal.
     CALL "STDMOB-HEALTH" USING EN-TYPE(L-ROW) WS-MAX
     IF EN-HEALTH(L-ROW) > 0 AND EN-HEALTH(L-ROW) < WS-MAX
         CALL "WEATHER-RAINING" USING EN-DIM(L-ROW) WS-RAIN
         MOVE 600 TO WS-PERIOD
         IF WS-RAIN = 1
             MOVE 20 TO WS-PERIOD
         END-IF
         IF FUNCTION MOD(PJ-I5(WS-SLOT), WS-PERIOD) = 0
             ADD 1 TO EN-HEALTH(L-ROW)
         END-IF
     END-IF
*>   Metadata 18 and 19 to the viewers when they changed.
     MOVE 0 TO WS-SHOWN
     IF PJ-I1(WS-SLOT) > 0
         ADD 1 TO WS-SHOWN
     END-IF
     IF PJ-I2(WS-SLOT) > 0
         ADD 2 TO WS-SHOWN
     END-IF
     IF PJ-I7(WS-SLOT) NOT = 1 + WS-SHOWN
         CALL "HG-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM HG-TICK.
