*> Acceptance test (wrap C, T56404; docs/protocol/30 part 8 section 14.3.8): the game events of drawing a bow and charging a crossbow. LivingEntity.startUsingItem posts
*> item_interact_start (drawing a bow, charging a crossbow, raising a trident) and stopUsingItem posts item_interact_finish (a release, a completed charge, a changed held slot),
*> both at the player with the player as the source.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPC-BOWEVENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY GAMEEVENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-TICKS               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-K                   BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LIST                PIC X(400).
 01 WS-STARTS              BINARY-LONG.
 01 WS-FINISHES            BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     MOVE "bow" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE "arrow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-FIVE WS-KEY WS-TEN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A bow: Use Item posts one item_interact_start; the release (a full draw) posts one item_interact_finish.
     MOVE GE-COUNT TO WS-BEFORE
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 drawing a bow posts item_interact_start once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-STARTS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance 30-8 14.3.8 drawing a bow posts no item_interact_finish yet" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 releasing the bow posts item_interact_finish once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance 30-8 14.3.8 releasing the bow posts no second item_interact_start" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STARTS TO WS-OBSERVE
     PERFORM CHECK-N
*>   A release without a use in progress posts nothing.
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 a release with no use in progress posts nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-STARTS + WS-FINISHES
     PERFORM CHECK-N
*>   A second Use Item while the first still runs is not another start.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE GE-COUNT TO WS-BEFORE
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 a Use Item while the bow is already drawn is not another item_interact_start" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-STARTS TO WS-OBSERVE
     PERFORM CHECK-N
*>   The held slot changed during the draw: the release still ends the use with item_interact_finish.
     MOVE 1 TO PL-HELD(WS-PLAYER)
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 a release after the held slot changed still posts item_interact_finish" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N

*>   A crossbow: the charge starts with item_interact_start; the completed charge (25 ticks) posts item_interact_finish by itself.
     MOVE "crossbow" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE GE-COUNT TO WS-BEFORE
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 charging a crossbow posts item_interact_start once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-STARTS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 24 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE GE-COUNT TO WS-BEFORE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 the completed crossbow charge posts item_interact_finish" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 releasing after the charge finished posts nothing more" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-STARTS + WS-FINISHES
     PERFORM CHECK-N
*>   The crossbow is loaded: Use Item shoots it (no use starts). Reload, then change the held slot during the charge: the next tick ends the use with item_interact_finish.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE "crossbow" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 1 TO PL-HELD(WS-PLAYER)
     MOVE GE-COUNT TO WS-BEFORE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO PL-HELD(WS-PLAYER)
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 a held slot changed during the crossbow charge ends the use with item_interact_finish" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N

*>   A trident: raising it starts a use, releasing it early (nothing is thrown before 10 ticks) still ends it with item_interact_finish.
     MOVE "trident" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE GE-COUNT TO WS-BEFORE
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 raising a trident posts item_interact_start once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-STARTS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE GE-COUNT TO WS-BEFORE
     CALL "RT-RELEASE" USING WS-CONN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.3.8 an early trident release posts item_interact_finish once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-FINISHES TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> LIST-NEW: the item_interact_start and item_interact_finish events posted since WS-BEFORE, counted into WS-STARTS and WS-FINISHES.
 LIST-NEW.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM WS-BEFORE BY 1 UNTIL WS-K >= GE-COUNT
         COMPUTE WS-LOG = FUNCTION MOD(WS-K, 128) + 1
         STRING " " FUNCTION TRIM(GE-L-NAME(WS-LOG)) " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     MOVE 0 TO WS-STARTS WS-FINISHES
     INSPECT WS-LIST TALLYING WS-STARTS FOR ALL " item_interact_start "
     INSPECT WS-LIST TALLYING WS-FINISHES FOR ALL " item_interact_finish ".

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-WRAPC-BOWEVENTS.
 COPY CORETEST.
 COPY RANGEDTEST.
