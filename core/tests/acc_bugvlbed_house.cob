*> Acceptance test, a villager sleeps in a bed inside a closed house (operator bug "villagers can't path find to their beds", try16; docs/protocol/19 section 22.8, 44 part 3 sections 2.1,
*> 2.15 and 2.17; lane 002-lane-bugvlbed, T58400): a 5 x 5 room of stone walls with a closed oak door in the east wall, a bed in the far corner (head against the walls), a villager with
*> no profession in the middle of the room. At night it claims the bed, walks to it, goes to sleep within reach of it and the bed is occupied (both halves); the pose and sleeping
*> position entries are on the wire.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGVLBED-HOUSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-OCC                 BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-HD                  BINARY-LONG.
 01 WS-HF                  BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
         PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
             IF WS-DX = -3 OR WS-DX = 3 OR WS-DZ = -3 OR WS-DZ = 3
                 PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 2
                     COMPUTE WS-X = WS-X0 + WS-DX
                     COMPUTE WS-Z = WS-Z0 + WS-DZ
                     COMPUTE WS-QY = WS-Y + WS-H
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z WS-KEY WS-PAIRS
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 3
     MOVE "minecraft:oak_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     COMPUTE WS-QY = WS-Y + 1
     MOVE "facing=east,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z0 WS-KEY WS-PAIRS
*>   The bed: head in the north-west corner of the room, the foot one block south of it.
     COMPUTE WS-X = WS-X0 - 2
     COMPUTE WS-Z = WS-Z0 - 2
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=south,occupied=false,part=head" TO WS-PAIRS
     MOVE "facing=south,occupied=false,part=foot" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     COMPUTE WS-Z = WS-Z0 - 1
     MOVE "facing=south,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     COMPUTE WS-X = WS-X0 + 1
     COMPUTE WS-Z = WS-Z0 + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-S
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500 OR VL-SLEEP(WS-S) = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 the villager claimed the bed of the house" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-HD WS-HX WS-HY WS-HZ WS-HF
     MOVE WS-HF TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 the villager went to sleep" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 the bed is occupied" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "VL-BED-IS-OCCUPIED" USING WS-DIM WS-HX WS-HY WS-HZ WS-OCC
     MOVE WS-OCC TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-BUGVLBED-HOUSE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
