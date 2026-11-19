*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 9, lane 002-lane-p49j-a): the sensors as functions: axolotl_attackables (9.1, with
*> the type tags of 8), frog_attackables (9.2) and the writer of UNREACHABLE_TONGUE_TARGETS (list of 5, expiry 100), and the item tags behind nautilus_temptations (9.3).
*> Nearest-visible selection and the tempting sensor's player choice need brain memories the core lacks for these mobs (gap).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-INWATER             BINARY-LONG.
 01 WS-HOSTILE             BINARY-LONG.
 01 WS-COOL                BINARY-LONG.
 01 WS-HUNT                BINARY-LONG.
 01 WS-ATTACKABLE          BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-CUBE                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-UNREACH             BINARY-LONG.
 01 WS-LIST.
    05 WS-ID               BINARY-LONG OCCURS 5 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-EXPIRY              BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-TAMING              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   9.1 tags.
     MOVE "drowned" TO WS-KEY
     CALL "Q7-AXO-TAG" USING WS-KEY WS-OBS
     MOVE "acceptance US15 44-7§9.1 drowned is in axolotl_always_hostiles" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE "elder_guardian" TO WS-KEY
     CALL "Q7-AXO-TAG" USING WS-KEY WS-OBS
     MOVE "acceptance US15 44-7§9.1 elder_guardian is in axolotl_always_hostiles" TO WS-NAME
     PERFORM EXPECT
     MOVE "glow_squid" TO WS-KEY
     CALL "Q7-AXO-TAG" USING WS-KEY WS-OBS
     MOVE "acceptance US15 44-7§9.1 glow_squid is in axolotl_hunt_targets" TO WS-NAME
     MOVE 2 TO WS-EXP
     PERFORM EXPECT
     MOVE "tadpole" TO WS-KEY
     CALL "Q7-AXO-TAG" USING WS-KEY WS-OBS
     MOVE "acceptance US15 44-7§9.1 tadpole is in axolotl_hunt_targets" TO WS-NAME
     PERFORM EXPECT
     MOVE "zombie" TO WS-KEY
     CALL "Q7-AXO-TAG" USING WS-KEY WS-OBS
     MOVE "acceptance US15 44-7§9.1 a zombie is in neither tag" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   9.1 matching.
     MOVE 64 TO WS-D2
     MOVE 1 TO WS-INWATER
     MOVE 0 TO WS-HOSTILE
     MOVE 0 TO WS-COOL
     MOVE 1 TO WS-HUNT
     MOVE 1 TO WS-ATTACKABLE
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 a hunt target in water at squared distance 64, no cooldown: matches" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 65 TO WS-D2
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 squared distance 65 (above 64): no" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 10 TO WS-D2
     MOVE 0 TO WS-INWATER
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 out of water: no" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-INWATER
     MOVE 1 TO WS-COOL
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 with HAS_HUNTING_COOLDOWN the hunt tag is ignored for 2400 ticks" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-HOSTILE
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 but a hostile (drowned, guardian) is still attacked during the cooldown" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-ATTACKABLE
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 isEntityAttackable false: no" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-ATTACKABLE
     MOVE 0 TO WS-HOSTILE
     MOVE 0 TO WS-COOL
     MOVE 0 TO WS-HUNT
     PERFORM AXO
     MOVE "acceptance US15 44-7§9.1 neither hostile nor a hunt target: no" TO WS-NAME
     PERFORM EXPECT
*>   9.2 frog.
     MOVE 1 TO WS-ATTACKABLE
     MOVE 1 TO WS-CUBE
     MOVE 1 TO WS-SIZE
     MOVE 1 TO WS-FOOD
     MOVE 0 TO WS-UNREACH
     MOVE 99 TO WS-D2
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 a size 1 slime at squared distance 99 (< 100): the frog's target" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 100 TO WS-D2
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 exactly 10 away: no (closerThan is strict)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 99 TO WS-D2
     MOVE 2 TO WS-SIZE
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 a cube mob of size 2: no (size must be exactly 1)" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-CUBE
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 a non-cube mob in frog_food ignores the size" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-FOOD
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 not in frog_food: no" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-FOOD
     MOVE 1 TO WS-UNREACH
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 a UUID in UNREACHABLE_TONGUE_TARGETS: no" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-UNREACH
     MOVE 0 TO WS-ATTACKABLE
     PERFORM FROG
     MOVE "acceptance US15 44-7§9.2 isEntityAttackable false: no" TO WS-NAME
     PERFORM EXPECT
*>   9.2 the memory writer: a list of 5, oldest out, duplicates kept once, expiry 100.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-NEW FROM 11 BY 1 UNTIL WS-NEW > 15
         CALL "Q7-FROG-UNREACH" USING WS-LIST WS-COUNT WS-NEW WS-EXPIRY
     END-PERFORM
     MOVE "acceptance US15 44-7§9.2 five additions fill the list (11 to 15)" TO WS-NAME
     MOVE 5 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM EXPECT
     MOVE 11 TO WS-NEW
     CALL "Q7-FROG-UNREACH" USING WS-LIST WS-COUNT WS-NEW WS-EXPIRY
     MOVE "acceptance US15 44-7§9.2 an id already present is not added twice (still 5, first stays 11)" TO WS-NAME
     MOVE 11 TO WS-EXP
     MOVE WS-ID(1) TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§9.2 each addition renews the expiry: 100" TO WS-NAME
     MOVE 100 TO WS-EXP
     MOVE WS-EXPIRY TO WS-OBS
     PERFORM EXPECT
     MOVE 16 TO WS-NEW
     CALL "Q7-FROG-UNREACH" USING WS-LIST WS-COUNT WS-NEW WS-EXPIRY
     MOVE "acceptance US15 44-7§9.2 a sixth new id removes the oldest (index 0): the list starts at 12" TO WS-NAME
     MOVE 12 TO WS-EXP
     MOVE WS-ID(1) TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§9.2 and ends with 16, size 5" TO WS-NAME
     MOVE 16 TO WS-EXP
     MOVE WS-ID(5) TO WS-OBS
     PERFORM EXPECT
     MOVE 5 TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     PERFORM EXPECT
*>   9.3 items.
     MOVE "cod" TO WS-KEY
     CALL "Q7-NAU-FOOD" USING WS-KEY WS-TAG WS-TAMING
     MOVE "acceptance US15 44-7§9.3 cod is in nautilus_food through the fishes tag" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-TAG TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§9.3 cod does not tame (not in nautilus_taming_items)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-TAMING TO WS-OBS
     PERFORM EXPECT
     MOVE "salmon_bucket" TO WS-KEY
     CALL "Q7-NAU-FOOD" USING WS-KEY WS-TAG WS-TAMING
     MOVE "acceptance US15 44-7§9.3 the salmon bucket is nautilus_bucket_food" TO WS-NAME
     MOVE 2 TO WS-EXP
     MOVE WS-TAG TO WS-OBS
     PERFORM EXPECT
     MOVE "pufferfish_bucket" TO WS-KEY
     CALL "Q7-NAU-FOOD" USING WS-KEY WS-TAG WS-TAMING
     MOVE "acceptance US15 44-7§9.3 the pufferfish bucket tames" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-TAMING TO WS-OBS
     PERFORM EXPECT
     MOVE "pufferfish" TO WS-KEY
     CALL "Q7-NAU-FOOD" USING WS-KEY WS-TAG WS-TAMING
     MOVE "acceptance US15 44-7§9.3 pufferfish tames and is a fish food" TO WS-NAME
     MOVE WS-TAMING TO WS-OBS
     PERFORM EXPECT
     MOVE 1 TO WS-EXP
     MOVE WS-TAG TO WS-OBS
     PERFORM EXPECT
     MOVE "bread" TO WS-KEY
     CALL "Q7-NAU-FOOD" USING WS-KEY WS-TAG WS-TAMING
     MOVE "acceptance US15 44-7§9.3 bread is not nautilus food" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-TAG TO WS-OBS
     PERFORM EXPECT
     STOP RUN.
 AXO.
     CALL "Q7-AXO-ATTACKABLE" USING WS-D2 WS-INWATER WS-HOSTILE WS-COOL WS-HUNT WS-ATTACKABLE WS-OBS.
 FROG.
     CALL "Q7-FROG-ATTACKABLE" USING WS-ATTACKABLE WS-CUBE WS-SIZE WS-FOOD WS-UNREACH WS-D2 WS-OBS.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-9.
