*> The ominous item spawner (docs/protocol/21 section 8.17, 44-2 section 4.6, 30-4 section 4.1), lane p49f. PJ-KIND 41: PJ-I1 spawn_item_after_ticks (60 + nextInt(61), nextIntBetween(60, 120)),
*> PJ-I2 the item, PJ-I3 its count, PJ-I4 the tick count. The viewers get metadata 8 (the item stack) after Add Entity. Each tick (OIS-STEP, from THROWN-TICK) the tick count rises by 1; once it
*> is spawn_item_after_ticks an ordinary item becomes an item entity at the spawner's position (the five-argument constructor: random motion, no pickup delay); an experience bottle, an egg or a
*> snowball is launched downward with the dispense power and uncertainty of 30-4 section 4.1 (velocity (normalize(d) + triangle(0, 0.0172275 x uncertainty)) x power per axis), owned by the spawner;
*> then level event 3021 with data 1 and the spawner is removed.
*> Not done: the about-to-spawn sound at tick count spawnAfter - 36 and the begin sound (the core sends no entity sounds), the ENTITY_PLACE game event, the client particles every 5 ticks, the
*> launch of the other projectile items (arrows, potions, fire charge, wind charge, firework rocket: they become item entities), saving (NBT item, spawn_item_after_ticks), an item with components.
*>
*>   OIS-SPAWN USING dim, x, y, z (FLOAT-LONG), item, count, row out   the spawner (row 0 when it cannot be made)
*>   OIS-DATA-BUILD USING row, PB-BUFFER                              Set Entity Data: 8 the item stack
*>   OIS-JITTER USING uncertainty (thousandths), power (thousandths), vx, vy, vz out   the launch velocity straight down
*>   OIS-STEP USING row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OIS-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:ominous_item_spawner".
 01 WS-TYPE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 41.
 01 WS-SALT                BINARY-LONG VALUE 9171.
 01 WS-BOUND               BINARY-LONG VALUE 61.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ITEM L-COUNT L-ROW.
     MOVE 0 TO L-ROW
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     CALL "PJ-ALLOC" USING EN-ID(WS-ROW) WS-KIND WS-SLOT
     IF WS-SLOT = 0
         INITIALIZE EN-ENTRY(WS-ROW)
         GOBACK
     END-IF
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW)
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
     COMPUTE PJ-I1(WS-SLOT) = 60 + WS-R
     MOVE L-ITEM TO PJ-I2(WS-SLOT)
     MOVE L-COUNT TO PJ-I3(WS-SLOT)
     MOVE 0 TO PJ-I4(WS-SLOT)
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM OIS-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OIS-DATA-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 8 TO MD-MD-INDEX
     MOVE MD-MDS-ITEM-STACK TO MD-MD-SERIALIZER
     MOVE PJ-I3(WS-SLOT) TO MD-MD-IS-COUNT
     MOVE PJ-I2(WS-SLOT) TO MD-MD-IS-ITEM
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM OIS-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OIS-JITTER.
*> triangle(0, 0.0172275 x uncertainty) = 0.0172275 x uncertainty x (nextDouble - nextDouble) per axis (two draws of a million steps each), added to the unit direction (0, -1, 0), then x power.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SALT                BINARY-LONG VALUE 9172.
 01 WS-BOUND               BINARY-LONG VALUE 1000000.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SPREAD              FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-UNCERTAINTY          BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-UNCERTAINTY L-POWER L-VX L-VY L-VZ.
     COMPUTE WS-SPREAD = 0.0172275 * L-UNCERTAINTY / 1000
     COMPUTE WS-POWER = L-POWER / 1000
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VX = WS-SPREAD * (WS-A - WS-B) / 1000000 * WS-POWER
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VY = (WS-SPREAD * (WS-A - WS-B) / 1000000 - 1) * WS-POWER
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-A
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-B
     COMPUTE L-VZ = WS-SPREAD * (WS-A - WS-B) / 1000000 * WS-POWER
     GOBACK.
 END PROGRAM OIS-JITTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OIS-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-DIM                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-UNCERTAINTY         BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-NEW                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-NO-VAR              BINARY-LONG VALUE 0.
 01 WS-NO-DELAY            BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 3021.
 01 WS-DATA                BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     ADD 1 TO PJ-I4(WS-SLOT)
     IF PJ-I4(WS-SLOT) < PJ-I1(WS-SLOT)
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-ID(L-ROW) TO WS-ID
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "TOOLUSE-KEY" USING PJ-I2(WS-SLOT) WS-KEY
     MOVE 0 TO WS-KIND
     EVALUATE WS-KEY
         WHEN "snowball" WHEN "egg"
             MOVE 6000 TO WS-UNCERTAINTY
             MOVE 1100 TO WS-POWER
             MOVE 1 TO WS-KIND
         WHEN "experience_bottle"
             MOVE 3000 TO WS-UNCERTAINTY
             MOVE 1375 TO WS-POWER
             MOVE 2 TO WS-KIND
     END-EVALUATE
     IF WS-KIND = 0
         CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z PJ-I2(WS-SLOT) PJ-I3(WS-SLOT) WS-NO-VAR WS-NO-DELAY WS-NEW
     ELSE
         CALL "OIS-JITTER" USING WS-UNCERTAINTY WS-POWER WS-VX WS-VY WS-VZ
         EVALUATE WS-KEY
             WHEN "snowball"
                 MOVE 3 TO WS-KIND
                 CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-NONE WS-ID WS-NEW
                 IF WS-NEW > 0
                     MOVE WS-VX TO EN-VX(WS-NEW)
                     MOVE WS-VY TO EN-VY(WS-NEW)
                     MOVE WS-VZ TO EN-VZ(WS-NEW)
                 END-IF
             WHEN "egg"
                 MOVE 6 TO WS-KIND
                 MOVE "minecraft:egg" TO WS-EKEY
                 CALL "THROWN-SPAWN" USING WS-KIND WS-EKEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ID WS-NEW
             WHEN OTHER
                 MOVE 40 TO WS-KIND
                 MOVE "minecraft:experience_bottle" TO WS-EKEY
                 CALL "THROWN-SPAWN" USING WS-KIND WS-EKEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ID WS-NEW
         END-EVALUATE
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
     CALL "LEVEL-EVENT" USING WS-DIM WS-EVENT WS-CX WS-CY WS-CZ WS-DATA WS-NONE2
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM OIS-STEP.
