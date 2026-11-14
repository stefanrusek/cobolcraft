*> Implementation test of the monster room (docs/protocol/35-worldgen-features-6-underground.md section 9 and 9.1; core/src/feat-room.cob): the data feature compiles (type 27; an unknown block makes
*> it unsupported); a room is checked (solid floor and ceiling, one to five open cells along the walls) and carved, with its chests, spawner and block entity requests, exactly as an independent model
*> of the section computes it (Xoroshiro128++ wrapper draws of 35-1 section 5.2; the model is the script that made the expected lines: rx, rz, the floor draws, the chest attempts with nextLong,
*> the spawner mob): the chest cells and their facing, the loot table requests with their seeds, the mob, the numbers of cobblestone, mossy cobblestone and cave air, and the next draw. A room that fails a check
*> changes nothing and consumes only the two size draws. StructurePiece.reorient (9.1) is tested directly for its four outcomes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-ROOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY GENBE.
 COPY XORO.
 01 WS-CASES.
    05 FILLER PIC X(220) VALUE "1#0#true chests 27,39,3 | reqs 27,39,2658880117764603838 | mob zombie | cobble 122 mossy 50 air 140 probe 70".
    05 FILLER PIC X(220) VALUE "3#0#true chests 23,38,2 26,38,2 | reqs 26,38,335931599240374571 23,38,-1188166040713153105 | mob zombie | cobble 124 mossy 48 air 139 probe 463".
    05 FILLER PIC X(220) VALUE "6#0#true chests 22,39,1 26,41,3 | reqs 26,41,1605630038719386601 22,39,2122004282570842566 | mob spider | cobble 110 mossy 32 air 99 probe 778".
    05 FILLER PIC X(220) VALUE "8#0#true chests 27,39,3 | reqs 27,39,-8191861524760717344 | mob skeleton | cobble 145 mossy 61 air 196 probe 718".
    05 FILLER PIC X(220) VALUE "2#1#false probe 566".
    05 FILLER PIC X(220) VALUE "2#2#false probe 566".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-ROW-TEXT         PIC X(220) OCCURS 6 TIMES.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/room".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(196608) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:features_cannot_replace".
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SEED-TEXT           PIC X(12).
 01 WS-VARIANT             PIC X(4).
 01 WS-EXPECTED            PIC X(200).
 01 WS-TEXT                PIC X(900).
 01 WS-PREV                PIC X(900).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(19)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-MOSSY               BINARY-LONG.
 01 WS-CAVE                BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-N-COBBLE            BINARY-LONG.
 01 WS-N-MOSSY             BINARY-LONG.
 01 WS-N-CAVE              BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-MOB                 PIC X(32).
 01 WS-CHESTS              PIC X(200).
 01 WS-REQS                PIC X(400).
 01 WS-J                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "bedrock" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE "chest" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE "spawner" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE 3 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     ALLOCATE 196608 CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "minecraft:room" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-6§9: the data feature monster_room compiles as type 27" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 27 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:monster_room_deep" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§9: the gate admits the monster room placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-COBBLE
     MOVE "mossy_cobblestone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-MOSSY
     MOVE "cave_air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-CAVE
     MOVE "chest" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-CHEST
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-STONE

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-SEED-TEXT WS-VARIANT WS-EXPECTED
         UNSTRING WS-ROW-TEXT(WS-I) DELIMITED BY "#" INTO WS-SEED-TEXT WS-VARIANT WS-EXPECTED
         PERFORM BUILD-ROOM-WORLD
         COMPUTE WS-SEED = FUNCTION NUMVAL(WS-SEED-TEXT)
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         MOVE 0 TO GBL-COUNT GBL-LOST
         MOVE 24 TO WS-X
         MOVE 70 TO WS-Y
         MOVE 40 TO WS-Z
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM DESCRIBE
         MOVE SPACES TO WS-CASE
         STRING "35-6§9: seed " FUNCTION TRIM(WS-SEED-TEXT) " variant " FUNCTION TRIM(WS-VARIANT) " matches the model of the section"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-CASE TO TL-CASE
         MOVE WS-TEXT TO TL-OBSERVED
         MOVE WS-EXPECTED TO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     END-PERFORM

*>   StructurePiece.reorient (9.1): a world of cave air with the cells around (24, 70, 40) set per case
     PERFORM EMPTY-BOX
     MOVE 23 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT-70
     MOVE 24 TO WS-X
     CALL "ROOM-REORIENT" USING FT-A(WS-FT) WS-X WS-Y WS-Z WS-STATE
     PERFORM FACING
     MOVE "35-6§9.1: one solid-render neighbour (west) turns the chest to face away from it: east (1)" TO WS-CASE
     MOVE WS-DIRECTION TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "chest" TO WS-KEY
     MOVE 39 TO WS-Z
     PERFORM PUT-AT-70
     MOVE 40 TO WS-Z
     CALL "ROOM-REORIENT" USING FT-A(WS-FT) WS-X WS-Y WS-Z WS-STATE
     PERFORM FACING
     MOVE "35-6§9.1: a chest next to the position keeps the default state, facing north (0), even beside a solid block" TO WS-CASE
     MOVE WS-DIRECTION TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM EMPTY-BOX
     MOVE "stone" TO WS-KEY
     MOVE 24 TO WS-X
     MOVE 39 TO WS-Z
     PERFORM PUT-AT-70
     MOVE 41 TO WS-Z
     PERFORM PUT-AT-70
     MOVE 40 TO WS-Z
     CALL "ROOM-REORIENT" USING FT-A(WS-FT) WS-X WS-Y WS-Z WS-STATE
     PERFORM FACING
     MOVE "35-6§9.1: two opposite solid-render neighbours (north, south) cancel: the default north faces a solid block, so the chest turns to south, then clockwise to west (3)" TO WS-CASE
     MOVE WS-DIRECTION TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM EMPTY-BOX
     CALL "ROOM-REORIENT" USING FT-A(WS-FT) WS-X WS-Y WS-Z WS-STATE
     PERFORM FACING
     MOVE "35-6§9.1: no neighbour: the default facing north (0)" TO WS-CASE
     MOVE WS-DIRECTION TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "stone" TO WS-KEY
     MOVE 39 TO WS-Z
     PERFORM PUT-AT-70
     MOVE 41 TO WS-Z
     PERFORM PUT-AT-70
     MOVE 40 TO WS-Z
     MOVE 25 TO WS-X
     PERFORM PUT-AT-70
     MOVE 24 TO WS-X
     CALL "ROOM-REORIENT" USING FT-A(WS-FT) WS-X WS-Y WS-Z WS-STATE
     PERFORM FACING
     MOVE "35-6§9.1: three solid-render neighbours (N, E, S): two cancel at the third, the three turns end facing west (3)" TO WS-CASE
     MOVE WS-DIRECTION TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N

*>   a block that the content set lacks makes the feature unsupported; a full table too
     MOVE CB-KEY-LENGTH(WS-MOSSY) TO WS-J
     MOVE 0 TO CB-KEY-LENGTH(WS-MOSSY)
     MOVE "minecraft:room_bad" TO WS-FTKEY
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-J TO CB-KEY-LENGTH(WS-MOSSY)
     MOVE "35-6§9: a content set without mossy cobblestone makes the room unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:room_full" TO WS-FTKEY
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-6§9: a full feature table makes the room unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

*> the stone box x 18..30, y 66..74, z 34..46 of the model, with its tunnel (variant 0), a hole in the floor (1) or no tunnel (2)
 BUILD-ROOM-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 18 TO WS-X0
     MOVE 30 TO WS-X1
     MOVE 66 TO WS-Y0
     MOVE 74 TO WS-Y1
     MOVE 34 TO WS-Z0
     MOVE 46 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE "air" TO WS-KEY
     IF WS-VARIANT(1:1) NOT = "2"
         MOVE 18 TO WS-X0
         MOVE 23 TO WS-X1
         MOVE 70 TO WS-Y0
         MOVE 71 TO WS-Y1
         MOVE 40 TO WS-Z0
         MOVE 40 TO WS-Z1
         PERFORM FILL-BOX
     END-IF
     IF WS-VARIANT(1:1) = "1"
         MOVE 24 TO WS-X
         MOVE 69 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM PUT-AT
     END-IF
     .
*> the observable state of the room as the text of the cases
 DESCRIBE.
     MOVE SPACES TO WS-TEXT WS-CHESTS WS-REQS WS-MOB
     MOVE 0 TO WS-N-COBBLE WS-N-MOSSY WS-N-CAVE
     PERFORM VARYING WS-X FROM 18 BY 1 UNTIL WS-X > 30
         PERFORM VARYING WS-Y FROM 66 BY 1 UNTIL WS-Y > 74
             PERFORM VARYING WS-Z FROM 34 BY 1 UNTIL WS-Z > 46
                 PERFORM BLOCK-NOW
                 EVALUATE TRUE
                     WHEN WS-BLOCK = WS-COBBLE
                         ADD 1 TO WS-N-COBBLE
                     WHEN WS-BLOCK = WS-MOSSY
                         ADD 1 TO WS-N-MOSSY
                     WHEN WS-BLOCK = WS-CAVE
                         ADD 1 TO WS-N-CAVE
                     WHEN WS-BLOCK = WS-CHEST
                         PERFORM FACING
                         MOVE WS-X TO WS-E1
                         MOVE WS-Z TO WS-E2
                         MOVE WS-DIRECTION TO WS-E3
                         MOVE WS-CHESTS TO WS-PREV
                         MOVE SPACES TO WS-CHESTS
                         STRING FUNCTION TRIM(WS-PREV) " " FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3)
                             DELIMITED BY SIZE INTO WS-CHESTS
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-CHESTS = SPACES
         MOVE "-" TO WS-CHESTS
     END-IF
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > GBL-COUNT
         IF GBL-KIND(WS-J) = 1
             MOVE GBL-X(WS-J) TO WS-E1
             MOVE GBL-Z(WS-J) TO WS-E2
             MOVE GBL-SEED(WS-J) TO WS-E3
             MOVE WS-REQS TO WS-PREV
             MOVE SPACES TO WS-REQS
             STRING FUNCTION TRIM(WS-PREV) " " FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO WS-REQS
         ELSE
             MOVE GBL-TEXT(WS-J) TO WS-NAME
             MOVE WS-NAME(11:22) TO WS-MOB
         END-IF
     END-PERFORM
     IF WS-REQS = SPACES
         MOVE "-" TO WS-REQS
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
     MOVE WS-DRAW TO WS-E1
     MOVE WS-N-COBBLE TO WS-E2
     MOVE WS-N-MOSSY TO WS-E3
     IF WS-RESULT = 0
         STRING "false probe " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     ELSE
         MOVE WS-N-CAVE TO WS-E4
         STRING "true chests " FUNCTION TRIM(WS-CHESTS) " | reqs " FUNCTION TRIM(WS-REQS) " | mob " FUNCTION TRIM(WS-MOB)
             " | cobble " FUNCTION TRIM(WS-E2) " mossy " FUNCTION TRIM(WS-E3) " air " FUNCTION TRIM(WS-E4) " probe " FUNCTION TRIM(WS-E1)
             DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     .
 FACING.
     CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIRECTION WS-TYPE WS-FLAG
     .
 EMPTY-BOX.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 24 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 40 TO WS-Z
     .
 PUT-AT-70.
     MOVE 70 TO WS-Y
     PERFORM PUT-AT
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-ROOM.
 COPY CORETEST.
