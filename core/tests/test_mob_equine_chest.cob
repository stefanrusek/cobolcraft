*> Implementation test (wrap C round 6, T52093 step 5; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.5 step 5 and 3.6, 45-4 section 6.5, 21 appendix metadata of the donkey): a tamed
*> adult donkey or mule that holds no chest takes a chest item in the main hand (equipChest): the chest flag is set (metadata 19 BOOLEAN, with the tamed flag 2 in metadata 18), one chest is used
*> (a creative player keeps the stack) and the viewers get Set Entity Data. A chested donkey takes no second chest; an untamed one, a baby and a horse (no chest) take none. ChestedHorse is saved and restored.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-EQUINE-CHEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CITEMS.
 COPY WCSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 COPY PROTO.
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
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DONKEY              BINARY-LONG.
 01 WS-MULE                BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-MDI                 BINARY-LONG.
 01 WS-MDV                 BINARY-LONG.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-TALLY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-OWNER               PIC X(16).
 01 WS-COUNT-OF-MOBS       BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-CHESTED             BINARY-LONG.
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
     MOVE "minecraft:chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:donkey" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-DONKEY
     MOVE 1 TO EN-TAMED(WS-DONKEY)
     MOVE EN-ID(WS-DONKEY) TO WS-ID
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A tamed adult donkey takes the chest: one of the two is used, the flag is set, the viewers get Set Entity Data (101).
     MOVE WS-CHEST TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-DONKEY
     MOVE "implementation 19 3.5 step 5 a tamed donkey takes a chest: the chest flag is set and one chest is used" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-CHEST(WS-DONKEY) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-TALLY
     MOVE SPACES TO WS-PADDED
     STRING " " FUNCTION TRIM(WS-IDS) " " DELIMITED BY SIZE INTO WS-PADDED
     INSPECT WS-PADDED TALLYING WS-TALLY FOR ALL " 101 "
     MOVE "implementation 19 3.5 step 5 the viewers get Set Entity Data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-TALLY > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-DONKEY TO WS-ROW-A
     MOVE 19 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 21 donkey metadata 19 DATA_ID_CHEST is true" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 19 3.1 metadata 18 of a tamed donkey has the tamed flag 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A donkey that carries a chest takes no second one.
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.5 step 5 a chested donkey takes no second chest" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An untamed donkey, a tamed baby and a tamed horse take none; a donkey without a chest sends no chest entry.
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE "minecraft:donkey" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MULE
     MOVE EN-ID(WS-MULE) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-MULE
     MOVE "implementation 19 3.5 an untamed donkey takes no chest" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-CHEST(WS-MULE) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-MULE TO WS-ROW-A
     MOVE 19 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "implementation 21 donkey metadata 19 is absent without a chest" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MDV TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-TAMED(WS-MULE)
     MOVE -24000 TO EN-MOBAGE(WS-MULE)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.5 a tamed baby donkey takes no chest" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-CHEST(WS-MULE) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-MOBAGE(WS-MULE)
     MOVE "minecraft:horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-HORSE
     MOVE 1 TO EN-TAMED(WS-HORSE)
     MOVE EN-ID(WS-HORSE) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     CALL "WC-ROW-OPEN" USING WS-HORSE
     MOVE "implementation 19 3.6 a tamed horse is not a chested type and takes no chest" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-CHEST(WS-HORSE) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A tamed adult mule takes the chest (WS-ROW), and a creative player keeps the stack.
     MOVE "minecraft:mule" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WS-ID
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE "implementation 19 3.6 a tamed mule takes a chest and a creative player keeps both chests" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WC-CHEST(WS-ROW) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ChestedHorse is saved and comes back with the mob: the chested mule at the chunk of the horse's spawn.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE EN-ID(WS-ROW) TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-COUNT-OF-MOBS WS-CHESTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             ADD 1 TO WS-COUNT-OF-MOBS
             CALL "WC-ROW-OPEN" USING WS-I
             ADD WC-CHEST(WS-I) TO WS-CHESTED
         END-IF
     END-PERFORM
     MOVE "implementation 45-4 6.5 ChestedHorse comes back: four mobs read (donkey, donkey, horse, mule), two of them have the chest flag" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT-OF-MOBS * 10 + WS-CHESTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
*> FIND-DATA: Set Entity Data as MOB-DATA-BUILD makes it for row WS-ROW-A: the value of entry WS-MDI (BOOLEAN, BYTE, INT: the int), -1 when absent
 FIND-DATA.
     CALL "PB-RESET" USING MQ-BUFFER
     CALL "MOB-DATA-BUILD" USING WS-ROW-A MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-MDV
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = WS-MDI
                 MOVE MQ-MX-INT TO WS-MDV
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-EQUINE-CHEST.
 COPY CORETEST.
 COPY MOBSPTEST.
