*> Live pistons, part 2: the trigger, the block event, moveBlocks, the moving block and its block entity, the head (docs/protocol/30-redstone-3-pistons.md sections 2, 3, 6, 7 and 9.3).
*> The moving_piston block entity (type 11) lives in the cells of CORE-BE: BE-XI 1 the moved state id, 2 the direction (the piston's facing), 3 extending, 4 source; BE-PROGRESS and BE-PROGRESS-OLD are
*> progress and progressO; BE-TIME2 is lastTicked. Not here: the pushing of entities (section 8: moveCollidedEntities, honey sticking), the shape updates of the vacated cells' indirect neighbours
*> (6 steps 9 and 11, so wire next to a vacated cell is not told through them), the order of the vacated cells (the JDK map order of 6.1: they are done in list order), flag 256 of 7.4 (a moving cell that
*> is overwritten does not finish at once), saving and loading a moving block entity, and the placed facing of 1 (the player's looking direction).
*>   RL-SOUND-AT USING dim, x, y, z, sound key (PIC X(48), without minecraft:), source, volume x 1e6, pitch x 1e6      a Sound Effect (05b 0x77) to the viewers of the chunk
*>   PST-HOOK USING kind, dim, x, y, z, state, a, b, out        the hooks of piston and sticky_piston (1 onPlace, 3 neighborChanged, 10 block event) and of piston_head (2, 3, 4)
*>   PST-MBE-TICK USING block entity index                      PistonMovingBlockEntity.tick (7.2), called by BE-TICK-ALL

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SOUND-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 119.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:sound_event".
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VOLUME              FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SOUND                PIC X(48).
 01 L-SOURCE               BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SOUND L-SOURCE L-VOLUME L-PITCH.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(L-SOUND) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-STATIC-ID" USING WS-REGISTRY WS-KEY WS-ID WS-STATUS
     COMPUTE WS-HOLDER = WS-ID + 1
     COMPUTE WS-FX = L-X * 8 + 4
     COMPUTE WS-FY = L-Y * 8 + 4
     COMPUTE WS-FZ = L-Z * 8 + 4
     COMPUTE WS-VOLUME = L-VOLUME / 1000000
     COMPUTE WS-PITCH = L-PITCH / 1000000
     CALL "RL-NOTE-SEED" USING WS-SEED
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SOURCE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FX
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FY
     CALL "PB-PUT-INT" USING PB-BUFFER WS-FZ
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-VOLUME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PITCH
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SEED
     CALL "VIEWERS-SEND" USING L-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
     GOBACK.
 END PROGRAM RL-SOUND-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-NEIGHBOR-SIGNAL.
*> USING dim, x, y, z, facing, powered out: getNeighborSignal (2.2): the six cells but the front, the cell itself below, and the neighbours of the cell above but its lower one (quasi-connectivity).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SIGNAL              BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-POWERED.
     MOVE 0 TO L-POWERED
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         IF WS-D NOT = L-FACING
             CALL "BU-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NY = L-Y + WS-DY
             COMPUTE WS-NZ = L-Z + WS-DZ
             CALL "RL-SIGNAL" USING L-DIM WS-NX WS-NY WS-NZ WS-D WS-SIGNAL
             IF WS-SIGNAL > 0
                 MOVE 1 TO L-POWERED
             END-IF
         END-IF
     END-PERFORM
*>   term 2, hasSignal(pos, DOWN) on the piston's own cell, is always false for a piston (2.2: it emits nothing and is no conductor), so it is not asked
     COMPUTE WS-ABOVE = L-Y + 1
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5
         CALL "BU-DIRECTION" USING WS-D WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = WS-ABOVE + WS-DY
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "RL-SIGNAL" USING L-DIM WS-NX WS-NY WS-NZ WS-D WS-SIGNAL
         IF WS-SIGNAL > 0
             MOVE 1 TO L-POWERED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PST-NEIGHBOR-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-BE-FILL.
*> USING dim, x, y, z, moved state, direction, extending, source: the moving block entity at the position (the cell holds moving_piston), progress 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-MOVED L-DIR L-EXT L-SOURCE.
     CALL "BE-FIND" USING L-DIM L-X L-Y L-Z WS-INDEX
     IF WS-INDEX > 0
         MOVE L-MOVED TO BE-XI(WS-INDEX, 1)
         MOVE L-DIR TO BE-XI(WS-INDEX, 2)
         MOVE L-EXT TO BE-XI(WS-INDEX, 3)
         MOVE L-SOURCE TO BE-XI(WS-INDEX, 4)
         MOVE 0 TO BE-PROGRESS(WS-INDEX) BE-PROGRESS-OLD(WS-INDEX) BE-TIME2(WS-INDEX)
         CALL "BE-MARK-CHUNK" USING WS-INDEX
     END-IF
     GOBACK.
 END PROGRAM PST-BE-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUT-MOVING.
*> USING dim, x, y, z, moving_piston state, moved state, direction, extending, source, write flags: setBlock of the moving block and its block entity (6 steps 6 and 7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-MOVED L-DIR L-EXT L-SOURCE L-FLAGS.
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE L-FLAGS WS-BUDGET WS-RESULT
     CALL "PST-BE-FILL" USING L-DIM L-X L-Y L-Z L-MOVED L-DIR L-EXT L-SOURCE
     GOBACK.
 END PROGRAM PST-PUT-MOVING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-MOVE RECURSIVE.
*> USING dim, piston x, y, z, facing, extending, ok out: moveBlocks (6): the resolver, the destroyed blocks (drops, air with flags 18), the pushed blocks far end first (moving_piston with flags 324 and a block
*> entity holding the snapshot), the head (extending), the vacated cells (flags 82) and the notifications in the order of steps 11 and 12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PSTATE.
 01 K-2                    BINARY-LONG VALUE 2.
 01 K-3                    BINARY-LONG VALUE 3.
 01 K-4                    BINARY-LONG VALUE 4.
 LOCAL-STORAGE SECTION.
 01 LS-CLASS               BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-PUSH-FLAGS          BINARY-LONG VALUE 324.
 01 LS-HX                  BINARY-LONG.
 01 LS-HY                  BINARY-LONG.
 01 LS-HZ                  BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-MX                  BINARY-LONG.
 01 LS-MY                  BINARY-LONG.
 01 LS-MZ                  BINARY-LONG.
 01 LS-MOVE-DIR            BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-MOVING              BINARY-LONG.
 01 LS-HEAD                BINARY-LONG.
 01 LS-PSTATE              BINARY-LONG.
 01 LS-STICKY              BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-NPUSH               BINARY-LONG.
 01 LS-NDEST               BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-AIR                 BINARY-LONG VALUE 0.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-ZERO2               BINARY-LONG VALUE 0.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-HOOK-OUT            BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-SHAPE-FLAGS         BINARY-LONG VALUE 2.
 01 LS-SHAPE-BUDGET        BINARY-LONG VALUE 2.
 01 LS-LISTS.
    05 LS-P OCCURS 64 TIMES.
       10 LS-P-X           BINARY-LONG.
       10 LS-P-Y           BINARY-LONG.
       10 LS-P-Z           BINARY-LONG.
       10 LS-P-STATE       BINARY-LONG.
       10 LS-P-LIVE        BINARY-LONG.
    05 LS-D OCCURS 64 TIMES.
       10 LS-D-X           BINARY-LONG.
       10 LS-D-Y           BINARY-LONG.
       10 LS-D-Z           BINARY-LONG.
       10 LS-D-STATE       BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-EXT L-OK.
     MOVE 0 TO L-OK
     CALL "REDSTONE-IDS-ENSURE"
     CALL "BU-DIRECTION" USING L-FACING LS-DX LS-DY LS-DZ
     COMPUTE LS-HX = L-X + LS-DX
     COMPUTE LS-HY = L-Y + LS-DY
     COMPUTE LS-HZ = L-Z + LS-DZ
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-PSTATE
     MOVE 0 TO LS-STICKY
     CALL "PST-CLASS" USING LS-PSTATE LS-CLASS
     IF LS-CLASS = 32
         MOVE 1 TO LS-STICKY
     END-IF
     IF L-EXT = 0
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-HX LS-HY LS-HZ LS-STATE
         CALL "PST-CLASS" USING LS-STATE LS-CLASS
         IF LS-CLASS = 33
             MOVE 276 TO LS-FLAGS
             CALL "LEVEL-SET-BLOCK" USING L-DIM LS-HX LS-HY LS-HZ LS-AIR LS-FLAGS LS-BUDGET LS-RESULT
         END-IF
     END-IF
     CALL "PST-RESOLVE" USING L-DIM L-X L-Y L-Z L-FACING L-EXT L-OK
     IF L-OK = 0
         GOBACK
     END-IF
*>   the snapshot (step 3): the lists are copied, the writes below may start other pistons
     MOVE PS-NPUSH TO LS-NPUSH
     MOVE PS-NDEST TO LS-NDEST
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-NPUSH
         MOVE PS-P-X(LS-I) TO LS-P-X(LS-I)
         MOVE PS-P-Y(LS-I) TO LS-P-Y(LS-I)
         MOVE PS-P-Z(LS-I) TO LS-P-Z(LS-I)
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-P-X(LS-I) LS-P-Y(LS-I) LS-P-Z(LS-I) LS-P-STATE(LS-I)
         MOVE 1 TO LS-P-LIVE(LS-I)
     END-PERFORM
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-NDEST
         MOVE PS-D-X(LS-I) TO LS-D-X(LS-I)
         MOVE PS-D-Y(LS-I) TO LS-D-Y(LS-I)
         MOVE PS-D-Z(LS-I) TO LS-D-Z(LS-I)
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-D-X(LS-I) LS-D-Y(LS-I) LS-D-Z(LS-I) LS-D-STATE(LS-I)
     END-PERFORM
     MOVE L-FACING TO LS-MOVE-DIR
     IF L-EXT = 0
         COMPUTE LS-MOVE-DIR = L-FACING + 1 - 2 * FUNCTION MOD(L-FACING, 2)
     END-IF
     CALL "BU-DIRECTION" USING LS-MOVE-DIR LS-MX LS-MY LS-MZ
*>   destroy, last entry first (step 5)
     PERFORM VARYING LS-I FROM LS-NDEST BY -1 UNTIL LS-I < 1
         CALL "BLOCK-DROPS-NO-TOOL" USING L-DIM LS-D-X(LS-I) LS-D-Y(LS-I) LS-D-Z(LS-I) LS-D-STATE(LS-I)
         MOVE 18 TO LS-FLAGS
         CALL "LEVEL-SET-BLOCK" USING L-DIM LS-D-X(LS-I) LS-D-Y(LS-I) LS-D-Z(LS-I) LS-AIR LS-FLAGS LS-BUDGET LS-RESULT
     END-PERFORM
*>   push, the block farthest from the piston first (step 6)
     CALL "PST-STATE-OF" USING K-4 L-FACING LS-ZERO LS-ZERO2 LS-MOVING
     PERFORM VARYING LS-I FROM LS-NPUSH BY -1 UNTIL LS-I < 1
         PERFORM VARYING LS-J FROM 1 BY 1 UNTIL LS-J > LS-NPUSH
             IF LS-P-X(LS-J) = LS-P-X(LS-I) + LS-MX AND LS-P-Y(LS-J) = LS-P-Y(LS-I) + LS-MY
                     AND LS-P-Z(LS-J) = LS-P-Z(LS-I) + LS-MZ
                 MOVE 0 TO LS-P-LIVE(LS-J)
             END-IF
         END-PERFORM
         COMPUTE LS-NX = LS-P-X(LS-I) + LS-MX
         COMPUTE LS-NY = LS-P-Y(LS-I) + LS-MY
         COMPUTE LS-NZ = LS-P-Z(LS-I) + LS-MZ
         CALL "PST-PUT-MOVING" USING L-DIM LS-NX LS-NY LS-NZ LS-MOVING LS-P-STATE(LS-I) L-FACING L-EXT LS-ZERO LS-PUSH-FLAGS
     END-PERFORM
*>   the head (step 7)
     IF L-EXT = 1
         PERFORM VARYING LS-J FROM 1 BY 1 UNTIL LS-J > LS-NPUSH
             IF LS-P-X(LS-J) = LS-HX AND LS-P-Y(LS-J) = LS-HY AND LS-P-Z(LS-J) = LS-HZ
                 MOVE 0 TO LS-P-LIVE(LS-J)
             END-IF
         END-PERFORM
         CALL "PST-STATE-OF" USING K-4 L-FACING LS-ZERO LS-STICKY LS-MOVING
         CALL "PST-STATE-OF" USING K-3 L-FACING LS-ZERO LS-STICKY LS-HEAD
         CALL "PST-PUT-MOVING" USING L-DIM LS-HX LS-HY LS-HZ LS-MOVING LS-HEAD L-FACING L-EXT LS-ONE LS-PUSH-FLAGS
     END-IF
*>   the vacated cells (steps 8 and 9)
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-NPUSH
         IF LS-P-LIVE(LS-I) = 1
             MOVE 82 TO LS-FLAGS
             CALL "LEVEL-SET-BLOCK" USING L-DIM LS-P-X(LS-I) LS-P-Y(LS-I) LS-P-Z(LS-I) LS-AIR LS-FLAGS LS-BUDGET LS-RESULT
             CALL "BU-SHAPE-UPDATES" USING L-DIM LS-P-X(LS-I) LS-P-Y(LS-I) LS-P-Z(LS-I) LS-AIR LS-SHAPE-FLAGS LS-SHAPE-BUDGET
         END-IF
     END-PERFORM
*>   the notifications (steps 11 and 12): the destroyed cells, then the pushed cells far end first, then the head
     PERFORM VARYING LS-I FROM LS-NDEST BY -1 UNTIL LS-I < 1
         CALL "BU-HOOK" USING K-2 L-DIM LS-D-X(LS-I) LS-D-Y(LS-I) LS-D-Z(LS-I) LS-D-STATE(LS-I) LS-ZERO LS-ZERO2 LS-HOOK-OUT
         MOVE CB-S-BLOCK(LS-D-STATE(LS-I) + 1) TO LS-BLOCK
         CALL "BU-NEIGHBORS-AT" USING L-DIM LS-D-X(LS-I) LS-D-Y(LS-I) LS-D-Z(LS-I) LS-BLOCK
     END-PERFORM
     PERFORM VARYING LS-I FROM LS-NPUSH BY -1 UNTIL LS-I < 1
         MOVE CB-S-BLOCK(LS-P-STATE(LS-I) + 1) TO LS-BLOCK
         CALL "BU-NEIGHBORS-AT" USING L-DIM LS-P-X(LS-I) LS-P-Y(LS-I) LS-P-Z(LS-I) LS-BLOCK
     END-PERFORM
     IF L-EXT = 1
         MOVE CB-S-BLOCK(LS-HEAD + 1) TO LS-BLOCK
         CALL "BU-NEIGHBORS-AT" USING L-DIM LS-HX LS-HY LS-HZ LS-BLOCK
     END-IF
     GOBACK.
 END PROGRAM PST-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-CLASS.
*> USING state, the RSLIVE class of its block out (31 piston, 32 sticky_piston, 33 piston_head, 34 moving_piston).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CLASS.
     CALL "REDSTONE-IDS-ENSURE"
     MOVE RL-CLASS(CB-S-BLOCK(L-STATE + 1) + 1) TO L-CLASS
     GOBACK.
 END PROGRAM PST-CLASS.
