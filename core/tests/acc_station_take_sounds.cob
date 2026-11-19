*> Acceptance test of the sounds of taking a result out of a workstation (docs/protocol/57-client-closures-2 section 3; 40-3 section 3 step 6; 40-4 section 1 rule 5): the stonecutter's take
*> sends one Clientbound Sound (0x77: ui.stonecutter.take_result, id 1676, source blocks, the block centre in eighths, volume 1.0, pitch 1.0) to the players within 16 blocks, the taker included,
*> once per game tick per menu; the grindstone sends Level Event 1042 and the smithing table 1044 (Data 0, not global) to the players within 64 blocks with no throttle; the anvil sends 1030
*> (infinite materials, a failed 12 percent roll, a block outside the tag anvil: the block is untouched) or damages the block (anvil to chipped_anvil to damaged_anvil, facing kept) and
*> sends 1030, and the take of a damaged anvil that wins the roll removes the block and sends 1029. The loom and the cartography table have no menu in the core (MENU-STATION-KIND), so no take.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-STATION-TAKE-SOUNDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY CBLOCKS.
 COPY COREAPI.
 COPY PROTO.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-CHIPPED             BINARY-LONG.
 01 WS-DAMAGED             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE-NOW           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-EVENT               BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-GLOBAL              BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-SEEN-1030           BINARY-LONG.
 01 WS-SEEN-1029           BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-F                   PIC 9.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-NONE         BINARY-LONG VALUE -1.
 01 WS-PACKET-47           BINARY-LONG VALUE 47.
 01 WS-PACKET-119          BINARY-LONG VALUE 119.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-ROW)) + 2
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     COMPUTE PL-X(WS-ROW2) = PL-X(WS-ROW) + 30
     MOVE "anvil" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-ANVIL
     MOVE "chipped_anvil" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-CHIPPED
     MOVE "damaged_anvil" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-DAMAGED
     MOVE "stone" TO WS-KEY
     CALL "TEST-BLOCK-ID" USING WS-KEY WS-ID
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STONE
     MOVE "T" TO TL-MODE
     MOVE WS-DIM TO MN-BENCH-DIM(WS-ROW)
     MOVE WS-BX TO MN-BENCH-X(WS-ROW)
     MOVE WS-BY TO MN-BENCH-Y(WS-ROW)
     MOVE WS-BZ TO MN-BENCH-Z(WS-ROW)
     MOVE 0 TO MN-WSOUND(WS-ROW)
     MOVE -1 TO MN-WSEL(WS-ROW)
     MOVE 1000 TO CW-TICKS
     PERFORM DRAIN-BOTH

*>   Stonecutter: the take sound (21).
     MOVE 21 TO MN-CFAMILY(WS-ROW)
     PERFORM TAKE-STONECUTTER
     PERFORM READ-SOUND
     MOVE "acceptance station take sounds the stonecutter take sends Sound ui.stonecutter.take_result (holder 1677) in source blocks at the block centre, volume 1, pitch 1, to the taker" TO TL-CASE
     COMPUTE WS-E1 = WS-BX * 8 + 4
     COMPUTE WS-E2 = WS-BY * 8 + 4
     COMPUTE WS-E3 = WS-BZ * 8 + 4
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 holder 1677 source 4 at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " vol 1 pitch 1"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-119 PB-BUFFER WS-FOUND
     MOVE "acceptance station take sounds a player 30 blocks away (beyond the 16 of the sound) hears nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     PERFORM TAKE-STONECUTTER
     PERFORM READ-SOUND
     MOVE "acceptance station take sounds a second take in the same game tick plays no sound (once per tick per menu)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     ADD 1 TO CW-TICKS
     PERFORM TAKE-STONECUTTER
     PERFORM READ-SOUND
     MOVE "acceptance station take sounds a take in the next game tick plays the sound again" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Grindstone (22) and smithing table (23): level events 1042 and 1044, every take.
     MOVE 22 TO MN-CFAMILY(WS-ROW)
     PERFORM TAKE-GENERIC
     PERFORM READ-EVENT
     MOVE "acceptance station take sounds the grindstone take sends Level Event 1042, data 0, not global at the block" TO TL-CASE
     PERFORM EVENT-TEXT
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-BX TO WS-E1
     MOVE WS-BY TO WS-E2
     MOVE WS-BZ TO WS-E3
     STRING "found 1 event 1042 at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " data 0 global 0"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     PERFORM TAKE-GENERIC
     PERFORM READ-EVENT
     MOVE "acceptance station take sounds a second grindstone take in the same tick sends the event again (no throttle)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 23 TO MN-CFAMILY(WS-ROW)
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1) MN-WSLOT-COUNT(WS-ROW, 2) MN-WSLOT-COUNT(WS-ROW, 3)
     PERFORM TAKE-GENERIC
     PERFORM READ-EVENT
     MOVE "acceptance station take sounds the smithing table take sends Level Event 1044" TO TL-CASE
     PERFORM EVENT-TEXT
     MOVE WS-BX TO WS-E1
     MOVE WS-BY TO WS-E2
     MOVE WS-BZ TO WS-E3
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 event 1044 at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " data 0 global 0"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-47 PB-BUFFER WS-FOUND
     MOVE "acceptance station take sounds a player 30 blocks away is within the 64 blocks of a level event and hears it" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

*>   Anvil (24): creative takes keep the block and send 1030.
     MOVE 24 TO MN-CFAMILY(WS-ROW)
     COMPUTE WS-STATE = WS-ANVIL + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-CHANGED
     MOVE 0 TO WS-SEEN-1029 WS-SEEN-1030
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM TAKE-ANVIL
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE-NOW
     MOVE "acceptance station take sounds 60 creative anvil takes never damage the block (still the same state) and every one sends 1030" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-SEEN-1030 TO WS-E1
     MOVE WS-SEEN-1029 TO WS-E2
     COMPUTE WS-STATE = WS-ANVIL + 2
     MOVE 0 TO WS-E3
     IF WS-STATE-NOW = WS-STATE
         MOVE 1 TO WS-E3
     END-IF
     STRING "1030 x" FUNCTION TRIM(WS-E1) " 1029 x" FUNCTION TRIM(WS-E2) " same " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1030 x60 1029 x0 same 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   A block outside the tag anvil: stone at the position: the roll is not drawn, 1030 only.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-SEEN-1029 WS-SEEN-1030
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM TAKE-ANVIL
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE-NOW
     MOVE "acceptance station take sounds 60 survival takes at a block outside the tag anvil leave it and send 1030 each time" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-SEEN-1030 TO WS-E1
     MOVE WS-SEEN-1029 TO WS-E2
     MOVE 0 TO WS-E3
     IF WS-STATE-NOW = WS-STONE
         MOVE 1 TO WS-E3
     END-IF
     STRING "1030 x" FUNCTION TRIM(WS-E1) " 1029 x" FUNCTION TRIM(WS-E2) " same " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1030 x60 1029 x0 same 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   Survival: an anvil (facing offset 2) is damaged by a won roll: chipped, same facing; every event is 1030.
     COMPUTE WS-STATE = WS-ANVIL + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-SEEN-1029 WS-SEEN-1030 WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-CHANGED = 1
         PERFORM TAKE-ANVIL
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE-NOW
         IF WS-STATE-NOW NOT = WS-STATE
             MOVE 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     MOVE "acceptance station take sounds an anvil of a survival taker is chipped by a won 12 percent roll with its facing kept, and the events are 1030" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-SEEN-1030 TO WS-E1
     MOVE WS-SEEN-1029 TO WS-E2
     MOVE 0 TO WS-E3
     COMPUTE WS-STATE = WS-CHIPPED + 2
     IF WS-STATE-NOW = WS-STATE
         MOVE 1 TO WS-E3
     END-IF
     MOVE 0 TO WS-E5
     IF WS-SEEN-1030 = WS-I - 1
         MOVE 1 TO WS-E5
     END-IF
     MOVE SPACES TO WS-TEXT
     STRING "1029 x" FUNCTION TRIM(WS-E2) " chipped " FUNCTION TRIM(WS-E3) " every take sent 1030 " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1029 x0 chipped 1 every take sent 1030 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   A damaged anvil that wins the roll is removed (event 1029, no 1030 for that take).
     COMPUTE WS-STATE = WS-DAMAGED + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO WS-SEEN-1029 WS-SEEN-1030 WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-CHANGED = 1
         PERFORM TAKE-ANVIL
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE-NOW
         IF WS-STATE-NOW NOT = WS-STATE
             MOVE 1 TO WS-CHANGED
         END-IF
     END-PERFORM
     MOVE "acceptance station take sounds a damaged anvil that wins the roll is removed and the last event is 1029" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-SEEN-1029 TO WS-E1
     MOVE WS-STATE-NOW TO WS-E2
     MOVE 0 TO WS-E5
     IF WS-SEEN-1030 = WS-I - 2
         MOVE 1 TO WS-E5
     END-IF
     STRING "1029 x" FUNCTION TRIM(WS-E1) " block " FUNCTION TRIM(WS-E2) " earlier 1030 only " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "1029 x1 block 0 earlier 1030 only 1" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     STOP RUN.

 DRAIN-BOTH.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-NONE PB-BUFFER WS-FOUND.

 TAKE-STONECUTTER.
     MOVE 1 TO MN-WSLOT-COUNT(WS-ROW, 1)
     MOVE 1 TO MN-WSLOT-ITEM(WS-ROW, 1)
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "MENU-STATION-TAKEN" USING WS-ROW.

 TAKE-GENERIC.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "MENU-STATION-TAKEN" USING WS-ROW.

 TAKE-ANVIL.
     MOVE 0 TO MN-WDATA(WS-ROW, 1)
     MOVE 0 TO MN-WSEL(WS-ROW)
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "MENU-STATION-TAKEN" USING WS-ROW
     PERFORM READ-EVENT
     IF WS-FOUND = 1 AND WS-EVENT = 1030
         ADD 1 TO WS-SEEN-1030
     END-IF
     IF WS-FOUND = 1 AND WS-EVENT = 1029
         ADD 1 TO WS-SEEN-1029
     END-IF.

*>   The first Sound packet (0x77 = 119) the connection was sent: holder, source, x, y, z, volume, pitch.
 READ-SOUND.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-119 PB-BUFFER WS-FOUND
     MOVE 0 TO WS-HOLDER WS-SOURCE WS-PX WS-PY WS-PZ
     MOVE 0 TO WS-VOLUME WS-PITCH
     IF WS-FOUND = 1
         MOVE 0 TO PB-POS
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-HOLDER
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SOURCE
         CALL "PB-GET-INT" USING PB-BUFFER WS-PX
         CALL "PB-GET-INT" USING PB-BUFFER WS-PY
         CALL "PB-GET-INT" USING PB-BUFFER WS-PZ
         CALL "PB-GET-FLOAT" USING PB-BUFFER WS-VOLUME
         CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PITCH
     END-IF
     MOVE WS-FOUND TO WS-F
     MOVE WS-HOLDER TO WS-E1
     MOVE WS-SOURCE TO WS-E2
     MOVE WS-PX TO WS-E3
     MOVE WS-PY TO WS-E4
     MOVE WS-PZ TO WS-E5
     COMPUTE WS-E6 ROUNDED = WS-VOLUME
     COMPUTE WS-E7 ROUNDED = WS-PITCH
     MOVE SPACES TO WS-TEXT
     STRING "found " WS-F " holder " FUNCTION TRIM(WS-E1) " source " FUNCTION TRIM(WS-E2) " at " FUNCTION TRIM(WS-E3) " "
         FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " vol " FUNCTION TRIM(WS-E6) " pitch " FUNCTION TRIM(WS-E7)
         DELIMITED BY SIZE INTO WS-TEXT.

*>   The first Level Event packet (0x2F = 47): event, position, data, global.
 READ-EVENT.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-47 PB-BUFFER WS-FOUND
     MOVE 0 TO WS-EVENT WS-PX WS-PY WS-PZ WS-DATA WS-GLOBAL
     IF WS-FOUND = 1
         MOVE 0 TO PB-POS
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
         CALL "PB-GET-INT" USING PB-BUFFER WS-EVENT
         CALL "PB-GET-POSITION" USING PB-BUFFER WS-PX WS-PY WS-PZ
         CALL "PB-GET-INT" USING PB-BUFFER WS-DATA
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-GLOBAL
     END-IF.

 EVENT-TEXT.
     MOVE WS-FOUND TO WS-F
     MOVE WS-EVENT TO WS-E1
     MOVE WS-PX TO WS-E2
     MOVE WS-PY TO WS-E3
     MOVE WS-PZ TO WS-E4
     MOVE WS-DATA TO WS-E5
     MOVE WS-GLOBAL TO WS-E6
     MOVE SPACES TO WS-TEXT
     STRING "found " WS-F " event " FUNCTION TRIM(WS-E1) " at " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         FUNCTION TRIM(WS-E4) " data " FUNCTION TRIM(WS-E5) " global " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK-TEXT.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-STATION-TAKE-SOUNDS.

 COPY CORETEST.
 COPY BETEST.
