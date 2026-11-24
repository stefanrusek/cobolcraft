*> Live pistons, part 3: checkIfExtend, triggerEvent, the moving block entity (finalTick and tick), the head and the hook dispatch (docs/protocol/30-redstone-3-pistons.md sections 2.3, 3.2, 7.2, 7.4, 9.3).
*> See piston-live-b.cob for the cells of the moving block entity and for what is not done.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-CHECK RECURSIVE.
*> USING dim, x, y, z, state of the piston: checkIfExtend (2.3): powered and retracted queues the extend event if the structure resolves; unpowered and extended queues the retract event, type 2 (drop) when the
*> block two cells ahead is a moving block still extending that is under half way, was ticked this very game tick, or the level is inside its tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY CORESTATE.
 COPY PSTATE.
 01 WS-NAME-EXTENDED       PIC X(16) VALUE "extended".
 LOCAL-STORAGE SECTION.
 01 LS-FACING              BINARY-LONG.
 01 LS-EXT                 BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-ZERO2               BINARY-LONG VALUE 0.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-TX                  BINARY-LONG.
 01 LS-TY                  BINARY-LONG.
 01 LS-TZ                  BINARY-LONG.
 01 LS-TSTATE              BINARY-LONG.
 01 LS-TCLASS              BINARY-LONG.
 01 LS-TFACING             BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "PST-FACING-OF" USING L-STATE LS-FACING
     CALL "RL-GET-BOOL" USING L-STATE WS-NAME-EXTENDED LS-EXT
     CALL "PST-NEIGHBOR-SIGNAL" USING L-DIM L-X L-Y L-Z LS-FACING LS-POWERED
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     IF LS-POWERED = 1 AND LS-EXT = 0
         CALL "PST-RESOLVE" USING L-DIM L-X L-Y L-Z LS-FACING LS-ONE LS-OK
         IF LS-OK = 1
             CALL "BE-ADD" USING L-DIM L-X L-Y L-Z LS-BLOCK LS-ZERO LS-FACING
         END-IF
     END-IF
     IF LS-POWERED = 0 AND LS-EXT = 1
         MOVE 1 TO LS-TYPE
         CALL "BU-DIRECTION" USING LS-FACING LS-DX LS-DY LS-DZ
         COMPUTE LS-TX = L-X + LS-DX * 2
         COMPUTE LS-TY = L-Y + LS-DY * 2
         COMPUTE LS-TZ = L-Z + LS-DZ * 2
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-TX LS-TY LS-TZ LS-TSTATE
         CALL "PST-CLASS" USING LS-TSTATE LS-TCLASS
         IF LS-TCLASS = 34
             CALL "PST-FACING-OF" USING LS-TSTATE LS-TFACING
             CALL "BE-FIND" USING L-DIM LS-TX LS-TY LS-TZ LS-INDEX
             IF LS-TFACING = LS-FACING AND LS-INDEX > 0
                 IF BE-XI(LS-INDEX, 3) = 1
                     IF BE-PROGRESS-OLD(LS-INDEX) < 0.5 OR BE-TIME2(LS-INDEX) = CW-TICKS OR PS-IN-TICK = 1
                         MOVE 2 TO LS-TYPE
                     END-IF
                 END-IF
             END-IF
         END-IF
         CALL "BE-ADD" USING L-DIM L-X L-Y L-Z LS-BLOCK LS-TYPE LS-FACING
     END-IF
     GOBACK.
 END PROGRAM PST-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-MBE-FINAL RECURSIVE.
*> USING block entity index: finalTick (7.4): when progressO is below 1 the entity ends at once: a source piston's cell becomes air, any other moved block is placed after the shape updates of its neighbours.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 LOCAL-STORAGE SECTION.
 01 LS-DIM                 BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-MOVED               BINARY-LONG.
 01 LS-SOURCE              BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
*>   finalTick (30-3 7.2) acts only while progressO < 1: an entity in use always has it (PST-MBE-TICK ends the entity in the tick that reads progress 1, and this program ends it before it returns), so no guard is needed
     MOVE BE-DIM(L-INDEX) TO LS-DIM
     MOVE BE-X(L-INDEX) TO LS-X
     MOVE BE-Y(L-INDEX) TO LS-Y
     MOVE BE-Z(L-INDEX) TO LS-Z
     MOVE BE-XI(L-INDEX, 1) TO LS-MOVED
     MOVE BE-XI(L-INDEX, 4) TO LS-SOURCE
     MOVE 1 TO BE-PROGRESS(L-INDEX) BE-PROGRESS-OLD(L-INDEX)
     CALL "BE-SET-REMOVED" USING L-INDEX LS-ONE
     MOVE 0 TO BE-USED(L-INDEX)
     CALL "WORLD-GET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-STATE
     CALL "PST-CLASS" USING LS-STATE LS-CLASS
     IF LS-CLASS = 34
         MOVE 0 TO LS-NEW
         IF LS-SOURCE = 0
             CALL "BU-UPDATE-FROM-SHAPES" USING LS-DIM LS-X LS-Y LS-Z LS-MOVED LS-NEW
         END-IF
         CALL "LEVEL-SET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
         MOVE CB-S-BLOCK(LS-NEW + 1) TO LS-BLOCK
         CALL "BU-NEIGHBOR-SIMPLE" USING LS-DIM LS-X LS-Y LS-Z LS-BLOCK
     END-IF
     GOBACK.
 END PROGRAM PST-MBE-FINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-MBE-TICK RECURSIVE.
*> USING block entity index: PistonMovingBlockEntity.tick (7.2): lastTicked and progressO are set; at progressO 1 the entity ends and the moved state is placed (waterlogged cleared, flags 67, or, when the
*> neighbours' shapes turn it into air, written with flags 340 and then destroyed with its drops); else the entities in the way are pushed (piston-push.cob, 8.1) and the progress rises by 0.5 (capped at 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY CORESTATE.
 01 WS-NAME-WL             PIC X(16) VALUE "waterlogged".
 01 WS-FALSE               PIC X(16) VALUE "false".
 LOCAL-STORAGE SECTION.
 01 LS-DIM                 BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-MOVED               BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NEW2                BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE CW-TICKS TO BE-TIME2(L-INDEX)
     MOVE BE-PROGRESS(L-INDEX) TO BE-PROGRESS-OLD(L-INDEX)
     IF BE-PROGRESS-OLD(L-INDEX) >= 1
         MOVE BE-DIM(L-INDEX) TO LS-DIM
         MOVE BE-X(L-INDEX) TO LS-X
         MOVE BE-Y(L-INDEX) TO LS-Y
         MOVE BE-Z(L-INDEX) TO LS-Z
         MOVE BE-XI(L-INDEX, 1) TO LS-MOVED
         CALL "BE-SET-REMOVED" USING L-INDEX LS-ONE
         MOVE 0 TO BE-USED(L-INDEX)
         CALL "WORLD-GET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-STATE
         CALL "PST-CLASS" USING LS-STATE LS-CLASS
         IF LS-CLASS = 34
             CALL "BU-UPDATE-FROM-SHAPES" USING LS-DIM LS-X LS-Y LS-Z LS-MOVED LS-NEW
             IF LS-NEW = 0
                 MOVE 340 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-MOVED LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "LEVEL-DESTROY-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-ONE LS-BUDGET LS-RESULT
             ELSE
                 CALL "SW-SET-PROP" USING LS-NEW WS-NAME-WL WS-FALSE LS-NEW2 LS-OLD
                 MOVE 67 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-NEW2 LS-FLAGS LS-BUDGET LS-RESULT
                 MOVE CB-S-BLOCK(LS-NEW2 + 1) TO LS-BLOCK
                 CALL "BU-NEIGHBOR-SIMPLE" USING LS-DIM LS-X LS-Y LS-Z LS-BLOCK
             END-IF
         END-IF
     ELSE
         CALL "PST-PUSH-ENTITIES" USING L-INDEX
         COMPUTE BE-PROGRESS(L-INDEX) = BE-PROGRESS(L-INDEX) + 0.5
         IF BE-PROGRESS(L-INDEX) >= 1
             MOVE 1 TO BE-PROGRESS(L-INDEX)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PST-MBE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-EVENT RECURSIVE.
*> USING dim, x, y, z, state, type, data, handled out: triggerEvent (3.2). The power is read again first: powered retraction (types 1, 2) is cancelled (the base is marked extended with flag 2), an unpowered
*> extension (type 0) is cancelled; both answer false (no packet). Type 0 moves the blocks, writes the extended base (flags 67), plays block.piston.extend and answers true. Types 1 and 2 retract.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY RSLIVE.
 01 K-3                    BINARY-LONG VALUE 3.
 01 K-4                    BINARY-LONG VALUE 4.
 01 WS-SOUND-EXTEND        PIC X(48) VALUE "block.piston.extend".
 01 WS-SOUND-CONTRACT      PIC X(48) VALUE "block.piston.contract".
 01 WS-SALT                BINARY-LONG VALUE 9301.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-SOURCE-BLOCKS       BINARY-LONG VALUE 4.
 01 WS-VOLUME              BINARY-LONG VALUE 500000.
 LOCAL-STORAGE SECTION.
 01 LS-FACING              BINARY-LONG.
 01 LS-CODE                BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-STICKY              BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-EXT-STATE           BINARY-LONG.
 01 LS-MOVING              BINARY-LONG.
 01 LS-BASE                BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-ZERO2               BINARY-LONG VALUE 0.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-HX                  BINARY-LONG.
 01 LS-HY                  BINARY-LONG.
 01 LS-HZ                  BINARY-LONG.
 01 LS-TX                  BINARY-LONG.
 01 LS-TY                  BINARY-LONG.
 01 LS-TZ                  BINARY-LONG.
 01 LS-TSTATE              BINARY-LONG.
 01 LS-TCLASS              BINARY-LONG.
 01 LS-TFACING             BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 01 LS-FOUND               BINARY-LONG.
 01 LS-PUSHABLE            BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-DATA-FACING         BINARY-LONG.
 01 LS-RETRACTED           BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-PITCH               BINARY-LONG.
 01 LS-SHAPE-FLAGS         BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-TYPE L-DATA L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "PST-CLASS" USING L-STATE LS-CLASS
     CALL "PST-FACING-OF" USING L-STATE LS-FACING
     MOVE 2 TO LS-CODE
     MOVE 0 TO LS-STICKY
     IF LS-CLASS = 32
         MOVE 1 TO LS-CODE
         MOVE 1 TO LS-STICKY
     END-IF
     CALL "PST-NEIGHBOR-SIGNAL" USING L-DIM L-X L-Y L-Z LS-FACING LS-POWERED
     IF LS-POWERED = 1 AND (L-TYPE = 1 OR L-TYPE = 2)
         CALL "PST-STATE-OF" USING LS-CODE LS-FACING LS-ONE LS-ZERO LS-EXT-STATE
         MOVE 2 TO LS-FLAGS
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-EXT-STATE LS-FLAGS LS-BUDGET LS-RESULT
         GOBACK
     END-IF
     IF LS-POWERED = 0 AND L-TYPE = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-MILLION LS-DRAW
     CALL "BU-DIRECTION" USING LS-FACING LS-DX LS-DY LS-DZ
     COMPUTE LS-HX = L-X + LS-DX
     COMPUTE LS-HY = L-Y + LS-DY
     COMPUTE LS-HZ = L-Z + LS-DZ
     EVALUATE L-TYPE
         WHEN 0
             CALL "PST-MOVE" USING L-DIM L-X L-Y L-Z LS-FACING LS-ONE LS-OK
             IF LS-OK = 1
                 CALL "PST-STATE-OF" USING LS-CODE LS-FACING LS-ONE LS-ZERO LS-EXT-STATE
                 MOVE 67 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-EXT-STATE LS-FLAGS LS-BUDGET LS-RESULT
                 COMPUTE LS-PITCH = LS-DRAW / 4 + 600000
                 CALL "RL-SOUND-AT" USING L-DIM L-X L-Y L-Z WS-SOUND-EXTEND WS-SOURCE-BLOCKS WS-VOLUME LS-PITCH
                 MOVE 1 TO L-HANDLED
             END-IF
         WHEN 1
         WHEN 2
*>           the head of an extension in progress ends at once (a source entity: its cell becomes air)
             CALL "BE-FIND" USING L-DIM LS-HX LS-HY LS-HZ LS-INDEX
             IF LS-INDEX > 0
                 IF BE-TYPE(LS-INDEX) = 11
                     CALL "PST-MBE-FINAL" USING LS-INDEX
                 END-IF
             END-IF
             CALL "PST-STATE-OF" USING K-4 LS-FACING LS-ZERO LS-STICKY LS-MOVING
             MOVE 276 TO LS-FLAGS
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-MOVING LS-FLAGS LS-BUDGET LS-RESULT
             MOVE L-DATA TO LS-DATA-FACING
             COMPUTE LS-DATA-FACING = FUNCTION MOD(L-DATA, 8)
             CALL "PST-STATE-OF" USING LS-CODE LS-DATA-FACING LS-ZERO LS-ZERO2 LS-RETRACTED
             CALL "PST-BE-FILL" USING L-DIM L-X L-Y L-Z LS-RETRACTED LS-FACING LS-ZERO LS-ONE
             MOVE CB-S-BLOCK(LS-MOVING + 1) TO LS-BLOCK
             CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z LS-BLOCK
             MOVE 512 TO LS-BUDGET
             CALL "BU-SHAPE-UPDATES" USING L-DIM L-X L-Y L-Z LS-MOVING LS-SHAPE-FLAGS LS-BUDGET
             IF LS-STICKY = 1
                 COMPUTE LS-TX = L-X + LS-DX * 2
                 COMPUTE LS-TY = L-Y + LS-DY * 2
                 COMPUTE LS-TZ = L-Z + LS-DZ * 2
                 CALL "WORLD-GET-BLOCK" USING L-DIM LS-TX LS-TY LS-TZ LS-TSTATE
                 CALL "PST-CLASS" USING LS-TSTATE LS-TCLASS
                 MOVE 0 TO LS-FOUND
                 IF LS-TCLASS = 34
                     CALL "BE-FIND" USING L-DIM LS-TX LS-TY LS-TZ LS-INDEX
                     IF LS-INDEX > 0
                         IF BE-XI(LS-INDEX, 2) = LS-FACING AND BE-XI(LS-INDEX, 3) = 1
                             CALL "PST-MBE-FINAL" USING LS-INDEX
                             MOVE 1 TO LS-FOUND
                         END-IF
                     END-IF
                 END-IF
                 IF LS-FOUND = 0
                     COMPUTE LS-OPP = LS-FACING + 1 - 2 * FUNCTION MOD(LS-FACING, 2)
                     MOVE 0 TO LS-PUSHABLE
                     IF L-TYPE = 1 AND LS-TSTATE NOT = 0
                         CALL "PST-PUSHABLE" USING L-DIM LS-TX LS-TY LS-TZ LS-OPP LS-ZERO LS-FACING LS-PUSHABLE
                     END-IF
                     IF LS-PUSHABLE = 1 AND (CB-PUSH(CB-S-BLOCK(LS-TSTATE + 1) + 1) = 0 OR LS-TCLASS = 31 OR LS-TCLASS = 32)
                         CALL "PST-MOVE" USING L-DIM L-X L-Y L-Z LS-FACING LS-ZERO LS-OK
                     ELSE
                         CALL "LEVEL-REMOVE-BLOCK" USING L-DIM LS-HX LS-HY LS-HZ LS-ZERO LS-RESULT
                     END-IF
                 END-IF
             ELSE
                 CALL "LEVEL-REMOVE-BLOCK" USING L-DIM LS-HX LS-HY LS-HZ LS-ZERO LS-RESULT
             END-IF
             COMPUTE LS-PITCH = LS-DRAW * 15 / 100 + 600000
             CALL "RL-SOUND-AT" USING L-DIM L-X L-Y L-Z WS-SOUND-CONTRACT WS-SOURCE-BLOCKS WS-VOLUME LS-PITCH
             MOVE 1 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM PST-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-HEAD-BEHIND.
*> USING dim, x, y, z, state of a piston head, behind x, y, z out, fitting out (9.3): the cell behind the head and whether it holds the matching extended base (isFittingBase: piston for type normal, sticky_piston
*> for sticky, extended, same facing); survive out is 1 for that or for a moving_piston of the same facing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME-TYPE           PIC X(16) VALUE "type".
 01 WS-NAME-EXTENDED       PIC X(16) VALUE "extended".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 01 WS-FACING              BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BFACING             BINARY-LONG.
 01 WS-EXTENDED            BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-FITTING              BINARY-LONG.
 01 L-SURVIVE              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-BX L-BY L-BZ L-FITTING L-SURVIVE.
     MOVE 0 TO L-FITTING L-SURVIVE
     CALL "PST-FACING-OF" USING L-STATE WS-FACING
     COMPUTE WS-OPP = WS-FACING + 1 - 2 * FUNCTION MOD(WS-FACING, 2)
     CALL "BU-DIRECTION" USING WS-OPP WS-DX WS-DY WS-DZ
     COMPUTE L-BX = L-X + WS-DX
     COMPUTE L-BY = L-Y + WS-DY
     COMPUTE L-BZ = L-Z + WS-DZ
     CALL "WORLD-GET-BLOCK" USING L-DIM L-BX L-BY L-BZ WS-STATE
     CALL "PST-CLASS" USING WS-STATE WS-CLASS
     CALL "PST-FACING-OF" USING WS-STATE WS-BFACING
     IF WS-CLASS = 34 AND WS-BFACING = WS-FACING
         MOVE 1 TO L-SURVIVE
     END-IF
     IF WS-CLASS = 31 OR WS-CLASS = 32
         CALL "SW-SET-PROP" USING L-STATE WS-NAME-TYPE WS-KEEP WS-NEW WS-OLD
         MOVE 31 TO WS-WANT
         IF WS-OLD = "sticky"
             MOVE 32 TO WS-WANT
         END-IF
         CALL "RL-GET-BOOL" USING WS-STATE WS-NAME-EXTENDED WS-EXTENDED
         IF WS-CLASS = WS-WANT AND WS-EXTENDED = 1 AND WS-BFACING = WS-FACING
             MOVE 1 TO L-FITTING L-SURVIVE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PST-HEAD-BEHIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PST-HOOK RECURSIVE.
*> USING kind, dim, x, y, z, state, a, b, out (the BU-HOOK arguments): piston and sticky_piston: onPlace (kind 1: the old state is another block and no block entity is here) and neighborChanged (3) run
*> checkIfExtend, the block event (10) is triggerEvent. piston_head: neighborChanged (3) passes the change on to the base behind when the head can survive (2.1), updateShape (4) from behind turns an
*> unsupported head into air (9.3), removal (2) destroys the fitting base behind with its drop.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-CLASS               BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 01 LS-BX                  BINARY-LONG.
 01 LS-BY                  BINARY-LONG.
 01 LS-BZ                  BINARY-LONG.
 01 LS-FITTING             BINARY-LONG.
 01 LS-SURVIVE             BINARY-LONG.
 01 LS-FACING              BINARY-LONG.
 01 LS-OPP                 BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     CALL "PST-CLASS" USING L-STATE LS-CLASS
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     IF LS-CLASS = 31 OR LS-CLASS = 32
         EVALUATE L-KIND
             WHEN 1
                 CALL "BE-FIND" USING L-DIM L-X L-Y L-Z LS-INDEX
                 IF CB-S-BLOCK(L-A + 1) NOT = LS-BLOCK AND LS-INDEX = 0
                     CALL "PST-CHECK" USING L-DIM L-X L-Y L-Z L-STATE
                 END-IF
             WHEN 3
                 CALL "PST-CHECK" USING L-DIM L-X L-Y L-Z L-STATE
             WHEN 10
                 CALL "PST-EVENT" USING L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
         END-EVALUATE
     END-IF
     IF LS-CLASS = 33
         CALL "PST-HEAD-BEHIND" USING L-DIM L-X L-Y L-Z L-STATE LS-BX LS-BY LS-BZ LS-FITTING LS-SURVIVE
         EVALUATE L-KIND
             WHEN 3
                 IF LS-SURVIVE = 1
                     CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM LS-BX LS-BY LS-BZ LS-BLOCK
                 END-IF
             WHEN 4
                 CALL "PST-FACING-OF" USING L-STATE LS-FACING
                 COMPUTE LS-OPP = LS-FACING + 1 - 2 * FUNCTION MOD(LS-FACING, 2)
                 IF L-A = LS-OPP AND LS-SURVIVE = 0
                     MOVE 0 TO L-OUT
                 END-IF
             WHEN 2
                 IF LS-FITTING = 1
                     CALL "LEVEL-DESTROY-BLOCK" USING L-DIM LS-BX LS-BY LS-BZ LS-ONE LS-BUDGET LS-RESULT
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM PST-HOOK.
