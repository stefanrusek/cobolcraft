*> /summon of every entity type the core can create (lane p49o; docs/protocol/16 section 5.8, 45-1 sections 4 to 6, 45-8 sections 3 to 5, 45-9 sections 6 to 12, 21 section 8). CX-SUMMON (cmds-entities.cob) hands
*> a summon of a standard world here, with the NBT of the command as a value tree (NBXTREE.cpy) whose Pos is the position of the command. A mob or a ground item goes through the entity loader
*> (ENTITY-NBT-READ, so the keys of ENTITY-NBT-ONE and the species key tables apply, and Passengers ride their vehicle); every other type is created by the spawn program of its family and takes the keys
*> it models (SUMMON-SPAWN). The Entity base keys (45-1 section 5: Invulnerable, NoGravity, Silent, Glowing, CustomName, Tags, data ...) apply to every family, Motion and Rotation too.
*> Families (SUMMON-FAMILY: 0 none; the sub family selects the variant): 1 ground item, 2 experience orb, 3 primed TNT, 4 falling block, 5 area effect cloud, 6 lightning bolt, 7 end crystal, 8 armor stand,
*> 9 item frame (sub 0) or glow item frame (sub 1), 10 painting, 11 minecart (sub 1 minecart, 2 chest, 3 hopper, 4 furnace, 5 TNT, 6 spawner, 7 command block), 12 boat, raft and their chest variants,
*> 13 interaction, 14 block display, 15 item display, 16 mannequin, 17 cushion, 18 marker, 19 arrow, 20 snowball, 21 egg, 22 ender pearl, 23 experience bottle, 24 fireball, 25 small fireball,
*> 26 wind charge (sub 0) and breeze wind charge (sub 1), 27 splash potion (sub 0) and lingering potion (sub 1), 28 ominous item spawner, 29 firework rocket, 30 eye of ender, 31 shulker bullet, 32 llama spit.
*> Not created (documented gaps): text_display (its component default is not in the documents), spectral_arrow, trident, evoker_fangs, wither_skull, dragon_fireball, leash_knot (the core has the knot only as a mob's
*> EN-LEASH-KNOT), every mob type without a row of STDMOBS.cpy, the passengers of a non-mob entity, and the family keys the core does not model (a potion's contents, the text of a mannequin, the transformation of a display).
*>
*>   SUMMON-FAMILY USING entity type id, family out, sub family out       0 for a type this file does not create (also in a cobolcraft world)
*>   SUMMON-CAN USING entity type id, can out                              1 when /summon can create the type (a mob row, or a family)
*>   SUMMON-KEYS USING root node, EB-DATA, KD-DATA, E8-DATA, block state out   the keys of the tree read by the entity key readers (ENTITY-BASE-KEY, ENTITY-KEEP-KEY, ENTITY8-NBT-KEY, block_state)
*>   SUMMON-LOAD USING dimension row, entity type id, x, y, z, root node, row out   a mob or a ground item through ENTITY-NBT-READ (0 when the loader made none)
*>   SUMMON-SPAWN USING dimension row, entity type id, x, y, z, root node, row out   the entity of a family (0 when it was not made)
*>   FB-SPAWN-AT USING dimension row, x, y, z, state, row out              a falling block at the position (the cell is not touched, unlike FB-SPAWN)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-NUM.
*> USING compound node (0 none), key (PIC X(32)), value out (FLOAT-LONG; left alone when the key is no number), found out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-VALUE                FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT L-KEY L-VALUE L-FOUND.
     MOVE 0 TO L-FOUND
     IF L-ROOT > 0
         MOVE SPACES TO WS-KEY
         MOVE L-KEY TO WS-KEY
         COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
         CALL "NBX-GET-NUM" USING L-ROOT WS-KEY WS-LENGTH L-VALUE L-FOUND
     END-IF
     GOBACK.
 END PROGRAM SUMMON-NUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-TEXT.
*> USING compound node (0 none), key (PIC X(16)), text out (PIC X(64), spaces when the key is no string), length out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NBXTREE.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 01 L-KEY                  PIC X(16).
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT L-KEY L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH WS-NODE
     IF L-ROOT > 0
         CALL "NBX-FIND-N" USING L-ROOT L-KEY WS-NODE
     END-IF
     IF WS-NODE > 0
         IF NX-TYPE(WS-NODE) = 8 AND NX-SLEN(WS-NODE) > 0 AND NX-SLEN(WS-NODE) <= 64
             MOVE NX-STR(WS-NODE)(1:NX-SLEN(WS-NODE)) TO L-TEXT
             MOVE NX-SLEN(WS-NODE) TO L-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SUMMON-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-ITEM.
*> USING compound node (0 none), key (PIC X(16), the entry that holds the stack compound {id, count}), item out (the item id, 0 for no stack or an unknown id), count out (1 when the stack has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-STACK               PIC X(16).
 01 WS-ID                  PIC X(16) VALUE "id".
 01 WS-COUNT-KEY           PIC X(32) VALUE "count".
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STACK-NODE          BINARY-LONG.
 01 WS-LOCAL               PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 01 L-KEY                  PIC X(16).
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT L-KEY L-ITEM L-COUNT.
     MOVE 0 TO L-ITEM WS-STACK-NODE
     MOVE 1 TO L-COUNT
     IF L-ROOT > 0
         CALL "NBX-FIND-N" USING L-ROOT L-KEY WS-STACK-NODE
     END-IF
     IF WS-STACK-NODE > 0
         CALL "SUMMON-TEXT" USING WS-STACK-NODE WS-ID WS-TEXT WS-LENGTH
         CALL "PERSIST-LOCAL-KEY" USING WS-TEXT WS-LOCAL
         CALL "KEY-BARE" USING WS-LOCAL WS-BARE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
             IF WS-LENGTH > 0 AND (IT-KEY(WS-I) = WS-LOCAL OR IT-KEY(WS-I) = WS-BARE)
                 COMPUTE L-ITEM = WS-I - 1
             END-IF
         END-PERFORM
         MOVE 1 TO WS-VALUE
         CALL "SUMMON-NUM" USING WS-STACK-NODE WS-COUNT-KEY WS-VALUE WS-FOUND
         COMPUTE L-COUNT = WS-VALUE
     END-IF
     GOBACK.
 END PROGRAM SUMMON-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-FAMILY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-KEY                 PIC X(64).
 01 WS-PATH                PIC X(64).
 01 WS-NAMESPACE           PIC X(64).
 01 WS-BOAT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-SUB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FAMILY L-SUB.
     MOVE 0 TO L-FAMILY L-SUB
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     MOVE ET-KEY(L-TYPE + 1) TO WS-KEY
     MOVE SPACES TO WS-PATH WS-NAMESPACE
     UNSTRING WS-KEY DELIMITED BY ":" INTO WS-NAMESPACE WS-PATH
     IF WS-PATH = SPACES
         MOVE WS-KEY TO WS-PATH
     END-IF
     EVALUATE TRUE
         WHEN L-TYPE = CR-LOOSE-ITEM
             MOVE 1 TO L-FAMILY
         WHEN WS-PATH = "experience_orb"
             MOVE 2 TO L-FAMILY
         WHEN WS-PATH = "tnt"
             MOVE 3 TO L-FAMILY
         WHEN WS-PATH = "falling_block"
             MOVE 4 TO L-FAMILY
         WHEN WS-PATH = "area_effect_cloud"
             MOVE 5 TO L-FAMILY
         WHEN WS-PATH = "lightning_bolt"
             MOVE 6 TO L-FAMILY
         WHEN WS-PATH = "end_crystal"
             MOVE 7 TO L-FAMILY
         WHEN WS-PATH = "armor_stand"
             MOVE 8 TO L-FAMILY
         WHEN WS-PATH = "item_frame"
             MOVE 9 TO L-FAMILY
         WHEN WS-PATH = "glow_item_frame"
             MOVE 9 TO L-FAMILY
             MOVE 1 TO L-SUB
         WHEN WS-PATH = "painting"
             MOVE 10 TO L-FAMILY
         WHEN WS-PATH = "minecart"
             MOVE 11 TO L-FAMILY
             MOVE 1 TO L-SUB
         WHEN WS-PATH = "chest_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 2 TO L-SUB
         WHEN WS-PATH = "hopper_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 3 TO L-SUB
         WHEN WS-PATH = "furnace_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 4 TO L-SUB
         WHEN WS-PATH = "tnt_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 5 TO L-SUB
         WHEN WS-PATH = "spawner_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 6 TO L-SUB
         WHEN WS-PATH = "command_block_minecart"
             MOVE 11 TO L-FAMILY
             MOVE 7 TO L-SUB
         WHEN WS-PATH = "interaction"
             MOVE 13 TO L-FAMILY
         WHEN WS-PATH = "block_display"
             MOVE 14 TO L-FAMILY
         WHEN WS-PATH = "item_display"
             MOVE 15 TO L-FAMILY
         WHEN WS-PATH = "mannequin"
             MOVE 16 TO L-FAMILY
         WHEN WS-PATH = "cushion"
             MOVE 17 TO L-FAMILY
         WHEN WS-PATH = "marker"
             MOVE 18 TO L-FAMILY
         WHEN WS-PATH = "arrow"
             MOVE 19 TO L-FAMILY
         WHEN WS-PATH = "snowball"
             MOVE 20 TO L-FAMILY
         WHEN WS-PATH = "egg"
             MOVE 21 TO L-FAMILY
         WHEN WS-PATH = "ender_pearl"
             MOVE 22 TO L-FAMILY
         WHEN WS-PATH = "experience_bottle"
             MOVE 23 TO L-FAMILY
         WHEN WS-PATH = "fireball"
             MOVE 24 TO L-FAMILY
         WHEN WS-PATH = "small_fireball"
             MOVE 25 TO L-FAMILY
         WHEN WS-PATH = "wind_charge"
             MOVE 26 TO L-FAMILY
         WHEN WS-PATH = "breeze_wind_charge"
             MOVE 26 TO L-FAMILY
             MOVE 1 TO L-SUB
         WHEN WS-PATH = "splash_potion"
             MOVE 27 TO L-FAMILY
         WHEN WS-PATH = "lingering_potion"
             MOVE 27 TO L-FAMILY
             MOVE 1 TO L-SUB
         WHEN WS-PATH = "ominous_item_spawner"
             MOVE 28 TO L-FAMILY
         WHEN WS-PATH = "firework_rocket"
             MOVE 29 TO L-FAMILY
         WHEN WS-PATH = "eye_of_ender"
             MOVE 30 TO L-FAMILY
         WHEN WS-PATH = "shulker_bullet"
             MOVE 31 TO L-FAMILY
         WHEN WS-PATH = "llama_spit"
             MOVE 32 TO L-FAMILY
         WHEN OTHER
             CALL "BOAT-KIND" USING L-TYPE WS-BOAT
             IF WS-BOAT > 0
                 MOVE 12 TO L-FAMILY
                 MOVE WS-BOAT TO L-SUB
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SUMMON-FAMILY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-CAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MOB                 BINARY-LONG.
 01 WS-STD                 BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-CAN.
     CALL "MOB-INDEX" USING L-TYPE WS-MOB
     CALL "STDMOB-INDEX" USING L-TYPE WS-STD
     CALL "SUMMON-FAMILY" USING L-TYPE WS-FAMILY WS-SUB
     MOVE 0 TO L-CAN
     IF WS-MOB > 0 OR WS-STD > 0 OR WS-FAMILY > 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM SUMMON-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-KEYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOT                 BINARY-LONG.
 COPY EBDATA.
 COPY ENKSTAGE.
 COPY E8DATA.
 01 L-BSTATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOT EB-DATA KD-DATA E8-DATA L-BSTATE.
     INITIALIZE EB-DATA KD-DATA E8-DATA
     MOVE -1 TO E8-STATE
     MOVE 80 TO E8-FUSE
     MOVE 0 TO L-BSTATE
     IF L-ROOT > 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "NBX-TO-BUFFER" USING PB-BUFFER L-ROOT
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         MOVE 0 TO PB-POS
         PERFORM UNTIL PB-ERROR = 1
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
             IF WS-TYPE = 0
                 EXIT PERFORM
             END-IF
             CALL "ENTITY-BASE-KEY" USING PB-BUFFER WS-TYPE WN EB-DATA WS-HANDLED
             IF WS-HANDLED = 0
                 CALL "ENTITY-KEEP-KEY" USING PB-BUFFER WS-TYPE WN KD-DATA WS-HANDLED
             END-IF
             IF WS-HANDLED = 0
                 CALL "ENTITY8-NBT-KEY" USING PB-BUFFER WS-TYPE WN E8-DATA WS-HANDLED
             END-IF
             IF WS-HANDLED = 0 AND WN = "block_state" AND WS-TYPE = 10
                 CALL "BLOCKSTATE-NBT-READ" USING PB-BUFFER L-BSTATE
                 MOVE 1 TO WS-HANDLED
             END-IF
             IF WS-HANDLED = 0
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-IF
         END-PERFORM
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM SUMMON-KEYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-LOAD.
*> USING dimension row, entity type id, x, y, z (FLOAT-LONG), root node, row out. The id of the type and the Pos of the command are put in the tree (the entity is moved to the position, 16 section 5.8 step 4), which is
*> wrapped as the entities/ payload {Entities: [root]} and read by ENTITY-NBT-READ, which creates the entity and the passengers of its Passengers list. The entity is the row of the first id handed out by
*> the read (the passengers are created after their vehicle); 0 when the loader made none (an empty stack, a refused or duplicate UUID).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY NBXTREE.
 COPY PROTO.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-T-LIST              BINARY-LONG VALUE 9.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-WRAP                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-K-ENTITIES          PIC X(16) VALUE "Entities".
 01 WS-K-ID                PIC X(16) VALUE "id".
 01 WS-K-POS               PIC X(16) VALUE "Pos".
 01 WS-ID                  PIC X(256).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-FIRST-ID            BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-ROOT L-ROW.
     MOVE 0 TO L-ROW
     MOVE SPACES TO WS-ID
     IF ET-KEY(L-TYPE + 1)(1:10) = "minecraft:" OR ET-KEY(L-TYPE + 1)(1:12) = "cobolcraft:"
         MOVE ET-KEY(L-TYPE + 1) TO WS-ID
     ELSE
         STRING "minecraft:" DELIMITED BY SIZE ET-KEY(L-TYPE + 1) DELIMITED BY SPACE INTO WS-ID
     END-IF
     COMPUTE WS-ID-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-ID))
     CALL "NBX-PUT-STR-N" USING L-ROOT WS-K-ID WS-ID WS-ID-LENGTH
     CALL "NBX-PUT-NUMS" USING L-ROOT WS-K-POS WS-T-DOUBLE WS-THREE L-X L-Y L-Z
     CALL "NBX-NEW" USING WS-T-COMPOUND WS-WRAP
     CALL "NBX-NEW" USING WS-T-LIST WS-LIST
     CALL "NBX-SET-N" USING WS-WRAP WS-K-ENTITIES WS-LIST
     CALL "NBX-CLONE" USING L-ROOT WS-COPY
     CALL "NBX-ADD" USING WS-LIST WS-COPY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "NBX-TO-BUFFER" USING PB-BUFFER WS-WRAP
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBX-FREE" USING WS-WRAP
     MOVE 0 TO PB-POS
     MOVE CW-NEXT-ENTITY-ID TO WS-FIRST-ID
     CALL "ENTITY-NBT-READ" USING L-DIM PB-BUFFER WS-OUTCOME
     CALL "PB-FREE" USING PB-BUFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-FIRST-ID
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SUMMON-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FB-SPAWN-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-ROW.
     CALL "FB-TYPE" USING WS-TYPE
     CALL "ENTITY-ALLOC" USING L-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
     MOVE WS-TYPE TO EN-TYPE(L-ROW)
     CALL "ENTITY-SET-UUID" USING L-ROW
     MOVE L-DIM TO EN-DIM(L-ROW)
     MOVE L-X TO EN-X(L-ROW)
     MOVE L-Y TO EN-Y(L-ROW)
     MOVE L-Z TO EN-Z(L-ROW)
     MOVE L-STATE TO EN-FB-STATE(L-ROW)
     CALL "ENTITY-TRACK" USING L-ROW
     GOBACK.
 END PROGRAM FB-SPAWN-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SUMMON-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CONTENT.
 COPY PROJSTATE.
 COPY PROTO.
 COPY EBDATA.
 COPY ENKSTAGE.
 COPY E8DATA.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-K-MOTION            PIC X(16) VALUE "Motion".
 01 WS-K-ROTATION          PIC X(16) VALUE "Rotation".
 01 WS-K-ITEM-UP           PIC X(16) VALUE "Item".
 01 WS-K-ITEM              PIC X(16) VALUE "item".
 01 WS-K-DISPLAY           PIC X(16) VALUE "item_display".
 01 WS-K-COLOR             PIC X(16) VALUE "color".
 01 WS-N-VALUE             PIC X(32) VALUE "Value".
 01 WS-N-RADIUS            PIC X(32) VALUE "Radius".
 01 WS-N-DURATION          PIC X(32) VALUE "Duration".
 01 WS-N-WAIT              PIC X(32) VALUE "WaitTime".
 01 WS-N-REAPP             PIC X(32) VALUE "ReapplicationDelay".
 01 WS-N-FUSE              PIC X(32) VALUE "fuse".
 01 WS-N-SHOW-BOTTOM       PIC X(32) VALUE "ShowBottom".
 01 WS-N-SMALL             PIC X(32) VALUE "Small".
 01 WS-N-ARMS              PIC X(32) VALUE "ShowArms".
 01 WS-N-BASE-PLATE        PIC X(32) VALUE "NoBasePlate".
 01 WS-N-MARKER            PIC X(32) VALUE "Marker".
 01 WS-N-INVISIBLE         PIC X(32) VALUE "Invisible".
 01 WS-N-FACING            PIC X(32) VALUE "Facing".
 01 WS-N-FACING-2D         PIC X(32) VALUE "facing".
 01 WS-N-ITEM-ROTATION     PIC X(32) VALUE "ItemRotation".
 01 WS-N-WIDTH             PIC X(32) VALUE "width".
 01 WS-N-HEIGHT            PIC X(32) VALUE "height".
 01 WS-N-RESPONSE          PIC X(32) VALUE "response".
 01 WS-N-DAMAGE            PIC X(32) VALUE "damage".
 01 WS-N-POWER             PIC X(32) VALUE "ExplosionPower".
 01 WS-N-LIFETIME          PIC X(32) VALUE "LifeTime".
 01 WS-NUM                 FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BSTATE              BINARY-LONG.
 01 WS-HAS-MOTION          BINARY-LONG.
 01 WS-HAS-ROTATION        BINARY-LONG.
 01 WS-MOTION              BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ROWI                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-YAW-S               FLOAT-SHORT.
 01 WS-PITCH-S             FLOAT-SHORT.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-WAIT                BINARY-LONG.
 01 WS-REAPP               BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-DAMAGE              FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-DIR-X               FLOAT-LONG VALUE 0.
 01 WS-DOWN                FLOAT-LONG VALUE -1.
 01 WS-DIR-Z               FLOAT-LONG VALUE 0.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-STAND-FLAGS         BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-PROJ-KIND           BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SAND                PIC X(112) VALUE "minecraft:sand".
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-DISPLAY             BINARY-LONG.
 01 WS-LIFE                BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
*> The serialized names of the dye colours (45-9 section 10) and of the item display types (45-8 section 3.9.2), in ordinal order.
 01 WS-DYE-NAMES.
    05 FILLER              PIC X(12) VALUE "white".
    05 FILLER              PIC X(12) VALUE "orange".
    05 FILLER              PIC X(12) VALUE "magenta".
    05 FILLER              PIC X(12) VALUE "light_blue".
    05 FILLER              PIC X(12) VALUE "yellow".
    05 FILLER              PIC X(12) VALUE "lime".
    05 FILLER              PIC X(12) VALUE "pink".
    05 FILLER              PIC X(12) VALUE "gray".
    05 FILLER              PIC X(12) VALUE "light_gray".
    05 FILLER              PIC X(12) VALUE "cyan".
    05 FILLER              PIC X(12) VALUE "purple".
    05 FILLER              PIC X(12) VALUE "blue".
    05 FILLER              PIC X(12) VALUE "brown".
    05 FILLER              PIC X(12) VALUE "green".
    05 FILLER              PIC X(12) VALUE "red".
    05 FILLER              PIC X(12) VALUE "black".
 01 WS-DYE-TABLE REDEFINES WS-DYE-NAMES.
    05 WS-DYE              PIC X(12) OCCURS 16 TIMES.
 01 WS-DISPLAY-NAMES.
    05 FILLER              PIC X(24) VALUE "none".
    05 FILLER              PIC X(24) VALUE "thirdperson_lefthand".
    05 FILLER              PIC X(24) VALUE "thirdperson_righthand".
    05 FILLER              PIC X(24) VALUE "firstperson_lefthand".
    05 FILLER              PIC X(24) VALUE "firstperson_righthand".
    05 FILLER              PIC X(24) VALUE "head".
    05 FILLER              PIC X(24) VALUE "gui".
    05 FILLER              PIC X(24) VALUE "ground".
    05 FILLER              PIC X(24) VALUE "fixed".
    05 FILLER              PIC X(24) VALUE "on_shelf".
 01 WS-DISPLAY-TABLE REDEFINES WS-DISPLAY-NAMES.
    05 WS-DISPLAY-NAME     PIC X(24) OCCURS 10 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-X L-Y L-Z L-ROOT L-ROW.
     MOVE 0 TO L-ROW
     CALL "SUMMON-FAMILY" USING L-TYPE WS-FAMILY WS-SUB
     IF WS-FAMILY = 0
         GOBACK
     END-IF
*>   The entity type key in full form, for the spawn programs that find their type by key.
     MOVE SPACES TO WS-KEY
     IF ET-KEY(L-TYPE + 1)(1:10) = "minecraft:"
         MOVE ET-KEY(L-TYPE + 1) TO WS-KEY
     ELSE
         STRING "minecraft:" DELIMITED BY SIZE ET-KEY(L-TYPE + 1) DELIMITED BY SPACE INTO WS-KEY
     END-IF
*>   Motion and Rotation (45-1 section 5): a list of three doubles and of two floats.
     MOVE 0 TO WS-VX WS-VY WS-VZ WS-YAW WS-PITCH WS-HAS-MOTION WS-HAS-ROTATION
     IF L-ROOT > 0
         CALL "NBX-FIND-N" USING L-ROOT WS-K-MOTION WS-LIST
         IF WS-LIST > 0
             MOVE 1 TO WS-HAS-MOTION
             CALL "NBX-GET-ELEM" USING WS-LIST WS-ONE WS-VX WS-FOUND
             MOVE WS-TWO TO WS-INT
             CALL "NBX-GET-ELEM" USING WS-LIST WS-INT WS-VY WS-FOUND
             MOVE WS-THREE TO WS-INT
             CALL "NBX-GET-ELEM" USING WS-LIST WS-INT WS-VZ WS-FOUND
         END-IF
         CALL "NBX-FIND-N" USING L-ROOT WS-K-ROTATION WS-LIST
         IF WS-LIST > 0
             MOVE 1 TO WS-HAS-ROTATION
             CALL "NBX-GET-ELEM" USING WS-LIST WS-ONE WS-YAW WS-FOUND
             MOVE WS-TWO TO WS-INT
             CALL "NBX-GET-ELEM" USING WS-LIST WS-INT WS-PITCH WS-FOUND
         END-IF
     END-IF
     CALL "SUMMON-KEYS" USING L-ROOT EB-DATA KD-DATA E8-DATA WS-BSTATE
     EVALUATE WS-FAMILY
         WHEN 1
*>           A ground item with no stack (no Item, air or an unknown id) is discarded at once by the loader (45-8 section 3.1): nothing is made.
             CALL "SUMMON-ITEM" USING L-ROOT WS-K-ITEM-UP WS-ITEM WS-COUNT
             IF WS-ITEM > 0
                 CALL "SUMMON-LOAD" USING L-DIM L-TYPE L-X L-Y L-Z L-ROOT L-ROW
             END-IF
         WHEN 2
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-VALUE WS-NUM WS-FOUND
             COMPUTE WS-COUNT = WS-NUM
             CALL "XP-ORB-SPAWN" USING L-DIM L-X L-Y L-Z WS-COUNT L-ROW
         WHEN 3
             CALL "TNT-PRIME-FUSE" USING L-DIM L-X L-Y L-Z E8-FUSE L-ROW
             MOVE WS-VX TO EN-VX(L-ROW)
             MOVE WS-VY TO EN-VY(L-ROW)
             MOVE WS-VZ TO EN-VZ(L-ROW)
         WHEN 4
             IF E8-STATE <= 0
                 CALL "CONTENT-BLOCK-BY-KEY" USING WS-SAND WS-BLOCK WS-BLOCK-ROW WS-STATUS
                 CALL "CONTENT-STATE-DEFAULT" USING WS-BLOCK E8-STATE WS-STATUS
             END-IF
             CALL "FB-SPAWN-AT" USING L-DIM L-X L-Y L-Z E8-STATE L-ROW
             CALL "ENTITY8-NBT-APPLY" USING L-ROW E8-DATA
         WHEN 5
             MOVE 3.0 TO WS-RADIUS
             MOVE -1 TO WS-DURATION
             MOVE 20 TO WS-WAIT WS-REAPP
             CALL "SUMMON-NUM" USING L-ROOT WS-N-RADIUS WS-RADIUS WS-FOUND
             MOVE WS-DURATION TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-DURATION WS-NUM WS-FOUND
             COMPUTE WS-DURATION = WS-NUM
             MOVE WS-WAIT TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-WAIT WS-NUM WS-FOUND
             COMPUTE WS-WAIT = WS-NUM
             MOVE WS-REAPP TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-REAPP WS-NUM WS-FOUND
             COMPUTE WS-REAPP = WS-NUM
             CALL "CLOUD-SPAWN" USING L-DIM L-X L-Y L-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-Z1 L-ROW
         WHEN 6
             CALL "LIGHTNING-SPAWN" USING L-DIM L-X L-Y L-Z WS-Z1 L-ROW
         WHEN 7
             MOVE 1 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-SHOW-BOTTOM WS-NUM WS-FOUND
             COMPUTE WS-INT = WS-NUM
             CALL "CRYSTAL-SPAWN" USING L-DIM L-X L-Y L-Z WS-INT L-ROW
         WHEN 8
             CALL "ARMOR-STAND-SPAWN" USING L-DIM L-X L-Y L-Z WS-YAW L-ROW
             CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
             MOVE 0 TO WS-STAND-FLAGS
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-SMALL WS-NUM WS-FOUND
             IF WS-NUM NOT = 0
                 ADD 1 TO WS-STAND-FLAGS
             END-IF
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-ARMS WS-NUM WS-FOUND
             IF WS-NUM NOT = 0
                 ADD 4 TO WS-STAND-FLAGS
             END-IF
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-BASE-PLATE WS-NUM WS-FOUND
             IF WS-NUM NOT = 0
                 ADD 8 TO WS-STAND-FLAGS
             END-IF
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-MARKER WS-NUM WS-FOUND
             IF WS-NUM NOT = 0
                 ADD 16 TO WS-STAND-FLAGS
             END-IF
             MOVE WS-STAND-FLAGS TO PJ-I1(WS-SLOT)
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-INVISIBLE WS-NUM WS-FOUND
             IF WS-NUM NOT = 0
                 MOVE 1 TO PJ-I4(WS-SLOT)
             END-IF
             CALL "DECOR-DATA-SYNC" USING L-ROW
         WHEN 9
*>           Facing is a 3D legacy id (45-9 section 7.1), DOWN when absent; ItemRotation a Byte.
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-FACING WS-NUM WS-FOUND
             COMPUTE WS-DIR = FUNCTION MOD(FUNCTION ABS(WS-NUM), 6)
             MOVE 12 TO WS-PJ
             CALL "DECOR-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-DIR L-ROW
             IF L-ROW > 0
                 CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
                 CALL "SUMMON-ITEM" USING L-ROOT WS-K-ITEM-UP WS-ITEM WS-COUNT
                 MOVE WS-ITEM TO PJ-I2(WS-SLOT)
                 MOVE 0 TO WS-NUM
                 CALL "SUMMON-NUM" USING L-ROOT WS-N-ITEM-ROTATION WS-NUM WS-FOUND
                 COMPUTE PJ-I3(WS-SLOT) = FUNCTION MOD(FUNCTION ABS(WS-NUM), 8)
                 MOVE WS-SUB TO PJ-I4(WS-SLOT)
                 CALL "DECOR-DATA-SYNC" USING L-ROW
             END-IF
         WHEN 10
*>           The painting's facing is a 2D legacy id (SOUTH 0, WEST 1, NORTH 2, EAST 3), SOUTH when absent; DECOR-SPAWN takes the 3D id.
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-FACING-2D WS-NUM WS-FOUND
             COMPUTE WS-INT = FUNCTION MOD(FUNCTION ABS(WS-NUM), 4)
             EVALUATE WS-INT
                 WHEN 0
                     MOVE 3 TO WS-DIR
                 WHEN 1
                     MOVE 4 TO WS-DIR
                 WHEN 2
                     MOVE 2 TO WS-DIR
                 WHEN OTHER
                     MOVE 5 TO WS-DIR
             END-EVALUATE
             MOVE 13 TO WS-PJ
             CALL "DECOR-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-DIR L-ROW
         WHEN 11
             CALL "MINECART-SPAWN" USING WS-SUB L-DIM L-X L-Y L-Z L-ROW
         WHEN 12
             CALL "BOAT-SPAWN" USING L-DIM L-X L-Y L-Z WS-YAW WS-KEY L-ROW
         WHEN 13
             MOVE 1 TO WS-WIDTH WS-HEIGHT
             CALL "SUMMON-NUM" USING L-ROOT WS-N-WIDTH WS-WIDTH WS-FOUND
             CALL "SUMMON-NUM" USING L-ROOT WS-N-HEIGHT WS-HEIGHT WS-FOUND
             MOVE 0 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-RESPONSE WS-NUM WS-FOUND
             MOVE 0 TO WS-INT
             IF WS-NUM NOT = 0
                 MOVE 1 TO WS-INT
             END-IF
             CALL "INTERACTION-SPAWN" USING L-DIM L-X L-Y L-Z WS-WIDTH WS-HEIGHT WS-INT L-ROW
         WHEN 14
             CALL "BDISPLAY-SPAWN" USING L-DIM L-X L-Y L-Z WS-BSTATE L-ROW
         WHEN 15
             CALL "SUMMON-ITEM" USING L-ROOT WS-K-ITEM WS-ITEM WS-COUNT
             CALL "SUMMON-TEXT" USING L-ROOT WS-K-DISPLAY WS-NAME WS-NAME-LENGTH
             MOVE 0 TO WS-DISPLAY
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
                 IF WS-NAME = WS-DISPLAY-NAME(WS-I)
                     COMPUTE WS-DISPLAY = WS-I - 1
                 END-IF
             END-PERFORM
             CALL "IDISPLAY-SPAWN" USING L-DIM L-X L-Y L-Z WS-ITEM WS-DISPLAY L-ROW
         WHEN 16
             CALL "MANNEQUIN-SPAWN" USING L-DIM L-X L-Y L-Z L-ROW
         WHEN 17
*>           The dye name of color (45-9 section 10): white when absent or unknown.
             CALL "SUMMON-TEXT" USING L-ROOT WS-K-COLOR WS-NAME WS-NAME-LENGTH
             MOVE 0 TO WS-INT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                 IF WS-NAME = WS-DYE(WS-I)
                     COMPUTE WS-INT = WS-I - 1
                 END-IF
             END-PERFORM
             CALL "CUSHION-SPAWN" USING L-DIM L-X L-Y L-Z WS-INT L-ROW
         WHEN 18
*>           The marker is an entity row with no state of its own and no behaviour (45-8 section 3.7); its tracking range keeps it from the clients.
             CALL "ENTITY-ALLOC" USING L-ROW
             CALL "ENTITY-NEW-ID" USING EN-ID(L-ROW)
             MOVE L-TYPE TO EN-TYPE(L-ROW)
             CALL "ENTITY-SET-UUID" USING L-ROW
             MOVE L-DIM TO EN-DIM(L-ROW)
             MOVE L-X TO EN-X(L-ROW)
             MOVE L-Y TO EN-Y(L-ROW)
             MOVE L-Z TO EN-Z(L-ROW)
             MOVE 1 TO EN-HEALTH(L-ROW)
             CALL "ENTITY-TRACK" USING L-ROW
         WHEN 19
             MOVE 2 TO WS-DAMAGE
             CALL "SUMMON-NUM" USING L-ROOT WS-N-DAMAGE WS-DAMAGE WS-FOUND
             COMPUTE WS-INT = WS-DAMAGE * 1000
             CALL "ARROW-SPAWN" USING L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-INT WS-Z1 L-ROW
         WHEN 20
             MOVE 3 TO WS-PROJ-KIND
             CALL "PROJ-SPAWN" USING WS-PROJ-KIND L-DIM L-X L-Y L-Z WS-DIR-X WS-DOWN WS-DIR-Z WS-Z1 WS-Z2 L-ROW
         WHEN 21
             MOVE 6 TO WS-PJ
             CALL "THROWN-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-Z1 L-ROW
         WHEN 22
             MOVE 4 TO WS-PJ
             CALL "THROWN-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-Z1 L-ROW
         WHEN 23
             MOVE 40 TO WS-PJ
             CALL "THROWN-SPAWN" USING WS-PJ WS-KEY L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-Z1 L-ROW
         WHEN 24
             MOVE 1 TO WS-PROJ-KIND
             MOVE 1 TO WS-NUM
             CALL "SUMMON-NUM" USING L-ROOT WS-N-POWER WS-NUM WS-FOUND
             COMPUTE WS-INT = WS-NUM
             CALL "PROJ-SPAWN" USING WS-PROJ-KIND L-DIM L-X L-Y L-Z WS-DIR-X WS-DOWN WS-DIR-Z WS-INT WS-Z2 L-ROW
         WHEN 25
             MOVE 2 TO WS-PROJ-KIND
             CALL "PROJ-SPAWN" USING WS-PROJ-KIND L-DIM L-X L-Y L-Z WS-DIR-X WS-DOWN WS-DIR-Z WS-Z1 WS-Z2 L-ROW
         WHEN 26
             CALL "WIND-SPAWN" USING WS-SUB L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-Z1 L-ROW
         WHEN 27
             CALL "POTION-SPAWN" USING WS-SUB L-DIM L-X L-Y L-Z WS-VX WS-VY WS-VZ WS-Z1 L-ROW
         WHEN 28
             CALL "SUMMON-ITEM" USING L-ROOT WS-K-ITEM WS-ITEM WS-COUNT
             CALL "OIS-SPAWN" USING L-DIM L-X L-Y L-Z WS-ITEM WS-COUNT L-ROW
         WHEN 29
             CALL "FIREWORK-SPAWN" USING L-DIM L-X L-Y L-Z WS-LIFE WS-Z1 WS-Z2 WS-Z3 L-ROW
         WHEN 30
             MOVE L-X TO WS-TX
             MOVE L-Y TO WS-TY
             MOVE L-Z TO WS-TZ
             CALL "EYE-SPAWN" USING L-DIM L-X L-Y L-Z WS-TX WS-TY WS-TZ WS-ONE WS-Z1 L-ROW
         WHEN 31
             MOVE 4 TO WS-PROJ-KIND
             CALL "PROJ-SPAWN" USING WS-PROJ-KIND L-DIM L-X L-Y L-Z WS-DIR-X WS-DOWN WS-DIR-Z WS-Z1 WS-Z2 L-ROW
         WHEN OTHER
             MOVE 5 TO WS-PROJ-KIND
             CALL "PROJ-SPAWN" USING WS-PROJ-KIND L-DIM L-X L-Y L-Z WS-DIR-X WS-DOWN WS-DIR-Z WS-Z1 WS-Z2 L-ROW
     END-EVALUATE
     IF L-ROW > 0 AND WS-FAMILY NOT = 1
         CALL "ENTITY-BASE-APPLY" USING L-ROW EB-DATA
         CALL "ENTITY-KEEP-APPLY" USING L-ROW KD-DATA
*>       Entity.load: Motion is the velocity (zero when absent), Rotation the yaw and pitch; a projectile that took the direction of its spawn program is turned to the rotation of the tree (0 when absent).
         MOVE WS-VX TO EN-VX(L-ROW)
         MOVE WS-VY TO EN-VY(L-ROW)
         MOVE WS-VZ TO EN-VZ(L-ROW)
         IF WS-FAMILY = 20 OR WS-FAMILY = 24 OR WS-FAMILY = 25 OR WS-FAMILY = 31 OR WS-FAMILY = 32
             MOVE 1 TO WS-HAS-ROTATION
         END-IF
         IF WS-FAMILY = 9 OR WS-FAMILY = 10
             MOVE 0 TO WS-HAS-ROTATION
         END-IF
         IF WS-HAS-ROTATION = 1
             MOVE WS-YAW TO WS-YAW-S
             MOVE WS-PITCH TO WS-PITCH-S
             MOVE EN-X(L-ROW) TO WS-TX
             MOVE EN-Y(L-ROW) TO WS-TY
             MOVE EN-Z(L-ROW) TO WS-TZ
             CALL "ENTITY-MOVE" USING L-ROW WS-TX WS-TY WS-TZ WS-YAW-S WS-PITCH-S EN-ON-GROUND(L-ROW)
         END-IF
         IF WS-HAS-MOTION = 1
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "SET-ENTITY-MOTION-BUILD" USING EN-ID(L-ROW) WS-VX WS-VY WS-VZ PB-BUFFER
             CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SUMMON-SPAWN.
