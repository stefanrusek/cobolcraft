*> Implementation test (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 10): the goat's state. At spawn a goat screams with chance 2 percent and an adult loses one horn
*> (left or right 50/50) with chance 10 percent; the entity data is 18 screaming, 19 has left horn, 20 has right horn (EN-WOOL: 1 screaming, 2 no left horn, 4 no right horn); a kid of two
*> screaming goats screams and has both horns; an empty bucket on an adult goat gives a milk bucket like a cow's. Ramming, long jumps and the horn drop are open items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SCREAM              BINARY-LONG.
 01 WS-ONE-HORN            BINARY-LONG.
 01 WS-BOTH                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-BUCKET              BINARY-LONG.
 01 WS-MILK                BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-N0                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:goat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "N" TO TL-MODE

*>   Spawn state over 1000 goats finalized from the Xoroshiro streams of the seeds 1 to 1000 (44-x1 section 8.10: STDMOB-FINALIZE, nextDouble, nextFloat, nextBoolean; the expected counts were derived in
*>   Python from 10 sections 2.1 to 2.3, scratchpad/i3/goat_derive.py, not from the code): 21 screaming, 39 + 60 = 99 with one horn missing, none with more than one horn missing.
     MOVE 0 TO WS-SCREAM WS-ONE-HORN WS-BOTH
     COMPUTE WS-X = WS-PX + 4
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-A
         IF FUNCTION MOD(EN-WOOL(WS-A), 2) = 1
             ADD 1 TO WS-SCREAM
         END-IF
         EVALUATE FUNCTION INTEGER(EN-WOOL(WS-A) / 2)
             WHEN 1
             WHEN 2
                 ADD 1 TO WS-ONE-HORN
             WHEN 3
                 ADD 1 TO WS-BOTH
         END-EVALUATE
         CALL "ENTITY-REMOVE" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§10 Goat: screaming at spawn is 2 percent: 21 of the seeds 1 to 1000" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE WS-SCREAM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§10 Goat: one horn is missing at spawn in 10 percent: 99 of the seeds 1 to 1000" TO TL-CASE
     MOVE 99 TO TL-EXPECTED-N
     MOVE WS-ONE-HORN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§10 Goat: never both horns missing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BOTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entity data: needed when it differs from the default.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 0 TO EN-WOOL(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§10 Goat: a goat with both horns that does not scream has nothing to send" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-WOOL(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§10 Goat: a screaming goat without a right horn has data to send" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-SEND" USING WS-A
     MOVE 6 TO EN-WOOL(WS-A)
     CALL "MOB-DATA-SEND" USING WS-A

*>   Kids of two screaming goats scream whichever parent the coin picks and have both horns.
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 0 TO WS-SCREAM WS-BOTH
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 100
         MOVE 3 TO EN-WOOL(WS-A)
         MOVE 5 TO EN-WOOL(WS-B)
         PERFORM BREED-ONE
     END-PERFORM
     MOVE "acceptance US15 19§10 Goat: every kid of two screaming goats screams (100 of 100) with both horns" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SCREAM - WS-BOTH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Two calm goats: the kids have both horns and scream only by the 2 percent roll (about 8 of 400).
     MOVE 0 TO WS-SCREAM WS-BOTH
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 400
         MOVE 0 TO EN-WOOL(WS-A) EN-WOOL(WS-B)
         PERFORM BREED-ONE
     END-PERFORM
     MOVE "acceptance US15 19§10 Goat: calm parents' kids scream by chance 1 to 30 of 400 and never lack a horn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SCREAM >= 1 AND WS-SCREAM <= 30 AND WS-BOTH = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Milk: an empty bucket on an adult goat gives a milk bucket.
     MOVE "minecraft:bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BUCKET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:milk_bucket" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-MILK WS-ITEM-ROW WS-STATUS
     MOVE 0 TO PL-MODE(WS-PLAYER) PL-HELD(WS-PLAYER)
     MOVE WS-BUCKET TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO EN-VARIANT(WS-A) EN-MOBAGE(WS-A)
     CALL "TEST-INTERACT" USING PL-CONN(WS-PLAYER) EN-ID(WS-A) WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§10 Goat: an empty bucket on an adult goat gives a milk bucket" TO TL-CASE
     MOVE WS-MILK TO TL-EXPECTED-N
     MOVE PL-SLOT-ITEM(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BREED-ONE.
*>   One breeding of A and B: the kid's scream goes to WS-SCREAM, a horn missing to WS-BOTH; the kid is removed.
     MOVE 600 TO EN-LOVE(WS-A) EN-LOVE(WS-B)
     CALL "MOB-BREED" USING WS-A WS-B
     PERFORM FIND-KID
     IF FUNCTION MOD(EN-WOOL(WS-K), 2) = 1
         ADD 1 TO WS-SCREAM
     END-IF
     IF EN-WOOL(WS-K) > 1
         ADD 1 TO WS-BOTH
     END-IF
     CALL "ENTITY-REMOVE" USING WS-K.

 FIND-KID.
     MOVE 0 TO WS-K WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE AND EN-VARIANT(WS-I) = 1 AND EN-ID(WS-I) > WS-BEST
             MOVE EN-ID(WS-I) TO WS-BEST
             MOVE WS-I TO WS-K
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-10.
 COPY CORETEST.
 COPY MOBSPTEST.
