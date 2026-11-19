*> Implementation test (coverage lane D1): villager brain, POI index, workstation scan, restock and trade orb edges. A claim whose bed or bell block is gone is released by the brain; a
*> baby villager claims no meeting point; the brain feeds the POI scan (one section of a neighbour chunk every 5 ticks) and a second chunk waits for the scan in progress; a chunk that
*> is not loaded is not scanned; a point is never indexed twice; a new claim of the same kind replaces the old one; entities that are no villager are ignored by the brain and the
*> workstation scan; a block key with the minecraft: namespace gives the profession of its path; the restock count of a day is reset 12000 ticks after the last restock; a trade orb of
*> an entity that is gone is not spawned.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD1-VILLAGER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY VILSTATE.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEY                 PIC X(112).
 01 WS-SAVED-KEY           PIC X(48).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BID                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-MEET                BINARY-LONG VALUE 3.
 01 WS-JOB                 BINARY-LONG VALUE 0.
 01 WS-KIND-BED            BINARY-LONG VALUE 1.
 01 WS-OWNER               BINARY-LONG VALUE 9001.
 01 WS-ADULT               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SLOT2               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-VID                 BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-DID                 BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-GONE-ID             BINARY-LONG VALUE 2000000.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
*>   A bed 2 blocks east, a bell above it, a lectern next to the spot; the player's chunk is scanned completely.
     COMPUTE WS-BX = WS-X0 + 2
     MOVE WS-Y0 TO WS-BY
     MOVE WS-Z0 TO WS-BZ
     MOVE "minecraft:red_bed" TO WS-KEY
*>   A bed is one point of interest at its head block (44 part 3 section 1.2); the default state of a bed is its foot.
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE SPACES TO WS-PAIRS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BY = WS-Y0 + 2
     MOVE "minecraft:bell" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BX = WS-X0 + 1
     COMPUTE WS-BY = WS-Y0 + 1
     MOVE "minecraft:lectern" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO PX-DONE-N
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
*>   A chunk that is not loaded is not scanned (no scan in progress afterwards).
     COMPUTE WS-FAR = WS-CX + 100
     CALL "PXI-SCAN" USING WS-DIM WS-FAR WS-CZ
     MOVE "covd1 index: a chunk that is not loaded starts no scan" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PX-SC-ON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A point is never indexed twice.
     PERFORM COUNT-POINTS
     MOVE WS-N TO WS-N0
     COMPUTE WS-BX = WS-X0 + 2
     MOVE WS-Y0 TO WS-BY
     CALL "PXI-ADD" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED
     PERFORM COUNT-POINTS
     MOVE "covd1 index: adding the bed again leaves the index as it was" TO TL-CASE
     MOVE WS-N0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A new claim of the same kind replaces the old one of the owner.
     CALL "VPX-CLAIM" USING WS-OWNER WS-HOME WS-DIM WS-BX WS-BY WS-BZ
     COMPUTE WS-QX = WS-BX + 5
     CALL "VPX-CLAIM" USING WS-OWNER WS-HOME WS-DIM WS-QX WS-BY WS-BZ
     CALL "PXI-TICKETS" USING WS-DIM WS-BX WS-BY WS-BZ WS-HOME WS-N
     MOVE "covd1 index: the first claim of the owner is gone after the second" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PXI-TICKETS" USING WS-DIM WS-QX WS-BY WS-BZ WS-HOME WS-N
     MOVE "covd1 index: the second claim holds one ticket" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-RELEASE-KIND" USING WS-OWNER WS-HOME
     CALL "PXI-TICKETS" USING WS-DIM WS-QX WS-BY WS-BZ WS-HOME WS-N
     MOVE "covd1 index: VPX-RELEASE-KIND frees the claim of that kind" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The villagers.
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ADULT
     CALL "VL-FIND" USING EN-ID(WS-ADULT) WS-NO WS-SLOT
*>   An adult claims home, meeting point and job site (daytime 3000).
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM FIX-TICKS-ADULT
     CALL "VL-BRAIN" USING WS-ADULT
     CALL "VPX-OF" USING EN-ID(WS-ADULT) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "covd1 brain: the adult claims the bed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-OF" USING EN-ID(WS-ADULT) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "covd1 brain: the adult claims the bell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Bed and bell are gone: the next evaluation releases both claims (and finds no other).
     COMPUTE WS-BX = WS-X0 + 2
     MOVE WS-Y0 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     COMPUTE WS-BY = WS-Y0 + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 2000 TO CW-TICKS
     PERFORM FIX-TICKS-ADULT
     CALL "VL-BRAIN" USING WS-ADULT
     CALL "VPX-OF" USING EN-ID(WS-ADULT) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "covd1 brain: a home whose bed is gone is released" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VPX-OF" USING EN-ID(WS-ADULT) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "covd1 brain: a meeting point whose bell is gone is released" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Put the bell back: a baby claims no meeting point, and its brain feeds the index scan of the chunk east of it.
     MOVE "minecraft:bell" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 0 TO PX-DONE-N
     PERFORM 24 TIMES
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BABY
     MOVE -24000 TO EN-MOBAGE(WS-BABY)
     CALL "VL-FIND" USING EN-ID(WS-BABY) WS-NO WS-SLOT2
*>   MOD(ticks + id, 5) = 0 and ticks / 5 = 31: the chunk one east of the villager's (a fraction goes to 31 too).
     COMPUTE WS-R = FUNCTION MOD(EN-ID(WS-BABY), 5)
     IF WS-R = 0
         MOVE 155 TO CW-TICKS
     ELSE
         COMPUTE CW-TICKS = 160 - WS-R
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-BABY) / 16) + 1
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-BABY) / 16)
     CALL "VL-BRAIN" USING WS-BABY
     CALL "VPX-OF" USING EN-ID(WS-BABY) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "covd1 brain: a baby claims no meeting point (the bell is free)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covd1 brain: the brain scans the neighbour chunk, one section" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PX-SC-ON = 1 AND PX-SC-CX = WS-CX AND PX-SC-CZ = WS-CZ AND PX-SC-SEC = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A scan of another chunk waits while this one is in progress.
     COMPUTE WS-CZ = WS-CZ + 1
     CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     MOVE "covd1 index: a second chunk waits for the scan in progress" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PX-SC-ON = 1 AND PX-SC-CZ = WS-CZ - 1 AND PX-SC-SEC = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The brain ignores a removed villager and a trader entry.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-OTHER
     MOVE EN-ID(WS-OTHER) TO WS-VID
     CALL "VL-SETUP" USING WS-VID WS-TWO WS-NO WS-SLOT
     MOVE 5000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-OTHER
     MOVE "covd1 brain: a trader entry is not evaluated (no next brain time)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-NEXT-BRAIN(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-REMOVE" USING WS-VID
     CALL "VL-BRAIN" USING WS-OTHER
     CALL "VL-FIND" USING WS-VID WS-NO WS-SLOT
     MOVE "covd1 brain: a removed villager stays without slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   VL-SCAN: a removed villager, a trader entry and a baby are ignored (the timer stays 0 for the baby).
     CALL "VL-SCAN" USING WS-OTHER
     CALL "VL-FIND" USING WS-VID WS-NO WS-SLOT
     MOVE "covd1 poi: the scan of a removed villager creates no slot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO CW-TICKS
     CALL "VL-SCAN" USING WS-BABY
     MOVE "covd1 poi: a baby villager does not scan for a workstation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-NEXT-SCAN(WS-SLOT2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block key with the namespace (a content set that names its blocks minecraft:...) gives the profession of the path.
     MOVE "minecraft:blast_furnace" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-BID = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-KEY(WS-BID) TO WS-SAVED-KEY
     MOVE "minecraft:blast_furnace" TO CB-KEY(WS-BID)
     COMPUTE WS-BX = WS-X0 - 5
     MOVE WS-Y0 TO WS-BY
     MOVE WS-Z0 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X = PL-X(WS-PLAYER) - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-OTHER
     CALL "VL-FIND" USING EN-ID(WS-OTHER) WS-NO WS-SLOT
     MOVE 100 TO CW-TICKS
     CALL "VL-SCAN" USING WS-OTHER
     MOVE 200 TO CW-TICKS
     CALL "VL-SCAN" USING WS-OTHER
     MOVE WS-SAVED-KEY TO CB-KEY(WS-BID)
     MOVE "T" TO TL-MODE
     MOVE "covd1 poi: a namespaced block key gives the armorer" TO TL-CASE
     MOVE "armorer" TO TL-EXPECTED
     MOVE VL-PROF(WS-SLOT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Restock: the count of a day is reset once the last restock is more than 12000 ticks old.
     MOVE 502 TO WS-VID
     CALL "VL-SETUP" USING WS-VID WS-ONE WS-NO WS-SLOT
     MOVE 100 TO VL-LAST-RESTOCK(WS-SLOT)
     MOVE 2 TO VL-RESTOCKS(WS-SLOT)
     MOVE 12100 TO WS-TIME
     CALL "VL-RESTOCK" USING WS-SLOT WS-TIME WS-DID
     MOVE "covd1 restock: exactly 12000 ticks after the last restock the count stays" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE VL-RESTOCKS(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13000 TO WS-TIME
     CALL "VL-RESTOCK" USING WS-SLOT WS-TIME WS-DID
     MOVE "covd1 restock: later than that the count of restocks is reset" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE VL-RESTOCKS(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covd1 restock: and the last restock time is the current one" TO TL-CASE
     MOVE 13000 TO TL-EXPECTED-N
     MOVE VL-LAST-RESTOCK(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A trade orb of an entity that is gone is not spawned.
     CALL "XP-ORB-TYPE" USING WS-ORB-TYPE
     PERFORM COUNT-ORBS
     MOVE WS-N TO WS-N0
     CALL "VL-TRADE-ORB" USING WS-GONE-ID WS-ONE
     PERFORM COUNT-ORBS
     MOVE "covd1 trade orb: an entity that is gone gets no orb" TO TL-CASE
     MOVE WS-N0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIX-TICKS-ADULT.
     IF FUNCTION MOD(CW-TICKS + EN-ID(WS-ADULT), 5) = 0
         ADD 1 TO CW-TICKS
     END-IF.

 COUNT-POINTS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.

 COUNT-ORBS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-COVD1-VILLAGER.
 COPY CORETEST.
 COPY MOBSPTEST.
