*> Entity NBT, part 8 (docs/protocol/45-entity-nbt-8-vehicles-projectiles-items.md sections 2.1, 3.3 and 3.4; lane 002-lane-p49k, T24560): the block state compound and the keys of
*> the falling block and the primed TNT. (The ground item's Health, Age, PickupDelay and Item are written by ENTITY-NBT-WRITE-MERGE.)
*>   BLOCKSTATE-NBT-WRITE USING PB-BUFFER, name (PIC X(32)), name length, state    {Name, Properties}: the block key in full form; Properties (every property of the state as
*>        a String) written only for a block that has properties
*>   BLOCKSTATE-NBT-READ USING PB-BUFFER (at the payload of a block state compound), state out   the state of that Name with its Properties set (the default state of the block
*>        for a property it does not name; -1 for an unknown block)
*>   ENTITY8-NBT-WRITE USING row, PB-BUFFER   a falling block: BlockState, Time, DropItem, HurtEntities, FallHurtAmount, FallHurtMax, CancelDrop; a primed TNT: fuse, block_state
*>   ENTITY8-NBT-KEY USING PB-BUFFER, tag type, name, E8-DATA, handled   BlockState, Time, CancelDrop, fuse
*>   ENTITY8-NBT-APPLY USING row, E8-DATA   a falling block gets its state, ticks and cancel flag; a TNT its fuse (EN-SWELL)
*>   ENTITY-IS-LIVING USING row, living out   0 for an entity type that is no LivingEntity (the writer leaves out its Health and its LivingEntity and Mob keys)
*> No state in the core, written at the default: DropItem 1, FallHurtAmount 0.0, FallHurtMax 40, HurtEntities (1 for the three anvils, else 0). Not modelled: TileEntityData,
*> explosion_power (written only when not 4.0, and the core always uses 4.0), owner; the other entities of the document (boats, minecarts, projectiles, orbs, clouds, markers, displays).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKSTATE-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CTPROPS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(32).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-NAME-LENGTH L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE L-NAME TO WN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN L-NAME-LENGTH
     MOVE "Name" TO WN MOVE 4 TO WL
     CALL "PERSIST-NAMESPACED" USING CB-KEY(WS-BLOCK + 1) CB-KEY-LENGTH(WS-BLOCK + 1) WS-NS-KEY WS-NS-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
     CALL "CONTENT-STATE-PROPS" USING L-STATE CT-PROPS WS-STATUS
     IF CTP-COUNT > 0
         MOVE "Properties" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
             MOVE CTP-NAME(WS-I) TO WN
             COMPUTE WS-NAME-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(CTP-NAME(WS-I)))
             COMPUTE WS-VALUE-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(CTP-VALUE(WS-I)))
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-NAME-LENGTH CTP-VALUE(WS-I) WS-VALUE-LENGTH
         END-PERFORM
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM BLOCKSTATE-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKSTATE-NBT-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 112.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-RESULT              BINARY-LONG.
 01 WS-VALUE-CAPACITY      BINARY-LONG VALUE 32.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-PROPS.
    05 WS-PROP OCCURS 16 TIMES.
       10 WS-PROP-NAME     PIC X(24).
       10 WS-PROP-VALUE    PIC X(32).
 01 WS-PROP-KEY            PIC X(24).
 01 WS-PROP-TEXT           PIC X(32).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-STATE.
     MOVE -1 TO L-STATE
     MOVE 0 TO WS-FOUND WS-COUNT
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Name" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-ROW WS-STATUS
                 IF WS-STATUS = CT-OK
                     MOVE 1 TO WS-FOUND
                 END-IF
             WHEN WN = "Properties" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WS-INNER-TYPE = 8 AND WS-COUNT < 16
                         ADD 1 TO WS-COUNT
                         MOVE WN TO WS-PROP-NAME(WS-COUNT)
                         MOVE SPACES TO WS-PROP-VALUE(WS-COUNT)
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-PROP-VALUE(WS-COUNT) WS-VALUE-CAPACITY WS-VALUE-LENGTH
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WS-FOUND = 1 AND PB-ERROR = 0
         MOVE CB-DEFAULT-STATE(WS-BLOCK + 1) TO L-STATE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE WS-PROP-NAME(WS-I) TO WS-PROP-KEY
             MOVE WS-PROP-VALUE(WS-I) TO WS-PROP-TEXT
             CALL "BLOCK-STATE-PROP" USING WS-MODE L-STATE WS-PROP-KEY WS-PROP-TEXT WS-RESULT
             MOVE WS-RESULT TO L-STATE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BLOCKSTATE-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY8-NBT-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FUSE-DEFAULT        BINARY-LONG VALUE 40.
 01 WS-FLOAT               FLOAT-SHORT VALUE 0.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-HURT                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TNT-KEY             PIC X(112) VALUE "minecraft:tnt".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     IF EN-FB-STATE(L-ROW) > 0
         MOVE "BlockState" TO WS-NAME MOVE 10 TO WS-NAME-LENGTH
         CALL "BLOCKSTATE-NBT-WRITE" USING PB-BUFFER WS-NAME WS-NAME-LENGTH EN-FB-STATE(L-ROW)
         MOVE "Time" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-FB-TIME(L-ROW)
         MOVE "DropItem" TO WN MOVE 8 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
         MOVE CB-S-BLOCK(EN-FB-STATE(L-ROW) + 1) TO WS-BLOCK
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-BLOCK + 1) WS-FULL
         MOVE 0 TO WS-HURT
         IF WS-FULL = "minecraft:anvil" OR "minecraft:chipped_anvil" OR "minecraft:damaged_anvil"
             MOVE 1 TO WS-HURT
         END-IF
         MOVE "HurtEntities" TO WN MOVE 12 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-HURT
         MOVE "FallHurtAmount" TO WN MOVE 14 TO WL
         CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
         MOVE "FallHurtMax" TO WN MOVE 11 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-FUSE-DEFAULT
         MOVE "CancelDrop" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL EN-FB-CANCEL(L-ROW)
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-TNT-KEY WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS
     IF EN-TYPE(L-ROW) = WS-TNT-TYPE AND WS-TNT-TYPE > 0
         MOVE "fuse" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL EN-SWELL(L-ROW)
         MOVE "block_state" TO WS-NAME MOVE 11 TO WS-NAME-LENGTH
         CALL "TNT-BLOCK-STATE" USING WS-STATE
         CALL "BLOCKSTATE-NBT-WRITE" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-STATE
     END-IF
     GOBACK.
 END PROGRAM ENTITY8-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TNT-BLOCK-STATE.
*> USING state out (BINARY-LONG): the default state of minecraft:tnt (0 for a set without it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:tnt".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE.
     MOVE 0 TO L-STATE
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-ROW WS-STATUS
     IF WS-STATUS = CT-OK
         CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK L-STATE WS-STATUS
     END-IF
     GOBACK.
 END PROGRAM TNT-BLOCK-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY8-NBT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 COPY E8DATA.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-NAME E8-DATA L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE TRUE
         WHEN L-NAME = "BlockState" AND L-TYPE = 10
             CALL "BLOCKSTATE-NBT-READ" USING PB-BUFFER E8-STATE
         WHEN L-NAME = "Time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER E8-TIME
         WHEN L-NAME = "CancelDrop" AND L-TYPE = 1
             CALL "PB-GET-BYTE" USING PB-BUFFER E8-CANCEL
         WHEN L-NAME = "fuse" AND L-TYPE = 2
             CALL "PB-GET-SHORT" USING PB-BUFFER E8-FUSE
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY8-NBT-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY8-NBT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TNT-KEY             PIC X(112) VALUE "minecraft:tnt".
 01 WS-FALLING-KEY         PIC X(112) VALUE "minecraft:falling_block".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY E8DATA.
 PROCEDURE DIVISION USING L-ROW E8-DATA.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-FALLING-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     IF WS-STATUS = CT-OK AND EN-TYPE(L-ROW) = WS-TYPE AND E8-STATE > 0
         MOVE E8-STATE TO EN-FB-STATE(L-ROW)
         MOVE E8-TIME TO EN-FB-TIME(L-ROW)
         MOVE 0 TO EN-FB-CANCEL(L-ROW)
         IF E8-CANCEL NOT = 0
             MOVE 1 TO EN-FB-CANCEL(L-ROW)
         END-IF
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-TNT-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     IF WS-STATUS = CT-OK AND EN-TYPE(L-ROW) = WS-TYPE
         MOVE E8-FUSE TO EN-SWELL(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ENTITY8-NBT-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-IS-LIVING.
*> USING row, living out (BINARY-LONG): 2 for an armor stand (a LivingEntity and no Mob, 45-9 section 11), 0 for the entity types whose class is an Entity but no LivingEntity (45-8 sections 3, 4, 5 and 6: TNT, falling block, orb, cloud, end
*> crystal, leash knot, painting, item frames, displays, marker, interaction, fangs, rocket, boats and rafts, minecarts, arrows, fireballs, charges and thrown items), else 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(64).
 01 WS-PATH                PIC X(64).
 01 WS-NAMESPACE           PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LIVING.
     MOVE 1 TO L-LIVING
     MOVE ET-KEY(EN-TYPE(L-ROW) + 1) TO WS-KEY
     MOVE SPACES TO WS-PATH WS-NAMESPACE
     UNSTRING WS-KEY DELIMITED BY ":" INTO WS-NAMESPACE WS-PATH
     IF WS-PATH = SPACES
         MOVE WS-KEY TO WS-PATH
     END-IF
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-PATH))
     EVALUATE TRUE
         WHEN WS-PATH = "armor_stand"
             MOVE 2 TO L-LIVING
         WHEN WS-PATH = "tnt" OR "falling_block" OR "experience_orb" OR "area_effect_cloud" OR "end_crystal" OR "leash_knot"
              OR "painting" OR "item_frame" OR "glow_item_frame" OR "block_display" OR "item_display" OR "text_display" OR "marker"
              OR "interaction" OR "evoker_fangs" OR "firework_rocket" OR "eye_of_ender" OR "llama_spit" OR "shulker_bullet"
              OR "wither_skull" OR "small_fireball" OR "fireball" OR "dragon_fireball" OR "wind_charge" OR "breeze_wind_charge"
              OR "arrow" OR "spectral_arrow" OR "trident" OR "snowball" OR "egg" OR "ender_pearl" OR "experience_bottle"
              OR "splash_potion" OR "lingering_potion" OR "ominous_item_spawner" OR "lightning_bolt" OR "fishing_bobber"
             MOVE 0 TO L-LIVING
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   A boat, a raft or a minecart by the end of its key (the offset is only taken for a key long enough).
     IF WS-LENGTH >= 4
         COMPUTE WS-START = WS-LENGTH - 3
         IF WS-PATH(WS-START:4) = "boat" OR "raft"
             MOVE 0 TO L-LIVING
         END-IF
     END-IF
     IF WS-LENGTH >= 8
         COMPUTE WS-START = WS-LENGTH - 7
         IF WS-PATH(WS-START:8) = "minecart"
             MOVE 0 TO L-LIVING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-IS-LIVING.
