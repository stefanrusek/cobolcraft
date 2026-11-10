*> Test US12-client (spec 002 T3250 to T3261, in one file; docs/protocol/40-menus-6-mount-inventories.md sections 1 to 6): the mount inventories at GUI 320 x 240 (left 72, top 37).
*> MOUNT-VARIANT is the table of 5.1/5.2 (entity type id of 21 section 2: horse 67, donkey 37, mule 88, llama 79, trader llama 138, skeleton horse 119, zombie horse 155, nautilus 89,
*> zombie nautilus 156): kind, saddle slot shown, body slot shown, body icon; the Mount Screen Open packet (05a 0x2A: VarInt container, VarInt columns, Int entity) opens the screen of an
*> entity the client tracks and nothing for any other; slots (2.2: saddle (8, 18), body (8, 36), chest 80 + 18 col, 18 + 18 row; own count 2 + 3 columns, 7.1), the frames (6.3: saddle 7, 17,
*> body 7, 35, chest area 79, 17 of 18 x columns by 54) and the empty-slot icons (16 x 16 at the item cell) of the active slots only; the title is the mount's name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-40-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PACKET              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KIND-OUT            BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-ICON                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KEY-OUT             PIC X(512).
 01 WS-KEY-LEN             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-D4                  BINARY-LONG.
 01 WS-D5                  BINARY-LONG.
 01 WS-D6                  BINARY-LONG.
 01 WS-D7                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-T3                  BINARY-LONG.
 01 WS-T4                  BINARY-LONG.
 01 WS-T5                  BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LEN                 BINARY-LONG.
 01 WS-E1                  PIC -(7)9.
 01 WS-E2                  PIC -(7)9.
 01 WS-E3                  PIC -(7)9.
 01 WS-E4                  PIC -(7)9.
 01 WS-COLS                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-MS                  BINARY-LONG VALUE 20.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 3 TIMES.
       10 WS-EKIND         BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.

 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
     MOVE "T" TO TL-MODE
*>   5.2 the variants: "kind saddle body icon" per entity type (kind 1 horse family, 2 nautilus; icon 1 horse armor, 2 llama armor, 3 nautilus armor, 0 none).
     MOVE 67 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 horse (tamed adult): saddle yes, body yes, horse armor icon" TO TL-CASE
     MOVE "1 1 1 1 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 119 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 skeleton horse: saddle only" TO TL-CASE
     MOVE "1 1 0 0 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 155 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 zombie horse: saddle and body (horse armor)" TO TL-CASE
     MOVE "1 1 1 1 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 37 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 donkey: saddle only" TO TL-CASE
     MOVE "1 1 0 0 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 88 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 mule: saddle only" TO TL-CASE
     MOVE "1 1 0 0 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 79 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 llama: no saddle (the tag), body with the llama armor icon" TO TL-CASE
     MOVE "1 0 1 2 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 138 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 trader llama: the same as the llama" TO TL-CASE
     MOVE "1 0 1 2 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 89 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 nautilus: saddle and body (nautilus armor icon)" TO TL-CASE
     MOVE "2 1 1 3 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 156 TO WS-TYPE
     MOVE "acceptance US12 40-6§5 zombie nautilus: the same as the nautilus" TO TL-CASE
     MOVE "2 1 1 3 " TO TL-EXPECTED
     PERFORM SHOW-VARIANT
     MOVE 101 TO WS-TYPE
     CALL "MOUNT-VARIANT" USING WS-TYPE WS-KIND-OUT WS-SADDLE WS-BODY WS-ICON WS-KEY WS-KNOWN
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-6§3.3 an entity type that is no mount (101, pig) is not known" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-KNOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Own slot counts (7.1): 2 + 3 columns; the frame is the default 176 x 166 with the player inventory at (8, 84).
     MOVE 100 TO WS-D1
     PERFORM FRAME-NUMBERS
     MOVE "acceptance US12 40-6§2.2 a horse (no chest): 2 own slots, 176 x 166, inventory at (8, 84)" TO TL-CASE
     MOVE 2176166 TO TL-EXPECTED-N
     MOVE WS-D7 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 103 TO WS-D1
     PERFORM FRAME-NUMBERS
     MOVE "acceptance US12 40-6§7.1 a llama with 3 columns: 11 own slots" TO TL-CASE
     MOVE 11176166 TO TL-EXPECTED-N
     MOVE WS-D7 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 105 TO WS-D1
     PERFORM FRAME-NUMBERS
     MOVE "acceptance US12 40-6§7.1 a donkey with a chest (5 columns): 17 own slots" TO TL-CASE
     MOVE 17176166 TO TL-EXPECTED-N
     MOVE WS-D7 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 110 TO WS-D1
     PERFORM FRAME-NUMBERS
     MOVE "acceptance US12 40-6§7.1 a nautilus: 2 own slots" TO TL-CASE
     MOVE 2176166 TO TL-EXPECTED-N
     MOVE WS-D7 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Slot positions (2.2, 7.1 llama of 3 columns): saddle (8, 18), body (8, 36), chest 2 (80, 18), 4 (116, 18), 5 (80, 36), 10 (116, 54).
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 103 TO WS-D1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 10
         IF WS-I < 2 OR WS-I = 2 OR WS-I = 4 OR WS-I = 5 OR WS-I = 10
             MOVE WS-I TO WS-D2
             CALL "CONTAINER-SLOT-POS" USING WS-D1 WS-D2 WS-D3 WS-D4
             MOVE WS-D3 TO WS-E1
             MOVE WS-D4 TO WS-E2
             MOVE WS-I TO WS-E3
             STRING FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "acceptance US12 40-6§7.1 own slot positions: saddle (8, 18), body (8, 36), chest 2 (80, 18), 4 (116, 18), 5 (80, 36), 10 (116, 54)" TO TL-CASE
     MOVE "0=8,18 1=8,36 2=80,18 4=116,18 5=80,36 10=116,54 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Mount Screen Open packet: the fixture container 1, columns 3, entity 0x102 (bytes 01 03 00 00 01 02), a llama the client tracks.
     MOVE 1 TO EN-USED(1)
     MOVE 258 TO EN-ID(1)
     MOVE 79 TO EN-TYPE(1)
     MOVE 1 TO EN-USED(2)
     MOVE 259 TO EN-ID(2)
     MOVE 1 TO EN-TYPE(2)
     MOVE 2 TO EN-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     MOVE X"010300000102" TO WS-TEXT(1:6)
     MOVE 6 TO WS-LEN
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-TEXT WS-LEN
     MOVE 42 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-6§3.2 the packet 01 03 00 00 01 02 opens the llama's menu: container 1, 3 columns (type 103), the container screen" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100000 + 103 * 100 + SCR-CONTAINER
     COMPUTE TL-OBSERVED-N = BM-ID * 100000 + BM-TYPE * 100 + SM-SCREEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "T" TO TL-MODE
     PERFORM OWN-SLOTS
     MOVE "acceptance US12 40-6§6 llama, 3 columns: no saddle slot (inactive), the body slot (79, 72) and the 9 chest slots (arguments 403 to 411) are drawn" TO TL-CASE
     MOVE "402:79:72 403:151:54 404:169:54 405:187:54 406:151:72 407:169:72 408:187:72 409:151:90 410:169:90 411:187:90 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 llama: the chest area 54 x 54 at (79, 17), the body frame at (7, 35), the empty body icon at (8, 36): no saddle frame" TO TL-CASE
     MOVE "151:54:54x54 79:72:18x18 80:73:16x16 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   6.1 the title is the mount's name (the entity type's name from the language) at (8, 6); the inventory label at (8, 72).
     MOVE "entity.minecraft.llama" TO WS-TEXT
     MOVE 22 TO WS-LEN
     CALL "LANG-GET" USING CLIENT-STATE WS-TEXT WS-LEN WS-KEY-OUT WS-KEY-LEN
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "=" SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) ";" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-EXPECTED
     STRING "80:43=" WS-KEY-OUT(1:WS-KEY-LEN) ";80:109=Inventory;" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE "acceptance US12 40-6§6.1 the title is the mount's name at (8, 6) = (80, 43) and the inventory label at (8, 72) = (80, 109)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO BX-COUNT(2)
     MOVE 2 TO BX-ITEM(2)
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 a carpet in the body slot: no empty-slot icon" TO TL-CASE
     MOVE "151:54:54x54 79:72:18x18 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO BX-COUNT(2)
*>   The other entities: horse, skeleton horse, donkey with a chest, nautilus.
     MOVE 67 TO EN-TYPE(1)
     MOVE 0 TO WS-COLS
     PERFORM OPEN-MOUNT
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 horse: the saddle frame (7, 17) and the body frame (7, 35), their empty icons, no chest area" TO TL-CASE
     MOVE "79:54:18x18 79:72:18x18 80:55:16x16 80:73:16x16 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 119 TO EN-TYPE(1)
     PERFORM OPEN-MOUNT
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 skeleton horse: only the saddle frame and icon" TO TL-CASE
     MOVE "79:54:18x18 80:55:16x16 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 37 TO EN-TYPE(1)
     MOVE 5 TO WS-COLS
     PERFORM OPEN-MOUNT
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 donkey with a chest (5 columns): chest area 90 x 54, the saddle frame and icon, no body slot" TO TL-CASE
     MOVE "151:54:90x54 79:54:18x18 80:55:16x16 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 89 TO EN-TYPE(1)
     MOVE 0 TO WS-COLS
     PERFORM OPEN-MOUNT
     PERFORM OVERLAYS
     MOVE "acceptance US12 40-6§6.2 nautilus: the saddle and body frames and icons, no chest area" TO TL-CASE
     MOVE "79:54:18x18 79:72:18x18 80:55:16x16 80:73:16x16 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Wire slots (7.1): llama of 3 columns: the main inventory is 11 to 37, the hotbar 38 to 46.
     MOVE 79 TO EN-TYPE(1)
     MOVE 3 TO WS-COLS
     PERFORM OPEN-MOUNT
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1 MOVE 402 TO WS-D1
             WHEN 2 MOVE 411 TO WS-D1
             WHEN 3 MOVE 9 TO WS-D1
             WHEN 4 MOVE 35 TO WS-D1
             WHEN 5 MOVE 8 TO WS-D1
         END-EVALUATE
         CALL "CONTAINER-WIRE" USING CLIENT-STATE WS-D1 WS-D2
         MOVE WS-D2 TO WS-E1
         STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 40-6§7.1 menu slots of a llama with 3 columns: body 1, last chest 10, main inventory 11 to 37, hotbar 38 to 46" TO TL-CASE
     MOVE "1 10 11 37 46 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An entity the client does not know, and one that is no mount: nothing happens.
     MOVE SCR-WORLD TO WS-D1
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-D1
     MOVE 0 TO BM-ID BM-TYPE
     MOVE 999 TO WS-ENTITY
     MOVE 5 TO WS-D2
     PERFORM SEND-OPEN
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 40-6§3.3 an entity id the client does not track: no menu, the screen stays the world" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-WORLD
     COMPUTE TL-OBSERVED-N = SM-SCREEN + BM-ID * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 259 TO WS-ENTITY
     PERFORM SEND-OPEN
     MOVE "acceptance US12 40-6§3.3 an entity that is no horse or nautilus (259, a stand-in type): no menu" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-WORLD
     COMPUTE TL-OBSERVED-N = SM-SCREEN + BM-ID * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 258 TO WS-ENTITY
     MOVE 6 TO WS-D2
     PERFORM SEND-OPEN
     MOVE "acceptance US12 40-6§4 a packet with 6 chest columns (above the 5 of the screen) is refused: no menu (coverage of the guard)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = SCR-WORLD
     COMPUTE TL-OBSERVED-N = SM-SCREEN + BM-ID * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> "kind saddle body icon " of the entity type WS-TYPE in TL-OBSERVED, asserted.
 SHOW-VARIANT.
     CALL "MOUNT-VARIANT" USING WS-TYPE WS-KIND-OUT WS-SADDLE WS-BODY WS-ICON WS-KEY WS-KNOWN
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-KIND-OUT TO WS-E1
     MOVE WS-SADDLE TO WS-E2
     MOVE WS-BODY TO WS-E3
     MOVE WS-ICON TO WS-E4
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> WS-D7 = own slots * 1000000 + width * 1000 + height of the menu type WS-D1 (CONTAINER-FRAME).
 FRAME-NUMBERS.
     CALL "CONTAINER-FRAME" USING WS-D1 WS-D2 WS-D3 WS-D4 WS-D5 WS-D6 WS-D7 WS-T1 WS-T2 WS-T3 WS-T4 WS-T5 WS-KNOWN
     COMPUTE WS-D7 = WS-D2 * 1000000 + WS-D6 * 1000 + WS-D7
     .

*> Open the mount of entity 258 with WS-COLS columns (the packet) and build.
 OPEN-MOUNT.
     MOVE 258 TO WS-ENTITY
     MOVE WS-COLS TO WS-D2
     PERFORM SEND-OPEN
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     .

*> Mount Screen Open: container 1, columns WS-D2, entity WS-ENTITY.
 SEND-OPEN.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-D1
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D1
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-D2
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ENTITY
     MOVE 42 TO WS-PACKET
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-PACKET
     .

*> The own slot widgets "argument:x:y " (arguments 401 and up).
 OWN-SLOTS.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) >= 401
             MOVE SM-W-ARG(WS-I) TO WS-E1
             MOVE SM-W-X(WS-I) TO WS-E2
             MOVE SM-W-Y(WS-I) TO WS-E3
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

*> Every overlay after the panel as "x:y:wxh " (the highlight sprites are not overlays).
 OVERLAYS.
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-OVERLAY
             MOVE SM-W-X(WS-I) TO WS-E1
             MOVE SM-W-Y(WS-I) TO WS-E2
             MOVE SM-W-W(WS-I) TO WS-E3
             MOVE SM-W-H(WS-I) TO WS-E4
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) ":" FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     .

 END PROGRAM TEST-SCREEN-40-6.

 COPY CLTEST.
