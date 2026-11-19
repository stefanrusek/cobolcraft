*> Copper golem (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 21). The row is the one of MOBROWS49V.cpy; state is EN-CG-* of CORESTATE.cpy:
*> EN-CG-WEATHER (metadata 16), EN-CG-STATE (metadata 17), EN-CG-NEXT (nextWeatheringTick: -2 waxed, -1 or 0 unscheduled), EN-CG-ANT (the antenna item), the main hand is EN-ITEM / EN-ITEM-COUNT.
*> Not here (the docs give no behaviour that can be tested, or a part of the game is missing): the chest-to-chest transport brain and its container steps (the golem states 1 to 4 are only stored and sent), the
*> block entity of the statue (it keeps no golem), sounds, the direction and speed of a thrown hand item.
*>   CG-DELAY USING draw (0 to 48000), delay out                                    504000 + draw
*>   CG-WEATHER-STEP USING weather, next (in/out), now, draw, changed out            one evaluation of the weathering clock
*>   CG-STATUE-CHECK USING weather, air, roll (0 to 999999), result out              oxidized, air at the position and nextFloat <= 0.0058
*>   CG-WAX USING next (in/out), event out                                           honeycomb: -2, level event 3003
*>   CG-AXE USING weather, next (in/out), event out                                  axe: unwax (3004) or scrape one level (3005)
*>   CG-LIGHTNING USING weather, next (in/out), changed out                          a bolt: one level back, timer -1
*>   CG-USE USING player row, entity row, used out                                   Interact with a copper golem
*>   CG-TICK USING row, gone out                                                      the golem's tick (STDMOB-STEP)
*>   CG-STATUE-MAKE USING row                                                         the golem becomes an oxidized statue block
*>   CG-HURT USING row                                                                any damage resets the golem state to idle
*>   CG-BOLT USING bolt slot, row                                                     LIGHTNING-HIT of a copper golem (once per bolt)
*>   CG-DATA-BUILD USING row, PB-BUFFER                                               Set Entity Data: 16 weathering state, 17 golem state
*>   COPPER-GOLEM-BUILD USING dim, x, y, z                                            a carved pumpkin on a copper block (GOLEM-BUILD)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-DELAY.
     COMPUTE L-DELAY = 504000 + L-DRAW
     GOBACK.
 END PROGRAM CG-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-WEATHER-STEP.
*> -2 waxed: nothing. Unscheduled (-1, or 0 of a new row): the timer becomes now + 504000 + draw. When the time has come and the state is not oxidized: one step on and the timer grows by another
*> 504000 + draw (changed 1). An oxidized golem keeps its timer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DELAY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-WEATHER              BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-NOW                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHER L-NEXT L-NOW L-DRAW L-CHANGED.
     MOVE 0 TO L-CHANGED
     CALL "CG-DELAY" USING L-DRAW WS-DELAY
     EVALUATE TRUE
         WHEN L-NEXT = -2
             CONTINUE
         WHEN L-NEXT <= 0
             COMPUTE L-NEXT = L-NOW + WS-DELAY
         WHEN L-NOW >= L-NEXT AND L-WEATHER < 3
             ADD 1 TO L-WEATHER
             ADD WS-DELAY TO L-NEXT
             MOVE 1 TO L-CHANGED
     END-EVALUATE
     GOBACK.
 END PROGRAM CG-WEATHER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-STATUE-CHECK.
*> nextFloat() <= 0.0058 with the float drawn as 0 to 999999 millionths: at most 5800.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHER              BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHER L-AIR L-ROLL L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-WEATHER = 3 AND L-AIR = 1 AND L-ROLL <= 5800
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM CG-STATUE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-WAX.
*> Honeycomb on a golem that is not waxed: the timer becomes -2 and level event 3003 plays; event 0 when nothing happens.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEXT                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NEXT L-EVENT.
     MOVE 0 TO L-EVENT
     IF L-NEXT NOT = -2
         MOVE -2 TO L-NEXT
         MOVE 3003 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM CG-WAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-AXE.
*> An axe on a waxed golem: the timer becomes -1 (unwaxed), event 3004, the state stays. On an unwaxed one with a state other than unaffected: the state steps back one level and the timer is -1, event 3005.
*> Otherwise event 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHER              BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHER L-NEXT L-EVENT.
     MOVE 0 TO L-EVENT
     EVALUATE TRUE
         WHEN L-NEXT = -2
             MOVE -1 TO L-NEXT
             MOVE 3004 TO L-EVENT
         WHEN L-WEATHER > 0
             SUBTRACT 1 FROM L-WEATHER
             MOVE -1 TO L-NEXT
             MOVE 3005 TO L-EVENT
     END-EVALUATE
     GOBACK.
 END PROGRAM CG-AXE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-LIGHTNING.
*> A bolt on a golem that is not unaffected: the timer is reset to -1 and the state steps back one level (changed 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHER              BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHER L-NEXT L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF L-WEATHER > 0
         SUBTRACT 1 FROM L-WEATHER
         MOVE -1 TO L-NEXT
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM CG-LIGHTNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-USE.
*> USING player row, entity row, used out: Interact with a copper golem (19 section 21), in this order: a player holding any item takes the item the golem holds in its main hand (it is thrown out and the hand
*> cleared); shears when an item sits in the antenna slot (the item drops 1.5 above the golem, the slot is emptied, the shears lose 1 durability); honeycomb on a golem that is not waxed (one honeycomb is used, level
*> event 3003); an axe (1 durability, event 3004 or 3005). used is 0 for a species other than the copper golem and when nothing happened.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SPECIES             PIC X(24).
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAIL                PIC X(4).
 01 WS-EVENT               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-OFFSET-HAND         FLOAT-LONG VALUE 0.8.
 01 WS-OFFSET-ANT          FLOAT-LONG VALUE 1.5.
 01 WS-COST                BINARY-LONG VALUE 1.
 01 WS-BROKE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-USED.
     MOVE 0 TO L-USED
     CALL "MOB-SPECIES-KEY" USING L-ENTITY WS-SPECIES
     IF WS-SPECIES NOT = "copper_golem"
         GOBACK
     END-IF
     MOVE PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) TO WS-COUNT
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) TO WS-ITEM
     CALL "TOOLUSE-KEY" USING WS-ITEM WS-KEY
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ENTITY))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ENTITY))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ENTITY))
     MOVE 0 TO WS-EVENT
     EVALUATE TRUE
         WHEN EN-ITEM(L-ENTITY) > 0 AND EN-ITEM-COUNT(L-ENTITY) > 0
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ENTITY) EN-X(L-ENTITY) EN-Y(L-ENTITY) EN-Z(L-ENTITY) WS-OFFSET-HAND
                 EN-ITEM(L-ENTITY) EN-ITEM-COUNT(L-ENTITY) WS-PATCH WS-DROPPED
             MOVE 0 TO EN-ITEM(L-ENTITY) EN-ITEM-COUNT(L-ENTITY)
             MOVE 1 TO L-USED
         WHEN WS-KEY = "shears" AND EN-CG-ANT(L-ENTITY) > 0
             CALL "IP-AT-LOCATION" USING EN-DIM(L-ENTITY) EN-X(L-ENTITY) EN-Y(L-ENTITY) EN-Z(L-ENTITY) WS-OFFSET-ANT
                 EN-CG-ANT(L-ENTITY) WS-ONE WS-PATCH WS-DROPPED
             MOVE 0 TO EN-CG-ANT(L-ENTITY)
             CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
             MOVE 1 TO L-USED
         WHEN WS-KEY = "honeycomb"
             CALL "CG-WAX" USING EN-CG-NEXT(L-ENTITY) WS-EVENT
             IF WS-EVENT > 0
                 CALL "MOB-TAKE" USING L-ROW
                 MOVE 1 TO L-USED
             END-IF
         WHEN OTHER
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY TRAILING)) TO WS-LENGTH
             IF WS-LENGTH >= 4
                 COMPUTE WS-LENGTH = WS-LENGTH - 3
                 MOVE WS-KEY(WS-LENGTH:4) TO WS-TAIL
                 IF WS-TAIL = "_axe"
                     CALL "CG-AXE" USING EN-CG-WEATHER(L-ENTITY) EN-CG-NEXT(L-ENTITY) WS-EVENT
                     IF WS-EVENT > 0
                         CALL "TOOL-HURT-STACK" USING PL-CONN(L-ROW) PL-HELD(L-ROW) WS-COST WS-BROKE
                         MOVE 1 TO L-USED
                     END-IF
                 END-IF
             END-IF
     END-EVALUATE
     IF WS-EVENT > 0
         CALL "LEVEL-EVENT" USING EN-DIM(L-ENTITY) WS-EVENT WS-BX WS-BY WS-BZ WS-NONE WS-NONE2
         IF WS-EVENT = 3005
             CALL "MOB-DATA-SEND" USING L-ENTITY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CG-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-STATUE-MAKE.
*> USING row: the golem is replaced by an oxidized_copper_golem_statue block at its block, facing as its yaw (Direction.fromYRot, BE8-STATUE-FACING) in a random pose; what it carries (hand and antenna)
*> drops and the entity is removed. The block entity that keeps the golem is not built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(48) VALUE "minecraft:oxidized_copper_golem_statue".
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-YAW                 BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 5211.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-POSE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WORLDSIM-FIND-BLOCK" USING WS-KEY WS-DEFAULT
     IF WS-DEFAULT = 0
         GOBACK
     END-IF
     MOVE WS-DEFAULT TO WS-STATE
     COMPUTE WS-YAW = FUNCTION INTEGER(EN-YAW(L-ROW))
     CALL "BE8-STATUE-FACING" USING WS-YAW WS-DIRECTION
     MOVE "facing" TO WS-NAME
     EVALUATE WS-DIRECTION
         WHEN 2 MOVE "north" TO WS-TEXT
         WHEN 3 MOVE "south" TO WS-TEXT
         WHEN 4 MOVE "west" TO WS-TEXT
         WHEN OTHER MOVE "east" TO WS-TEXT
     END-EVALUATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-POSE
     MOVE "copper_golem_pose" TO WS-NAME
     EVALUATE WS-POSE
         WHEN 0 MOVE "standing" TO WS-TEXT
         WHEN 1 MOVE "sitting" TO WS-TEXT
         WHEN 2 MOVE "running" TO WS-TEXT
         WHEN OTHER MOVE "star" TO WS-TEXT
     END-EVALUATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE EN-DIM(L-ROW) TO WS-DIM
     IF EN-ITEM(L-ROW) > 0 AND EN-ITEM-COUNT(L-ROW) > 0
         CALL "IP-AT-LOCATION" USING WS-DIM EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET EN-ITEM(L-ROW) EN-ITEM-COUNT(L-ROW)
             WS-PATCH WS-DROPPED
     END-IF
     IF EN-CG-ANT(L-ROW) > 0
         CALL "IP-AT-LOCATION" USING WS-DIM EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET EN-CG-ANT(L-ROW) WS-ONE WS-PATCH WS-DROPPED
     END-IF
     CALL "ENTITY-REMOVE" USING L-ROW
     CALL "BLOCK-CHANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     GOBACK.
 END PROGRAM CG-STATUE-MAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-TICK.
*> USING row, gone out (1 when the golem became a statue): evaluates the weathering clock with the game time (CW-TICKS) and, once oxidized, the statue roll while the block at its position is air.
*> A step of the state goes to the viewers. The draws are XP-RANDOM draws (the clock one only when it is needed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-CLOCK          BINARY-LONG VALUE 5212.
 01 WS-BOUND-CLOCK         BINARY-LONG VALUE 48001.
 01 WS-SALT-ROLL           BINARY-LONG VALUE 5213.
 01 WS-BOUND-ROLL          BINARY-LONG VALUE 1000000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-GONE.
     MOVE 0 TO L-GONE
     IF EN-CG-NEXT(L-ROW) NOT = -2
         CALL "XP-RANDOM" USING WS-SALT-CLOCK WS-BOUND-CLOCK WS-DRAW
         MOVE CW-TICKS TO WS-NOW
         CALL "CG-WEATHER-STEP" USING EN-CG-WEATHER(L-ROW) EN-CG-NEXT(L-ROW) WS-NOW WS-DRAW WS-CHANGED
         IF WS-CHANGED = 1
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     IF EN-CG-WEATHER(L-ROW) = 3
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
         MOVE 0 TO WS-AIR
         IF WS-STATE = 0
             MOVE 1 TO WS-AIR
         END-IF
         CALL "XP-RANDOM" USING WS-SALT-ROLL WS-BOUND-ROLL WS-ROLL
         CALL "CG-STATUE-CHECK" USING EN-CG-WEATHER(L-ROW) WS-AIR WS-ROLL WS-RESULT
         IF WS-RESULT = 1
             CALL "CG-STATUE-MAKE" USING L-ROW
             MOVE 1 TO L-GONE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CG-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-HURT.
*> USING row: any damage resets the golem state to idle (the change goes to the viewers).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "copper_golem" AND EN-CG-STATE(L-ROW) NOT = 0
         MOVE 0 TO EN-CG-STATE(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM CG-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-BOLT.
*> USING bolt slot, row: a bolt hits a copper golem once per bolt (CLOUD-VICTIM): CG-LIGHTNING, the change goes to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ID                  BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ROW.
     MOVE EN-ID(L-ROW) TO WS-ID
     CALL "CLOUD-VICTIM" USING L-SLOT WS-ID WS-KNOWN
     IF WS-KNOWN = 0
         CALL "CLOUD-VICTIM-ADD" USING L-SLOT WS-ID
         CALL "CG-LIGHTNING" USING EN-CG-WEATHER(L-ROW) EN-CG-NEXT(L-ROW) WS-CHANGED
         IF WS-CHANGED = 1
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CG-BOLT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CG-DATA-BUILD.
*> USING row, PB-BUFFER: Set Entity Data (0x65) of a copper golem: index 16 WEATHERING_COPPER_STATE (serializer 38) and index 17 COPPER_GOLEM_STATE (serializer 37), both VarInt enums, then the end marker.
*> The animal's baby entry at index 16 is not sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==GD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SERIALIZER-WEATHER  BINARY-LONG VALUE 38.
 01 WS-SERIALIZER-STATE    BINARY-LONG VALUE 37.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE GD-METADATA-ENTRY-X
     MOVE 16 TO GD-MX-INDEX
     MOVE WS-SERIALIZER-WEATHER TO GD-MX-SERIALIZER
     MOVE EN-CG-WEATHER(L-ROW) TO GD-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER GD-METADATA-ENTRY-X
     INITIALIZE GD-METADATA-ENTRY-X
     MOVE 17 TO GD-MX-INDEX
     MOVE WS-SERIALIZER-STATE TO GD-MX-SERIALIZER
     MOVE EN-CG-STATE(L-ROW) TO GD-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER GD-METADATA-ENTRY-X
     INITIALIZE GD-METADATA-ENTRY
     MOVE GD-MD-END TO GD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER GD-METADATA-ENTRY
     GOBACK.
 END PROGRAM CG-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COPPER-GOLEM-BUILD.
*> USING dim, x, y, z of a carved pumpkin or jack o'lantern just placed (GOLEM-BUILD found no other pattern): when the block below it is one of the eight blocks of the tag copper, the pumpkin goes, the copper
*> block becomes the copper chest of its type (copper_block gives copper_chest; waxed ones the waxed chest) facing the way the pumpkin faces, and the golem appears at the pumpkin's block, 0.05 above its floor,
*> with the weathering level of the block (a waxed block counts as its unwaxed level; the golem itself is not waxed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-CHEST               PIC X(48).
 01 WS-FULL                PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-MODE-GET            BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24) VALUE "facing".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-CHEST-STATE         BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ENTITY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     COMPUTE WS-BELOW = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BELOW L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE SPACES TO WS-CHEST
     MOVE 0 TO WS-LEVEL
     MOVE CB-KEY(WS-BLOCK) TO WS-FULL
     CALL "KEY-BARE" USING WS-FULL WS-BARE
     EVALUATE WS-BARE
         WHEN "copper_block"
             MOVE "minecraft:copper_chest" TO WS-CHEST
         WHEN "exposed_copper"
             MOVE "minecraft:exposed_copper_chest" TO WS-CHEST
             MOVE 1 TO WS-LEVEL
         WHEN "weathered_copper"
             MOVE "minecraft:weathered_copper_chest" TO WS-CHEST
             MOVE 2 TO WS-LEVEL
         WHEN "oxidized_copper"
             MOVE "minecraft:oxidized_copper_chest" TO WS-CHEST
             MOVE 3 TO WS-LEVEL
         WHEN "waxed_copper_block"
             MOVE "minecraft:waxed_copper_chest" TO WS-CHEST
         WHEN "waxed_exposed_copper"
             MOVE "minecraft:waxed_exposed_copper_chest" TO WS-CHEST
             MOVE 1 TO WS-LEVEL
         WHEN "waxed_weathered_copper"
             MOVE "minecraft:waxed_weathered_copper_chest" TO WS-CHEST
             MOVE 2 TO WS-LEVEL
         WHEN "waxed_oxidized_copper"
             MOVE "minecraft:waxed_oxidized_copper_chest" TO WS-CHEST
             MOVE 3 TO WS-LEVEL
     END-EVALUATE
     IF WS-CHEST = SPACES
         GOBACK
     END-IF
     CALL "WORLDSIM-FIND-BLOCK" USING WS-CHEST WS-DEFAULT
     IF WS-DEFAULT = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-GET WS-STATE WS-NAME WS-TEXT WS-RESULT
     MOVE WS-DEFAULT TO WS-CHEST-STATE
     IF WS-RESULT = 1
         CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-CHEST-STATE WS-NAME WS-TEXT WS-RESULT
         MOVE WS-RESULT TO WS-CHEST-STATE
     END-IF
     CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-AIR
     CALL "BLOCK-CHANGE" USING L-DIM L-X WS-BELOW L-Z WS-CHEST-STATE
     MOVE "minecraft:copper_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW WS-STATUS
     COMPUTE WS-FX = L-X + 0.5
     COMPUTE WS-FY = L-Y + 0.05
     COMPUTE WS-FZ = L-Z + 0.5
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ENTITY
     MOVE WS-LEVEL TO EN-CG-WEATHER(WS-ENTITY)
     CALL "MOB-DATA-SEND" USING WS-ENTITY
     GOBACK.
 END PROGRAM COPPER-GOLEM-BUILD.
