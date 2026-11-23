*> Implementation test (wrap I2 round 3, T2451; docs/protocol/19-mobs-land-friendly-and-neutral.md section 3.8, camel husk row): a player's interact with a camel husk first sets persistence required (it
*> then no longer despawns), and the husk's food is the rabbit foot: a hurt husk heals 2 and one item is used (Camel.handleEating), an unhurt husk takes none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-HUSK-CAMEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
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
 01 WS-TYPE                BINARY-LONG.
 01 WS-FOOT                BINARY-LONG.
 01 WS-HUSK                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
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
     MOVE "minecraft:rabbit_foot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-FOOT WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 2
     MOVE "minecraft:camel_husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-HUSK
     MOVE EN-ID(WS-HUSK) TO WS-ID
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-HUSK) WS-M
     MOVE SM-HEALTH(WS-M) TO WS-MAX
     MOVE 0 TO EN-PERSISTENT(WS-HUSK)

*>   An unhurt husk takes no rabbit foot, but the interact still sets persistence.
     MOVE WS-FOOT TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.8 interacting with a camel husk sets persistence required" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-PERSISTENT(WS-HUSK) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 19 3.8 an unhurt husk is not fed: three rabbit feet stay" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hurt husk heals 2 per rabbit foot, up to its maximum health, and one item is used each time.
     COMPUTE EN-HEALTH(WS-HUSK) = WS-MAX - 5
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.8 a hurt husk fed a rabbit foot heals 2 (Camel.handleEating)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-MAX - 3
     MOVE EN-HEALTH(WS-HUSK) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 19 3.8 and one rabbit foot is used" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-HEALTH(WS-HUSK) = WS-MAX - 1
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 19 3.8 the heal stops at the maximum health" TO TL-CASE
     MOVE WS-MAX TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-HUSK) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-HUSK-CAMEL.
 COPY CORETEST.
 COPY MOBSPTEST.
