*> Implementation test (wrap I2 round 3, T52093; docs/protocol/45-entity-nbt-4-land-animals.md sections 6.1 and 6.5, 45-2 section 2.4; 40-6 section 2): what the mount screen holds is saved in the mob's NBT and comes back.
*> A chested mule and llama keep ChestedHorse and the Items list (Slot, id, count; a slot at or above 3 x columns is dropped on read, an unchested mule writes none), the saddle of a horse, zombie horse, skeleton horse and
*> nautilus is equipment.saddle, the body item (horse armor, nautilus armor) is equipment.body. A viewer who comes into view later gets one Set Equipment (0x68) with the body pair (ordinal 6) and the saddle pair (ordinal 7).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-MOUNT-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY WCSTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY24               PIC X(24).
 01 WS-IDKEY               PIC X(112).
 01 WS-IDS                 PIC X(1024).
 01 WS-IDOUT               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-IRON                BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-APPLE               BINARY-LONG.
 01 WS-BREAD               BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-ROWS.
    05 WS-ROW-OF           BINARY-LONG OCCURS 7 TIMES.
    05 WS-EID-OF           BINARY-LONG OCCURS 7 TIMES.
 01 WS-EQ.
    05 WS-EQ-ROW OCCURS 7 TIMES.
       10 WS-EQ-N          BINARY-LONG.
       10 WS-EQ-ORD        BINARY-LONG OCCURS 2 TIMES.
       10 WS-EQ-ITM        BINARY-LONG OCCURS 2 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ORDINAL             BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COUNT-OF-MOBS       BINARY-LONG.
 01 WS-R-MULE              BINARY-LONG.
 01 WS-R-MULE2             BINARY-LONG.
 01 WS-R-LLAMA             BINARY-LONG.
 01 WS-R-HORSE             BINARY-LONG.
 01 WS-R-ZOMBIE            BINARY-LONG.
 01 WS-R-SKEL              BINARY-LONG.
 01 WS-R-NAU               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-ENCH-LEVEL          BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE 0 TO PL-YAW(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE "saddle" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-SADDLE
     MOVE "iron_horse_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-IRON
     MOVE "iron_nautilus_armor" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-NAUTILUS
     MOVE "apple" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-APPLE
     MOVE "bread" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-BREAD
     MOVE "cobblestone" TO WS-IDKEY
     PERFORM ITEM-ID
     MOVE WS-IDOUT TO WS-COBBLE
     MOVE "implementation 45-4 6.5 the items of the test exist in the content set" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-SADDLE > 0 AND WS-IRON > 0 AND WS-NAUTILUS > 0 AND WS-APPLE > 0 AND WS-BREAD > 0 AND WS-COBBLE > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   Seven tamed adults with the state of the screen: a chested mule (saddle, apple x5 in slot 0, bread in slot 8), a chested llama of strength 3 (cobblestone x3 in slot 0, and one stack at slot 9 that
*>   the size 9 does not hold), a horse in iron armor with a saddle, a saddled zombie horse and skeleton horse, a saddled nautilus in nautilus armor, and a mule without a chest whose WC-INV is stale.
     MOVE "mule" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE 1 TO WS-K
     MOVE WS-M TO WS-ROW-OF(1)
     MOVE EN-ID(WS-M) TO WS-EID-OF(1)
     MOVE 1 TO WC-CHEST(WS-M) EN-SADDLE(WS-M)
     MOVE WS-APPLE TO WC-INV-ITEM(WS-M, 1)
     MOVE 5 TO WC-INV-COUNT(WS-M, 1)
     MOVE WS-BREAD TO WC-INV-ITEM(WS-M, 9)
     MOVE 1 TO WC-INV-COUNT(WS-M, 9)
*>   Slot 3 holds two enchanted apples (a data component patch): the pool sweep must keep the patch of a chest stack.
     MOVE 0 TO WS-HANDLE
     MOVE 1 TO WS-ENCH-ID
     MOVE 3 TO WS-ENCH-LEVEL
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-ENCH-LEVEL
     MOVE WS-APPLE TO WC-INV-ITEM(WS-M, 4)
     MOVE 2 TO WC-INV-COUNT(WS-M, 4)
     MOVE WS-HANDLE TO WC-INV-VAR(WS-M, 4)
     CALL "SP-SWEEP"
     MOVE "llama" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(2)
     MOVE EN-ID(WS-M) TO WS-EID-OF(2)
     MOVE 1 TO WC-CHEST(WS-M)
     MOVE 3 TO EN-STRENGTH(WS-M)
     MOVE WS-COBBLE TO WC-INV-ITEM(WS-M, 1)
     MOVE 3 TO WC-INV-COUNT(WS-M, 1)
     MOVE WS-COBBLE TO WC-INV-ITEM(WS-M, 10)
     MOVE 2 TO WC-INV-COUNT(WS-M, 10)
     MOVE "horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(3)
     MOVE EN-ID(WS-M) TO WS-EID-OF(3)
     MOVE 1 TO EN-SADDLE(WS-M)
     MOVE WS-IRON TO WC-BODY(WS-M)
     MOVE "zombie_horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(4)
     MOVE EN-ID(WS-M) TO WS-EID-OF(4)
     MOVE 1 TO EN-SADDLE(WS-M)
     MOVE "skeleton_horse" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(5)
     MOVE EN-ID(WS-M) TO WS-EID-OF(5)
     MOVE 1 TO EN-SADDLE(WS-M)
     MOVE "nautilus" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(6)
     MOVE EN-ID(WS-M) TO WS-EID-OF(6)
     MOVE 1 TO EN-SADDLE(WS-M)
     MOVE WS-NAUTILUS TO WC-BODY(WS-M)
     MOVE "mule" TO WS-KEY24
     PERFORM SPAWN-MOUNT
     MOVE WS-M TO WS-ROW-OF(7)
     MOVE EN-ID(WS-M) TO WS-EID-OF(7)
     MOVE WS-APPLE TO WC-INV-ITEM(WS-M, 1)
     MOVE 4 TO WC-INV-COUNT(WS-M, 1)

*>   A viewer who comes into view later: the client of the player forgets every entity and sees them again.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "ENTITY-VIEWER-FORGET" USING WS-PLAYER
     CALL "ENTITY-VIEWER-REFRESH" USING WS-PLAYER
     PERFORM SCAN-EQUIP
     MOVE "implementation 40-6 2.2 a later viewer gets one Set Equipment for the horse: two pairs, body (ordinal 6) then saddle (7)" TO WS-CASE
     MOVE 267 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-EQ-N(3) * 100 + WS-EQ-ORD(3, 1) * 10 + WS-EQ-ORD(3, 2)
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 the horse's pairs hold iron_horse_armor and the saddle" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-EQ-ITM(3, 1) = WS-IRON AND WS-EQ-ITM(3, 2) = WS-SADDLE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 a saddled zombie horse and a chested, saddled mule send the saddle pair only (ordinal 7)" TO WS-CASE
     COMPUTE WS-OBSERVE = WS-EQ-N(4) * 1000 + WS-EQ-ORD(4, 1) * 100 + WS-EQ-N(1) * 10 + WS-EQ-ORD(1, 1)
     COMPUTE WS-EXPECT = 1000 + 700 + 10 + 7
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 the nautilus sends nautilus armor (6) and the saddle (7)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-EQ-N(6) = 2 AND WS-EQ-ORD(6, 1) = 6 AND WS-EQ-ITM(6, 1) = WS-NAUTILUS AND WS-EQ-ORD(6, 2) = 7 AND WS-EQ-ITM(6, 2) = WS-SADDLE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 40-6 2.2 an unequipped llama and mule send no Set Equipment" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-EQ-N(2) + WS-EQ-N(7)
     PERFORM CHECK

*>   The save: the chunk of the mobs written, every mob removed, the compound read back.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW-OF(1)) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW-OF(1)) / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-COUNT-OF-MOBS WS-R-MULE WS-R-MULE2 WS-R-LLAMA WS-R-HORSE WS-R-ZOMBIE WS-R-SKEL WS-R-NAU
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             ADD 1 TO WS-COUNT-OF-MOBS
             CALL "WC-ROW-OPEN" USING WS-I
             CALL "MNT-KIND" USING WS-I WS-KIND
             EVALUATE TRUE
                 WHEN WS-KIND = 3 AND WC-CHEST(WS-I) = 1
                     MOVE WS-I TO WS-R-MULE
                 WHEN WS-KIND = 3
                     MOVE WS-I TO WS-R-MULE2
                 WHEN WS-KIND = 4
                     MOVE WS-I TO WS-R-LLAMA
                 WHEN WS-KIND = 1
                     MOVE WS-I TO WS-R-HORSE
                 WHEN WS-KIND = 7
                     MOVE WS-I TO WS-R-ZOMBIE
                 WHEN WS-KIND = 6
                     MOVE WS-I TO WS-R-SKEL
                 WHEN WS-KIND = 8
                     MOVE WS-I TO WS-R-NAU
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE "implementation 45-4 6.5 the seven mobs come back" TO WS-CASE
     MOVE 7 TO WS-EXPECT
     MOVE WS-COUNT-OF-MOBS TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 the chested mule keeps its chest flag and its saddle (equipment.saddle)" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-CHEST(WS-R-MULE) * 10 + EN-SADDLE(WS-R-MULE)
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 Items: Slot 0 is the five apples" TO WS-CASE
     MOVE 51 TO WS-EXPECT
     MOVE 0 TO WS-FLAG
     IF WC-INV-ITEM(WS-R-MULE, 1) = WS-APPLE
         MOVE 1 TO WS-FLAG
     END-IF
     COMPUTE WS-OBSERVE = WC-INV-COUNT(WS-R-MULE, 1) * 10 + WS-FLAG
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 Items: Slot 8 is the bread and the slots between are empty" TO WS-CASE
     MOVE 1001 TO WS-EXPECT
     MOVE 0 TO WS-FLAG
     IF WC-INV-ITEM(WS-R-MULE, 9) = WS-BREAD
         MOVE 1 TO WS-FLAG
     END-IF
     COMPUTE WS-OBSERVE = WC-INV-COUNT(WS-R-MULE, 9) * 1000 + WC-INV-COUNT(WS-R-MULE, 2) * 100 + WC-INV-COUNT(WS-R-MULE, 8) * 10 + WS-FLAG
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 Items: Slot 3 keeps its components (an enchantment of level 3) through a pool sweep and a reload" TO WS-CASE
     MOVE 23 TO WS-EXPECT
     MOVE 1 TO WS-ENCH-ID
     CALL "SP-ENCHANT-LEVEL" USING WC-INV-VAR(WS-R-MULE, 4) WS-ENCH-ID WS-ENCH-LEVEL
     COMPUTE WS-OBSERVE = WC-INV-COUNT(WS-R-MULE, 4) * 10 + WS-ENCH-LEVEL
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 a llama is chested too: chest flag and Strength 3 come back" TO WS-CASE
     MOVE 13 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-CHEST(WS-R-LLAMA) * 10 + EN-STRENGTH(WS-R-LLAMA)
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 the llama's Items: Slot 0 comes back, Slot 9 (at or above 3 x 3) is dropped" TO WS-CASE
     MOVE 30 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-INV-COUNT(WS-R-LLAMA, 1) * 10 + WC-INV-COUNT(WS-R-LLAMA, 10)
     PERFORM CHECK
     MOVE "implementation 45-4 6.5 a mule without a chest writes no Items" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WC-CHEST(WS-R-MULE2) * 10 + WC-INV-COUNT(WS-R-MULE2, 1)
     PERFORM CHECK
     MOVE "implementation 45-4 6.1 the horse's saddle and body slot (equipment.saddle, equipment.body) come back" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-SADDLE(WS-R-HORSE) = 1 AND WC-BODY(WS-R-HORSE) = WS-IRON
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     MOVE "implementation 45-4 6.4 a zombie horse and a skeleton horse keep their saddle" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SADDLE(WS-R-ZOMBIE) * 10 + EN-SADDLE(WS-R-SKEL)
     PERFORM CHECK
     MOVE "implementation 45-2 2.4 a nautilus keeps its saddle and its body armor" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-SADDLE(WS-R-NAU) = 1 AND WC-BODY(WS-R-NAU) = WS-NAUTILUS
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK
     STOP RUN.
*> ITEM-ID: the item id of minecraft:<WS-IDKEY> in WS-IDOUT
 ITEM-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-IDKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IDOUT WS-ITEM-ROW WS-STATUS.
*> SPAWN-MOUNT: a tamed adult mob of the key WS-KEY24 two blocks in front of the player, its tracker row in WS-M, its WCSTATE entry open
 SPAWN-MOUNT.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY24) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-M
     MOVE 1 TO EN-TAMED(WS-M)
     MOVE 0 TO EN-MOBAGE(WS-M)
     CALL "WC-ROW-OPEN" USING WS-M.
*> SCAN-EQUIP: drains the player's connection; for each of the seven spawned mobs WS-EQ-N counts the pairs of its Set Equipment (0x68) packets, WS-EQ-ORD and WS-EQ-ITM hold the first two
 SCAN-EQUIP.
     INITIALIZE WS-EQ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 104
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-ENTITY
             MOVE 1 TO WS-MORE
             PERFORM UNTIL WS-MORE = 0 OR PK-ERROR = 1
                 CALL "PB-GET-UBYTE" USING PK-BUFFER WS-ORDINAL
                 MOVE 0 TO WS-MORE
                 IF WS-ORDINAL >= 128
                     MOVE 1 TO WS-MORE
                     SUBTRACT 128 FROM WS-ORDINAL
                 END-IF
                 INITIALIZE PK-ITEMSTACK-X
                 CALL "PB-GET-ITEM-STACK" USING PK-BUFFER PK-ITEMSTACK-X
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
                     IF WS-EID-OF(WS-I) = WS-ENTITY
                         ADD 1 TO WS-EQ-N(WS-I)
                         IF WS-EQ-N(WS-I) <= 2
                             MOVE WS-ORDINAL TO WS-EQ-ORD(WS-I, WS-EQ-N(WS-I))
                             MOVE PK-ISX-ITEM TO WS-EQ-ITM(WS-I, WS-EQ-N(WS-I))
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-MOUNT-NBT.
 COPY CORETEST.
 COPY MOBSPTEST.
