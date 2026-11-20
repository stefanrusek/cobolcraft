*> Live pistons, part 1: the helpers and the structure resolver over the world (docs/protocol/30-redstone-3-pistons.md sections 1, 4 and 5). The plain-number programs of redstone-30-3.cob (RS1-PSR-*)
*> work on a grid of kind codes; these read the blocks of the level: the push reaction and the block entity test of 5.1 come from the block table (CB-PUSH of BLOCKS-PUSH-OF, BE-BLOCK-TYPE).
*>   PST-IDS-ENSURE                                          resolves the slime and honey blocks from the open block table (once per CB-EPOCH)
*>   PST-FACING-OF USING state, facing out                   the facing property as a direction number (0 down, 1 up, 2 north, 3 south, 4 west, 5 east)
*>   PST-STATE-OF USING block (1 sticky_piston, 2 piston, 3 piston_head, 4 moving_piston), facing, extended or short, type (0 normal, 1 sticky), state out
*>   PST-PUSHABLE USING dim, x, y, z, direction, allowDestroy, piston facing, result out    PistonBaseBlock.isPushable (5.1)
*>   PST-RESOLVE USING dim, piston x, y, z, facing, extending, ok out   PistonStructureResolver.resolve (4.2); the lists are in PSTATE.cpy

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-IDS-ENSURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-BARE                PIC X(48).
 PROCEDURE DIVISION.
     IF PS-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO PS-EPOCH
     MOVE -1 TO PS-SLIME PS-HONEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         CALL "KEY-BARE" USING CB-KEY(WS-I) WS-BARE
         IF WS-BARE = "slime_block"
             COMPUTE PS-SLIME = WS-I - 1
         END-IF
         IF WS-BARE = "honey_block"
             COMPUTE PS-HONEY = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PST-IDS-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-FACING-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(16) VALUE "facing".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FACING.
     CALL "SW-SET-PROP" USING L-STATE WS-NAME WS-KEEP WS-NEW WS-OLD
     EVALUATE WS-OLD
         WHEN "down"
             MOVE 0 TO L-FACING
         WHEN "up"
             MOVE 1 TO L-FACING
         WHEN "north"
             MOVE 2 TO L-FACING
         WHEN "south"
             MOVE 3 TO L-FACING
         WHEN "west"
             MOVE 4 TO L-FACING
         WHEN OTHER
             MOVE 5 TO L-FACING
     END-EVALUATE
     GOBACK.
 END PROGRAM PST-FACING-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-STATE-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-FACE                PIC X(5).
 01 WS-FLAG                PIC X(5).
 01 WS-TYPE                PIC X(6).
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-FACING L-FLAG L-TYPE L-STATE.
     EVALUATE L-FACING
         WHEN 0
             MOVE "down" TO WS-FACE
         WHEN 1
             MOVE "up" TO WS-FACE
         WHEN 2
             MOVE "north" TO WS-FACE
         WHEN 3
             MOVE "south" TO WS-FACE
         WHEN 4
             MOVE "west" TO WS-FACE
         WHEN OTHER
             MOVE "east" TO WS-FACE
     END-EVALUATE
     MOVE "false" TO WS-FLAG
     IF L-FLAG = 1
         MOVE "true" TO WS-FLAG
     END-IF
     MOVE "normal" TO WS-TYPE
     IF L-TYPE = 1
         MOVE "sticky" TO WS-TYPE
     END-IF
     MOVE SPACES TO WS-KEY WS-PAIRS
     EVALUATE L-BLOCK
         WHEN 1
             MOVE "sticky_piston" TO WS-KEY
             STRING "extended=" FUNCTION TRIM(WS-FLAG) ",facing=" FUNCTION TRIM(WS-FACE) DELIMITED BY SIZE INTO WS-PAIRS
         WHEN 2
             MOVE "piston" TO WS-KEY
             STRING "extended=" FUNCTION TRIM(WS-FLAG) ",facing=" FUNCTION TRIM(WS-FACE) DELIMITED BY SIZE INTO WS-PAIRS
         WHEN 3
             MOVE "piston_head" TO WS-KEY
             STRING "facing=" FUNCTION TRIM(WS-FACE) ",short=" FUNCTION TRIM(WS-FLAG) ",type=" FUNCTION TRIM(WS-TYPE)
                 DELIMITED BY SIZE INTO WS-PAIRS
         WHEN OTHER
             MOVE "moving_piston" TO WS-KEY
             STRING "facing=" FUNCTION TRIM(WS-FACE) ",type=" FUNCTION TRIM(WS-TYPE) DELIMITED BY SIZE INTO WS-PAIRS
     END-EVALUATE
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS L-STATE
     GOBACK.
 END PROGRAM PST-STATE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-PUSHABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY RSLIVE.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BE-TYPE             BINARY-LONG.
 01 WS-EXTENDED            BINARY-LONG.
 01 WS-NAME-EXTENDED       PIC X(16) VALUE "extended".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-ALLOW                BINARY-LONG.
 01 L-PF                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DIR L-ALLOW L-PF L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "REDSTONE-IDS-ENSURE"
     CALL "BU-VALID-BOUNDS" USING DM-MIN-Y(L-DIM) DM-HEIGHT(L-DIM) L-X L-Y L-Z WS-VALID
     IF WS-VALID = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     IF (L-DIR = 0 AND L-Y = DM-MIN-Y(L-DIM)) OR (L-DIR = 1 AND L-Y = WS-TOP)
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BE-BLOCK-TYPE" USING WS-BLOCK WS-BE-TYPE
     IF RL-CLASS(WS-BLOCK + 1) = 31 OR RL-CLASS(WS-BLOCK + 1) = 32
         CALL "RL-GET-BOOL" USING WS-STATE WS-NAME-EXTENDED WS-EXTENDED
         IF WS-EXTENDED = 0 AND WS-BE-TYPE < 0
             MOVE 1 TO L-RESULT
         END-IF
         GOBACK
     END-IF
     IF CB-BREAK-MS(WS-BLOCK + 1) = -1
         GOBACK
     END-IF
     EVALUATE CB-PUSH(WS-BLOCK + 1)
         WHEN 3
             GOBACK
         WHEN 2
             MOVE L-ALLOW TO L-RESULT
             GOBACK
         WHEN 1
             IF L-DIR NOT = L-PF
                 GOBACK
             END-IF
     END-EVALUATE
     IF WS-BE-TYPE < 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM PST-PUSHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-STICK.
*> USING state a, state b, canStickToEachOther out (4.5): honey never sticks to slime; otherwise one sticky block is enough.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PSTATE.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-RESULT.
     CALL "PST-IDS-ENSURE"
     MOVE CB-S-BLOCK(L-A + 1) TO WS-A
     MOVE CB-S-BLOCK(L-B + 1) TO WS-B
     MOVE 0 TO L-RESULT
     IF (WS-A = PS-SLIME OR WS-A = PS-HONEY OR WS-B = PS-SLIME OR WS-B = PS-HONEY)
             AND NOT (WS-A = PS-HONEY AND WS-B = PS-SLIME) AND NOT (WS-A = PS-SLIME AND WS-B = PS-HONEY)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM PST-STICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-IS-STICKY.
*> USING state, sticky out (4.5): slime_block and honey_block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY PSTATE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-STICKY               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-STICKY.
     CALL "PST-IDS-ENSURE"
     MOVE 0 TO L-STICKY
     IF CB-S-BLOCK(L-STATE + 1) = PS-SLIME OR CB-S-BLOCK(L-STATE + 1) = PS-HONEY
         MOVE 1 TO L-STICKY
     END-IF
     GOBACK.
 END PROGRAM PST-IS-STICKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-FIND.
*> USING x, y, z, index out: the place of the position in the toPush list, 0 when it is not there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PS-NPUSH OR L-INDEX > 0
         IF PS-P-X(WS-I) = L-X AND PS-P-Y(WS-I) = L-Y AND PS-P-Z(WS-I) = L-Z
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PST-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-BRANCH RECURSIVE.
*> USING x, y, z, ok out (4.5 addBranchingBlocks): every direction off the push axis whose neighbour sticks to this block is a line; a failed line fails the call.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-D                   BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-AX                  BINARY-LONG.
 01 LS-AP                  BINARY-LONG.
 01 LS-STICK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     CALL "WORLD-GET-BLOCK" USING PS-DIM L-X L-Y L-Z LS-STATE
     DIVIDE PS-PUSHDIR BY 2 GIVING LS-AP
     PERFORM VARYING LS-D FROM 0 BY 1 UNTIL LS-D > 5 OR L-OK = 0
         DIVIDE LS-D BY 2 GIVING LS-AX
         IF LS-AX NOT = LS-AP
             CALL "BU-DIRECTION" USING LS-D LS-DX LS-DY LS-DZ
             COMPUTE LS-NX = L-X + LS-DX
             COMPUTE LS-NY = L-Y + LS-DY
             COMPUTE LS-NZ = L-Z + LS-DZ
             CALL "WORLD-GET-BLOCK" USING PS-DIM LS-NX LS-NY LS-NZ LS-NSTATE
             CALL "PST-STICK" USING LS-NSTATE LS-STATE LS-STICK
             IF LS-STICK = 1
                 CALL "PST-LINE" USING LS-NX LS-NY LS-NZ LS-D L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PST-BRANCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-LINE RECURSIVE.
*> USING x, y, z, the direction the line was entered in, ok out (4.3 addBlockLine): false only when the structure is blocked or too long.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PSTATE.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-STATE               BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-PREV                BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-ODX                 BINARY-LONG.
 01 LS-ODY                 BINARY-LONG.
 01 LS-ODZ                 BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CY                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NZ                  BINARY-LONG.
 01 LS-LEN                 BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-OKA                 BINARY-LONG.
 01 LS-STICK               BINARY-LONG.
 01 LS-STICKY              BINARY-LONG.
 01 LS-GO                  BINARY-LONG.
 01 LS-PUSHABLE            BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 01 LS-SIZE                BINARY-LONG.
 01 LS-LIM                 BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-PD                  BINARY-LONG.
 01 LS-TMP.
    05 LS-T OCCURS 64 TIMES.
       10 LS-T-X           BINARY-LONG.
       10 LS-T-Y           BINARY-LONG.
       10 LS-T-Z           BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO LS-DONE
     MOVE PS-PUSHDIR TO LS-PD
     CALL "BU-DIRECTION" USING PS-PUSHDIR LS-DX LS-DY LS-DZ
     COMPUTE LS-OPP = PS-PUSHDIR + 1 - 2 * FUNCTION MOD(PS-PUSHDIR, 2)
     CALL "BU-DIRECTION" USING LS-OPP LS-ODX LS-ODY LS-ODZ
     CALL "WORLD-GET-BLOCK" USING PS-DIM L-X L-Y L-Z LS-STATE
     IF LS-STATE = 0
         MOVE 1 TO LS-DONE
     END-IF
     IF LS-DONE = 0
         CALL "PST-PUSHABLE" USING PS-DIM L-X L-Y L-Z PS-PUSHDIR LS-ZERO L-DIR LS-PUSHABLE
         IF LS-PUSHABLE = 0
             MOVE 1 TO LS-DONE
         END-IF
     END-IF
     IF LS-DONE = 0
         IF L-X = PS-PX AND L-Y = PS-PY AND L-Z = PS-PZ
             MOVE 1 TO LS-DONE
         END-IF
         CALL "PST-FIND" USING L-X L-Y L-Z LS-FOUND
         IF LS-FOUND > 0
             MOVE 1 TO LS-DONE
         END-IF
     END-IF
     IF LS-DONE = 0
         MOVE 1 TO LS-LEN
         COMPUTE LS-LIM = LS-LEN + PS-NPUSH
         IF LS-LIM > 12
             MOVE 0 TO L-OK
             MOVE 1 TO LS-DONE
         END-IF
     END-IF
     CALL "PST-IS-STICKY" USING LS-STATE LS-STICKY
     IF LS-DONE = 0 AND LS-STICKY = 1
         MOVE LS-STATE TO LS-PREV
         MOVE L-X TO LS-CX
         MOVE L-Y TO LS-CY
         MOVE L-Z TO LS-CZ
         MOVE 1 TO LS-GO
         PERFORM UNTIL LS-GO = 0
             COMPUTE LS-NX = LS-CX + LS-ODX
             COMPUTE LS-NY = LS-CY + LS-ODY
             COMPUTE LS-NZ = LS-CZ + LS-ODZ
             CALL "WORLD-GET-BLOCK" USING PS-DIM LS-NX LS-NY LS-NZ LS-NSTATE
             CALL "PST-STICK" USING LS-PREV LS-NSTATE LS-STICK
             CALL "PST-PUSHABLE" USING PS-DIM LS-NX LS-NY LS-NZ PS-PUSHDIR LS-ZERO LS-OPP LS-PUSHABLE
             IF LS-NSTATE = 0 OR LS-STICK = 0 OR LS-PUSHABLE = 0 OR (LS-NX = PS-PX AND LS-NY = PS-PY AND LS-NZ = PS-PZ)
                 MOVE 0 TO LS-GO
             ELSE
                 ADD 1 TO LS-LEN
                 COMPUTE LS-LIM = LS-LEN + PS-NPUSH
                 IF LS-LIM > 12
                     MOVE 0 TO L-OK
                     MOVE 1 TO LS-DONE
                     MOVE 0 TO LS-GO
                 END-IF
                 MOVE LS-NSTATE TO LS-PREV
                 MOVE LS-NX TO LS-CX
                 MOVE LS-NY TO LS-CY
                 MOVE LS-NZ TO LS-CZ
             END-IF
         END-PERFORM
     END-IF
     IF LS-DONE = 0
         PERFORM VARYING LS-I FROM LS-LEN BY -1 UNTIL LS-I < 1
             COMPUTE LS-J = LS-I - 1
             ADD 1 TO PS-NPUSH
             COMPUTE PS-P-X(PS-NPUSH) = L-X + LS-ODX * LS-J
             COMPUTE PS-P-Y(PS-NPUSH) = L-Y + LS-ODY * LS-J
             COMPUTE PS-P-Z(PS-NPUSH) = L-Z + LS-ODZ * LS-J
         END-PERFORM
         MOVE LS-LEN TO LS-COUNT
         MOVE L-X TO LS-CX
         MOVE L-Y TO LS-CY
         MOVE L-Z TO LS-CZ
         PERFORM UNTIL LS-DONE = 1
             COMPUTE LS-CX = LS-CX + LS-DX
             COMPUTE LS-CY = LS-CY + LS-DY
             COMPUTE LS-CZ = LS-CZ + LS-DZ
             CALL "PST-FIND" USING LS-CX LS-CY LS-CZ LS-FOUND
             CALL "WORLD-GET-BLOCK" USING PS-DIM LS-CX LS-CY LS-CZ LS-NSTATE
             IF LS-FOUND > 0
*>               two branches meet (4.4): the new line moves in front of the part it collided with
                 COMPUTE LS-A = LS-FOUND - 1
                 MOVE PS-NPUSH TO LS-SIZE
                 MOVE 0 TO LS-K
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-A
                     ADD 1 TO LS-K
                     MOVE PS-P(LS-I) TO LS-T(LS-K)
                 END-PERFORM
                 COMPUTE LS-B = LS-SIZE - LS-COUNT
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                     ADD 1 TO LS-K
                     COMPUTE LS-J = LS-B + LS-I
                     MOVE PS-P(LS-J) TO LS-T(LS-K)
                 END-PERFORM
                 PERFORM VARYING LS-I FROM LS-FOUND BY 1 UNTIL LS-I > LS-B
                     ADD 1 TO LS-K
                     MOVE PS-P(LS-I) TO LS-T(LS-K)
                 END-PERFORM
                 PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-SIZE
                     MOVE LS-T(LS-I) TO PS-P(LS-I)
                 END-PERFORM
                 COMPUTE LS-LIM = LS-A + LS-COUNT + 1
                 MOVE 1 TO LS-I
                 PERFORM UNTIL LS-I > LS-LIM OR L-OK = 0
                     CALL "WORLD-GET-BLOCK" USING PS-DIM PS-P-X(LS-I) PS-P-Y(LS-I) PS-P-Z(LS-I) LS-NSTATE
                     CALL "PST-IS-STICKY" USING LS-NSTATE LS-STICKY
                     IF LS-STICKY = 1
                         CALL "PST-BRANCH" USING PS-P-X(LS-I) PS-P-Y(LS-I) PS-P-Z(LS-I) LS-OKA
                         IF LS-OKA = 0
                             MOVE 0 TO L-OK
                         END-IF
                     END-IF
                     ADD 1 TO LS-I
                 END-PERFORM
                 MOVE 1 TO LS-DONE
             ELSE
                 IF LS-NSTATE = 0
                     MOVE 1 TO LS-DONE
                 ELSE
                     CALL "PST-PUSHABLE" USING PS-DIM LS-CX LS-CY LS-CZ PS-PUSHDIR LS-ONE LS-PD LS-PUSHABLE
                     IF LS-PUSHABLE = 0 OR (LS-CX = PS-PX AND LS-CY = PS-PY AND LS-CZ = PS-PZ)
                         MOVE 0 TO L-OK
                         MOVE 1 TO LS-DONE
                     ELSE
                         IF CB-PUSH(CB-S-BLOCK(LS-NSTATE + 1) + 1) = 2
                             ADD 1 TO PS-NDEST
                             MOVE LS-CX TO PS-D-X(PS-NDEST)
                             MOVE LS-CY TO PS-D-Y(PS-NDEST)
                             MOVE LS-CZ TO PS-D-Z(PS-NDEST)
                             MOVE 1 TO LS-DONE
                         ELSE
                             IF PS-NPUSH >= 12
                                 MOVE 0 TO L-OK
                                 MOVE 1 TO LS-DONE
                             ELSE
                                 ADD 1 TO PS-NPUSH
                                 MOVE LS-CX TO PS-P-X(PS-NPUSH)
                                 MOVE LS-CY TO PS-P-Y(PS-NPUSH)
                                 MOVE LS-CZ TO PS-P-Z(PS-NPUSH)
                                 ADD 1 TO LS-COUNT
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PST-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-RESOLVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PSTATE.
 COPY CBLOCKS.
 01 WS-STEPS               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PUSHABLE            BINARY-LONG.
 01 WS-STICKY              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-EXT                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-EXT L-OK.
     MOVE L-DIM TO PS-DIM
     MOVE L-X TO PS-PX
     MOVE L-Y TO PS-PY
     MOVE L-Z TO PS-PZ
     MOVE 0 TO PS-NPUSH PS-NDEST
     MOVE L-FACING TO PS-PUSHDIR
     MOVE 2 TO WS-STEPS
     IF L-EXT = 1
         MOVE 1 TO WS-STEPS
     ELSE
         COMPUTE PS-PUSHDIR = L-FACING + 1 - 2 * FUNCTION MOD(L-FACING, 2)
     END-IF
     CALL "BU-DIRECTION" USING L-FACING WS-DX WS-DY WS-DZ
     COMPUTE WS-SX = L-X + WS-DX * WS-STEPS
     COMPUTE WS-SY = L-Y + WS-DY * WS-STEPS
     COMPUTE WS-SZ = L-Z + WS-DZ * WS-STEPS
     MOVE 1 TO L-OK
     MOVE 0 TO WS-DONE
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-SX WS-SY WS-SZ WS-STATE
     CALL "PST-PUSHABLE" USING L-DIM WS-SX WS-SY WS-SZ PS-PUSHDIR WS-ZERO L-FACING WS-PUSHABLE
     IF WS-PUSHABLE = 0
         MOVE 1 TO WS-DONE
         MOVE 0 TO L-OK
         IF L-EXT = 1 AND CB-PUSH(CB-S-BLOCK(WS-STATE + 1) + 1) = 2
             MOVE 1 TO L-OK
             MOVE 1 TO PS-NDEST
             MOVE WS-SX TO PS-D-X(1)
             MOVE WS-SY TO PS-D-Y(1)
             MOVE WS-SZ TO PS-D-Z(1)
         END-IF
     END-IF
     IF WS-DONE = 0
         CALL "PST-LINE" USING WS-SX WS-SY WS-SZ PS-PUSHDIR L-OK
     END-IF
     IF WS-DONE = 0 AND L-OK = 1
         MOVE 1 TO WS-I
         PERFORM UNTIL WS-I > PS-NPUSH OR L-OK = 0
             CALL "WORLD-GET-BLOCK" USING L-DIM PS-P-X(WS-I) PS-P-Y(WS-I) PS-P-Z(WS-I) WS-STATE
             CALL "PST-IS-STICKY" USING WS-STATE WS-STICKY
             IF WS-STICKY = 1
                 CALL "PST-BRANCH" USING PS-P-X(WS-I) PS-P-Y(WS-I) PS-P-Z(WS-I) L-OK
             END-IF
             ADD 1 TO WS-I
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PST-RESOLVE.
