*> Shared tables of the overworld hostile mobs (002-lane-mobsfull-h3; docs/protocol/20 section 3).
*>
*> Entry points:
*>   STDMOB-DIFFICULTY USING difficulty id, time, inhabited time (BINARY-DOUBLE ticks), moon brightness (thousandths), eff out (thousandths)
*>   STDMOB-SPECIAL USING eff (thousandths), multiplier out (thousandths)
*>   STDMOB-BRIGHTNESS USING light 0 to 15, ambient (thousandths), brightness out (thousandths)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-DIFFICULTY.
*> Effective (local) difficulty (3.2). a = clamp((T - 72000) / 1440000, 0, 1) x 0.25; base = 0.75 + a; b = clamp(I / 3600000, 0, 1) x (1 on Hard, else
*> 0.75) + clamp(M x 0.25, 0, a), halved on Easy; eff = difficulty id x (base + b); Peaceful 0. All in thousandths (truncated).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-M                   BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-INHABITED            BINARY-DOUBLE.
 01 L-MOON                 BINARY-LONG.
 01 L-EFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-TIME L-INHABITED L-MOON L-EFF.
     MOVE 0 TO L-EFF
     IF L-DIFFICULTY = 0
         GOBACK
     END-IF
     COMPUTE WS-T = FUNCTION MAX(0, FUNCTION MIN(1440000, L-TIME - 72000))
     COMPUTE WS-A = WS-T * 250 / 1440000
     COMPUTE WS-B = FUNCTION MAX(0, FUNCTION MIN(3600000, L-INHABITED)) * 750 / 3600000
     IF L-DIFFICULTY = 3
         COMPUTE WS-B = FUNCTION MAX(0, FUNCTION MIN(3600000, L-INHABITED)) * 1000 / 3600000
     END-IF
     COMPUTE WS-M = FUNCTION MAX(0, FUNCTION MIN(WS-A, L-MOON * 250 / 1000))
     COMPUTE WS-B = WS-B + WS-M
     IF L-DIFFICULTY = 1
         COMPUTE WS-B = WS-B / 2
     END-IF
     COMPUTE L-EFF = L-DIFFICULTY * (750 + WS-A + WS-B)
     GOBACK.
 END PROGRAM STDMOB-DIFFICULTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPECIAL.
*> The special multiplier of an effective difficulty (3.2): 0 below 2, 1 above 4, else (eff - 2) / 2 (thousandths).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFF                  BINARY-LONG.
 01 L-MULT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EFF L-MULT.
     EVALUATE TRUE
         WHEN L-EFF < 2000
             MOVE 0 TO L-MULT
         WHEN L-EFF > 4000
             MOVE 1000 TO L-MULT
         WHEN OTHER
             COMPUTE L-MULT = (L-EFF - 2000) / 2
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-SPECIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BRIGHTNESS.
*> Light-dependent brightness (3.3): v = l / (60 - 3 l) (f / (4 - 3 f) with f = l / 15), result v + ambient (1 - v), thousandths. Light 13 and more is above 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-AMBIENT L-B.
     COMPUTE WS-V = L-LIGHT * 1000 / (60 - 3 * L-LIGHT)
     COMPUTE L-B = WS-V + L-AMBIENT * (1000 - WS-V) / 1000
     GOBACK.
 END PROGRAM STDMOB-BRIGHTNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HEAD-MAX.
*> USING tier (0 leather, 1 copper, 2 golden, 3 chainmail, 4 iron, 5 diamond), durability out: the maximum damage of the helmet of that tier (25 section 8.4:
*> 55, 121, 77, 165, 165, 363); 0 for another tier.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIER                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIER L-MAX.
     EVALUATE L-TIER
         WHEN 0 MOVE 55 TO L-MAX
         WHEN 1 MOVE 121 TO L-MAX
         WHEN 2 MOVE 77 TO L-MAX
         WHEN 3 MOVE 165 TO L-MAX
         WHEN 4 MOVE 165 TO L-MAX
         WHEN 5 MOVE 363 TO L-MAX
         WHEN OTHER MOVE 0 TO L-MAX
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-HEAD-MAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SHELTERED.
*> USING dim, x, y, z (BINARY-LONG feet cell), sheltered out: 1 when the daylight burn of a mob in that cell is stopped (3.5 step 4): its feet are in water or powder
*> snow, the sky is not visible from its eye cell (the sky light there is below 15), or it rains (the dimension's rain level above 0.2) with the sky open. The
*> biome's precipitation kind is not read (open item), so any rain counts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SHELTERED            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SHELTERED.
     MOVE 0 TO L-SHELTERED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE 0 TO WS-N
         INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "water" ALL "powder_snow"
         IF WS-N > 0
             MOVE 1 TO L-SHELTERED
         END-IF
     END-IF
     COMPUTE WS-EYE = L-Y + 1
     CALL "STDMOB-LIGHTS" USING L-DIM L-X WS-EYE L-Z WS-SKY WS-BLK
     IF WS-SKY < 15
         MOVE 1 TO L-SHELTERED
     END-IF
     CALL "WEATHER-RAINING" USING L-DIM WS-RAIN
     IF WS-RAIN = 1
         MOVE 1 TO L-SHELTERED
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SHELTERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-EQUIP-ROLL.
*> USING xoro state, difficulty id, special multiplier (thousandths), tier out (-1 none, else 0 leather to 5 diamond), slots out (0 to 4) (3.6 steps 1 and 2):
*> with probability 0.15 x special: tier nextInt(3), then 3 attempts that each add 1 with probability 0.1087; slots are filled head, chest, legs, feet,
*> and before every slot but the first a draw below the stop chance (0.1 on Hard, 0.25 otherwise) ends the list. The floats are nextDouble draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 01 L-TIER                 BINARY-LONG.
 01 L-SLOTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIFFICULTY L-SPECIAL L-TIER L-SLOTS.
     MOVE -1 TO L-TIER
     MOVE 0 TO L-SLOTS
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE WS-P = 0.15 * L-SPECIAL / 1000
     IF WS-D >= WS-P
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-THREE L-TIER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         IF WS-D < 0.1087
             ADD 1 TO L-TIER
         END-IF
     END-PERFORM
     MOVE 0.25 TO WS-P
     IF L-DIFFICULTY = 3
         MOVE 0.1 TO WS-P
     END-IF
     MOVE 1 TO L-SLOTS
     MOVE 0 TO WS-DONE
     PERFORM UNTIL L-SLOTS >= 4 OR WS-DONE = 1
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         IF WS-D < WS-P
             MOVE 1 TO WS-DONE
         ELSE
             ADD 1 TO L-SLOTS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-EQUIP-ROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-EQUIP-KEY.
*> USING tier (0 leather, 1 copper, 2 golden, 3 chainmail, 4 iron, 5 diamond), slot (1 head, 2 chest, 3 legs, 4 feet), key out (PIC X(40)): the item key of
*> that armour piece (3.6 step 3); spaces for a tier above 5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TIER-NAME           PIC X(10).
 01 WS-SLOT-NAME           PIC X(10).
 LINKAGE SECTION.
 01 L-TIER                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 PROCEDURE DIVISION USING L-TIER L-SLOT L-KEY.
     MOVE SPACES TO L-KEY WS-TIER-NAME WS-SLOT-NAME
     EVALUATE L-TIER
         WHEN 0 MOVE "leather" TO WS-TIER-NAME
         WHEN 1 MOVE "copper" TO WS-TIER-NAME
         WHEN 2 MOVE "golden" TO WS-TIER-NAME
         WHEN 3 MOVE "chainmail" TO WS-TIER-NAME
         WHEN 4 MOVE "iron" TO WS-TIER-NAME
         WHEN 5 MOVE "diamond" TO WS-TIER-NAME
         WHEN OTHER GOBACK
     END-EVALUATE
     EVALUATE L-SLOT
         WHEN 1 MOVE "helmet" TO WS-SLOT-NAME
         WHEN 2 MOVE "chestplate" TO WS-SLOT-NAME
         WHEN 3 MOVE "leggings" TO WS-SLOT-NAME
         WHEN OTHER MOVE "boots" TO WS-SLOT-NAME
     END-EVALUATE
     STRING "minecraft:" DELIMITED BY SIZE WS-TIER-NAME DELIMITED BY SPACE "_" DELIMITED BY SIZE
         WS-SLOT-NAME DELIMITED BY SPACE INTO L-KEY
     GOBACK.
 END PROGRAM STDMOB-EQUIP-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HAND-KEY.
*> USING hand (EN-HAND: 1 iron sword, 2 iron spear, 3 iron shovel, 4 bow, 10 iron axe, 11 crossbow, 12 stone sword, 14 golden sword, 15 golden spear, 16 golden axe), key out (PIC X(40)): the item key of the main-hand item; spaces for 0 or an unknown value.; 14 golden sword, 15 golden spear (lane p49s; its codes 11 to 13 are 14, 15 and 11 here)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-ITEM                BINARY-LONG.
 01 WS-BARE                PIC X(32).
 LINKAGE SECTION.
 01 L-HAND                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 PROCEDURE DIVISION USING L-HAND L-KEY.
     MOVE SPACES TO L-KEY
     IF L-HAND >= 1000 AND L-HAND - 1000 < IT-COUNT
         COMPUTE WS-ITEM = L-HAND - 1000
         CALL "PGW-ITEM-KEY" USING WS-ITEM WS-BARE
         STRING "minecraft:" DELIMITED BY SIZE WS-BARE DELIMITED BY SPACE INTO L-KEY
     END-IF
     EVALUATE L-HAND
         WHEN 1 MOVE "minecraft:iron_sword" TO L-KEY
         WHEN 2 MOVE "minecraft:iron_spear" TO L-KEY
         WHEN 3 MOVE "minecraft:iron_shovel" TO L-KEY
         WHEN 4 MOVE "minecraft:bow" TO L-KEY
         WHEN 9 MOVE "minecraft:warped_fungus_on_a_stick" TO L-KEY
         WHEN 10 MOVE "minecraft:iron_axe" TO L-KEY
         WHEN 11 MOVE "minecraft:crossbow" TO L-KEY
         WHEN 12 MOVE "minecraft:stone_sword" TO L-KEY
         WHEN 14 MOVE "minecraft:golden_sword" TO L-KEY
         WHEN 15 MOVE "minecraft:golden_spear" TO L-KEY
         WHEN 16 MOVE "minecraft:golden_axe" TO L-KEY
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-HAND-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-EQUIP-BUILD.
*> USING tracker row, PB-BUFFER (empty): Set Equipment (0x68) of the armour in EN-EQUIP (10 x (tier + 1) + slots worn) and the main-hand item EN-HAND: slot
*> ordinals main hand 0, feet 2, legs 3, chest 4, head 5; bit 0x80 on every pair but the last (armour head to feet, then the hand). An item the set does
*> not know, and a broken helmet (EN-HEAD-WEAR -1), is sent as an empty stack. Nothing is written for a row with neither armour nor weapon. A piglin's golden pieces (EN-PIG-GEAR bits,
*> head first) replace the prefix count: tier 2, only the slots whose bit is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO REPLACING LEADING ==PB-== BY ==EQ-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 104.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT-LIST.
    05 WS-SLOT-NO          BINARY-LONG OCCURS 4 TIMES.
 01 WS-GEAR                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-ORDINAL             BINARY-LONG.
 01 WS-KEY40               PIC X(40).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE 0 TO WS-SLOTS WS-TIER
     IF EN-EQUIP(L-ROW) > 0
         COMPUTE WS-TIER = EN-EQUIP(L-ROW) / 10 - 1
         COMPUTE WS-SLOTS = FUNCTION MOD(EN-EQUIP(L-ROW), 10)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE WS-I TO WS-SLOT-NO(WS-I)
     END-PERFORM
     IF EN-PIG-GEAR(L-ROW) > 0
*>       a piglin's golden pieces: the slots whose bit is set, in head to feet order
         MOVE 2 TO WS-TIER
         MOVE 0 TO WS-SLOTS
         MOVE EN-PIG-GEAR(L-ROW) TO WS-GEAR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             COMPUTE WS-BIT = FUNCTION MOD(WS-GEAR, 2)
             DIVIDE 2 INTO WS-GEAR
             IF WS-BIT = 1
                 ADD 1 TO WS-SLOTS
                 MOVE WS-I TO WS-SLOT-NO(WS-SLOTS)
             END-IF
         END-PERFORM
     END-IF
     MOVE WS-SLOTS TO WS-TOTAL
     IF EN-HAND(L-ROW) > 0
         ADD 1 TO WS-TOTAL
     END-IF
     IF WS-TOTAL = 0
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL
         IF WS-I <= WS-SLOTS
             CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOT-NO(WS-I) WS-KEY40
             COMPUTE WS-ORDINAL = 6 - WS-SLOT-NO(WS-I)
             IF WS-SLOT-NO(WS-I) = 1 AND EN-HEAD-WEAR(L-ROW) = -1
                 MOVE SPACES TO WS-KEY40
             END-IF
         ELSE
             CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY40
             MOVE 0 TO WS-ORDINAL
         END-IF
         MOVE SPACES TO WS-KEY
         MOVE WS-KEY40 TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         IF WS-I < WS-TOTAL
             ADD 128 TO WS-ORDINAL
         END-IF
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-ORDINAL
         INITIALIZE EQ-ITEMSTACK-X
         IF WS-STATUS = CT-OK
             MOVE 1 TO EQ-ISX-COUNT
             MOVE WS-ITEM TO EQ-ISX-ITEM
         END-IF
         CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER EQ-ITEMSTACK-X
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-EQUIP-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-EQUIP-SEND.
*> USING tracker row: STDMOB-EQUIP-BUILD to the viewers of the row (nothing when the row wears and holds nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-EQUIP-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-EQUIP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-VARIANT-BUILD.
*> USING tracker row, PB-BUFFER (empty): Set Entity Data (0x65) of the row's variant (EN-VARIANT): a baby zombie, zombie villager or husk is index 16
*> BOOLEAN true (4.1); a ghast (charging) index 16 BOOLEAN and a blaze (charged) index 16 BYTE of EN-VARIANT, 0 or 1, a shulker its raw peek 0 to 100 as index 17 BYTE; a powered creeper index 17 BOOLEAN true and an ignited one index 18 BOOLEAN true (6.1); a slime of a size above 0 index 18 INT size (10). Nothing is written for any
*> other row or a variant of 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-M                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-CONVERT             BINARY-LONG.
 01 WS-ZSLOT               BINARY-LONG.
 01 WS-ZNO                 BINARY-LONG VALUE 0.
 01 WS-DANCE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE 0 TO WS-INDEX
     MOVE 0 TO WS-VALUE WS-EXTRA
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND (EN-VARIANT(L-ROW) > 0 OR SM-RANGED(WS-M) >= 4)
         EVALUATE SM-KEY(WS-M)
             WHEN "ghast"
*>               The charging flag (21 section 5.1): index 16 BOOLEAN, sent for either value.
                 MOVE 16 TO WS-INDEX
                 MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
                 MOVE EN-VARIANT(L-ROW) TO WS-VALUE
             WHEN "shulker"
*>               The peek amount (21 section 6.2): index 17 BYTE, raw 0 to 100, sent for every value.
                 MOVE 17 TO WS-INDEX
                 MOVE MD-MDS-BYTE TO WS-SERIALIZER
                 MOVE EN-VARIANT(L-ROW) TO WS-VALUE
             WHEN "blaze"
*>               The flags byte (21 section 5.2): index 16 BYTE, bit 0 charged.
                 MOVE 16 TO WS-INDEX
                 MOVE MD-MDS-BYTE TO WS-SERIALIZER
                 MOVE EN-VARIANT(L-ROW) TO WS-VALUE
             WHEN "vindicator" WHEN "evoker" WHEN "pillager" WHEN "ravager" WHEN "witch" WHEN "illusioner"
*>               The raiders' celebrating flag (20 section 13): index 16 BOOLEAN, EN-VARIANT 1 true, 2 false (sent after a celebration).
                 MOVE 16 TO WS-INDEX
                 MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
                 IF EN-VARIANT(L-ROW) = 1
                     MOVE 1 TO WS-VALUE
                 END-IF
             WHEN "zombie"
             WHEN "zombie_villager"
             WHEN "husk"
                 MOVE 16 TO WS-INDEX
                 MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
                 MOVE 1 TO WS-VALUE
             WHEN "creeper"
                 MOVE 17 TO WS-INDEX
                 MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
                 MOVE 1 TO WS-VALUE
             WHEN "slime"
             WHEN "magma_cube"
             WHEN "sulfur_cube"
                 MOVE 18 TO WS-INDEX
                 MOVE MD-MDS-INT TO WS-SERIALIZER
                 MOVE EN-VARIANT(L-ROW) TO WS-VALUE
             WHEN "salmon"
             WHEN "tropical_fish"
*>               EN-VARIANT is 1 + the variant (21 sections 4.2 and 4.4): metadata 17.
                 MOVE 17 TO WS-INDEX
                 MOVE MD-MDS-INT TO WS-SERIALIZER
                 COMPUTE WS-VALUE = EN-VARIANT(L-ROW) - 1
             WHEN "pufferfish"
                 MOVE 17 TO WS-INDEX
                 MOVE MD-MDS-INT TO WS-SERIALIZER
                 MOVE EN-VARIANT(L-ROW) TO WS-VALUE
         END-EVALUATE
     END-IF
*>   A converting zombie villager (curing started, ZVCURE.cpy) adds index 19 BOOLEAN true (20 section 4.2), or is the only entry.
     MOVE 0 TO WS-CONVERT
     IF WS-M > 0 AND SM-KEY(WS-M) = "zombie_villager"
         CALL "ZC-FIND" USING EN-ID(L-ROW) WS-ZNO WS-ZSLOT
         IF WS-ZSLOT > 0
             MOVE 1 TO WS-CONVERT
         END-IF
     END-IF
     IF WS-CONVERT = 1 AND WS-INDEX = 0
         MOVE 19 TO WS-INDEX
         MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
         MOVE 1 TO WS-VALUE
         MOVE 0 TO WS-CONVERT
     END-IF
*>   The immunity to zombification (T8804): metadata 16 of a piglin or brute, 18 of a hoglin, BOOLEAN true, when it is the only entry.
     IF WS-INDEX = 0 AND WS-M > 0 AND EN-PIG-IMMUNE(L-ROW) = 1
         EVALUATE SM-KEY(WS-M)
             WHEN "piglin"
             WHEN "piglin_brute"
                 MOVE 16 TO WS-INDEX
             WHEN "hoglin"
                 MOVE 18 TO WS-INDEX
         END-EVALUATE
         IF WS-INDEX > 0
             MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
             MOVE 1 TO WS-VALUE
         END-IF
     END-IF
*>   A piglin that has danced (lane mobsb7, PGBRAIN.cpy): metadata 19 BOOLEAN, true while dancing and false once it has stopped, when it is the only entry.
     IF WS-INDEX = 0 AND WS-M > 0
         IF SM-KEY(WS-M) = "piglin"
             CALL "PGB-DANCE-OF" USING EN-ID(L-ROW) WS-DANCE
             IF WS-DANCE > 0
                 MOVE 19 TO WS-INDEX
                 MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
                 IF WS-DANCE = 1
                     MOVE 1 TO WS-VALUE
                 END-IF
             END-IF
         END-IF
     END-IF
*>   A skeleton's stray-conversion flag (20 section 3.8: index 16 BOOLEAN): true while converting, false once (EN-CONVERTING 2) when the conversion was cancelled.
     IF WS-INDEX = 0 AND WS-M > 0 AND SM-KEY(WS-M) = "skeleton" AND EN-CONVERTING(L-ROW) > 0
         MOVE 16 TO WS-INDEX
         MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
         IF EN-CONVERTING(L-ROW) = 1
             MOVE 1 TO WS-VALUE
         END-IF
     END-IF
*>   An ignited creeper (metadata 18 BOOLEAN true, 6.1) follows the powered entry, or is the only one.
     IF WS-M > 0 AND SM-KEY(WS-M) = "creeper" AND EN-IGNITED(L-ROW) = 1
         IF WS-INDEX = 0
             MOVE 18 TO WS-INDEX
             MOVE MD-MDS-BOOLEAN TO WS-SERIALIZER
             MOVE 1 TO WS-VALUE
         ELSE
             MOVE 1 TO WS-EXTRA
         END-IF
     END-IF
     IF WS-INDEX > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         INITIALIZE MD-METADATA-ENTRY
         MOVE WS-INDEX TO MD-MD-INDEX
         MOVE WS-SERIALIZER TO MD-MD-SERIALIZER
         MOVE WS-VALUE TO MD-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         IF WS-EXTRA = 1
             MOVE 18 TO MD-MD-INDEX
             MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
             MOVE 1 TO MD-MD-INT
             CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         END-IF
         IF WS-CONVERT = 1
             MOVE 19 TO MD-MD-INDEX
             MOVE MD-MDS-BOOLEAN TO MD-MD-SERIALIZER
             MOVE 1 TO MD-MD-INT
             CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         END-IF
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     GOBACK.
 END PROGRAM STDMOB-VARIANT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-VARIANT-SEND.
*> USING tracker row: STDMOB-VARIANT-BUILD to the viewers of the row (nothing when the row has no variant packet).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-VARIANT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-MOBFLAGS-BUILD.
*> USING tracker row, PB-BUFFER (empty): Set Entity Data (0x65) of the mob flags (index 15 BYTE: 1 no AI, 2 left-handed; 18 section 1.4): nothing is written while both are
*> off (the default 0 is not sent at pairing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     IF EN-NO-AI(L-ROW) = 1 OR EN-LEFTY(L-ROW) = 1
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         INITIALIZE MD-METADATA-ENTRY
         MOVE 15 TO MD-MD-INDEX
         MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
         COMPUTE MD-MD-INT = EN-NO-AI(L-ROW) + 2 * EN-LEFTY(L-ROW)
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     GOBACK.
 END PROGRAM STDMOB-MOBFLAGS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-MOBFLAGS-SEND.
*> USING tracker row: STDMOB-MOBFLAGS-BUILD to the viewers of the row (nothing while no flag is set).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-MOBFLAGS-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-MOBFLAGS-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HP-BUILD.
*> USING tracker row, PB-BUFFER (empty): Set Entity Data (0x65) of the health, index 9 FLOAT (18 sections 1.4 and 9.3): the health of the row less the carried fraction
*> of an armour-reduced hit. Nothing is written for the default 1.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-MILLI               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     COMPUTE WS-MILLI = EN-HEALTH(L-ROW) * 1000 - EN-HEALTH-MILLI(L-ROW)
     IF WS-MILLI NOT = 1000
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         INITIALIZE MD-METADATA-ENTRY
         MOVE 9 TO MD-MD-INDEX
         MOVE MD-MDS-FLOAT TO MD-MD-SERIALIZER
         COMPUTE MD-MD-FLOAT = WS-MILLI / 1000
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     GOBACK.
 END PROGRAM STDMOB-HP-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HP-SYNC.
*> USING tracker row: a standard mob whose health differs from the last one sent sends the new one to its viewers (the synced health slot, 18 section 9.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-M                   BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     COMPUTE WS-MILLI = EN-HEALTH(L-ROW) * 1000 - EN-HEALTH-MILLI(L-ROW)
     IF WS-MILLI = EN-HP-SENT(L-ROW)
         GOBACK
     END-IF
     MOVE WS-MILLI TO EN-HP-SENT(L-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-HP-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-HP-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HP-PAIR.
*> USING tracker row: the pairing of a standard mob sends its health (metadata 9, a value that differs from the default) to the viewers and remembers it as sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     COMPUTE EN-HP-SENT(L-ROW) = EN-HEALTH(L-ROW) * 1000 - EN-HEALTH-MILLI(L-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-HP-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-HP-PAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FINALIZE-BASE.
*> USING tracker row: the first two steps of Mob.finalizeSpawn for every mob (18 section 7.1, 44 x1 section 3): the random_spawn_bonus modifier of follow_range
*> (amount triangle(0, 0.11485) = 0.11485 x (nextDouble - nextDouble), stored in millionths in EN-FOLLOW-BONUS, only while none is there) and left-handedness (nextFloat < 0.05,
*> EN-LEFTY). The draws are hashes of the entity id and the time, not the spawn's xoroshiro state, so the draws of the species' own finalize do not move. The mob flags go
*> to the viewers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     IF EN-FOLLOW-BONUS(L-ROW) = 0
         MOVE 31 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE WS-A = FUNCTION MOD(WS-R, 1000000)
         MOVE 32 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE WS-B = FUNCTION MOD(WS-R, 1000000)
         COMPUTE EN-FOLLOW-BONUS(L-ROW) = (WS-A - WS-B) * 0.11485
     END-IF
     MOVE 33 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     IF FUNCTION MOD(WS-R, 1000) < 50
         MOVE 1 TO EN-LEFTY(L-ROW)
     ELSE
         MOVE 0 TO EN-LEFTY(L-ROW)
     END-IF
     CALL "STDMOB-MOBFLAGS-SEND" USING L-ROW
     GOBACK.
 END PROGRAM STDMOB-FINALIZE-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-XP-POINTS.
*> USING base reward, baby (BINARY-LONG, 1 baby), points out: the experience reward of a mob (3.6): a baby zombie multiplies it by 2.5, truncated.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-POINTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-BABY L-POINTS.
     MOVE L-BASE TO L-POINTS
     IF L-BABY = 1
         COMPUTE L-POINTS = L-BASE * 5 / 2
     END-IF
     GOBACK.
 END PROGRAM STDMOB-XP-POINTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FINALIZE RECURSIVE.
*> USING xoro state, tracker row: finalizeSpawn of a freshly spawned standard mob (4.1, 3.6). A zombie, zombie villager or husk is a baby with probability
*> 0.05 (EN-VARIANT 1), rolls its armour (STDMOB-EQUIP-ROLL with the special multiplier of the effective difficulty; EN-EQUIP), gets the reinforcement
*> chance nextDouble x 0.1 (EN-REINF, ten-thousandths) and with probability 0.05 x special is a leader: +0.5 + nextDouble x 0.25 chance and the maximum
*> health times (1 + nextDouble x 3 + 1), the health full; then the weapon draw of 4.1 (EN-HAND). A slime takes its size (STDMOB-SLIME-INIT). The viewers get the variant and equipment packets.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-GAME-TIME           BINARY-DOUBLE.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-EFF                 BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-PICK                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     CALL "STDMOB-FINALIZE-BASE" USING L-ROW
     *> T of 3.2 is the world game time, not the time of day.
     COMPUTE WS-GAME-TIME = CW-GAME-TIME + CW-TICKS
     CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY WS-GAME-TIME WS-INHABITED WS-MOON WS-EFF
     CALL "STDMOB-SPECIAL" USING WS-EFF WS-SPECIAL
     EVALUATE SM-KEY(WS-M)
         WHEN "zombie"
         WHEN "zombie_villager"
         WHEN "husk"
             CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
             IF WS-D < 0.05
                 MOVE 1 TO EN-VARIANT(L-ROW)
                 CALL "MOB-JOCKEY-ZOMBIE" USING L-STATE L-ROW
             END-IF
             CALL "STDMOB-EQUIP-ROLL" USING L-STATE BW-DIFFICULTY WS-SPECIAL WS-TIER WS-SLOTS
             IF WS-SLOTS > 0
                 COMPUTE EN-EQUIP(L-ROW) = 10 * (WS-TIER + 1) + WS-SLOTS
             END-IF
             CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
             COMPUTE EN-REINF(L-ROW) = WS-D * 1000
             CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
             COMPUTE WS-P = 0.05 * WS-SPECIAL / 1000
             IF WS-D < WS-P
                 CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
                 COMPUTE EN-REINF(L-ROW) = EN-REINF(L-ROW) + 5000 + WS-D * 2500
                 CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
                 COMPUTE EN-HEALTH(L-ROW) = SM-HEALTH(WS-M) * (2 + WS-D * 3)
             END-IF
*>           The zombie weapon: probability 0.05 on Hard, 0.01 otherwise; nextInt(6) 0 iron sword, 1 iron spear, else iron shovel (4.1 step 5).
             CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
             COMPUTE WS-P = 0.01
             IF BW-DIFFICULTY = 3
                 COMPUTE WS-P = 0.05
             END-IF
             IF WS-D < WS-P
                 CALL "XORO-NEXT-INT" USING L-STATE WS-SIX WS-PICK
                 EVALUATE WS-PICK
                     WHEN 0 MOVE 1 TO EN-HAND(L-ROW)
                     WHEN 1 MOVE 2 TO EN-HAND(L-ROW)
                     WHEN OTHER MOVE 3 TO EN-HAND(L-ROW)
                 END-EVALUATE
             END-IF
         WHEN "skeleton"
         WHEN "stray"
         WHEN "bogged"
         WHEN "parched"
*>           Armour as 3.6 and always a bow in the main hand (5, populateDefaultEquipmentSlots).
             CALL "STDMOB-EQUIP-ROLL" USING L-STATE BW-DIFFICULTY WS-SPECIAL WS-TIER WS-SLOTS
             IF WS-SLOTS > 0
                 COMPUTE EN-EQUIP(L-ROW) = 10 * (WS-TIER + 1) + WS-SLOTS
             END-IF
             MOVE 4 TO EN-HAND(L-ROW)
         WHEN "wither_skeleton"
*>           Default equipment: a stone sword (44-6 section 9.4; no random enchantments). EN-HAND 12: 10 and 11 are the vindicator's axe and the pillager's crossbow.
             MOVE 12 TO EN-HAND(L-ROW)
         WHEN "slime"
         WHEN "magma_cube"
             CALL "STDMOB-SLIME-INIT" USING L-STATE L-ROW WS-SPECIAL
         WHEN "sulfur_cube"
             CALL "SULFUR-CUBE-INIT" USING L-ROW
*>           A vindicator holds an iron axe, a pillager a crossbow (20 sections 13.1 and 13.2, populateDefaultEquipmentSlots).
         WHEN "vindicator"
             MOVE 10 TO EN-HAND(L-ROW)
         WHEN "pillager"
             MOVE 11 TO EN-HAND(L-ROW)
*>           An illusioner holds a bow (13.5), a vex an iron sword (13.4).
         WHEN "illusioner"
             MOVE 4 TO EN-HAND(L-ROW)
         WHEN "vex"
             MOVE 1 TO EN-HAND(L-ROW)
         WHEN "salmon"
         WHEN "tropical_fish"
             CALL "STDMOB-AQUATIC-FINALIZE" USING L-STATE L-ROW WS-M
         WHEN "axolotl"
             CALL "AXOLOTL-FINALIZE" USING L-STATE L-ROW
         WHEN "spider"
         WHEN "cave_spider"
             IF SM-KEY(WS-M) = "spider"
                 CALL "MOB-JOCKEY-SPIDER" USING L-STATE L-ROW
             END-IF
             CALL "STDMOB-SPIDER-FX" USING L-STATE L-ROW WS-SPECIAL
         WHEN "hoglin"
         WHEN "zoglin"
*>           finalizeSpawn of a hoglin or zoglin: a baby with probability 0.2 (nextFloat() < 0.2, 44 part 6 sections 6.2 and 6.3); a negative age is the baby flag here.
             CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
             IF WS-D < 0.2
                 MOVE -24000 TO EN-MOBAGE(L-ROW)
             END-IF
         WHEN "strider"
             CALL "STRIDER-JOCKEY" USING L-STATE L-ROW
         WHEN "piglin"
             CALL "PGW-FINALIZE" USING L-STATE L-ROW
         WHEN "phantom"
*>           anchorPoint = the block + (0, 5, 0), size 0, the move control speed 0.1 (20 section 12).
             COMPUTE EN-PH-AX(L-ROW) = FUNCTION INTEGER(EN-X(L-ROW))
             COMPUTE EN-PH-AY(L-ROW) = FUNCTION INTEGER(EN-Y(L-ROW)) + 5
             COMPUTE EN-PH-AZ(L-ROW) = FUNCTION INTEGER(EN-Z(L-ROW))
             MOVE 1 TO EN-PH-SET(L-ROW)
             MOVE 0.1 TO EN-PH-SPEED(L-ROW)
             MOVE 1 TO EN-PH-CW(L-ROW)
             MOVE 20 TO EN-PH-SCAN(L-ROW)
     END-EVALUATE
     CALL "STDMOB-VARIANT-SEND" USING L-ROW
     CALL "STDMOB-EQUIP-SEND" USING L-ROW
     GOBACK.
 END PROGRAM STDMOB-FINALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-XP-VARIANT.
*> USING dim, x, y, z (FLOAT-LONG), type, killer player row, variant (EN-VARIANT): the experience of a defeated mob that has a variant: a baby zombie, zombie
*> villager or husk gives the reward times 2.5 (3.6); any other variant (a powered creeper) gives the plain reward (STDMOB-XP-BONUS). The equipment bonus of the row
*> (STDMOB-XP-GEAR, the last argument) is added to either reward after the multiplication.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-KILLER               BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 01 L-BONUS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE L-KILLER L-VARIANT L-BONUS.
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     MOVE 0 TO WS-BABY
     IF L-VARIANT = 1 AND (SM-KEY(WS-M) = "zombie" OR SM-KEY(WS-M) = "zombie_villager" OR SM-KEY(WS-M) = "husk")
         MOVE 1 TO WS-BABY
     END-IF
     IF WS-BABY = 1
         IF L-KILLER > 0
             CALL "STDMOB-XP-POINTS" USING SM-XP(WS-M) WS-BABY WS-POINTS
             ADD L-BONUS TO WS-POINTS
             CALL "XP-AWARD" USING L-DIM L-X L-Y L-Z WS-POINTS
         END-IF
     ELSE
         CALL "STDMOB-XP-BONUS" USING L-DIM L-X L-Y L-Z L-TYPE L-KILLER L-BONUS
     END-IF
     GOBACK.
 END PROGRAM STDMOB-XP-VARIANT.
