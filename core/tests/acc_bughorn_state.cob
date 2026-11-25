*> Acceptance test (CC-0014, docs/protocol/58 sections 2.1, 2.2, 5.2 and 5.8; 30 part 8 section 14.3.8): the use state of a player and what the viewers are told. Using a goat horn starts a use of
*> 140 ticks (item_interact_start at the player); the next tick sends the players who see the player Set Equipment of the used hand (slot 0 main hand, 1 off hand; the stack with its
*> components, so the horn keeps the instrument of its prototype: added 0 removed 0) and then Set Entity Data entry 8, the living entity flags (1 using an item, 2 the used hand is the off
*> hand; the player itself is sent the flags too). The use ends at 140 ticks, when the key is let go (Player Action 6) or the held slot changes, each with item_interact_finish at the player and the
*> flags byte back to 0 (a use with the off hand leaves bit 2: 3 then 2); a main hand start clears bit 2 again. The state is shared: a bow being drawn, eating and a raised shield set
*> and clear the same flags.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGHORN-STATE.
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
 01 WS-CONN-READ           BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-HAND                BINARY-LONG.
 01 WS-HORN                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-PACKET-NONE         BINARY-LONG VALUE -1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-2              PIC -(9)9.
 01 WS-CASE                PIC X(240).
 01 WS-WANT                PIC X(1024).
 01 WS-GOT                 PIC X(1024).
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-ITEM-A              BINARY-LONG.
 01 WS-ITEM-B              BINARY-LONG.
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
     CALL "RT-ITEM-ID" USING WS-KEY WS-HORN
     MOVE EN-ID(PL-ENTITY-ROW(WS-PLAYER)) TO WS-ENTITY
     MOVE WS-ENTITY TO WS-EDIT
     MOVE WS-HORN TO WS-EDIT-2
     MOVE 0 TO PL-HELD(WS-PLAYER) PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-HAND

*>   The use at tick 1000: item_interact_start then instrument_play are posted; nothing about the flags is sent before the tick.
     MOVE 1000 TO CW-TICKS
     PERFORM DRAIN-BOTH
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM USE-ITEM
     MOVE "acceptance bughorn 58 2.2: using a goat horn posts item_interact_start and then instrument_play at the player" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N
     MOVE "acceptance bughorn 58 2.2: the last event of the use is instrument_play (the start came first)" TO WS-CASE
     MOVE "instrument_play" TO WS-WANT
     MOVE GE-NAME TO WS-GOT
     PERFORM CHECK-TEXT
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM TICK-USER
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.2 and 5.8: the viewer is sent Set Equipment of the main hand (the horn, count 1, no component changes) and then Set Entity Data entry 8 = 1" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s0 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE WS-CONN TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.2: the player itself is sent its flags (entry 8 = 1) and no equipment" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT

*>   While the use lasts and nothing changes the next ticks send nothing; at 139 ticks the horn is still in use.
     MOVE 1139 TO CW-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.2: 139 ticks after the start the use goes on (no packet)" TO WS-CASE
     MOVE SPACES TO WS-WANT
     PERFORM CHECK-TEXT
     MOVE "acceptance bughorn 58 2.2: and nothing is posted" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N

*>   At 140 ticks the use completes: item_interact_finish once, the viewer gets entry 8 = 0; a tick later nothing more.
     MOVE 1140 TO CW-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM TICK-USER
     MOVE "acceptance bughorn 58 2.2: completion at 140 ticks posts item_interact_finish once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N
     MOVE "item_interact_finish" TO WS-WANT
     MOVE GE-NAME TO WS-GOT
     MOVE "acceptance bughorn 58 2.2: the event is item_interact_finish" TO WS-CASE
     PERFORM CHECK-TEXT
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: the viewer is sent entry 8 = 0 when the use completes" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 1141 TO CW-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM TICK-USER
     MOVE "acceptance bughorn 58 2.2: a finished use posts no second finish" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N

*>   The key let go (Player Action 6) 10 ticks into a use ends it: the finish event now, entry 8 = 0 with the next tick; the completion tick later adds nothing.
     MOVE 1200 TO CW-TICKS
     PERFORM USE-ITEM
     PERFORM TICK-USER
     MOVE 1210 TO CW-TICKS
     PERFORM DRAIN-BOTH
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     MOVE "acceptance bughorn 58 2.2: letting go of the key posts item_interact_finish" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: and the viewer is sent entry 8 = 0" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 1340 TO CW-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     PERFORM TICK-USER
     MOVE "acceptance bughorn 58 2.2: no completion follows a released use" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N

*>   A change of the held slot ends a use in the main hand (Set Carried Item).
     MOVE 1400 TO CW-TICKS
     PERFORM USE-ITEM
     PERFORM TICK-USER
     PERFORM DRAIN-BOTH
     MOVE GE-COUNT TO WS-BEFORE
     CALL "INV-HELD" USING WS-CONN WS-THREE
     MOVE "acceptance bughorn 58 2.2: a changed held slot ends the use (item_interact_finish)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = GE-COUNT - WS-BEFORE
     PERFORM CHECK-N
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: and the viewer is sent entry 8 = 0" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   The off hand: the horn in the off-hand slot with the used hand 1: Set Equipment slot 1 and entry 8 = 3, then 2 (bit 2 stays after the use) and 1 again with the main hand.
     MOVE 1600 TO CW-TICKS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE WS-HORN TO MN-EQUIP-ITEM(WS-PLAYER, 5)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 5)
     PERFORM DRAIN-BOTH
     MOVE 1 TO WS-HAND
     PERFORM USE-ITEM
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: a horn used with the off hand sends Set Equipment slot 1 and entry 8 = 3" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s1 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=3" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 1740 TO CW-TICKS
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: after the off-hand use ends the byte keeps bit 2 (entry 8 = 2)" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=2" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     MOVE "goat_horn" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE 1740 TO CW-TICKS
     MOVE 0 TO WS-HAND
     PERFORM USE-ITEM
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 2.1: a main hand start clears bit 2 again (entry 8 = 1)" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s0 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM TICK-USER
     PERFORM DRAIN-BOTH

*>   The state is shared: a bow being drawn, eating an apple and a raised shield set entry 8 = 1 and clear it again.
     MOVE "bow" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM-A
     MOVE "arrow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-TWO WS-KEY WS-ONE
     MOVE WS-ITEM-A TO WS-EDIT-2
     MOVE 1900 TO CW-TICKS
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: drawing a bow sends Set Equipment of the bow and entry 8 = 1" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s0 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE 1910 TO CW-TICKS
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: shooting the bow sends entry 8 = 0" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE "apple" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM-B
     MOVE WS-ITEM-B TO WS-EDIT-2
     MOVE 10 TO PL-FOOD(WS-PLAYER)
     MOVE 1920 TO CW-TICKS
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: eating an apple sends Set Equipment of the apple and entry 8 = 1" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s0 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: stopping eating sends entry 8 = 0" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     MOVE "shield" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM-B
     MOVE WS-ITEM-B TO WS-EDIT-2
     MOVE 2000 TO CW-TICKS
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: raising a shield sends Set Equipment of the shield and entry 8 = 1" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "q" FUNCTION TRIM(WS-EDIT) " s0 " FUNCTION TRIM(WS-EDIT-2) "x1 a0 r0 | e" FUNCTION TRIM(WS-EDIT) " 8=1" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM TICK-USER
     MOVE WS-CONN2 TO WS-CONN-READ
     PERFORM READ-VIEWER
     MOVE "acceptance bughorn 58 6: lowering the shield sends entry 8 = 0" TO WS-CASE
     MOVE SPACES TO WS-WANT
     STRING "e" FUNCTION TRIM(WS-EDIT) " 8=0" DELIMITED BY SIZE INTO WS-WANT
     PERFORM CHECK-TEXT
     STOP RUN.

 DRAIN-BOTH.
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-NONE PB-BUFFER WS-FOUND
     CALL "TEST-DRAIN-PACKET" USING WS-CONN2 WS-PACKET-NONE PB-BUFFER WS-FOUND.

 USE-ITEM.
     CALL "HORN-TEST-USE" USING WS-CONN WS-HAND.

 TICK-USER.
     CALL "HUNGER-TICK" USING WS-PLAYER.

 READ-VIEWER.
     CALL "BWH-DRAIN" USING WS-CONN-READ WS-GOT.

 CHECK-TEXT.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED
     MOVE WS-GOT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE.
 END PROGRAM ACC-BUGHORN-STATE.

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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BWH-DRAIN.
*> USING connection id, text out (PIC X(1024)): the Set Equipment (0x68) and Set Entity Data (0x65) packets the connection has queued, in the order they were sent, separated by " | ":
*> "q<entity> s<slot> <item>x<count> a<added components> r<removed components>" for each (slot, stack) pair of an equipment packet and "e<entity> <index>=<value>" for each entry of a data packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MORE                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 104
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-ENTITY
             MOVE 128 TO WS-SLOT
             PERFORM UNTIL WS-SLOT < 128 OR PK-ERROR = 1
                 CALL "PB-GET-UBYTE" USING PK-BUFFER WS-SLOT
                 CALL "PB-GET-ITEM-STACK" USING PK-BUFFER PK-ITEMSTACK-X
                 IF WS-PTR > 1
                     STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 MOVE WS-ENTITY TO WS-E1
                 COMPUTE WS-E2 = FUNCTION MOD(WS-SLOT, 128)
                 MOVE PK-ISX-ITEM TO WS-E3
                 MOVE PK-ISX-COUNT TO WS-E4
                 STRING "q" FUNCTION TRIM(WS-E1) " s" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4)
                     DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 MOVE PK-ISX-ADDED-COUNT TO WS-E1
                 MOVE PK-ISX-REMOVED-COUNT TO WS-E2
                 STRING " a" FUNCTION TRIM(WS-E1) " r" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-PERFORM
         END-IF
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 101
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-ENTITY
             MOVE 1 TO WS-MORE
             PERFORM UNTIL WS-MORE = 0
                 CALL "PB-GET-METADATA-ENTRY-X" USING PK-BUFFER PK-METADATA-ENTRY-X
                 IF PK-MX-INDEX = PK-MD-END OR PK-ERROR = 1
                     MOVE 0 TO WS-MORE
                 ELSE
                     IF WS-PTR > 1
                         STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     END-IF
                     MOVE WS-ENTITY TO WS-E1
                     MOVE PK-MX-INDEX TO WS-E2
                     MOVE PK-MX-INT TO WS-E3
                     STRING "e" FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) "=" FUNCTION TRIM(WS-E3)
                         DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM BWH-DRAIN.
 COPY CORETEST.
 COPY RANGEDTEST.
