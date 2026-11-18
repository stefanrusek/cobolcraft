*> Acceptance test (US14; docs/protocol/17 section 3.8, 25 part 5 section 5.5 and 29a section 7.4, 45 part 7 sections 8 and 9): mob buckets through the real play path. Interact (0x1A) with a
*> water_bucket on a living fish, axolotl or tadpole takes the mob into a mob bucket (the bucket item of its kind, its custom name as custom_name, bucket_entity_data holding Health as a
*> Float, PersistenceRequired when it is persistent, the tadpole's Age) and removes the mob; a survival player's water bucket is replaced (one of a stack is taken and the filled bucket added), a
*> creative player keeps the water bucket and gets the filled one in addition; another item or a mob of another kind does nothing. Use Item with a mob bucket empties the water into the cell
*> in front and spawns the mob there (Health, name, persistence and Age restored, fromBucket set); the bucket becomes an empty bucket.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-MOB-BUCKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-MOB                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-C61                 BINARY-LONG VALUE 61.
 01 WS-LOOK-YAW            FLOAT-SHORT VALUE 0.
 01 WS-LOOK-DOWN           FLOAT-SHORT VALUE 90.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 2.
 01 WS-TYPE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE-COD            BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-VALUE               PIC X(512).
 01 WS-VALUE64             PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FILLED-AT           BINARY-LONG.
 01 WS-BUCKETS             BINARY-LONG.
 01 WS-WATERS              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)

*>   Pickup: a cod named Fin with 2 health into a stack of one water bucket.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "cod" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-MOB
     MOVE 2 TO EN-HEALTH(WS-MOB)
     MOVE "Fin" TO EN-CNAME(WS-MOB)
     MOVE 3 TO EN-CNAME-LEN(WS-MOB)
     MOVE EN-ID(WS-MOB) TO WS-ID
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE-COD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "cod_bucket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     CALL "RT-COUNT" USING WS-TYPE-COD WS-COUNT WS-ROW
     MOVE "acceptance US14 25 5.5 a water bucket on a cod gives a cod bucket and the cod is gone" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-SLOT-ITEM(WS-PLAYER, 1) = WS-ITEM AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1 AND WS-COUNT = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "SP-GET-NAME" USING PL-SLOT-VAR(WS-PLAYER, 1) WS-NAME WS-NAME-LENGTH
     MOVE "acceptance US14 45 7 8 the cod's custom name is copied to the bucket (custom_name)" TO WS-CASE
     MOVE "Fin" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-NAME-LENGTH > 0
         MOVE WS-NAME(1:WS-NAME-LENGTH) TO TL-OBSERVED
     END-IF
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-GET-COMPONENT" USING PL-SLOT-VAR(WS-PLAYER, 1) WS-C61 WS-VALUE64 WS-LENGTH WS-FOUND
     MOVE SPACES TO WS-VALUE
     MOVE WS-VALUE64 TO WS-VALUE
     CALL "TEST-HEX-OF" USING WS-VALUE WS-LENGTH WS-HEX
     MOVE 0 TO WS-HITS
     INSPECT WS-HEX TALLYING WS-HITS FOR ALL "0a0500064865616c746840000000"
     MOVE "acceptance US14 45 7 8 bucket_entity_data (61) is the compound with Health 2.0 as a Float (tag 5, key Health, 40000000)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HITS * WS-FOUND
     PERFORM CHECK-N

*>   A stack of three water buckets: one is taken, the filled bucket goes elsewhere.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-THREE
     MOVE "salmon" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-MOB
     MOVE EN-ID(WS-MOB) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "salmon_bucket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     MOVE 0 TO WS-BUCKETS
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
         IF PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) > 0 AND PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) = WS-ITEM
             ADD 1 TO WS-BUCKETS
         END-IF
     END-PERFORM
     MOVE "acceptance US14 25 5.5 three water buckets: two stay, one salmon bucket appears in the inventory" TO WS-CASE
     MOVE 21 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + WS-BUCKETS
     PERFORM CHECK-N

*>   A creative player keeps the water bucket and gets the filled one too.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "pufferfish" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-MOB
     MOVE EN-ID(WS-MOB) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "pufferfish_bucket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     MOVE 0 TO WS-BUCKETS
     MOVE 0 TO WS-WATERS
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
         IF PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) > 0 AND PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) = WS-ITEM
             ADD 1 TO WS-BUCKETS
         END-IF
     END-PERFORM
     MOVE "acceptance US14 25 5.5 a creative player keeps the water bucket and also has the pufferfish bucket" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + WS-BUCKETS
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   An empty bucket and a mob that no bucket holds: nothing happens.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "tropical_fish" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-MOB
     MOVE EN-ID(WS-MOB) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "acceptance US14 25 5.5 an empty bucket does not pick up a tropical fish: still the empty bucket, the fish still there" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-USED(WS-MOB) = 1 AND PL-SLOT-COUNT(WS-PLAYER, 1) = 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     MOVE "acceptance US14 25 5.5 a water bucket on a cow is no pickup: still the water bucket" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-SLOT-ITEM(WS-PLAYER, 1) = WS-ITEM
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   Release: a tadpole bucket (age 100) used on the floor in front: the tadpole appears, the bucket is empty.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "water_bucket" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "tadpole" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-MOB
     MOVE 100 TO EN-TAD-AGE(WS-MOB)
     MOVE 1 TO EN-PERSISTENT(WS-MOB)
     MOVE EN-ID(WS-MOB) TO WS-ID
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "tadpole" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-TYPE
     CALL "RT-CLEAR-TYPE" USING WS-TYPE
     CALL "RT-USE-ITEM-AT" USING WS-CONN WS-LOOK-YAW WS-LOOK-DOWN
     CALL "RT-COUNT" USING WS-TYPE WS-COUNT WS-ROW
     MOVE "bucket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY WS-ITEM
     MOVE "acceptance US14 29a 7.4 a tadpole bucket used on the floor spawns the tadpole and leaves an empty bucket" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-SLOT-ITEM(WS-PLAYER, 1) = WS-ITEM
         MOVE 1 TO WS-OBSERVE
     END-IF
     COMPUTE WS-OBSERVE = WS-OBSERVE + WS-COUNT * 10
     PERFORM CHECK-N
     MOVE "acceptance US14 45 7 9 the released tadpole has the bucket's Age 100, persistence and fromBucket" TO WS-CASE
     MOVE 1101 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-TAD-AGE(WS-ROW) * 10 + EN-PERSISTENT(WS-ROW) * 100 + EN-FROM-BUCKET(WS-ROW) * 1
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-MOB-BUCKET.
 COPY CORETEST.
 COPY RANGEDTEST.
