*> Implementation test (T1759, T1760; docs/protocol/39-portals.md section 8 and V18, V19; core/src/dimensions.cob DIM-SWITCH, portals.cob): a player
*> changes dimension through a nether portal. The stream the player is sent is read packet by packet: Respawn first, then Change Difficulty (the
*> world difficulty, not locked) and the permission level as Entity Event 24 + level of her own entity (8.1 steps 5 and 6), Player Abilities, Set Held
*> Slot, Container Set Content, Initialize Border of the new level (centre, sizes, lerp time, absolute maximum, warning 5 and 300), the join
*> messages of the level, the chunk stream, Player Position, then Set Experience and Set Health (the "last sent" reset of step 19) and the portal
*> sound Level Event last; the values of Set Experience (progress, level, total) and Set Health; the portal changing flag stays until Accept
*> Teleportation (8.2); game mode, experience, health, inventory and the player's entity are unchanged (V19); a moving border is sent with its
*> current size, its target and the remaining time in milliseconds. Deviations from V18 (open items): the abilities, held slot and container
*> content are sent before the chunk stream and the position after it (the order of the join sequence, 09 section 3.2), the sound follows the refresh.
*> Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTAL.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4194304.
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-PORTAL              BINARY-LONG.
 01 WS-FRAME-AXIS          BINARY-LONG VALUE 0.
 01 WS-FRAME-W             BINARY-LONG VALUE 2.
 01 WS-FRAME-H             BINARY-LONG VALUE 3.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LAST-ID             BINARY-LONG VALUE -1.
 01 WS-RUN                 BINARY-LONG.
 01 WS-ORDER               PIC X(1024).
 01 WS-ORDER-PTR           BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-V3                  BINARY-LONG.
 01 WS-F1                  FLOAT-SHORT.
 01 WS-F2                  FLOAT-SHORT.
 01 WS-F3                  FLOAT-SHORT.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-D4                  FLOAT-LONG.
 01 WS-L                   BINARY-DOUBLE.
 01 WS-DIFFICULTY          PIC X(40).
 01 WS-EVENT               PIC X(40).
 01 WS-BORDER              PIC X(120).
 01 WS-XP                  PIC X(80).
 01 WS-HEALTH              PIC X(80).
 01 WS-POSITION-ID         BINARY-LONG.
 01 WS-SLOT-ITEM           BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EXPECT-ITEM         PIC X(20).
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-F                   PIC -(3)9.999999.
 01 WS-G                   PIC -(3)9.999999.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§8 A player changes dimension: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-ENTITY-ID(WS-ROW) TO WS-ENTITY
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 2 TO PL-XP-LEVEL(WS-ROW)
     MOVE 3 TO PL-XP-POINTS(WS-ROW)
     MOVE 10 TO PL-XP-TOTAL(WS-ROW)
     MOVE "flint_and_steel" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-V1 WS-ROW-TEXT WS-STATUS
     MOVE WS-V1 TO WS-SLOT-ITEM
     MOVE WS-SLOT-ITEM TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 3 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 10 TO WS-FX MOVE 100 TO WS-FY MOVE 10 TO WS-FZ
     CALL "PT-FRAME" USING DIM-STANDARD-OVERWORLD WS-FX WS-FY WS-FZ WS-FRAME-AXIS WS-FRAME-W WS-FRAME-H
     MOVE "nether_portal" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-PORTAL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-BX = 10 - WS-I
             COMPUTE WS-BY = 100 + WS-J
             MOVE 10 TO WS-BZ
             CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-BX WS-BY WS-BZ WS-PORTAL
         END-PERFORM
     END-PERFORM
     MOVE 10.0 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     MOVE 0 TO PL-YAW(WS-ROW)
*>   the first tick enters the portal (the overworld chunk stream of the move is discarded), the second transfers her
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-ORDER
     CALL "TEST-TICKS" USING WS-ONE

*>   The stream of the change, packet by packet.
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ALICE ST-BUFFER WS-CLOSE
     MOVE SPACES TO WS-ORDER
     MOVE 1 TO WS-ORDER-PTR
     MOVE SPACES TO WS-DIFFICULTY WS-EVENT WS-BORDER WS-XP WS-HEALTH
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
         CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-MINUS-ONE WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             PERFORM NOTE-PACKET
         END-IF
         CALL "PB-FREE" USING PK-BUFFER
     END-PERFORM
     PERFORM FLUSH-RUN
     CALL "PB-FREE" USING ST-BUFFER

     MOVE "acceptance US12 39§8 A player changes dimension: the packets come in order: Respawn, Difficulty, Event, Abilities, Slot, "
         & "Container Content, Initialize Border, spawn, Set Time, weather, the 25 chunks, Player Position, XP, Health, sound" TO TL-CASE
     MOVE "84 10 34 65 107 18 44 99 115 39 96 12 46x25 11 73 105 106 47" TO TL-EXPECTED
     MOVE WS-ORDER TO TL-OBSERVED
     PERFORM CHECK

     MOVE "acceptance US12 39§8 A player changes dimension: Change Difficulty carries the world difficulty 2 and not locked" TO TL-CASE
     MOVE "difficulty 2 locked 0" TO TL-EXPECTED
     MOVE WS-DIFFICULTY TO TL-OBSERVED
     PERFORM CHECK

     MOVE WS-ENTITY TO WS-A
     MOVE SPACES TO TL-EXPECTED
     STRING "entity " FUNCTION TRIM(WS-A) " event 24" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 39§8 A player changes dimension: the permission level 0 is Entity Event 24 of her own entity" TO TL-CASE
     MOVE WS-EVENT TO TL-OBSERVED
     PERFORM CHECK

     MOVE "acceptance US12 39§8 A player changes dimension: Initialize Border of the Nether: centre 0 0, size 59999968 both, no lerp, "
         & "absolute maximum 29999984, warning 5 blocks and 300" TO TL-CASE
     MOVE "c 0 0 size 59999968 59999968 lerp 0 max 29999984 warn 5 300" TO TL-EXPECTED
     MOVE WS-BORDER TO TL-OBSERVED
     PERFORM CHECK

     MOVE "acceptance US12 39§8 A player changes dimension: Set Experience re-sent with progress 3 / 11, level 2, total 10" TO TL-CASE
     MOVE "0.272727 2 10" TO TL-EXPECTED
     MOVE WS-XP TO TL-OBSERVED
     PERFORM CHECK

     MOVE "acceptance US12 39§8 A player changes dimension: Set Health re-sent with health 20, food 20, saturation 5" TO TL-CASE
     MOVE "20.000000 20 5.000000" TO TL-EXPECTED
     MOVE WS-HEALTH TO TL-OBSERVED
     PERFORM CHECK

*>   V19: nothing is lost; 8.2: the flag stays until the client acknowledges.
     MOVE PL-DIM(WS-ROW) TO WS-A
     MOVE PL-MODE(WS-ROW) TO WS-B
     MOVE PL-XP-LEVEL(WS-ROW) TO WS-C
     MOVE PL-SLOT-ITEM(WS-ROW, 5) TO WS-D
     MOVE PL-SLOT-COUNT(WS-ROW, 5) TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING "dim " FUNCTION TRIM(WS-A) " mode " FUNCTION TRIM(WS-B) " xp level " FUNCTION TRIM(WS-C) " slot " FUNCTION TRIM(WS-D) "x"
         FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§8 A player changes dimension: she is in the Nether (row 4) with game mode, experience level and inventory unchanged"
         TO TL-CASE
     MOVE WS-SLOT-ITEM TO WS-A
     MOVE SPACES TO TL-EXPECTED
     STRING "dim 4 mode 1 xp level 2 slot " FUNCTION TRIM(WS-A) "x3" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     MOVE PL-ENTITY-ID(WS-ROW) TO TL-OBSERVED-N
     MOVE WS-ENTITY TO TL-EXPECTED-N
     MOVE "acceptance US12 39§8 A player changes dimension: it is the same player entity (no new ServerPlayer, V19)" TO TL-CASE
     PERFORM CHECK-N

     MOVE PQ-PL-CHANGING(WS-ROW) TO WS-A
     MOVE PQ-PL-COOLDOWN(WS-ROW) TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "changing " FUNCTION TRIM(WS-A) " cooldown " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§8 A player changes dimension: until Accept Teleportation she is changing dimension and the cooldown of 10 is armed (8.2)"
         TO TL-CASE
     MOVE "changing 1 cooldown 10" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-TICKS" USING WS-ONE
     MOVE PQ-PL-CHANGING(WS-ROW) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "acceptance US12 39§8 A player changes dimension: a tick without the acknowledgement keeps the changing flag" TO TL-CASE
     PERFORM CHECK-N
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     CALL "TEST-TICKS" USING WS-ONE
     MOVE PQ-PL-CHANGING(WS-ROW) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     MOVE "acceptance US12 39§8 A player changes dimension: Accept Teleportation of the awaited id ends the changing flag on the next tick (8.2)"
         TO TL-CASE
     PERFORM CHECK-N

*>   A moving border of the destination is sent with its size now, its target and the remaining time in milliseconds.
     MOVE 100.0 TO WS-D1
     MOVE 200.0 TO WS-D2
     MOVE 100 TO WS-V1
     CALL "WORLDSIM-BORDER-LERP" USING DIM-STANDARD-NETHER WS-D1 WS-D2 WS-V1
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-ORDER
     CALL "DIM-BORDER-SEND" USING WS-ROW DIM-STANDARD-NETHER
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ALICE ST-BUFFER WS-CLOSE
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-MINUS-ONE WS-PACKET-ID WS-OUTCOME
     PERFORM READ-BORDER
     CALL "PB-FREE" USING PK-BUFFER
     CALL "PB-FREE" USING ST-BUFFER
     MOVE "acceptance US12 39§8 A player changes dimension: a border growing from 100 to 200 over 100 ticks is sent as sizes 100 and 200 with "
         & "a lerp time of 5000 ms" TO TL-CASE
     MOVE "c 0 0 size 100 200 lerp 5000 max 29999984 warn 5 300" TO TL-EXPECTED
     MOVE WS-BORDER TO TL-OBSERVED
     PERFORM CHECK
     STOP RUN.

*> The packet WS-PACKET-ID of PK-BUFFER: its place in the order text and the fields of the packets under test.
 NOTE-PACKET.
     IF WS-PACKET-ID = WS-LAST-ID
         ADD 1 TO WS-RUN
     ELSE
         PERFORM FLUSH-RUN
         MOVE WS-PACKET-ID TO WS-LAST-ID
         MOVE 1 TO WS-RUN
     END-IF
     EVALUATE WS-PACKET-ID
         WHEN 10
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-V1
             CALL "PB-GET-BOOL" USING PK-BUFFER WS-V2
             MOVE WS-V1 TO WS-A
             MOVE WS-V2 TO WS-B
             MOVE SPACES TO WS-DIFFICULTY
             STRING "difficulty " FUNCTION TRIM(WS-A) " locked " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-DIFFICULTY
         WHEN 34
             CALL "PB-GET-INT" USING PK-BUFFER WS-V1
             CALL "PB-GET-BYTE" USING PK-BUFFER WS-V2
             MOVE WS-V1 TO WS-A
             MOVE WS-V2 TO WS-B
             MOVE SPACES TO WS-EVENT
             STRING "entity " FUNCTION TRIM(WS-A) " event " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-EVENT
         WHEN 44
             PERFORM READ-BORDER
         WHEN 105
             CALL "PB-GET-FLOAT" USING PK-BUFFER WS-F1
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-V1
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-V2
             COMPUTE WS-F ROUNDED = WS-F1
             MOVE WS-V1 TO WS-A
             MOVE WS-V2 TO WS-B
             MOVE SPACES TO WS-XP
             STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-XP
         WHEN 106
             CALL "PB-GET-FLOAT" USING PK-BUFFER WS-F1
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-V1
             CALL "PB-GET-FLOAT" USING PK-BUFFER WS-F2
             COMPUTE WS-F ROUNDED = WS-F1
             COMPUTE WS-G ROUNDED = WS-F2
             MOVE WS-V1 TO WS-A
             MOVE SPACES TO WS-HEALTH
             STRING FUNCTION TRIM(WS-F) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-G) DELIMITED BY SIZE INTO WS-HEALTH
     END-EVALUATE.

*> Initialize Border fields of PK-BUFFER (after the packet id) into WS-BORDER.
 READ-BORDER.
     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-D1
     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-D2
     MOVE WS-D1 TO WS-A
     MOVE WS-D2 TO WS-B
     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-D3
     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-D4
     MOVE WS-D3 TO WS-C
     MOVE WS-D4 TO WS-D
     CALL "PB-GET-VARLONG" USING PK-BUFFER WS-L
     MOVE WS-L TO WS-E
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-V1
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-V2
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-V3
     MOVE SPACES TO WS-BORDER
     STRING "c " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " size " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " lerp " FUNCTION TRIM(WS-E)
         DELIMITED BY SIZE INTO WS-BORDER
     MOVE FUNCTION TRIM(WS-BORDER) TO WS-KEY
     MOVE WS-V1 TO WS-A
     MOVE WS-V2 TO WS-B
     MOVE WS-V3 TO WS-C
     MOVE SPACES TO WS-BORDER
     STRING FUNCTION TRIM(WS-KEY) " max " FUNCTION TRIM(WS-A) " warn " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-BORDER.

*> Appends the run of WS-LAST-ID to WS-ORDER (nothing for the first call, when no id is pending).
 FLUSH-RUN.
     IF WS-LAST-ID >= 0
         MOVE WS-LAST-ID TO WS-A
         IF WS-ORDER-PTR > 1
             STRING " " DELIMITED BY SIZE INTO WS-ORDER POINTER WS-ORDER-PTR
         END-IF
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-ORDER POINTER WS-ORDER-PTR
         IF WS-RUN > 1
             MOVE WS-RUN TO WS-A
             STRING "x" FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-ORDER POINTER WS-ORDER-PTR
         END-IF
     END-IF.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 END PROGRAM TEST-PORTAL-39-8.

 COPY CORETEST.
 COPY PORTALTEST.
