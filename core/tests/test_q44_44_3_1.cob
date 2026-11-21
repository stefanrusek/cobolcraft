*> Test of 44 part 3 section 1, Villages (lane 002-lane-p49h, T22000): the POI type table (1.2), claims and occupancy (1.3), the section distance field and isVillage / isCloseToVillage
*> (1.4, worked example 1 of section 11), the setBlock hook (1.4a).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILPOIX.
 COPY VILPOI.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-HEAD                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TICKETS             BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-TAG                 BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-KIND-BED            BINARY-LONG VALUE 1.
 01 WS-KIND-BELL           BINARY-LONG VALUE 2.
 01 WS-RANGE48             BINARY-LONG VALUE 48.
 01 WS-OCC                 BINARY-LONG.
 01 WS-KEYS.
    05 WS-KEY-ENTRY        PIC X(32) OCCURS 21 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "blast_furnace" TO WS-KEY-ENTRY(1)
     MOVE "smoker" TO WS-KEY-ENTRY(2)
     MOVE "cartography_table" TO WS-KEY-ENTRY(3)
     MOVE "brewing_stand" TO WS-KEY-ENTRY(4)
     MOVE "composter" TO WS-KEY-ENTRY(5)
     MOVE "barrel" TO WS-KEY-ENTRY(6)
     MOVE "fletching_table" TO WS-KEY-ENTRY(7)
     MOVE "powder_snow_cauldron" TO WS-KEY-ENTRY(8)
     MOVE "lectern" TO WS-KEY-ENTRY(9)
     MOVE "stonecutter" TO WS-KEY-ENTRY(10)
     MOVE "loom" TO WS-KEY-ENTRY(11)
     MOVE "smithing_table" TO WS-KEY-ENTRY(12)
     MOVE "grindstone" TO WS-KEY-ENTRY(13)
     MOVE "red_bed" TO WS-KEY-ENTRY(14)
     MOVE "bell" TO WS-KEY-ENTRY(15)
     MOVE "beehive" TO WS-KEY-ENTRY(16)
     MOVE "bee_nest" TO WS-KEY-ENTRY(17)
     MOVE "nether_portal" TO WS-KEY-ENTRY(18)
     MOVE "lodestone" TO WS-KEY-ENTRY(19)
     MOVE "test_instance_block" TO WS-KEY-ENTRY(20)
     MOVE "waxed_oxidized_lightning_rod" TO WS-KEY-ENTRY(21)
     MOVE 1 TO WS-HEAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 21
         CALL "Q3-POI-TYPE" USING WS-KEY-ENTRY(WS-I) WS-HEAD WS-TYPE WS-TICKETS WS-RANGE
         MOVE "acceptance US15 44-3§1 Villages 1.2 the POI type ids follow registration order" TO WS-CASE
         COMPUTE WS-E = WS-I - 1
         MOVE WS-TYPE TO WS-O
         CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
         MOVE "acceptance US15 44-3§1 Villages 1.2 tickets: 1 for job sites and home, 32 for the bell, 0 for the six others" TO WS-CASE
         EVALUATE TRUE
             WHEN WS-I = 15
                 MOVE 32 TO WS-E
             WHEN WS-I >= 16
                 MOVE 0 TO WS-E
             WHEN OTHER
                 MOVE 1 TO WS-E
         END-EVALUATE
         MOVE WS-TICKETS TO WS-O
         CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
         MOVE "acceptance US15 44-3§1 Villages 1.2 valid range 1 for all but the bell (6)" TO WS-CASE
         MOVE 1 TO WS-E
         IF WS-I = 15
             MOVE 6 TO WS-E
         END-IF
         MOVE WS-RANGE TO WS-O
         CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     END-PERFORM
     MOVE "cauldron" TO WS-KEY
     CALL "Q3-POI-TYPE" USING WS-KEY WS-HEAD WS-TYPE WS-TICKETS WS-RANGE
     MOVE "acceptance US15 44-3§1 Villages 1.2 an empty cauldron is a leatherworker POI (7)" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "lightning_rod" TO WS-KEY
     CALL "Q3-POI-TYPE" USING WS-KEY WS-HEAD WS-TYPE WS-TICKETS WS-RANGE
     MOVE "acceptance US15 44-3§1 Villages 1.2 a lightning rod is type 20, after test_instance 19" TO WS-CASE
     MOVE 20 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "stone" TO WS-KEY
     CALL "Q3-POI-TYPE" USING WS-KEY WS-HEAD WS-TYPE WS-TICKETS WS-RANGE
     MOVE "acceptance US15 44-3§1 Villages 1.2 stone belongs to no POI type" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-HEAD
     MOVE "red_bed" TO WS-KEY
     CALL "Q3-POI-TYPE" USING WS-KEY WS-HEAD WS-TYPE WS-TICKETS WS-RANGE
     MOVE "acceptance US15 44-3§1 Villages 1.2 the foot half of a bed is no POI" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Tags: village = 13 job sites + home + meeting; acquirable_job_site = the 13; bee_home = beehive, bee_nest.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 20
         MOVE 1 TO WS-TAG
         CALL "Q3-POI-IN-TAG" USING WS-TYPE WS-TAG WS-YES
         ADD WS-YES TO WS-N
     END-PERFORM
     MOVE "acceptance US15 44-3§1 Villages 1.2 tag village holds 15 types" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-N
     PERFORM VARYING WS-TYPE FROM 0 BY 1 UNTIL WS-TYPE > 20
         MOVE 2 TO WS-TAG
         CALL "Q3-POI-IN-TAG" USING WS-TYPE WS-TAG WS-YES
         ADD WS-YES TO WS-N
     END-PERFORM
     MOVE "acceptance US15 44-3§1 Villages 1.2 tag acquirable_job_site holds the 13 job sites" TO WS-CASE
     MOVE 13 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 15 TO WS-TYPE
     MOVE 3 TO WS-TAG
     CALL "Q3-POI-IN-TAG" USING WS-TYPE WS-TAG WS-YES
     MOVE WS-YES TO WS-N
     MOVE 16 TO WS-TYPE
     CALL "Q3-POI-IN-TAG" USING WS-TYPE WS-TAG WS-YES
     ADD WS-YES TO WS-N
     MOVE 13 TO WS-TYPE
     CALL "Q3-POI-IN-TAG" USING WS-TYPE WS-TAG WS-YES
     ADD WS-YES TO WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.2 tag bee_home holds beehive and bee_nest only" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Block states: a bed is a POI at the head part only.
     MOVE SPACES TO WS-PAIRS
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     MOVE "minecraft:red_bed" TO WS-KEY112
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     CALL "Q3-STATE-POI-TYPE" USING WS-STATE WS-TYPE
     MOVE "acceptance US15 44-3§1 Villages 1.2 a bed head state is the home type" TO WS-CASE
     MOVE 13 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=false,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE2
     CALL "Q3-STATE-POI-TYPE" USING WS-STATE2 WS-TYPE
     MOVE "acceptance US15 44-3§1 Villages 1.2 a bed foot state is no POI" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-STATE-POI-TYPE" USING WS-AIR WS-TYPE
     MOVE "acceptance US15 44-3§1 Villages 1.2 air is no POI" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE WS-TYPE TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Worked example 1: a villager sleeps in the bed with the head block at (35, 70, 3), section (2, 4, 0).
     INITIALIZE PX-STATE
     INITIALIZE PO-STATE
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     MOVE 35 TO WS-BX
     MOVE 70 TO WS-BY
     MOVE 3 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 80 TO WS-SX
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 an unclaimed bed does not make a village" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-SX
     MOVE 4 TO WS-SY
     MOVE 0 TO WS-SZ
     CALL "Q3-LEVEL" USING WS-DIM WS-SX WS-SY WS-SZ WS-LEVEL
     MOVE "acceptance US15 44-3§1 Villages 1.4 with no centre every section has level 7" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE WS-LEVEL TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "VPX-CLAIM" USING WS-ONE WS-HOME WS-DIM WS-BX WS-BY WS-BZ
     MOVE 2 TO WS-SX
     CALL "Q3-LEVEL" USING WS-DIM WS-SX WS-SY WS-SZ WS-LEVEL
     MOVE "acceptance US15 44-3§1 Villages 1.4 the section of a claimed bed is level 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LEVEL TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 3 TO WS-SX
     MOVE 5 TO WS-SY
     MOVE -1 TO WS-SZ
     CALL "Q3-LEVEL" USING WS-DIM WS-SX WS-SY WS-SZ WS-LEVEL
     MOVE "acceptance US15 44-3§1 Villages 1.4 the corner of the 3 x 3 x 3 cube is level 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-LEVEL TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 4 TO WS-SX
     MOVE 4 TO WS-SY
     MOVE 0 TO WS-SZ
     CALL "Q3-LEVEL" USING WS-DIM WS-SX WS-SY WS-SZ WS-LEVEL
     MOVE "acceptance US15 44-3§1 Villages 1.4 two sections away is level 2 (Chebyshev)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-LEVEL TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 80 TO WS-BX
     MOVE 70 TO WS-BY
     MOVE 3 TO WS-BZ
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-TWO WS-YES
     MOVE "acceptance US15 44-3§1 Villages worked 1 a player at (80,70,3) is at level 3: not close to a village (2)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 3 TO WS-BX
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-TWO WS-YES
     MOVE "acceptance US15 44-3§1 Villages worked 1 (3,70,3) is level 2: close to a village (2)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE WS-YES
     MOVE "acceptance US15 44-3§1 Villages worked 1 (3,70,3) is not isVillage" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 20 TO WS-BX
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE WS-YES
     MOVE "acceptance US15 44-3§1 Villages worked 1 (20,70,3) is level 1: isVillage" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "RAID-IS-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 the raid village test is isVillage" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   isCloseToVillage is false for n above 6; level 6 is still stored, level 7 means none.
     MOVE 2 TO WS-BX
     MOVE 6 TO WS-SX
     MOVE 4 TO WS-SY
     MOVE 0 TO WS-SZ
     COMPUTE WS-BX = 2 * 16 + 6 * 16 + 1
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-SIX WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 6 sections away is still close at n = 6" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     COMPUTE WS-BX = 2 * 16 + 7 * 16 + 1
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-SIX WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 7 sections away is no village at n = 6" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     COMPUTE WS-BX = 35
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-SEVEN WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 isCloseToVillage is false when n is above 6" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   A released claim ends the village.
     CALL "VPX-RELEASE-KIND" USING WS-ONE WS-HOME
     MOVE 20 TO WS-BX
     CALL "Q3-CLOSE-TO-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-ONE WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 releasing the ticket ends the village" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   Claims and counting (1.3): getCountInRange with the occupancy filters.
     MOVE 35 TO WS-BX
     MOVE 3 TO WS-BZ
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 getCountInRange with any occupancy counts the unclaimed bed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 2 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 IS_OCCUPIED does not count it" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "VPX-CLAIM" USING WS-ONE WS-HOME WS-DIM WS-BX WS-BY WS-BZ
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 a claimed bed is occupied" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 1 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 HAS_SPACE does not count a claimed bed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 0 TO WS-OCC
     COMPUTE WS-BX = 35 + 49
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 a record 49 blocks away is out of range 48" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   The setBlock hook (1.4a): a colour change keeps the record and its claim; breaking the bed drops both; a foot half never becomes a record.
     MOVE 35 TO WS-BX
     MOVE "minecraft:blue_bed" TO WS-KEY112
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE2
     MOVE 2 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.4a replacing one bed colour with another keeps the claim" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
     MOVE 0 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.4a breaking the bed removes its record" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "VPX-OF" USING WS-ONE WS-HOME WS-DIM WS-BX WS-BY WS-BZ WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4a the villager's ticket on it is dropped with the record" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=false,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE2
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.4a a bed foot is none, so no record is added" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE2
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.4a the foot flipping to head adds a record with free tickets" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 1 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BED WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.4a the new record has space" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
*>   A bell takes up to 32 tickets and the section counts as a village once one is taken.
     ADD 3 TO WS-BY
     MOVE "minecraft:bell" TO WS-KEY112
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 1 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BELL WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 a fresh bell has space" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 3 TO WS-HOME
     CALL "VPX-CLAIM" USING WS-ONE WS-HOME WS-DIM WS-BX WS-BY WS-BZ
     MOVE 2 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BELL WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 a bell with one of its tickets taken is occupied" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     MOVE 1 TO WS-OCC
     CALL "Q3-COUNT-IN-RANGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-KIND-BELL WS-RANGE48 WS-OCC WS-N
     MOVE "acceptance US15 44-3§1 Villages 1.3 and still has space (31 of 32 free)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     CALL "RAID-IS-VILLAGE" USING WS-DIM WS-BX WS-BY WS-BZ WS-YES
     MOVE "acceptance US15 44-3§1 Villages 1.4 a bell with a ticket taken makes a village" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-YES TO WS-O
     CALL "Q3-CHECK" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-1.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
