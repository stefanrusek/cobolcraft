*> Acceptance test (US15; docs/protocol/18-mob-framework.md section 8.3, 05b 0x66 Set Entity Link, 17 section 3.7): leads through the real play path. A lead in the main hand on a
*> passive mob within reach leashes it to the player (the lead is used up, Set Entity Link goes to the viewers); aquatic fish and hostile mobs refuse; a holder more than 12 blocks away
*> cannot attach; beyond the elastic distance the mob is pulled toward the holder; beyond 12 blocks, with a gone holder or when the mob is defeated the lead drops as an item and the link
*> is cleared (Set Entity Link with destination 0, the detach value picked for the open item); the holder's interact unleashes; a viewer that starts to track a leashed mob is sent the link.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-LEASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 COPY CITEMS.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-NEEDLE              PIC X(12).
 01 WS-HITS                BINARY-LONG.
 01 WS-WANT-KEY            PIC X(112).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-HORSE-ID            BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-PIG-ID              BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-INPUT               BINARY-LONG.
 01 WS-MV-ID               BINARY-LONG VALUE 34.
 01 WS-IN-ID               BINARY-LONG VALUE 43.
 01 WS-MV-X                FLOAT-LONG.
 01 WS-MV-Y                FLOAT-LONG.
 01 WS-MV-Z                FLOAT-LONG.
 01 WS-MV-FLAGS            BINARY-LONG VALUE 1.
 01 WS-HORSE-X0            FLOAT-LONG.
 01 WS-HORSE-Z0            FLOAT-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-COW-ID              BINARY-LONG.
 01 WS-COD                 BINARY-LONG.
 01 WS-COD-ID              BINARY-LONG.
 01 WS-LEADS               BINARY-LONG.
 01 WS-LEADS0              BINARY-LONG.
 01 WS-LEAD-ITEM           BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-PX0                 FLOAT-LONG.
 01 WS-GONE                BINARY-LONG VALUE 60.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 8
             COMPUTE WS-E = WS-CX - 4 + WS-X
             COMPUTE WS-I = WS-CZ - 4 + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-E WS-FLOOR WS-I WS-STATE
             PERFORM VARYING WS-HITS FROM 1 BY 1 UNTIL WS-HITS > 3
                 COMPUTE WS-ITEM-ID = WS-FLOOR + WS-HITS
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-E WS-ITEM-ID WS-I WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT


     MOVE "lead" TO WS-ITEM-KEY
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE WS-ITEM-ID TO WS-LEAD-ITEM
     MOVE PL-X(WS-PLAYER) TO WS-PX0

*> A lead on a cow in reach leashes it
     MOVE "cow" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-COW
     MOVE EN-ID(WS-COW) TO WS-COW-ID
     MOVE "cod" TO WS-WANT-KEY
     MOVE 0 TO WS-DX
     MOVE 2 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-COD
     MOVE EN-ID(WS-COD) TO WS-COD-ID
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     CALL "TEST-INTERACT" USING WS-CONN WS-COD-ID WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.3 Leashing: a fish cannot be leashed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COD) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.3 Leashing: the refused lead is kept" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-INTERACT" USING WS-CONN WS-COW-ID WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.3 Leashing: a lead on a cow leashes it to the player" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.3 Leashing: the lead is used up" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE " 102" TO WS-NEEDLE
     PERFORM COUNT-PACKET
     MOVE "acceptance US15 18§8.3 Leashing: Set Entity Link is sent to the viewer" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N

*> A holder beyond the snap distance cannot attach another mob
     MOVE 0 TO WS-DX
     MOVE -2 TO WS-DZ
     MOVE "sheep" TO WS-WANT-KEY
     PERFORM SPAWN-MOB
     MOVE PL-X(WS-PLAYER) TO WS-PX0
     COMPUTE PL-X(WS-PLAYER) = WS-PX0 + 13
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-E WS-OK
     MOVE "acceptance US15 18§8.3 Leashing: a mob more than 12 blocks from the holder is refused" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-PX0 TO PL-X(WS-PLAYER)
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-COW WS-OK
     MOVE "acceptance US15 18§8.3 Leashing: a mob that is leashed already is refused" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE EN-X(WS-COW) TO WS-X0
     CALL "ENTITY-REMOVE" USING WS-E

*> Pulled beyond 6 blocks, dropped beyond 12
     COMPUTE PL-X(WS-PLAYER) = WS-PX0 + 9
     CALL "TEST-TICKS-ANSWERED" USING 3
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.3 Leashing: a mob beyond 6 blocks from its holder is pulled toward it" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-X(WS-COW) > WS-X0 + 0.01
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.3 Leashing: the lead holds within the snap distance" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-LOOSE-LEADS
     MOVE WS-LEADS TO WS-LEADS0
     COMPUTE PL-X(WS-PLAYER) = WS-PX0 + 18
     CALL "TEST-TICKS-ANSWERED" USING 1
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.3 Leashing: a holder beyond 12 blocks breaks the lead" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-LOOSE-LEADS
     MOVE "acceptance US15 18§8.3 Leashing: the broken lead drops as an item" TO WS-CASE
     COMPUTE WS-EXPECT = WS-LEADS0 + 1
     MOVE WS-LEADS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE " 102" TO WS-NEEDLE
     PERFORM COUNT-PACKET
     MOVE "acceptance US15 18§8.3 Leashing: Set Entity Link is sent for the break" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-PX0 TO PL-X(WS-PLAYER)
     MOVE WS-PX0 TO EN-X(WS-COW)
     ADD 2 TO EN-X(WS-COW)

*> The holder's interact unleashes
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-COW WS-OK
     MOVE "acceptance US15 18§8.3 Leashing: a mob within 12 blocks is leashed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM COUNT-LOOSE-LEADS
     MOVE WS-LEADS TO WS-LEADS0
     CALL "TEST-INTERACT" USING WS-CONN WS-COW-ID WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.3 Leashing: the holder unleashes by interacting" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-LOOSE-LEADS
     MOVE "acceptance US15 18§8.3 Leashing: the unleashed lead drops as an item" TO WS-CASE
     COMPUTE WS-EXPECT = WS-LEADS0 + 1
     MOVE WS-LEADS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.3 Leashing: an empty hand on a free mob does nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     CALL "TEST-INTERACT" USING WS-CONN WS-COW-ID WS-HAND0 WS-SNEAK0
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N

*> A viewer that starts tracking a leashed mob is sent the link
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-COW WS-OK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-COW:1)
     CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-COW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE " 102" TO WS-NEEDLE
     PERFORM COUNT-PACKET
     MOVE "acceptance US15 18§8.3 Leashing: a new viewer is sent Set Entity Link after Add Entity" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N

*> A holder that is gone, or a mob that is defeated, drops the lead
     PERFORM COUNT-LOOSE-LEADS
     MOVE WS-LEADS TO WS-LEADS0
     MOVE WS-GONE TO EN-LEASH(WS-COW)
     CALL "TEST-TICKS-ANSWERED" USING 1
     MOVE "acceptance US15 18§8.3 Leashing: a lead whose holder is gone is dropped" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-LOOSE-LEADS
     MOVE "acceptance US15 18§8.3 Leashing: the lead of a gone holder is an item" TO WS-CASE
     COMPUTE WS-EXPECT = WS-LEADS0 + 1
     MOVE WS-LEADS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-LEADS TO WS-LEADS0
     CALL "MOB-LEASH-ATTACH" USING WS-PLAYER WS-COW WS-OK
     MOVE 0 TO EN-HEALTH(WS-COW)
     CALL "TEST-TICKS-ANSWERED" USING 1
     MOVE "acceptance US15 18§8.3 Leashing: a defeated mob drops its lead" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LEASH(WS-COW) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM COUNT-LOOSE-LEADS
     MOVE "acceptance US15 18§8.3 Leashing: the lead of a defeated mob is an item" TO WS-CASE
     COMPUTE WS-EXPECT = WS-LEADS0 + 1
     MOVE WS-LEADS TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

 COUNT-LOOSE-LEADS.
     MOVE 0 TO WS-LEADS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-LEAD-ITEM
             ADD EN-ITEM-COUNT(WS-I) TO WS-LEADS
         END-IF
     END-PERFORM.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 GIVE-HELD.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1).

 COUNT-PACKET.
     MOVE SPACES TO WS-HAYSTACK
     STRING " " DELIMITED BY SIZE WS-TEXT DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-HITS
     INSPECT WS-HAYSTACK TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE) .

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-LEASH.
 COPY CORETEST.
