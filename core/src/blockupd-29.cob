*> Block updates, ticking, placement and breaking (docs/protocol/29), the sections as the tasks T0455 to T0478 reach
*> them. Section 1: the update flags (BLOCKUPD.cpy) and the bounds tests of the recursion and of isInValidBounds.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-SHAPE-FLAGS.
*> USING flags, shape flags out (BINARY-LONG): the flags the shape updates of 2.2 step 7 hand on, flags with bits 0 and 5
*> cleared (the read constant -34).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKUPD.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAGS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAGS L-OUT.
     MOVE L-FLAGS TO L-OUT
     COMPUTE WS-LOW = FUNCTION MOD(L-FLAGS, 2)
     SUBTRACT WS-LOW FROM L-OUT
     COMPUTE WS-HIGH = FUNCTION MOD(L-FLAGS, 64) - FUNCTION MOD(L-FLAGS, 32)
     SUBTRACT WS-HIGH FROM L-OUT
     GOBACK.
 END PROGRAM BU-SHAPE-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-BUDGET-OPEN.
*> USING budget, open out (BINARY-LONG): 1 while the budget is above 0, the condition under which the shape updates of
*> 2.2 step 7 run (each nested pass hands budget - 1 on, so the chain is at most BU-UPDATE-LIMIT levels deep).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUDGET               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BUDGET L-OPEN.
     MOVE 0 TO L-OPEN
     IF L-BUDGET > 0
         MOVE 1 TO L-OPEN
     END-IF
     GOBACK.
 END PROGRAM BU-BUDGET-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-PACKED-LENGTH.
*> USING bits out, maximum horizontal coordinate out, its section coordinate out (BINARY-LONG): PACKED_HORIZONTAL_LENGTH
*> = 1 + log2 of the smallest power of two that is at least 30000000 (a bit-smearing round-up, then the log), the maximum
*> coordinate (1 << bits) / 2 - 1 and that coordinate shifted right by 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-POWER               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-BITS                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-BITS L-MAX L-SECTION.
*> The smeared round-up of 30000000 - 1 plus 1 is the least power of two at or above 30000000.
     MOVE 1 TO WS-V
     MOVE 0 TO WS-LOG
     PERFORM UNTIL WS-V >= 30000000
         COMPUTE WS-V = WS-V * 2
         ADD 1 TO WS-LOG
     END-PERFORM
     COMPUTE L-BITS = 1 + WS-LOG
     MOVE 1 TO WS-POWER
     PERFORM L-BITS TIMES
         COMPUTE WS-POWER = WS-POWER * 2
     END-PERFORM
     COMPUTE L-MAX = WS-POWER / 2 - 1
     COMPUTE L-SECTION = (L-MAX - FUNCTION MOD(L-MAX, 16)) / 16
     GOBACK.
 END PROGRAM BU-PACKED-LENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-SAFETY-MARGIN.
*> USING margin out (BINARY-LONG): SAFETY_MARGIN_CHUNKS = (32 + n + 1) * 2 where n is the accumulated dependency count of the
*> FULL step of the generation pyramid, derived from the rule of 1: an own list of length D and the parent's radius rp give
*> max(rp + A(parent), D). The steps after EMPTY (A = 0) are, as (rp, D): STRUCTURE_STARTS (0, 1), STRUCTURE_REFERENCES (8, 9),
*> BIOMES (0, 9), TERRAIN (1, 9), FEATURES (1, 9), INITIALIZE_LIGHT (0, 1), LIGHT (1, 2), SPAWN (0, 2), FULL (0, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEPS.
    05 FILLER              PIC X(27) VALUE "001809009109109001102002001".
 01 WS-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 9 TIMES.
       10 WS-RP            PIC 9.
       10 WS-D             PIC 99.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MARGIN               BINARY-LONG.
 PROCEDURE DIVISION USING L-MARGIN.
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         COMPUTE WS-N = WS-RP(WS-I) + WS-A
         IF WS-D(WS-I) > WS-N
             MOVE WS-D(WS-I) TO WS-N
         END-IF
         MOVE WS-N TO WS-A
     END-PERFORM
     COMPUTE L-MARGIN = (32 + WS-A + 1) * 2
     GOBACK.
 END PROGRAM BU-SAFETY-MARGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-MAX-CHUNK-COORD.
*> USING value out (BINARY-LONG): ChunkPyramid.MAX_CHUNK_COORDINATE_VALUE = the section coordinate of the maximum horizontal
*> block coordinate minus SAFETY_MARGIN_CHUNKS (2,097,061).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-MARGIN              BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     CALL "BU-PACKED-LENGTH" USING WS-BITS WS-MAX WS-SECTION
     CALL "BU-SAFETY-MARGIN" USING WS-MARGIN
     COMPUTE L-VALUE = WS-SECTION - WS-MARGIN
     GOBACK.
 END PROGRAM BU-MAX-CHUNK-COORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-CHUNK-VALID.
*> USING chunk x, chunk z, valid out (BINARY-LONG): ChunkPos.isValid, 1 when the larger absolute chunk coordinate is at
*> most the maximum chunk coordinate value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-VALID.
     CALL "BU-MAX-CHUNK-COORD" USING WS-MAX
     COMPUTE WS-A = FUNCTION ABS(L-CX)
     COMPUTE WS-B = FUNCTION ABS(L-CZ)
     IF WS-B > WS-A
         MOVE WS-B TO WS-A
     END-IF
     MOVE 0 TO L-VALID
     IF WS-A <= WS-MAX
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM BU-CHUNK-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-VALID-BOUNDS.
*> USING minimum y, height, x, y, z, valid out (BINARY-LONG): Level.isInValidBounds, 1 when y is inside the build height
*> (minimum y to minimum y + height - 1) and the chunk coordinates of x and z pass ChunkPos.isValid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN-Y L-HEIGHT L-X L-Y L-Z L-VALID.
     MOVE 0 TO L-VALID
     COMPUTE WS-TOP = L-MIN-Y + L-HEIGHT
     IF L-Y < L-MIN-Y OR L-Y >= WS-TOP
         GOBACK
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "BU-CHUNK-VALID" USING WS-CX WS-CZ L-VALID
     GOBACK.
 END PROGRAM BU-VALID-BOUNDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-WORLD-BOUNDS.
*> USING x, z, inside out (BINARY-LONG): Level.isInWorldBounds horizontally, 1 when both are at least -30000000 and
*> strictly below 30000000.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-INSIDE.
     MOVE 0 TO L-INSIDE
     IF L-X >= -30000000 AND L-X < 30000000 AND L-Z >= -30000000 AND L-Z < 30000000
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM BU-WORLD-BOUNDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-ENSURE.
*> No parameters: sets the defaults of BUSTATE.cpy once (the chained-update limit 1,000,000 of 29 section 3.3, empty queues).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 PROCEDURE DIVISION.
     IF BU-READY = 0
         MOVE 1 TO BU-READY
         MOVE 1000000 TO BU-CHAINED-LIMIT
         MOVE 0 TO BU-COUNT BU-SKIPPED BU-STACK-SIZE BU-ADDED-SIZE BU-RULE-COUNT BU-TRACE-LENGTH BU-TRACE-ON
     END-IF
     GOBACK.
 END PROGRAM BU-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-RESET-TRACE.
*> No parameters: empties BU-TRACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 PROCEDURE DIVISION.
     MOVE 0 TO BU-TRACE-LENGTH
     GOBACK.
 END PROGRAM BU-RESET-TRACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-RULES-CLEAR.
*> No parameters: removes every hook rule.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 PROCEDURE DIVISION.
     MOVE 0 TO BU-RULE-COUNT
     GOBACK.
 END PROGRAM BU-RULES-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-RULE-ADD.
*> USING kind, block id (-1 = every block), effect, state, flags (BINARY-LONG): appends a hook rule (BUSTATE.cpy). A rule
*> beyond BU-MAX-RULES is not kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-EFFECT               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BLOCK L-EFFECT L-STATE L-FLAGS.
     CALL "BU-ENSURE"
     IF BU-RULE-COUNT < BU-MAX-RULES
         ADD 1 TO BU-RULE-COUNT
         MOVE L-KIND TO BU-R-KIND(BU-RULE-COUNT)
         MOVE L-BLOCK TO BU-R-BLOCK(BU-RULE-COUNT)
         MOVE L-EFFECT TO BU-R-EFFECT(BU-RULE-COUNT)
         MOVE L-STATE TO BU-R-STATE(BU-RULE-COUNT)
         MOVE L-FLAGS TO BU-R-FLAGS(BU-RULE-COUNT)
     END-IF
     GOBACK.
 END PROGRAM BU-RULE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-MARKED.
*> USING kind, state, marked out (BINARY-LONG): 1 when a rule of that kind (the markers 5 redstone wire and 6 comparator)
*> names the block of the state (or every block).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MARKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-STATE L-MARKED.
     MOVE 0 TO L-MARKED
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BU-RULE-COUNT
         IF BU-R-KIND(WS-I) = L-KIND AND (BU-R-BLOCK(WS-I) = -1 OR BU-R-BLOCK(WS-I) = WS-BLOCK)
             MOVE 1 TO L-MARKED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BU-MARKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-DIRECTION.
*> USING direction, dx, dy, dz (BINARY-LONG): the step of a Direction ordinal: 0 down (0, -1, 0), 1 up, 2 north (0, 0, -1),
*> 3 south, 4 west (-1, 0, 0), 5 east.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     EVALUATE L-DIR
         WHEN 0
             MOVE -1 TO L-DY
         WHEN 1
             MOVE 1 TO L-DY
         WHEN 2
             MOVE -1 TO L-DZ
         WHEN 3
             MOVE 1 TO L-DZ
         WHEN 4
             MOVE -1 TO L-DX
         WHEN OTHER
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM BU-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-ORDER.
*> USING kind, index (1 to 6), direction out (BINARY-LONG): the direction at that place of an update order (29 section 3.1).
*> Kind 1 is NeighborUpdater.UPDATE_ORDER (west, east, down, up, north, south); kind 2 is
*> BlockBehaviour.UPDATE_SHAPE_ORDER (west, east, north, south, down, up).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEIGHBOUR-ORDER     PIC X(6) VALUE "450123".
 01 WS-SHAPE-ORDER         PIC X(6) VALUE "452301".
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-INDEX L-DIR.
     IF L-KIND = 1
         MOVE WS-NEIGHBOUR-ORDER(L-INDEX:1) TO WS-DIGIT
     ELSE
         MOVE WS-SHAPE-ORDER(L-INDEX:1) TO WS-DIGIT
     END-IF
     MOVE WS-DIGIT TO L-DIR
     GOBACK.
 END PROGRAM BU-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-TRACE-PUT.
*> USING letter (PIC X), x, y, z, state, a, b (BINARY-LONG): appends one entry to BU-TRACE while BU-TRACE-ON is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-LETTER               PIC X.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-LETTER L-X L-Y L-Z L-STATE L-A L-B.
     IF BU-TRACE-ON = 1
         MOVE L-X TO WS-E1
         MOVE L-Y TO WS-E2
         MOVE L-Z TO WS-E3
         MOVE L-STATE TO WS-E4
         MOVE L-A TO WS-E5
         MOVE L-B TO WS-E6
         COMPUTE WS-PTR = BU-TRACE-LENGTH + 1
         STRING L-LETTER " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
             FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) ";" DELIMITED BY SIZE
             INTO BU-TRACE WITH POINTER WS-PTR
         COMPUTE BU-TRACE-LENGTH = WS-PTR - 1
     END-IF
     GOBACK.
 END PROGRAM BU-TRACE-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-HOOK RECURSIVE.
*> USING kind, dimension row, x, y, z, state, a, b, out state (BINARY-LONG): the block hooks of 29 sections 2 and 3. Kind 1
*> onPlace (state = the new state, a = the old state, b = moved by piston), 2 affectNeighborsAfterRemoval (state = the old
*> state, a = the new state, b = moved), 3 neighborChanged (state = the receiver's state, a = the source block, b = moved),
*> 4 updateShape (state = the receiver's state, a = the direction towards the neighbour, b = the neighbour's state; out =
*> the state the receiver becomes), 7 scheduled block tick (state = the state at the position, a = the block id), 8 random tick,
*> 9 scheduled fluid tick (state = the fluid id), 10 block event (a, b = the event parameters; out = 1 when handled), 11 random
*> tick of the fluid. The default does nothing (out = state); the per-block overrides of the family documents
*> are the rules of BUSTATE.cpy, and every call is recorded in BU-TRACE when it is on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 COPY CBLOCKS.
 01 WS-LETTERS             PIC X(11) VALUE "PRNS..TGFEH".
 01 WS-SCHEDULE-TYPE       BINARY-LONG VALUE 1.
 01 WS-NORMAL              BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-LETTER              PIC X.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG.
 01 LS-NEXT-A              BINARY-LONG.
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
     MOVE L-STATE TO L-OUT
     IF L-KIND = 10
         MOVE 0 TO L-OUT
     END-IF
     MOVE WS-LETTERS(L-KIND:1) TO LS-LETTER
     CALL "BU-TRACE-PUT" USING LS-LETTER L-X L-Y L-Z L-STATE L-A L-B
     IF L-KIND = 1 OR L-KIND = 3 OR L-KIND = 4 OR L-KIND = 9
         CALL "FLUID-HOOK" USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT
     END-IF
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE 512 TO LS-BUDGET
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > BU-RULE-COUNT
         IF BU-R-KIND(LS-I) = L-KIND AND (BU-R-BLOCK(LS-I) = -1 OR BU-R-BLOCK(LS-I) = LS-BLOCK)
             IF BU-R-EFFECT(LS-I) = 1
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z BU-R-STATE(LS-I) BU-R-FLAGS(LS-I) LS-BUDGET
                     LS-RESULT
             END-IF
             IF BU-R-EFFECT(LS-I) = 2
                 MOVE BU-R-STATE(LS-I) TO L-OUT
             END-IF
             IF BU-R-EFFECT(LS-I) = 4
                 MOVE 1 TO L-OUT
             END-IF
             IF BU-R-EFFECT(LS-I) = 5 AND L-A < BU-R-FLAGS(LS-I)
                 COMPUTE LS-NEXT-A = L-A + 1
                 CALL "BE-ADD" USING L-DIM L-X L-Y L-Z LS-BLOCK LS-NEXT-A L-B
             END-IF
             IF BU-R-EFFECT(LS-I) = 6
                 CALL "GB-FALL-TICK" USING L-DIM L-X L-Y L-Z
             END-IF
             IF BU-R-EFFECT(LS-I) = 7
                 CALL "GB-CROP-RT" USING L-DIM L-X L-Y L-Z
             END-IF
             IF BU-R-EFFECT(LS-I) = 8
                 CALL "GB-SAPLING-RT" USING L-DIM L-X L-Y L-Z
             END-IF
             IF BU-R-EFFECT(LS-I) = 3
                 CALL "BT-SCHEDULE" USING L-DIM WS-SCHEDULE-TYPE LS-BLOCK L-X L-Y L-Z BU-R-FLAGS(LS-I) WS-NORMAL
                     LS-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BU-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-BROADCAST.
*> USING dimension row, x, y, z, excluded player row (0 = none) (BINARY-LONG), PB-BUFFER: PlayerList.broadcast (29 section 2.3): the
*> packet to every player of the dimension whose feet are strictly less than 64.0 blocks from the block corner (x, y, z), except
*> the excluded player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EXCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EXCLUDED PB-BUFFER.
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0 AND PL-DIM(WS-PLAYER) = L-DIM
                 AND WS-PLAYER NOT = L-EXCLUDED
             COMPUTE WS-DX = L-X - PL-X(WS-PLAYER)
             COMPUTE WS-DY = L-Y - PL-Y(WS-PLAYER)
             COMPUTE WS-DZ = L-Z - PL-Z(WS-PLAYER)
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4096
                 CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LEVEL-BROADCAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-EVENT.
*> USING dimension row, event id, x, y, z, data, excluded player row (0 = none) (BINARY-LONG): ServerLevel.levelEvent (29
*> section 2.3): a Level Event (0x2F, global false) broadcast within 64.0 of the block corner (LEVEL-BROADCAST).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 47.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 01 L-EXCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-EVENT L-X L-Y L-Z L-DATA L-EXCLUDED.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LEVEL-EVENT" USING PB-BUFFER L-EVENT L-X L-Y L-Z L-DATA WS-FALSE
     CALL "LEVEL-BROADCAST" USING L-DIM L-X L-Y L-Z L-EXCLUDED PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM LEVEL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-UPD-STEP RECURSIVE.
*> USING stack index, more out (BINARY-LONG): the runNext of the entry at that place of the stack (29 section 3.3). A multi
*> entry notifies one neighbour in UPDATE_ORDER, reading its state now, then moves past the skipped direction; a simple
*> entry reads the state at its position; a full entry uses the state it carries; a shape entry is 3.2's executeShapeUpdate.
*> More is 1 only for a multi entry with neighbours left.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-3                   BINARY-LONG VALUE 3.
 01 K-4                   BINARY-LONG VALUE 4.
 01 K-5                   BINARY-LONG VALUE 5.
 COPY BUSTATE.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-DIM                 BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-MOVED               BINARY-LONG.
 01 LS-WIRE                BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-ORDER-KIND          BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-DROP                BINARY-LONG.
 01 LS-RESULT              BINARY-LONG.
 01 LS-LOW                 BINARY-LONG.
 01 LS-HIGH                BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-DUMMY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MORE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MORE.
     MOVE 0 TO L-MORE
     MOVE BU-S-KIND(L-INDEX) TO LS-KIND
     MOVE BU-S-DIM(L-INDEX) TO LS-DIM
     MOVE BU-S-X(L-INDEX) TO LS-X
     MOVE BU-S-Y(L-INDEX) TO LS-Y
     MOVE BU-S-Z(L-INDEX) TO LS-Z
     MOVE BU-S-BLOCK(L-INDEX) TO LS-BLOCK
     EVALUATE LS-KIND
         WHEN 1
             MOVE 1 TO LS-ORDER-KIND
             COMPUTE LS-INDEX = BU-S-INDEX(L-INDEX) + 1
             CALL "BU-ORDER" USING LS-ORDER-KIND LS-INDEX LS-DIR
             CALL "BU-DIRECTION" USING LS-DIR LS-DX LS-DY LS-DZ
             COMPUTE LS-X = LS-X + LS-DX
             COMPUTE LS-Y = LS-Y + LS-DY
             COMPUTE LS-Z = LS-Z + LS-DZ
             CALL "WORLD-GET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-STATE
             ADD 1 TO BU-S-INDEX(L-INDEX)
             IF BU-S-INDEX(L-INDEX) < 6
                 COMPUTE LS-INDEX = BU-S-INDEX(L-INDEX) + 1
                 CALL "BU-ORDER" USING LS-ORDER-KIND LS-INDEX LS-DIR
                 IF LS-DIR = BU-S-SKIP(L-INDEX)
                     ADD 1 TO BU-S-INDEX(L-INDEX)
                 END-IF
             END-IF
             IF BU-S-INDEX(L-INDEX) < 6
                 MOVE 1 TO L-MORE
             END-IF
             MOVE 0 TO LS-MOVED
             CALL "BU-HOOK" USING K-3 LS-DIM LS-X LS-Y LS-Z LS-STATE LS-BLOCK LS-MOVED LS-NEW
         WHEN 2
             CALL "WORLD-GET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-STATE
             MOVE 0 TO LS-MOVED
             CALL "BU-HOOK" USING K-3 LS-DIM LS-X LS-Y LS-Z LS-STATE LS-BLOCK LS-MOVED LS-NEW
         WHEN 3
             MOVE BU-S-STATE(L-INDEX) TO LS-STATE
             MOVE BU-S-MOVED(L-INDEX) TO LS-MOVED
             CALL "BU-HOOK" USING K-3 LS-DIM LS-X LS-Y LS-Z LS-STATE LS-BLOCK LS-MOVED LS-NEW
         WHEN OTHER
             MOVE BU-S-FLAGS(L-INDEX) TO LS-FLAGS
             MOVE BU-S-BUDGET(L-INDEX) TO LS-BUDGET
             MOVE BU-S-DIR(L-INDEX) TO LS-DIR
             MOVE BU-S-STATE(L-INDEX) TO LS-NSTATE
             CALL "WORLD-GET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-STATE
             COMPUTE LS-HIGH = FUNCTION MOD(LS-FLAGS, 256) - FUNCTION MOD(LS-FLAGS, 128)
             MOVE 0 TO LS-WIRE
             IF LS-HIGH > 0
                 CALL "BU-MARKED" USING K-5 LS-STATE LS-WIRE
             END-IF
             IF LS-WIRE = 0
                 CALL "BU-HOOK" USING K-4 LS-DIM LS-X LS-Y LS-Z LS-STATE LS-DIR LS-NSTATE LS-NEW
                 EVALUATE TRUE
                     WHEN LS-NEW = LS-STATE
                         CONTINUE
                     WHEN LS-NEW = 0
                         COMPUTE LS-LOW = FUNCTION MOD(LS-FLAGS, 64) - FUNCTION MOD(LS-FLAGS, 32)
                         MOVE 1 TO LS-DROP
                         IF LS-LOW > 0
                             MOVE 0 TO LS-DROP
                         END-IF
                         CALL "LEVEL-DESTROY-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-DROP LS-BUDGET LS-RESULT
                     WHEN OTHER
                         COMPUTE LS-LOW = FUNCTION MOD(LS-FLAGS, 64) - FUNCTION MOD(LS-FLAGS, 32)
                         COMPUTE LS-FLAGS = LS-FLAGS - LS-LOW
                         CALL "LEVEL-SET-BLOCK" USING LS-DIM LS-X LS-Y LS-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 END-EVALUATE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BU-UPD-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-UPD-RUN RECURSIVE.
*> No parameters: runUpdates of 29 section 3.3. While the stack or the entries added this layer are not empty: push the added
*> entries in reverse order (the first added ends on top), then run the top entry until it is finished (popped) or has added
*> entries. Finally the count is back to 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-TOP                 BINARY-LONG.
 01 LS-MORE                BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM UNTIL BU-STACK-SIZE = 0 AND BU-ADDED-SIZE = 0
         PERFORM VARYING LS-I FROM BU-ADDED-SIZE BY -1 UNTIL LS-I < 1
             ADD 1 TO BU-STACK-SIZE
             MOVE BU-ADDED(LS-I) TO BU-STACK(BU-STACK-SIZE)
         END-PERFORM
         MOVE 0 TO BU-ADDED-SIZE
         MOVE BU-STACK-SIZE TO LS-TOP
         PERFORM UNTIL BU-ADDED-SIZE > 0
             CALL "BU-UPD-STEP" USING LS-TOP LS-MORE
             IF LS-MORE = 0
                 SUBTRACT 1 FROM BU-STACK-SIZE
                 EXIT PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO BU-COUNT
     GOBACK.
 END PROGRAM BU-UPD-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-UPD-ADD RECURSIVE.
*> USING entry (BUENTRY.cpy layout): addAndRun of 29 section 3.3. The entry is nested when an update already runs
*> (BU-COUNT above 0). It is dropped when the chained-update limit is not negative and the count has reached it (the first
*> skipped position is kept); otherwise it goes to the entries added this layer when nested, else on the stack. A call that
*> was not nested runs the updates.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-NESTED              BINARY-LONG.
 01 LS-OVER                BINARY-LONG.
 01 LS-BEFORE              BINARY-LONG.
 LINKAGE SECTION.
 COPY BUENTRY.
 PROCEDURE DIVISION USING E-ENTRY.
     CALL "BU-ENSURE"
     MOVE 0 TO LS-NESTED LS-OVER
     IF BU-COUNT > 0
         MOVE 1 TO LS-NESTED
     END-IF
     IF BU-CHAINED-LIMIT >= 0 AND BU-COUNT >= BU-CHAINED-LIMIT
         MOVE 1 TO LS-OVER
     END-IF
     MOVE BU-COUNT TO LS-BEFORE
     ADD 1 TO BU-COUNT
     IF LS-OVER = 1
         ADD 1 TO BU-SKIPPED
         IF LS-BEFORE = BU-CHAINED-LIMIT
             MOVE E-X TO BU-FIRST-SKIPPED-X
             MOVE E-Y TO BU-FIRST-SKIPPED-Y
             MOVE E-Z TO BU-FIRST-SKIPPED-Z
         END-IF
     ELSE
         IF LS-NESTED = 1
             ADD 1 TO BU-ADDED-SIZE
             MOVE E-ENTRY TO BU-ADDED(BU-ADDED-SIZE)
         ELSE
             ADD 1 TO BU-STACK-SIZE
             MOVE E-ENTRY TO BU-STACK(BU-STACK-SIZE)
         END-IF
     END-IF
     IF LS-NESTED = 0
         CALL "BU-UPD-RUN"
     END-IF
     GOBACK.
 END PROGRAM BU-UPD-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-NEIGHBORS-EXCEPT RECURSIVE.
*> USING dimension row, x, y, z, source block, skipped direction (-1 = none) (BINARY-LONG): updateNeighborsAtExceptFromFacing,
*> one multi entry in the updater (29 sections 3.1 and 3.3). Its index starts past the skipped direction when that is first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 LOCAL-STORAGE SECTION.
 01 LS-KIND                BINARY-LONG.
 01 LS-INDEX               BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 COPY BUENTRY.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK L-SKIP.
     INITIALIZE E-ENTRY
     MOVE 1 TO E-KIND
     MOVE L-DIM TO E-DIM
     MOVE L-X TO E-X
     MOVE L-Y TO E-Y
     MOVE L-Z TO E-Z
     MOVE L-BLOCK TO E-BLOCK
     MOVE L-SKIP TO E-SKIP
     MOVE 0 TO E-INDEX
     MOVE 1 TO LS-KIND
     MOVE 1 TO LS-INDEX
     CALL "BU-ORDER" USING LS-KIND LS-INDEX LS-DIR
     IF LS-DIR = L-SKIP
         MOVE 1 TO E-INDEX
     END-IF
     CALL "BU-UPD-ADD" USING E-ENTRY
     GOBACK.
 END PROGRAM BU-NEIGHBORS-EXCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-NEIGHBORS-AT RECURSIVE.
*> USING dimension row, x, y, z, source block (BINARY-LONG): updateNeighborsAt, the except form with nothing skipped.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-NONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     MOVE -1 TO LS-NONE
     CALL "BU-NEIGHBORS-EXCEPT" USING L-DIM L-X L-Y L-Z L-BLOCK LS-NONE
     GOBACK.
 END PROGRAM BU-NEIGHBORS-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-NEIGHBOR-SIMPLE RECURSIVE.
*> USING dimension row, x, y, z, source block (BINARY-LONG): a simple entry, neighborChanged on the block at the position
*> (its state read when the entry runs, moved by piston false).
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 COPY BUENTRY.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     INITIALIZE E-ENTRY
     MOVE 2 TO E-KIND
     MOVE L-DIM TO E-DIM
     MOVE L-X TO E-X
     MOVE L-Y TO E-Y
     MOVE L-Z TO E-Z
     MOVE L-BLOCK TO E-BLOCK
     CALL "BU-UPD-ADD" USING E-ENTRY
     GOBACK.
 END PROGRAM BU-NEIGHBOR-SIMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-NEIGHBOR-FULL RECURSIVE.
*> USING dimension row, x, y, z, source block, receiver state, moved (BINARY-LONG): a full entry, neighborChanged with the
*> state and the moved-by-piston flag it carries.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 COPY BUENTRY.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK L-STATE L-MOVED.
     INITIALIZE E-ENTRY
     MOVE 3 TO E-KIND
     MOVE L-DIM TO E-DIM
     MOVE L-X TO E-X
     MOVE L-Y TO E-Y
     MOVE L-Z TO E-Z
     MOVE L-BLOCK TO E-BLOCK
     MOVE L-STATE TO E-STATE
     MOVE L-MOVED TO E-MOVED
     CALL "BU-UPD-ADD" USING E-ENTRY
     GOBACK.
 END PROGRAM BU-NEIGHBOR-FULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-SHAPE-UPDATES RECURSIVE.
*> USING dimension row, x, y, z, state, flags, budget (BINARY-LONG): BlockState.updateNeighbourShapes (29 section 3.2): for
*> each direction of UPDATE_SHAPE_ORDER a shape entry for the receiver there, with the opposite direction (the receiver's view
*> towards the changed block), this position as the neighbour, the state, the flags and the budget.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 COPY BUENTRY.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-FLAGS L-BUDGET.
     MOVE 2 TO LS-KIND
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 6
         CALL "BU-ORDER" USING LS-KIND LS-I LS-DIR
         CALL "BU-DIRECTION" USING LS-DIR LS-DX LS-DY LS-DZ
         INITIALIZE E-ENTRY
         MOVE 4 TO E-KIND
         MOVE L-DIM TO E-DIM
         COMPUTE E-X = L-X + LS-DX
         COMPUTE E-Y = L-Y + LS-DY
         COMPUTE E-Z = L-Z + LS-DZ
         COMPUTE E-DIR = LS-DIR + 1 - 2 * FUNCTION MOD(LS-DIR, 2)
         MOVE L-X TO E-NX
         MOVE L-Y TO E-NY
         MOVE L-Z TO E-NZ
         MOVE L-STATE TO E-STATE
         MOVE L-FLAGS TO E-FLAGS
         MOVE L-BUDGET TO E-BUDGET
         CALL "BU-UPD-ADD" USING E-ENTRY
     END-PERFORM
     GOBACK.
 END PROGRAM BU-SHAPE-UPDATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-UPDATE-FROM-SHAPES RECURSIVE.
*> USING dimension row, x, y, z, state, state out (BINARY-LONG): Block.updateFromNeighbourShapes (29 section 3.2): for each
*> direction of UPDATE_SHAPE_ORDER the state becomes updateShape with that direction (towards the neighbour, not the receiver's
*> view) and the neighbour's current state; the final state is returned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-4                   BINARY-LONG VALUE 4.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-NSTATE              BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-CURRENT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OUT.
     MOVE L-STATE TO LS-CURRENT
     MOVE 2 TO LS-KIND
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 6
         CALL "BU-ORDER" USING LS-KIND LS-I LS-DIR
         CALL "BU-DIRECTION" USING LS-DIR LS-DX LS-DY LS-DZ
         COMPUTE LS-X = L-X + LS-DX
         COMPUTE LS-Y = L-Y + LS-DY
         COMPUTE LS-Z = L-Z + LS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM LS-X LS-Y LS-Z LS-NSTATE
         CALL "BU-HOOK" USING K-4 L-DIM L-X L-Y L-Z LS-CURRENT LS-DIR LS-NSTATE LS-NEW
         MOVE LS-NEW TO LS-CURRENT
     END-PERFORM
     MOVE LS-CURRENT TO L-OUT
     GOBACK.
 END PROGRAM BU-UPDATE-FROM-SHAPES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BU-OUTPUT-SIGNAL RECURSIVE.
*> USING dimension row, x, y, z, source block (BINARY-LONG): updateNeighbourForOutputSignal (29 section 3.4). For north, east,
*> south, west: the neighbour is skipped when its chunk is not loaded; a comparator there is told directly; otherwise a
*> redstone conductor (solid and opaque) there passes the notice to a comparator right behind it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-6                   BINARY-LONG VALUE 6.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-X2                  BINARY-LONG.
 01 LS-Z2                  BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-STATE2              BINARY-LONG.
 01 LS-MARK                BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-DIRECTIONS          PIC X(4) VALUE "2354".
 01 LS-DIGIT               PIC 9.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK.
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > 4
         MOVE LS-DIRECTIONS(LS-I:1) TO LS-DIGIT
         MOVE LS-DIGIT TO LS-DIR
         CALL "BU-DIRECTION" USING LS-DIR LS-DX LS-DY LS-DZ
         COMPUTE LS-X = L-X + LS-DX
         COMPUTE LS-Y = L-Y
         COMPUTE LS-Z = L-Z + LS-DZ
         COMPUTE LS-CX = (LS-X - FUNCTION MOD(LS-X, 16)) / 16
         COMPUTE LS-CZ = (LS-Z - FUNCTION MOD(LS-Z, 16)) / 16
         CALL "WORLD-FIND" USING L-DIM LS-CX LS-CZ LS-ROW
         IF LS-ROW > 0
             CALL "WORLD-GET-BLOCK" USING L-DIM LS-X LS-Y LS-Z LS-STATE
             CALL "BU-MARKED" USING K-6 LS-STATE LS-MARK
             IF LS-MARK = 1
                 CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM LS-X LS-Y LS-Z L-BLOCK
             ELSE
                 MOVE CB-S-BLOCK(LS-STATE + 1) TO LS-BLOCK
                 COMPUTE LS-X2 = LS-X + LS-DX
                 COMPUTE LS-Z2 = LS-Z + LS-DZ
                 COMPUTE LS-CX = (LS-X2 - FUNCTION MOD(LS-X2, 16)) / 16
                 COMPUTE LS-CZ = (LS-Z2 - FUNCTION MOD(LS-Z2, 16)) / 16
                 CALL "WORLD-FIND" USING L-DIM LS-CX LS-CZ LS-ROW
                 IF CB-SOLID(LS-BLOCK + 1) = 1 AND CB-OPAQUE(LS-BLOCK + 1) = 1 AND LS-ROW > 0
                     CALL "WORLD-GET-BLOCK" USING L-DIM LS-X2 LS-Y LS-Z2 LS-STATE2
                     CALL "BU-MARKED" USING K-6 LS-STATE2 LS-MARK
                     IF LS-MARK = 1
                         CALL "BU-NEIGHBOR-SIMPLE" USING L-DIM LS-X2 LS-Y LS-Z2 L-BLOCK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BU-OUTPUT-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-SET-BLOCK RECURSIVE.
*> USING dimension row, x, y, z, state, flags, budget, result out (BINARY-LONG): Level.setBlock (29 sections 2.1 and 2.2).
*> Result 0 (false) for a position outside the valid bounds, a state that is already there, or a removal hook that replaced
*> the block; otherwise 1. Steps: the chunk write (the world and its light; WORLD-SET-BLOCK through LIGHT-SET-BLOCK), the
*> removal hook of the old state when the block differs and flag 1 or 64 is set, the onPlace hook unless flag 512 is set; when
*> a hook replaced the block, stop there with true; flag 2 records the position in the change set (BC-MARK, sent by BC-BROADCAST); flag 1 tells the neighbours
*> with the OLD block as source; unless flag 16 is set and while the budget is above 0, the shape updates run with the flags
*> minus bits 0 and 5 and the budget minus 1. Block entities, heightmaps and the analog-output notice are not part of this
*> world (29 section 12 and 3.4 with the comparator rules).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-1                   BINARY-LONG VALUE 1.
 01 K-2                   BINARY-LONG VALUE 2.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-VALID               BINARY-LONG.
 01 LS-OLD                 BINARY-LONG.
 01 LS-NOW                 BINARY-LONG.
 01 LS-MOVED               BINARY-LONG.
 01 LS-OLD-BLOCK           BINARY-LONG.
 01 LS-NEW-BLOCK           BINARY-LONG.
 01 LS-BIT                 BINARY-LONG.
 01 LS-HOOK-OUT            BINARY-LONG.
 01 LS-SKIP                BINARY-LONG.
 01 LS-SHAPE-FLAGS         BINARY-LONG.
 01 LS-SHAPE-BUDGET        BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-LOW                 BINARY-LONG.
 01 LS-MARKED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-FLAGS L-BUDGET L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "BU-VALID-BOUNDS" USING DM-MIN-Y(L-DIM) DM-HEIGHT(L-DIM) L-X L-Y L-Z LS-VALID
     IF LS-VALID = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-OLD
     IF LS-OLD = L-STATE
         GOBACK
     END-IF
     CALL "LIGHT-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     MOVE CB-S-BLOCK(LS-OLD + 1) TO LS-OLD-BLOCK
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-NEW-BLOCK
     MOVE 0 TO LS-MOVED
     COMPUTE LS-BIT = FUNCTION MOD(L-FLAGS, 128) - FUNCTION MOD(L-FLAGS, 64)
     IF LS-BIT > 0
         MOVE 1 TO LS-MOVED
     END-IF
     COMPUTE LS-BIT = FUNCTION MOD(L-FLAGS, 2)
     IF LS-OLD-BLOCK NOT = LS-NEW-BLOCK AND (LS-BIT = 1 OR LS-MOVED = 1)
         CALL "BU-HOOK" USING K-2 L-DIM L-X L-Y L-Z LS-OLD L-STATE LS-MOVED LS-HOOK-OUT
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NOW
         IF LS-NOW NOT = L-STATE
             GOBACK
         END-IF
     END-IF
     COMPUTE LS-LOW = FUNCTION MOD(L-FLAGS, 1024) - FUNCTION MOD(L-FLAGS, 512)
     IF LS-LOW = 0
         CALL "BU-HOOK" USING K-1 L-DIM L-X L-Y L-Z L-STATE LS-OLD LS-MOVED LS-HOOK-OUT
     END-IF
     MOVE 1 TO L-RESULT
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NOW
     IF LS-NOW NOT = L-STATE
         GOBACK
     END-IF
     COMPUTE LS-LOW = FUNCTION MOD(L-FLAGS, 4) - FUNCTION MOD(L-FLAGS, 2)
     IF LS-LOW > 0
         CALL "BC-MARK" USING L-DIM L-X L-Y L-Z LS-MARKED
     END-IF
     IF LS-BIT = 1
         MOVE -1 TO LS-SKIP
         CALL "BU-NEIGHBORS-EXCEPT" USING L-DIM L-X L-Y L-Z LS-OLD-BLOCK LS-SKIP
     END-IF
     COMPUTE LS-LOW = FUNCTION MOD(L-FLAGS, 32) - FUNCTION MOD(L-FLAGS, 16)
     IF LS-LOW = 0 AND L-BUDGET > 0
         CALL "BU-SHAPE-FLAGS" USING L-FLAGS LS-SHAPE-FLAGS
         COMPUTE LS-SHAPE-BUDGET = L-BUDGET - 1
         CALL "BU-SHAPE-UPDATES" USING L-DIM L-X L-Y L-Z L-STATE LS-SHAPE-FLAGS LS-SHAPE-BUDGET
     END-IF
     GOBACK.
 END PROGRAM LEVEL-SET-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-REMOVE-BLOCK RECURSIVE.
*> USING dimension row, x, y, z, moved, result out (BINARY-LONG): Level.removeBlock (29 section 2.2): the position becomes the
*> fluid's block (air: this world has no fluid state here yet) with flags 3, plus 64 for a piston move, budget 512.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG.
 01 LS-AIR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-MOVED L-RESULT.
     MOVE 3 TO LS-FLAGS
     IF L-MOVED NOT = 0
         MOVE 67 TO LS-FLAGS
     END-IF
     MOVE 512 TO LS-BUDGET
     MOVE 0 TO LS-AIR
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-AIR LS-FLAGS LS-BUDGET L-RESULT
     GOBACK.
 END PROGRAM LEVEL-REMOVE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-DESTROY-BLOCK RECURSIVE.
*> USING dimension row, x, y, z, drop, budget, result out (BINARY-LONG): Level.destroyBlock (29 sections 2.2 and 10.6): air
*> returns 0; otherwise the destroy effect (level event 2001 with the old state's id, nobody excluded), the drops when asked
*> (the loot and item entities are the later sections 10.4 and 10.5; the argument is accepted), then the position becomes air
*> with flags 3 and the given budget; the result is that write's.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-OLD                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-AIR                 BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-NONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DROP                 BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DROP L-BUDGET L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z LS-OLD
     IF LS-OLD = 0
         GOBACK
     END-IF
     MOVE 2001 TO LS-EVENT
     MOVE 0 TO LS-NONE
     CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-OLD LS-NONE
     MOVE 3 TO LS-FLAGS
     MOVE 0 TO LS-AIR
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-AIR LS-FLAGS L-BUDGET L-RESULT
     GOBACK.
 END PROGRAM LEVEL-DESTROY-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-NEIGHBOURS-ON-SET.
*> USING dimension row, x, y, z, old state (BINARY-LONG): ServerLevel.updateNeighboursOnBlockSet (29 section 2.3): the old
*> state's removal hook only when its block differs from the block now there, then updateNeighborsAt with the new block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-2                   BINARY-LONG VALUE 2.
 COPY CBLOCKS.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MOVED               BINARY-LONG VALUE 0.
 01 WS-OUT                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OLD.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW
     MOVE CB-S-BLOCK(WS-NEW + 1) TO WS-BLOCK
     IF CB-S-BLOCK(L-OLD + 1) NOT = WS-BLOCK
         CALL "BU-HOOK" USING K-2 L-DIM L-X L-Y L-Z L-OLD WS-NEW WS-MOVED WS-OUT
     END-IF
     CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z WS-BLOCK
     GOBACK.
 END PROGRAM LEVEL-NEIGHBOURS-ON-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-HAS.
*> USING dimension row, type (1 block, 2 fluid), id, x, y, z, found out (BINARY-LONG): hasScheduledTick, 1 when a tick with that
*> identity (type, id and position; time and priority do not count) is pending (29 section 4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-ID L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE AND BT-T-ID(WS-I) = L-ID
                 AND BT-T-X(WS-I) = L-X AND BT-T-Y(WS-I) = L-Y AND BT-T-Z(WS-I) = L-Z
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-ADD.
*> USING dimension row, type, id, x, y, z, trigger time (BINARY-DOUBLE), priority, sub-tick order, result out (BINARY-LONG):
*> LevelChunkTicks.schedule: the tick is added only when its identity is not pending (the first schedule wins and keeps its
*> time); result 1 when added, 0 when ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TRIG                 BINARY-DOUBLE.
 01 L-PRIO                 BINARY-LONG.
 01 L-SUB                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-ID L-X L-Y L-Z L-TRIG L-PRIO L-SUB L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "BT-HAS" USING L-DIM L-TYPE L-ID L-X L-Y L-Z WS-FOUND
     IF WS-FOUND = 0
         ADD 1 TO BT-COUNT
         MOVE L-DIM TO BT-T-DIM(BT-COUNT)
         MOVE L-TYPE TO BT-T-TYPE(BT-COUNT)
         MOVE L-ID TO BT-T-ID(BT-COUNT)
         MOVE L-X TO BT-T-X(BT-COUNT)
         MOVE L-Y TO BT-T-Y(BT-COUNT)
         MOVE L-Z TO BT-T-Z(BT-COUNT)
         MOVE L-TRIG TO BT-T-TRIG(BT-COUNT)
         MOVE L-PRIO TO BT-T-PRIO(BT-COUNT)
         MOVE L-SUB TO BT-T-SUB(BT-COUNT)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-SCHEDULE.
*> USING dimension row, type, id, x, y, z, delay, priority, result out (BINARY-LONG): createTick and schedule (29 section 4.1):
*> the trigger time is the game time (CW-TICKS) plus the delay (no minimum, no cap), the sub-tick order is the level's counter
*> (taken, then raised, even when the tick turns out to be a duplicate). Result 1 when added, 0 when ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKTICK.
 01 WS-TRIG                BINARY-DOUBLE.
 01 WS-SUB                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-PRIO                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-ID L-X L-Y L-Z L-DELAY L-PRIO L-RESULT.
     COMPUTE WS-TRIG = CW-TICKS + L-DELAY
     MOVE BT-SUB-COUNT(L-DIM) TO WS-SUB
     ADD 1 TO BT-SUB-COUNT(L-DIM)
     CALL "BT-ADD" USING L-DIM L-TYPE L-ID L-X L-Y L-Z WS-TRIG L-PRIO WS-SUB L-RESULT
     GOBACK.
 END PROGRAM BT-SCHEDULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-HEAD.
*> USING dimension row, type, chunk x, chunk z, index out (BINARY-LONG): the head of one chunk's queue, the pending tick that
*> sorts first by DRAIN_ORDER (trigger time, then priority, then sub-tick order); 0 when the chunk holds none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BETTER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-CX L-CZ L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         COMPUTE WS-CX = (BT-T-X(WS-I) - FUNCTION MOD(BT-T-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (BT-T-Z(WS-I) - FUNCTION MOD(BT-T-Z(WS-I), 16)) / 16
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE AND WS-CX = L-CX AND WS-CZ = L-CZ
             MOVE 0 TO WS-BETTER
             IF L-INDEX = 0
                 MOVE 1 TO WS-BETTER
             ELSE
                 EVALUATE TRUE
                     WHEN BT-T-TRIG(WS-I) < BT-T-TRIG(L-INDEX)
                         MOVE 1 TO WS-BETTER
                     WHEN BT-T-TRIG(WS-I) > BT-T-TRIG(L-INDEX)
                         CONTINUE
                     WHEN BT-T-PRIO(WS-I) < BT-T-PRIO(L-INDEX)
                         MOVE 1 TO WS-BETTER
                     WHEN BT-T-PRIO(WS-I) > BT-T-PRIO(L-INDEX)
                         CONTINUE
                     WHEN BT-T-SUB(WS-I) < BT-T-SUB(L-INDEX)
                         MOVE 1 TO WS-BETTER
                 END-EVALUATE
             END-IF
             IF WS-BETTER = 1
                 MOVE WS-I TO L-INDEX
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-CHUNK-TICKS.
*> USING dimension row, chunk x, chunk z, ticking out (BINARY-LONG): shouldTickBlocksAt, 1 when a player of the dimension has the
*> chunk inside the view square (the block-ticking range of this core).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-TICKING.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO L-TICKING
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0 AND PL-DIM(WS-PLAYER) = L-DIM
                 AND FUNCTION ABS(L-CX - PL-CENTER-X(WS-PLAYER)) <= CS-VIEW-DISTANCE
                 AND FUNCTION ABS(L-CZ - PL-CENTER-Z(WS-PLAYER)) <= CS-VIEW-DISTANCE
             MOVE 1 TO L-TICKING
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-CHUNK-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-POLL.
*> USING index (BINARY-LONG): removes that pending tick (the table stays dense).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE BT-TICK(BT-COUNT) TO BT-TICK(L-INDEX)
     SUBTRACT 1 FROM BT-COUNT
     GOBACK.
 END PROGRAM BT-POLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-BEST-CHUNK.
*> USING dimension row, type, chunk count, chunks, best out, head out (BINARY-LONG): among the chunks flagged in (the containers
*> to tick) the one whose head sorts first by INTRA_TICK_DRAIN_ORDER (priority, then sub-tick order; time is ignored, every head
*> is due); its row in the table, 0 when none is flagged, and its head's index in the tick table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-J                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BETTER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-CHUNKS.
    05 L-CHUNK OCCURS 4096 TIMES.
       10 L-C-CX           BINARY-LONG.
       10 L-C-CZ           BINARY-LONG.
       10 L-C-IN           BINARY-LONG.
 01 L-BEST                 BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-COUNT L-CHUNKS L-BEST L-HEAD.
     MOVE 0 TO L-BEST L-HEAD
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-COUNT
         IF L-C-IN(WS-J) = 1
             CALL "BT-HEAD" USING L-DIM L-TYPE L-C-CX(WS-J) L-C-CZ(WS-J) WS-HEAD
             MOVE 0 TO WS-BETTER
             IF L-BEST = 0
                 MOVE 1 TO WS-BETTER
             ELSE
                 IF BT-T-PRIO(WS-HEAD) < BT-T-PRIO(L-HEAD)
                         OR (BT-T-PRIO(WS-HEAD) = BT-T-PRIO(L-HEAD) AND BT-T-SUB(WS-HEAD) < BT-T-SUB(L-HEAD))
                     MOVE 1 TO WS-BETTER
                 END-IF
             END-IF
             IF WS-BETTER = 1
                 MOVE WS-J TO L-BEST
                 MOVE WS-HEAD TO L-HEAD
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-BEST-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-DRAIN.
*> USING dimension row, type, maximum, run count out (BINARY-LONG): one call of LevelTicks.tick for one queue (29 section 4.3).
*> 1 Select the chunks whose head is due (trigger <= CW-TICKS) and that tick (BT-CHUNK-TICKS); the others wait. 2 Drain: while
*> fewer than the maximum are collected, take the chunk whose head has the smallest (priority, sub-tick order), poll that head
*> unconditionally, then keep polling the same chunk while room remains, its head is due, and the head does not sort after the
*> head of the best remaining chunk; a chunk with a due head and room left goes back. 4 Run the collected ticks in order: a block
*> tick whose block is still at its position calls the tick hook (BU-HOOK kind 7), else it is dropped; a fluid tick calls hook 9.
*> The run count is the number of hook calls.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKTICK.
 COPY CBLOCKS.
 01 K-7                    BINARY-LONG VALUE 7.
 01 K-9                    BINARY-LONG VALUE 9.
 01 WS-CHUNKS.
    05 WS-CHUNK OCCURS 4096 TIMES.
       10 WS-C-CX          BINARY-LONG.
       10 WS-C-CZ          BINARY-LONG.
       10 WS-C-IN          BINARY-LONG.
 01 WS-CHUNK-COUNT         BINARY-LONG.
 01 WS-RUN.
    05 WS-R OCCURS 32768 TIMES.
       10 WS-R-ID          BINARY-LONG.
       10 WS-R-X           BINARY-LONG.
       10 WS-R-Y           BINARY-LONG.
       10 WS-R-Z           BINARY-LONG.
 01 WS-RUN-COUNT           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-HEAD           BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-NEXT-HEAD           BINARY-LONG.
 01 WS-TICKING             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-OUT                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-RAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-MAX L-RAN.
     MOVE 0 TO L-RAN WS-CHUNK-COUNT WS-RUN-COUNT
*> Step 1: the distinct chunks of this queue; flagged in when their head is due and they tick.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE
             COMPUTE WS-CX = (BT-T-X(WS-I) - FUNCTION MOD(BT-T-X(WS-I), 16)) / 16
             COMPUTE WS-CZ = (BT-T-Z(WS-I) - FUNCTION MOD(BT-T-Z(WS-I), 16)) / 16
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-CHUNK-COUNT
                 IF WS-C-CX(WS-J) = WS-CX AND WS-C-CZ(WS-J) = WS-CZ
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-CHUNK-COUNT
                 MOVE WS-CX TO WS-C-CX(WS-CHUNK-COUNT)
                 MOVE WS-CZ TO WS-C-CZ(WS-CHUNK-COUNT)
                 MOVE 0 TO WS-C-IN(WS-CHUNK-COUNT)
                 CALL "BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
                 CALL "BT-CHUNK-TICKS" USING L-DIM WS-CX WS-CZ WS-TICKING
                 IF BT-T-TRIG(WS-HEAD) <= CW-TICKS AND WS-TICKING = 1
                     MOVE 1 TO WS-C-IN(WS-CHUNK-COUNT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
*> Step 2: drain.
     PERFORM UNTIL WS-RUN-COUNT >= L-MAX
         CALL "BT-BEST-CHUNK" USING L-DIM L-TYPE WS-CHUNK-COUNT WS-CHUNKS WS-BEST WS-BEST-HEAD
         IF WS-BEST = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-C-IN(WS-BEST)
         MOVE WS-C-CX(WS-BEST) TO WS-CX
         MOVE WS-C-CZ(WS-BEST) TO WS-CZ
         MOVE WS-BEST-HEAD TO WS-HEAD
         ADD 1 TO WS-RUN-COUNT
         MOVE BT-T-ID(WS-HEAD) TO WS-R-ID(WS-RUN-COUNT)
         MOVE BT-T-X(WS-HEAD) TO WS-R-X(WS-RUN-COUNT)
         MOVE BT-T-Y(WS-HEAD) TO WS-R-Y(WS-RUN-COUNT)
         MOVE BT-T-Z(WS-HEAD) TO WS-R-Z(WS-RUN-COUNT)
         CALL "BT-POLL" USING WS-HEAD
         PERFORM UNTIL WS-RUN-COUNT >= L-MAX
             CALL "BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
             IF WS-HEAD = 0
                 EXIT PERFORM
             END-IF
             IF BT-T-TRIG(WS-HEAD) > CW-TICKS
                 EXIT PERFORM
             END-IF
             CALL "BT-BEST-CHUNK" USING L-DIM L-TYPE WS-CHUNK-COUNT WS-CHUNKS WS-NEXT WS-NEXT-HEAD
             IF WS-NEXT > 0
                 IF BT-T-PRIO(WS-HEAD) > BT-T-PRIO(WS-NEXT-HEAD)
                         OR (BT-T-PRIO(WS-HEAD) = BT-T-PRIO(WS-NEXT-HEAD)
                             AND BT-T-SUB(WS-HEAD) > BT-T-SUB(WS-NEXT-HEAD))
                     EXIT PERFORM
                 END-IF
             END-IF
             ADD 1 TO WS-RUN-COUNT
             MOVE BT-T-ID(WS-HEAD) TO WS-R-ID(WS-RUN-COUNT)
             MOVE BT-T-X(WS-HEAD) TO WS-R-X(WS-RUN-COUNT)
             MOVE BT-T-Y(WS-HEAD) TO WS-R-Y(WS-RUN-COUNT)
             MOVE BT-T-Z(WS-HEAD) TO WS-R-Z(WS-RUN-COUNT)
             CALL "BT-POLL" USING WS-HEAD
         END-PERFORM
         CALL "BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
         IF WS-HEAD > 0 AND WS-RUN-COUNT < L-MAX
             IF BT-T-TRIG(WS-HEAD) <= CW-TICKS
                 MOVE 1 TO WS-C-IN(WS-BEST)
             END-IF
         END-IF
     END-PERFORM
*> Step 4: run the collected ticks in order.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-RUN-COUNT
         IF L-TYPE = 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-R-X(WS-I) WS-R-Y(WS-I) WS-R-Z(WS-I) WS-STATE
             IF CB-S-BLOCK(WS-STATE + 1) = WS-R-ID(WS-I)
                 CALL "BU-HOOK" USING K-7 L-DIM WS-R-X(WS-I) WS-R-Y(WS-I) WS-R-Z(WS-I) WS-STATE WS-R-ID(WS-I)
                     WS-ZERO WS-OUT
                 ADD 1 TO L-RAN
             END-IF
         ELSE
             CALL "BU-HOOK" USING K-9 L-DIM WS-R-X(WS-I) WS-R-Y(WS-I) WS-R-Z(WS-I) WS-R-ID(WS-I) WS-ZERO
                 WS-ZERO2 WS-OUT
             ADD 1 TO L-RAN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-DRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-TICK-LEVEL.
*> USING dimension row (BINARY-LONG): the level's tick queues for one game tick (33 section 2.1 step 6): blocks first, then fluids,
*> each with the limit of 65,536.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-MAX                 BINARY-LONG VALUE 65536.
 01 WS-RAN                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG VALUE 1.
 01 WS-FLUID               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "BT-DRAIN" USING L-DIM WS-BLOCK WS-MAX WS-RAN
     CALL "BT-DRAIN" USING L-DIM WS-FLUID WS-MAX WS-RAN
     GOBACK.
 END PROGRAM BT-TICK-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-PACK.
*> USING dimension row, chunk x, chunk z, type, list (BTSAVED.cpy): LevelChunkTicks.pack (29 section 4.2): the chunk's pending
*> ticks of that type as saved ticks sorted by sub-tick order, delay = trigger time - game time (CW-TICKS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ORDER.
    05 WS-IDX              BINARY-LONG OCCURS 256 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 COPY BTSAVED.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-TYPE BT-SAVED.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         COMPUTE WS-CX = (BT-T-X(WS-I) - FUNCTION MOD(BT-T-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (BT-T-Z(WS-I) - FUNCTION MOD(BT-T-Z(WS-I), 16)) / 16
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE AND WS-CX = L-CX AND WS-CZ = L-CZ
             ADD 1 TO WS-N
             MOVE WS-I TO WS-IDX(WS-N)
             PERFORM VARYING WS-J FROM WS-N BY -1 UNTIL WS-J < 2
                 MOVE WS-IDX(WS-J - 1) TO WS-KEEP
                 IF BT-T-SUB(WS-KEEP) > BT-T-SUB(WS-IDX(WS-J))
                     MOVE WS-IDX(WS-J) TO WS-IDX(WS-J - 1)
                     MOVE WS-KEEP TO WS-IDX(WS-J)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-N TO BT-SV-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-IDX(WS-I) TO WS-J
         MOVE BT-T-X(WS-J) TO BT-SV-X(WS-I)
         MOVE BT-T-Y(WS-J) TO BT-SV-Y(WS-I)
         MOVE BT-T-Z(WS-J) TO BT-SV-Z(WS-I)
         MOVE BT-T-ID(WS-J) TO BT-SV-ID(WS-I)
         COMPUTE BT-SV-DELAY(WS-I) = BT-T-TRIG(WS-J) - CW-TICKS
         MOVE BT-T-PRIO(WS-J) TO BT-SV-PRIO(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM BT-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-UNPACK.
*> USING dimension row, chunk x, chunk z, type, list (BTSAVED.cpy): the chunk reader and LevelChunkTicks.unpack (29 sections 4.2 and
*> 4.5): saved ticks whose position is not in the chunk are dropped (filterTickListForChunk); the others become ticks with
*> trigger time = game time + delay and sub-tick orders -size, -size + 1, ..., -1 in list order (size = the kept count), so
*> reloaded ticks sort before every tick scheduled later at the same time and priority.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-TRIG                BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 COPY BTSAVED.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-TYPE BT-SAVED.
     MOVE 0 TO WS-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-SV-COUNT
         COMPUTE WS-CX = (BT-SV-X(WS-I) - FUNCTION MOD(BT-SV-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (BT-SV-Z(WS-I) - FUNCTION MOD(BT-SV-Z(WS-I), 16)) / 16
         IF WS-CX = L-CX AND WS-CZ = L-CZ
             ADD 1 TO WS-KEPT
         END-IF
     END-PERFORM
     COMPUTE WS-SUB = 0 - WS-KEPT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-SV-COUNT
         COMPUTE WS-CX = (BT-SV-X(WS-I) - FUNCTION MOD(BT-SV-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (BT-SV-Z(WS-I) - FUNCTION MOD(BT-SV-Z(WS-I), 16)) / 16
         IF WS-CX = L-CX AND WS-CZ = L-CZ
             COMPUTE WS-TRIG = CW-TICKS + BT-SV-DELAY(WS-I)
             CALL "BT-ADD" USING L-DIM L-TYPE BT-SV-ID(WS-I) BT-SV-X(WS-I) BT-SV-Y(WS-I) BT-SV-Z(WS-I) WS-TRIG
                 BT-SV-PRIO(WS-I) WS-SUB WS-RESULT
             ADD 1 TO WS-SUB
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-UNPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-CLEAR-AREA.
*> USING dimension row, x1, y1, z1, x2, y2, z2 (BINARY-LONG): LevelTicks.clearArea, removes the pending ticks (both types) inside
*> the box (corners inclusive, either order).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-LOX                 BINARY-LONG.
 01 WS-HIX                 BINARY-LONG.
 01 WS-LOY                 BINARY-LONG.
 01 WS-HIY                 BINARY-LONG.
 01 WS-LOZ                 BINARY-LONG.
 01 WS-HIZ                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2.
     COMPUTE WS-LOX = FUNCTION MIN(L-X1, L-X2)
     COMPUTE WS-HIX = FUNCTION MAX(L-X1, L-X2)
     COMPUTE WS-LOY = FUNCTION MIN(L-Y1, L-Y2)
     COMPUTE WS-HIY = FUNCTION MAX(L-Y1, L-Y2)
     COMPUTE WS-LOZ = FUNCTION MIN(L-Z1, L-Z2)
     COMPUTE WS-HIZ = FUNCTION MAX(L-Z1, L-Z2)
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-X(WS-I) >= WS-LOX AND BT-T-X(WS-I) <= WS-HIX
                 AND BT-T-Y(WS-I) >= WS-LOY AND BT-T-Y(WS-I) <= WS-HIY
                 AND BT-T-Z(WS-I) >= WS-LOZ AND BT-T-Z(WS-I) <= WS-HIZ
             CALL "BT-POLL" USING WS-I
         ELSE
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-CLEAR-AREA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BT-COPY-AREA.
*> USING dimension row, x1, y1, z1, x2, y2, z2, dx, dy, dz (BINARY-LONG): LevelTicks.copyArea, copies the pending ticks inside
*> the box to the position plus the offset with their remaining delay and priority and a fresh sub-tick order (an existing tick
*> of that identity stays).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LOX                 BINARY-LONG.
 01 WS-HIX                 BINARY-LONG.
 01 WS-LOY                 BINARY-LONG.
 01 WS-HIY                 BINARY-LONG.
 01 WS-LOZ                 BINARY-LONG.
 01 WS-HIZ                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X2                   BINARY-LONG.
 01 L-Y2                   BINARY-LONG.
 01 L-Z2                   BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2 L-DX L-DY L-DZ.
     COMPUTE WS-LOX = FUNCTION MIN(L-X1, L-X2)
     COMPUTE WS-HIX = FUNCTION MAX(L-X1, L-X2)
     COMPUTE WS-LOY = FUNCTION MIN(L-Y1, L-Y2)
     COMPUTE WS-HIY = FUNCTION MAX(L-Y1, L-Y2)
     COMPUTE WS-LOZ = FUNCTION MIN(L-Z1, L-Z2)
     COMPUTE WS-HIZ = FUNCTION MAX(L-Z1, L-Z2)
     MOVE BT-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-X(WS-I) >= WS-LOX AND BT-T-X(WS-I) <= WS-HIX
                 AND BT-T-Y(WS-I) >= WS-LOY AND BT-T-Y(WS-I) <= WS-HIY
                 AND BT-T-Z(WS-I) >= WS-LOZ AND BT-T-Z(WS-I) <= WS-HIZ
             COMPUTE WS-X = BT-T-X(WS-I) + L-DX
             COMPUTE WS-Y = BT-T-Y(WS-I) + L-DY
             COMPUTE WS-Z = BT-T-Z(WS-I) + L-DZ
             MOVE BT-SUB-COUNT(L-DIM) TO WS-SUB
             ADD 1 TO BT-SUB-COUNT(L-DIM)
             CALL "BT-ADD" USING L-DIM BT-T-TYPE(WS-I) BT-T-ID(WS-I) WS-X WS-Y WS-Z BT-T-TRIG(WS-I)
                 BT-T-PRIO(WS-I) WS-SUB WS-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BT-COPY-AREA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-CLASS.
*> USING state, class out (BINARY-LONG): what a state adds to the section counts of 29 section 5: 0 for air; otherwise 1 (not
*> air) plus 2 when its block is randomly ticking (rule kind 11), 4 when it holds a non-empty fluid (kind 12) and 8 when that
*> fluid is randomly ticking (kind 13).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-11                   BINARY-LONG VALUE 11.
 01 K-12                   BINARY-LONG VALUE 12.
 01 K-13                   BINARY-LONG VALUE 13.
 01 WS-MARK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CLASS.
     MOVE 0 TO L-CLASS
     IF L-STATE NOT = 0
         MOVE 1 TO L-CLASS
         CALL "BU-MARKED" USING K-11 L-STATE WS-MARK
         IF WS-MARK = 1
             ADD 2 TO L-CLASS
         END-IF
         CALL "BU-MARKED" USING K-12 L-STATE WS-MARK
         IF WS-MARK = 1
             ADD 4 TO L-CLASS
         END-IF
         CALL "BU-MARKED" USING K-13 L-STATE WS-MARK
         IF WS-MARK = 1
             ADD 8 TO L-CLASS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BR-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ADD-CLASS.
*> USING row, section (1-based), class, sign (BINARY-LONG; 1 or -1, or the number of states with a minus for removing them): adds or removes
*> states of that class (BR-CLASS) to the counts of the section.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCOUNT.
 01 WS-BITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-SIGN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SECTION L-CLASS L-SIGN.
     IF L-CLASS > 0
         ADD L-SIGN TO BR-NONEMPTY(L-ROW, L-SECTION)
         COMPUTE WS-BITS = (FUNCTION MOD(L-CLASS, 4) - FUNCTION MOD(L-CLASS, 2)) / 2
         COMPUTE BR-TICKING-BLOCKS(L-ROW, L-SECTION) = BR-TICKING-BLOCKS(L-ROW, L-SECTION) + WS-BITS * L-SIGN
         COMPUTE WS-BITS = FUNCTION MOD(L-CLASS, 8) - FUNCTION MOD(L-CLASS, 4)
         COMPUTE WS-BITS = WS-BITS / 4
         COMPUTE BR-FLUID(L-ROW, L-SECTION) = BR-FLUID(L-ROW, L-SECTION) + WS-BITS * L-SIGN
         COMPUTE WS-BITS = (L-CLASS - FUNCTION MOD(L-CLASS, 8)) / 8
         COMPUTE BR-TICKING-FLUIDS(L-ROW, L-SECTION) = BR-TICKING-FLUIDS(L-ROW, L-SECTION) + WS-BITS * L-SIGN
     END-IF
     GOBACK.
 END PROGRAM BR-ADD-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-ADJUST.
*> USING row, section (1-based), old state, new state (BINARY-LONG): a state was written in the section (29 section 5, 2.1 step 3):
*> the previous state decrements the counts it qualified for, the new one increments them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS               BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE -1.
 01 WS-UP                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SECTION L-OLD L-NEW.
     CALL "BR-CLASS" USING L-OLD WS-CLASS
     CALL "BR-ADD-CLASS" USING L-ROW L-SECTION WS-CLASS WS-DOWN
     CALL "BR-CLASS" USING L-NEW WS-CLASS
     CALL "BR-ADD-CLASS" USING L-ROW L-SECTION WS-CLASS WS-UP
     GOBACK.
 END PROGRAM BR-ADJUST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-COUNT-ROW.
*> USING row (BINARY-LONG): establishes the section counts of a chunk that was just loaded or generated, by counting its cells
*> (each distinct state is classified once). The cells of a section are tallied by class in a small table and added to the counts
*> once per class (BR-ADD-CLASS takes the number of states as its sign), not once per cell: a chunk arriving from a generation
*> worker is installed inside a tick.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY BRCOUNT.
 01 WS-CACHE               PIC X(40001).
 01 WS-CELL                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TALLY-TABLE.
    05 WS-TALLY            BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     INITIALIZE BR-ROW(L-ROW)
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE ALL "~" TO WS-CACHE
     COMPUTE WS-SECTIONS = DM-HEIGHT(CK-DIM(L-ROW)) / 16
     PERFORM VARYING WS-SECTION FROM 1 BY 1 UNTIL WS-SECTION > WS-SECTIONS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
             MOVE 0 TO WS-TALLY(WS-K)
         END-PERFORM
         COMPUTE WS-FIRST = (WS-SECTION - 1) * 4096 + 1
         COMPUTE WS-LAST = WS-FIRST + 4095
         PERFORM VARYING WS-CELL FROM WS-FIRST BY 1 UNTIL WS-CELL > WS-LAST
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             IF WS-STATE NOT = 0
                 IF WS-CACHE(WS-STATE + 1:1) = "~"
                     CALL "BR-CLASS" USING WS-STATE WS-CLASS
                     MOVE FUNCTION CHAR(WS-CLASS + 49) TO WS-CACHE(WS-STATE + 1:1)
                 END-IF
                 COMPUTE WS-CLASS = FUNCTION ORD(WS-CACHE(WS-STATE + 1:1)) - 49
                 ADD 1 TO WS-TALLY(WS-CLASS + 1)
             END-IF
         END-PERFORM
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 16
             IF WS-TALLY(WS-K) > 0
                 COMPUTE WS-CLASS = WS-K - 1
                 CALL "BR-ADD-CLASS" USING L-ROW WS-SECTION WS-CLASS WS-TALLY(WS-K)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BR-COUNT-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-GET.
*> USING dimension row, chunk x, chunk z, section (0 = lowest), non-empty, ticking blocks, fluid, ticking fluid out (BINARY-LONG):
*> the counts of one loaded chunk's section (the chunk is loaded when it is not).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCOUNT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 01 L-NONEMPTY             BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-TICKING-FLUID        BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-SECTION L-NONEMPTY L-TICKING L-FLUID L-TICKING-FLUID.
     CALL "WORLD-CHUNK-LOAD" USING L-DIM L-CX L-CZ WS-ROW
     COMPUTE WS-SECTION = L-SECTION + 1
     MOVE BR-NONEMPTY(WS-ROW, WS-SECTION) TO L-NONEMPTY
     MOVE BR-TICKING-BLOCKS(WS-ROW, WS-SECTION) TO L-TICKING
     MOVE BR-FLUID(WS-ROW, WS-SECTION) TO L-FLUID
     MOVE BR-TICKING-FLUIDS(WS-ROW, WS-SECTION) TO L-TICKING-FLUID
     GOBACK.
 END PROGRAM BR-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-VISIT.
*> USING row, section (0 = lowest), visited out (BINARY-LONG): 1 when the random-tick loop of 33 section 2.4 visits the section,
*> that is when its ticking block count or its ticking fluid count is above 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRCOUNT.
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 01 L-VISITED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SECTION L-VISITED.
     COMPUTE WS-SECTION = L-SECTION + 1
     MOVE 0 TO L-VISITED
     IF BR-TICKING-BLOCKS(L-ROW, WS-SECTION) > 0 OR BR-TICKING-FLUIDS(L-ROW, WS-SECTION) > 0
         MOVE 1 TO L-VISITED
     END-IF
     GOBACK.
 END PROGRAM BR-VISIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RANDOM-TICK.
*> USING dimension row, x, y, z (BINARY-LONG): the random tick of one position (29 section 5): the state's randomTick (hook 8) when
*> its block is randomly ticking, then the fluid's (hook 11) when that is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 K-8                    BINARY-LONG VALUE 8.
 01 K-11B                  BINARY-LONG VALUE 11.
 01 K-11                   BINARY-LONG VALUE 11.
 01 K-13                   BINARY-LONG VALUE 13.
 01 WS-STATE               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BU-MARKED" USING K-11B WS-STATE WS-MARK
     IF WS-MARK = 1
         CALL "BU-HOOK" USING K-8 L-DIM L-X L-Y L-Z WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     END-IF
     CALL "BU-MARKED" USING K-13 WS-STATE WS-MARK
     IF WS-MARK = 1
         CALL "BU-HOOK" USING K-11 L-DIM L-X L-Y L-Z WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     END-IF
     GOBACK.
 END PROGRAM BR-RANDOM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-RANDOM-TICK-ROW.
*> USING dimension row, chunk row, x, y, z (BINARY-LONG; the position lies in that chunk): BR-RANDOM-TICK for a position of a loaded chunk
*> row, without the world lookup, and with the marks of a state (BU-MARKED walks every rule) kept for the run of the random ticks:
*> chunk row 0 forgets them (WORLDSIM-RANDOM does it before each run, so rules added between runs count).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 K-8                    BINARY-LONG VALUE 8.
 01 K-11B                  BINARY-LONG VALUE 11.
 01 K-11                   BINARY-LONG VALUE 11.
 01 K-13                   BINARY-LONG VALUE 13.
 01 WS-CACHE               PIC X(65536).
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW L-X L-Y L-Z.
     IF L-ROW = 0
         MOVE ALL "~" TO WS-CACHE
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - CK-Z(L-ROW) * 16) * 16 + L-X - CK-X(L-ROW) * 16 + 1
     MOVE CE-STATE(WS-CELL) TO WS-STATE
*>   The marks of the state: 1 the block ticks, 2 the fluid ticks (kept as the characters 0 to 3).
     IF WS-CACHE(WS-STATE + 1:1) = "~"
         MOVE 0 TO WS-BITS
         CALL "BU-MARKED" USING K-11B WS-STATE WS-MARK
         IF WS-MARK = 1
             ADD 1 TO WS-BITS
         END-IF
         CALL "BU-MARKED" USING K-13 WS-STATE WS-MARK
         IF WS-MARK = 1
             ADD 2 TO WS-BITS
         END-IF
         MOVE FUNCTION CHAR(WS-BITS + 49) TO WS-CACHE(WS-STATE + 1:1)
     END-IF
     COMPUTE WS-BITS = FUNCTION ORD(WS-CACHE(WS-STATE + 1:1)) - 49
     IF WS-BITS = 1 OR WS-BITS = 3
         CALL "BU-HOOK" USING K-8 L-DIM L-X L-Y L-Z WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     END-IF
     IF WS-BITS = 2 OR WS-BITS = 3
         CALL "BU-HOOK" USING K-11 L-DIM L-X L-Y L-Z WS-STATE WS-ZERO WS-ZERO2 WS-OUT
     END-IF
     GOBACK.
 END PROGRAM BR-RANDOM-TICK-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-ADD.
*> USING dimension row, x, y, z, block id, parameter a, parameter b (BINARY-LONG): ServerLevel.blockEvent (29 section 6): the event
*> is appended to the pending set unless an event equal in all seven fields is already there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKEVT.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCK L-A L-B.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-COUNT
         IF BE-E-DIM(WS-I) = L-DIM AND BE-E-X(WS-I) = L-X AND BE-E-Y(WS-I) = L-Y AND BE-E-Z(WS-I) = L-Z
                 AND BE-E-BLOCK(WS-I) = L-BLOCK AND BE-E-A(WS-I) = L-A AND BE-E-B(WS-I) = L-B
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         ADD 1 TO BE-COUNT
         MOVE L-DIM TO BE-E-DIM(BE-COUNT)
         MOVE L-X TO BE-E-X(BE-COUNT)
         MOVE L-Y TO BE-E-Y(BE-COUNT)
         MOVE L-Z TO BE-E-Z(BE-COUNT)
         MOVE L-BLOCK TO BE-E-BLOCK(BE-COUNT)
         MOVE L-A TO BE-E-A(BE-COUNT)
         MOVE L-B TO BE-E-B(BE-COUNT)
     END-IF
     GOBACK.
 END PROGRAM BE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-FIRST.
*> USING dimension row, index out (BINARY-LONG): the first pending event of the level, 0 when it has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKEVT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-COUNT OR L-INDEX > 0
         IF BE-E-DIM(WS-I) = L-DIM
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-RUN.
*> USING dimension row (BINARY-LONG): ServerLevel.runBlockEvents (29 section 6): while the level has an event, the first one is
*> removed; when its chunk is block-ticking it is handled (the block must still be at the position, then hook 10 answers whether it
*> was handled: true broadcasts a Block Event packet, id 7, within 64.0 of the corner) and otherwise it goes on a reschedule list.
*> Events added while the loop runs are handled in the same loop; the reschedule list is appended to the set afterwards.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKEVT.
 COPY CBLOCKS.
 COPY PROTO.
 01 K-10                   BINARY-LONG VALUE 10.
 01 WS-PACKET-ID           BINARY-LONG VALUE 7.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-LATER.
    05 WS-L-EVENT OCCURS 4096 TIMES.
       10 WS-L-DIM         BINARY-LONG.
       10 WS-L-X           BINARY-LONG.
       10 WS-L-Y           BINARY-LONG.
       10 WS-L-Z           BINARY-LONG.
       10 WS-L-BLOCK       BINARY-LONG.
       10 WS-L-A           BINARY-LONG.
       10 WS-L-B           BINARY-LONG.
 01 WS-LATER-COUNT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-EVENT.
    05 WS-E-DIM            BINARY-LONG.
    05 WS-E-X              BINARY-LONG.
    05 WS-E-Y              BINARY-LONG.
    05 WS-E-Z              BINARY-LONG.
    05 WS-E-BLOCK          BINARY-LONG.
    05 WS-E-A              BINARY-LONG.
    05 WS-E-B              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TICKING             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     MOVE 0 TO WS-LATER-COUNT
     CALL "BE-FIRST" USING L-DIM WS-FIRST
     PERFORM UNTIL WS-FIRST = 0
         MOVE BE-EVENT(WS-FIRST) TO WS-EVENT
         PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I >= BE-COUNT
             MOVE BE-EVENT(WS-I + 1) TO BE-EVENT(WS-I)
         END-PERFORM
         SUBTRACT 1 FROM BE-COUNT
         COMPUTE WS-CX = (WS-E-X - FUNCTION MOD(WS-E-X, 16)) / 16
         COMPUTE WS-CZ = (WS-E-Z - FUNCTION MOD(WS-E-Z, 16)) / 16
         CALL "BT-CHUNK-TICKS" USING L-DIM WS-CX WS-CZ WS-TICKING
         IF WS-TICKING = 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-E-X WS-E-Y WS-E-Z WS-STATE
             MOVE 0 TO WS-HANDLED
             IF CB-S-BLOCK(WS-STATE + 1) = WS-E-BLOCK
                 CALL "BU-HOOK" USING K-10 L-DIM WS-E-X WS-E-Y WS-E-Z WS-STATE WS-E-A WS-E-B WS-HANDLED
             END-IF
             IF WS-HANDLED = 1
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
                 CALL "PB-PUT-BLOCK-EVENT" USING PB-BUFFER WS-E-X WS-E-Y WS-E-Z WS-E-A WS-E-B WS-E-BLOCK
                 CALL "LEVEL-BROADCAST" USING L-DIM WS-E-X WS-E-Y WS-E-Z WS-NONE PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
             END-IF
         ELSE
             ADD 1 TO WS-LATER-COUNT
             MOVE WS-EVENT TO WS-L-EVENT(WS-LATER-COUNT)
         END-IF
         CALL "BE-FIRST" USING L-DIM WS-FIRST
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LATER-COUNT
         ADD 1 TO BE-COUNT
         MOVE WS-L-EVENT(WS-I) TO BE-EVENT(BE-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM BE-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-MARK.
*> USING dimension row, x, y, z, recorded out (BINARY-LONG): ServerChunkCache.blockChanged (29 section 7.1): when the chunk ticks (a
*> holder with a ticking chunk) the section-relative position (x << 8 | z << 4 | y, 12 bits) joins the section's set of changed
*> positions (a set: a repeat adds nothing). Result 1 when the chunk ticks, else 0 and no record.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BCHANGE.
 COPY DIMENSIONS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RECORDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RECORDED.
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "BT-CHUNK-TICKS" USING L-DIM WS-CX WS-CZ L-RECORDED
     IF L-RECORDED = 1
         COMPUTE WS-OFFSET = L-Y - DM-MIN-Y(L-DIM)
         COMPUTE WS-SEC = (WS-OFFSET - FUNCTION MOD(WS-OFFSET, 16)) / 16
         COMPUTE WS-POS = FUNCTION MOD(L-X, 16) * 256 + FUNCTION MOD(L-Z, 16) * 16 + FUNCTION MOD(WS-OFFSET, 16)
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BC-COUNT
             IF BC-DIM(WS-I) = L-DIM AND BC-CX(WS-I) = WS-CX AND BC-CZ(WS-I) = WS-CZ AND BC-SEC(WS-I) = WS-SEC
                     AND BC-POS(WS-I) = WS-POS
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             ADD 1 TO BC-COUNT
             MOVE L-DIM TO BC-DIM(BC-COUNT)
             MOVE WS-CX TO BC-CX(BC-COUNT)
             MOVE WS-CZ TO BC-CZ(BC-COUNT)
             MOVE WS-SEC TO BC-SEC(BC-COUNT)
             MOVE WS-POS TO BC-POS(BC-COUNT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BC-MARK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-LOWEST-SECTION.
*> USING dimension row, chunk x, chunk z, section out (BINARY-LONG): the lowest section of that chunk that has changed positions, -1
*> when it has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BCHANGE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-LOW.
     MOVE -1 TO L-LOW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BC-COUNT
         IF BC-DIM(WS-I) = L-DIM AND BC-CX(WS-I) = L-CX AND BC-CZ(WS-I) = L-CZ
                 AND (L-LOW < 0 OR BC-SEC(WS-I) < L-LOW)
             MOVE BC-SEC(WS-I) TO L-LOW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BC-LOWEST-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-BROADCAST.
*> No parameters: ChunkHolder.broadcastChanges for every holder (29 section 7.2). Per chunk, its sections from the bottom: one changed
*> position sends a Block Update with the state the level holds now, two or more one Section Blocks Update (id 86) whose entries
*> take their states from the level now; the sets are then cleared. (Block entity data follows only for states with a block entity:
*> 29 section 12 has none in this world; light changes travel with the write, LIGHT-SET-BLOCK.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BCHANGE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-MIN-SECTION         BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-ENTRIES.
    05 WS-ENTRY OCCURS 4096 TIMES.
       10 WS-E-X           BINARY-LONG.
       10 WS-E-Y           BINARY-LONG.
       10 WS-E-Z           BINARY-LONG.
       10 WS-E-STATE       BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     PERFORM UNTIL BC-COUNT = 0
         MOVE BC-DIM(1) TO WS-DIM
         MOVE BC-CX(1) TO WS-CX
         MOVE BC-CZ(1) TO WS-CZ
         CALL "BC-LOWEST-SECTION" USING WS-DIM WS-CX WS-CZ WS-LOW
         PERFORM UNTIL WS-LOW < 0
             MOVE 0 TO WS-N
             MOVE 1 TO WS-I
             PERFORM UNTIL WS-I > BC-COUNT
                 IF BC-DIM(WS-I) = WS-DIM AND BC-CX(WS-I) = WS-CX AND BC-CZ(WS-I) = WS-CZ AND BC-SEC(WS-I) = WS-LOW
                     ADD 1 TO WS-N
                     COMPUTE WS-X = WS-CX * 16 + (BC-POS(WS-I) - FUNCTION MOD(BC-POS(WS-I), 256)) / 256
                     COMPUTE WS-LOCAL = FUNCTION MOD(BC-POS(WS-I), 256)
                     COMPUTE WS-Z = WS-CZ * 16 + (WS-LOCAL - FUNCTION MOD(WS-LOCAL, 16)) / 16
                     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) + WS-LOW * 16 + FUNCTION MOD(WS-LOCAL, 16)
                     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
                     COMPUTE WS-E-X(WS-N) = FUNCTION MOD(WS-X, 16)
                     COMPUTE WS-E-Y(WS-N) = FUNCTION MOD(WS-Y - DM-MIN-Y(WS-DIM), 16)
                     COMPUTE WS-E-Z(WS-N) = FUNCTION MOD(WS-Z, 16)
                     MOVE WS-STATE TO WS-E-STATE(WS-N)
                     MOVE BC-ENTRY(BC-COUNT) TO BC-ENTRY(WS-I)
                     SUBTRACT 1 FROM BC-COUNT
                 ELSE
                     ADD 1 TO WS-I
                 END-IF
             END-PERFORM
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             IF WS-N = 1
                 CALL "BLOCK-UPDATE-BUILD" USING WS-X WS-Y WS-Z WS-STATE PB-BUFFER
             ELSE
                 COMPUTE WS-MIN-SECTION = DM-MIN-Y(WS-DIM) / 16
                 COMPUTE WS-SY = WS-MIN-SECTION + WS-LOW
                 CALL "SECTION-BLOCKS-UPDATE-BUILD" USING WS-CX WS-SY WS-CZ WS-N WS-ENTRIES PB-BUFFER
             END-IF
             CALL "VIEWERS-SEND" USING WS-DIM WS-CX WS-CZ WS-NONE PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             CALL "BC-LOWEST-SECTION" USING WS-DIM WS-CX WS-CZ WS-LOW
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BC-BROADCAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-ACK-SET.
*> USING connection id, sequence, accepted out (BINARY-LONG): ackBlockChangesUpTo (29 section 7.3): the highest sequence seen is
*> kept; a negative sequence is rejected (result 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BCHANGE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 01 L-ACCEPTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SEQUENCE L-ACCEPTED.
     MOVE 0 TO L-ACCEPTED
     IF L-SEQUENCE >= 0
         MOVE 1 TO L-ACCEPTED
         IF L-SEQUENCE + 1 > BC-ACK(L-ID)
             COMPUTE BC-ACK(L-ID) = L-SEQUENCE + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BC-ACK-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BC-ACK-TICK.
*> USING connection id (BINARY-LONG): the start of ServerGamePacketListenerImpl.tick (29 section 7.3): a stored sequence is sent as
*> Block Changed Ack and reset.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BCHANGE.
 01 WS-SEQUENCE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     IF BC-ACK(L-ID) > 0
         COMPUTE WS-SEQUENCE = BC-ACK(L-ID) - 1
         MOVE 0 TO BC-ACK(L-ID)
         CALL "BLOCK-ACK" USING L-ID WS-SEQUENCE
     END-IF
     GOBACK.
 END PROGRAM BC-ACK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IR-PROPERTIES.
*> USING result (INTERACT.cpy), kind out, consumes out, swings out, send to self out (BINARY-LONG): the table of 29 section 8. Kind
*> 1 Success, 2 Fail, 3 Pass, 4 TryEmptyHandInteraction. A Success consumes the action; it swings the arm unless its swing source is
*> NONE (CONSUME); the swing is sent to the acting player's own client unless the source is PREDICTED (SUCCESS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-CONSUMES             BINARY-LONG.
 01 L-SWINGS               BINARY-LONG.
 01 L-SELF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-KIND L-CONSUMES L-SWINGS L-SELF.
     MOVE 0 TO L-CONSUMES L-SWINGS
     MOVE 1 TO L-SELF
     EVALUATE L-RESULT
         WHEN IR-SUCCESS
             MOVE 1 TO L-KIND L-CONSUMES L-SWINGS
             MOVE 0 TO L-SELF
         WHEN IR-SUCCESS-SERVER
             MOVE 1 TO L-KIND L-CONSUMES L-SWINGS
         WHEN IR-CONSUME
             MOVE 1 TO L-KIND L-CONSUMES
         WHEN IR-FAIL
             MOVE 2 TO L-KIND
         WHEN IR-PASS
             MOVE 3 TO L-KIND
         WHEN OTHER
             MOVE 4 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM IR-PROPERTIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IR-ITEM-CONTEXT.
*> USING result, item interaction out (BINARY-LONG): the item context of a Success: 1 (wasItemInteraction, the default) for SUCCESS
*> and SUCCESS_SERVER, 0 for CONSUME (the NONE context) and for the results that are not a Success.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY INTERACT.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-ITEM.
     MOVE 0 TO L-ITEM
     IF L-RESULT = IR-SUCCESS OR L-RESULT = IR-SUCCESS-SERVER
         MOVE 1 TO L-ITEM
     END-IF
     GOBACK.
 END PROGRAM IR-ITEM-CONTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. IR-WITHOUT-ITEM.
*> USING result, item interaction out (BINARY-LONG): withoutItem(): the same result with the NONE item context, so 0 whatever the result.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-ITEM.
     MOVE 0 TO L-ITEM
     GOBACK.
 END PROGRAM IR-WITHOUT-ITEM.
