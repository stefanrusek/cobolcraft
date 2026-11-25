*> Acceptance test (CC-0014; docs/protocol/25 part 7 section 12.2 InstrumentItem.use, 05a Cooldown 0x16, 05b Sound 0x77, 30 part 8 instrument_play): using a goat horn plays its
*> instrument and starts the item cooldown. Use Item with a goat_horn in the hand that uses (hand 0 the held slot, hand 1 the off-hand) sends the Sound of item.goat_horn.sound.0
*> (holder 846 = registry id 845 + 1, source records 2, the player's position in eighths, volume 16.0, pitch 1.0) to the viewers except the player, posts the game event
*> instrument_play at the player (the player as its source) and sends the player Cooldown (group minecraft:goat_horn, 140 ticks). A horn on its cooldown does nothing until
*> 140 ticks after the use; the cooldown belongs to one player; any other item, an empty hand and a spectator play nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGHORN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY GAMEEVENT.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Bobby".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-USER                BINARY-LONG.
 01 WS-READER              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-NONE         BINARY-LONG VALUE -1.
 01 WS-PACKET-SOUND        BINARY-LONG VALUE 119.
 01 WS-PACKET-COOLDOWN     BINARY-LONG VALUE 22.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUP               PIC X(64).
 01 WS-GROUP-LENGTH        BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-F                   PIC 9.
 01 WS-TEXT                PIC X(256).
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     MOVE 0 TO PL-MODE(WS-ROW2) PL-HELD(WS-ROW2)
     MOVE PL-X(WS-PLAYER) TO PL-X(WS-ROW2)
     MOVE PL-Y(WS-PLAYER) TO PL-Y(WS-ROW2)
     MOVE PL-Z(WS-PLAYER) TO PL-Z(WS-ROW2)
     MOVE "T" TO TL-MODE
     MOVE "goat_horn" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE WS-CONN TO WS-USER
     MOVE 0 TO WS-HAND

*>   The first use: Bobby, who looks on, is sent the sound at the player's position; the game event is posted; the player is sent the cooldown.
     MOVE 1000 TO CW-TICKS
     PERFORM DRAIN-BOTH
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: a goat horn used plays item.goat_horn.sound.0 (holder 846) in source records at the player, volume 16, pitch 1, to a viewer" TO WS-CASE
     COMPUTE WS-E1 = FUNCTION INTEGER-PART(PL-X(WS-PLAYER) * 8)
     COMPUTE WS-E2 = FUNCTION INTEGER-PART(PL-Y(WS-PLAYER) * 8)
     COMPUTE WS-E3 = FUNCTION INTEGER-PART(PL-Z(WS-PLAYER) * 8)
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 holder 846 source 2 at " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " vol 16 pitch 1"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance bughorn 25-7 12.2: the game event instrument_play is posted once at the player with the player as its source" TO WS-CASE
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-E4
     MOVE GE-SOURCE TO WS-E5
     COMPUTE WS-E6 = GE-COUNT - WS-BEFORE
     MOVE SPACES TO TL-EXPECTED
     STRING "instrument_play row " FUNCTION TRIM(WS-E4) " posted 1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(GE-NAME) " row " FUNCTION TRIM(WS-E5) " posted " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO WS-TEXT
     PERFORM CHECK-TEXT
     MOVE WS-CONN TO WS-READER
     PERFORM READ-COOLDOWN
     MOVE "acceptance bughorn 25-7 12.2: the player is sent Cooldown for minecraft:goat_horn of 140 ticks (floor(7.0 x 20))" TO WS-CASE
     MOVE "found 1 group minecraft:goat_horn ticks 140" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   139 ticks after the use the horn is still on its cooldown: nothing is played, posted or sent.
     MOVE 1139 TO CW-TICKS
     PERFORM DRAIN-BOTH
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: a horn on its cooldown (139 ticks after the use) plays no sound" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance bughorn 25-7 12.2: and posts no game event" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N
     MOVE WS-CONN TO WS-READER
     PERFORM READ-COOLDOWN
     MOVE "acceptance bughorn 25-7 12.2: and sends no new Cooldown" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N

*>   140 ticks after the use the horn plays again, and the player does not hear what the viewers do.
     MOVE 1140 TO CW-TICKS
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: 140 ticks after the use the horn plays again" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-SOUND PB-BUFFER WS-FOUND
     MOVE "acceptance bughorn 25-7 12.2: the player who plays the horn is not sent the sound (the player is the except of the call)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N

*>   The cooldown is the player's own: Bobby plays a horn at once, and Stefan, who looks on, is sent the sound.
     MOVE 1141 TO CW-TICKS
     CALL "RT-GIVE1" USING WS-ROW2 WS-KEY WS-ONE
     PERFORM DRAIN-BOTH
     MOVE WS-CONN2 TO WS-USER
     PERFORM USE-ITEM
     MOVE WS-CONN TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: the cooldown of one player does not stop another player's horn (Stefan hears Bobby)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-CONN TO WS-USER

*>   The off-hand: a horn there is played by Use Item with hand 1 (and not by hand 0 while the held slot is empty).
     MOVE 5000 TO CW-TICKS
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     MOVE WS-ITEM TO MN-EQUIP-ITEM(WS-PLAYER, 5)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: Use Item with hand 0 and an empty held slot plays nothing even with a horn in the off-hand" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO WS-HAND
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: Use Item with hand 1 plays the horn of the off-hand" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: Use Item with hand 1 and an empty off-hand plays nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N

*>   Another item in the hand plays nothing and starts no cooldown; a spectator's horn is silent.
     MOVE 9000 TO CW-TICKS
     MOVE 0 TO WS-HAND
     MOVE "stone" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: a stone in the hand plays nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "goat_horn" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: a spectator's goat horn plays nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM DRAIN-BOTH
     PERFORM USE-ITEM
     MOVE WS-CONN2 TO WS-READER
     PERFORM READ-SOUND
     MOVE "acceptance bughorn 25-7 12.2: the same horn in survival plays (the stone and the spectator started no cooldown)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FOUND TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

 DRAIN-BOTH.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-NONE PB-BUFFER WS-FOUND.

 USE-ITEM.
     CALL "HORN-TEST-USE" USING WS-USER WS-HAND.

*>   The first Sound packet (0x77 = 119) the reader was sent: holder, source, x, y, z, volume, pitch.
 READ-SOUND.
     CALL "TEST-DRAIN-PACKET" USING WS-READER WS-PACKET-SOUND PB-BUFFER WS-FOUND
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

*>   The first Cooldown packet (0x16 = 22) the reader was sent: the group identifier and the ticks.
 READ-COOLDOWN.
     CALL "TEST-DRAIN-PACKET" USING WS-READER WS-PACKET-COOLDOWN PB-BUFFER WS-FOUND
     MOVE SPACES TO WS-GROUP
     MOVE 0 TO WS-GROUP-LENGTH WS-TICKS
     IF WS-FOUND = 1
         MOVE 0 TO PB-POS
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-GROUP WS-CAP WS-GROUP-LENGTH
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-TICKS
     END-IF
     MOVE WS-FOUND TO WS-F
     MOVE WS-TICKS TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "found " WS-F " group " WS-GROUP(1:WS-GROUP-LENGTH) " ticks " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK-TEXT.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 END PROGRAM ACC-BUGHORN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HORN-TEST-USE.
*> USING connection id, hand: feeds a Use Item (0x43) with that hand, sequence 0 and the angles 0 (TEST-USE-ITEM is hand 0 only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 67.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ANGLE               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-HAND.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-HAND
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-ANGLE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-ANGLE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HORN-TEST-USE.
 COPY CORETEST.
 COPY RANGEDTEST.
