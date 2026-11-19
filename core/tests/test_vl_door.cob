*> Implementation test, the doors of the villagers (lane 002-lane-bugvlclaim, T57001; docs/protocol/18 section 5.1, 44 part 3 section 2.15): VL-DOOR-CLASS and its cache, VL-DOOR-OPEN-AT, VL-DOOR-SET,
*> the open-door rule of ENTITY-BOX-HITS (a closed door blocks a villager's box, an open one wooden or iron lets it through), the path rule of STDMOB-CELL (VD-PATH-DOORS) and the cases of VL-DOOR-TICK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VL-DOOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 COPY CBLOCKS.
 COPY VILDOOR.
 78 TM-DOOR-ON             VALUE 54.
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
 01 WS-Y1                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Y1 = WS-Y + 1
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
*>   The classes of blocks.
     MOVE "minecraft:oak_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     PERFORM 2 TIMES
         CALL "VL-DOOR-CLASS" USING WS-BLOCK WS-CLASS
     END-PERFORM
     MOVE "test vl door the class of oak_door is 1 (a mob opens it), also from the cache" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "minecraft:iron_door" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "VL-DOOR-CLASS" USING WS-BLOCK WS-CLASS
     MOVE "test vl door the class of iron_door is 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "VL-DOOR-CLASS" USING WS-BLOCK WS-CLASS
     MOVE "test vl door the class of stone is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A closed oak door in the cell east of the middle: state, open flag, setting both halves.
     COMPUTE WS-X = WS-X0 + 1
     PERFORM PLACE-OAK
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door a closed oak door cell reads as a wooden door that is not open" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-STATE > 0 AND WS-OPEN = 0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X0 WS-FY WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door the stone floor is no door" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-DOOR-SET" USING WS-DIM WS-X WS-Y WS-Z0 WS-ONE
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door VL-DOOR-SET opens the lower half" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door and the upper half" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The box of a villager in the doorway: free while the door is open, blocked when closed.
     MOVE WS-X TO WS-FX
     COMPUTE WS-FX = WS-X + 0.5
     MOVE WS-Y TO WS-FY2
     COMPUTE WS-FZ = WS-Z0 + 0.5
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-FX WS-FY2 WS-FZ WS-HIT WS-TOP
     MOVE "test vl door an open oak door does not stop a villager's box" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HIT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-DOOR-SET" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-ZERO
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door VL-DOOR-SET given the upper half closes both" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-FX WS-FY2 WS-FZ WS-HIT WS-TOP
     MOVE "test vl door a closed oak door stops a villager's box" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HIT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The path: with VD-PATH-DOORS a closed wooden door cell is passable, an iron one is not, and nothing changes without the flag.
     CALL "STDMOB-CELL" USING WS-DIM WS-X WS-Y WS-Z0 WS-CLASS
     MOVE "test vl door without the path flag a closed door is solid for the path" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 1 TO VD-PATH-DOORS
     CALL "STDMOB-CELL" USING WS-DIM WS-X WS-Y WS-Z0 WS-CLASS
     MOVE "test vl door with the path flag a closed wooden door cell is passable" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "STDMOB-CELL" USING WS-DIM WS-X0 WS-FY WS-Z0 WS-CLASS
     MOVE "test vl door with the path flag the stone floor is still solid" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM PLACE-IRON
     CALL "STDMOB-CELL" USING WS-DIM WS-X WS-Y WS-Z0 WS-CLASS
     MOVE "test vl door with the path flag a closed iron door is still solid" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CLASS TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO VD-PATH-DOORS
*>   An iron door that is open (powered) lets the box through too; closed it stops it.
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-FX WS-FY2 WS-FZ WS-HIT WS-TOP
     MOVE "test vl door a closed iron door stops a villager's box" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-HIT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "minecraft:iron_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=true,powered=true" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     MOVE "facing=east,half=upper,hinge=left,open=true,powered=true" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-KEY WS-PAIRS
     CALL "ENTITY-BOX-HITS" USING WS-DIM WS-TYPE WS-FX WS-FY2 WS-FZ WS-HIT WS-TOP
     MOVE "test vl door an open iron door lets a villager's box through" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HIT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   VL-DOOR-TICK. The villager stands two cells west of the door cell; its walk goes to the door cell (EN-WAY).
     PERFORM PLACE-OAK
     COMPUTE WS-Z = WS-Z0 + 4
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z WS-V WS-S
     MOVE 0 TO VM-T(WS-S, TM-DOOR-ON)
     MOVE 10 TO EN-COOLDOWN(WS-V)
     COMPUTE EN-WAY-X(WS-V) = WS-X + 0.5
     COMPUTE EN-WAY-Z(WS-V) = WS-Z0 + 0.5
     COMPUTE EN-X(WS-V) = WS-X - 0.5
     COMPUTE EN-Z(WS-V) = WS-Z0 + 0.5
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door the next cell of the walk holds a closed door: it is opened" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test vl door and remembered" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VM-T(WS-S, TM-DOOR-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Standing in the door cell, the door stays open (it is the villager's cell).
     COMPUTE EN-X(WS-V) = WS-X + 0.5
     MOVE 0 TO EN-COOLDOWN(WS-V)
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door the door of the villager's own cell stays open" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Two cells on, the door is neither its cell nor the next one: closed and forgotten.
     COMPUTE EN-X(WS-V) = WS-X + 2.5
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door a door the villager has passed is closed again" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test vl door and forgotten" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-DOOR-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A remembered door that is closed already is dropped.
     MOVE 1 TO VM-T(WS-S, TM-DOOR-ON)
     MOVE WS-X TO VM-T(WS-S, 55)
     MOVE WS-Y TO VM-T(WS-S, 56)
     MOVE WS-Z0 TO VM-T(WS-S, 57)
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     MOVE "test vl door a remembered door that is closed already is dropped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-DOOR-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A remembered door more than 3 blocks away is dropped and left open.
     CALL "VL-DOOR-SET" USING WS-DIM WS-X WS-Y WS-Z0 WS-ONE
     MOVE 1 TO VM-T(WS-S, TM-DOOR-ON)
     COMPUTE EN-X(WS-V) = WS-X + 5.5
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     CALL "VL-DOOR-OPEN-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-STATE WS-OPEN
     MOVE "test vl door a remembered door 5 blocks away is dropped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-DOOR-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test vl door and left as it is (open)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OPEN TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A remembered door that is no wooden door any more is dropped.
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-KEY WS-PAIRS
     MOVE 1 TO VM-T(WS-S, TM-DOOR-ON)
     COMPUTE EN-X(WS-V) = WS-X + 0.5
     CALL "VL-DOOR-TICK" USING WS-V WS-S
     MOVE "test vl door a remembered cell that holds no door any more is dropped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-DOOR-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.

 PLACE-OAK.
     MOVE "minecraft:oak_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     MOVE "facing=east,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-KEY WS-PAIRS.

 PLACE-IRON.
     MOVE "minecraft:iron_door" TO WS-KEY
     MOVE "facing=east,half=lower,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     MOVE "facing=east,half=upper,hinge=left,open=false,powered=false" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y1 WS-Z0 WS-KEY WS-PAIRS.
 END PROGRAM TEST-VL-DOOR.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
