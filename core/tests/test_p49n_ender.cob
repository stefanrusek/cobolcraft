*> Implementation test (002-lane-p49n; docs/protocol/20 section 8.1): the enderman's carried block and its metadata 16 to 18.
*> Take block: needs no carried block, mob_griefing, a block of tag enderman_holdable at the cell and a ray from the enderman's block centre that hits that block first; the block is
*> removed and its default state carried (sent as metadata 16, OPTIONAL_BLOCK_STATE). Leave block: needs a carried block, mob_griefing, air at the cell, a solid block below that is not
*> bedrock, a carried state that can survive there and no body in the cell. The draws (1 in 20 to take, 1 in 2000 to leave) run in ENDER-CARRY-TICK. A carrying enderman never despawns.
*> Metadata 17 (creepy) follows the target, 18 (stared at) is set by the stare that took it and clears with it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49N-ENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY P49NSTATE.
 COPY CBLOCKS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ENDER               BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-STONE               BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-CACTUS           BINARY-LONG.
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDABLE            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-CASE240             PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-WANTED              BINARY-LONG VALUE 101.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEX                 PIC X(1024).
 01 WS-HEX-STATE           PIC X(1024).
 01 WS-AREA512             PIC X(512).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-IDS                 PIC X(1024).
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-ROW            BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-TICK                BINARY-LONG.
 01 WS-CARRIES             BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:enderman_holdable".
 01 WS-MEMBERS.
    05 WS-MEMBER           BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 8
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z) + 8
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-GRASS
     MOVE "minecraft:cactus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-CACTUS
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BEDROCK
     COMPUTE WS-EX = WS-BX + 0.5
     COMPUTE WS-EZ = WS-BZ + 0.5
     MOVE "minecraft:enderman" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-EX WS-Y WS-EZ WS-ENDER

*>   The tag enderman_holdable of the content set (a data tag; the test world's set has none, so it is bound here): grass block yes, stone no.
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK TO WS-MEMBER(1)
     CALL "TAG-PUT" USING WS-TAG-REGISTRY WS-TAG WS-ONE WS-MEMBERS WS-STATUS
     CALL "ENDER-HOLDABLE" USING WS-BLOCK WS-HOLDABLE
     MOVE "acceptance US15 20§8.1 A grass block is enderman_holdable" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-HOLDABLE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     CALL "ENDER-HOLDABLE" USING WS-BLOCK WS-HOLDABLE
     MOVE "acceptance US15 20§8.1 Stone is not" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-HOLDABLE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Take block: a grass block next to it is taken (removed, default state carried).
     COMPUTE WS-CX = WS-BX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-GRASS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 The enderman takes a holdable block next to it" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US15 20§8.1 The block is gone from the world" TO WS-CASE
     MOVE WS-AIR TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 It carries the default state of the block" TO WS-CASE
     MOVE CB-DEFAULT-STATE(CB-S-BLOCK(WS-GRASS + 1) + 1) TO WS-EXP
     MOVE PN-CARRY(WS-ENDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 An enderman that carries a block never despawns" TO WS-CASE
     MOVE 1 TO WS-EXP
     CALL "ENDER-CARRIES" USING WS-ENDER WS-CARRIES
     MOVE WS-CARRIES TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The carried block is metadata 16 (index 16, serializer 15, the state id as a VarInt), then the flags 17 and 18 (false).
     MOVE SPACES TO WS-AREA512
     MOVE FUNCTION CHAR(EN-ID(WS-ENDER) + 1) TO WS-AREA512(1:1)
     CALL "TEST-HEX-OF" USING WS-AREA512 WS-ONE WS-HEX
     MOVE SPACES TO WS-AREA512
     MOVE FUNCTION CHAR(PN-CARRY(WS-ENDER) + 1) TO WS-AREA512(1:1)
     CALL "TEST-HEX-OF" USING WS-AREA512 WS-ONE WS-HEX-STATE
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100f" WS-HEX-STATE(1:2) "110800120800ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 20§8.1 Taking a block sends metadata 16 (carried state), 17 and 18" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED
*>   Carrying already, a second block is not taken.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-GRASS
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 An enderman that carries a block takes no other" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Leave block: first the refusals, with the enderman carrying a grass block.
*>   not air at the cell:
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 It does not leave the block on a cell that is not air" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   air below the cell:
     COMPUTE WS-CY = WS-BY + 2
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-CY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 Nor on a cell with air below" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   bedrock below:
     COMPUTE WS-CZ = WS-BZ - 3
     COMPUTE WS-CY = WS-BY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-BEDROCK
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-CZ WS-AIR
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-CZ WS-DONE
     MOVE "acceptance US15 20§8.1 Nor on bedrock" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
*>   a body in the cell:
     COMPUTE WS-CZ = WS-BZ + 3
     COMPUTE WS-EZ = WS-CZ + 0.5
     COMPUTE WS-EX = WS-CX + 0.5
     MOVE "minecraft:cow" TO WS-KEY
     CALL "PN-SPAWN" USING WS-DIM WS-KEY WS-EX WS-Y WS-EZ WS-COW
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-CZ WS-DONE
     MOVE "acceptance US15 20§8.1 Nor on a cell a mob stands in" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-COW
*>   mob griefing off:
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-ROW
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-CZ WS-DONE
     MOVE "acceptance US15 20§8.1 Nor with mob griefing off" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
*>   a carried dandelion cannot survive on stone:
     MOVE PN-CARRY(WS-ENDER) TO WS-STATE
     MOVE CB-DEFAULT-STATE(CB-S-BLOCK(WS-CACTUS + 1) + 1) TO PN-CARRY(WS-ENDER)
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-CZ WS-DONE
     MOVE "acceptance US15 20§8.1 A carried cactus is not left where it cannot survive (stone below)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE WS-STATE TO PN-CARRY(WS-ENDER)
*>   a valid cell: air, stone below, nobody there: placed.
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "ENDER-LEAVE" USING WS-ENDER WS-CX WS-BY WS-CZ WS-DONE
     MOVE "acceptance US15 20§8.1 It leaves the block on an air cell with a solid block below" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-BY WS-CZ WS-STATE
     MOVE "acceptance US15 20§8.1 The placed block is the carried state" TO WS-CASE
     MOVE CB-DEFAULT-STATE(CB-S-BLOCK(WS-GRASS + 1) + 1) TO WS-EXP
     MOVE WS-STATE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§8.1 It carries nothing afterwards" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PN-CARRY(WS-ENDER) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100f00110800120800ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 20§8.1 Leaving the block sends metadata 16 absent (VarInt 0)" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED
     CALL "ENDER-CARRIES" USING WS-ENDER WS-CARRIES
     MOVE "acceptance US15 20§8.1 An enderman that carries nothing may despawn" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-CARRIES TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Take refusals: stone is not holdable, a holdable block behind a stone block is hit second (the ray hits the stone first), mob griefing off.
     COMPUTE WS-CX = WS-BX - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-STONE
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 A stone block is not taken" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-CX = WS-BX - 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-GRASS
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 A holdable block behind a stone block is not taken (the ray hits the stone)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     COMPUTE WS-CX = WS-BX - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-BY WS-BZ WS-AIR
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
     COMPUTE WS-CX = WS-BX - 2
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 With mob griefing off nothing is taken" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-ROW WS-RULE-VALUE
     CALL "ENDER-TAKE" USING WS-ENDER WS-CX WS-BY WS-BZ WS-DONE
     MOVE "acceptance US15 20§8.1 With the stone gone and griefing on the same block is taken" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DONE TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO PN-CARRY(WS-ENDER)

*>   The draws: a ring of grass blocks around it; ticks until it carries something (1 in 20 and a random cell), then clear the ring and tick until it leaves the block (1 in 2000).
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             PERFORM VARYING WS-K FROM -2 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 IF WS-I NOT = 0 OR WS-K NOT = 0
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-GRASS
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-TICK
     PERFORM UNTIL PN-CARRY(WS-ENDER) NOT = 0 OR WS-TICK >= 600
         ADD 1 TO WS-TICK
         ADD 1 TO CW-TICKS
         CALL "ENDER-CARRY-TICK" USING WS-ENDER
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Within 600 ticks the enderman takes a block of the ring on its own" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PN-CARRY(WS-ENDER) NOT = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             PERFORM VARYING WS-K FROM -2 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-TICK
     PERFORM UNTIL PN-CARRY(WS-ENDER) = 0 OR WS-TICK >= 60000
         ADD 1 TO WS-TICK
         ADD 1 TO CW-TICKS
         CALL "ENDER-CARRY-TICK" USING WS-ENDER
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Within 60000 ticks the enderman leaves the block on its own" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PN-CARRY(WS-ENDER) = 0
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 1
             PERFORM VARYING WS-K FROM -1 BY 1 UNTIL WS-K > 1
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
                 IF WS-STATE NOT = 0
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 20§8.1 The block it left is in the world within 1 block of it" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-SEEN TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS

*>   Metadata 17 and 18: a target taken by a stare sets both, the target gone clears both.
     CALL "ENDER-FLAGS-TICK" USING WS-ENDER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE WS-PLAYER TO EN-TARGET(WS-ENDER)
     CALL "ENDER-STARED-SET" USING WS-ENDER
     CALL "ENDER-FLAGS-TICK" USING WS-ENDER
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100f00110801120801ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 20§8.1 A target taken by a stare: metadata 17 and 18 true" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED
     MOVE 0 TO EN-TARGET(WS-ENDER)
     CALL "ENDER-FLAGS-TICK" USING WS-ENDER
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100f00110800120800ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 20§8.1 The target gone: metadata 17 and 18 false" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED
*>   Nothing changes, nothing is sent.
     CALL "ENDER-FLAGS-TICK" USING WS-ENDER
     MOVE "none" TO WS-EXPECTED
     MOVE "acceptance US15 20§8.1 No change, no packet" TO WS-CASE240
     CALL "PN-CHECK-HEX" USING WS-CONN WS-CASE240 WS-WANTED WS-EXPECTED
     STOP RUN.
 END PROGRAM TEST-P49N-ENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-SPAWN.
*> USING dim, key (PIC X(112)), x, y, z (FLOAT-LONG), row out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING L-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM PN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PN-CHECK-HEX.
*> USING connection id, case (X(240)), wanted packet id, expected hex of the body ("none": no such packet): the body of the first packet of that id drained from the connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AREA                PIC X(65536) BASED.
 01 WS-COPY                PIC X(512).
 01 WS-HEX                 PIC X(1024).
 01 WS-TEXT                PIC X(4096).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CASE                 PIC X(240).
 01 L-WANTED               BINARY-LONG.
 01 L-EXPECTED             PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-CASE L-WANTED L-EXPECTED.
     MOVE "none" TO WS-HEX
     MOVE 0 TO WS-FOUND WS-OUTCOME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             COMPUTE WS-COUNT = PK-LENGTH - PK-POS
             MOVE SPACES TO WS-COPY
             MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
             CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     MOVE WS-HEX TO WS-TEXT
     MOVE L-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE L-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM PN-CHECK-HEX.
 COPY CORETEST.
 COPY MOBSPTEST.
