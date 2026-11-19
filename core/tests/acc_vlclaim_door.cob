*> Acceptance test, a villager shut in a house by a door takes the job site outside (operator bug "villagers in generated villages never take a profession"; docs/protocol/44 part 3
*> sections 2.1 and 2.15, 18 section 5.1 WALKABLE_DOOR; lane 002-lane-bugvlclaim, T57000): a villager stands in a 3 x 3 room of stone walls whose only way out is a door, the composter is
*> 8 blocks outside. A villager opens a wooden door that is on its path (InteractWithDoor), so the path check of AcquirePoi (canReach) lets it claim the composter, it walks out through the
*> door and takes the profession; the door is shut again behind it. An iron door cannot be opened by a mob (path type DOOR_IRON_CLOSED, malus -1): behind it the villager claims nothing and stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-VLCLAIM-DOOR.
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
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-SEEN                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
*>   The room: walls of stone, three high, two blocks from the middle; the door is in the east wall.
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             IF WS-DX = -2 OR WS-DX = 2 OR WS-DZ = -2 OR WS-DZ = 2
                 PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 2
                     COMPUTE WS-X = WS-X0 + WS-DX
                     COMPUTE WS-Z = WS-Z0 + WS-DZ
                     COMPUTE WS-QY = WS-Y + WS-H
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z WS-KEY WS-PAIRS
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 2
     PERFORM PLACE-IRON-DOOR
     COMPUTE WS-X = WS-X0 + 10
     MOVE "minecraft:composter" TO WS-KEY
     MOVE "level=0" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 900
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 18§5.1 behind an iron door the villager takes no profession" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VL-PROF(WS-S) = "none"
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-VX = FUNCTION INTEGER(EN-X(WS-V))
     MOVE "acceptance US15 18§5.1 and stays inside the room" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-VX < WS-X0 + 2
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The iron door is replaced by an oak door: the villager claims the composter, opens the door on its path and takes the profession.
     COMPUTE WS-X = WS-X0 + 2
     PERFORM PLACE-OAK-DOOR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR VL-PROF(WS-S) NOT = "none"
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
         CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
         IF WS-OPEN = 1
             MOVE 1 TO WS-SEEN
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.1 behind a wooden door the villager reaches the composter and becomes a farmer" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VL-PROF(WS-S) = "farmer"
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-VX = FUNCTION INTEGER(EN-X(WS-V))
     MOVE "acceptance US15 44-3§2.15 the villager went out through the door" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-VX > WS-X0 + 2
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.15 the villager opened the door (it was open on some tick of the walk)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-SEEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "minecraft:oak_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     COMPUTE WS-X = WS-X0 + 2
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z0 WS-STATE
     MOVE "acceptance US15 44-3§2.15 the door it opened is closed again behind the villager" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.

 PLACE-IRON-DOOR.
     MOVE "minecraft:iron_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     COMPUTE WS-QY = WS-Y + 1
     MOVE "facing=east,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z0 WS-KEY WS-PAIRS.

 PLACE-OAK-DOOR.
     MOVE "minecraft:oak_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     COMPUTE WS-QY = WS-Y + 1
     MOVE "facing=east,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z0 WS-KEY WS-PAIRS.
 END PROGRAM ACC-VLCLAIM-DOOR.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
